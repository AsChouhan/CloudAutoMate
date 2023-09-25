/** 
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class FeedDataServer extends DataServer {
	/*
	private static final String STR_KEY_ERROR_RESOURCE_NOT_FOUND = 'feed.single_post.not_found_error_flash';
    */

    private final String ACTION_VALUE_SEARCH = 'search';
    private final String ACTION_GET_POPULAR_CONTENT = 'getPopularContent';
    private final String ACTION_GET_MUST_READ_CONTENT = 'getMustReadContent';
    private final String ACTION_GET_UPCOMING_EVENTS = 'getUpcomingEvents';
    private final String ACTION_GET_PEOPLE_POSTS = 'getPeoplePosts';
    private final String ACTION_GET_FEED_ONBOARDING_CONTENT = 'getFeedOnboardingContent';
    private final String ACTION_SAVE_ONBOARDING_FLAG = 'saveFeedOnboardingFlag';
    private final String ACTION_CREATE_FEED_COMMENT_FOR_EXTERNAL_SRC = 'createFeedCommentForExternalSrc';
    private final String ACTION_CREATE_FEED_ITEM_FOR_EXTERNAL_SRC = 'createFeedItemForExternalSrc';

	public override void handleRequest () { 
		String redirectUrl = null;
		logger.logDebug('FeedDataServer----entered handleRequest----');
		try {
            String action = readParam(REQUEST_PARAM_ACTION);
        	
            if (ACTION_GET_POPULAR_CONTENT.equalsIgnoreCase(action)) {
                logger.logDebug('FeedDataServer----getPopularPosts----'); 
                AllContentDataServer allContentDSObj = new AllContentDataServer();
                Map<String, String> requestMap = new Map<String, String>();
                requestMap.put('siteId', readParam('siteId'));
                requestMap.put('size', '12');
                response = allContentDSObj.getPopularContents(JSON.serialize(requestMap));
            
            } else if(ACTION_GET_MUST_READ_CONTENT.equalsIgnoreCase(action)){
                logger.logDebug('FeedDataServer----getMustReadContent----'); 
                AllContentDataServer allContentDSObj = new AllContentDataServer();
                Map<String, String> requestMap = new Map<String, String>();
                requestMap.put('siteId', readParam('siteId'));
                requestMap.put('filter', 'unread');
                requestMap.put('size', '999');
                response = allContentDSObj.getContentMustReadForUser(JSON.serialize(requestMap));

            } else if(ACTION_GET_UPCOMING_EVENTS.equalsIgnoreCase(action)){
                logger.logDebug('FeedDataServer----getUpcomingEvents----'); 
                AllContentDataServer allContentDSObj = new AllContentDataServer();
                Map<String, String> requestMap = new Map<String, String>();
                requestMap.put('siteId', readParam('siteId'));
                requestMap.put('size', '12');
                requestMap.put('type', 'event');
                requestMap.put('maxAllowedEventEndDateTime', String.valueOf(System.now().addDays(7)));
                response = allContentDSObj.getLatestContents(JSON.serialize(requestMap));
                
            } else if(ACTION_GET_PEOPLE_POSTS.equalsIgnoreCase(action)){
                logger.logDebug('FeedDataServer----getPeoplePosts----'); 
                response = getPeoplePosts(readParam('variant'));
                
            } else if(ACTION_GET_FEED_ONBOARDING_CONTENT.equalsIgnoreCase(action)){
                logger.logDebug('FeedDataServer----getFeedOnboardingContent----');
                AllContentDataServer allContentDSObj = new AllContentDataServer();
                Map<String, String> requestMap = new Map<String, String>();
                requestMap.put('siteId', readParam('siteId'));
                requestMap.put('size', '999');
                response = allContentDSObj.getFeedOnboardingContents(JSON.serialize(requestMap));
            
            }else if(ACTION_SAVE_ONBOARDING_FLAG.equalsIgnoreCase(action)){
                logger.logDebug('FeedDataServer----saveFeedOnboardingFlag----');
                Map<String, String> requestMap = new Map<String, String>();
                requestMap.put('isOnboardingDisabledOnFeed', readParam('isOnboardingDisabledOnFeed'));
                response = saveFeedOnboardingFlag(JSON.serialize(requestMap));
                
            } else if(ACTION_CREATE_FEED_COMMENT_FOR_EXTERNAL_SRC.equalsIgnoreCase(action)){
                logger.logDebug('FeedDataServer----createFeedCommentForExternalSrc----');
                
                String payload = readParam('data');
                Map<String,Object> requestData = (Map<String,Object>)JSON.deserializeUntyped(payload);

                Map<String, Object> requestMap = new Map<String, Object>();

                requestMap.put('bodyJson', JSON.serialize(requestData.get('bodyJson')));
                requestMap.put('feedPostId', requestData.get('feedPostId'));
                requestMap.put('creatorUserId', requestData.get('creatorUserId'));

                response = createFeedCommentForExternalSrc(JSON.serialize(requestMap));

            } else if(ACTION_CREATE_FEED_ITEM_FOR_EXTERNAL_SRC.equalsIgnoreCase(action)){
                logger.logDebug('FeedDataServer----createFeedItemForExternalSrc----');
                
                String payload = readParam('data');
                response = createFeedItemForExternalSrc(payload);

            } else {
                String nextPageToken = readSafeParam('nextPageToken');
                String size = readSafeParam('size');
                String subjectId = readSafeParam('subjectId');
                String feedType =  readSafeParam('type');
                String searchTerm = readSafeParam('term');
                searchTerm = String.isNotBlank(searchTerm) ?  searchTerm.trim() : '';
                String sortBy = readSafeParam('sort');
                String postId = readSafeParam('postId');
                String origin = readSafeParam('origin');   

                if ('mobile'.equalsIgnoreCase(origin) && 'me'.equalsIgnoreCase(subjectId) && 
                            String.isBlank(sortBy) && String.isBlank(feedType)) {
                    sortBy = UserContext.getCurrentUserSettings.Feed_Sort_Order__c;
                    feedType = UserContext.getCurrentUserSettings.feed_type__c;

                } else if ('mobile'.equalsIgnoreCase(origin) && 'record'.equalsIgnoreCase(feedType)  
                        && String.isBlank(sortBy)) {
                    sortBy = UserContext.getCurrentUserSettings.Feed_Sort_Order__c;
                }

                if ('favorites'.equalsIgnoreCase(feedType)) {
                    feedType = 'bookmarks';
                }

                /*Feed Search Block */
                if (searchTerm != null && searchTerm.trim().length() > 0) {
                    logger.logDebug('FeedDataServer----Searching feed');
                    if (searchTerm.startsWith('\\"')) {
                        searchTerm = searchTerm.replaceFirst('\\\\"', '');
                    }
                    
                    searchTerm = '*' + searchTerm + '*';

                    /**Timeline search */
                    if (SimpplrContext.feedMode == 'timeline') { 
                        
                        if (nextPageToken == null || String.isBlank(nextPageToken)) {
                            nextPageToken = '0';
                        }

                        FeedElementPageWrapper feedElementPageWrapObj = new FeedElementPageWrapper();
                        feedElementPageWrapObj = FeedServiceProvider.searchTimeLineFeed(feedType, 
                                Integer.valueOf(nextPageToken), Integer.valueOf(size), 
                                searchTerm, sortBy);
                        response =  buildResponseWrapper('success', null, feedElementPageWrapObj);

                    /**Timeline and content search */
                    } else if (SimpplrContext.feedMode == 'timeline_comment') {
                        FeedElementPageWrapper feedElementPageWrapObj = new FeedElementPageWrapper();
                        feedElementPageWrapObj = FeedServiceProvider.searchTimeLineAndContentFeed(null, 
                                feedType, subjectId , nextPageToken, Integer.valueOf(size), 
                                searchTerm, sortBy);
                        if(!('record'.equalsIgnoreCase(feedType) && 
                            subjectId != null && subjectId.startsWith(Utility.getSimpplrContentPrefix()))){
                            
                            feedElementPageWrapObj = filterOutQuestionPost(feedElementPageWrapObj);
                        }
                        response =  buildResponseWrapper('success', null, feedElementPageWrapObj);

                    /**Full feed search */
                    } else if (size != null && subjectId != null && feedType != null && sortBy != null) {
                        ConnectApi.FeedElementPage feedElementPageObj = FeedConnectAPIService.searchFeeds(null, 
                                feedType, subjectId, nextPageToken, Integer.valueOf(size), 
                                searchTerm, sortBy);
                        FeedElementPageWrapper feedElementPageWrapObj = new FeedElementPageWrapper();
                        feedElementPageWrapObj = FeedDataAdapter.convertFeedElementPageToWrapper(feedElementPageObj);
                        if(!('record'.equalsIgnoreCase(feedType) && 
                            subjectId.startsWith(Utility.getSimpplrContentPrefix()))){
                            
                            feedElementPageWrapObj = filterOutQuestionPost(feedElementPageWrapObj);
                        }
                        List<FeedElementWrapper> listOfFeedElemWrapTemp = new List<FeedElementWrapper> ();

                        for (FeedElementWrapper feedElemObj: feedElementPageWrapObj.listOfItems) { 

                            if ((feedElemObj.postType == 'link' && feedElemObj.postedOn != null && 
                                    (feedElemObj.postedOn.type == 'page' || 
                                    feedElemObj.postedOn.type == 'album' || 
                                    feedElemObj.postedOn.type == 'blogpost' || 
                                    feedElemObj.postedOn.type == 'event')) 
                                    || feedElemObj.postType == 'timeline') {
        
                                if (feedElemObj.postedOn.isPublished) { 
            
                                        feedElemObj.postType = 'timeline';
                                        feedElemObj.site = feedElemObj.postedOn.site;
                                        feedElemObj.body = null; 
                                }

                            }
                            
                            listOfFeedElemWrapTemp.add(feedElemObj);

                        }
                        
                        feedElementPageWrapObj.listOfItems = new List<FeedElementWrapper>();
                        feedElementPageWrapObj.listOfItems.addAll(listOfFeedElemWrapTemp);
                        feedElementPageWrapObj.sortBy = sortBy;
                        feedElementPageWrapObj.type = feedType;
                        response =  buildResponseWrapper('success', null, feedElementPageWrapObj);
                        
                    }

                /*Single feed block */
                } else if (feedType != null && feedType == 'FilteredRecord' && postId != null) {
                    logger.logDebug('FeedDataServer----SingleFeed');

                    if (SimpplrContext.feedMode == 'timeline') {
                        throw new SimpplrException(ServiceConstants.ERROR_404);

                    } else if (SimpplrContext.feedMode == 'timeline_comment') {
                        List<Simpplr_Content__Feed> listOfSimpContentFeed = [SELECT id
                                FROM simpplr_content__feed 
                                WHERE Id=:postId WITH SECURITY_ENFORCED];
                        
                        if (!listOfSimpContentFeed.isEmpty()) {
                            FeedElementPageWrapper feedElementPageWrapObj = new FeedElementPageWrapper();
                            feedElementPageWrapObj = FeedServiceProvider.getSingleFeedRecord(postId, feedType, 
                                    sortBy, size);
                            response =  buildResponseWrapper('success', null, feedElementPageWrapObj);
                    
                        } else {
                            throw new SimpplrException(ServiceConstants.ERROR_404);
                        }

                        if (nextPageToken == null || String.isBlank(nextPageToken)) {
                            nextPageToken = '0';
                        } 
   
                   } else {
                       FeedElementPageWrapper feedElementPageWrapObj = new FeedElementPageWrapper();
                       feedElementPageWrapObj = FeedServiceProvider.getSingleFeedRecord(postId, feedType, 
                               sortBy, size);
                       response =  buildResponseWrapper('success', null, feedElementPageWrapObj);
                   }
                /*Multiple feeds black */ 
                } else if (feedType != null && feedType == 'FilteredMultipleRecords') {
                    logger.logDebug('FeedDataServer----MultipleFeeds');
                    String postIds = readSafeParam('postIds');
                    List<String> postIdList = postIds.split(',');
                        if (SimpplrContext.feedMode == 'timeline') {
                            throw new SimpplrException(ServiceConstants.ERROR_404);
    
                        } else {
                           FeedElementPageWrapper feedElementsPageWrapObj = new FeedElementPageWrapper();
                           feedElementsPageWrapObj = FeedServiceProvider.getMultipleFeedRecords(postIdList, feedType, 
                                   sortBy, size);
                           response =  buildResponseWrapper('success', null, feedElementsPageWrapObj);
                       }
                    /*Feed Page */ 
                } else {
                    logger.logDebug('FeedDataServer----getFeedPage');
                    if (SimpplrContext.feedMode == 'timeline') {

                        if (nextPageToken == null || String.isBlank(nextPageToken)) {
                            nextPageToken = '0';
                        }

                        FeedElementPageWrapper feedElementPageWrapObj = new FeedElementPageWrapper();
                        feedElementPageWrapObj = FeedServiceProvider.getTimeLineFeedPage(null, 
                                Integer.valueOf(size), Integer.valueOf(nextPageToken), feedType, 
                                subjectId);
                        response =  buildResponseWrapper('success', null, feedElementPageWrapObj);

                    } else if (SimpplrContext.feedMode == 'timeline_comment') {

                        if (nextPageToken == null || String.isBlank(nextPageToken)) {
                            nextPageToken = '0';
                        }

                        FeedElementPageWrapper feedElementPageWrapObj = new FeedElementPageWrapper();
                        feedElementPageWrapObj = FeedServiceProvider.getTimeLineAndContentFeedPage(null, 
                                Integer.valueOf(size), Integer.valueOf(nextPageToken), feedType, sortBy, 
                                subjectId, origin);

                        response =  buildResponseWrapper('success', null, feedElementPageWrapObj);

                    } else { 

                        if (size != null && subjectId != null && feedType != null && sortBy != null) {
                            FeedElementPageWrapper feedElementPageWrapObj = new FeedElementPageWrapper();
                            feedElementPageWrapObj = FeedServiceProvider.getFeedElementsPage(feedType, 
                                    subjectId, nextPageToken, size, sortBy, origin);
                            response =  buildResponseWrapper('success', null, feedElementPageWrapObj);
                        }
    
                    }

                }

                /**RAW data from connectAPI */
                String showFullData = readParam('showFullData');
                        
                if (showFullData != null) {
                    ConnectApi.FeedElementPage feedElementPageObj = FeedConnectAPIService.getFeedElementsFromFeed(null,
                            feedType, subjectId, nextPageToken, Integer.valueOf(size), sortBy);
                    response =  buildResponseWrapper('success', null, feedElementPageObj);
                }

            } 
		
		} catch (Exception e) {
			logger.logError(e.getMessage(), e);
			response = buildResponseWrapper(RESPONSE_STATUS_ERROR, 
					MessageHelper.translateSFMessageToErrorCode(e), null);
        	
			if (String.isNotBlank(redirectUrl)) {
        		response.redirectUrl = redirectUrl;
        	}	

		}

	}
    
    @TestVisible
    private FeedElementPageWrapper filterOutQuestionPost(FeedElementPageWrapper feedElementPageWrapObj) {
        List<FeedElementWrapper> listOfFeedElemWrapTemp = new List<FeedElementWrapper> ();
        Integer questionCount = 0;
        Integer totalCount = (Integer)feedElementPageWrapObj.total;

        for (FeedElementWrapper feedElemObj: feedElementPageWrapObj.listOfItems) {
            if (feedElemObj.postType == 'question') {
                questionCount++;
            } else {
                listOfFeedElemWrapTemp.add(feedElemObj);
            }
        }
        feedElementPageWrapObj.listOfItems = new List<FeedElementWrapper>();
        feedElementPageWrapObj.listOfItems.addAll(listOfFeedElemWrapTemp);
        feedElementPageWrapObj.total = totalCount != null ? totalCount - questionCount : null;
        return feedElementPageWrapObj;
    }

    private ResponseWrapper getPeoplePosts (String variant) {
    	logger.logDebug('FeedDataServer.getPeoplePosts()----variant----' + variant);
        ResponseWrapper response = null;
        List<PeopleListingWrapper> peopleDataList = new List<PeopleListingWrapper>();
       
        try {
            String segmentId;
            if(SimpplrContext.isSegmentsEnabled) {
                segmentId = UserContext.segmentId;
            }

            PeopleContentProvider providerObj = new PeopleContentProvider();
			if('latest_hires'.equalsIgnoreCase(variant)) {
				peopleDataList = providerObj.getNewHiresForPeoplePosts(segmentId, false);
            } else {
				peopleDataList = providerObj.getCelebrationsForPeoplePosts(segmentId, false);
			}
            
            Map<String, Object> resultMap = new Map<String, Object>(); 
            resultMap.put('listOfItems' , peopleDataList);

            response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Celebrations detail response successful', resultMap);
        
        } catch (Exception e) {
        	logger.logError('Could not retrieve Celebrations Data',e);
        	response = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
        logger.logDebug('FeedDataServer.getPeoplePosts()----response----' + response);
        return response;
    }

    private ResponseWrapper saveFeedOnboardingFlag(String requestData) {
    	logger.logDebug('FeedDataServer.saveFeedOnboardingFlag()----requestData----'+requestData);
        if (String.isBlank(requestData)) {
    		throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
    	}

        ResponseWrapper responseWrapperObj = new ResponseWrapper();
        try {
            Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(requestData);
            String peopleId = UserContext.peopleId;
            List<People_Preference__c> peoplePrefList = [SELECT Id, Disable_Onboarding_Feed__c FROM People_Preference__c WHERE People__r.Id =:peopleId AND Is_Deleted__c = false AND People__r.Is_Deleted__c = false WITH SECURITY_ENFORCED];
            Boolean isOnboardingDisabledOnFeed = requestDataMap != null && !requestDataMap.isEmpty() ? Boolean.valueOf(requestDataMap.get('isOnboardingDisabledOnFeed')) : null;
            if (!peoplePrefList.isEmpty() && isOnboardingDisabledOnFeed != null) {
            	List<Schema.SObjectField> fieldsToBeUpdated = new List<Schema.SObjectField>();
                peoplePrefList[0].Disable_Onboarding_Feed__c = isOnboardingDisabledOnFeed;
                fieldsToBeUpdated.add(People_Preference__c.Disable_Onboarding_Feed__c);
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			    SIMPESAPI.accessController().updateAsUser(peoplePrefList[0], fieldsToBeUpdated);
	        }
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Allow onboarding flag saved successfully!', null);
        } catch (Exception e) {
        	logger.logError('FeedDataServer------could not save allow onboarding flag setting',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('FeedDataServer.saveFeedOnboardingFlag()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }

    private ResponseWrapper createFeedCommentForExternalSrc(String requestData) {
    	logger.logDebug('FeedDataServer.createFeedCommentForExternalSrc()----requestData----'+requestData);
        if (String.isBlank(requestData)) {
    		throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
    	}

        ResponseWrapper responseWrapperObj = new ResponseWrapper();
        try {

            Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(requestData);
            String feedPostId = (String) requestDataMap.get('feedPostId');
            String bodyJson = (String) requestDataMap.get('bodyJson');
            String creatorUserId = (String) requestDataMap.get('creatorUserId');

            FeedComment feedCommentObject = new FeedComment();
            feedCommentObject.FeedItemId = feedPostId;
            feedCommentObject.CommentBody = ServiceConstants.FEED_COMMENT_BODY_PLACEHOLDER;
            feedCommentObject.CreatedById = creatorUserId;
            feedCommentObject.CommentType = 'TextComment';
            feedCommentObject.IsRichText = true;

            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			feedCommentObject = (FeedComment) SIMPESAPI.accessController().insertAsUser(feedCommentObject, new List<Schema.SObjectField>{
                FeedComment.FeedItemId,
                FeedComment.CommentBody,
                FeedComment.CreatedById,
                FeedComment.CommentType,
                FeedComment.IsRichText});

            ConnectApi.CommentInput feedItemInputObject = (ConnectApi.CommentInput) JSON.deserialize(bodyJson, ConnectApi.CommentInput.class);
            ConnectApi.Comment commentObj = ConnectApi.ChatterFeeds.updateComment(null, feedCommentObject.Id, 
                feedItemInputObject);

            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, RESPONSE_STATUS_SUCCESS, commentObj);
            responseWrapperObj.responseTimeStamp = String.valueOf(system.now().getTime());
            
        } catch (Exception e) {

        	logger.logError('FeedDataServer------could not create feed for External Source', e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('FeedDataServer.createFeedCommentForExternalSrc()----responseWrapperObj----' + responseWrapperObj);
        return responseWrapperObj;
    }

    private ResponseWrapper createFeedItemForExternalSrc(String requestData) {
    	logger.logDebug('FeedDataServer.createFeedItemForExternalSrc()----requestData----'+requestData);

        if (String.isBlank(requestData)) {
    		throw new SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
    	}

        ResponseWrapper responseWrapperObj = new ResponseWrapper();
        try {

            Criteria.Feed criteriaFeedObj = (Criteria.Feed)JSON.deserialize(requestData, Criteria.Feed.class);

            if (String.isBlank(criteriaFeedObj.creatorUserId)) {
                throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
            }
            
            PeopleDao peopleDaoObj = new PeopleDao();
            String creatorUserId = criteriaFeedObj.creatorUserId.startsWith('005') ? criteriaFeedObj.creatorUserId : peopleDaoObj.getUserIdByPeopleId(criteriaFeedObj.creatorUserId);

            Boolean isRecognitionPost = criteriaFeedObj.recognitionBody != null ? true : false;

            FeedItem feedItemObject = new FeedItem();
            feedItemObject.Body = ServiceConstants.FEED_BODY_PLACEHOLDER;
            feedItemObject.ParentId = criteriaFeedObj.subjectId != 'me' ? criteriaFeedObj.subjectId : creatorUserId;
            feedItemObject.createdById = creatorUserId;
            feedItemObject.IsRichText = true;
            feedItemObject.type = 'TextPost';

            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			feedItemObject = (FeedItem) SIMPESAPI.accessController().insertAsUser(feedItemObject, new List<Schema.SObjectField>{
                FeedItem.ParentId,
                FeedItem.Body,
                FeedItem.CreatedById,
                FeedItem.type,
                FeedItem.IsRichText});

            FeedElementWrapper feedElementWrapperObj = new FeedElementWrapper();
            if (criteriaFeedObj.recognitionBody != null) {
                criteriaFeedObj.recognitionBody.feedElementId = feedItemObject.Id; //Attach feed element id
                //create recognition
                FeedDataAdapter.createRecognition(new List<FeedElementWrapper.RecognitionInfo>{criteriaFeedObj.recognitionBody});
            }
			feedElementWrapperObj = FeedServiceProvider.updateFeedElement(criteriaFeedObj.communityId, feedItemObject.id,
			criteriaFeedObj.textBody, criteriaFeedObj.bodyJson, criteriaFeedObj.moderationResult, criteriaFeedObj.recognitionBody, criteriaFeedObj.externalFiles);

            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, RESPONSE_STATUS_SUCCESS, feedElementWrapperObj);
            responseWrapperObj.responseTimeStamp = String.valueOf(system.now().getTime());
            
        } catch (Exception e) {

        	logger.logError('FeedDataServer------could not create feed for External Source', e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('FeedDataServer.createFeedItemForExternalSrc()----responseWrapperObj----' + responseWrapperObj);
        return responseWrapperObj;
    }
}