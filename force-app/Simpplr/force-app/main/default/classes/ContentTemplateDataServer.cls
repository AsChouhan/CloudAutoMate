/**
* @Class [ContentTemplateDataServer] 
* @Description:  [perform various functions on content templates - create,edit,delete,get,save]
*
*/

public with sharing class ContentTemplateDataServer extends ContentDataServer {
    /**
    * @description This constant is used to fetch the success create message from labelMap
    */
	public transient final String STR_SUCCESS_CREATE_TEMPLATE_FLASH { get { return labelMap.get('page_template.create_template.success_message');}} // NOPMD - correct naming convension, suppressed codacy error
    /**
    * @description This constant is used to fetch the success update message from labelMap
    */
    public transient final String STR_SUCCESS_UPDATE_TEMPLATE_FLASH { get { return labelMap.get('page_template.update_template.success_message');}} // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_VALUE_GET = 'get';
	private final String REQUEST_PARAM_DATA = 'data';
    private final String ACTION_VALUE_SEARCH = 'search';
    private final String ACTION_VALUE_SAVE_PAGE_TEMPLATE = 'savePageTemplate';
    private final String ACTION_VALUE_UPDATE_PAGE_TEMPLATE = 'updatePageTemplate';

    /**
     * @description handleRequest
    */
    public override void handleRequest(){
        try{
            logger.logDebug('ContentTemplateDataServer.handleRequest()----Start----');
            String action = readParam(REQUEST_PARAM_ACTION);
            String requestData = readParam(REQUEST_PARAM_DATA);
            
            if(String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
            }

            if (ACTION_VALUE_SEARCH.equalsIgnoreCase(action)) {
                response = search(requestData);

            } else if (ACTION_VALUE_SAVE_PAGE_TEMPLATE.equalsIgnoreCase(action)) {
                if(String.isNotBlank(requestData)) {
                    response = savePageTemplate(requestData,ACTION_VALUE_SAVE_PAGE_TEMPLATE);

                } else {
                    throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());

                }
            }else if(ACTION_VALUE_UPDATE_PAGE_TEMPLATE.equalsIgnoreCase(action)) {
                if(String.isNotBlank(requestData)) {
                    response = savePageTemplate(requestData,ACTION_VALUE_UPDATE_PAGE_TEMPLATE);
                }else {
                    throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
                }
            } else if (ACTION_VALUE_GET.equalsIgnoreCase(action)) {
                response = getTemplate(readParam('contentTemplateId'));

            } else {
                throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            }

        }catch (Exception ex) {
            logger.logError('ContentTemplateDataServer.handleRequest()---Exception occured----', ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, 
					MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
    }

    /**
     * @description save page template
     * @return ResponseWrapper
    */
    private ResponseWrapper savePageTemplate(String data, String action) {
		logger.logDebug('ContentTemplateDataServer.processPageTemplateData()----action----' + action);

        Savepoint sp = Database.setSavepoint();
        ResponseWrapper responseWrapperObj = new ResponseWrapper();
        try{
            ContentTemplateWrapper wrapperObj = ContentTemplateWrapper.parse(data);
            if ((userContext.hasManageUnlistedSitePermission && SiteContext.currentSiteType.equalsIgnoreCase('Unlisted')) || UserContext.isUserSiteOwner || (AccessManager.isUserAppModerator(UserContext.id) && !SiteContext.currentSiteType.equalsIgnoreCase('Unlisted')) 
                || AccessManager.hasUserManageSiteAccess(SiteContext.siteId) || UserContext.sitesIManageContentsIdSet.contains(SiteContext.siteId)) {
                
                wrapperObj.id = wrapperObj.id == null ? readParam('contentTemplateId') : wrapperObj.id;
                wrapperObj.siteId = wrapperObj.siteId == null ? SiteContext.siteId : wrapperObj.siteId;
                Boolean isEdit = String.isNotBlank(wrapperObj.id);
                Boolean isSiteAvailableInSimpplr = checkSiteAvailabilityInSimpplr(wrapperObj.siteId);
                
                if (!isSiteAvailableInSimpplr) {
                    if (isEdit) {
                        responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, ServiceConstants.SF_EXCEPTION, null);
                        return responseWrapperObj;
                    } 
                }
                
                Map<String, String> mapOfNewTopics = createNewTopics(wrapperObj.listOfTopics, wrapperObj.listOfTemplateTopicIds);
                Content_Template__c contentTemplateObj = savePageTemplateObjectToSF(isEdit, wrapperObj, mapOfNewTopics);

                saveContentTemplateInlineImagesToSF(isEdit, contentTemplateObj.id, wrapperObj);
                saveContentTemplateCoverImagesToSF(isEdit, contentTemplateObj.id, wrapperObj);
                saveContentTemplateVideosToSF(isEdit, contentTemplateObj.id, wrapperObj);
                    
                saveTopicAssignmentsToSF(isEdit, contentTemplateObj.id, wrapperObj.listOfTopics, 
                        wrapperObj.listOfTemplateTopicIds, mapOfNewTopics);
                
                if(!isEdit){
                    responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, STR_SUCCESS_CREATE_TEMPLATE_FLASH , contentTemplateObj);
                }else {
                    responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, STR_SUCCESS_UPDATE_TEMPLATE_FLASH , contentTemplateObj);
                }
            }else {
                throw new SimpplrException(ServiceConstants.ERROR_403);
            }
        }catch(Exception ex){
            logger.logError('ContentTemplateDataServer.saveTemplate() --- Exception occured ---', ex);
            Database.rollback(sp);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
       	return responseWrapperObj;
        
    }
    
    /**
     * @description get template
     * @return ResponseWrapper
    */
    private ResponseWrapper getTemplate(String templateId) {
        logger.logDebug('ContentTemplateDataServer.getTemplate()---data---' + templateId);
        ResponseWrapper resultWrapper = New ResponseWrapper();

        try{
            ContentTemplateDao conTempDao = new ContentTemplateDao();
            List<Content_Template__c> contentTemplateObj = conTempDao.getContentTemplateListFromIdSet(new Set<String>{templateId}, 'fullWrapper');

            if (contentTemplateObj.size() == 0) {
	    		throw new SimpplrException(ServiceConstants.ERROR_404);

            } else if (contentTemplateObj[0].Is_Deleted__c || 
                    contentTemplateObj[0].Site__r.Is_Active__c == false) {
                throw new SimpplrException(ServiceConstants.ERROR_404);

            } else {
                List<ContentTemplateWrapper> contentTemplateWrapperList = convertToContentTemplateWrapper(new List<Content_Template__c>{contentTemplateObj[0]},'fullWrapper');
                resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, contentTemplateWrapperList);
            }

        } catch (exception e) {
    		logger.logError('Exception Details', e);
        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, e.getMessage(), null);

        }
        return resultWrapper;
    }

    /**
     * @description check if site is available
     * @return boolean
    */
    private Boolean checkSiteAvailabilityInSimpplr(String siteId) {
    	List<Simpplr_Site__c> siteList = [SELECT Id, Show_In_Simpplr__c 
				FROM Simpplr_Site__c WHERE Id = :siteId WITH SECURITY_ENFORCED];
        return(!siteList.isEmpty() && siteList[0].Show_In_Simpplr__c == true);
    }

    /**
     * @description make sf object record for page template
     * @return Content_Template__c
    */
    private Content_Template__c savePageTemplateObjectToSF(Boolean isEdit, ContentTemplateWrapper contentTemplateWrapperObj, Map<String, String> mapOfNewTopics) {
        Content_Template__c contentTempObj;
        
        if (!isEdit) {
			// To Stop DOS attack limiting pagecreation to 5 request per second SV2-34176
			Datetime lastSecond = System.now().addSeconds(-1);
			List<Content_Template__c> listOfSimpTemp = [SELECT Id FROM Content_Template__c		
					WHERE CreatedBy.id=:UserInfo.getUserId() AND CreatedDate=:lastSecond WITH SECURITY_ENFORCED
					LIMIT 10];

			if (!listOfSimpTemp.isEmpty() && listOfSimpTemp.size() > 5) {
				throw new SimpplrException(ServiceConstants.ERROR_429);
			}

	        contentTempObj = new Content_Template__c();
	        contentTempObj.Type__c = ServiceConstants.TYPE_PAGE;
			contentTempObj.site__c = contentTemplateWrapperObj.siteId;
        }else{
            contentTempObj = [SELECT ownerId, Primary_Author__c,Cover_Image_Layout__c, Pages_Category__c, Title_Image_Caption__c, Text_Main_Continued__c,
                            Text_Main__c, Text_Intro__c, Title__c, Site__c, Type__c, Sub_Type__c, Language__c,
                            Is_Deleted__c, Is_Enabled__c, Is_System_Template__c, Name__c FROM Content_Template__c 
            	            WHERE id =: contentTemplateWrapperObj.id AND Type__c =: ServiceConstants.TYPE_PAGE AND Site__c=: contentTemplateWrapperObj.siteId WITH SECURITY_ENFORCED];   
        }
        contentTempObj.Name__c = contentTemplateWrapperObj.name;
        contentTempObj.Title__c = contentTemplateWrapperObj.title;
		contentTempObj.Sub_Type__c = contentTemplateWrapperObj.contentTemplateSubType;

        List<String> contentBodyParts = getContentBodyParts(contentTemplateWrapperObj.body, mapOfNewTopics);

        contentTempObj.Text_Intro__c = contentBodyParts[0];
        contentTempObj.Text_Main__c	= contentBodyParts[1];
        contentTempObj.Text_Main_Continued__c = contentBodyParts[2];
        contentTempObj.is_Deleted__c =false;
        contentTempObj.Is_Enabled__c = true;
        contentTempObj.Is_System_Template__c = false;
        contentTempObj.Title_Image_Caption__c = contentTemplateWrapperObj.imgCaption;

		if (contentTemplateWrapperObj.category != null) {
			if (String.isNotBlank(contentTemplateWrapperObj.category.Id)) {
				contentTempObj.Pages_Category__c = contentTemplateWrapperObj.category.Id;
			} else {
                PageDao pageDaoObj = new PageDao();
				contentTempObj.Pages_Category__c = pageDaoObj.createPagesCategory(contentTemplateWrapperObj.category.Name, contentTemplateWrapperObj.siteId).Id;
			}
        }
       		
        contentTempObj.Cover_Image_Layout__c = contentTemplateWrapperObj.coverImgLayout;
		contentTempObj.Language__c = contentTemplateWrapperObj.language;
		
        if (!isEdit) {
            contentTempObj.ownerId = UserContext.Id;
        	contentTempObj.Primary_Author__c = UserContext.getCurrentUserInfo.Id;
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPSFDCAccessControlResults.InsertResults result = SIMPESAPI.accessController().insertAsUser(
                    new List<Content_Template__c>{contentTempObj},
					new List<Schema.SObjectField>{
					Content_Template__c.ownerId,
					Content_Template__c.Primary_Author__c,
					Content_Template__c.Cover_Image_Layout__c, 
					Content_Template__c.Pages_Category__c,  
					Content_Template__c.Title_Image_Caption__c, 
					Content_Template__c.Text_Main_Continued__c,
					Content_Template__c.Text_Main__c,
					Content_Template__c.Text_Intro__c,
					Content_Template__c.Title__c,
					Content_Template__c.Site__c,
					Content_Template__c.Type__c,
					Content_Template__c.Sub_Type__c,
					Content_Template__c.Language__c,
                    Content_Template__c.Is_Deleted__c,
					Content_Template__c.Is_Enabled__c,
					Content_Template__c.Is_System_Template__c,
					Content_Template__c.Name__c
			    });
			List<Content_Template__c> listOfContentTemplateObj = new List<Content_Template__c>();
			listOfContentTemplateObj =(List<Content_Template__c>) result.getInsertedObjects();
			contentTempObj = listOfContentTemplateObj[0];
        }else {		
            if (contentTemplateWrapperObj.authoredBy !=null && 
                String.isNotBlank(contentTemplateWrapperObj.authoredBy.peopleId)) {
                    contentTempObj.Primary_Author__c = contentTemplateWrapperObj.authoredBy.peopleId;
            }
            
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(contentTempObj, new List<Schema.SObjectField>{
				Content_Template__c.Primary_Author__c,
                Content_Template__c.Cover_Image_Layout__c,
                Content_Template__c.Language__c, 
                Content_Template__c.Pages_Category__c, 
                Content_Template__c.Title_Image_Caption__c, 
                Content_Template__c.Is_System_Template__c, 
                Content_Template__c.Is_Enabled__c, 
                Content_Template__c.is_Deleted__c, 
                Content_Template__c.Text_Main_Continued__c, 
                Content_Template__c.Text_Main__c, 
                Content_Template__c.Text_Intro__c, 
                Content_Template__c.Sub_Type__c, 
                Content_Template__c.Title__c, 
                Content_Template__c.Name__c
			});
         	logger.logDebug('ContentTemplateDataServer.edit--contentTempObj--'+contentTempObj);
           			
        } 

        return contentTempObj;
    }
    /**
     * 
     * @Description:  [This method search templates for a site]
     * @Parameters: 
     *      requestData -> request data
     * @Returns:  [Returns the list of Content Templates fulfilling request criteria]
    */
    @TestVisible
    private ResponseWrapper search(String requestData) {
        logger.logDebug('ContentTemplateDataServer.search()---requestData---' + requestData);
        ResponseWrapper resultWrapper = new ResponseWrapper();

        try{
            Criteria.ContentTemplateSearchWrapper requestObj = (Criteria.ContentTemplateSearchWrapper)JSON.deserialize(requestData, Criteria.ContentTemplateSearchWrapper.class);
            String siteType = getSiteTypeFromSiteId(requestObj.siteId);

            if(!SimpplrContext.isPageTemplateEnabled 
                || !(UserContext.sitesIManageIdSet.contains(requestObj.siteId) 
                        || UserContext.sitesIManageContentsIdSet.contains(requestObj.siteId)
                        || (siteType.equalsIgnoreCase('Public') && UserContext.isUserAppModerator) 
                        || (siteType.equalsIgnoreCase('Unlisted') && UserContext.hasManageUnlistedSitePermission)
                    )
                ) {
                throw new SimpplrException(ServiceConstants.ERROR_403);
            }
            
            List<Content_Template__c> contentTemplateList = new List<Content_Template__c>();
            ContentTemplateDao conTempDao = new ContentTemplateDao();
            List<ContentTemplateWrapper> contentTemplateWrapperList = null;
            String orderBy = '';
            String order = '';
            Integer size = requestObj.size != null ? requestObj.size : SimpplrContext.simpplrDefaultPageSize;
            Integer nextPageToken = String.isNotBlank(requestObj.nextPageToken) ? Integer.valueOf(requestObj.nextPageToken) : 0;
            String searchText = String.isNotBlank(requestObj.term) ? requestObj.term : '';
            String siteId = String.isNotBlank(requestObj.siteId) ? requestObj.siteId : '';
            String type = String.isNotBlank(requestObj.type) ? requestObj.type : '';
            String sortByfield = String.isNotBlank(requestObj.sortBy) ? requestObj.sortBy : '';

            if (String.isNotblank(sortByfield) ){
                if(sortByfield.equalsIgnoreCase('modifiedNewest') || sortByfield.equalsIgnoreCase('modifiedOldest')){
                    orderBy = 'LastModifiedDate';
                    order = sortByfield.equalsIgnoreCase('modifiedNewest')? 'DESC' : 'ASC';
            
                }else if(sortByfield.equalsIgnoreCase('createdNewest') || sortByfield.equalsIgnoreCase('createdOldest')){
                    orderBy = 'CreatedDate';
                    order = sortByfield.equalsIgnoreCase('createdNewest')? 'DESC' : 'ASC';
                }
            } else {
                orderBy = 'CreatedDate';
                order = 'DESC';
            }

            if(SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(searchText)) {
                logger.logDebug('ContentTemplateDataServer.search()---in External search---' + requestData);
                Criteria.ExternalSearchReq contentTemplateCriteriaObj = (Criteria.ExternalSearchReq)JSON.deserialize(requestData, Criteria.ExternalSearchReq.class);
                String searchForType = 'Content_Template';
                ExternalSearchService externalSearchServiceObj = new ExternalSearchService();
                Set<String> contentTemplateIdSet = externalSearchServiceObj.searchContentTemplates(contentTemplateCriteriaObj, searchForType);
                contentTemplateList = conTempDao.getContentTemplateListFromIdSet(contentTemplateIdSet, '');
            }else {
                contentTemplateList = conTempDao.getContentTemplateListFromCriteria(siteId, type, searchText, orderBy, order, size, nextPageToken);
            }

            contentTemplateWrapperList = convertToContentTemplateWrapper(contentTemplateList,'');
            nextPageToken = contentTemplateWrapperList.size() < size ? null : nextPageToken + size;

            Map<String,Object> result = new Map<String,Object>();
            result.put('listOfItems',contentTemplateWrapperList);
            result.put('nextPageToken',nextPageToken);

            resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
        }catch(Exception ex) {
            logger.logError('ContentTemplateDataServer.search()-----could not retrieve data----',ex);
            resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return resultWrapper;
    }
    /**
     * 
     * @Description:  [This method convert template record to template wrapper]
     * @Parameters:
     *      parameter_name -- data -> List of template records
     *      
     * @Returns:  [Returns the list of Content Templates wrapper]
    */
    public List<ContentTemplateWrapper> convertToContentTemplateWrapper(List<Content_Template__c> contentTemplateList, String wrapperType) {
        List<ContentTemplateWrapper> wrapperObjList = new List<ContentTemplateWrapper>();

        for (Content_Template__c templateRecord : contentTemplateList) {
            ContentTemplateWrapper wrapperObj = new ContentTemplateWrapper();
            wrapperObj.id = templateRecord.id;
            wrapperObj.templateId = templateRecord.id;
            wrapperObj.isDeleted = templateRecord.Is_Deleted__c;
            wrapperObj.name = templateRecord.Name__c;
            wrapperObj.type = templateRecord.Type__c;
            wrapperObj.siteId = templateRecord.Site__c;
            wrapperObj.contentTemplateSubType = templateRecord.Sub_Type__c;
            wrapperObj.isEnabled = templateRecord.Is_Enabled__c;
            wrapperObj.isSystemTemplate = templateRecord.Is_System_Template__c;
            wrapperObj.language = templateRecord.Language__c;
            wrapperObj.title = templateRecord.Title__c;
            wrapperObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+templateRecord.site__c+'/contentTemplate/'+templateRecord.Type__c+'/'+templateRecord.Id;
            wrapperObj.editUrl = wrapperObj.url + '/edit';
            if (wrapperType.equalsIgnoreCase('fullWrapper')) {
                if('Page'.equalsIgnoreCase(templateRecord.Type__c) && String.isNotBlank(templateRecord.Pages_Category__c)) {
                    wrapperObj.category = new CategoryWrapper();
                    wrapperObj.category.id = templateRecord.Pages_Category__c;
                    wrapperObj.category.categoryId = templateRecord.Pages_Category__c;
                    wrapperObj.category.Name = templateRecord.Pages_Category__r.Name__c;
                    wrapperObj.category.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + templateRecord.Site__c + '/contentTemplate&pageCategoryId=' + templateRecord.Pages_Category__c;
                }
                wrapperObj.body = (String.isNotBlank(templateRecord.Text_Intro__c) ? 
                        templateRecord.Text_Intro__c : '') +
				        (String.isNotBlank(templateRecord.Text_Main__c) ? templateRecord.Text_Main__c : '') +
				        (String.isNotBlank(templateRecord.Text_Main_Continued__c) ? 
				        templateRecord.Text_Main_Continued__c : '');
                wrapperObj.listOfTopics = convertToContentTemplateTopicWrapper(templateRecord.Id, 
                        PageContext.getPageURL(Pages.app));
                List<File__c> fileList = getFilesByContentTemplateId(templateRecord.Id);
                for (File__c fileObj : fileList) {
                    if (ServiceConstants.TITLE_IMAGE_TYPE_THUMBNAIL.equalsIgnoreCase(fileObj.Title_Image_Type__c) && 
					        fileObj.Is_Title_Image__c) {
				        wrapperObj.img = Utility.getFileDownloadURL(fileObj.Content_Version__c);
    			        wrapperObj.imgFile = convertFileToFileContentTemplateWrapper(fileObj);
    		
    		        } else if (ServiceConstants.TITLE_IMAGE_TYPE_WIDESCREEN.equalsIgnoreCase(fileObj.Title_Image_Type__c) && 
					        fileObj.Is_Title_Image__c) {
    			        wrapperObj.imgLandscape = Utility.getFileDownloadURL(fileObj.Content_Version__c);
    			        wrapperObj.imgLandscapeFile = convertFileToFileContentTemplateWrapper(fileObj);
    			
    		        } else if (ServiceConstants.TITLE_IMAGE_TYPE_ORIGINAL.equalsIgnoreCase(fileObj.Title_Image_Type__c) && 
					        fileObj.Is_Title_Image__c) {
    			        wrapperObj.imgOriginal = Utility.getFileDownloadURL(fileObj.Content_Version__c);
    			        wrapperObj.imgOriginalFile = convertFileToFileContentTemplateWrapper(fileObj);
    		
    		        } else if (ServiceConstants.FILE_LOCATION_INLINE.equalsIgnoreCase(fileObj.Location__c) && ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(fileObj.Repository__c)) {
                        wrapperObj.listOfInlineVideos = new List<FileContentWrapper>();
                        wrapperObj.listOfInlineVideos.add(convertFileToFileContentTemplateWrapper(fileObj));
                    
                    }else if (ServiceConstants.FILE_LOCATION_INLINE.equalsIgnoreCase(fileObj.Location__c)) {
                        wrapperObj.listOfInlineImages = new List<FileContentWrapper>();
                        wrapperObj.listOfInlineImages.add(convertFileToFileContentTemplateWrapper(fileObj));
                    
                    }
                }
            }
                
            if (String.isNotBlank(templateRecord.Site__c)) {
                wrapperObj.site = new SiteLiteWrapper();
                wrapperObj.site.siteId = templateRecord.Site__c;
                wrapperObj.site.chatterGroupId = templateRecord.Site__r.Chatter_Group_Id__c;
                wrapperObj.site.title = templateRecord.site__r.Name;
                wrapperObj.site.isMember = UserContext.sitesIFollowIdSet.contains(wrapperObj.site.siteId);
                wrapperObj.site.name = templateRecord.site__r.Name;
                wrapperObj.site.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + templateRecord.site__c + '/' + templateRecord.site__r.Landing_Page__c;
                wrapperObj.site.imgContentDocumentId = templateRecord.Site__r.Title_Content_Document__c;
                wrapperObj.site.img = String.isBlank(templateRecord.site__r.Title_Content_Version__c) ? null : Utility.getFileDownloadURLFor720By480(templateRecord.site__r.Title_Content_Version__c);
                wrapperObj.site.imgThumbnail = String.isBlank(templateRecord.site__r.Title_Content_Version__c) ? null : Utility.getFileDownloadURLFor120BY90(templateRecord.site__r.Title_Content_Version__c);
                wrapperObj.site.isActive = templateRecord.site__r.Is_Active__c;
                wrapperObj.site.access = templateRecord.site__r.site_type__c;
                wrapperObj.site.isListed  = !'Unlisted'.equalsIgnoreCase(templateRecord.site__r.Site_Type__c);
                wrapperObj.site.isManager = UserContext.sitesIManageIdSet.contains(wrapperObj.site.siteId);
                wrapperObj.site.isContentManager = UserContext.sitesIManageContentsIdSet.contains(wrapperObj.site.siteId);
                wrapperObj.site.isPrivate = 'Private'.equalsIgnoreCase(templateRecord.site__r.Site_Type__c);
                wrapperObj.site.isPublic = 'Public'.equalsIgnoreCase(templateRecord.site__r.Site_Type__c);
            }
            wrapperObj.createdAt = templateRecord.createdDate == null ? '':Utility.dateToDisplayString(templateRecord.createdDate,'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            wrapperObj.modifiedAt = templateRecord.LastModifiedDate == null ? '':Utility.dateToDisplayString(templateRecord.LastModifiedDate,'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            if (wrapperObj.createdAt.equalsIgnoreCase(wrapperObj.modifiedAt)) {
                wrapperObj.modifiedAt = '';

            }
            if (AccessManager.calculateContentTemplateManageAccess(wrapperObj.site.isManager, wrapperObj.site.isContentManager, wrapperObj.site.access)) {
                wrapperObj.canEdit = true;
                wrapperObj.canDelete = true;
                wrapperObj.canDuplicate = true;
                wrapperObj.canMove = true;
                wrapperObj.canChangeStatus = true;
                if (wrapperObj.isSystemTemplate == true) {
                    wrapperObj.canEdit = false;
                    wrapperObj.canDelete = false;
                    wrapperObj.canMove = false;
                }

            } else {
                wrapperObj.canEdit = false;
                wrapperObj.canDelete = false;
                wrapperObj.canDuplicate = false;
                wrapperObj.canMove = false;
                wrapperObj.canChangeStatus = false;
            }
            //Author detail
            if (templateRecord.Primary_Author__c != null) {
                wrapperObj.authoredBy = new PeopleListWrapper();
                wrapperObj.authoredBy.id = templateRecord.Primary_Author__c;
                wrapperObj.authoredBy.peopleId = templateRecord.Primary_Author__c;
                wrapperObj.authoredBy.sfUserId = templateRecord.Primary_Author__r.user__r.Id;
                wrapperObj.authoredBy.nickname = templateRecord.Primary_Author__r.Community_Nickname__c;//TBD
                wrapperObj.authoredBy.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + templateRecord.Primary_Author__c;
                String nameForAuthor = Utility.buildName(templateRecord.Primary_Author__r.First_Name__c,templateRecord.Primary_Author__r.Last_Name__c);
                if(String.isNotBlank(nameForAuthor)){
                    wrapperObj.authoredBy.name = nameForAuthor;
                }
                wrapperObj.authoredBy.img = templateRecord.Primary_Author__r.user__r.FullPhotoURL.endsWith('005/F') ? null : templateRecord.Primary_Author__r.user__r.FullPhotoURL;
                wrapperObj.authoredBy.department = templateRecord.Primary_Author__r.Department__c;
                wrapperObj.authoredBy.title = templateRecord.Primary_Author__r.Title__c;
                wrapperObj.authoredBy.location = Utility.buildLocation(templateRecord.Primary_Author__r.City__c, templateRecord.Primary_Author__r.State__c, templateRecord.Primary_Author__r.Country__c);
                wrapperObj.authoredBy.email = templateRecord.Primary_Author__r.Email__c;
                wrapperObj.authoredBy.phone = templateRecord.Primary_Author__r.Phone__c;
                wrapperObj.authoredBy.mobile = templateRecord.Primary_Author__r.mobile_phone__c;
                wrapperObj.authoredBy.phoneExtension = templateRecord.Primary_Author__r.extension__c;
                wrapperObj.authoredBy.about = templateRecord.Primary_Author__r.About__c;//TBD
                wrapperObj.authoredBy.isActive = templateRecord.Primary_Author__r.User__r.isactive;
                wrapperObj.authoredBy.birthday = SimpplrContext.isPPBirthDateDisplay ? Utility.dateToDisplayString(templateRecord.Primary_Author__r.Birth_Date__c,'MM-dd') : null;
                if(SimpplrContext.isPPJoiningDateDisplay && templateRecord.Primary_Author__r.Joining_Date__c != null && templateRecord.Primary_Author__r.Joining_Date__c < Date.today().addDays(-3)) {
                    wrapperObj.authoredBy.hireDate = Utility.dateToDisplayString(templateRecord.Primary_Author__r.Joining_Date__c,'yyyy-MM-dd');
                }
            
                if (UserContext.usersIFollowIdSet.contains(templateRecord.Primary_Author__r.User__c)) {
                        wrapperObj.authoredBy.isFollowing = true;
                        
                } else {
                        wrapperObj.authoredBy.isFollowing = false;
                }
                if (UserContext.getCurrentUserInfo.Id == templateRecord.Primary_Author__c) {
                    wrapperObj.authoredBy.canFollow = false;
                    
                } else {
                    wrapperObj.authoredBy.canFollow = templateRecord.Primary_Author__r.User__r.isactive;
                    
                }
            } 
            wrapperObjList.add(wrapperObj);
        }
        return wrapperObjList;
    }
    /**
     * 
     * @Description:  [This method search for site type from site id]
     * @Parameters: 
     *      siteId -> id of site for which it fetch site type
     * @Returns:  [Returns the site type corresponding to site id]
    */
    public String getSiteTypeFromSiteId(String siteId) {
        String siteType = '';
        List<Simpplr_Site__c> siteList = [select id, name, Site_Type__c from Simpplr_Site__c where id =: siteId WITH SECURITY_ENFORCED];
        if (!siteList.isEmpty()) {
            siteType = siteList[0].Site_Type__c;
        }
        return siteType;
    }

    /**
     * @description save images to sf
     * @param isEdit
     * @param templateId
     * @param wrapperObj
    */
    public void saveContentTemplateInlineImagesToSF(Boolean isEdit, Id templateId, ContentTemplateWrapper wrapperObj) {
		String contentImagesFolderId; 
		if(String.isNotBlank(wrapperObj.siteId)) {
			SiteDao siteDaoObj = new SiteDao();
	        Map<String, Folder__c> mapOfSystemFolders4Site = siteDaoObj.getMapOfSystemFoldersForSite(wrapperObj.siteId);
	        if(!mapOfSystemFolders4Site.isEmpty()) {
				contentImagesFolderId = mapOfSystemFolders4Site.get('Content Files.Images').Id;
            }
		}
        
		List<File__c> listOfContentFiles = new List<File__c>(); 
        List<File__c> listOfNewFiles = new List<File__c>();
        List<File__c> listOfDeletedFiles = new List<File__c>();
        Map<Id, File__c> mapOfExistingInlineImages = new Map<Id, File__c>();
		
        if(isEdit) {
            FileDao fileDaoObj = new FileDao();
            List<File__c> fileList = fileDaoObj.getContentTemplateFiles(templateId);
            for(File__c fileObj : fileList) {
                if(ServiceConstants.FILE_LOCATION_INLINE.equalsIgnoreCase(fileObj.Location__c)) {
                    mapOfExistingInlineImages.put(fileObj.id, fileObj);
                    
                } else if(ServiceConstants.File_LOCATION_MEDIA.equalsIgnoreCase(fileObj.Location__c) && 'image'.equalsIgnoreCase(fileObj.MIME_Type__c)) {
                    listOfContentFiles.add(fileObj);
                
                }
            }
        } 
        ContentTemplateWrapper.TemplateFilesWrapper templateFilesWrapperObj = new ContentTemplateWrapper.TemplateFilesWrapper();
        
        if(wrapperObj.listOfInlineImages != null && !wrapperObj.listOfInlineImages.isEmpty()) {
	        for(FileContentWrapper fileWrapperObj : wrapperObj.listOfInlineImages) {
		        	if(mapOfExistingInlineImages.containsKey(fileWrapperObj.fileId)) {
		        		listOfContentFiles.add(mapOfExistingInlineImages.get(fileWrapperObj.fileId));
		        		mapOfExistingInlineImages.remove(fileWrapperObj.fileId);
		        	} else {
                        templateFilesWrapperObj.folderId = contentImagesFolderId;
                        templateFilesWrapperObj.location = ServiceConstants.FILE_LOCATION_INLINE; 
                        templateFilesWrapperObj.titleImageType = null;
                        templateFilesWrapperObj.fileWrapperObj = fileWrapperObj;
		        		File__c fileObj = convertFileTemplateWrapperToFileObject(wrapperObj.siteId,templateId,templateFilesWrapperObj);
	        			listOfNewFiles.add(fileObj);
		        	}
	        }
		}
		listOfDeletedFiles.addAll(mapOfExistingInlineImages.values());
		
        if(listOfNewFiles.isEmpty() == false) {
			listOfNewFiles = insertTemplateFiles(listOfNewFiles);
        }
        	
        updateDeletedTemplateFiles(listOfDeletedFiles);
          
        listOfContentFiles.addAll(listOfNewFiles);
        SimpplrContext.skipContentDocTrigger = true;
		
		// Create CDL for all files siteId and siteType
        createCDLForTemplateFiles(listOfContentFiles,wrapperObj.siteId);
		
		SimpplrContext.skipContentDocTrigger = false;
	}

    /**
     * @description save cover image
     * @param isEdit
     * @param templateId
     * @param wrapperObj
    */
    public void saveContentTemplateCoverImagesToSF(Boolean isEdit, Id templateId, ContentTemplateWrapper wrapperObj) {
		String contentImagesFolderId; 
		if(String.isNotBlank(wrapperObj.siteId)) {
			SiteDao siteDaoObj = new SiteDao();
	        Map<String, Folder__c> mapOfSystemFolders4Site = siteDaoObj.getMapOfSystemFoldersForSite(wrapperObj.siteId);
	        if(!mapOfSystemFolders4Site.isEmpty()) {
				contentImagesFolderId = mapOfSystemFolders4Site.get('Content Files.Images').Id;
            }
		}
        
		List<File__c> listOfContentFiles = new List<File__c>(); 
        List<File__c> listOfNewFiles = new List<File__c>();
        List<File__c> listOfDeletedFiles = new List<File__c>();
        Map<Id, File__c> mapOfExistingTitleImages = new Map<Id, File__c>();
        
        if(isEdit) {
            FileDao fileDaoObj = new FileDao();
            List<File__c> fileList = fileDaoObj.getContentTemplateFiles(templateId);
            for(File__c fileObj : fileList) {
                if(ServiceConstants.File_LOCATION_COVER.equalsIgnoreCase(fileObj.Location__c)) {
                    mapOfExistingTitleImages.put(fileObj.id, fileObj);
                
                } else if(ServiceConstants.File_LOCATION_MEDIA.equalsIgnoreCase(fileObj.Location__c) && 'image'.equalsIgnoreCase(fileObj.MIME_Type__c)) {
                    listOfContentFiles.add(fileObj);
                
                }
            }
        } 
        ContentTemplateWrapper.TemplateFilesWrapper templateFilesWrapperObj = new ContentTemplateWrapper.TemplateFilesWrapper();
        if(wrapperObj.imgFile == null) {
        		listOfDeletedFiles.addAll(mapOfExistingTitleImages.values());
        
        } else if(mapOfExistingTitleImages.containsKey(wrapperObj.imgFile.fileId) == false) {
	        	listOfDeletedFiles.addAll(mapOfExistingTitleImages.values());
	        	
                templateFilesWrapperObj.folderId = contentImagesFolderId;
                templateFilesWrapperObj.location = ServiceConstants.FILE_LOCATION_COVER; 
                templateFilesWrapperObj.titleImageType = ServiceConstants.TITLE_IMAGE_TYPE_THUMBNAIL;
                templateFilesWrapperObj.fileWrapperObj = wrapperObj.imgFile;
	        	listOfNewFiles.add(convertFileTemplateWrapperToFileObject(wrapperObj.siteId,templateId,templateFilesWrapperObj));

                templateFilesWrapperObj.titleImageType = ServiceConstants.TITLE_IMAGE_TYPE_WIDESCREEN;
                templateFilesWrapperObj.fileWrapperObj = wrapperObj.imgLandscapeFile;
	        	listOfNewFiles.add(convertFileTemplateWrapperToFileObject(wrapperObj.siteId,templateId,templateFilesWrapperObj));
	        	if(wrapperObj.imgOriginalFile != null) {
                    templateFilesWrapperObj.titleImageType = ServiceConstants.TITLE_IMAGE_TYPE_ORIGINAL;
                    templateFilesWrapperObj.fileWrapperObj = wrapperObj.imgOriginalFile;
		        	listOfNewFiles.add(convertFileTemplateWrapperToFileObject(wrapperObj.siteId,templateId,templateFilesWrapperObj));
	        	}
        
        } else {
        		listOfContentFiles.addAll(mapOfExistingTitleImages.values());
        }
        
        
        if(listOfNewFiles.isEmpty() == false) {
			listOfNewFiles = insertTemplateFiles(listOfNewFiles);
        }
        	
        updateDeletedTemplateFiles(listOfDeletedFiles);
          
        listOfContentFiles.addAll(listOfNewFiles);
        SimpplrContext.skipContentDocTrigger = true;
		
		// Create CDL for all files siteId and siteType
        createCDLForTemplateFiles(listOfContentFiles,wrapperObj.siteId);
		
		SimpplrContext.skipContentDocTrigger = false;
	}

    /**
     * @description save videos
     * @param isEdit
     * @param templateId
     * @param wrapperObj
    */
    public void saveContentTemplateVideosToSF(Boolean isEdit, Id templateId, ContentTemplateWrapper wrapperObj) {
		String contentVideosFolderId; 
		if(String.isNotBlank(wrapperObj.siteId)) {
			SiteDao siteDaoObj = new SiteDao();
	        Map<String, Folder__c> mapOfSystemFolders4Site = siteDaoObj.getMapOfSystemFoldersForSite(wrapperObj.siteId);
            if(!mapOfSystemFolders4Site.isEmpty() && SimpplrContext.isNativeVideo) {
                contentVideosFolderId = mapOfSystemFolders4Site.get('Content Files.Videos').Id;
            }
		}
        
		List<File__c> listOfContentFiles = new List<File__c>(); 
        List<File__c> listOfNewFiles = new List<File__c>();
        List<File__c> listOfDeletedFiles = new List<File__c>();
        Map<Id, File__c> mapOfExistingInlineVideos = new Map<Id, File__c>();

        if(isEdit) {
            FileDao fileDaoObj = new FileDao();
            List<File__c> fileList = fileDaoObj.getContentTemplateFiles(templateId);
            for(File__c fileObj : fileList) {
                if(ServiceConstants.FILE_LOCATION_INLINE.equalsIgnoreCase(fileObj.Location__c) && ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(fileObj.Repository__c)) {
                    mapOfExistingInlineVideos.put(fileObj.id, fileObj);  
                } 
            }
        } 
        ContentTemplateWrapper.TemplateFilesWrapper templateFilesWrapperObj = new ContentTemplateWrapper.TemplateFilesWrapper();
        
		//Insert List Of Inline Videos 
		if(wrapperObj.listOfInlineVideos != null && !wrapperObj.listOfInlineVideos.isEmpty()) {
	        for(FileContentWrapper fileWrapperObj : wrapperObj.listOfInlineVideos) {
		        	if(mapOfExistingInlineVideos.containsKey(fileWrapperObj.fileId)) {
		        		listOfContentFiles.add(mapOfExistingInlineVideos.get(fileWrapperObj.fileId));
		        		mapOfExistingInlineVideos.remove(fileWrapperObj.fileId);
		        	} else {
                        templateFilesWrapperObj.folderId = contentVideosFolderId;
                        templateFilesWrapperObj.location = ServiceConstants.FILE_LOCATION_INLINE; 
                        templateFilesWrapperObj.titleImageType = null;
                        templateFilesWrapperObj.fileWrapperObj = fileWrapperObj;
		        		File__c fileObj = convertFileTemplateWrapperToFileObject(wrapperObj.siteId,templateId,templateFilesWrapperObj);
	        			listOfNewFiles.add(fileObj);
		        	}
	        }
        }

		listOfDeletedFiles.addAll(mapOfExistingInlineVideos.values());
    		
        if(listOfNewFiles.isEmpty() == false) {
			listOfNewFiles = insertTemplateFiles(listOfNewFiles);
        }
        	
        updateDeletedTemplateFiles(listOfDeletedFiles);
          
        listOfContentFiles.addAll(listOfNewFiles);
        SimpplrContext.skipContentDocTrigger = true;
		
		// Create CDL for all files siteId and siteType
        createCDLForTemplateFiles(listOfContentFiles,wrapperObj.siteId);
		
		SimpplrContext.skipContentDocTrigger = false;
	}

    /** 
     * @description insert new files 
     * @param fileList
     * @return List<File__c>
     */
    public List<File__c> insertTemplateFiles(List<File__c> fileList){
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPSFDCAccessControlResults.InsertResults result = SIMPESAPI.accessController().insertAsUser(fileList, new List<Schema.SObjectField>{
				File__c.Title__c,
				File__c.Size__c,
				File__c.MIME_Type__c,
				File__c.Content_Version__c,
				File__c.Content_Document__c,
				File__c.author__c,
				File__c.Content_Template__c,
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
			return (List<File__c>)result.getInsertedObjects();
    }

    /** 
     * @description update template id for deleted template files
     * @param fileList
     */
    public void updateDeletedTemplateFiles(List<File__c> fileList){
        if(fileList.isEmpty() == false) {
            for(File__c fileObj : fileList) {
                fileObj.Content_Template__c = null;
            }
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(new Map<Id, File__c>(fileList), new List<Schema.SObjectField>{
                                                        File__c.Content_Template__c
                                                    });
        } 
    }

    /** 
     * @description create CDL
     * @param fileList
     * @param siteId
     */
    public void createCDLForTemplateFiles(List<File__c> fileList,Id siteId){
        if((fileList.size() > 0)) {
			FileDao fileDaoObj = new FileDao();
				if(String.isNotBlank(siteId)) {
					fileDaoObj.createContentDocumentLinks( fileList, SiteContext.chatterGroupId, SiteContext.isPublicSite);
				} else {
					fileDaoObj.createContentDocumentLinks( fileList, SiteContext.chatterGroupId, null);
				}

        }
    }

    /**
     * @description save topic to sf
    */
    public void saveTopicAssignmentsToSF(Boolean isEdit, Id templateId, List<TopicWrapper> listOfTopics, List<String> listOfTemplateBodyTopics, Map<String, String> mapOfNewTopics) {
		Map<String, TopicAssignment> mapOfTopicIdAndTopicAssignment = new Map<String, TopicAssignment>();
        if(listOfTopics != null) {
	        for(TopicWrapper topicObj : listOfTopics) {
	            if(String.isNotBlank(topicObj.id)) {
					mapOfTopicIdAndTopicAssignment.put(topicObj.id, new TopicAssignment(TopicId = topicObj.id, EntityId = templateId));
	            
	            } else if(mapOfNewTopics.containsKey(topicObj.name)) {
	            		String topicId = mapOfNewTopics.get(topicObj.name);
					mapOfTopicIdAndTopicAssignment.put(topicId, new TopicAssignment(TopicId = topicId, EntityId = templateId));
	            	
	            }
	        }
        }
        if(listOfTemplateBodyTopics != null) {
        		for(String topicStr : listOfTemplateBodyTopics) {
    				if(mapOfNewTopics.containsKey(topicStr)) {
    					String topicId = mapOfNewTopics.get(topicStr);
    					mapOfTopicIdAndTopicAssignment.put(topicId, new TopicAssignment(TopicId = topicId, EntityId = templateId));
    					
    				} else if(String.isNotBlank(topicStr) && topicStr.startsWithIgnoreCase('_new_') == false) {
    					mapOfTopicIdAndTopicAssignment.put(topicStr, new TopicAssignment(TopicId = topicStr, EntityId = templateId));
    					
        			}
        		}
        	
        }
        List<TopicAssignment> listOfDeletedTopicAssignment = new List<TopicAssignment>();
        List<TopicAssignment> listOfNewTopicAssignment = new List<TopicAssignment>();
		
		if(isEdit) {
			List<TopicAssignment> existingTopicAssignmentList= [Select id, TopicId from TopicAssignment where entityId=:templateId WITH SECURITY_ENFORCED];
			
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
			insert mapOfTopicIdAndTopicAssignment.values();
		}
	}
    
    /**
     * @description conversion of wrapper to object
     * @param templateFilesWrapperObj
     * @return File__c
    */
    private File__c convertFileTemplateWrapperToFileObject(Id siteId,Id templateId,ContentTemplateWrapper.TemplateFilesWrapper templateFilesWrapperObj) {
		
		File__c fileObj 			= new File__c(); 
        fileObj.Title__c 			= templateFilesWrapperObj.fileWrapperObj.title;
        fileObj.Size__c 			= templateFilesWrapperObj.fileWrapperObj.size != null ? Decimal.valueOf(templateFilesWrapperObj.fileWrapperObj.size) : 0;
        fileObj.MIME_Type__c		= templateFilesWrapperObj.fileWrapperObj.fileType;
        
        if (!ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(templateFilesWrapperObj.fileWrapperObj.context)) {
        	fileObj.Content_Version__c 	= templateFilesWrapperObj.fileWrapperObj.contentVersionId;
        }
		fileObj.Content_Document__c = templateFilesWrapperObj.fileWrapperObj.contentDocumentId;
		fileObj.author__c = UserContext.peopleId;
		fileObj.Content_Template__c 	= templateId;
		fileObj.Site__c = siteId;
        fileObj.Folder__c = templateFilesWrapperObj.folderId;
        fileObj.Location__c = templateFilesWrapperObj.location;
        fileObj.MIME_Type__c = templateFilesWrapperObj.fileWrapperObj.type;
        
		fileObj.Is_Title_Image__c = false;
        if(ServiceConstants.FILE_LOCATION_COVER.equalsIgnoreCase(templateFilesWrapperObj.location)) {
	        	fileObj.Title_Image_Type__c = templateFilesWrapperObj.titleImageType;
	        	fileObj.Is_Title_Image__c = true;
        }
		fileObj.Repository__c = templateFilesWrapperObj.fileWrapperObj.context;
		if(ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(templateFilesWrapperObj.fileWrapperObj.context)){
			Integer captionLanguageId = ServiceConstants.SIMPPLR_LANG_VS_KALTURA_LANG_ID_MAP.get(UserContext.languageLocaleKey);
			if(captionLanguageId != null){
				fileObj.Video_Caption_Language__c =  String.valueOf(captionLanguageId);
			}
			fileObj.video_provider__c = templateFilesWrapperObj.fileWrapperObj.context ;
			fileObj.External_Id__c = String.isBlank(templateFilesWrapperObj.fileWrapperObj.externalFileId) ? String.isNotBlank(templateFilesWrapperObj.fileWrapperObj.url.subStringAfter('?').subStringBetween('fileId=','&'))?templateFilesWrapperObj.fileWrapperObj.url.subStringAfter('?').subStringBetween('fileId=','&'): templateFilesWrapperObj.fileWrapperObj.url.subStringAfter('fileId='): templateFilesWrapperObj.fileWrapperObj.externalFileId;	
			fileObj.Thumbnail_url__c = ServiceConstants.NATIVE_VIDEO_BASE_URL + SimpplrContext.Integrations.get(ServiceConstants.VIDEO_PROVIDER_NATIVE).External_Id__c +'/thumbnail/entry_id/' + fileObj.External_Id__c +'/width/550/height/480';
        }
		
		return fileObj;
	}
    /**
     * 
     * @Description:  [This method create topic wrapper for a content template]
     * @Parameters:    contentTemplateId -> templateId, topicURL -> base URL
     * @Returns:  [Returns the list of Content Templates wrapper]
    */
    public List<TopicWrapper> convertToContentTemplateTopicWrapper(String contentTemplateId, String topicURL){
		List<TopicWrapper> listOfTopics = new List<TopicWrapper>(); 
		for(TopicAssignment topicAssignmentRecord : [SELECT TopicId, Topic.Name FROM TopicAssignment WHERE EntityId =:contentTemplateId AND EntityType='Content_Template' WITH SECURITY_ENFORCED]) {
			if(String.isNotBlank(topicAssignmentRecord.topic.name)) {
				TopicWrapper wrapperObj 		= new TopicWrapper();
				wrapperObj.id 					= topicAssignmentRecord.topic.id;
				wrapperObj.topicAssignmentId 	= topicAssignmentRecord.Id;
				wrapperObj.name 				= topicAssignmentRecord.topic.name;
				wrapperObj.url 					= topicURL + '?u=/topic/' + topicAssignmentRecord.Topic.Id + '/contentTemplate';
				listOfTopics.add(wrapperObj);
			}
		}
		return listOfTopics;
	}
    /**
     * 
     * @Description:  [This method returns list of files corresponding to content template]
     * @Parameters:    contentTemplateId -> templateId
     * @Returns:  [Returns the list of files for Content Templates id]
    */
    public List<File__c> getFilesByContentTemplateId(String contentTemplateId){
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', contentTemplateId);
		String filesQuery = 'SELECT id, Title_Image_Type__c,Description__c, Is_Title_Image__c, Thumbnail_URL__c, '+
									' MIME_Type__c, Content_Template__r.Site__c,External_Id__c, Repository__c, URL__c, '+
									' Title__c, Site__c, Content_Document__c,Content_Version__c, size__c, Location__c,'+
									' Likes__c, Video_Status__c, is_Deleted__c, SP_Instance_Id__c '+
									' FROM File__c WHERE is_Deleted__c = false '+
									' AND (Location__c != \'media\' OR Is_Title_Image__c = true) AND'+
		 							' Content_Template__c =:soqlParam1 ORDER BY Order__c';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> fileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
		return fileList;
	}
    /**
     * 
     * @Description:  [This method convert the file object to file wrapper]
     * @Parameters:    fileObj -> file record
     * @Returns:  [Returns the wrapper corresponding to file record]
    */
    public FileContentWrapper convertFileToFileContentTemplateWrapper(File__c fileObj) {
    	FileContentWrapper fileWrapperObj = New FileContentWrapper();
  		fileWrapperObj.fileId = fileObj.id;
  		fileWrapperObj.type = Utility.getFileType(fileObj.MIME_Type__c);
  		fileWrapperObj.context = fileObj.Repository__c != null ? fileObj.Repository__c.toLowerCase() : ServiceConstants.STORAGE_TYPE_INTRANET_STRING;
  		fileWrapperObj.provider = fileWrapperObj.context;
  		if(String.isNotBlank(fileObj.Content_Document__c)) {
  			fileWrapperObj.id = fileObj.Content_Document__c;
  			Map<String, String> fileDetailParams = new Map<String, String>{'fileId' => fileObj.Content_Document__c};
	  		if(String.isNotBlank(fileObj.Content_Template__r.Site__c)){
				fileDetailParams.put('siteId', fileObj.Content_Template__r.Site__c);
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
					PageReference internalSFLink = new PageReference(fileObj.Url__c);
					fileWrapperObj.rootDirectory = internalSFLink.getParameters().get('rootDirectory');
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
}