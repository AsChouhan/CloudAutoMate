/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing abstract class ContentDataServer extends DataServer{
		
		
	private File__c convertFileContentWrapperToFileObject(String siteId, String contentId, String folderId, String location, String titleImageType,
																	FileContentWrapper fileWrapperObj) {
		
		File__c fileObj 			= new File__c(); 
        fileObj.Title__c 			= fileWrapperObj.title;
        fileObj.Size__c 			= fileWrapperObj.size != null ? Decimal.valueOf(fileWrapperObj.size) : 0;
        fileObj.MIME_Type__c		= fileWrapperObj.fileType;
        
        if (!ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(fileWrapperObj.context)) {
        	fileObj.Content_Version__c 	= fileWrapperObj.contentVersionId;
        }
		fileObj.Content_Document__c = fileWrapperObj.contentDocumentId;
		fileObj.author__c = UserContext.peopleId;
		fileObj.Simpplr_Content__c 	= contentId;
		fileObj.Site__c = siteId;
        fileObj.Folder__c = folderId;
        fileObj.Location__c = location;
        fileObj.MIME_Type__c = fileWrapperObj.type;
        
		fileObj.Is_Title_Image__c = false;
        if(ServiceConstants.FILE_LOCATION_COVER.equalsIgnoreCase(location)) {
	        	fileObj.Title_Image_Type__c = titleImageType;
	        	fileObj.Is_Title_Image__c = true;
        }
		fileObj.Repository__c = fileWrapperObj.context;
		if(ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(fileWrapperObj.context)){
			Integer captionLanguageId = ServiceConstants.SIMPPLR_LANG_VS_KALTURA_LANG_ID_MAP.get(UserContext.languageLocaleKey);
			if(captionLanguageId != null){
				fileObj.Video_Caption_Language__c =  String.valueOf(captionLanguageId);
			}
			fileObj.video_provider__c = fileWrapperObj.context ;
			fileObj.External_Id__c = String.isBlank(fileWrapperObj.externalFileId) ? String.isNotBlank(fileWrapperObj.url.subStringAfter('?').subStringBetween('fileId=','&'))?fileWrapperObj.url.subStringAfter('?').subStringBetween('fileId=','&'): fileWrapperObj.url.subStringAfter('fileId='): fileWrapperObj.externalFileId;	
			fileObj.Thumbnail_url__c = ServiceConstants.NATIVE_VIDEO_BASE_URL + SimpplrContext.Integrations.get(ServiceConstants.VIDEO_PROVIDER_NATIVE).External_Id__c +'/thumbnail/entry_id/' + fileObj.External_Id__c +'/width/550/height/480';
        }if(ServiceConstants.FILE_LOCATION_ATTACHMENT.equalsIgnoreCase(location)) {
        	fileObj.url__c = fileWrapperObj.url;
			// Need to optimize below line as We must get value in externalFileId from UI
			fileObj.External_Id__c = String.isBlank(fileWrapperObj.externalFileId) ? String.isNotBlank(fileWrapperObj.url.subStringAfter('?').subStringBetween('fileId=','&'))?fileWrapperObj.url.subStringAfter('?').subStringBetween('fileId=','&'): fileWrapperObj.url.subStringAfter('fileId='): fileWrapperObj.externalFileId;	
        }
		if(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(fileWrapperObj.context)){
			fileObj.SP_Instance_Id__c = UserContext.spInstanceId;
			fileObj.External_Folder_Id__c = Utility.getParamValueFromUrl(fileWrapperObj.url, 'rootDirectory');
		}
		return fileObj;
	}
	
	public List<TopicWrapper> convertToListOfTopicWrapper(String contentId, String topicURL){
		List<TopicWrapper> listOfTopics = new List<TopicWrapper>(); 
		for(TopicAssignment topicAssignmentRecord : [SELECT TopicId, Topic.Name FROM TopicAssignment WHERE EntityId =:contentId AND EntityType='Simpplr_Content' WITH SECURITY_ENFORCED]) {
			if(String.isNotBlank(topicAssignmentRecord.topic.name)) {
				TopicWrapper wrapperObj 		= new TopicWrapper();
				wrapperObj.id 					= topicAssignmentRecord.topic.id;
				wrapperObj.topicAssignmentId 	= topicAssignmentRecord.Id;
				wrapperObj.name 				= topicAssignmentRecord.topic.name;
				wrapperObj.url 					= topicURL + '?u=/topic/' + topicAssignmentRecord.Topic.Id + '/content';
				listOfTopics.add(wrapperObj);
			}
		}
		return listOfTopics;
	}
	
	public List<File__c> getFilesByContentId(String contentId){

		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', contentId);
		String filesQuery = 'SELECT id, Title_Image_Type__c,Description__c, Is_Title_Image__c, Thumbnail_URL__c, '+
									' MIME_Type__c, Simpplr_Content__r.Site__c,External_Id__c, Repository__c, URL__c, '+
									' Title__c, Site__c, Content_Document__c,Content_Version__c, size__c, Location__c,'+
									' Likes__c,Simpplr_Content__r.Album_Image_Count__c,'+
									' Simpplr_Content__r.Album_Video_Count__c, Video_Status__c, is_Deleted__c, SP_Instance_Id__c '+
									' FROM File__c WHERE is_Deleted__c = false '+
									' AND (Location__c != \'media\' OR Is_Title_Image__c = true) AND'+
		 							' Simpplr_Content__c =:soqlParam1 ORDER BY Order__c';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> fileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
		return fileList;
	}
	
	public String getContentStatus(String status, Boolean isPublished) {
		String contentStatus;
		if(ServiceConstants.CONTENT_STATUS_SUBMITTED.equalsIgnoreCase(status)){
			contentStatus = ServiceConstants.CONTENT_STATUS_PENDING.toLowerCase();
			
		} else if (ServiceConstants.CONTENT_STATUS_DRAFT.equalsIgnoreCase(status)){
			contentStatus = ServiceConstants.CONTENT_STATUS_DRAFT.toLowerCase();
		
		} else if (ServiceConstants.CONTENT_STATUS_PREDRAFT.equalsIgnoreCase(status)){
			contentStatus = ServiceConstants.CONTENT_STATUS_PREDRAFT.toLowerCase();
				
		} else if (ServiceConstants.CONTENT_STATUS_REJECTED.equalsIgnoreCase(status)){ 
			contentStatus = ServiceConstants.CONTENT_STATUS_REJECTED.toLowerCase();
			
		} else if (isPublished){
			contentStatus = ServiceConstants.CONTENT_STATUS_PUBLISH.toLowerCase();
			
		} else {
			contentStatus = ServiceConstants.CONTENT_STATUS_UNPUBLISH.toLowerCase();
		} 
		
		return contentStatus;
	}

	public List<String> splitBodyString(String contentBody){
		List<String> contentBodyParts = new List<String>();
		if(contentBody != null && contentBody.length() > 131000){
            contentBodyParts.add(contentBody.substring(0, 131000));
            if((contentBody.length() - 131000) > 131000){
                contentBodyParts.add(contentBody.substring(131000, 131000 + 131000));
                contentBodyParts.add(contentBody.substring(131000 + 131000, contentBody.length()));
            }else{
                contentBodyParts.add(contentBody.substring(131000, contentBody.length()));
                contentBodyParts.add(null);
            }
        } else if(contentBody == null || contentBody.length() < 131000){
            contentBodyParts.add(contentBody);
            contentBodyParts.add(null);
            contentBodyParts.add(null);
        }
		return contentBodyParts;
	}

	public String getMergedBodyJson(String textJson, String textMainJson, String textMainContinuedJson){

		return (String.isNotBlank(textJson) ? textJson : '') +
				(String.isNotBlank(textMainJson) ? textMainJson : '') + 
				(String.isNotBlank(textMainContinuedJson) ? textMainContinuedJson : '');
	}

	public List<String> getContentJsonBodyParts(String bodyJson, Map<String, String> mapOfNewTopics){
		for(String topicStr : mapOfNewTopics.keySet()) {
			if(topicStr.startsWithIgnoreCase('_New_')) {
				bodyJson = bodyJson.replaceAll(topicStr, mapOfNewTopics.get(topicStr));
			}
		}
		return splitBodyString(bodyJson);
	}

    public List<String> getContentBodyParts(String body, Map<String, String> mapOfNewTopics) {
		String sanitizedHTML = body;
		for(String topicStr : mapOfNewTopics.keySet()) {
			if(topicStr.startsWithIgnoreCase('_New_')) {
				sanitizedHTML = sanitizedHTML.replaceAll('data-token-id="' + topicStr + '"', 'data-token-id="' + mapOfNewTopics.get(topicStr) + '"');
				sanitizedHTML = sanitizedHTML.replaceAll(topicStr, mapOfNewTopics.get(topicStr));
			}
		}
		return splitBodyString(sanitizedHTML);
	}
	
	public ContentWrapper.RejectionDetailWrapper getRejectionComment(String contentId) {
		ContentWrapper.RejectionDetailWrapper rejectionDetails = new ContentWrapper.RejectionDetailWrapper();
		List<Content_Audit_Trail__c> auditTrailList = [SELECT Comment__c, Action_DateTime__c, Action_By__c
													FROM Content_Audit_Trail__c 
													WHERE content__c=:contentId
													AND Action__c='Rejected' WITH SECURITY_ENFORCED
													Order by createddate desc limit 1];
		if(!auditTrailList.isEmpty()) {
			rejectionDetails.message = auditTrailList[0].Comment__c;
			rejectionDetails.rejectedAt = Utility.dateTimeToMomentJSDateTime(auditTrailList[0].Action_DateTime__c);
			rejectionDetails.rejectedBy = getPeopleListWrapper(auditTrailList[0].Action_By__c);			
		}
		return rejectionDetails;
	}
    
    public  List<String> getContentDetailFieldList() {
    	String segmentId = String.isBlank(UserContext.SegmentId) ? '' : UserContext.SegmentId;
    	return New List<String>{
            'Id', 
            'Type__c', 
            'Title__c', 
            'Version__c', 
            'Is_Deleted__c',
            'Activated_By_Feature__c',
            'Display_Excerpt__c',
            'Summary_1__c',
            'Text_Main__c', 
            'Text_Main_Continued__c', 
            'Text_Intro__c',
			'Text_Json__c',
			'Text_Main_Json__c',
			'Text_Main_Continued_Json__c',
            'Status__c',
            'Allow_comments__c',
            'Title_Image_Caption__c',
            'Publish_Start_DateTime__c',
            'Publish_End_DateTime__c',
            'First_Publish_DateTime__c',
			'Created_DateTime__c',
			'CreatedBy_People__c',
			'Last_UpdatedBy_People__c',
			'Last_Updated_DateTime__c',
            'Site__c',  
            'Site__r.name',
			'Site__r.Allow_Comments__c',
            'Site__r.Is_Active__c',
            'Site__r.Chatter_Group_Id__c',
            'Site__r.Site_Type__c',
            'Site__r.Origin__c',
            'Site__r.Show_In_Simpplr__c',
            'Site__r.Landing_Page__c', 
			'Site__r.Is_Must_Read_Enabled__c',
			'Site__r.Allow_File_Upload_App_Permission__c',
			'Site__r.Is_Featured__c',
			'Site__r.Question_Answer_Enabled__c',
			'Site__r.Is_Content_Unfurl_Enabled__c',
			'Primary_Author__c',
            'Primary_Author__r.Full_Name__c',
            'Primary_Author__r.First_Name__c',
            'Primary_Author__r.Last_Name__c',
            'Primary_Author__r.Email__c',
            'Primary_Author__r.Department__c',
            'Primary_Author__r.title__c',
			'Primary_Author__r.city__c',
			'Primary_Author__r.state__c',
			'Primary_Author__r.country__c',
			'Primary_Author__r.Street__c',
			'Primary_Author__r.Phone__c',
			'Primary_Author__r.Mobile_Phone__c',
			'Primary_Author__r.Extension__c',
			'Primary_Author__r.Is_Protected_Author__c',
			'Primary_Author__r.User__r.MediumPhotoURL',
			'Primary_Author__r.User__r.FullPhotoURL',
            'Primary_Author__r.User__r.Id',
            'Primary_Author__r.User__r.SmallPhotoUrl',
            'Primary_Author__r.User__r.IsActive',
            'Pages_Category__c',
            'Pages_Category__r.Name__c',
			'Question_Answer_Enabled__c',
            'Cover_Image_Layout__c',
            'CreatedDate',
            'lastModifiedDate',
            'Is_Published__c',
            'Is_Unpublished__c',
            'Likes__c',
            'Feed_Posts__c',
            'Feed_Questions__c',
            'Last_Edited_DateTime__c',
            'Site__r.Title_Content_Version__c',
            'Site__r.Is_Onboarding_Enabled__c',
			'(Select Id, Content__c, Audience_Type__c, Expiry_DateTime__c, Message__c, Duration__c, Removed_By_People__c, Removed_DateTime__c, Must_Read_Confirm_Count__c, Mark_DateTime__c, Marked_By_People__c, Marked_By_People__r.Full_Name__c, Marked_By_People__r.User__r.FullPhotoURL  from Must_Read_Audits__r order by Mark_DateTime__c desc limit 1 )',
            '(Select Id, Confirm_DateTime__c  from Must_Read_Confirm_History__r Where People__c =:loggedInPeopleId and Must_Read_Audit__r.Removed_DateTime__c = null AND (Must_Read_Audit__r.Expiry_DateTime__c = null OR Must_Read_Audit__r.Expiry_DateTime__c >: currentDateTime))',
			'(select id from Bookmarked_Content__r where People__c =:loggedInPeopleId AND Is_Deleted__c = false)',
			'(Select Id FROM Content_Notification_Setting__r where People__c =:loggedInPeopleId And Notification_Enabled__c=true)',
            '(select Was_Content_Useful__c from Simpplr_Content_Feedback__r where Submitter__c =:loggedInPeopleId)',
            '(select id from Likes_Simpplr_Content__r where People__c =: loggedInPeopleId and Is_Deleted__c=false)',
            '(select id, Segment__c, Segment__r.Name__c, Site__c from Simpplr_Carousel_Contents__r where  Is_Deleted__c = false) ',
			'Content_Onboarding_Status__c'
        };
    }
    
    public Integer getViewCountInLast30Days(String contentId) {
    	Integer ViewCount;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', contentId);
    	String query = 'select sum(views__c) views from Analytics_Top_Content__c where content__c=:soqlParam1 and Date__c  = LAST_N_DAYS: 30';
    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<AggregateResult> aggrList = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		for(AggregateResult ar : aggrList) {
    		ViewCount = Integer.valueOf(ar.get('views'));
    	}
    	return ViewCount == null ? 0 : ViewCount;
    }
    
    public FileContentWrapper convertFileToFileContentWrapper(File__c fileObj) {
    	FileContentWrapper fileWrapperObj = New FileContentWrapper();
  		fileWrapperObj.fileId = fileObj.id;
  		fileWrapperObj.type = Utility.getFileType(fileObj.MIME_Type__c);
  		fileWrapperObj.context = fileObj.Repository__c != null ? fileObj.Repository__c.toLowerCase() : ServiceConstants.STORAGE_TYPE_INTRANET_STRING;
  		fileWrapperObj.provider = fileWrapperObj.context;
  		if(String.isNotBlank(fileObj.Content_Document__c)) {
  			fileWrapperObj.id = fileObj.Content_Document__c;
  			Map<String, String> fileDetailParams = new Map<String, String>{'fileId' => fileObj.Content_Document__c};
	  		if(String.isNotBlank(fileObj.Simpplr_Content__r.Site__c)){
				fileDetailParams.put('siteId', fileObj.Simpplr_Content__r.Site__c);
			}
			fileWrapperObj.url = PageContext.getPageURL(Pages.FileDetail, fileDetailParams);
	  		fileWrapperObj.downloadUrl = Utility.getFileDownloadURL(fileObj.Content_Version__c); 
	  		if('jpeg'.equalsIgnoreCase(fileWrapperObj.type) 
					|| 'jpg'.equalsIgnoreCase(fileWrapperObj.type) 
					|| 'png'.equalsIgnoreCase(fileWrapperObj.type)  
					|| 'gif'.equalsIgnoreCase(fileWrapperObj.type)
					|| 'image'.equalsIgnoreCase(fileWrapperObj.type) 
					|| 'pdf'.equalsIgnoreCase(fileWrapperObj.type)) {
	  			fileWrapperObj.thumbnailImg = Utility.getFileDownloadURLFor240BY180(fileObj.Content_Version__c);
				fileWrapperObj.imgTHUMB240BY180URL = SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +fileObj.Content_Document__c+'/rendition?type=THUMB240BY180';
	            fileWrapperObj.imgTHUMB720BY480URL = SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +fileObj.Content_Document__c+'/rendition?type=THUMB720BY480';
	            fileWrapperObj.imgFullURL = SImpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +fileObj.Content_Document__c+'/content';
			}

	  		fileWrapperObj.contentVersionId = fileObj.Content_Version__c;
	  		fileWrapperObj.contentDocumentId = fileObj.Content_Document__c;
  		} else {
			fileWrapperObj.isAccessible = !fileObj.Is_Deleted__c;
  			if (ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(fileWrapperObj.provider) || 
  					ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING.equalsIgnoreCase(fileWrapperObj.provider)) {
				fileWrapperObj.url = fileObj.Url__c;
				if(String.isNotBlank(fileObj.Url__c)) {
					fileWrapperObj.rootDirectory = Utility.getParamValueFromUrl(fileObj.Url__c, 'rootDirectory');
				}				
  			} else {
				if(ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(fileWrapperObj.context)) {
					if(SimpplrContext.isNativeVideo) {
						fileWrapperObj.url = PageContext.getPageURL(Pages.app) + '?u=/video/' + fileObj.External_id__c;
						fileWrapperObj.videoStatus = fileObj.Video_Status__c != null ? Integer.valueOf(fileObj.Video_Status__c) : 1;
						fileWrapperObj.thumbnailImg =  fileObj.Thumbnail_URL__c ;
						fileWrapperObj.isVideo = true;
					} else {
						fileWrapperObj.isAccessible = false;
					}
				} else {
					fileWrapperObj.url = PageContext.getPageURL(Pages.FileDetail, new Map<String, String>{'fileId' => fileObj.External_Id__c, 'provider' => fileWrapperObj.context});
				}				
			}
  			fileWrapperObj.externalFileId = fileObj.External_Id__c;		
  			fileWrapperObj.id = fileObj.External_Id__c;	
  		}
		if(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(fileWrapperObj.context)){
			fileWrapperObj.spInstanceId = fileObj.SP_Instance_Id__c;
		}
		fileWrapperObj.fileURL = fileWrapperObj.url;
		fileWrapperObj.title = fileObj.Title__c;
		fileWrapperObj.fileExtension = String.isNotBlank(fileWrapperObj.title) && String.isNotBlank(fileWrapperObj.title.substringAfterLast('.')) ? fileWrapperObj.title.substringAfterLast('.') : null;
		fileWrapperObj.size = fileObj.size__c!=null ? Integer.valueOf(fileObj.size__c):0; 
		return fileWrapperObj;
	}
    
    public Map<String, String> createNewTopics(List<TopicWrapper> listOfTopics, List<String> listOfContentBodyTopics) {
    		Map<String, String> mapOfTopicNameAndEnteredText = new Map<String, String>(); 
			Map<String, String> mapOfSmallcaseTopicNameAndEnteredText = new Map<String, String>();
    		if(listOfTopics != null) {
	    		for(TopicWrapper topicObj : listOfTopics) {
	    			if(String.isBlank(topicObj.id)) {
	    				String topicName = Utility.removeAllHashSymbolFromStart(topicObj.name).trim();
	                	mapOfTopicNameAndEnteredText.put(topicName, topicObj.name);
						mapOfSmallcaseTopicNameAndEnteredText.put(topicName.tolowercase(), topicObj.name);
	    			}
	    		}
    		}
    		if(listOfContentBodyTopics != null) {
	    		for(String topicStr : listOfContentBodyTopics) {
	    			if(String.isNotBlank(topicStr) && topicStr.startsWithIgnoreCase('_new_')) {
	    				String topicName = topicStr.replaceFirst('_new_','');
	    				mapOfTopicNameAndEnteredText.put(topicName, topicStr);
						mapOfSmallcaseTopicNameAndEnteredText.put(topicName.tolowercase(), topicStr);
	    			} 
	    		}
    		}
    		logger.logDebug('ContentDataServer.createNewTopics()----mapOfTopicNameAndEnteredText----' + mapOfTopicNameAndEnteredText);
    		Map<String, String> mapOfNewTopics = new Map<String, String>();
    		if(mapOfTopicNameAndEnteredText.isEmpty() == false) {
    			Set<String> setOfTopicNames = mapOfTopicNameAndEnteredText.keySet();
    			String topicQuery= 'Select Id, Name from Topic where Name in: setOfTopicNames';
			if(SimpplrContext.isCommunitiesEnabled){
				topicQuery = topicQuery+' AND NetworkId = null';
			}
			List<Topic> listOfDBTopics = Database.query(topicQuery);
			logger.logDebug('ContentDataServer.createNewTopics()----listOfDBTopics----' + listOfDBTopics);
			for(Topic dbTopic :listOfDBTopics){
				String enteredText = mapOfSmallcaseTopicNameAndEnteredText.get(dbTopic.name.tolowercase());
    				if(String.isNotBlank(enteredText)) {
    					mapOfTopicNameAndEnteredText.remove(dbTopic.name);
    					mapOfNewTopics.put(enteredText, dbTopic.Id);
    				}
    			}
    			if(mapOfTopicNameAndEnteredText.isEmpty() == false && UserContext.canCreateTopics) {
				List<Topic> listOfNewTopics = new List<Topic>(); 
    				for(String topicStr : mapOfTopicNameAndEnteredText.keySet()) {
    					listOfNewTopics.add(new Topic(name = topicStr));
    				}

					if(listOfNewTopics.isEmpty() == false){

						SIMPESAPI.accessController().setArrayOperationMode(SIMPSFDCAccessController.OperationMode.BEST_EFFORT);
						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
						SIMPSFDCAccessControlResults.InsertResults insertResults = SIMPESAPI.accessController().insertAsUser(listOfNewTopics, new List<Schema.SObjectField>{
							Topic.name});
						listOfNewTopics	= (List<Topic>) insertResults.getInsertedObjects();
					}

    				logger.logDebug('ContentDataServer.createNewTopics()----listOfNewTopics----' + listOfNewTopics);
		        	for(Topic topicSaved : listOfNewTopics) {
		        		String enteredText = mapOfTopicNameAndEnteredText.get(topicSaved.name);
    					if(String.isNotBlank(enteredText) && String.isNotBlank(topicSaved.Id)) {
						mapOfNewTopics.put(enteredText, topicSaved.Id);
		        		}
		        	}
    			}
    		}
    		logger.logDebug('ContentDataServer.createNewTopics()----mapOfNewTopics----' + mapOfNewTopics);
    		return mapOfNewTopics;
    }
	
	public void saveTopicAssignmentsToDB(Boolean isEdit, Id contentId, List<TopicWrapper> listOfTopics, List<String> listOfContentBodyTopics, Map<String, String> mapOfNewTopics) {
		Map<String, TopicAssignment> mapOfTopicIdAndTopicAssignment = new Map<String, TopicAssignment>();
        if(listOfTopics != null) {
	        for(TopicWrapper topicObj : listOfTopics) {
	            if(String.isNotBlank(topicObj.id)) {
					mapOfTopicIdAndTopicAssignment.put(topicObj.id, new TopicAssignment(TopicId = topicObj.id, EntityId = contentId));
	            
	            } else if(mapOfNewTopics.containsKey(topicObj.name)) {
	            		String topicId = mapOfNewTopics.get(topicObj.name);
					mapOfTopicIdAndTopicAssignment.put(topicId, new TopicAssignment(TopicId = topicId, EntityId = contentId));
	            	
	            }
	        }
        }
        if(listOfContentBodyTopics != null) {
        		for(String topicStr : listOfContentBodyTopics) {
    				if(mapOfNewTopics.containsKey(topicStr)) {
    					String topicId = mapOfNewTopics.get(topicStr);
    					mapOfTopicIdAndTopicAssignment.put(topicId, new TopicAssignment(TopicId = topicId, EntityId = contentId));
    					
    				} else if(String.isNotBlank(topicStr) && topicStr.startsWithIgnoreCase('_new_') == false) {
    					mapOfTopicIdAndTopicAssignment.put(topicStr, new TopicAssignment(TopicId = topicStr, EntityId = contentId));
    					
        			}
        		}
        	
        }
        List<TopicAssignment> listOfDeletedTopicAssignment = new List<TopicAssignment>();
        List<TopicAssignment> listOfNewTopicAssignment = new List<TopicAssignment>();
		
		if(isEdit) {
			List<TopicAssignment> existingTopicAssignmentList= [Select id, TopicId from TopicAssignment where entityId=:contentId WITH SECURITY_ENFORCED];
			
			for(TopicAssignment topicAssignmentObj : existingTopicAssignmentList) {
				if(mapOfTopicIdAndTopicAssignment.containsKey(topicAssignmentObj.topicId)) {
					mapOfTopicIdAndTopicAssignment.remove(topicAssignmentObj.topicId);
					
				} else {
					listOfDeletedTopicAssignment.add(topicAssignmentObj);
					
				}
			}
		}
		if(listOfDeletedTopicAssignment.size() > 0) {
			delete listOfDeletedTopicAssignment;
		}
		if(mapOfTopicIdAndTopicAssignment.size() > 0) {

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(mapOfTopicIdAndTopicAssignment.values(), new List<Schema.SObjectField>{
				TopicAssignment.TopicId,
				TopicAssignment.EntityId});

		}
	}
	
	public void saveContentFilesToDB(Boolean isEdit, Id contentId, ContentWrapper wrapperObj, String status) {
		String contentFilesFolderId;
		String contentImagesFolderId; 
		String contentVideosFolderId; 
		String albumFolderId;
		if(String.isNotBlank(wrapperObj.siteId)) {
			SiteDao siteDaoObj = new SiteDao();
	        Map<String, Folder__c> mapOfSystemFolders4Site = siteDaoObj.getMapOfSystemFoldersForSite(wrapperObj.siteId);
	        if(!mapOfSystemFolders4Site.isEmpty()) {
				contentFilesFolderId = mapOfSystemFolders4Site.get('Content Files.Files').Id;
				contentImagesFolderId = mapOfSystemFolders4Site.get('Content Files.Images').Id;
				if(SimpplrContext.isNativeVideo) {
					contentVideosFolderId = mapOfSystemFolders4Site.get('Content Files.Videos').Id;
				}
	        }
		}
        
		List<File__c> listOfContentFiles = new List<File__c>(); 
        List<File__c> listOfNewFiles = new List<File__c>();
        List<File__c> listOfUpdatedFiles = new List<File__c>();
        List<File__c> listOfDeletedFiles = new List<File__c>();

        Map<Id, File__c> mapOfExistingTitleImages = new Map<Id, File__c>();
        Map<String, File__c> mapOfExistingAttachments = new Map<String, File__c>();
		Map<Id, File__c> mapOfExistingInlineImages = new Map<Id, File__c>();
		Map<Id, File__c> mapOfExistingInlineVideos = new Map<Id, File__c>();

        if(isEdit) {
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', contentId);
	        	String filesQuery = 'select id, Location__c, Content_Document__c, Repository__c, '+
									  ' Is_Title_Image__c, Content_Version__c, MIME_Type__c'+
									  ' from File__c'+
									  ' where is_deleted__c = false'+
									  ' And Simpplr_Content__c=:soqlParam1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<File__c> fileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
		    	for(File__c fileObj : fileList) {
		    		if(ServiceConstants.File_LOCATION_COVER.equalsIgnoreCase(fileObj.Location__c)) {
		    			mapOfExistingTitleImages.put(fileObj.id, fileObj);
		    		
					}else if(ServiceConstants.FILE_LOCATION_INLINE.equalsIgnoreCase(fileObj.Location__c) && ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(fileObj.Repository__c)) {
		    			mapOfExistingInlineVideos.put(fileObj.id, fileObj);
		    			
		    		}else if(ServiceConstants.FILE_LOCATION_ATTACHMENT.equalsIgnoreCase(fileObj.Location__c)) {
		    			mapOfExistingAttachments.put(fileObj.id, fileObj);
		    		
		    		} else if(ServiceConstants.FILE_LOCATION_INLINE.equalsIgnoreCase(fileObj.Location__c)) {
		    			mapOfExistingInlineImages.put(fileObj.id, fileObj);
		    			
		    		} else if(ServiceConstants.File_LOCATION_MEDIA.equalsIgnoreCase(fileObj.Location__c) && 'image'.equalsIgnoreCase(fileObj.MIME_Type__c)) {
		    			listOfContentFiles.add(fileObj);
					
					}
		    	}
        } 
        
        if(wrapperObj.imgFile == null) {
        		listOfDeletedFiles.addAll(mapOfExistingTitleImages.values());
        
        } else if(mapOfExistingTitleImages.containsKey(wrapperObj.imgFile.fileId) == false) {
	        	listOfDeletedFiles.addAll(mapOfExistingTitleImages.values());
	        	
	        	listOfNewFiles.add(convertFileContentWrapperToFileObject(wrapperObj.siteId, contentId, contentImagesFolderId,
	        															ServiceConstants.FILE_LOCATION_COVER,
	        															 ServiceConstants.TITLE_IMAGE_TYPE_THUMBNAIL,
	        															 wrapperObj.imgFile));
	        	listOfNewFiles.add(convertFileContentWrapperToFileObject(wrapperObj.siteId, contentId, contentImagesFolderId,
	        															 ServiceConstants.FILE_LOCATION_COVER,
	        															 ServiceConstants.TITLE_IMAGE_TYPE_WIDESCREEN,
	        															 wrapperObj.imgLandscapeFile));
	        	if(wrapperObj.imgOriginalFile != null) {
		        	listOfNewFiles.add(convertFileContentWrapperToFileObject(wrapperObj.siteId, contentId, contentImagesFolderId,
		        															 ServiceConstants.FILE_LOCATION_COVER,
		        															 ServiceConstants.TITLE_IMAGE_TYPE_ORIGINAL,
		        															 wrapperObj.imgOriginalFile));
	        	}
        
        } else {
        		listOfContentFiles.addAll(mapOfExistingTitleImages.values());
        }
        
        if(wrapperObj.listOfFiles != null && !wrapperObj.listOfFiles.isEmpty()) {
        		Integer fileOrder = 1;
	        for(FileContentWrapper fileWrapperObj : wrapperObj.listOfFiles) {
		        	File__c fileObj = mapOfExistingAttachments.get(fileWrapperObj.fileId);
		        	if(fileObj == null) {
						String folderId = contentFilesFolderId;
						if(fileWrapperObj.isImage) {
							folderId  = contentImagesFolderId;
						} else if(ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(fileWrapperObj.context)) {
							folderId  = contentVideosFolderId;
						}
		        		fileObj = convertFileContentWrapperToFileObject(wrapperObj.siteId, contentId, folderId,
	        															ServiceConstants.FILE_LOCATION_ATTACHMENT,
	        															null, fileWrapperObj);
	        			
						fileObj.order__c = fileOrder++;
	        			listOfNewFiles.add(fileObj);
		        	} else {
		        		fileObj.order__c = fileOrder++;
		        		listOfUpdatedFiles.add(fileObj);
		        		mapOfExistingAttachments.remove(fileWrapperObj.fileId);
		        	}
	        }
        }
        listOfDeletedFiles.addAll(mapOfExistingAttachments.values());
        if(wrapperObj.listOfInlineImages != null && !wrapperObj.listOfInlineImages.isEmpty()) {
	        for(FileContentWrapper fileWrapperObj : wrapperObj.listOfInlineImages) {
		        	if(mapOfExistingInlineImages.containsKey(fileWrapperObj.fileId)) {
		        		listOfContentFiles.add(mapOfExistingInlineImages.get(fileWrapperObj.fileId));
		        		mapOfExistingInlineImages.remove(fileWrapperObj.fileId);
		        	} else {
		        		File__c fileObj = convertFileContentWrapperToFileObject(wrapperObj.siteId, contentId, contentImagesFolderId,
	        															ServiceConstants.FILE_LOCATION_INLINE,
	        															null, fileWrapperObj);
	        			listOfNewFiles.add(fileObj);
		        	}
	        }
		}
		listOfDeletedFiles.addAll(mapOfExistingInlineImages.values());
		//Insert List Of Inline Videos 
		if(wrapperObj.listOfInlineVideos != null && !wrapperObj.listOfInlineVideos.isEmpty()) {
	        for(FileContentWrapper fileWrapperObj : wrapperObj.listOfInlineVideos) {
		        	if(mapOfExistingInlineVideos.containsKey(fileWrapperObj.fileId)) {
		        		listOfContentFiles.add(mapOfExistingInlineVideos.get(fileWrapperObj.fileId));
		        		mapOfExistingInlineVideos.remove(fileWrapperObj.fileId);
		        	} else {
		        		File__c fileObj = convertFileContentWrapperToFileObject(wrapperObj.siteId, contentId, contentVideosFolderId,
	        															ServiceConstants.FILE_LOCATION_INLINE,
	        															null, fileWrapperObj);
	        			listOfNewFiles.add(fileObj);
		        	}
	        }
        }

		listOfDeletedFiles.addAll(mapOfExistingInlineVideos.values());
    		
        if(listOfNewFiles.isEmpty() == false) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPSFDCAccessControlResults.InsertResults result = SIMPESAPI.accessController().insertAsUser(listOfNewFiles, new List<Schema.SObjectField>{
				File__c.Title__c,
				File__c.Size__c,
				File__c.MIME_Type__c,
				File__c.Content_Version__c,
				File__c.Content_Document__c,
				File__c.author__c,
				File__c.Simpplr_Content__c,
				File__c.Site__c,
				File__c.Folder__c,
				File__c.Location__c,
				File__c.Title_Image_Type__c,
				File__c.Is_Title_Image__c,
				File__c.Repository__c,
				File__c.video_provider__c,
				File__c.External_Id__c,
				File__c.Thumbnail_url__c,
				File__c.url__c,
				File__c.Order__c,
				File__c.Video_Caption_Language__c,
				File__c.SP_Instance_Id__c,
				File__c.External_Folder_Id__c
            });
			listOfNewFiles = (List<File__c>)result.getInsertedObjects();
        }
        	
        if(listOfUpdatedFiles.isEmpty() == false) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, File__c>(listOfUpdatedFiles), new List<Schema.SObjectField>{
														File__c.order__c
													});
        }  
        if(listOfDeletedFiles.isEmpty() == false) {
		    	for(File__c fileObj : listOfDeletedFiles) {
		    		fileObj.Simpplr_Content__c = null;
		    	}
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<Id, File__c>(listOfDeletedFiles), new List<Schema.SObjectField>{
															File__c.Simpplr_Content__c
														});
        }   
        listOfContentFiles.addAll(listOfNewFiles);
        listOfContentFiles.addAll(listOfUpdatedFiles);
        SimpplrContext.skipContentDocTrigger = true;
		
		// Create CDL for all files based on Content Status, siteId and siteType
		if((listOfContentFiles.size() > 0)) {
			FileDao fileDaoObj = new FileDao();
			if(ServiceConstants.CONTENT_STATUS_DRAFT.equals(status)) {
				// share files with site managers and content managers
				SiteDao siteDaoObj = new SiteDao();
				Set<String> setOfContentApprovers = new Set<String>();
				Set<Id> siteManagersIdSet = siteDaoObj.getSiteManagerIdsSet(SiteContext.siteId);
				for(Id managerId : siteManagersIdSet) {
					setOfContentApprovers.add((String)managerId);
				}
				setOfContentApprovers.addAll(siteDaoObj.getSiteContentManagerUserIdsSet(SiteContext.siteId));
				
				fileDaoObj.createContentDocumentLinks(listOfContentFiles, setOfContentApprovers);
			
			} else {
				if(String.isNotBlank(wrapperObj.siteId)) {
					fileDaoObj.createContentDocumentLinks(status, true, listOfContentFiles, SiteContext.chatterGroupId, SiteContext.isPublicSite);
				} else {
					fileDaoObj.createContentDocumentLinks(status, true, listOfContentFiles, SiteContext.chatterGroupId, null);
				}

			}
        }
		
		SimpplrContext.skipContentDocTrigger = false;
	}
	
	public void saveAISuggestedTopicsToDB(List<ContentWrapper.SuggestedTopicsWrapper> listOfSuggestedTopics, Id contentId, List<TopicWrapper> listOfTopics, Map<String, String> mapOfNewTopics) {
		Map<String, TopicAssignment> mapOfTopicIdAndTopicAssignment = new Map<String, TopicAssignment>();
        List<String> suggestedTopicsList =new List<String>();
		if(listOfSuggestedTopics != null) {
	        for(ContentWrapper.SuggestedTopicsWrapper topicObj : listOfSuggestedTopics) {
	            suggestedTopicsList.add(topicObj.name);
	        }
        }
		List<String> contentTopicsSelectedList =new List<String>();
		if(listOfTopics != null) {
	        for(TopicWrapper topicObj : listOfTopics) {
	            if(mapOfNewTopics.containsKey(topicObj.name)) {
	            		String topicId = mapOfNewTopics.get(topicObj.name);
						contentTopicsSelectedList.add(topicObj.name);
	            }
	        }
        }
		if(!suggestedTopicsList.isEmpty()){
			Analytics_Topic_Suggestion__c topicSuggestObj = new Analytics_Topic_Suggestion__c();
			topicSuggestObj.Suggested_Topics__c=JSON.serialize(suggestedTopicsList);
			topicSuggestObj.Sync_Status__c=0;
			topicSuggestObj.People__c=UserContext.peopleId;
			topicSuggestObj.Date__c=date.today();
			topicSuggestObj.Content__c=contentId;
			topicSuggestObj.Content_Topics__c=JSON.serialize(contentTopicsSelectedList);
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(topicSuggestObj, new List<Schema.SObjectField>{
													Analytics_Topic_Suggestion__c.Suggested_Topics__c,
													Analytics_Topic_Suggestion__c.People__c,
													Analytics_Topic_Suggestion__c.Date__c,
													Analytics_Topic_Suggestion__c.Content__c,
													Analytics_Topic_Suggestion__c.Content_Topics__c,
													Analytics_Topic_Suggestion__c.Sync_Status__c
												});
		}
	}

	public void sendNotificationOnAuthorChange(String oldAuthorId, String newAuthorId, Simpplr_Content__c contentObj){		
		logger.logDebug('ContentDataServer()----newAuthorId----' + newAuthorId+'---oldAuthorId---'+oldAuthorId);
		Content_Audit_Trail__c contAudTrailObj = new Content_Audit_Trail__c();
		contAudTrailObj.Old_Author__c = oldAuthorId;
		contAudTrailObj.New_Author__c = newAuthorId;
		contAudTrailObj.content__C =  contentObj.id; 
		contAudTrailObj.Action_By__c = UserContext.peopleId;
		contAudTrailObj.Action_DateTime__c = system.now();
		contAudTrailObj.Action__c = 'Author Changed';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().insertAsUser(contAudTrailObj, new List<Schema.SObjectField>{
			Content_Audit_Trail__c.Old_Author__c,
			Content_Audit_Trail__c.New_Author__c,
			Content_Audit_Trail__c.content__C,
			Content_Audit_Trail__c.Action_By__c,
			Content_Audit_Trail__c.Action_DateTime__c,
			Content_Audit_Trail__c.Action__c});

		if(UserContext.peopleId.equalsIgnoreCase(newAuthorId) == false) {
			NotificationDispatcher.sendNotificationForContentAuthorChange(contentObj);
		}
	}

	public void sendNotificationForPublishedOnYourBehalf(String newAuthorId, Simpplr_Content__c contentObj){		
		logger.logDebug('ContentDataServer()----newAuthorId----' + newAuthorId);

		if(UserContext.peopleId.equalsIgnoreCase(newAuthorId) == false) {
			NotificationDispatcher.sendNotificationForPublishedOnYourBehalf(contentObj);
		}
	}

	public ContentWrapper.MustReadDetails getMustReadDetails(Must_Read_Audit__c mustReadAuditObj){
		ContentWrapper.MustReadDetails mustReadDetailObj = new ContentWrapper.MustReadDetails();
		mustReadDetailObj.createdAt = Utility.dateTimeToMomentJSDateTime(mustReadAuditObj.Mark_DateTime__c);
		if(mustReadAuditObj.Removed_DateTime__c !=null) {
			mustReadDetailObj.removedAt = Utility.dateTimeToMomentJSDateTime(mustReadAuditObj.Removed_DateTime__c);
		} else if(mustReadAuditObj.Expiry_DateTime__c < DateTime.now()) {
			mustReadDetailObj.removedAt = Utility.dateTimeToMomentJSDateTime(mustReadAuditObj.Expiry_DateTime__c);			
		}
		mustReadDetailObj.audience = mustReadAuditObj.Audience_Type__c;
		mustReadDetailObj.message = mustReadAuditObj.Message__c;
		// must read readCount should consider only active site users
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
        soqlParamMap.put('soqlParam1', mustReadAuditObj.Id);
		String query = 'SELECT Id, Content__c, Content__r.Site__r.Chatter_group_Id__c, Audience_Type__c FROM Must_Read_Audit__c WHERE Id=:soqlParam1';
		List<Must_Read_Audit__c> mustReadAuditList = (List<Must_Read_Audit__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
		Must_Read_Audit__c mustReadAudit = mustReadAuditList[0];
		PeopleDao peopleDaoObj = new PeopleDao();
		mustReadDetailObj.readCount = peopleDaoObj.getReadCount(mustReadAudit.Id, mustReadAudit.Content__c, mustReadAudit.Content__r.Site__r.Chatter_group_Id__c, mustReadAudit.Audience_Type__c);
		//Integer inactiveUserCount = getInactiveUserCount(mustReadAuditObj.Content__c, mustReadAuditObj.Id);
		//mustReadDetailObj.readCount = Integer.valueOf(mustReadAuditObj.Must_Read_Confirm_Count__c) - inactiveUserCount;
		mustReadDetailObj.unreadMustReadsCount = getUnreadMustReadCountForCurrentUser();
		mustReadDetailObj.duration = 'ninety_days'.equalsIgnoreCase(mustReadAuditObj.Duration__c) ? 'ninety_days' : 'indefinitely';

		mustReadDetailObj.createdBy = new PeopleListWrapper();
        mustReadDetailObj.createdBy.peopleId 	= mustReadAuditObj.Marked_By_People__c;
        mustReadDetailObj.createdBy.name 		= mustReadAuditObj.Marked_By_People__r.Full_Name__c;
        mustReadDetailObj.createdBy.img 		= Utility.getProfilePhotoURL(mustReadAuditObj.Marked_By_People__r.User__r.FullPhotoURL);
        mustReadDetailObj.createdBy.url 		= PageContext.getPageURL(Pages.app) + '?u=/people/' + mustReadAuditObj.Marked_By_People__c;

		return mustReadDetailObj;
	}

	private Integer getInactiveUserCount(String contentId, String mRAuditId) {
		Integer inactiveUserCount = 0;
		List<AggregateResult> aggregateResult = database.query('Select count(id) c FROM Must_Read_Confirm_History__c WHERE Content__c = :contentId AND Must_Read_Audit__c = :mRAuditId AND People__r.User__r.isActive = false');
		
		if (aggregateResult != null && aggregateResult.size() > 0) {
			inactiveUserCount = Integer.valueOf(aggregateResult[0].get('c'));
		}

		return inactiveUserCount;
	}

	private Integer getUnreadMustReadCountForCurrentUser() {
		Integer count = 0;
		String loggedInPeopleId = UserContext.peopleId;

		DateTime currentDateTime = DateTime.now();
		Set<Id> sitesIFollowIdSet = UserContext.sitesIFollowIdSet;

		Map<Id, Site_Role__c> mapofSiteIdAndSiteRole = new Map<Id, Site_Role__c>();
		mapofSiteIdAndSiteRole = UserContext.mySiteRolesMap;

		List<Simpplr_Content__c> contentList = new List<Simpplr_Content__c>();
		
		List<Simpplr_Content__c> allcontentList =  [Select Id, Site__c, (Select Id, Expiry_DateTime__c, Removed_DateTime__c, Audience_Type__c From Must_Read_Audits__r ) From Simpplr_Content__c Where  Is_Deleted__c = false AND Is_Published__c = true
				AND id IN (SELECT Content__c FROM Must_Read_Audit__c WHERE Removed_DateTime__c = null  
				AND (Expiry_DateTime__c = null OR Expiry_DateTime__c >: currentDateTime) AND  ( Audience_Type__c='everyone' OR Content__r.Site__c=:sitesIFollowIdSet))  
				AND Id not in ( select Content__c from Must_Read_Confirm_History__c  Where People__c =:loggedInPeopleId And Must_Read_Audit__r.Removed_DateTime__c = null 
				AND (Must_Read_Audit__r.Expiry_DateTime__c = null OR Must_Read_Audit__r.Expiry_DateTime__c >: currentDateTime)) WITH SECURITY_ENFORCED];

				for(Simpplr_Content__c contentObj : allcontentList) {
					if (contentObj.Must_Read_Audits__r.isEmpty() == false) {
						for(Must_Read_Audit__c mustReadObj : contentObj.Must_Read_Audits__r) {
							if ((mustReadObj.Expiry_DateTime__c == null || 
								mustReadObj.Expiry_DateTime__c>DateTime.now()) && 
								mustReadObj.Removed_DateTime__c == null) {
								if(mustReadObj.Audience_Type__c == 'site_members') {
									Site_Role__c siteRoleForContentSite = mapofSiteIdAndSiteRole.get(contentObj.Site__c);
									if(siteRoleForContentSite != null && siteRoleForContentSite.Is_Member__c == true) {
										contentList.add(contentObj);
									}
								} else {
									contentList.add(contentObj);
								}
							}
						}
					}

				}

		return contentList.size();
	}
	
	public void insertSearchTrailObjectForContent(String contentId){
		List<External_Search_Data_Trail__c> listToInsert = new List<External_Search_Data_Trail__c>();
		External_Search_Data_Trail__c searchObj = new External_Search_Data_Trail__c();
		searchObj.Content__c = contentId;
		searchObj.Type__c = 'Content';
		listToInsert.add(searchObj);

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().insertAsUser(listToInsert, new List<Schema.SObjectField>{
			External_Search_Data_Trail__c.Content__c,
			External_Search_Data_Trail__c.Type__c});

	}

	public List<TopicWrapper> convertToListOfTopicWrapper(String topicJsonStr){
		String baseUrl = PageContext.getPageURL(Pages.app);
		List<TopicWrapper> listOfTopics = new List<TopicWrapper>();
		
		List<Object> topicObjList = (List<Object>) JSON.deserializeUntyped(topicJsonStr);
		
		for(Object obj : topicObjList) {
			Map<String, Object> topicMap = (Map<String, Object>) obj;

			Map<String, Object> topicObjMap = (Map<String, Object>) topicMap.get('Topic');
			
			TopicWrapper topicWrapperObj = new TopicWrapper();

			topicWrapperObj.id = (String) topicObjMap.get('Id');
			topicWrapperObj.name = (String) topicObjMap.get('Name');
			topicWrapperObj.topicAssignmentId 	= null;
			topicWrapperObj.url 					= baseUrl + '?u=/topic/' + topicWrapperObj.Id + '/content';
			
			listOfTopics.add(topicWrapperObj);
		}

		return listOfTopics;
	}

	public SiteLiteWrapper getSiteDetails(String siteId){

		List<Simpplr_Site__c> siteList = [SELECT Id, name, Title_Content_Version__c, Landing_Page__c, Is_Content_Unfurl_Enabled__c,
											 Site_Type__c, Is_Active__c, Chatter_Group_Id__c FROM Simpplr_Site__c
											 WHERE Id =:siteId WITH SECURITY_ENFORCED];

		SiteLiteWrapper wrapperObj = new SiteLiteWrapper();

		if(siteList != null && !siteList.isEmpty()){

			Simpplr_Site__c site = siteList[0];

			wrapperObj.siteId = site.Id;
			wrapperObj.name = site.name;
			wrapperObj.img	= String.isBlank(site.Title_Content_Version__c)? null :Utility.getFileDownloadURLFor720By480(site.Title_Content_Version__c);
			wrapperObj.imgThumbnail = String.isBlank(site.Title_Content_Version__c)? null :Utility.getFileDownloadURLFor120BY90(site.Title_Content_Version__c);
			wrapperObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + site.Id + '/' + site.Landing_Page__c;
			wrapperObj.access = site.Site_Type__c;
			wrapperObj.isActive = site.Is_Active__c;
			wrapperObj.isPrivate = ServiceConstants.PRIVATE_SITE.equalsIgnoreCase(site.Site_Type__c);
			wrapperObj.isPublic = ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(site.Site_Type__c);
			wrapperObj.isMember = UserContext.sitesIFollowIdSet.contains(site.Id);
			wrapperObj.isManager = UserContext.sitesIManageIdSet.contains(site.Id);
			wrapperObj.isContentManager = UserContext.sitesIManageContentsIdSet.contains(site.Id);
			wrapperObj.isListed = !ServiceConstants.UNLISTED_SITE.equalsIgnoreCase(site.Site_Type__c);
			wrapperObj.chatterGroupId = site.Chatter_Group_Id__c;
			wrapperObj.isContentUnfurlEnabled = site.Is_Content_Unfurl_Enabled__c;
		}

		return wrapperObj;
	}
    
    public Boolean isTimeLineCreatedForContent(String contentId) {
        List<simpplr_content__feed> listOfSimpContentFeed = [SELECT id, parentId, type
                FROM simpplr_content__feed 
                WHERE type= 'LinkPost'  AND parentId=:contentId WITH SECURITY_ENFORCED limit 1];
        
        if (!listOfSimpContentFeed.isEmpty()) {
            return true;

        } else {
            return false;
        }

    } 

    public Boolean isContentPublished(String contentId) {
        List<Simpplr_Content__c> listOfSimpCont = [SELECT id, Is_Published__c 
                FROM Simpplr_Content__c 
                WHERE id=:contentId WITH SECURITY_ENFORCED]; 
        return listOfSimpCont[0].Is_Published__c;
	}
	
	@TestVisible public Boolean checkContentModerationAccess(String contentId){
    	Simpplr_Content__c simpContentObj = [select id, Status__c, Type__c, Primary_Author__c,Primary_Author__r.user__c, Site__c,Site__r.Site_Type__c, Is_Deleted__c,Is_Published__c,Is_Unpublished__c from Simpplr_Content__c where id=:contentId WITH SECURITY_ENFORCED limit 1];
    	Boolean hasContentEditAccess = false;
    	if(simpContentObj.Is_Deleted__c == true) {
    		throw new SimpplrException(ServiceConstants.ERROR_CONTENT_DELETED);
    	}
    	Boolean isCurrentUserAuthor = UserContext.peopleId.equalsIgnoreCase(simpContentObj.Primary_Author__c)?true:false;
    	
    	if ('BlogPost'.equalsIgnoreCase(simpContentObj.Type__c)){
    		if(isCurrentUserAuthor || UserContext.isUserAppModerator || UserContext.hasModifyAllDataPermission){
    			hasContentEditAccess = true;
    		}
    	} else {
    		String status = getContentStatus (simpContentObj.Status__c, simpContentObj.Is_Published__c,
    				simpContentObj.Is_Unpublished__c);
			Boolean isSiteManager = (UserContext.sitesIManageIdSet).contains(simpContentObj.Site__c);
			Boolean isContentManager = (UserContext.sitesIManageContentsIdSet).contains(simpContentObj.Site__c);
    		hasContentEditAccess = AccessManager.calculateEditAccess(isSiteManager, isContentManager, status, 
    				simpContentObj.Primary_Author__r.user__c, simpContentObj.Site__r.Site_Type__c);
    	}
    	
    	return hasContentEditAccess;
	}
	
	public String getContentStatus(String dbStatus, Boolean isPublished, Boolean isUnpublished) {
		String status;
		if (dbStatus != NULL){
		   if(ServiceConstants.CONTENT_STATUS_SUBMITTED.equalsIgnoreCase(dbStatus)){
			   status = ServiceConstants.CONTENT_STATUS_PENDING.toLowerCase();
		   
		   } else if (ServiceConstants.CONTENT_STATUS_DRAFT.equalsIgnoreCase(dbStatus)){
			   status = ServiceConstants.CONTENT_STATUS_DRAFT.toLowerCase();
		   
		   } else if (ServiceConstants.CONTENT_STATUS_REJECTED.equalsIgnoreCase(dbStatus)){ 
			   status = ServiceConstants.CONTENT_STATUS_REJECTED.toLowerCase();
		   
		   } else if (isPublished){
			   status = ServiceConstants.CONTENT_STATUS_PUBLISH.toLowerCase();
		   
		   } else if (isUnpublished){
			   status = ServiceConstants.CONTENT_STATUS_UNPUBLISH.toLowerCase();
		   
		   } else if (ServiceConstants.CONTENT_STATUS_APPROVED.equalsIgnoreCase(dbStatus)){
			   status = ServiceConstants.CONTENT_STATUS_APPROVED.toLowerCase();

		   }
	   }
	   return status;
   }

   public Boolean checkIfContentScheduled(String status, DateTime publishStartDateTime) {
		Boolean isScheduled = false;
		if(ServiceConstants.CONTENT_STATUS_UNPUBLISH.equalsIgnoreCase(status) && publishStartDateTime != null) {
			DateTime currentDateTime = DateTime.now();
			DateTime cutoffDateTime = currentDateTime.addYears(5);
			isScheduled = publishStartDateTime > currentDateTime && publishStartDateTime < cutoffDateTime;
		}
		return isScheduled;
	}

   public PeopleListWrapper getPeopleListWrapper(String peopleId){

		List<People__c> peopleList = [SELECT Id, User__c, user__r.Id, First_Name__c, Community_Nickname__c, Last_Name__c,
											Full_Name__c, user__r.SmallPhotoURL, user__r.FullPhotoURL, user__r.MediumPhotoURL, Department__c, About__c, Title__c,
											City__c, State__c, Country__c, Street__c, Email__c, Phone__c, mobile_phone__c, extension__c, Birth_Date__c,
											Joining_Date__c, User__r.isactive 
											FROM People__c WHERE Id = :peopleId WITH SECURITY_ENFORCED];

		People__c peopleRec = peopleList[0];

		PeopleListWrapper wrapperObj = new PeopleListWrapper();
		wrapperObj.Id = peopleRec.Id;
		wrapperObj.sfUserId = peopleRec.User__r.Id;
		wrapperObj.peopleId = peopleRec.Id;
		wrapperObj.name = peopleRec.Full_Name__c;
		wrapperObj.img = Utility.getProfilePhotoURL(peopleRec.User__r.FullPhotoURL);
		wrapperObj.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleRec.Id;
		wrapperObj.title = SimpplrContext.isPPTitleDisplay ? peopleRec.title__c : null;
		wrapperObj.location = Utility.buildLocation(peopleRec.city__c, peopleRec.state__c, peopleRec.country__c);
		wrapperObj.isFollowing = UserContext.usersIFollowIdSet.contains(wrapperObj.sfUserId);
		wrapperObj.department = SimpplrContext.isPPDepartmentDisplay ? peopleRec.Department__c : null;
		wrapperObj.canFollow	= UserContext.peopleId.equalsIgnoreCase(peopleRec.Id) ?  false : peopleRec.User__r.isActive;
		wrapperObj.mediumPhotoUrl = Utility.getUserProfileImgUrl(peopleRec.User__r.MediumPhotoURL, peopleRec.User__r.FullPhotoURL);
		wrapperObj.street = peopleRec.Street__c;
		wrapperObj.city = peopleRec.City__c;
		wrapperObj.state = peopleRec.State__c;
		wrapperObj.country = peopleRec.Country__c;
		wrapperObj.email = peopleRec.Email__c;
		wrapperObj.mobile = peopleRec.Mobile_Phone__c;
		wrapperObj.phone = peopleRec.Phone__c;
		wrapperObj.phoneExtension = peopleRec.Extension__c;
		wrapperObj.firstName = peopleRec.First_Name__c;
		wrapperObj.lastName = peopleRec.Last_Name__c;
		wrapperObj.isActive = peopleRec.User__r.IsActive;

		return wrapperObj;
	}
    
}