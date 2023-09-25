/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class AnalyticsLegacyDataServer extends DataServer{ 
	
	private AnalyticsDao analyticsDaoObj = new AnalyticsDao(); 
	
	private final String ACTION_GET_LOGINS = 'getLogins';
	private final String ACTION_GET_PAGE_VIEWS = 'getPageviews';
	private final String ACTION_GET_ADOPTION = 'getAdoption';
	private final String ACTION_GET_ADOPTION_COUNTS = 'getAdoptionCounts';
	private final String ACTION_GET_ADOPTION_AVERAGE = 'getAdoptionAverage';
	
	private final String ACTION_GET_ENGAGEMENT_FEED_POSTS = 'getEngagementFeedPosts';
	private final String ACTION_GET_ENGAGEMENT_FEED_LIKES = 'getEngagementFeedLikes';
	private final String ACTION_GET_ENGAGEMENT_FEED_REPLIES = 'getEngagementFeedReplies';
	private final String ACTION_GET_ENGAGEMENT_FEED_SHARES = 'getEngagementFeedShares';
	
	private final String ACTION_GET_ENGAGEMENT_CONTENT_FAVORITES = 'getEngagementContentFavorites';
	private final String ACTION_GET_ENGAGEMENT_CONTENT_LIKES = 'getEngagementContentLikes';
	private final String ACTION_GET_ENGAGEMENT_CONTENT_POSTS = 'getEngagementContentPosts';
	private final String ACTION_GET_ENGAGEMENT_CONTENT_PUBLISHED = 'getEngagementContentPublished';
	private final String ACTION_GET_ENGAGEMENT_CONTENT_REPLIES = 'getEngagementContentReplies';
	private final String ACTION_GET_ENGAGEMENT_CONTENT_SHARES = 'getEngagementContentShares';
	private final String ACTION_GET_ENGAGEMENT_CONTENT_VIEWS = 'getEngagementContentViews';
	private final String ACTION_GET_ENGAGEMENT_CONTENT_TYPES = 'getEngagementContentTypes';
	
	private final String ACTION_GET_PERFORMANCE_SITES_MEMBERS = 'getPerformanceSitesmembers';
	private final String ACTION_GET_PERFORMANCE_SITES_VIEWS = 'getPerformanceSitesviews';
	private final String ACTION_GET_PERFORMANCE_SITES_REPLIES = 'getPerformanceSitesreplies';
	private final String ACTION_GET_PERFORMANCE_SITES_LIKES = 'getPerformanceSiteslikes';
	private final String ACTION_GET_PERFORMANCE_SITES_POSTS = 'getPerformanceSitesposts';
	private final String ACTION_GET_PERFORMANCE_SITES_PUBLISHED = 'getPerformanceSitespublished';
	
	private final String ACTION_GET_PERFORMANCE_PEOPLE_FAVORITES = 'getPerformancePeopleFavorites';
	private final String ACTION_GET_PERFORMANCE_PEOPLE_FAVORITES_RECEIVED = 'getPerformancePeopleFavorites_Received';
	private final String ACTION_GET_PERFORMANCE_PEOPLE_PUBLISHED = 'getPerformancePeoplePublished';
	private final String ACTION_GET_PERFORMANCE_PEOPLE_MENTIONS = 'getPerformancePeopleMentions';
	private final String ACTION_GET_PERFORMANCE_PEOPLE_POSTS = 'getPerformancePeoplePosts';
	private final String ACTION_GET_PERFORMANCE_PEOPLE_REPLIES = 'getPerformancePeopleReplies';
	private final String ACTION_GET_PERFORMANCE_PEOPLE_REPLIES_RECEIVED = 'getPerformancePeopleReplies_Received';
	private final String ACTION_GET_PERFORMANCE_PEOPLE_FOLLOWERS = 'getPerformancePeopleFollowers';
	private final String ACTION_GET_PERFORMANCE_PEOPLE_FOLLOWING = 'getPerformancePeopleFollowing';
	private final String ACTION_GET_PERFORMANCE_PEOPLE_LIKES = 'getPerformancePeopleLikes';
	private final String ACTION_GET_PERFORMANCE_PEOPLE_LIKES_RECEIVED = 'getPerformancePeopleLikes_Received';
	private final String ACTION_GET_PERFORMANCE_PEOPLE_SHARES = 'getPerformancePeopleShares';
	private final String ACTION_GET_PERFORMANCE_PEOPLE_SHARES_RECEIVED = 'getPerformancePeopleShares_Received';
	
	private final String ACTION_GET_PERFORMANCE_CONTENT_FAVORITES = 'getPerformanceContentFavorites';
	private final String ACTION_GET_PERFORMANCE_CONTENT_LIKES = 'getPerformanceContentLikes';
	private final String ACTION_GET_PERFORMANCE_CONTENT_POSTS = 'getPerformanceContentPosts';
	private final String ACTION_GET_PERFORMANCE_CONTENT_REPLIES = 'getPerformanceContentReplies';
	private final String ACTION_GET_PERFORMANCE_CONTENT_SHARES = 'getPerformanceContentShares';
	private final String ACTION_GET_PERFORMANCE_CONTENT_UNUSEFUL = 'getPerformanceContentUnuseful';
	private final String ACTION_GET_PERFORMANCE_CONTENT_USEFUL = 'getPerformanceContentUseful';
	private final String ACTION_GET_PERFORMANCE_CONTENT_VIEWS = 'getPerformanceContentViews';
	
	private final String ACTION_GET_PERFORMANCE_TOPIC_ENDORSEMENTS = 'getPerformanceTopicsEndorsements';
	private final String ACTION_GET_PERFORMANCE_TOPIC_EXPERTISE = 'getPerformanceTopicsExpertise';
	private final String ACTION_GET_PERFORMANCE_TOPIC_VIEWS = 'getPerformanceTopicsViews';
	private final String ACTION_GET_PERFORMANCE_TOPIC_FOLLOWERS = 'getPerformanceTopicsFollowers';
	
	private final String ACTION_GET_PERFORMANCE_SEARCH = 'getPerformanceSearch';
	private final String ACTION_GET_PERFORMANCE_ZERO_SEARCH_RESULTS = 'getPerformanceZeroSearchResults';
	private final string ACTION_GET_PERFORMANCE_PEOPLE_PROFILE_VIEWS = 'getPerformancePeopleprofile_views';
	private final String REQUEST_PARAM_DATA = 'data';
	private String toDate;
	private String fromDate;
	private String siteId;
	
    public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
    public override void handleRequest() {
        try {

			// Load label map for AnalyticsDataServer to avoid language map error
			labelMap = LocaleContext.getLabelMap('AnalyticsDataServer', UserContext.languageLocaleKey);
			
        	logger.logDebug('AnalyticsLegacyDataServer----entered handleRequest----');
        	
	    	String action = readParam(REQUEST_PARAM_ACTION);
	    	
        	String requestData = readParam(REQUEST_PARAM_DATA);
        	
        	if(ACTION_GET_LOGINS.equalsIgnoreCase(action)) {
                response = getLogins(requestData);
                
            }else if(ACTION_GET_PAGE_VIEWS.equalsIgnoreCase(action)) {
                response = getPageviews(requestData);
                
            }else if(ACTION_GET_ADOPTION.equalsIgnoreCase(action)) {
                response = getAdoption(requestData);
                
            }else if(ACTION_GET_ADOPTION_COUNTS.equalsIgnoreCase(action)) {
                response = getAdoptionCounts(requestData);
                
            }else if(ACTION_GET_ADOPTION_AVERAGE.equalsIgnoreCase(action)) {
                response = getAdoptionAverage(requestData);
                
            }else if(ACTION_GET_ENGAGEMENT_FEED_POSTS.equalsIgnoreCase(action)) {
                response = getEngagementFeedPosts(requestData);
                
            }else if(ACTION_GET_ENGAGEMENT_FEED_LIKES.equalsIgnoreCase(action)) {
                response = getEngagementFeedLikes(requestData);
                
            }else if(ACTION_GET_ENGAGEMENT_FEED_REPLIES.equalsIgnoreCase(action)) {
                response = getEngagementFeedReplies(requestData);
                
            }else if(ACTION_GET_ENGAGEMENT_FEED_SHARES.equalsIgnoreCase(action)) {
                response = getEngagementFeedShares(requestData);
                
            }else if(ACTION_GET_ENGAGEMENT_CONTENT_FAVORITES.equalsIgnoreCase(action)) {
                response = getEngagementContentBookmarks(requestData);
                
            }else if(ACTION_GET_ENGAGEMENT_CONTENT_LIKES.equalsIgnoreCase(action)) {
                response = getEngagementContentLikes(requestData);
                
            }else if(ACTION_GET_ENGAGEMENT_CONTENT_POSTS.equalsIgnoreCase(action)) {
                response = getEngagementContentPosts(requestData);
                
            }else if(ACTION_GET_ENGAGEMENT_CONTENT_PUBLISHED.equalsIgnoreCase(action)) {
                response = getEngagementContentPublished(requestData);
                
            }else if(ACTION_GET_ENGAGEMENT_CONTENT_REPLIES.equalsIgnoreCase(action)) {
                response = getEngagementContentReplies(requestData);
                
            }else if(ACTION_GET_ENGAGEMENT_CONTENT_SHARES.equalsIgnoreCase(action)) {
                response = getEngagementContentShares(requestData);
                
            }else if(ACTION_GET_ENGAGEMENT_CONTENT_VIEWS.equalsIgnoreCase(action)) {
                response = getEngagementContentViews(requestData);
                
            }else if(ACTION_GET_ENGAGEMENT_CONTENT_TYPES.equalsIgnoreCase(action)) {
                response = getEngagementContentTypes(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_SITES_MEMBERS.equalsIgnoreCase(action)) {
                response = getPerformanceSitesmembers(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_SITES_VIEWS.equalsIgnoreCase(action)) {
                response = getPerformanceSitesviews(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_SITES_REPLIES.equalsIgnoreCase(action)) {
                response = getPerformanceSitesreplies(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_SITES_LIKES.equalsIgnoreCase(action)) {
                response = getPerformanceSiteslikes(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_SITES_POSTS.equalsIgnoreCase(action)) {
                response = getPerformanceSitesposts(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_SITES_PUBLISHED.equalsIgnoreCase(action)) {
                response = getPerformanceSitespublished(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_PEOPLE_FAVORITES.equalsIgnoreCase(action)) {
                response = getPerformancePeopleFavorites(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_PEOPLE_FAVORITES_RECEIVED.equalsIgnoreCase(action)) {
                response = getPerformancePeopleFavoritesReceived(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_PEOPLE_PUBLISHED.equalsIgnoreCase(action)) {
                response = getPerformancePeoplePublished(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_PEOPLE_MENTIONS.equalsIgnoreCase(action)) {
                response = getPerformancePeopleMentions(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_PEOPLE_POSTS.equalsIgnoreCase(action)) {
                response = getPerformancePeoplePosts(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_PEOPLE_REPLIES.equalsIgnoreCase(action)) {
                response = getPerformancePeopleReplies(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_PEOPLE_REPLIES_RECEIVED.equalsIgnoreCase(action)) {
                response = getPerformancePeopleRepliesReceived(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_PEOPLE_FOLLOWERS.equalsIgnoreCase(action)) {
                response = getPerformancePeopleFollowers(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_PEOPLE_FOLLOWING.equalsIgnoreCase(action)) {
                response = getPerformancePeopleFollowing(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_PEOPLE_LIKES.equalsIgnoreCase(action)) {
                response = getPerformancePeopleLikes(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_PEOPLE_LIKES_RECEIVED.equalsIgnoreCase(action)) {
                response = getPerformancePeopleLikesReceived(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_PEOPLE_SHARES.equalsIgnoreCase(action)) {
                response = getPerformancePeopleShares(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_PEOPLE_SHARES_RECEIVED.equalsIgnoreCase(action)) {
                response = getPerformancePeopleSharesReceived(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_PEOPLE_PROFILE_VIEWS.equalsIgnoreCase(action)) {
                response = getPerformancePeopleProfileViews(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_CONTENT_FAVORITES.equalsIgnoreCase(action)) {
                response = getPerformanceContentFavorites(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_CONTENT_LIKES.equalsIgnoreCase(action)) {
                response = getPerformanceContentLikes(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_CONTENT_POSTS.equalsIgnoreCase(action)) {
                response = getPerformanceContentPosts(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_CONTENT_REPLIES.equalsIgnoreCase(action)) {
                response = getPerformanceContentReplies(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_CONTENT_SHARES.equalsIgnoreCase(action)) {
                response = getPerformanceContentShares(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_CONTENT_UNUSEFUL.equalsIgnoreCase(action)) {
                response = getPerformanceContentUnuseful(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_CONTENT_USEFUL.equalsIgnoreCase(action)) {
                response = getPerformanceContentUseful(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_CONTENT_VIEWS.equalsIgnoreCase(action)) {
                response = getPerformanceContentViews(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_TOPIC_ENDORSEMENTS.equalsIgnoreCase(action)) {
                response = getPerformanceTopicsEndorsements(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_TOPIC_EXPERTISE.equalsIgnoreCase(action)) {
                response = getPerformanceTopicsExpertise(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_TOPIC_VIEWS.equalsIgnoreCase(action)) {
                response = getPerformanceTopicsViews(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_TOPIC_FOLLOWERS.equalsIgnoreCase(action)) {
                response = getPerformanceTopicsFollowers(requestData);
                
            }else if(ACTION_GET_PERFORMANCE_SEARCH.equalsIgnoreCase(action)) {
                response = getPerformanceSearch(requestData);
                
            } else if(ACTION_GET_PERFORMANCE_ZERO_SEARCH_RESULTS.equalsIgnoreCase(action)) {
                response = getPerformanceZeroSearchResults(requestData);
                
            } else{
                throw new SimpplrException(ExceptionCode.INVALID_PARAMETER.name());
            }
            
        } catch (Exception ex) {
        	response = buildResponseWrapper(RESPONSE_STATUS_ERROR,MessageHelper.translateSFMessageToErrorCode(ex), null);
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
   private ResponseWrapper getLogins(String requestData){
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
        	AnalyticsWrapper.Logins loginDataObj = analyticsDaoObj.getLoginsAnalytics(fromDate, toDate);      	
        
	        if(loginDataObj == null) {
	        	loginDataObj = new AnalyticsWrapper.Logins();
        	}
	        if(toDate!=null && fromdate!=null){
	        	loginDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_LOGINS+'&to='+toDate+'&from='+fromDate ;
	        }
	        
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, loginDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult; 
	}
    
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	private ResponseWrapper getPageviews(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
        	AnalyticsWrapper.PageViews pageViewsObj = analyticsDaoObj.getPageviewsAnalytics(fromDate, toDate);      	
        	if(toDate!=null && fromdate!=null){
	        	pageViewsObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PAGE_VIEWS+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, pageViewsObj);	
	                
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult; 
	}
	
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	private ResponseWrapper getAdoption(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.Adoption adoptionObj = new AnalyticsWrapper.Adoption();
        	String fromDate = String.valueOf(requestDataMap.get('from'));
			String toDate = String.valueOf(requestDataMap.get('to'));
        	List<AnalyticsWrapper.AdoptionData> adoptionDataObjList = analyticsDaoObj.getAdoptionAnalytics(fromDate, toDate);      	
	        adoptionObj.data  = adoptionDataObjList;
			if(toDate!=null && fromdate!=null){
				adoptionObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_ADOPTION+'&to='+toDate+'&from='+fromDate ;
			}
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, adoptionObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult;
	}
	
	 /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	private ResponseWrapper getAdoptionCounts(String requestData){
        ResponseWrapper localResult = null;
        try {
	    	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.AdoptionCount adoptionCountObj = new AnalyticsWrapper.AdoptionCount();
        	String fromDate = String.valueOf(requestDataMap.get('from'));
			String toDate = String.valueOf(requestDataMap.get('to'));
        	AnalyticsWrapper.AdoptionCountData adoptionCountDataObj = analyticsDaoObj.getAdoptionCount(fromDate, toDate);      	
	        adoptionCountObj.data = adoptionCountDataObj;
			if(toDate!=null && fromdate!=null){
				adoptionCountObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_ADOPTION_COUNTS+'&to='+toDate+'&from='+fromDate ;
			}
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, adoptionCountObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult; 
	}
	 
	 
	 /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	private ResponseWrapper getAdoptionAverage(String requestData){  
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.AdoptionAverage adoptionAverageDataObj = new AnalyticsWrapper.AdoptionAverage();
        	String fromDate = String.valueOf(requestDataMap.get('from'));
			String toDate = String.valueOf(requestDataMap.get('to'));
        	List<AnalyticsWrapper.AdoptionAverageData> adoptionAverageDataList = new List<AnalyticsWrapper.AdoptionAverageData>();
        	adoptionAverageDataList = analyticsDaoObj.getAdoptionAverage(fromDate, toDate);      	
	        
	        if(adoptionAverageDataList != null) {
				adoptionAverageDataObj.data = adoptionAverageDataList;
			}else{
			    adoptionAverageDataObj.data = new List<AnalyticsWrapper.AdoptionAverageData>();
			}
			if(toDate!=null && fromdate!=null){
				adoptionAverageDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_ADOPTION_AVERAGE+'&to='+toDate+'&from='+fromDate ;
			}
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, adoptionAverageDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult; 
	}
	
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	private ResponseWrapper getEngagementFeedPosts(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.Engagementfeed engagementfeedDataObj = new AnalyticsWrapper.Engagementfeed();
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        siteId = String.valueof(requestDataMap.get('siteId'));
        	List<AnalyticsWrapper.EngagementfeedData> listofEngagementfeedWrapper = analyticsDaoObj.getEngagementFeedPosts(fromDate,toDate,siteId);      	
	        
	        if(listofEngagementfeedWrapper != null) {
	        	engagementfeedDataObj.data = listofEngagementfeedWrapper;
        	}else{
        		engagementfeedDataObj.data = new List<AnalyticsWrapper.EngagementfeedData>();
        	}
	        if(siteId!=null){
	        	engagementfeedDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?type=posts&action='+ACTION_GET_ENGAGEMENT_FEED_POSTS+'&to='+toDate+'&from='+fromDate+'&siteId='+siteId ;
	        }else{
	        	engagementfeedDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?type=posts&action='+ACTION_GET_ENGAGEMENT_FEED_POSTS+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, engagementfeedDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult; 
	}
	
	private ResponseWrapper getEngagementFeedLikes(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.Engagementfeed engagementfeedDataObj = new AnalyticsWrapper.Engagementfeed();
        	
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        siteId = String.valueof(requestDataMap.get('siteId'));
        
        	List<AnalyticsWrapper.EngagementfeedData> listofEngagementfeedWrapper = analyticsDaoObj.getEngagementFeedLikes(fromDate,toDate,siteId);      	
        	
	        if(listofEngagementfeedWrapper != null) {
	        	engagementfeedDataObj.data = listofEngagementfeedWrapper;
        	}else{
        		engagementfeedDataObj.data = new List<AnalyticsWrapper.EngagementfeedData>();
        	}
	        if(siteId!=null){
	        	engagementfeedDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?type=likes&action='+ACTION_GET_ENGAGEMENT_FEED_LIKES+'&to='+toDate+'&from='+fromDate+'&siteId='+siteId ;
	        }else{
	        	engagementfeedDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?type=likes&action='+ACTION_GET_ENGAGEMENT_FEED_LIKES+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, engagementfeedDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult; 
	}
	
	private ResponseWrapper getEngagementFeedReplies(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.Engagementfeed engagementfeedDataObj = new AnalyticsWrapper.Engagementfeed();
        	
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        siteId = String.valueof(requestDataMap.get('siteId'));
	        
        	List<AnalyticsWrapper.EngagementfeedData> listofEngagementfeedWrapper = analyticsDaoObj.getEngagementFeedReplies(fromDate,toDate,siteId);      	
        	
	        if(listofEngagementfeedWrapper != null) {
	        	engagementfeedDataObj.data = listofEngagementfeedWrapper;
        	}else{
        		engagementfeedDataObj.data = new List<AnalyticsWrapper.EngagementfeedData>();
        	}
	        if(siteId!=null){
	        	engagementfeedDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?type=replies&action='+ACTION_GET_ENGAGEMENT_FEED_REPLIES+'&to='+toDate+'&from='+fromDate+'&siteId='+siteId ;
	        }else{
	        	engagementfeedDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?type=replies&action='+ACTION_GET_ENGAGEMENT_FEED_REPLIES+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, engagementfeedDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult; 
	}
	
	private ResponseWrapper getEngagementFeedShares(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.Engagementfeed engagementfeedDataObj = new AnalyticsWrapper.Engagementfeed();
        	
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        siteId = String.valueof(requestDataMap.get('siteId'));
	        
        	List<AnalyticsWrapper.EngagementfeedData> listofEngagementfeedWrapper = analyticsDaoObj.getEngagementFeedShares(fromDate,toDate,siteId);      	
	        
	        if(listofEngagementfeedWrapper != null) {
	        	engagementfeedDataObj.data = listofEngagementfeedWrapper;
        	}else{
        		engagementfeedDataObj.data = new List<AnalyticsWrapper.EngagementfeedData>();
        	}
	        if(siteId!=null){
	        	engagementfeedDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?type=shares&action='+ACTION_GET_ENGAGEMENT_FEED_SHARES+'&to='+toDate+'&from='+fromDate+'&siteId='+siteId ;
	        }else{
	        	engagementfeedDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?type=shares&action='+ACTION_GET_ENGAGEMENT_FEED_SHARES+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, engagementfeedDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult; 
	}
	
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	private ResponseWrapper getEngagementContentBookmarks(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.EngagementContent engagementContentDataObj = new AnalyticsWrapper.EngagementContent();
        	
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        siteId = String.valueof(requestDataMap.get('siteId'));
	        
        	List<AnalyticsWrapper.EngagementContentData> listofEngagementContentWrapper = analyticsDaoObj.getEngagementContentBookmarks(fromDate,toDate,siteId);      	
        	
	        if(listofEngagementContentWrapper != null) {
	        	engagementContentDataObj.data = listofEngagementContentWrapper;
        	}else{
        		engagementContentDataObj.data = new List<AnalyticsWrapper.EngagementContentData>();
        	}
            if(siteId!=null){
	        	engagementContentDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?type=favorites&action='+ACTION_GET_ENGAGEMENT_CONTENT_FAVORITES+'&to='+toDate+'&from='+fromDate+'&siteId='+siteId ;
	        }else{
	        	engagementContentDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?type=favorites&action='+ACTION_GET_ENGAGEMENT_CONTENT_FAVORITES+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, engagementContentDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult; 
	}
	
	private ResponseWrapper getEngagementContentLikes(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.EngagementContent engagementContentDataObj = new AnalyticsWrapper.EngagementContent();
        	
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        siteId = String.valueof(requestDataMap.get('siteId'));
        	List<AnalyticsWrapper.EngagementContentData> listofEngagementContentWrapper = analyticsDaoObj.getEngagementContentLikes(fromDate,toDate,siteId);      	
        	
	        if(listofEngagementContentWrapper != null) {
	        	engagementContentDataObj.data = listofEngagementContentWrapper;
        	}else{
        		engagementContentDataObj.data = new List<AnalyticsWrapper.EngagementContentData>();
        	}
	        if(siteId!=null){
	        	engagementContentDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?type=likes&action='+ACTION_GET_ENGAGEMENT_CONTENT_LIKES+'&to='+toDate+'&from='+fromDate+'&siteId='+siteId ;
	        }else{
	        	engagementContentDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?type=likes&action='+ACTION_GET_ENGAGEMENT_CONTENT_LIKES+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, engagementContentDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult; 
	}
	
	private ResponseWrapper getEngagementContentPosts(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.EngagementContent engagementContentDataObj = new AnalyticsWrapper.EngagementContent();
        	
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        siteId = String.valueof(requestDataMap.get('siteId'));
        	List<AnalyticsWrapper.EngagementContentData> listofEngagementContentWrapper = analyticsDaoObj.getEngagementContentPosts(fromDate,toDate,siteId);      	
        	
	        if(listofEngagementContentWrapper != null) {
	        	engagementContentDataObj.data = listofEngagementContentWrapper;
        	}else{
        		engagementContentDataObj.data = new List<AnalyticsWrapper.EngagementContentData>();
        	}
	        if(siteId!=null){
	        	engagementContentDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?type=posts&action='+ACTION_GET_ENGAGEMENT_CONTENT_POSTS+'&to='+toDate+'&from='+fromDate+'&siteId='+siteId ;
	        }else{
	        	engagementContentDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?type=posts&action='+ACTION_GET_ENGAGEMENT_CONTENT_POSTS+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, engagementContentDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult; 
	}
	
	private ResponseWrapper getEngagementContentPublished(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.EngagementContent engagementContentDataObj = new AnalyticsWrapper.EngagementContent();
        	
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        siteId = String.valueof(requestDataMap.get('siteId'));
        	List<AnalyticsWrapper.EngagementContentData> listofEngagementContentWrapper = analyticsDaoObj.getEngagementContentPublished(fromDate,toDate,siteId);      	
        	
	        if(listofEngagementContentWrapper != null) {
	        	engagementContentDataObj.data = listofEngagementContentWrapper;
        	}else{
        		engagementContentDataObj.data = new List<AnalyticsWrapper.EngagementContentData>();
        	}
        	if(siteId!=null){
	        	engagementContentDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?type=published&action='+ACTION_GET_ENGAGEMENT_CONTENT_PUBLISHED+'&to='+toDate+'&from='+fromDate+'&siteId='+siteId ;
	        }else{
	        	engagementContentDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?type=published&action='+ACTION_GET_ENGAGEMENT_CONTENT_PUBLISHED+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, engagementContentDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult; 
	}
	
	private ResponseWrapper getEngagementContentReplies(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.EngagementContent engagementContentDataObj = new AnalyticsWrapper.EngagementContent();
        	
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        siteId = String.valueof(requestDataMap.get('siteId'));
        	List<AnalyticsWrapper.EngagementContentData> listofEngagementContentWrapper = analyticsDaoObj.getEngagementContentReplies(fromDate,toDate,siteId);      	
        	
	        if(listofEngagementContentWrapper != null) {
	        	engagementContentDataObj.data = listofEngagementContentWrapper;
        	}else{
        		engagementContentDataObj.data = new List<AnalyticsWrapper.EngagementContentData>();
        	}
	        if(siteId!=null){
	        	engagementContentDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?type=replies&action='+ACTION_GET_ENGAGEMENT_CONTENT_REPLIES+'&to='+toDate+'&from='+fromDate+'&siteId='+siteId ;
	        }else{
	        	engagementContentDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?type=replies&action='+ACTION_GET_ENGAGEMENT_CONTENT_REPLIES+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, engagementContentDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult; 
	}
	
	private ResponseWrapper getEngagementContentShares(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.EngagementContent engagementContentDataObj = new AnalyticsWrapper.EngagementContent();
        	
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        siteId = String.valueof(requestDataMap.get('siteId'));
        	List<AnalyticsWrapper.EngagementContentData> listofEngagementContentWrapper = analyticsDaoObj.getEngagementContentShares(fromDate,toDate,siteId);      	
        	
	        if(listofEngagementContentWrapper != null) {
	        	engagementContentDataObj.data = listofEngagementContentWrapper;
        	}else{
        		engagementContentDataObj.data = new List<AnalyticsWrapper.EngagementContentData>();
        	}
	        if(siteId!=null){
	        	engagementContentDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?type=shares&action='+ACTION_GET_ENGAGEMENT_CONTENT_SHARES+'&to='+toDate+'&from='+fromDate+'&siteId='+siteId ;
	        }else{
	        	engagementContentDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?type=shares&action='+ACTION_GET_ENGAGEMENT_CONTENT_SHARES+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, engagementContentDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult; 
	}
	
	private ResponseWrapper getEngagementContentViews(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.EngagementContent engagementContentDataObj = new AnalyticsWrapper.EngagementContent();
        	
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        siteId = String.valueof(requestDataMap.get('siteId'));
	        String metric = String.valueof(requestDataMap.get('metric'));
	        
        	List<AnalyticsWrapper.EngagementContentData> listofEngagementContentWrapper = analyticsDaoObj.getEngagementContentViews(fromDate,toDate,siteId);      	
        	
	        if(listofEngagementContentWrapper != null) {
	        	engagementContentDataObj.data = listofEngagementContentWrapper;
        	}else{
        		engagementContentDataObj.data = new List<AnalyticsWrapper.EngagementContentData>();
        	}
	         if(siteId!=null){
	        	engagementContentDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?type=views&action='+ACTION_GET_ENGAGEMENT_CONTENT_VIEWS+'&to='+toDate+'&from='+fromDate+'&siteId='+siteId ;
	        }else{
	        	engagementContentDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?type=views&action='+ACTION_GET_ENGAGEMENT_CONTENT_VIEWS+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, engagementContentDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult;
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	private ResponseWrapper getEngagementContentTypes(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.EngagementContentTypes engagementContentTypesObj = new AnalyticsWrapper.EngagementContentTypes();
        	
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        siteId = String.valueof(requestDataMap.get('siteId'));
        	List<AnalyticsWrapper.EngagementContentTypesData> engagementContentTypesDataList = analyticsDaoObj.getEngagementContentTypes(fromDate,toDate,siteId);      	
        	
	        if(engagementContentTypesDataList != null) {
	        	engagementContentTypesObj.data = engagementContentTypesDataList;
        	}else{
        		engagementContentTypesObj.data = new List<AnalyticsWrapper.EngagementContentTypesData>();
        	}
	        if(siteId!=null){
	        	engagementContentTypesObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_ENGAGEMENT_CONTENT_TYPES+'&to='+toDate+'&from='+fromDate+'&siteId='+siteId ;
	        }else{
	        	engagementContentTypesObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_ENGAGEMENT_CONTENT_TYPES+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, engagementContentTypesObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult;  
	}
	
	
	/** 
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *  published    
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	
	private ResponseWrapper getPerformanceSitesmembers(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformanceSites performanceSitesDataObj = new AnalyticsWrapper.PerformanceSites();
        	
        	toDate = String.valueOf(requestDataMap.get('to'));
		    fromDate = String.valueOf(requestDataMap.get('from'));
        	List<AnalyticsWrapper.PerformanceSitesData> listofPerformanceSitesWrapper = analyticsDaoObj.getPerformanceSitesMembers(String.valueOf(requestDataMap.get('from')),String.valueOf(requestDataMap.get('to')));      	
	        
	        listofPerformanceSitesWrapper = (List<AnalyticsWrapper.PerformanceSitesData>)listToReturn(listofPerformanceSitesWrapper,List<AnalyticsWrapper.PerformanceSitesData>.class);
	        if(listofPerformanceSitesWrapper != null) {
	        	performanceSitesDataObj.data = listofPerformanceSitesWrapper;
        	}else{
        		performanceSitesDataObj.data = new List<AnalyticsWrapper.PerformanceSitesData>();
        	}
        	if(toDate!=null && fromDate!=null){
	        	performanceSitesDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_SITES_MEMBERS+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performanceSitesDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult; 
	}
	
	private ResponseWrapper getPerformanceSitesposts(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformanceSites performanceSitesDataObj = new AnalyticsWrapper.PerformanceSites();
        	
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
    		List<AnalyticsWrapper.PerformanceSitesData> listofPerformanceSitesWrapper = analyticsDaoObj.getPerformanceSitesPosts(String.valueOf(requestDataMap.get('from')),String.valueOf(requestDataMap.get('to')));      	
        
	        listofPerformanceSitesWrapper = (List<AnalyticsWrapper.PerformanceSitesData>)listToReturn(listofPerformanceSitesWrapper,List<AnalyticsWrapper.PerformanceSitesData>.class);
	        if(listofPerformanceSitesWrapper != null) {
	        	performanceSitesDataObj.data = listofPerformanceSitesWrapper;
        	}else{
        		performanceSitesDataObj.data = new List<AnalyticsWrapper.PerformanceSitesData>();
        	}
        	if(toDate!=null && fromDate!=null){
	        	performanceSitesDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_SITES_POSTS+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performanceSitesDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult; 
	}
	
	private ResponseWrapper getPerformanceSiteslikes(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformanceSites performanceSitesDataObj = new AnalyticsWrapper.PerformanceSites();
        	
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        
    		List<AnalyticsWrapper.PerformanceSitesData> listofPerformanceSitesWrapper = analyticsDaoObj.getPerformanceSitesLikes(fromdate,toDate);      	
        
	        listofPerformanceSitesWrapper = (List<AnalyticsWrapper.PerformanceSitesData>)listToReturn(listofPerformanceSitesWrapper,List<AnalyticsWrapper.PerformanceSitesData>.class);
	        if(listofPerformanceSitesWrapper != null) {
	        	performanceSitesDataObj.data = listofPerformanceSitesWrapper;
        	}else{
        		performanceSitesDataObj.data = new List<AnalyticsWrapper.PerformanceSitesData>();
        	}
        	
	        if(toDate!=null && fromDate!=null){
	        	performanceSitesDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_SITES_LIKES+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performanceSitesDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult; 
	}
	
	private ResponseWrapper getPerformanceSitesreplies(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformanceSites performanceSitesDataObj = new AnalyticsWrapper.PerformanceSites();
        	
        	toDate = String.valueOf(requestDataMap.get('to'));
        	fromDate = String.valueOf(requestDataMap.get('from'));
        	List<AnalyticsWrapper.PerformanceSitesData> listofPerformanceSitesWrapper = analyticsDaoObj.getPerformanceSitesReplies(String.valueOf(requestDataMap.get('from')),String.valueOf(requestDataMap.get('to')));      	
	      
	        listofPerformanceSitesWrapper = (List<AnalyticsWrapper.PerformanceSitesData>)listToReturn(listofPerformanceSitesWrapper,List<AnalyticsWrapper.PerformanceSitesData>.class);
	        if(listofPerformanceSitesWrapper != null) {
	        	performanceSitesDataObj.data = listofPerformanceSitesWrapper;
        	}else{
        		performanceSitesDataObj.data = new List<AnalyticsWrapper.PerformanceSitesData>();
        	}
        	
	        if(toDate!=null && fromDate!=null){
	        	performanceSitesDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_SITES_REPLIES+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performanceSitesDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult; 
	}
	
	private ResponseWrapper getPerformanceSitesviews(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformanceSites performanceSitesDataObj = new AnalyticsWrapper.PerformanceSites();
        	
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
        
        	List<AnalyticsWrapper.PerformanceSitesData> listofPerformanceSitesWrapper = analyticsDaoObj.getPerformanceSitesViews(String.valueOf(requestDataMap.get('from')),String.valueOf(requestDataMap.get('to')));      	
	      
	        listofPerformanceSitesWrapper = (List<AnalyticsWrapper.PerformanceSitesData>)listToReturn(listofPerformanceSitesWrapper,List<AnalyticsWrapper.PerformanceSitesData>.class);
	        if(listofPerformanceSitesWrapper != null) {
	        	performanceSitesDataObj.data = listofPerformanceSitesWrapper;
        	}else{
        		performanceSitesDataObj.data = new List<AnalyticsWrapper.PerformanceSitesData>();
        	}
        	if(toDate!=null && fromDate!=null){
	        	performanceSitesDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_SITES_VIEWS+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performanceSitesDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult; 
	}
	
	private ResponseWrapper getPerformanceSitespublished(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformanceSites performanceSitesDataObj = new AnalyticsWrapper.PerformanceSites();
        	
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
        
        	List<AnalyticsWrapper.PerformanceSitesData> listofPerformanceSitesWrapper = analyticsDaoObj.getPerformanceSitesContentPublished(String.valueOf(requestDataMap.get('from')),String.valueOf(requestDataMap.get('to')));      	
	      
	        listofPerformanceSitesWrapper = (List<AnalyticsWrapper.PerformanceSitesData>)listToReturn(listofPerformanceSitesWrapper,List<AnalyticsWrapper.PerformanceSitesData>.class);
	        if(listofPerformanceSitesWrapper != null) {
	        	performanceSitesDataObj.data = listofPerformanceSitesWrapper;
        	}else{
        		performanceSitesDataObj.data = new List<AnalyticsWrapper.PerformanceSitesData>();
        	}
        	if(toDate!=null && fromDate!=null){
	        	performanceSitesDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_SITES_PUBLISHED+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performanceSitesDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult; 
	}
	
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	private ResponseWrapper getPerformancePeopleFavorites(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformancePeople performancePeopleDataObj = new AnalyticsWrapper.PerformancePeople();
        	
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
        
        	List<AnalyticsWrapper.PerformancePeopleData> listofPerformancePeopleWrapper = analyticsDaoObj.getPerformancePeopleBookmarks(String.valueOf(requestDataMap.get('from')),String.valueOf(requestDataMap.get('to')));      	
	        
	        listofPerformancePeopleWrapper = (List<AnalyticsWrapper.PerformancePeopleData>)listToReturn(listofPerformancePeopleWrapper,List<AnalyticsWrapper.PerformancePeopleData>.class);
	        if(listofPerformancePeopleWrapper != null) {
	        	performancePeopleDataObj.data = listofPerformancePeopleWrapper;
        	}else{
        		performancePeopleDataObj.data = new List<AnalyticsWrapper.PerformancePeopleData>();
        	}
        	if(toDate!=null && fromDate!=null){
	        	performancePeopleDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_PEOPLE_FAVORITES+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performancePeopleDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult;  
	}
	
	private ResponseWrapper getPerformancePeopleFavoritesReceived(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformancePeople performancePeopleDataObj = new AnalyticsWrapper.PerformancePeople();
        	
        	 toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        
        	List<AnalyticsWrapper.PerformancePeopleData> listofPerformancePeopleWrapper = analyticsDaoObj.getPerformancePeopleBookmarksReceived(String.valueOf(requestDataMap.get('from')),String.valueOf(requestDataMap.get('to')));      	
	       
	        listofPerformancePeopleWrapper = (List<AnalyticsWrapper.PerformancePeopleData>)listToReturn(listofPerformancePeopleWrapper,List<AnalyticsWrapper.PerformancePeopleData>.class);
	        if(listofPerformancePeopleWrapper != null) {
	        	performancePeopleDataObj.data = listofPerformancePeopleWrapper;
        	}else{
        		performancePeopleDataObj.data = new List<AnalyticsWrapper.PerformancePeopleData>();
        	}
        	 if(toDate!=null && fromDate!=null){
	        	performancePeopleDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_PEOPLE_FAVORITES_RECEIVED+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performancePeopleDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult;  
	}
	
	private ResponseWrapper getPerformancePeoplePublished(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformancePeople performancePeopleDataObj = new AnalyticsWrapper.PerformancePeople();
        	
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        
        	List<AnalyticsWrapper.PerformancePeopleData> listofPerformancePeopleWrapper = analyticsDaoObj.getPerformancePeoplePublished(String.valueOf(requestDataMap.get('from')),String.valueOf(requestDataMap.get('to')));      	
	       
	        listofPerformancePeopleWrapper = (List<AnalyticsWrapper.PerformancePeopleData>)listToReturn(listofPerformancePeopleWrapper,List<AnalyticsWrapper.PerformancePeopleData>.class);
	        if(listofPerformancePeopleWrapper != null) {
	        	performancePeopleDataObj.data = listofPerformancePeopleWrapper;
        	}else{
        		performancePeopleDataObj.data = new List<AnalyticsWrapper.PerformancePeopleData>();
        	}
        	 if(toDate!=null && fromDate!=null){
	        	performancePeopleDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_PEOPLE_PUBLISHED+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performancePeopleDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult;  
	}
	
	private ResponseWrapper getPerformancePeopleMentions(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformancePeople performancePeopleDataObj = new AnalyticsWrapper.PerformancePeople();
        	
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        
        	List<AnalyticsWrapper.PerformancePeopleData> listofPerformancePeopleWrapper = analyticsDaoObj.getPerformancePeopleMentions(String.valueOf(requestDataMap.get('from')),String.valueOf(requestDataMap.get('to')));      	
	        
	        listofPerformancePeopleWrapper = (List<AnalyticsWrapper.PerformancePeopleData>)listToReturn(listofPerformancePeopleWrapper,List<AnalyticsWrapper.PerformancePeopleData>.class);
	        if(listofPerformancePeopleWrapper != null) {
	        	performancePeopleDataObj.data = listofPerformancePeopleWrapper;
        	}else{
        		performancePeopleDataObj.data = new List<AnalyticsWrapper.PerformancePeopleData>();
        	}
        	 if(toDate!=null && fromDate!=null){
	        	performancePeopleDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_PEOPLE_MENTIONS+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performancePeopleDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult;  
	}
	
	private ResponseWrapper getPerformancePeoplePosts(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformancePeople performancePeopleDataObj = new AnalyticsWrapper.PerformancePeople();
        	
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
        	List<AnalyticsWrapper.PerformancePeopleData> listofPerformancePeopleWrapper = analyticsDaoObj.getPerformancePeoplePosts(String.valueOf(requestDataMap.get('from')),String.valueOf(requestDataMap.get('to')));      	
	        
	        listofPerformancePeopleWrapper = (List<AnalyticsWrapper.PerformancePeopleData>)listToReturn(listofPerformancePeopleWrapper,List<AnalyticsWrapper.PerformancePeopleData>.class);
	        if(listofPerformancePeopleWrapper != null) {
	        	performancePeopleDataObj.data = listofPerformancePeopleWrapper;
        	}else{
        		performancePeopleDataObj.data = new List<AnalyticsWrapper.PerformancePeopleData>();
        	}
        	if(toDate!=null && fromDate!=null){
	        	performancePeopleDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_PEOPLE_POSTS+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performancePeopleDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult;  
	}
	
	private ResponseWrapper getPerformancePeopleReplies(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformancePeople performancePeopleDataObj = new AnalyticsWrapper.PerformancePeople();
        	
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        
        	List<AnalyticsWrapper.PerformancePeopleData> listofPerformancePeopleWrapper = analyticsDaoObj.getPerformancePeopleReplies(String.valueOf(requestDataMap.get('from')),String.valueOf(requestDataMap.get('to')));      	
	        
	        listofPerformancePeopleWrapper = (List<AnalyticsWrapper.PerformancePeopleData>)listToReturn(listofPerformancePeopleWrapper,List<AnalyticsWrapper.PerformancePeopleData>.class);
	        if(listofPerformancePeopleWrapper != null) {
	        	performancePeopleDataObj.data = listofPerformancePeopleWrapper;
        	}else{
        		performancePeopleDataObj.data = new List<AnalyticsWrapper.PerformancePeopleData>();
        	}
        	if(toDate!=null && fromDate!=null){
	        	performancePeopleDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_PEOPLE_REPLIES+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performancePeopleDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult;  
	}
	
	private ResponseWrapper getPerformancePeopleRepliesReceived(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformancePeople performancePeopleDataObj = new AnalyticsWrapper.PerformancePeople();
        	
        	 toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        
        	List<AnalyticsWrapper.PerformancePeopleData> listofPerformancePeopleWrapper = analyticsDaoObj.getPerformancePeopleRepliesReceived(String.valueOf(requestDataMap.get('from')),String.valueOf(requestDataMap.get('to')));      	
	       
	        listofPerformancePeopleWrapper = (List<AnalyticsWrapper.PerformancePeopleData>)listToReturn(listofPerformancePeopleWrapper,List<AnalyticsWrapper.PerformancePeopleData>.class);
	        if(listofPerformancePeopleWrapper != null) {
	        	performancePeopleDataObj.data = listofPerformancePeopleWrapper;
        	}else{
        		performancePeopleDataObj.data = new List<AnalyticsWrapper.PerformancePeopleData>();
        	}
        	if(toDate!=null && fromDate!=null){
	        	performancePeopleDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_PEOPLE_REPLIES_RECEIVED+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performancePeopleDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult;  
	}
	
	private ResponseWrapper getPerformancePeopleFollowers(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformancePeople performancePeopleDataObj = new AnalyticsWrapper.PerformancePeople();
        	
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        
        	List<AnalyticsWrapper.PerformancePeopleData> listofPerformancePeopleWrapper = analyticsDaoObj.getPerformancePeopleFollowers(String.valueOf(requestDataMap.get('from')),String.valueOf(requestDataMap.get('to')));      	
	        
	        listofPerformancePeopleWrapper = (List<AnalyticsWrapper.PerformancePeopleData>)listToReturn(listofPerformancePeopleWrapper,List<AnalyticsWrapper.PerformancePeopleData>.class);
	        if(listofPerformancePeopleWrapper != null) {
	        	performancePeopleDataObj.data = listofPerformancePeopleWrapper;
        	}else{
        		performancePeopleDataObj.data = new List<AnalyticsWrapper.PerformancePeopleData>();
        	}
        	 if(toDate!=null && fromDate!=null){
	        	performancePeopleDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_PEOPLE_FOLLOWERS+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performancePeopleDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult;  
	}
	
	private ResponseWrapper getPerformancePeopleFollowing(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformancePeople performancePeopleDataObj = new AnalyticsWrapper.PerformancePeople();
        	
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        
        	List<AnalyticsWrapper.PerformancePeopleData> listofPerformancePeopleWrapper = analyticsDaoObj.getPerformancePeopleFollowing(String.valueOf(requestDataMap.get('from')),String.valueOf(requestDataMap.get('to')));      	
	       
	        listofPerformancePeopleWrapper = (List<AnalyticsWrapper.PerformancePeopleData>)listToReturn(listofPerformancePeopleWrapper,List<AnalyticsWrapper.PerformancePeopleData>.class);
	        if(listofPerformancePeopleWrapper != null) {
	        	performancePeopleDataObj.data = listofPerformancePeopleWrapper;
        	}else{
        		performancePeopleDataObj.data = new List<AnalyticsWrapper.PerformancePeopleData>();
        	}
        	 if(toDate!=null && fromDate!=null){
	        	performancePeopleDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_PEOPLE_FOLLOWING+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performancePeopleDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult;  
	}
	
	private ResponseWrapper getPerformancePeopleLikes(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformancePeople performancePeopleDataObj = new AnalyticsWrapper.PerformancePeople();
        	
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        
        	List<AnalyticsWrapper.PerformancePeopleData> listofPerformancePeopleWrapper = analyticsDaoObj.getPerformancePeopleLikes(String.valueOf(requestDataMap.get('from')),String.valueOf(requestDataMap.get('to')));      	
	        
	        listofPerformancePeopleWrapper = (List<AnalyticsWrapper.PerformancePeopleData>)listToReturn(listofPerformancePeopleWrapper,List<AnalyticsWrapper.PerformancePeopleData>.class);
	        if(listofPerformancePeopleWrapper != null) {
	        	performancePeopleDataObj.data = listofPerformancePeopleWrapper;
        	}else{
        		performancePeopleDataObj.data = new List<AnalyticsWrapper.PerformancePeopleData>();
        	}
        	if(toDate!=null && fromDate!=null){
	        	performancePeopleDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_PEOPLE_LIKES+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performancePeopleDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult;  
	}
	
	private ResponseWrapper getPerformancePeopleLikesReceived(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformancePeople performancePeopleDataObj = new AnalyticsWrapper.PerformancePeople();
        	
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        
        	List<AnalyticsWrapper.PerformancePeopleData> listofPerformancePeopleWrapper = analyticsDaoObj.getPerformancePeopleLikesReceived(String.valueOf(requestDataMap.get('from')),String.valueOf(requestDataMap.get('to')));      	
	       
	        listofPerformancePeopleWrapper = (List<AnalyticsWrapper.PerformancePeopleData>)listToReturn(listofPerformancePeopleWrapper,List<AnalyticsWrapper.PerformancePeopleData>.class);
	        if(listofPerformancePeopleWrapper != null) {
	        	performancePeopleDataObj.data = listofPerformancePeopleWrapper;
        	}else{
        		performancePeopleDataObj.data = new List<AnalyticsWrapper.PerformancePeopleData>();
        	}
        	if(toDate!=null && fromDate!=null){
	        	performancePeopleDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_PEOPLE_LIKES_RECEIVED+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performancePeopleDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult;  
	}
	
	private ResponseWrapper getPerformancePeopleShares(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformancePeople performancePeopleDataObj = new AnalyticsWrapper.PerformancePeople();
        	
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
        	List<AnalyticsWrapper.PerformancePeopleData> listofPerformancePeopleWrapper = analyticsDaoObj.getPerformancePeopleShares(String.valueOf(requestDataMap.get('from')),String.valueOf(requestDataMap.get('to')));      	
	       
	        listofPerformancePeopleWrapper = (List<AnalyticsWrapper.PerformancePeopleData>)listToReturn(listofPerformancePeopleWrapper,List<AnalyticsWrapper.PerformancePeopleData>.class);
	        if(listofPerformancePeopleWrapper != null) {
	        	performancePeopleDataObj.data = listofPerformancePeopleWrapper;
        	}else{
        		performancePeopleDataObj.data = new List<AnalyticsWrapper.PerformancePeopleData>();
        	}
        	 if(toDate!=null && fromDate!=null){
	        	performancePeopleDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_PEOPLE_SHARES+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performancePeopleDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult;  
	}
	
	private ResponseWrapper getPerformancePeopleSharesReceived(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformancePeople performancePeopleDataObj = new AnalyticsWrapper.PerformancePeople();
        	
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        
        	List<AnalyticsWrapper.PerformancePeopleData> listofPerformancePeopleWrapper = analyticsDaoObj.getPerformancePeopleSharesReceived(String.valueOf(requestDataMap.get('from')),String.valueOf(requestDataMap.get('to')));      	
	        
	        listofPerformancePeopleWrapper = (List<AnalyticsWrapper.PerformancePeopleData>)listToReturn(listofPerformancePeopleWrapper,List<AnalyticsWrapper.PerformancePeopleData>.class);
	        if(listofPerformancePeopleWrapper != null) {
	        	performancePeopleDataObj.data = listofPerformancePeopleWrapper;
        	}else{
        		performancePeopleDataObj.data = new List<AnalyticsWrapper.PerformancePeopleData>();
        	}
        	if(toDate!=null && fromDate!=null){
	        	performancePeopleDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_PEOPLE_SHARES_RECEIVED+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performancePeopleDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult;
	}
	
	private ResponseWrapper getPerformancePeopleProfileViews(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformancePeople performancePeopleDataObj = new AnalyticsWrapper.PerformancePeople();
        	
        	List<AnalyticsWrapper.PerformancePeopleData> listofPerformancePeopleWrapper = analyticsDaoObj.getPerformancePeopleProfileViews(String.valueOf(requestDataMap.get('from')),String.valueOf(requestDataMap.get('to')));      	
	        toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        listofPerformancePeopleWrapper = (List<AnalyticsWrapper.PerformancePeopleData>)listToReturn(listofPerformancePeopleWrapper,List<AnalyticsWrapper.PerformancePeopleData>.class);
	        if(listofPerformancePeopleWrapper != null) {
	        	performancePeopleDataObj.data = listofPerformancePeopleWrapper;
        	}else{
        		performancePeopleDataObj.data = new List<AnalyticsWrapper.PerformancePeopleData>();
        	}
	        if(toDate!=null && fromDate!=null){
	        	performancePeopleDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_PEOPLE_PROFILE_VIEWS+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performancePeopleDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult;
	}
	
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	private ResponseWrapper getPerformanceContentFavorites(String requestData){ 
		List<AnalyticsWrapper.PerformanceContentData> listofPerformanceContentWrapper;
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformanceContent performanceContentDataObj = new AnalyticsWrapper.PerformanceContent();
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        String contentType = String.valueOf(requestDataMap.get('contentType'));
	        siteId = requestDataMap.get('siteId')!=null ? String.valueof(requestDataMap.get('siteId')) : '';
	        
        	if(contentType != null){
        		listofPerformanceContentWrapper = analyticsDaoObj.getPerformanceContentBookmarks(fromDate,toDate,contentType,siteId);
        	}else{
        		listofPerformanceContentWrapper = analyticsDaoObj.getPerformanceContentBookmarksAll(fromDate,toDate,siteId);
        	}
       
	        listofPerformanceContentWrapper = (List<AnalyticsWrapper.PerformanceContentData>)listToReturn(listofPerformanceContentWrapper,List<AnalyticsWrapper.PerformanceContentData>.class);
	        if(listofPerformanceContentWrapper != null) {
	        	performanceContentDataObj.data = listofPerformanceContentWrapper;
        	}else{
        		performanceContentDataObj.data = new List<AnalyticsWrapper.PerformanceContentData>();
        	}
	         if(toDate!=null && fromDate!=null){
	        	if(contentType != null){
	        		performanceContentDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_CONTENT_FAVORITES+'&to='+toDate+'&from='+fromDate+'&contentType='+contentType+'&siteId='+siteId;
	        	}else{
	        		performanceContentDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_CONTENT_FAVORITES+'&to='+toDate+'&from='+fromDate+'&siteId='+siteId;
	        	}
	        	
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performanceContentDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult; 
	}
	
	private ResponseWrapper getPerformanceContentLikes(String requestData){ 
		List<AnalyticsWrapper.PerformanceContentData> listofPerformanceContentWrapper;
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformanceContent performanceContentDataObj = new AnalyticsWrapper.PerformanceContent();
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        String contentType = String.valueOf(requestDataMap.get('contentType'));
	        siteId = requestDataMap.get('siteId')!=null ? String.valueof(requestDataMap.get('siteId')) : '';
        	
        	if(contentType != null){
        		listofPerformanceContentWrapper = analyticsDaoObj.getPerformanceContentLikes(fromDate,toDate,contentType,siteId);
        	}else{
        		listofPerformanceContentWrapper = analyticsDaoObj.getPerformanceContentLikesAll(fromDate,toDate,siteId);
        	}
    	      	
	        listofPerformanceContentWrapper = (List<AnalyticsWrapper.PerformanceContentData>)listToReturn(listofPerformanceContentWrapper,List<AnalyticsWrapper.PerformanceContentData>.class);
	        if(listofPerformanceContentWrapper != null) {
	        	performanceContentDataObj.data = listofPerformanceContentWrapper;
        	}else{
        		performanceContentDataObj.data = new List<AnalyticsWrapper.PerformanceContentData>();
        	}
        	
        	 if(toDate!=null && fromDate!=null){
	        	if(contentType != null){
	        		performanceContentDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_CONTENT_LIKES+'&to='+toDate+'&from='+fromDate+'&contentType='+contentType+'&siteId='+siteId;
	        	}else{
	        		performanceContentDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_CONTENT_LIKES+'&to='+toDate+'&from='+fromDate+'&siteId='+siteId;
	        	}
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performanceContentDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult; 
	}
	
	private ResponseWrapper getPerformanceContentPosts(String requestData){ 
		List<AnalyticsWrapper.PerformanceContentData> listofPerformanceContentWrapper;
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformanceContent performanceContentDataObj = new AnalyticsWrapper.PerformanceContent();
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        String contentType = String.valueOf(requestDataMap.get('contentType'));
	        siteId = requestDataMap.get('siteId')!=null ? String.valueof(requestDataMap.get('siteId')) : '';
	        
        	if(contentType != null){
        		listofPerformanceContentWrapper = analyticsDaoObj.getPerformanceContentPosts(fromDate,toDate,contentType,siteId);
        	}else{
        		listofPerformanceContentWrapper = analyticsDaoObj.getPerformanceContentPostsAll(fromDate,toDate,siteId);
        	}
        
	        listofPerformanceContentWrapper = (List<AnalyticsWrapper.PerformanceContentData>)listToReturn(listofPerformanceContentWrapper,List<AnalyticsWrapper.PerformanceContentData>.class);
	        if(listofPerformanceContentWrapper != null) {
	        	performanceContentDataObj.data = listofPerformanceContentWrapper;
        	}else{
        		performanceContentDataObj.data = new List<AnalyticsWrapper.PerformanceContentData>();
        	}
	        if(toDate!=null && fromDate!=null){
	        	if(contentType != null){
	        		performanceContentDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_CONTENT_POSTS+'&to='+toDate+'&from='+fromDate+'&contentType='+contentType+'&siteId='+siteId;
	        	}else{
	        		performanceContentDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_CONTENT_POSTS+'&to='+toDate+'&from='+fromDate+'&siteId='+siteId;
	        	}
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performanceContentDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult; 
	}
	
	private ResponseWrapper getPerformanceContentReplies(String requestData){ 
		List<AnalyticsWrapper.PerformanceContentData> listofPerformanceContentWrapper;
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformanceContent performanceContentDataObj = new AnalyticsWrapper.PerformanceContent();
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        String contentType = String.valueOf(requestDataMap.get('contentType'));
	        siteId = requestDataMap.get('siteId')!=null ? String.valueof(requestDataMap.get('siteId')) : '';
        	
        	if(contentType != null){
        		listofPerformanceContentWrapper = analyticsDaoObj.getPerformanceContentReplies(fromDate,toDate,contentType,siteId);
        	}else{
        		listofPerformanceContentWrapper = analyticsDaoObj.getPerformanceContentRepliesAll(fromDate,toDate,siteId);
        	}
    	      	
	        listofPerformanceContentWrapper = (List<AnalyticsWrapper.PerformanceContentData>)listToReturn(listofPerformanceContentWrapper,List<AnalyticsWrapper.PerformanceContentData>.class);
	        if(listofPerformanceContentWrapper != null) {
	        	performanceContentDataObj.data = listofPerformanceContentWrapper;
        	}else{
        		performanceContentDataObj.data = new List<AnalyticsWrapper.PerformanceContentData>();
        	}
        	if(toDate!=null && fromDate!=null){
	        	if(contentType != null){
	        		performanceContentDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_CONTENT_REPLIES+'&to='+toDate+'&from='+fromDate+'&contentType='+contentType+'&siteId='+siteId;
	        	}else{
	        		performanceContentDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_CONTENT_REPLIES+'&to='+toDate+'&from='+fromDate+'&siteId='+siteId;
	        	}
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performanceContentDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult; 
	}
	
	private ResponseWrapper getPerformanceContentShares(String requestData){ 
		List<AnalyticsWrapper.PerformanceContentData> listofPerformanceContentWrapper;
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformanceContent performanceContentDataObj = new AnalyticsWrapper.PerformanceContent();
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        String contentType = String.valueOf(requestDataMap.get('contentType'));
	        siteId = requestDataMap.get('siteId')!=null ? String.valueof(requestDataMap.get('siteId')) : '';
        	if(contentType != null){
        		listofPerformanceContentWrapper = analyticsDaoObj.getPerformanceContentShares(fromDate,toDate,contentType,siteId);
        	}else{
        		listofPerformanceContentWrapper = analyticsDaoObj.getPerformanceContentSharesAll(fromDate,toDate,siteId);
        	}
        
	        listofPerformanceContentWrapper = (List<AnalyticsWrapper.PerformanceContentData>)listToReturn(listofPerformanceContentWrapper,List<AnalyticsWrapper.PerformanceContentData>.class);
	        if(listofPerformanceContentWrapper != null) {
	        	performanceContentDataObj.data = listofPerformanceContentWrapper;
        	}else{
        		performanceContentDataObj.data = new List<AnalyticsWrapper.PerformanceContentData>();
        	}
        	if(toDate!=null && fromDate!=null){
	        	if(contentType != null){
	        		performanceContentDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_CONTENT_SHARES+'&to='+toDate+'&from='+fromDate+'&contentType='+contentType+'&siteId='+siteId;
	        	}else{
	        		performanceContentDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_CONTENT_SHARES+'&to='+toDate+'&from='+fromDate+'&siteId='+siteId;
	        	}
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performanceContentDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult; 
	}
	
	private ResponseWrapper getPerformanceContentUnuseful(String requestData){ 
		List<AnalyticsWrapper.PerformanceContentData> listofPerformanceContentWrapper;
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformanceContent performanceContentDataObj = new AnalyticsWrapper.PerformanceContent();
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        String contentType = String.valueOf(requestDataMap.get('contentType'));
	        siteId = requestDataMap.get('siteId')!=null ? String.valueof(requestDataMap.get('siteId')) : '';
        	
        	if(contentType != null){
        		listofPerformanceContentWrapper = analyticsDaoObj.getPerformanceContentUnuseful(fromDate,toDate,contentType,siteId);
        	}else{
        		listofPerformanceContentWrapper = analyticsDaoObj.getPerformanceContentUnusefulAll(fromDate,toDate,siteId);
        	}
    	
	        listofPerformanceContentWrapper = (List<AnalyticsWrapper.PerformanceContentData>)listToReturn(listofPerformanceContentWrapper,List<AnalyticsWrapper.PerformanceContentData>.class);
	        if(listofPerformanceContentWrapper != null) {
	        	performanceContentDataObj.data = listofPerformanceContentWrapper;
        	}else{
        		performanceContentDataObj.data = new List<AnalyticsWrapper.PerformanceContentData>();
        	}
        	if(toDate!=null && fromDate!=null){
	        	if(contentType != null){
	        		performanceContentDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_CONTENT_UNUSEFUL+'&to='+toDate+'&from='+fromDate+'&contentType='+contentType+'&siteId='+siteId;
	        	}else{
	        		performanceContentDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_CONTENT_UNUSEFUL+'&to='+toDate+'&from='+fromDate+'&siteId='+siteId;
	        	}
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performanceContentDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult; 
	}
	
	private ResponseWrapper getPerformanceContentUseful(String requestData){ 
		List<AnalyticsWrapper.PerformanceContentData> listofPerformanceContentWrapper;
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformanceContent performanceContentDataObj = new AnalyticsWrapper.PerformanceContent();
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        String contentType = String.valueOf(requestDataMap.get('contentType'));
	        siteId = requestDataMap.get('siteId')!=null ? String.valueof(requestDataMap.get('siteId')) : '';
	        
        	if(contentType != null){
        		listofPerformanceContentWrapper = analyticsDaoObj.getPerformanceContentUseful(fromDate,toDate,contentType,siteId);
        	}else{
        		listofPerformanceContentWrapper = analyticsDaoObj.getPerformanceContentUsefulAll(fromDate,toDate,siteId);
        	}
    	      	
	        listofPerformanceContentWrapper = (List<AnalyticsWrapper.PerformanceContentData>)listToReturn(listofPerformanceContentWrapper,List<AnalyticsWrapper.PerformanceContentData>.class);
	        if(listofPerformanceContentWrapper != null) {
	        	performanceContentDataObj.data = listofPerformanceContentWrapper;
        	}else{
        		performanceContentDataObj.data = new List<AnalyticsWrapper.PerformanceContentData>();
        	}
	        if(toDate!=null && fromDate!=null){
	        	if(contentType != null){
	        		performanceContentDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_CONTENT_USEFUL+'&to='+toDate+'&from='+fromDate+'&contentType='+contentType+'&siteId='+siteId;
	        	}else{
	        		performanceContentDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_CONTENT_USEFUL+'&to='+toDate+'&from='+fromDate+'&siteId='+siteId;
	        	}
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performanceContentDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult; 
	}
	
	private ResponseWrapper getPerformanceContentViews(String requestData){ 
		List<AnalyticsWrapper.PerformanceContentData> listofPerformanceContentWrapper;
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformanceContent performanceContentDataObj = new AnalyticsWrapper.PerformanceContent();
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        String contentType = String.valueOf(requestDataMap.get('contentType'));
	        siteId = requestDataMap.get('siteId')!=null ? String.valueof(requestDataMap.get('siteId')) : '';
        
        	if(contentType != null){
        		listofPerformanceContentWrapper = analyticsDaoObj.getPerformanceContentViews(fromDate,toDate,contentType,siteId);
        	}else{
        		listofPerformanceContentWrapper = analyticsDaoObj.getPerformanceContentViewsAll(fromDate,todate,siteId);
        	}
    	      	
	        listofPerformanceContentWrapper = (List<AnalyticsWrapper.PerformanceContentData>)listToReturn(listofPerformanceContentWrapper,List<AnalyticsWrapper.PerformanceContentData>.class);
	        if(listofPerformanceContentWrapper != null) {
	        	performanceContentDataObj.data = listofPerformanceContentWrapper;
        	}else{
        		performanceContentDataObj.data = new List<AnalyticsWrapper.PerformanceContentData>();
        	}
	        if(toDate!=null && fromDate!=null){
	        	if(contentType != null){
	        		performanceContentDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_CONTENT_VIEWS+'&to='+toDate+'&from='+fromDate+'&contentType='+contentType+'&siteId='+siteId ;
	        	}else{
	        		performanceContentDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_CONTENT_VIEWS+'&to='+toDate+'&from='+fromDate+'&siteId='+siteId;
	        	}
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performanceContentDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult; 
	}
	
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	private ResponseWrapper getPerformanceTopicsEndorsements(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformanceTopics performanceTopicsDataObj = new AnalyticsWrapper.PerformanceTopics();
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
        
        	List<AnalyticsWrapper.PerformanceTopicsData> listofPerformanceTopicsWrapper = analyticsDaoObj.getPerformanceTopicsEndorsements(fromDate,toDate);      	
	      
	        listofPerformanceTopicsWrapper = (List<AnalyticsWrapper.PerformanceTopicsData>)listToReturn(listofPerformanceTopicsWrapper,List<AnalyticsWrapper.PerformanceTopicsData>.class);
	        if(listofPerformanceTopicsWrapper != null) {
	        	performanceTopicsDataObj.data = listofPerformanceTopicsWrapper;
        	}else{
        		performanceTopicsDataObj.data = new List<AnalyticsWrapper.PerformanceTopicsData>();
        	}
	         if(toDate!=null && fromDate!=null){
	        	performanceTopicsDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_TOPIC_ENDORSEMENTS+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performanceTopicsDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult;
	}
	
	private ResponseWrapper getPerformanceTopicsExpertise(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformanceTopics performanceTopicsDataObj = new AnalyticsWrapper.PerformanceTopics();
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        
        	List<AnalyticsWrapper.PerformanceTopicsData> listofPerformanceTopicsWrapper = analyticsDaoObj.getPerformanceTopicsExpertise(fromDate,toDate);      	
	      
	        listofPerformanceTopicsWrapper = (List<AnalyticsWrapper.PerformanceTopicsData>)listToReturn(listofPerformanceTopicsWrapper,List<AnalyticsWrapper.PerformanceTopicsData>.class);
	        if(listofPerformanceTopicsWrapper != null) {
	        	performanceTopicsDataObj.data = listofPerformanceTopicsWrapper;
        	}else{
        		performanceTopicsDataObj.data = new List<AnalyticsWrapper.PerformanceTopicsData>();
        	}
        	if(toDate!=null && fromDate!=null){
	        	performanceTopicsDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_TOPIC_EXPERTISE+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performanceTopicsDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult;
	}
	
	private ResponseWrapper getPerformanceTopicsViews(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformanceTopics performanceTopicsDataObj = new AnalyticsWrapper.PerformanceTopics();
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
	        
        	List<AnalyticsWrapper.PerformanceTopicsData> listofPerformanceTopicsWrapper = analyticsDaoObj.getPerformanceTopicsViews(fromDate,toDate);      	
	      
	        listofPerformanceTopicsWrapper = (List<AnalyticsWrapper.PerformanceTopicsData>)listToReturn(listofPerformanceTopicsWrapper,List<AnalyticsWrapper.PerformanceTopicsData>.class);
	        if(listofPerformanceTopicsWrapper != null) {
	        	performanceTopicsDataObj.data = listofPerformanceTopicsWrapper;
        	}else{
        		performanceTopicsDataObj.data = new List<AnalyticsWrapper.PerformanceTopicsData>();
        	}
	        if(toDate!=null && fromDate!=null){
	        	performanceTopicsDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_TOPIC_VIEWS+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performanceTopicsDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult;
	}
	
	private ResponseWrapper getPerformanceTopicsFollowers(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformanceTopics performanceTopicsDataObj = new AnalyticsWrapper.PerformanceTopics();
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
    	
        	List<AnalyticsWrapper.PerformanceTopicsData> listofPerformanceTopicsWrapper = analyticsDaoObj.getPerformanceTopicsFollowers(fromDate,toDate);      	
	      
	        if(listofPerformanceTopicsWrapper != null) {
	        	performanceTopicsDataObj.data = listofPerformanceTopicsWrapper;
        	}else{
        		performanceTopicsDataObj.data = new List<AnalyticsWrapper.PerformanceTopicsData>();
        	}
        	
        	if(toDate!=null && fromDate!=null){
	        	performanceTopicsDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_TOPIC_FOLLOWERS+'&to='+toDate+'&from='+fromDate ;
	        }
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performanceTopicsDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, ' exception occurred while fetching Analytics Performance Topics Followers.', null);
        }
        return localResult;
	}
	
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	private ResponseWrapper getPerformanceSearch(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformanceSearch performanceSearchDataObj = new AnalyticsWrapper.PerformanceSearch();
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
			String filterBy = String.valueOf(requestDataMap.get('filterBy'));
			String filterValue = String.valueOf(requestDataMap.get('filterValue'));
	        
        	List<AnalyticsWrapper.PerformanceSearchData> listofPerformanceSearchWrapper = analyticsDaoObj.getPerformanceSearch(fromDate,toDate);      	
	        
	        listofPerformanceSearchWrapper = (List<AnalyticsWrapper.PerformanceSearchData>)listToReturn(listofPerformanceSearchWrapper,List<AnalyticsWrapper.PerformanceSearchData>.class);
	        if(listofPerformanceSearchWrapper != null) {
	        	performanceSearchDataObj.data = listofPerformanceSearchWrapper;
        	}else{
        		performanceSearchDataObj.data = new List<AnalyticsWrapper.PerformanceSearchData>();
        	}
	        if(toDate!=null && fromDate!=null){
	        	performanceSearchDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_SEARCH+'&to='+toDate+'&from='+fromDate ;
	        }
			if(String.isNotBlank(filterBy)){
        		performanceSearchDataObj.csvUrl += '&filterBy='+filterBy;
        	}
        	if(String.isNotBlank(filterValue)){
        		performanceSearchDataObj.csvUrl += '&filterValue='+ EncodingUtil.urlEncode(filterValue, 'UTF-8');
        	}
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performanceSearchDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult;
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	private ResponseWrapper getPerformanceZeroSearchResults(String requestData){ 
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.PerformanceSearch performanceSearchDataObj = new AnalyticsWrapper.PerformanceSearch();
        	toDate = String.valueOf(requestDataMap.get('to'));
	        fromDate = String.valueOf(requestDataMap.get('from'));
			String filterBy = String.valueOf(requestDataMap.get('filterBy'));
			String filterValue = String.valueOf(requestDataMap.get('filterValue'));
	        
        	List<AnalyticsWrapper.PerformanceSearchData> listofPerformanceSearchWrapper = analyticsDaoObj.getPerformanceZeroSearchResults(fromDate,toDate);      	
	       
	        listofPerformanceSearchWrapper = (List<AnalyticsWrapper.PerformanceSearchData>)listToReturn(listofPerformanceSearchWrapper,List<AnalyticsWrapper.PerformanceSearchData>.class);
	        if(listofPerformanceSearchWrapper != null) {
	        	performanceSearchDataObj.data = listofPerformanceSearchWrapper;
        	}else{
        		performanceSearchDataObj.data = new List<AnalyticsWrapper.PerformanceSearchData>();
        	}
	        if(toDate!=null && fromDate!=null){
	        	performanceSearchDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_ZERO_SEARCH_RESULTS+'&to='+toDate+'&from='+fromDate ;
	        }
			if(String.isNotBlank(filterBy)){
        		performanceSearchDataObj.csvUrl += '&filterBy='+filterBy;
        	}
        	if(String.isNotBlank(filterValue)){
        		performanceSearchDataObj.csvUrl += '&filterValue='+ EncodingUtil.urlEncode(filterValue, 'UTF-8');
        	}
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, performanceSearchDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult;
	}
	
	private  List<Object> listToReturn(List<Object> objlst, System.Type clazz){
		if(objlst.size()<=10){
			return objlst;
		}else{
			Integer counter = 0;
			List<Object> objlist = (List<Object>)clazz.newInstance();
			while(counter<10 && counter<objlst.size()) {
	    		objlist.add(objlst[counter++]);
	    	}
	    	return objlist;
		}
		
	}
	
}