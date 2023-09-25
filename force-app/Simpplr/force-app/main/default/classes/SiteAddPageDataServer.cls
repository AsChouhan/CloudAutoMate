/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class SiteAddPageDataServer extends ContentDataServer{
	private PageDao pageDaoObj;
    private Boolean hasContentApprovalAccess;
	private final String ACTION_VALUE_PUBLISH = 'publish';
	private final String ACTION_VALUE_DRAFT = 'saveDraft';
	private final String ACTION_VALUE_UPDATE_DRAFT = 'updateDraft';
	private final String ACTION_VALUE_UPDATE = 'update';
	private final String ACTION_VALUE_APPROVE = 'approve';
	private final String ACTION_VALUE_GET = 'get';
	private final String REQUEST_PARAM_DATA = 'data';
	private final String MOVE_TO_BOTTOM = 'moveToBottom';
	private final String MOVE_TO_TOP = 'moveToTop';
	private final String UPDATE_PAGE_POISTION = 'updatePagePosition';
    private final String ACTION_START_CONTENT_EDIT = 'startContentEdit';
    private final String CONTENT_LASTMODIFIEDDATETIMESTAMP = 'lastModifiedDateTimeStamp';
	private DateTime currentDateTime = DateTime.now();
	private String loggedInPeopleId = UserContext.peopleId;
    
    public SiteAddPageDataServer() {
		pageDaoObj = new PageDao();
    }

	public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
    public override void handleRequest() {
		Savepoint sp;

    	try {
    		logger.logDebug('SiteAddPageDataServer.handleRequest()----Start----');
            String action = readParam(REQUEST_PARAM_ACTION);
            String requestData = readParam(REQUEST_PARAM_DATA);
    		
            if (String.isBlank(requestData) && !ACTION_VALUE_GET.equalsIgnoreCase(action)) {
	            throw new SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
	        } 
	        
	        if (ACTION_VALUE_GET.equalsIgnoreCase(action)) {

				if(String.isNotBlank(readParam('versionHistoryId'))){
					response = getPageByVersionHistoryId(readParam('contentId'), readParam('versionHistoryId'));

				} else {
					response = getPage(readParam('contentId'));

				}

	        } else if(ACTION_START_CONTENT_EDIT.equalsIgnoreCase(action)){
				sp = Database.setSavepoint();
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
	            
	            } else if (ACTION_VALUE_APPROVE.equalsIgnoreCase(action) && 
						hasContentApprovalAccess) {
					response = publish(requestData);
					
				} else if (ACTION_VALUE_UPDATE.equalsIgnoreCase(action)) {
					response = hasContentApprovalAccess ? updatePage(requestData) : 
							submitForApproval(requestData);
	            
	            } else if (MOVE_TO_BOTTOM.equalsIgnoreCase(action)) {
					sp = Database.setSavepoint();
	            	response = moveToBottom(requestData);
	            
	            } else if (MOVE_TO_TOP.equalsIgnoreCase(action)) {
					sp = Database.setSavepoint();
	            	response = moveToTop(requestData);
	            
	            } else if (UPDATE_PAGE_POISTION.equalsIgnoreCase(action)) {
					sp = Database.setSavepoint();
	            	response = updatePagePosition(requestData);	            	            

				} else {
	                throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
	            }

	        }

        } catch (Exception ex) {
            logger.logError('SiteAddPageDataServer.handleRequest()---Exception occured----', ex);
			if(sp!=null){
				Database.rollback(sp);
			}
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, 
					MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        
	}
	
	@TestVisible
	private ResponseWrapper startContentEdit(String requestData){
		logger.logDebug('SiteAddPageDataServer.startContentEdit()---data---' + requestData);
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

			List<Simpplr_Content__c> contentList = getPageById(contentId); 
			if(!contentList.isEmpty() && versionNumber != contentList[0].Version__c){
                contentLockWrapperObj.content = convertToContentWrapper(contentList[0]);
				// This is to handle existing content records created before this change.
				ManageContentDao contentDoa = new ManageContentDao();
				contentDoa.checkAndCreateContentHistory(contentList[0], ServiceConstants.TYPE_PAGE);
			}
			
		}
		
		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, contentLockWrapperObj);

		return resultWrapper;
    }

	private ResponseWrapper updatePage(String data) {
		ContentWrapper localContWrapObj = ContentWrapper.parse(data);
		String contentId = localContWrapObj.id == null ? readParam('contentId') : localContWrapObj.id;
        Boolean isContentPublishedBeforeUpdate = isContentPublished(contentId); 

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
            }
            
        }
        
        return resultObj;
    }

	private ResponseWrapper moveToBottom(String data) {
		PageOrderWrapper wrapperObj = (PageOrderWrapper) JSON.deserialize(data, 
				PageOrderWrapper.class);

		if (wrapperObj != null) {
			List<Simpplr_Content__c> pageList = [SELECT Id, Pages_Category__c, Site__c, 
					Display_Order__c 
					FROM Simpplr_Content__c 
					WHERE Is_Published__c= true AND Status__c= 'Approved' 
					AND Type__c='Page' AND Site__c =: wrapperObj.siteId AND 
					Pages_Category__c =: wrapperObj.categoryId WITH SECURITY_ENFORCED ORDER BY Display_Order__c, Last_Updated_DateTime__c desc, Last_Validated_DateTime__c];
			List<Simpplr_Content__c> updatedPageList = new List<Simpplr_Content__c>();
			Integer counter = 1; 

			for (Simpplr_Content__c pages : pageList) {
				
				if (pages.id != wrapperObj.pageId) {
					updatedPageList.add(new Simpplr_Content__c(id = pages.id, 
							Display_Order__c = counter++));
				}

			}

			updatedPageList.add(new Simpplr_Content__c(id = wrapperObj.pageId, 
					Display_Order__c = counter));
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, Simpplr_Content__c>(updatedPageList), 
					new List<Schema.SObjectField> {
						Simpplr_Content__c.Display_Order__c
					});
		}

		ResponseWrapper result = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, wrapperObj);
        return result;
	}

	private ResponseWrapper moveToTop(String data) {
		PageOrderWrapper wrapperObj = (PageOrderWrapper) JSON.deserialize(data, 
				PageOrderWrapper.class);

		if (wrapperObj != null) {
			List<Simpplr_Content__c> pageList = [SELECT Id, Pages_Category__c, Site__c, 
					Display_Order__c 
					FROM Simpplr_Content__c 
					WHERE Is_Published__c= true AND Status__c= 'Approved' AND Type__c = 'Page' 
					AND Site__c =: wrapperObj.siteId AND 
					Pages_Category__c =: wrapperObj.categoryId WITH SECURITY_ENFORCED ORDER BY Display_Order__c, Last_Updated_DateTime__c desc, Last_Validated_DateTime__c];
			List<Simpplr_Content__c> updatedPageList = new List<Simpplr_Content__c>();
			Integer counter = 1; 
			updatedPageList.add(new Simpplr_Content__c(id = wrapperObj.pageId, 
					Display_Order__c=counter++));

			for (Simpplr_Content__c pages : pageList) {
				
				if (pages.id != wrapperObj.pageId){
					updatedPageList.add(new Simpplr_Content__c(id = pages.id, 
							Display_Order__c = counter++));
				}

			}

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, Simpplr_Content__c>(updatedPageList), 
					new List<Schema.SObjectField> {
						Simpplr_Content__c.Display_Order__c
					});
		}

		ResponseWrapper result = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, wrapperObj);
        return result;
	}

	private ResponseWrapper updatePagePosition(String data){
		PageOrderWrapper wrapperObj = (PageOrderWrapper) JSON.deserialize(data, 
				PageOrderWrapper.class);
		
		if (wrapperObj != null) {
			List<String> pageIdList = wrapperObj.pageIdsArray;

			if (pageIdList != null && !pageIdList.isEmpty()) {
				List<Simpplr_Content__c> pageList = [SELECT Id, Display_Order__c 
						FROM Simpplr_Content__c 
						WHERE Site__c =: wrapperObj.siteId AND Pages_Category__c =: wrapperObj.categoryId WITH SECURITY_ENFORCED ORDER BY Display_Order__c, Publish_Start_DateTime__c desc, Last_Updated_DateTime__c desc, Last_Validated_DateTime__c limit 10000];
				Map<String,Simpplr_Content__c> pageMap = new Map<String, Simpplr_Content__c>(pageList);
				Set<String> processedPageIdSet = new Set<String>();
				Integer displayorder = 1;

				for (String pageId : pageIdList) {
					
					if (pageMap.get(pageId) != null) {
						pageMap.get(pageId).Display_Order__c = displayorder;
						displayorder = displayorder +1 ;
						processedPageIdSet.add(pageId);
					}

				}

				for (Simpplr_Content__c content : pageList) {

					if (!processedPageIdSet.contains(content.id)) {
						pageMap.get(content.id).Display_Order__c = displayorder;
						displayorder = displayorder + 1 ;
					}

				}
				
				if (!pageMap.values().isEmpty()) {
					update pageMap.values();	
				}

			}

		}

		ResponseWrapper result = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, wrapperObj);
        return result;
	}
   
    private ResponseWrapper publish(String data){
        ResponseWrapper resultObj = processContentData(data, 
				ServiceConstants.CONTENT_STATUS_APPROVED, null);

		if (resultObj.status == RESPONSE_STATUS_SUCCESS)  {
			ContentWrapper contWrapObj = new ContentWrapper();
			contWrapObj = ((ContentWrapper)(resultObj.result));

            if (contWrapObj.isPublished) { 

					publishTimeLine(contWrapObj);

				if(SimpplrContext.isFeatureMicrosoftTeamsEnabledPhase2 && SiteContext.MicrosoftTeamsIntegrationEnabled){
					new MicrosoftTeamsHelper().getContentInfo(contWrapObj.id, 'page');
            	}

				if(SimpplrContext.isSlackPhase2FeatureEnabled && SimpplrContext.isSlackUpgraded && SiteContext.SlackIntegrationEnabled){
					new SlackHelper().getContentInfo(contWrapObj.id, null, '');
				}
			}
        }
		return resultObj; 
    } 

	private void publishTimeLine(ContentWrapper contWrapObj) {
		String grpMentionStr = ''; 
		if('Public'.equalsIgnoreCase(contWrapObj.site.access) || 
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
		}else if(SiteContext.isBroadcastSite && UserContext.isUserAppModerator){
			FeedServiceProvider.createTimeLineFeedForBroadcastSiteByAppModerators(contWrapObj.site.chatterGroupId, contWrapObj.id, contWrapObj.url, contWrapObj.title, grpMentionStr);
		}else {
			FeedServiceProvider.createTimeLine(null, contWrapObj.id, contWrapObj.url, 
				contWrapObj.title, grpMentionStr);
		}
	}
       
    private ResponseWrapper updateDraft(String data) {
        ResponseWrapper result = processContentData(data, ServiceConstants.CONTENT_STATUS_DRAFT, ServiceConstants.CONTENT_STATUS_UPDATE_DRAFT);
        return result;
    }
    
    private ResponseWrapper draft(String data) {
    	ResponseWrapper result = processContentData(data, ServiceConstants.CONTENT_STATUS_DRAFT, ServiceConstants.CONTENT_STATUS_CREATE_DRAFT);
        return result;
    }

	private ResponseWrapper submitForApproval(String data) {
        ResponseWrapper result = processContentData(data, ServiceConstants.CONTENT_STATUS_SUBMIITED, null);
        return result;
    }
    
    private ResponseWrapper processContentData(String data, String status, String draftType) {
		logger.logDebug('SiteAddPageDataServer.processContentData()----status----' + status);
		ContentWrapper wrapperObj = ContentWrapper.parse(data);
		Savepoint sp;
		ResponseWrapper result;
		try{

			wrapperObj.id = wrapperObj.id == null ? readParam('contentId') : wrapperObj.id;
			wrapperObj.siteId = wrapperObj.siteId == null ? SiteContext.siteId : wrapperObj.siteId;
			Boolean isEdit = String.isNotBlank(wrapperObj.id);
			Boolean isSiteAvailableInSimpplr = checkSiteAvailabilityInSimpplr(wrapperObj.siteId);
			Boolean saveDraftInPlaceOfPublish = false;
			wrapperObj.status = status;
			
			if (!isSiteAvailableInSimpplr) {
				
				if (isEdit) {
					result = buildResponseWrapper(RESPONSE_STATUS_ERROR, ServiceConstants.SF_EXCEPTION, null);
					return result;

				} else {
					
					if (ServiceConstants.CONTENT_STATUS_APPROVED.equals(status)) { // Publishing new content 
						saveDraftInPlaceOfPublish = true;
						wrapperObj.status = ServiceConstants.CONTENT_STATUS_DRAFT;
					}

				}
				
			}

			String contentStatusOld = '';
			// Check if content update is there then pass exsiting content object to create history and trails
			if(isSiteAvailableInSimpplr){
				Simpplr_Content__c content = ManageContentDao.getContentById(wrapperObj.id);
				if(content != null) {
					contentStatusOld = content.Status__c;
					if(ACTION_VALUE_UPDATE.equalsIgnoreCase(status)){
						//Addtionally check if there are stuck validation notifications
						if('knowledge'.equalsIgnoreCase(content.Content_Sub_Type__c) && 'news'.equalsIgnoreCase(wrapperObj.contentSubType)){
							NotificationDao notificationDaoObj = new NotificationDao();
							notificationDaoObj.checkAndRemoveStuckNotifications(content.Id);
						}
					} 
				}
			}
			
			if(wrapperObj.bodyJson!=null) {
				String sanitizedHTML = Utility.getSanitizedHTMLfromLambda(wrapperObj.body);
				wrapperObj.body = sanitizedHTML;
			}
			sp = Database.setSavepoint();

			// Step 1: Create new topics or get existing topicId if topic exists already
			Map<String, String> mapOfNewTopics = createNewTopics(wrapperObj.listOfTopics, 
					wrapperObj.listOfContentTopicIds);
			// Step 2: Save Simpplr_Content__c record
			ContentTriggerHandler.isCalledFromEditContentScreen = true;
			Simpplr_Content__c contentObj = saveContentObjectToDB(isEdit, wrapperObj, mapOfNewTopics);
			logger.logDebug('content Obj '+contentObj);
			// Step 3: Send approval notification if required
			if (isSiteAvailableInSimpplr && isEdit && 
					ServiceConstants.CONTENT_STATUS_APPROVED.equals(status)) {
					AllContentDataServer contentServerObj =  new AllContentDataServer();
					contentServerObj.checkAndApproveNotifications(contentObj);
			}

			// Step 4: Save File__c records
			saveContentFilesToDB(isEdit, contentObj.id, wrapperObj, status);
				
			// Step 5: Save TopicAssignment records
			saveTopicAssignmentsToDB(isEdit, contentObj.id, wrapperObj.listOfTopics, 
					wrapperObj.listOfContentTopicIds, mapOfNewTopics);
			
			// Save Suggested Topics from AI 
			if(wrapperObj.listOfSuggestedTopics!=null){
				saveAISuggestedTopicsToDB(wrapperObj.listOfSuggestedTopics, contentObj.id, wrapperObj.listOfTopics, mapOfNewTopics);
			}

			if (SimpplrContext.isExternalSearchAppConnected) {
				ManageContentDao.insertSearchTrailObjectForContentAsync(contentObj.id);
			}

			//Create content history record asynchronously
			if (isSiteAvailableInSimpplr) {
				if(isEdit){
					if(ACTION_VALUE_UPDATE.equalsIgnoreCase(status)){
						ManageContentDao.createContentHistoryAndAuditRecordsAsync(contentObj.Id, ServiceConstants.CONTENT_STATUS_UPDATE, ServiceConstants.TYPE_PAGE);

					} else if(ServiceConstants.CONTENT_STATUS_UPDATE_DRAFT.equalsIgnoreCase(draftType)){
						ManageContentDao.createContentHistoryAndAuditRecordsAsync(contentObj.Id, ServiceConstants.CONTENT_STATUS_UPDATE_DRAFT, ServiceConstants.TYPE_PAGE); 

					} else if(ServiceConstants.CONTENT_STATUS_APPROVED.equalsIgnoreCase(status) && 
							ServiceConstants.CONTENT_STATUS_SUBMITTED.equalsIgnoreCase(contentStatusOld)) {
						ManageContentDao.createContentHistoryAndAuditRecordsAsync(contentObj.Id, ServiceConstants.CONTENT_STATUS_UPDATE, ServiceConstants.TYPE_PAGE);
					
					} else if(ServiceConstants.CONTENT_STATUS_SUBMITTED.equalsIgnoreCase(status)) {
						ManageContentDao.createContentHistoryAndAuditRecordsAsync(contentObj.Id, ServiceConstants.CONTENT_STATUS_UPDATE_DRAFT, ServiceConstants.TYPE_PAGE);

					} 
				}else{
					if(ServiceConstants.CONTENT_STATUS_CREATE_DRAFT.equalsIgnoreCase(draftType)){
						ManageContentDao.createContentHistoryAndAuditRecordsAsync(contentObj.Id, ServiceConstants.CONTENT_STATUS_CREATE_DRAFT, ServiceConstants.TYPE_PAGE);

					} else if(ServiceConstants.CONTENT_STATUS_APPROVED.equalsIgnoreCase(status)){
						ManageContentDao.createContentHistoryAndAuditRecordsAsync(contentObj.Id, ServiceConstants.CONTENT_STATUS_APPROVED, ServiceConstants.TYPE_PAGE);

					} else if(ServiceConstants.CONTENT_STATUS_SUBMITTED.equalsIgnoreCase(status)) {
						ManageContentDao.createContentHistoryAndAuditRecordsAsync(contentObj.Id, ServiceConstants.CONTENT_STATUS_CREATE_DRAFT, ServiceConstants.TYPE_PAGE);
					}
				}

				if(ServiceConstants.CONTENT_STATUS_SUBMIITED.equalsIgnoreCase(status)){
					ManageContentDao daoObj = new ManageContentDao();
					daoObj.createContentAuditTrail(contentObj.id, status, null); 
					Map<String,App_Notification__c> userToNotificationMap = NotificationDao.generateReviewNotifications(contentObj.Id, 
							ServiceConstants.TYPE_PAGE, contentObj.title__c, contentObj.site__c, 
							contentObj.Summary_1__c);
					NotificationDispatcher.sendEmailForContentModeration(contentObj);
				}
			}
			
			if (saveDraftInPlaceOfPublish) {
				result = buildResponseWrapper(RESPONSE_STATUS_ERROR, 
						ServiceConstants.SF_EXCEPTION, null);

			} else {
				result = getPage(contentObj.Id);
			}
		}catch(Exception ex) {
            logger.logError('SiteAddPageDataServer.processContentData()---Exception occured----', ex);
			if(sp!=null){
				Database.rollback(sp);
			}
            result = buildResponseWrapper(RESPONSE_STATUS_ERROR, 
					MessageHelper.translateSFMessageToErrorCode(ex), null);
        }

		return result;

    }
    
    private Simpplr_Content__c saveContentObjectToDB(Boolean isEdit, ContentWrapper localWrapperObj, 
		Map<String, String> mapOfNewTopics) {
        Simpplr_Content__c contentObj;
        String oldAuthorId;
		String oldPageCategoryId;
		String oldStatus;
		Datetime oldpublishStartDatetime;

		// common fields to update - irrespective of isEdit paramater
		List<Schema.SObjectField> fieldList = new List<Schema.SObjectField> {
			Simpplr_Content__c.Title__c,
			Simpplr_Content__c.Content_Sub_Type__c,
			Simpplr_Content__c.Title_Image_Caption__c,
			Simpplr_Content__c.Display_Excerpt__c,
			Simpplr_Content__c.Publish_End_DateTime__c,
			Simpplr_Content__c.Last_Edited_DateTime__c,
			Simpplr_Content__c.Last_Updated_DateTime__c,
			Simpplr_Content__c.Last_UpdatedBy_People__c,
			Simpplr_Content__c.Allow_comments__c,
			Simpplr_Content__c.Use_Maximum_Screenwidth__c,
			Simpplr_Content__c.Cover_Image_Layout__c,
			Simpplr_Content__c.Language__c
		};
		
        if (isEdit) {
            contentObj = [SELECT Id, Type__c, Display_Order__c, Site__c, Status__c, Version__c, Is_Published__c,
					Primary_Author__c, Primary_Author__r.Full_Name__c, Primary_Author__r.Is_Protected_Author__c, 
					Publish_Start_DateTime__c, Pages_Category__c, Content_Sub_Type__c, Last_Validated_DateTime__c, Read_Time__c
            		FROM Simpplr_Content__c 
            		WHERE id =: localWrapperObj.id 
            		AND Type__c =: ServiceConstants.TYPE_PAGE
            		AND Site__c=: localWrapperObj.siteId WITH SECURITY_ENFORCED];   
            oldAuthorId = contentObj.Primary_Author__c;
			oldPageCategoryId = contentObj.Pages_Category__c;
			oldStatus = contentObj.Status__c;
			oldpublishStartDatetime = contentObj.Publish_Start_DateTime__c;

			// Update version
			if(contentObj.Version__c != null){
				contentObj.Version__c = contentObj.Version__c + 1;
				fieldList.add(Simpplr_Content__c.Version__c);
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
            	
				if (ServiceConstants.CONTENT_STATUS_DRAFT.equalsIgnoreCase(contentObj.Status__c)) {
            		contentObj.Status__c = hasContentApprovalAccess ? ServiceConstants.CONTENT_STATUS_APPROVED : ServiceConstants.CONTENT_STATUS_SUBMITTED;
					fieldList.add(Simpplr_Content__c.Status__c);
				} 

            } else {
            	contentObj.Status__c = localWrapperObj.status;
				fieldList.add(Simpplr_Content__c.Status__c);
            }

        } else {

			Utility.checkForRateLimit('content');

	        contentObj = new Simpplr_Content__c();
	        contentObj.Type__c = ServiceConstants.TYPE_PAGE;
			contentObj.Site__c = localWrapperObj.siteId;
			contentObj.Status__c = localWrapperObj.status;

			fieldList.add(Simpplr_Content__c.Type__c);
			fieldList.add(Simpplr_Content__c.Site__c);
			fieldList.add(Simpplr_Content__c.Status__c);
        }
        
        contentObj.Title__c = localWrapperObj.title;
		contentObj.Content_Sub_Type__c = localWrapperObj.contentSubType;
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
		contentObj.Text_Main__c	= contentBodyParts[1];
		contentObj.Text_Main_Continued__c = contentBodyParts[2];
		contentObj.Excerpt__c = Utility.getPlainText(contentObj.Text_Intro__c, 250, true);
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
		contentObj.Display_Excerpt__c = Utility.getDisplayExcerpt(contentObj.Excerpt__c,contentObj.Summary_1__c);
        
		if (localWrapperObj.category != null) {
			if (String.isNotBlank(localWrapperObj.category.Id)) {
				contentObj.Pages_Category__c = localWrapperObj.category.Id;

			} else if (hasContentApprovalAccess) {
				contentObj.Pages_Category__c = pageDaoObj.createPagesCategory(localWrapperObj.category.Name, 
						localWrapperObj.siteId).Id;
			}
			fieldList.add(Simpplr_Content__c.Pages_Category__c);
        }
       		
		if (String.isNotBlank(localWrapperObj.publishAt)) {
			// publishAt => 2022-07-04T00:00:00 from UI
			contentObj.Publish_Start_DateTime__c = Utility.momentJSDateTimeStringToDateTime(localWrapperObj.publishAt);
			fieldList.add(Simpplr_Content__c.Publish_Start_DateTime__c);
		} else {
			throw New SimpplrException(ExceptionCode.EMPTY_PUBLISH_START_DATE.name());
		}

		if(localWrapperObj.readTime != null){
			contentObj.Read_Time__c = localWrapperObj.readTime;
			fieldList.add(Simpplr_Content__c.Read_Time__c);
		}

        contentObj.Publish_End_DateTime__c = String.isNotBlank(localWrapperObj.publishTo) ? 
				Utility.momentJSDateTimeStringToDateTime(localWrapperObj.publishTo) : null;
        contentObj.Last_Edited_DateTime__c = DateTime.now();
		contentObj.Last_Updated_DateTime__c = DateTime.now();
		contentObj.Last_UpdatedBy_People__c = UserContext.getCurrentUserInfo.Id;
		contentObj.Allow_comments__c = localWrapperObj.isFeedEnabled == true ? true : false;
        contentObj.Use_Maximum_Screenwidth__c = localWrapperObj.isMaximumWidth == true ? true : false;
		contentObj.Cover_Image_Layout__c = localWrapperObj.imgLayout;
		contentObj.Language__c = localWrapperObj.language;

		ManageContentDao manageContentDaoObj = new ManageContentDao();
        
        if (isEdit) {
			if (hasContentApprovalAccess) {
				
				if (localWrapperObj.authoredBy !=null && 
						String.isNotBlank(localWrapperObj.authoredBy.peopleId)) {
					contentObj.Primary_Author__c = localWrapperObj.authoredBy.peopleId;
					fieldList.add(Simpplr_Content__c.Primary_Author__c);
				}

				if (ServiceConstants.CONTENT_STATUS_APPROVED.equalsIgnoreCase(contentObj.Status__c) 
						&& contentObj.Pages_Category__c != oldPageCategoryId) {
					contentObj.Display_Order__c = 1;
					fieldList.add(Simpplr_Content__c.Display_Order__c);

					moveContentToTop(contentObj.id, contentObj.Pages_Category__c);
				}
			}
			if('knowledge'.equalsIgnoreCase(contentObj.Content_Sub_Type__c) && SimpplrContext.isContentGovernanceEnabled==true) {
				setPageValidationTimeToNULL(contentObj, oldpublishStartDatetime);
				fieldList.add(Simpplr_Content__c.Last_Validated_DateTime__c);
			}

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(contentObj, fieldList);

			// enable content notifications for the user
			if(ServiceConstants.CONTENT_STATUS_APPROVED.equalsIgnoreCase(contentObj.Status__c)) {
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

			logger.logDebug('SiteAddPageDataServer.saveContentObjectToDB()----oldAuthorId----' + oldAuthorId);
				
        } else {
			contentObj.Created_DateTime__c = DateTime.now();
			contentObj.CreatedBy_People__c = UserContext.getCurrentUserInfo.Id;
        	contentObj.OwnerId = pageDaoObj.getContentOwnerId('Simpplr_' + SiteContext.chatterGroupId + '_Admin');
        	contentObj.Primary_Author__c = UserContext.getCurrentUserInfo.Id;

			fieldList.add(Simpplr_Content__c.Created_DateTime__c);
			fieldList.add(Simpplr_Content__c.CreatedBy_People__c);
			fieldList.add(Simpplr_Content__c.OwnerId);

			if( ! fieldList.contains(Simpplr_Content__c.Primary_Author__c) ) {
				fieldList.add(Simpplr_Content__c.Primary_Author__c);
			}

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPSFDCAccessControlResults.InsertResults result = SIMPESAPI.accessController().insertAsUser(
					new List<Simpplr_Content__c>{contentObj}, fieldList);

			List<Simpplr_Content__c> listOfContentObj = new List<Simpplr_Content__c>();
			listOfContentObj =(List<Simpplr_Content__c>) result.getInsertedObjects();      
			contentObj = listOfContentObj[0];

			// enable content notifications for the user
			if(ServiceConstants.CONTENT_STATUS_APPROVED.equalsIgnoreCase(contentObj.Status__c)) {
				manageContentDaoObj.insertContentNotificationSettingForUser(contentObj.Id, UserContext.peopleId);
			}
        }

        return contentObj;
    }

	private void setPageValidationTimeToNULL(Simpplr_Content__c contentObj, Datetime oldpublishStartDatetime) {
		List<String> knowledgeContentIdsForNotification = new List<String>();
		Datetime expiry28DaysStartDateTime = DateTime.now().addMonths(- (SimpplrContext.validationPeriodMonth)).addDays(28);
		if(contentObj.Last_Validated_DateTime__c != null && 
			contentObj.Publish_Start_DateTime__c != oldpublishStartDatetime &&
			contentObj.Publish_Start_DateTime__c > contentObj.Last_Validated_DateTime__c &&
			contentObj.Publish_Start_DateTime__c > expiry28DaysStartDateTime) {

			contentObj.Last_Validated_DateTime__c = null;
			knowledgeContentIdsForNotification.add(contentObj.Id);

		} else if(contentObj.Last_Validated_DateTime__c == null &&
			contentObj.Publish_Start_DateTime__c > oldpublishStartDatetime &&
			contentObj.Publish_Start_DateTime__c > expiry28DaysStartDateTime) {
			
			knowledgeContentIdsForNotification.add(contentObj.Id);
		}
		if(knowledgeContentIdsForNotification.size() > 0) {
			Map<String, Object> soqlParamMap = new  Map<String, Object>();
			soqlParamMap.put('soqlParam1', knowledgeContentIdsForNotification);
			String query = 'SELECT Id, Is_Deleted__c FROM App_Notification__c ' +
				' WHERE Content__c = :soqlParam1 AND Category__c = \'Content_For_Review\' AND Type__c = \'Actionable\' ' +
				' AND Action_By__c = null AND Is_Deleted__c = false LIMIT 9000';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<App_Notification__c> notiList = (List<App_Notification__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);

			if(notiList.isEmpty() == false) {
				for(App_Notification__c notiObj : notiList) {
					notiObj.Is_Deleted__c = true;
				}

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<Id,App_Notification__c>(notiList),new List<Schema.SObjectField>{App_Notification__c.Is_Deleted__c});
			}
		}
	}
    
    private void moveContentToTop(String contentId, String pageCategoryId) {
		logger.logDebug('SiteAddPageDataServer.moveContentToTop()---pageCategoryId---' + pageCategoryId);
		List<Simpplr_Content__c> listOfExistingContentInCategory = [SELECT id 
				FROM Simpplr_Content__c 
				WHERE Is_Published__c = true AND Is_Deleted__c = false
				AND Status__c = 'Approved'
				AND Pages_Category__c =: pageCategoryId
				AND Id !=: contentId
				WITH SECURITY_ENFORCED
				ORDER BY Display_Order__c, 
				Publish_Start_DateTime__c DESC, 
				Last_Updated_DateTime__c  DESC, 
				Last_Validated_DateTime__c];
		Integer index = 2;

		for (Simpplr_Content__c simpplrContentObj : listOfExistingContentInCategory) {
			simpplrContentObj.Display_Order__c = index++;
		}

		List<Schema.SObjectField> fieldList = new List<Schema.SObjectField> {
			Simpplr_Content__c.Display_Order__c
		};

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id, Simpplr_Content__c>(listOfExistingContentInCategory), fieldList);
	}
	
	private ResponseWrapper getPageByVersionHistoryId(String contentId, String versionId){
		logger.logDebug('SiteAddPageDataServer.getPageByVersionHistoryId()---data---' + contentId);
    	ResponseWrapper resultWrapper = New ResponseWrapper();
    	String redirectUrl = null;
    	
    	try {
    		String content_LastModifiedTimeStamp = readParam(CONTENT_LASTMODIFIEDDATETIMESTAMP);
    		
    		if (String.valueOf(SimpplrContext.allowedFeatures).containsIgnoreCase(ServiceConstants.TYPE_PAGE) == false) {
	    		throw new SimpplrException(ServiceConstants.ERROR_404);
			}

	    	String query = 'SELECT '+String.join(getContentDetailFieldList(),',') + 
					' FROM Simpplr_Content__c WHERE id=:contentId AND Type__c = \'Page\' ';
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

    			ContentWrapper wrapperObj = getPageHistoryByVersion(contentId, versionId);

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

	public ContentWrapper getPageHistoryByVersion(String contentId, String versionId){
		ContentWrapper wrapperObj  	= New ContentWrapper();
		List<Content_History__c> contentHistoryList = [SELECT Id, Content__c, Content_Json_Part1__c, Content_Json_Part2__c,
														Content_Json_Part3__c, Content_Json_Part4__c, Content_Json_Part5__c,
														File_Json__c, File_Json_Part1__c, File_Json_Part2__c,
														File_Json_Part3__c, Topic_Json__c, Version__c 
														FROM Content_History__c
														WHERE Content__c = :contentId AND Version__c = :Decimal.valueOf(versionId) AND IsDeleted = false WITH SECURITY_ENFORCED ORDER BY Version__c ASC];

		if(!contentHistoryList.isEmpty()){
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
			wrapperObj.lastValidatedAt = Utility.dateTimeToMomentJSDateTime(contentRecord.Last_Validated_DateTime__c);
			wrapperObj.lastMovedAt = Utility.dateTimeToMomentJSDateTime(contentRecord.Last_Moved_DateTime__c);
			wrapperObj.isMustRead 		= false;
			wrapperObj.MustReadDetails = null;
			wrapperObj.imgCaption = contentRecord.Title_Image_Caption__c;
			wrapperObj.isLiked = false;
			wrapperObj.likeCount = Integer.valueOf(contentRecord.Likes__c);
			wrapperObj.isMaximumWidth = contentRecord.Use_Maximum_Screenwidth__c;
			wrapperObj.postCount = contentRecord.Feed_Posts__c == null ? 0 : Integer.valueOf(contentRecord.Feed_Posts__c);
			wrapperObj.questionCount = contentRecord.Feed_Questions__c == null ? 0 : Integer.valueOf(contentRecord.Feed_Questions__c);
			wrapperObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRecord.site__c+'/page/'+contentRecord.Id;
			wrapperObj.editUrl = wrapperObj.url + '/edit';
			if(contentRecord.Text_Json__c!=null) {
				String bodyJsonData = getMergedBodyJson(contentRecord.Text_Json__c, contentRecord.Text_Main_Json__c, contentRecord.Text_Main_Continued_Json__c );
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
			wrapperObj.expiresAt = null;
			wrapperObj.lastDismissedAt = null;
			wrapperObj.listOfTopics = String.isNotBlank(contentHistoryList[0].Topic_Json__c) ? convertToListOfTopicWrapper(contentHistoryList[0].Topic_Json__c) : null;
			wrapperObj.site = getSiteDetails(contentRecord.Site__c);
			
			if (String.isNotBlank(contentRecord.Pages_Category__c)) {

				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', contentRecord.Pages_Category__c);
				String pageCtgryQuery = 'SELECT Id, Name__c FROM Pages_Category__c WHERE Id = :soqlParam1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<Pages_Category__c> pageCategoryList = (List<Pages_Category__c>)SIMPESAPI.accessController().queryAsUser(pageCtgryQuery, soqlParamMap);
				if(!pageCategoryList.isEmpty()){
					
					wrapperObj.category = new CategoryWrapper();
					wrapperObj.category.id = contentRecord.Pages_Category__c;
					wrapperObj.category.categoryId = contentRecord.Pages_Category__c;
					wrapperObj.category.Name = pageCategoryList[0].Name__c;
					wrapperObj.category.url = PageContext.getPageURL(Pages.app) + '?u=/site/' + contentRecord.Site__c  + '/content&pageCategoryId=' + contentRecord.Pages_Category__c;

				} else {
					wrapperObj.category = null;

				}
			}

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

				for (File__c fileObj : fileList) {
					
					if (ServiceConstants.TITLE_IMAGE_TYPE_THUMBNAIL.equalsIgnoreCase(fileObj.Title_Image_Type__c) && 
							fileObj.Is_Title_Image__c) {
						wrapperObj.img = Utility.getFileDownloadURL(fileObj.Content_Version__c);
						wrapperObj.imgFile = convertFileToFileContentWrapper(fileObj);
					
					} else if (ServiceConstants.TITLE_IMAGE_TYPE_WIDESCREEN.equalsIgnoreCase(fileObj.Title_Image_Type__c) && 
							fileObj.Is_Title_Image__c) {
						wrapperObj.imgLandscape = Utility.getFileDownloadURL(fileObj.Content_Version__c);
						wrapperObj.imgLandscapeFile = convertFileToFileContentWrapper(fileObj);
						
					} else if (ServiceConstants.TITLE_IMAGE_TYPE_ORIGINAL.equalsIgnoreCase(fileObj.Title_Image_Type__c) && 
							fileObj.Is_Title_Image__c) {
						wrapperObj.imgOriginal = Utility.getFileDownloadURL(fileObj.Content_Version__c);
						wrapperObj.imgOriginalFile = convertFileToFileContentWrapper(fileObj);
					
					} else if (ServiceConstants.FILE_LOCATION_ATTACHMENT.equalsIgnoreCase(fileObj.Location__c)) {
						wrapperObj.listOfFiles.add(convertFileToFileContentWrapper(fileObj));
					
					} else if (ServiceConstants.FILE_LOCATION_INLINE.equalsIgnoreCase(fileObj.Location__c) && ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(fileObj.Repository__c)) {
						wrapperObj.listOfInlineVideos.add(convertFileToFileContentWrapper(fileObj));
					
					}else if (ServiceConstants.FILE_LOCATION_INLINE.equalsIgnoreCase(fileObj.Location__c)) {
						wrapperObj.listOfInlineImages.add(convertFileToFileContentWrapper(fileObj));
					
					}
		
				}
			}

		}	

		return wrapperObj;
	}

	public Boolean isContentRead(String contentId) {
        Id peopleId = UserContext.peopleId;
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
        soqlParamMap.put('soqlParam1', peopleId);
        soqlParamMap.put('soqlParam2', contentId);
        soqlParamMap.put('soqlParam3', new List<String>{ServiceConstants.CONTENT_STATUS_SITE_ONBOARDING, ServiceConstants.CONTENT_STATUS_ORG_ONBOARDING});
        String query  = 'SELECT Id FROM Content_Interaction__c WHERE People__c =: soqlParam1 AND Content__c =: soqlParam2 AND Content__r.Content_Onboarding_Status__c IN :soqlParam3 AND View_Count__c > 0';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<Content_Interaction__c> readDetails = (List<Content_Interaction__c>) SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
        return readDetails.size() > 0 ? true : false;
	}
	
    private List<Simpplr_Content__c> getPageById(String contentId){
		List<String> pageFieldList = new List<String> { 
			'Use_Maximum_Screenwidth__c',
			'Content_Sub_Type__c',
			'Last_Validated_DateTime__c',
			'Last_Moved_DateTime__c',
			'Language__c',
			'Read_Time__c',
			'(select LastModifiedDate from Content_Audit_Trails__r where Dismiss_By__c !=null order by LastModifiedDate Limit 1)'
		};

		pageFieldList.addAll(getContentDetailFieldList());	
		String query = 'SELECT '+ String.join(pageFieldList, ',') + 
					' FROM Simpplr_Content__c where id=:contentId ';

		List<Simpplr_Content__c> contentObjList = Database.query(query); 

		return contentObjList;
	}
 
    private ResponseWrapper getPage(String contentId) {
    	logger.logDebug('SiteAddPageDataServer.getPage()---data---' + contentId);
    	ResponseWrapper resultWrapper = New ResponseWrapper();
    	String redirectUrl = null;
    	
    	try {
    		String content_LastModifiedTimeStamp = readParam(CONTENT_LASTMODIFIEDDATETIMESTAMP);
    		DateTime lastModifiedDateTimeStamp =  content_LastModifiedTimeStamp != null && 
					content_LastModifiedTimeStamp != '0' ? DateTime.newInstance(long.valueOf(content_LastModifiedTimeStamp)) : null;
    		
    		if (String.valueOf(SimpplrContext.allowedFeatures).containsIgnoreCase(ServiceConstants.TYPE_PAGE) == false) {
	    		throw new SimpplrException(ServiceConstants.ERROR_404);
	    	}

	    	List<Simpplr_Content__c> contentObjList = getPageById(contentId); 
	  
	    	if (contentObjList.size() == 0) {
	    		throw new SimpplrException(ServiceConstants.ERROR_404);
	    	
	    	} else if (contentObjList[0].Site__r.Show_In_Simpplr__c == false) {
	    		redirectUrl = SimpplrContext.salesforceBaseUrl + '/' + 
						contentObjList[0].Site__r.Chatter_Group_Id__c;
	    		throw new SimpplrException(ServiceConstants.ERROR_404);
	    
	    	} else if (lastModifiedDateTimeStamp !=null && 
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
				SiteDao siteDaoObj = new siteDao();
				CollaborationGroup collaborationGroupObj = siteDaoObj.getChatterGroupDetails(contentObjList[0].Site__r.Chatter_Group_Id__c);
				wrapperObj.site.isBroadcast = collaborationGroupObj?.IsBroadcast;

				if ('mobile'.equalsIgnoreCase(readParam('origin'))) {
					wrapperObj.isFeedEnabled = SimpplrContext.isCommentsAllowed && 
							contentObjList[0].Site__r.Allow_Comments__c && 
							wrapperObj.isFeedEnabled;
					if(String.isNotBlank(wrapperObj.body) && wrapperObj.body.containsIgnoreCase('<iframe') && !Test.isRunningTest()){
						wrapperObj.body = Utility.getUpdatedMobileWapperBody(wrapperObj.body);
					}
					Utility.insertMobileAnalyticsRecord('PageDetail', 
							new Map<String, String>{'siteId'=>wrapperObj.site.siteId, 
							'contentId'=>contentId, 
							'userAgent' => readHeader('User-Agent')});
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
    
    private Boolean checkSiteAvailabilityInSimpplr(String siteId) {
    	List<Simpplr_Site__c> siteList = [SELECT Id, Show_In_Simpplr__c 
				FROM Simpplr_Site__c WHERE Id = :siteId WITH SECURITY_ENFORCED];
    	
    	if ( !siteList.isEmpty() && siteList[0].Show_In_Simpplr__c == true) {
    		return true;

    	} else {
    		return false;
    	}

    }
    
    @testVisible 
	private ContentWrapper convertToContentWrapper (Simpplr_Content__c contentRecord) {
		logger.logDebug('SiteAddPageDataServer.convertToContentWrapper()---contentRecord---' + contentRecord);
    	Set<Id> sitesIManageIdSet = UserContext.sitesIManageIdSet;
		ContentWrapper wrapperObj  	= New ContentWrapper();
		wrapperObj.id = contentRecord.id;
		wrapperObj.isLatest = true;
		wrapperObj.versionId = contentRecord.Version__c;
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
		wrapperObj.language = contentRecord.Language__c;
		wrapperObj.lastValidatedAt = Utility.dateTimeToMomentJSDateTime(contentRecord.Last_Validated_DateTime__c);
		wrapperObj.lastMovedAt = Utility.dateTimeToMomentJSDateTime(contentRecord.Last_Moved_DateTime__c);
		wrapperObj.readTime = contentRecord.Read_Time__c != null ? Integer.valueOf(contentRecord.Read_Time__c) : null;
		Map<Id, Site_Role__c> mapofSiteIdAndSiteRole = new Map<Id, Site_Role__c>();
		mapofSiteIdAndSiteRole = UserContext.mySiteRolesMap;
		if (contentRecord.Must_Read_Audits__r != null  && contentRecord.Must_Read_Audits__r.isEmpty() == false) {
			List<Must_Read_Audit__c> mustReadAudList = contentRecord.Must_Read_Audits__r;

			if ((mustReadAudList[0].Expiry_DateTime__c == null || 
					mustReadAudList[0].Expiry_DateTime__c>DateTime.now()) && 
					mustReadAudList[0].Removed_DateTime__c == null) {
				if(mustReadAudList[0].Audience_Type__c == 'site_members') {
					Site_Role__c siteRoleForContentSite = mapofSiteIdAndSiteRole.get(contentRecord.Site__c);
					if(siteRoleForContentSite != null && siteRoleForContentSite.Is_Member__c == true) {
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
			wrapperObj.isMustRead 		= false;
			wrapperObj.MustReadDetails = null;
		}

        wrapperObj.imgCaption = contentRecord.Title_Image_Caption__c;
        wrapperObj.isLiked = contentRecord.Likes_Simpplr_Content__r.isEmpty() ? false : true;
        wrapperObj.likeCount = Integer.valueOf(contentRecord.Likes__c);
		wrapperObj.isMaximumWidth = contentRecord.Use_Maximum_Screenwidth__c;
		wrapperObj.postCount = contentRecord.Feed_Posts__c == null ? 0 : Integer.valueOf(contentRecord.Feed_Posts__c);
		wrapperObj.questionCount = contentRecord.Feed_Questions__c == null ? 0 : Integer.valueOf(contentRecord.Feed_Questions__c);
        wrapperObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRecord.site__c+'/page/'+contentRecord.Id;
        wrapperObj.editUrl = wrapperObj.url + '/edit';
		if(String.isNotBlank(contentRecord.Text_Json__c)) {
			String bodyJsonData = getMergedBodyJson(contentRecord.Text_Json__c, contentRecord.Text_Main_Json__c, contentRecord.Text_Main_Continued_Json__c );
			wrapperObj.bodyJson = (TipTapBodyWrapper)JSON.deserialize(bodyJsonData, TipTapBodyWrapper.class);
		} 
		wrapperObj.body = (String.isNotBlank(contentRecord.Text_Intro__c) ? 
							contentRecord.Text_Intro__c : '') +
							(String.isNotBlank(contentRecord.Text_Main__c) ? contentRecord.Text_Main__c : '') +
							(String.isNotBlank(contentRecord.Text_Main_Continued__c) ? 
							contentRecord.Text_Main_Continued__c : '');
		
        wrapperObj.isFavorited = !contentRecord.Bookmarked_Content__r.isEmpty();
        wrapperObj.isOpenToNotification = !contentRecord.Content_Notification_Setting__r.isEmpty();
        wrapperObj.favoriteContext = contentRecord.Type__c;
        wrapperObj.site = new SiteLiteWrapper();
        wrapperObj.site.siteId = contentRecord.Site__c;
        wrapperObj.site.name = contentRecord.Site__r.name;
        wrapperObj.site.img	= String.isBlank(contentRecord.Site__r.Title_Content_Version__c)? null :Utility.getFileDownloadURLFor720By480(contentRecord.Site__r.Title_Content_Version__c);
        wrapperObj.site.imgThumbnail = String.isBlank(contentRecord.Site__r.Title_Content_Version__c)? null :Utility.getFileDownloadURLFor120BY90(contentRecord.Site__r.Title_Content_Version__c);
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
		logger.logDebug('SimpplrContext.isSegmentsEnabled ' +SimpplrContext.isSegmentsEnabled);
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
	    
		if (SimpplrContext.validationPeriodMonth != null && 
				ServiceConstants.CONTENT_SUB_TYPE_KNOWLEDGE.equalsIgnoreCase(contentRecord.Content_Sub_Type__c)) { 
			DateTime expiresAtDateTime = contentRecord.Publish_Start_DateTime__c;							
			
			if (contentRecord.Last_Validated_DateTime__c != null && 
					expiresAtDateTime < contentRecord.Last_Validated_DateTime__c) {
				expiresAtDateTime = contentRecord.Last_Validated_DateTime__c;
			}

			expiresAtDateTime = expiresAtDateTime.addMonths(SimpplrContext.validationPeriodMonth);
			
			wrapperObj.expiresAt = Utility.dateTimeToMomentJSDateTime(expiresAtDateTime);
			
			if (!contentRecord.Content_Audit_Trails__r.isEmpty()) {
				wrapperObj.lastDismissedAt = Utility.dateTimeToMomentJSDateTime(contentRecord.Content_Audit_Trails__r[0].LastModifiedDate);
			}

		}	

        wrapperObj.authoredBy.Id = contentRecord.Primary_Author__c;
        wrapperObj.authoredBy.sfUserId = contentRecord.Primary_Author__r.User__r.Id;
        wrapperObj.authoredBy.peopleId = contentRecord.Primary_Author__c;
        wrapperObj.authoredBy.name = contentRecord.Primary_Author__r.Full_Name__c;
        wrapperObj.authoredBy.img = Utility.getProfilePhotoURL(contentRecord.Primary_Author__r.User__r.FullPhotoURL);
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
		
    	wrapperObj.canPublishUnpublish = AccessManager.calculatePublishUnpublishAccess(wrapperObj.site.isManager, wrapperObj.site.isContentManager,
				wrapperObj.status, wrapperObj.authoredBy.sfUserId, wrapperObj.site.access);
        wrapperObj.canModerate = AccessManager.calculateModerateAccess(wrapperObj.site.isManager, wrapperObj.site.isContentManager,
				wrapperObj.status, wrapperObj.authoredBy.sfUserId, wrapperObj.site.access);
        wrapperObj.canDelete = AccessManager.calculateDeleteAccess(wrapperObj.site.isManager, wrapperObj.site.isContentManager,
				wrapperObj.status, wrapperObj.authoredBy.sfUserId, wrapperObj.site.access);
        wrapperObj.canEdit = AccessManager.calculateEditAccess(wrapperObj.site.isManager, wrapperObj.site.isContentManager,
				wrapperObj.status, wrapperObj.authoredBy.sfUserId, wrapperObj.site.access);
		wrapperObj.canSendUpdateNotification = wrapperObj.canEdit;
		wrapperObj.canMakeMustRead = AccessManager.calculateCanMakeMustRead(wrapperObj.type, wrapperObj.isPublished, wrapperObj.site.access, 
				contentRecord.Site__r.Is_Must_Read_Enabled__c, wrapperObj.site.isManager, wrapperObj.site.isContentManager);
		if(SimpplrContext.isFeatureContentOnboardingEnabled) {
            wrapperObj.canManageOnboardingContent = AccessManager.calculateCanManageOnboarding(wrapperObj.isPublished, contentRecord.Site__c, contentRecord.Site__r.Is_Onboarding_Enabled__c, wrapperObj.site.isFeatured);
            wrapperObj.onboardingStatus = contentRecord.Content_Onboarding_Status__c;
            wrapperObj.isContentRead = isContentRead(contentRecord.Id);
        } else {
            wrapperObj.canManageOnboardingContent = false;
            wrapperObj.onboardingStatus = ServiceConstants.CONTENT_STATUS_NOT_ONBOARDING;
            wrapperObj.isContentRead = false;
        }
		wrapperObj.usefulContent.canViewHistory = wrapperObj.canPublishUnpublish;

	    if (contentRecord.Simpplr_Content_Feedback__r.isEmpty()) {
	    	wrapperObj.usefulContent.hasUserRated = false;
	    
		} else {
	    	wrapperObj.usefulContent.hasUserRated = true;
	    	wrapperObj.usefulContent.hasUserRatedUseful	= contentRecord.Simpplr_Content_Feedback__r[0].Was_Content_Useful__c;
	    }
	    	
        if (String.isNotBlank(contentRecord.Pages_Category__c)) {
	        wrapperObj.category = new CategoryWrapper();
	        wrapperObj.category.id = contentRecord.Pages_Category__c;
	        wrapperObj.category.categoryId = contentRecord.Pages_Category__c;
	        wrapperObj.category.Name = contentRecord.Pages_Category__r.Name__c;
	        wrapperObj.category.url = PageContext.getPageURL(Pages.app) + '?u=/site/' + contentRecord.Site__c  + '/content&pageCategoryId=' + contentRecord.Pages_Category__c;
        }
        
    	wrapperObj.listOfTopics = convertToListOfTopicWrapper(contentRecord.Id, 
				PageContext.getPageURL(Pages.app));
    	wrapperObj.recentViewCount = getViewCountInLast30Days(contentRecord.Id);
		List<File__c> fileList = getFilesByContentId(contentRecord.Id);

		for (File__c fileObj : fileList) {
			
			if (ServiceConstants.TITLE_IMAGE_TYPE_THUMBNAIL.equalsIgnoreCase(fileObj.Title_Image_Type__c) && 
					fileObj.Is_Title_Image__c) {
				wrapperObj.img = Utility.getFileDownloadURL(fileObj.Content_Version__c);
    			wrapperObj.imgFile = convertFileToFileContentWrapper(fileObj);
    		
    		} else if (ServiceConstants.TITLE_IMAGE_TYPE_WIDESCREEN.equalsIgnoreCase(fileObj.Title_Image_Type__c) && 
					fileObj.Is_Title_Image__c) {
    			wrapperObj.imgLandscape = Utility.getFileDownloadURL(fileObj.Content_Version__c);
    			wrapperObj.imgLandscapeFile = convertFileToFileContentWrapper(fileObj);
    			
    		} else if (ServiceConstants.TITLE_IMAGE_TYPE_ORIGINAL.equalsIgnoreCase(fileObj.Title_Image_Type__c) && 
					fileObj.Is_Title_Image__c) {
    			wrapperObj.imgOriginal = Utility.getFileDownloadURL(fileObj.Content_Version__c);
    			wrapperObj.imgOriginalFile = convertFileToFileContentWrapper(fileObj);
    		
    		} else if (ServiceConstants.FILE_LOCATION_ATTACHMENT.equalsIgnoreCase(fileObj.Location__c)) {
    			wrapperObj.listOfFiles.add(convertFileToFileContentWrapper(fileObj));
    		
			} else if (ServiceConstants.FILE_LOCATION_INLINE.equalsIgnoreCase(fileObj.Location__c) && ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(fileObj.Repository__c)) {
    			wrapperObj.listOfInlineVideos.add(convertFileToFileContentWrapper(fileObj));
			
			}else if (ServiceConstants.FILE_LOCATION_INLINE.equalsIgnoreCase(fileObj.Location__c)) {
    			wrapperObj.listOfInlineImages.add(convertFileToFileContentWrapper(fileObj));
			
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
		wrapperObj.authoredBy.isProtectedAuthor = contentRecord.Primary_Author__r.Is_Protected_Author__c;
		if(ServiceConstants.CONTENT_STATUS_REJECTED.equalsIgnoreCase(wrapperObj.status)) {
			wrapperObj.rejectionDetails = getRejectionComment(wrapperObj.id);
		}
        
    	return wrapperObj;
    }

}