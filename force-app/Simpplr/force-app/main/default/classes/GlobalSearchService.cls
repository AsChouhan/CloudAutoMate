public with sharing class GlobalSearchService {

	
	private App_Config__c appConfig = SimpplrContext.appConfig;
	private static DateTime currentTime = DateTime.now();
	public String searchTerm;
	public static Boolean isMyDriveFolderLinked;
	private Id loggedInPeopleId{get{
    	return UserContext.getCurrentUserInfo.Id;
    }}
	public static Integer totalPageResults;
	public static Integer totalAlbumResults;
	public static Integer totalEventResults;
	public static Integer totalBlogResults;
	public static Integer totalResults;
	public static Object totalMSResults;
	public static String nextPageToken;
	public static String  shareddriveName;
	public static Set<String> contentWrkSpaceIdSet;
	public static Map<String,Set<String>> contentDocumentToSiteMap;
	
	public List<String> allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).replace('Blog', 'BlogPost').split(',');
	
	private List<String> listOfFileExtensionToIgnore{get{
		return new List<String>{'jpg','gif','png','jpeg'};
	}}
	
	Boolean applyUserContext;
	List<String> setOfTerms;
	/*##################################################################################################################################################*/
	/*##################################################################################################################################################*/

	public FeedElementPageWrapper searchFeed(Criteria.Feed feedCriteriaObj){
		logger.logDebug('GlobalSearchService.searchFeed()----feedCriteriaObj---' + feedCriteriaObj);
		Integer size = SimpplrContext.simpplrDefaultPageSize;
		ConnectApi.FeedElementPage feedElementPageObj = FeedConnectAPIService.searchFeeds(null, 'news',
				'me', feedCriteriaObj.nextPageToken, size, feedCriteriaObj.term, 'activity');
								
		FeedElementPageWrapper feedElementPageWrapObj = new FeedElementPageWrapper();
    	feedElementPageWrapObj = FeedDataAdapter.convertFeedElementPageToWrapper(feedElementPageObj);
    	logger.logDebug('GlobalSearchService.searchFeed()----return----feedElementPageWrapObj----' + feedElementPageWrapObj);
		return feedElementPageWrapObj;
	}
	
	/*##################################################################################################################################################*/
	/*##################################################################################################################################################*/
	
    public List<Object> searchSites(Criteria.Site siteCriteriaObj){
    	logger.logDebug('GlobalSearchService.searchSites()----siteCriteriaObj----' + siteCriteriaObj);
    	String SIMPPLR_APP_HOME_CHATTER_GROUP_ID = 'S06I000000MPPLR';
    	String userSegmentId = UserContext.segmentId;
    	searchTerm = siteCriteriaObj.term;
    	Set<String> searchTokens= Utility.getSearchTokens(String.escapeSingleQuotes(siteCriteriaObj.term));
    	
    	String collabQuery= 'SELECT ID from CollaborationGroup WHERE (';
    	for(String searchToken: searchTokens){
    		String searchVal='\'%'+searchToken+'%\'';
    		collabQuery=collabQuery+' Name like '+searchVal+' OR Description LIKE '+searchVal +' OR';
    	}
    	collabQuery = collabQuery.removeEnd('OR');
    	collabQuery=collabQuery+' )';
    	
    	if(SimpplrContext.isCommunitiesEnabled){
    		collabQuery = collabQuery+' AND (NetworkId = null)';
    	}
    	 	logger.logDebug('GlobalSearchService.searchSites()----collabQuery----' + collabQuery);
    	
    		Map<Id, CollaborationGroup> mapOfCollobarationGrp = new Map<Id,CollaborationGroup>((List<CollaborationGroup>)Database.query(collabQuery));
		Set<Id> collabGroupIds= new Set<Id>(mapOfCollobarationGrp.keySet());

		String currentUserId=UserContext.id;
		
		String BASE_QUERY = 'SELECT Name,Title_Content_Version__c,Site_Type__c, Id,Is_Active__c, Landing_Page__c, Site_Category__r.Name__c,Chatter_Group_Id__c, '
		+ 'Is_Featured__c, Is_Deleted__c, Show_In_Simpplr__c, Has_Pages__c, Has_Albums__c, Has_Events__c, Title_Content_Document__c,' +
		'Slack_Channel_Id__c, Slack_Channel_Name__c, Slack_Url__c,Member_Count__c,Follower_Count__c,' +
		'(SELECT Id, Is_Featured__c FROM Site_Segments__r WHERE Segment__c =: userSegmentId), ' +
		'(SELECT id FROM Subscription_Entity_Site__r WHERE Subscription__r.Action_Type__c = \'mandatory\' AND Status__c =\'Approved\' AND Subscription__r.Status__c != \'Deleted\' AND '+
		'(Subscription__r.Audience__r.Segment__c =: userSegmentId  OR Subscription__r.Audience__r.Segment__c = null) Limit 1), '+
			' ( SELECT Id, Type__c, CreatedById FROM Bookmarked_Simpplr_Site__r WHERE '+
			' People__r.User__c=:currentUserId AND Type__c=\'site\' And Is_Deleted__c=false ) ';
    		String BASE_FROM_WHERE = 'FROM Simpplr_Site__c WHERE Show_In_Simpplr__c = true AND '+
    								'(Chatter_Group_Id__c IN :collabGroupIds';
    	
    		for(String searchToken: searchTokens) {
        	BASE_FROM_WHERE += ' OR Site_Category__r.Name__c like \'%' + searchToken + '%\'' ;
        }
        
    	BASE_FROM_WHERE = BASE_FROM_WHERE+') and Is_Deleted__c = false and Is_active__c = true';
    	
    	String queryStr=BASE_QUERY+BASE_FROM_WHERE;
    	logger.logDebug('GlobalSearchService.searchSites()----query----' + queryStr);
		Map<Id, Simpplr_Site__c> mapOfSites= new Map<Id, Simpplr_Site__c>((list<Simpplr_Site__c>)Database.query(queryStr));
		
		SiteListingWrapper wrapObj= new SiteListingWrapper();
		List<SiteListingWrapper> listForCalculateScore= new List<SiteListingWrapper>();
		List<GlobalSearchWrapper.ItemWrapper> listToBeReturned = new List<GlobalSearchWrapper.ItemWrapper>();
		List<Id> listOfCollGroupId = new List<Id>();
		
		if (!mapOfSites.isEmpty()) {
			for (Simpplr_Site__c simpplrSiteObj : mapOfSites.values()) {
				listOfCollGroupId.add(simpplrSiteObj.Chatter_Group_Id__c);
			}
			
			SiteDao siteDaoObj = new SiteDao();
			Map<Id, CollaborationGroup> mapOfIdWithCollaborationGrpForLoggedInUser = siteDaoObj.getMapOfIdWithCollaborationGroup(listOfCollGroupId,UserContext.id);
    			SiteListingWrapper siteWrapObj;
    			CollaborationGroup collGrpObjArg;
    			Boolean isSegmentsEnabled = SimpplrContext.isSegmentsEnabled;
    			for (Simpplr_Site__c siteObj :mapOfSites.values()) {
    				if(mapOfIdWithCollaborationGrpForLoggedInUser.containsKey(siteObj.Chatter_Group_Id__c)) {
					siteWrapObj = new SiteListingWrapper();
					collGrpObjArg = mapOfIdWithCollaborationGrpForLoggedInUser.get(siteObj.Chatter_Group_Id__c);
					siteWrapObj.id = siteObj.Id;
					siteWrapObj.title = siteObj.name;
					if (String.isBlank(collGrpObjArg.Description)){
				 		siteWrapObj.description = '';	 		
				 	} else {
				 		siteWrapObj.description = Utility.getAllValidWords(collGrpObjArg.Description, 100, false);
				 	}
				 	if(isSegmentsEnabled) {
				 		siteWrapObj.isFeatured = siteObj.Site_Segments__r.isEmpty() == false;
				 	} else {
				 		siteWrapObj.isFeatured = siteObj.Is_Featured__c;
				 	}
					siteWrapObj.relevancyScore= getSiteScore(siteWrapObj,siteCriteriaObj.term);
					
					siteWrapObj.memberCount = collGrpObjArg.MemberCount;
					listForCalculateScore.add(siteWrapObj);
				}
			}
			//Apply sort logic here and return the listing
			if(!listForCalculateScore.isEmpty()){
	    		listForCalculateScore.sort();
	    		GlobalSearchService.totalResults=listForCalculateScore.size();
				Integer size = siteCriteriaObj.size;
				Integer offset = siteCriteriaObj.offset;
	    		Integer endIndex =   offset+size;
	    		endIndex = (endIndex >= listForCalculateScore.size())? listForCalculateScore.size()-1 :endIndex;
	    		
	    	 	if('mobile'.equalsIgnoreCase(siteCriteriaObj.origin)){
		    		logger.logDebug('GlobalSearchService.searchSite()---Mobile()----');
		    		MobileSiteDataProvider mobileSiteProviderObj = new MobileSiteDataProvider();		    		
					List<SiteCacheWrapper> siteWrapperList = new List<SiteCacheWrapper>();		
					Map<String, ObjectToWrapperAdapter.SiteStats> siteStatsMap = new ObjectToWrapperAdapter().getSiteStats(mapOfSites.values());			
					for(Integer x = offset; x<= endIndex; x++){
						Simpplr_Site__c siteObj = mapOfSites.get(listForCalculateScore.get(x).Id);
						siteWrapperList.add(mobileSiteProviderObj.toSiteCacheWrapper(siteObj, mapOfIdWithCollaborationGrpForLoggedInUser.get(siteObj.Chatter_Group_Id__c), siteStatsMap.get(siteObj.id)));
					}
					return siteWrapperList;
				}
	
		    	for(Integer x = offset; x<= endIndex; x++){
		    		GlobalSearchWrapper.ItemWrapper itemWrapperObj = new GlobalSearchWrapper.ItemWrapper();
		    		Simpplr_Site__c siteObj = mapOfSites.get(listForCalculateScore.get(x).Id);
		    		siteWrapObj = ObjectToWrapperAdapter.generateSiteWrapFromSiteAndCollGrp(siteObj,mapOfIdWithCollaborationGrpForLoggedInUser.get(siteObj.Chatter_Group_Id__c));
		    		siteWrapObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteWrapObj.id + '/' + siteObj.Landing_Page__c;
		    		
		    		itemWrapperObj.relevancyScore = listForCalculateScore.get(x).relevancyScore;
					itemWrapperObj.itemType = 'site';
					itemWrapperObj.item = siteWrapObj;
		    		listToBeReturned.add(itemWrapperObj);
		    	}
	    	}
		}
		
	    	logger.logDebug('GlobalSearchService.searchSites()----listToBeReturned----');
	    	return listToBeReturned;
    }
    
	/*##################################################################################################################################################*/
    /*##################################################################################################################################################*/
	
    public List<Object> searchPeople(Criteria.People peopleCriteriaObj){
		logger.logDebug('GlobalSearchService.searchPeople()----peopleCriteriaObj----' + peopleCriteriaObj);
		String searchTerm = String.isBlank(peopleCriteriaObj.term) ? '' : String.escapeSingleQuotes(peopleCriteriaObj.term);
		String department = String.isBlank(peopleCriteriaObj.department) ? '' : String.escapeSingleQuotes(peopleCriteriaObj.department);
		String location = String.isBlank(peopleCriteriaObj.location) ? '' : String.escapeSingleQuotes(peopleCriteriaObj.location);
		Set<String> searchTokens= Utility.getSearchTokens(searchTerm);
		Set<Id> setOfEndorseeId = new Set<Id>();
		Map<String,Integer> mapOfUserIdAndScore= getUserIdWithScoreForExpertiseInPeopleSearch(searchTokens);
		Map<String, Integer> mapOfUserIdAndUserFieldScore = getUserIdWithUserFieldScore(searchTokens);
		List<Id> listOfUserId = new List<Id>();
           
		if(peopleCriteriaObj.expertise != null) {
			setOfEndorseeId.addAll(PeopleContentProvider.getExperts(peopleCriteriaObj.expertise.id));
		}
		
		String loggedInPeopleId = UserContext.peopleId;
    		List<People__c> listOfPeople = new List<People__c>();
    		String queryStr = 'SELECT Id, About__c, User__c, Title__c, Street__c,Birth_Date__c, Joining_Date__c, '+
    			' State__c, Department__c, Extension__c, Mobile_Phone__c,Phone__c,People_Category__r.Name__c,'+
    			'Email__c,First_Name__c, Last_Name__c, User__r.SmallPhotoURL, Full_Name__c, City__c, Is_Deleted__c,'+
    			' Country__c, User__r.isActive, User__r.Show_Simpplr__c, User__r.UserType, User__r.MediumPhotoUrl, User__r.FullPhotoUrl,'+ 
				'(SELECT People__c, Bookmark_Receiver__c FROM Bookmark_Receiver_People__r'+ 
				' WHERE People__c=:loggedInPeopleId AND Type__c=\'People\' And Is_Deleted__c=false), '+
				' Zoom_Id__c, Skype_Id__c, Cover_Content_Document_Id__c, Segment__c '+
				' FROM People__c ' +
				' WHERE ((User__r.isActive=true And User__r.UserType=\'Standard\' ' + 
				' And User__r.Show_Simpplr__c != \'No\') Or User__r.Show_Simpplr__c = \'Yes\') ';
		
		Set<String> userIdsFromSearch = new Set<String>();
		userIdsFromSearch.addAll(mapOfUserIdAndScore.keySet());
		userIdsFromSearch.addAll(mapOfUserIdAndUserFieldScore.keySet());
		queryStr += getFilterCriteria(peopleCriteriaObj, userIdsFromSearch);

		if ('following'.equalsIgnoreCase(peopleCriteriaObj.filter)) {
			listOfUserId.addAll(UserContext.usersIFollowIdSet);
			queryStr += ' And User__c =:listOfUserId ';
		}
		
		String segmentAttValue = UserContext.segmentAttributeValue;
		if(SimpplrContext.isSegmentsEnabled &&
		 		String.isNotBlank(peopleCriteriaObj.limitToSubsegment) && 
				'true'.equalsIgnoreCase(peopleCriteriaObj.limitToSubsegment)){
			queryStr += ' AND Segment_Attribute_Value__c = :segmentAttValue ';
		}
		
		if(peopleCriteriaObj.expertise != null) {
			queryStr += ' And User__c=:setOfEndorseeId '; 
		}

		if(peopleCriteriaObj.department != null) {
			queryStr += ' And Department__c=:department ';
		}

		if(String.isNotBlank(location) ){
			String cityQueryParam;
	        String stateQueryParam;
	        String countryQueryParam;
			
			cityQueryParam = location.SubString(0,(location.indexOf('@@')-1));
			stateQueryParam = location.SubString((location.indexOf('@@') + 3),(location.lastIndexOf('@@')-1));
			countryQueryParam = location.SubString((location.lastIndexOf('@@') + 3),location.length());
			
			queryStr += (cityQueryParam == 'null' ? '' : ' AND City__c =:cityQueryParam ');
			queryStr += (stateQueryParam == 'null' ? '' : ' AND State__c =:stateQueryParam ');
			queryStr += (countryQueryParam == 'null' ? '' : ' AND Country__c =:countryQueryParam ');
		}
		
		logger.logDebug('GlobalSearchService.searchPeople()----queryStr----' + queryStr);
		
		Map<Id, People__c> peopleMap = new Map<Id, People__c>((List<People__c>)Database.query(queryStr + ' LIMIT 2000'));
		
	    	String scoreDefinitionString = appConfig.Search_People_Allowed_Field__c;
	    	Map<String, Integer> mapOfScoreDefinitions = (Map<String,Integer>) Json.deserialize(scoreDefinitionString, Map<String,Integer>.class);
    	
    		List<PeopleListingWrapper> listForCalculateScore= new List<PeopleListingWrapper>();
    		Boolean isPPTitleDisplay = SimpplrContext.isPPTitleDisplay;
    		Boolean isPPDepartmentDisplay = SimpplrContext.isPPDepartmentDisplay;
    		Boolean isPPCityDisplay = SimpplrContext.isPPCityDisplay;
    		Boolean isPPStateDisplay = SimpplrContext.isPPStateDisplay;
    		Boolean isPPCountryDisplay = SimpplrContext.isPPCountryDisplay;
    		Boolean isPPPhoneDisplay = SimpplrContext.isPPPhoneDisplay;
    		Boolean isPPMobilePhoneDisplay = SimpplrContext.isPPMobilePhoneDisplay;
    		
		for (People__c peopleObj : peopleMap.values()) {
			PeopleListingWrapper peopleListWrapObj = new PeopleListingWrapper();
			peopleListWrapObj.id = peopleObj.Id;
			peopleListWrapObj.sfUserId = peopleObj.User__c;
			peopleListWrapObj.name = Utility.buildName(peopleObj.First_Name__c,peopleObj.Last_Name__c);
			
			if(!isPPTitleDisplay){
				peopleObj.Title__c = null;
			}
			if(!isPPDepartmentDisplay){
				peopleObj.Department__c = null;
			}
			if(!isPPCityDisplay){
				peopleObj.City__c = null;
			}
			if(!isPPStateDisplay){
				peopleObj.State__c = null;
			}
			if(!isPPCountryDisplay){
				peopleObj.Country__c = null;
			}
			if(!isPPPhoneDisplay){
				peopleObj.Phone__c = null;
			}
			if(!isPPMobilePhoneDisplay){
				peopleObj.Mobile_Phone__c = null;
			}
				
			Integer scoreFromTopicSearch = mapOfUserIdAndScore.get(peopleListWrapObj.sfUserId);
			scoreFromTopicSearch = (scoreFromTopicSearch == null) ? 0 : scoreFromTopicSearch; 

			Integer scoreFromUserFieldSearch = mapOfUserIdAndUserFieldScore.get(peopleListWrapObj.sfUserId);
			scoreFromUserFieldSearch = (scoreFromUserFieldSearch == null) ? 0 : scoreFromUserFieldSearch;
			
			Integer scoreFromAdvancePeopleSearch = getScoreOnAdvancePeopleSearch(peopleObj, peopleCriteriaObj);
			peopleListWrapObj.relevancyScore = scoreFromTopicSearch + scoreFromAdvancePeopleSearch + scoreFromUserFieldSearch + getPeopleScore(peopleObj, mapOfScoreDefinitions, searchTokens);
			
			if (scoreFromTopicSearch > 0) {
				peopleListWrapObj.matchedOnExpertise = true;
			} else {
				peopleListWrapObj.matchedOnExpertise = false;
			}
			listForCalculateScore.add(peopleListWrapObj);
		}
		
		listForCalculateScore.sort();

		GlobalSearchService.totalResults=listForCalculateScore.size();
		Integer size = peopleCriteriaObj.size;
		Integer offset = peopleCriteriaObj.offset;
	    	Integer endIndex =   offset+size;
	    	endIndex = (endIndex >= listForCalculateScore.size())? listForCalculateScore.size()-1 :endIndex;
	    	
	    	if('mobile'.equalsIgnoreCase(peopleCriteriaObj.origin)){
	    		logger.logDebug('GlobalSearchService.searchPeople()---Mobile()----');
	    		MobilePeopleDataProvider mobilePeopleProviderObj = new MobilePeopleDataProvider();	    		
				List<PeopleCacheWrapper>peopleWrapperList = new List<PeopleCacheWrapper>();
				for(Integer x = offset; x<= endIndex; x++){
					peopleWrapperList.add(mobilePeopleProviderObj.convertToPeopleCacheWrapper(peopleMap.get(listForCalculateScore.get(x).id)));
				}
				return peopleWrapperList;	    		
		}
		
	    	List<GlobalSearchWrapper.ItemWrapper> listToBeReturned = new List<GlobalSearchWrapper.ItemWrapper>();
	    	for(Integer x = offset; x<= endIndex; x++){
	    		GlobalSearchWrapper.ItemWrapper itemWrapperObj = new GlobalSearchWrapper.ItemWrapper();
	    		PeopleListingWrapper peopleListWrapObj = ObjectToWrapperAdapter.peopleToWrapper(peopleMap.get(listForCalculateScore.get(x).id));
	    		peopleListWrapObj.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleListWrapObj.peopleId;
    			itemWrapperObj.relevancyScore = listForCalculateScore.get(x).relevancyScore;
	    		itemWrapperObj.matchedOnExpertise = listForCalculateScore.get(x).matchedOnExpertise;
    			itemWrapperObj.itemType = 'user';
    			itemWrapperObj.item = peopleListWrapObj;
	    		listToBeReturned.add(itemWrapperObj);
	    	}
		logger.logDebug('GlobalSearchService.searchPeople()----listToBeReturned----');
		return listToBeReturned;
    }
	
	
	/*##################################################################################################################################################*/
    /*##################################################################################################################################################*/
    
    public Map<String,Object> searchContents(Map<String,Object> contnetCriteria){
    	
    	logger.logDebug('GlobalSearchService.searchContents()----contnetCriteria----' + contnetCriteria);
    	
    	List<ContnetListingWrapper> listForCalculateScore = new List<ContnetListingWrapper>();
    	
    	searchTerm = String.valueOf(contnetCriteria.get('term'));
    	String siteId = String.valueOf(contnetCriteria.get('siteId'));
		if(String.isBlank(siteId)) {
			siteId = String.valueOf(contnetCriteria.get('site'));
		}
    	String filter = String.valueOf(contnetCriteria.get('filter'));
    	Integer size = Integer.valueOf(contnetCriteria.get('size'));
    	Integer offset = Integer.valueOf(contnetCriteria.get('nextPageToken')) != null ?Integer.valueOf(contnetCriteria.get('nextPageToken')) : 0;
		String author = String.valueOf(contnetCriteria.get('author'));
		String contentType = String.valueOf(contnetCriteria.get('contentType'));
		DateTime publishStartDateTime = Utility.getDateTimeFilterValue(String.valueOf(contnetCriteria.get('publishStartDate')));
		String topicId;
		if(contnetCriteria.containsKey('topic')) {
			List<Object> topicList = (List<Object>) contnetCriteria.get('topic');
			Map<String,Object> topicWrapper = (Map<String,Object>) topicList[0];
			topicId = String.valueOf(topicWrapper.get('id'));
		}
		
		Set<String> searchTokens= Utility.getSearchTokens(String.escapeSingleQuotes(searchTerm));
		
    	
    	Map<Id,Double>  mapOfContentIdAndScoreBySOSL = getContentIdBySOSLAndScore(searchTokens, siteId, filter, author, contentType, publishStartDateTime);
    	Map<Id,Integer> mapOfContentIdAndScoreByTopicSearch = getContentIdByTopicAndScore(searchTokens, siteId, filter, author, contentType, publishStartDateTime, topicId);
    	Map<Id,Integer> mapOfContentIdAndScoreWRTFileName = getMapOfContentIdAndScoreWRTFileName(searchTerm, siteId, author, contentType, publishStartDateTime, topicId);
    	
    	Map<Id,Integer> mapOfContentIdAndScoreByPagesCategorySearch = new Map<Id,Integer>();
    	if(SimpplrContext.AllowedFeatures.containsIgnoreCase(ServiceConstants.TYPE_PAGE)) {
    		mapOfContentIdAndScoreByPagesCategorySearch = getPageIdByCategoryAndScore(searchTokens, siteId, filter, author, contentType, publishStartDateTime, topicId);
    	}
    	
        Set<Id> setOfMatchedContentIds = new Set<Id>();
        setOfMatchedContentIds.addAll(mapOfContentIdAndScoreBySOSL.keySet()); // for all contnets
        setOfMatchedContentIds.addAll(mapOfContentIdAndScoreByPagesCategorySearch.keySet()); // for pages only
        setOfMatchedContentIds.addAll(mapOfContentIdAndScoreByTopicSearch.keySet());// for all contnets
        setOfMatchedContentIds.addAll(mapOfContentIdAndScoreWRTFileName.keySet()); // for attachments only
        Map<String, Object> mapToBeReturned = new Map<String, Object>();
		
        map<Id,Simpplr_Content__c> allContents = getAllContentsForTextSearch(siteId, setOfMatchedContentIds, searchTokens, author, contentType, publishStartDateTime, topicId);
        List<GlobalSearchWrapper.ItemWrapper> listToBeReturned = new List<GlobalSearchWrapper.ItemWrapper>();
        
		if(!allContents.isEmpty()){
	        String allowedContentSearchFields=appConfig.Search_Content_Allowed_Field__c;
	        Map<String,Integer> mapOfFieldsToSearch = (Map<String,Integer>) Json.deserialize(allowedContentSearchFields, Map<String,Integer>.class);

		    	for(Simpplr_Content__c contentObj: allContents.values()) {
		    		Double scoreFromSOSL = (mapOfContentIdAndScoreBySOSL.get(contentObj.id)==null)?0:mapOfContentIdAndScoreBySOSL.get(contentObj.id);
		    		Integer scoreFromPageCategorySearch = (mapOfContentIdAndScoreByPagesCategorySearch.get(contentObj.id)==null)?0:mapOfContentIdAndScoreByPagesCategorySearch.get(contentObj.id);
		    		Integer scoreFromTopicSearch = (mapOfContentIdAndScoreByTopicSearch.get(contentObj.id)==null)?0:mapOfContentIdAndScoreByTopicSearch.get(contentObj.id);
		    		Integer scoreFromFileSearch=(mapOfContentIdAndScoreWRTFileName.get(contentObj.Id)==null)?0:mapOfContentIdAndScoreWRTFileName.get(contentObj.Id);
		    		
		    		ContnetListingWrapper contentWrapObj = ContentToWrapperAdapter.convertContentToContentLiteListingWrapper(contentObj);
		    		contentWrapObj.relevancyScore = scoreFromSOSL + scoreFromPageCategorySearch + scoreFromTopicSearch + scoreFromFileSearch + getContentScore(contentObj, mapOfFieldsToSearch, searchTokens);
		    		
		    		if (scoreFromTopicSearch > 0 ) {
		    			contentWrapObj.matchedOnTopic = true;
		    		} else {
		    			contentWrapObj.matchedOnTopic = false;
		    		}
		    		if(scoreFromPageCategorySearch>0){
		    			contentWrapObj.matchedOnPageCategory = true;
		    		}else{
		    			contentWrapObj.matchedOnPageCategory = false;
		    		}
		    		listForCalculateScore.add(contentWrapObj);
		    	}
    	  
	    		listForCalculateScore.sort();
		    	Integer endIndex = offset+size;
		    	endIndex = (endIndex >= listForCalculateScore.size())? listForCalculateScore.size()-1 :endIndex;
		    	totalResults = listForCalculateScore.size();
		    	
		    	if('mobile'.equalsIgnoreCase((String)contnetCriteria.get('origin'))){
		    		logger.logDebug('GlobalSearchService.searchContent()---Mobile()----');
		    		MobileContentDataProvider mobileContentProviderObj = new MobileContentDataProvider();
					List<ContentCacheWrapper>contentCacheWrapperList = new List<ContentCacheWrapper>();
					
					for(Integer x = offset; x<= endIndex; x++){
						contentCacheWrapperList.add(mobileContentProviderObj.convertContentToWrapperForMobileCaching(allContents.get(listForCalculateScore.get(x).id)));
					}
					mapToBeReturned.put('contents',contentCacheWrapperList);
					return mapToBeReturned;		    		
				}
		
		    	for(Integer x = offset; x<= endIndex; x++){
		    		GlobalSearchWrapper.ItemWrapper itemWrapperObj = new GlobalSearchWrapper.ItemWrapper();
		    		ContnetListingWrapper wpr = listForCalculateScore.get(x);
		    		ContentWrapper contentWrapObj = convertContentToWrapper(allContents.get(wpr.id));
		   			
		   			
		   			if(ServiceConstants.TYPE_PAGE.equalsIgnoreCase(wpr.contentType)){
		   				contentWrapObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+allContents.get(contentWrapObj.id).Site__c+'/page/'+contentWrapObj.id;
		   			} else if(ServiceConstants.TYPE_EVENT.equalsIgnoreCase(wpr.contentType)){
		    				contentWrapObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+allContents.get(contentWrapObj.id).Site__c+'/event/'+contentWrapObj.id;
		    		} else if(ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(wpr.contentType)){
		    			contentWrapObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+allContents.get(contentWrapObj.id).Site__c+'/album/'+contentWrapObj.id;
		    		} else if(ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(wpr.contentType)) {
		    			contentWrapObj.url = PageContext.getPageURL(Pages.app)+'?u=/people/'+allContents.get(contentWrapObj.id).Primary_Author__c+'/blog/'+contentWrapObj.id;
		    		}
			    		
			    	itemWrapperObj.relevancyScore = Math.floor(listForCalculateScore.get(x).relevancyScore) -1;	
		   			itemWrapperObj.matchedOnTopic = wpr.matchedOnTopic;
		   			itemWrapperObj.matchedOnExpertise = false;
		   			itemWrapperObj.itemType = 'content';
		   			itemWrapperObj.item = contentWrapObj;
		   			listToBeReturned.add(itemWrapperObj);
		    	}
		}
		mapToBeReturned.put('contents',listToBeReturned);
		return mapToBeReturned;
    }
    
    private ContentWrapper convertContentToWrapper(Simpplr_Content__c contentObjArg){
    		ContentWrapper wrapperObj = new ContentWrapper();
		
		wrapperObj.id = contentObjArg.Id;
		if (!contentObjArg.File_Simpplr_Content__r.isEmpty()) {
			wrapperObj.img = Utility.getFileDownloadURLFor240BY180(contentObjArg.File_Simpplr_Content__r[0].Content_Version__c);
		}
	    
        wrapperObj.title = contentObjArg.Title__c;
        wrapperObj.isMustRead = contentObjArg.Is_Must_read__c;
		wrapperObj.excerpt = String.isEmpty(contentObjArg.Display_Excerpt__c)?'':contentObjArg.Display_Excerpt__c.unescapeHtml4();
		
		if(contentObjArg.Must_Read_Confirm_History__r.isEmpty()){
        		wrapperObj.hasRead = false;
        }else{
        		wrapperObj.hasRead = true;
		}
		
		DateTime dateTimeValue = null;
        String dateStringValue = String.valueOf(contentObjArg.Last_Edited_DateTime__c);
        String publishedDateStringValue = String.valueOf(contentObjArg.Publish_Start_DateTime__c);
        if(String.isNotBlank(dateStringValue)){
	        if (String.isNotBlank(publishedDateStringValue) && contentObjArg.Last_Edited_DateTime__c.date() > contentObjArg.Publish_Start_DateTime__c.date()){
		        dateTimeValue = contentObjArg.Last_Edited_DateTime__c;
	    	    wrapperObj.modifiedAt = dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		    	}else {
		    		wrapperObj.modifiedAt = null;
		    	}
        }
	    	dateStringValue = String.valueOf(contentObjArg.Publish_Start_DateTime__c);
        if(String.isNotBlank(dateStringValue)){
	        dateTimeValue = contentObjArg.Publish_Start_DateTime__c;
    	    		wrapperObj.publishAt = dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        }
        
        dateStringValue = String.valueOf(contentObjArg.CreatedDate);
        if(String.isNotBlank(dateStringValue)){
	        dateTimeValue = contentObjArg.CreatedDate;
    	   		wrapperObj.createdAt = dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        }
		
		if('BlogPost'.equalsIgnoreCase(contentObjArg.Type__c)){
        		wrapperObj.type = 'blog_post';
        }else{
        		wrapperObj.type = contentObjArg.Type__c;
        }
        
	    if(!ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(contentObjArg.Type__c)){
		    wrapperObj.site = new SiteLiteWrapper();
	        wrapperObj.site.siteId = contentObjArg.Site__c;
	        wrapperObj.site.name = contentObjArg.Site__r.Name;
	        wrapperObj.site.isListed = !'Unlisted'.equalsIgnoreCase(contentObjArg.Site__r.Site_Type__c);
	        wrapperObj.site.isPrivate = 'Private'.equalsIgnoreCase(contentObjArg.Site__r.Site_Type__c);
	        wrapperObj.site.isPublic = 'Public'.equalsIgnoreCase(contentObjArg.Site__r.Site_Type__c);
	        wrapperObj.site.isActive = contentObjArg.Site__r.is_Active__c;
		    wrapperObj.site.img = String.isBlank(contentObjArg.Site__r.Title_Content_Version__c)? null :Utility.getFileDownloadURLFor720By480(contentObjArg.Site__r.Title_Content_Version__c);
	    	wrapperObj.site.imgThumbnail = String.isBlank(contentObjArg.Site__r.Title_Content_Version__c)? null :Utility.getFileDownloadURLFor120BY90(contentObjArg.Site__r.Title_Content_Version__c);
		    wrapperObj.site.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + contentObjArg.Site__c + '/' + contentObjArg.Site__r.Landing_Page__c;
	    }
	    wrapperObj.authoredBy = new PeopleListWrapper();
        wrapperObj.authoredBy.id = contentObjArg.Primary_Author__c;
        wrapperObj.authoredBy.name = contentObjArg.Primary_Author__r.Full_Name__c;
        if(String.isNotBlank(contentObjArg.Primary_Author__c)) {
        		wrapperObj.authoredBy.img = contentObjArg.Primary_Author__r.User__r.SmallPhotoURL.endsWith('005/T') ? null : contentObjArg.Primary_Author__r.User__r.SmallPhotoURL;
        }
        wrapperObj.authoredBy.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + wrapperObj.authoredBy.id;
	    
       if(contentObjArg.Bookmarked_Content__r.size() > 0) {
        		wrapperObj.isFavorited = true;
        }
           
	    
		if(ServiceConstants.TYPE_PAGE.equalsIgnoreCase(contentObjArg.Type__c)){
	        
	        if(String.isNotBlank(contentObjArg.Pages_Category__c)) {
		        	wrapperObj.category = new CategoryWrapper();
		        	wrapperObj.category.id = contentObjArg.Pages_Category__c;
		        	wrapperObj.category.Name = contentObjArg.Pages_Category__r.Name__c;
		        	wrapperObj.category.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + contentObjArg.Site__c + '/content&pageCategoryId=' + contentObjArg.Pages_Category__c;
	        }
		}
    		
    		if(ServiceConstants.TYPE_EVENT.equalsIgnoreCase(contentObjArg.Type__c)){
    			wrapperObj.favoriteContext = ServiceConstants.TYPE_EVENT;
			
			TimeZone tz = Timezone.getTimeZone(contentObjArg.Event_TimezoneSidKey__c);
			wrapperObj.timezoneName = Utility.timezoneIdToDisplayLabel(contentObjArg.Event_TimezoneSidKey__c);
			wrapperObj.timezoneIso = tz.getID();
			wrapperObj.timezoneOffset = tz.getOffset(system.today());	
			
			dateStringValue = String.valueOf(contentObjArg.Event_Start_DateTime__c);
	        if(String.isNotBlank(dateStringValue)){
		        dateTimeValue = contentObjArg.Event_Start_DateTime__c;
				wrapperObj.startsAt = dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
	        }
	        
	        DateTime endDateTimeValue = contentObjArg.Event_End_DateTime__c;
	        if('12:00 AM'.equalsIgnoreCase(endDateTimeValue.format('h:mm a'))) {
	        	endDateTimeValue = contentObjArg.Event_End_DateTime__c.addMinutes(-1);
	        }
		    wrapperObj.endsAt = endDateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		    
		    wrapperObj.isAllDay = contentObjArg.Event_Is_All_Day__c;
	        if(contentObjArg.Event_Start_DateTime__c.isSameDay(endDateTimeValue)) {
	        		wrapperObj.isMultiDay = false;
	        }
	        else {
	        		wrapperObj.isMultiDay = true;
	        }
	        
        		if(contentObjArg.Event_RSVP_Allowed__c){
	        		wrapperObj.rsvp					= new ContentWrapper.RsvpWrapper();
	            wrapperObj.rsvp.hasMaybeOption 	= contentObjArg.Event_RSVP_Show_Maybe__c;
	            wrapperObj.rsvp.noteLabel 		= contentObjArg.Event_RSVP_Note__c ;
	            wrapperObj.rsvp.capacityCount	= Integer.valueOf(contentObjArg.Event_RSVP_Limit__c);
	            	wrapperObj.rsvp.attendingCount 	= contentObjArg.Event_Attending_Count__c != null && contentObjArg.Event_Attending_Count__c > 0 ? 
	        							  	  		  Integer.valueOf(contentObjArg.Event_Attending_Count__c) : null;
	            wrapperObj.rsvp.dueAtDate		= Utility.dateTimeToMomentJSDateTime(contentObjArg.Event_RSVP_By_DateTime__c);
			    	wrapperObj.rsvp.reportUrl 		= PageContext.getPageURL(Pages.Reports) +'?contentId='+contentObjArg.id + '&action=getRsvpList';
			    	wrapperObj.rsvp.canDownloadReport = AccessManager.hasContentApprovalAccess(wrapperObj.site.siteId, wrapperObj.site.isPublic);
		        
		        if(contentObjArg.Event_RSVP_Responses__r.isEmpty() == false) {
		        		Event_RSVP_Response__c rsvpResponse = contentObjArg.Event_RSVP_Responses__r[0];
		    			wrapperObj.rsvp.noteValue = rsvpResponse.RSVP_Response_Text__c;
		    			wrapperObj.rsvp.respondedWith = rsvpResponse.RSVP_Response__c.toLowerCase();
		    		}
	        }
    		}
    		
    		if(ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(contentObjArg.Type__c)){
    			
			List<File__c> lstFile = contentObjArg.File_Simpplr_Content__r;
			if (lstFile.size() > 0) {
				if (lstFile[0].MIME_Type__c == 'video') {
					wrapperObj.img = lstFile[0].Thumbnail_URL__c;
				} else {
					wrapperObj.img = Utility.getFileDownloadURLFor720By480(lstFile[0].Content_Version__c);
				}
			}
	        
	        if (contentObjArg.Content_r__r != null && !(contentObjArg.Content_r__r.isEmpty())) {
				wrapperObj.isLiked = true;
	        } else {
				wrapperObj.isLiked = false;
	        }
			wrapperObj.imageCount = Integer.valueOf(contentObjArg.Album_Image_Count__c);
	    		wrapperObj.videoCount = Integer.valueOf(contentObjArg.Album_Video_Count__c);
    		}
		    		
    		return wrapperObj;
    }
	
    /*##################################################################################################################################################*/
    /*##################################################################################################################################################*/

    public List<FileListingWrapper> searchFiles(Criteria.File fileCriteriaObj){
    	logger.logDebug('GlobalSearchService.searchFiles()----fileCriteriaObj----' + fileCriteriaObj);
    	List<FileListingWrapper> listForCalculateScore = new List<FileListingWrapper>();
    	Map<Id, ContentVersion> mapOfFiles= new Map<Id, ContentVersion>();
    	Set<Id> listOfCVIds = new Set<Id>();
    	Map<Id, Id> mapOfCDnCVIds = new Map<Id, Id>();
    	searchTerm = fileCriteriaObj.term;
		List<Id> listOfSiteFileIds = new List<Id>();
		List<String> listOfFileTypes;
		String ownerId;
		String siteCheckContentDocument = '';
		String siteCheckContentVersion = '';
		String ownerCheckContentVersion = '';
		String typeCheckContentVersion = '';
		String publishDateCheckContentVersion = '';
		//
		if(String.isNotBlank(fileCriteriaObj.siteId) || String.isNotBlank(fileCriteriaObj.site)) {
			if(String.isNotBlank(fileCriteriaObj.site)) {
				fileCriteriaObj.siteId = fileCriteriaObj.site;
			}
			listOfSiteFileIds = getContentDocumentIdsForSite(fileCriteriaObj.siteId);
			siteCheckContentVersion = ' And ContentDocumentId=:listOfSiteFileIds ';
			siteCheckContentDocument = ' And Id=:listOfSiteFileIds ';
		}

		if(String.isNotBlank(fileCriteriaObj.owner)) {
			ownerId = fileCriteriaObj.owner;
			ownerCheckContentVersion = ' AND Owner.Id =: ownerId';
		}

		if(String.isNotBlank(fileCriteriaObj.fileType)) { 
			listOfFileTypes = SearchConstants.mapOfFileTypeToExtension.get(fileCriteriaObj.fileType);
			typeCheckContentVersion = ' And FileExtension =:listOfFileTypes';
		}

		DateTime publishStartDateTime = Utility.getDateTimeFilterValue(fileCriteriaObj.publishStartDate);
		if(publishStartDateTime != null) {
			publishDateCheckContentVersion = ' And LastModifiedDate >=: publishStartDateTime ';
		}

    	Set<String> searchTokens= Utility.getSearchTokens(String.escapeSingleQuotes(fileCriteriaObj.term));
    	String SOSL_Query = Utility.generateStringForSOSLQuery(searchTokens);
    	SOSL_Query = 'FIND {' + SOSL_Query + '} IN All FIELDS RETURNING ContentVersion'+
    			' (Id, Title, ContentDocumentId, description, OwnerId WHERE  IsLatest = true' + siteCheckContentVersion + ownerCheckContentVersion + typeCheckContentVersion + publishDateCheckContentVersion +
    			' AND IsDeleted = false And (not FileExtension =: listOfFileExtensionToIgnore )' +
    			' AND (not pathOnClient like \'%' + ServiceConstants.REMOVE_FILE_SEARCH_IDENTIFIER + '%\')) ';
    	
		logger.logDebug('GlobalSearchService.searchFiles()----SOSL_Query----' + SOSL_Query);
        List<List<SObject>> searchList = Search.query(SOSL_Query);
		for (List<SObject> lstSRElement : searchList) {
			if(!lstSRElement.isEmpty()) {
				for (SObject srElement : lstSRElement ) {
					mapOfCDnCVIds.put( ((ContentVersion)srElement).ContentDocumentId, ((ContentVersion)srElement).Id );
				}
			}
		}
		
		listOfCVIds = new Set<Id>(mapOfCDnCVIds.values());
		
		//Get Files having Name Or Description match
		String fileNameQuery = 'SELECT id, LatestPublishedVersionId from ContentDocument where '+ 
				' (not FileExtension =: listOfFileExtensionToIgnore ) And (';
		String OR_CLAUSE = '';
		for(String searchToken: searchTokens){
			fileNameQuery += OR_CLAUSE + ' Title LIKE \'%' + searchToken + '%\'  OR Description LIKE \'%' + searchToken + '%\'';
			OR_CLAUSE = ' OR ';
		}
		fileNameQuery += ') ' + siteCheckContentDocument + ownerCheckContentVersion + typeCheckContentVersion + publishDateCheckContentVersion;
		
		if(SimpplrContext.isCommunitiesEnabled){
    		fileNameQuery += ' AND LatestPublishedVersion.networkid = null';
    	}
		
		logger.logDebug('GlobalSearchService.searchFiles()----fileNameQuery----' + fileNameQuery);
		List<ContentDocument> listOfContentDocumentsWithFileNameMatch = Database.query(fileNameQuery);
		for(ContentDocument contentDocumentObj:listOfContentDocumentsWithFileNameMatch) {
			mapOfCDnCVIds.put(contentDocumentObj.Id, contentDocumentObj.LatestPublishedVersionId);
		}
		
		// Filter 1: Remove the files which are not associated with a site
		Map<Id, Set<Id>> groupIdWithCVMap = getGroupIdWithCVMap(mapOfCDnCVIds);
		listOfCVIds = getCVIdsLinkedWithSites(groupIdWithCVMap);
		
		if(!listOfCVIds.isEmpty()){
			String query = 'SELECT Id,ContentDocumentId, Title, Origin, Description,OwnerId,Owner.Name,' +
					' ContentModifiedDate,FileExtension,FileType, ContentSize '+ 
					' from ContentVersion WHERE Id= :listOfCVIds' +
					' AND (not pathOnClient like \'%' + ServiceConstants.REMOVE_FILE_SEARCH_IDENTIFIER + '%\')';
			if(SimpplrContext.isCommunitiesEnabled){
	    		query += ' AND networkid = null';
	    	}
	    	
			//listOfFiles = Database.query(query + ' LIMIT 2000');
			mapOfFiles = new Map<Id, ContentVersion>((List<ContentVersion>)Database.query(query + ' LIMIT 2000'));
		}
		
		// Calculate the score for all the files
		for(ContentVersion fileObj: mapOfFiles.values()) {
			FileListingWrapper flw = new FileListingWrapper();
			flw.name = fileObj.Title;
			flw.contentDocumentId=fileObj.ContentDocumentId;
			flw.contentVersionId=fileObj.Id;
			flw.description=fileObj.Description;
			flw.relevancyScore = getFileScore(fileObj.Title, fileObj.Description, searchTokens);
			
			listForCalculateScore.add(flw);
		}

		// Sort the files based on the score
		listForCalculateScore.sort();
		
    	GlobalSearchService.totalResults=listForCalculateScore.size(); //total size after all filtering
    	Integer size = fileCriteriaObj.size;
		Integer offset = fileCriteriaObj.offset;
    	Integer endIndex =   offset+size;
    	endIndex = (endIndex >= listForCalculateScore.size())? listForCalculateScore.size()-1 :endIndex;
    	
    	Set<Id> listOfIds = new Set<Id>();
    	List<FileListingWrapper> listToBeReturnedTemp = new List<FileListingWrapper>();
    	for(Integer x = offset; x<= endIndex; x++) {
    		FileListingWrapper temp = listForCalculateScore.get(x);
    		listOfIds.add(temp.contentVersionId);
    		listToBeReturnedTemp.add(temp);
    	}
    	
    	Map<Id,List<SiteLiteWrapper>> mapOfsiteDetailsWRTFile = new Map<Id,List<SiteLiteWrapper>>();
    	// Need site details only for the first response, but this got changed with Winter18 Patch.
    	FileDao fileObj = new FileDao();
    	mapOfsiteDetailsWRTFile = fileObj.getCVRelatedSites(listOfIds, 'intranet');
    	
    	List<FileListingWrapper> listToBeReturned = new List<FileListingWrapper>();
    	for(FileListingWrapper fileListingItem :listToBeReturnedTemp) {
			FileListingWrapper newFLW = convertToFileListingWrapper(mapOfFiles.get(fileListingItem.contentVersionId), new Set<String>(), new Map<Id,List<SiteLiteWrapper>>(), null);
    		newFLW.itemType = 'file';
    		newFLW.fileId = fileListingItem.id;
    		if(mapOfsiteDetailsWRTFile.containsKey(newFLW.ContentDocumentId)) {
    			newFLW.listOfSite = mapOfsiteDetailsWRTFile.get(newFLW.ContentDocumentId);
    		}
    		listToBeReturned.add(newFLW);
    	}
    	
		return listToBeReturned;
    }

    /**
     * @description This method is used to fetch contentDocumentId from ContentWorkspaceDoc
     * @param setOfContentWorkspaceId 
     * @return  `List<Id>` Ids of contentDocument
    */
    public List<Id> getContentDocumentIdsInCRMLibraries(Set<String> setOfContentWorkspaceId) {
        List<Id> listOfIds = new List<Id>();
        String loggedInUserId = UserContext.Id;
        List<ContentWorkspaceDoc> listOfContentWorkspaceDoc = [SELECT ContentDocumentId FROM ContentWorkspaceDoc 
                                                                WHERE ContentWorkspaceId  =:setOfContentWorkspaceId WITH SECURITY_ENFORCED];
                                                                	
        for(ContentWorkspaceDoc contentWorkspaceDocObj : listOfContentWorkspaceDoc){
            listOfIds.add(contentWorkspaceDocObj.ContentDocumentId);
        }
        return listOfIds;	
    }

    /**
     * @description This method is used to fetch external folder id when Folder type is CRM
     * @param siteId 
     * @return  `Set<String>` Ids of ContentWorkspaceDoc
    */
    public Set<String> getSetOfSiteCRMLibraries(String siteId) {
        Set<String> setOfContentWorkspaceId = new Set<String>();
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1', siteId);
        String folderQuery = 'select External_Folder_Id__c from Folder__c where is_deleted__c=false And type__c=\'CRM\' And Site__c=:soqlParam1';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<Folder__c> listOfFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
        for(Folder__c folderObj : listOfFolders) {
            setOfContentWorkspaceId.add(folderObj.External_Folder_Id__c);	
        }
        return setOfContentWorkspaceId;
    }
    
    /**
     * @description This method is used to return linked contentDocumentId
     * @param siteId 
     * @return  `List<Id>` Ids of contentDocument
    */
    public List<Id> searchSiteCRMFilesInAllLibraries(String siteId) {
        List<Id> contentDocumnet = new List<Id>();
        contentDocumnet = getContentDocumentIdsInCRMLibraries(getSetOfSiteCRMLibraries(siteId));
        return contentDocumnet;
    }

    public List<FileListingWrapper> searchCrmFiles(Criteria.File fileCriteriaObj){
    	logger.logDebug('GlobalSearchService.searchCrmFiles()----fileCriteriaObj----' + fileCriteriaObj);
    	List<FileListingWrapper> listForCalculateScore = new List<FileListingWrapper>();
    	Map<Id, ContentVersion> mapOfFiles= new Map<Id, ContentVersion>();
    	Set<Id> listOfCVIds = new Set<Id>();
    	Map<Id, Id> mapOfCDnCVIds = new Map<Id, Id>();
    	searchTerm = fileCriteriaObj.term;
		List<Id> listOfSiteFileIds = new List<Id>();
		String siteCheckContentDocument = '';
		String siteCheckContentVersion = '';
		String crmCheck = '';
		//
		if(String.isNotBlank(fileCriteriaObj.siteId)) {
			listOfSiteFileIds = searchSiteCRMFilesInAllLibraries(fileCriteriaObj.siteId);
			siteCheckContentVersion = ' And ContentDocumentId=:listOfSiteFileIds ';
			siteCheckContentDocument = ' And Id=:listOfSiteFileIds ';
		}
		// crm check 
		if ('CRM'.equalsIgnoreCase(fileCriteriaObj.origin)) {
			crmCheck = ' AND Origin=\'C\'';
		}
    	Set<String> searchTokens= Utility.getSearchTokens(String.escapeSingleQuotes(fileCriteriaObj.term));
    	String SOSL_Query = Utility.generateStringForSOSLQuery(searchTokens);
    	SOSL_Query = 'FIND {' + SOSL_Query + '} IN All FIELDS RETURNING ContentVersion'+
    			' (Id, Title, ContentDocumentId, description, OwnerId WHERE  IsLatest = true' + siteCheckContentVersion + crmCheck +
    			' AND IsDeleted = false And (not FileExtension =: listOfFileExtensionToIgnore) ' +
    			' AND (not pathOnClient like \'%' + ServiceConstants.REMOVE_FILE_SEARCH_IDENTIFIER + '%\')) ';
    	
		logger.logDebug('GlobalSearchService.searchCrmFiles()----SOSL_Query----' + SOSL_Query);
        List<List<SObject>> searchList = Search.query(SOSL_Query);
		for (List<SObject> lstSRElement : searchList) {
			if(!lstSRElement.isEmpty()) {
				for (SObject srElement : lstSRElement ) {
					mapOfCDnCVIds.put( ((ContentVersion)srElement).ContentDocumentId, ((ContentVersion)srElement).Id );
				}
			}
		}
		
		//listOfCVIds = new Set<Id>(mapOfCDnCVIds.values());
		//Get Files having Name Or Description match
		String fileNameQuery = 'SELECT id, LatestPublishedVersionId from ContentDocument where '+ 
				' (not FileExtension =: listOfFileExtensionToIgnore) And (';
		String OR_CLAUSE = '';
		for(String searchToken: searchTokens){
			fileNameQuery += OR_CLAUSE + ' Title LIKE \'%' + searchToken + '%\'  OR Description LIKE \'%' + searchToken + '%\'';
			OR_CLAUSE = ' OR ';
		}
		fileNameQuery += ') ' + siteCheckContentDocument;
		
		if(SimpplrContext.isCommunitiesEnabled){
    		fileNameQuery += ' AND LatestPublishedVersion.networkid = null';
    	}
		
		logger.logDebug('GlobalSearchService.searchCrmFiles()----fileNameQuery----' + fileNameQuery);
		List<ContentDocument> listOfContentDocumentsWithFileNameMatch = Database.query(fileNameQuery);
		for(ContentDocument contentDocumentObj:listOfContentDocumentsWithFileNameMatch) {
			mapOfCDnCVIds.put(contentDocumentObj.Id, contentDocumentObj.LatestPublishedVersionId);
		}
		
		listOfCVIds.addAll(getLinkedSiteLibraryCvIdSet(mapOfCDnCVIds));
		
		if(!listOfCVIds.isEmpty()){
			String query = 'SELECT Id,ContentDocumentId, Title, Origin, Description,OwnerId,Owner.Name,' +
					' ContentModifiedDate,FileExtension,FileType, ContentSize '+ 
					' from ContentVersion WHERE Id= :listOfCVIds' + crmCheck ;
			if(SimpplrContext.isCommunitiesEnabled){
	    		query += ' AND networkid = null';
	    	}
	    	
			mapOfFiles = new Map<Id, ContentVersion>((List<ContentVersion>)Database.query(query + ' LIMIT 2000'));
		}
		
		// Calculate the score for all the files
		for(ContentVersion fileObj: mapOfFiles.values()) {
			FileListingWrapper flw = new FileListingWrapper();
			flw.name = fileObj.Title;
			flw.contentDocumentId=fileObj.ContentDocumentId;
			flw.contentVersionId=fileObj.Id;
			flw.description=fileObj.Description;
			flw.relevancyScore = getFileScore(fileObj.Title, fileObj.Description, searchTokens);
			
			listForCalculateScore.add(flw);
		}
		
		// Sort the files based on the score
		listForCalculateScore.sort();
		
    	GlobalSearchService.totalResults=listForCalculateScore.size(); //total size after all filtering
    	Integer size = fileCriteriaObj.size;
		Integer offset = fileCriteriaObj.offset;
    	Integer endIndex =   offset+size;
    	endIndex = (endIndex >= listForCalculateScore.size())? listForCalculateScore.size()-1 :endIndex;
    	
    	Set<Id> listOfIds = new Set<Id>();
    	List<FileListingWrapper> listToBeReturnedTemp = new List<FileListingWrapper>();
    	for(Integer x = offset; x<= endIndex; x++) {
    		FileListingWrapper temp = listForCalculateScore.get(x);
    		listOfIds.add(temp.contentDocumentId);
    		listToBeReturnedTemp.add(temp);
    	}
    	
    	Map<Id,List<SiteLiteWrapper>> mapOfsiteDetailsWRTFile = new Map<Id,List<SiteLiteWrapper>>();
    	FileDao fileObj = new FileDao();
    	mapOfsiteDetailsWRTFile = fileObj.getCDRelatedSites(listOfIds, 'crm');
    	
    	List<FileListingWrapper> listToBeReturned = new List<FileListingWrapper>();
    	for(FileListingWrapper fileListingItem :listToBeReturnedTemp) {
			FileListingWrapper newFLW = convertToFileListingWrapper(mapOfFiles.get(fileListingItem.contentVersionId), new Set<String>(), new Map<Id,List<SiteLiteWrapper>>(), null);
    		newFLW.itemType = 'file';
    		newFLW.fileId = fileListingItem.id;
    		if(offset == 0 && mapOfsiteDetailsWRTFile.containsKey(newFLW.ContentDocumentId)) {
    			newFLW.listOfSite = mapOfsiteDetailsWRTFile.get(newFLW.ContentDocumentId);
    		}
    		listToBeReturned.add(newFLW);
    	}
    	
		return listToBeReturned;
	}
    
    private Set<Id> getCVIdsLinkedWithSites(Map<Id, Set<Id>> groupIdWithCVMap) {
    	Set<Id> listOfCVIds = new Set<Id>();
    	
    	Set<Id> groupIdsList = groupIdWithCVMap.keySet();
		List<Simpplr_Site__c> listOfSites = new List<Simpplr_Site__c>();
		
    	// Filter remove all Sites which are not related to the User
    	// Step 1: Get all CG I follow
		Set<Id> setOfFollowedGrpIds = UserContext.chatterGroupsIFollowMap.keySet();
    			
		// Step 2: Get all Sites related to the files
		listOfSites = [select Id, chatter_group_id__c, Name, Site_Type__c, Landing_Page__c, Show_In_Simpplr__c 
						from Simpplr_Site__c 
						where Is_Deleted__c = false and Is_Active__c = true and Chatter_Group_Id__c IN :groupIdsList WITH SECURITY_ENFORCED];
    	
    	// Step 3: Remove the sites which met below conditions
    	//		Cond 1: Show in Simpplr is False
    	//		Cond 2: Non public sites which user is not following
    	for(Simpplr_Site__c siteObj : listOfSites) {
    		if(siteObj.Show_In_Simpplr__c == false || 
    		   (!'Public'.equalsIgnoreCase(siteObj.Site_Type__c) && !setOfFollowedGrpIds.contains(siteObj.chatter_group_id__c))
    		  ){
    			groupIdWithCVMap.remove(siteObj.Chatter_Group_Id__c);
    		}
    	}
    	
    	for(Set<Id> cvIdsSet : groupIdWithCVMap.values()) {
    		listOfCVIds.addAll(cvIdsSet);
    	}
    	
    	return listOfCVIds;
    }
    
    private Map<Id, Set<Id>> getGroupIdWithCVMap(Map<Id, Id> mapOfCDnCVIds) {
    	Map<Id, Set<Id>> groupIdWithCVMap = new Map<Id, Set<Id>>();
    	
    	Set<Id> listOfCDIds = mapOfCDnCVIds.keySet();
    	
    	logger.logDebug('GlobalSearchService.searchFiles()----listOfCDIds----' + listOfCDIds);
    	
    	if( !listOfCDIds.isEmpty() ) {
	    	List<ContentDocumentLink> listOfCDL = 
	    								[SELECT LinkedEntityId, ContentDocumentId from ContentDocumentLink 
	    									where ContentDocumentId = :listOfCDIds WITH SECURITY_ENFORCED
	    									order by LinkedEntityId ASC];
	    	
	    	String tempEntityId = null;
	    	Set<Id> setOfCVIds = null;
	    	for(ContentDocumentLink cDLObj : listOfCDL) {
	    		if(String.valueOf(cDLObj.LinkedEntityId).equalsIgnoreCase(tempEntityId)) {
	    		}
	    		else {
	    			if(setOfCVIds != null && setOfCVIds.size() > 0) {
	    				groupIdWithCVMap.put(tempEntityId, setOfCVIds);
	    			}
	    			
					setOfCVIds = new Set<Id>();
	    		}
	    		
	    		tempEntityId = cDLObj.LinkedEntityId;
	    		// Filter only the Documents related to Collaboration Group
	    		if(tempEntityId.startsWith('0F9')) {
	    			setOfCVIds.add(mapOfCDnCVIds.get(cDLObj.ContentDocumentId));
	    		}
	    	}
	    	
	    	if(setOfCVIds != null && setOfCVIds.size() > 0) {
				groupIdWithCVMap.put(tempEntityId, setOfCVIds);
			}
    	}
		
		logger.logDebug('GlobalSearchService.searchFiles()----groupIdWithCVMap----' + groupIdWithCVMap);
    	
    	return groupIdWithCVMap;
    }
    
    private Set<Id> getLinkedSiteLibraryCvIdSet(Map<Id, Id> mapOfCDnCVIds) {
    	Map<Id, Set<Id>> groupIdWithCVMap = new Map<Id, Set<Id>>();
    	contentWrkSpaceIdSet = new Set<String>();
    	Set<Id> setOfCVIds = new Set<Id>() ;
    	contentDocumentToSiteMap = new Map<String,Set<string>>();
    	Map<String,Set<String>> cwsToSitesMap = new Map<String,Set<String>>();
		String folderQuery = 'SELECT Id,External_Folder_Id__c,Site__c,Site__r.Show_In_Simpplr__c, ' +
			' Site__r.Is_Active__c FROM Folder__c WHERE Type__c=\'CRM\' And Site__c != NULL AND External_Folder_Id__c != NULL  ' +
			' AND Site__r.Show_In_Simpplr__c = true AND Site__r.Is_Active__c = true And Is_Deleted__c=false ' +
			' AND Site__r.File_Storage_Source__c=\'crm\'';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> folderList = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, null);
    	
    	for (Folder__c folderObj : folderList) {
			contentWrkSpaceIdSet.add(folderObj.External_Folder_Id__c);
			if (cwsToSitesMap.get(folderObj.External_Folder_Id__c) == NULL) {
				cwsToSitesMap.put(folderObj.External_Folder_Id__c,new Set<String>());
			}
			cwsToSitesMap.get(folderObj.External_Folder_Id__c).add(folderObj.Site__c);
    	}	
    	
    	Set<Id> listOfCDIds = mapOfCDnCVIds.keySet();
    	
    	if( !listOfCDIds.isEmpty() ) {
	    	List<ContentDocumentLink> listOfCDL = [SELECT LinkedEntityId, ContentDocumentId from ContentDocumentLink 
				WHERE ContentDocumentId = :listOfCDIds AND LinkedEntityId IN : contentWrkSpaceIdSet WITH SECURITY_ENFORCED
				ORDER BY LinkedEntityId ASC];
	    	
	    	for(ContentDocumentLink cDLObj : listOfCDL) {
	    		setOfCVIds.add(mapOfCDnCVIds.get(cDLObj.ContentDocumentId));
	    		contentDocumentToSiteMap.put(cDLObj.ContentDocumentId,cwsToSitesMap.get(cDLObj.LinkedEntityId));
	    	}	    	
    	}
		logger.logDebug('GlobalSearchService.getLinkedSiteLibraryCvIdSet()----contentDocumentToSiteMap----' + contentDocumentToSiteMap);
    	
    	return setOfCVIds;
    }
    
    /*##################################################################################################################################################*/
    /*##################################################################################################################################################*/

    public List<FileListingWrapper> searchEFSFiles(Criteria.File fileCriteriaObj) {
		logger.logDebug('GlobalSearchService.searchEFSFiles()----fileCriteriaObj----' + fileCriteriaObj);
		List<FileListingWrapper> listToBeReturned = new List<FileListingWrapper>();
    	List<FileListingWrapper> listForCalculateScore = new List<FileListingWrapper>();
    	List<ContentVersion> listOfFiles= new List<ContentVersion>();
    	List<Id> listOfUserIds= new List<id>();
    	Set<Id> listOfIds = new Set<Id>();
    	
    	Set<String> searchTokens= Utility.getSearchTokens(String.escapeSingleQuotes(fileCriteriaObj.term));
    	fileCriteriaObj.isGlobalSearchReq = true;
    	List<FileListingWrapper> listOfEFSFiles = new List<FileListingWrapper>();
   	
    	// Make the callout only when connected
    	if(SimpplrContext.connectedStorages.contains(fileCriteriaObj.provider) && 
    	   UserContext.connectedStorages.contains(fileCriteriaObj.provider)) {
			
			//Full Search is enabled for Sharepoint
			if(String.isBlank(fileCriteriaObj.siteId) && 
			ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(fileCriteriaObj.provider) &&
			EFSConstants.SHAREPOINT_FULL_SEARCH_CLIENT_ID.equalsIgnoreCase(SimpplrContext.integrations.get(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING).Client_Id__c)) {
				EFSAccessService efsAccess = new EFSAccessService(fileCriteriaObj.provider, false);
				EFSFileService gfs = new EFSFileService(efsAccess);
				Map<String, Object> fullSearchResponse = gfs.searchAllFilesSharePoint(fileCriteriaObj);
				gfs.close();
				listToBeReturned = (List<FileListingWrapper>) fullSearchResponse.get('listOfFiles');
				GlobalSearchService.nextPageToken = (String) fullSearchResponse.get('nextPageToken'); 
				GlobalSearchService.totalMSResults = (Integer) fullSearchResponse.get('totalRecords');
				
			} else if(ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING.equalsIgnoreCase(fileCriteriaObj.provider) || 
				ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(fileCriteriaObj.provider)) {
				
				Set<String> inaccessibleCGIdSet;
				if(String.isBlank(fileCriteriaObj.siteId)) {
					inaccessibleCGIdSet = getInaccessibleCGIdsListString(UserContext.userId);
				}
				EFSAccessService efsAccess = new EFSAccessService(fileCriteriaObj.provider, false);
				EFSFileService gfs = new EFSFileService(efsAccess);
				String scope = (String.isBlank(fileCriteriaObj.siteId) ? 'MyFiles' : 'SiteFiles');
				Map<String, Object> curatedSearchResponse = gfs.getMSDriveFilesCuratedSearch(scope, fileCriteriaObj, inaccessibleCGIdSet);
				gfs.close();

				listToBeReturned = (List<FileListingWrapper>) curatedSearchResponse.get('listOfItems');
				GlobalSearchService.nextPageToken = (String) curatedSearchResponse.get('nextPageToken');
				GlobalSearchService.totalMSResults  = (String) curatedSearchResponse.get('totalRecords');
				
			} else if(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING.equalsIgnoreCase(fileCriteriaObj.provider)) {
				GoogleDriveService gds = new GoogleDriveService();
				fileCriteriaObj.fullText = true;
				GlobalSearchService.shareddriveName = null;
				if(String.isNotBlank(fileCriteriaObj.siteId) && String.isNotBlank(fileCriteriaObj.driveType) && 'shareddrive'.equalsIgnoreCase(fileCriteriaObj.driveType)) {
					String siteId = fileCriteriaObj.siteId;
					Map<String, Object> soqlParamMap = new  Map<String, Object>();
					soqlParamMap.put('soqlParam1', siteId);
					String query = 'SELECT Id, Site__c, Name__c, Type__c, Drive_Type__c, External_Folder_Id__c, Is_Deleted__c '+
									' FROM Folder__c where Type__c = \'googledrive\' and Drive_Type__c = \'shareddrive\' '+
									' and Is_Deleted__c = false and Site__c =: soqlParam1';
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
					List<Folder__c> folderList = (List<Folder__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
					if(folderList.size() > 0) {
						fileCriteriaObj.directory = folderList[0].External_Folder_Id__c;
						GlobalSearchService.shareddriveName = folderList[0].Name__c;
					}
				} else if(String.isNotBlank(fileCriteriaObj.siteId) && String.isNotBlank(fileCriteriaObj.driveType) && IntegrationConstants.GOOGLE_DRIVE_TYPE_MYDRIVE.equalsIgnoreCase(fileCriteriaObj.driveType)) {
					String siteId = fileCriteriaObj.siteId;
					FolderDao folderDaoObj = new FolderDao();
					GlobalSearchService.isMyDriveFolderLinked = folderDaoObj.isMyDriveFolderLinkedForSite(siteId);
				}
				if(String.isBlank(fileCriteriaObj.siteId) || GlobalSearchService.shareddriveName != null || GlobalSearchService.isMyDriveFolderLinked == true) {
					Map<String, Object> searchResponse =  gds.searchFiles(fileCriteriaObj);
					listToBeReturned = (List<FileListingWrapper>) searchResponse.get('listOfFiles');
					GlobalSearchService.nextPageToken = (String) searchResponse.get('nextPageToken'); 
					GlobalSearchService.totalMSResults = searchResponse.get('totalRecords');
				} else {
					GlobalSearchService.totalMSResults = 0;
				}

			} else if(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(fileCriteriaObj.provider)) {
				try {	
					EFSAccessService efsAccess = new EFSAccessService(fileCriteriaObj.provider, false);
					EFSFileService gfs = new EFSFileService(efsAccess);				
					String srchContext = (String.isBlank(fileCriteriaObj.siteId) ? 'AppFiles' : 'SiteFiles');
					Map<String, Object> searchResponse = gfs.searchFilesDropbox(srchContext, fileCriteriaObj);

					listToBeReturned = (List<FileListingWrapper>) searchResponse.get('listOfFiles');
					GlobalSearchService.totalMSResults = searchResponse.get('totalRecords');
					GlobalSearchService.nextPageToken = (String) searchResponse.get('cursor');

					gfs.close();
				} catch(EFSException se) {
					logger.logError('GlobalSearchService.searchEFSFiles----Exception occured---->', se);
					Utility.sendExceptionEmail('GlobalSearchService.searchEFSFiles', se);
				}

			} else {
				try {	
					EFSAccessService efsAccess = new EFSAccessService(fileCriteriaObj.provider, false);
					EFSFileService gfs = new EFSFileService(efsAccess);				
					String srchContext = (String.isBlank(fileCriteriaObj.siteId) ? 'AppFiles' : 'SiteFiles');
					listOfEFSFiles = gfs.searchFiles(srchContext, fileCriteriaObj);
					gfs.close();
				} catch(EFSException se) {
					logger.logError('GlobalSearchService.searchEFSFiles----Exception occured---->', se);
					Utility.sendExceptionEmail('GlobalSearchService.searchEFSFiles', se);
				}
				
				Integer score;
				for(FileListingWrapper fileListingWrapObj: listOfEFSFiles){
					score = getFileScore(fileListingWrapObj.name, fileListingWrapObj.description, searchTokens);
					fileListingWrapObj.relevancyScore = score > 0 ? score : 1;
					fileListingWrapObj.itemType = 'file';
					listForCalculateScore.add(fileListingWrapObj);
				}
				listForCalculateScore.sort();
				GlobalSearchService.totalResults=listForCalculateScore.size();
				Integer size = fileCriteriaObj.size;
				Integer offset = fileCriteriaObj.offset;
				Integer endIndex =   offset+size;
				endIndex = (endIndex >= listForCalculateScore.size())? listForCalculateScore.size()-1 :endIndex;
						
				for(Integer x = offset; x<= endIndex; x++){
					listToBeReturned.add(listForCalculateScore.get(x));
				}
			}
		} else {
			logger.logError('GlobalSearchService.searchEFSFiles()----User is not connected.');
		}
		logger.logDebug('GlobalSearchService.searchEFSFiles()----listToBeReturned----' + listToBeReturned);
		return listToBeReturned;
    }
    
    /*##################################################################################################################################################*/
    /*##################################################################################################################################################*/

    public List<FileListingWrapper> searchBoxFiles(Criteria.File fileCriteriaObj){
    	logger.logDebug('GlobalSearchService.searchBoxFiles()----fileCriteriaObj----' + fileCriteriaObj);
    	List<FileListingWrapper> listForCalculateScore = new List<FileListingWrapper>();
    	List<ContentVersion> listOfFiles= new List<ContentVersion>();
    	List<Id> listOfUserIds= new List<id>();
    	Set<Id> listOfIds = new Set<Id>();
    	
    	Set<String> searchTokens= Utility.getSearchTokens(String.escapeSingleQuotes(fileCriteriaObj.term));
    	fileCriteriaObj.isGlobalSearchReq = true;
    	List<FileListingWrapper> listOfBoxFiles = BoxContentProvider.searchFiles(fileCriteriaObj);
		Integer score;
		for(FileListingWrapper fileListingWrapObj: listOfBoxFiles){
			score = getFileScore(fileListingWrapObj.name, fileListingWrapObj.description, searchTokens);
			fileListingWrapObj.relevancyScore = score > 0 ? score : 1;
			fileListingWrapObj.itemType = 'file';
			listForCalculateScore.add(fileListingWrapObj);
		}
		listForCalculateScore.sort();
		GlobalSearchService.totalResults=listForCalculateScore.size();
		Integer size = fileCriteriaObj.size;
		Integer offset = fileCriteriaObj.offset;
    	Integer endIndex =   offset+size;
    	endIndex = (endIndex >= listForCalculateScore.size())? listForCalculateScore.size()-1 :endIndex;
    	
    	List<FileListingWrapper> listToBeReturned = new List<FileListingWrapper>();
    	for(Integer x = offset; x<= endIndex; x++){
    		listToBeReturned.add(listForCalculateScore.get(x));
    	}
		logger.logDebug('GlobalSearchService.searchBoxFiles()----listToBeReturned----' + listToBeReturned);
		return listToBeReturned;
    }
    
    /**************************************************************************************************************
	**
	****************************************************************************************************************/
    @testVisible 
    private Integer getSiteScore(SiteListingWrapper siteListingObj, String searchTerm){
    	Integer score=0;
    	Integer SITE_TITLE_WEIGHT_EXACT_MATCH=1000;
    	Integer SITE_TITLE_WEIGHT_STARTS_WITH=1;
    	Integer SITE_TITLE_WEIGHT_CONTAINS_IT=1;
    	
    	Integer SITE_TITLE_MULTIPLICATION_FACTOR_EXACT_MATCH=3;
    	Integer SITE_TITLE_MULTIPLICATION_FACTOR_STARTS_WITH=2;
    	Integer SITE_TITLE_MULTIPLICATION_FACTOR_CONTAINS_IT=1;
    	
    	Integer SITE_DESCRIPTION_WEIGHT_EXACT_MATCH=1;
    	Integer SITE_DESCRIPTION_WEIGHT_STARTS_WITH=1;
    	Integer SITE_DESCRIPTION_WEIGHT_CONTAINS_IT=1;
    	
    	Integer SITE_DESCRIPTION_MULTIPLICATION_FACTOR_EXACT_MATCH=3;
    	Integer SITE_DESCRIPTION_MULTIPLICATION_FACTOR_STARTS_WITH=2;
    	Integer SITE_DESCRIPTION_MULTIPLICATION_FACTOR_CONTAINS_IT=1;
    	
    	Set<String> searchTokens= Utility.getSearchTokens(String.escapeSingleQuotes(searchTerm));
    	Integer numberOfUniqueTokensFound = 0;
    	for(String tokenObj : searchTokens){
    		
    		//check for score in Site Title
    		if(siteListingObj.Title.equalsIgnoreCase(tokenObj)){
    			score=score+(SITE_TITLE_WEIGHT_EXACT_MATCH*SITE_TITLE_MULTIPLICATION_FACTOR_EXACT_MATCH);
    		} else if(siteListingObj.Title.startsWithIgnoreCase(tokenObj)){
    			score=score+(SITE_TITLE_WEIGHT_STARTS_WITH*SITE_TITLE_MULTIPLICATION_FACTOR_STARTS_WITH);
    		} else if(siteListingObj.Title.containsIgnoreCase(tokenObj)){
    			score=score+(SITE_TITLE_WEIGHT_CONTAINS_IT*SITE_TITLE_MULTIPLICATION_FACTOR_CONTAINS_IT);
    		}
    		
    		//check for score in Site Description
    		
    		if(siteListingObj.Description.equalsIgnoreCase(tokenObj)){
    			score=score+(SITE_DESCRIPTION_WEIGHT_EXACT_MATCH*SITE_DESCRIPTION_MULTIPLICATION_FACTOR_EXACT_MATCH);
    		} else if(siteListingObj.Description.startsWithIgnoreCase(tokenObj)){
    			score=score+(SITE_DESCRIPTION_WEIGHT_STARTS_WITH*SITE_DESCRIPTION_MULTIPLICATION_FACTOR_STARTS_WITH);
    		} else if(siteListingObj.Description.containsIgnoreCase(tokenObj)){
    			score=score+(SITE_DESCRIPTION_WEIGHT_CONTAINS_IT*SITE_DESCRIPTION_MULTIPLICATION_FACTOR_CONTAINS_IT);
    		}
    		
    		if(siteListingObj.Title.containsIgnoreCase(tokenObj) || siteListingObj.Description.containsIgnoreCase(tokenObj)) {
    			numberOfUniqueTokensFound++;
    		}
    	}
    	if(score > 0 && siteListingObj.isFeatured) {
    		score += 5;
    	}
    	if(searchTokens.size() > 1 && numberOfUniqueTokensFound > 1) {
        	score = score + 2000 * numberOfUniqueTokensFound;
        }
    	return score;
    }
    
    /**************************************************************************************************************
	**
	****************************************************************************************************************/
    private list<People__c> updatePeopleListAccToProfileFields(List<People__c> pplList){
			List<People__c> listOfPeopleToUpdate = new List<People__c>();
			for(People__c peopleObj : pplList){
				if(SimpplrContext.isPPTitleDisplay == false){
					peopleObj.Title__c = null;
				}
				if(SimpplrContext.isPPDepartmentDisplay == false){
					peopleObj.Department__c = null;
				}
				if(SimpplrContext.isPPCityDisplay == false){
					peopleObj.City__c = null;
				}
				if(SimpplrContext.isPPStateDisplay == false){
					peopleObj.State__c = null;
				}
				if(SimpplrContext.isPPCountryDisplay == false){
					peopleObj.Country__c = null;
				}
				if(SimpplrContext.isPPFirstNameDisplay == false){
					peopleObj.First_Name__c = null;
				}
				if(SimpplrContext.isPPLastNameDisplay == false){
					peopleObj.Last_Name__c = null;
				}
				if(SimpplrContext.isPPPhoneDisplay == false){
					peopleObj.Phone__c = null;
				}
				if(SimpplrContext.isPPMobilePhoneDisplay == false){
					peopleObj.Mobile_Phone__c = null;
				}
				listOfPeopleToUpdate.add(peopleObj);
			}
			
		return listOfPeopleToUpdate;
 	}
    
    /**************************************************************************************************************
	**
	****************************************************************************************************************/
	private Map<String, Integer> getUserIdWithScoreForExpertiseInPeopleSearch(Set<String> searchTokens){
    	Map<String, Integer> mapOfUsersWithEndorsementCount = new Map<String, Integer>();
		
		if(searchTokens.size() > 0) { 
	    	List<String> listOfExpertiseId = searchExpertiseInPeople(searchTokens);
	    	ExpertiseDao expertiseDao = new ExpertiseDao();
			
			List<People_Expertise__c> peopleExpertiseList = expertiseDao.getPeopleExpertisesById(listOfExpertiseId);
			
			for(People_Expertise__c pEObj : peopleExpertiseList) {
				Integer endorsementCount = 1;
				if(mapOfUsersWithEndorsementCount.containsKey(pEObj.People__c)) {
					endorsementCount = mapOfUsersWithEndorsementCount.get(pEObj.People__c);
				}

				mapOfUsersWithEndorsementCount.put(pEObj.People__c, endorsementCount);
			}
		}
		
    	return mapOfUsersWithEndorsementCount;
	}
	
    /**************************************************************************************************************
	**
	****************************************************************************************************************/
	private Map<String, Integer> getUserIdWithUserFieldScore(Set<String> searchTokens){
    	Map<String, Integer> mapOfUsersAndUserField = new Map<String, Integer>();
    	if(searchTokens.size() > 0) {    		 
			List<CustomProfileField> userFieldList = new List<CustomProfileField>();
			if(String.isNotBlank(SimpplrContext.PPUserCustomFields)) {
    			userFieldList = (List<CustomProfileField>)Json.deserialize(SimpplrContext.PPUserCustomFields, List<CustomProfileField>.class);
				Map<String, Schema.SObjectField> userFieldAPIMap = Schema.SObjectType.User.fields.getMap();
				Set<String> userFieldAPINames = new Set<String>();
				Map<String,List<Schema.PicklistEntry>> userFieldMultiSelectAPINames = new Map<String,List<Schema.PicklistEntry>>();
				for(Schema.SObjectField userField : userFieldAPIMap.values()){
					Schema.DescribeFieldResult userFieldDescribe = userField.getDescribe();
					if((userFieldDescribe.isFilterable() == true) && ((Schema.DisplayType.Email == userFieldDescribe.getType())
						|| (Schema.DisplayType.Phone == userFieldDescribe.getType()) || (Schema.DisplayType.Picklist == userFieldDescribe.getType()) 
						|| (Schema.DisplayType.String == userFieldDescribe.getType()) || (Schema.DisplayType.TextArea == userFieldDescribe.getType())
						|| (Schema.DisplayType.URL == userFieldDescribe.getType()))){
						userFieldAPINames.add(userFieldDescribe.getName());	
					}
					else if(Schema.DisplayType.MultiPicklist == userFieldDescribe.getType()){
						if(!userFieldMultiSelectAPINames.containskey(userFieldDescribe.getName())){
							userFieldMultiSelectAPINames.put(userFieldDescribe.getName(), userFieldDescribe.getPicklistValues());
						}
					}
				}
				String userFieldQueryString = 'SELECT id,';
				for(CustomProfileField userField: userFieldList){
					if(String.isBlank(userField.syncSource) && userField.onOff == true) {
						if(userFieldAPINames.contains(userField.columnName)){
								userFieldQueryString += userField.columnName +',';
						}
						else if(userFieldMultiSelectAPINames.containsKey(userField.columnName)){
								userFieldQueryString += 'toLabel(' + userField.columnName +'),';
						}	
					}				
				}
				userFieldQueryString = userFieldQueryString.removeEnd(',') + ' From user where (';
				for(CustomProfileField userField: userFieldList){
					if(String.isBlank(userField.syncSource) && userField.onOff == true) {
						if(userFieldAPINames.contains(userField.columnName)){
							for(String search : searchTokens){
								userFieldQueryString += userField.columnName + ' like \'%' + search + '%\' ' + 'OR '; 
							}
						}
						else if(userFieldMultiSelectAPINames.containsKey(userField.columnName)){
							Set<String> picklistLabelSet = getPickListKeyFromSearchTokens(searchTokens, userFieldMultiSelectAPINames.get(userField.columnName));
							for(String search : picklistLabelSet){
								userFieldQueryString += userField.columnName + ' includes (\'' + search + '\') ' + 'OR ';	
							}						
						}	
					}				
				}
				if(userFieldQueryString.endsWith('(')){
					mapOfUsersAndUserField = new Map<String, Integer>();			
				} else{		
					userFieldQueryString = userFieldQueryString.removeEnd('OR ') + ') AND UserType = \'Standard\'';
					
		    		logger.logDebug('GlobalSearchService.getUserIdWithUserFieldScore()----userFieldQueryString----' + userFieldQueryString);		
					List<User> userList = new List<User>();
					userList = Database.query(userFieldQueryString);
					for(User userRecord : userList){
						for(CustomProfileField userField: userFieldList){
							if(String.isBlank(userField.syncSource) && userField.onOff == true) {
								if(userFieldAPINames.contains(userField.columnName)){
									for(String search : searchTokens){
										if((userRecord.get(userField.columnName) != null) && (String.valueOf(userRecord.get(userField.columnName)).containsIgnoreCase(search))){
											if(!mapOfUsersAndUserField.containsKey(userRecord.id)){
												mapOfUsersAndUserField.put(userRecord.id,1);
											}
											mapOfUsersAndUserField.put(userRecord.id,mapOfUsersAndUserField.get(userRecord.id) + 1);								
										}	
									}
								}
								else if(userFieldMultiSelectAPINames.containsKey(userField.columnName)){
									for(String search : searchTokens){
										if((userRecord.get(userField.columnName) != null) && (String.valueOf(userRecord.get(userField.columnName)).containsIgnoreCase(search))){
											if(!mapOfUsersAndUserField.containsKey(userRecord.id)){
												mapOfUsersAndUserField.put(userRecord.id,1);
											}
											mapOfUsersAndUserField.put(userRecord.id,mapOfUsersAndUserField.get(userRecord.id) + 1);								
										}	
									}
								}
							}							
						}			
					}
				}	
			}	
    	}    	
    	return mapOfUsersAndUserField;
    }    
   
    /**************************************************************************************************************
	**
	****************************************************************************************************************/
    @TestVisible 
    private Integer getPeopleScore (People__c peopleObj, Map<String, Integer> mapOfScoreDefinitions, Set<String> searchTokens){
    	Integer score= 0; //base score
    	Integer numberOfUniqueTokensFound = 0;
    	for(String searchToken:  searchTokens) {
    		Integer tokenScore = calculatePeopleScoreWithConditions(peopleObj, mapOfScoreDefinitions, searchToken);
			if(tokenScore > 0) {
				score += tokenScore;
				numberOfUniqueTokensFound++;
			}
    	}
    	if(searchTokens.size() > 1 && numberOfUniqueTokensFound > 1) {
        	score = score + 2000 * numberOfUniqueTokensFound;
        }
    	return score;
    }
    
    private Integer getScoreOnAdvancePeopleSearch(People__c peopleObj, Criteria.People peopleCriteriaObj) {
    		Integer score= 0; //base score
    		
    		Integer MULTIPLICATION_FACTOR=1000;
	    	Integer EXACT_MATCH_WEIGHT = 3;
	    	Integer STARTS_WITH_WEIGHT = 2;
	    	Integer CONTAINS_IT_WEIGHT = 1;
    		String escapedValueInDB;
    		if(String.isNotBlank(peopleCriteriaObj.title_term)) {
    			if(appConfig.PP_Title_Display__c && String.isNotBlank(peopleObj.Title__c)){
	    			escapedValueInDB = String.escapeSingleQuotes(peopleObj.Title__c);
				if(escapedValueInDB.equalsIgnoreCase(peopleCriteriaObj.title_term)){
					score= score+(EXACT_MATCH_WEIGHT * MULTIPLICATION_FACTOR);
				} else if(escapedValueInDB.startsWithIgnoreCase(peopleCriteriaObj.title_term)){
					score= score+(STARTS_WITH_WEIGHT * MULTIPLICATION_FACTOR);
				} else if(escapedValueInDB.containsIgnoreCase(peopleCriteriaObj.title_term)){
					score= score+(CONTAINS_IT_WEIGHT * MULTIPLICATION_FACTOR);
				}
    			}
    		}
    		if(String.isNotBlank(peopleCriteriaObj.name_term)) {
    			if(appConfig.PP_FirstName_Display__c && String.isNotBlank(peopleObj.First_Name__c)){
	    			escapedValueInDB = String.escapeSingleQuotes(peopleObj.First_Name__c);
				if(escapedValueInDB.equalsIgnoreCase(peopleCriteriaObj.name_term)){
					score= score+(EXACT_MATCH_WEIGHT * MULTIPLICATION_FACTOR);
				} else if(escapedValueInDB.startsWithIgnoreCase(peopleCriteriaObj.name_term)){
					score= score+(STARTS_WITH_WEIGHT * MULTIPLICATION_FACTOR);
				} else if(escapedValueInDB.containsIgnoreCase(peopleCriteriaObj.name_term)){
					score= score+(CONTAINS_IT_WEIGHT * MULTIPLICATION_FACTOR);
				}
    			}
    			if(appConfig.PP_LastName_Display__c && String.isNotBlank(peopleObj.Last_Name__c)){
	    			escapedValueInDB = String.escapeSingleQuotes(peopleObj.Last_Name__c);
				if(escapedValueInDB.equalsIgnoreCase(peopleCriteriaObj.name_term)){
					score= score+(EXACT_MATCH_WEIGHT * MULTIPLICATION_FACTOR);
				} else if(escapedValueInDB.startsWithIgnoreCase(peopleCriteriaObj.name_term)){
					score= score+(STARTS_WITH_WEIGHT * MULTIPLICATION_FACTOR);
				} else if(escapedValueInDB.containsIgnoreCase(peopleCriteriaObj.name_term)){
					score= score+(CONTAINS_IT_WEIGHT * MULTIPLICATION_FACTOR);
				}
    			}
    		}
    		if(String.isNotBlank(peopleCriteriaObj.phone_term)) {
	    		if(appConfig.PP_MobilePhone_Display__c && String.isNotBlank(peopleObj.Mobile_Phone__c)){
				escapedValueInDB = String.escapeSingleQuotes(peopleObj.Mobile_Phone__c);
				if(escapedValueInDB.equalsIgnoreCase(peopleCriteriaObj.phone_term)){
					score= score+(EXACT_MATCH_WEIGHT * MULTIPLICATION_FACTOR);
				} else if(escapedValueInDB.startsWithIgnoreCase(peopleCriteriaObj.phone_term)){
					score= score+(STARTS_WITH_WEIGHT * MULTIPLICATION_FACTOR);
				} else if(escapedValueInDB.containsIgnoreCase(peopleCriteriaObj.phone_term)){
					score= score+(CONTAINS_IT_WEIGHT * MULTIPLICATION_FACTOR);
				}
			}
			if(appConfig.PP_Phone_Display__c && String.isNotBlank(peopleObj.Phone__c)){
				escapedValueInDB = String.escapeSingleQuotes(peopleObj.Phone__c);
				if(escapedValueInDB.equalsIgnoreCase(peopleCriteriaObj.phone_term)){
					score= score+(EXACT_MATCH_WEIGHT * MULTIPLICATION_FACTOR);
				} else if(escapedValueInDB.startsWithIgnoreCase(peopleCriteriaObj.phone_term)){
					score= score+(STARTS_WITH_WEIGHT * MULTIPLICATION_FACTOR);
				} else if(escapedValueInDB.containsIgnoreCase(peopleCriteriaObj.phone_term)){
					score= score+(CONTAINS_IT_WEIGHT * MULTIPLICATION_FACTOR);
				}
			}
		}
    		return score;
    		
    }
    
	/**************************************************************************************************************
	**
	****************************************************************************************************************/
    @TestVisible 
    private Integer calculatePeopleScoreWithConditions(People__c peopleObj, Map<String, Integer> mapOfScoreDefinitions,  String searchToken){
    	Integer score=0;
    	
    	Integer PEOPLE_MULTIPLICATION_FACTOR_PRIMARY_FIELD=1000;
    	Integer PEOPLE_MULTIPLICATION_FACTOR_EXACT_MATCH=3;
    	Integer PEOPLE_MULTIPLICATION_FACTOR_STARTS_WITH=2;
    	Integer PEOPLE_MULTIPLICATION_FACTOR_CONTAINS_IT=1;
    	
    	Integer ABOUT_ME_WEIGHT=  (mapOfScoreDefinitions.get('about__c')==null)?1:mapOfScoreDefinitions.get('about__c');
		Integer CITY_WEIGHT= (mapOfScoreDefinitions.get('city__c')==null)?1:mapOfScoreDefinitions.get('city__c');
		Integer COUNTRY_WEIGHT=  (mapOfScoreDefinitions.get('country__c')==null)?1:mapOfScoreDefinitions.get('country__c');
		Integer DEPARTMENT_WEIGHT= (mapOfScoreDefinitions.get('department__c')==null)?1:mapOfScoreDefinitions.get('department__c');
		Integer EXTENSION_WEIGHT=  (mapOfScoreDefinitions.get('extension__c')==null)?1:mapOfScoreDefinitions.get('extension__c');
		Integer MOBILE_PHONE_WEIGHT= (mapOfScoreDefinitions.get('mobile_phone__c')==null)?1:mapOfScoreDefinitions.get('mobile_phone__c');
		Integer PHONE_WEIGHT=  (mapOfScoreDefinitions.get('phone__c')==null)?1:mapOfScoreDefinitions.get('phone__c');
		Integer STATE_WEIGHT= (mapOfScoreDefinitions.get('state__c')==null)?1:mapOfScoreDefinitions.get('state__c');
		Integer TITLE_WEIGHT= (mapOfScoreDefinitions.get('title__c')==null)?1:mapOfScoreDefinitions.get('title__c');
		
		/******************SPECIAL FIELDS WITH PRIMARY WEIGHTS AND MULTIPLICATION FACTORS START***********************/
		Integer FIRST_NAME_WEIGHT= (mapOfScoreDefinitions.get('first_name__c')==null)?4:mapOfScoreDefinitions.get('first_name__c');
		Integer LAST_NAME_WEIGHT= (mapOfScoreDefinitions.get('last_name__c')==null)?4:mapOfScoreDefinitions.get('last_name__c');
		Integer NAME_WEIGHT= (mapOfScoreDefinitions.get('name__c')==null)?4:mapOfScoreDefinitions.get('name__c');
		Integer EMAIL_WEIGHT= (mapOfScoreDefinitions.get('email__c')==null)?4:mapOfScoreDefinitions.get('email__c');
		/****************** SPECIAL FIELDS WITH PRIMARY WEIGHTS AND MULTIPLICATION FACTORS END ***********************/
    	String escapedValueInDB;
    	if(appConfig.PP_About_Me_Display__c){
				if(String.isNotBlank(peopleObj.About__c)){
					escapedValueInDB = String.escapeSingleQuotes(peopleObj.About__c);
					if(escapedValueInDB.equalsIgnoreCase(searchToken)){
						score= score+(ABOUT_ME_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_EXACT_MATCH);
					} else if(escapedValueInDB.startsWithIgnoreCase(searchToken)){
						score= score+(ABOUT_ME_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_STARTS_WITH);
					} else if(escapedValueInDB.containsIgnoreCase(searchToken)){
						score= score+(ABOUT_ME_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_CONTAINS_IT);
					}
				}
			}
			if(appConfig.PP_City_Display__c){
				if(String.isNotBlank(peopleObj.City__c)){
					escapedValueInDB = String.escapeSingleQuotes(peopleObj.City__c);
					if(escapedValueInDB.equalsIgnoreCase(searchToken)){
						score= score+(CITY_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_EXACT_MATCH);
					} else if(escapedValueInDB.startsWithIgnoreCase(searchToken)){
						score= score+(CITY_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_STARTS_WITH);
					} else if(escapedValueInDB.containsIgnoreCase(searchToken)){
						score= score+(CITY_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_CONTAINS_IT);
					}
				}
			}
			if(appConfig.PP_Country_Display__c){
				if(String.isNotBlank(peopleObj.Country__c)){
					escapedValueInDB = String.escapeSingleQuotes(peopleObj.Country__c);
					if(escapedValueInDB.equalsIgnoreCase(searchToken)){
						score= score+(COUNTRY_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_EXACT_MATCH);
					} else if(escapedValueInDB.startsWithIgnoreCase(searchToken)){
						score= score+(COUNTRY_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_STARTS_WITH);
					} else if(escapedValueInDB.containsIgnoreCase(searchToken)){
						score= score+(COUNTRY_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_CONTAINS_IT);
					}
				}
			}
			if(appConfig.PP_Department_Display__c){
				if(String.isNotBlank(peopleObj.Department__c)){
					escapedValueInDB = String.escapeSingleQuotes(peopleObj.Department__c);
					if(escapedValueInDB.equalsIgnoreCase(searchToken)){
						score= score+(DEPARTMENT_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_EXACT_MATCH);
					} else if(escapedValueInDB.startsWithIgnoreCase(searchToken)){
						score= score+(DEPARTMENT_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_STARTS_WITH);
					} else if(escapedValueInDB.containsIgnoreCase(searchToken)){
						score= score+(DEPARTMENT_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_CONTAINS_IT);
					}
				}
			}
			if(appConfig.PP_Extension_Display__c){
				if(String.isNotBlank(peopleObj.Extension__c)){
					escapedValueInDB = String.escapeSingleQuotes(peopleObj.Extension__c);
					if(escapedValueInDB.equalsIgnoreCase(searchToken)){
						score= score+(EXTENSION_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_EXACT_MATCH);
					} else if(escapedValueInDB.startsWithIgnoreCase(searchToken)){
						score= score+(EXTENSION_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_STARTS_WITH);
					} else if(escapedValueInDB.containsIgnoreCase(searchToken)){
						score= score+(EXTENSION_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_CONTAINS_IT);
					}
				}
			}
			if(appConfig.PP_MobilePhone_Display__c){
				if(String.isNotBlank(peopleObj.Mobile_Phone__c)){
					escapedValueInDB = String.escapeSingleQuotes(peopleObj.Mobile_Phone__c);
					if(escapedValueInDB.equalsIgnoreCase(searchToken)){
						score= score+(MOBILE_PHONE_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_EXACT_MATCH);
					} else if(escapedValueInDB.startsWithIgnoreCase(searchToken)){
						score= score+(MOBILE_PHONE_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_STARTS_WITH);
					} else if(escapedValueInDB.containsIgnoreCase(searchToken)){
						score= score+(MOBILE_PHONE_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_CONTAINS_IT);
					}
				}
			}
			if(appConfig.PP_Phone_Display__c){
				if(String.isNotBlank(peopleObj.Phone__c)){
					escapedValueInDB = String.escapeSingleQuotes(peopleObj.Phone__c);
					if(escapedValueInDB.equalsIgnoreCase(searchToken)){
						score= score+(PHONE_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_EXACT_MATCH);
					} else if(escapedValueInDB.startsWithIgnoreCase(searchToken)){
						score= score+(PHONE_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_STARTS_WITH);
					} else if(escapedValueInDB.containsIgnoreCase(searchToken)){
						score= score+(PHONE_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_CONTAINS_IT);
					}
				}
			}
			if(appConfig.PP_State_Display__c){
				if(String.isNotBlank(peopleObj.State__c)){
					escapedValueInDB = String.escapeSingleQuotes(peopleObj.State__c);
					if(escapedValueInDB.equalsIgnoreCase(searchToken)){
						score= score+(STATE_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_EXACT_MATCH);
					} else if(escapedValueInDB.startsWithIgnoreCase(searchToken)){
						score= score+(STATE_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_STARTS_WITH);
					} else if(escapedValueInDB.containsIgnoreCase(searchToken)){
						score= score+(STATE_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_CONTAINS_IT);
					}
				}
			}
			if(appConfig.PP_Title_Display__c){
				if(String.isNotBlank(peopleObj.Title__c)){
					escapedValueInDB = String.escapeSingleQuotes(peopleObj.Title__c);
					if(escapedValueInDB.equalsIgnoreCase(searchToken)){
						score= score+(TITLE_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_EXACT_MATCH);
					} else if(escapedValueInDB.startsWithIgnoreCase(searchToken)){
						score= score+(TITLE_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_STARTS_WITH);
					} else if(escapedValueInDB.containsIgnoreCase(searchToken)){
						score= score+(TITLE_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_CONTAINS_IT);
					}
				}
			}
			/***********************************SPECIAL FIELDS WITH PRIMARY SEARCH START****************************************/
			//Name Search Starts
			if(String.isNotBlank(peopleObj.Full_Name__c)){
				escapedValueInDB = String.escapeSingleQuotes(peopleObj.Full_Name__c);
				if(escapedValueInDB.equalsIgnoreCase(searchToken)){
					score= score+(NAME_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_PRIMARY_FIELD);
				} else if(escapedValueInDB.startsWithIgnoreCase(searchToken)){
					score= score+(NAME_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_STARTS_WITH);
				} else if(escapedValueInDB.containsIgnoreCase(searchToken)){
					score= score+(NAME_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_CONTAINS_IT);
				}
			}
			//Name Search Ends
			
			//Email Search Starts
			if(String.isNotBlank(peopleObj.Email__c)){
				escapedValueInDB = String.escapeSingleQuotes(peopleObj.Email__c);
				if(escapedValueInDB.equalsIgnoreCase(searchToken)){
					score= score+(EMAIL_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_PRIMARY_FIELD);
				} else if(escapedValueInDB.startsWithIgnoreCase(searchToken)){
					score= score+(EMAIL_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_STARTS_WITH);
				} else if(escapedValueInDB.containsIgnoreCase(searchToken)){
					score= score+(EMAIL_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_CONTAINS_IT);
				}
			}
			//Email Search Ends
			
			if(appConfig.PP_FirstName_Display__c){
				if(String.isNotBlank(peopleObj.First_Name__c)){
					escapedValueInDB = String.escapeSingleQuotes(peopleObj.First_Name__c);
					if(escapedValueInDB.equalsIgnoreCase(searchToken)){
						score= score+(FIRST_NAME_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_PRIMARY_FIELD);
					} else if(escapedValueInDB.startsWithIgnoreCase(searchToken)){
						score= score+(FIRST_NAME_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_STARTS_WITH);
					} else if(escapedValueInDB.containsIgnoreCase(searchToken)){
						score= score+(FIRST_NAME_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_CONTAINS_IT);
					}
				}
			}
			if(appConfig.PP_LastName_Display__c){
				escapedValueInDB = String.escapeSingleQuotes(peopleObj.Last_Name__c);
				if(escapedValueInDB.equalsIgnoreCase(searchToken)){
					score= score+(LAST_NAME_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_PRIMARY_FIELD);
				} else if(escapedValueInDB.startsWithIgnoreCase(searchToken)){
					score= score+(LAST_NAME_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_STARTS_WITH);
				} else if(escapedValueInDB.containsIgnoreCase(searchToken)){
					score= score+(LAST_NAME_WEIGHT*PEOPLE_MULTIPLICATION_FACTOR_CONTAINS_IT);
				}
			}
			return score;
    }
    
	/**************************************************************************************************************
	**
	****************************************************************************************************************/
    @TestVisible 
    private List<String> searchExpertiseInPeople(Set<String> searchTokens) {
    	Boolean addORInQuery = false;
    	String expertiseQuery = 'SELECT Id, Name__c from Expertise__c WHERE';
		
		expertiseQuery += ' (';
    	for(String searchToken : searchTokens){
    		if(addORInQuery){
    			expertiseQuery += ' OR ';
    		}
    		expertiseQuery += 'Name__c like \'%'+searchToken+'%\'';
    		addORInQuery=true;
    	}
    	expertiseQuery += ')';
    	
    	logger.logDebug('GlobalSearchService.searchExpertiseInPeople()----expertiseQuery----' + expertiseQuery);
    	List<String> expertiseIds = new List<String>();
    	List<Expertise__c> listOfMatchedExpertise = Database.query(expertiseQuery);
    	for(Expertise__c expertiseObj: listOfMatchedExpertise){
    		expertiseIds.add(expertiseObj.id);
    	}
    	logger.logDebug('GlobalSearchService.searchExpertiseInPeople()----expertiseIds----' + expertiseIds);
    	return expertiseIds;
    }

	/**************************************************************************************************************
	**
	****************************************************************************************************************/
    @TestVisible 
    private String getFilterCriteria(Criteria.People peopleCriteriaObj, Set<String> userIdsFromSearch) {
		String cityQueryParam;
		String stateQueryParam;
		String countryQueryParam;
		String nameQueryParam;
		String telephoneQueryParam;
		String titleQueryParam;
		Set<String> setOfSearchTerms;
		String filterCriteria = '';
		if(String.isNotBlank(peopleCriteriaObj.userCategory)) {
			if(ServiceConstants.UNCATEGORIZED_CATEGORY_STR.equalsIgnoreCase(peopleCriteriaObj.userCategory)){
				filterCriteria += ' AND People_Category__c = null ';
			} else if(!'all'.equalsIgnoreCase(peopleCriteriaObj.userCategory)){
				filterCriteria += ' AND People_Category__c = \'' + String.escapeSingleQuotes(peopleCriteriaObj.userCategory) + '\' ';
			}
        }
        
		if(String.isNotBlank(peopleCriteriaObj.term)) {
			setOfSearchTerms = Utility.getSearchTokens(String.escapeSingleQuotes(peopleCriteriaObj.term));
			String queryPart='';
			for(String searchToken:setOfSearchTerms){
				queryPart+=' OR Full_Name__c like \'%'+searchToken+'%\' ';
				queryPart+=' OR Email__c like \'%'+searchToken+'%\' ';
				
				String numericOnlySearchTerm = searchToken.replaceAll('[^?#0-9a-zA-Z]+', '').replaceFirst('^0+(?!$)','');
				if(appConfig.People_Category_Enabled__c){
					queryPart+=' OR People_Category__r.Name__c like \'%'+searchToken+'%\' ';
				}
				if(appConfig.PP_City_Display__c){
					queryPart+=' OR City__c like \'%'+searchToken+'%\' ';
				}
				if(appConfig.PP_Country_Display__c){
					queryPart+=' OR Country__c like \'%'+searchToken+'%\' ';
				}
				if(appConfig.PP_Department_Display__c){
					queryPart+=' OR Department__c like \'%'+searchToken+'%\' ';
				}
				if(appConfig.PP_Extension_Display__c){
					queryPart+=' OR Extension__c like \'%'+searchToken+'%\' ';
				}
				if(appConfig.PP_FirstName_Display__c){
					queryPart+=' OR First_Name__c like \'%'+searchToken+'%\' ';
				}
				if(appConfig.PP_Video_Display__c){
					queryPart+=' OR Skype_Id__c like \'%'+searchToken+'%\' ';
					queryPart+=' OR Zoom_Id__c like \'%'+searchToken+'%\' ';
				}
				if(appConfig.PP_State_Display__c){
					queryPart+=' OR State__c like \'%'+searchToken+'%\' ';
				}
				if(appConfig.PP_Title_Display__c){
					queryPart+=' OR Title__c like \'%'+searchToken+'%\' ';
				}
			}
			if(!userIdsFromSearch.isEmpty()) {
				queryPart+=' OR Id =: userIdsFromSearch ';
			}
			filterCriteria += 'and (' + queryPart.removeStart(' OR') + ')';
		}
		
		logger.logDebug('GlobalSearchService.getFilterCriteria()----filterCriteria----' + filterCriteria);
		return filterCriteria;
	}
	
    /**************************************************************************************************************
	**
	****************************************************************************************************************/
    private Map<Id,Integer> getPageIdByCategoryAndScore(Set<String> searchTokens, String relatedSimpplrSite, String filter, String author, String type, DateTime publishStartDateTime, String topicId) {
        Map<Id,Integer> mapOfPageIdAndScore = new Map<Id,Integer>();
        String contentTypeFilter = '\'%' + ServiceConstants.TYPE_PAGE + '%\'';
        String query  = 'Select id,Pages_Category__c, Pages_Category__r.Name__c from Simpplr_Content__c where Is_Deleted__c=false ' +
                        'And Site__r.Is_Deleted__c = false '+ 
                        'And Site__r.Is_Active__c = true '+
                        'And Site__r.Show_In_Simpplr__c = true '+
                        'And Is_Published__c = true ' +
                        'And Type__c = \'Page\' '+
                        'And Site__r.Has_Pages__c = true ' +
                        'AND ( '; 
    	
    	Boolean addORinQuery=false;
    	for(String searchToken: searchTokens) { 
        	if(addORinQuery){
        		query += ' OR ';
        	}
        	query += ' Pages_Category__r.Name__c like \'%' + searchToken + '%\'' ;
        	addORinQuery=true;
        }
        query += ' )';
		query += getContentFilterCondition(relatedSimpplrSite, author, type, publishStartDateTime);
		query += getTopicCondition(topicId);
        Set<Id> setOfIdsToFilter = new Set<Id>();
        if('following'.equalsIgnoreCase(filter)) {
			setOfIdsToFilter = UserContext.chatterGroupsIFollowIdSet;
			query += ' And Site__r.Chatter_Group_Id__c =:setOfIdsToFilter ';
		}
        logger.logDebug('GlobalSearchService.getPageIdByCategoryAndScore()----query----' + query);
        List<Simpplr_Content__c> listOfSimpplrContent = Database.query(query);
        
        Integer NAME_WEIGHT_EXACT_MATCH=1000;
        Integer NAME_WEIGHT_STARTS_WITH=1;
        Integer NAME_WEIGHT_CONTAINS_IT=1;
        
        Integer MULTIPLICATION_FACTOR_EXACT_MATCH=1;
        Integer MULTIPLICATION_FACTOR_STARTS_WITH=1;
        Integer MULTIPLICATION_FACTOR_CONTAINS_IT=1;
        
        for(Simpplr_Content__c contentObj : listOfSimpplrContent) {
        	Integer score=0;
        	for(String searchToken: searchTokens){
				if(contentObj.Pages_Category__r.Name__c.equalsIgnoreCase(searchToken)){
					score=score+NAME_WEIGHT_EXACT_MATCH * MULTIPLICATION_FACTOR_EXACT_MATCH;
					
				} else if(contentObj.Pages_Category__r.Name__c.startsWithIgnoreCase(searchToken)) {
					score=score+NAME_WEIGHT_STARTS_WITH * MULTIPLICATION_FACTOR_STARTS_WITH;
						
				} else if(contentObj.Pages_Category__r.Name__c.containsIgnoreCase(searchToken)) {
					score=score+NAME_WEIGHT_CONTAINS_IT * MULTIPLICATION_FACTOR_CONTAINS_IT;
						
				}
			}
            mapOfPageIdAndScore.put(contentObj.id,score);
        }
        logger.logDebug('GlobalSearchService.getPageIdByCategoryAndScore()----mapOfPageIdAndScore----' + mapOfPageIdAndScore);
    	return mapOfPageIdAndScore;
    }
    
    /**************************************************************************************************************
	**
	****************************************************************************************************************/
   	private Map<Id,Integer> getContentIdByTopicAndScore( Set<String> searchTokens, String relatedSimpplrSite, String filter, String author, String type, DateTime publishStartDateTime, String topicId) {
        Map<Id,Integer> mapOfContentIdAndScore = new Map<Id,Integer>();
        String query  = 'select topic.name, EntityId from topicassignment where EntityId in (select id From Simpplr_Content__c where Is_Deleted__c=false ';
    	
		query += getContentFilterCondition(relatedSimpplrSite, author, type, publishStartDateTime);
		query  += ') AND ( '; 
    	
    	Boolean addORinQuery=false;
    	for(String searchToken: searchTokens) {
        	if(addORinQuery){
        		query += ' OR ';
        	}
        	query += ' topic.name like \'%' + searchToken + '%\'' ;
        	addORinQuery=true;
        }
		query += ' ) ';
		if(String.isNotBlank(topicId)) { 
			query += ' And topicId=:topicId ';
		}
        logger.logDebug('GlobalSearchService.getContentIdByTopicAndScore()----query----' + query);
        List<TopicAssignment> listOfTopicAssignment = Database.query(query);
        
        Integer NAME_WEIGHT_EXACT_MATCH=1000;
        Integer NAME_WEIGHT_STARTS_WITH=1;
        Integer NAME_WEIGHT_CONTAINS_IT=1;
        
        Integer MULTIPLICATION_FACTOR_EXACT_MATCH=1;
        Integer MULTIPLICATION_FACTOR_STARTS_WITH=1;
        Integer MULTIPLICATION_FACTOR_CONTAINS_IT=1;
        
        for(TopicAssignment topicAssignmentObj : listOfTopicAssignment) {
        	Integer score=mapOfContentIdAndScore.get(topicAssignmentObj.entityId) != null ? mapOfContentIdAndScore.get(topicAssignmentObj.entityId) : 0;
        	for(String searchToken: searchTokens){
				if(topicAssignmentObj.Topic.Name.equalsIgnoreCase(searchToken)){
					score=score+NAME_WEIGHT_EXACT_MATCH * MULTIPLICATION_FACTOR_EXACT_MATCH;
					
				} else if(topicAssignmentObj.Topic.Name.startsWithIgnoreCase(searchToken)) {
					score=score+NAME_WEIGHT_STARTS_WITH * MULTIPLICATION_FACTOR_STARTS_WITH;
						
				} else if(topicAssignmentObj.Topic.Name.containsIgnoreCase(searchToken)) {
					score=score+NAME_WEIGHT_CONTAINS_IT * MULTIPLICATION_FACTOR_CONTAINS_IT;
						
				}
			}
            mapOfContentIdAndScore.put(topicAssignmentObj.entityId,score);
        }
        logger.logDebug('GlobalSearchService.getPageIdByCategoryAndScore()----mapOfContentIdAndScore----' + listOfTopicAssignment);
    	return mapOfContentIdAndScore;
	}
    
    /**************************************************************************************************************
	**
	****************************************************************************************************************/
    private Map<Id,Double> getContentIdBySOSLAndScore(Set<String> searchTokens, String relatedSimpplrSite, String filter, String author, String type, DateTime publishStartDateTime) {
        Map<Id,Double> mapOfContentIdAndScore = new Map<Id,Double>();
        
		try {
	    	String SOSL_Query = Utility.generateStringForSOSLQuery(searchTokens);
	        SOSL_Query = 'FIND {'+SOSL_Query +'} IN All FIELDS RETURNING ' + PageContext.namespacePrefix +'Simpplr_Content__c (Id WHERE Is_Deleted__c = false ';
			
			SOSL_QUERY += getContentFilterCondition(relatedSimpplrSite, author, type, publishStartDateTime);
						
			SOSL_Query += ')';
			
			logger.logDebug('GlobalSearchService.getContentIdBySOSLAndScore()----SOSL_Query----' + SOSL_Query);
	        List<List<SObject>> searchList = Search.query(SOSL_Query);
	        
	        Double score = 2.0;
	        for (List<SObject> lstSRElement : searchList) {
	            if(lstSRElement.size() > 0) {
	                for (SObject srElement : lstSRElement ) {
	                	score = score - 0.001;
	                    mapOfContentIdAndScore.put(srElement.Id, score);
	                }
	            }
	        }
		} catch(Exception ex) {
			// Just Ignore any SOSL error during content search, 
			// user may enter single char and its allowed to enter single char for non english languages
			logger.logError('GlobalSearchService.getContentIdBySOSLAndScore()----Exception occured in Content Search', ex);
		}
        
        logger.logDebug('GlobalSearchService.getContentIdBySOSLAndScore()----mapOfContentIdAndScore----' + mapOfContentIdAndScore);
    	return mapOfContentIdAndScore;
	}
	
	private String getContentFilterCondition(String relatedSimpplrSite, String author, String type, DateTime publishStartDateTime) {
		String contentFilterCondition = ' And Is_Published__c = true AND TYPE__c IN : allowedFeaturesInAppList ';
		if(String.isNotBlank(relatedSimpplrSite)) {
			relatedSimpplrSite = String.escapeSingleQuotes(relatedSimpplrSite);
			contentFilterCondition += ' And Site__r.id =:relatedSimpplrSite ';
		}

		if(String.isNotBlank(author)) {
			contentFilterCondition += ' And primary_author__c =:author ';
		}

		if(String.isNotBlank(type)) {
			contentFilterCondition += ' And Type__c =:type ';
		}

		if(publishStartDateTime !=null) {            	
			contentFilterCondition += ' And Publish_Start_DateTime__c >=: publishStartDateTime ';
		}
		return contentFilterCondition;
	}

	private String getTopicCondition(String topicId){
		String queryStr = '';
		if(String.isNotBlank(topicId)){
			queryStr += 'And Id in (select EntityId from TopicAssignment where TopicId=: topicId ' +
            				'And EntityType=\'Simpplr_Content\') ';
		}
		
		return queryStr;
	}
    
	/**************************************************************************************************************
	**
	****************************************************************************************************************/
    @TestVisible 
    private Map<Id,List<SiteLiteWrapper>> getSiteDetailsOfCrmFiles(){
    	
    	Map<Id, List<SiteLiteWrapper>> mapofCDIdAndRelatedSites= new Map<Id,List<SiteLiteWrapper>>();
    	List<Simpplr_Site__c> listOfSites = new List<Simpplr_Site__c>();
    	Set<String> chatterGroupIdsSet = new Set<String>();
		Set<String> siteIdsSet = new Set<String>();
		Set<Id> setOfFollowedGrpIds = new Set<Id>();
		Map<Id,Simpplr_Site__c> idToSiteObjMap = new Map<Id,Simpplr_Site__c>();
		
		for (String cdId : contentDocumentToSiteMap.keySet()) {
			if (contentDocumentToSiteMap.get(cdId) != NULL ) {
				siteIdsSet.addAll(contentDocumentToSiteMap.get(cdId));
			}
		}
		
		if(contentDocumentToSiteMap != NULL){
			listOfSites= [SELECT Id, chatter_group_id__c,Name, Site_Type__c, Allowed_Features__c, Landing_Page__c FROM Simpplr_Site__c 
					WHERE Id IN :siteIdsSet WITH SECURITY_ENFORCED];
			
			for (Simpplr_Site__c site : listOfSites) {		
				chatterGroupIdsSet.add(site.chatter_group_id__c);
				idToSiteObjMap.put(site.id, site);
			}
			List<CollaborationGroupMember> listOfMembers = [SELECT CollaborationGroupId FROM 
					CollaborationGroupMember WHERE CollaborationGroupId =:chatterGroupIdsSet 
					AND MemberId=:UserContext.id WITH SECURITY_ENFORCED];
			for(CollaborationGroupMember memberObj:listOfMembers) {
				setOfFollowedGrpIds.add(memberObj.CollaborationGroupId);
			}
		} 
		
		
		map<Id,Simpplr_Site__c> mapOfCollaborationGroupAndSite = new map<Id,Simpplr_Site__c>();
		for(Simpplr_Site__c siteObj: listOfSites){
			if('Public'.equalsIgnoreCase(siteObj.Site_Type__c) || 
				setOfFollowedGrpIds.contains(siteObj.chatter_group_id__c)) {
				mapOfCollaborationGroupAndSite.put(siteObj.chatter_group_id__c,siteObj);
			}
		}
		
		for(String cdId : contentDocumentToSiteMap.keySet()) {
			
			for(String siteId : contentDocumentToSiteMap.get(cdId)){
				Simpplr_Site__c siteObj = idToSiteObjMap.get(siteId);
				if (mapOfCollaborationGroupAndSite.containsKey(siteObj.chatter_group_id__c) ){
					SiteLiteWrapper siteWrapObj= new SiteLiteWrapper();
					siteWrapObj.siteId= siteObj.id;
					siteWrapObj.name=siteObj.Name;
					siteWrapObj.url= PageContext.getPageURL(Pages.app) +'?u=/site/' + siteObj.id + '/' + siteObj.Landing_Page__c;
					siteWrapObj.isPrivate = ServiceConstants.PRIVATE_SITE.equalsIgnoreCase(siteObj.Site_Type__c)?true:false;
					siteWrapObj.isListed = ServiceConstants.UNLISTED_SITE.equalsIgnoreCase(siteObj.Site_Type__c)?false:true;
					
					if(mapofCDIdAndRelatedSites.containsKey(cdId)) {
						List<SiteLiteWrapper> listOfSiteWrapper = mapofCDIdAndRelatedSites.get(cdId);
						listOfSiteWrapper.add(siteWrapObj);
						mapofCDIdAndRelatedSites.put(cdId,listOfSiteWrapper);
					} else {
						mapofCDIdAndRelatedSites.put(cdId,new List<SiteLiteWrapper>{siteWrapObj});
					}
				}
				
			}
		}
				

		return mapofCDIdAndRelatedSites;
    }

    /**************************************************************************************************************
	**
	****************************************************************************************************************/
	@testVisible 
    private  FileListingWrapper convertToFileListingWrapper(ContentVersion fileObj, set<String> searchTokens, 
    		Map<Id,List<SiteLiteWrapper>> mapOfsiteDetailsWRTFile, List<ContentDocumentLink> cdlList){
    	FileListingWrapper fileListingWrapObj= new FileListingWrapper();
    	fileListingWrapObj.id=fileObj.ContentDocumentId;
		fileListingWrapObj.name=fileObj.Title;
		fileListingWrapObj.title=fileObj.Title;
		fileListingWrapObj.url= PageContext.getPageURL(Pages.FileDetail) +'?fileId=' + fileObj.ContentDocumentId;
		fileListingWrapObj.publicUrl=''; //to be decided later
		fileListingWrapObj.fileUrl=''; //to be decided later
		fileListingWrapObj.downloadUrl=Utility.getFileDownloadURL(fileObj.id); 
		fileListingWrapObj.isDir=false;
		fileListingWrapObj.context = 'H'.equalsIgnoreCase(fileObj.Origin) ? 'Intranet' : 'CRM';
		fileListingWrapObj.isImage = 'pdf'.equalsIgnoreCase(fileObj.fileExtension) || Utility.isImage(fileObj.fileExtension);
		if(UserContext.hasModifyAllDataPermission || UserContext.id.equalsIgnoreCase(fileObj.OwnerId)) {
			fileListingWrapObj.canCreatePublicShareLink = true;
		} else {
			fileListingWrapObj.canCreatePublicShareLink = ObjectToWrapperAdapter.checkUploadNewVersionPermission(cdlList);
		}
		
		if(fileListingWrapObj.isImage) {
			fileListingWrapObj.thumbnailImg = Utility.getFileDownloadURLFor240BY180(fileObj.Id);
			fileListingWrapObj.imgTHUMB240BY180URL = SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +fileObj.ContentDocumentId+'/rendition?type=THUMB240BY180';
			fileListingWrapObj.imgTHUMB720BY480URL = SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +fileObj.ContentDocumentId+'/rendition?type=THUMB720BY480';
			fileListingWrapObj.imgFullURL = SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +fileObj.ContentDocumentId+'/content';
		}
		fileListingWrapObj.type = fileObj.FileType;
		fileListingWrapObj.FileExtension = fileObj.FileExtension;
		fileListingWrapObj.size=fileObj.ContentSize;
		if(fileObj.ContentModifiedDate != NULL) {
			fileListingWrapObj.modifiedAt = fileObj.ContentModifiedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		}
		fileListingWrapObj.modifiedAtDateTime = fileObj.ContentModifiedDate;
		fileListingWrapObj.owner.id=fileObj.OwnerId;
		fileListingWrapObj.owner.name=fileObj.Owner.Name;
		fileListingWrapObj.owner.url=PageContext.getPageURL(Pages.app) + '?u=/redirect-to-profile/' + fileListingWrapObj.owner.id;
		fileListingWrapObj.contentDocumentId=fileObj.ContentDocumentId;
		fileListingWrapObj.contentVersionId=fileObj.Id;
		fileListingWrapObj.description=fileObj.Description;
		fileListingWrapObj.relevancyScore=getFileScore(fileListingWrapObj.name, fileListingWrapObj.description, searchTokens);
		return fileListingWrapObj;
    }

	/**************************************************************************************************************
	**
	****************************************************************************************************************/
	@testvisible 
    private Integer getFileScore(String fileName, String description, Set<String> searchTokens) {
    	Integer score = 0;
    	
    	Integer FILE_NAME_WEIGHT_EXACT_MATCH=1000;
    	Integer FILE_NAME_WEIGHT_STARTS_WITH=2;
    	Integer FILE_NAME_WEIGHT_CONTAINS_IT=1;
    	
    	Integer FILE_NAME_MULTIPLICATION_FACTOR_EXACT_MATCH=4;
    	Integer FILE_NAME_MULTIPLICATION_FACTOR_STARTS_WITH=3;
    	Integer FILE_NAME_MULTIPLICATION_FACTOR_CONTAINS_IT=2; 
    	
    	Integer DESCRIPTION_WEIGHT_EXACT_MATCH=1;
    	Integer DESCRIPTION_WEIGHT_STARTS_WITH=1;
    	Integer DESCRIPTION_WEIGHT_CONTAINS_IT=1;
    	
    	Integer DESCRIPTION_MULTIPLICATION_FACTOR_EXACT_MATCH=3;
    	Integer DESCRIPTION_MULTIPLICATION_FACTOR_STARTS_WITH=2;
    	Integer DESCRIPTION_MULTIPLICATION_FACTOR_CONTAINS_IT=1; 
    	Integer numberOfUniqueTokensFound = 0;
    	for(String searchToken : searchTokens) {
    		Boolean found = false;
    		if(String.isNotBlank(fileName)){
	    		if(searchToken.equalsIgnoreCase(fileName)){
	    			score= score+(FILE_NAME_WEIGHT_EXACT_MATCH*FILE_NAME_MULTIPLICATION_FACTOR_EXACT_MATCH);
	    		} else if(fileName.startsWithIgnoreCase(searchToken)){
	    			score= score+(FILE_NAME_WEIGHT_STARTS_WITH*FILE_NAME_MULTIPLICATION_FACTOR_STARTS_WITH);
	    		} else if(fileName.containsIgnoreCase(searchToken)){
	    			score= score+(FILE_NAME_WEIGHT_CONTAINS_IT*FILE_NAME_MULTIPLICATION_FACTOR_CONTAINS_IT);
	    		}
	    		if(fileName.containsIgnoreCase(searchToken)) {
	    			found = true;
	    		}
    		}

    		if(String.isNotBlank(description)){    			
	    		if(searchToken.equalsIgnoreCase(description)){
	    			score= score+(DESCRIPTION_WEIGHT_EXACT_MATCH*DESCRIPTION_MULTIPLICATION_FACTOR_EXACT_MATCH);
	    		} else if(description.startsWithIgnoreCase(searchToken)){
	    			score= score+(DESCRIPTION_WEIGHT_STARTS_WITH*DESCRIPTION_MULTIPLICATION_FACTOR_STARTS_WITH);
	    		} else if(description.containsIgnoreCase(searchToken)){
	    			score= score+(DESCRIPTION_WEIGHT_CONTAINS_IT*DESCRIPTION_MULTIPLICATION_FACTOR_CONTAINS_IT);
	    		}
	    		if(description.containsIgnoreCase(searchToken)) {
	    			found = true;
	    		}
    		}
    		
    		if(found) {
            	numberOfUniqueTokensFound++;
            }
    	}
    	if(searchTokens.size() > 1 && numberOfUniqueTokensFound > 1) {
        	score = score + 2000 * numberOfUniqueTokensFound;
        }
    	return score;
    }
    
	/**************************************************************************************************************
	**
	****************************************************************************************************************/
    public String getFinalSearchString(String soslSearchText){
    	logger.logDebug('GlobalSearchService.getFinalSearchString()----soslSearchText----' + soslSearchText);
        Set<String> setOfSearchTokens=Utility.getSearchTokens(String.escapeSingleQuotes(soslSearchText));
        List<String> listOfSearchTokens= new List<String>(setOfSearchTokens);
        Boolean hasAndOr=false;
        for(String s: listOfSearchTokens){
            if('AND'.equalsIgnoreCase(s) || 'OR'.equalsIgnoreCase(s) ){
                hasAndOr=true;
                break;
            }
        }
        return hasAndOr? soslSearchText: String.join(listOfSearchTokens,' OR ');
    }
    
	/**************************************************************************************************************
	**
	****************************************************************************************************************/
    private Map<Id, Integer> getMapOfContentIdAndScoreWRTFileName (String term, String relatedSimpplrSite, String author, String type, DateTime publishStartDateTime, String topicId){
    	logger.logDebug('GlobalSearchService.getMapOfContentIdAndScoreWRTFileName()----term----' + term);
    	Map<Id, Integer> mapToBeReturned= new Map<Id, Integer>();
    	Set<String> searchTokens= Utility.getSearchTokens(String.escapeSingleQuotes(term));
    	List<File__c> listOfMatchedFiles= new List<File__c>();
    	Boolean addOrInQuery=false;
    	if(!searchTokens.isEmpty()){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', allowedFeaturesInAppList);
    		String query='SELECT ID,Name,Title__c, Content_name__c,Description__c,Simpplr_Content__c from File__c WHERE ';
    		String likeBasedSearchToken;
    		for(String searchToken: searchTokens){
    			likeBasedSearchToken= '\'%'+searchToken+'%\'';
    			if(addOrInQuery){
    				query=query+ ' OR ';
    			} else {
    				query=query+ ' ( ';
    			}
    			query=query+' Name LIKE '+likeBasedSearchToken+'  OR Title__c LIKE ' +likeBasedSearchToken+' OR Description__c LIKE '+likeBasedSearchToken;
    			addOrInQuery=true;
    		}
    		query+=') AND Simpplr_Content__c!=null AND Is_Deleted__c=false AND Location__c=\'attachment\' '; 
    		query += ' AND Simpplr_Content__r.TYPE__c IN : soqlParam1 ';
    		
    		if(String.isNotBlank(relatedSimpplrSite)) {
	            relatedSimpplrSite=String.escapeSingleQuotes(relatedSimpplrSite);
				soqlParamMap.put('soqlParam2', relatedSimpplrSite);
	            query+= ' And Simpplr_Content__r.site__c =:soqlParam2 ';
			}
			
			if(String.isNotBlank(author)) {
				soqlParamMap.put('soqlParam3', author);
				query += ' And Simpplr_Content__r.primary_author__c =:soqlParam3 ';
			}
	
			if(String.isNotBlank(type)) {
				soqlParamMap.put('soqlParam4', type);
				query += ' And Simpplr_Content__r.Content_Type__c =:soqlParam4 ';
			}
	
			if (publishStartDateTime != null) {
				soqlParamMap.put('soqlParam5', publishStartDateTime);
				query += ' And Simpplr_Content__r.Publish_Start_DateTime__c >=: soqlParam5 ';
	
			}

			if(String.isNotBlank(topicId)){
				query += 'And Simpplr_Content__c in (select EntityId from TopicAssignment where TopicId=: topicId ' +
								'And EntityType=\'Simpplr_Content\') ';
			}

    		logger.logDebug('GlobalSearchService.getMapOfContentIdAndScoreWRTFileName()----query----' + query);
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<File__c> listFiles = (List<File__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
    		listOfMatchedFiles.addAll(listFiles);
    	}
    	for(File__c fileObj: listOfMatchedFiles){
    		Integer score=getFileScore(fileObj,searchTokens);
    		Integer previousScoreIfExists=(mapToBeReturned.get(fileObj.Simpplr_Content__c)==null)?0:mapToBeReturned.get(fileObj.Simpplr_Content__c);
			score=score+previousScoreIfExists;
			mapToBeReturned.put(fileObj.Simpplr_Content__c, score);
    	}
    	logger.logDebug('GlobalSearchService.getMapOfContentIdAndScoreWRTFileName()----mapToBeReturned----' + mapToBeReturned);
    	return mapToBeReturned;
    	
    }
    
	/**************************************************************************************************************
	**
	****************************************************************************************************************/
    @TestVisible 
    private Integer getFileScore(File__c fileObj, Set<String> searchTokens){
    	logger.logDebug('GlobalSearchService.getFileScore()----fileObj----' + fileObj+'----searchTokens----'+searchTokens);
    	Integer score=0;
		
		Integer NAME_WEIGHT_EXACT_MATCH=1000;
    	Integer NAME_WEIGHT_STARTS_WITH=1;
    	Integer NAME_WEIGHT_CONTAINS_IT=1;
    	
    	Integer TITLE_WEIGHT_EXACT_MATCH=1000;
    	Integer TITLE_WEIGHT_STARTS_WITH=1;
    	Integer TITLE_WEIGHT_CONTAINS_IT=1;
    	
    	Integer DESCRIPTION_WEIGHT_EXACT_MATCH=1;
    	Integer DESCRIPTION_WEIGHT_STARTS_WITH=1;
    	Integer DESCRIPTION_WEIGHT_CONTAINS_IT=1;
    	
    	Integer MULTIPLICATION_FACTOR_EXACT_MATCH=3;
    	Integer MULTIPLICATION_FACTOR_STARTS_WITH=2;
    	Integer MULTIPLICATION_FACTOR_CONTAINS_IT=1;
    	
		for(String searchToken: searchTokens){
			if(String.isNotBlank(fileObj.Name)){
    			if(fileObj.Name.equalsIgnoreCase(searchToken)){
    				score= score+(NAME_WEIGHT_EXACT_MATCH*MULTIPLICATION_FACTOR_EXACT_MATCH);
    			} else if(fileObj.Name.startsWithIgnoreCase(searchToken)){
    				score= score+(NAME_WEIGHT_STARTS_WITH*MULTIPLICATION_FACTOR_STARTS_WITH);
    			} else if(fileObj.Name.containsIgnoreCase(searchToken)) {
    				score= score+(NAME_WEIGHT_CONTAINS_IT*MULTIPLICATION_FACTOR_CONTAINS_IT);
    			}
			}
			if(String.isNotBlank(fileObj.Title__c)){
    			if(fileObj.Title__c.equalsIgnoreCase(searchToken)){
    				score= score+(TITLE_WEIGHT_EXACT_MATCH*MULTIPLICATION_FACTOR_EXACT_MATCH);
    			} else if(fileObj.Title__c.startsWithIgnoreCase(searchToken)){
    				score= score+(TITLE_WEIGHT_STARTS_WITH*MULTIPLICATION_FACTOR_STARTS_WITH);
    			} else if(fileObj.Title__c.containsIgnoreCase(searchToken)) {
    				score= score+(TITLE_WEIGHT_CONTAINS_IT*MULTIPLICATION_FACTOR_CONTAINS_IT);
    			}
			}
			if(String.isNotBlank(fileObj.Description__c)){
    			if(fileObj.Description__c.equalsIgnoreCase(searchToken)){
    				score= score+(TITLE_WEIGHT_EXACT_MATCH*MULTIPLICATION_FACTOR_EXACT_MATCH);
    			} else if(fileObj.Description__c.startsWithIgnoreCase(searchToken)){
    				score= score+(TITLE_WEIGHT_STARTS_WITH*MULTIPLICATION_FACTOR_STARTS_WITH);
    			} else if(fileObj.Description__c.containsIgnoreCase(searchToken)) {
    				score= score+(TITLE_WEIGHT_CONTAINS_IT*MULTIPLICATION_FACTOR_CONTAINS_IT);
    			}
			}
			
		}
		logger.logDebug('GlobalSearchService.getFileScore()----score----' + score);
		return score;
    }
    
    /**************************************************************************************************************
	**
	****************************************************************************************************************/
    @TestVisible 
    private Integer getContentScore(Simpplr_Content__c cObj, Map<String,Integer> mapOfFieldsToSearch, Set<String> searchTokens){        
        Integer score=0;
        
        Integer CONTENT_TITLE_WEIGHT_EXACT_MATCH=1000;
        Integer CONTENT_TITLE_WEIGHT_CONTAINS_IT=(mapOfFieldsToSearch.get('Title__c')==null)?1:mapOfFieldsToSearch.get('Title__c');
        Integer CONTENT_SUMMARY_WEIGHT_CONTAINS_IT=(mapOfFieldsToSearch.get('Display_Excerpt__c')==null)?1:mapOfFieldsToSearch.get('Display_Excerpt__c');

        Integer SUMMARY_WEIGHT=(mapOfFieldsToSearch.get('Display_Excerpt__c')==null)?0:mapOfFieldsToSearch.get('Display_Excerpt__c');
        
        Integer CONTENT_MULTIPLICATION_FACTOR_EXACT_MATCH=4;
        Integer CONTENT_MULTIPLICATION_FACTOR_STARTS_WITH=3;
        Integer CONTENT_MULTIPLICATION_FACTOR_CONTAINS_IT=2;
       
        //check occurenece in title
        
        String title=String.escapeSingleQuotes(cObj.title__c.remove('"'));
        String summary= String.isBlank(cObj.Display_Excerpt__c)?'':String.escapeSingleQuotes(cObj.Display_Excerpt__c.remove('"'));
        Integer numberOfUniqueTokensFound = 0;
        for(String s: searchTokens){
            //check occurenece in Title
            if(title.containsIgnoreCase(s)){
            	if(title.equalsIgnoreCase(s)){
            		score=CONTENT_TITLE_WEIGHT_EXACT_MATCH*CONTENT_MULTIPLICATION_FACTOR_EXACT_MATCH;
            	} else {
	                s = s.replaceAll('\\(', '\\\\(').replaceAll('\\)', '\\\\)');
            		
            		List<String> occurenceArray=title.split('(?i)' + s);
	                Integer occurence=occurenceArray.size() - 1;
	                occurence = occurence <=0 ? 1 : occurence;
	                
	                if('Event'.equalsIgnoreCase(cObj.type__c) && currentTime > cObj.Event_End_DateTime__c) {
	                	score = score + 1;  
	                } else {
	                	score = score+CONTENT_TITLE_WEIGHT_CONTAINS_IT * CONTENT_MULTIPLICATION_FACTOR_CONTAINS_IT * (occurence);
	                }
	                
            	}
            }
            if(summary.containsIgnoreCase(s)){
                s = s.replaceAll('\\(', '\\\\(').replaceAll('\\)', '\\\\)');
            	
            	List<String> occurenceArray=summary.split('(?i)' + s);
                Integer occurence=occurenceArray.size() - 1;
                occurence = occurence <=0 ? 1 : occurence;
                if('Event'.equalsIgnoreCase(cObj.type__c) && currentTime > cObj.Event_End_DateTime__c) {
                	score = score + 1;
                } else {
                	score=score+CONTENT_SUMMARY_WEIGHT_CONTAINS_IT*(occurence);  //initial score+ columnWeight*(number of occurences of searchItem)
                }
            }
            
            if(title.containsIgnoreCase(s) || summary.containsIgnoreCase(s)) {
            	numberOfUniqueTokensFound++;
            }
        }
        if(searchTokens.size() > 1 && numberOfUniqueTokensFound > 1) {
        	score = score + 2000 * numberOfUniqueTokensFound;
        }
        return score;
    }
    
    /**************************************************************************************************************
	**
	****************************************************************************************************************/
    @TestVisible 
    private Set<String> getStringFromCommaSeprated(String s)
    {
        Set<String> processedSet=new Set<String>(); 
        if(s!=null && s.length()>0)
        {
            processedSet.addAll(s.split(','));
        }
        return processedSet;
    }
    
    /**************************************************************************************************************
	**
	****************************************************************************************************************/
    @testVisible
    private List<Id> getContentDocumentIdsForSite(String siteId) {
    	//TODO - file uploaded to contents do not show up in AttachedContentDocument
		List<Id> listOfIds = new List<Id>();
		Simpplr_Site__c siteObj = Utility.getAllSimpplrSiteMap().get(siteId);
		if(siteObj != null) {
			String groupId = siteObj.Chatter_Group_Id__c;
			List<CollaborationGroup> listOfCollaborationGroup=new List<CollaborationGroup>();
			String BASE_QUERY= 'Select Id'+
					', (Select ContentDocumentId, Title From AttachedContentDocuments where IsDeleted = false) ';
			String BASE_FROM_WHERE = 'From CollaborationGroup where Id = :groupId ';
			if(SimpplrContext.isCommunitiesEnabled){
	    		BASE_FROM_WHERE = BASE_FROM_WHERE+'AND NetworkId = null';
	    	}
			String queryStr=BASE_QUERY+BASE_FROM_WHERE;
			listOfCollaborationGroup= Database.query(queryStr);
			for(CollaborationGroup collaborationGroupObj : listOfCollaborationGroup){
				for(AttachedContentDocument attachedContentDocumentObj : collaborationGroupObj.AttachedContentDocuments) {
					listOfIds.add(attachedContentDocumentObj.ContentDocumentId);  
				}
			}
		}
		return listOfIds;
	}
	
	/**************************************************************************************************************
	****************************************************************************************************************/
	
    private map<Id,Simpplr_Content__c> getAllContentsForTextSearch(String relatedSimpplrSite, Set<Id> setOfMatchedContentIds, Set<String> searchTokens, String author, String type, DateTime publishStartDateTime, String topicId) {
        logger.logDebug('GlobalSearchService.getAllContentsForTextSearch()----contentType--------relatedSimpplrSite----'+relatedSimpplrSite+'----setOfMatchedContentIds----'+setOfMatchedContentIds);
        List<String> allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).replace('Blog', 'BlogPost').split(','); 
        Set<String> setOfChatterGroupIdsNotFollowed= Utility.getSetOfPrivateChatterGroupIdsNotFollowedByCurrentUser();
        String mustReadSubCondition = '';
		Set<Id> sitesIFollowIdSet = UserContext.sitesIFollowIdSet;
		if (UserContext.isUserAppModerator == false) {
			mustReadSubCondition = ' And (Audience_Type__c=\'everyone\' OR Content__r.Site__c=:sitesIFollowIdSet) ';
		}
		DateTime currentDateTime = DateTime.now();
        String query = 'SELECT ID,Type__c,Display_Excerpt__c,Summary__c,Event_RSVP_Note__c, Is_Deleted__c, Activated_By_Feature__c,Status__c,Publish_End_DateTime__c, First_Publish_DateTime__c, Event_RSVP_Limit__c,Event_RSVP_By_DateTime__c,Event_RSVP_Allowed__c,Event_RSVP_Show_Maybe__c,Title__c,Event_Is_All_Day__c,Event_Start_DateTime__c ,Event_End_DateTime__c,Event_TimezoneSidKey__c ,Site__c,Pages_Category__c,Pages_Category__r.Name__c,CreatedDate,Primary_Author__c,' 
        + ' Primary_Author__r.Full_Name__c,Primary_Author__r.User__r.SmallPhotoURL, Site__r.Name, Site__r.Show_In_Simpplr__c, Site__r.Chatter_Group_Id__c, Site__r.Site_Type__c, Is_Must_Read__c , Site__r.is_Active__c,Event_Attending_Count__c,'
        + ' Simpplr_Content__c.Album_Image_Count__c,Simpplr_Content__c.Album_Video_Count__c, Last_Edited_DateTime__c,Site__r.Landing_Page__c,Site__r.Title_Content_Document__c, Site__r.Title_Content_Version__c, Publish_Start_DateTime__c, '
        + ' (Select Id,Rsvp_Response__c,RSVP_Response_Text__c from Event_RSVP_Responses__r where is_deleted__c = false And People__c=:loggedInPeopleId),'
        + ' (Select Thumbnail_URL__c, Content_Version__c, MIME_Type__c, Is_Title_Image__c,Title_Image_Type__c,Content_Document__c from File_Simpplr_Content__r where  '
        + '  Is_Deleted__c = false AND (Title_Image_Type__c =\'Thumbnail\' or Title_Image_Type__c =\'None\') And Is_Title_Image__c = true),'
        + '(Select Id from Must_Read_Confirm_History__r Where People__c =:loggedInPeopleId), '
		+ '(select id from Content_Interactions__r where People__c =: loggedInPeopleId ), ' 
		+ ' (select Must_Read_Confirm_Count__c, Audience_Type__c from Must_Read_Audits__r where Removed_DateTime__c = null  AND (Expiry_DateTime__c = null OR Expiry_DateTime__c >: currentDateTime) ' +  mustReadSubCondition + ' order by createddate desc limit 1)'
        + ' FROM Simpplr_Content__c WHERE Activated_By_Feature__c = true '
        + ' AND TYPE__c IN : allowedFeaturesInAppList '
        + ' AND Is_Deleted__c=false AND Is_Published__c=true AND (Id in : setOfMatchedContentIds ';
		
		//SOSL doesn't give result from within words, lets search for partial word as well
		for(String searchToken: searchTokens){
			query += ' OR Title__c LIKE \'%' + searchToken + '%\'  OR Display_Excerpt__c LIKE \'%' + searchToken + '%\'';
		}
    		query += ') ';
		query += ' And ((Site__c = null) OR (Site__r.is_Deleted__c = false AND Site__r.is_Active__c = true AND Site__r.Show_In_Simpplr__c = true AND Site__r.Chatter_Group_Id__c not in :setOfChatterGroupIdsNotFollowed '; 

        query+= ' )) ';
		query += getContentFilterCondition(relatedSimpplrSite, author, type, publishStartDateTime);
		query += getTopicCondition(topicId);

		
        logger.logDebug('GlobalSearchService.getAllContentsForTextSearch()----query----' + query);
        Map<Id, Simpplr_Content__c> mapSite = new map<Id,Simpplr_Content__c>((List<Simpplr_Content__c>) Database.query(query + ' LIMIT 2000'));
        return mapSite;
    }
   
    //ONLY FOR SITES
    Map<String,Map<String,String>> grpIdWithMapOfMemberIdWithRole;
    
    public List<AutoCompleteWrapper> searchAutoComplete(String term,Boolean applyUserContext,Integer size) {
    	//term = '%'+term+'%';
    	this.applyUserContext = applyUserContext;
    	
    	Set<String> allgroupsIFollow;
    	Boolean hasModifyAllDataPermission = UserContext.hasModifyAllDataPermission;
    	String currentUserId = UserContext.id;
    	
    	String siteQuery = 'SELECT Id, Title_Content_Version__c, Title_Content_Document__c, Name,Landing_Page__c,Site_Type__c,'+
							'chatter_group_id__c,Is_Featured__c'+
							' FROM Simpplr_Site__c'+
							' WHERE Is_Active__c = true'+
							' AND Show_In_Simpplr__c = true';
							
		String peopleQuery = 'SELECT Id,Full_Name__c,user__c,User__r.SmallPhotoUrl'+ 
							 ' FROM People__c'+
							 ' WHERE Is_Deleted__c = false '+
							 ' And User__r.isActive=true ' + 
							 ' And ((User__r.UserType=\'Standard\' And User__r.Show_Simpplr__c != \'No\') Or User__r.Show_Simpplr__c = \'Yes\') ';
							 
    	List<String> allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).replace('Blog', 'BlogPost').split(',');
    	String contentQuery = 'SELECT Id, Title__c,Publish_Start_DateTime__c,Event_Start_DateTime__c,Event_TimezoneSidKey__c,primary_author__r.user__c,site__r.chatter_group_id__c,'+
    							'Type__c,Primary_Author__c,Site__c,(SELECT Id, Content_Version__c, Content_Document__c, Thumbnail_URL__c'+
							    ' FROM File_Simpplr_Content__r WHERE Is_Title_Image__c = true And Is_Deleted__c = false)'+
    							' FROM Simpplr_Content__c'+ 
			    				' WHERE Is_Deleted__c = false AND Is_Published__c = true'+
			    				' AND Type__c=:allowedFeaturesInAppList And Activated_by_feature__c=true'+
			    				' AND ((Site__r.Is_Active__c = true And Site__r.Show_In_Simpplr__c = true) or type__c = \'BlogPost\')';
			    				
    	String grpQuery = 'select collaborationgroupid,memberid,CollaborationRole from CollaborationGroupMember where CollaborationGroup.IsArchived=false AND MemberId =:currentUserId ';
    	
    	List<String> setOfTerms =  (String.escapeSingleQuotes(term).replaceAll('[-"!]', ' ').replaceAll('\\s+', ' ')).toLowerCase().split(' ');
    	this.setOfTerms = setOfTerms;
    	for(String searchToken: setOfTerms){
    		String searchVal='\'%'+searchToken+'%\'';
    		siteQuery += ' AND Name like '+searchVal;
    		peopleQuery += ' AND Full_Name__c like '+searchVal;
    		contentQuery += ' AND Title__c like '+searchVal;
    		grpQuery += ' AND CollaborationGroup.NAME like '+searchVal;
    	}
		//  all public sites and private/unlisted sites only if they are member
		grpIdWithMapOfMemberIdWithRole = new Map<String,Map<String,String>>();
		
		allgroupsIFollow = new Set<String>();
		for(CollaborationGroupMember cgm : (List<CollaborationGroupMember>)Database.query(grpQuery)){
			if(grpIdWithMapOfMemberIdWithRole.containsKey(cgm.collaborationgroupid) == false){
				grpIdWithMapOfMemberIdWithRole.put(cgm.collaborationgroupid,new Map<String,String>());
			}
			grpIdWithMapOfMemberIdWithRole.get(cgm.collaborationgroupid).put(cgm.memberid,cgm.CollaborationRole);
		}

    	// if user has no modify all data permission then fetch private sites only if they are member
    	if(!hasModifyAllDataPermission){
    		allgroupsIFollow.addAll(grpIdWithMapOfMemberIdWithRole.keySet());
    		siteQuery += ' AND (Chatter_Group_Id__c IN :allgroupsIFollow OR Site_Type__c=\'Public\')';
    	}
    	
    	String recordlimit = '';
    	//limiting records as per no. of characters typed
    	if(term.length() == 1){
    		recordlimit = ' limit 50';
    	} else if(term.length() == 2){
    		recordlimit = ' limit 200';
    	}else if(term.length() == 3){
    		recordlimit = ' limit 500';
    	} else{
    		recordlimit = ' limit 1000';
    	}
    	siteQuery += recordlimit;
    	peopleQuery += recordlimit;
    	contentQuery += recordlimit;

    	List<AutoCompleteWrapper> listOfAllObjects = new List<AutoCompleteWrapper>();
    	
    	listOfAllObjects.addAll(convertToAutoCompleteWrapperForSite((List<Simpplr_Site__c>)Database.query(siteQuery)));
    	listOfAllObjects.addAll(convertToAutoCompleteWrapperForPeople((List<People__c>)Database.query(peopleQuery)));
    	listOfAllObjects.addAll(convertToAutoCompleteWrapperForContent((List<Simpplr_content__c>)Database.query(contentQuery)));

    	//sorting on the basis of score
    	if(listOfAllObjects.size()>0){
    		listOfAllObjects.sort();
    	}
		
		//returning final 32 records to UI
		Integer maxSize = size !=null ? size:32;
		if(listOfAllObjects.size()>maxSize){
			Integer counter = 0; 
			List<AutoCompleteWrapper> listToReturn = new List<AutoCompleteWrapper>();
			
			while(counter<maxSize && counter < listOfAllObjects.size()) { 
				listToReturn.add(listOfAllObjects[counter++]); 
			}
			return listToReturn;
		}else{
			return listOfAllObjects;
		}
    	
    }
    
    private List<AutoCompleteWrapper> convertToAutoCompleteWrapperForSite (List<Simpplr_Site__c> siteList) {
    	List<AutoCompleteWrapper> listToReturn = new List<AutoCompleteWrapper>();
    	String currentUserId = UserContext.id;
    	for(Simpplr_Site__c siteObj : siteList){
    		AutoCompleteWrapper autoCompleteWrapObj = new AutoCompleteWrapper();
    		autoCompleteWrapObj.baseScore = 2;
    		autoCompleteWrapObj.score = getAutoCompleteScore(autoCompleteWrapObj.baseScore, siteObj.Name.toLowerCase());
    		
    		if(applyUserContext){
    			// If it's a site I follow - +1
    			if(grpIdWithMapOfMemberIdWithRole.containsKey(siteObj.chatter_group_id__c) && grpIdWithMapOfMemberIdWithRole.get(siteObj.chatter_group_id__c).containsKey(currentUserId)){
    				autoCompleteWrapObj.score += 2;
    				//If it's a site I manage/own
    				if('Admin'.equalsIgnorecase(grpIdWithMapOfMemberIdWithRole.get(siteObj.chatter_group_id__c).get(currentUserId))){
    					autoCompleteWrapObj.score += 2;
    				}
    			}
    			
    			//If site is either mandatory or featured
    			if(siteObj.Is_Featured__c){
    				autoCompleteWrapObj.score += 2;
    			}
    		}
    		
    		autoCompleteWrapObj.id = siteObj.id;
	    	autoCompleteWrapObj.name = siteObj.Name;
	    	autoCompleteWrapObj.access = siteObj.Site_Type__c;
	    	
	    	if(String.isNotBlank(siteObj.Title_Content_Version__c)) {
		    	autoCompleteWrapObj.img = Utility.getFileDownloadURLFor240BY180(siteObj.Title_Content_Version__c);
		    	autoCompleteWrapObj.imgTHUMB240BY180URL = Utility.getFileDownload240BY180URLForMobile(siteObj.Title_Content_Document__c);
	    	}	
    		autoCompleteWrapObj.type = 'site';
	    	autoCompleteWrapObj.resourceType = 'site';
	    	autoCompleteWrapObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteObj.id + '/' + siteObj.Landing_Page__c;
    		listToReturn.add(autoCompleteWrapObj);
    	}
    	
    	return listToReturn;
    }
    
    private Integer getAutoCompleteScore(Integer baseScore, String value) {
    		Integer finalScore = baseScore;
    		List<String> listOfWords = value.split(' ');
    		Integer position;
    		for(String searchTerm : setOfTerms) {
    			if(listOfWords.contains(searchTerm)){
	    			finalScore += 3;
    			} else {
    				position = value.indexOf(searchTerm);
    				if(position == 0) {
    					finalScore += 2;
    					
    				} else if(position > -1) {
		    			finalScore += 1;
		    			if(value.indexOf(' ' + searchTerm) > -1) {
	    					finalScore += 1;
		    			}
    				}
    			}
    		}
    		return finalScore;
    }
    
    private List<AutoCompleteWrapper> convertToAutoCompleteWrapperForContent(List<Simpplr_Content__c> contentList){
    	List<AutoCompleteWrapper> listToReturn = new List<AutoCompleteWrapper>();
    	for(Simpplr_Content__c contentObj : contentList) {
    		AutoCompleteWrapper autoCompleteWrapObj = new AutoCompleteWrapper();
    		autoCompleteWrapObj.baseScore = 3;
    		autoCompleteWrapObj.score = getAutoCompleteScore(autoCompleteWrapObj.baseScore, contentObj.title__c.toLowerCase());
    		autoCompleteWrapObj.id = contentObj.id;
    		autoCompleteWrapObj.name = contentObj.Title__c;
    		autoCompleteWrapObj.title = contentObj.Title__c;
    		autoCompleteWrapObj.siteId = contentObj.Site__c;
    		autoCompleteWrapObj.publishStartDateTimeInLong = contentObj.Publish_Start_DateTime__c.getTime();
    		
    		if (!contentObj.File_Simpplr_Content__r.isEmpty()) {
	    		if (contentObj.Type__c == 'album') {
	    			if(String.isNotBlank(contentObj.File_Simpplr_Content__r[0].Content_Version__c)) {
	    				autoCompleteWrapObj.img = Utility.getFileDownloadURLFor240BY180(contentObj.File_Simpplr_Content__r[0].Content_Version__c);
	    				autoCompleteWrapObj.imgTHUMB240BY180URL = Utility.getFileDownload240BY180URLForMobile(contentObj.File_Simpplr_Content__r[0].Content_Document__c);
	    			} else {
	    				autoCompleteWrapObj.img = contentObj.File_Simpplr_Content__r[0].Thumbnail_URL__c;
	    			}
	    		
	    		} else {
	    			autoCompleteWrapObj.img = Utility.getFileDownloadURLFor240BY180(contentObj.File_Simpplr_Content__r[0].Content_Version__c);
	    			autoCompleteWrapObj.imgTHUMB240BY180URL = SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL + contentObj.File_Simpplr_Content__r[0].Content_Document__c + '/rendition?type=THUMB240BY180';
	    		}
	    	} else {
	    		autoCompleteWrapObj.img = null;
	    	}
	    	
	    	autoCompleteWrapObj.type = contentObj.Type__c;
	    	autoCompleteWrapObj.resourceType = 'content';
	    	
	    	if(ServiceConstants.TYPE_PAGE.equalsIgnoreCase(contentObj.Type__c)) {
	    		autoCompleteWrapObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentObj.site__c+'/page/' + contentObj.Id;
	    		
        } else if(ServiceConstants.TYPE_EVENT.equalsIgnoreCase(contentObj.Type__c)){
            autoCompleteWrapObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentObj.site__c+'/event/' + contentObj.Id;
			
			TimeZone tz = Timezone.getTimeZone(contentObj.Event_TimezoneSidKey__c);
			autoCompleteWrapObj.timezoneName = Utility.timezoneIdToDisplayLabel(contentObj.Event_TimezoneSidKey__c);
			autoCompleteWrapObj.timezoneIso = tz.getID();
			autoCompleteWrapObj.timezoneOffset = tz.getOffset(system.today());

	        String dateStringValue = String.valueOf(contentObj.Event_Start_DateTime__c);
	        if(String.isNotBlank(dateStringValue)){
	    	    		autoCompleteWrapObj.startsAt = contentObj.Event_Start_DateTime__c.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
	        }                                         
        
        } else if(ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(contentObj.Type__c)){
            autoCompleteWrapObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentObj.site__c+'/album/' + contentObj.Id;  
                                                   
        } else if(ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(contentObj.Type__c)){
            autoCompleteWrapObj.url = PageContext.getPageURL(Pages.app)+'?u=/people/'+contentObj.Primary_Author__c+'/blog/' + contentObj.Id;                                         
            
        }
    		listToReturn.add(autoCompleteWrapObj);
    	}
    	return listToReturn;
    }
    
    private List<AutoCompleteWrapper> convertToAutoCompleteWrapperForPeople(List<People__c> peopleList){
    	List<AutoCompleteWrapper> listToReturn = new List<AutoCompleteWrapper>();
    	Set<String> peopleIFollow;
    	String currentUserId = UserContext.id;
    	if(applyUserContext){
    		peopleIFollow = new Set<String>();
    		
    		for(EntitySubscription es : [SELECT ParentId, Parent.Name FROM EntitySubscription WHERE SubscriberId = :currentUserId AND Parent.type = 'User' limit 1000]){
    			peopleIFollow.add(es.ParentId);
    		}
    	}
    	
    	for(People__c peopleObj : peopleList){
    		AutoCompleteWrapper autoCompleteWrapObj = new AutoCompleteWrapper();
    		autoCompleteWrapObj.baseScore = 4;
    		autoCompleteWrapObj.score = getAutoCompleteScore(autoCompleteWrapObj.baseScore, peopleObj.Full_Name__c.toLowerCase());
    		
    		if(applyUserContext){
    			// If it's a person I follow - +1
    			if(peopleIFollow.contains(peopleObj.user__c)){
    				autoCompleteWrapObj.score += 2;
    			}
    		}
    		
    		autoCompleteWrapObj.id = peopleObj.id;
	    	autoCompleteWrapObj.name = peopleObj.Full_Name__c;
	    	autoCompleteWrapObj.img = peopleObj.User__r.SmallPhotoUrl.endsWith('005/T') ? null : peopleObj.User__r.SmallPhotoUrl;
    		autoCompleteWrapObj.type = 'person';
	    	autoCompleteWrapObj.resourceType = 'person';
	        autoCompleteWrapObj.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleObj.id;
    		listToReturn.add(autoCompleteWrapObj);
    	}
    	return listToReturn;
    	
    }
    
    private Set<String> getPickListKeyFromSearchTokens(Set<String> searchTokens, List<Schema.PicklistEntry> picklistEntryList){
    	Set<String> picklistLabelSet = new Set<String>();
    	for(String searchString : searchTokens){
    		for(PicklistEntry picklistEntryString : picklistEntryList){
    			if(picklistEntryString.getLabel().containsIgnoreCase(searchString)){
    				picklistLabelSet.add(picklistEntryString.getValue());		
    			}
    		}
    	}
    	return picklistLabelSet; 	
    }
    
    public GlobalSearchWrapper convertToGlobalSearchWrapper (List<FileListingWrapper> results,
    		Criteria.File fileSearchCriteria) {
    	List<GlobalSearchWrapper.ItemWrapper> resultObjList = new List<GlobalSearchWrapper.ItemWrapper>();
	    GlobalSearchWrapper gsrwObj = new GlobalSearchWrapper();
	    		
		for (FileListingWrapper flw : results) {
			GlobalSearchWrapper.ItemWrapper itemWrapObj = new GlobalSearchWrapper.ItemWrapper();
			itemWrapObj.item = flw;
			itemWrapObj.itemType = 'file';
			itemWrapObj.relevancyScore = flw.relevancyScore;
			resultObjList.add(itemWrapObj);
		}
		
    	
    	if(!resultObjList.isEmpty()){
			gsrwObj.listOfItems = resultObjList;
			if(ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING.equalsIgnoreCase(fileSearchCriteria.provider) || 
				ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(fileSearchCriteria.provider) ||
				ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING.equalsIgnoreCase(fileSearchCriteria.provider)) {					
				gsrwObj.totalRecords = GlobalSearchService.totalMSResults; 

			} else {
				gsrwObj.totalRecords = GlobalSearchService.totalResults;
			}

			
			if(GlobalSearchService.nextPageToken != null) {
				gsrwObj.nextPageToken = GlobalSearchService.nextPageToken;

	        } else if (gsrwObj.listOfItems.size() == (fileSearchCriteria.Size + 1) && fileSearchCriteria.offset < 2000) {
	        	gsrwObj.listOfItems.remove((gsrwObj.listOfItems.size()-1));
	        	gsrwObj.nextPageToken = String.valueOf(fileSearchCriteria.offset + fileSearchCriteria.Size);
	        } else {
	        	gsrwObj.nextPageToken = null;
	        }
    	}
    	return gsrwObj;
	}
	
	private Set<String> getInaccessibleCGIdsListString(String userId) {
		Set<String> nonPublicCGIdList = new Set<String>();

		List<Simpplr_Site__c> nonPublicSites = [SELECT Id, Chatter_Group_Id__c FROM Simpplr_Site__c WHERE Site_Type__c != 'Public' AND Is_Active__c = true WITH SECURITY_ENFORCED];
		
		for(Simpplr_Site__c siteObj : nonPublicSites) {
			nonPublicCGIdList.add(siteObj.Chatter_Group_Id__c);
		}

		List<CollaborationGroupMember> cGMList = [SELECT Id, CollaborationGroupId FROM CollaborationGroupMember 
													WHERE Member.IsActive=true AND MemberId = :userId AND CollaborationGroupId = :nonPublicCGIdList AND CollaborationGroup.isArchived=false WITH SECURITY_ENFORCED];

		for(CollaborationGroupMember cGMObj : cGMList) {
			nonPublicCGIdList.remove(cGMObj.CollaborationGroupId);
		}

		return nonPublicCGIdList;
	}

}