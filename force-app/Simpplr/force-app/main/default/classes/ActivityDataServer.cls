public with sharing class ActivityDataServer extends DataServer{
	
	private final String REQUEST_PARAM_DATA = 'data';
	private final string ACTION_GET_ACTIVITY = 'getActivity';
    private List<String> allowedFeaturesInAppList;
	private String loggedInPeopleId = UserContext.peopleId;
	private DateTime currentDateTime = DateTime.now();
	
	public ActivityDataServer() {
        
    }
    
    public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
    public override void handleRequest() {
        try{
        	logger.logDebug('ActivityDataServer----entered handleRequest----');
			String action = readParam(REQUEST_PARAM_ACTION);
            	
            if(String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
            } else {
            	if(ACTION_GET_ACTIVITY.equalsIgnoreCase(action)){
            		response = getActivity(readParam(REQUEST_PARAM_DATA));
            	}else{
                	throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            	}
            }
            
        }catch(Exception ex) {
        	logger.logError('Either no page access or action parameter returning wrong data',ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR,MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        
    }
    
    
    /**
	 * @api {post} /apex/DataServerRW?target=ActivityDataServer&action=getActivity ActivityDataServer Get activity listing for home and site dashbaord
	 * @apiUse ContentCacheWrapper
	 * @apiGroup ActivityDataServer
	 * @apiName Activity
	 * @apiHeader (MyHeaderGroup) {String} authorization Authorization value.
	 *
	 * @apiParam (Post Parameter) {String} data {"filter":"popular/latest","siteId":"null for home dashboard and siteId for site dashboard","term":"optional"}
	 *
	 * @apiDescription Get activity listing for home and site dashbaord
	 * @apiSuccess {Number} nextPageTokenLatest It defines the offset of successive results
	 * @apiSuccess {Number} nextPageTokenPopular It defines the offset of successive results
	 * @apiSuccess {List[ContentCacheWrapper]} latest list of latest activity
	 * @apiSuccess {List[ContentCacheWrapper]} popular list of popular activity
	 *
	 * @apiError Error {error} status
	 */
    @testVisible 
    private ResponseWrapper getActivity(String requestData){
    	logger.logDebug('ActivityDataServer.getActivity()----requestData----'+requestData);
    	if(String.isBlank(requestData)) {
    		throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
    	}
        ResponseWrapper responseWrapperObj = new ResponseWrapper();
        try{
        	
        	Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(requestData, Type.forName('Map<String,String>'));
        	String siteId = String.isNotBlank(requestDataMap.get('siteId'))?requestDataMap.get('siteId'):'';
        	String chatterGroupId = readParam('chatterGroupId');
        	SiteDetailWrapper sdWrapperObj;
        	if(String.isNotBlank(chatterGroupId) ){
    			Id  chatterGrpId  = chatterGroupId;
    			List<Simpplr_Site__c> siteList = [Select Id from Simpplr_Site__c Where Chatter_Group_Id__c =:chatterGrpId WITH SECURITY_ENFORCED];
    			if(siteList.isEmpty() == false){
    				siteId = siteList[0].Id;
    				SiteContext.siteId = siteId;
    			}
	    	}
        	if(String.isNotBlank(siteId)){
                SiteContext.siteId = siteId;
	        	if(!SiteContext.isActive){
	        		throw new SimpplrException(ServiceConstants.ERROR_404);
		    	}
		    	if(!AccessManager.hasSiteAccess()){
		    		sdWrapperObj = new MobileSiteDataProvider().getSiteMembership(siteId);
		    		
		    		if(SiteContext.isUnlistedSite){
		    			return buildResponseWrapper(RESPONSE_STATUS_ERROR, ServiceConstants.ERROR_404, sdWrapperObj);
		    		}else {
		    			return buildResponseWrapper(RESPONSE_STATUS_ERROR, ServiceConstants.ERROR_403, sdWrapperObj);
		    		}
		    	}
	        	sdWrapperObj = new MobileSiteDataProvider().getsiteDetailData(siteId);
        	}
        	String filter = requestDataMap.get('filter');
        	String term = requestDataMap.get('term');
		Integer recordLimit = String.isNotBlank(requestDataMap.get('size'))?Integer.valueOf(requestDataMap.get('size')) : SimpplrContext.simpplrDefaultPageSize;
        	recordLimit = recordLimit + 1;
        	Integer offset = String.isNotBlank(requestDataMap.get('nextPageToken'))?Integer.valueOf(requestDataMap.get('nextPageToken')) : 0;
		Boolean isFullModel = readParam('isFullModel') == 'true'? true : false;

		List<Object> popularActivityWrapperList = new List<Object>();
	    	List<Object> latestActivityWrapperList = new List<Object>();
        	List<Simpplr_Content__c> latestContentList = new List<Simpplr_Content__c>();
        	
        	if(String.isBlank(requestDataMap.get('nextPageToken')) || 'latest'.equalsIgnoreCase(filter)){
				Criteria.ContentSearchFilter criteriaObj = new Criteria.ContentSearchFilter();
				criteriaObj.offset = offset;
				criteriaObj.recordLimit = recordLimit;
				criteriaObj.siteId = siteId;
				criteriaObj.contentType = 'All';
				criteriaObj.excludeType = null;
				criteriaObj.searchText = term;
				criteriaObj.sortBy = 'latest';
				criteriaObj.publishStartDateTime = null;
				criteriaObj.author = null;
				criteriaObj.maxAllowedEventEndDateTime = null;
				criteriaObj.isAllContent = false;
				criteriaObj.futureEventsOnly = false;
				
	        	latestContentList = (new AllContentDataServer()).getLatestContentList(criteriaObj);
        	}
        	 	
	    	if(String.isBlank(requestDataMap.get('nextPageToken')) || 'all'.equalsIgnoreCase(filter)){
	    		if(String.isBlank(siteId)){
	    			popularActivityWrapperList = getPopularActivityList(offset, recordLimit, term, isFullModel);
	    		}
	    		latestActivityWrapperList = getLatestActivityList(latestContentList, isFullModel);
	    	} else if(String.isBlank(siteId) && 'popular'.equalsIgnoreCase(filter)){
	    		popularActivityWrapperList = getPopularActivityList(offset, recordLimit, term, isFullModel);
	    	} else if('latest'.equalsIgnoreCase(filter)){
		    	latestActivityWrapperList = getLatestActivityList(latestContentList, isFullModel);
	    	}
	    	
	    	Integer nextPageTokenLatest;
			Integer nextPageTokenPopular;
			if(latestActivityWrapperList.size() == recordLimit){
				latestActivityWrapperList.remove(recordLimit - 1);
				nextPageTokenLatest = offset + (recordLimit -1);
			} else {
				nextPageTokenLatest = null;
			}

			if(popularActivityWrapperList.size() == recordLimit){
				popularActivityWrapperList.remove(recordLimit - 1);
				nextPageTokenPopular = offset + (recordLimit -1);
			} else {
				nextPageTokenPopular = null;
			}
        	Map<String,Object> resultMap = new map<String,Object>();
        	resultMap.put('latest',latestActivityWrapperList);
        	resultMap.put('popular',popularActivityWrapperList);
        	resultMap.put('siteDetail',sdWrapperObj);
        	resultMap.put('nextPageTokenLatest',nextPageTokenLatest);
        	resultMap.put('nextPageTokenPopular',nextPageTokenPopular);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null , resultMap);
            
            requestDataMap.put('userAgent', readHeader('User-Agent'));
            Utility.insertMobileAnalyticsRecord( requestDataMap.get('filter')+'Activity',requestDataMap);
            
        } catch(Exception e){
        	logger.logError('Could not retrieve activity list',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR,MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        logger.logDebug('ActivityDataServer.getActivity()----responseWrapperObj----');
        return responseWrapperObj;
    }   
    
    @testVisible
    private List<Object> getPopularActivityList(Integer offset, Integer recordLimit, String term, Boolean isFullModel){
    	logger.logDebug('ActivityDataServer.getPopularActivityList()------');
    	List<Object> popularActivityWrapperList = new List<Object>(); 
    
    	List<String>popularContentIdList = getPopularContentIdList(offset, recordLimit, term);
    	Map<Id,Simpplr_Content__c> contentMap = getFinalPopularContentList(popularContentIdList);    		
		MobileContentDataProvider mblContentProviderObj = new MobileContentDataProvider();
		for(String contentId : popularContentIdList){
			popularActivityWrapperList.add(mblContentProviderObj.convertContentToWrapperForMobileCaching(contentMap.get(contentId)));
		}
    	
    	logger.logDebug('ActivityDataServer.getPopularActivityList()----'+popularActivityWrapperList);
    	return popularActivityWrapperList;
    }
     
    @testVisible
    private List<Object> getLatestActivityList(List<Simpplr_Content__c> latestContentList, Boolean isFullModel){
    	logger.logdebug('ActivityDataServer.getLatestActivityList()------');
    	List<Object> latestActivityWrapperList = (new MobileContentDataProvider()).generateListOfContentCacheWrap(latestContentList);

    	return latestActivityWrapperList;
    }
    
     public List<String> getContentFieldList() {
    	return New List<String>{
    		'Id',
            'Type__c',
            'Activated_By_Feature__c',
            'site__c',
            'Primary_Author__c',
            'Title__c',
            'Text_Intro__c',
            'Text_Main__c', 
            'Text_Main_Continued__c',
            'Display_Excerpt__c',
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
			'Pages_Category__r.Name__c',
			'Primary_Author__r.user__r.Id',
			'Primary_Author__r.First_Name__c', 
			'Primary_Author__r.Community_Nickname__c',
            'Primary_Author__r.Last_Name__c',
            'Primary_Author__r.Full_Name__c',
            'Primary_Author__r.user__r.SmallPhotoURL',
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
            'Site__r.Title_Content_Version__c',
            'Site__r.Title_Content_Document__c',
            'Site__r.Show_In_Simpplr__c',
			'Site__r.Is_Featured__c',
			'(select Must_Read_Confirm_Count__c from Must_Read_Audits__r order by createddate desc limit 1)',
            '(Select Id,Confirm_DateTime__c  from Must_Read_Confirm_History__r Where People__c =:loggedInPeopleId and Must_Read_Audit__r.Removed_DateTime__c=null AND (Must_Read_Audit__r.Expiry_DateTime__c = null OR Must_Read_Audit__r.Expiry_DateTime__c >: currentDateTime) )',
            '(select id from Content_Interactions__r where People__c =: loggedInPeopleId )',
			'(select id from Bookmarked_Content__r where People__c =:loggedInPeopleId and Is_Deleted__c=false)',
            '(SELECT Id,Content_Version__c, Content_Document__c, Title_Image_Type__c,Is_Title_Image__c,Thumbnail_URL__c, MIME_Type__c FROM File_Simpplr_Content__r WHERE Is_Deleted__c = false and Is_Title_Image__c = true)' 

        };
    }
    
    @testVisible
    private Map<Id, Simpplr_Content__c> getFinalPopularContentList(List<String> contentIdSet){
    	logger.logDebug('ActivityDataServer.getFinalPopularContentList()------');
    		String query = 'SELECT ' +String.join(getContentFieldList(),',')+' FROM Simpplr_Content__c WHERE Id IN:contentIdSet WITH SECURITY_ENFORCED';
    		
    		return new Map<Id, Simpplr_Content__c>((List<Simpplr_Content__c>) Database.query(query));
    }
    
    @testVisible
    private List<String> getPopularContentIdList(Integer offset, Integer recordLimit, String term) {
    	String siteID = '';
    	Set<Id> topicsIFollowIdSet = new Set<Id>();
		Set<Id> usersIFollowIdSet = new Set<Id>();
		Set<Id> sitesIFollowIdSet = new Set<Id>();
		Set<Id> contentIdsForFollowingTopics = new Set<Id>();
		allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).replace('Blog', 'BlogPost').split(',');
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', allowedFeaturesInAppList);
		String blogSubCondition = '';
		if(SimpplrContext.AllowedFeatures.containsIgnoreCase(AccessManager.FEATURE_BLOG)) {
			blogSubCondition = ' or Content__r.type__c = \'BlogPost\' ';
		}
		String query = 	' select content__c contentId, Sum(Popularity_Score__c) popularityScore from Analytics_Top_Content__c ' +
        					' where createddate = LAST_N_DAYS: 14 ' +
        					' And content__c != null ' +
        					' And content__r.TYPE__c IN : soqlParam1 ' +
        					' And content__r.Is_Deleted__c = false ' +
        					' And ((Content__r.Site__r.Is_Active__c = true And Content__r.Site__r.Show_In_Simpplr__c = true) ' + blogSubCondition + ' ) ' +
        					' And Content__r.Is_Published__c = true ' +
    						' And Content__r.Activated_By_Feature__c = true ';
		
		if(String.isNotBlank(siteID) && !siteID.containsIgnoreCase('home')) {
			soqlParamMap.put('soqlParam2', siteID);
    		query += ' And Content__r.Site__c =: soqlParam2 ';
        		
        } else {
        	contentIdsForFollowingTopics = getContentIdSetForFollowedTopics();
        	topicsIFollowIdSet = UserContext.topicsIFollowIdSet;
	        usersIFollowIdSet =	UserContext.usersIFollowIdSet;
        	sitesIFollowIdSet = UserContext.sitesIFollowIdSet;
			soqlParamMap.put('soqlParam3', usersIFollowIdSet);
			soqlParamMap.put('soqlParam4', loggedInPeopleId);
			soqlParamMap.put('soqlParam5', sitesIFollowIdSet);
			soqlParamMap.put('soqlParam6', contentIdsForFollowingTopics);
            query += 	' AND ( ';
            query += 	' (Content__r.TYPE__c=\'BlogPost\' And (Content__r.Primary_Author__r.User__c IN :soqlParam3 OR Content__r.Primary_Author__c =:soqlParam4 or Content__r.Primary_Author__r.Is_Influencer__c = true)) ';
            query += 	' Or ';
            query += 	' (Content__r.Site__c != null And Content__r.site__r.is_Active__c=true And Content__r.Site__r.Show_In_Simpplr__c = true And (Content__r.site__c IN:soqlParam5 or Content__r.Primary_Author__c =:soqlParam4)) ';
            query += 	' Or ';
            query += 	' content__c IN :soqlParam6';
            query += 	' ) ';
        }
    		
   	 	query 	+=		' group by content__c ' + 
        					' order by sum(Popularity_Score__c) desc ' +
        					' LIMIT :soqlParam7 OFFSET :soqlParam8 ';
		soqlParamMap.put('soqlParam7', recordLimit);
		soqlParamMap.put('soqlParam8', offset);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<AggregateResult> aggrList  = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		
        List<String> popularContentIdList = new List<String>();
        
	    for(AggregateResult ar: aggrList) {
            popularContentIdList.add((Id)ar.get('contentId'));
        }
        
        return popularContentIdList;
    }
    
    @testVisible
    private Set<Id> getContentIdSetForFollowedTopics() {
	 	Set<Id> contentIdsForFollowingTopics = new Set<Id>();
	 	Set<Id> topicIdSet = UserContext.topicsIFollowIdSet;
	 	allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).replace('Blog', 'BlogPost').split(',');
	 	String query = 	' SELECT Id, Title__c FROM Simpplr_Content__c ' +
	 					' WHERE Status__c =\'Approved\' ' + 
						' AND Is_Published__c = true ' +
						' AND Is_Deleted__c = false ' +
						' And ((Site__c = null) OR (Site__r.Is_Active__c = true AND Site__r.Show_In_Simpplr__c = true)) ' +
						' AND Type__c IN :allowedFeaturesInAppList ' +
	 					' AND Id in (SELECT EntityId from TopicAssignment ' +
	 					' where TopicId in : topicIdSet AND entitytype=\'Simpplr_Content\') WITH SECURITY_ENFORCED ';
	 				
	 	List<Simpplr_Content__c> contentObjList = Database.query(query);
	 	
	 	for(Simpplr_Content__c contentObj : contentObjList) {
	 		contentIdsForFollowingTopics.add(contentObj.Id);
	 	}
	 	
	 	return contentIdsForFollowingTopics;
	 }                
    
}