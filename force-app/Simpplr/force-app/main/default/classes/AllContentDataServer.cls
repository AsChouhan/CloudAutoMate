/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class AllContentDataServer extends DataServer{ 
	
	@TestVisible private final String ACTION_VALUE_SEARCH = 'search';
	@TestVisible private final String ACTION_VALUE_GET_EXPIRING_CONTENT_COUNTS = 'getExpiringContentCounts';
	@TestVisible private final String ACTION_VALUE_GET_POPULAR_CONTENTS = 'getPopularContents';
	@TestVisible private final String ACTION_VALUE_GET_LATEST_CONTENTS = 'getLatestContents';
    @TestVisible private final String ACTION_VALUE_DELETE = 'delete';
    @TestVisible private final String ACTION_VALUE_APPROVE = 'approve';
    @TestVisible private final String ACTION_VALUE_REJECT = 'reject';
    @TestVisible private final String ACTION_VALUE_PUBLISH = 'publish';
    @TestVisible private final String ACTION_VALUE_CREATE = 'create';
    @TestVisible private final String ACTION_VALUE_UNPUBLISH = 'unpublish';
    @TestVisible private final String ACTION_VALUE_RATE = 'rate';
    @TestVisible private final String ACTION_VALUE_GET_RATINGS = 'getRatings';
    @TestVisible private final String ACTION_VALUE_GET_MODERATION_HISTORY = 'getModerationHistory';
	@TestVisible private final String ACTION_VALUE_GET_ONBOARDING_HISTORY = 'getOnboardingHistory';
    @TestVisible private final String ACTION_VALUE_DELETE_RATINGS = 'deleteRatings';
    @TestVisible private final String ACTION_VALUE_SUBMIT = 'submit';
    @TestVisible private final String FILTER_FAVORITES = 'favorites';
    @TestVisible private final String FILTER_POPULAR = 'popular';
    @TestVisible private final String FILTER_UPDATES = 'updates';
	@TestVisible private final String FILTER_TOPIC = 'topic';
    @TestVisible private final String ACTION_VALUE_MAKE_MUST_READ = 'makeMustRead';
    @TestVisible private final String ACTION_VALUE_REMOVE_MUST_READ = 'removeMustRead';
    @TestVisible private final String ACTION_VALUE_RESET_MUST_READ = 'resetMustRead';
    @TestVisible private final String ACTION_VALUE_MARK_CONTENT_READ = 'markAsRead';
	@TestVisible private final String ACTION_VALUE_SEND_MUST_READ_REMINDER_EMAIL = 'sendMustReadReminderMail';
    @TestVisible private final String FILTER_CAN_ACCESS = 'canAccess';
    @TestVisible private final String FILTER_CAN_ADD_TO_NEWSLETTER = 'canAddToNewsletter';
    @TestVisible private final String FILTER_CAN_ADD_TO_NEWSLETTER_FROM_SITE = 'canAddToNewsletterFromSite';
    @TestVisible private final String FILTER_AUTHOR = 'author';
    @TestVisible public Static final String CONTENT_FEEDBACK_JSON_PROTOTYPE = '{"listOfratings":[{"user":{"url":null,"img":null,"name":"Lokesh Agarwal","id":"a0L36000000LEahEAG"},"id":"a0H36000004Jed2EAC","isUseful":true,"notes":"yes this is very helpful","ratedAt":"2016-07-05T22:13:01.000-1100"}]}';
	@TestVisible private final String ERROR_CONTENT_DELETED = 'Could not perform action - Content has been deleted';
    @TestVisible private final String ACTION_VALUE_GET_RELATED = 'getRelated';
	@TestVisible private final String ACTION_VALUE_MOVE = 'move';
	@TestVisible private final String ACTION_VALUE_OPT_FOR_NOTIFICATION = 'optForNotification';
	@TestVisible private final String CONTENT_SET_VALID = 'setValid';
	@TestVisible private final String CONTENT_DISMISS_VALIDATION = 'dismissValidation';
	@TestVisible private final String CONTENT_VERSION_HISTORY = 'getVersionHistory';
	@TestVisible private final String RESTORE_CONTENT_VERSION_HISTORY = 'restoreVersion';
	@TestVisible private final String ACTION_RENEW_LOCK = 'renewLock';
	@TestVisible private final String ACTION_START_INDEXING_FOR_AI = 'statrtIndexingForAI';
	@TestVisible private final String ACTION_VALUE_GET_BY_IDS = 'getByIds';
	@TestVisible private final String ACTION_VALUE_GET_METADATA = 'getMetadata';
	@TestVisible private final String ACTION_VALUE_PREPARE_MUST_READ_HISTORY_CSV = 'prepareMustReadHistoryCsv';
	@TestVisible private final String ACTION_VALUE_SAVE_CONTENT_ONBOARDING_STATUS = 'saveContentOnboardingStatus';
    @TestVisible private final String ACTION_VALUE_GET_MY_ONBOARDING_CONTENTS = 'getMyOnboardingContents';
	@TestVisible private final String STATUS_ONBOARDING = 'onboarding';
	private final String UPDATE_CONTENT_POISTION = 'updateContentPosition';
	private final String MOVE_CONTENT_TO_BOTTOM = 'moveContentToBottom';
	private final String MOVE_CONTENT_TO_TOP = 'moveContentToTop';
	@TestVisible private final String ACTION_VALUE_PREPARE_BULK_DATA_CSV = 'prepareBulkDataCsv';
    public List<String> allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).replace('Blog', 'BlogPost').split(',');

	private Boolean isAppModerator = UserContext.isUserAppModerator;
    
	private final String REQUEST_PARAM_DATA = 'data';
	
	private Set<Id> contentIdsForFollowingTopics;
	private String loggedInPeopleId = UserContext.peopleId;
	private String loggedInUserId = UserContext.userId;
	private Boolean peopleIdContext = false;
	private DateTime currentDateTime = DateTime.now();
	
	private Set<Id> sitesIFollowIdSet = UserContext.sitesIFollowIdSet;
	
	private Set<Id> sitesIManageContentOrSiteIManageSet = new Set<Id>();

    public AllContentDataServer() {
		sitesIManageContentOrSiteIManageSet.addAll(UserContext.sitesIManageIdSet);
		sitesIManageContentOrSiteIManageSet.addAll(UserContext.sitesIManageContentsIdSet);
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
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
    public override void handleRequest() {
    	try{
    		logger.logDebug('AllContentDataServer----entered handleRequest----');
	    	
           //-----pass controll to check data integrity---------
            String action = readParam(REQUEST_PARAM_ACTION);
            String dataJSON = readParam(REQUEST_PARAM_DATA);
            
            if(ACTION_VALUE_SEARCH.equalsIgnoreCase(action)){
            	//Map<String,String> requestMap = (Map<String, String>)JSON.deserialize(dataJSON, Map<String, String>.class);
            	Map<String,Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(dataJSON);
            	String filter = (String) requestMap.get('filter');
            	Boolean isMustRead = (Boolean) requestMap.get('isMustRead');
                String status = (String) requestMap.get('status');

				//Onboarding Content Listing
            	if(STATUS_ONBOARDING.equalsIgnoreCase(status)) {
            		response = getOnboardingContents(dataJSON);
				}

            	//Favorite Content Listing
            	else if(FILTER_FAVORITES.equalsIgnoreCase(filter)) {
            		response = getFavoriteContents(dataJSON);
            	
            	//Latest Content Listing
            	} else if(FILTER_UPDATES.equalsIgnoreCase(filter)) {
            		response = getLatestContents(dataJSON);
				
				//Content Search in Custom Tile
            	} else if(FILTER_CAN_ACCESS.equalsIgnoreCase(filter)) {
            		response = getAllContentUserCanAccess(dataJSON);
            		
            	//Content Search for must read content 
            	} else if(isMustRead == true) {
            		response = getContentMustReadForUser(dataJSON);
            	//search content fot Newsletter
            	} else if(FILTER_CAN_ADD_TO_NEWSLETTER.equalsIgnoreCase(filter) || FILTER_CAN_ADD_TO_NEWSLETTER_FROM_SITE.equalsIgnoreCase(filter)) {
            		response = searchContentForAddingInNewsltter(dataJSON,filter);
            	//Popular Content Listing
            	} else if(FILTER_POPULAR.equalsIgnoreCase(filter)) {
            		response = getPopularContents(dataJSON);
            	//Manage Content Listing	
            	
            	} else if(FILTER_AUTHOR.equalsIgnoreCase(filter)){
            		response = getAuthoredByPeopleContents(dataJSON);	
            	
            	} else if(FILTER_TOPIC.equalsIgnoreCase(filter)){
            		response = getContentsByTopic(dataJSON);	
            	
            	} else {
            		response = search(dataJSON);
            	}
            	
            } else if (ACTION_VALUE_DELETE.equalsIgnoreCase(action)){
                response = deleteContent(dataJSON);
            
            } else if (ACTION_VALUE_APPROVE.equalsIgnoreCase(action)){
                response = approveContent(dataJSON);
            } else if (ACTION_VALUE_SUBMIT.equalsIgnoreCase(action)){
                response = submitContent(dataJSON);
            } else if (ACTION_VALUE_REJECT.equalsIgnoreCase(action)){
                response = rejectContent(dataJSON);
            } else if (ACTION_VALUE_UNPUBLISH.equalsIgnoreCase(action)){
                response = unpublishContent(dataJSON);
            } else if (ACTION_VALUE_PUBLISH.equalsIgnoreCase(action)){
                response = publishContent(dataJSON);
            } else if (ACTION_VALUE_CREATE.equalsIgnoreCase(action)){
                response = createContent(dataJSON);
            
            } else if (ACTION_VALUE_RATE.equalsIgnoreCase(action)){
                response = rateContent(dataJSON);
            
            } else if (ACTION_VALUE_GET_RATINGS.equalsIgnoreCase(action)){
                response = getRatings(dataJSON);
            
            } else if (ACTION_VALUE_GET_MODERATION_HISTORY.equalsIgnoreCase(action)){
                response = getModerationHistory(dataJSON);
            
            }else if (ACTION_VALUE_GET_ONBOARDING_HISTORY.equalsIgnoreCase(action)){
                response = getOnboardingHistory(dataJSON);
            
            } else if (ACTION_VALUE_DELETE_RATINGS.equalsIgnoreCase(action)){
                //response = deleteRatings(dataJSON); This to be used in future , not in use as of now
            
            } else if (ACTION_VALUE_MAKE_MUST_READ.equalsIgnoreCase(action)){
                response = makeMustRead(dataJSON);
                
            } else if (ACTION_VALUE_REMOVE_MUST_READ.equalsIgnoreCase(action)){
                response = removeMustRead(dataJSON);
                
            } else if (ACTION_VALUE_RESET_MUST_READ.equalsIgnoreCase(action)){
                response = resetMustRead(dataJSON);
                
            } else if (ACTION_VALUE_MARK_CONTENT_READ.equalsIgnoreCase(action)){
                response = markAsRead(dataJSON);
                
            } else if (ACTION_VALUE_GET_RELATED.equalsIgnoreCase(action)){
				Boolean aiEnabled = false;
				if( SimpplrContext.aiRelatedContentEnabled ){
					String appFeatureQuery = 'Select Id, AI_Related_Content_Enabled__c, AI_Related_Content_Active__c From App_Feature__c Limit 1';
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					List<App_Feature__c> appFeatureObj = (List<App_Feature__c>)SIMPESAPI.accessController().queryAsUser(appFeatureQuery, null);
					aiEnabled = appFeatureObj.size() > 0 && appFeatureObj[0].AI_Related_Content_Enabled__c && appFeatureObj[0].AI_Related_Content_Active__c ? true : false;
				}
				
				if(aiEnabled) {
					response = getAIRelatedContent(dataJson);
					if(response.status == 'error'){
						response = getRelated(dataJson, true);
					}
				} else {
					response = getRelated(dataJson, false);
				}
            	
            } else if (ACTION_VALUE_SEND_MUST_READ_REMINDER_EMAIL.equalsIgnoreCase(action)) {
				response = sendMustReadReminderMail(dataJson);
			} else if(ACTION_VALUE_GET_EXPIRING_CONTENT_COUNTS.equalsIgnoreCase(action)){
				Map<String,Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(dataJSON);
            	String siteId = (String) requestMap.get('siteId');

				response = getExpiringContentCounts(siteId);
			
			} else if (ACTION_VALUE_MOVE.equalsIgnoreCase(action)) { 
				response = moveContent(dataJson);

			} else if(CONTENT_SET_VALID.equalsIgnoreCase(action)){
				response = setValid(dataJson);
					
	        } else if(CONTENT_DISMISS_VALIDATION.equalsIgnoreCase(action)){
				response = dismissValidation(dataJson);
					
	        } else if(CONTENT_VERSION_HISTORY.equalsIgnoreCase(action)){
				response = getVersionHistory(dataJson);

			} else if(RESTORE_CONTENT_VERSION_HISTORY.equalsIgnoreCase(action)){
				response = restoreVersion(dataJson);

			} else if(ACTION_VALUE_OPT_FOR_NOTIFICATION.equalsIgnoreCase(action)){
				response = optForNotification(dataJson);

			} else if(ACTION_RENEW_LOCK.equalsIgnoreCase(action)){
				response = renewLock(dataJson);

			} else if (ACTION_START_INDEXING_FOR_AI.equalsIgnoreCase(action)){
                response = startIndexingForAI(dataJSON);
				
            }  else if (ACTION_VALUE_GET_BY_IDS.equalsIgnoreCase(action)) {
                String[] listOfContentId = (String[])JSON.deserialize(dataJSON, 
                        String[].class);

                List<ContentWrapper> listOfSimpplrContWrap = new AllContentDataServer().getSimpplrContentsByIds(listOfContentId);
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, listOfSimpplrContWrap);

            } else if(ACTION_VALUE_GET_POPULAR_CONTENTS.equalsIgnoreCase(action)){
				response = getPopularContents(dataJSON);

			} else if(ACTION_VALUE_GET_LATEST_CONTENTS.equalsIgnoreCase(action)){
				response = getLatestContents(dataJSON);

			} else if(ACTION_VALUE_GET_METADATA.equalsIgnoreCase(action)){
				response = getMetadata(dataJSON);

			} else if(ACTION_VALUE_PREPARE_BULK_DATA_CSV.equalsIgnoreCase(action)){
				response = prepareBulkDataCsv(dataJSON);

			} else if(ACTION_VALUE_SAVE_CONTENT_ONBOARDING_STATUS.equalsIgnoreCase(action)){
				response = saveContentOnboardingStatus(dataJSON);

			} else if(ACTION_VALUE_GET_MY_ONBOARDING_CONTENTS.equalsIgnoreCase(action)){
				response = getMyOnboardingContents(dataJSON);

			} else if(UPDATE_CONTENT_POISTION.equalsIgnoreCase(action)){
				response = updateContentPosition(dataJSON);

			} else if(MOVE_CONTENT_TO_BOTTOM.equalsIgnoreCase(action)){
				response = moveContentToBottom(dataJSON);

			} else if(MOVE_CONTENT_TO_TOP.equalsIgnoreCase(action)){
				response = moveContentToTop(dataJSON);

			} else {
                throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            }
            
        }catch(Exception ex) {
            logger.logError('AllContentDataServer.handleRequest()----Exception Occured----', ex);
            
       		response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
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
    
    @TestVisible private Boolean checkContentModerationAccess(String contentId){
    	Simpplr_Content__c simpContentObj = [select id, Status__c, Type__c, Primary_Author__c,Primary_Author__r.user__c, Site__c,Site__r.Site_Type__c, Is_Deleted__c,Is_Published__c,Is_Unpublished__c from Simpplr_Content__c where id=:contentId WITH SECURITY_ENFORCED limit 1];
    	Boolean hasContentEditAccess = false;
    	if(simpContentObj.Is_Deleted__c == true) {
    		throw new SimpplrException(ERROR_CONTENT_DELETED);
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
    
    @TestVisible private Boolean checkContentModerationHistoryAccess(String contentId){
    	logger.logDebug('AllContentDataServer.checkContentModerationHistoryAccess()-----contentId----' + contentId);
    	Simpplr_Content__c simpContentObj = [select id, Status__c, Type__c, Primary_Author__c,Primary_Author__r.user__c, Site__c,Site__r.Site_Type__c, Is_Deleted__c,Is_Published__c,Is_Unpublished__c from Simpplr_Content__c where id=:contentId WITH SECURITY_ENFORCED limit 1];
    	Boolean hasContentModerationHistoryAccess = false;
    	
    	if (simpContentObj.Is_Deleted__c == true) {
    		throw new SimpplrException(ERROR_CONTENT_DELETED);
    	}
    	
    	Boolean isCurrentUserAuthor = UserContext.peopleId.equalsIgnoreCase(simpContentObj.Primary_Author__c)?true:false;
    	logger.logDebug('AllContentDataServer.checkContentModerationHistoryAccess()-----isCurrentUserAuthor----' + isCurrentUserAuthor);
    	
    	if (isCurrentUserAuthor) {
    		hasContentModerationHistoryAccess = true;
    	} else if('BlogPost'.equalsIgnoreCase(simpContentObj.Type__c)){
    		if(UserContext.isUserAppModerator || UserContext.hasModifyAllDataPermission){
    			hasContentModerationHistoryAccess = true;
    		}
    	} else {
    		String status = getContentStatus (simpContentObj.Status__c, simpContentObj.Is_Published__c,
    				simpContentObj.Is_Unpublished__c);
			Boolean isSiteManager = (UserContext.sitesIManageIdSet).contains(simpContentObj.Site__c);
			Boolean isContentManager = (UserContext.sitesIManageContentsIdSet).contains(simpContentObj.Site__c);
    		hasContentModerationHistoryAccess = AccessManager.calculateEditAccess(isSiteManager, isContentManager, status, 
    				simpContentObj.Primary_Author__r.user__c, simpContentObj.Site__r.Site_Type__c);
    	}
    	
    	return hasContentModerationHistoryAccess;
    }
    
    
    
     @TestVisible private Boolean checkMustReadContentEditAccess(String contentId) {
    	Simpplr_Content__c simpContentObj = [select id, Status__c, Type__c, Primary_Author__c,
				Site__c,Site__r.Site_Type__c, Is_Deleted__c, Is_Published__c, Is_Unpublished__c 
				FROM Simpplr_Content__c 
				WHERE id=:contentId WITH SECURITY_ENFORCED limit 1];
    	Boolean hasMustReadContentEditAccess = false;
    	
		if (simpContentObj.Is_Deleted__c == true) {
    		throw new SimpplrException(ERROR_CONTENT_DELETED);
    	}

    	if (UserContext.isUserAppModerator && simpContentObj.Is_Published__c) {
	    	
			if ('BlogPost'.equalsIgnoreCase(simpContentObj.Type__c) || 
					'Public'.equalsIgnoreCase(simpContentObj.Site__r.Site_Type__c)) {
    			hasMustReadContentEditAccess = true;
	    	}

    	}

	 	return hasMustReadContentEditAccess;
    }
	@TestVisible private ResponseWrapper getExpiringContentCounts(String siteId){
    	
    	logger.logDebug('AllContentDataServer.getExpiringContentCounts()------siteId: ' + siteId);
        ResponseWrapper resultWrapper = New ResponseWrapper();
        
		Datetime dateTimeNow = DateTime.now();
		Integer validationPeriodMonth = SimpplrContext.validationPeriodMonth;

		String contentStatusPreDraft = ServiceConstants.CONTENT_STATUS_PREDRAFT;

		String query = null;

		// Query to fetch expired contents 
		if(UserContext.isUserAppModerator){
			query =  ' SELECT COUNT(Id) expiredContentCount FROM Content_Audit_Trail__c WHERE '
					+' Content__r.Type__c = \'Page\' AND Content__r.Content_Sub_Type__c = \'knowledge\' AND ' 
					+' Action__c = \'Validation Expired\' AND Dismiss_By__c=null AND ' 
					+' Content__r.Is_Unpublished__c = true AND Content__r.Is_Deleted__c = false AND '
					+' Action_DateTime__c = LAST_N_DAYS: 14 AND '
					+' (Content__r.Site__c IN : sitesIManageContentOrSiteIManageSet OR Content__r.Site__r.Site_Type__c = \'Public\') ';

		} else {
			query =  ' SELECT COUNT(Id) expiredContentCount FROM Content_Audit_Trail__c WHERE '
					+' Content__r.Type__c = \'Page\' AND Content__r.Content_Sub_Type__c = \'knowledge\' AND ' 
					+' Action__c = \'Validation Expired\' AND Dismiss_By__c=null AND '
					+' Content__r.Is_Unpublished__c = true AND Content__r.Is_Deleted__c = false AND '
					+' Action_DateTime__c = LAST_N_DAYS: 14 AND '
					+' (Content__r.Site__c IN :sitesIManageContentOrSiteIManageSet) ';
		}

		if(String.isNotBlank(siteId)){
			query += ' AND Content__r.Site__c = :siteId ';
		}

        query += ' AND Content__r.Status__c !=: contentStatusPreDraft ';
        query += ' AND (Content__r.Site__c != null And Content__r.Site__r.Is_Active__c = true And Content__r.Site__r.Show_In_Simpplr__c = true) ';
        query += ' AND Content__r.Type__c IN : allowedFeaturesInAppList ';
		query += ' AND Content__r.Activated_By_Feature__c = true ';
		
		List<AggregateResult> aggResExpiredContentList = Database.query(query);

		Datetime currentTime = Datetime.now();
		Datetime expiryStartDateTime = currentTime.addMonths(- (validationPeriodMonth));
		Datetime expiry28DaysStartDateTime = expiryStartDateTime.addDays(28);
		Datetime expiry14DaysStartDateTime = expiryStartDateTime.addDays(14);

		Datetime expiry28DaysEndDate = currentTime.addDays(28);
		Datetime expiry14DaysEndDate = currentTime.addDays(14);
		
		// Query to fetch expiring contents
		if(UserContext.isUserAppModerator){

			query =  ' SELECT COUNT(Id) expiringContentCount FROM Simpplr_Content__c WHERE '
					+'  type__c = \'Page\' AND Content_Sub_Type__c = \'knowledge\' AND ' 
					+'	Id not in (SELECT content__c from Content_Audit_Trail__c ' 
					+'				WHERE Action__c=\'Validation Require Dismissed\' '
					+'				AND LastModifiedDate=LAST_N_DAYS: 14) AND '
					+'	Is_Published__c = true AND Is_Deleted__c = false AND '
					+'	( '
					+'		( '
					+'			(Publish_End_DateTime__c = null OR Publish_End_DateTime__c >= :expiry28DaysEndDate) AND  '
					+'			Primary_Author__c = :loggedInUserId AND  (Site__c IN :sitesIManageContentOrSiteIManageSet OR Site__r.Site_Type__c = \'Public\') AND '
					+'			(  '
					+'				(Last_Validated_DateTime__c = null AND Publish_Start_DateTime__c <= :expiry28DaysStartDateTime) '
					+'				OR  '
					+'				(Last_Validated_DateTime__c != null AND Last_Validated_DateTime__c <= :expiry28DaysStartDateTime)  '
					+'	    	) '
					+'		) '
					+'		OR '
					+'		( '
					+'			(Publish_End_DateTime__c = null OR Publish_End_DateTime__c >= :expiry14DaysEndDate) AND  '
					+'			Primary_Author__c != :loggedInUserId AND (Site__c IN :sitesIManageContentOrSiteIManageSet OR Site__r.Site_Type__c = \'Public\') AND '
					+'			(  '
					+'				(Last_Validated_DateTime__c = null AND Publish_Start_DateTime__c <= :expiry14DaysStartDateTime) '
					+'				OR  '
					+'				(Last_Validated_DateTime__c != null AND Last_Validated_DateTime__c <= :expiry14DaysStartDateTime)  '
					+'	    	) '
					+'		) '
					+'	) ';

		} else {
			query =  ' SELECT COUNT(Id) expiringContentCount FROM Simpplr_Content__c WHERE '
					+'  	type__c = \'Page\' AND Content_Sub_Type__c = \'knowledge\' AND  '
					+'  	Id not in (SELECT content__c from Content_Audit_Trail__c ' 
					+'  				WHERE Action__c=\'Validation Require Dismissed\' '
					+'  				AND LastModifiedDate=LAST_N_DAYS: 14 '
					+'  				AND Dismiss_By__c!=null) AND '
					+'  	Is_Published__c = true AND Is_Deleted__c = false AND '
					+'  	( '
					+'  		( '
					+'  			(Publish_End_DateTime__c = null OR Publish_End_DateTime__c >= :expiry28DaysEndDate) AND  '
					+'  			Primary_Author__c = :loggedInUserId AND (Site__c IN :sitesIManageContentOrSiteIManageSet) AND '
					+'  			(  '
					+'  				(Last_Validated_DateTime__c = null AND Publish_Start_DateTime__c <= :expiry28DaysStartDateTime) '
					+'  				OR  '
					+'  				(Last_Validated_DateTime__c != null AND Last_Validated_DateTime__c <= :expiry28DaysStartDateTime)  '
					+'  	    	) '
					+'  		) '
					+'  		OR '
					+'  		( '
					+'  			(Publish_End_DateTime__c = null OR Publish_End_DateTime__c >= :expiry14DaysEndDate) AND  '
					+'  			Primary_Author__c != :loggedInUserId AND (Site__c IN :sitesIManageContentOrSiteIManageSet) AND '
					+'  			(  '
					+'  				(Last_Validated_DateTime__c = null AND Publish_Start_DateTime__c <= :expiry14DaysStartDateTime) '
					+'  				OR  '
					+'  				(Last_Validated_DateTime__c != null AND Last_Validated_DateTime__c <= :expiry14DaysStartDateTime)  '
					+'  	    	) '
					+'  		) '
					+'  	)';
									
		}

        query += ' AND Is_Deleted__c = false ';
        query += ' AND Status__c !=: contentStatusPreDraft ';
        query += ' AND (Site__c != null And Site__r.Is_Active__c = true And Site__r.Show_In_Simpplr__c = true) ';
        query += ' AND Type__c IN : allowedFeaturesInAppList ';
		query += ' AND Activated_By_Feature__c = true ';

		if(String.isNotBlank(siteId)){
			query += ' AND Site__c = :siteId ';
		}
		List<AggregateResult> aggResExpiringContentList = Database.query(query);									

		Map<String, Integer> expiryCountmap = new Map<String, Integer>{
			'expiringContentCount' => !aggResExpiringContentList.isEmpty() ? (Integer) aggResExpiringContentList[0].get('expiringContentCount') : 0,
			'expiredContentCount' => !aggResExpiredContentList.isEmpty() ? (Integer) aggResExpiredContentList[0].get('expiredContentCount') : 0
		};
		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, expiryCountmap);

        return resultWrapper;
    }

    @TestVisible private ResponseWrapper deleteContent(String data){
    	
    	logger.logDebug('AllContentDataServer.deleteContent()----checking if data to be deleted is null');
    	logger.logDebug('AllContentDataServer.deleteContent()----data----'+data);
        ResponseWrapper resultWrapper = New ResponseWrapper();
        if(data == null || String.isBlank(data)){
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        }
        Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data, Type.forName('Map<String,String>'));
        String siteId = requestDataMap.get('siteId'); 
        String contentId = requestDataMap.get('contentId');
        if(String.isBlank(contentId)){
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        }
        
        logger.logDebug('AllContentDataServer.deleteContent()-----siteId----'+ siteId);
        logger.logDebug('AllContentDataServer.deleteContent()-----contentId----'+ contentId);
        if(checkContentModerationAccess(contentId)){
        	ManageContentDao daoObj = new ManageContentDao();
	        Boolean isSuccess = daoObj.updateContent(contentId, ServiceConstants.CONTENT_STATUS_DELETED);
	        logger.logDebug('AllContentDataServer.deleteContent()-----isSuccess-- '+ isSuccess);
	        if (isSuccess){
	        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
	        } else {
	        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
	        }	
	        logger.logDebug('AllContentDataServer.deleteContent()-----resultWrapper-- '+ resultWrapper);
        } else {
        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return resultWrapper;
    }
    
   
    @TestVisible 
    private ResponseWrapper rejectContent(String data){
    	logger.logDebug('AllContentDataServer.rejectContent()---data---' + data);
        ResponseWrapper resultWrapper = New ResponseWrapper();

        if (data == null || String.isBlank(data)){
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        }

        //String contentToReject = (String)JSON.deserialize(data, Type.forName('String'));
        Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data, Type.forName('Map<String,String>'));
         // TODO : Need to change parameteres as these are incorrecly mapped. Case has been raised with Joe
        String rejectionComment = requestDataMap.get('rejectionComment');
        String siteId = requestDataMap.get('siteId'); 
        String contentId = requestDataMap.get('contentId');
        
        logger.logDebug('AllContentDataServer.rejectContent()-----siteId----'+ siteId);
        logger.logDebug('AllContentDataServer.rejectContent()-----contentId----'+ contentId);
        
        if (checkContentModerationAccess(contentId)){
	        String status = ManageContentDao.getCurrentApprovalStatus(contentId);
	        
	        if('Submitted'.equalsIgnoreCase(status)){
	        	ManageContentDao daoObj = new ManageContentDao();
		        Boolean isSuccess = daoObj.updateContent(contentId, ServiceConstants.CONTENT_STATUS_REJECTED);
		        
		        logger.logDebug('AllContentDataServer.rejectContent()-----isSuccess-- '+ isSuccess);
		   
                if (isSuccess){
					Simpplr_Content__c contentObj = getContentObjFromContentId(contentId);
					
					Map<String,App_Notification__c> userToNotificationMap = NotificationDao.markNotificationForContentAsRejected(rejectionComment, contentObj);
					NotificationDispatcher.sendEmailForContentRejection(contentId, rejectionComment);
					daoObj.createContentAuditTrail(contentId, 'Rejected', rejectionComment);
		   
                }else{
		        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		        }
	        }
	        List<Simpplr_Content__c> contentObjList  = getContentListFromCriteria(contentId,siteId,'','','' ,'',0,0,new Set<Id>{siteId}, null, null, null, null, null, null);                                          
			List<ContentWrapper> contentWrapperList = contentListToLightWrapper(contentObjList, null);
	        ContentWrapper result = New ContentWrapper();
	        if (contentWrapperList.size() > 0) {
				result = contentWrapperList[0];
	        }
	        
	        if('Submitted'.equalsIgnoreCase(status) && 'Rejected'.equalsIgnoreCase(result.status)){
	        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
	        }else{
		    	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Content has already been '+result.status+'!', result);
	        }
	    	
	        logger.logDebug('AllContentDataServer.rejectContent()-----resultWrapper-- '+ resultWrapper);
        } else {
        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return resultWrapper;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    @TestVisible private ResponseWrapper unpublishContent(String data) {
    	logger.logDebug('AllContentDataServer.unpublishContent()---data---' + data);
        ResponseWrapper resultWrapper = New ResponseWrapper();

        if (data == null || String.isBlank(data)) {
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        }

        Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data, 
				Type.forName('Map<String,String>'));
        String siteId = requestDataMap.get('siteId'); 
        String contentId = requestDataMap.get('contentId');
        logger.logDebug('AllContentDataServer.unpublishContent()-----siteId----'+ siteId);
        logger.logDebug('AllContentDataServer.unpublishContent()-----contentId----'+ contentId);
        
		if (checkContentModerationAccess(contentId)) {
	        Boolean isSuccess = ManageContentDao.unpublishContent(contentId);
	        logger.logDebug('AllContentDataServer.unpublishContent()-----isSuccess-- '+ isSuccess);
	        
	        if (isSuccess){
	        	List<Simpplr_Content__c> contentObjList = New List<Simpplr_Content__c>();
		        contentObjList = getContentListFromCriteria(contentId,siteId,'','','' ,'',0,0,new Set<Id>{siteId}, null, null, null, null, null, null);                                          
	        	List<ContentWrapper> contentWrapperList = contentListToLightWrapper(contentObjList, null);
		        ContentWrapper result = New ContentWrapper();
		        String resultContentId;
				if (contentWrapperList.size() > 0) {
		        	result = contentWrapperList[0];
					result.unpublishedAt = Utility.dateTimeToMomentJSDateTime(DateTime.now());
					resultContentId = result.contentId;
		        }

	        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
	        	ManageContentDao daoObj = new ManageContentDao();
				
				if(!String.isBlank(resultContentId) && resultContentId!=null){
					daoObj.createContentAuditTrail(resultContentId, 'Unpublished', null);
				}else{
					daoObj.createContentAuditTrail(contentId, 'Unpublished', null);
				}
			} else {
	        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
	        }
	        
	        logger.logDebug('AllContentDataServer.unpublishContent()-----resultWrapper-- '+ resultWrapper);
        
		} else {
        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }

        return resultWrapper;
    }
    
	@TestVisible private ResponseWrapper saveContentOnboardingStatus(String data) {
    	logger.logDebug('AllContentDataServer.saveContentOnboardingStatus()---data---' + data);
        ResponseWrapper resultWrapper = New ResponseWrapper();
		Map<String,Object> result = New Map<String,Object>();
		
		if (data == null || String.isBlank(data)) {
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        }
		try{
       		Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data, 
				Type.forName('Map<String,String>')); 
        	String contentId = requestDataMap.get('contentId');
			String onboardingStatus = requestDataMap.get('onboardingStatus');
			logger.logDebug('AllContentDataServer.saveContentOnboardingStatus()-----contentId----'+ contentId);
			logger.logDebug('AllContentDataServer.saveContentOnboardingStatus()-----onboardingStatus----'+ onboardingStatus);

            ManageContentDao daoObj = new ManageContentDao();
	        Boolean isOnboardingContentExist = daoObj.updateContentOnboardingStatus(contentId, onboardingStatus);
	        result.put('isOnboardingContentExist', isOnboardingContentExist);

			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
			logger.logDebug('AllContentDataServer.saveContentOnboardingStatus()-----resultWrapper-- '+ resultWrapper);
			
		} catch(Exception e){
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
			logger.logDebug('AllContentDataServer.saveContentOnboardingStatus()-----resultWrapper-- '+ resultWrapper);
		}
        
        return resultWrapper;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    @TestVisible 
    private ResponseWrapper publishContent(String data){ 
    	logger.logDebug('AllContentDataServer.publishContent()---data---' + data);
        ResponseWrapper resultWrapper = New ResponseWrapper();
        if(data == null || String.isBlank(data)){
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        }
        
        Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data, Type.forName('Map<String,String>'));
        String siteId = requestDataMap.get('siteId'); 
        String contentId = requestDataMap.get('contentId');
        
        logger.logDebug('AllContentDataServer.publishContent()-----siteId----'+ siteId);
        logger.logDebug('AllContentDataServer.publishContent()-----contentId----'+ contentId);
        if(checkContentModerationAccess(contentId)){

			Simpplr_Content__c contentObj = getContentObjFromContentId(contentId);
			
			Boolean isPublicSite = contentObj.Site__r.Site_Type__c == 'Public' ? true : false; 
			String previousStatus = (contentObj != null) ? contentObj.Status__c : '';

			if (contentObj != NULL && !ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(contentObj.Type__c) 
				&& !AccessManager.hasContentApprovalAccess(contentObj.Site__c, isPublicSite)){
				throw new SimpplrException(ExceptionCode.NO_ACCESS.name());
 
			} else if (contentObj != NULL && ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(contentObj.Type__c) 
	        			&& (contentObj.Album_Image_Count__c == 0) && (contentObj.Album_Video_Count__c == 0)){
	        	throw New SimpplrException(ServiceConstants.ALBUM_WITHOUT_IMAGE_VIDEO_ERR);
			}
	        
	        Boolean isSuccess = ManageContentDao.publishContent(contentId);
	        logger.logDebug('AllContentDataServer.publishContent()-----isSuccess-- '+ isSuccess);
	        if (isSuccess){
	        	// create notification if content is approved from submitted status
	        	if (ServiceConstants.CONTENT_STATUS_SUBMIITED.equalsIgnoreCase(previousStatus)){
	    			Map<String,App_Notification__c> userToNotificationMap = NotificationDao.markNotificationForContentAsApproved(contentObj);
	    			
					NotificationDispatcher.sendEmailForContentApproval(contentId);
                }
                
	    		List<Simpplr_Content__c> contentObjList = New List<Simpplr_Content__c>();
		        contentObjList = getContentListFromCriteria(contentId,siteId,'','','' ,'',0,0,new Set<Id>{siteId}, null, null, null, null, null, null);  
				string newStatus = contentObjList[0].status__c;                               
	        	List<ContentWrapper> contentWrapperList = contentListToLightWrapper(contentObjList, null);
		        ContentWrapper contWrapObj = New ContentWrapper();
                
                if (contentWrapperList.size() > 0) {
		        	contWrapObj = contentWrapperList[0];
                }

                List<simpplr_content__feed> listOfSimpContentFeed = [SELECT id, parentId, type
                        FROM simpplr_content__feed 
                        WHERE type= 'LinkPost'  AND parentId=:contWrapObj.id WITH SECURITY_ENFORCED limit 1];

                if (contWrapObj.isPublished && listOfSimpContentFeed.isEmpty()) {
                    String grpMentionStr = ''; 

                    if (!'blog_post'.equalsIgnoreCase(contWrapObj.type)) {

                        if ('Public'.equalsIgnoreCase(contWrapObj.site.access) || 
                                ('Private'.equalsIgnoreCase(contWrapObj.site.access) && 
                                UserContext.chatterGroupsIFollowIdSet.contains(contWrapObj.site.chatterGroupId))) {
                            grpMentionStr = '@[' + contWrapObj.site.chatterGroupId + ']';
                        } 
                        
                    }
					if (!test.isRunningTest()) {
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
				if (contWrapObj.authoredBy != null) {
					if(ServiceConstants.CONTENT_STATUS_DRAFT.equalsIgnoreCase(previousStatus) && ServiceConstants.CONTENT_STATUS_APPROVED.equalsIgnoreCase(newStatus)) {
						if(UserContext.peopleId.equalsIgnoreCase(contWrapObj.authoredBy.peopleId) == false) {
							NotificationDispatcher.sendNotificationForPublishedOnYourBehalf(contentObj);
						}
						
					} 
				}

				ManageContentDao daoObj = new ManageContentDao();
				daoObj.createContentAuditTrail(contentId, ServiceConstants.CONTENT_STATUS_PUBLISH, null);

	        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, contWrapObj);
	        } else{
	        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
	        }
	        logger.logDebug('AllContentDataServer.publishContent()-----resultWrapper-- '+ resultWrapper);
        } else {
        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return resultWrapper;
    }
    
    public ResponseWrapper getPopularContents(String data) {
    	logger.logDebug('AllContentDataServer.getPopularContents()---data---' + data);
    	ResponseWrapper resultWrapper = New ResponseWrapper();
        
        try { 
            
            if (data == null || String.isBlank(data)) {
				throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
            }
            
			Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data, Type.forName('Map<String,String>'));
            String siteId = requestDataMap.get('siteId');
            String peopleId = requestDataMap.get('peopleId');
			String contentType =  requestDataMap.get('type');
			Boolean isAllContent = requestDataMap.get('isAllContent') != null ? Boolean.valueOf(requestDataMap.get('isAllContent')) : false;
			peopleIdContext = requestDataMap.get('peopleIdContext') != null ? Boolean.valueOf(requestDataMap.get('peopleIdContext')) : false;
			
			if (String.isBlank(contentType)) {
				contentType = 'all';
			}

            if (String.isNotBlank(peopleId)) {
                loggedInPeopleId = peopleId;
				PeopleDao peopleDaoObj = new PeopleDao();
				loggedInUserId = peopleDaoObj.getPeopleByPeopleId(peopleId).User__c;
            }

			
			String excludeType = getExcludeContentType(requestDataMap.get('excludeType'));
			Integer size = requestDataMap.get('size') != NULL ? Integer.valueOf(requestDataMap.get('size')) : SimpplrContext.simpplrDefaultPageSize;
			Integer offset = String.isNotBlank(requestDataMap.get('nextPageToken'))?Integer.valueOf(requestDataMap.get('nextPageToken')) : 0;
			Integer recordLimit =  size + 1;
			DateTime publishStartDateTime = Utility.getDateTimeFilterValue(requestDataMap.get('publishStartDate'));
			String author = requestDataMap.get('authoredBy');			
			List<ContentWrapper> contentWrapperList = contentListToLightWrapper(getPopularContentList(siteId, contentType, excludeType, offset, recordLimit, publishStartDateTime, author, isAllContent), null);
			
			Integer nextPageToken = contentWrapperList.size() < size ? null : offset + size;
			Map<String,Object> result = New Map<String,Object>();
            
            if (contentWrapperList.size() == recordLimit && nextPageToken < 2000) {
				contentWrapperList.remove(recordLimit - 1);
				result.put('nextPageToken',nextPageToken);
            
            } else {
				result.put('nextPageToken',null);
            }
            
			result.put('listOfItems',contentWrapperList);
			if(!test.isRunningTest() && String.isBlank(siteId) && SimpplrContext.aiContentRecommendationEnabled ){	
				//Show Recommended contents only if AI Content Recommendation Enabled
				Set<String> contentIds = new Set<String>();
				contentIds = ContentDataProvider.getAIContentRecommendations(new List<String>{UserContext.peopleId}, 'feed', 15);
				if(!contentIds.isEmpty()){
					List<Simpplr_Content__c> listOfContents = getSortedContentList(contentIds, 15);//Sorted on score basis from AI
					
					List<ContentWrapper> aiRecommendedcontentWrapperList = contentListToLightWrapper(listOfContents, null);
					result.put('aiRecommendedListOfItems',aiRecommendedcontentWrapperList);
				}else{
					result.put('aiRecommendedListOfItems', new List<ContentWrapper>());
				}
			}
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
        
        } catch(exception e){
      		logger.logError('AllContentDataServer.getPopularContents()-----could not retrieve data----',e);
  			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
		return resultWrapper;
    }
	@TestVisible
	private ResponseWrapper updateContentPosition(String data){
		ContentWrapper.ContentOrderWrapper wrapperObj = (ContentWrapper.ContentOrderWrapper) JSON.deserialize(data, 
        ContentWrapper.ContentOrderWrapper.class);
		
		if (wrapperObj != null) {
			List<String> contentIdList = wrapperObj.contentIdsArray;

			if (contentIdList != null && !contentIdList.isEmpty()) {
				List<Simpplr_Content__c> contentList = [SELECT Id, Display_Order__c 
						FROM Simpplr_Content__c 
						WHERE Site__c =: wrapperObj.siteId WITH SECURITY_ENFORCED ORDER BY Display_Order__c, Publish_Start_DateTime__c desc, Last_Updated_DateTime__c desc, Last_Validated_DateTime__c limit 10000];
				Map<String,Simpplr_Content__c> contentMap = new Map<String, Simpplr_Content__c>(contentList);
				Set<String> processedContentIdSet = new Set<String>();
				Integer displayorder = 1;

				for (String contentId : contentIdList) {
					
					if (contentMap.get(contentId) != null) {
						contentMap.get(contentId).Display_Order__c = displayorder;
						displayorder = displayorder +1 ;
						processedContentIdSet.add(contentId);
					}

				}

				for (Simpplr_Content__c content : contentList) {

					if (!processedContentIdSet.contains(content.id)) {
						contentMap.get(content.id).Display_Order__c = displayorder;
						displayorder = displayorder + 1 ;
					}

				}
				
				if (!contentMap.values().isEmpty()) {
					update contentMap.values();	
				}

			}

		}

		ResponseWrapper result = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, wrapperObj);
        return result;
	}
	@TestVisible
	private ResponseWrapper moveContentToBottom(String data) {
		ContentWrapper.ContentOrderWrapper wrapperObj = (ContentWrapper.ContentOrderWrapper) JSON.deserialize(data, 
        ContentWrapper.ContentOrderWrapper.class);

		if (wrapperObj != null) {
			List<Simpplr_Content__c> contentList = [SELECT Id,Display_Order__c 
					FROM Simpplr_Content__c 
					WHERE Is_Published__c= true AND Is_Deleted__c = false AND Site__c = :wrapperObj.siteId
					WITH SECURITY_ENFORCED
					ORDER BY Display_Order__c, Last_Updated_DateTime__c desc, Last_Validated_DateTime__c];
			List<Simpplr_Content__c> updatedContentList = new List<Simpplr_Content__c>();
			Integer counter = 1; 

			for (Simpplr_Content__c content : contentList) {
				
				if (content.id != wrapperObj.contentId) {
					updatedContentList.add(new Simpplr_Content__c(id = content.id, 
							Display_Order__c = counter++));
				}
			}

			updatedContentList.add(new Simpplr_Content__c(id = wrapperObj.contentId, 
					Display_Order__c = counter));
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, Simpplr_Content__c>(updatedContentList), 
					new List<Schema.SObjectField> {
						Simpplr_Content__c.Display_Order__c
					});
		}

		ResponseWrapper result = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, wrapperObj);
        return result;
	}
	@TestVisible
	private ResponseWrapper moveContentToTop(String data) {
		ContentWrapper.ContentOrderWrapper wrapperObj = (ContentWrapper.ContentOrderWrapper) JSON.deserialize(data, 
        ContentWrapper.ContentOrderWrapper.class);

		if (wrapperObj != null) {
			List<Simpplr_Content__c> contentList = [SELECT Id,Display_Order__c 
					FROM Simpplr_Content__c 
					WHERE Is_Published__c= true AND Is_Deleted__c = false AND Site__c = :wrapperObj.siteId
					WITH SECURITY_ENFORCED
					ORDER BY Display_Order__c, Last_Updated_DateTime__c desc, Last_Validated_DateTime__c];
			List<Simpplr_Content__c> updatedContentList = new List<Simpplr_Content__c>();
			Integer counter = 1; 
			updatedContentList.add(new Simpplr_Content__c(id = wrapperObj.contentId, 
					Display_Order__c=counter++));

			for (Simpplr_Content__c content : contentList) {
				
				if (content.id != wrapperObj.contentId){
					updatedContentList.add(new Simpplr_Content__c(id = content.id, 
							Display_Order__c = counter++));
				}

			}

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, Simpplr_Content__c>(updatedContentList), 
					new List<Schema.SObjectField> {
						Simpplr_Content__c.Display_Order__c
					});
		}

		ResponseWrapper result = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, wrapperObj);
        return result;
	}

	public ResponseWrapper getOnboardingContents(String data) {
    	logger.logDebug('AllContentDataServer.getOnboardingContents()---data---' + data);
    	ResponseWrapper resultWrapper = New ResponseWrapper();
        
        try { 
            
            if (data == null || String.isBlank(data)) {
				throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
            }
            
			Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data, Type.forName('Map<String,String>'));
            String siteId = requestDataMap.get('siteId');
			List<String> onboardingStatus = new List<String> {ServiceConstants.CONTENT_STATUS_ORG_ONBOARDING, ServiceConstants.CONTENT_STATUS_SITE_ONBOARDING};
			
			Integer size = requestDataMap.get('size') != NULL ? Integer.valueOf(requestDataMap.get('size')) : SimpplrContext.simpplrDefaultPageSize;
			Integer offset = String.isNotBlank(requestDataMap.get('nextPageToken'))?Integer.valueOf(requestDataMap.get('nextPageToken')) : 0;
			Integer recordLimit =  size + 1;
			List<ContentWrapper> contentWrapperList = contentListToLightWrapper(getOnboardingContentList(siteId, onboardingStatus, offset, recordLimit), null);
			Integer nextPageToken = contentWrapperList.size() < size ? null : offset + size;
			Map<String,Object> result = New Map<String,Object>();
            
            if (contentWrapperList.size() == recordLimit && nextPageToken < 2000) {
				contentWrapperList.remove(recordLimit - 1);
				result.put('nextPageToken',nextPageToken);
            
            } else {
				result.put('nextPageToken',null);
            }
            
			result.put('listOfItems',contentWrapperList);
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
        
        } catch(exception e){
      		logger.logError('AllContentDataServer.getOnboardingContents()-----could not retrieve data----',e);
  			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
		return resultWrapper;
    }

	public List<Simpplr_Content__c> getOnboardingContentList(String siteId, List<String> onboardingStatus, 
            Integer offset, Integer recordLimit) {
		List<String> allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).replace('Blog', 'BlogPost').split(',');
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteId);
		soqlParamMap.put('soqlParam2', onboardingStatus);
		soqlParamMap.put('soqlParam3', allowedFeaturesInAppList);
		soqlParamMap.put('soqlParam4', recordLimit);
		soqlParamMap.put('soqlParam5', offset);
		
		String query = ' SELECT Id, CreatedDate, Display_Order__c, Primary_Author__r.Name,Title__c,Created_DateTime__c FROM Simpplr_Content__c'+
					   ' WHERE Site__c=:soqlParam1 AND Content_Onboarding_Status__c=:soqlParam2'+
					   ' AND Type__c IN : soqlParam3 '+
					   ' AND Is_Published__c = true AND Is_Deleted__c = false'+
					   ' Order by Display_Order__c,Created_DateTime__c desc' +
				 	   ' LIMIT :soqlParam4 OFFSET :soqlParam5 ';
		
		logger.logDebug('AllContentDataServer.getOnboardingContentList()----query----' + query);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		List<Simpplr_Content__c> aggrList  = SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
    	List<String> listOfContentIds = new List<String>(); 
		for (Simpplr_Content__c ar: aggrList) {
    		listOfContentIds.add((String)ar.get('Id'));
    	}
		
        query = 'SELECT ' + String.join(getContentFieldList(), ',') + 
                ' FROM Simpplr_Content__c where id=:listOfContentIds ';  
		Map<Id, Simpplr_Content__c> mapOfContentObjects = new Map<Id, Simpplr_Content__c> ((List<Simpplr_Content__c>) Database.query(query));
		List<Simpplr_Content__c> listOfSortedContents = new List<Simpplr_Content__c>();
		
		for (String contentId : listOfContentIds) {
            
            if (mapOfContentObjects.containsKey(contentId)) {
				listOfSortedContents.add(mapOfContentObjects.get(contentId));
            }
            
		}
		return  listOfSortedContents;
    }
    
    private List<ContentWrapper> contentListToLightWrapper(List<Simpplr_Content__c> listOfContents, Map<String,Integer> contentIdToAudienceCountMap){
		List<ContentWrapper> contentWrapperList = new List<ContentWrapper>();
		Map<String,List<TopicAssignment>> contentIdWithTopicListMap;
		Set<Id> contentIdSet = new Set<Id>();
		Set<Id> usersIFollowIdSet = UserContext.usersIFollowIdSet;
		Set<Id> sitesIManageIdSet = UserContext.sitesIManageIdSet;
		Set<Id> sitesIManageContentsIdSet = UserContext.sitesIManageContentsIdSet;
		List<String> allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).replace('Blog', 'BlogPost').split(',');
		Set<String>  allowedFeaturesInAppSet = new  Set<String>();
		for(String feature : allowedFeaturesInAppList) {
	    	allowedFeaturesInAppSet.add(feature.toLowerCase());
	    }
		
		if(!listOfContents.isEmpty()){		
			Set<String> setOfContentDocumentId = new Set<String>();
			for(Simpplr_Content__c contentObj : listOfContents){
				contentIdSet.add(contentObj.Id);
				for(File__c fileObj : contentObj.File_Simpplr_Content__r) {
					if(fileObj.Content_Document__c != null) {
						setOfContentDocumentId.add(fileObj.Content_Document__c);
					}
				}
			}
			Map<Id, ContentDocument> contentDocumentMap = new Map<Id, ContentDocument>([SELECT Id, ContentSize FROM ContentDocument WHERE Id in :setOfContentDocumentId]);
			contentIdWithTopicListMap = initiateMapOfContentIdWithTopicList(contentIdSet);
			for(Simpplr_Content__c contentObj : listOfContents){
				contentWrapperList.add(convertContentToWrapper(contentObj,contentIdWithTopicListMap,usersIFollowIdSet,sitesIManageIdSet,sitesIManageContentsIdSet,allowedFeaturesInAppSet,contentIdToAudienceCountMap,contentDocumentMap));
			}
		}
		return contentWrapperList;
	} 
	 
	 private List<String> getContentIdsFromAWSResponse(List<ExternalSearchWrapper.ItemWrapper> listOfItems, Criteria.ExternalSearchReq contentCriteria) {
		List<String> contentIds = new List<String>();

		for(ExternalSearchWrapper.ItemWrapper itemWrapperObj : listOfItems) {
			Object item = itemWrapperObj.item;
			ContentWrapper clWrapper = (ContentWrapper)item;

			contentIds.add(clWrapper.id);
		}
		return contentIds;
	}

	private Map<String,List<TopicAssignment>> initiateMapOfContentIdWithTopicList(Set<Id> contentIdSet){
		Map<String,List<TopicAssignment>> contentIdWithtopicListMap = new Map<String,List<TopicAssignment>>();
		if(contentIdSet.size()>0){
			String queryToFetchTopic = 'SELECT Id,Topic.Id,Topic.name,EntityId FROM TopicAssignment WHERE EntityId IN:contentIdSet';
			if(SimpplrContext.isCommunitiesEnabled){
	    		queryToFetchTopic = queryToFetchTopic+' AND NetworkId = null';
	    	}
			List<TopicAssignment> topicList = Database.query(queryToFetchTopic);
			
			if(!topicList.isEmpty()){
				for(TopicAssignment topicAssObj : topicList){
					if(contentIdWithtopicListMap.get(topicAssObj.EntityId) == null){
						contentIdWithtopicListMap.put(topicAssObj.EntityId,new List<TopicAssignment>());
					}
					contentIdWithtopicListMap.get(topicAssObj.EntityId).add(topicAssObj);
				}
			}
		}
		return contentIdWithtopicListMap;
	}
    
    public List<Simpplr_Content__c> getPopularContentList(String siteId, String contentType, 
            String excludeType, Integer offset, Integer recordLimit, DateTime publishStartDateTime, String author,Boolean isAllContent) {
		Set<Id> topicsIFollowIdSet = new Set<Id>();
		Set<Id> userIdSet = new Set<Id>();
        Set<Id> siteIdSet = new Set<Id>();
        DateTime todayDateTime = System.now();
		SiteDao siteDaoObj = new SiteDao();
		PeopleDao peopleDaoObj = new PeopleDao();  
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', allowedFeaturesInAppList);
		soqlParamMap.put('soqlParam2', todayDateTime);
		String blogSubCondition = '';
		if(SimpplrContext.AllowedFeatures.containsIgnoreCase(AccessManager.FEATURE_BLOG)) {
			blogSubCondition = ' or Content__r.type__c = \'BlogPost\' ';
		}
		String query = ' select content__c contentId from Analytics_Top_Content__c ' +
    		    ' where createddate = LAST_N_DAYS: 14 ' +
    			' And content__r.TYPE__c IN : soqlParam1 ' +
    			' And content__r.Is_Deleted__c = false ' +
    			' And ((Content__r.Site__r.Is_Active__c = true And Content__r.Site__r.Show_In_Simpplr__c = true) ' + blogSubCondition + ' ) ' +
    			' And Content__r.Is_Published__c = true ' +
                ' And Content__r.Activated_By_Feature__c = true ' + 
                ' AND ((content__r.TYPE__c = \'Event\' AND content__r.Event_Start_DateTime__c >=:soqlParam2 )' + 
                '  OR (content__r.TYPE__c != \'Event\')) ' +  
                ' AND ((content__r.TYPE__c = \'Page\' AND content__r.Content_Sub_Type__c=\'news\' AND content__r.Publish_Start_DateTime__c = LAST_N_DAYS: 7)' +
                '  OR (content__r.TYPE__c = \'Page\' AND content__r.Content_Sub_Type__c=\'knowledge\') ' + 
                '  OR (content__r.TYPE__c != \'Page\'))';
		
		if (String.isNotBlank(contentType) && !'all'.equalsIgnoreCase(contentType)) {
			soqlParamMap.put('soqlParam3', contentType);
			query += ' And Content__r.Type__c=:soqlParam3 ';
        }
        
		if (String.isNotBlank(excludeType)) {
			soqlParamMap.put('soqlParam4', excludeType);
        	query += ' And Content__r.TYPE__c != :soqlParam4';
		}
		
		if(publishStartDateTime != null) {
			soqlParamMap.put('soqlParam5', publishStartDateTime);
			query += ' And Content__r.Publish_Start_DateTime__c >=: soqlParam5  ';
		}
		
		if(String.isNotBlank(author)) {
			soqlParamMap.put('soqlParam6', author);
			query += ' And Content__r.primary_author__c =:soqlParam6 ';
		} 

		
		if (String.isNotBlank(siteID) && !siteID.containsIgnoreCase('home')) {
			soqlParamMap.put('soqlParam7', siteID);
    		query += ' And Content__r.Site__c =: soqlParam7 ';
    		
		} else {
			if(!isAllContent){
				contentIdsForFollowingTopics = getContentIdSetForFollowedTopics(contentType);
				if(peopleIdContext){
					siteIdSet = siteDaoObj.sitesIFollowIdSet(loggedInUserId);
					userIdSet = peopleDaoObj.usersIFollowIdSet(loggedInUserId);
					topicsIFollowIdSet = siteDaoObj.topicsIFollowIdSet(loggedInUserId);
				}else{
					siteIdSet = UserContext.sitesIFollowIdSet;
					userIdSet = UserContext.usersIFollowIdSet;
					topicsIFollowIdSet = UserContext.topicsIFollowIdSet;
				}
				soqlParamMap.put('soqlParam8', userIdSet);
				soqlParamMap.put('soqlParam9', loggedInPeopleId);
				soqlParamMap.put('soqlParam10', siteIdSet);
				soqlParamMap.put('soqlParam11', contentIdsForFollowingTopics);
				query += ' AND ( ';
				query += ' (Content__r.TYPE__c=\'BlogPost\' And (Content__r.Primary_Author__r.User__c IN :soqlParam8 OR Content__r.Primary_Author__c =:soqlParam9 or Content__r.Primary_Author__r.Is_Influencer__c = true)) ';
				query += ' Or ';
				query += ' (Content__r.Site__c != null And Content__r.site__r.is_Active__c=true And Content__r.Site__r.Show_In_Simpplr__c = true And (Content__r.site__c IN:soqlParam10 or Content__r.Primary_Author__c =:soqlParam9)) ';
				query += ' Or ';
				query += ' content__c IN :soqlParam11';
				query += ' ) ';
			}else{
				query += ' AND ( ';
				query += ' (Content__r.TYPE__c=\'BlogPost\' And (Content__r.Primary_Author__r.Is_Influencer__c = true)) ';
				query += ' Or ';
				query += ' (Content__r.Site__c != null And Content__r.site__r.is_Active__c=true And Content__r.Site__r.Show_In_Simpplr__c = true)) ';
			}
    	}
		
        query += ' group by content__c ' + 	
				' having sum(Popularity_Score__c) > 0 ' +
				' order by sum(Popularity_Score__c) desc ' +
				' LIMIT :soqlParam12 OFFSET :soqlParam13 ';
		
		soqlParamMap.put('soqlParam12', recordLimit);
		soqlParamMap.put('soqlParam13', offset);
		logger.logDebug('AllContentDataServer.getPopularContentList()----query----' + query);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<AggregateResult> aggrList  = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
    	List<String> listOfContentIds = new List<String>(); 
        
        for (AggregateResult ar: aggrList) {
    		listOfContentIds.add((String)ar.get('contentId'));
    	}
       
        query = 'SELECT ' + String.join(getContentFieldList(), ',') + 
                ' FROM Simpplr_Content__c where id=:listOfContentIds ';  
		Map<Id, Simpplr_Content__c> mapOfContentObjects = new Map<Id, Simpplr_Content__c> ((List<Simpplr_Content__c>) Database.query(query));
		List<Simpplr_Content__c> listOfSortedContents = new List<Simpplr_Content__c>();
		
		for (String contentId : listOfContentIds) {
            
            if (mapOfContentObjects.containsKey(contentId)) {
				listOfSortedContents.add(mapOfContentObjects.get(contentId));
            }
            
		}
		
		return  listOfSortedContents;
    }
    
    @TestVisible public Map<Id, Simpplr_Content__c> getCustomTilesData(String siteId, List<String> ListOfContentIds) {
    	logger.logDebug('AllContentDataServer.getCustomTilesData()---siteId---' + siteId + '---ListOfContentIds---' + ListOfContentIds);
    	String query = 'SELECT '+String.join(getContentFieldList(),',')+' FROM Simpplr_Content__c Where id=:ListOfContentIds';
        query += ' And TYPE__c IN : allowedFeaturesInAppList ' +
					' And Is_Deleted__c = false ' +
					' And ((Site__r.Is_Active__c = true And Site__r.Show_In_Simpplr__c = true) or Type__c = \'BlogPost\')' +
					' And Is_Published__c = true ' +
					' And Activated_By_Feature__c = true ';
    	Map<Id, Simpplr_Content__c> mapOfContentObjects = new Map<Id, Simpplr_Content__c> ((List<Simpplr_Content__c>) Database.query(query));
        return mapOfContentObjects;
    }
    
    @TestVisible private ResponseWrapper createContent(String data){
    	logger.logDebug('AllContentDataServer.createContent()---data---' + data);
        ResponseWrapper resultWrapper = New ResponseWrapper();
        if(data == null || String.isBlank(data)){
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        }
        
        Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data, Type.forName('Map<String,String>'));
        String siteId = requestDataMap.get('siteId'); 
        String contentId = requestDataMap.get('contentId');
        if(checkContentModerationAccess(contentId)){
	        logger.logDebug('AllContentDataServer.createContent()-----siteId----'+ siteId);
	        logger.logDebug('AllContentDataServer.createContent()-----contentId----'+ contentId);
	        
	        Simpplr_Content__c contentObj = getContentObjFromContentId(contentId);
	        String previousStatus = (contentObj != null) ? contentObj.Status__c : '';
	       
	        if (contentObj != NULL && ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(contentObj.Type__c) 
	        			&& (contentObj.Album_Image_Count__c == 0) && (contentObj.Album_Video_Count__c == 0)){
	        	throw New SimpplrException(ServiceConstants.ALBUM_WITHOUT_IMAGE_VIDEO_ERR);
	        }	
	        
	        Boolean isSuccess = ManageContentDao.createContent(contentId);
	        logger.logDebug('AllContentDataServer.createContent()-----isSuccess-- '+ isSuccess);
	        if (isSuccess){
	        	// create notification if content is approved from submitted status
	    		if (ServiceConstants.CONTENT_STATUS_SUBMIITED.equalsIgnoreCase(previousStatus)){
	    			Map<String,App_Notification__c> userToNotificationMap = NotificationDao.markNotificationForContentAsApproved(contentObj);
	    			
	    		}
	    		List<Simpplr_Content__c> contentObjList = New List<Simpplr_Content__c>();
		        contentObjList = getContentListFromCriteria(contentId,siteId,'','','' ,'',0,0,new Set<Id>{siteId}, null, null, null, null, null, null);  
				String newStatus = contentObjList.size() > 0 ? contentObjList[0].Status__c : '';                                        
	        	List<ContentWrapper> contentWrapperList = contentListToLightWrapper(contentObjList, null);
		        ContentWrapper result = New ContentWrapper();
		        if (contentWrapperList.size() > 0) {
		        	result = contentWrapperList[0];
					String grpMentionStr = '';
					if (!'blog_post'.equalsIgnoreCase(result.type)) {
						if('Public'.equalsIgnoreCase(result.site.access) || 
							('Private'.equalsIgnoreCase(result.site.access) && 
							UserContext.chatterGroupsIFollowIdSet.contains(result.site.chatterGroupId))) {
							
							grpMentionStr = '@[' + result.site.chatterGroupId + ']';
						}
					}
					if (!test.isRunningTest()) {
						RecursionCheck.stopRecursion();
						if(SiteContext.isBroadcastSite && SiteContext.isCurrentUserSiteContentManager) {
							SiteDao siteDaoObj = new siteDao();
							siteDaoObj.ToggleMemberManager(result.site.chatterGroupId ,UserContext.id,'Admin');
							FeedServiceProvider.createTimeLine(null, result.id, result.url, 
								result.title, grpMentionStr);
							siteDaoObj.ToggleMemberManager(result.site.chatterGroupId ,UserContext.id,'Standard');
						} else {
							FeedServiceProvider.createTimeLine(null, result.id, result.url, 
								result.title, grpMentionStr);
						}
					}
					if (result.authoredBy != null) {
						if(ServiceConstants.CONTENT_STATUS_DRAFT.equalsIgnoreCase(previousStatus) && ServiceConstants.CONTENT_STATUS_APPROVED.equalsIgnoreCase(newStatus)) {
							if(UserContext.peopleId.equalsIgnoreCase(result.authoredBy.peopleId) == false) {
								NotificationDispatcher.sendNotificationForPublishedOnYourBehalf(contentObjList[0]);
							}
							
						} 
					}
		        }
	        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
	        } else{
	        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
	        }
	        logger.logDebug('AllContentDataServer.createContent()-----resultWrapper-- '+ resultWrapper);
        } else {
        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return resultWrapper;
    }
    
	@TestVisible private Simpplr_Content__c getContentObjFromContentId(String contentId) {
		Simpplr_Content__c contentObj = null;
		
		List<Simpplr_Content__c> simContentList = [SELECT Id, Status__c, Type__c, Title__c, Site__c, Display_Excerpt__c, Album_Image_Count__c, 
														  Album_Video_Count__c, Primary_Author__c, Primary_Author__r.User__c, Primary_Author__r.Full_Name__c ,
														  Site__r.Site_Type__c
													FROM Simpplr_Content__c 
													WHERE Id =: contentId WITH SECURITY_ENFORCED];
		
		if(!simContentList.isEmpty()) {
			contentObj = simContentList[0];
		}
		return contentObj;
	}
	
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    
    public void checkAndApproveNotifications(Simpplr_Content__c contentObj) {
    	if(NotificationDao.getPendingActionableNotificationForContent(contentObj.Id) > 0) {
    		Map<String,App_Notification__c> userToNotificationMap = NotificationDao.markNotificationForContentAsApproved(contentObj);
			NotificationDispatcher.sendEmailForContentApproval(contentObj.Id);
			ManageContentDao daoObj = new ManageContentDao();
			daoObj.createContentAuditTrail(contentObj.id, 'Approved', null);
    	}
    }
	
	@TestVisible private ResponseWrapper approveContent(String data) {
		logger.logDebug('AllContentDataServer.approveContent()---data---' + data);
    	ResponseWrapper resultWrapper = new ResponseWrapper();

        if (data == null || String.isBlank(data)) {
            throw new SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        }

        //String contentToApprove = (String)JSON.deserialize(data, Type.forName('String'));
        Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data, Type.forName('Map<String,String>'));
        String siteId = requestDataMap.get('siteId'); 
        String contentId = requestDataMap.get('contentId');
        logger.logDebug('AllContentDataServer.approveContent()-----siteId----'+ siteId);
        logger.logDebug('AllContentDataServer.approveContent()-----contentId----'+ contentId);
        
		if (checkContentModerationAccess(contentId)) {
	        String status = ManageContentDao.getCurrentApprovalStatus(contentId);
	        
			if ('Submitted'.equalsIgnoreCase(status)) {
	        	ManageContentDao daoObj = new ManageContentDao();
		        Boolean isSuccess = daoObj.updateContent(contentId, ServiceConstants.CONTENT_STATUS_APPROVED);
		        logger.logDebug('AllContentDataServer.approveContent()-----isSuccess-- '+ isSuccess);
		        
				if (isSuccess) {
		        	Simpplr_Content__c contentObj = getContentObjFromContentId(contentId);
					Map<String,App_Notification__c> userToNotificationMap = NotificationDao.markNotificationForContentAsApproved(contentObj);
					NotificationDispatcher.sendEmailForContentApproval(contentId);
		        
				} else {
		        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		        }

	        }
			List<Simpplr_Content__c> contentObjList = getContentListFromCriteria(contentId,siteId,'','','' ,'',0,0,new Set<Id>{siteId}, null, null, null, null, null, null);                                          
	    	List<ContentWrapper> contentWrapperList = contentListToLightWrapper(contentObjList, null);
	        ContentWrapper result = New ContentWrapper();
	        String contentUpdatedStatus;
	        String resultContentId;
			if (contentWrapperList.size() > 0) {
	        	contentUpdatedStatus = contentObjList[0].Status__c;
				result = contentWrapperList[0];
				resultContentId = result.contentId;
	        }
	        
	        if ('Submitted'.equalsIgnoreCase(status) && 'Approved'.equalsIgnoreCase(contentUpdatedStatus)) {
				resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);

	        } else {
				resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Content has already been '+result.status+'!', result);
	        }

	        ManageContentDao daoObj = new ManageContentDao();
			if(!String.isBlank(resultContentId) && resultContentId!=null){
				daoObj.createContentAuditTrail(resultContentId, 'Approved', null);
			}else{
				daoObj.createContentAuditTrail(contentId, 'Approved', null);
			}
	        logger.logDebug('AllContentDataServer.approveContent()-----resultWrapper-- '+ resultWrapper);
        
		} else {
        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }

        return resultWrapper;
        
    }
    
    @TestVisible private ResponseWrapper submitContent(String data) {
		logger.logDebug('AllContentDataServer.submitContent()---data---' + data);
    	ResponseWrapper resultWrapper = new ResponseWrapper();

        if (data == null || String.isBlank(data)) {
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        }

        Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data, 
				Type.forName('Map<String,String>'));
        String siteId = requestDataMap.get('siteId'); 
        String contentId = requestDataMap.get('contentId');
        logger.logDebug('AllContentDataServer.submitContent()-----siteId----'+ siteId);
        logger.logDebug('AllContentDataServer.submitContent()-----contentId----'+ contentId);
        
		if (checkContentModerationAccess(contentId)) {
	        String status = ManageContentDao.getCurrentApprovalStatus(contentId);
	        
			if ('Draft'.equalsIgnoreCase(status) || 'Rejected'.equalsIgnoreCase(status)) {
		        Boolean isSuccess = false;
		        ManageContentDao daoObj = new ManageContentDao();

		        if (AccessManager.hasContentApprovalAccess()) {
		        	isSuccess = daoObj.updateContent(contentId, ServiceConstants.STATUS_APPROVED);
		        	daoObj.createContentAuditTrail(contentId, 'Approved', null);

				} else {
		        	isSuccess = daoObj.updateContent(contentId, ServiceConstants.CONTENT_STATUS_SUBMIITED);
					daoObj.createContentAuditTrail(contentId, 'Submitted', null);
		        }
		        
		        logger.logDebug('AllContentDataServer.submitContent()-----isSuccess-- '+ isSuccess);
		        
				if (isSuccess && AccessManager.hasContentApprovalAccess() ==  false){
					
					try {
						Simpplr_Content__c contentObj = getContentObjFromContentId(contentId);
	        			String contentTitle = (contentObj != null) ? contentObj.Title__c : '';
						String contentType = (contentObj != null) ? contentObj.Type__c : '';
						Map<String,App_Notification__c> userToNotificationMap = NotificationDao.generateReviewNotifications(contentId, contentType, contentTitle, contentObj.site__c, contentObj.Display_Excerpt__c);
						NotificationDispatcher.sendEmailForContentModeration(contentObj);
					
					} catch (Exception e) {
						logger.logDebug('AllContentDataServer.submitContent()-----Unable to send email or notification-- '+ e);	
					}

		        } else {
		        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		        }

	        }
	        
			List<Simpplr_Content__c> contentObjList = getContentListFromCriteria(contentId, siteId, 
					'', '', '' ,'', 0, 0, new Set<Id>{siteId}, null, null, null, null, null, null);                                          
	    	List<ContentWrapper> contentWrapperList = contentListToLightWrapper(contentObjList, null);
	        ContentWrapper result = new ContentWrapper();
	        
			if (contentWrapperList.size() > 0) {
	        	result = contentWrapperList[0];
	        } 
	        resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);	
	        logger.logDebug('AllContentDataServer.submitContent()-----resultWrapper-- '+ resultWrapper);
        
		} else {
        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }

        return resultWrapper;
        
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    @TestVisible private ResponseWrapper rateContent(String data){
    	logger.logDebug('AllContentDataServer.rateContent()---data---' + data);
        ResponseWrapper resultWrapper = New ResponseWrapper();
        if(data == null || String.isBlank(data)){
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        }
        
        Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data, Type.forName('Map<String,String>'));
        
        Boolean isUsefulBool = Boolean.valueOf(requestDataMap.get('isUsefulBool')); 
        String contentId = requestDataMap.get('contentId');
        String comment = requestDataMap.get('comment');
        
        logger.logDebug('AllContentDataServer.rateContent()-----isUsefulBool----'+ isUsefulBool);
        logger.logDebug('AllContentDataServer.rateContent()-----contentId----'+ contentId);
        logger.logDebug('AllContentDataServer.rateContent()-----comment----'+ comment);
        String rateObjId = ManageContentDao.rateContent(contentId,isUsefulBool,comment);
        logger.logDebug('AllContentDataServer.rateContent()-----rateObjId-- '+ rateObjId);

        if (String.isNotBlank(rateObjId)){
        	Simpplr_Content__c contentObj = getContentObjFromContentId(contentId);
        	String contentTitle = (contentObj != null) ? contentObj.Title__c : '';
			String contentType = (contentObj != null) ? contentObj.Type__c : '';
			String siteId = (contentObj != null) ? contentObj.Site__c : '';
        	// create notification if content is being rated
			NotificationDispatcher.sendNotificationForContentFeedback(contentId, contentType, isUsefulBool, siteId,comment, contentTitle);
			
			//NotificationDispatcher.sendEmailForContentApproval(contentId);
    		Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', rateObjId);
			String feedbackQuery = 'SELECT Id,Comment__c,Is_Deleted__c,Simpplr_Content__c,createdDate, ' +
				' Submitter__c,Was_Content_Useful__c,Submitter__r.Full_Name__c, ' +
				' Submitter__r.User__r.Id, Submitter__r.User__r.SmallPhotoUrl ' +
				' FROM Content_Feedback__c WHERE ID =:soqlParam1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Content_Feedback__c> contentFeedbackList = (List<Content_Feedback__c>)SIMPESAPI.accessController().queryAsUser(feedbackQuery, soqlParamMap);
    		
    		List<Object> listOfRatings = getJsonObjectFromFeedbackList(contentFeedbackList);
		    Map<String,Object> result = new Map<String,Object>();
		    if(listOfRatings.size() > 0){
		    	result = (Map<String,Object>)listOfRatings[0];
		    }
        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
        } else{
        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('AllContentDataServer.rateContent()-----resultWrapper-- '+ resultWrapper);
        return resultWrapper;
    }
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    @TestVisible private ResponseWrapper deleteRatings(String data){
    	logger.logDebug('AllContentDataServer.deleteRatings()---data---' + data);
        ResponseWrapper resultWrapper = New ResponseWrapper();
        if(data == null || String.isBlank(data)){
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        }
    	Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data, Type.forName('Map<String,String>'));
        String contentId = requestDataMap.get('contentId');
        String recordId = requestDataMap.get('recordId');
        
        Boolean isSuccess = ManageContentDao.deleteRatings(contentId, recordId);
        
        logger.logDebug('AllContentDataServer.deleteRatings()-----isSuccess-- '+ isSuccess);
        if (isSuccess){
        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
        } else {
        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }	
        logger.logDebug('AllContentDataServer.deleteRatings()-----resultWrapper-- '+ resultWrapper);
        return resultWrapper;
    }

    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    @TestVisible private ResponseWrapper getRatings(String data){
    	logger.logDebug('AllContentDataServer.getRatings()---data---' + data);
        ResponseWrapper resultWrapper = New ResponseWrapper();
        if(data == null || String.isBlank(data)){
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        }
        try {
        	Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data, Type.forName('Map<String,String>'));
	        String contentId = requestDataMap.get('contentId');
	        if(checkContentModerationHistoryAccess(contentId)){
		        Integer size = String.isNotBlank(requestDataMap.get('limit')) ? Integer.valueOf(requestDataMap.get('limit')) : 0; 
		        Integer nextPageToken = String.isNotBlank(requestDataMap.get('nextPageToken'))?Integer.valueOf(requestDataMap.get('nextPageToken')):0;
		        
		        logger.logDebug('AllContentDataServer.getRatings()-----contentId----'+ contentId);
		        List<Content_Feedback__c> feedbackObjectList = new List<Content_Feedback__c>();
		        feedbackObjectList = ManageContentDao.getRatings(contentId, nextPageToken, size, null, '', '');
		        logger.logDebug('AllContentDataServer.getRatings()-----feedbackObjectList-- '+ feedbackObjectList);
		        
			    List<Object> listOfRatings = getJsonObjectFromFeedbackList(feedbackObjectList);
			    Map<String,Object> result = new Map<String,Object>();
			    nextPageToken = feedbackObjectList.size() < size ? null : nextPageToken + size;
			    result.put('nextPageToken',nextPageToken);  
			    result.put('listOfItems',listOfRatings);
		       	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
	        } else {
	        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
	        }
	        
	        
        } catch (exception e){
        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('AllContentDataServer.getRatings()-----resultWrapper-- '+ resultWrapper);
        return resultWrapper;
    }
    
    @TestVisible 
    private ResponseWrapper getModerationHistory(String data){
    	logger.logDebug('AllContentDataServer.getModerationHistory()---data---' + data);
        
        ResponseWrapper resultWrapper = new ResponseWrapper();

        if (data == null || String.isBlank(data)){
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        }

        try {
        	Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data, Type.forName('Map<String,String>'));
	        String contentId = requestDataMap.get('id');
	    
            if (checkContentModerationHistoryAccess(contentId)){
		        Integer size = String.isNotBlank(requestDataMap.get('size')) ? Integer.valueOf(requestDataMap.get('size')) : 0; 
		        Integer nextPageToken = String.isNotBlank(requestDataMap.get('nextPageToken'))?Integer.valueOf(requestDataMap.get('nextPageToken')):0;
		        
		        logger.logDebug('AllContentDataServer.getModerationHistory()-----contentId----' + contentId + ' ------size----' + size);
		        List<ApprovalHistoryService.ModerationHistoryWrapper> moderationHistoryList = new List<ApprovalHistoryService.ModerationHistoryWrapper>();
		        moderationHistoryList = ApprovalHistoryService.getModerationHistory(contentId, size, nextPageToken);
		        logger.logDebug('AllContentDataServer.getModerationHistory()-----moderationHistoryList-- '+ moderationHistoryList);
		        
			    Map<String,Object> result = new Map<String,Object>();
			   
                if (moderationHistoryList.size() == (size+1)){
			    	nextPageToken = nextPageToken + size;
			    	moderationHistoryList.remove((moderationHistoryList.size()-1));
			    
                } else {
			    	nextPageToken = null;
			    }

			    result.put('nextPageToken',nextPageToken);  
			    result.put('listOfItems',moderationHistoryList);
		       	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
	        } else {
	        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
	        }
	        
	        
        } catch (exception e){
			logger.logError('AllContentDataServer.getModerationHistory()-----Exception occurred----',e);
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('AllContentDataServer.getModerationHistory()-----resultWrapper-- '+ resultWrapper);
        return resultWrapper;
    }

	@TestVisible 
    private ResponseWrapper getOnboardingHistory(String data){
    	logger.logDebug('AllContentDataServer.getOnboardingHistory()---data---' + data);
        
        ResponseWrapper resultWrapper = new ResponseWrapper();

        if (data == null || String.isBlank(data)){
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        }

        try {
        	Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data, Type.forName('Map<String,String>'));
	        String contentId = requestDataMap.get('id');
	    	Integer size = String.isNotBlank(requestDataMap.get('size')) ? Integer.valueOf(requestDataMap.get('size')) : 0; 
		    Integer nextPageToken = String.isNotBlank(requestDataMap.get('nextPageToken'))?Integer.valueOf(requestDataMap.get('nextPageToken')):0;
		        
		    logger.logDebug('AllContentDataServer.getOnboardingHistory()-----contentId----' + contentId + ' ------size----' + size);
		    List<ApprovalHistoryService.OnboardingHistoryWrapper> onboardingHistoryList = new List<ApprovalHistoryService.OnboardingHistoryWrapper>();
		    onboardingHistoryList = ApprovalHistoryService.getOnboardingHistory(contentId, size, nextPageToken);
		    logger.logDebug('AllContentDataServer.getOnboardingHistory()-----onboardingHistoryList-- '+ onboardingHistoryList);
		        
			Map<String,Object> result = new Map<String,Object>();
			if (onboardingHistoryList.size() == (size+1)){
			    nextPageToken = nextPageToken + size;
			    onboardingHistoryList.remove((onboardingHistoryList.size()-1));
			    
            } else {
			    nextPageToken = null;
			}

			result.put('nextPageToken',nextPageToken);  
			result.put('listOfItems',onboardingHistoryList);
		    resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
	    
		} catch (exception e){
			logger.logError('AllContentDataServer.getOnboardingHistory()-----Exception occurred----',e);
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('AllContentDataServer.getOnboardingHistory()-----resultWrapper-- '+ resultWrapper);
        return resultWrapper;
    }
    
    private List<Object> getJsonObjectFromFeedbackList(List<Content_Feedback__c> contentFeedbackList){
    	
    	Map<String,Object> feedbackPrototypeObj = (Map<String,Object>)JSON.deserializeUntyped(CONTENT_FEEDBACK_JSON_PROTOTYPE);
		List<Object> ratingObjectist = (List<Object>) feedbackPrototypeObj.get('listOfratings');
		ratingObjectist.clear();
		for(Content_Feedback__c obj : contentFeedbackList ){
			
			Map<String, Object> userObjectMap = new Map<String,Object>();
			userObjectMap.put('url',PageContext.getPageURL(Pages.app) + '?u=/people/' + obj.Submitter__c);
			userObjectMap.put('img',obj.Submitter__r.User__r.SmallPhotoUrl.endsWith('005/T') ? null : obj.Submitter__r.User__r.SmallPhotoUrl);
			userObjectMap.put('name',obj.Submitter__r.Full_Name__c);
			userObjectMap.put('userId',obj.Submitter__r.User__r.Id);
			userObjectMap.put('id',obj.Submitter__c);
			
			Map<String, Object> feedbackObjectMap = new Map<String,Object>();
			feedbackObjectMap.put('id',obj.id);
		    feedbackObjectMap.put('user',userObjectMap);
		    feedbackObjectMap.put('isUsefulBoolean',obj.Was_Content_Useful__c);
		    feedbackObjectMap.put('notes',obj.Comment__c);
		    
		    String dateStringValue = String.valueOf(obj.CreatedDate);
	        if(String.isNotBlank(dateStringValue)){
		        DateTime dateTimeValue = obj.CreatedDate;
	    	    feedbackObjectMap.put('ratedAt',dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
	        }
	        
		    ratingObjectist.add((Object)feedbackObjectMap);
		}
		return ratingObjectist;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public class PageCategoryWrapper{
    	public String contentId;
    }
    
    @TestVisible private ResponseWrapper makeMustRead(String data) {
    	logger.logDebug('AllContentDataServer.makeMustRead()---data---' + data);
    	ResponseWrapper resultWrapper = New ResponseWrapper();
    	Boolean isSuccess = false;

		try {
			InternalRequestWrapper.MustRead reqMustReadWrapObj = (InternalRequestWrapper.MustRead)JSON.deserialize(data, 
					InternalRequestWrapper.MustRead.class);
			ManageContentDao daoObj = new ManageContentDao();
			daoObj.makeMustRead(reqMustReadWrapObj);
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);    	
		} catch (Exception e) {
			logger.logError('AllContentDataServer.makeMustRead()----Exception occured----', e);
    		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
    	}

    	return resultWrapper;
    }
    
    @TestVisible private ResponseWrapper removeMustRead(String data) {
    	logger.logDebug('AllContentDataServer.removeMustRead()---data---' + data);
    	ResponseWrapper resultWrapper = New ResponseWrapper();
    	Boolean isSuccess = false;
		try{
			Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data, Type.forName('Map<String,String>'));
			String contentId = requestDataMap.get('contentId');
			ManageContentDao daoOj = new ManageContentDao();
			daoOj.removeMustRead(contentId);
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
    	}catch(Exception e){
			logger.logError('AllContentDataServer.removeMustRead()----Exception occured----', e);
    		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR,null, null);
    	}
    	return resultWrapper;
    }
    
    @TestVisible private ResponseWrapper resetMustRead(String data) {
    	logger.logDebug('AllContentDataServer.resetMustRead()---data---' + data);
    	ResponseWrapper resultWrapper = New ResponseWrapper();
    	Boolean isSuccess = false;
		try{
			Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data, Type.forName('Map<String,String>'));
			String contentId = requestDataMap.get('contentId');
			if(checkMustReadContentEditAccess(contentId)){
				isSuccess = ManageContentDao.resetMustRead(contentId);
	       		logger.logDebug('AllContentDataServer.resetMustRead()----isSuccess----' + isSuccess);
			}
	        if (isSuccess){
        		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
	        } else {
	        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
	        }	
	        logger.logDebug('AllContentDataServer.resetMustRead()-----resultWrapper-- '+ resultWrapper);
    	}catch(Exception e){
    		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR,null, null);
    	}
    	return resultWrapper;
    }

	@TestVisible private ResponseWrapper sendMustReadReminderMail(String data) {
    	logger.logDebug('AllContentDataServer.sendMustReadReminderMail()---data---' + data);
    	ResponseWrapper resultWrapper = New ResponseWrapper();
    	Boolean isSuccess = false;
		try{
			Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data, Type.forName('Map<String,String>'));
			String contentId = requestDataMap.get('contentId');			
			new ManageContentDao().sendMustReadReminderMail(contentId);
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
	        
    	}catch(Exception e){
			logger.logError('AllContentDataServer.sendMustReadReminderMail----Exception occured----', e);
    		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR,null, null);
    	}
    	return resultWrapper;
    }
    
    @TestVisible private ResponseWrapper markAsRead(String data) {
    	logger.logDebug('AllContentDataServer.markAsRead()---data---' + data);
    	ResponseWrapper resultWrapper = New ResponseWrapper();
    	
		try{
			Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data, Type.forName('Map<String,String>'));
			String contentId = requestDataMap.get('contentId');
			Boolean isSuccess = ManageContentDao.markAsRead(contentId);
       		logger.logDebug('AllContentDataServer.markAsRead()----isSuccess----' + isSuccess);
	        if (isSuccess){
        		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, true);
	        } else {
	        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null , false);
	        }	
    	}catch(Exception e){
			logger.logError('AllContentDataServer.markAsRead()-----Exception Occured----'+ e);
    		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
    	}
    	return resultWrapper;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    @TestVisible private ResponseWrapper search(String data){
    	logger.logDebug('AllContentDataServer.search()---data---' + data);
    	ResponseWrapper resultWrapper = New ResponseWrapper();
        //Boolean isAppModerator = UserContext.isUserAppModerator;
        try{
	        ManageContentRequestWrapper requestObj = (ManageContentRequestWrapper)JSON.deserialize(data, ManageContentRequestWrapper.class);
	        String orderBy = '';
	        String order = '';
			String contentId = String.isBlank(requestObj.contentId) ? '':requestObj.contentId;
			String contentType= String.isBlank(requestObj.type) ? null:requestObj.type;
			String contentStatus= String.isBlank(requestObj.status) ? '':requestObj.status;
	        String searchText = String.isBlank(requestObj.term) ? '':requestObj.term;
	        String excludeType = getExcludeContentType(requestObj.excludeType);
	        String peopleId = requestObj.peopleId;
			String contentSubType = requestObj.contentSubType;
			String contribution = requestObj.contribution;
	        String authorId= String.isBlank(requestObj.peopleId) ? null:requestObj.peopleId;
	        String siteId = String.isBlank(requestObj.siteId) ? '':requestObj.siteId;
			Map<String, String> contToUnpubDateMap = new Map<String,String>();
        	Map<String, String> contToSubmitDateMap = new Map<String,String>();
	        if (String.isBlank(siteId) && !String.isBlank(requestObj.id)){
	        	siteId = requestObj.id;
	        }
	        logger.logDebug('AllContentDataServer.search()-----siteId----'+ siteId);
	        Integer size = requestObj.size != NULL ? Integer.valueOf(requestObj.size) : 0; 
	        Integer nextPageToken = String.isNotBlank(requestObj.nextPageToken)?Integer.valueOf(requestObj.nextPageToken):0;
	        if (!String.isblank(requestObj.sortBy) ){
				if(requestObj.sortBy.equalsIgnoreCase('publishedNewest') || requestObj.sortBy.equalsIgnoreCase('publishedOldest')){
		            order = requestObj.sortBy.equalsIgnoreCase('publishedNewest') ? 'DESC' : 'ASC';
		            orderBy = 'Is_Published__c desc, Publish_Start_DateTime__c ' + order + ', Last_Updated_DateTime__c ' + order + ', Created_DateTime__c ';
			
				}else if(requestObj.sortBy.equalsIgnoreCase('modifiedNewest') || requestObj.sortBy.equalsIgnoreCase('modifiedOldest')){
		            orderBy = 'Last_Updated_DateTime__c';
		            order = requestObj.sortBy.equalsIgnoreCase('modifiedNewest')? 'DESC' : 'ASC';
			
				}else if(requestObj.sortBy.equalsIgnoreCase('createdNewest') || requestObj.sortBy.equalsIgnoreCase('createdOldest')){
		            orderBy = 'Created_DateTime__c';
		            order = requestObj.sortBy.equalsIgnoreCase('createdNewest')? 'DESC' : 'ASC';
		        }
	        } else {
				orderBy = 'Created_DateTime__c ';
				order = 'DESC ';
	        	
			}
			String SearchForType='Content';
			List<ContentWrapper> contentWrapperList =null;
			List<Simpplr_Content__c> contentObjList = New List<Simpplr_Content__c>();
			if(SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(searchText)) {  
				Criteria.ExternalSearchReq contentCriteria = (Criteria.ExternalSearchReq)JSON.deserialize(data, Criteria.ExternalSearchReq.class);
				if(contentType!=null){
					if('page'.equalsIgnoreCase(contentType)){
						contentType='Page';
					}else if('event'.equalsIgnoreCase(contentType)){
						contentType='Event';
					}else if('album'.equalsIgnoreCase(contentType)){
						contentType='Album';
					}else if('blogpost'.equalsIgnoreCase(contentType)){
						contentType = 'BlogPost';
					}
				}

				if(String.isNotBlank(contentStatus)) {
					if('rejected'.equalsIgnoreCase(contentStatus)) {
						contentStatus = 'Rejected';
					} else if('draft'.equalsIgnoreCase(contentStatus)) {
						contentStatus = 'Draft';
					} else if('pending'.equalsIgnoreCase(contentStatus)) {
						contentStatus = 'Pending';
					} else if('published'.equalsIgnoreCase(contentStatus)) {
						contentStatus = 'Published';
					} else if('unpublished'.equalsIgnoreCase(contentStatus)) {
						contentStatus = 'Unpublished';
					}
				}

				contentCriteria.siteId = null;

				if(String.isNotBlank(requestObj.siteId)) {
					contentCriteria.siteId = requestObj.siteId;
				}

				if('contributedByMe'.equalsIgnoreCase(requestObj.contribution)) {
					List<String> contentIdList = new List<String>();
					List<Content_Audit_Trail__c> contentAuditTrailList = [Select Content__c, Content__r.Id from Content_Audit_Trail__c where Action_By__c =: loggedInPeopleId WITH SECURITY_ENFORCED];
					for(Content_Audit_Trail__c contentAuditTrailObj : contentAuditTrailList) {
						contentIdList.add(contentAuditTrailObj.Content__r.Id);
					}
					contentCriteria.contentContributed = contentIdList;
				}

				contentCriteria.contentType= contentType;
				contentCriteria.status= contentStatus;
				contentCriteria.authorId= authorId;
				contentCriteria.sortBy = requestObj.sortBy;
				contentCriteria.pageCategory = requestObj.category;
				ExternalSearchService externalSearchServiceObj=new ExternalSearchService();
				ExternalSearchWrapper.TopContentsWrapper returnWrapperObj=externalSearchServiceObj.searchContents(contentCriteria, SearchForType);
				List<String> contentIds = new List<String>();
				if(returnWrapperObj.listOfItems != null && returnWrapperObj.listOfItems.size() > 0) {
					contentIds = getContentIdsFromAWSResponse(returnWrapperObj.listOfItems, contentCriteria);
				}
				contentObjList = getContentDataFromSF(contentIds, orderBy, order);
			}
			else {
				if('all'.equalsIgnoreCase(requestObj.type) || String.isBlank(requestObj.type) || 'content'.equalsIgnoreCase(requestObj.type)){
					contentObjList = getContentListFromCriteria(contentId,siteId,searchText,requestObj.status,orderBy ,order,size,nextPageToken,sitesIManageContentOrSiteIManageSet, requestObj.filter, excludeType, peopleId, contentSubType, contribution, requestObj.category); 
				}
				else if(ServiceConstants.TYPE_PAGE.equalsIgnoreCase(requestObj.type)){
					PageDao pageDaoObj = new PageDao();
					contentObjList = pageDaoObj.getContentListFromCriteria(siteId,searchText,requestObj.status,orderBy ,order,requestObj.size,nextPageToken,sitesIManageContentOrSiteIManageSet,isAppModerator, requestObj.filter,requestObj.category, peopleId, contentSubType, contribution);                                          
				}
				else if(ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(requestObj.type)){
					BlogDao blogDaoObj = new BlogDao(); 
					contentObjList = blogDaoObj.getBlogList(siteId,searchText,requestObj.status,orderBy ,order,requestObj.size,nextPageToken,sitesIManageContentOrSiteIManageSet,isAppModerator, requestObj.filter, peopleId, contribution);                                          
				}
				else if(ServiceConstants.TYPE_EVENT.equalsIgnoreCase(requestObj.type)){
					EventDao eventDaoObj = new EventDao();
					contentObjList = eventDaoObj.getContentListFromCriteria(siteId,searchText,requestObj.status,orderBy ,order,requestObj.size,nextPageToken,sitesIManageContentOrSiteIManageSet,isAppModerator, requestObj.filter, peopleId, contribution);                                          
				}
				else if(ServiceConstants.TYPE_ALBUM .equalsIgnoreCase(requestObj.type)){
					AlbumDao albumDaoObj = new AlbumDao();
					contentObjList = albumDaoObj.getContentListFromCriteria(siteId,searchText,requestObj.status,orderBy ,order,requestObj.size,nextPageToken,sitesIManageContentOrSiteIManageSet,isAppModerator, requestObj.filter, peopleId, contribution);                                          
				}

			}

			Map<String,Integer> contentIdToAudienceCountMap = new Map<String,Integer>();
			if('must_read'.equalsIgnoreCase(requestObj.filter)){
				contentIdToAudienceCountMap = new ManageContentDao().getContentIdToAudienceCountMap(contentObjList);
			}
			
			contentWrapperList = contentListToLightWrapper(contentObjList, contentIdToAudienceCountMap);
			contToUnpubDateMap = getContentToDateMap(contentObjList, 'Unpublished');
            contToSubmitDateMap = getContentToDateMap(contentObjList, 'Submitted');
			if(!contToUnpubDateMap.isEmpty() || !contToSubmitDateMap.isEmpty()) {
                for(ContentWrapper conWrapper : contentWrapperList) {
                    if(contToUnpubDateMap.containsKey(conWrapper.contentId)) {
                        conWrapper.unpublishedAt = contToUnpubDateMap.get(conWrapper.contentId);
                    }
                    if(contToSubmitDateMap.containsKey(conWrapper.contentId)) {
                        conWrapper.submittedAt = contToSubmitDateMap.get(conWrapper.contentId);
                    }
                }
            }
			nextPageToken = contentWrapperList.size() < size ? null : nextPageToken + size;
	        Map<String,Object> result = New Map<String,Object>();
	        result.put('listOfItems',contentWrapperList);
	        result.put('nextPageToken',nextPageToken);
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
			
		} catch(Exception e){
			logger.logError('AllContentDataServer.search()-----could not retrieve data----',e);
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return resultWrapper;
    }
    
    @TestVisible private ResponseWrapper getFavoriteContents(String data) {
    	logger.logDebug('AllContentDataServer.getFavoriteContents()---data---' + data);
    	ResponseWrapper resultWrapper = New ResponseWrapper();
    	try {
    		Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data, Type.forName('Map<String,String>'));
        	String contentType = requestDataMap.get('type');
        	String searchText = requestDataMap.get('term');
        	String excludeType = getExcludeContentType(requestDataMap.get('excludeType'));
        	
        	Integer size = String.isNotBlank(requestDataMap.get('size'))?Integer.valueOf(requestDataMap.get('size')):0;
			Integer recordLimit = size + 1;
        	Integer offsetVal = String.isNotBlank(requestDataMap.get('nextPageToken'))?Integer.valueOf(requestDataMap.get('nextPageToken')):0;
        	
        	String conditionString = ' Where People__c =:loggedInPeopleId ';
	        conditionString += ' And Simpplr_Content__r.TYPE__c IN : allowedFeaturesInAppList';
	        if(String.isNotBlank(excludeType)) {
	        	conditionString += ' And Simpplr_Content__r.TYPE__c != :excludeType';
	        }
        	conditionString += ' And Simpplr_Content__r.Is_Deleted__c = false';
        	conditionString += ' AND Simpplr_Content__r.Activated_By_Feature__c = true';
        	conditionString += ' And ((Simpplr_Content__r.Site__r.is_Active__c = true And Simpplr_Content__r.Site__r.Show_In_Simpplr__c = true) or Simpplr_Content__r.type__c = \'BlogPost\') ';
        	conditionString += ' AND Simpplr_Content__r.Is_Published__c = true ';
        	conditionString += ' AND Is_Deleted__c = false ';
	        List<String> listOfContentIds=new List<String>();
			List<Bookmark__c> listOfBookmarks=new List<Bookmark__c>();
			List<ContentWrapper> contentWrapperList=new List<ContentWrapper>();
			Integer nextPageToken;
			if(SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(searchText)) {  
				Criteria.ExternalSearchReq contentCriteria = (Criteria.ExternalSearchReq)JSON.deserialize(data, Criteria.ExternalSearchReq.class);
				if(contentType!=null){
					if('page'.equalsIgnoreCase(contentType)){
						contentType='Page';
					}else if('event'.equalsIgnoreCase(contentType)){
						contentType='Event';
					}else if('album'.equalsIgnoreCase(contentType)){
						contentType='Album';
					}else if('blogpost'.equalsIgnoreCase(contentType)){
						contentType = 'BlogPost';
					}
				}
				contentCriteria.contentType= contentType;
				contentCriteria.filter= FILTER_FAVORITES;
				String SearchForType='Content';
				String subConditionString = ' Order by LastModifiedDate Desc ';
				if(recordLimit != null && recordLimit > 0){
					subConditionString+=' LIMIT :recordLimit';
				}
				if(offsetVal != null && offsetVal > 0){
					subConditionString+=' OFFSET :offsetVal';
				}
				String contents='';
				String bookmarQuery  =  ' Select Simpplr_Content__c from Bookmark__c '+ conditionString +' and Simpplr_Content__c!=:contents '+ subConditionString;
				logger.logDebug('AllContentDataServer.getFavoriteContents()----bookmarQuery----' + bookmarQuery);
										
				listOfBookmarks = Database.query(bookmarQuery);	
				List<String> ids= new List<String>();
				for(Bookmark__c bookmarkObj:listOfBookmarks) {
					ids.add(bookmarkObj.Simpplr_Content__c);
				} 
				contentCriteria.ContentIds= ids;
				ExternalSearchService externalSearchServiceObj=new ExternalSearchService();
				ExternalSearchWrapper.TopContentsWrapper returnWrapperObj=externalSearchServiceObj.searchContents(contentCriteria, SearchForType);
				if(returnWrapperObj.listOfItems != null && returnWrapperObj.listOfItems.size() > 0) {
					listOfContentIds = getContentIdsFromAWSResponse(returnWrapperObj.listOfItems, contentCriteria);
				}
				String query = ' SELECT ' + String.join(getContentFieldList(),',') + ' FROM Simpplr_Content__c where id=:listOfContentIds';
				logger.logDebug('AllContentDataServer.getFavoriteContents()----query----' + query);
				List<Simpplr_Content__c> ListContents =Database.query(query);	   
				contentWrapperList = contentListToLightWrapper(ListContents, null);
				
				nextPageToken=returnWrapperObj.nextPageToken!=null?Integer.valueOf(returnWrapperObj.nextPageToken):0;
			
			}else{

				if(String.isNotBlank(searchText)) {
					Set<String> setOfSearchTerms = Utility.getSearchTokens(String.escapeSingleQuotes(searchText));
					conditionString += getSearchTermCondition(setOfSearchTerms, 'Simpplr_Content__r.Title__c');
				}

				if(String.isNotBlank(contentType) && !'All'.equalsIgnoreCase(contentType)) {
					conditionString += ' And Simpplr_Content__r.TYPE__c=:contentType ';
				}
				
				String subConditionString = ' Order by LastModifiedDate Desc ';
				if(recordLimit != null && recordLimit > 0){
					subConditionString+=' LIMIT :recordLimit';
				}
				if(offsetVal != null && offsetVal > 0){
					subConditionString+=' OFFSET :offsetVal';
				}
				
				String bookmarQuery  =  ' Select Simpplr_Content__c from Bookmark__c  ' + conditionString + subConditionString;
				logger.logDebug('AllContentDataServer.getFavoriteContents()----bookmarQuery----' + bookmarQuery);
										
				listOfBookmarks = Database.query(bookmarQuery);	
				listOfContentIds = new List<String>();
				for(Bookmark__c bookmarkObj:listOfBookmarks) {
					listOfContentIds.add(bookmarkObj.Simpplr_Content__c);
				} 
				
				String query = ' SELECT ' + String.join(getContentFieldList(),',') + ' FROM Simpplr_Content__c where id=:listOfContentIds';
				logger.logDebug('AllContentDataServer.getFavoriteContents()----query----' + query);
				Map<Id, Simpplr_Content__c>	mapOfContents = new Map<Id, Simpplr_Content__c>((List<Simpplr_Content__c>)Database.query(query));	   
				List<Simpplr_Content__c> sortedContentList = new List<Simpplr_Content__c>();
				for(Bookmark__c bookmarkObj:listOfBookmarks) {
					if(mapOfContents.containsKey(bookmarkObj.Simpplr_Content__c)) {
						sortedContentList.add(mapOfContents.get(bookmarkObj.Simpplr_Content__c));
					}
				}
				contentWrapperList = contentListToLightWrapper(sortedContentList, null);
				if (contentWrapperList.size() == (size + 1) && offsetVal < 2000) {
					contentWrapperList.remove((contentWrapperList.size()-1));
					nextPageToken = offsetVal + size;
				}
			}
	        
	        Map<String,Object> result = New Map<String,Object>();
	        result.put('listOfItems',contentWrapperList);
	        result.put('nextPageToken',nextPageToken) ;
	    	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
	    				   
	    } catch(Exception e){
			logger.logError('AllContentDataServer.getFavoriteContents()-----could not retrieve data----',e);
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
    	}
    	return resultWrapper;
    }
	
	public ResponseWrapper getContentMustReadForUser(String data) {
    	logger.logDebug('AllContentDataServer.getContentMustReadForUser()---data---' + data);
    	ResponseWrapper resultWrapper = New ResponseWrapper();
    	
    	try{
    		Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data, Type.forName('Map<String,String>'));
    		
    		String sortBy = requestDataMap.get('sortBy');
    		String filter = requestDataMap.get('filter');
			String searchToken = requestDataMap.get('term');
			String siteId = requestDataMap.get('siteId');
        	String excludeType = getExcludeContentType(requestDataMap.get('excludeType'));
        	Integer size = String.isNotBlank(requestDataMap.get('size'))?Integer.valueOf(requestDataMap.get('size')):0;
        	Integer recordLimit = size + 1;
        	Boolean queryUnreadFlag = true;
        	Boolean queryReadFlag = false;
        	String nextPageToken = String.isNotBlank(requestDataMap.get('nextPageToken'))?
        			String.valueOf(requestDataMap.get('nextPageToken')):'0';
        			
        	if (String.isNotBlank(nextPageToken) && nextPageToken.contains(':')) {
        		String afterColonStr = nextPageToken.substringAfter(':');
        		String beforeColonStr = nextPageToken.substringBefore(':');
        		
        		if (String.isNotBlank(afterColonStr)) {
        			queryUnreadFlag = false; 
        			queryReadFlag = true;
        			nextPageToken = afterColonStr;
        		} else {
        			nextPageToken = beforeColonStr;
        		}
        	}
        	
        	Integer offsetVal = String.isNotBlank(nextPageToken)? Integer.valueOf(nextPageToken):0;
        	Set<String> setOfSearchTerms = String.isNotBlank(searchToken) ? Utility.getSearchTokens(String.escapeSingleQuotes(searchToken)) : null;
			Set<Id> sitesIFollowIdSet = UserContext.sitesIFollowIdSet;
			String conditionString;
			if(String.isNotBlank(siteId)) {
				conditionString = ' Is_Deleted__c = false AND Is_Published__c = true  AND Site__c=:siteId AND id IN (SELECT Content__c FROM Must_Read_Audit__c WHERE Removed_DateTime__c = null  AND (Expiry_DateTime__c = null OR Expiry_DateTime__c >: currentDateTime)) ';
			} else {
				conditionString = ' Is_Deleted__c = false AND Is_Published__c = true  AND id IN (SELECT Content__c FROM Must_Read_Audit__c WHERE Removed_DateTime__c = null  AND (Expiry_DateTime__c = null OR Expiry_DateTime__c >: currentDateTime) AND  ( Audience_Type__c=\'everyone\' OR Content__r.Site__c=:sitesIFollowIdSet)) ';
			}

			if('unread'.equalsIgnoreCase(filter)) {
				conditionString += ' AND Id not in ( select Content__c from Must_Read_Confirm_History__c ' + 
								   ' Where People__c =:loggedInPeopleId And Must_Read_Audit__r.Removed_DateTime__c = null AND (Must_Read_Audit__r.Expiry_DateTime__c = null OR Must_Read_Audit__r.Expiry_DateTime__c >: currentDateTime) )';
			}
		
        	
        	conditionString += ' AND Activated_By_Feature__c = true';
        	conditionString += ' And TYPE__c IN : allowedFeaturesInAppList ';
        	
        	if(String.isNotBlank(excludeType)) {
	        	conditionString += ' And TYPE__c != :excludeType';
	        }
        	
        	String subConditionString = ' Order By Publish_Start_DateTime__c Desc, Last_Updated_DateTime__c desc ';
	        
	        if(recordLimit != null && recordLimit > 0){
	            subConditionString+=' LIMIT :recordLimit';
	        }
	        
	        if(offsetVal != null && offsetVal > 0){
	            subConditionString+=' OFFSET :offsetVal';
	        }	 
	               
	        String unreadConditionStr;
	    	String readConditionStr;
	    	List<Simpplr_Content__c> listOfMustReadContents = new List<Simpplr_Content__c>();
	    	List<ContentWrapper> contentWrapperList = new List<ContentWrapper>();
			
			Map<Id, Site_Role__c> mapofSiteIdAndSiteRole = new Map<Id, Site_Role__c>();
			mapofSiteIdAndSiteRole = UserContext.mySiteRolesMap;

	    	//logic to put unread first and then the read ones
	    	if ('unreadNewest'.equalsIgnoreCase(sortBy)) {
	    		
	    		unreadConditionStr = conditionString + ' AND Id not in ( select Content__c from Must_Read_Confirm_History__c'
	    				+' Where People__c =:loggedInPeopleId And Must_Read_Audit__r.Removed_DateTime__c = null AND (Must_Read_Audit__r.Expiry_DateTime__c = null OR Must_Read_Audit__r.Expiry_DateTime__c >: currentDateTime) )';
	    		readConditionStr = conditionString + ' AND Id in ( select Content__c from Must_Read_Confirm_History__c'
	    				+' Where People__c =:loggedInPeopleId And Must_Read_Audit__r.Removed_DateTime__c = null AND (Must_Read_Audit__r.Expiry_DateTime__c = null OR Must_Read_Audit__r.Expiry_DateTime__c >: currentDateTime) )';		 
	    		unreadConditionStr += getSearchTextCondition(setOfSearchTerms);
	        	readConditionStr += getSearchTextCondition(setOfSearchTerms);
	        	String queryUnread = ' SELECT ' + String.join(getContentFieldList(),',') + ' FROM Simpplr_Content__c '
	        			+ 'Where ' + unreadConditionStr + subConditionString;
        		String queryRead = ' SELECT ' + String.join(getContentFieldList(),',') + ' FROM Simpplr_Content__c '
        				+ 'Where ' + readConditionStr + subConditionString;
        		
        		// if there is still unread must read
        		if (queryUnreadFlag) {

					List<Simpplr_Content__c> listOfAllMustReadContents = new List<Simpplr_Content__c>();
					listOfAllMustReadContents = Database.query(queryUnread);

					for(Simpplr_Content__c contentObj : listOfAllMustReadContents) {
						if (contentObj.Must_Read_Audits__r.isEmpty() == false) {
							for(Must_Read_Audit__c mustReadObj : contentObj.Must_Read_Audits__r) {
								if ((mustReadObj.Expiry_DateTime__c == null || 
									mustReadObj.Expiry_DateTime__c>DateTime.now()) && 
									mustReadObj.Removed_DateTime__c == null) {
									if(mustReadObj.Audience_Type__c == 'site_members') {
										Site_Role__c siteRoleForContentSite = mapofSiteIdAndSiteRole.get(contentObj.Site__c);
										if(siteRoleForContentSite != null && siteRoleForContentSite.Is_Member__c == true) {
											listOfMustReadContents.add(contentObj);
										}
									} else {
										listOfMustReadContents.add(contentObj);
									}
								}
							}
						}

					}
        			
        			// if we have more records than offset then keep querying Unread
        			if (listOfMustReadContents.size() == recordLimit) {
        				listOfMustReadContents.remove((listOfMustReadContents.size()-1));
        				contentWrapperList = contentListToLightWrapper(listOfMustReadContents, null);
	        			nextPageToken = String.valueOf(offsetVal + size)+':';
	        			
        			// else if Unread has finised and we need more records to meet the page size 
        			//then query the read mustreads with the help of below queryReadFlag
	        		} else if (listOfMustReadContents.size() < size ) {
	        			queryUnreadFlag = false; 
	        			queryReadFlag = true;
	        			offsetVal = 0;
	        			recordLimit = recordLimit - listOfMustReadContents.size();
	        			
        			// else size of Unread is exactly same as the page size then put the nextpage token
        			// in a way that in next hit we need to query the READ mustreads
        			} else if (listOfMustReadContents.size() == size) {	
	        			contentWrapperList = contentListToLightWrapper(listOfMustReadContents, null);
	        			offsetVal = 0;
	        			
	        			// if there are READ records then set nextPage token to ':0' 
	        			if (Database.query(queryRead).size() > 0) {
	        				nextPageToken = ':0';
	        			
	        			// else if there are no records of READ then just set nextpageToken to null	
	        			} else {
	        				nextPageToken = null;
	        			}		
	        		} 
        		}
        	    
        	    // if we need to query READ to meet the page size
        		if (queryReadFlag) {
        			listOfMustReadContents.addAll((List<Simpplr_Content__c>) Database.query(queryRead));
        			contentWrapperList = contentListToLightWrapper(listOfMustReadContents, null);
        			
        			// if there are more records than page size
        			if (contentWrapperList.size() == (size + 1)) {
        				contentWrapperList.remove(contentWrapperList.size()-1);
        				
        				// if came here directly without going to UNREAD block 
        				if (recordLimit == (size - 1) ) {
        					nextpageToken = ':'+ String.valueOf(offsetVal + size);
        				
        				// else came here to meet page size after finishing UNREAD list	
        				} else {
        					nextpageToken = ':'+ String.valueOf(recordLimit -1);
        				}
        			// met the page size and now no need to query more.	
        			} else {
        				nextPagetoken = null;
        			}
        		}
	    	} else {
	    		
	    		conditionString += getSearchTextCondition(setOfSearchTerms);
		        String query = ' SELECT ' + String.join(getContentFieldList(),',') + ' FROM Simpplr_Content__c '
		        		+ 'Where ' +conditionString + subConditionString;
		        
				logger.logDebug('AllContentDataServer.getContentMustReadForUser()----query----' + query);

				List<Simpplr_Content__c> listOfAllMustReadContents = new List<Simpplr_Content__c>();
				listOfAllMustReadContents = Database.query(query);

				for(Simpplr_Content__c contentObj : listOfAllMustReadContents) {
					if(contentObj.Must_Read_Audits__r != null) {
						for(Must_Read_Audit__c mustReadObj : contentObj.Must_Read_Audits__r) {
							if(mustReadObj.Removed_By_People__c == null) {
								if(mustReadObj.Audience_Type__c == 'site_members') {
									Site_Role__c siteRoleForContentSite = mapofSiteIdAndSiteRole.get(contentObj.Site__c);
									if(siteRoleForContentSite != null && siteRoleForContentSite.Is_Member__c == true) {
										listOfMustReadContents.add(contentObj);
									}
								} else {
									listOfMustReadContents.add(contentObj);
								}
							}
						}
					}

				}

		    	contentWrapperList = contentListToLightWrapper(listOfMustReadContents, null);
		    	
		    	if (contentWrapperList.size() == recordLimit) {
		    		contentWrapperList.remove(contentWrapperList.size()-1);
		    		nextPageToken = String.valueOf(offsetVal + size);
		    	} else {
		    		nextPageToken = null;
		    	}
		    	
	    	}
	    	
	        Map<String,Object> result = New Map<String,Object>();
	        result.put('listOfItems',contentWrapperList);
	        result.put('nextPageToken',nextPageToken);
	    	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
        		        
    	}
    	catch(Exception e){
    		logger.logError('AllContentDataServer.getContentMustReadForUser()-----could not retrieve data----',e);
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
    	}
    	return resultWrapper;
    }
    
    @TestVisible public ResponseWrapper getLatestContents(String data) {
	    	logger.logDebug('AllContentDataServer.getLatestContents()---data---' + data);
	    	ResponseWrapper resultWrapper = New ResponseWrapper();
	    	try {
	        	Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data, Type.forName('Map<String,String>'));
	        	String contentType = requestDataMap.get('type');
	        	String searchText = requestDataMap.get('term');
                String siteID = requestDataMap.get('siteId');
                String peopleId = requestDataMap.get('peopleId');
				Boolean isAllContent = requestDataMap.get('isAllContent') != null ? Boolean.valueOf(requestDataMap.get('isAllContent')) : false;
				peopleIdContext = requestDataMap.get('peopleIdContext') != null ? Boolean.valueOf(requestDataMap.get('peopleIdContext')) : false;

                if (String.isNotBlank(peopleId)) {
                    loggedInPeopleId = peopleId;
					PeopleDao peopleDaoObj = new PeopleDao();
					loggedInUserId = peopleDaoObj.getPeopleByPeopleId(peopleId).User__c;
                }

				DateTime publishStartDateTime = Utility.getDateTimeFilterValue(requestDataMap.get('publishStartDate'));
				DateTime maxAllowedEventEndDateTime = requestDataMap.get('maxAllowedEventEndDateTime') != null ? Utility.momentJSDateTimeStringToDateTime(requestDataMap.get('maxAllowedEventEndDateTime')) : null;
				String author = requestDataMap.get('authoredBy');
				Integer size = String.isBlank(requestDataMap.get('size')) ? SimpplrContext.simpplrDefaultPageSize 
																		  : Integer.valueOf(requestDataMap.get('size'));
	        	String excludeType = getExcludeContentType(requestDataMap.get('excludeType'));
	        	
	        	Integer recordLimit = size + 1;
	        	Integer offsetVal = String.isNotBlank(requestDataMap.get('nextPageToken'))?Integer.valueOf(requestDataMap.get('nextPageToken')):0;
	        	
				Criteria.ContentSearchFilter criteriaObj = new Criteria.ContentSearchFilter();
				criteriaObj.offset = offsetVal;
				criteriaObj.recordLimit = recordLimit;
				criteriaObj.siteId = siteID;
				criteriaObj.contentType = contentType;
				criteriaObj.excludeType = excludeType;
				criteriaObj.searchText = searchText;
				criteriaObj.sortBy = requestDataMap.get('sortBy');
				criteriaObj.publishStartDateTime = publishStartDateTime;
				criteriaObj.author = author;
				criteriaObj.maxAllowedEventEndDateTime = maxAllowedEventEndDateTime;
				criteriaObj.isAllContent = isAllContent;
				criteriaObj.futureEventsOnly = false;

				List<Simpplr_Content__c> contentObjList = getLatestContentList(criteriaObj);

		        List<ContentWrapper> contentWrapperList = new List<ContentWrapper>(); 
	
				Set<Id> sitesIManageIdSet = UserContext.sitesIManageIdSet;
				Set<Id> sitesIManageContentsIdSet = UserContext.sitesIManageContentsIdSet;
				Set<Id> usersIFollowIdSet = UserContext.usersIFollowIdSet;
				Set<String>  allowedFeaturesInAppSet = new  Set<String>();
				for(String feature : allowedFeaturesInAppList) {
			    	allowedFeaturesInAppSet.add(feature.toLowerCase());
			    }
			    ContentWrapper wrapperObj;
	            for(Simpplr_Content__c contentRecord : contentObjList){
	            	 wrapperObj = convertContentToWrapper(contentRecord,new Map<String,List<TopicAssignment>>(),sitesIManageIdSet,sitesIManageContentsIdSet,usersIFollowIdSet,allowedFeaturesInAppSet, null, new Map<Id, ContentDocument>()); 
	            	
	            	if(contentRecord.TopicAssignments.size()>0){
	            		wrapperObj.listOfTopics = new List<TopicWrapper>();
		            	for(TopicAssignment assignmentObj : contentRecord.TopicAssignments) {
		            		TopicWrapper followedTopicObj = new TopicWrapper();
		            		followedTopicObj.Id = assignmentObj.topicId;
		            		followedTopicObj.Name = assignmentObj.Topic.Name;
		            		followedTopicObj.isFollowing = true;
		            		followedTopicObj.url = PageContext.getPageURL(Pages.app)+'?u=/topic/'+followedTopicObj.Id + '/content';
		            		wrapperObj.listOfTopics.add(followedTopicObj);
		            	} 
	            	}
	        		contentWrapperList.add(wrapperObj);
	            }
		        Integer nextPageToken;
		        if (contentWrapperList.size() == recordLimit && offsetVal < 2000) {
			        	contentWrapperList.remove((contentWrapperList.size()-1));
			        	nextPageToken = offsetVal + size;
		        }
		        Map<String,Object> result = New Map<String,Object>();
		        result.put('listOfItems',contentWrapperList);
		        result.put('nextPageToken',nextPageToken);
		    		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
		    	
			} catch(Exception e){
				logger.logError('AllContentDataServer.getLatestContents()-----could not retrieve data----',e);
				resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
	    	}
    	return resultWrapper;
    }
    
    @TestVisible private ResponseWrapper getAuthoredByPeopleContents(String data) {
	    	logger.logDebug('AllContentDataServer.getAuthoredByPeopleContents()---data---' + data);
	    	ResponseWrapper resultWrapper = New ResponseWrapper();
	    	try {
	        	Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data, Type.forName('Map<String,String>'));
	        	String sortBy = requestDataMap.get('sortBy');
	        	String contentType = requestDataMap.get('type');
	        	String excludeType = getExcludeContentType(requestDataMap.get('excludeType'));
	        	String searchText = requestDataMap.get('term');
	        	String status = requestDataMap.get('status');
	        	String peopleId = requestDataMap.get('peopleId');
				Boolean includeTotal = false;
				if(requestDataMap.containsKey('includeTotal')) {
					includeTotal = Boolean.valueOf(requestDataMap.get('includeTotal'));
				}
	        	
				Integer pageSize = requestDataMap.get('size') == null ? SimpplrContext.simpplrDefaultPageSize : Integer.valueOf(requestDataMap.get('size'));
	        	Integer recordLimit = pageSize + 1;
	        	Integer offsetVal = String.isNotBlank(requestDataMap.get('nextPageToken'))?Integer.valueOf(requestDataMap.get('nextPageToken')):0;

	        	List<Simpplr_Content__c> contentObjList;
				if(SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotEmpty(searchText)) {
					sortBy = sortBy == null ? 'publishedNewest' : sortBy.equalsIgnoreCase('most_viewed') ? 'mostViewed' : sortBy.equalsIgnoreCase('most_liked') ? 'mostLiked' : sortBy;

					ExternalSearchService externalSearchService = new ExternalSearchService();
					Criteria.ExternalSearchReq contentSearchCriteria = new Criteria.ExternalSearchReq();
					contentSearchCriteria.term = searchText;
					contentSearchCriteria.filter = 'author';
					contentSearchCriteria.sortBy = sortBy;
					contentSearchCriteria.nextPageToken = requestDataMap.get('nextPageToken');
					contentSearchCriteria.contentType = contentType != null ? contentType.toLowerCase() : (excludeType != null && excludeType.equalsIgnoreCase('blogpost') ? 'content' : 'blogpost');
					List<String> contentIds = externalSearchService.getAuthoredByPeopleContentList(contentSearchCriteria);
	
					String query = 'SELECT '+String.join(getContentFieldList(),',')+' FROM Simpplr_Content__c WHERE Id IN :contentIds';
					logger.logDebug('AllContentDataServer.getAuthoredByPeopleContents()----query----'+query);
					contentObjList = Database.query(query);
				} else {
		        	contentObjList = getAuthoredByPeopleContentList(offsetVal, recordLimit, sortBy, contentType, excludeType, searchText, status, peopleId);  
				}

		        List<ContentWrapper> contentWrapperList = new List<ContentWrapper>(); 
			    ContentWrapper wrapperObj;
	
	
				Set<Id> sitesIManageIdSet = UserContext.sitesIManageIdSet;
				Set<Id> sitesIManageContentsIdSet = UserContext.sitesIManageContentsIdSet;
				Set<Id> usersIFollowIdSet = UserContext.usersIFollowIdSet;
				Set<String>  allowedFeaturesInAppSet = new  Set<String>();
				for(String feature : allowedFeaturesInAppList) {
			    	allowedFeaturesInAppSet.add(feature.toLowerCase());
			    }
			    
				for(Simpplr_Content__c contentRecord : contentObjList){
	            	wrapperObj = convertContentToWrapper(contentRecord, new Map<String,List<TopicAssignment>>(), usersIFollowIdSet, sitesIManageIdSet,sitesIManageContentsIdSet,allowedFeaturesInAppSet, null, new Map<Id, ContentDocument>()); 
 	         		contentWrapperList.add(wrapperObj);
	            }

		        Integer nextPageToken;
		        if (contentWrapperList.size() == recordLimit && offsetVal < 2000) { 
			        	contentWrapperList.remove((contentWrapperList.size()-1));
			        	nextPageToken = offsetVal + pageSize;
		        }
		        Map<String,Object> result = New Map<String,Object>();
		        result.put('listOfItems',contentWrapperList);
                result.put('nextPageToken',nextPageToken);
                
				if (includeTotal) {
                    
                    if (SimpplrContext.isFeatureEnabled('Full_External_Search')) {
                        Integer count  = new ExternalSearchService().getContentPublishedCount(peopleId);
                        result.put('totalRecords', count);

                    } else { 
                        ManageContentDao daoObj = new ManageContentDao();
                        result.put('totalRecords', daoObj.getContentPublishedCount(peopleId));
                    }

				}
		    		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
		    	
			} catch(Exception e){
				logger.logError('AllContentDataServer.getAuthoredByPeopleContents()-----could not retrieve data----',e);
				resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);

	    	}
    	return resultWrapper;
    } 

	@TestVisible private ResponseWrapper getContentsByTopic(String data) {
	    	logger.logDebug('AllContentDataServer.getContentsByTopic()---data---' + data);
	    	ResponseWrapper resultWrapper = New ResponseWrapper();
	    	try {
	        	Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data, Type.forName('Map<String,String>'));
	        	String sortBy = requestDataMap.get('sortBy');
	        	String contentType = requestDataMap.get('type');
	        	String excludeType = getExcludeContentType(requestDataMap.get('excludeType'));
	        	String searchText = requestDataMap.get('term');
	        	String status = requestDataMap.get('status');
	        	String topicId = requestDataMap.get('topicId');
	        	
				Integer pageSize = requestDataMap.get('size') == null ? SimpplrContext.simpplrDefaultPageSize : Integer.valueOf(requestDataMap.get('size'));

	        	Integer recordLimit = requestDataMap.get('size') == null ? SimpplrContext.simpplrDefaultPageSize + 1 : Integer.valueOf(requestDataMap.get('size')) + 1;
	        	Integer offsetVal = String.isNotBlank(requestDataMap.get('nextPageToken'))?Integer.valueOf(requestDataMap.get('nextPageToken')):0;
	        	
		        List<Simpplr_Content__c> contentObjList = getContentByTopicList(offsetVal, recordLimit, sortBy, contentType, excludeType, searchText, status, topicId);  

		        List<ContentWrapper> contentWrapperList = new List<ContentWrapper>(); 
			    ContentWrapper wrapperObj;
	
				Set<Id> sitesIManageIdSet = UserContext.sitesIManageIdSet;
				Set<Id> sitesIManageContentsIdSet = UserContext.sitesIManageContentsIdSet;
				Set<Id> usersIFollowIdSet = UserContext.usersIFollowIdSet;
				Set<String>  allowedFeaturesInAppSet = new  Set<String>();
				for(String feature : allowedFeaturesInAppList) {
			    	allowedFeaturesInAppSet.add(feature.toLowerCase());
			    }
			    	
	            for(Simpplr_Content__c contentRecord : contentObjList){
	            	 wrapperObj = convertContentToWrapper(contentRecord, new Map<String,List<TopicAssignment>>(), usersIFollowIdSet, sitesIManageIdSet, sitesIManageContentsIdSet, allowedFeaturesInAppSet, null, new Map<Id, ContentDocument>()); 
 	         		 contentWrapperList.add(wrapperObj);
	            }
		        Integer nextPageToken;
		        if (contentWrapperList.size() == recordLimit && offsetVal < 2000) { 
			        	contentWrapperList.remove((contentWrapperList.size()-1));
			        	nextPageToken = offsetVal + pageSize;
		        }
		        Map<String,Object> result = New Map<String,Object>();
		        result.put('listOfItems',contentWrapperList);
		        result.put('nextPageToken',nextPageToken);
		    		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
		    	
			} catch(Exception e){
				logger.logError('AllContentDataServer.getContentsByTopic()-----could not retrieve data----',e);
				resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
	    	}
    	return resultWrapper;
    }

	public List<Simpplr_Content__c> getContentByTopicList(Integer offset, Integer recordLimit, String sortBy, String contentType, String excludeType, String searchText, String status, String topicId) {
    	Set<Id> topicsIFollowIdSet = new Set<Id>();
    	
        String conditionString = ' Where Is_Deleted__c = false ';
        conditionString += ' AND Activated_By_Feature__c = true';
        conditionString += ' And TYPE__c IN : allowedFeaturesInAppList';	
        conditionString += ' AND (TYPE__c=\'BlogPost\' or (site__r.is_Active__c=true AND Site__r.Show_In_Simpplr__c = true)) ';
        conditionString += ' AND Is_Published__c = true';
        
        if(String.isNotBlank(contentType) &&!'all'.equalsIgnoreCase(contentType)){
        	 conditionString += ' And TYPE__c = : contentType';		
        } 
        
        if(String.isNotBlank(excludeType)) {
        	conditionString += ' And TYPE__c != :excludeType ';
        } 
        
        if(String.isNotBlank(searchText)) {
        	Set<String> setOfSearchTerms = Utility.getSearchTokens(String.escapeSingleQuotes(searchText));
            conditionString += getSearchTermCondition(setOfSearchTerms, 'Title__c');
        }

		DateTime minAllowedEventEndDateTime = DateTime.now();
    	conditionString += ' And ((Event_End_DateTime__c = null) OR (Event_End_DateTime__c >:minAllowedEventEndDateTime))';
        
		if(String.isNotBlank(topicId)){
			conditionString += ' And Id in (select EntityId from TopicAssignment where TopicId=: topicId ' +
	            				' And EntityType=\'Simpplr_Content\') ';
		}

        String subConditionString = '';

		if ('publishedNewest'.equalsIgnoreCase(sortBy)) {
        	subConditionString += ' Order By Publish_Start_DateTime__c Desc, Last_Updated_DateTime__c desc, Created_DateTime__c DESC '; 
        } else if ('most_liked'.equalsIgnoreCase(sortby)) {
        	subConditionString += ' Order by Likes__c desc, Last_Updated_DateTime__c desc '; 
        } else if ('most_viewed'.equalsIgnoreCase(sortby)) {
        	subConditionString += ' Order by Total_View_Count__c  desc, Last_Updated_DateTime__c desc '; 
        } else {
        	subConditionString += ' Order By Publish_Start_DateTime__c Desc, Last_Updated_DateTime__c desc, Created_DateTime__c DESC ';
        }
        
        if(recordLimit != null && recordLimit > 0){
            subConditionString+=' LIMIT :recordLimit';
        }
        if(offset != null && offset > 0){
            subConditionString+=' OFFSET :offset';
        }
        String query = ' SELECT ' + String.join(getContentFieldList(),',') + ' FROM Simpplr_Content__c ' + conditionString + subConditionString;
        
        logger.logDebug('AllContentDataServer.getContentByTopicList()----query----'+query);
        
        return Database.query(query);
    }    
    
    public List<Simpplr_Content__c> getLatestContentList(Criteria.ContentSearchFilter criteriaObj){
		Integer offset = criteriaObj.offset;
		Integer recordLimit = criteriaObj.recordLimit;
		String siteID = criteriaObj.siteId;
		String contentType = criteriaObj.contentType;
		String excludeType = criteriaObj.excludeType;
		String searchText = criteriaObj.searchText;
		String sortBy = criteriaObj.sortBy;
		DateTime publishStartDateTime = criteriaObj.publishStartDateTime;
		String author = criteriaObj.author;
		DateTime maxAllowedEventEndDateTime = criteriaObj.maxAllowedEventEndDateTime;
		Boolean isAllContent = criteriaObj.isAllContent;
		Boolean futureEventsOnly = criteriaObj.futureEventsOnly;

		Set<Id> topicsIFollowIdSet = new Set<Id>();
		Set<Id> userIdSet = new Set<Id>();
        Set<Id> siteIdSet = new Set<Id>();
		SiteDao siteDaoObj = new SiteDao();
		PeopleDao peopleDaoObj = new PeopleDao();
    	
        String conditionString = ' Where Is_Deleted__c = false ';
        conditionString += ' AND Activated_By_Feature__c = true';
        conditionString += ' AND Is_Published__c = true';
        conditionString += ' And TYPE__c IN : allowedFeaturesInAppList';
        if(String.isNotBlank(siteID) && !siteID.containsIgnoreCase('home')) {
        	conditionString += ' And Site__c =: siteID ';
        } else {
			if(!isAllContent){
				contentIdsForFollowingTopics = getContentIdSetForFollowedTopics(contentType);
				if(peopleIdContext){
					siteIdSet = siteDaoObj.sitesIFollowIdSet(loggedInUserId);
					userIdSet = peopleDaoObj.usersIFollowIdSet(loggedInUserId);
					topicsIFollowIdSet = siteDaoObj.topicsIFollowIdSet(loggedInUserId);
				}else{
					siteIdSet = UserContext.sitesIFollowIdSet;
					userIdSet = UserContext.usersIFollowIdSet;
					topicsIFollowIdSet = UserContext.topicsIFollowIdSet;
				}

				conditionString += ' AND ( ';
				conditionString += ' (TYPE__c=\'BlogPost\' And (Primary_Author__r.User__c IN :userIdSet OR Primary_Author__c =:loggedInPeopleId or Primary_Author__r.Is_Influencer__c = true)) ';
				conditionString += ' Or ';
				conditionString += ' (Site__c != null And site__r.is_Active__c=true And Site__r.Show_In_Simpplr__c = true And (site__c IN:siteIdSet or Primary_Author__c =:loggedInPeopleId)) ';
				conditionString += ' Or ';
				conditionString += ' Id IN :contentIdsForFollowingTopics';
				conditionString += ' ) ';
			}else{
				conditionString += ' AND ( ';
				conditionString += ' (TYPE__c=\'BlogPost\' And (Primary_Author__r.Is_Influencer__c = true)) ';
				conditionString += ' Or ';
				conditionString += ' (Site__c != null And site__r.is_Active__c=true And Site__r.Show_In_Simpplr__c = true)) ';
			}
        }
        
        if(String.isNotBlank(searchText)) {
        	Set<String> setOfSearchTerms = Utility.getSearchTokens(String.escapeSingleQuotes(searchText));
            conditionString += getSearchTermCondition(setOfSearchTerms, 'Title__c');
        }
        if(String.isNotBlank(contentType) && !'All'.equalsIgnoreCase(contentType)) {
        	conditionString += ' And TYPE__c = :contentType ';
        }
        
        if(String.isNotBlank(excludeType)) {
        	conditionString += ' And TYPE__c != :excludeType ';
		}
		
		if(publishStartDateTime != null){
			conditionString += ' And Publish_Start_DateTime__c >=: publishStartDateTime  ';
		}
		if(String.isNotBlank(author)) {
			conditionString += ' And primary_author__c =:author ';
		}        
        
        String subConditionString = '';
		DateTime minAllowedEventEndDateTime = DateTime.now();

		if(futureEventsOnly) {
			conditionString += ' And (Event_End_DateTime__c = NULL OR Event_End_DateTime__c >:minAllowedEventEndDateTime)';
		}
		
        if('Event'.equalsIgnoreCase(contentType)) {
			if(maxAllowedEventEndDateTime != null) {
				conditionString += ' And Event_Start_DateTime__c <: maxAllowedEventEndDateTime';
			}
			conditionString += ' And Event_End_DateTime__c >:minAllowedEventEndDateTime And Id Not IN(Select content__c from Event_RSVP_Response__c where is_deleted__c = false And RSVP_Response__c = \'No\' And People__c=:loggedInPeopleId)';
			subConditionString = ' Order By Event_Start_DateTime__c asc, Last_Updated_DateTime__c desc ';			
        } else {
        	subConditionString = ' Order By Publish_Start_DateTime__c Desc, Last_Updated_DateTime__c desc, Created_DateTime__c DESC ';
        }
        
        if(recordLimit != null && recordLimit > 0){
            subConditionString+=' LIMIT :recordLimit';
        }
        if(offset != null && offset > 0){
            subConditionString+=' OFFSET :offset';
        }
        String query = ' SELECT ' + String.join(getContentFieldList(),',') + ' ,(select TopicId, Topic.Name from TopicAssignments where EntityType=\'Simpplr_Content\'';
		if(!isAllContent){
			query +=  'and TopicId=:topicsIFollowIdSet';
		}
		query += ') FROM Simpplr_Content__c ' + conditionString + subConditionString;
        logger.logDebug('AllContentDataServer.getLatestContentList()----query----'+query);
        
        return Database.query(query);
    }
    
    public List<Simpplr_Content__c> getAuthoredByPeopleContentList(Integer offset, Integer recordLimit, String sortBy, String contentType, String excludeType, String searchText, String status, String peopleId) {
    	Set<Id> topicsIFollowIdSet = new Set<Id>();
    	
        String conditionString = ' Where Is_Deleted__c = false ';
        conditionString += ' AND Activated_By_Feature__c = true';
        conditionString += ' And TYPE__c IN : allowedFeaturesInAppList';	
        conditionString += ' AND (TYPE__c=\'BlogPost\' or (site__r.is_Active__c=true AND Site__r.Show_In_Simpplr__c = true)) ';
        if('published'.equalsIgnoreCase(status)){
        	conditionString += ' AND Is_Published__c = true';
        }	
        
        if(String.isNotBlank(contentType) &&!'all'.equalsIgnoreCase(contentType)){
        	 conditionString += ' And TYPE__c = : contentType';		
        } 
        
        if(String.isNotBlank(excludeType)) {
        	conditionString += ' And TYPE__c != :excludeType ';
        } 
        
        if(String.isNotBlank(searchText)) {
        	Set<String> setOfSearchTerms = Utility.getSearchTokens(String.escapeSingleQuotes(searchText));
            conditionString += getSearchTermCondition(setOfSearchTerms, 'Title__c');
        }
     	
        conditionString += ' AND  Primary_Author__c = :peopleId';  

    	Date todayDate = Date.today();
		DateTime minAllowedEventEndDateTime = DateTime.now();
    	conditionString += ' And ((Event_End_DateTime__c = null) OR (Event_End_DateTime__c >:minAllowedEventEndDateTime))';
        
        String subConditionString = '';

		if ('publishedNewest'.equalsIgnoreCase(sortBy)) {
        	subConditionString += ' Order By Publish_Start_DateTime__c Desc, Last_Updated_DateTime__c desc, Created_DateTime__c DESC '; 
        } else if ('most_liked'.equalsIgnoreCase(sortby)) {
        	subConditionString += ' Order by Likes__c desc, Last_Updated_DateTime__c desc '; 
        } else if ('most_viewed'.equalsIgnoreCase(sortby)) {
        	subConditionString += ' Order by Total_View_Count__c  desc, Last_Updated_DateTime__c desc '; 
        } else {
        	subConditionString += ' Order By Publish_Start_DateTime__c Desc, Last_Updated_DateTime__c desc, Created_DateTime__c DESC ';
        }
        
        if(recordLimit != null && recordLimit > 0){
            subConditionString+=' LIMIT :recordLimit';
        }
        if(offset != null && offset > 0){
            subConditionString+=' OFFSET :offset';
        }
        String query = ' SELECT ' + String.join(getContentFieldList(),',') + ' FROM Simpplr_Content__c ' + conditionString + subConditionString;
        
        logger.logDebug('AllContentDataServer.getAuthoredByPeopleContentList()----query----'+query);
        
        return Database.query(query);
    }
        
    @TestVisible private ResponseWrapper getAllContentUserCanAccess(String data) {
    	logger.logDebug('AllContentDataServer.getAllContentUserCanAccess()---data---' + data);
    	ResponseWrapper resultWrapper = New ResponseWrapper();
    	try {
        	Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data, Type.forName('Map<String,String>'));
        	String contentType = requestDataMap.get('type');
        	String searchText = requestDataMap.get('term');
        	String siteID = requestDataMap.get('siteId');
        	String excludeType = getExcludeContentType(requestDataMap.get('excludeType'));
        	
        	Integer recordLimit = SimpplrContext.simpplrDefaultPageSize + 1;
        	Integer offsetVal = String.isNotBlank(requestDataMap.get('nextPageToken'))?Integer.valueOf(requestDataMap.get('nextPageToken')):0;
        	
        	Set<Id> siteIdSet = UserContext.sitesIFollowIdSet;
        	Set<Id> userIdSet = UserContext.usersIFollowIdSet;

			List<Simpplr_Content__c> contentObjList;
			if(SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotEmpty(searchText)) {
				Set<String> setOfContentIds = new Set<String>();
				ExternalSearchService externalSearchService = new ExternalSearchService();
				Criteria.ExternalSearchReq contentSearchCriteria = (Criteria.ExternalSearchReq)JSON.deserialize(data, Criteria.ExternalSearchReq.class);
				ExternalSearchWrapper.TopContentsWrapper returnWrapper = externalSearchService.searchContents(contentSearchCriteria, 'Content');
				for(ExternalSearchWrapper.ItemWrapper itemWrap : returnWrapper.listOfItems) {
					if(((ContentWrapper)itemWrap.item).contentId != null) {
						setOfContentIds.add(((ContentWrapper)itemWrap.item).contentId);
					}
				}

				String query = 'SELECT '+String.join(getContentFieldList(),',')+' FROM Simpplr_Content__c WHERE Id IN :setOfContentIds';
				logger.logDebug('AllContentDataServer.getAllContentUserCanAccess()----query----'+query);
				contentObjList = Database.query(query);
			} else {
				String conditionString = ' Where Is_Deleted__c = false ';
				conditionString += ' AND Activated_By_Feature__c = true';
				conditionString += ' AND Is_Published__c = true';
				conditionString += ' And TYPE__c IN : allowedFeaturesInAppList';
				
				if(String.isNotBlank(excludeType)) {
					conditionString += ' And TYPE__c != :excludeType';
				}
				
				if(String.isNotBlank(siteID)) {
					conditionString += ' And Site__c =: siteID ';
					
				} else {
					conditionString += ' AND (TYPE__c=\'BlogPost\' or (site__r.is_Active__c=true AND Site__r.Show_In_Simpplr__c = true)) ';
					
				} 
				
				if(String.isNotBlank(searchText)) {
					Set<String> setOfSearchTerms = Utility.getSearchTokens(String.escapeSingleQuotes(searchText));
					conditionString += getSearchTermCondition(setOfSearchTerms, 'Title__c');
				}
				if(String.isNotBlank(contentType) && !'All'.equalsIgnoreCase(contentType) && !'content'.equalsIgnoreCase(contentType)) {
					conditionString += ' And TYPE__c=:contentType ';
				}
				
				String subConditionString = ' Order By Publish_Start_DateTime__c Desc, Last_Updated_DateTime__c desc ';
				if(recordLimit != null && recordLimit > 0){
					subConditionString+=' LIMIT :recordLimit';
				}
				if(offsetVal != null && offsetVal > 0){
					subConditionString+=' OFFSET :offsetVal';
				}
		
				String query = ' SELECT ' + String.join(getContentFieldList(),',') + ' FROM Simpplr_Content__c ' + conditionString + subConditionString;
				logger.logDebug('AllContentDataServer.getAllContentUserCanAccess()----query----'+query);
				contentObjList = Database.query(query);
			}
	        List<ContentWrapper> contentWrapperList = contentListToLightWrapper(contentObjList, null);
	        Integer nextPageToken;
	        if (contentWrapperList.size() == (SimpplrContext.simpplrDefaultPageSize + 1) && offsetVal < 2000) {
	        	contentWrapperList.remove((contentWrapperList.size()-1));
	        	nextPageToken = offsetVal + SimpplrContext.simpplrDefaultPageSize;
	        }
	        Map<String,Object> result = New Map<String,Object>();
	        result.put('listOfItems',contentWrapperList);
	        result.put('nextPageToken',nextPageToken);
	    	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
	    	
		} catch(Exception e){
			logger.logError('AllContentDataServer.getAllContentUserCanAccess()-----could not retrieve data----',e);
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
    	}
    	return resultWrapper;
	}
	
	private List<Simpplr_Content__c> getContentDataFromSF(List<String> contentIds, String orderByField, String order) {
		
		String query = 'SELECT '+String.join(getContentFieldList(),',')+' FROM Simpplr_Content__c WHERE id = :contentIds';
		if(String.isBlank(order)){
			order = 'DESC';
		}
		if(String.isNotBlank(orderByField)){
			query+=' ORDER BY '+orderByField+' '+order;
		}
        logger.logDebug('AllContentDataServer.getContentDataFromSF()----query----'+query);
        return Database.query(query); 
	}
    
    public List<Simpplr_Content__c> getContentListFromCriteria(String contentId,String siteId,String searchText,String status,String orderByField,String order,Integer recordLimit,Integer offsetVal,Set<Id> sitesIManageContentOrSiteIManageSet, String filter, String excludeType, String peopleId, String contentSubType, String contribution, String categoryId){
		logger.logDebug('AllContentDataServer.getContentListFromCriteria()----contentId----'+contentId+'----siteId----'+siteId+'----searchText----'+searchText+'----status----'+status+'----orderByField----'+orderByField+'----order----'+order+'----recordLimit----'+recordLimit+'----offsetVal----'+offsetVal+'----sitesIManageContentOrSiteIManageSet----'+sitesIManageContentOrSiteIManageSet+'----filter----'+filter);
		Set<Id> groupsIFollowIdSet = new Set<Id>();
        String thumbnail = 'thumbnail';
        String contentStatusPreDraft = ServiceConstants.CONTENT_STATUS_PREDRAFT;
        Boolean isPublished = false;
        Boolean isUnpublished = false;
        //to do - rmeove the fields that are not needed like the long text field here
        String conditionString = '';
        String subConditionString = '';
        String currentUserId = UserContext.id;
        conditionString += ' Is_Deleted__c = false ';
        conditionString += ' And Status__c !=: contentStatusPreDraft ';
        conditionString += ' And ((Site__c != null And Site__r.Is_Active__c = true And Site__r.Show_In_Simpplr__c = true) OR (Type__c=\'BlogPost\') )';
        conditionString += ' And Type__c IN : allowedFeaturesInAppList';
        Set<Id> sitesIFollowIdSet = UserContext.sitesIFollowIdSet;
		Set<String> contentIdSet = new Set<String>();
	
		Datetime expiryStartDateTime = null;
		Datetime expiry28DaysStartDateTime = null;
		Datetime expiry14DaysStartDateTime = null;

		Datetime expiry28DaysEndDate = null;
		Datetime expiry14DaysEndDate = null;
		Set<Id> sitesIManageOnboardingContentsIdSet = UserContext.sitesIManageOnboardingContentsIdSet;

		if(String.isNotBlank(excludeType)) {
        	conditionString += ' And Type__c != : excludeType';
        }
        
        if('updates'.equalsIgnoreCase(filter)){
			List<Id> listOfUserId = new List<Id>(UserContext.usersIFollowIdSet);
			conditionString += ' AND Status__c =\'Approved\' AND Is_Published__c = true';
			if(String.isNotBlank(siteId)){
	            conditionString+=' AND Site__c = :siteId'; 
	            conditionString+=' AND Activated_By_Feature__c = true'; 
	        }else{
				groupsIFollowIdSet = UserContext.chatterGroupsIFollowIdSet; 
				conditionString += ' AND ((Site__r.Chatter_Group_Id__c =:groupsIFollowIdSet) OR (Primary_Author__r.User__c IN :listOfUserId) OR (Primary_Author__c=:loggedInPeopleId))';
	        }
	        conditionString = !conditionString.equals('')?' WHERE'+conditionString : '';
	        subConditionString+=' Order by Last_Updated_DateTime__c desc';
	        
        }else{
			if (String.isNotBlank(contentId)){
	        	conditionString += ' AND Id =: contentId';
	        }
	        if (String.isNotBlank(peopleId)){
	        	conditionString += ' AND Primary_Author__c =: peopleId';
	        }
	        if('owned'.equalsIgnoreCase(filter)) {
	        	 conditionString += ' AND Primary_Author__c =: loggedInPeopleId';
	        } else if('managing'.equalsIgnoreCase(filter)) {
				if(!UserContext.hasModifyAllDataPermission) {
					String onboardingCondition = UserContext.isUserOnboardingManager ? ' Site__r.Site_Type__c = \'Public\' OR Site__c IN :sitesIFollowIdSet OR ' : '';
					if(isAppModerator){
						conditionString += ' AND (site__c IN :sitesIManageContentOrSiteIManageSet OR site__c IN :sitesIManageOnboardingContentsIdSet OR Site__r.Site_Type__c = \'Public\' OR Type__c=\'BlogPost\') ';
						
					} else {
						conditionString += ' AND (site__c IN :sitesIManageContentOrSiteIManageSet OR site__c IN :sitesIManageOnboardingContentsIdSet OR ' + onboardingCondition + ' (Type__c=\'BlogPost\' AND Primary_Author__c =: loggedInPeopleId)) ';

					}
				}
	        } else if('must_read'.equalsIgnoreCase(filter)) {
	        	conditionString += ' AND id IN (SELECT Content__c FROM Must_Read_Audit__c WHERE Removed_DateTime__c = null AND (Expiry_DateTime__c = null OR Expiry_DateTime__c >: currentDateTime) AND ( Audience_Type__c=\'everyone\' OR Content__r.Site__c=:sitesIFollowIdSet)) ';
	        } else if('canAddToCarousel'.equalsIgnoreCase(filter)) {
	        	status = ServiceConstants.STATUS_APPROVED;
			}
			if('contributedByMe'.equalsIgnoreCase(contribution)) {
				conditionString += ' AND id IN (Select Content__c from Content_Audit_Trail__c where Action_By__c =: loggedInPeopleId) ';
			}
	        
	        if(!isAppModerator && ('favorites'.equalsIgnoreCase(filter) == false) && ('canAddToCarousel'.equalsIgnoreCase(filter) == false)){
				String onboardingCondition = UserContext.isUserOnboardingManager ? ' Site__r.Site_Type__c = \'Public\' OR Site__c IN :sitesIFollowIdSet OR ' : '';
	            if(UserContext.hasManageUnlistedSitePermission) {
	            	if(sitesIManageContentOrSiteIManageSet != null && sitesIManageContentOrSiteIManageSet.size() > 0){
	            		conditionString += ' AND (' + onboardingCondition + 'site__r.Site_type__c=\'Unlisted\' OR site__c IN :sitesIManageContentOrSiteIManageSet OR site__c IN :sitesIManageOnboardingContentsIdSet OR Primary_Author__c =: loggedInPeopleId)';
	            	} else {
	            		conditionString += ' AND (' + onboardingCondition + 'site__r.Site_type__c=\'Unlisted\' OR site__c IN :sitesIManageOnboardingContentsIdSet OR Primary_Author__c =: loggedInPeopleId)';
	            	}
	            	
	            } else if(sitesIManageContentOrSiteIManageSet != null && sitesIManageContentOrSiteIManageSet.size() > 0){
	                conditionString += ' AND (' + onboardingCondition + 'site__c IN :sitesIManageContentOrSiteIManageSet OR site__c IN :sitesIManageOnboardingContentsIdSet OR Primary_Author__c =: loggedInPeopleId)';
	            } else {
	                conditionString += ' AND (' + onboardingCondition + 'site__c IN :sitesIManageOnboardingContentsIdSet OR Primary_Author__c =: loggedInPeopleId)';
	            }
	        }
	        if(String.isNotBlank(status) && !status.equalsIgnoreCase('all') ){
	            if(ServiceConstants.CONTENT_STATUS_PENDING.equalsIgnoreCase(status)){
	                status = ServiceConstants.CONTENT_STATUS_SUBMITTED;
	                conditionString+=' AND Status__c =:status';
	            } else if (ServiceConstants.CONTENT_STATUS_REJECTED.equalsIgnoreCase(status) ){
	                status = ServiceConstants.CONTENT_STATUS_REJECTED;
	                conditionString+=' AND Status__c =:status';
	            } else if (ServiceConstants.CONTENT_STATUS_PUBLISH.equalsIgnoreCase(status) ){
	                conditionString+=' AND Is_Published__c = true';
	            } else if (ServiceConstants.CONTENT_STATUS_UNPUBLISH.equalsIgnoreCase(status)){
	                conditionString+=' AND Is_Unpublished__c = true';
	            } else if (ServiceConstants.CONTENT_STATUS_DRAFT.equalsIgnoreCase(status) ){
	                status = ServiceConstants.CONTENT_STATUS_DRAFT;
	                conditionString+=' AND Status__c =:status ';
	            } else if (ServiceConstants.STATUS_APPROVED.equalsIgnoreCase(status) ){
	                conditionString+=' AND Status__c =:status ';
	            } else if (ServiceConstants.CONTENT_VALIDATION_EXPIRED.equalsIgnoreCase(status)){
					ManageContentDao daoObj = new ManageContentDao();
					contentIdSet = daoObj.getValidationExpiredLast14DaysContentIdSet();
	                
					conditionString += ' AND id IN :contentIdSet ';

	            } else if (ServiceConstants.CONTENT_VALIDATION_REQUIRED.equalsIgnoreCase(status)){
					Datetime currentTime = Datetime.now();
		
					expiryStartDateTime = currentTime.addMonths(- (SimpplrContext.validationPeriodMonth));
					expiry28DaysStartDateTime = expiryStartDateTime.addDays(28);
					expiry14DaysStartDateTime = expiryStartDateTime.addDays(14);

					expiry28DaysEndDate = currentTime.addDays(28);
					expiry14DaysEndDate = currentTime.addDays(14);

					conditionString += ' AND Id not in (SELECT content__c from Content_Audit_Trail__c ' +
													'WHERE Action__c=\'Validation Require Dismissed\' ' +
													'AND Action_DateTime__c=LAST_N_DAYS: 14) ';
					if(UserContext.isUserAppModerator){
						conditionString += ' AND type__c = \'Page\' AND Content_Sub_Type__c = \'knowledge\' AND '
									+ ' Is_Published__c = true AND Is_Deleted__c = false AND '
									+'	( '
									+'		( '
									+'			(Publish_End_DateTime__c = null OR Publish_End_DateTime__c >= :expiry28DaysEndDate) AND  '
									+'			Primary_Author__c = :loggedInPeopleId AND (Site__c IN :sitesIManageContentOrSiteIManageSet OR Site__r.Site_Type__c = \'Public\') AND '
									+'			(  '
									+'				(Last_Validated_DateTime__c = null AND Publish_Start_DateTime__c <= :expiry28DaysStartDateTime) '
									+'				OR  '
									+'				(Last_Validated_DateTime__c != null AND Last_Validated_DateTime__c <= :expiry28DaysStartDateTime)  '
									+'	    	) '
									+'		) '
									+'		OR '
									+'		( '
									+'			(Publish_End_DateTime__c = null OR Publish_End_DateTime__c >= :expiry14DaysEndDate) AND  '
									+'			Primary_Author__c != :loggedInUserId AND (Site__c IN :sitesIManageContentOrSiteIManageSet OR Site__r.Site_Type__c = \'Public\') AND '
									+'			(  '
									+'				(Last_Validated_DateTime__c = null AND Publish_Start_DateTime__c <= :expiry14DaysStartDateTime) '
									+'				OR  '
									+'				(Last_Validated_DateTime__c != null AND Last_Validated_DateTime__c <= :expiry14DaysStartDateTime)  '
									+'	    	) '
									+'		) '
									+'	) ';
					} else {
						conditionString += ' AND type__c = \'Page\' AND Content_Sub_Type__c = \'knowledge\' AND '
									+ ' Is_Published__c = true AND Is_Deleted__c = false AND '
									+'  	( '
									+'  		( '
									+'  			(Publish_End_DateTime__c = null OR Publish_End_DateTime__c >= :expiry28DaysEndDate) AND  '
									+'  			Primary_Author__c = :loggedInUserId AND (Site__c IN :sitesIManageContentOrSiteIManageSet) AND '
									+'  			(  '
									+'  				(Last_Validated_DateTime__c = null AND Publish_Start_DateTime__c <= :expiry28DaysStartDateTime) '
									+'  				OR  '
									+'  				(Last_Validated_DateTime__c != null AND Last_Validated_DateTime__c <= :expiry28DaysStartDateTime)  '
									+'  	    	) '
									+'  		) '
									+'  		OR '
									+'  		( '
									+'  			(Publish_End_DateTime__c = null OR Publish_End_DateTime__c >= :expiry14DaysEndDate) AND  '
									+'  			Primary_Author__c != :loggedInUserId AND (Site__c IN :sitesIManageContentOrSiteIManageSet) AND '
									+'  			(  '
									+'  				(Last_Validated_DateTime__c = null AND Publish_Start_DateTime__c <= :expiry14DaysStartDateTime) '
									+'  				OR  '
									+'  				(Last_Validated_DateTime__c != null AND Last_Validated_DateTime__c <= :expiry14DaysStartDateTime)  '
									+'  	    	) '
									+'  		) '
									+'  	)';
					}					
	            } else if (ServiceConstants.CONTENT_STATUS_ORG_OR_SITE_ONBOARDING.equalsIgnoreCase(status) ){
					conditionString+=' AND (Content_Onboarding_Status__c = \'orgOnboarding\' OR Content_Onboarding_Status__c = \'siteOnboarding\') ';
				} else if (ServiceConstants.CONTENT_STATUS_ORG_ONBOARDING.equalsIgnoreCase(status) ){
					conditionString+=' AND Content_Onboarding_Status__c =\'orgOnboarding\' ';
				} else if (ServiceConstants.CONTENT_STATUS_SITE_ONBOARDING.equalsIgnoreCase(status) ){
					conditionString+=' AND Content_Onboarding_Status__c =\'siteOnboarding\' ';
				}
	        } else if (String.isNotBlank(status) && status.equalsIgnoreCase('all')){
	        	String draftStatus = ServiceConstants.CONTENT_STATUS_DRAFT;
	        	conditionString+=' AND (Status__c !=: draftStatus OR (Status__c =: draftStatus AND Primary_Author__c =: loggedInPeopleId))';
	        } 

	        if(String.isNotBlank(searchText)) {
				Set<String> setOfSearchTerms = Utility.getSearchTokens(String.escapeSingleQuotes(searchText));
	            conditionString += getSearchTermCondition(setOfSearchTerms, 'Title__c');
	        }
	        if(String.isNotBlank(siteId)){
	            conditionString+=' AND Site__c = :siteId';  
	        }
	        conditionString+=' AND Activated_By_Feature__c = true';
	        if(isAppModerator && !UserContext.hasModifyAllDataPermission) {
		        if('favorites'.equalsIgnoreCase(filter) || 
		        	(String.isBlank(siteId) && 'canAddToCarousel'.equalsIgnoreCase(filter))) {
					//User has access to content for Favorite Listing and Carousel
		        	
		        } else if(UserContext.hasManageUnlistedSitePermission) {
					groupsIFollowIdSet = UserContext.chatterGroupsIFollowIdSet;
	            	conditionString+=' AND ((Site__r.Chatter_Group_Id__c =:groupsIFollowIdSet And Primary_Author__c =: loggedInPeopleId) OR Site__r.Site_Type__c =\'Public\' OR Type__c=\'BlogPost\' OR site__c IN :sitesIManageContentOrSiteIManageSet OR site__c IN :sitesIManageOnboardingContentsIdSet OR site__r.Site_type__c=\'Unlisted\')';
	            	
	            } else  {
					groupsIFollowIdSet = UserContext.chatterGroupsIFollowIdSet;
					conditionString+=' AND ((Site__r.Chatter_Group_Id__c =:groupsIFollowIdSet And Primary_Author__c =: loggedInPeopleId) OR Site__r.Site_Type__c =\'Public\' OR Type__c=\'BlogPost\' OR site__c IN :sitesIManageContentOrSiteIManageSet OR site__c IN :sitesIManageOnboardingContentsIdSet)';
		        }
	        }

			if(String.isNotBlank(contentSubType)){
				conditionString += ' AND Content_Sub_Type__c = :contentSubType ';
			}
			if(String.isNotBlank(categoryId) && !'all'.equalsIgnoreCase(categoryId)) {
				conditionString += ' AND Pages_Category__c =: categoryId ';
			}

	        conditionString = !conditionString.equals('')?' WHERE'+conditionString : '';
	        
	        if(String.isBlank(order)){
	            order = 'DESC';
	        }
	        if(String.isNotBlank(orderByField)){
	            subConditionString+=' ORDER BY '+orderByField+' '+order;
	        }
        }
        if(recordLimit != null && recordLimit > 0){
            subConditionString+=' LIMIT :recordLimit';
        }
        if(offsetVal != null && offsetVal > 0){
            subConditionString+=' OFFSET :offsetVal';
        }

        String query = 'SELECT '+String.join(getContentFieldList(),',')+' FROM Simpplr_Content__c'+conditionString+subConditionString;
        logger.logDebug('AllContentDataServer.getContentListFromCriteria()----query----'+query);
        return Database.query(query); 
    }
    
	private String getSearchTermCondition(Set<String> setOfSearchTerms, String fieldToSearch){
		String queryStr = '';
		if (setOfSearchTerms != null) {
			for(String searchToken:setOfSearchTerms) {
				queryStr += ' And ' + fieldToSearch + ' like \'%' + searchToken + '%\' ';
			}
        }
        return queryStr;
	}
	
	private Map<Id, CollaborationGroup> cGMap{
		get {
	    	if(cGMap == null) {
	    		cGMap = Utility.getAllCollaborationGroupMap();
	    	}
	    	return cGMap;
	     }set; 
	}
	 
	private Set<Id> getContentIdSetForFollowedTopics(String contentType) {
	 	if(contentIdsForFollowingTopics == null) {
		 	contentIdsForFollowingTopics = new Set<Id>();
			SiteDao siteDaoObj = new SiteDao();
		 	Set<Id> topicIdSet;
			 if(peopleIdContext){
				topicIdSet = siteDaoObj.topicsIFollowIdSet(loggedInUserId);
			}else{
				topicIdSet = UserContext.topicsIFollowIdSet;
			}
		 	
		 	String query = 	' SELECT Id, Title__c FROM Simpplr_Content__c ' +
		 					' WHERE Status__c =\'Approved\' ' + 
							' AND Is_Published__c = true ' +
							' AND Is_Deleted__c = false ' +
							' And ((Site__c = null) OR (Site__r.Is_Active__c = true AND Site__r.Show_In_Simpplr__c = true)) ' +
							' AND Type__c IN :allowedFeaturesInAppList ' +
		 					' AND Id in (SELECT EntityId from TopicAssignment ' +
		 					' where TopicId in : topicIdSet AND entitytype=\'Simpplr_Content\') ';
		 	
			if(String.isNotBlank(contentType) && !'All'.equalsIgnoreCase(contentType) && !'content'.equalsIgnoreCase(contentType)) {
	       		query += 	' And TYPE__c=:contentType ';
			}				
		 	List<Simpplr_Content__c> contentObjList = Database.query(query);
		 	
		 	for(Simpplr_Content__c contentObj : contentObjList) {
		 		contentIdsForFollowingTopics.add(contentObj.Id);
		 	}
	 	}
	 	
	 	return contentIdsForFollowingTopics;
	}
	
	private String getContentStatus(String dbStatus, Boolean isPublished, Boolean isUnpublished) {
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

	private Boolean checkIfContentScheduled(String status, DateTime publishStartDateTime) {
		Boolean isScheduled = false;
		if(ServiceConstants.CONTENT_STATUS_UNPUBLISH.equalsIgnoreCase(status) && publishStartDateTime != null) {
			DateTime cutoffDateTime = currentDateTime.addYears(5);
			isScheduled = publishStartDateTime > currentDateTime && publishStartDateTime < cutoffDateTime;
		}
		return isScheduled;
	}
	 
	 
	@TestVisible  private ResponseWrapper searchContentForAddingInNewsltter(String requestDate,String filter) {
    	ResponseWrapper resultWrapper = New ResponseWrapper();
        try{
        	Map<String,Object> paramMap = (Map<String,Object>)JSON.deserializeUntyped(requestDate);
	        
	        String searchText = (String) paramMap.get('term');
	        String newsLetterSiteId = (String) paramMap.get('siteId');
	        String contentType = (String) paramMap.get('type');
	        String excludeType = getExcludeContentType((String)paramMap.get('excludeType'));
			String publishStartDateSpan = paramMap.containsKey('publishStartDateSpan') ? (String) paramMap.get('publishStartDateSpan') : 'anytime';
			String peopleId= paramMap.containsKey('peopleId') ? (String) paramMap.get('peopleId') : null;
	        Integer size = (Integer) paramMap.get('size');
	        Integer recordLimit = size+1;
	        Integer offsetVal = paramMap.get('nextPageToken') !=null ?Integer.valueOf(paramMap.get('nextPageToken')):0;
	        
            String orderByField = 'Publish_Start_DateTime__c desc,Last_Updated_DateTime__c desc, Created_DateTime__c DESC ';
			List<Simpplr_Content__c> contentObjList;

			Datetime publishStartDate;
			if('past_24_hours'.equalsIgnoreCase(publishStartDateSpan)){
				publishStartDate = DateTime.now().AddDays(-1);
			} else if('past_week'.equalsIgnoreCase(publishStartDateSpan)){
				publishStartDate = DateTime.now().AddDays(-7);
			} else if('past_month'.equalsIgnoreCase(publishStartDateSpan)){
				publishStartDate = DateTime.now().addMonths(-1);
			} else if('past_year'.equalsIgnoreCase(publishStartDateSpan)){
				publishStartDate = DateTime.now().addYears(-1);
			}


			if(SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotEmpty(searchText)) {
				Set<String> setOfContentIds = new Set<String>();
				ExternalSearchService externalSearchService = new ExternalSearchService();
				Criteria.ExternalSearchReq contentSearchCriteria = (Criteria.ExternalSearchReq)JSON.deserialize(requestDate, Criteria.ExternalSearchReq.class);
				contentSearchCriteria.authorId = peopleId; //this is also the autherId key from UI
				ExternalSearchWrapper.TopContentsWrapper returnWrapper = externalSearchService.searchContents(contentSearchCriteria, 'Content');
				for(ExternalSearchWrapper.ItemWrapper itemWrap : returnWrapper.listOfItems) {
					if(((ContentWrapper)itemWrap.item).contentId != null) {
						setOfContentIds.add(((ContentWrapper)itemWrap.item).contentId);
					}
				}

				String query = 'SELECT '+String.join(getContentFieldList(),',')+' FROM Simpplr_Content__c WHERE Id IN :setOfContentIds';
				if(publishStartDate != null){
					query += ' AND Publish_Start_DateTime__c > :publishStartDate';
				}
			
				logger.logDebug('AllContentDataServer.searchContentForAddingInNewsltter()----query----'+query); 
				contentObjList = Database.query(query);
			} else {
				contentObjList = getContentsFromCriteria(searchText, orderByField, recordLimit,offsetVal, newsLetterSiteId, contentType, excludeType, filter, publishStartDate, peopleId);
			}

	        List<ContentWrapper> contentWrapperList = contentListToLightWrapper(contentObjList, null);
	        Map<String,Object> result = New Map<String,Object>();
	        result.put('listOfItems',contentWrapperList);
	        if(contentWrapperList.size() == (size+1)){
		    	result.put('nextPageToken',String.valueOf(offsetVal + size));
		    	contentWrapperList.remove((contentWrapperList.size()-1));
		    } else{
		    	result.put('nextPageToken',null);
		    }
	    	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
		} catch(Exception e){
			logger.logError('AllContentDataServer.searchContentForAddingInNewsltter()-----could not retrieve data----',e);
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return resultWrapper;
    }
    
    public List<Simpplr_Content__c> getContentsFromCriteria(String searchText, String orderByField, Integer recordLimit,Integer offsetVal, String newsLetterSiteId, String contentType, String excludeType, String filter, Datetime publishStartDate, string peopleId){
        String thumbnail = 'thumbnail';
        Boolean isPublished = false;
        Boolean isUnpublished = false;
        //to do - rmeove the fields that are not needed like the long text field here
       
        String conditionString = '';
        conditionString +='  Is_Deleted__c = false';
        conditionString +='  AND Is_Published__c = true';
		conditionString += ' And ((Site__c != null And Site__r.Is_Active__c = true And Site__r.Show_In_Simpplr__c = true) OR (TYPE__c=\'BlogPost\') )';
		conditionString += ' And TYPE__c IN : allowedFeaturesInAppList';
		if(String.isNotBlank(excludeType)) {
        	conditionString += ' And TYPE__c != :excludeType';
        }

		if(String.isNotBlank(peopleId)){
			conditionString += ' AND Primary_Author__c =: peopleId';
		}
        
        if(String.isNotBlank(contentType) && !'All'.equalsIgnoreCase(contentType) && !'content'.equalsIgnoreCase(contentType)) {
        	conditionString += ' And TYPE__c=:contentType ';
        }
    
        if(String.isNotBlank(searchText)){
            searchText = '%' + searchText + '%';
            conditionString+=' AND Title__c like:searchText';
        }

		if(publishStartDate != null){
			conditionString += ' AND Publish_Start_DateTime__c > :publishStartDate';
		}

        conditionString+=' AND Activated_By_Feature__c = true';
        
        if(FILTER_CAN_ADD_TO_NEWSLETTER_FROM_SITE.equalsIgnoreCase(filter) && String.isNotBlank(newsLetterSiteId)){
        	conditionString += ' AND site__c=:newsLetterSiteId';
        }else{
	        if(String.isBlank(newsLetterSiteId)){
	        	conditionString+=' AND (Site__r.Site_Type__c = \'Public\' OR TYPE__c=\'BlogPost\') ';
	        } else {
	        	conditionString+=' AND (Site__r.Site_Type__c = \'Public\' OR TYPE__c=\'BlogPost\' OR Site__c=:newsLetterSiteId)';
	        }
        }
        conditionString = !conditionString.equals('')?' WHERE'+conditionString : '';
        
        String subConditionString = '';
        if(String.isNotBlank(orderByField)){
            subConditionString+=' ORDER BY '+orderByField;
        }
        if(recordLimit != null && recordLimit > 0){
            subConditionString+=' LIMIT :recordLimit';
        }
        
        if(offsetVal!=null && offsetVal>0){
        	subConditionString+=' OFFSET :offsetVal';
        }
        String query = 'SELECT '+String.join(getContentFieldList(),',')+' FROM Simpplr_Content__c'+conditionString+subConditionString;
        
        logger.logDebug('AllContentDataServer.getContentsFromCriteria()----query----'+query);
        return Database.query(query); 
    }
    
    private ContentWrapper convertContentToWrapper (Simpplr_Content__c contentRecord, 
    		Map<String,List<TopicAssignment>> contentIdWithTopicListMap, Set<Id> usersIFollowIdSet, 
			Set<Id> sitesIManageIdSet, Set<Id> sitesIManageContentsIdSet, Set<String> allowedFeaturesInAppSet, 
			Map<String,Integer> contentIdToAudienceCountMap, Map<Id, ContentDocument> contentDocumentMap) {

		String currentPeopleRecordId = UserContext.peopleId;
		ContentWrapper wrapperObj = new ContentWrapper();
        wrapperObj.id = contentRecord.id; 
		wrapperObj.contentId = contentRecord.id; 
        if('BlogPost'.equalsIgnoreCase(contentRecord.Type__c)){
        		wrapperObj.type = 'blog_post';
        }else{
        		wrapperObj.type = contentRecord.Type__c;
        }
        wrapperObj.isTypeActive =  (allowedFeaturesInAppSet.contains(contentRecord.Type__c.toLowerCase()) && contentRecord.Activated_By_Feature__c == true) ? true : false;
		List<File__c> titleFilesList = contentRecord.File_Simpplr_Content__r;
        if(titleFilesList.size() > 0){
        	for(File__c fileObj : titleFilesList){
        		if(ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(contentRecord.Type__c)){
        			if(fileObj.Is_Title_Image__c){
	        			if(String.isNotBlank(fileObj.Content_Version__c)) {					
	        				wrapperObj.img = Utility.getFileDownloadURLFor240BY180(fileObj.Content_Version__c);
	        				wrapperObj.imgLandscape = Utility.getFileDownloadURL(fileObj.Content_Version__c);
							wrapperObj.imgFile = convertFileToFileContentWrapper(fileObj); 
							wrapperObj.imgFile.size = getFileSize(fileObj, contentDocumentMap);
							wrapperObj.imgLandscapeFile = convertFileToFileContentWrapper(fileObj); 
							wrapperObj.imgLandscapeFile.size = getFileSize(fileObj, contentDocumentMap);
        				} else {
        					wrapperObj.img = fileObj.Thumbnail_URL__c;
        					wrapperObj.imgLandscape = fileObj.Thumbnail_URL__c;

        				} 
	        			//break;
	        		} 
	        		ContentWrapper.AlbumImagesWrapper imagesWrapperObj = new ContentWrapper.AlbumImagesWrapper();
				imagesWrapperObj.albumMediaId = fileObj.id;
    				// Add the image to the TopAlbumImages
    				if(String.isNotBlank(fileObj.Content_Version__c)) {
						imagesWrapperObj.isVideo = false;
    					imagesWrapperObj.img = Utility.getFileDownloadURL(fileObj.Content_Version__c);
						imagesWrapperObj.thumbnailImg = Utility.getFileDownloadURLFor720BY480(fileObj.Content_Version__c);
    				} else {
						imagesWrapperObj.isVideo = true;
    					imagesWrapperObj.thumbnailImg = fileObj.Thumbnail_URL__c;
						imagesWrapperObj.img = fileObj.Thumbnail_URL__c;	
    				}
    				wrapperObj.listOfTopAlbumImages.add(imagesWrapperObj);
	        		
        		}else if(fileObj.Is_Title_Image__c) {
        			if(ServiceConstants.TITLE_IMAGE_TYPE_THUMBNAIL.equalsIgnoreCase(fileObj.Title_Image_Type__c)){
						wrapperObj.imgFile = convertFileToFileContentWrapper(fileObj);
						wrapperObj.imgFile.size = getFileSize(fileObj, contentDocumentMap);
        				wrapperObj.img = Utility.getFileDownloadURL(fileObj.Content_Version__c);
        				
	        		} else if(ServiceConstants.TITLE_IMAGE_TYPE_WIDESCREEN.equalsIgnoreCase(fileObj.Title_Image_Type__c)){
						wrapperObj.imgLandscapeFile = convertFileToFileContentWrapper(fileObj);
						wrapperObj.imgLandscapeFile.size = getFileSize(fileObj, contentDocumentMap);
	        			wrapperObj.imgLandscape = Utility.getFileDownloadURL(fileObj.Content_Version__c);
	        		}
        		}
        	}
        }
        if(ServiceConstants.TYPE_PAGE.equalsIgnoreCase(contentRecord.Type__c)){
            wrapperObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRecord.site__c+'/page/'+contentRecord.Id;                                          

        } else if(ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(contentRecord.Type__c)){
            wrapperObj.url = PageContext.getPageURL(Pages.app)+'?u=/people/'+contentRecord.Primary_Author__c+'/blog/'+contentRecord.id;                                          

        } else if(ServiceConstants.TYPE_EVENT.equalsIgnoreCase(contentRecord.Type__c)){
            wrapperObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRecord.site__c+'/event/'+contentRecord.Id;                                           

        } else if(ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(contentRecord.Type__c)){
            wrapperObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRecord.site__c+'/album/'+contentRecord.Id;                                           
        }
        wrapperObj.editUrl = wrapperObj.url + '/edit';
		wrapperObj.title = Utility.getAllValidWords(contentRecord.Title__c, contentRecord.Title__c.length(), false);
        wrapperObj.excerpt = String.isBlank(contentRecord.Display_Excerpt__c)?'':contentRecord.Display_Excerpt__c.unescapeHtml4();

		if(SimpplrContext.validationPeriodMonth != null && 
			ServiceConstants.TYPE_PAGE.equalsIgnoreCase(contentRecord.Type__c) &&
			ServiceConstants.CONTENT_SUB_TYPE_KNOWLEDGE.equalsIgnoreCase(contentRecord.Content_Sub_Type__c)) { 

			DateTime expiresAtDateTime = contentRecord.Publish_Start_DateTime__c;							
			if(contentRecord.Last_Validated_DateTime__c != null && expiresAtDateTime < contentRecord.Last_Validated_DateTime__c) {
				expiresAtDateTime = contentRecord.Last_Validated_DateTime__c;
			}
			expiresAtDateTime = expiresAtDateTime.addMonths(SimpplrContext.validationPeriodMonth);
			
			wrapperObj.expiresAt = Utility.dateTimeToMomentJSDateTime(expiresAtDateTime);
			
			if(!contentRecord.Content_Audit_Trails__r.isEmpty()) {
				wrapperObj.lastDismissedAt = Utility.dateTimeToMomentJSDateTime(contentRecord.Content_Audit_Trails__r[0].LastModifiedDate);
			}
		}

        wrapperObj.isPublished = contentRecord.Is_Published__c;
		if(contentRecord.Bookmarked_Content__r.size() > 0) {
    			wrapperObj.isFavorited = true;
        }else{
        		wrapperObj.isFavorited = false;
        }
        if(contentRecord.Likes_Simpplr_Content__r.size() > 0){
        		wrapperObj.isLiked = true;
        }else{
			wrapperObj.isLiked = false;
        }
		wrapperObj.isInHomeCarousel = false;
		wrapperObj.isInSiteCarousel = false;
		if(contentRecord.Is_Published__c) {
			for(Carousel_Content__c carouselObj : contentRecord.Simpplr_Carousel_Contents__r) {
				if(String.isNotBlank(carouselObj.Site__c)) {
					wrapperObj.isInSiteCarousel = true;
				} 
				if(String.isBlank(carouselObj.Site__c)) {
					wrapperObj.isInHomeCarousel = true;
				}
			}
		}
        wrapperObj.isDeleted = contentRecord.Is_Deleted__c;
		if(contentRecord.Must_Read_Confirm_History__r.isEmpty()){
        		wrapperObj.hasRead = false;
        }else{
	        	wrapperObj.hasRead = true;
	        	DateTime dateTimeValue = null;
	        	dateTimeValue = contentRecord.Must_Read_Confirm_History__r[0].Confirm_DateTime__c;
	        	wrapperObj.readAt = dateTimeValue != null ? dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'):'';
        }
        wrapperObj.likeCount = Integer.valueOf(contentRecord.Likes__c);
		if(contentRecord.Must_Read_Audits__r.isEmpty() == false) {
			wrapperObj.isMustRead 		= true;

			Map<Id, Site_Role__c> mapofSiteIdAndSiteRole = new Map<Id, Site_Role__c>();
				mapofSiteIdAndSiteRole = UserContext.mySiteRolesMap;
				if(contentRecord.Must_Read_Audits__r[0].Audience_Type__c == 'site_members') {
					Site_Role__c siteRoleForContentSite = mapofSiteIdAndSiteRole.get(contentRecord.Site__c);
					if(siteRoleForContentSite != null && siteRoleForContentSite.Is_Member__c == true) {
						wrapperObj.isMustRead = true;

						wrapperObj.mustReadDetails = new ContentWrapper.MustReadDetails();
						wrapperObj.mustReadDetails.readCount = Integer.valueOf(contentRecord.Must_Read_Audits__r[0].Must_Read_Confirm_Count__c);
						wrapperObj.mustReadDetails.audience = contentRecord.Must_Read_Audits__r[0].Audience_Type__c;
						wrapperObj.mustReadDetails.usertype='member';
						if(contentIdToAudienceCountMap != null) {
							wrapperObj.mustReadDetails.audienceCount = contentIdToAudienceCountMap.get(contentRecord.id) != null ?contentIdToAudienceCountMap.get(contentRecord.id) : 0;
						}

					} else {
						wrapperObj.isMustRead = false;
					}
				} else {
					wrapperObj.isMustRead = true;
					wrapperObj.mustReadDetails = new ContentWrapper.MustReadDetails();
					wrapperObj.mustReadDetails.readCount = Integer.valueOf(contentRecord.Must_Read_Audits__r[0].Must_Read_Confirm_Count__c);
					wrapperObj.mustReadDetails.audience = contentRecord.Must_Read_Audits__r[0].Audience_Type__c;
					if(contentIdToAudienceCountMap != null) {
						wrapperObj.mustReadDetails.audienceCount = contentIdToAudienceCountMap.get(contentRecord.id) != null ?contentIdToAudienceCountMap.get(contentRecord.id) : 0;
					}
					if(contentRecord.Must_Read_Audits__r[0].Audience_Type__c == 'everyone') {
						wrapperObj.mustReadDetails.usertype='everyone';
					}
					else {
						Site_Role__c siteRoleForContentSite = mapofSiteIdAndSiteRole.get(contentRecord.Site__c);
						if(siteRoleForContentSite != null){
							if(siteRoleForContentSite.Is_Member__c == false) {
								wrapperObj.mustReadDetails.usertype='follower';
							} else {
								wrapperObj.mustReadDetails.usertype='member';
							}
						}
					}
				}

		} else {
			wrapperObj.isMustRead = false;
		}
		wrapperObj.favoriteContext = ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(contentRecord.type__c)?'blog post':contentRecord.Type__c;
		wrapperObj.createdAt = contentRecord.Created_DateTime__c == null ? '':Utility.dateToDisplayString(contentRecord.Created_DateTime__c,'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        wrapperObj.publishAt = contentRecord.Publish_Start_DateTime__c == null ? '':Utility.dateToDisplayString(contentRecord.Publish_Start_DateTime__c,'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		wrapperObj.firstPublishedAt = contentRecord.First_Publish_DateTime__c  != null ? Utility.dateTimeToMomentJSDateTime(contentRecord.First_Publish_DateTime__c) : null;
		wrapperObj.publishTo = contentRecord.Publish_End_DateTime__c == null ? '':Utility.dateToDisplayString(contentRecord.Publish_End_DateTime__c,'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		wrapperObj.modifiedAt = contentRecord.Last_Updated_DateTime__c == null ? '':Utility.dateToDisplayString(contentRecord.Last_Updated_DateTime__c,'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		if(ServiceConstants.TYPE_EVENT.equalsIgnoreCase(contentRecord.Type__c)){

			TimeZone tz = Timezone.getTimeZone(contentRecord.Event_TimezoneSidKey__c);
            wrapperObj.timezoneName = Utility.timezoneIdToDisplayLabel(contentRecord.Event_TimezoneSidKey__c);
            wrapperObj.timezoneIso = tz.getID();
            wrapperObj.timezoneOffset = tz.getOffset(system.today());

			wrapperObj.startsAt = Utility.dateTimeToMomentJSDateTime(contentRecord.Event_Start_DateTime__c);
		    DateTime endDateTimeValue = contentRecord.Event_End_DateTime__c;
		    wrapperObj.endsAt = Utility.dateTimeToMomentJSDateTime(endDateTimeValue);
		    wrapperObj.isAllDay = contentRecord.Event_Is_All_Day__c;
			wrapperObj.isMultiDay = !contentRecord.Event_Start_DateTime__c.isSameDay(endDateTimeValue);
		        
			if (contentRecord.Event_RSVP_Allowed__c){
				wrapperObj.rsvp = new ContentWrapper.RsvpWrapper();
				for(Event_RSVP_Response__c rsvpResponse : contentRecord.Event_RSVP_Responses__r){
					if(currentPeopleRecordId.equalsIgnoreCase(rsvpResponse.People__c)){
						wrapperObj.rsvp.noteValue = rsvpResponse.RSVP_Response_Text__c;
						wrapperObj.rsvp.respondedWith = rsvpResponse.RSVP_Response__c.toLowerCase();
					}
				}
				wrapperObj.rsvp.attendingCount = contentRecord.Event_Attending_Count__c != null && contentRecord.Event_Attending_Count__c > 0 ? 
													Integer.valueOf(contentRecord.Event_Attending_Count__c) : null;
				wrapperObj.rsvp.capacityCount = Integer.valueOf(contentRecord.Event_RSVP_Limit__c);
				DateTime DateTimeValue = contentRecord.Event_RSVP_By_DateTime__c;
				
				String rsvpEndTime = contentRecord.Event_RSVP_By_DateTime__c == null ? '':Utility.dateToDisplayString(contentRecord.Event_RSVP_By_DateTime__c,'h:mm a');
				if(rsvpEndTime == '12:00 AM') {
					DateTimeValue = DateTimeValue.addSeconds(-1);
				}
				if(DateTimeValue != null) {
					wrapperObj.rsvp.dueAtDate = DateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
				}
				wrapperObj.rsvp.hasMaybeOption = contentRecord.Event_RSVP_Show_Maybe__c;
				wrapperObj.rsvp.noteLabel = contentRecord.Event_RSVP_Note__c;
				wrapperObj.rsvp.reportUrl = PageContext.getPageURL(Pages.Reports) +'?contentId='+contentRecord.id + '&action=getRsvpList';
				wrapperObj.rsvp.canDownloadReport = AccessManager.hasContentApprovalAccess();
		   }
        } else if (ServiceConstants.TYPE_PAGE.equalsIgnoreCase(contentRecord.Type__c)) {
			wrapperObj.contentSubType = contentRecord.Content_Sub_Type__c;
		}
        if(ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(contentRecord.Type__c)){
        	wrapperObj.videoCount = Integer.valueOf(contentRecord.Album_Video_Count__c);
        	wrapperObj.imageCount = Integer.valueOf(contentRecord.Album_Image_Count__c);
		}
		wrapperObj.status = getContentStatus(contentRecord.Status__c, contentRecord.Is_Published__c, contentRecord.Is_Unpublished__c);
		wrapperObj.isScheduled = checkIfContentScheduled(wrapperObj.status, contentRecord.Publish_Start_DateTime__c);
        
		Boolean isSiteManager = sitesIManageIdSet.contains(contentRecord.Site__c);
		Boolean isContentManager = sitesIManageContentsIdSet.contains(contentRecord.Site__c);

        wrapperObj.canPublishUnpublish = (ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(contentRecord.type__c) ? 
        		AccessManager.calculateManageBlogAccess(contentRecord.Primary_Author__r.User__c) :
        		AccessManager.calculatePublishUnpublishAccess(isSiteManager, isContentManager, wrapperObj.status, 
        		contentRecord.primary_author__r.user__c, contentRecord.Site__r.Site_Type__c));
        wrapperObj.canModerate = AccessManager.calculateModerateAccess(isSiteManager, isContentManager, wrapperObj.status, 
        		contentRecord.primary_author__r.user__c, contentRecord.Site__r.Site_Type__c);
        wrapperObj.canDelete = ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(contentRecord.type__c) ? 
        		AccessManager.calculateManageBlogAccess(contentRecord.Primary_Author__r.User__c) : 
        		AccessManager.calculateDeleteAccess(isSiteManager, isContentManager, wrapperObj.status, 
        		contentRecord.primary_author__r.user__c, contentRecord.Site__r.Site_Type__c);
        
        if(ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(contentRecord.type__c)) {
        	wrapperObj.canEdit = AccessManager.calculateBlogEditAccess(contentRecord.primary_author__r.user__c, wrapperObj.status);
			wrapperObj.canMakeMustRead = wrapperObj.isPublished && UserContext.isUserAppModerator;
        	
        } else {
        	wrapperObj.canEdit = AccessManager.calculateEditAccess(isSiteManager, isContentManager, wrapperObj.status, 
        						 contentRecord.primary_author__r.user__c, contentRecord.Site__r.Site_Type__c);
        	wrapperObj.canMakeMustRead = AccessManager.calculateCanMakeMustRead(wrapperObj.type, wrapperObj.isPublished, 
													contentRecord.site__r.site_type__c, contentRecord.Site__r.Is_Must_Read_Enabled__c, 
													isSiteManager, isContentManager);					 
        }
		Map<Id, Site_Role__c> mapofSiteIdAndSiteRole = new Map<Id, Site_Role__c>();
		mapofSiteIdAndSiteRole = UserContext.mySiteRolesMap;
        wrapperObj.canSendUpdateNotification = ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(contentRecord.type__c) ? false : wrapperObj.canEdit;
        
         if('Page'.equalsIgnoreCase(contentRecord.Type__c) && String.isNotBlank(contentRecord.Pages_Category__c)) {
	        	wrapperObj.category = new CategoryWrapper();
	        	wrapperObj.category.id = contentRecord.Pages_Category__c;
	        	wrapperObj.category.categoryId = contentRecord.Pages_Category__c;
	        	wrapperObj.category.Name = contentRecord.Pages_Category__r.Name__c;
	        	wrapperObj.category.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + contentRecord.Site__c + '/content&pageCategoryId=' + contentRecord.Pages_Category__c;
        }
        //Author 
        wrapperObj.authoredBy.id = contentRecord.Primary_Author__c;
		wrapperObj.authoredBy.peopleId = contentRecord.Primary_Author__c;
		wrapperObj.authoredBy.sfUserId = contentRecord.Primary_Author__r.user__r.Id;
		wrapperObj.authoredBy.nickname = contentRecord.Primary_Author__r.Community_Nickname__c;//TBD
		wrapperObj.authoredBy.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + contentRecord.Primary_Author__c;
		String nameForAuthor = Utility.buildName(contentRecord.Primary_Author__r.First_Name__c,contentRecord.Primary_Author__r.Last_Name__c);
		if(String.isNotBlank(nameForAuthor)){
			wrapperObj.authoredBy.name = nameForAuthor;
		}
		wrapperObj.authoredBy.img = contentRecord.Primary_Author__r.user__r.FullPhotoURL.endsWith('005/F') ? null : contentRecord.Primary_Author__r.user__r.FullPhotoURL;
		wrapperObj.authoredBy.department = contentRecord.Primary_Author__r.Department__c;
		wrapperObj.authoredBy.title = contentRecord.Primary_Author__r.Title__c;
		wrapperObj.authoredBy.location = Utility.buildLocation(contentRecord.Primary_Author__r.City__c, contentRecord.Primary_Author__r.State__c, contentRecord.Primary_Author__r.Country__c);
		wrapperObj.authoredBy.email = contentRecord.Primary_Author__r.Email__c;
		wrapperObj.authoredBy.phone = contentRecord.Primary_Author__r.Phone__c;
		wrapperObj.authoredBy.mobile = contentRecord.Primary_Author__r.mobile_phone__c;
		wrapperObj.authoredBy.phoneExtension = contentRecord.Primary_Author__r.extension__c;
		wrapperObj.authoredBy.about = contentRecord.Primary_Author__r.About__c;//TBD
		wrapperObj.authoredBy.birthday = SimpplrContext.isPPBirthDateDisplay ? Utility.dateToDisplayString(contentRecord.Primary_Author__r.Birth_Date__c,'MM-dd') : null;
		if(SimpplrContext.isPPJoiningDateDisplay && contentRecord.Primary_Author__r.Joining_Date__c != null && contentRecord.Primary_Author__r.Joining_Date__c < Date.today().addDays(-3)) {
			wrapperObj.authoredBy.hireDate = Utility.dateToDisplayString(contentRecord.Primary_Author__r.Joining_Date__c,'yyyy-MM-dd');
		}
		
		if (usersIFollowIdSet.contains(contentRecord.Primary_Author__r.User__c)) {
	    		wrapperObj.authoredBy.isFollowing = true;
	    		
	    	} else {
	    		wrapperObj.authoredBy.isFollowing = false;
	    	}
    	
		wrapperObj.authoredBy.isActive = contentRecord.Primary_Author__r.User__r.isactive;
		
		if (UserContext.getCurrentUserInfo.Id == contentRecord.Primary_Author__c) {
			wrapperObj.authoredBy.canFollow = false;
			
		} else {
			wrapperObj.authoredBy.canFollow = contentRecord.Primary_Author__r.User__r.isactive;
			
		} 
		
		// Light Weight Site
		if (!ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(contentRecord.type__c)){
			wrapperObj.site = new SiteLiteWrapper();
			wrapperObj.site.siteId = contentRecord.site__c;
	    	wrapperObj.site.chatterGroupId = contentRecord.site__r.Chatter_Group_Id__c;
	    	wrapperObj.site.title = contentRecord.site__r.Name;
	    	wrapperObj.site.isMember = UserContext.sitesIFollowIdSet.contains(wrapperObj.site.siteId);
	    	wrapperObj.site.name = contentRecord.site__r.Name;
	    	wrapperObj.site.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + contentRecord.site__c + '/' + contentRecord.site__r.Landing_Page__c;
			wrapperObj.site.imgContentDocumentId = contentRecord.Site__r.Title_Content_Document__c;
			wrapperObj.site.img = String.isBlank(contentRecord.site__r.Title_Content_Version__c) ? null : Utility.getFileDownloadURLFor720By480(contentRecord.site__r.Title_Content_Version__c);
 			wrapperObj.site.imgThumbnail = String.isBlank(contentRecord.site__r.Title_Content_Version__c) ? null : Utility.getFileDownloadURLFor120BY90(contentRecord.site__r.Title_Content_Version__c);
			wrapperObj.site.isActive = contentRecord.site__r.Is_Active__c;
			wrapperObj.site.access = contentRecord.site__r.site_type__c;
			wrapperObj.site.hasCampaigns = contentRecord.site__r.Has_Campaigns__c;
			wrapperObj.site.isOwner = UserContext.siteIOwnMap.keySet().contains(wrapperObj.site.siteId);
		 		
		 	wrapperObj.site.isListed  = !'Unlisted'.equalsIgnoreCase(contentRecord.site__r.Site_Type__c);
		 	wrapperObj.site.isManager = sitesIManageIdSet.contains(wrapperObj.site.siteId);
		 	wrapperObj.site.isContentManager = sitesIManageContentsIdSet.contains(wrapperObj.site.siteId);
	 		wrapperObj.site.isPrivate = 'Private'.equalsIgnoreCase(contentRecord.site__r.Site_Type__c);
	 		wrapperObj.site.isPublic = 'Public'.equalsIgnoreCase(contentRecord.site__r.Site_Type__c);
			if(SimpplrContext.isSegmentsEnabled){
				String segmentId = String.isBlank(UserContext.SegmentId) ? '' : UserContext.SegmentId;
				if(String.isNotBlank(segmentId)) {
					List<Segment_Site__c> segList = [SELECT id, Is_Featured__c from Segment_Site__c where site__c =: contentRecord.Site__c and segment__c =:segmentId WITH SECURITY_ENFORCED limit 1];
					wrapperObj.site.isFeatured = segList.size()>0 ? segList[0].Is_Featured__c : false;
				} else {
					wrapperObj.site.isFeatured = false;
				}
			} else {
				wrapperObj.site.isFeatured = contentRecord.site__r.Is_Featured__c;
			}
		 	wrapperObj.usefulContent.canViewHistory 			= wrapperObj.canPublishUnpublish;
		    if(contentRecord.Simpplr_Content_Feedback__r.isEmpty()) {
		    	wrapperObj.usefulContent.hasUserRated		= false;
		    } else {
		    	wrapperObj.usefulContent.hasUserRated		= true;
		    	wrapperObj.usefulContent.hasUserRatedUseful	= contentRecord.Simpplr_Content_Feedback__r[0].Was_Content_Useful__c;
		    }
		}
		if(SimpplrContext.isFeatureContentOnboardingEnabled) {
			wrapperObj.canManageOnboardingContent = AccessManager.calculateCanManageOnboarding(wrapperObj.isPublished, contentRecord.Site__c, contentRecord.Site__r.Is_Onboarding_Enabled__c, (wrapperObj.site?.isFeatured == null ? false : wrapperObj.site.isFeatured));
			wrapperObj.onboardingStatus = contentRecord.Content_Onboarding_Status__c;
			wrapperObj.onboardingAddedDate = contentRecord.Onboarding_Added_Date__c == null ? '':Utility.dateToDisplayString(contentRecord.Onboarding_Added_Date__c,'yyyy-MM-dd');
            wrapperObj.isContentRead = !contentRecord.Content_Interactions__r.isEmpty() && (ServiceConstants.CONTENT_STATUS_SITE_ONBOARDING.equalsIgnoreCase(contentRecord.Content_Onboarding_Status__c)
                                || ServiceConstants.CONTENT_STATUS_ORG_ONBOARDING.equalsIgnoreCase(contentRecord.Content_Onboarding_Status__c))
                                && contentRecord.Content_Interactions__r[0].View_Count__c > 0;
            
        } else {
            wrapperObj.canManageOnboardingContent = false;
            wrapperObj.onboardingStatus = ServiceConstants.CONTENT_STATUS_NOT_ONBOARDING;
			wrapperObj.isContentRead=false;
        }
	 	//topic wrapper
	 	if(contentIdWithTopicListMap.get(contentRecord.Id) != null && contentIdWithTopicListMap.get(contentRecord.Id).size()>0){
	 		wrapperObj.listOfTopics = convertContentTopicsToTopicWrapper(contentRecord.Type__c,contentIdWithTopicListMap.get(contentRecord.Id));
	 	}
        return wrapperObj;
	}

	@TestVisible
	Integer getFileSize(File__c fileObj, Map<Id, ContentDocument> contentDocumentMap) {
		Decimal fileSize = fileObj.Size__c;
		if(fileSize == null) {
			if(contentDocumentMap.containsKey(fileObj.Content_Document__c)) {
				fileSize = contentDocumentMap.get(fileObj.Content_Document__c).ContentSize;
			}
		}
		return (Integer)fileSize;
	}

	public FileContentWrapper convertFileToFileContentWrapper(File__c fileObj) {
    	FileContentWrapper fileWrapperObj = New FileContentWrapper();
  		fileWrapperObj.fileId = fileObj.id;
  		fileWrapperObj.type = Utility.getFileType(fileObj.MIME_Type__c);  			
		fileWrapperObj.id = fileObj.Content_Document__c;
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
  		
		fileWrapperObj.fileURL = fileWrapperObj.url;
  		return fileWrapperObj;
    }
	
	private List<TopicWrapper> convertContentTopicsToTopicWrapper(String  contentType , List<topicAssignment> topicAssignmentList){
		List<TopicWrapper> topicWrapperList = new List<TopicWrapper>();
		for(topicAssignment topicAssignmentObj : topicAssignmentList){
			TopicWrapper topicWrapperObj = new TopicWrapper();
			topicWrapperObj.Id = topicAssignmentObj.topic.id;
			topicWrapperObj.topicId = topicAssignmentObj.topic.id;
			topicWrapperObj.name = topicAssignmentObj.topic.name;
			topicWrapperObj.url = PageContext.getPageURL(Pages.app)+ '?u=/topic/' + topicAssignmentObj.Topic.Id + '/content';
			topicWrapperList.add(topicWrapperObj);
		}
		return topicWrapperList;
	}
	
	private String getSearchTextCondition(Set<String> setOfSearchTerms){
		String subConditionString = '';
		if (setOfSearchTerms != null) {
			for(String searchToken:setOfSearchTerms){
				subConditionString += ' OR Title__c like \'%'+searchToken+'%\' OR Display_Excerpt__c like \'%'+searchToken+'%\' ';
			}
			subConditionString = ' And (' + subConditionString.removeStart(' OR') + ')';
        }
        return subConditionString;
	}
	
	private String getExcludeContentType(String excludeType) {
		if(String.isBlank(excludeType)) {
			excludeType = '';
		}else if('blogs'.equalsIgnoreCase(excludeType)) {
			excludeType = 'blogPost';
		} else if('albums'.equalsIgnoreCase(excludeType)) {
			excludeType = 'album';
		} else if('events'.equalsIgnoreCase(excludeType)) {
			excludeType = 'event';
		}else if('pages'.equalsIgnoreCase(excludeType)) {
			excludeType = 'page';
		}
		
		return excludeType;
	}
	
	public static List<String> getContentFieldList() {
    		String segmentId = String.isBlank(UserContext.SegmentId) ? '' : UserContext.SegmentId;
			String mustReadSubCondition = '';
			if(UserContext.isUserAppModerator == false) {
				mustReadSubCondition = ' And (Audience_Type__c=\'everyone\' OR Content__r.Site__c=:sitesIFollowIdSet) ';
			}
    		List<String> fieldList = New List<String>{
			'Id',
            'Type__c',
			'Content_Sub_Type__c',
            'Activated_By_Feature__c',
            'site__c',
            'Primary_Author__c',
			'Title__c',
			'Text_Intro__c',
            'Display_Excerpt__c',
            'Summary_1__c',
            'Use_Maximum_Screenwidth__c',
            'Is_Published__c',
            'Is_Unpublished__c',
            'Is_Must_Read__c',
            'Is_Deleted__c',
            'Allow_comments__c',
            'Likes__c',
            'Feed_Posts__c',
            'createdDate',
            'Publish_Start_DateTime__c', 
            'Publish_End_DateTime__c', 
            'First_Publish_DateTime__c', 
			'Last_Validated_DateTime__c ',
            'lastModifiedDate',
            'Event_Start_DateTime__c',
			'Event_End_DateTime__c',
			'Event_TimezoneSidKey__c',
			'Event_Is_All_Day__c',
			'Status__c',
			'Last_Edited_DateTime__c',
			'Album_Image_Count__c',
            'Album_Video_Count__c',
			'Event_Attending_Count__c',
			'Event_Location__c',
			'Title_Image_Caption__c',
			'Cover_Image_Layout__c',
			'Event_RSVP_Allowed__c',
			'Event_RSVP_Show_Maybe__c',
			'Event_RSVP_Note__c',
			'Event_RSVP_Limit__c',
			'Event_RSVP_By_DateTime__c',
			'Event_Map_URL__c',
			'Event_Directions_Enabled__c',
			'Event_Directions__c',
			'Pages_Category__c',
			'Content_Onboarding_Status__c',
			'Onboarding_Added_Date__c',
			'Last_Updated_DateTime__c',
			'Last_UpdatedBy_People__c', 
			'Created_DateTime__c', 
			'CreatedBy_People__c',
			'Pages_Category__r.Name__c',
			'Primary_Author__r.user__r.Id',
			'Primary_Author__r.First_Name__c', 
			'Primary_Author__r.Community_Nickname__c',
            'Primary_Author__r.Last_Name__c',
            'Primary_Author__r.Full_Name__c',
            'Primary_Author__r.user__r.SmallPhotoURL',
            'Primary_Author__r.user__r.FullPhotoURL',
			'Primary_Author__r.Department__c',
			'Primary_Author__r.About__c',
			'Primary_Author__r.Title__c',
			'Primary_Author__r.City__c',
			'Primary_Author__r.State__c',
			'Primary_Author__r.Country__c',
			'Primary_Author__r.Email__c',
			'Primary_Author__r.Phone__c',
			'Primary_Author__r.mobile_phone__c',
			'Primary_Author__r.extension__c',
			'Primary_Author__r.Birth_Date__c',
			'Primary_Author__r.Joining_Date__c',
			'Primary_Author__r.User__c',
			'Primary_Author__r.User__r.isactive',
            'Site__r.name',
            'Site__r.Is_Active__c',
            'Site__r.Chatter_Group_Id__c',
            'Site__r.Site_Type__c',
            'Site__r.Landing_Page__c',
			'Site__r.Title_Content_Document__c',
            'Site__r.Title_Content_Version__c',
			'Site__r.Show_In_Simpplr__c',
            'Site__r.Is_Onboarding_Enabled__c',
			'Site__r.Is_Must_Read_Enabled__c',
			'Site__r.Is_Featured__c',
			'Site__r.Has_Campaigns__c',
			'(select Must_Read_Confirm_Count__c, Audience_Type__c, Removed_By_People__c, Removed_DateTime__c, Expiry_DateTime__c, Content__r.Title__c from Must_Read_Audits__r where Removed_DateTime__c = null  AND (Expiry_DateTime__c = null OR Expiry_DateTime__c >: currentDateTime) ' +  mustReadSubCondition + ' order by createddate desc limit 1)',
            '(Select Id,Confirm_DateTime__c  from Must_Read_Confirm_History__r Where People__c =:loggedInPeopleId and Must_Read_Audit__r.Removed_DateTime__c=null AND (Must_Read_Audit__r.Expiry_DateTime__c = null OR Must_Read_Audit__r.Expiry_DateTime__c >: currentDateTime) )',
            '(select id from Bookmarked_Content__r where People__c =:loggedInPeopleId and Is_Deleted__c=false)',
            '(select id from Likes_Simpplr_Content__r where People__c =: loggedInPeopleId and Is_Deleted__c=false)',
			'(select id, View_Count__c from Content_Interactions__r where People__c =: loggedInPeopleId )',
            '(Select Id, Was_Content_Useful__c from Simpplr_Content_Feedback__r where submitter__c =:loggedInPeopleId and Is_Deleted__c=false)',
            '(select id, Site__c from Simpplr_Carousel_Contents__r where Is_Deleted__c = false AND (Site__c != null OR Segment__c =\''+segmentId+'\')) ',
			'(SELECT Id,Content_Version__c,Content_Document__c,Title_Image_Type__c,Size__c,Is_Title_Image__c,Thumbnail_URL__c, MIME_Type__c FROM File_Simpplr_Content__r WHERE Location__c in (\'cover\' , \'media\') And Is_Deleted__c = false ORDER BY Is_Title_Image__c DESC, Likes__c DESC NULLS last, Order__c desc LIMIT 4)',
			'(Select Id, content__c, People__c, is_deleted__c, RSVP_Response__c, RSVP_Response_Text__c from Event_RSVP_Responses__r where is_deleted__c = false And RSVP_Response__c = \'No\' And People__c=:loggedInPeopleId)'
        };

		if(SimpplrContext.isContentGovernanceEnabled){
			fieldList.add('(select LastModifiedDate from Content_Audit_Trails__r where Dismiss_By__c !=null order by LastModifiedDate Limit 1)');
		}

		return fieldList;
    }
    
    @TestVisible 
    private ResponseWrapper getRelated(String data, Boolean isAIFailed) {
    	logger.logDebug('AllContentDataServer.getRelated()---data---' + data);
    	ResponseWrapper resultWrapper = new ResponseWrapper();
    	
		try {
			Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data, Type.forName('Map<String,String>'));
			String contentId = requestDataMap.get('contentId');
			Set<Simpplr_Content__c> setOfRelatedContent = new Set<Simpplr_Content__c>();
			Simpplr_Content__c contentObj = [SELECT id, name, title__c, Primary_Author__c, site__c 
					FROM Simpplr_Content__c 
					WHERE id=:contentId
					WITH SECURITY_ENFORCED];
			list<TopicAssignment> listOfTopicAssignmentForContent = [SELECT id, EntityId, topicId, topic.name 
					FROM TopicAssignment WHERE EntityId=:contentId
					WITH SECURITY_ENFORCED];
					
			if (contentObj.site__c != null) {
				String siteId =  contentObj.site__c;
				DateTime currentDateTime = DateTime.now();
				String query = 'SELECT ' + String.join(getContentFieldList(),',') + 
						' FROM Simpplr_Content__c Where Is_Published__c = true And site__c=:siteId'  + 
						' And TYPE__c IN : allowedFeaturesInAppList ' +
    					' And Is_Deleted__c = false ' +
    					' And (Site__r.Is_Active__c = true And Site__r.Show_In_Simpplr__c = true)  ' +
                        ' And Activated_By_Feature__c = true AND ' + 
                        ' (Type__c!=\'Event\' OR Event_End_DateTime__c>=:currentDateTime) ';
    	
    			Map<Id, Simpplr_Content__c> mapOfContentObjects = new Map<Id, Simpplr_Content__c> ((List<Simpplr_Content__c>) Database.query(query));
    			List<Simpplr_Content__c> listOfAllContentsInSite = new List<Simpplr_content__c>();
				listOfAllContentsInSite = mapOfContentObjects.values();
               
				if (!listOfAllContentsInSite.isEmpty()) {
					
					for (Simpplr_Content__c contObj: listOfAllContentsInSite) {
						Integer counter = 0;
						
						if (contObj.Primary_Author__c == contentObj.Primary_Author__c && 
								counter < 3 && contObj.id != contentId) {
                            
                            if ('page'.equalsIgnoreCase(contObj.type__c) && 
                                    'news'.equalsIgnoreCase(contObj.Content_Sub_Type__c)) {

                                if (contObj.Publish_Start_DateTime__c + 30 > System.today()) {
                                    setOfRelatedContent.add(contObj); 
                                    counter ++;
                                }

                            } else {
                                setOfRelatedContent.add(contObj); 
							    counter ++; 
                            }
							
						}
						
					}
					
				}
				
				list<TopicAssignment> listOfTopicAssignment = [SELECT id, EntityId, topicId, topic.name 
                        FROM TopicAssignment 
                        WHERE EntityId=:mapOfContentObjects.keyset() 
						WITH SECURITY_ENFORCED];
				Set<id> setOfRelatedContentId = new Set<Id>();
				 
				for (TopicAssignment topicForContent:listOfTopicAssignmentForContent) {
					Integer counter = 0;
					for (TopicAssignment topicAssigObj: listOfTopicAssignment) {
						
						if (topicForContent.topicId == topicAssigObj.topicId && counter <3) {
							setOfRelatedContentId.add(topicAssigObj.entityId); // 3 Related contentId added for same author and same topic
							counter ++; 
						}
							
					}
					
				}
				
				setOfRelatedContentId.remove(contentId);
				String queryForTopic = 'SELECT ' + String.join(getContentFieldList(),',') + ' FROM Simpplr_Content__c Where id=:setOfRelatedContentId';
				Map<Id, Simpplr_Content__c> mapOfContentIdWithObj = new Map<Id, Simpplr_Content__c> ((List<Simpplr_Content__c>) Database.query(queryForTopic));
				List<Simpplr_Content__c> listOfContentWithSameTopic = new List<Simpplr_Content__c>();
				listOfContentWithSameTopic = mapOfContentIdWithObj.values();
                setOfRelatedContent.addAll(listOfContentWithSameTopic);
				
			} else {
				// For blogposts
				String queryForTopic = 'SELECT ' + String.join(getContentFieldList(),',') + 
				' FROM Simpplr_Content__c WHERE Is_Published__c = true And type__c=\'BlogPost\'' + 
						' And TYPE__c IN : allowedFeaturesInAppList ' +
    					' And Is_Deleted__c = false ' +
    					' And Activated_By_Feature__c = true ';
				Map<Id, Simpplr_Content__c> mapOfContentIdWithObj = new Map<Id, Simpplr_Content__c> ((List<Simpplr_Content__c>) Database.query(queryForTopic));
				List<Simpplr_Content__c> listOfAllBlogPost = new List<Simpplr_content__c>();
				listOfAllBlogPost = mapOfContentIdWithObj.values();
				
				Set<Id> setOfBlogIdsForTopic = new Set<Id>();
				
				if (!listOfAllBlogPost.isEmpty()) {
					
					for (Simpplr_Content__c blogObj: listOfAllBlogPost) {
						Integer counter = 0;
						
						if (blogObj.Primary_Author__c == contentObj.Primary_Author__c && counter < 3 && 
								blogObj.id != contentId) {
							setOfRelatedContent.add(blogObj); // 3 Related content added for same author and same site
							counter ++; 
						}
						
						setOfBlogIdsForTopic.add(blogObj.id);
						
					}

				}
				
				list<TopicAssignment> listOfTopicAssigForBlog = [SELECT id, EntityId, topicId, topic.name 
						FROM TopicAssignment 
						WHERE EntityId=:setOfBlogIdsForTopic WITH SECURITY_ENFORCED];
				Set<id> setOfRelatedBlogId = new Set<Id>();
				 
				for (TopicAssignment topicForContent: listOfTopicAssignmentForContent) {
					Integer counter = 0;
					
					for (TopicAssignment topicAssigObj: listOfTopicAssigForBlog) {
						
						if (topicForContent.topicId == topicAssigObj.topicId && counter < 3) {
							setOfRelatedBlogId.add(topicAssigObj.entityId); // 3 Related contentId added for same author and same topic
							counter ++; 
						}
							
					}
					
				}
				
				setOfRelatedBlogId.remove(contentId);
				String queryForBlog = 'SELECT ' + String.join(getContentFieldList(),',') + 
						' FROM Simpplr_Content__c WHERE id=:setOfRelatedBlogId';
				Map<Id, Simpplr_Content__c> mapOfBlogIdWithObj = new Map<Id, Simpplr_Content__c> ((List<Simpplr_Content__c>) Database.query(queryForBlog));
				List<Simpplr_Content__c> listOfBlogWithSameTopic = mapOfBlogIdWithObj.values();
				setOfRelatedContent.addAll(listOfBlogWithSameTopic);
			}

			Set<String>  allowedFeaturesInAppSet = new  Set<String>();

			for (String feature : allowedFeaturesInAppList) {
		    	allowedFeaturesInAppSet.add(feature.toLowerCase());
		    }

			List<Simpplr_Content__c> listOfRelatedContent = new List<Simpplr_Content__c>();
			Map<String, Object> result = new Map<String, Object>();
			
			listOfRelatedContent.addAll(setOfRelatedContent);
			if(listOfRelatedContent.size() > 0){
				result = getRandomRelatedContent(listOfRelatedContent, 3, allowedFeaturesInAppSet);
			}
			String message = isAIFailed ? 'AI is enabled but AI failed' : 'AI is not enabled';
			result.put('message',message);
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
	        logger.logDebug('AllContentDataServer.getRelated()-----resultWrapper-- '+ resultWrapper);
			
    	} catch (Exception e) {
	        logger.logDebug('AllContentDataServer.getRelated()-----Exception-- '+ e);
    		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
    	}
    	return resultWrapper;
	}
	
	@TestVisible
    private ResponseWrapper getAIRelatedContent(String data) {
        logger.logDebug('AllContentDataServer.getAIRelatedContent()---data---' + data);
        String RELATED_CONTENT_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/content/related-content';
        ResponseWrapper resultWrapper = new ResponseWrapper();
        
        try {
            Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data, Type.forName('Map<String,String>'));
            String contentId = requestDataMap.get('contentId');
            List<ContentWrapper> listOfContentWrapper = new List<ContentWrapper>();

            List<Simpplr_Content__c> contentList = [SELECT ID, Is_Published__c, site__c FROM Simpplr_Content__c WHERE Is_Published__c = true AND Id = :contentId WITH SECURITY_ENFORCED];
            if(contentList.size() > 0) {
                List<String> recommendedContentIds = new List<String>();
                Set<String>  allowedFeaturesInAppSet = new  Set<String>();

                for (String feature : allowedFeaturesInAppList) {
                    allowedFeaturesInAppSet.add(feature.toLowerCase());
                }

                Map<String, Object> response = null;       
                Map<String, Object> requestBody = new Map<String, Object>();
                String ACCESS_TOKEN_ENDPOINT ;

                requestBody.put('orgId', SimpplrContext.simpplrOrgId);
                requestBody.put('peopleId', UserContext.peopleId);
                requestBody.put('userId', UserContext.userId);
                requestBody.put('contentId', contentId);
                requestBody.put('version', ServiceConstants.RELATED_CONTENT_API_VERSION);
                requestBody.put('action', 'getRelatedContent');

				Map<String, String> mapOfCustomHeader = new Map<String, String>();
				mapOfCustomHeader.put('jwttoken', Utility.getJWTToken());

                HttpResponse httpresponseObj = Utility.getResponseFromAWS(RELATED_CONTENT_ENDPOINT, requestBody, mapOfCustomHeader);                

                if(httpresponseObj.getStatusCode() == 200) {
                    String bodyStr = httpresponseObj.getBody();
        
                    if(String.isNotBlank(bodyStr)) {
                        Map<String, Object> resultBodyMap = ((Map<String, Object>) JSON.deserializeUntyped(bodyStr));
                        List<Object> recommendationsList = (List<Object>)resultBodyMap.get('similar_text');
                        for(Object recommendationsObj : recommendationsList){
                            List<Object> recommendations = (List<Object>)recommendationsObj;
                            for(Object recommendationObj : recommendations){
                                Map<String, Object> recommendationmap = (Map<String, Object>) recommendationObj;
                                if(contentId != ((String) recommendationmap.get('id'))){
                                    recommendedContentIds.add(((String) recommendationmap.get('id')));
                                }
                            }
                        }

                        Map<Id, Simpplr_Content__c> relatedContentMap = new Map<Id, Simpplr_Content__c>();

                        String siteId =  contentList[0].site__c;
                        DateTime currentDateTime = DateTime.now();
                        String query = 'SELECT ' + String.join(getContentFieldList(),',') + 
                                ' FROM Simpplr_Content__c Where Is_Published__c = true And Id IN :recommendedContentIds'  + 
                                ' And TYPE__c IN : allowedFeaturesInAppList ' +
                                ' And Is_Deleted__c = false ' +
                                ' And (site__c = null or (site__c != null And Site__r.Is_Active__c = true And Site__r.Show_In_Simpplr__c = true))' +
                                ' And Activated_By_Feature__c = true AND ' + 
                                ' (Type__c!=\'Event\' OR Event_End_DateTime__c>=:currentDateTime) ';
                
                        List<Simpplr_Content__c> relatedContentList = (List<Simpplr_Content__c>) Database.query(query);

                        Set<String> SiteIds = new Set<String>();
                        for(Simpplr_Content__c content:relatedContentList){
                            relatedContentMap.put(content.id,content);
                            if(String.isNotBlank(content.Site__c)){
                                SiteIds.add(content.Site__c);
                            }
                        }

                        Set<String> userAccessableSites = new Set<String>();
                        
                        for(Site_Role__c siteRole: [SELECT id, Is_Manager__c, Is_Member__c, Is_Content_Manager__c, Site__c FROM Site_Role__c WHERE Site__c IN:SiteIds AND User__c =:UserContext.userId AND Is_Deleted__c=false WITH SECURITY_ENFORCED]){
                            if(String.isNotBlank(siteRole.Site__c) && (siteRole.Is_Manager__c || siteRole.Is_Content_Manager__c || siteRole.Is_Member__c)){
                                userAccessableSites.add(siteRole.Site__c);
                            }
                        }

                        if(recommendedContentIds.size() > 0){
                            for(Integer i = 0; i < recommendedContentIds.size() ; i++){
                                if(listOfContentWrapper.size() == 3){
                                    break;
                                }else{
                                    if(relatedContentMap.containsKey(recommendedContentIds[i])){
                                        Simpplr_Content__c contentObj = relatedContentMap.get(recommendedContentIds[i]);
                                        if(String.isNotBlank(contentObj.Site__c)){ //If not a blogpost
                                            if((userAccessableSites.contains(contentObj.Site__c) || contentObj.Site__r.Site_Type__c == 'Public' || (contentObj.Site__r.Site_Type__c == 'Unlisted' && UserContext.hasManageUnlistedSitePermission))){
                                                listOfContentWrapper.add(convertContentToWrapper(contentObj, new Map<String,List<TopicAssignment>>(), UserContext.sitesIManageIdSet, UserContext.sitesIManageContentsIdSet, UserContext.usersIFollowIdSet, allowedFeaturesInAppSet, null, new Map<Id, ContentDocument>()));
                                            }
                                        }else{
                                            listOfContentWrapper.add(convertContentToWrapper(contentObj, new Map<String,List<TopicAssignment>>(), UserContext.sitesIManageIdSet, UserContext.sitesIManageContentsIdSet, UserContext.usersIFollowIdSet, allowedFeaturesInAppSet, null, new Map<Id, ContentDocument>()));
                                        }
                                    }
                                }
                            }
                        }
                    }
					Map<String, Object> result = new Map<String, Object>();
					result.put('listOfItems',listOfContentWrapper);
					result.put('message', 'AI is enabled');

					resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
					logger.logDebug('AllContentDataServer.getAIRelatedContent()-----resultWrapper-- '+ resultWrapper);
                } else {
					logger.logDebug('AllContentDataServer.getAIRelatedContent()-----Error-- '+ httpresponseObj.getStatusCode());
					resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
				}
            }

            
            
        } catch (Exception e) {
            logger.logDebug('AllContentDataServer.getAIRelatedContent()-----Exception-- '+ e);
            resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return resultWrapper;
    }

	public Map<String, Object> getRandomRelatedContent(List<Simpplr_content__c> listOfRelatedContent, Integer recordLimit, Set<String> allowedFeaturesInAppSet)
	{
		logger.logDebug('AllContentDataServer.getRandomRelatedContent()-----listOfRelatedContent-- '+ listOfRelatedContent + '--recordLimit---' + recordLimit);
		Map<String, Object> mapOfRandomRecords = new Map<String, Object>();
		List<ContentWrapper> listOfContentWrapper = new List<ContentWrapper>();
		Integer total = listOfRelatedContent.size();
		Set<ContentWrapper> setOfContentWrapper = new Set<ContentWrapper>();
		Set<Id> contentIdSet = new Set<Id>();
		if(total > 0)
		{
			while(listOfContentWrapper.size() < recordLimit && listOfContentWrapper.size() < total && !listOfRelatedContent.isEmpty())
			{  
				Integer randomNumber = Math.round(Math.random()*(listOfRelatedContent.size() - 1));
				if(!contentIdSet.contains(listOfRelatedContent[randomNumber].Id))
				{
					listOfContentWrapper.add(convertContentToWrapper(listOfRelatedContent[randomNumber], new Map<String,List<TopicAssignment>>(), UserContext.sitesIManageIdSet, UserContext.sitesIManageContentsIdSet, UserContext.usersIFollowIdSet, allowedFeaturesInAppSet, null, new Map<Id, ContentDocument>()));
					contentIdSet.add(listOfRelatedContent[randomNumber].Id);
				}
				listOfRelatedContent.remove(randomNumber);
			}
		}
		setOfContentWrapper.addAll(listOfContentWrapper);
		mapOfRandomRecords.put('listOfItems', setOfContentWrapper);
		logger.logDebug('AllContentDataServer.getRandomRelatedContent()-----mapOfRandomRecords-- '+ mapOfRandomRecords);
		return mapOfRandomRecords;
	}
    
    public List<ContentWrapper> getPopularContentListWrap (String contentType, String siteId) {
  		List<ContentWrapper> listOfContentWrapper = contentListToLightWrapper(getPopularContentList(siteId, contentType, null, 0, 5, null, null, false), null);
  		return listOfContentWrapper;
    }
    
    public List<ContentWrapper> getLatestContentListWrap (String contentType, String siteId) {
		Criteria.ContentSearchFilter criteriaObj = new Criteria.ContentSearchFilter();
		criteriaObj.offset = 0;
		criteriaObj.recordLimit = 5;
		criteriaObj.siteId = siteId;
		criteriaObj.contentType = contentType;
		criteriaObj.excludeType = null;
		criteriaObj.searchText = null;
		criteriaObj.sortBy = null;
		criteriaObj.publishStartDateTime = null;
		criteriaObj.author = null;
		criteriaObj.maxAllowedEventEndDateTime = null;
		criteriaObj.isAllContent = false;
		criteriaObj.futureEventsOnly = false;

  		List<ContentWrapper> listOfContentWrapper = contentListToLightWrapper(getLatestContentList(criteriaObj), null);
  		return listOfContentWrapper;
    }

	@TestVisible 
	private ResponseWrapper moveContent(String data) {
    	logger.logDebug('AllContentDataServer.moveContent()---data---' + data);
    	ResponseWrapper resultWrapper = new ResponseWrapper();
    	Boolean isSuccess = false;
	 
		try {

			if (data == null || String.isBlank(data)) {
            	throw new SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        	} 
			//

			/*Getting data from page parameters */
			Criteria.ContentMove contMoveCriteria = new Criteria.ContentMove();
			contMoveCriteria = (Criteria.ContentMove)JSON.deserialize(data, Criteria.ContentMove.class);
			List<String> listOfContentIdToMove = new List<String>();
			listOfContentIdToMove = contMoveCriteria.contentIdList; 
			String newSiteId = contMoveCriteria.siteId;
			String categoryId = contMoveCriteria.categoryId;	
			List<Simpplr_Content__c> listOfContentToMove = new List<Simpplr_Content__c>();
			Simpplr_Site__c newSiteObj = new Simpplr_Site__c();
			List<Simpplr_Site__c> listOfSiteContentMoveTo =  new 	List<Simpplr_Site__c>();
			// Method call to move video content
			if(SimpplrContext.isnativeVideo){
					VideoDao.moveVideo(newSiteId,listOfContentIdToMove);
			}
	
			/*Getting new sites detail based on siteId where we have to move content*/
			if (String.isNotBlank(newSiteId)) {
				listOfSiteContentMoveTo = [SELECT Id, Site_Type__c,
				chatter_group_id__c, Allow_Public_Contribution__c  
				FROM Simpplr_Site__c 
				WHERE id=:newSiteId WITH SECURITY_ENFORCED];
			}

			if (!listOfSiteContentMoveTo.isEmpty()) {
				newSiteObj = listOfSiteContentMoveTo[0];
			}

			Boolean isPublicSite = newSiteObj.Site_Type__c == 'Public' ? true : false; 

			if (!AccessManager.hasContentApprovalAccess(newSiteObj.id, isPublicSite)){
				Boolean isUnlistedSite = newSiteObj.Site_Type__c == 'Unlisted' ? true : false; 
				if(!(UserContext.hasManageUnlistedSitePermission && isUnlistedSite)){
					throw new SimpplrException(ExceptionCode.NO_ACCESS.name());
				}
			} 

			/* Fetching content records for contentId to move*/
			if (!listOfContentIdToMove.isEmpty()) {
				listOfContentToMove = [SELECT id, site__c ,site__r.Name, Primary_Author__c , 
						Type__c, site__r.Chatter_Group_Id__c, site__r.Site_Type__c
						FROM Simpplr_Content__c  
						WHERE Id IN :listOfContentIdToMove WITH SECURITY_ENFORCED];		

				/*Getting groups information for site, to and from content move*/
				List<String> listOfGroupNames = new List<String>();

				for (Simpplr_Content__c contentObj: listOfContentToMove) {

					if (String.isNotBlank(contentObj.Site__c)) {
						listOfGroupNames.add('Simpplr_' + contentObj.Site__r.chatter_group_id__c + '%');
					}

				}

				/*Adding groups for new site*/
				String groupNamePattern = 'Simpplr_' + newSiteObj.chatter_group_id__c + '%' ;
				listOfGroupNames.add(groupNamePattern);
				List<Group> listOfGroupForNewSite = [SELECT id, developername  
						FROM Group 
						WHERE developername like: listOfGroupNames WITH SECURITY_ENFORCED];
				Map<String, String> mapOfGroupNameWithId = new Map<String, String>();
				
				for (Group grpObj: listOfGroupForNewSite) {
					mapOfGroupNameWithId.put(grpObj.developername, grpObj.id); 
				}

				String adminGroupIdForNewSite = mapOfGroupNameWithId.get('Simpplr_' + 
						newSiteObj.chatter_group_id__c + '_Admin');
				String standardGroupIdForNewSite = mapOfGroupNameWithId.get('Simpplr_' + 
						newSiteObj.chatter_group_id__c + '_Standard');

				List<ManageContentDao.ContentAuditTrailWrapper> listOfContentTrailWrap = new List<ManageContentDao.ContentAuditTrailWrapper>();
				List<String> listOfChatterGrpIdForCDLUpdate = new List<String>();//For content document link update
				List<ContentMoveSharingWrapper> listOfContMoveSharingWrap = new List<ContentMoveSharingWrapper>();

				/*Moving content and post move activities along with data prepration */
				for (Simpplr_Content__c simpObj: listOfContentToMove) {
					/*Preparing data for apex sharing */ 
					ContentMoveSharingWrapper contMoveSharingWrapObj = new ContentMoveSharingWrapper();
					contMoveSharingWrapObj.contentId = simpObj.id;
					contMoveSharingWrapObj.oldSiteId =  simpObj.site__c;
					contMoveSharingWrapObj.oldChatterGroupId = simpObj.site__r.Chatter_Group_Id__c;
					contMoveSharingWrapObj.oldSiteType = simpObj.site__r.Site_Type__c;
					contMoveSharingWrapObj.oldAdminGroupId = mapOfGroupNameWithId.get('Simpplr_' + 
							simpObj.site__r.chatter_group_id__c + '_Admin');
					contMoveSharingWrapObj.oldStandardGroupId = mapOfGroupNameWithId.get('Simpplr_' + 
							simpObj.site__r.chatter_group_id__c + '_Standard');
					contMoveSharingWrapObj.newSiteId = newSiteId;
					contMoveSharingWrapObj.newChatterGroupId = newSiteObj.chatter_group_id__c;
					contMoveSharingWrapObj.newAdminGroupId = adminGroupIdForNewSite;
					contMoveSharingWrapObj.newStandardGroupId = standardGroupIdForNewSite;
					contMoveSharingWrapObj.newSiteType = newSiteObj.Site_Type__c;
					listOfContMoveSharingWrap.add(contMoveSharingWrapObj);
				
					/*Data for content documentlink updation */
					listOfChatterGrpIdForCDLUpdate.add(simpObj.site__r.Chatter_Group_Id__c);
					
					/*Creating contentAudit trail history  */
					ManageContentDao.ContentAuditTrailWrapper  contAudTrailWrapObj = new ManageContentDao.ContentAuditTrailWrapper();
					contAudTrailWrapObj.contentId = simpObj.id;
					contAudTrailWrapObj.oldSite = simpObj.site__c;
					contAudTrailWrapObj.newSite = newSiteId; 
					contAudTrailWrapObj.action = 'Site Changed';
					listOfContentTrailWrap.add(contAudTrailWrapObj);
					
					/*Updating content fields for move*/
					if ('page'.equalsIgnoreCase(simpObj.Type__c) && categoryId != null) {
						simpObj.Pages_Category__c = categoryId;	
					}

					simpObj.site__c = newSiteId;
					simpObj.ownerId = adminGroupIdForNewSite;

					simpObj.Last_Moved_DateTime__c = system.now();
				}

				if (!test.isRunningTest()) {
					update listOfContentToMove;
				} 

				/*changing the apex sharing for moved content */
				changeContentSharingSettingsOnMove(listOfContMoveSharingWrap, 
						listOfContentIdToMove);

				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', listOfContentIdToMove);

				/*ContentDocumentLink updation */
				String filesQuery = 'SELECT id, name, Simpplr_Content__c, Site__c,'+
						' Content_Document__c, Is_Deleted__c'+ 
						' FROM File__C' +
						' WHERE Is_Deleted__c = false AND Content_Document__c !=null AND'+ 
						' Simpplr_Content__c IN :soqlParam1';				
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<File__c> listOfFile = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);

				List<String> listOfContentDocId = new List<String>();

				if (!listOfFile.isEmpty()) {
					
					for (File__c fileObj: listOfFile) {
						listOfContentDocId.add(fileObj.Content_Document__c);
					}

				}

				List<ContentDocumentLink> listOfOldContentDocLinkToDelete = new List<ContentDocumentLink>();
				List<ContentDocumentLink> listOfNewContentDocLinkToInsert = new List<ContentDocumentLink>();
				listOfOldContentDocLinkToDelete = [SELECT Id, ContentDocumentId, LinkedEntityId
						FROM ContentDocumentLink 
						WHERE ContentDocumentId IN :listOfContentDocId AND 
						LinkedEntityId =:listOfChatterGrpIdForCDLUpdate WITH SECURITY_ENFORCED]; 

				//For new contentDocumentLink insert
				List<Simpplr_Site__c> listOfSimpplrSite = [SELECT id, Chatter_Group_Id__c 
						FROM Simpplr_Site__c 
						WHERE id=:newSiteId WITH SECURITY_ENFORCED];
				/*To move file in elastic from one site to another on content move */
				List<External_Search_Data_Trail__c> listOfExtSearchDataTrailToInsert = new List<External_Search_Data_Trail__c>();

				SimpplrContext.skipContentDocTrigger = true;
				for (String contDocId: listOfContentDocId) {
					ContentDocumentLink contDocLinkObj = new ContentDocumentLink();
					contDocLinkObj.ContentDocumentId = contDocId;
					contDocLinkObj.LinkedEntityId = listOfSimpplrSite[0].Chatter_Group_Id__c;
					contDocLinkObj.sharetype = 'V';
					listOfNewContentDocLinkToInsert.add(contDocLinkObj);

					External_Search_Data_Trail__c searchObj = new External_Search_Data_Trail__c();
					searchObj.Content_Document__c = contDocId;
					searchObj.Type__c = 'ContentDocument';
					listOfExtSearchDataTrailToInsert.add(searchObj);
				}

				if (!listOfOldContentDocLinkToDelete.isEmpty()) {
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().deleteAsUser(listOfOldContentDocLinkToDelete);
				}

				if (!listOfNewContentDocLinkToInsert.isEmpty()) {
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().insertAsUser(listOfNewContentDocLinkToInsert, 
							new List<Schema.SObjectField>{
							ContentDocumentLink.ContentDocumentId,
							ContentDocumentLink.LinkedEntityId,
							ContentDocumentLink.sharetype
							}); 
				}
				SimpplrContext.skipContentDocTrigger = false;				
				if (!listOfNewContentDocLinkToInsert.isEmpty()) {
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().insertAsUser(listOfExtSearchDataTrailToInsert, 
							new List<Schema.SObjectField>{
							External_Search_Data_Trail__c.Content_Document__c,
							External_Search_Data_Trail__c.Type__c
							});
				}
				
				/*Updates FeedItem records for moved contents*/
				if(!listOfContentIdToMove.isEmpty()){
					 BatchUpdateFeedRecords job = new BatchUpdateFeedRecords('moveContent', listOfContentIdToMove, newSiteObj.chatter_group_id__c,listOfContentToMove[0].site__r.Name,newSiteObj.Site_Type__c);
					 Database.executeBatch(job, 100);
				} 

				/*Method for content audit trail creation */
				ManageContentDao daoObj = new ManageContentDao();
				daoObj.insertContentAuditTrail(listOfContentTrailWrap);
				/*Method call for Content update in elastic*/
				insertSearchTrailObjectForContentList(listOfContentIdToMove);
			}
			
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
	        
    	} catch(Exception e) {
			logger.logError('AllContentDataServer.moveContent----Exception occured----', e);
    		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR,null, null);
    	}

    	return resultWrapper;
    }

	private ResponseWrapper setValid(String requestData){
		logger.logDebug('AllContentDataServer.setValid()---data---' + requestData);
		ResponseWrapper resultWrapper = New ResponseWrapper();

		Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(requestData);
		String contentId = (String) requestDataMap.get('contentId');
		Boolean isValid = Boolean.valueOf(requestDataMap.get('isValid'));

		if(!checkContentModerationAccess(contentId)){
			throw new SimpplrException(ServiceConstants.ERROR_404);
		}

		if(SimpplrContext.isContentGovernanceEnabled){
			List<Simpplr_Content__c> contentList = [SELECT id, Last_Validated_DateTime__c, Publish_End_DateTime__c, Is_Published__c FROM Simpplr_Content__c 
													WHERE Is_Deleted__c = false
													AND Status__c = 'Approved'
													AND type__c = 'Page'
													AND Content_Sub_Type__c = 'knowledge'
													AND Id =: contentId WITH SECURITY_ENFORCED];

			if(!contentList.isEmpty()){
				ManageContentDao.ContentAuditTrailWrapper contAudTrailWrapObj = new ManageContentDao.ContentAuditTrailWrapper();

				Simpplr_Content__c contentObj = contentList[0];
				if(isValid){
					if(!contentObj.Is_Published__c) {
						contentObj.Publish_End_DateTime__c = null;
					}
					// Validate content
					contentObj.Last_Validated_DateTime__c = Datetime.now();
					
					contAudTrailWrapObj.contentId = contentObj.id;
					contAudTrailWrapObj.action = 'Validated';					
					
				} else {
					// unpublish content
					contentObj.Publish_End_DateTime__c = Datetime.now();

					contAudTrailWrapObj.contentId = contentObj.id;
					contAudTrailWrapObj.action = 'Manually Unpublished';
				}

				update contentList;

				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', contentId);
				String queryString = 'Select id, Content__c, Action_By__c from App_Notification__c ' +
									 'where Content__c =:soqlParam1 ' +
									 'And Is_Deleted__c = false ' +
									 'And Category__c=\'Content_For_Review\' ' +
									 'And Type__c = \'Actionable\' ' +
									 'And Action_By__c = null ';

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<App_Notification__c> appNotificationsList = (List<App_Notification__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);

				if(!appNotificationsList.isEmpty()) {
					for(App_Notification__c appNotification : appNotificationsList) {
						appNotification.Action_By__c = UserContext.peopleId;
						appNotification.Is_Read__c=true;
						appNotification.Action_On__c=Datetime.now();
					}
					List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{
						App_Notification__c.Is_Read__c,
						App_Notification__c.Action_By__c,
						App_Notification__c.Action_On__c
					};

					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().updateAsUser(new Map<Id,App_Notification__c>(appNotificationsList), listOfColumnsToBeUpdated);
				}

				ManageContentDao daoObj = new ManageContentDao();
				daoObj.insertContentAuditTrail(new List<ManageContentDao.ContentAuditTrailWrapper>{contAudTrailWrapObj});
				
				resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
			} else {
				throw new SimpplrException(ServiceConstants.ERROR_404);
			}										
		} else {
			throw new SimpplrException(ServiceConstants.ERROR_404);
		}

		return resultWrapper;
	}

	@TestVisible
	private ResponseWrapper restoreVersion(String requestData){
		logger.logDebug('AllContentDataServer.restoreVersion()----requestData----' + requestData);
    	ResponseWrapper responseToReturn = null;
    	
    	List<ContentWrapper> contentWrapperObj = null;
    	try{
			Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(requestData);
			String contentId = (String) requestDataMap.get('contentId');
			String versionId = (String) requestDataMap.get('versionId');

			// Check if user can rolllback content version history
			if(!checkContentModerationAccess(contentId)){
				throw new SimpplrException(ServiceConstants.ERROR_404);
			}

			ManageContentDao manageContentDaoObj = new ManageContentDao(); 
			manageContentDaoObj.restoreVersion(contentId, versionId);
	        
		    responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
	     } catch(Exception ex) {
			 
        	logger.logError('Could not restore content version history', ex);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		logger.logDebug('AllContentDataServer.restoreVersion()----responseToReturn----' + responseToReturn);
		
    	return responseToReturn;
	}	

	@TestVisible
	private ResponseWrapper optForNotification(String requestData){
		logger.logDebug('AllContentDataServer.optForNotification()----requestData----' + requestData);
    	ResponseWrapper responseToReturn = null;
    	
		List<ContentWrapper> contentWrapperObj = null;
		ManageContentDao manageContentDaoObj = new ManageContentDao();
		
    	try {
			Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(requestData);

			String contentId = (String) requestDataMap.get('contentId');
			String peopleId = UserContext.peopleId;
			Boolean isOpenToNotification = (Boolean) requestDataMap.get('isOpenToNotification'); 

			Content_Notification_Setting__c contentNotiSettingObj = manageContentDaoObj.getNotificationSetting(contentId, UserContext.peopleId);
			
			if(isOpenToNotification) {
				if(contentNotiSettingObj == null) {
					manageContentDaoObj.insertContentNotificationSettingForUser(contentId, UserContext.peopleId);
				} else if(contentNotiSettingObj.Notification_Enabled__c == false) {
					manageContentDaoObj.updateContentNotificationSettingForUser(contentNotiSettingObj, true);
				}
			} else {
				if(contentNotiSettingObj != null) {
					manageContentDaoObj.updateContentNotificationSettingForUser(contentNotiSettingObj, false);
				}
			}
																		
		    responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
	     } catch(Exception ex) {
			 
        	logger.logError('Could not set content-notifications for user', ex);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		logger.logDebug('AllContentDataServer.optForNotification()----responseToReturn----' + responseToReturn);
		
    	return responseToReturn;
	}	

	@TestVisible
	private ResponseWrapper getVersionHistory(String requestData){
		logger.logDebug('AllContentDataServer.getVersionHistory()----requestData----' + requestData);
    	ResponseWrapper responseToReturn = null;
    	
    	List<ContentVersionHistoryWrapper> contentVersionHistoryWrapperList = null;
    	try{
			Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(requestData);
			String contentId = (String) requestDataMap.get('id');
			Integer size = (Integer) requestDataMap.get('size');
			Integer nextPageToken = (Integer) requestDataMap.get('nextPageToken');

    		Integer offset = nextPageToken == null ? 0 : nextPageToken;
			
			// Check if user can view content version history
			if(!checkContentModerationAccess(contentId)){
				throw new SimpplrException(ServiceConstants.ERROR_404);
			}

			ManageContentDao manageContentDaoObj = new ManageContentDao(); 
			contentVersionHistoryWrapperList = manageContentDaoObj.getContentVersionHistory(contentId, offset, size);
	    	
	        Map<String, Object> resultMap = new Map<String, Object>(); 
	        Integer nextPageTokenInt;
        	if (contentVersionHistoryWrapperList.size() == (size + 1) && offset < 2000) {
        		contentVersionHistoryWrapperList.remove((contentVersionHistoryWrapperList.size()-1));
        		nextPageTokenInt = offset + size;	
        	}
	        resultMap.put('nextPageToken' , nextPageTokenInt);
	        resultMap.put('listOfItems' , contentVersionHistoryWrapperList);
	        
		    responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, resultMap);
	     } catch(Exception ex) {
			 
        	logger.logError('Could not retrieve content version history', ex);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		logger.logDebug('AllContentDataServer.getVersionHistory()----responseToReturn----'+responseToReturn);
		
    	return responseToReturn;
	}

	@TestVisible
	private ResponseWrapper dismissValidation(String requestData){
		logger.logDebug('AllContentDataServer.dismissValidation()---data---' + requestData);
		ResponseWrapper resultWrapper = New ResponseWrapper();

		Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(requestData);
		String contentId = (String) requestDataMap.get('contentId');
		String type = (String) requestDataMap.get('type');

		if(!checkContentModerationAccess(contentId)){
			throw new SimpplrException(ServiceConstants.ERROR_404);
		}

		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
		new ManageContentDao().dismissValidation(contentId, type);

		return resultWrapper;
	}

	public void insertSearchTrailObjectForContentList(List<String> listOfContentIdToMove){
		List<External_Search_Data_Trail__c> listToInsert = new List<External_Search_Data_Trail__c>();
		
		for (String contId: listOfContentIdToMove) {
			External_Search_Data_Trail__c searchObj = new External_Search_Data_Trail__c();
			searchObj.Content__c = contId;
			searchObj.Type__c = 'Content';
			listToInsert.add(searchObj);
		}
		
		if ( !listToInsert.isEmpty() ) {
			List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();

			 fieldList.add(External_Search_Data_Trail__c.Content__c);
			 fieldList.add(External_Search_Data_Trail__c.Type__c);

			 SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			 SIMPESAPI.accessController().insertAsUser(listToInsert, fieldList);
		}
	}

	public void changeContentSharingSettingsOnMove(List<ContentMoveSharingWrapper> 
			listOfContMoveSharingWrap, List<String> listOfContentIdToMove) {
		logger.logDebug('changeContentSharingSettingsOnMove----listOfContMoveSharingWrap:' + listOfContMoveSharingWrap);
	    	
		List<Simpplr_Content__Share> listOfSimpplrContentShareForInsert = new List<Simpplr_Content__Share>();
		String allInternalUserGroupId = Utility.getUserGroupId('AllInternalUsers');
    	String simpplrAppManagerGroupId = Utility.getUserGroupId('Simpplr_App_Managers');
    	String simpplrUnlistedSiteManagerGroupId = Utility.getUserGroupId('Simpplr_Unlisted_Site_Managers');
		List<String> listOfUserOrGroupIdForDelete = new List<String>();

		for (ContentMoveSharingWrapper sharingWrapObj: listOfContMoveSharingWrap) {
			/*Old Content share record for delete */
			listOfUserOrGroupIdForDelete.add(sharingWrapObj.oldStandardGroupId);
			/*Explicitly adding allInternaluserGrp and AppManagerGrp for delete due to some sf issue*/
			listOfUserOrGroupIdForDelete.add(allInternalUserGroupId);
			listOfUserOrGroupIdForDelete.add(simpplrAppManagerGroupId);

			/*New Content share record for insert*/
			Simpplr_Content__Share contShareObjForInsert = new Simpplr_Content__Share();
			contShareObjForInsert.ParentId = sharingWrapObj.contentId;
			contShareObjForInsert.AccessLevel = 'Edit';
			contShareObjForInsert.RowCause = Schema.Simpplr_Content__Share.RowCause.Manual;
			contShareObjForInsert.UserOrGroupId = sharingWrapObj.newStandardGroupId;
			listOfSimpplrContentShareForInsert.add(contShareObjForInsert);

			if (sharingWrapObj.oldSiteType == 'Public') {

				/*Public to Private */
				if (sharingWrapObj.newSiteType == 'Private') {

				/*Public to Unlisted, Inserting content share for unlisted*/
				} else if (sharingWrapObj.newSiteType == 'Unlisted') {
					/*Adding content share for standard group*/
					Simpplr_Content__Share shareObjForUnlistedToInsert = new Simpplr_Content__Share();
		    		shareObjForUnlistedToInsert.ParentID = sharingWrapObj.contentId;
		    		shareObjForUnlistedToInsert.AccessLevel = 'Edit';
		    		shareObjForUnlistedToInsert.RowCause = Schema.Simpplr_Content__Share.RowCause.Manual;
		    		shareObjForUnlistedToInsert.UserOrGroupId = simpplrUnlistedSiteManagerGroupId;
					listOfSimpplrContentShareForInsert.add(shareObjForUnlistedToInsert);
				
				} else if (sharingWrapObj.newSiteType == 'Public') {
					Simpplr_Content__Share shareObjForAllInternalUserToInsert = new Simpplr_Content__Share();
					shareObjForAllInternalUserToInsert.ParentID = sharingWrapObj.contentId;
					shareObjForAllInternalUserToInsert.AccessLevel = 'Edit';
					shareObjForAllInternalUserToInsert.RowCause = Schema.Simpplr_Content__Share.RowCause.Manual;
					shareObjForAllInternalUserToInsert.UserOrGroupId = allInternalUserGroupId;
					listOfSimpplrContentShareForInsert.add(shareObjForAllInternalUserToInsert);

					Simpplr_Content__Share contShareObjSimpAppForInsert = new Simpplr_Content__Share();
					contShareObjSimpAppForInsert.ParentId = sharingWrapObj.contentId;
					contShareObjSimpAppForInsert.AccessLevel = 'Edit';
					contShareObjSimpAppForInsert.RowCause = Schema.Simpplr_Content__Share.RowCause.Manual;
					contShareObjSimpAppForInsert.UserOrGroupId = simpplrAppManagerGroupId;
					listOfSimpplrContentShareForInsert.add(contShareObjSimpAppForInsert);
				}

			} else if (sharingWrapObj.oldSiteType == 'Private') {

				/*Private to Public, inserting for  allInternalUserGroupId*/
				if (sharingWrapObj.newSiteType == 'Public') {
					Simpplr_Content__Share shareObjForAllInternalUserToInsert = new Simpplr_Content__Share();
					shareObjForAllInternalUserToInsert.ParentID = sharingWrapObj.contentId;
					shareObjForAllInternalUserToInsert.AccessLevel = 'Edit';
					shareObjForAllInternalUserToInsert.RowCause = Schema.Simpplr_Content__Share.RowCause.Manual;
					shareObjForAllInternalUserToInsert.UserOrGroupId = allInternalUserGroupId;
					listOfSimpplrContentShareForInsert.add(shareObjForAllInternalUserToInsert);

					Simpplr_Content__Share contShareObjSimpAppForInsert = new Simpplr_Content__Share();
					contShareObjSimpAppForInsert.ParentId = sharingWrapObj.contentId;
					contShareObjSimpAppForInsert.AccessLevel = 'Edit';
					contShareObjSimpAppForInsert.RowCause = Schema.Simpplr_Content__Share.RowCause.Manual;
					contShareObjSimpAppForInsert.UserOrGroupId = simpplrAppManagerGroupId;

				/*Private to Unlisted */
				} else if (sharingWrapObj.newSiteType == 'Unlisted') {
					Simpplr_Content__Share shareObjForUnlistedToInsert = new Simpplr_Content__Share();
		    		shareObjForUnlistedToInsert.ParentID = sharingWrapObj.contentId;
		    		shareObjForUnlistedToInsert.AccessLevel = 'Edit';
		    		shareObjForUnlistedToInsert.RowCause = Schema.Simpplr_Content__Share.RowCause.Manual;
		    		shareObjForUnlistedToInsert.UserOrGroupId = simpplrUnlistedSiteManagerGroupId;
					listOfSimpplrContentShareForInsert.add(shareObjForUnlistedToInsert);
				
				/*Private to Private */
				} else if (sharingWrapObj.newSiteType == 'Private') {}

			} else if (sharingWrapObj.oldSiteType == 'Unlisted') {
				listOfUserOrGroupIdForDelete.add(simpplrUnlistedSiteManagerGroupId);

				/*Unlisted to Public*/
				if (sharingWrapObj.newSiteType == 'Public') {
					Simpplr_Content__Share shareObjForAllInternalUserToInsert = new Simpplr_Content__Share();
					shareObjForAllInternalUserToInsert.ParentID = sharingWrapObj.contentId;
					shareObjForAllInternalUserToInsert.AccessLevel = 'Edit';
					shareObjForAllInternalUserToInsert.RowCause = Schema.Simpplr_Content__Share.RowCause.Manual;
					shareObjForAllInternalUserToInsert.UserOrGroupId = allInternalUserGroupId;
					listOfSimpplrContentShareForInsert.add(shareObjForAllInternalUserToInsert);

					Simpplr_Content__Share contShareObjSimpAppForInsert = new Simpplr_Content__Share();
					contShareObjSimpAppForInsert.ParentId = sharingWrapObj.contentId;
					contShareObjSimpAppForInsert.AccessLevel = 'Edit';
					contShareObjSimpAppForInsert.RowCause = Schema.Simpplr_Content__Share.RowCause.Manual;
					contShareObjSimpAppForInsert.UserOrGroupId = simpplrAppManagerGroupId;
					listOfSimpplrContentShareForInsert.add(contShareObjSimpAppForInsert);
				
				/*Unlisted to private*/
				} else if (sharingWrapObj.newSiteType == 'Private') {} 

			}

		}
		
		List<Simpplr_Content__Share> listOfSimpplrContentShareForDelete = [SELECT Id,  parentId 
				,UserOrGroupId 
				FROM Simpplr_Content__Share 
				WHERE (ParentID IN :listOfContentIdToMove AND 
				UserOrGroupId IN :listOfUserOrGroupIdForDelete) WITH SECURITY_ENFORCED];

		delete listOfSimpplrContentShareForDelete;

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	    SIMPESAPI.accessController().insertAsUser(listOfSimpplrContentShareForInsert, 
				new List<Schema.SObjectField>{
				Simpplr_Content__Share.ParentID,
				Simpplr_Content__Share.AccessLevel,
				Simpplr_Content__Share.RowCause,
				Simpplr_Content__Share.UserOrGroupId});
		
	}

	@TestVisible
	private ResponseWrapper renewLock(String requestData){
		logger.logDebug('AllContentDataServer.renewLock()---data---' + requestData);
		ResponseWrapper resultWrapper = New ResponseWrapper();

		Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(requestData);
		String contentId = (String) requestDataMap.get('contentId');

		if(!checkContentModerationAccess(contentId)){
			throw new SimpplrException(ServiceConstants.ERROR_404);
		}

		ContentLockWrapper contentLockWrapperObj = new ContentLockWrapper();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', contentId);
		soqlParamMap.put('soqlParam2', UserContext.peopleId);
		String lockStatusQuery = 'SELECT Id, Content__r.Version__c, Last_Renew_DateTime__c, ' +
			' Start_DateTime__c, Locked_By_People__c FROM Content_Lock_Status__c ' +
			' WHERE Content__c =:soqlParam1 AND Locked_By_People__c =:soqlParam2 ' +
			' ORDER BY CreatedDate DESC LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Content_Lock_Status__c> contentLockStatusList = (List<Content_Lock_Status__c>)SIMPESAPI.accessController().queryAsUser(lockStatusQuery, soqlParamMap);

		if(!contentLockStatusList.isEmpty()){
			
			if(contentLockStatusList[0].Start_DateTime__c.addMinutes(30) <= currentDateTime){				
				// warning to user that 30 mins are over do you want to extend it	
																						
			} else {
				contentLockStatusList[0].Last_Renew_DateTime__c = currentDateTime;

				SIMPESAPI.accessController().updateAsUser(contentLockStatusList[0], new List<Schema.SObjectField>{
																				Content_Lock_Status__c.Last_Renew_DateTime__c
																				});
			}
		} else {
			throw new SimpplrException(ServiceConstants.ERROR_404);
		}
		
		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);

		return resultWrapper;
	} 

	private ResponseWrapper startIndexingForAI(String requestData){
		logger.logDebug('AllContentDataServer.startIndexingForAI()---data---' + requestData);
		ResponseWrapper responseToReturn = New ResponseWrapper();
		try {
			
			BatchPushContentDataForAI job = new BatchPushContentDataForAI();
			Database.executeBatch(job,100);

			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
		}
		catch(Exception e) {
        	logger.logError('AllContentDataServer.startIndexingForAI()----Could not index',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		return responseToReturn;
    }
    
    public List<ContentWrapper> getSimpplrContentsByIds (List<String> listOfContentIds) {
        String query = 'SELECT '+String.join(getContentFieldList(),',')+' FROM Simpplr_Content__c WHERE Id IN :listOfContentIds limit 50';
        logger.logDebug('AllContentDataServer.getSimpplrContentsByIds()----query----'+query); 
        List<Simpplr_Content__c> listOfSimpCont = Database.query(query);
        List<ContentWrapper> contentWrapperList = contentListToLightWrapper(listOfSimpCont, null);
        return contentWrapperList;

    }

    /**
     * This method is used to fetch metadata of content
     * @param data 
     * @return  `ResponseWrapper`
    */
    @TestVisible
    public ResponseWrapper getMetadata(String data) {
        logger.logDebug('AllContentDataServer.getMetadata()---data---' + data);
        ResponseWrapper resultWrapper = new ResponseWrapper();
        try {
            Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data, Type.forName('Map<String,String>'));
            String contentId = requestDataMap.get('contentId');
            if (data == null || String.isBlank(contentId)){
                throw new SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
            }
            ManageContentDao daoObj = new ManageContentDao();
            Map<String, Object> resMap = daoObj.getMetadata(contentId);
            resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, resMap);
        } catch(Exception e){
            logger.logError('AllContentDataServer.getMetadata()-----could not retrieve data----',e);
            resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return resultWrapper;
    }
	
    /**
     * @description This method is used to send request to AWS to generate csv for bulk data  
     * @param data 
     * @return  `ResponseWrapper`
    */
    @TestVisible
    public ResponseWrapper prepareBulkDataCsv(String data) {
        logger.logDebug('AllContentDataServer.prepareBulkDataCsv()---data---' + data);
		ManageContentDao daoObj = new ManageContentDao();
        ResponseWrapper resultWrapper = new ResponseWrapper();
        try {
			Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(data);
			String action = requestDataMap != null && requestDataMap.containsKey('action') && requestDataMap.get('action') != null ? (String) requestDataMap.get('action') : null;
			String widgetTab = requestDataMap != null && requestDataMap.containsKey('widgetTab') && requestDataMap.get('widgetTab') != null ? (String) requestDataMap.get('widgetTab') : null;
			String widgetTitle = requestDataMap != null && requestDataMap.containsKey('widgetTitle') && requestDataMap.get('widgetTitle') != null ? (String) requestDataMap.get('widgetTitle') : null;
			String toDate = requestDataMap != null && requestDataMap.containsKey('to') && requestDataMap.get('to') != null ? (String) requestDataMap.get('to') : null;
			String fromDate = requestDataMap != null && requestDataMap.containsKey('from') && requestDataMap.get('from') != null ? (String) requestDataMap.get('from') : null;
		
			if(String.isNotBlank(action) && String.isNotBlank(widgetTab) && String.isNotBlank(widgetTitle)){
				Map<String, Object> requestBody = new Map<String, Object>();
				requestBody.put('action', action);
				requestBody.put('widgetTab', widgetTab);
				requestBody.put('widgetTitle', widgetTitle);
				requestBody.put('to', toDate);
				requestBody.put('from', fromDate);
				
				daoObj.requestBulkDataCsv(requestBody, requestDataMap);
			}else{
				//must read history csv
				String contentId = (String) requestDataMap.get('contentId');
				String filter = (String) requestDataMap.get('filter');
            	daoObj.requestMustReadHistoryCsv(contentId, filter);
			}
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
        } catch(Exception e){
            logger.logError('AllContentDataServer.prepareBulkDataCsv()-----could not retrieve data----',e);
            resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return resultWrapper;
    }

    public class ContentWrapperSorted implements Comparable {
        public ContentWrapperSorted(Date onboardingAddedDate, ContentWrapper cw) {
            this.onboardingAddedDate = onboardingAddedDate;
            this.cw = cw;
        }
        public Date onboardingAddedDate {get; set;}
        public ContentWrapper cw {get; set;}
        public Integer compareTo(Object compareTo){
            ContentWrapperSorted wrapperObj = (ContentWrapperSorted) compareTo;
            if(onboardingAddedDate == null || wrapperObj.onboardingAddedDate == null){
                return 0;
            }
            if (onboardingAddedDate == wrapperObj.onboardingAddedDate) return 0;
            if (onboardingAddedDate > wrapperObj.onboardingAddedDate) return -1;
            return 1;
        }
    }

    public ResponseWrapper getMyOnboardingContents(String data) {
    	logger.logDebug('AllContentDataServer.getMyOnboardingContents()---data---' + data);
    	ResponseWrapper resultWrapper = New ResponseWrapper();
    	
    	try{
    		Map<String,String> requestDataMap = (Map<String,String>) JSON.deserialize(data, Type.forName('Map<String, String>'));
    		String sortBy = requestDataMap.get('sortBy');
			Integer size = String.isNotBlank(requestDataMap.get('size')) ? Integer.valueOf(requestDataMap.get('size')) : SimpplrContext.simpplrDefaultPageSize;
        	Integer recordLimit = size + 1;
            List<Site_Role__c> mySiteRoles = UserContext.mySitesRolesList;
            Set<Id> siteIds = new Set<Id>();
            for(Site_Role__c role:mySiteRoles) {
                siteIds.add(role.Site__c);
            }
            List<String> onboardingStatus = new List<String> {ServiceConstants.CONTENT_STATUS_ORG_ONBOARDING, ServiceConstants.CONTENT_STATUS_SITE_ONBOARDING};
            String orgOnboarding = ServiceConstants.CONTENT_STATUS_ORG_ONBOARDING;
            String siteOnboarding = ServiceConstants.CONTENT_STATUS_SITE_ONBOARDING;
			String contentFields = String.join(getContentFieldList(), ',');
            Map<String,Object> result = New Map<String,Object>();
			
			
            if('site'.equalsIgnoreCase(sortBy)) {
				if(SimpplrContext.isFeatureEnabled('Full_External_Search')){
					ExternalSearchService externalSearchService = new ExternalSearchService();
					Criteria.ExternalSearchReq contentSearchCriteria = (Criteria.ExternalSearchReq)JSON.deserialize(data, Criteria.ExternalSearchReq.class);
					ExternalSearchWrapper.TopContentsWrapper returnWrapper = externalSearchService.searchContents(contentSearchCriteria, 'ContentOnboarding');
				
					List<Object> listOfItems = new List<Object>();
					Boolean isOnboardingContentAvailable = returnWrapper.listOfItems.size()>0 ? true : false;

					for(ExternalSearchWrapper.ItemWrapper itemWrap : returnWrapper.listOfItems) {
						if(((ContentWrapper)itemWrap.item).contentId != null) {
							if(ServiceConstants.CONTENT_STATUS_ORG_ONBOARDING.equalsIgnoreCase(((ContentWrapper)itemWrap.item).onboardingStatus)) {
								listOfItems.add(new Map<String, Object> {
									'type' => 'orgOnboarding',
									'data' => (ContentWrapper)itemWrap.item
									});
							} else if(ServiceConstants.CONTENT_STATUS_SITE_ONBOARDING.equalsIgnoreCase(((ContentWrapper)itemWrap.item).onboardingStatus)) {
								listOfItems.add(new Map<String, Object> {
									'type' => ((ContentWrapper)itemWrap.item).site.siteId,
									'site' => ((ContentWrapper)itemWrap.item).site,
									'data' => (ContentWrapper)itemWrap.item
								});
							}   
						}
					}
					//org content count

					Map<String, Object> soqlParamMap = new Map<String, Object>();
		        	soqlParamMap.put('soqlParam1', orgOnboarding);

					String query = 'SELECT COUNT(Id) orgContentCount FROM Simpplr_Content__c WHERE Is_Published__c = true AND Is_Deleted__c = false AND Content_Onboarding_Status__c = :soqlParam1';
                	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
                	List<AggregateResult> aggrList = (List<AggregateResult>) SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
                	Integer orgContentCount = aggrList[0].get('orgContentCount') != null ? Integer.valueOf(String.valueOf(aggrList[0].get('orgContentCount'))) : 0;
                
				
                	String nextPageToken = null;
					if(returnWrapper.nextPageToken!=null) {
						nextPageToken =	returnWrapper.nextPageToken;
					}
	

                	result.put('orgOnboardingCount', orgContentCount);
                	result.put('listOfItems', listOfItems);
                	result.put('nextPageToken', nextPageToken);
					result.put('isOnboardingContentAvailable', isOnboardingContentAvailable);
                	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
				} else {
					Integer offset = String.isNotBlank(requestDataMap.get('nextPageToken') != null ? requestDataMap.get('nextPageToken') : '') ? Integer.valueOf(String.valueOf(requestDataMap.get('nextPageToken'))) : 0;
                	String nextPageQuery = ' LIMIT :recordLimit OFFSET :offset';
					Map<String, Object> soqlParamMap = new Map<String, Object>();
		       		soqlParamMap.put('soqlParam1', orgOnboarding);
		        
					//org content count
					String query = 'SELECT COUNT(Id) orgContentCount FROM Simpplr_Content__c WHERE Is_Published__c = true AND Is_Deleted__c = false AND Content_Onboarding_Status__c = :soqlParam1';
                	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
                	List<AggregateResult> aggrList = (List<AggregateResult>) SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
                	Integer orgContentCount = aggrList[0].get('orgContentCount') != null ? Integer.valueOf(String.valueOf(aggrList[0].get('orgContentCount'))) : 0;
                
					//content query
					query = 'SELECT ' + contentFields + ' FROM Simpplr_Content__c WHERE Is_Published__c = true AND Is_Deleted__c = false AND (Content_Onboarding_Status__c = :orgOnboarding OR (Site__c IN :siteIds AND Content_Onboarding_Status__c = :siteOnboarding)) ORDER BY Content_Onboarding_Status__c ASC, Site__r.Name ASC, Onboarding_Added_Date__c DESC ' + nextPageQuery;
					logger.logDebug('AllContentDataServer.getMyOnboardingContents()---query---' + query);
				
					List<Simpplr_Content__c> contentList = Database.query(query);
					List<ContentWrapper> contentWrapperList = contentListToLightWrapper(contentList, null);
					Boolean isOnboardingContentAvailable = contentList.size()>0 ? true : false;
                
					//** Prepare result *
                	List<Object> listOfItems = new List<Object>();
                	List<ContentWrapperSorted> sortedOrgOnboardingByDate = new List<ContentWrapperSorted>();
                	for(ContentWrapper cw:contentWrapperList) {
                    	if(ServiceConstants.CONTENT_STATUS_ORG_ONBOARDING.equalsIgnoreCase(cw.onboardingStatus)) {
                       		sortedOrgOnboardingByDate.add(new ContentWrapperSorted(Date.valueOf(cw.onboardingAddedDate), cw));
                    	}   
                	}
                	sortedOrgOnboardingByDate.sort();
                	for(ContentWrapperSorted cwSorted:sortedOrgOnboardingByDate) {
                    	listOfItems.add(new Map<String, Object> {
                        	'type' => 'orgOnboarding',
                        	'data' => cwSorted.cw
                    	});
                	}
                
                	for(ContentWrapper cw:contentWrapperList) {
                    	if(ServiceConstants.CONTENT_STATUS_SITE_ONBOARDING.equalsIgnoreCase(cw.onboardingStatus)) {
                        	listOfItems.add(new Map<String, Object> {
								'type' => cw.site.siteId,
                            	'site' => cw.site,
                            	'data' => cw
                        	});
                    	}   
                	}
                
                	Integer nextPageToken = null;
	        		if (listOfItems.size() == (size + 1) && offset < 2000) {
	        			listOfItems.remove((listOfItems.size() - 1));
	        			nextPageToken = offset + size;	
	        		}

                	result.put('orgOnboardingCount', orgContentCount);
                	result.put('listOfItems', listOfItems);
                	result.put('nextPageToken', nextPageToken);
					result.put('isOnboardingContentAvailable', isOnboardingContentAvailable);
                	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
				}

            } else if('dateadded'.equalsIgnoreCase(sortBy)) {
				Integer offset = String.isNotBlank(requestDataMap.get('nextPageToken') != null ? requestDataMap.get('nextPageToken') : '') ? Integer.valueOf(String.valueOf(requestDataMap.get('nextPageToken'))) : 0;
                String nextPageQuery = ' LIMIT :recordLimit OFFSET :offset';
               	Map<String, Object> soqlParamMap = new Map<String, Object>();
		        soqlParamMap.put('soqlParam1', siteIds);
		        soqlParamMap.put('soqlParam2', orgOnboarding);
				soqlParamMap.put('soqlParam3', siteOnboarding);
				
				//within7daysCount count
				String query = 'SELECT COUNT(Id) recordCount FROM Simpplr_Content__c WHERE Is_Published__c = true AND Is_Deleted__c = false AND (Content_Onboarding_Status__c = :soqlParam2 OR (Site__c = :soqlParam1 AND Content_Onboarding_Status__c = :soqlParam3)) AND Onboarding_Added_Date__c = LAST_N_DAYS:6';
                List<AggregateResult> aggrList = (List<AggregateResult>) SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
				Integer within7daysCount = aggrList[0].get('recordCount') != null ? Integer.valueOf(String.valueOf(aggrList[0].get('recordCount'))) : 0;
				
				//morethan7daysCount count
				query = 'SELECT COUNT(Id) recordCount FROM Simpplr_Content__c WHERE Is_Published__c = true AND Is_Deleted__c = false AND (Content_Onboarding_Status__c = :soqlParam2 OR (Site__c = :soqlParam1 AND Content_Onboarding_Status__c = :soqlParam3)) AND Onboarding_Added_Date__c != LAST_N_DAYS:6';
                aggrList = (List<AggregateResult>) SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
                Integer morethan7daysCount = aggrList[0].get('recordCount') != null ? Integer.valueOf(String.valueOf(aggrList[0].get('recordCount'))) : 0;
				
				//content query
				query = 'SELECT ' + contentFields + ' FROM Simpplr_Content__c WHERE Is_Published__c = true AND Is_Deleted__c = false AND (Content_Onboarding_Status__c = :orgOnboarding OR (Site__c IN :siteIds AND Content_Onboarding_Status__c = :siteOnboarding)) ORDER BY Onboarding_Added_Date__c DESC ' + nextPageQuery;
                logger.logDebug('AllContentDataServer.getMyOnboardingContents()---query---' + query);
				
				List<Simpplr_Content__c> contentList = Database.query(query);
				List<ContentWrapper> contentWrapperList = contentListToLightWrapper(contentList, null);
                Boolean isOnboardingContentAvailable = contentList.size()>0 ? true : false;
				
				//** Prepare result *
                List<Object> listOfItems = new List<Object>();
                for(ContentWrapper cw:contentWrapperList) {
					if(String.isNotBlank(cw.onboardingAddedDate) && date.valueOf(cw.onboardingAddedDate).daysBetween(Date.today())<7) {
                        listOfItems.add(new Map<String, Object> {
                            'type' => 'Added in the last week',
                            'data' => cw
                        });
                    } else {
                        listOfItems.add(new Map<String, Object> {
                            'type' => 'Added more than a week ago',
                            'data' => cw
                        });
                    }   
                }
                
                Integer nextPageToken = null;
	        	if (listOfItems.size() == (size + 1) && offset < 2000) {
	        		listOfItems.remove((listOfItems.size() - 1));
	        		nextPageToken = offset + size;	
	        	}

                result.put('within7daysCount', within7daysCount);
				result.put('moreThan7days', morethan7daysCount);
                result.put('listOfItems', listOfItems);
                result.put('nextPageToken', nextPageToken);
				result.put('isOnboardingContentAvailable', isOnboardingContentAvailable);
                resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
				
            } else if('read'.equalsIgnoreCase(sortBy)) {
				String nextPageToken = String.isNotBlank(requestDataMap.get('nextPageToken')) ? String.valueOf(requestDataMap.get('nextPageToken')):'0';
				Boolean queryUnreadFlag = true;
        		Boolean queryReadFlag = false;
				if (String.isNotBlank(nextPageToken) && nextPageToken.contains(':')) {
					String afterColonStr = nextPageToken.substringAfter(':');
					String beforeColonStr = nextPageToken.substringBefore(':');
					
					if (String.isNotBlank(afterColonStr)) {
						queryUnreadFlag = false; 
						queryReadFlag = true;
						nextPageToken = afterColonStr;
					} else {
						nextPageToken = beforeColonStr; 
					}
				}
				Integer offsetVal = String.isNotBlank(nextPageToken)? Integer.valueOf(nextPageToken):0;
				List<Content_Interaction__c> myReadDetails = [SELECT Id, Content__c FROM Content_Interaction__c WHERE People__c = :loggedInPeopleId AND Content__r.Content_Onboarding_Status__c IN :onboardingStatus AND View_Count__c > 0 WITH SECURITY_ENFORCED];
                Set<Id> contentIds = new Set<Id>();
                for(Content_Interaction__c readDetail:myReadDetails) {
                    contentIds.add(readDetail.Content__c);
                }

                Map<String, Object> soqlParamMap = new Map<String, Object>();
		        soqlParamMap.put('soqlParam1', siteIds);
		        soqlParamMap.put('soqlParam2', orgOnboarding);
				soqlParamMap.put('soqlParam3', siteOnboarding);
				soqlParamMap.put('soqlParam4', contentIds);
				
				//read count
				String query = 'SELECT COUNT(Id) recordCount FROM Simpplr_Content__c WHERE Is_Published__c = true AND Is_Deleted__c = false AND (Content_Onboarding_Status__c = :soqlParam2 OR (Site__c = :soqlParam1 AND Content_Onboarding_Status__c = :soqlParam3)) AND Id IN :soqlParam4';
                List<AggregateResult> aggrList = (List<AggregateResult>) SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
                Integer readCount = aggrList[0].get('recordCount') != null ? Integer.valueOf(String.valueOf(aggrList[0].get('recordCount'))) : 0;
                
				//unread count
				query = 'SELECT COUNT(Id) recordCount FROM Simpplr_Content__c WHERE Is_Published__c = true AND Is_Deleted__c = false AND (Content_Onboarding_Status__c = :soqlParam2 OR (Site__c = :soqlParam1 AND Content_Onboarding_Status__c = :soqlParam3)) AND Id NOT IN :soqlParam4';
                aggrList = (List<AggregateResult>) SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
				Integer unreadCount = aggrList[0].get('recordCount') != null ? Integer.valueOf(String.valueOf(aggrList[0].get('recordCount'))) : 0;
                
				String queryUnread =  'SELECT ' + contentFields + ' FROM Simpplr_Content__c WHERE Is_Published__c = true AND Is_Deleted__c = false AND '+ 	
										'(Content_Onboarding_Status__c = :orgOnboarding OR (Site__c IN :siteIds AND Content_Onboarding_Status__c = :siteOnboarding))AND '+
										 'Id NOT IN :contentIds ORDER BY Onboarding_Added_Date__c DESC LIMIT :recordLimit OFFSET :offsetVal';

				String queryRead =  'SELECT ' + contentFields + ' FROM Simpplr_Content__c WHERE Is_Published__c = true AND Is_Deleted__c = false AND '+ 	
										 '(Content_Onboarding_Status__c = :orgOnboarding OR (Site__c IN :siteIds AND Content_Onboarding_Status__c = :siteOnboarding)) AND '+
										  'Id IN :contentIds ORDER BY Onboarding_Added_Date__c DESC LIMIT :recordLimit OFFSET :offsetVal';

				
				List<ContentWrapper> contentWrapperList = new List<ContentWrapper>();
				List<Simpplr_Content__c> contentList= new List<Simpplr_Content__c>();

				if (queryUnreadFlag) {
					contentList = Database.query(queryUnread);
					if (contentList.size() == recordLimit) {
        				contentList.remove((contentList.size()-1));
        				contentWrapperList = contentListToLightWrapper(contentList , null);
	        			nextPageToken = String.valueOf(offsetVal + size)+':';
					
					// else if Unread has finised and we need more records to meet the page size 
        			//then query the read mustreads with the help of below queryReadFlag
					} else if (contentList.size() < size ) {
						queryUnreadFlag = false; 
						queryReadFlag = true;
						offsetVal = 0;
						recordLimit = recordLimit - contentList.size();
					
					// else size of Unread is exactly same as the page size then put the nextpage token
					// in a way that in next hit we need to query the READ mustreads
					} else if (contentList.size() == size) {	
						contentWrapperList = contentListToLightWrapper(contentList , null);
						offsetVal = 0;
					
						// if there are READ records then set nextPage token to ':0' 
						if (Database.query(queryRead).size() > 0) {
							nextPageToken = ':0';
					
						// else if there are no records of READ then just set nextpageToken to null	
						} else {
						nextPageToken = null;
						}		
					} 
				}

				if (queryReadFlag) {
        			contentList.addAll((List<Simpplr_Content__c>) Database.query(queryRead));
        			contentWrapperList = contentListToLightWrapper(contentList , null); 
        			
        			// if there are more records than page size
        			if (contentWrapperList.size() == (size + 1)) {
        				contentWrapperList.remove(contentWrapperList.size()-1);
        				
        				// if came here directly without going to UNREAD block 
        				if (recordLimit == (size + 1) ) {
        					nextpageToken = ':'+ String.valueOf(offsetVal + size);
        				
        				// else came here to meet page size after finishing UNREAD list	
        				} else {
        					nextpageToken = ':'+ String.valueOf(recordLimit -1);
        				}
        			// met the page size and now no need to query more.	
        			} else {
        				nextPagetoken = null;
        			}
        		}
				
				Boolean isOnboardingContentAvailable = contentList.size()>0 ? true : false;
				
				//** Prepare result *
                List<Object> listOfItems = new List<Object>();
                List<Object> unreadLst = new List<Object>();
                List<Object> readLst = new List<Object>();
                for(ContentWrapper cw:contentWrapperList) {
					if(!contentIds.contains(cw.contentId)) {
                        unreadLst.add(new Map<String, Object> {
                            'type' => 'Unread',
                            'data' => cw
                        });
                    } else {
                        readLst.add(new Map<String, Object> {
                            'type' => 'Read',
                            'data' => cw
                        });
                    }
				}
				listOfItems.addAll(unreadLst);
				listOfItems.addAll(readLst);
                
                result.put('readCount', readCount);
				result.put('unreadCount', unreadCount);
                result.put('listOfItems', listOfItems);
                result.put('nextPageToken', nextPageToken);
				result.put('isOnboardingContentAvailable', isOnboardingContentAvailable);
                resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);

            }
                    		        
    	}
    	catch(Exception e){
    		logger.logError('AllContentDataServer.getMyOnboardingContents()-----could not retrieve data----',e);
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
    	}
    	return resultWrapper;
    }

    public ResponseWrapper getFeedOnboardingContents(String data) {
        logger.logDebug('AllContentDataServer.getFeedOnboardingContents()---data---' + data);
        ResponseWrapper resultWrapper = New ResponseWrapper();
        try {
            Map<String,String> requestDataMap = (Map<String,String>) JSON.deserialize(data, Type.forName('Map<String, String>'));
            Integer size = String.isNotBlank(requestDataMap.get('size')) ? Integer.valueOf(requestDataMap.get('size')) : SimpplrContext.simpplrDefaultPageSize;
            Integer recordlimit = size + 1;
			Integer offset = String.isNotBlank(requestDataMap.get('nextPageToken') != null ? requestDataMap.get('nextPageToken') : '') ? Integer.valueOf(String.valueOf(requestDataMap.get('nextPageToken'))) : 0;
            String siteId = requestDataMap.get('siteId');

            List<Site_Role__c> mySiteRoles = UserContext.mySitesRolesList;
            Set<Id> siteIds = new Set<Id>();
            for(Site_Role__c role:mySiteRoles) {
                siteIds.add(role.Site__c);
            }

            String orgOnboarding = ServiceConstants.CONTENT_STATUS_ORG_ONBOARDING;
            String siteOnboarding = ServiceConstants.CONTENT_STATUS_SITE_ONBOARDING;
            List<String> onboardingStatus = new List<String> {orgOnboarding, siteOnboarding};
            String contentFields = String.join(getContentFieldList(), ',');
            Map<String,Object> result = New Map<String,Object>();

            List<Content_Interaction__c> myReadDetails = [SELECT Id, Content__c FROM Content_Interaction__c WHERE People__c = :loggedInPeopleId AND Content__r.Content_Onboarding_Status__c IN :onboardingStatus AND View_Count__c > 0 WITH SECURITY_ENFORCED];
            Set<Id> contentIds = new Set<Id>();
            for(Content_Interaction__c readDetail:myReadDetails) {
                contentIds.add(readDetail.Content__c);
            }

            String query='';
			String nextPageQuery = 'LIMIT :recordlimit OFFSET :offset';
			if(String.isNotBlank(siteId)) {
				query = 'SELECT ' + contentFields + ' FROM Simpplr_Content__c WHERE Site__c = :siteId AND Is_Published__c = true AND Is_Deleted__c = false AND Content_Onboarding_Status__c IN :onboardingStatus ORDER BY Onboarding_Added_Date__c DESC ' + nextPageQuery;
			}  else {
            	query = 'SELECT ' + contentFields + ' FROM Simpplr_Content__c WHERE Is_Published__c = true AND Is_Deleted__c = false AND (Content_Onboarding_Status__c = :orgOnboarding OR (Site__c IN :siteIds AND Content_Onboarding_Status__c = :siteOnboarding)) ORDER BY Onboarding_Added_Date__c DESC ' + nextPageQuery;
			}
			logger.logDebug('AllContentDataServer.getFeedOnboardingContents()---query---' + query);
			
			List<Simpplr_Content__c> contentList = Database.query(query);
			List<ContentWrapper> contentWrapperList = contentListToLightWrapper(contentList, null);
            
            //** Prepare result *
            List<Object> listOfItems = new List<Object>();
            for(ContentWrapper cw:contentWrapperList) {
                if(!contentIds.contains(cw.contentId)) {
                    listOfItems.add(cw);
                }
            }
            for(ContentWrapper cw:contentWrapperList) {
                if(contentIds.contains(cw.contentId)) {
                    listOfItems.add(cw);
                }
            }   
            
            result.put('listOfItems', listOfItems);
            resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
        } catch(Exception e) {
            logger.logError('AllContentDataServer.getFeedOnboardingContents()-----could not retrieve data----',e);
            resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return resultWrapper;
    }

	/**
     * @description This method is used to fetch And Sort contents on score basis from AI 
     * @param listOfContentIds 
     * @param digestLimit
     * @return  `List<Simpplr_Content__c>`
    */
    @TestVisible
	public List<Simpplr_Content__c> getSortedContentList(Set<String> listOfContentIds, Integer digestLimit) {
        Map<String, Object> soqlParamMap = new  Map<String, Object>();
		Set<Id> sitesIFollowIdSet = UserContext.sitesIFollowIdSet;
		soqlParamMap.put('soqlParam1', listOfContentIds);
		soqlParamMap.put('soqlParam2', UserContext.peopleId);
		soqlParamMap.put('soqlParam3', DateTime.now());
		soqlParamMap.put('soqlParam4', sitesIFollowIdSet);
		String query = 'SELECT '+String.join(getContentFieldList(),',')+' FROM Simpplr_Content__c WHERE Id IN :soqlParam1 AND '
					+ ' Is_Deleted__c = false AND Is_Published__c=true AND Status__c = \'Approved\' AND Activated_By_Feature__c = true AND ((Site__c != null And Site__r.is_Active__c = true '
					+ ' And Site__r.Show_In_Simpplr__c = true) OR TYPE__c = \'BlogPost\') limit 50';
        query = query.replaceAll('loggedInPeopleId','soqlParam2');
		query = query.replaceAll('currentDateTime','soqlParam3');
		query = query.replaceAll('sitesIFollowIdSet','soqlParam4');
		logger.logDebug('AllContentDataServer.getSortedContentList()----query----'+query); 
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		List<Simpplr_Content__c> listOfSimpCont = (List<Simpplr_Content__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);								
        Map<String,Simpplr_Content__c> contentMap = new Map<String,Simpplr_Content__c>();
		for(Simpplr_Content__c contentRecored : listOfSimpCont){
			contentMap.put(contentRecored.Id, contentRecored);
		}
		Integer loopCounter = 0;
		List<Simpplr_Content__c> contentList = new List<Simpplr_Content__c>();
		for(String contentId : listOfContentIds) { //Sort on score basis from AI
			if(loopCounter < digestLimit && contentMap.get(contentId) != null) {
					contentList.add(contentMap.get(contentId));
			}else if(loopCounter == (digestLimit - 1)){
				break;
			}
			loopCounter = loopCounter +1;
		}
		return contentList;
    }

	public Map<String,String> getContentToDateMap(List<Simpplr_Content__c> contentObjList, String action) {
        Map<String, Object> soqlParamMap = new  Map<String, Object>();
        Map<String, String> contToDateMap = new Map<String, String>();
        soqlParamMap.put('soqlParam1', contentObjList);
		soqlParamMap.put('soqlParam2', action);
        String query = 'SELECT Id,Content__c,Action_DateTime__c,CreatedDate,Action__c  from Content_Audit_Trail__c where Content__c =:soqlParam1 AND Action__c =:soqlParam2';
        if(action.equalsIgnoreCase('Submitted')) {
            query += ' AND Content__r.Status__c =:soqlParam2';
        }
        query += ' order by Action_DateTime__c desc';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<Content_Audit_Trail__c> listOfContAudTrail = (List<Content_Audit_Trail__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
        for(Content_Audit_Trail__c conAudTrail : listOfContAudTrail) {
            if(conAudTrail.Content__c!=null && !contToDateMap.containsKey(conAudTrail.Content__c)) {
                contToDateMap.put(Id.valueOf(conAudTrail.Content__c), Utility.dateToDisplayString(conAudTrail.Action_DateTime__c,'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
            }
        }
        return contToDateMap;
    }
}