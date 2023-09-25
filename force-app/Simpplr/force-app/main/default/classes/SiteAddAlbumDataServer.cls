public with sharing class SiteAddAlbumDataServer extends ContentDataServer {
	private AlbumDao albumDaoObj;
	private final String ACTION_VALUE_PUBLISH = 'publish';
	private final String ACTION_VALUE_DRAFT = 'saveDraft';
	private final String ACTION_VALUE_UPDATE_DRAFT = 'updateDraft';
	private final String ACTION_VALUE_UPDATE = 'update';
	private final String ACTION_VALUE_APPROVE = 'approve';
	private final String ACTION_VALUE_GET = 'get'; 
	private final String ACTION_VALUE_ADD_VIDEO = 'addVideo';
    private final String REQUEST_PARAM_DATA = 'data';
    private final String ACTION_VALUE_ADD_PHOTO = 'addPhoto';
    private final String ACTION_VALUE_SUBMIT_MEDIA = 'submitMedia';
    private final String ACTION_START_CONTENT_EDIT = 'startContentEdit';
    private Boolean hasContentApprovalAccess;
    private Integer totalImageCount = 0;
	private Integer totalVideoCount = 0;
	private final String CONTENT_LASTMODIFIEDDATETIMESTAMP = 'lastModifiedDateTimeStamp';
	private DateTime currentDateTime = DateTime.now();
	private String loggedInPeopleId = UserContext.peopleId;
	
    public SiteAddAlbumDataServer(){
    	albumDaoObj = new AlbumDao();
    }
    
    public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
     public override void handleRequest() {

    	try {
    		logger.logDebug('SiteAddAlbumDataServer.handleRequest()----Start----');
            String action = readParam(REQUEST_PARAM_ACTION);
            String requestData = readParam(REQUEST_PARAM_DATA);
        	
			if (String.isBlank(requestData)) {
	            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
	        }

	        if (ACTION_VALUE_ADD_VIDEO.equalsIgnoreCase(action)) { 
            	response = addVideo(readParam(REQUEST_PARAM_DATA));
            
            } else if (ACTION_VALUE_ADD_PHOTO.equalsIgnoreCase(action)) { 
            		response = addPhoto(readParam(REQUEST_PARAM_DATA));
            
            } else if (ACTION_VALUE_SUBMIT_MEDIA.equalsIgnoreCase(action)) {
            		response = submitMedia(readParam(REQUEST_PARAM_DATA));

			} else if (ACTION_VALUE_GET.equalsIgnoreCase(action)){
					if(String.isNotBlank(readParam('versionHistoryId'))){
						response = getAlbumByVersionHistoryId(readSafeParam('contentId'), readSafeParam('versionHistoryId'));
	
					} else {
						response = getContent(readParam('contentId'));
	
					}
						
            } else if(ACTION_START_CONTENT_EDIT.equalsIgnoreCase(action)){
				response = startContentEdit(requestData);

			} else {
				Utility.isContentEditFromContentDetailPage = true;
	            hasContentApprovalAccess = AccessManager.hasContentApprovalAccess(); 
	            
	        	if (ACTION_VALUE_PUBLISH.equalsIgnoreCase(action)) {
					response = hasContentApprovalAccess ? publish(requestData) : submitForApproval(requestData);
	
	            } else if (ACTION_VALUE_DRAFT.equalsIgnoreCase(action)) {
					response = draft(requestData);
	            
	            } else if (ACTION_VALUE_UPDATE_DRAFT.equalsIgnoreCase(action)) {
					response = updateDraft(requestData);

				} else if (ACTION_VALUE_APPROVE.equalsIgnoreCase(action) && hasContentApprovalAccess) {
						response = publish(requestData);
						
	            } else if (ACTION_VALUE_UPDATE.equalsIgnoreCase(action)) {
					response = hasContentApprovalAccess ? updateAlbum(requestData) : submitForApproval(requestData); 
	            	
	            } else {
					throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
	            }

	        }
            
        } catch (Exception ex) {
			logger.logError('SiteAddAlbumDataServer.handleRequest()---Exception occured----', ex);
			response = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
	}
	
	@TestVisible
	private ResponseWrapper startContentEdit(String requestData){
		logger.logDebug('AllContentDataServer.startContentEdit()---data---' + requestData);
		ResponseWrapper resultWrapper = New ResponseWrapper();

		Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(requestData);
		String contentId = (String) requestDataMap.get('contentId');
		Integer versionNumber = (Integer) requestDataMap.get('versionNumber');

		if(!checkContentModerationAccess(contentId)){
			throw new SimpplrException(ServiceConstants.ERROR_404);
		}

		ContentLockWrapper contentLockWrapperObj = new ContentLockWrapper();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', contentId);
		String lockStatusQuery = 'SELECT Id, Content__r.Version__c, Last_Renew_DateTime__c, ' +
			' Start_DateTime__c, Locked_By_People__c FROM Content_Lock_Status__c ' +
			' WHERE Content__c =:soqlParam1 ' +
			' ORDER BY LastModifiedDate DESC LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Content_Lock_Status__c> contentLockStatusList = (List<Content_Lock_Status__c>)SIMPESAPI.accessController().queryAsUser(lockStatusQuery, soqlParamMap);

		if(!contentLockStatusList.isEmpty()){
			// Check if lock is still alive
			if(contentLockStatusList[0].Last_Renew_DateTime__c >= currentDateTime.addSeconds(-90)){
				// Content was locked 

				contentLockWrapperObj.isLocked = true;
				contentLockWrapperObj.lockedBy = getPeopleListWrapper(contentLockStatusList[0].Locked_By_People__c);
				
				// Content was locked so no need to create content wrapper.
				contentLockWrapperObj.content = null;

			} else {
				// Content is not locked

				contentLockWrapperObj.isLocked = false;															
			}
		} else {
			// If list is empty then there wasn't any lock
			
			contentLockWrapperObj.isLocked = false;
		}
		
		if(contentLockWrapperObj.isLocked == false){
			// Create lock on this content for current user
			Content_Lock_Status__c contentLockStatusObj = new Content_Lock_Status__c();
			contentLockStatusObj.Content__c = contentId;
			contentLockStatusObj.Last_Renew_DateTime__c = currentDateTime;
			contentLockStatusObj.Start_DateTime__c = currentDateTime;
			contentLockStatusObj.Locked_By_People__c = UserContext.peopleId;

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	        SIMPESAPI.accessController().insertAsUser(contentLockStatusObj, new List<Schema.SObjectField>{
																			Content_Lock_Status__c.Content__c,
																			Content_Lock_Status__c.Last_Renew_DateTime__c,
																			Content_Lock_Status__c.Start_DateTime__c,
																			Content_Lock_Status__c.Locked_By_People__c});

			contentLockWrapperObj.lockedBy = getPeopleListWrapper(UserContext.peopleId);

			// Check if the version is same then do not send content wrapper
			contentLockWrapperObj.content = null;

			String query = 'SELECT '+ String.join(getAlbumFieldList(),',') +' FROM Simpplr_Content__c where id=:contentId ';
			List<Simpplr_Content__c> contentList = Database.query(query); 
			if(!contentList.isEmpty() && versionNumber != contentList[0].Version__c){
                contentLockWrapperObj.content = convertToContentWrapper(contentList[0]);
                // This is to handle existing content records created before this change.
				ManageContentDao contentDoa = new ManageContentDao();
				contentDoa.checkAndCreateContentHistory(contentList[0], ServiceConstants.TYPE_ALBUM);
			}
			
		}
		
		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, contentLockWrapperObj);

		return resultWrapper;
    }
    
    private ResponseWrapper updateAlbum(String data) {
        ContentWrapper localContWrapObj = ContentWrapper.parse(data);
        Boolean isContentPublishedBeforeUpdate = isContentPublished(localContWrapObj.id);

        ResponseWrapper resultObj = processContentData(data, ACTION_VALUE_UPDATE, null);
        
        if (resultObj.status == RESPONSE_STATUS_SUCCESS)  {
			ContentWrapper contWrapObj = new ContentWrapper();
			contWrapObj = ((ContentWrapper)(resultObj.result));
            
            if (!isContentPublishedBeforeUpdate  && 
                    contWrapObj.isPublished && !isTimeLineCreatedForContent(contWrapObj.id)) {
                String grpMentionStr = ''; 

                if ('Public'.equalsIgnoreCase(contWrapObj.site.access) || 
                        ('Private'.equalsIgnoreCase(contWrapObj.site.access) && 
                        UserContext.chatterGroupsIFollowIdSet.contains(contWrapObj.site.chatterGroupId))) {
                    grpMentionStr = '@[' + contWrapObj.site.chatterGroupId + ']';
                } 

                RecursionCheck.stopRecursion();
				if(SiteContext.isBroadcastSite && SiteContext.isCurrentUserSiteContentManager) {
					SiteDao siteDaoObj = new siteDao();
					siteDaoObj.ToggleMemberManager(contWrapObj.site.chatterGroupId ,UserContext.id,'Admin');
					FeedServiceProvider.createTimeLine(null, contWrapObj.id, contWrapObj.url, 
					    contWrapObj.title, grpMentionStr);

					siteDaoObj.ToggleMemberManager(contWrapObj.site.chatterGroupId ,UserContext.id,'Standard');
				}
				else {
			    	FeedServiceProvider.createTimeLine(null, contWrapObj.id, contWrapObj.url, 
					    contWrapObj.title, grpMentionStr);
				}

				if(SimpplrContext.isFeatureMicrosoftTeamsEnabledPhase2 && SiteContext.MicrosoftTeamsIntegrationEnabled){
					new MicrosoftTeamsHelper().getContentInfo(contWrapObj.id, 'album');
            	}

				if(SimpplrContext.isSlackPhase2FeatureEnabled && SimpplrContext.isSlackUpgraded && SiteContext.SlackIntegrationEnabled){
					new SlackHelper().getContentInfo(contWrapObj.id, null, '');
				}

            }
            
        }
        
        return resultObj;
    }
    
    private ResponseWrapper publish(String data) {
        ResponseWrapper resultObj = processContentData(data, ServiceConstants.CONTENT_STATUS_APPROVED, null);
		
		if (resultObj.status == RESPONSE_STATUS_SUCCESS)  {
			ContentWrapper contWrapObj = new ContentWrapper();
			contWrapObj = ((ContentWrapper)(resultObj.result));
            
            if (contWrapObj.isPublished ) {   
				publishTimeLine(contWrapObj);	
			}
		}
        return resultObj;
    }
    private void publishTimeLine(ContentWrapper contWrapObj) {
		String grpMentionStr = ''; 
		if (!'unlisted'.equalsIgnoreCase(contWrapObj.site.access)) {
			grpMentionStr = '@[' + contWrapObj.site.chatterGroupId + ']';
		}
		RecursionCheck.stopRecursion();
		if(SiteContext.isBroadcastSite && SiteContext.isCurrentUserSiteContentManager) {
			SiteDao siteDaoObj = new siteDao();
			siteDaoObj.ToggleMemberManager(contWrapObj.site.chatterGroupId ,UserContext.id,'Admin');
			FeedServiceProvider.createTimeLine(null, contWrapObj.id, contWrapObj.url, contWrapObj.title, grpMentionStr);
			siteDaoObj.ToggleMemberManager(contWrapObj.site.chatterGroupId ,UserContext.id,'Standard');
		}else if(SiteContext.isBroadcastSite && UserContext.isUserAppModerator){
			FeedServiceProvider.createTimeLineFeedForBroadcastSiteByAppModerators(contWrapObj.site.chatterGroupId, contWrapObj.id, contWrapObj.url, contWrapObj.title, grpMentionStr);
		}else {
			FeedServiceProvider.createTimeLine(null, contWrapObj.id, contWrapObj.url, contWrapObj.title, grpMentionStr);
		}
		if(SimpplrContext.isFeatureMicrosoftTeamsEnabledPhase2 && SiteContext.MicrosoftTeamsIntegrationEnabled){
			new MicrosoftTeamsHelper().getContentInfo(contWrapObj.id, 'album');
		}
		if(SimpplrContext.isSlackPhase2FeatureEnabled && SimpplrContext.isSlackUpgraded && SiteContext.SlackIntegrationEnabled){
			new SlackHelper().getContentInfo(contWrapObj.id, null, '');
		}
	
	}

    private ResponseWrapper draft(String data) {
        ResponseWrapper result = processContentData(data, ServiceConstants.CONTENT_STATUS_DRAFT, ServiceConstants.CONTENT_STATUS_CREATE_DRAFT);
        return result;
    }
    
     private ResponseWrapper updateDraft(String data) {
        ResponseWrapper result = processContentData(data, ServiceConstants.CONTENT_STATUS_DRAFT, ServiceConstants.CONTENT_STATUS_UPDATE_DRAFT);
        return result;
    }
    
    private ResponseWrapper submitForApproval(String data) {
        ResponseWrapper result = processContentData(data, ServiceConstants.CONTENT_STATUS_SUBMIITED, null);
        return result;
    }
     
    private ResponseWrapper addVideo(String data) {
    	 ResponseWrapper responseObj = new ResponseWrapper();
    	 Criteria.Album albumRequestObj = (Criteria.Album) JSON.deserialize(data, Criteria.Album.class);
    	 FileListingWrapper fileWrapperObj = new FileListingWrapper();
    	 
    	 if (albumRequestObj.Id != null) {
    	 	fileWrapperObj = FileContentProvider.addVideoToAlbum(albumRequestObj);
    	 	responseObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, fileWrapperObj);
        		
    	 } else {

    		throw new SimpplrException(ServiceConstants.ERROR_404);
    	 }
    	 
    	 return responseObj;
    }
    
    private ResponseWrapper submitMedia (String requestData) {
    	 ResponseWrapper responseObj = new ResponseWrapper();
    	 Map<String,Object> paramData = (Map<String,Object>)JSON.deserializeUntyped(requestData);
    	 String albumId = paramData.get('albumId')==null ? '':String.valueOf(paramData.get('albumId'));
    	 List<ContentWrapper.MediaWrapper> fileWrapperList = new List<ContentWrapper.MediaWrapper>();
    	
    	 if (paramData.get('albumMediaList')!= null) {
    	 	fileWrapperList =  (List<ContentWrapper.MediaWrapper>) JSON.deserialize((JSON.serialize(paramData.get('albumMediaList'))),List<ContentWrapper.MediaWrapper>.class);
    	 }
    	 
    	 if (String.isBlank(albumId) || fileWrapperList.isEmpty()) {
    	 	throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
    	 }
    	 
    	 if (albumId != null) {
    	 	FileContentProvider.submitMediaToAlbum(albumId,fileWrapperList);
    	 	responseObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);

    	 } else {
    	 	throw new SimpplrException(ServiceConstants.ERROR_404);
    	 }
    	 
    	 return responseObj;
    }
    
    private ResponseWrapper addPhoto (String data) {
    	 ResponseWrapper responseObj = new ResponseWrapper();
    	 Criteria.Album albumRequestObj = (Criteria.Album) JSON.deserialize(data, Criteria.Album.class);
    	 FileListingWrapper fileWrapperObj = new FileListingWrapper();
		
    	 if (albumRequestObj.Id != null) {
			if(albumRequestObj.fileContentVersionId == null || albumRequestObj.fileContentVersionId == ''){
				albumRequestObj.fileContentVersionId = getLatestContentVersionByContentDocumentId(albumRequestObj.fileContentDocId);
			}
    	 	albumRequestObj.photoUrl = Utility.getFileDownloadURL(albumRequestObj.fileContentVersionId);
    	 	albumRequestObj.thumbsnailUrl = Utility.getFileDownloadURLFor720By480(albumRequestObj.fileContentVersionId);
    	 	fileWrapperObj = FileContentProvider.addPhotoToAlbum(albumRequestObj);
    	 	responseObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, fileWrapperObj);
        		
    	 } else {
    		throw new SimpplrException(ServiceConstants.ERROR_404);
    	 }
    	 
    	 return responseObj;
    }

	private String getLatestContentVersionByContentDocumentId(String conentDocumentId){
		List<ContentVersion> cv = new List<ContentVersion>();
		cv = [SELECT id FROM ContentVersion WHERE ContentDocumentId = :conentDocumentId AND IsLatest = true WITH SECURITY_ENFORCED];
		if(cv!=null && cv.size()>0){
			return cv[0].id;
		}
		return null;
	}
    
	private ResponseWrapper processContentData(String data, String status, String draftType) {
		logger.logDebug('SiteAddAlbumDataServer.processContentData()----status----' + status);
		ResponseWrapper resultWrapper = new ResponseWrapper();
        ContentWrapper wrapperObj = ContentWrapper.parse(data);
		wrapperObj.status  = status ;
		wrapperObj.id = wrapperObj.id == null ? readParam('contentId') : wrapperObj.id;
		wrapperObj.siteId = wrapperObj.siteId == null ? SiteContext.siteId : wrapperObj.siteId;
		Boolean isEdit = String.isNotBlank(wrapperObj.id);
		
		String contentStatusOld = '';
		// Check if content update is there then pass exsiting content object to create history and trails
		Simpplr_Content__c content = ManageContentDao.getContentById(wrapperObj.id);
		if(content != null) {
			contentStatusOld = content.Status__c;		
		}
        
		//sanitize content data before DMLs
		if(wrapperObj.bodyJson!=null) {
			String sanitizedHTML = Utility.getSanitizedHTMLfromLambda(wrapperObj.body);
			wrapperObj.body = sanitizedHTML;
		}

        // Step 1: Create new topics or get existing topicId if topic exists already
        Map<String, String> mapOfNewTopics = createNewTopics(wrapperObj.listOfTopics, wrapperObj.listOfContentTopicIds);
        
        // Step 2: Save Album media
        if (isEdit && wrapperObj.listOfAlbumMedia != null && 
				wrapperObj.listOfAlbumMedia.isEmpty() == false) {
			saveAlbumMediaToDB(wrapperObj.id, wrapperObj.coverImageMediaId, 
					wrapperObj.listOfAlbumMedia);
        }
        
		// Step 3: Save Simpplr_Content__c record
		ContentTriggerHandler.isCalledFromEditContentScreen = true;
        Simpplr_Content__c contentObj = saveContentObjectToDB(isEdit, wrapperObj, mapOfNewTopics);
        
        // Step 4: Send approval notification if required
        if (isEdit && ServiceConstants.CONTENT_STATUS_APPROVED.equals(status)) {
			AllContentDataServer contentServerObj =  new AllContentDataServer();
    		contentServerObj.checkAndApproveNotifications(contentObj);
        }
        
        //Step 5: Save Folder__c record
        saveAlbumTitleToFolderNameInDB(isEdit, contentObj.id, wrapperObj.siteId, wrapperObj.title);

        // Step 6: Save File__c records
        saveContentFilesToDB(isEdit, contentObj.id, wrapperObj, status);
        
        // Step 7: Save TopicAssignment records
        saveTopicAssignmentsToDB(isEdit, contentObj.id, wrapperObj.listOfTopics, 
				wrapperObj.listOfContentTopicIds, mapOfNewTopics);
        
		List<ContentWrapper.SuggestedTopicsWrapper> listOfSuggestedTopics = null;
		// Save Suggested Topics from AI 
		if(wrapperObj.listOfSuggestedTopics != null ){
			saveAISuggestedTopicsToDB(wrapperObj.listOfSuggestedTopics, contentObj.id, wrapperObj.listOfTopics, mapOfNewTopics);
			listOfSuggestedTopics = wrapperObj.listOfSuggestedTopics;
		}

        if (SimpplrContext.isExternalSearchAppConnected) {
        	ManageContentDao.insertSearchTrailObjectForContentAsync(contentObj.id);
		}

		//Create content history record asynchronously
		if(ServiceConstants.CONTENT_STATUS_PREDRAFT.equalsIgnoreCase(contentStatusOld)) {
			if(ServiceConstants.CONTENT_STATUS_UPDATE_DRAFT.equalsIgnoreCase(draftType)){		
				ManageContentDao.createContentHistoryAndAuditRecordsAsync(contentObj.id, ServiceConstants.CONTENT_STATUS_CREATE_DRAFT, ServiceConstants.TYPE_ALBUM);

			} else if(ServiceConstants.CONTENT_STATUS_SUBMITTED.equalsIgnoreCase(status)) {	
				ManageContentDao.createContentHistoryAndAuditRecordsAsync(contentObj.id, ServiceConstants.CONTENT_STATUS_CREATE_DRAFT, ServiceConstants.TYPE_ALBUM);

			} else if(ACTION_VALUE_UPDATE.equalsIgnoreCase(status)) {
				ManageContentDao.createContentHistoryAndAuditRecordsAsync(contentObj.id, ServiceConstants.CONTENT_STATUS_APPROVED, ServiceConstants.TYPE_ALBUM);
			}

		} else if(ACTION_VALUE_UPDATE.equalsIgnoreCase(status)){
			ManageContentDao.createContentHistoryAndAuditRecordsAsync(contentObj.id, ServiceConstants.CONTENT_STATUS_UPDATE, ServiceConstants.TYPE_ALBUM);

		} else if(ServiceConstants.CONTENT_STATUS_UPDATE_DRAFT.equalsIgnoreCase(draftType)){				
			ManageContentDao.createContentHistoryAndAuditRecordsAsync(contentObj.id, ServiceConstants.CONTENT_STATUS_UPDATE_DRAFT, ServiceConstants.TYPE_ALBUM);

		} else if(ServiceConstants.CONTENT_STATUS_APPROVED.equalsIgnoreCase(status) && 
			ServiceConstants.CONTENT_STATUS_SUBMITTED.equalsIgnoreCase(contentStatusOld)) {
			ManageContentDao.createContentHistoryAndAuditRecordsAsync(contentObj.id, ServiceConstants.CONTENT_STATUS_UPDATE, ServiceConstants.TYPE_ALBUM);
		
		} else if(ServiceConstants.CONTENT_STATUS_SUBMITTED.equalsIgnoreCase(status)) {				
			ManageContentDao.createContentHistoryAndAuditRecordsAsync(contentObj.id, ServiceConstants.CONTENT_STATUS_UPDATE_DRAFT, ServiceConstants.TYPE_ALBUM);

		} 
		
        if (ServiceConstants.CONTENT_STATUS_SUBMIITED.equalsIgnoreCase(status)) {
			ManageContentDao daoObj = new ManageContentDao();
			daoObj.createContentAuditTrail(contentObj.id, status, null); 
			Map<String,App_Notification__c> userToNotificationMap = NotificationDao.generateReviewNotifications(contentObj.Id, ServiceConstants.TYPE_ALBUM, contentObj.title__c, contentObj.site__c, contentObj.Summary_1__c);
       		NotificationDispatcher.sendEmailForContentModeration(contentObj);
        }

        return getContent(contentObj.Id, listOfSuggestedTopics);
    }
    
    @testVisible 
	private void saveAlbumMediaToDB(Id contentId, String coverImageMediaId, 
		List<ContentWrapper.MediaWrapper> listOfAlbumMedia) {
		logger.logDebug('SiteAddAlbumDataServer.saveAlbumMediaToDB()----listOfAlbumMedia----' + listOfAlbumMedia);
		List<String> listOfFileIds = new List<String>();
		
		for (ContentWrapper.MediaWrapper wrapperObj : listOfAlbumMedia) {
			listOfFileIds.add(wrapperObj.id);
		}

		if (String.isBlank(coverImageMediaId)) {
			coverImageMediaId = listOfFileIds[0];
		}
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', contentId);
		soqlParamMap.put('soqlParam2', listOfFileIds);
		String filesQuery = 'SELECT Id, Order__c, Mime_Type__c,'+
				' Location__c,Is_Deleted__c,Title__c,External_Id__c, Description__c,Video_Provider__c, Is_Title_Image__c'+
				' FROM File__c'+
				' WHERE Location__c = \'media\''+
				' And Simpplr_Content__c=:soqlParam1'+
				' And (id=:soqlParam2 OR is_Deleted__c=false)';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		Map<Id, File__c> mapOfFiles = new Map<Id, File__c>((List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap));
		
		Integer index = listOfFileIds.size();
		List<File__c> listOfUpdatedFiles = new List<File__c>();
		File__c fileObj;
		
		for (ContentWrapper.MediaWrapper wrapperObj : listOfAlbumMedia) {
			fileObj = mapOfFiles.get(wrapperObj.id);
			
			if (fileObj.id == coverImageMediaId) {
				fileObj.Order__c = index;
				fileObj.is_Deleted__c=false;
				fileObj.Description__c = wrapperObj.description;
				fileObj.Is_Title_Image__c = true;
				listOfUpdatedFiles.add(fileObj);
				
			} else if (fileObj.Order__c != index || fileObj.is_Deleted__c || 
					fileObj.Is_Title_Image__c || fileObj.Description__c != wrapperObj.description) {
				fileObj.Order__c = index;
				fileObj.is_Deleted__c=false;
				fileObj.Description__c = wrapperObj.description;
				fileObj.Is_Title_Image__c = false;
				listOfUpdatedFiles.add(fileObj);
			}

			if ('image'.equalsIgnoreCase(fileObj.Mime_Type__c)) {
				totalImageCount++;

			} else {
				totalVideoCount++;
			}

			mapOfFiles.remove(wrapperObj.id);
			index--;
		}
		
		for (File__c fileOb : mapOfFiles.values()) {
			fileOb.is_Deleted__c = true;
			listOfUpdatedFiles.add(fileOb);
		}
		if(SimpplrContext.isNativeVideo && ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(fileObj.Video_Provider__c)){
			VideoDao.updateVideo(fileObj.Title__c,fileObj.External_Id__c,fileObj.Description__c, null) ;
		}
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id, File__c>(listOfUpdatedFiles), new List<Schema.SObjectField>{
														File__c.order__c,
														File__c.is_Deleted__c,
														File__c.Description__c,
														File__c.Is_Title_Image__c
													});
    }
    
    private void saveAlbumTitleToFolderNameInDB(Boolean isEdit, String contentId, 
			String siteId, String title) {
     	
		 if (isEdit) {
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', contentId);
			soqlParamMap.put('soqlParam2', siteId);
			String folderQuery = 'SELECT id, Name__c FROM Folder__c WHERE External_Folder_Id__c =:soqlParam1 and site__c =:soqlParam2 and Is_Deleted__c = false limit 1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Folder__c> listOfSavedFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
     		
			if (listOfSavedFolders.isEmpty() == false && 
					title.equalsIgnoreCase(listOfSavedFolders[0].name__c) == false) {
	     		listOfSavedFolders[0].name__c = title;
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<Id,Folder__c>(listOfSavedFolders), new List<Schema.SObjectField>{
					Folder__c.Name__c
				});
     		}
     	
     	} else { 
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', siteId);
			String folderQuery = 'SELECT Id, path__c FROM Folder__c WHERE Name__c =\'Albums\' and site__c =:soqlParam1 and Is_Deleted__c = false and Is_System_Folder__c = true';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Folder__c> parent = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
	        Folder__c folderObj	= new Folder__c();
	        folderObj.Name__c = title;
		    folderObj.Site__c = siteId;
		    folderObj.Is_System_Folder__c = false;
		    folderObj.Type__c = 'Intranet';
		    folderObj.Parent_Folder__c = parent[0].Id;
		    folderObj.Permissions__c = 'Read';
		    folderObj.External_Folder_Id__c = contentId;
		    folderObj.Is_Hidden__c = true;
	    	folderObj.path__c = String.isNotBlank(parent[0].path__c) ? 
					(parent[0].path__c + ',' +  parent[0].Id) : parent[0].Id;    	
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			folderObj = (Folder__c) SIMPESAPI.accessController().insertAsUser(folderObj, new List<Schema.SObjectField>{
					Folder__c.Name__c,
					Folder__c.Site__c,
					Folder__c.Is_System_Folder__c,
					Folder__c.Type__c,
					Folder__c.Parent_Folder__c,
					Folder__c.Permissions__c,
					Folder__c.External_Folder_Id__c,
					Folder__c.Is_Hidden__c,
					Folder__c.path__c
					});
			List<Folder__c> albumChildFolderList = new List<Folder__c>();
			albumChildFolderList.add(getAlbumChildFolder('Images', 'Intranet', folderObj));
			if(SimpplrContext.isNativeVideo) {
				albumChildFolderList.add(getAlbumChildFolder('Videos', 'native_video', folderObj));
			}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().insertAsUser(albumChildFolderList, new List<Schema.SObjectField>{
					Folder__c.Name__c,
					Folder__c.Site__c,
					Folder__c.Is_System_Folder__c,
					Folder__c.Type__c,
					Folder__c.Parent_Folder__c,
					Folder__c.Permissions__c,
					Folder__c.External_Folder_Id__c,
					Folder__c.Is_Hidden__c,
					Folder__c.path__c
					}); 
     	}

	}
	
	private Folder__c getAlbumChildFolder(String folderName, String provider, Folder__c parentFolder) {
		Folder__c folderObj	= new Folder__c();
		folderObj.Name__c = folderName;
		folderObj.Site__c = parentFolder.Site__c;
		folderObj.Is_System_Folder__c = false;
		folderObj.Type__c = provider;
		folderObj.Parent_Folder__c = parentFolder.id;
		folderObj.Permissions__c = 'Read';
		folderObj.Is_Hidden__c = true;
		folderObj.path__c = parentFolder.path__c + ',' + parentFolder.id;
		return folderObj;
	}
    
    private Simpplr_Content__c saveContentObjectToDB(Boolean isEdit, 
			ContentWrapper localWrapperObj, Map<String, String> mapOfNewTopics) {
    	Simpplr_Content__c contentObj;
		String oldAuthorId;
		String oldStatus;
		List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();

        if (isEdit) {
            contentObj = [SELECT Id, Type__c, Site__c, Status__c, Primary_Author__c, Is_Published__c,
					Primary_Author__r.Full_Name__c, Publish_Start_DateTime__c, Version__c,
					Primary_Author__r.Is_Protected_Author__c   
					FROM Simpplr_Content__c 
					WHERE id =: localWrapperObj.id 
					And Type__c =: ServiceConstants.TYPE_ALBUM
					And Site__c=: localWrapperObj.siteId WITH SECURITY_ENFORCED]; 

			oldStatus = contentObj.Status__c;

			// Update version		
			if(contentObj.Version__c != null){
				if(ServiceConstants.CONTENT_STATUS_PREDRAFT.equalsIgnoreCase(contentObj.Status__c) == false){
					contentObj.Version__c = contentObj.Version__c + 1;
					fieldList.add(Simpplr_Content__c.Version__c);
				}
			}

			if (!AccessManager.hasContentEditAccess(contentObj.Status__c, 
					Usercontext.peopleId.equalsIgnoreCase(contentObj.Primary_Author__c))) {
				throw new SimpplrException(ServiceConstants.ERROR_403);
				
			} else if(contentObj.Primary_Author__r.Is_Protected_Author__c && 
						(!UserContext.peopleId.equalsIgnoreCase(contentObj.Primary_Author__c) && 
						!UserContext.isProtectedAuthorAllowlisted && 
						!UserContext.isUserAppModerator)) {
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}
			
            if (ACTION_VALUE_UPDATE.equalsIgnoreCase(localWrapperObj.status)) {
            	
				if (ServiceConstants.CONTENT_STATUS_DRAFT.equalsIgnoreCase(contentObj.Status__c) || 
            			ServiceConstants.CONTENT_STATUS_PREDRAFT.equalsIgnoreCase(contentObj.Status__c)) {
            		contentObj.Status__c = hasContentApprovalAccess ? ServiceConstants.CONTENT_STATUS_APPROVED : ServiceConstants.CONTENT_STATUS_SUBMITTED;
            	} 

            } else {
            	contentObj.Status__c = localWrapperObj.status;
            }

        } else {

			Utility.checkForRateLimit('content');
			
	        contentObj = new Simpplr_Content__c();
	        contentObj.Type__c = ServiceConstants.TYPE_ALBUM;
			contentObj.Site__c = localWrapperObj.siteId;
			contentObj.Status__c = ServiceConstants.CONTENT_STATUS_PREDRAFT;

            fieldList.add(Simpplr_Content__c.Type__c);
            fieldList.add(Simpplr_Content__c.Site__c);
        }
        
		fieldList.add(Simpplr_Content__c.Status__c);

        contentObj.Title__c = localWrapperObj.title;
		fieldList.add(Simpplr_Content__c.Title__c);

		if(localWrapperObj.bodyJson!=null){
			List<String> contentBodyJsonParts = getContentJsonBodyParts(JSON.serialize(localWrapperObj.bodyJson,true), mapOfNewTopics);
			contentObj.Text_Json__c =  contentBodyJsonParts[0];
			contentObj.Text_Main_Json__c =  contentBodyJsonParts[1];
			contentObj.Text_Main_Continued_Json__c =  contentBodyJsonParts[2];	
			fieldList.add(Simpplr_Content__c.Text_Json__c);
			fieldList.add(Simpplr_Content__c.Text_Main_Json__c);
			fieldList.add(Simpplr_Content__c.Text_Main_Continued_Json__c);
		} 
		List<String> contentBodyParts = getContentBodyParts(localWrapperObj.body, mapOfNewTopics);
		contentObj.Text_Intro__c = contentBodyParts[0];
		contentObj.Text_Main__c = contentBodyParts[1];
		contentObj.Text_Main_Continued__c = contentBodyParts[2];
		contentObj.Excerpt__c = String.isNotBlank(contentObj.Text_Intro__c) ? 
				Utility.getPlainText(contentObj.Text_Intro__c, 250, true) : '';
		contentObj.Summary_1__c	= String.valueOf(String.isEmpty(localWrapperObj.summary) 
				? '' : localWrapperObj.summary.unescapeHtml4()).replace('&#8203;','');

		fieldList.add(Simpplr_Content__c.Text_Intro__c);
		fieldList.add(Simpplr_Content__c.Text_Main__c);
		fieldList.add(Simpplr_Content__c.Text_Main_Continued__c);
		fieldList.add(Simpplr_Content__c.Excerpt__c);
		fieldList.add(Simpplr_Content__c.Summary_1__c);
		
		if(SiteContext.isQuestionAnswerEnabled && localWrapperObj.isQuestionAnswerEnabled != null) {
			contentObj.Question_Answer_Enabled__c = localWrapperObj.isQuestionAnswerEnabled;
			fieldList.add(Simpplr_Content__c.Question_Answer_Enabled__c);
		}
        contentObj.Title_Image_Caption__c = localWrapperObj.imgCaption;
        contentObj.Album_Allow_All_to_Upload__c	= localWrapperObj.isOpenToSubmissions == true ? true : false;
        contentObj.Display_Excerpt__c = Utility.getDisplayExcerpt(contentObj.Excerpt__c,contentObj.Summary_1__c);

		fieldList.add(Simpplr_Content__c.Cover_Image_Layout__c);
        fieldList.add(Simpplr_Content__c.Title_Image_Caption__c);
        fieldList.add(Simpplr_Content__c.Display_Excerpt__c);
		fieldList.add(Simpplr_Content__c.Album_Allow_All_to_Upload__c);

		if (String.isNotBlank(localWrapperObj.publishAt)) {
			// publishAt => 2022-07-04T00:00:00 from UI
			contentObj.Publish_Start_DateTime__c = Utility.momentJSDateTimeStringToDateTime(localWrapperObj.publishAt);
			fieldList.add(Simpplr_Content__c.Publish_Start_DateTime__c);
		} else if (ServiceConstants.CONTENT_STATUS_DRAFT.equalsIgnoreCase(contentObj.Status__c)==false) {
			throw New SimpplrException(ExceptionCode.EMPTY_PUBLISH_START_DATE.name());
		}

        contentObj.Publish_End_DateTime__c = String.isNotBlank(localWrapperObj.publishTo) ? 
				Utility.momentJSDateTimeStringToDateTime(localWrapperObj.publishTo) : null;
        contentObj.Last_Edited_DateTime__c = DateTime.now();
		contentObj.Last_Updated_DateTime__c = DateTime.now();
		contentObj.Last_UpdatedBy_People__c = UserContext.getCurrentUserInfo.Id;
    	contentObj.Allow_comments__c = localWrapperObj.isFeedEnabled == true ? true : false;
        
		fieldList.add(Simpplr_Content__c.Publish_End_DateTime__c);
        fieldList.add(Simpplr_Content__c.Allow_comments__c);
        fieldList.add(Simpplr_Content__c.Last_Edited_DateTime__c);
        fieldList.add(Simpplr_Content__c.Last_Updated_DateTime__c);
        fieldList.add(Simpplr_Content__c.Last_UpdatedBy_People__c);

		//----------------Album specific fields wrapping--------------------------------------------------------
		contentObj.Use_Maximum_Screenwidth__c = localWrapperObj.isMaximumWidth == true ? true : false;
        contentObj.Cover_Image_Layout__c = localWrapperObj.imgLayout;
        contentObj.Album_Video_Count__c = totalVideoCount != null ? totalVideoCount : 0;
        contentObj.Album_Image_Count__c = totalImageCount != null ? totalImageCount : 0;

		fieldList.add(Simpplr_Content__c.Use_Maximum_Screenwidth__c);
        fieldList.add(Simpplr_Content__c.Cover_Image_Layout__c);
        fieldList.add(Simpplr_Content__c.Album_Video_Count__c);
        fieldList.add(Simpplr_Content__c.Album_Image_Count__c);

        
		if (isEdit) {
			if (ServiceConstants.CONTENT_STATUS_PREDRAFT.equalsIgnoreCase(oldStatus)) {
				contentObj.Created_DateTime__c = DateTime.now();
				contentObj.CreatedBy_People__c = UserContext.getCurrentUserInfo.Id;

				fieldList.add(Simpplr_Content__c.Created_DateTime__c);
				fieldList.add(Simpplr_Content__c.CreatedBy_People__c);
			}
        	oldAuthorId = String.valueOf(contentObj.Primary_Author__c);
	        
			if (hasContentApprovalAccess && localWrapperObj.authoredBy != null && 
					String.isNotBlank(localWrapperObj.authoredBy.peopleId)) {

	        	contentObj.Primary_Author__c = localWrapperObj.authoredBy.peopleId;
				fieldList.add(Simpplr_Content__c.Primary_Author__c);
	        }

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
 			SIMPESAPI.accessController().updateAsUser(contentObj, fieldList);

			// enable content notifications for the user
			if(ServiceConstants.CONTENT_STATUS_APPROVED.equalsIgnoreCase(contentObj.Status__c)) {
				ManageContentDao manageContentDaoObj = new ManageContentDao();
				Content_Notification_Setting__c contentNotiSettingObj = manageContentDaoObj.getNotificationSetting(contentObj.Id, UserContext.peopleId);

				if(contentNotiSettingObj == null) {
					manageContentDaoObj.insertContentNotificationSettingForUser(contentObj.Id, UserContext.peopleId);
				}
			}

			if (localWrapperObj.authoredBy != null) {
                if(ServiceConstants.CONTENT_STATUS_DRAFT.equalsIgnoreCase(oldStatus) && ServiceConstants.CONTENT_STATUS_APPROVED.equalsIgnoreCase(contentObj.Status__c)) {
                    sendNotificationForPublishedOnYourBehalf(localWrapperObj.authoredBy.peopleId, contentObj);
                    
                } else if(localWrapperObj.authoredBy.peopleId != oldAuthorId) {
                    sendNotificationOnAuthorChange(oldAuthorId, localWrapperObj.authoredBy.peopleId, contentObj);

                }
			}
			
			logger.logDebug('SiteAddAlbumDataServer.saveContentObjectToDB()----oldAuthorId----'+oldAuthorId+'--localWrapperObj.authoredBy.peopleId--'+localWrapperObj.authoredBy.peopleId+'--contentObj--'+contentObj);
				
        } else {
			contentObj.Created_DateTime__c = DateTime.now();
	        contentObj.OwnerId = albumDaoObj.getContentOwnerId('Simpplr_' + SiteContext.chatterGroupId + '_Admin');
	        contentObj.Primary_Author__c = UserContext.getCurrentUserInfo.Id;

			fieldList.add(Simpplr_Content__c.Created_DateTime__c);
 			//fieldList.add(Simpplr_Content__c.CreatedBy_People__c);
 			fieldList.add(Simpplr_Content__c.OwnerId);
            fieldList.add(Simpplr_Content__c.Primary_Author__c);

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPSFDCAccessControlResults.InsertResults result = SIMPESAPI.accessController().insertAsUser(
					new List<Simpplr_Content__c>{contentObj}, fieldList);

			List<Simpplr_Content__c> listOfContentObj = new List<Simpplr_Content__c>();
			listOfContentObj = (List<Simpplr_Content__c>) result.getInsertedObjects();  
			contentObj = listOfContentObj[0];
        }

        return contentObj;
	} 
	
	public ResponseWrapper getAlbumByVersionHistoryId(String contentId, String versionHistoryId){
		logger.logDebug('SiteAddAlbumDataServer.getAlbumByVersionHistoryId()---data---' + contentId);
    	ResponseWrapper resultWrapper = New ResponseWrapper();
    	String redirectUrl = null;
    	
    	try {
    		String content_LastModifiedTimeStamp = readParam(CONTENT_LASTMODIFIEDDATETIMESTAMP);
    		
    		if (String.valueOf(SimpplrContext.allowedFeatures).containsIgnoreCase(ServiceConstants.TYPE_PAGE) == false) {
	    		throw new SimpplrException(ServiceConstants.ERROR_404);
			}

	    	String query = 'SELECT '+String.join(getAlbumFieldList(),',') + 
					' FROM Simpplr_Content__c where id=:contentId AND Type__c = \'Album\' ';
	    	List<Simpplr_Content__c> contentObjList = Database.query(query); 
	  
	    	if (contentObjList.size() == 0) {
	    		throw new SimpplrException(ServiceConstants.ERROR_404);
	    	
	    	} else if (contentObjList[0].Site__r.Show_In_Simpplr__c == false) {
	    		redirectUrl = SimpplrContext.salesforceBaseUrl + '/' + 
						contentObjList[0].Site__r.Chatter_Group_Id__c;
	    		throw new SimpplrException(ServiceConstants.ERROR_404);
	    
	    	} else if (contentObjList[0].Is_Deleted__c || 
					(contentObjList[0].Activated_By_Feature__c == false) || 
					(contentObjList[0].Site__r.Is_Active__c == false)) {
	    		throw new SimpplrException(ServiceConstants.ERROR_404);
	    	
    		} else if(AccessManager.calculateContentViewAccess(contentObjList[0].Type__c, 
					contentObjList[0].Is_Published__c, contentObjList[0].Site__c, 
					contentObjList[0].Site__r.Site_Type__c, contentObjList[0].Status__c, 
					contentObjList[0].Primary_Author__r.User__c)) {

    			ContentWrapper wrapperObj = getAlbumWrapperByVersion(contentId, versionHistoryId);

				resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, wrapperObj);
				
			} else {
				throw new SimpplrException(ServiceConstants.ERROR_404);
			}

    	} catch (exception ex) {
    		logger.logError('Exception Details', ex);
        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, ex.getMessage(), null);

        	if (String.isNotBlank(redirectUrl)) {
        		resultWrapper.redirectUrl = redirectUrl;
        	}

        }

        return resultWrapper;
	}

	public ContentWrapper getAlbumWrapperByVersion(String contentId, String versionId){
		ContentWrapper wrapperObj  	= New ContentWrapper();
		List<Content_History__c> contentHistoryList = [SELECT Id, Content__c, Content_Json_Part1__c,
														Content_Json_Part2__c, Content_Json_Part3__c, Content_Json_Part4__c,
														Content_Json_Part5__c, File_Json__c, File_Json_Part1__c, File_Json_Part2__c,
														File_Json_Part3__c, Topic_Json__c, Version__c FROM Content_History__c
														WHERE Content__c = :contentId AND Version__c  = :Decimal.valueOf(versionId) AND IsDeleted = false WITH SECURITY_ENFORCED ORDER BY Version__c ASC];

		if(!contentHistoryList.isEmpty() && contentHistoryList.size() > 0){
			ManageContentDao contentDao = new ManageContentDao();
			String contentJsonStr = contentDao.mergeContentHistoryJsonStrings(contentHistoryList[0], 'content');
            
			String unescapedContentJsonStr= contentJsonStr.unescapeUnicode();
			Simpplr_Content__c contentRecord;
			
			try{
				contentRecord = (Simpplr_Content__c) JSON.deserialize(unescapedContentJsonStr, Type.forName('Simpplr_Content__c'));
			}catch(Exception e) {           
				contentRecord = (Simpplr_Content__c) JSON.deserialize(contentJsonStr, Type.forName('Simpplr_Content__c'));
			}

			Set<Id> sitesIManageIdSet = UserContext.sitesIManageIdSet;
			
			wrapperObj.id = contentRecord.id;
			wrapperObj.isLatest = false;
			wrapperObj.versionId = contentHistoryList[0].Version__c;
			wrapperObj.contentId = contentRecord.id;
			wrapperObj.contentBodyUrl = PageContext.getPageURL(Pages.ContentBody) + '?contentId=' + contentRecord.id;
			wrapperObj.title = Utility.getAllValidWords(contentRecord.Title__c, contentRecord.Title__c.length(), false);
			wrapperObj.type = contentRecord.Type__c.toLowerCase();
			wrapperObj.contentSubType = contentRecord.Content_Sub_Type__c;
			wrapperObj.excerpt = String.isBlank(contentRecord.Display_Excerpt__c) ? '': contentRecord.Display_Excerpt__c.unescapeHtml4();
			wrapperObj.summary = String.isBlank(contentRecord.Summary_1__c) ? '' : contentRecord.Summary_1__c.unescapeHtml4();
			wrapperObj.isPublished = contentRecord.Is_Published__c;
			wrapperObj.status = getContentStatus(contentRecord.Status__c, contentRecord.Is_Published__c);
			wrapperObj.isScheduled = checkIfContentScheduled(wrapperObj.status, contentRecord.Publish_Start_DateTime__c);
			wrapperObj.isFeedEnabled = contentRecord.Allow_comments__c;
			wrapperObj.imgLayout = contentRecord.Cover_Image_Layout__c;
			wrapperObj.lastMovedAt = Utility.dateTimeToMomentJSDateTime(contentRecord.Last_Moved_DateTime__c);
			wrapperObj.isMustRead 		= false;
			wrapperObj.MustReadDetails = null;
			wrapperObj.imgCaption = contentRecord.Title_Image_Caption__c;
			wrapperObj.isLiked = false;
			wrapperObj.likeCount = Integer.valueOf(contentRecord.Likes__c);
			wrapperObj.imageCount = Integer.valueOf(contentRecord.Album_Image_Count__c);
        	wrapperObj.videoCount = Integer.valueOf(contentRecord.Album_Video_Count__c);
			wrapperObj.isMaximumWidth = contentRecord.Use_Maximum_Screenwidth__c;
			wrapperObj.postCount = contentRecord.Feed_Posts__c == null ? 0 : Integer.valueOf(contentRecord.Feed_Posts__c);
			wrapperObj.questionCount = contentRecord.Feed_Questions__c == null ? 0 : Integer.valueOf(contentRecord.Feed_Questions__c);
			wrapperObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRecord.site__c+'/album/'+contentRecord.Id;
			wrapperObj.editUrl = wrapperObj.url + '/edit';
			if(String.isNotBlank(contentRecord.Text_Json__c)) {
				String bodyJsonData = getMergedBodyJson(contentRecord.Text_Json__c, contentRecord.Text_Main_Json__c, contentRecord.Text_Main_Continued_Json__c);
				wrapperObj.bodyJson = (TipTapBodyWrapper)JSON.deserialize(bodyJsonData, TipTapBodyWrapper.class);
			}
			wrapperObj.body = (String.isNotBlank(contentRecord.Text_Intro__c) ? 
						contentRecord.Text_Intro__c : '') +
						(String.isNotBlank(contentRecord.Text_Main__c) ? contentRecord.Text_Main__c : '') +
						(String.isNotBlank(contentRecord.Text_Main_Continued__c) ? 
						contentRecord.Text_Main_Continued__c : '');
			wrapperObj.isFavorited = false;
			wrapperObj.favoriteContext = contentRecord.Type__c;
			wrapperObj.hasRead = false;
			wrapperObj.readAt = null;
			wrapperObj.modifiedAt = Utility.dateTimeToMomentJSDateTime(contentRecord.Last_Edited_DateTime__c);
			wrapperObj.publishAt = Utility.dateTimeToMomentJSDateTime(contentRecord.Publish_Start_DateTime__c);
			wrapperObj.publishTo = Utility.dateTimeToMomentJSDateTime(contentRecord.Publish_End_DateTime__c);
			wrapperObj.createdAt = Utility.dateTimeToMomentJSDateTime(contentRecord.CreatedDate);
			wrapperObj.lastModifiedDateTimeStamp = contentRecord.Last_Updated_DateTime__c != null ? contentRecord.Last_Updated_DateTime__c.getTime() : 0;
			wrapperObj.firstPublishedAt = contentRecord.First_Publish_DateTime__c  != null ? Utility.dateTimeToMomentJSDateTime(contentRecord.First_Publish_DateTime__c) : null; 
			wrapperObj.isOpenToSubmissions = contentRecord.Album_Allow_All_to_Upload__c;
			wrapperObj.listOfTopics = String.isNotBlank(contentHistoryList[0].Topic_Json__c) ? convertToListOfTopicWrapper(contentHistoryList[0].Topic_Json__c) : null;
			wrapperObj.site = getSiteDetails(contentRecord.Site__c);

			if(String.isNotBlank(contentRecord.Primary_Author__c)){
				wrapperObj.authoredBy = getPeopleListWrapper(contentRecord.Primary_Author__c);
			}

			wrapperObj.canEdit = AccessManager.calculateEditAccess(wrapperObj.site.isManager, wrapperObj.site.isContentManager,
				wrapperObj.status, wrapperObj.authoredBy.sfUserId, wrapperObj.site.access);

			if(String.isNotBlank(contentHistoryList[0].File_Json__c)){

				String fileJsonStr = contentDao.mergeContentHistoryJsonStrings(contentHistoryList[0], 'file');
				String unescapedFileJsonStr = fileJsonStr.unescapeUnicode();
				List<File__c> fileList;
			
				try{
					fileList = (List<File__c>) JSON.deserialize(unescapedFileJsonStr, Type.forName('List<File__c>'));
				}catch(Exception e) {          
					fileList = (List<File__c>) JSON.deserialize(fileJsonStr, Type.forName('List<File__c>'));
				}
				Set<Id> fileIdSet = new Set<Id>();
        
				for (File__c fileObj : fileList) {
					if ('Image'.equalsIgnoreCase(fileObj.MIME_Type__c)) {
						fileIdSet.add(fileObj.id);
					}
				}

				wrapperObj.listOfAlbumImagesAndVideos = new List<FileListingWrapper>();
				for (File__c fileObj : fileList){
					
					if (ServiceConstants.FILE_LOCATION_ATTACHMENT.equalsIgnoreCase(fileObj.Location__c)) {
						wrapperObj.listOfFiles.add(convertFileToFileContentWrapper(fileObj));
					
					} else if (ServiceConstants.FILE_LOCATION_INLINE.equalsIgnoreCase(fileObj.Location__c) && ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(fileObj.Repository__c)) {
						wrapperObj.listOfInlineVideos.add(convertFileToFileContentWrapper(fileObj));
					
					}else if (ServiceConstants.FILE_LOCATION_INLINE.equalsIgnoreCase(fileObj.Location__c)) {
						wrapperObj.listOfInlineImages.add(convertFileToFileContentWrapper(fileObj));
					
					}else if (ServiceConstants.File_LOCATION_MEDIA.equalsIgnoreCase(fileObj.Location__c) && 
							fileObj.Is_Title_Image__c) {

						if ('video'.equalsIgnoreCase(fileObj.MIME_Type__c)) {
							wrapperObj.img = fileObj.Thumbnail_URL__c;
							wrapperObj.imgLandscape = fileObj.Thumbnail_URL__c;

						} else {
							wrapperObj.img = Utility.getFileDownloadURL(fileObj.Content_Version__c);
							wrapperObj.imgLandscape = Utility.getFileDownloadURL(fileObj.Content_Version__c);
						}

						if ('mobile'.equalsIgnoreCase(readParam('origin'))) {
							if(String.isNotBlank(wrapperObj.body) && wrapperObj.body.containsIgnoreCase('<iframe') ){
								wrapperObj.body = Utility.getUpdatedMobileWapperBody(wrapperObj.body);
							}
							wrapperObj.imgFile = convertFileToFileContentWrapper(fileObj);
							wrapperObj.imgLandscapeFile = wrapperObj.imgFile;
						}

					}
					
					if ('Image'.equalsIgnoreCase(fileObj.MIME_Type__c) || 
							'Video'.equalsIgnoreCase(fileObj.MIME_Type__c)) {
						FileListingWrapper fileWrapObj = ObjectToWrapperAdapter.fileToWrapperWithoutIsLiked(fileObj);
						fileWrapObj.isLiked = false;

						wrapperObj.listOfAlbumImagesAndVideos.add(fileWrapObj);
					}

				}
				
			}

		}

		return wrapperObj;
	}
	/**
	 * @description method overriding getContent
	 * @return ResponseWrapper
	 * @param contentId of String type
	 */
	public ResponseWrapper getContent(String contentId) {
		return getContent(contentId, null);
	}

	/**
	 * @description getContent to return content data back 
	 * @return ResponseWrapper
	 * @param contentId of String type
	 * @param listOfSuggestedTopics of type List<ContentWrapper.SuggestedTopicsWrapper>
	 */
	public ResponseWrapper getContent(String contentId, List<ContentWrapper.SuggestedTopicsWrapper> listOfSuggestedTopics) {
    	logger.logDebug('SiteAddAlbumDataServer.getContent()---data---' + contentId);
    	ResponseWrapper resultWrapper = New ResponseWrapper();
    	String redirectUrl = null;
    	
    	try {
    		String content_LastModifiedTimeStamp = readParam(CONTENT_LASTMODIFIEDDATETIMESTAMP);
    		DateTime lastModifiedDateTimeStamp =  content_LastModifiedTimeStamp != null && content_LastModifiedTimeStamp != '0' ? DateTime.newInstance(long.valueOf(content_LastModifiedTimeStamp)) : null;
    		
    		if (String.valueOf(SimpplrContext.allowedFeatures).containsIgnoreCase(ServiceConstants.TYPE_ALBUM) == false) {
    			throw new SimpplrException(ServiceConstants.ERROR_404);
    		}

	    	String query = 'SELECT '+String.join(getAlbumFieldList(),',')+' FROM Simpplr_Content__c where id=:contentId ';
	    	List<Simpplr_Content__c> contentObjList = Database.query(query); 
	    	
	    	if (contentObjList.size() == 0) {
	    		throw new SimpplrException(ServiceConstants.ERROR_404);
	    	
	    	} else if (contentObjList[0].Site__r.Show_In_Simpplr__c == false) {
	    		redirectUrl = SimpplrContext.salesforceBaseUrl + '/' + contentObjList[0].Site__r.Chatter_Group_Id__c;
	    		throw new SimpplrException(ServiceConstants.ERROR_404);
	    
	    	} else if (lastModifiedDateTimeStamp != null && 
					contentObjList[0].Last_Updated_DateTime__c == lastModifiedDateTimeStamp) {
				resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 
						'Content data Not changed!', null);

	    	} else if (contentObjList[0].Is_Deleted__c || 
					(contentObjList[0].Activated_By_Feature__c == false) || 
					(contentObjList[0].Site__r.Is_Active__c == false)) {
	    		throw new SimpplrException(ServiceConstants.ERROR_404);
	    
    		} else if (AccessManager.calculateContentViewAccess(contentObjList[0].Type__c, 
					contentObjList[0].Is_Published__c, contentObjList[0].Site__c, 
					contentObjList[0].Site__r.Site_Type__c, contentObjList[0].Status__c, 
					contentObjList[0].Primary_Author__r.User__c)) {
				ContentWrapper wrapperObj = convertToContentWrapper(contentObjList[0]);
				wrapperObj.listOfSuggestedTopics = listOfSuggestedTopics;
				SiteDao siteDaoObj = new siteDao();
				CollaborationGroup collaborationGroupObj = siteDaoObj.getChatterGroupDetails(contentObjList[0].Site__r.Chatter_Group_Id__c);
				wrapperObj.site.isBroadcast = collaborationGroupObj?.IsBroadcast;
				
				if ('mobile'.equalsIgnoreCase(readParam('origin'))) {
					wrapperObj.isFeedEnabled = SimpplrContext.isCommentsAllowed && 
							contentObjList[0].Site__r.Allow_Comments__c && 
							wrapperObj.isFeedEnabled;
					if(String.isNotBlank(wrapperObj.body) && wrapperObj.body.containsIgnoreCase('<iframe') ){
						wrapperObj.body = Utility.getUpdatedMobileWapperBody(wrapperObj.body);
					}
        			Utility.insertMobileAnalyticsRecord('AlbumDetail', new Map<String, String> {
							'siteId'=>wrapperObj.site.siteid,'contentId'=>contentId, 
							'userAgent'=>readHeader('User-Agent')});
        		}

				resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, wrapperObj);

			} else {
				throw new SimpplrException(ServiceConstants.ERROR_404);
			}

    	} catch (exception e) {
    		logger.logError('Exception Details', e);
        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, e.getMessage(), null);

        	if (String.isNotBlank(redirectUrl)) {
        		resultWrapper.redirectUrl = redirectUrl;
        	}

        }

        return resultWrapper;
    }
    
    @TestVisible
    private List<String> getAlbumFieldList() {
		List<String> albumFieldList = new List<String>{
			'Album_Allow_All_to_Upload__c',
			'Album_Image_Count__c',
			'Album_Video_Count__c',
			'Use_Maximum_Screenwidth__c',
			'Last_Moved_DateTime__c'
		};
		albumFieldList.addAll(getContentDetailFieldList());
		return albumFieldList;
    }
    
    @TestVisible 
	private ContentWrapper convertToContentWrapper(Simpplr_Content__c contentRecord) {
        Set<Id> sitesIManageIdSet = UserContext.sitesIManageIdSet;
        ContentWrapper wrapperObj  	= new ContentWrapper();
        wrapperObj.id = contentRecord.id;
		wrapperObj.isLatest = true;
		wrapperObj.versionId = contentRecord.Version__c;
        wrapperObj.contentId = contentRecord.id;
        wrapperObj.contentBodyUrl = PageContext.getPageURL(Pages.ContentBody)+'?contentId='+contentRecord.id;
        wrapperObj.title = String.isBlank(contentRecord.Title__c)?'' : Utility.getAllValidWords(contentRecord.Title__c, contentRecord.Title__c.length(), false);
        wrapperObj.type = contentRecord.Type__c.toLowerCase();
       	wrapperObj.excerpt = String.isBlank(contentRecord.Display_Excerpt__c)?'':contentRecord.Display_Excerpt__c.unescapeHtml4();
		wrapperObj.summary = String.isBlank(contentRecord.Summary_1__c)?'':contentRecord.Summary_1__c.unescapeHtml4();
        wrapperObj.isPublished = contentRecord.Is_Published__c;
		wrapperObj.status = getContentStatus(contentRecord.Status__c, contentRecord.Is_Published__c);
		wrapperObj.isScheduled = checkIfContentScheduled(wrapperObj.status, contentRecord.Publish_Start_DateTime__c);
        wrapperObj.isFeedEnabled = contentRecord.Allow_comments__c;
        wrapperObj.imgLayout = contentRecord.Cover_Image_Layout__c;
		wrapperObj.lastMovedAt = Utility.dateTimeToMomentJSDateTime(contentRecord.Last_Moved_DateTime__c);

		Map<Id, Site_Role__c> mapofSiteIdAndSiteRole = new Map<Id, Site_Role__c>();
		mapofSiteIdAndSiteRole = UserContext.mySiteRolesMap;

		if (contentRecord.Must_Read_Audits__r != null && contentRecord.Must_Read_Audits__r.isEmpty() == false) {
			List<Must_Read_Audit__c> mustReadAudList = contentRecord.Must_Read_Audits__r;

			if ((mustReadAudList[0].Expiry_DateTime__c == null || 
					mustReadAudList[0].Expiry_DateTime__c > DateTime.now()) && 
					mustReadAudList[0].Removed_DateTime__c == null) {
				if(mustReadAudList[0].Audience_Type__c == 'site_members') { 
					Site_Role__c siteRoleForContentSite = mapofSiteIdAndSiteRole.get(contentRecord.Site__c);
					if(siteRoleForContentSite !=null && siteRoleForContentSite.Is_Member__c == true) {
						wrapperObj.isMustRead = true;
					} else {
						wrapperObj.isMustRead = false;
					}
				} else {
					wrapperObj.isMustRead = true;
				}
				
			} else {
				wrapperObj.isMustRead = false;
			}

			wrapperObj.MustReadDetails = getMustReadDetails(mustReadAudList[0]);
			Map<String,Integer> contentIdToAudienceCountMap = new Map<String,Integer>();
			contentIdToAudienceCountMap = new ManageContentDao().getContentIdToAudienceCountMap(new List<Simpplr_Content__c>{contentRecord});
			if(contentIdToAudienceCountMap != null) {
				wrapperObj.mustReadDetails.audienceCount = contentIdToAudienceCountMap.get(contentRecord.id) != null ?contentIdToAudienceCountMap.get(contentRecord.id) : 0;
			}
		
		} else {
			wrapperObj.isMustRead = false;
			wrapperObj.MustReadDetails = null;
		}

        wrapperObj.imgCaption = contentRecord.Title_Image_Caption__c;
        wrapperObj.isLiked = contentRecord.Likes_Simpplr_Content__r.isEmpty() ? false : true;
        wrapperObj.likeCount = Integer.valueOf(contentRecord.Likes__c);
        wrapperObj.imageCount = Integer.valueOf(contentRecord.Album_Image_Count__c);
        wrapperObj.videoCount = Integer.valueOf(contentRecord.Album_Video_Count__c);
        wrapperObj.isMaximumWidth = contentRecord.Use_Maximum_Screenwidth__c;
        wrapperObj.postCount = contentRecord.Feed_Posts__c == null ? 0 : Integer.valueOf(contentRecord.Feed_Posts__c);
		wrapperObj.questionCount = contentRecord.Feed_Questions__c == null ? 0 : Integer.valueOf(contentRecord.Feed_Questions__c);
        wrapperObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRecord.site__c+'/album/'+contentRecord.Id;
        wrapperObj.editUrl = wrapperObj.url + '/edit';

		if(String.isNotBlank(contentRecord.Text_Json__c)) {			
			String bodyJsonData = getMergedBodyJson(contentRecord.Text_Json__c, contentRecord.Text_Main_Json__c, contentRecord.Text_Main_Continued_Json__c );
			wrapperObj.bodyJson = (TipTapBodyWrapper)JSON.deserialize(bodyJsonData, TipTapBodyWrapper.class);
		} 
		wrapperObj.body = (String.isNotBlank(contentRecord.Text_Intro__c) ? contentRecord.Text_Intro__c : '') +
				(String.isNotBlank(contentRecord.Text_Main__c) ? contentRecord.Text_Main__c : '') +
				(String.isNotBlank(contentRecord.Text_Main_Continued__c) ? contentRecord.Text_Main_Continued__c : '');
		wrapperObj.isFavorited = !contentRecord.Bookmarked_Content__r.isEmpty();
		wrapperObj.isOpenToNotification = !contentRecord.Content_Notification_Setting__r.isEmpty();
        wrapperObj.favoriteContext 	= contentRecord.Type__c;
        wrapperObj.site = New SiteLiteWrapper();
        wrapperObj.site.siteid = contentRecord.Site__c;
        wrapperObj.site.name = contentRecord.Site__r.name;
        wrapperObj.site.img = String.isBlank(contentRecord.Site__r.Title_Content_Version__c)? null :Utility.getFileDownloadURLFor720By480(contentRecord.Site__r.Title_Content_Version__c);
        wrapperObj.site.imgThumbnail= String.isBlank(contentRecord.Site__r.Title_Content_Version__c)? null :Utility.getFileDownloadURLFor120BY90(contentRecord.Site__r.Title_Content_Version__c);
        wrapperObj.site.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + contentRecord.Site__c + '/' + contentRecord.Site__r.Landing_Page__c;
        wrapperObj.site.access = contentRecord.Site__r.Site_Type__c;
        wrapperObj.site.isActive = contentRecord.site__r.Is_Active__c;
        wrapperObj.site.isPrivate = ServiceConstants.PRIVATE_SITE.equalsIgnoreCase(contentRecord.Site__r.Site_Type__c);
        wrapperObj.site.isPublic = ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(contentRecord.Site__r.Site_Type__c);
		if(SimpplrContext.isSegmentsEnabled){
			String segmentId = String.isBlank(UserContext.SegmentId) ? '' : UserContext.SegmentId;
			if(String.isNotBlank(segmentId)) {
				List<Segment_Site__c> segList = [SELECT id, Is_Featured__c from Segment_Site__c where site__c =: contentRecord.Site__c and segment__c =:segmentId WITH SECURITY_ENFORCED limit 1];
				wrapperObj.site.isFeatured = segList.size()>0 ? segList[0].Is_Featured__c : false;
			} else {
				wrapperObj.site.isFeatured = false;
			}
		} else {
			wrapperObj.site.isFeatured = contentRecord.Site__r.Is_Featured__c;
		}
		wrapperObj.site.isMember = false;
		wrapperObj.site.isFollower = false;
		if(mapofSiteIdAndSiteRole.containsKey(contentRecord.Site__c)) {
			Site_Role__c siteRoleForContentSite = mapofSiteIdAndSiteRole.get(contentRecord.Site__c);
			if(siteRoleForContentSite.Is_Member__c == true) {
				wrapperObj.site.isMember = true;
				wrapperObj.site.isFollower = false;
			} else {
				wrapperObj.site.isMember = false;
				wrapperObj.site.isFollower = true;
			}
		}
		if(UserContext.sitesIManageIdSet.contains(contentRecord.Site__c) || UserContext.sitesIManageContentsIdSet.contains(contentRecord.Site__c)) {
			if (ServiceConstants.ALLOW_FILE_UPLOAD_IN_ALL_SITES.equalsIgnoreCase(SimpplrContext.appConfig.Allow_File_Upload_Site_Managers__c)) {
				wrapperObj.site.canUploadAllFileTypes =  true;
			} else if (ServiceConstants.ALLOW_FILE_UPLOAD_AS_All_USER.equalsIgnoreCase(SimpplrContext.appConfig.Allow_File_Upload_Site_Managers__c)) {
				wrapperObj.site.canUploadAllFileTypes =  false;
			} else if (ServiceConstants.ALLOW_FILE_UPLOAD_IN_SELECTED_SITE.equalsIgnoreCase(SimpplrContext.appConfig.Allow_File_Upload_Site_Managers__c)){
				wrapperObj.site.canUploadAllFileTypes = contentRecord.site__r.Allow_File_Upload_App_Permission__c;
			}
		}else{
			wrapperObj.site.canUploadAllFileTypes = false;
		}
        wrapperObj.site.isManager = UserContext.sitesIManageIdSet.contains(contentRecord.Site__c);
        wrapperObj.site.isContentManager = UserContext.sitesIManageContentsIdSet.contains(contentRecord.Site__c);
        wrapperObj.site.isListed = !ServiceConstants.UNLISTED_SITE.equalsIgnoreCase(contentRecord.Site__r.Site_Type__c);
        wrapperObj.site.chatterGroupId = contentRecord.Site__r.Chatter_Group_Id__c;
		wrapperObj.site.isContentUnfurlEnabled = contentRecord.Site__r.Is_Content_Unfurl_Enabled__c;
		wrapperObj.isQuestionAnswerEnabled = SimpplrContext.isQuestionAnswerEnabled && contentRecord.Site__r.Question_Answer_Enabled__c == true && contentRecord.Question_Answer_Enabled__c == true;
        wrapperObj.hasRead = !contentRecord.Must_Read_Confirm_History__r.isEmpty();
        wrapperObj.readAt = wrapperObj.hasRead ? Utility.dateTimeToMomentJSDateTime(contentRecord.Must_Read_Confirm_History__r[0].Confirm_DateTime__c):null;
        wrapperObj.modifiedAt = Utility.dateTimeToMomentJSDateTime(contentRecord.Last_Updated_DateTime__c);
		wrapperObj.publishAt = Utility.dateTimeToMomentJSDateTime(contentRecord.Publish_Start_DateTime__c);
		wrapperObj.publishTo = Utility.dateTimeToMomentJSDateTime(contentRecord.Publish_End_DateTime__c);
		wrapperObj.createdAt = Utility.dateTimeToMomentJSDateTime(contentRecord.Created_DateTime__c);
        wrapperObj.lastModifiedDateTimeStamp = contentRecord.Last_Updated_DateTime__c != null ? contentRecord.Last_Updated_DateTime__c.getTime() : 0;
        wrapperObj.firstPublishedAt = contentRecord.First_Publish_DateTime__c  != null ? Utility.dateTimeToMomentJSDateTime(contentRecord.First_Publish_DateTime__c) : null;
		wrapperObj.isOpenToSubmissions = contentRecord.Album_Allow_All_to_Upload__c;
        wrapperObj.authoredBy.Id = contentRecord.Primary_Author__c;
        wrapperObj.authoredBy.sfUserId = contentRecord.Primary_Author__r.User__r.Id;
        wrapperObj.authoredBy.peopleId = contentRecord.Primary_Author__c;
        wrapperObj.authoredBy.name = contentRecord.Primary_Author__r.Full_Name__c;
        wrapperObj.authoredBy.img = contentRecord.Primary_Author__r.User__r.FullPhotoURL.endsWith('005/F') ? null : contentRecord.Primary_Author__r.User__r.FullPhotoURL;
        wrapperObj.authoredBy.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + contentRecord.Primary_Author__c;
		wrapperObj.authoredBy.title = SimpplrContext.isPPTitleDisplay ? contentRecord.Primary_Author__r.title__c : null;
	    wrapperObj.authoredBy.location = Utility.buildLocation(contentRecord.Primary_Author__r.city__c,contentRecord.Primary_Author__r.state__c,contentRecord.Primary_Author__r.country__c);
        wrapperObj.authoredBy.isFollowing = UserContext.usersIFollowIdSet.contains(wrapperObj.authoredBy.sfUserId);
		wrapperObj.authoredBy.department = SimpplrContext.isPPDepartmentDisplay ? contentRecord.Primary_Author__r.Department__c : null;
		wrapperObj.authoredBy.canFollow	= UserContext.peopleId.equalsIgnoreCase(wrapperObj.authoredBy.peopleId) ?  false : contentRecord.Primary_Author__r.User__r.isActive;
		wrapperObj.authoredBy.mediumPhotoUrl = Utility.getUserProfileImgUrl(contentRecord.Primary_Author__r.User__r.MediumPhotoURL, contentRecord.Primary_Author__r.User__r.FullPhotoURL);
		wrapperObj.authoredBy.street = contentRecord.Primary_Author__r.Street__c;
		wrapperObj.authoredBy.city = contentRecord.Primary_Author__r.City__c;
		wrapperObj.authoredBy.state = contentRecord.Primary_Author__r.State__c;
		wrapperObj.authoredBy.country = contentRecord.Primary_Author__r.Country__c;
		wrapperObj.authoredBy.email = contentRecord.Primary_Author__r.Email__c;
		wrapperObj.authoredBy.mobile = contentRecord.Primary_Author__r.Mobile_Phone__c;
		wrapperObj.authoredBy.phone = contentRecord.Primary_Author__r.Phone__c;
		wrapperObj.authoredBy.phoneExtension = contentRecord.Primary_Author__r.Extension__c;
		wrapperObj.authoredBy.firstName = contentRecord.Primary_Author__r.First_Name__c;
		wrapperObj.authoredBy.lastName = contentRecord.Primary_Author__r.Last_Name__c;
		wrapperObj.authoredBy.isActive = contentRecord.Primary_Author__r.User__r.IsActive;
		
    	if (UserContext.peopleId == contentRecord.Primary_Author__c) {
			wrapperObj.authoredBy.canFollow = false;
		
		} else {
			wrapperObj.authoredBy.canFollow = contentRecord.Primary_Author__r.User__r.isactive;
		}

		wrapperObj.canPublishUnpublish = AccessManager.calculatePublishUnpublishAccess(wrapperObj.site.isManager, wrapperObj.site.isContentManager,
				wrapperObj.status, wrapperObj.authoredBy.sfUserId, wrapperObj.site.access);
        wrapperObj.canModerate = AccessManager.calculateModerateAccess(wrapperObj.site.isManager, wrapperObj.site.isContentManager,
        		wrapperObj.status, wrapperObj.authoredBy.sfUserId, wrapperObj.site.access);
        wrapperObj.canDelete = AccessManager.calculateDeleteAccess(wrapperObj.site.isManager, wrapperObj.site.isContentManager,
        		wrapperObj.status, wrapperObj.authoredBy.sfUserId, wrapperObj.site.access);
        wrapperObj.canEdit 	= AccessManager.calculateEditAccess(wrapperObj.site.isManager, wrapperObj.site.isContentManager,
        		wrapperObj.status, wrapperObj.authoredBy.sfUserId, wrapperObj.site.access);
		wrapperObj.canSendUpdateNotification = wrapperObj.canEdit;
		wrapperObj.canMakeMustRead = AccessManager.calculateCanMakeMustRead(wrapperObj.type, wrapperObj.isPublished, wrapperObj.site.access, 
				contentRecord.Site__r.Is_Must_Read_Enabled__c, wrapperObj.site.isManager, wrapperObj.site.isContentManager);						  
        if(SimpplrContext.isFeatureContentOnboardingEnabled) {
            wrapperObj.canManageOnboardingContent = AccessManager.calculateCanManageOnboarding(wrapperObj.isPublished, contentRecord.Site__c, contentRecord.Site__r.Is_Onboarding_Enabled__c,wrapperObj.site.isFeatured);
		    wrapperObj.onboardingStatus = contentRecord.Content_Onboarding_Status__c;
        } else {
            wrapperObj.canManageOnboardingContent = false;
		    wrapperObj.onboardingStatus = ServiceConstants.CONTENT_STATUS_NOT_ONBOARDING;
        }
		wrapperObj.usefulContent.canViewHistory = wrapperObj.canPublishUnpublish;

	    if (contentRecord.Simpplr_Content_Feedback__r.isEmpty()) {
    		wrapperObj.usefulContent.hasUserRated = false;
	    
		} else {
    		wrapperObj.usefulContent.hasUserRated = true;
    		wrapperObj.usefulContent.hasUserRatedUseful	= contentRecord.Simpplr_Content_Feedback__r[0].Was_Content_Useful__c;
	    }

		wrapperObj.listOfTopics = convertToListOfTopicWrapper(contentRecord.Id, PageContext.getPageURL(Pages.app));
		wrapperObj.recentViewCount = getViewCountInLast30Days(contentRecord.Id);
    	List<File__c> fileList = getFilesByContentId(contentRecord.Id);
		Set<Id> fileIdSet = new Set<Id>();
        
		for (File__c fileObj : fileList) {
            
			if ('Image'.equalsIgnoreCase(fileObj.MIME_Type__c)) {
                fileIdSet.add(fileObj.id);
            }

        }

		List<Like__c> fileLikeList = [SELECT id, File__c  
				FROM Like__c 
				WHERE People__c =: UserContext.peopleId AND File__c IN:fileIdSet WITH SECURITY_ENFORCED];
        Set<Id> fileLikedSet = new Set<Id>();

        for (Like__c likeObj : fileLikeList ) {
            fileLikedSet.add(likeObj.file__c);
        }

        wrapperObj.listOfAlbumImagesAndVideos = new List<FileListingWrapper>();

		for (File__c fileObj : fileList){
			
			if (ServiceConstants.FILE_LOCATION_ATTACHMENT.equalsIgnoreCase(fileObj.Location__c)) {
    			wrapperObj.listOfFiles.add(convertFileToFileContentWrapper(fileObj));
    		
				}else if (ServiceConstants.FILE_LOCATION_INLINE.equalsIgnoreCase(fileObj.Location__c) && ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(fileObj.Repository__c)) {
					wrapperObj.listOfInlineVideos.add(convertFileToFileContentWrapper(fileObj));
				
				}else if (ServiceConstants.FILE_LOCATION_INLINE.equalsIgnoreCase(fileObj.Location__c)) {
	    			wrapperObj.listOfInlineImages.add(convertFileToFileContentWrapper(fileObj));
	    		
				}else if (ServiceConstants.File_LOCATION_MEDIA.equalsIgnoreCase(fileObj.Location__c) && 
						fileObj.Is_Title_Image__c) {

	    			if ('video'.equalsIgnoreCase(fileObj.MIME_Type__c)) {
	    				wrapperObj.img = fileObj.Thumbnail_URL__c;
	    				wrapperObj.imgLandscape = fileObj.Thumbnail_URL__c;

	    			} else {
	    				wrapperObj.img = Utility.getFileDownloadURL(fileObj.Content_Version__c);
			    		wrapperObj.imgLandscape = Utility.getFileDownloadURL(fileObj.Content_Version__c);
	    			}

		    		if ('mobile'.equalsIgnoreCase(readParam('origin'))) {
			    		wrapperObj.imgFile = convertFileToFileContentWrapper(fileObj);
			    		wrapperObj.imgLandscapeFile = convertFileToFileContentWrapper(fileObj);
		    		}

	    		}
	    		
    			if ('Image'.equalsIgnoreCase(fileObj.MIME_Type__c) || 
						'Video'.equalsIgnoreCase(fileObj.MIME_Type__c)) {
                	FileListingWrapper fileWrapObj = ObjectToWrapperAdapter.fileToWrapperWithoutIsLiked(fileObj);
                
				if (fileLikedSet.contains(fileObj.id) && 
						'Image'.equalsIgnoreCase(fileObj.MIME_Type__c)) {
                    fileWrapObj.isLiked = true;

                } else {
                    fileWrapObj.isLiked = false;
                }

                wrapperObj.listOfAlbumImagesAndVideos.add(fileWrapObj);
            }

		}

		Boolean includeMedia = readParam('includeMedia') != null && 
				'true'.equalsIgnoreCase(readParam('includeMedia')) ? true : false;
		
		if (includeMedia) {
			wrapperObj.listOfMedia = new List<FileListingWrapper>();
	    	FileDao fileDaoObj = new FileDao();
			List<File__c> listOfFiles = fileDaoObj.getSiteAlbumDetailAllFiles(null, 
					null, contentRecord.id);

			if (!listOfFiles.isEmpty()) {
				
				for (File__c contentDocObj : listOfFiles) {
	    			FileListingWrapper  fileWrapObj = new FileListingWrapper();
	    			fileWrapObj = ObjectToWrapperAdapter.fileToWrapper(contentDocObj);
	    			wrapperObj.listOfMedia.add(fileWrapObj);
	    		}

	    	}

		} else {
			FileDao fileDaoObj = new FileDao();
			List<File__c> topFileList = fileDaoObj.getListOfTopAlbumImages(contentRecord.Id);
			
			for (File__c fileObj : topFileList) {
    			ContentWrapper.AlbumImagesWrapper imagesWrapperObj = new ContentWrapper.AlbumImagesWrapper();
				imagesWrapperObj.albumMediaId = fileObj.id;

				if (String.isNotBlank(fileObj.Content_Version__c)) {
					imagesWrapperObj.isVideo = false;
					imagesWrapperObj.thumbnailImg = Utility.getFileDownloadURL(fileObj.Content_Version__c);
					imagesWrapperObj.img = Utility.getFileDownloadURLFor720BY480(fileObj.Content_Version__c);
				
				} else {
					imagesWrapperObj.isVideo = true;
					imagesWrapperObj.thumbnailImg = fileObj.Thumbnail_URL__c;
					imagesWrapperObj.img = fileObj.Thumbnail_URL__c;	
				}

    			wrapperObj.listOfTopAlbumImages.add(imagesWrapperObj);
    		}

		}
    		
        wrapperObj.isInHomeCarousel = false;
		wrapperObj.isInSiteCarousel = false;
		wrapperObj.addedToSegmentCarouselList = new List<ContentWrapper.SegmentWrapper>();
		
		if (contentRecord.Is_Published__c) {

			for (Carousel_Content__c carouselObj : contentRecord.Simpplr_Carousel_Contents__r) {
				
				if (String.isNotBlank(carouselObj.Site__c)) {
					wrapperObj.isInSiteCarousel = true;
				
				} else {
					wrapperObj.isInHomeCarousel = true;
				}

				if (String.isNotBlank(carouselObj.Segment__c)) {
					ContentWrapper.SegmentWrapper segWrapObj = new ContentWrapper.SegmentWrapper();
					segWrapObj.segmentId = carouselObj.Segment__c;
					segWrapObj.segmentName = carouselObj.Segment__r.Name__c;
					wrapperObj.addedToSegmentCarouselList.add(segWrapObj);
				}
			}
		}

		/* Protected Author and Allowlisted User **/
		wrapperObj.authoredBy.isProtectedAuthor = contentRecord.Primary_Author__r.Is_Protected_Author__c;	
		if(ServiceConstants.CONTENT_STATUS_REJECTED.equalsIgnoreCase(wrapperObj.status)) {
			wrapperObj.rejectionDetails = getRejectionComment(wrapperObj.id);
		}	

    	return wrapperObj;
    }
}