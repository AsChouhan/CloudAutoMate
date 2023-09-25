/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class ProfileAddBlogPostDataServer extends ContentDataServer{
	public transient final String STR_ERROR_ONLY_INFLUENCERS_CREATE_BLOG { get { return labelMap.get('content.only_influencers_create_blogs_error_flash');}}
    private BlogDao blogDaoObj;
    private final String ACTION_VALUE_PUBLISH = 'publish';
    private final String ACTION_VALUE_DRAFT = 'saveDraft';
    private final String ACTION_VALUE_UPDATE_DRAFT = 'updateDraft';
    private final String ACTION_VALUE_UPDATE = 'update';
    private final String ACTION_VALUE_GET = 'get';
    private final String REQUEST_PARAM_DATA = 'data';
    private final String CONTENT_LASTMODIFIEDDATETIMESTAMP = 'lastModifiedDateTimeStamp';
    private DateTime currentDateTime = DateTime.now();
    
    public ProfileAddBlogPostDataServer() {
		blogDaoObj = new BlogDao();
    }

	public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
    public override void handleRequest() {
    	
        try {
        	logger.logDebug('ProfileAddBlogPostDataServer.handleRequest()----Start----');

            String action = readParam(REQUEST_PARAM_ACTION);
            String requestData = readParam(REQUEST_PARAM_DATA);
            
            if (String.isBlank(requestData) && !ACTION_VALUE_GET.equalsIgnoreCase(action)) {
	            throw new SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
	        } 
            
            if (ACTION_VALUE_GET.equalsIgnoreCase(action)) {
            		response = getContent(readParam('contentId'));
            		
            } else {

                if (SimpplrContext.isOnlyInfluencersAllowedToCreateBlog && 
                        UserContext.getCurrentUserInfo.Is_Influencer__c == false) {
                    throw New SimpplrException(STR_ERROR_ONLY_INFLUENCERS_CREATE_BLOG);
                }

                Utility.isContentEditFromContentDetailPage = true;
                
                if (ACTION_VALUE_PUBLISH.equalsIgnoreCase(action)) {
                    response = publish(readParam(REQUEST_PARAM_DATA));
                    
                } else if (ACTION_VALUE_DRAFT.equalsIgnoreCase(action)) { 
                    response = draft(readParam(REQUEST_PARAM_DATA));
                
                } else if (ACTION_VALUE_UPDATE_DRAFT.equalsIgnoreCase(action)) {
                    response = updateDraft(requestData);
                        
                } else if (ACTION_VALUE_UPDATE.equalsIgnoreCase(action)) {
                        response = updateBlogPost(readParam(REQUEST_PARAM_DATA));
                
                } else {
                    throw new SimpplrException(ServiceConstants.ERROR_404);
                }

            }
            
        } catch (Exception ex) {
        	logger.logError('ProfileAddBlogPostDataServer.handleRequest()---Exception occured----', ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR,MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        
    }

    private ResponseWrapper publish(String data) {
        ResponseWrapper resultObj = processContentData(data, ServiceConstants.CONTENT_STATUS_APPROVED);
        
        if (resultObj.status == RESPONSE_STATUS_SUCCESS)  {
			ContentWrapper contWrapObj = new ContentWrapper();
			contWrapObj = ((ContentWrapper)(resultObj.result));

            if (contWrapObj.isPublished && !Test.isRunningTest()) {
                FeedServiceProvider.createTimeLine(null, contWrapObj.id, contWrapObj.url, 
					contWrapObj.title, '');
            }
			
		}

        return resultObj;
    }
    
    private ResponseWrapper updateBlogPost(String data) {
        ContentWrapper localContWrapObj = ContentWrapper.parse(data);
        String contentId = localContWrapObj.id == null ? readParam('contentId') : localContWrapObj.id;
        Boolean isContentPublishedBeforeUpdate = isContentPublished(contentId);
        ResponseWrapper resultObj = processContentData(data, ServiceConstants.CONTENT_STATUS_APPROVED);
        
        if (resultObj.status == RESPONSE_STATUS_SUCCESS)  {
			ContentWrapper contWrapObj = new ContentWrapper();
			contWrapObj = ((ContentWrapper)(resultObj.result));

            if (!Test.isRunningTest() && !isContentPublishedBeforeUpdate  && 
                    contWrapObj.isPublished && !isTimeLineCreatedForContent(contWrapObj.id)) { 
			    FeedServiceProvider.createTimeLine(null, contWrapObj.id, contWrapObj.url, 
					    contWrapObj.title, '');
            }
            
        }

        return resultObj;
    }
    
    private ResponseWrapper draft(String data) {
        ResponseWrapper result = processContentData(data,ServiceConstants.CONTENT_STATUS_DRAFT);
        return result;
    }
    
	private ResponseWrapper updateDraft(String data) {
        ResponseWrapper result = processContentData(data, ServiceConstants.CONTENT_STATUS_DRAFT);
        return result;
    }
    
    private Simpplr_Content__c saveContentObjectToDB (Boolean isEdit, 
            ContentWrapper localWrapperObj, Map<String, String> mapOfNewTopics) {
        Simpplr_Content__c contentObj;
        String oldAuthorId;
        String oldStatus;

        if (isEdit) {
            contentObj = [SELECT id, Type__c, status__c, Primary_Author__c, 
                    Primary_Author__r.User__c, Primary_Author__r.Is_Protected_Author__c,   
                    Publish_Start_DateTime__c, Is_Published__c, Read_Time__c, Text_Json__c, Text_Main_Json__c, Text_Main_Continued_Json__c
            	    FROM Simpplr_Content__c 
            		WHERE id =: localWrapperObj.id 
            		And Type__c =: ServiceConstants.TYPE_BLOGPOST WITH SECURITY_ENFORCED];  
            oldStatus = contentObj.status__c;
            String status = getContentStatus(contentObj.Status__c, contentObj.Is_Published__c);  

            if (!AccessManager.calculateBlogEditAccess(contentObj.Primary_Author__r.User__c, status)) {
                throw new SimpplrException(ServiceConstants.ERROR_403);
                
            } else if(contentObj.Primary_Author__r.Is_Protected_Author__c && 
                        (!UserContext.peopleId.equalsIgnoreCase(contentObj.Primary_Author__c) && 
                        !UserContext.isProtectedAuthorAllowlisted && 
                        !UserContext.isUserAppModerator)) {
                throw new SimpplrException(ServiceConstants.ERROR_403);
            }
             
        } else {

            Utility.checkForRateLimit('content');
                        
            contentObj = New Simpplr_Content__c();
            contentObj.Type__c = ServiceConstants.TYPE_BLOGPOST;
        }
        
        contentObj.Title__c = localWrapperObj.title;
        if(localWrapperObj.bodyJson!=null){
            List<String> contentBodyJsonParts = getContentJsonBodyParts(JSON.serialize(localWrapperObj.bodyJson,true), mapOfNewTopics);
			contentObj.Text_Json__c =  contentBodyJsonParts[0];
			contentObj.Text_Main_Json__c =  contentBodyJsonParts[1];
			contentObj.Text_Main_Continued_Json__c =  contentBodyJsonParts[2];	
		}
        List<String> contentBodyParts = getContentBodyParts(localWrapperObj.body, mapOfNewTopics);
        contentObj.Text_Intro__c = contentBodyParts[0];
        contentObj.Text_Main__c = contentBodyParts[1];
        contentObj.Text_Main_Continued__c = contentBodyParts[2];
        contentObj.Excerpt__c = Utility.getPlainText(contentObj.Text_Intro__c, 250, true);
        contentObj.Summary_1__c	= String.valueOf(String.isEmpty(localWrapperObj.summary) 
                ? '' : localWrapperObj.summary.unescapeHtml4()).replace('&#8203;','');
    
        contentObj.Title_Image_Caption__c = localWrapperObj.imgCaption;
        contentObj.Display_Excerpt__c = Utility.getDisplayExcerpt(contentObj.Excerpt__c,contentObj.Summary_1__c);
        Boolean isUpdateMode = false;

		if (ACTION_VALUE_UPDATE.equalsIgnoreCase(localWrapperObj.status)) {
			isUpdateMode = true;

		} else {
			contentObj.Status__c = localWrapperObj.status;
		}
       		
        if (String.isNotBlank(localWrapperObj.publishAt)) {
            // publishAt => 2022-07-04T00:00:00 from UI	
			contentObj.Publish_Start_DateTime__c = Utility.momentJSDateTimeStringToDateTime(localWrapperObj.publishAt);
        } else if (isUpdateMode == false) {
            throw new SimpplrException(ExceptionCode.EMPTY_PUBLISH_START_DATE.name());
        }
        if(localWrapperObj.readTime != null){
			contentObj.Read_Time__c = localWrapperObj.readTime;
		}
        contentObj.Publish_End_DateTime__c = String.isNotBlank(localWrapperObj.publishTo)?Utility.momentJSDateTimeStringToDateTime(localWrapperObj.publishTo):null;
        contentObj.Last_Edited_DateTime__c = DateTime.now();
        contentObj.Last_Updated_DateTime__c = DateTime.now();
		contentObj.Last_UpdatedBy_People__c = UserContext.getCurrentUserInfo.Id;
        contentObj.Allow_comments__c = localWrapperObj.isFeedEnabled == true ? true : false;
        contentObj.Use_Maximum_Screenwidth__c = localWrapperObj.isMaximumWidth == true ? true : false;
        contentObj.Cover_Image_Layout__c = localWrapperObj.imgLayout;
        
        ManageContentDao manageContentDaoObj = new ManageContentDao();
        if (isEdit) {
        	oldAuthorId = String.valueOf(contentObj.Primary_Author__c);
	        
            if (UserContext.isUserAppModerator && localWrapperObj.authoredBy !=null && 
                    String.isNotBlank(localWrapperObj.authoredBy.peopleId)) {
	            contentObj.Primary_Author__c = localWrapperObj.authoredBy.peopleId;
	        }

            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(contentObj, new List<Schema.SObjectField>{
                Simpplr_Content__c.Title__c,
                Simpplr_Content__c.Text_Json__c, 
                Simpplr_Content__c.Text_Main_Json__c,
                Simpplr_Content__c.Text_Main_Continued_Json__c,
                Simpplr_Content__c.Text_Intro__c, 
                Simpplr_Content__c.Text_Main__c, 
                Simpplr_Content__c.Text_Main_Continued__c, 
                Simpplr_Content__c.Excerpt__c, 
                Simpplr_Content__c.Summary_1__c, 
                Simpplr_Content__c.Title_Image_Caption__c, 
                Simpplr_Content__c.Display_Excerpt__c, 
                Simpplr_Content__c.Status__c, 
                Simpplr_Content__c.Publish_Start_DateTime__c, 
                Simpplr_Content__c.Read_Time__c, 
                Simpplr_Content__c.Publish_End_DateTime__c, 
                Simpplr_Content__c.Last_Edited_DateTime__c, 
                Simpplr_Content__c.Last_Updated_DateTime__c, 
                Simpplr_Content__c.Last_UpdatedBy_People__c, 
                Simpplr_Content__c.Allow_comments__c, 
                Simpplr_Content__c.Use_Maximum_Screenwidth__c, 
                Simpplr_Content__c.Cover_Image_Layout__c, 
                Simpplr_Content__c.Primary_Author__c
            });

            if (localWrapperObj.authoredBy != null) {
                if(ServiceConstants.CONTENT_STATUS_DRAFT.equalsIgnoreCase(oldStatus) && ServiceConstants.CONTENT_STATUS_APPROVED.equalsIgnoreCase(contentObj.Status__c)) {
                    sendNotificationForPublishedOnYourBehalf(localWrapperObj.authoredBy.peopleId, contentObj);
                    
                } else if(localWrapperObj.authoredBy.peopleId != oldAuthorId) {
                    sendNotificationOnAuthorChange(oldAuthorId, localWrapperObj.authoredBy.peopleId, contentObj);

                }
			}
			

            if(ServiceConstants.CONTENT_STATUS_APPROVED.equalsIgnoreCase(contentObj.Status__c)) {
				Content_Notification_Setting__c contentNotiSettingObj = manageContentDaoObj.getNotificationSetting(contentObj.Id, UserContext.peopleId);

				if(contentNotiSettingObj == null) {
					manageContentDaoObj.insertContentNotificationSettingForUser(contentObj.Id, UserContext.peopleId);
				}
			}
        
        } else {
            contentObj.Created_DateTime__c = DateTime.now();
			contentObj.CreatedBy_People__c = UserContext.getCurrentUserInfo.Id;
        	contentObj.Primary_Author__c = UserContext.getCurrentUserInfo.Id;
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPSFDCAccessControlResults.InsertResults result = SIMPESAPI.accessController().insertAsUser(
					new List<Simpplr_Content__c>{contentObj},
					new List<Schema.SObjectField>{
					Simpplr_Content__c.Primary_Author__c,
					Simpplr_Content__c.Cover_Image_Layout__c,
                    Simpplr_Content__c.Use_Maximum_Screenwidth__c,
                    Simpplr_Content__c.Allow_comments__c,
                    Simpplr_Content__c.Last_Edited_DateTime__c,
                    Simpplr_Content__c.Publish_End_DateTime__c,
                    Simpplr_Content__c.Publish_Start_DateTime__c,
                    Simpplr_Content__c.Status__c,
                    Simpplr_Content__c.Title_Image_Caption__c,
                    Simpplr_Content__c.Summary_1__c,
                    Simpplr_Content__c.Excerpt__c,
                    Simpplr_Content__c.Text_Main_Continued__c,
                    Simpplr_Content__c.Text_Main__c,
                    Simpplr_Content__c.Text_Intro__c,
                    Simpplr_Content__c.Text_Json__c,
                    Simpplr_Content__c.Title__c,
                    Simpplr_Content__c.Type__c,
                    Simpplr_Content__c.Read_Time__c,
                    Simpplr_Content__c.Last_Updated_DateTime__c,
					Simpplr_Content__c.Last_UpdatedBy_People__c, 
					Simpplr_Content__c.Created_DateTime__c, 
					Simpplr_Content__c.CreatedBy_People__c
					});
			List<Simpplr_Content__c> listOfContentObj = new List<Simpplr_Content__c>();
			listOfContentObj =(List<Simpplr_Content__c>) result.getInsertedObjects();  
			contentObj = listOfContentObj[0];

            if(ServiceConstants.CONTENT_STATUS_APPROVED.equalsIgnoreCase(contentObj.Status__c)) {
        		manageContentDaoObj.insertContentNotificationSettingForUser(contentObj.Id, UserContext.peopleId);		
			}

        }
        
        return contentObj;
    }

    private ResponseWrapper processContentData(String data,String status){
    	logger.logDebug('ProfileAddBlogPostDataServer.processContentData()----status----'+status);
        ContentWrapper wrapperObj = ContentWrapper.parse(data);
        wrapperObj.status  = status ;
        Savepoint sp;
		ResponseWrapper result;
		try{
            //sanitize content data before savepoint
            if(wrapperObj.bodyJson!=null) {
				String sanitizedHTML = Utility.getSanitizedHTMLfromLambda(wrapperObj.body);
				wrapperObj.body = sanitizedHTML;
			}
            sp = Database.setSavepoint();

            // Step 1: Create new Topics
            Map<String, String> mapOfNewTopics = createNewTopics(wrapperObj.listOfTopics, 
                    wrapperObj.listOfContentTopicIds);
            
            // Step 2: Save Simpplr_Content__c record
            ContentTriggerHandler.isCalledFromEditContentScreen = true;
            wrapperObj.id = wrapperObj.id == null ? readParam('contentId') : wrapperObj.id;
            Boolean isEdit = String.isNotBlank(wrapperObj.id);
            Simpplr_Content__c contentObj = saveContentObjectToDB(isEdit, wrapperObj, mapOfNewTopics);
            
            // Step 3: Save File__c records
            saveContentFilesToDB(isEdit, contentObj.id, wrapperObj, status);
            
            // Step 4: Save TopicAssignment records
            saveTopicAssignmentsToDB(isEdit, contentObj.id, 
                    wrapperObj.listOfTopics, wrapperObj.listOfContentTopicIds, mapOfNewTopics);
            
            if (SimpplrContext.isExternalSearchAppConnected) {
                insertSearchTrailObjectForContent(contentObj.id);
            }
            
            result = getContent(contentObj.Id);
        }catch(Exception ex) {
            logger.logError('ProfileAddBlogPostDataServer.processContentData()---Exception occured----', ex);
			if(sp!=null){
				Database.rollback(sp);
			}
            result = buildResponseWrapper(RESPONSE_STATUS_ERROR, 
					MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        return result;
    }

	@TestVisible 
    public ResponseWrapper getContent(String contentId) {
    	logger.logDebug('ProfileAddBlogPostDataServer.getContent()---data---' + contentId);
    	ResponseWrapper resultWrapper = new ResponseWrapper();

    	try {
    		String loggedInPeopleId = UserContext.peopleId;
    		String content_LastModifiedTimeStamp = readParam(CONTENT_LASTMODIFIEDDATETIMESTAMP);
    		DateTime lastModifiedDateTimeStamp =  content_LastModifiedTimeStamp != null && content_LastModifiedTimeStamp != '0' ? DateTime.newInstance(long.valueOf(content_LastModifiedTimeStamp)) : null;
    		
    		if (String.valueOf(SimpplrContext.allowedFeatures).containsIgnoreCase('Blog') == false) {
    			throw new SimpplrException(ServiceConstants.ERROR_404);
    		}

    		List<String> blogFieldList = new List<String> {
    			'Use_Maximum_Screenwidth__c',
                'Read_Time__c'
		    };
		    blogFieldList.addAll(getContentDetailFieldList());	
	    	String query = 'SELECT ' + String.join(blogFieldList,',') + 
                    ' FROM Simpplr_Content__c where id=:contentId ';
	    	List<Simpplr_Content__c> contentObjList = Database.query(query); 
	    	
	    	if (contentObjList.size() == 0) {
	    		throw new SimpplrException(ServiceConstants.ERROR_404);
	    	
	    	} else if (contentObjList[0].Is_Deleted__c || 
                    (contentObjList[0].Activated_By_Feature__c == false)) {
	    		throw new SimpplrException(ServiceConstants.ERROR_404);
	    
	    	} else if (lastModifiedDateTimeStamp != null && 
                    contentObjList[0].Last_Updated_DateTime__c == lastModifiedDateTimeStamp) {
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Content data Not changed!', null);

	    	} else if ('mobile'.equalsIgnoreCase(readParam('origin')) && 
                    !contentObjList[0].Is_Published__c) {
    			throw new SimpplrException(ServiceConstants.ERROR_404);
    		
    		} else if (AccessManager.calculateContentViewAccess(contentObjList[0].Type__c, 
                    contentObjList[0].Is_Published__c, contentObjList[0].Site__c, 
                    contentObjList[0].Site__r.Site_Type__c, contentObjList[0].Status__c, 
                    contentObjList[0].Primary_Author__r.User__c)) {
				ContentWrapper wrapperObj = convertToContentWrapper(contentObjList[0]);

				if ('mobile'.equalsIgnoreCase(readParam('origin'))) {
					wrapperObj.isFeedEnabled = SimpplrContext.isCommentsAllowed && 
                            wrapperObj.isFeedEnabled;
                    if(String.isNotBlank(wrapperObj.body) && wrapperObj.body.containsIgnoreCase('<iframe') ){
                        wrapperObj.body = Utility.getUpdatedMobileWapperBody(wrapperObj.body);
                    }
	        		Utility.insertMobileAnalyticsRecord('BlogDetail', 
                            new Map<String,String>{'contentId'=>contentId, 
                            'userAgent'=>readHeader('User-Agent')});
                }

				resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null , wrapperObj);
		
		    } else {
			    throw new SimpplrException(ServiceConstants.ERROR_404);
		
		    }

    	} catch (exception e){
    		logger.logError('ProfileAddBlogPostDataServer.getContent() Exception Details', e);
        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, e.getMessage(), null);
        }

        return resultWrapper;
    }
    
	@TestVisible 
    private ContentWrapper convertToContentWrapper(Simpplr_Content__c contentRecord) {
        Set<Id> sitesIManageIdSet = UserContext.sitesIManageIdSet;
        ContentWrapper wrapperObj = new ContentWrapper();
        wrapperObj.id = contentRecord.id;
        wrapperObj.contentId = contentRecord.id;
        wrapperObj.contentBodyUrl = PageContext.getPageURL(Pages.ContentBody) + 
                '?contentId='+contentRecord.id;
        wrapperObj.title = Utility.getAllValidWords(contentRecord.Title__c, 
                contentRecord.Title__c.length(), false);
        wrapperObj.type = contentRecord.Type__c.toLowerCase();
       	wrapperObj.excerpt = String.isBlank(contentRecord.Display_Excerpt__c) ? 
                '' : contentRecord.Display_Excerpt__c.unescapeHtml4();
		wrapperObj.summary = String.isBlank(contentRecord.Summary_1__c) ? 
                '' : contentRecord.Summary_1__c.unescapeHtml4();
        wrapperObj.isPublished = contentRecord.Is_Published__c;
        wrapperObj.status = getContentStatus(contentRecord.Status__c, 
                contentRecord.Is_Published__c);
        wrapperObj.isScheduled = checkIfContentScheduled(wrapperObj.status, contentRecord.Publish_Start_DateTime__c);
        wrapperObj.isFeedEnabled = contentRecord.Allow_comments__c;
        wrapperObj.imgLayout = contentRecord.Cover_Image_Layout__c;
        
        if (contentRecord.Must_Read_Audits__r != null && contentRecord.Must_Read_Audits__r.isEmpty() == false) {
			List<Must_Read_Audit__c> mustReadAudList = contentRecord.Must_Read_Audits__r;

			if ((mustReadAudList[0].Expiry_DateTime__c == null || 
                    mustReadAudList[0].Expiry_DateTime__c > DateTime.now()) && 
                    mustReadAudList[0].Removed_DateTime__c == null) {
				wrapperObj.isMustRead = true;

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
        wrapperObj.isMaximumWidth = contentRecord.Use_Maximum_Screenwidth__c;
        wrapperObj.postCount = contentRecord.Feed_Posts__c == null ? 0 : 
                Integer.valueOf(contentRecord.Feed_Posts__c);
        wrapperObj.url = PageContext.getPageURL(Pages.app) + 
                '?u=/people/' + contentRecord.Primary_Author__c + '/blog/'+ contentRecord.id;                                          
        wrapperObj.editUrl = wrapperObj.url + '/edit';
        if(String.isNotBlank(contentRecord.Text_Json__c)) {
            String bodyJsonData = getMergedBodyJson(contentRecord.Text_Json__c, contentRecord.Text_Main_Json__c, contentRecord.Text_Main_Continued_Json__c );
			wrapperObj.bodyJson = (TipTapBodyWrapper)JSON.deserialize(bodyJsonData, TipTapBodyWrapper.class);
        } 
        wrapperObj.shouldUseNewEditor = false;
        wrapperObj.body	= (String.isNotBlank(contentRecord.Text_Intro__c) ? 
                contentRecord.Text_Intro__c : '') +
                (String.isNotBlank(contentRecord.Text_Main__c) ? contentRecord.Text_Main__c : '') +
                (String.isNotBlank(contentRecord.Text_Main_Continued__c) ? 
                contentRecord.Text_Main_Continued__c : '');
    
        wrapperObj.isFavorited = !contentRecord.Bookmarked_Content__r.isEmpty();
        wrapperObj.favoriteContext = contentRecord.Type__c;
        wrapperObj.hasRead = !contentRecord.Must_Read_Confirm_History__r.isEmpty();
        wrapperObj.readAt = wrapperObj.hasRead ? 
                Utility.dateTimeToMomentJSDateTime(contentRecord.Must_Read_Confirm_History__r[0].Confirm_DateTime__c):null;
        wrapperObj.modifiedAt = Utility.dateTimeToMomentJSDateTime(contentRecord.Last_Updated_DateTime__c);
        wrapperObj.publishAt = Utility.dateTimeToMomentJSDateTime(contentRecord.Publish_Start_DateTime__c);
        wrapperObj.publishTo = Utility.dateTimeToMomentJSDateTime(contentRecord.Publish_End_DateTime__c);
        wrapperObj.createdAt = Utility.dateTimeToMomentJSDateTime(contentRecord.Created_DateTime__c);
        wrapperObj.lastModifiedDateTimeStamp = contentRecord.Last_Updated_DateTime__c != null ? 
                contentRecord.Last_Updated_DateTime__c.getTime() : 0;
        wrapperObj.firstPublishedAt = contentRecord.First_Publish_DateTime__c  != null ? 
                Utility.dateTimeToMomentJSDateTime(contentRecord.First_Publish_DateTime__c) : null;
        wrapperObj.authoredBy.Id = contentRecord.Primary_Author__c;
        wrapperObj.authoredBy.userId = contentRecord.Primary_Author__r.User__r.Id;
        wrapperObj.authoredBy.peopleId = contentRecord.Primary_Author__c;
        wrapperObj.authoredBy.name = contentRecord.Primary_Author__r.Full_Name__c;
        wrapperObj.authoredBy.img = contentRecord.Primary_Author__r.User__r.FullPhotoURL.endsWith('005/F') ? 
                null : contentRecord.Primary_Author__r.User__r.FullPhotoURL;
        wrapperObj.authoredBy.url = PageContext.getPageURL(Pages.app) + 
                '?u=/people/' + contentRecord.Primary_Author__c;
    	wrapperObj.authoredBy.title = SimpplrContext.isPPTitleDisplay ? 
                contentRecord.Primary_Author__r.title__c : null;
	    wrapperObj.authoredBy.location = Utility.buildLocation(contentRecord.Primary_Author__r.city__c, 
                contentRecord.Primary_Author__r.state__c, contentRecord.Primary_Author__r.country__c);
        wrapperObj.authoredBy.isFollowing = UserContext.usersIFollowIdSet.contains(wrapperObj.authoredBy.userId);
    	wrapperObj.authoredBy.department = SimpplrContext.isPPDepartmentDisplay ? 
                contentRecord.Primary_Author__r.Department__c : null;
    	wrapperObj.authoredBy.canFollow = UserContext.peopleId.equalsIgnoreCase(wrapperObj.authoredBy.peopleId) ?
            false : contentRecord.Primary_Author__r.User__r.isActive;
        wrapperObj.authoredBy.mediumPhotoUrl = Utility.getUserProfileImgUrl(contentRecord.Primary_Author__r.User__r.MediumPhotoURL, 
                contentRecord.Primary_Author__r.User__r.FullPhotoURL);
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
        wrapperObj.canPublishUnpublish = AccessManager.calculateManageBlogAccess(wrapperObj.authoredBy.userId);
        wrapperObj.canDelete = AccessManager.calculateManageBlogAccess(wrapperObj.authoredBy.userId);
        wrapperObj.canEdit = AccessManager.calculateBlogEditAccess(contentRecord.Primary_Author__r.User__c, wrapperObj.status);
        wrapperObj.canModerate = UserContext.isUserAppModerator;
        wrapperObj.canMakeMustRead = wrapperObj.isPublished && UserContext.isUserAppModerator;
		wrapperObj.usefulContent.canViewHistory = UserContext.isUserAppModerator;
        wrapperObj.readTime = contentRecord.Read_Time__c != null ? Integer.valueOf(contentRecord.Read_Time__c) : null;

	    if (contentRecord.Simpplr_Content_Feedback__r.isEmpty()) {
	    	wrapperObj.usefulContent.hasUserRated = false;

	    } else {
	    	wrapperObj.usefulContent.hasUserRated		= true;
	    	wrapperObj.usefulContent.hasUserRatedUseful	= contentRecord.Simpplr_Content_Feedback__r[0].Was_Content_Useful__c;
	    }
        
    	wrapperObj.listOfTopics = convertToListOfTopicWrapper(contentRecord.Id, 
                PageContext.getPageURL(Pages.app));
    	wrapperObj.recentViewCount = getViewCountInLast30Days(contentRecord.Id);
		List<File__c> fileList = getFilesByContentId(contentRecord.Id);

		for (File__c fileObj : fileList) {
			
            if (ServiceConstants.TITLE_IMAGE_TYPE_THUMBNAIL.equalsIgnoreCase(fileObj.Title_Image_Type__c) && 
                    fileObj.Is_Title_Image__c){
				wrapperObj.img = Utility.getFileDownloadURL(fileObj.Content_Version__c);
    			wrapperObj.imgFile = convertFileToFileContentWrapper(fileObj);
    		
    		} else if (ServiceConstants.TITLE_IMAGE_TYPE_WIDESCREEN.equalsIgnoreCase(fileObj.Title_Image_Type__c) && 
                    fileObj.Is_Title_Image__c){
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
            
            }  else if (ServiceConstants.FILE_LOCATION_INLINE.equalsIgnoreCase(fileObj.Location__c)) {
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
        wrapperObj.isOpenToNotification = !contentRecord.Content_Notification_Setting__r.isEmpty();
        wrapperObj.authoredBy.isProtectedAuthor = contentRecord.Primary_Author__r.Is_Protected_Author__c;
		
    	return wrapperObj;
    }
 
}