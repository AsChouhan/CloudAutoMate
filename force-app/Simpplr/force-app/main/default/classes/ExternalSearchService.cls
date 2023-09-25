public with sharing class ExternalSearchService {
	
	
	public static Integer totalResults;
	public String searchTerm;
	public String siteId;
	public static String nextPageToken;
	ExternalSearchWrapper.TopContentsWrapper resultWrapper; 
	
	public ExternalSearchWrapper.TopContentsWrapper searchTopResuls(Criteria.ExternalSearchReq contentCriteria, 
            String searchForType){
		List<ExternalSearchWrapper.AIResponse> topResultsWrapperList = new List<ExternalSearchWrapper.AIResponse>();
        Integer offset = 0; 

        if (contentCriteria.nextPageToken != null) {
           offset =  Integer.valueOf(contentCriteria.nextPageToken);
        }
		
        String searchResultJSON = getExternalSearchResults(contentCriteria.term, offset, searchForType, 
                contentCriteria.isCorrectionEnabled, contentCriteria.siteId, contentCriteria);
		logger.logDebug('ExternalSearchService.searchTopResuls()----searchResultJSON----' + searchResultJSON);
		ExternalSearchWrapper.AIResponse responseWrapperAI = (ExternalSearchWrapper.AIResponse)JSON.deserialize(searchResultJSON, ExternalSearchWrapper.AIResponse.class);
		resultWrapper = convertToWrapper(responseWrapperAI, searchForType, searchTerm);
		
		if (String.isNotBlank(responseWrapperAI.did_you_mean_term)) {
			resultWrapper.term = searchTerm;
		}

		resultWrapper.nextPageToken = ((responseWrapperAI.hits.start+Integer.valueOf(contentCriteria.size))<(responseWrapperAI.hits.total.value)) ? String.valueOf(responseWrapperAI.hits.start+Integer.valueOf(contentCriteria.size)):null;
		return resultWrapper;
		
	}	
	
	public ExternalSearchWrapper.TopContentsWrapper searchTopic(ManageContentRequestWrapper requestObj) {
		Criteria.ExternalSearchReq topicCriteriaObj = new Criteria.ExternalSearchReq();
		topicCriteriaObj.term = requestObj.term;
		topicCriteriaObj.nextPageToken = requestObj.nextPageToken;
		topicCriteriaObj.sortBy = requestObj.sortBy;
		searchTerm = String.isBlank(topicCriteriaObj.term) ? '' : topicCriteriaObj.term;
		if(requestObj.size == null ) {
        	requestObj.size=16;
        }
		
		ExternalSearchWrapper.TopContentsWrapper resultWrapper = new ExternalSearchWrapper.TopContentsWrapper();		
        Integer offset = 0; 

        if (topicCriteriaObj.nextPageToken != null) {
            offset = Integer.valueOf(topicCriteriaObj.nextPageToken);
		}

		String searchForType = 'Topic';
		if(String.isBlank(requestObj.sortBy)){
			topicCriteriaObj.sortBy = 'alphabetical';
		}
		String searchResultJSON = getExternalSearchResults(topicCriteriaObj.term, offset, searchForType, 
			topicCriteriaObj.isCorrectionEnabled, topicCriteriaObj.siteId, 
			topicCriteriaObj);

		ExternalSearchWrapper.AIResponse responseWrapperAI = (ExternalSearchWrapper.AIResponse)JSON.deserialize(searchResultJSON, ExternalSearchWrapper.AIResponse.class);
		resultWrapper = convertTopicResponseToWrapper(responseWrapperAI, searchTerm);
		resultWrapper.nextPageToken = ((responseWrapperAI.hits.start+Integer.valueOf(requestObj.size))<(responseWrapperAI.hits.total.value)) ? String.valueOf(responseWrapperAI.hits.start+Integer.valueOf(requestObj.size)):null;
		return resultWrapper;
	}

	private ExternalSearchWrapper.TopContentsWrapper convertTopicResponseToWrapper(ExternalSearchWrapper.AIResponse responseWrapperAI, String searchTerm) {		
		ExternalSearchWrapper.TopContentsWrapper wrapperObj = new ExternalSearchWrapper.TopContentsWrapper();
		List<ExternalSearchWrapper.ItemWrapper> listOfItems = new List<ExternalSearchWrapper.ItemWrapper>();
		
		logger.logDebug('ExternalSearchService.convertTopicResponseToWrapper()----responseWrapperAI----' + responseWrapperAI);

		if('success'.equalsIgnoreCase(responseWrapperAI.status) == false) { 
			throw new SimpplrException(responseWrapperAI.message);
		}

		for(ExternalSearchWrapper.SearchDataWrapper rec : responseWrapperAI.hits.hit) {
			listOfItems.add(convertToTopicItemWrapper(rec, searchTerm));
		}

		wrapperObj.listOfItems = listOfItems;

		return wrapperObj;
	}

	private ExternalSearchWrapper.ItemWrapper convertToTopicItemWrapper(ExternalSearchWrapper.SearchDataWrapper rec, String searchTerm) {
		ExternalSearchWrapper.ItemWrapper itemWrapperObj = new ExternalSearchWrapper.ItemWrapper();
		ExternalSearchWrapper.TopicWrapper topicWrapperItem = new ExternalSearchWrapper.TopicWrapper();
		topicWrapperItem.id = rec.Id;
		topicWrapperItem.name = rec.topic_name;

		itemWrapperObj.item = topicWrapperItem;
		return itemWrapperObj;
	}

	public ExternalSearchWrapper.TopContentsWrapper searchExpertise(ManageContentRequestWrapper requestObj) {
		Criteria.ExternalSearchReq expertiseCriteriaObj = new Criteria.ExternalSearchReq();
		expertiseCriteriaObj.term = requestObj.term;
		expertiseCriteriaObj.nextPageToken = requestObj.nextPageToken;
		expertiseCriteriaObj.order = requestObj.order;
		

		ExternalSearchWrapper.TopContentsWrapper resultWrapper = new ExternalSearchWrapper.TopContentsWrapper();		
        Integer offset = 0; 

        if (expertiseCriteriaObj.nextPageToken != null) {
            offset = Integer.valueOf(expertiseCriteriaObj.nextPageToken);
		}

		String searchForType = 'Expertise';
		if(String.isBlank(requestObj.order)){
			expertiseCriteriaObj.order = 'desc';
		}
        
		String searchResultJSON = getExternalSearchResults(expertiseCriteriaObj.term, offset, searchForType, 
			expertiseCriteriaObj.isCorrectionEnabled, expertiseCriteriaObj.siteId, 
			expertiseCriteriaObj);

		ExternalSearchWrapper.AIResponse responseWrapperAI = (ExternalSearchWrapper.AIResponse)JSON.deserialize(searchResultJSON, ExternalSearchWrapper.AIResponse.class);
		
		resultWrapper = convertExpertiseResponseToWrapper(responseWrapperAI, searchTerm);
		resultWrapper.nextPageToken = ((responseWrapperAI.hits.start+Integer.valueOf(requestObj.size))<(responseWrapperAI.hits.total.value)) ? String.valueOf(responseWrapperAI.hits.start+Integer.valueOf(requestObj.size)):null;
		return resultWrapper;
	}

	private ExternalSearchWrapper.TopContentsWrapper convertExpertiseResponseToWrapper(ExternalSearchWrapper.AIResponse responseWrapperAI, String searchTerm) {		
		ExternalSearchWrapper.TopContentsWrapper wrapperObj = new ExternalSearchWrapper.TopContentsWrapper();
		List<ExternalSearchWrapper.ItemWrapper> listOfItems = new List<ExternalSearchWrapper.ItemWrapper>();

		logger.logDebug('ExternalSearchService.convertExpertiseResponseToWrapper()----responseWrapperAI----' + responseWrapperAI);

		if('success'.equalsIgnoreCase(responseWrapperAI.status) == false) { 
			throw new SimpplrException(responseWrapperAI.message);
		}

		for(ExternalSearchWrapper.SearchDataWrapper rec : responseWrapperAI.hits.hit) {
			listOfItems.add(convertToExpertiseItemWrapper(rec, searchTerm));
		}

		wrapperObj.listOfItems = listOfItems;

		return wrapperObj;
	}

	private ExternalSearchWrapper.ItemWrapper convertToExpertiseItemWrapper(ExternalSearchWrapper.SearchDataWrapper rec, String searchTerm) {
		ExternalSearchWrapper.ItemWrapper itemWrapperObj = new ExternalSearchWrapper.ItemWrapper();
		ExternalSearchWrapper.ExpertiseWrapper expertiseWrapperItem = new ExternalSearchWrapper.ExpertiseWrapper();
		expertiseWrapperItem.id = rec.Id;
		expertiseWrapperItem.name = rec.expertise_name;
		expertiseWrapperItem.count = rec.expertise_user_count;

		itemWrapperObj.item = expertiseWrapperItem;

		return itemWrapperObj;
	}

	public List<String> searchAlert(Criteria.ExternalSearchReq alertCriteriaObj) {
		
		ExternalSearchWrapper.TopContentsWrapper resultWrapper = new ExternalSearchWrapper.TopContentsWrapper();		
        Integer offset = 0; 
		String orderBy = '';		
		String order = '';
		String sortBy = alertCriteriaObj.sortBy;
		if (!String.isblank(sortBy)){
			if(sortBy.equalsIgnoreCase('createdNewest')){
				orderBy = 'created_date_newest';
				order =  'DESC';
			}else if(sortBy.equalsIgnoreCase('createdOldest')){
				orderBy = 'created_date_oldest';
				order =  'ASC';
			}else if(sortBy.equalsIgnoreCase('displayToNewest')){
				orderBy = 'display_to_date_newest';
				order = 'DESC';
			} else if(sortBy.equalsIgnoreCase('displayToOldest')){
				orderBy = 'display_to_date_oldest';
				order = 'ASC';
			} else if(sortBy.equalsIgnoreCase('displayFromNewest')){
				orderBy = 'display_from_date_newest';
				order = 'DESC';
			} else if(sortBy.equalsIgnoreCase('displayFromOldest')){
				orderBy = 'display_from_date_oldest';
				order = 'ASC';
			}
		} else {
			orderBy = 'CreatedDate';
			order = 'DESC';
		}
        if (alertCriteriaObj.nextPageToken != null) {
			offset = Integer.valueOf(alertCriteriaObj.nextPageToken);
		}
		alertCriteriaObj.sortby = orderBy;
		alertCriteriaObj.order = order;
		alertCriteriaObj.status = alertCriteriaObj.filter;
		
		String searchResultJSON = getExternalSearchResults(alertCriteriaObj.term, offset, 'Alert', 
			alertCriteriaObj.isCorrectionEnabled, alertCriteriaObj.siteId, alertCriteriaObj);

		ExternalSearchWrapper.AIResponse responseWrapperAI = (ExternalSearchWrapper.AIResponse)JSON.deserialize(searchResultJSON, ExternalSearchWrapper.AIResponse.class);
		
		return convertAlertResponseToWrapper(responseWrapperAI);
	}

	private List<String> convertAlertResponseToWrapper(ExternalSearchWrapper.AIResponse responseWrapperAI) {		
		
		logger.logDebug('ExternalSearchService.convertAlertResponseToWrapper()----responseWrapperAI----' + responseWrapperAI);

		if('success'.equalsIgnoreCase(responseWrapperAI.status) == false) { 
			throw new SimpplrException(responseWrapperAI.message);
		}
		List<String> alertIdList = new List<String>();
		for(ExternalSearchWrapper.SearchDataWrapper hitOj : responseWrapperAI.hits.hit){
			alertIdList.add(hitOj.id);
		}
		
		return alertIdList;
	}

	public ExternalSearchWrapper.TopContentsWrapper searchSiteCategory(Criteria.ExternalSearchReq siteCategoryCriteriaObj, String searchForType) {
		ExternalSearchWrapper.TopContentsWrapper resultWrapper = new ExternalSearchWrapper.TopContentsWrapper();		
        Integer offset = 0; 
		String searchTerm = String.isBlank(siteCategoryCriteriaObj.term) ? '' : siteCategoryCriteriaObj.term;
		if (siteCategoryCriteriaObj.nextPageToken != null) {
            offset = Integer.valueOf(siteCategoryCriteriaObj.nextPageToken);
		}

		String searchResultJSON = getExternalSearchResults(siteCategoryCriteriaObj.term, offset, searchForType, 
			siteCategoryCriteriaObj.isCorrectionEnabled, siteCategoryCriteriaObj.siteId, 
			siteCategoryCriteriaObj);

		ExternalSearchWrapper.AIResponse responseWrapperAI = (ExternalSearchWrapper.AIResponse)JSON.deserialize(searchResultJSON, ExternalSearchWrapper.AIResponse.class);
		resultWrapper = convertToWrapper(responseWrapperAI,searchForType,searchTerm);
		resultWrapper.nextPageToken = ((responseWrapperAI.hits.start+Integer.valueOf(siteCategoryCriteriaObj.size))<(responseWrapperAI.hits.total.value)) ? String.valueOf(responseWrapperAI.hits.start+Integer.valueOf(siteCategoryCriteriaObj.size)):null;
		return resultWrapper;
	}

	private List<ExternalSearchWrapper.ItemWrapper> convertToSiteCategoryItemWrapperList(List<ExternalSearchWrapper.SearchDataWrapper> hitList, String searchTerm){
		List<ExternalSearchWrapper.ItemWrapper> listToReturn = new List<ExternalSearchWrapper.ItemWrapper>();
		ExternalSearchWrapper.ItemWrapper item;
			
		for(ExternalSearchWrapper.SearchDataWrapper hitObj : hitList){
			listToReturn.add(convertToSiteCategoryItemWrapper(hitObj, searchTerm));
		}
		return listToReturn;
	}

	private ExternalSearchWrapper.ItemWrapper convertToSiteCategoryItemWrapper(ExternalSearchWrapper.SearchDataWrapper hitObj, String searchTerm){
		ExternalSearchWrapper.ItemWrapper itemWrapperObj = new ExternalSearchWrapper.ItemWrapper();
		try{
			ManageApplicationWrapper.ManageSitesCategoryWrapper wrapperObj = new ManageApplicationWrapper.ManageSitesCategoryWrapper();
			wrapperObj.id = hitObj.id;
			wrapperObj.name = hitObj.site_category_name;
			itemWrapperObj.item = wrapperObj;
		}catch(Exception e) {			
			logger.logDebug(' e.getStackTraceString()	'+e.getStackTraceString());
	   	}
	   return itemWrapperObj;	   
	}

	public ExternalSearchWrapper.TopContentsWrapper searchPeople(Criteria.ExternalSearchReq peopleCriteriaObj, String searchForType) {
        Integer offset = 0; 

        if (peopleCriteriaObj.nextPageToken != null) {
            offset = Integer.valueOf(peopleCriteriaObj.nextPageToken);
        }
        String searchResultJSON = getExternalSearchResults(peopleCriteriaObj.term, offset, searchForType, 
                peopleCriteriaObj.isCorrectionEnabled, peopleCriteriaObj.siteId, 
                peopleCriteriaObj);
		ExternalSearchWrapper.AIResponse responseWrapperAI = (ExternalSearchWrapper.AIResponse)JSON.deserialize(searchResultJSON, ExternalSearchWrapper.AIResponse.class);
		resultWrapper = convertToWrapper(responseWrapperAI, searchForType, searchTerm);
		
		if (String.isNotBlank(responseWrapperAI.did_you_mean_term)) {
			resultWrapper.term = searchTerm;
		}

		resultWrapper.nextPageToken = ((responseWrapperAI.hits.start+peopleCriteriaObj.size)<(responseWrapperAI.hits.total.value)) ? String.valueOf(responseWrapperAI.hits.start+peopleCriteriaObj.size):null;
		return resultWrapper;
	}

	public ExternalSearchWrapper.TopContentsWrapper searchPeopleDepartment(Criteria.People peopleCriteriaObj) {	
		Criteria.ExternalSearchReq peopleDepartmentCriteriaObj = new Criteria.ExternalSearchReq();
		peopleDepartmentCriteriaObj.term = peopleCriteriaObj.term;
		peopleDepartmentCriteriaObj.nextPageToken = peopleCriteriaObj.nextPageToken;
		
		ExternalSearchWrapper.TopContentsWrapper resultWrapper = new ExternalSearchWrapper.TopContentsWrapper(); 	
        Integer offset = 0; 

        if (peopleDepartmentCriteriaObj.nextPageToken != null) {
            offset = Integer.valueOf(peopleDepartmentCriteriaObj.nextPageToken);
        }
        
		String searchResultJSON = getExternalSearchResults(peopleDepartmentCriteriaObj.term, offset, 'UserDepartment', 
			peopleDepartmentCriteriaObj.isCorrectionEnabled, peopleDepartmentCriteriaObj.siteId, 
			peopleDepartmentCriteriaObj);

		ExternalSearchWrapper.AIResponse responseWrapperAI = (ExternalSearchWrapper.AIResponse)JSON.deserialize(searchResultJSON, ExternalSearchWrapper.AIResponse.class);

		resultWrapper = convertFilterResponseToWrapper(responseWrapperAI, searchTerm);
		
		if (String.isNotBlank(responseWrapperAI.did_you_mean_term)) {
			resultWrapper.term = searchTerm;
		}

		return resultWrapper;
	}

	public ExternalSearchWrapper.TopContentsWrapper searchPeopleLocation(Criteria.People peopleCriteriaObj) {	
		Criteria.ExternalSearchReq peopleLocationCriteriaObj = new Criteria.ExternalSearchReq();
		peopleLocationCriteriaObj.term = peopleCriteriaObj.term;
		peopleLocationCriteriaObj.nextPageToken = peopleCriteriaObj.nextPageToken;

		ExternalSearchWrapper.TopContentsWrapper resultWrapper = new ExternalSearchWrapper.TopContentsWrapper(); 	
        Integer offset = 0; 

        if (peopleLocationCriteriaObj.nextPageToken != null) {
            offset = Integer.valueOf(peopleLocationCriteriaObj.nextPageToken);
        }
        
		String searchResultJSON = getExternalSearchResults(peopleLocationCriteriaObj.term, offset, 'UserLocation', 
			peopleLocationCriteriaObj.isCorrectionEnabled, peopleLocationCriteriaObj.siteId, 
			peopleLocationCriteriaObj);

		ExternalSearchWrapper.AIResponse responseWrapperAI = (ExternalSearchWrapper.AIResponse)JSON.deserialize(searchResultJSON, ExternalSearchWrapper.AIResponse.class);

		resultWrapper = convertFilterResponseToWrapper(responseWrapperAI, searchTerm);
		
		return resultWrapper;
	}

	public ExternalSearchWrapper.TopContentsWrapper searchPageCategories(Criteria.ExternalSearchReq pageCategoryCriteria, String SearchForType){
		List<ExternalSearchWrapper.AIResponse> topResultsWrapperList = new List<ExternalSearchWrapper.AIResponse>();
		Integer offset = 0; 
		if (pageCategoryCriteria.nextPageToken != null) {
	          offset =  Integer.valueOf(pageCategoryCriteria.nextPageToken);
	    }
		
		String searchResultJSON = getExternalSearchResults(pageCategoryCriteria.term, offset, searchForType, 
										pageCategoryCriteria.isCorrectionEnabled, pageCategoryCriteria.siteId, pageCategoryCriteria);
		
		ExternalSearchWrapper.AIResponse responseWrapperAI = (ExternalSearchWrapper.AIResponse)JSON.deserialize(searchResultJSON, ExternalSearchWrapper.AIResponse.class);
		resultWrapper = convertToWrapper(responseWrapperAI,searchForType,searchTerm);
		
		if (String.isNotBlank(responseWrapperAI.did_you_mean_term)) {
			resultWrapper.term = searchTerm;
		}

		resultWrapper.nextPageToken = ((responseWrapperAI.hits.start+Integer.valueOf(pageCategoryCriteria.size))<(responseWrapperAI.hits.total.value)) ? String.valueOf(responseWrapperAI.hits.start+Integer.valueOf(pageCategoryCriteria.size)):null;
		return resultWrapper;
	}

	public ExternalSearchWrapper.ObjectTypeWrapper getAudienceFieldValues(Criteria.ExternalSearchReq audienceFiledValuesCriteria, String searchForType){
		List<ExternalSearchWrapper.AIResponse> topResultsWrapperList = new List<ExternalSearchWrapper.AIResponse>();
		Integer offset = 0;
		
		String searchResultJSON = getExternalSearchResults(null, offset, searchForType, null, null, audienceFiledValuesCriteria);

		ExternalSearchWrapper.AIResponse responseWrapperAI = (ExternalSearchWrapper.AIResponse)JSON.deserialize(searchResultJSON, ExternalSearchWrapper.AIResponse.class);
		ExternalSearchWrapper.ObjectTypeWrapper audienceFieldValues = new ExternalSearchWrapper.ObjectTypeWrapper();

		if(responseWrapperAI.facets != null && responseWrapperAI.facets.field_agg != null) {
			audienceFieldValues = responseWrapperAI.facets.field_agg;
		}
		
		return audienceFieldValues;
	}

	private ExternalSearchWrapper.TopContentsWrapper convertFilterResponseToWrapper(ExternalSearchWrapper.AIResponse responseWrapperAI, String searchTerm) {		
		
		ExternalSearchWrapper.TopContentsWrapper wrapperObj = new ExternalSearchWrapper.TopContentsWrapper();
		List<ExternalSearchWrapper.ItemWrapper> listOfItems = new List<ExternalSearchWrapper.ItemWrapper>();
		
		logger.logDebug('ExternalSearchService.convertFilterResponseToWrapper()----responseWrapperAI----' + responseWrapperAI);
		if('success'.equalsIgnoreCase(responseWrapperAI.status) == false) { 
			throw new SimpplrException(responseWrapperAI.message);
		}

		for(ExternalSearchWrapper.FilterAttributeWrapper rec : responseWrapperAI.results) {
			listOfItems.add(convertToFilterItemWrapper(rec, searchTerm));
		}

		wrapperObj.listOfItems = listOfItems;
		wrapperObj.term = searchTerm;
		
		return wrapperObj;
	}

	private ExternalSearchWrapper.ItemWrapper convertToFilterItemWrapper(ExternalSearchWrapper.FilterAttributeWrapper rec, String searchTerm) {
		ExternalSearchWrapper.ItemWrapper itemWrapperObj = new ExternalSearchWrapper.ItemWrapper();
		
		ExternalSearchWrapper.FilterAttributeWrapper filterWrapObj = new ExternalSearchWrapper.FilterAttributeWrapper();
		filterWrapObj.id = rec.id;
		filterWrapObj.name = rec.name;

		itemWrapperObj.item = filterWrapObj;

		return itemWrapperObj;
	}

	private ExternalSearchWrapper.TopContentsWrapper convertNativeVideoResponseToWrapper(String responseStr, String searchForType, String searchTerm) {

		if(resultWrapper == null){
			resultWrapper = new ExternalSearchWrapper.TopContentsWrapper();
			resultWrapper.listOfItems = new List<ExternalSearchWrapper.ItemWrapper>();
		}
		List<ExternalSearchWrapper.ItemWrapper> listOfItems = new List<ExternalSearchWrapper.ItemWrapper>();	
		
		Map<String, Object> respObj = (Map<String, Object>) JSON.deserializeUntyped(responseStr);
		if('KalturaAPIException'.equalsIgnoreCase((String) respObj.get('objectType')) == true) { 
			throw new SimpplrException((String) respObj.get('message'));
		}

		if(respObj.get('objects') != null){

			List<Object> objectList = (List<Object>) respObj.get('objects');
			Set<String> entryIdSet = new Set<String>();
			Map<String, FileListingWrapper.VideoCaptionWrapper> captionsMap = new Map<String, FileListingWrapper.VideoCaptionWrapper>();
			Map<String, Integer> mapOfVideoDuration = new Map<String, Integer>();
			for(Object objElem : objectList){
				Map<String, Object> tempMap = (Map<String, Object>) objElem;
				Map<String, Object> videoObj = (Map<String, Object>) tempMap.get('object');

				String fileExternalId = (String) videoObj.get('id');
				mapOfVideoDuration.put(fileExternalId, (Integer) videoObj.get('duration'));
				entryIdSet.add(fileExternalId);
				
				captionsMap.put(fileExternalId, getVideoCaptions(fileExternalId, (List<Object>) tempMap.get('itemsData')));
			}
			
			List<File__c> fileList = new List<File__c>();
			Map<String, File__c> fileMap = new Map<String, File__c> ();
			Map<String, List<SiteLiteWrapper>> fileToSiteList = new Map<String, List<SiteLiteWrapper>> ();
			Map<String, Set<String>> fileToSiteIdsMap = new Map<String, Set<String>> ();
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', entryIdSet);
			Map<String, Boolean> mapOfExtIdAndHome = new Map<String, Boolean>();
			if(entryIdSet.isEmpty() == false){
				String filesQuery = 'SELECT Id, Title__c, External_Id__c, MIME_Type__c, Author__c, Author__r.Full_Name__c,'+
											' Author__r.User__c, LastModifiedDate, Size__c, Site__r.Name, Site__r.Site_Type__c,'+
											' Site__r.Landing_Page__c ,Simpplr_Content__c, Feed_Item__c, Video_Provider__c, Repository__c, video_status__c '+
											' FROM File__c WHERE External_Id__c IN :soqlParam1 and is_Deleted__c = false ORDER BY createdDate';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				fileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
				Set<String> feedIdsSet = new Set<String>();
				for(File__c fileObj : fileList) {
					if(!fileMap.containsKey(fileObj.External_Id__c)){
						fileMap.put(fileObj.External_Id__c, fileObj);
					}
					if(String.isNotBlank(fileObj.Site__c)){
						Set<String> siteIds = new Set<String>();
						List<SiteLiteWrapper> listOfSite = new List<SiteLiteWrapper>();
						if(fileToSiteIdsMap.containsKey(fileObj.External_Id__c)){
							siteIds.addAll(fileToSiteIdsMap.get(fileObj.External_Id__c));
							listOfSite.addAll(fileToSiteList.get(fileObj.External_Id__c));
						}
						if(!siteIds.contains(fileObj.Site__c)){
							SiteLiteWrapper siteWrapObj= new SiteLiteWrapper();
							siteWrapObj.siteId = fileObj.Site__c;
							siteWrapObj.name = fileObj.Site__r.Name;
							siteWrapObj.access = fileObj.Site__r.Site_Type__c;
							siteWrapObj.url= PageContext.getPageURL(Pages.app) +'?u=/site/' + fileObj.Site__c + '/' + fileObj.Site__r.Landing_Page__c;
							siteIds.add(fileObj.Site__c);
							listOfSite.add(siteWrapObj);
							fileToSiteIdsMap.put(fileObj.External_Id__c, siteIds);
							fileToSiteList.put(fileObj.External_Id__c, listOfSite);
						}
					}
					if(String.isBlank(fileObj.Site__c) && String.isBlank(fileObj.Simpplr_Content__c) && String.isNotBlank(fileObj.Feed_Item__c)) {
						mapOfExtIdAndHome.put(fileObj.External_Id__c, true);
					}
					if(String.isNotBlank(fileObj.Feed_Item__c) && (fileObj.Video_Provider__c == ServiceConstants.VIDEO_PROVIDER_NATIVE || fileObj.Repository__c == ServiceConstants.VIDEO_PROVIDER_NATIVE)) {
						feedIdsSet.add(fileObj.Feed_Item__c);
					}
				}
				VideoDao videoDaoObj = new VideoDao();
				Map<String, List<NativeVideoWrapper.ReferenceItemWrapper>> refrencesMap = videoDaoObj.getReferencesForVideos(entryIdSet,feedIdsSet);
				
				for(String externalId : fileMap.keySet()){
					ExternalSearchWrapper.ItemWrapper itemWrapperObj = new ExternalSearchWrapper.ItemWrapper();
					FileListingWrapper fileWrapperObj = new FileListingWrapper();

					fileWrapperObj.title = fileMap.get(externalId).Title__c;
					fileWrapperObj.name = fileMap.get(externalId).Title__c;
					fileWrapperObj.size = fileMap.get(externalId).Size__c != null ? fileMap.get(externalId).Size__c.longValue() : 0;
					fileWrapperObj.id = externalId;
					fileWrapperObj.fileId = externalId;
					fileWrapperObj.type = 'Video';
					fileWrapperObj.isVideo = true;
					fileWrapperObj.videoStatus = 1;
					if(fileMap.get(externalId).video_status__c != null){
						fileWrapperObj.videoStatus = Integer.valueOf(fileMap.get(externalId).video_status__c);
					}
					fileWrapperObj.owner.id = fileMap.get(externalId).Author__c;
					fileWrapperObj.owner.name = fileMap.get(externalId).Author__r.Full_Name__c;
					fileWrapperObj.owner.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + fileWrapperObj.owner.id;
					fileWrapperObj.context = ServiceConstants.VIDEO_PROVIDER_NATIVE;
					fileWrapperObj.provider = ServiceConstants.VIDEO_PROVIDER_NATIVE;
					DateTime dateTimeValue = fileMap.get(externalId).LastModifiedDate;
					fileWrapperObj.modifiedAt = dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
					fileWrapperObj.url = PageContext.getPageURL(Pages.app) + '?u=/video/' + externalId;
					fileWrapperObj.thumbnailImg = ServiceConstants.NATIVE_VIDEO_BASE_URL + SimpplrContext.Integrations.get(ServiceConstants.VIDEO_PROVIDER_NATIVE).External_Id__c +'/thumbnail/entry_id/' + fileMap.get(externalId).External_Id__c +'/width/550/height/480';

					fileWrapperObj.listOfSite = fileToSiteList.containsKey(externalId) ? fileToSiteList.get(externalId) : new List<SiteLiteWrapper>();
					fileWrapperObj.runTime = mapOfVideoDuration.get(externalId);
					fileWrapperObj.isInHomeFeed = mapOfExtIdAndHome.keyset().contains(externalId) ? true : false;
					fileWrapperObj.captions = captionsMap.get(externalId);
					if(refrencesMap.containsKey(externalId)){
						fileWrapperObj.references = refrencesMap.get(externalId);
					}
					itemWrapperObj.item = fileWrapperObj;
					itemWrapperObj.itemType = 'file';

					listOfItems.add(itemWrapperObj);
				}
			}

		}
		resultWrapper.listOfItems.addAll(listOfItems);
		resultWrapper.totalRecords = respObj.get('totalCount') != null ? (Integer) respObj.get('totalCount') : 0;
		resultWrapper.term = searchTerm;
		
		return resultWrapper;
	}

	private FileListingWrapper.VideoCaptionWrapper getVideoCaptions(String fileExternalId, List<Object> itemsData) {
		FileListingWrapper.VideoCaptionWrapper vCWObj = new FileListingWrapper.VideoCaptionWrapper();
		vCWObj.totalRecords = 0;
		vCWObj.listOfItems = new List<FileListingWrapper.VideoCaptionItem>();

		for(Object itemObj : itemsData) {
			Map<String, Object> tempMap = (Map<String, Object>) itemObj;

			String itemType = (String)tempMap.get('itemsType');
			if('caption'.equalsIgnoreCase(itemType)) {
				vCWObj.totalRecords = (Integer)tempMap.get('totalCount');
				List<Object> captionMap = (List<Object>)tempMap.get('items');
				
				for(Object captionObj : captionMap) {
					Map<String, Object> captionObjMap = (Map<String, Object>)captionObj;

					FileListingWrapper.VideoCaptionItem vCItem = new FileListingWrapper.VideoCaptionItem();
					vCItem.id = (String)captionObjMap.get('captionAssetId');
					vCItem.text = (String)captionObjMap.get('line');
					vCItem.timeStamp = (Integer)((Integer)captionObjMap.get('startsAt'))/1000;

					vCWObj.listOfItems.add(vCItem);
				}
			}
		}
		
		return vCWObj;
	}
	
	private ExternalSearchWrapper.TopContentsWrapper convertToWrapper(ExternalSearchWrapper.AIResponse responseWrapperAI,String SearchForType, String searchTerm) {
		logger.logDebug('ExternalSearchService.convertToWrapper()----responseWrapperAI----' + responseWrapperAI);
		if('success'.equalsIgnoreCase(responseWrapperAI.status) == false) { 
			throw new SimpplrException(responseWrapperAI.message);
		}
		
		ExternalSearchWrapper.TopContentsWrapper wrapperObj = new ExternalSearchWrapper.TopContentsWrapper();
		List<ExternalSearchWrapper.ItemWrapper> listOfItems = new List<ExternalSearchWrapper.ItemWrapper>();
		List<String> contentIdList = new List<String>();
		if('Top'.equalsIgnoreCase(searchForType)){
			Map<String,List<ExternalSearchWrapper.SearchDataWrapper>> contentTypeMap = new Map<String,List<ExternalSearchWrapper.SearchDataWrapper>>();
			for(ExternalSearchWrapper.SearchDataWrapper rec : responseWrapperAI.hits.hit){
				if('Content'.equalsIgnoreCase(rec.object_type)){
					contentIdList.add(rec.Id);
				}
			}
			Map<String,Simpplr_Content__c> contentMap = new Map<String,Simpplr_Content__c>();
			if(contentIdList.size() > 0) {
				String loggedInPeopleId = UserContext.peopleId;
				contentMap.putAll([Select Id, (Select Id from Must_Read_Confirm_History__r Where People__c =:loggedInPeopleId) 
									From Simpplr_Content__c Where id IN : contentIdList]);
			}										
			for(ExternalSearchWrapper.SearchDataWrapper rec : responseWrapperAI.hits.hit){
				if('People'.equalsIgnoreCase(rec.object_type)){
					removeDisabledProfileFields(rec);
					listOfItems.add(convertToPeopleItemWrapper(rec, searchTerm));
					
				}else if('Site'.equalsIgnoreCase(rec.object_type)){
					listOfItems.add(convertToSiteItemWrapper(rec, searchTerm));
					
				}else if('Content'.equalsIgnoreCase(rec.object_type)){
					listOfItems.add(convertToContentItemWrapper(rec,searchTerm, contentMap.get(rec.id), false));
					
				} else if('File'.equalsIgnoreCase(rec.object_type) || 'CrmFile'.equalsIgnoreCase(rec.object_type)){
					listOfItems.add(convertToFileItemWrapper(rec, searchTerm));
					
				}  else if('Links'.equalsIgnoreCase(rec.object_type)) {
					listOfItems.add(convertLinksResponseToItemWrapper(rec));
				} else if('Tiles'.equalsIgnoreCase(rec.object_type)) {
					listOfItems.add(convertTilesResponseToItemWrapper(rec));
				} else if('Question'.equalsIgnoreCase(rec.object_type)) {
					listOfItems.add(convertQuestionResponseToItemWrapper(rec));
				}
			}
			ExternalSearchWrapper.sectionCounts secCount = new ExternalSearchWrapper.sectionCounts();
			for(ExternalSearchWrapper.BucketWrapper sec : responseWrapperAI.facets.object_type.buckets){
				if(sec.value.equalsIgnoreCase('People')){
					secCount.User = sec.count;
				}
				if(sec.value.equalsIgnoreCase('Site')){
					secCount.Site = sec.count;
				}
				if(sec.value.equalsIgnoreCase('Content')){
					secCount.Content = sec.count;
				}
				if(sec.value.equalsIgnoreCase('Tiles')){
					secCount.Tiles = sec.count;
				}
				if(sec.value.equalsIgnoreCase('Links')){
					secCount.Links = sec.count;
				}
				if(sec.value.equalsIgnoreCase('Question')){
					secCount.Question = sec.count;
				}
			}
			wrapperObj.sectionCounts = secCount;
			
		} else if('Site'.equalsIgnoreCase(searchForType)){
			listOfItems = convertToSiteItemWrapperList(responseWrapperAI.hits.hit, searchTerm);
			
		} else if('Chatter_Group'.equalsIgnoreCase(searchForType)){
			listOfItems = convertToChatterGroupItemWrapperList(responseWrapperAI.hits.hit, searchTerm);
			
		} else if('User'.equalsIgnoreCase(searchForType)){
			listOfItems = convertToPeopleItemWrapperList(responseWrapperAI.hits.hit, searchTerm);
			
		} else if('Content'.equalsIgnoreCase(searchForType)){
			listOfItems = convertToContentItemWrapperList(responseWrapperAI.hits.hit, searchTerm);
			
		} else if('ContentOnboarding'.equalsIgnoreCase(searchForType)){
			listOfItems = convertToContentOnboardingItemWrapperList(responseWrapperAI.hits.hit, searchTerm);
			
		} else if('Pages_Category'.equalsIgnoreCase(searchForType)){
			listOfItems = convertToPageCategoryItemWrapperList(responseWrapperAI.hits.hit, searchTerm);
			
		} else if('File'.equalsIgnoreCase(searchForType) || 'CrmFile'.equalsIgnoreCase(searchForType)){
			listOfItems = convertToFileItemWrapperList(responseWrapperAI.hits.hit, searchTerm);
			
		} else if('Site_Category'.equalsIgnoreCase(searchForType)){
			listOfItems = convertToSiteCategoryItemWrapperList(responseWrapperAI.hits.hit, searchTerm);
			
		} else if('Links'.equalsIgnoreCase(searchForType)) {
			listOfItems = convertToLinksItemWrapperList(responseWrapperAI.hits.hit);
		} else if('Tiles'.equalsIgnoreCase(searchForType)) {
			listOfItems = convertToTilesItemWrapperList(responseWrapperAI.hits.hit);
		} else if('Question'.equalsIgnoreCase(searchForType)) {
			listOfItems = convertToQuestionItemWrapperList(responseWrapperAI.hits.hit);
		}
		wrapperObj.listOfItems = listOfItems;
		wrapperObj.totalRecords = responseWrapperAI.hits.total.value;
		if(String.isNotBlank(responseWrapperAI.showing_results_for_term)){
			wrapperObj.term = responseWrapperAI.showing_results_for_term;
			wrapperObj.suggestedTerm = responseWrapperAI.showing_results_for_term;
		}
		
		if(String.isNotBlank(responseWrapperAI.did_you_mean_term)){
			wrapperObj.suggestedTerm = responseWrapperAI.did_you_mean_term;
		}
		
		return wrapperObj;
	}
	
	private ExternalSearchWrapper.ItemWrapper convertToPeopleItemWrapper(ExternalSearchWrapper.SearchDataWrapper hitObj, String searchTerm){
		ExternalSearchWrapper.ItemWrapper itemWrapperObj = new ExternalSearchWrapper.ItemWrapper();
		PeopleListingWrapper peopleWrapObj = new PeopleListingWrapper();
		peopleWrapObj.id = hitObj.Id;
		peopleWrapObj.peopleId = hitObj.Id;
		peopleWrapObj.isActive = hitObj.user_r_isactive;
		String name = hitObj.name;
		if(String.isNotBlank(name)){
			peopleWrapObj.name = name;
		}
		peopleWrapObj.title = hitObj.title;
		peopleWrapObj.department = hitObj.department;
		peopleWrapObj.city = hitObj.city;
		peopleWrapObj.state = hitObj.state;
		peopleWrapObj.country = hitObj.country;
		peopleWrapObj.location = Utility.buildLocation(peopleWrapObj.city, peopleWrapObj.state, peopleWrapObj.country);
		peopleWrapObj.email = hitObj.email;
		peopleWrapObj.phone = hitObj.phone;
		peopleWrapObj.mobile = hitObj.mobile_phone;
		peopleWrapObj.img = hitObj.img;
		peopleWrapObj.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + hitObj.id;
		peopleWrapObj.slackUserId = hitObj.slack_user_id;
		peopleWrapObj.slackUserName = hitObj.slack_user_name;
		peopleWrapObj.slackTenantId = hitObj.slack_tenant_id;
	
		itemWrapperObj.relevancyScore = Double.valueOf(hitObj.score);
		itemWrapperObj.itemType = 'user';
		itemWrapperObj.item = peopleWrapObj;
		return itemWrapperObj;
	}
	
	//converting AI response to item  wrapper for people
	private List<ExternalSearchWrapper.ItemWrapper> convertToPeopleItemWrapperList(List<ExternalSearchWrapper.SearchDataWrapper> hitList, String searchTerm){
		List<ExternalSearchWrapper.ItemWrapper> listToReturn = new List<ExternalSearchWrapper.ItemWrapper>();
		
		for(ExternalSearchWrapper.SearchDataWrapper hitObj : hitList){
			listToReturn.add(convertToPeopleItemWrapper(hitObj,searchTerm));
		}
		return listToReturn;
	}
	
	private ExternalSearchWrapper.ItemWrapper convertToFileItemWrapper(ExternalSearchWrapper.SearchDataWrapper hitObj, String searchTerm){
	 	ExternalSearchWrapper.ItemWrapper itemWrapperObj = new ExternalSearchWrapper.ItemWrapper();
		try{
		FileListingWrapper wrapperObj = new FileListingWrapper();
		itemWrapperObj.relevancyScore = Double.valueOf(hitObj.score);
		itemWrapperObj.itemType = 'file';
		wrapperObj.title = hitObj.file_name;
		wrapperObj.name = hitObj.file_name;
		if(String.isNotBlank(hitObj.file_size)) {
			wrapperObj.size = Long.valueOf(hitObj.file_size);
		}
		wrapperObj.id = hitObj.Id;
		wrapperObj.fileId = hitObj.Id;
		wrapperObj.type = hitObj.type;
		wrapperObj.fileExtension = hitObj.fileExtension;
		wrapperObj.owner.id = hitObj.owner_id;
		wrapperObj.owner.name = hitObj.owner_name;
		wrapperObj.owner.url = PageContext.getPageURL(Pages.app) + '?u=/redirect-to-profile/' + hitObj.owner_id; 
		if('C'.equalsIgnoreCase(hitObj.origin)) {
			wrapperObj.context = 'crm';
			wrapperObj.provider = 'crm';
		} else {
			wrapperObj.context = 'intranet';
			wrapperObj.provider = 'intranet';
		}
		DateTime dateTimeValue = null;
		if(String.isNotBlank(hitObj.lastModifiedDate)){
			dateTimeValue = DateTime.ValueofGMT(hitObj.lastModifiedDate.replace('T', ' '));
			wrapperObj.modifiedAt = dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		}
		wrapperObj.downloadUrl = Utility.getFileDownloadURL(hitObj.contentVersionId);	
		wrapperObj.url= PageContext.getPageURL(Pages.FileDetail) +'?fileId=' + hitObj.Id;
		
		itemWrapperObj.item = wrapperObj;
		SiteLiteWrapper siteWrapObj= new SiteLiteWrapper();
		List<SiteLiteWrapper> listOfSite = new List<SiteLiteWrapper>();
		
		for(ExternalSearchWrapper.SiteWrapper site : hitObj.sites){
			siteWrapObj.siteId= site.id;
			siteWrapObj.name=site.name;
			siteWrapObj.access = site.site_type;
			siteWrapObj.url= PageContext.getPageURL(Pages.app) +'?u=/site/' + site.id + '/' + site.landing_page;
		}
		
		listOfSite.add(siteWrapObj);
		wrapperObj.listOfSite = listOfSite;
		
		}catch(Exception e) {			
		 	logger.logDebug(' @@@@@	e.getStackTraceString()	'+e.getStackTraceString());
		}
		return itemWrapperObj;
	}
	
	private ExternalSearchWrapper.ItemWrapper convertToContentItemWrapper(ExternalSearchWrapper.SearchDataWrapper hitObj,String searchTerm, Simpplr_Content__c contentObj, Boolean isOnboardingContent){
		ExternalSearchWrapper.ItemWrapper itemWrapperObj = new ExternalSearchWrapper.ItemWrapper();
		ContentWrapper wrapperObj = new ContentWrapper();
		wrapperObj.id = hitObj.Id;
		wrapperObj.contentId = hitObj.Id;
		DateTime dateTimeValue = null;
		String dateStringValue = hitObj.last_edited_datetime;
		String publishedDateStringValue = hitObj.publish_start_datetime;
		if(String.isNotBlank(dateStringValue)){
			if (String.isNotBlank(publishedDateStringValue) && DateTime.ValueofGMT(hitObj.last_edited_datetime.replace('T', ' ')).date() > DateTime.ValueofGMT(hitObj.publish_start_datetime.replace('T', ' ')).date()){
				dateTimeValue = DateTime.ValueofGMT(hitObj.last_edited_datetime.replace('T', ' '));
				wrapperObj.modifiedAt = dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
			}else {
				wrapperObj.modifiedAt = null;
			}
		}
		dateStringValue = hitObj.publish_start_datetime;
		if(String.isNotBlank(dateStringValue)){
			dateTimeValue = DateTime.ValueofGMT(hitObj.publish_start_datetime.replace('T', ' '));
			wrapperObj.publishAt = dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		}
		
		if(ServiceConstants.TYPE_PAGE.equalsIgnoreCase(hitObj.type)){
			wrapperObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+hitObj.site+'/page/'+hitObj.id;
		
		} else if(ServiceConstants.TYPE_EVENT.equalsIgnoreCase(hitObj.type)){
		    wrapperObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+hitObj.site+'/event/'+hitObj.id;
		    dateStringValue = hitObj.event_start_datetime;
			if(String.isNotBlank(dateStringValue)){
				wrapperObj.startsAt = EmailUtility.getFormattedDate(DateTime.ValueofGMT(hitObj.event_start_datetime.replace('T', ' ')),'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ',UserContext.timeZoneName);
			}
			
			DateTime endDateTimeValue = DateTime.ValueofGMT(hitObj.event_end_datetime.replace('T', ' '));
			if('12:00 AM'.equalsIgnoreCase(endDateTimeValue.format('h:mm a'))) {
				endDateTimeValue = DateTime.ValueofGMT(hitObj.event_end_datetime.replace('T', ' ')).addMinutes(-1);
			}
			wrapperObj.endsAt = EmailUtility.getFormattedDate(DateTime.ValueofGMT(hitObj.event_end_datetime.replace('T', ' ')),'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ',UserContext.timeZoneName);
			wrapperObj.isAllDay = hitObj.event_is_all_day;
			if(DateTime.ValueofGMT(hitObj.event_start_datetime.replace('T', ' ')).isSameDay(endDateTimeValue)) {
				wrapperObj.isMultiDay = false;
			}else {
				wrapperObj.isMultiDay = true;
			}

			TimeZone tz = Timezone.getTimeZone(hitObj.event_timezonesidkey);
			wrapperObj.timezoneName = Utility.timezoneIdToDisplayLabel(hitObj.event_timezonesidkey);
			wrapperObj.timezoneIso = tz.getID();
			wrapperObj.timezoneOffset = tz.getOffset(system.today());
			
	    } else if(ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(hitObj.type)){
			wrapperObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+hitObj.site+'/album/'+hitObj.id;

	    } else if(ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(hitObj.type)){
		   wrapperObj.url = PageContext.getPageURL(Pages.app)+'?u=/people/'+hitObj.primary_author+'/blog/'+hitObj.id;
	   	}
	   	
	   	if(ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(hitObj.type)) {
	   		wrapperObj.img = hitObj.img;
			wrapperObj.imgLandscape = hitObj.imgLandscape;  
	   	} else {
			wrapperObj.img = String.isNotBlank(hitObj.img) ? Utility.getFileDownloadURLFor240BY180(hitObj.img) : null;
			wrapperObj.imgLandscape = String.isNotBlank(hitObj.img) ? Utility.getFileDownloadURLFor240BY180(hitObj.imgLandscape) : null;
	   	}
		if(String.isNotBlank(hitObj.imgContentDocumentId)) {
			wrapperObj.imgFile = New FileContentWrapper();
			wrapperObj.imgFile.id = hitObj.imgContentDocumentId;			
		}
		if(String.isNotBlank(hitObj.imgLandscapeContentDocumentId)) {
			wrapperObj.imgLandscapeFile = New FileContentWrapper();
			wrapperObj.imgLandscapeFile.id = hitObj.imgLandscapeContentDocumentId;
			wrapperObj.imgLandscapeFile.imgTHUMB720BY480URL =  SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +hitObj.imgLandscapeContentDocumentId+'/rendition?type=THUMB720BY480';
			wrapperObj.imgLandscapeFile.imgFullURL = SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL + hitObj.imgLandscapeContentDocumentId + '/content';

		}
		
		wrapperObj.title = hitObj.title;
		wrapperObj.isMustRead = Boolean.valueOf(hitObj.is_must_read);
		If(contentObj != null && contentObj.Must_Read_Confirm_History__r.isEmpty()==false){
			wrapperObj.hasRead = true;
		}else{
			wrapperObj.hasRead = false;
		}
		wrapperObj.excerpt = String.isEmpty(hitObj.display_summary)?'':hitObj.display_summary.unescapeHtml4();
		wrapperObj.type = 'BlogPost'.equalsIgnoreCase(hitObj.type) ? 'blog_post' : hitObj.type;
		
		if(!ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(hitObj.type)){
			wrapperObj.site = new SiteLiteWrapper();
			wrapperObj.site.siteId = hitObj.site;
			wrapperObj.site.name = hitObj.site_r_name;
			wrapperObj.site.access = hitObj.site_r_site_type;
			wrapperObj.site.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + hitObj.site + '/' + hitObj.site_r_landing_page;
			wrapperObj.site.img = String.isNotBlank(hitObj.site_r_title_content_version) ? Utility.getFileDownloadURLFor720By480(hitObj.site_r_title_content_version) : null;
			wrapperObj.site.imgThumbnail = String.isNotBlank(hitObj.site_r_title_content_version) ? Utility.getFileDownloadURLFor120BY90(hitObj.site_r_title_content_version) : null;
			wrapperObj.site.imgContentDocumentId = hitObj.site_r_title_content_document;
		}
		wrapperObj.authoredBy = new PeopleListWrapper();
		wrapperObj.authoredBy.id = hitObj.primary_author;
		wrapperObj.authoredBy.name = hitObj.primary_author_r_name;
		wrapperObj.authoredBy.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + wrapperObj.authoredBy.id;
		wrapperObj.isContentRead = new SiteAddPageDataServer().isContentRead(hitObj.Id);

		wrapperObj.onboardingStatus = hitObj.onboarding_status;
		wrapperObj.onboardingAddedDate = String.isNotBlank(hitObj.onboarding_added_date) ? hitObj.onboarding_added_date : null;

		itemWrapperObj.relevancyScore = Double.valueOf(hitObj.score);
		itemWrapperObj.itemType = isOnboardingContent ? 'contentOnboarding' : 'content';
		itemWrapperObj.item = wrapperObj;

		return itemWrapperObj;
	}

	//converting AI response to item  wrapper for page category
	private List<ExternalSearchWrapper.ItemWrapper> convertToPageCategoryItemWrapperList(List<ExternalSearchWrapper.SearchDataWrapper> hitList, String searchTerm){
		List<ExternalSearchWrapper.ItemWrapper> listToReturn = new List<ExternalSearchWrapper.ItemWrapper>();
		
		for(ExternalSearchWrapper.SearchDataWrapper hitObj : hitList){
			listToReturn.add(convertToPageCategoryItemWrapper(hitObj, searchTerm));
		}			
		return listToReturn;
	}
	
	private ExternalSearchWrapper.ItemWrapper convertToPageCategoryItemWrapper(ExternalSearchWrapper.SearchDataWrapper hitObj, String searchTerm){
		ExternalSearchWrapper.ItemWrapper itemWrapperObj = new ExternalSearchWrapper.ItemWrapper();
		try{
			CategoryListWrapper wrapperObj = new CategoryListWrapper();
			itemWrapperObj.relevancyScore = Double.valueOf(hitObj.score);
			itemWrapperObj.itemType = 'page_category';
			
			wrapperObj.id = hitObj.Id;
			wrapperObj.name = hitObj.name;
			//wrapperObj.Id = hitObj.Id;
			DateTime dateTimeValue = null;
			if(String.isNotBlank(hitObj.createdDate)){
				dateTimeValue = DateTime.ValueofGMT(hitObj.createdDate.replace('T', ' '));
				wrapperObj.createdAt = dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
			}
			
			itemWrapperObj.item = wrapperObj;

		}catch(Exception e) {			
			logger.logDebug(' @@@@@	e.getStackTraceString()	'+e.getStackTraceString());
		}
		return itemWrapperObj;
	}

	//converting AI response to item  wrapper for file
	 private List<ExternalSearchWrapper.ItemWrapper> convertToFileItemWrapperList(List<ExternalSearchWrapper.SearchDataWrapper> hitList, String searchTerm){
		List<ExternalSearchWrapper.ItemWrapper> listToReturn = new List<ExternalSearchWrapper.ItemWrapper>();
		ContentWrapper wrapperObj;
		ExternalSearchWrapper.ItemWrapper itemWrapperObj;
		
		for(ExternalSearchWrapper.SearchDataWrapper hitObj : hitList){
			listToReturn.add(convertToFileItemWrapper(hitObj, searchTerm));
		}			
		return listToReturn;
	}
	
	//converting AI response to item  wrapper for content
	private List<ExternalSearchWrapper.ItemWrapper> convertToContentItemWrapperList(List<ExternalSearchWrapper.SearchDataWrapper> hitList, String searchTerm){
		List<ExternalSearchWrapper.ItemWrapper> listToReturn = new List<ExternalSearchWrapper.ItemWrapper>();
		ContentWrapper wrapperObj;
		ExternalSearchWrapper.ItemWrapper itemWrapperObj;
		List<String> listOfContentIds = new List<String>();
		String loggedInPeopleId = UserContext.peopleId;
		
		for(ExternalSearchWrapper.SearchDataWrapper hitObj : hitList){
			listOfContentIds.add(hitObj.Id);
		}		
		Map<String,Simpplr_Content__c> contentMap = new Map<String,Simpplr_Content__c>([Select Id,(Select Id from Must_Read_Confirm_History__r Where People__c =:loggedInPeopleId) 
													From Simpplr_Content__c Where id IN : listOfContentIds]);
		for(ExternalSearchWrapper.SearchDataWrapper hitObj : hitList){
			listToReturn.add(convertToContentItemWrapper(hitObj, searchTerm, contentMap.get(hitObj.id), false));
		}			
		return listToReturn;
	}
	
    private List<ExternalSearchWrapper.ItemWrapper> convertToContentOnboardingItemWrapperList(List<ExternalSearchWrapper.SearchDataWrapper> hitList, String searchTerm){
		List<ExternalSearchWrapper.ItemWrapper> listToReturn = new List<ExternalSearchWrapper.ItemWrapper>();
		ContentWrapper wrapperObj;
		ExternalSearchWrapper.ItemWrapper itemWrapperObj;
		List<String> listOfContentIds = new List<String>();
		String loggedInPeopleId = UserContext.peopleId;
		
		for(ExternalSearchWrapper.SearchDataWrapper hitObj : hitList){
			listOfContentIds.add(hitObj.Id);
		}		
		Map<String,Simpplr_Content__c> contentMap = new Map<String,Simpplr_Content__c>([Select Id,(Select Id from Must_Read_Confirm_History__r Where People__c =:loggedInPeopleId) 
													From Simpplr_Content__c Where id IN : listOfContentIds]);
		for(ExternalSearchWrapper.SearchDataWrapper hitObj : hitList){
			listToReturn.add(convertToContentItemWrapper(hitObj, searchTerm, contentMap.get(hitObj.id), true));
		}			
		return listToReturn;
	}
	
	private ExternalSearchWrapper.ItemWrapper convertToSiteItemWrapper(ExternalSearchWrapper.SearchDataWrapper hitObj, String searchTerm){
		ExternalSearchWrapper.ItemWrapper itemWrapperObj = new ExternalSearchWrapper.ItemWrapper();
		try{
		SiteListingWrapper siteWrapperObj = new SiteListingWrapper();
	 	siteWrapperObj.id = hitObj.id;
		 //For MAR-6437 defaulting the attributes
		 siteWrapperObj.siteId = hitObj.id;	
		 siteWrapperObj.memberCount =  0;
		 siteWrapperObj.isShowInSimpplrEnabled =  false;
		 siteWrapperObj.isPageEnabled =  false;
		 siteWrapperObj.isOwner =  false;
		 siteWrapperObj.isMember =  false;
		 siteWrapperObj.isMandatory =  false;
		 siteWrapperObj.isManager =  false;
		 siteWrapperObj.isFileEnabled =  false;
		 siteWrapperObj.isFeedEnabled =  false;
		 siteWrapperObj.isFeatured =  false;
		 siteWrapperObj.isFavorited =  false;
		 siteWrapperObj.isEventEnabled =  false;
		 siteWrapperObj.isDeleted =  false;
		 siteWrapperObj.IsBroadcast =  false;
		 siteWrapperObj.isAccessRequested =  false;
		 siteWrapperObj.isAboutEnabled =  false;
		 siteWrapperObj.chatterGroupId =  'dummyId';
		 // End
		siteWrapperObj.isQuestionAnswerEnabled =  hitObj.question_answer_enabled;
	 	siteWrapperObj.isActivated = hitObj.is_active;
	 	siteWrapperObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + hitObj.id + '/' + hitObj.landing_page;
	 	siteWrapperObj.title = hitObj.site_name;	 	
		siteWrapperObj.name = hitObj.site_name;	 	
	 	if(String.isNotBlank(hitObj.site_category)) {
	 		siteWrapperObj.category.id = hitObj.site_category;
	 		siteWrapperObj.category.name = hitObj.site_category_r_name;
			 //For MAR-6437 defaulting the attributes
			 siteWrapperObj.categoryName =  hitObj.site_category_r_name;
			 siteWrapperObj.categoryId =  hitObj.site_category;
			 //End
	 		siteWrapperObj.category.url = PageContext.getPageURL(Pages.App) +'?u=/sites#/sites/category?category='+hitObj.site_category;
	 	} else {
	 		siteWrapperObj.category = null;
	 	}
	 	if (String.isBlank(hitObj.collaborationgroup_description)){
	 		siteWrapperObj.description = '';	 		
	 	} else {
	 		siteWrapperObj.description = Utility.getAllValidWords(hitObj.collaborationgroup_description, 100, false);
	 	}
	 	siteWrapperObj.access = hitObj.site_type;
		siteWrapperObj.memberCount = hitObj.siteMemberCount;
		if(String.isNotBlank(hitObj.title_content_version) && (!'Unlisted'.equalsIgnoreCase(hitObj.site_type) || UserContext.hasModifyAllDataPermission ||
				 (UserContext.hasManageUnlistedSitePermission && 'Unlisted'.equalsIgnoreCase(hitObj.site_type)))){
			siteWrapperObj.img = Utility.getFileDownloadURLFor720By480(hitObj.title_content_version);
 			siteWrapperObj.imgThumbnail = Utility.getFileDownloadURLFor120BY90(hitObj.title_content_version);
		}
		if(String.isNotBlank(hitObj.title_content_version)) {
			siteWrapperObj.imgFile = new FileListingWrapper();
			siteWrapperObj.imgFile.downloadUrl = Utility.getFileDownloadURL(hitObj.title_content_version);
			siteWrapperObj.imgFile.fileUrl = Utility.getFileDownloadURL(hitObj.title_content_version);
			siteWrapperObj.imgFile.thumbnailImg = Utility.getFileDownloadURLFor240BY180(hitObj.title_content_version);
			siteWrapperObj.imgFile.url = PageContext.getPageURL(Pages.FileDetail, new Map<String, String>{'fileId' => hitObj.title_content_document, 'siteId' => hitObj.id});
			siteWrapperObj.imgFile.id = hitObj.title_content_document;
		}
		
		itemWrapperObj.relevancyScore = Double.valueOf(hitObj.score);
		itemWrapperObj.itemType = 'site';
		itemWrapperObj.item = siteWrapperObj;
		}
		catch(Exception e) {			
		 	logger.logDebug(' e.getStackTraceString()	'+e.getStackTraceString());
		}
		return itemWrapperObj;
		
	}

	//converting AI response to item wrapper for site
	private List<ExternalSearchWrapper.ItemWrapper> convertToSiteItemWrapperList(List<ExternalSearchWrapper.SearchDataWrapper> hitList, String searchTerm){
		List<ExternalSearchWrapper.ItemWrapper> listToReturn = new List<ExternalSearchWrapper.ItemWrapper>();
		ExternalSearchWrapper.ItemWrapper item;
		
		for(ExternalSearchWrapper.SearchDataWrapper hitObj : hitList){
			listToReturn.add(convertToSiteItemWrapper(hitObj, searchTerm));
		}
		return listToReturn;
	}

	public ExternalSearchWrapper.TopContentsWrapper searchNewsletters(Criteria.ExternalSearchReq newsletterCriteria, String SearchForType){
		logger.logDebug('ExternalSearchService.searchNewsletters()----newsletterCriteria----' + newsletterCriteria);
		 
		List<ExternalSearchWrapper.AIResponse> topResultsWrapperList = new List<ExternalSearchWrapper.AIResponse>();
		Integer offset = 0; 

        if (newsletterCriteria.nextPageToken != null) {
           offset =  Integer.valueOf(newsletterCriteria.nextPageToken);
        }

        String searchResultJSON = getExternalSearchResults(newsletterCriteria.term, offset, searchForType, 
		newsletterCriteria.isCorrectionEnabled, newsletterCriteria.siteId, newsletterCriteria);
		ExternalSearchWrapper.AIResponse responseWrapperAI = (ExternalSearchWrapper.AIResponse)JSON.deserialize(searchResultJSON, ExternalSearchWrapper.AIResponse.class);
		resultWrapper = convertNewsletterResponseToWrapper(responseWrapperAI,searchTerm);
		
        if (String.isNotBlank(responseWrapperAI.did_you_mean_term)) {
			resultWrapper.term = searchTerm;
		}

		resultWrapper.nextPageToken = ((responseWrapperAI.hits.start+Integer.valueOf(newsletterCriteria.size))<(responseWrapperAI.hits.total.value)) ? String.valueOf(responseWrapperAI.hits.start+Integer.valueOf(newsletterCriteria.size)):null;
		return resultWrapper;
	}

	private ExternalSearchWrapper.TopContentsWrapper convertNewsletterResponseToWrapper(ExternalSearchWrapper.AIResponse responseWrapperAI, String searchTerm) {		
		ExternalSearchWrapper.TopContentsWrapper wrapperObj = new ExternalSearchWrapper.TopContentsWrapper();
		List<ExternalSearchWrapper.ItemWrapper> listOfItems = new List<ExternalSearchWrapper.ItemWrapper>();

		logger.logDebug('ExternalSearchService.convertNewsletterResponseToWrapper()----responseWrapperAI----' + responseWrapperAI);

		if('success'.equalsIgnoreCase(responseWrapperAI.status) == false) { 
			throw new SimpplrException(responseWrapperAI.message);
		}

		for(ExternalSearchWrapper.SearchDataWrapper rec : responseWrapperAI.hits.hit) {
			listOfItems.add(convertToNewsletterItemWrapper(rec, searchTerm));
		}

		wrapperObj.listOfItems = listOfItems;

		return wrapperObj;
	}

	private ExternalSearchWrapper.ItemWrapper convertToNewsletterItemWrapper(ExternalSearchWrapper.SearchDataWrapper rec, String searchTerm) {
		ExternalSearchWrapper.ItemWrapper itemWrapperObj = new ExternalSearchWrapper.ItemWrapper();
		NewsletterListingWrapper newsletterWrapperItem=new NewsletterListingWrapper();
		newsletterWrapperItem.newsletterId=rec.Id;
		
		itemWrapperObj.item = newsletterWrapperItem;

		return itemWrapperObj;
	}

	public ExternalSearchWrapper.TopContentsWrapper searchContents(Criteria.ExternalSearchReq contentCriteria, String SearchForType){
		logger.logDebug('ExternalSearchService.searchContents()----contentCriteria----' + contentCriteria);
		 
		List<ExternalSearchWrapper.AIResponse> topResultsWrapperList = new List<ExternalSearchWrapper.AIResponse>();
		Integer offset = 0; 

        if (contentCriteria.nextPageToken != null) {
           offset =  Integer.valueOf(contentCriteria.nextPageToken);
        }

        String searchResultJSON = getExternalSearchResults(contentCriteria.term, offset, searchForType, 
                contentCriteria.isCorrectionEnabled, contentCriteria.siteId, contentCriteria);
		
		ExternalSearchWrapper.AIResponse responseWrapperAI = (ExternalSearchWrapper.AIResponse)JSON.deserialize(searchResultJSON, ExternalSearchWrapper.AIResponse.class);
		resultWrapper = convertToWrapper(responseWrapperAI,searchForType,searchTerm);
		
        if (String.isNotBlank(responseWrapperAI.did_you_mean_term)) {
			resultWrapper.term = searchTerm;
		}

		if(contentCriteria.size != null) {
			resultWrapper.nextPageToken = ((responseWrapperAI.hits.start+Integer.valueOf(contentCriteria.size))<(responseWrapperAI.hits.total.value)) ? String.valueOf(responseWrapperAI.hits.start+Integer.valueOf(contentCriteria.size)):null;
		}

		return resultWrapper;
	}
	
	public ExternalSearchWrapper.TopContentsWrapper searchSites(Criteria.ExternalSearchReq siteCriteriaObj, 
            String SearchForType){
		logger.logDebug('ExternalSearchService.searchSites()----siteCriteriaObj----' + siteCriteriaObj);
		List<ExternalSearchWrapper.AIResponse> topResultsWrapperList = new List<ExternalSearchWrapper.AIResponse>();
		searchTerm = String.isBlank(siteCriteriaObj.term) ? '' : siteCriteriaObj.term;
		Integer offset = 0;  

        if (siteCriteriaObj.nextPageToken != null) {
           offset =  Integer.valueOf(siteCriteriaObj.nextPageToken);
        }

		String searchResultJSON = getExternalSearchResults(searchTerm, offset, searchForType, 
                siteCriteriaObj.isCorrectionEnabled, siteCriteriaObj.siteId, siteCriteriaObj);
		logger.logDebug('ExternalSearchService.searchSites()----searchResultJSON----' + searchResultJSON);
		ExternalSearchWrapper.AIResponse responseWrapperAI = (ExternalSearchWrapper.AIResponse)JSON.deserialize(searchResultJSON, ExternalSearchWrapper.AIResponse.class);
		resultWrapper = convertToWrapper(responseWrapperAI,searchForType,searchTerm);
         
        if (String.isNotBlank(responseWrapperAI.did_you_mean_term)){
			resultWrapper.term = searchTerm;
        }
		resultWrapper.nextPageToken = ((responseWrapperAI.hits.start+siteCriteriaObj.size)<(responseWrapperAI.hits.total.value)) ? String.valueOf(responseWrapperAI.hits.start+siteCriteriaObj.size):null;
		return resultWrapper;
	}

	public ExternalSearchWrapper.TopContentsWrapper searchChatterGroups(Criteria.ExternalSearchReq chatterGroupCriteriaObj, String SearchForType){

		List<ExternalSearchWrapper.AIResponse> topResultsWrapperList = new List<ExternalSearchWrapper.AIResponse>();
		searchTerm = String.isBlank(chatterGroupCriteriaObj.term) ? '' : chatterGroupCriteriaObj.term;
		Integer offset = 0;  

        if (chatterGroupCriteriaObj.nextPageToken != null) {
           offset =  Integer.valueOf(chatterGroupCriteriaObj.nextPageToken);
        }

		String searchResultJSON = getExternalSearchResults(searchTerm, offset, searchForType, 
			chatterGroupCriteriaObj.isCorrectionEnabled, chatterGroupCriteriaObj.siteId, chatterGroupCriteriaObj);
		logger.logDebug('ExternalSearchService.searchChatterGroups()----searchResultJSON----' + searchResultJSON);
		ExternalSearchWrapper.AIResponse responseWrapperAI = (ExternalSearchWrapper.AIResponse)JSON.deserialize(searchResultJSON, ExternalSearchWrapper.AIResponse.class);
		resultWrapper = convertToWrapper(responseWrapperAI,searchForType,searchTerm);
         
        if (String.isNotBlank(responseWrapperAI.did_you_mean_term)){
			resultWrapper.term = searchTerm;
        }
        
		resultWrapper.nextPageToken = ((responseWrapperAI.hits.start+chatterGroupCriteriaObj.size)<(responseWrapperAI.hits.total.value)) ? String.valueOf(responseWrapperAI.hits.start+chatterGroupCriteriaObj.size):null;
		return resultWrapper;
	}

	private List<ExternalSearchWrapper.ItemWrapper> convertToChatterGroupItemWrapperList(List<ExternalSearchWrapper.SearchDataWrapper> hitList, String searchTerm){
		List<ExternalSearchWrapper.ItemWrapper> listToReturn = new List<ExternalSearchWrapper.ItemWrapper>();
		ExternalSearchWrapper.ItemWrapper item;
			
		for(ExternalSearchWrapper.SearchDataWrapper hitObj : hitList){
			listToReturn.add(convertToChatterGroupItemWrapper(hitObj, searchTerm));
		}
		return listToReturn;
	}

	private ExternalSearchWrapper.ItemWrapper convertToChatterGroupItemWrapper(ExternalSearchWrapper.SearchDataWrapper hitObj, String searchTerm){
		ExternalSearchWrapper.ItemWrapper itemWrapperObj = new ExternalSearchWrapper.ItemWrapper();
		try{
			SiteListingWrapper siteWrapperObj = new SiteListingWrapper();
			
			siteWrapperObj.chatterGroupId = hitObj.chatter_group_id;
			siteWrapperObj.name = hitObj.site_name;
			siteWrapperObj.memberCount = hitObj.siteMemberCount;
			siteWrapperObj.access = hitObj.site_type;

			itemWrapperObj.relevancyScore = Double.valueOf(hitObj.score);
			itemWrapperObj.itemType = 'chatterGroup';
			itemWrapperObj.item = siteWrapperObj;
		}
		catch(Exception e) {			
		 	logger.logDebug(' e.getStackTraceString()	'+e.getStackTraceString());
		}
		return itemWrapperObj;
		
	}

	public ExternalSearchWrapper.TopContentsWrapper searchNativeVideos(Criteria.ExternalSearchReq fileCriteriaObj, 
			String SearchForType){
		Integer offset = 1;
		Integer counter = 0;

		if (fileCriteriaObj.nextPageToken != null && Integer.valueOf(fileCriteriaObj.nextPageToken) > 0) {
			offset =  Integer.valueOf(fileCriteriaObj.nextPageToken);
		}

		resultWrapper = searchNativeVideosChild(fileCriteriaObj, searchForType);

		// when records retrieved not equals page size , fetch more records
		// If nextpagetoken exists and records less than page size, get next page items, so that count exceeds page size
		// The following section will not be executed, if no orphan records exists in Kaltura.
		if(offset == 1){
			if(resultWrapper.nextPageToken != null && resultWrapper.listOfItems.size() < fileCriteriaObj.size){
				fileCriteriaObj.nextPageToken = resultWrapper.nextPageToken;
				offset =  Integer.valueOf(fileCriteriaObj.nextPageToken);
				resultWrapper = searchNativeVideosChild(fileCriteriaObj, searchForType);
				counter = counter + 1;
				logger.logDebug('ExternalSearchService.searchNativeVideos()----offset----' + offset);
			}
		}

		Boolean showPlusSymbol = (resultWrapper.nextPageToken == null && offset == (counter * fileCriteriaObj.size + 1)) ? false : true;
		if(!showPlusSymbol && resultWrapper.listOfItems.size() <= fileCriteriaObj.size){
			resultWrapper.totalRecords = resultWrapper.listOfItems.size() + '';
		}else{
			resultWrapper.totalRecords = fileCriteriaObj.size + '+';
		}

		return resultWrapper;
	}

	/**
	* @description search native videos
	* @param fileCriteriaObj criteria object from UI
	* @param searchForType search type nativevideo
	* @return records list 
	**/
	public ExternalSearchWrapper.TopContentsWrapper searchNativeVideosChild(Criteria.ExternalSearchReq fileCriteriaObj, String searchForType){

		logger.logDebug('ExternalSearchService.searchNativeVideos()----fileCriteriaObj----' + fileCriteriaObj);
		List<ExternalSearchWrapper.AIResponse> topResultsWrapperList = new List<ExternalSearchWrapper.AIResponse>();
		searchTerm = String.isBlank(fileCriteriaObj.term) ? '' : EncodingUtil.urlEncode(fileCriteriaObj.term, 'UTF-8').replaceAll('\\+','%20');
		Integer offset = 1; 

		if (fileCriteriaObj.nextPageToken != null && Integer.valueOf(fileCriteriaObj.nextPageToken) > 0) {
			offset =  Integer.valueOf(fileCriteriaObj.nextPageToken);
		}

		String searchResultJSON = getExternalSearchResults(searchTerm, offset, searchForType, 
				fileCriteriaObj.isCorrectionEnabled, fileCriteriaObj.siteId, fileCriteriaObj); 
		logger.logDebug('ExternalSearchService.searchNativeVideos()----searchResultJSON----' + searchResultJSON);
		
		resultWrapper = convertNativeVideoResponseToWrapper(searchResultJSON, searchForType, searchTerm);
		resultWrapper.nextPageToken = (offset + fileCriteriaObj.size) > (Integer) resultWrapper.totalRecords ? null : offset + fileCriteriaObj.size + '';
		
		return resultWrapper;
	}

	/**
	 * @description search custom links using elastic search
	 * @param linkCriteriaObj
	 * @param searchForType
	 * @return topcontentwrapper
	 */
	public ExternalSearchWrapper.TopContentsWrapper searchLinks(Criteria.ExternalSearchReq linkCriteriaObj, String searchForType){
		logger.logDebug('ExternalSearchService.searchLinks()----linkCriteriaObj----' + linkCriteriaObj);
		List<ExternalSearchWrapper.AIResponse> topResultsWrapperList = new List<ExternalSearchWrapper.AIResponse>();
		searchTerm = String.isBlank(linkCriteriaObj.term) ? '' : linkCriteriaObj.term;
		Integer offset = 0; 

		if (linkCriteriaObj.nextPageToken != null && Integer.valueOf(linkCriteriaObj.nextPageToken) > 0) {
			offset =  Integer.valueOf(linkCriteriaObj.nextPageToken);
		}

		String searchResultJSON = getExternalSearchResults(searchTerm, offset, searchForType, 
			linkCriteriaObj.isCorrectionEnabled, linkCriteriaObj.siteId, linkCriteriaObj); 
		logger.logDebug('ExternalSearchService.searchLinks()----searchResultJSON----' + searchResultJSON);

		ExternalSearchWrapper.AIResponse responseWrapperAI = (ExternalSearchWrapper.AIResponse)JSON.deserialize(searchResultJSON, ExternalSearchWrapper.AIResponse.class);
		resultWrapper = convertToWrapper(responseWrapperAI, SearchForType, searchTerm);
		resultWrapper.nextPageToken = (offset + linkCriteriaObj.size) > (Integer) resultWrapper.totalRecords ? null : offset + linkCriteriaObj.size + '';

		return resultWrapper;
	}

	private List<ExternalSearchWrapper.ItemWrapper> convertToLinksItemWrapperList(List<ExternalSearchWrapper.SearchDataWrapper> hitList) {
		List<ExternalSearchWrapper.ItemWrapper> listToReturn = new List<ExternalSearchWrapper.ItemWrapper>();
		for(ExternalSearchWrapper.SearchDataWrapper hitObj : hitList){
			listToReturn.add(convertLinksResponseToItemWrapper(hitObj));
		}
		return listToReturn;
	}

	/**
	 * @description search tiles data using elastic search
	 * @param tileCriteriaObj for externalsearch
	 * @param searchForType object type for search
	 * @return topcontentwrapper
	 */
	public ExternalSearchWrapper.TopContentsWrapper searchTiles(Criteria.ExternalSearchReq tileCriteriaObj, 
			String searchForType){

		logger.logDebug('ExternalSearchService.searchTiles()----tileCriteriaObj----' + tileCriteriaObj);
		List<ExternalSearchWrapper.AIResponse> topResultsWrapperList = new List<ExternalSearchWrapper.AIResponse>();
		searchTerm = String.isBlank(tileCriteriaObj.term) ? '' : tileCriteriaObj.term;
		Integer offset = 0; 

		if (tileCriteriaObj.nextPageToken != null && Integer.valueOf(tileCriteriaObj.nextPageToken) > 0) {
			offset =  Integer.valueOf(tileCriteriaObj.nextPageToken);
		}

		String searchResultJSON = getExternalSearchResults(searchTerm, offset, searchForType, 
				tileCriteriaObj.isCorrectionEnabled, tileCriteriaObj.siteId, tileCriteriaObj); 
		logger.logDebug('ExternalSearchService.searchTiles()----searchResultJSON----' + searchResultJSON);

		ExternalSearchWrapper.AIResponse responseWrapperAI = (ExternalSearchWrapper.AIResponse)JSON.deserialize(searchResultJSON, ExternalSearchWrapper.AIResponse.class);
		resultWrapper = convertToWrapper(responseWrapperAI, SearchForType, searchTerm);
		resultWrapper.nextPageToken = (offset + tileCriteriaObj.size) > (Integer) resultWrapper.totalRecords ? null : offset + tileCriteriaObj.size + '';
		
		return resultWrapper;
	}

	private List<ExternalSearchWrapper.ItemWrapper> convertToTilesItemWrapperList(List<ExternalSearchWrapper.SearchDataWrapper> hitList) {
		List<ExternalSearchWrapper.ItemWrapper> listToReturn = new List<ExternalSearchWrapper.ItemWrapper>();
		for(ExternalSearchWrapper.SearchDataWrapper hitObj : hitList){
			listToReturn.add(convertTilesResponseToItemWrapper(hitObj));
		}
		return listToReturn;
	}
	
	/**
	 * @description search questions data using elastic search
	 * @param questionCriteriaObj for externalsearch
	 * @param searchForType object type for search
	 * @return topcontentwrapper
	 */
	public ExternalSearchWrapper.TopContentsWrapper searchQuestions(Criteria.ExternalSearchReq questionCriteriaObj, 
			String searchForType){

		logger.logDebug('ExternalSearchService.searchTiles()----questionCriteriaObj----' + questionCriteriaObj);
		List<ExternalSearchWrapper.AIResponse> topResultsWrapperList = new List<ExternalSearchWrapper.AIResponse>();
		searchTerm = String.isBlank(questionCriteriaObj.term) ? '' : questionCriteriaObj.term;
		Integer offset = 0; 

		if (questionCriteriaObj.nextPageToken != null && Integer.valueOf(questionCriteriaObj.nextPageToken) > 0) {
			offset =  Integer.valueOf(questionCriteriaObj.nextPageToken);
		}

		String searchResultJSON = getExternalSearchResults(searchTerm, offset, searchForType, 
				questionCriteriaObj.isCorrectionEnabled, questionCriteriaObj.siteId, questionCriteriaObj); 
		logger.logDebug('ExternalSearchService.searchTiles()----searchResultJSON----' + searchResultJSON);

		ExternalSearchWrapper.AIResponse responseWrapperAI = (ExternalSearchWrapper.AIResponse)JSON.deserialize(searchResultJSON, ExternalSearchWrapper.AIResponse.class);
		resultWrapper = convertToWrapper(responseWrapperAI, SearchForType, searchTerm);
		resultWrapper.nextPageToken = (offset + questionCriteriaObj.size) > (Integer) resultWrapper.totalRecords ? null : offset + questionCriteriaObj.size + '';
		
		return resultWrapper;
	}

	private List<ExternalSearchWrapper.ItemWrapper> convertToQuestionItemWrapperList(List<ExternalSearchWrapper.SearchDataWrapper> hitList) {
		List<ExternalSearchWrapper.ItemWrapper> listToReturn = new List<ExternalSearchWrapper.ItemWrapper>();
		for(ExternalSearchWrapper.SearchDataWrapper hitObj : hitList){
			listToReturn.add(convertQuestionResponseToItemWrapper(hitObj));
		}
		return listToReturn;
	}

	private ExternalSearchWrapper.ItemWrapper convertLinksResponseToItemWrapper(ExternalSearchWrapper.SearchDataWrapper hitObj){
		ExternalSearchWrapper.ItemWrapper itemWrapperObj = new ExternalSearchWrapper.ItemWrapper();
		ManageApplicationWrapper.CheckboxLink wrapperObj = new ManageApplicationWrapper.CheckboxLink();
		wrapperObj.id = hitObj.id;
		wrapperObj.name = hitObj.links_label;
		wrapperObj.url = hitObj.original_links_url;
		itemWrapperObj.relevancyScore = Double.valueOf(hitObj.score);
		itemWrapperObj.itemType = 'link';
		itemWrapperObj.item = wrapperObj;

		return itemWrapperObj;
	}

	private ExternalSearchWrapper.ItemWrapper convertTilesResponseToItemWrapper(ExternalSearchWrapper.SearchDataWrapper hitObj){
		ExternalSearchWrapper.ItemWrapper itemWrapperObj = new ExternalSearchWrapper.ItemWrapper();
		TileDataWrapper.TileData wrapperObj = new TileDataWrapper.TileData();
		wrapperObj.id = hitObj.id;
		wrapperObj.title = hitObj.tile_title;
		wrapperObj.description = hitObj.tile_description;
		wrapperObj.type = hitObj.tile_type;
		wrapperObj.variant = hitObj.tile_variant;
		wrapperObj.location = hitObj.tile_location;
		if(hitObj.tile_link_items != null) {
			wrapperObj.links = new List<TileDataWrapper.TileData>();
			for(ExternalSearchWrapper.TilesLinkItem linkItem : hitObj.tile_link_items) {
				TileDataWrapper.TileData linkData = new TileDataWrapper.TileData();
				linkData.url = linkItem.link_url;
				linkData.text = linkItem.link_text;
				wrapperObj.links.add(linkData);
			}
		}
		wrapperObj.siteId = hitObj.site;
		if(String.isNotBlank(hitObj.site)){
			wrapperObj.site = new SiteLiteWrapper();
			wrapperObj.site.siteId = hitObj.site;
			wrapperObj.site.name = hitObj.site_r_name;
			wrapperObj.site.access = hitObj.site_r_site_type;
			wrapperObj.site.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + hitObj.site + '/' + hitObj.site_r_landing_page;
			wrapperObj.site.img = String.isNotBlank(hitObj.site_r_title_content_version) ? Utility.getFileDownloadURLFor720By480(hitObj.site_r_title_content_version) : null;
			wrapperObj.site.imgThumbnail = String.isNotBlank(hitObj.site_r_title_content_version) ? Utility.getFileDownloadURLFor120BY90(hitObj.site_r_title_content_version) : null;
		}
		itemWrapperObj.relevancyScore = Double.valueOf(hitObj.score);
		itemWrapperObj.itemType = 'tile';
		itemWrapperObj.item = wrapperObj;

		return itemWrapperObj;
	}
	
	private ExternalSearchWrapper.ItemWrapper convertQuestionResponseToItemWrapper(ExternalSearchWrapper.SearchDataWrapper hitObj){
		ExternalSearchWrapper.ItemWrapper itemWrapperObj = new ExternalSearchWrapper.ItemWrapper();
		QuestionWrapper wrapperObj = new QuestionWrapper();
		wrapperObj.id = hitObj.id;
		wrapperObj.questionId = hitObj.id;
		wrapperObj.title = hitObj.question_title;
		wrapperObj.isDuplicate = hitObj.is_duplicate;
		if(String.isNotBlank(hitObj.question_description)) {
			wrapperObj.body = hitObj.question_description;
			wrapperObj.description = hitObj.question_description;
		}
		wrapperObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + hitObj.site + '/questions/' + hitObj.id;
		wrapperObj.siteId = hitObj.site;
		wrapperObj.answersCount = hitObj.answer_count;
		wrapperObj.hasApprovedAnswer = hitObj.has_approved_answer;
		if(String.isNotBlank(hitObj.site)){
			wrapperObj.site = new SiteLiteWrapper();
			wrapperObj.site.siteId = hitObj.site;
			wrapperObj.site.name = hitObj.site_r_name;
			if(String.isNotBlank(hitObj.site_r_title_content_document)) {
				wrapperObj.site.imgContentDocumentId = hitObj.site_r_title_content_document;
			}
			wrapperObj.site.access = hitObj.site_r_site_type;
			wrapperObj.site.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + hitObj.site + '/' + hitObj.site_r_landing_page;
			wrapperObj.site.img = String.isNotBlank(hitObj.site_r_title_content_version) ? Utility.getFileDownloadURLFor720By480(hitObj.site_r_title_content_version) : null;
			wrapperObj.site.imgThumbnail = String.isNotBlank(hitObj.site_r_title_content_version) ? Utility.getFileDownloadURLFor120BY90(hitObj.site_r_title_content_version) : null;
		}
		if(String.isNotBlank(hitObj.content_r_id)) {
			wrapperObj.content = new ContentWrapper();
			wrapperObj.content.id = hitObj.content_r_id;
			wrapperObj.content.contentId = hitObj.content_r_id;
			wrapperObj.content.type = hitObj.content_r_type?.toLowerCase();
			wrapperObj.content.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + hitObj.site + '/' + wrapperObj.content.type + '/' + hitObj.content_r_id;
			wrapperObj.content.title = hitObj.content_r_title;
		}
		if(String.isNotBlank(hitObj.questioned_by)){
			wrapperObj.askedBy = new PeopleLiteWrapper();
			wrapperObj.askedBy.id = hitObj.questioned_by;
			wrapperObj.askedBy.peopleId = hitObj.questioned_by;
			wrapperObj.askedBy.name = hitObj.questioned_by_r_name;
			wrapperObj.askedBy.url = PageContext.getPageURL(Pages.app) +'?u=/people/' + hitObj.questioned_by;
		}
		itemWrapperObj.relevancyScore = Double.valueOf(hitObj.score);
		itemWrapperObj.itemType = 'question';
		itemWrapperObj.item = wrapperObj;

		return itemWrapperObj;
	}
	
	public ExternalSearchWrapper.TopContentsWrapper searchFiles(Criteria.ExternalSearchReq fileCriteriaObj, String SearchForType) {
		logger.logDebug('ExternalSearchService.searchFiles()----fileCriteriaObj----' + fileCriteriaObj);
		List<ExternalSearchWrapper.AIResponse> topResultsWrapperList = new List<ExternalSearchWrapper.AIResponse>();
		Integer offset = 0;  

        if (fileCriteriaObj.nextPageToken != null) {
           offset =  Integer.valueOf(fileCriteriaObj.nextPageToken);
        }

		String searchResultJSON = getExternalSearchResults(fileCriteriaObj.term, offset, searchForType, 
                fileCriteriaObj.isCorrectionEnabled, fileCriteriaObj.siteId, fileCriteriaObj); 
		logger.logDebug('ExternalSearchService.searchFiles()----searchResultJSON----' + searchResultJSON);
		ExternalSearchWrapper.AIResponse responseWrapperAI = (ExternalSearchWrapper.AIResponse)JSON.deserialize(searchResultJSON, ExternalSearchWrapper.AIResponse.class);
		resultWrapper = convertToWrapper(responseWrapperAI,searchForType,searchTerm);
		if(String.isNotBlank(responseWrapperAI.did_you_mean_term)){
			resultWrapper.term = searchTerm;
		}
		resultWrapper.nextPageToken = ((responseWrapperAI.hits.start+fileCriteriaObj.size)<(responseWrapperAI.hits.total.value)) ? String.valueOf(responseWrapperAI.hits.start+fileCriteriaObj.size):null;
		return resultWrapper;
	}

	public ExternalSearchWrapper.TopContentsWrapper searchEFSFiles(Criteria.File fileCriteriaObj, String SearchForType){
		logger.logDebug('ExternalSearchService.searchEFSFiles()----fileCriteriaObj----' + fileCriteriaObj);
		resultWrapper = new ExternalSearchWrapper.TopContentsWrapper();

		if (fileCriteriaObj.nextPageToken == null) {
			fileCriteriaObj.offset = 0;
			
		} else if(fileCriteriaObj.nextPageToken.isNumeric()) {
			fileCriteriaObj.offset = Integer.valueOf(fileCriteriaObj.nextPageToken);
		}
		
		// Populate the ItemList with GlobalSearchService resp
		resultWrapper.listOfItems = new List<ExternalSearchWrapper.ItemWrapper>();
		GlobalSearchService gsService = new GlobalSearchService();
		List<FileListingWrapper> results;
		
		if('BoxFile'.equalsIgnoreCase(SearchForType)){
			results = gsService.searchBoxFiles(fileCriteriaObj);	
			
		} else if('CrmFile'.equalsIgnoreCase(SearchForType)){
			results = gsService.searchCrmFiles(fileCriteriaObj);	
			
		} else {
			results = gsService.searchEFSFiles(fileCriteriaObj);
		}

		if(ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING.equalsIgnoreCase(fileCriteriaObj.provider) || 
			ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(fileCriteriaObj.provider) ||
			ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING.equalsIgnoreCase(fileCriteriaObj.provider) ||
			ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(fileCriteriaObj.provider)) {					
			resultWrapper.totalRecords = GlobalSearchService.totalMSResults != null ? GlobalSearchService.totalMSResults : 0; 

		} else {
			resultWrapper.totalRecords = GlobalSearchService.totalResults != null ? GlobalSearchService.totalResults : 0; 
		}
		
		for(FileListingWrapper fw: results) {
			 ExternalSearchWrapper.ItemWrapper itemObj = new ExternalSearchWrapper.ItemWrapper();
			 itemObj.item = fw;
			 itemObj.itemType = 'file';
			 itemObj.relevancyScore = 0;
			 resultWrapper.listOfItems.add(itemObj);
		}
		
		if(GlobalSearchService.nextPageToken != null) {
			resultWrapper.nextPageToken = GlobalSearchService.nextPageToken;
		
		} else if(resultWrapper.listOfItems.size() > fileCriteriaObj.size && fileCriteriaObj.offset < 2000) {
        	//resultWrapper.listOfItems.remove((resultWrapper.listOfItems.size()-1));
        	resultWrapper.nextPageToken = String.valueOf(fileCriteriaObj.offset + fileCriteriaObj.size);
        } else {
        	resultWrapper.nextPageToken = null;
        }
        
		return resultWrapper;
	}
	
	public List<AutoCompleteWrapper> searchAutoComplete(String term) {
		List<AutoCompleteWrapper> listOfAutoCompleteWrapper = new List<AutoCompleteWrapper>();
		List<String> allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).replace('Blog', 'BlogPost').split(','); 
		searchTerm = term;
		
		String resultJSON = getAutoCompleteResults(term);
		logger.logDebug('ExternalSearchService.searchAutoComplete()----resultJSON----' + resultJSON);
		ExternalSearchWrapper.AutoCompleteResponse responseWrapperAI  = (ExternalSearchWrapper.AutoCompleteResponse)JSON.deserialize(resultJSON, ExternalSearchWrapper.AutoCompleteResponse.class);
		if('success'.equalsIgnoreCase(responseWrapperAI.status)) {
			listOfAutoCompleteWrapper = convertToAutoCompleteWrapper(responseWrapperAI);
		} else {
			logger.logDebug('ExternalSearchService.searchAutoComplete()----message----' + responseWrapperAI.message);
			logger.logDebug('ExternalSearchService.searchAutoComplete()----exception_traceback----' + responseWrapperAI.exception_traceback);
			throw new SimpplrException(responseWrapperAI.message);
		}
		return listOfAutoCompleteWrapper;
	}
	
	private List<AutoCompleteWrapper> convertToAutoCompleteWrapper(ExternalSearchWrapper.AutoCompleteResponse responseWrapperAI){
		List<AutoCompleteWrapper> listOfAutoCompleteWrapper = new List<AutoCompleteWrapper>();  
		
		for(ExternalSearchWrapper.SearchDataWrapper rec : responseWrapperAI.matches){
			AutoCompleteWrapper wrapperObj = new AutoCompleteWrapper();

			wrapperObj.id = rec.id;
			wrapperObj.title = rec.title;
			wrapperObj.aws_score = rec.score;
			if('Content'.equalsIgnoreCase(rec.object_type)){
				wrapperObj.type = rec.type;
				wrapperObj.resourceType = 'content';
				wrapperObj.isMustRead = Boolean.valueOf(rec.is_must_read);
				wrapperObj.authoredBy = new PeopleLiteWrapper();
				wrapperObj.authoredBy.id = rec.primary_author;
				wrapperObj.authoredBy.name = rec.primary_author_r_name;
				if(ServiceConstants.TYPE_PAGE.equalsIgnoreCase(rec.type)){
					wrapperObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+rec.site+'/page/'+rec.id;
				
				}else if(ServiceConstants.TYPE_EVENT.equalsIgnoreCase(rec.type)){
			    	 wrapperObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+rec.site+'/event/'+rec.id;
			    	 wrapperObj.startsAt = EmailUtility.getFormattedDate(DateTime.ValueofGMT(rec.event_start_datetime.replace('T', ' ')),'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ',UserContext.timeZoneName);
			    }else if(ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(rec.type)){
					 wrapperObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+rec.site+'/album/'+rec.id;
			    
			    }else if(ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(rec.type)){
					 wrapperObj.url = PageContext.getPageURL(Pages.app)+'?u=/people/'+rec.primary_author+'/blog/'+rec.id;
			   }
			   
			   if(ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(rec.type)) {
			   		wrapperObj.img = rec.img;
			   } else {
					if(String.isNotBlank(rec.img)) {
						wrapperObj.img = Utility.getFileDownloadURLFor240BY180(rec.img);
					} else if(String.isNotBlank(rec.site_r_title_content_version)) {
						wrapperObj.img = Utility.getFileDownloadURLFor240BY180(rec.site_r_title_content_version);
					} else {
						wrapperObj.img = null;
					}
			   }			   
				wrapperObj.imgContentDocumentId  = rec.imgContentDocumentId; 
				wrapperObj.siteTitleContentDocumentId = rec.site_r_title_content_document;
				
			} else if('People'.equalsIgnoreCase(rec.object_type)){
				wrapperObj.name = rec.name;
				wrapperObj.type = 'person';
				wrapperObj.resourceType = 'person';
				wrapperObj.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + rec.id;
				wrapperObj.img = rec.img;
				
			} else if('Site'.equalsIgnoreCase(rec.object_type)){
				wrapperObj.name = rec.site_name;
				wrapperObj.type = 'site';
				wrapperObj.resourceType = 'site';
				wrapperObj.access = rec.site_type;
				if(String.isNotBlank(rec.title_content_version)) {
					wrapperObj.imgContentDocumentId = rec.title_content_document;
					wrapperObj.img = Utility.getFileDownloadURLFor720By480(rec.title_content_version);
				}
				wrapperObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + rec.id + '/' + rec.landing_page;
			
			} else if('NativeVideo'.equalsIgnoreCase(rec.object_type)){
				wrapperObj.name = rec.title;
				wrapperObj.type = 'native_video';
				wrapperObj.resourceType = 'native_video';
				wrapperObj.url = PageContext.getPageURL(Pages.app) +'?u=/video/' + rec.id;
				wrapperObj.img = rec.img;
			}  else if('Links'.equalsIgnoreCase(rec.object_type)){
				wrapperObj.name = rec.links_label;
				wrapperObj.title = rec.links_label;
				wrapperObj.type = 'link';
				wrapperObj.resourceType = 'link';
				wrapperObj.url = rec.original_links_url;
			} else if('Tiles'.equalsIgnoreCase(rec.object_type)){
				wrapperObj.name = rec.tile_title;
				wrapperObj.title = rec.tile_title;
				wrapperObj.type = 'Site Dashboard'.equalsIgnoreCase(rec.tile_location) ? (rec.site_r_name + ' dashboard') : 'Home dashboard';
				wrapperObj.resourceType = 'tile';
				wrapperObj.siteId = rec.site;
				wrapperObj.url = PageContext.getPageURL(Pages.app);
				if(String.isNotBlank(rec.site)) {
					wrapperObj.site = new SiteLiteWrapper();
					wrapperObj.site.siteId = rec.site;
					wrapperObj.site.name = rec.site_r_name;
					wrapperObj.site.img = String.isNotBlank(rec.site_r_title_content_version) ? Utility.getFileDownloadURLFor720By480(rec.site_r_title_content_version) : null;
					wrapperObj.site.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + rec.site + '/';
				}
			} else if('Question'.equalsIgnoreCase(rec.object_type)){
				wrapperObj.name = rec.question_title;
				wrapperObj.title = rec.question_title;
				wrapperObj.type = 'Question';
				wrapperObj.resourceType = 'question';
				wrapperObj.siteId = rec.site;
				wrapperObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + rec.site + '/questions/' + rec.id;
				if(String.isNotBlank(rec.site)) {
					wrapperObj.site = new SiteLiteWrapper();
					wrapperObj.site.siteId = rec.site;
					wrapperObj.site.name = rec.site_r_name;
					if(String.isNotBlank(rec.site_r_title_content_document)) {
						wrapperObj.imgContentDocumentId = rec.site_r_title_content_document;
					}
					wrapperObj.site.img = String.isNotBlank(rec.site_r_title_content_version) ? Utility.getFileDownloadURLFor720By480(rec.site_r_title_content_version) : null;
					wrapperObj.site.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + rec.site + '/';
				}
			}
			listOfAutoCompleteWrapper.add(wrapperObj);
		}  	
		return listOfAutoCompleteWrapper;
	}

	private String getAutoCompleteResults(String term){
		String responseObj ='';
		Set<String> setOfChatterGroupIds = new Set<String>();
		String userId = UserContext.Id;
		
		String queryStr  = 'select CollaborationGroupId from CollaborationGroupMember where MemberId=:userId and (CollaborationGroup.CollaborationType = \'Private\' or CollaborationGroup.CollaborationType = \'Unlisted\') ';
		if (SimpplrContext.isCommunitiesEnabled) {
			queryStr = queryStr + ' AND CollaborationGroup.NetworkId = null';
		}
		List<CollaborationGroupMember> cGrpMemList = Database.query(queryStr); 
			
		for (CollaborationGroupMember cGrpMem : cGrpMemList) {
			setOfChatterGroupIds.add(cGrpMem.CollaborationGroupId);
		}

		Map<String, Object> requestBody = new Map<String, Object>();
		List<String> listOfAllowedFeatures = String.valueOf(SimpplrContext.AllowedFeatures).replace('Blog', 'BlogPost').split(',');
		
		requestBody.put('chatterGroupIds', setOfChatterGroupIds);
		requestBody.put('peopleId', UserContext.peopleId);
		requestBody.put('userId', UserContext.userId);
		requestBody.put('pplSegmentId', UserContext.segmentId);
		requestBody.put('department', UserContext.getUsersDepartmentDetail);
		requestBody.put('people_category ', UserContext.getUserCategory);
		requestBody.put('listOfAllowedFeatures', listOfAllowedFeatures);
		requestBody.put('is_system_admin', UserContext.hasModifyAllDataPermission);
		requestBody.put('is_unlisted_manager',UserContext.hasManageUnlistedSitePermission);
		requestBody.put('app_dashboard', SimpplrContext.AppDashboardMode);
		requestBody.put('search_links_in_segment', SimpplrContext.isSegmentsEnabled && SimpplrContext.isSegmentAppsNLinksEnabled);
		requestBody.put('question_answer_enabled', SimpplrContext.isQuestionAnswerEnabled);

		String termAndToken = EncodingUtil.urlEncode(term, 'UTF-8').replaceAll('\\+','%20');
        String externalEndPoint = SimpplrContext.simpplrAPIEndpoint + '/seps' + '/autocomplete?q='+termAndToken;
        String simpDri = Utility.externalRequestAuthToken() + 
                ' ' + SimpplrContext.simpplrOrgId.substring(0, 15) +
                ' ' + UserContext.userId.substring(0, 15);
		HttpRequest req = new HttpRequest();
		req.setEndpoint(externalEndPoint); 
		req.setMethod('POST');
		req.setBody(Json.serialize(requestBody));
		req.setTimeout(60000);
		req.setHeader('simpplr-dri', simpDri);
		
		logger.logDebug('endpoint => ' + externalEndPoint);
		logger.logDebug('request body => ' + Json.serialize(requestBody));
		Http http = new Http();
		HTTPResponse res = http.send(req);
		
		if(res.getStatusCode() == 200){
			responseObj = res.getBody();
		} else if (res.getStatusCode() == 403){
			throw new SimpplrException(ServiceConstants.ERROR_403);
		} else if (res.getStatusCode() == 404){
			throw new SimpplrException(ServiceConstants.ERROR_404);
		} else if (res.getStatusCode() == 500){
			throw new SimpplrException(ServiceConstants.ERROR_500);
		}
		return responseObj;
		
	}
 
	private String getExternalSearchResults(String term, Integer offset, String SearchForType, Boolean isCorrectionEnabled, String siteId, 
			Criteria.ExternalSearchReq filterObj) {
		String externalEndPoint = SimpplrContext.simpplrAPIEndpoint + '/seps';
		String termAndToken = '';
		if(String.isNotBlank(term)) {
			termAndToken = EncodingUtil.urlEncode(term, 'UTF-8').replaceAll('\\+','%20');
		}

		List<String> chatterGroupIds= new List<String>();
		List<String> contentIds = new List<String>();
		String userId = UserContext.Id;
		String responseObj ='';
		Set<String> setOfChatterGroupIds = new Set<String>();
		
		if (String.isNotBlank(siteId)) {
			Simpplr_Site__c siteObj = [SELECT Chatter_Group_id__c FROM Simpplr_Site__c where id=:siteId WITH SECURITY_ENFORCED];
			setOfChatterGroupIds.add(siteObj.Chatter_Group_id__c);
		
		} else {
			String queryStr  = 'select CollaborationGroupId from CollaborationGroupMember where MemberId=:userId and (CollaborationGroup.CollaborationType = \'Private\' or CollaborationGroup.CollaborationType = \'Unlisted\') ';
			if (SimpplrContext.isCommunitiesEnabled) {
				queryStr = queryStr + ' AND CollaborationGroup.NetworkId = null';
			}
			List<CollaborationGroupMember> cGrpMemList = Database.query(queryStr); 
			
			for (CollaborationGroupMember cGrpMem : cGrpMemList) {
				setOfChatterGroupIds.add(cGrpMem.CollaborationGroupId);
			}
		}
		
		Map<String, Object> requestBody = new Map<String, Object>();
		List<String> listOfAllowedFeatures = String.valueOf(SimpplrContext.AllowedFeatures).replace('Blog', 'BlogPost').split(',');
		requestBody.put('chatterGroupIds', setOfChatterGroupIds);
		requestBody.put('peopleId', UserContext.peopleId);
		requestBody.put('userId', UserContext.userId);
		requestBody.put('pplSegmentId', UserContext.segmentId);
		requestBody.put('department', UserContext.getUsersDepartmentDetail);
		requestBody.put('people_category', UserContext.getUserCategory);
		requestBody.put('listOfAllowedFeatures', listOfAllowedFeatures);
		requestBody.put('site_id', siteId);
		requestBody.put('is_system_admin', UserContext.hasModifyAllDataPermission);
		requestBody.put('is_unlisted_manager',UserContext.hasManageUnlistedSitePermission);
		requestBody.put('is_app_manager', UserContext.isUserAppModerator);
		requestBody.put('question_answer_enabled', SimpplrContext.isQuestionAnswerEnabled);
		requestBody.put('user_city', UserContext.city);
		requestBody.put('user_state', UserContext.state);
		requestBody.put('user_country', UserContext.country);
		
        if (filterObj.siteId != null) {
            requestBody.put('site', filterObj.siteId);

		} 
		
		if (filterObj.site != null) {
            requestBody.put('site', filterObj.site);

        } 
        
		if (filterObj.contentType != null) {
            requestBody.put('contentType', filterObj.contentType);

        } 
        
        if (filterObj.author != null) {
            requestBody.put('author', filterObj.author);

		}
		//SV2-40959 change topic from array to string 
        if (filterObj.topicId != null) {
            requestBody.put('topicId', filterObj.topicId);

		}

		if (filterObj.canManage != null) {
			List<Id> groupsIManageIdList = new List<Id>();
			if (UserContext.isUserAppModerator) {
				SiteDao daoObj = new SiteDao();
				groupsIManageIdList = daoObj.getListOfAppMgrOrSysAdmManagableCollaborationGroupIds();
			}
			else {
				Set<Id> groupsIContentManageIdList = new Set<Id>();
				for(Simpplr_Site__c site :UserContext.sitesIManageContentsMap.values())
				{
					groupsIContentManageIdList.add(site.chatter_Group_Id__c);
				}
				Set<Id> groupsIManageIdSet =  UserContext.groupsIManageIdSet;	
				groupsIManageIdList.addAll(groupsIManageIdSet);
				groupsIManageIdList.addAll(groupsIContentManageIdList);
			}
			requestBody.put('groups_i_manage_ids', groupsIManageIdList);
			requestBody.put('app_manager', UserContext.isUserAppModerator);
			requestBody.put('unlisted_manager', UserContext.hasManageUnlistedSitePermission);
			requestBody.put('canManage', filterObj.canManage);				
		}

		if (filterObj.filter != null){
			requestBody.put('filter', filterObj.filter);
		}

		if (filterObj.isPrivate != null){
			requestBody.put('isPrivate', filterObj.isPrivate);
		}

		if (filterObj.favouriteIds != null){
			requestBody.put('favourite_ids', filterObj.favouriteIds);
		}

		
		if (filterObj.provider != null){
			requestBody.put('provider', filterObj.provider);
		}

		if (filterObj.category != null){
			requestBody.put('category', filterObj.category);
		}

        if (filterObj.publishStartDate != null && 
                !'anytime'.equalsIgnoreCase(filterObj.publishStartDate)) {
            DateTime tempDateToPass;

            if (filterObj.publishStartDate.equalsIgnoreCase('past_24_hours')) {
                tempDateToPass = System.now().addHours(-24);

            } else if (filterObj.publishStartDate.equalsIgnoreCase('past_week')) {
                tempDateToPass = System.now().addDays(-7);

            } else if (filterObj.publishStartDate.equalsIgnoreCase('past_month')) {
                 tempDateToPass = System.now().addMonths(-1);

            } else if (filterObj.publishStartDate.equalsIgnoreCase('past_year')) {
                tempDateToPass = System.now().addYears(-1);
            }
			if ('NativeVideo'.equalsIgnoreCase(SearchForType)){
				requestBody.put('publishStartDate', tempDateToPass.getTime() / 1000);
			} else {
				requestBody.put('publishStartDate', tempDateToPass.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
			}
        }

        if (String.isNotBlank(filterObj.department)) {
            requestBody.put('department_filter', filterObj.department);

        }
        
		if (String.isNotBlank(filterObj.userCategory)) {
			if(ServiceConstants.UNCATEGORIZED_CATEGORY_STR.equalsIgnoreCase(filterObj.userCategory) || (filterObj.userCategory).equals('all')) {
				requestBody.put('people_category_filter', null);
			} else {
				requestBody.put('people_category_filter', filterObj.userCategory);
			}
		}

        if (String.isNotBlank(filterObj.location)) {
            List<String> locationArr = filterObj.location.split(' @@ ');
            
            if (locationArr[0] != 'null') {
                requestBody.put('city', locationArr[0]);
            } 
            
            if (locationArr[1] != 'null') {
                requestBody.put('state', locationArr[1]); 
            } 
            
            if (locationArr[2] != 'null') {
                requestBody.put('country', locationArr[2]);
            } 

		}
		
		if (filterObj.expertise != null) {
            requestBody.put('expertise', filterObj.expertise.id);

        } 

		if (String.isNotBlank(filterObj.status)) {
            requestBody.put('content_status', filterObj.status);

        }

        if (String.isNotBlank(filterObj.eventOccurrence)) {
            requestBody.put('eventOccurrence', filterObj.eventOccurrence);

        }

        if (String.isNotBlank(filterObj.pageCategory)) {
            requestBody.put('pageCategory', filterObj.pageCategory);

        }

        if (String.isNotBlank(filterObj.contentSubType)) {
            requestBody.put('contentSubType', filterObj.contentSubType);

        }else{
			requestBody.put('contentSubType', null);
		}

        if (String.isNotBlank(filterObj.owner)) {
            requestBody.put('owner', filterObj.owner);

        }
         
        if (String.isNotBlank(filterObj.fileType)) {
            requestBody.put('fileExtension', SearchConstants.mapOfFileTypeToExtension.get(filterObj.fileType));
        }

        if (String.isNotBlank(filterObj.chatterGroupId)) {
            requestBody.put('chatterGroupIdFilter', filterObj.chatterGroupId);

        }

		if(filterObj.contentContributed != null) {
			for (String contentId : filterObj.contentContributed) {
				contentIds.add(contentId);
			}
		}

		if (String.isNotBlank(filterObj.duration)) {
			requestBody.put('duration', filterObj.duration);

		}

		requestBody.put('app_dashboard', SimpplrContext.AppDashboardMode);
		if(String.isNotBlank(filterObj.tileDashboard)) {
			requestBody.put('tile_filter', filterObj.tileDashboard);
		}

		if ('Top'.equalsIgnoreCase(SearchForType)){
			externalEndPoint = externalEndPoint + '/search?q='+termAndToken;
			requestBody.put('search_links_in_segment', SimpplrContext.isSegmentsEnabled && SimpplrContext.isSegmentAppsNLinksEnabled);
		
        } else if ('File'.equalsIgnoreCase(SearchForType)){
			externalEndPoint = externalEndPoint + '/search_files?q='+termAndToken+'&origin=H&global_search=false&start='+offset;
		
        } else if ('Alert'.equalsIgnoreCase(SearchForType)){
			externalEndPoint = externalEndPoint  + '/search?q='+termAndToken+'&start='+offset+'&object_type=Alert';
			Boolean canSendAlert =  userContext.isUserAppModerator || userContext.canSendAlerts;
			logger.logdebug('RECIPIENT***********'+filterObj.recipient);
			logger.logdebug('sortBy***********'+filterObj.sortBy);
			logger.logdebug('status***********'+filterObj.status);
			requestBody.put('org_id', UserInfo.getOrganizationId());
			requestBody.put('offset', offset);
			requestBody.put('is_app_manager', UserContext.isUserAppModerator);
			requestBody.put('can_send_alert', canSendAlert);
			if (String.isNotBlank(filterObj.status)) {
				requestBody.put('status', filterObj.status);
			}
			if (filterObj.siteSet != null && !(filterObj.siteSet).isEmpty()) {
				requestBody.put('site_list', filterObj.siteSet);
			}
			if (String.isNotBlank(filterObj.sortBy)) {
				requestBody.put('sort_by', filterObj.sortBy);
			}
			if(String.isNotBlank(filterObj.recipient)){
				requestBody.put('recipient', filterObj.recipient);
			} else {
				requestBody.put('recipient', 'any');
			}
			
			
			
        } else if ('NativeVideo'.equalsIgnoreCase(SearchForType)){
			externalEndPoint = SimpplrContext.simpplrAPIEndpoint + '/video/search-manager?';
			requestBody.put('orgId', UserInfo.getOrganizationId());
			requestBody.put('action', 'search');
			requestBody.put('offset', offset);
			requestBody.put('searchTerm', termAndToken);
			requestBody.put('pageSize', filterObj.size);

        } else if ('CrmFile'.equalsIgnoreCase(SearchForType)){
			externalEndPoint = externalEndPoint + '/search_files?q='+termAndToken+'&origin=C&global_search=false&start='+offset;
		
        } else if ('UserDepartment'.equalsIgnoreCase(SearchForType)){
			externalEndPoint = externalEndPoint  + '/search?q='+termAndToken+'&start='+offset+'&object_type=People&filter_field_name=department';
		
        } else if ('UserLocation'.equalsIgnoreCase(SearchForType)){
			externalEndPoint = externalEndPoint  + '/search?q='+termAndToken+'&start='+offset+'&object_type=People&filter_field_name=location';
		
        } else if ('Expertise'.equalsIgnoreCase(SearchForType)){
			externalEndPoint = externalEndPoint  + '/search?q='+termAndToken+'&start='+offset+'&object_type=Expertise&expertise_sort_order='+filterObj.order;

        } else if ('Newsletter'.equalsIgnoreCase(SearchForType)){
			Boolean canSendNewsletter= userContext.isUserAppModerator || userContext.canSendNewsletter;
			requestBody.put('org_id', UserInfo.getOrganizationId());
			requestBody.put('offset', offset);
			requestBody.put('is_app_manager', UserContext.isUserAppModerator);
			requestBody.put('can_send_newsletter', canSendNewsletter);
			if (String.isNotBlank(filterObj.status)) {
				requestBody.put('status', filterObj.status);
			}
			if (filterObj.siteSet != null && !(filterObj.siteSet).isEmpty()) {
				requestBody.put('site_list', filterObj.siteSet);
			}
			if (String.isNotBlank(filterObj.sortBy)) {
				requestBody.put('sortBy', filterObj.sortBy);
			}
			if(String.isNotBlank(filterObj.recipient)){
				requestBody.put('recipient', filterObj.recipient);
			} else {
				requestBody.put('recipient', 'any');
			}
			externalEndPoint = externalEndPoint  + '/search?q='+termAndToken+'&start='+offset+'&object_type='+SearchForType;

        } else if ('Topic'.equalsIgnoreCase(SearchForType)){
			externalEndPoint = externalEndPoint  + '/search?q='+termAndToken+'&start='+offset+'&object_type=Topic&topic_sortBy='+filterObj.sortBy;

        } else if ('Site_Category'.equalsIgnoreCase(SearchForType)){
			if(String.isNotBlank(termAndToken)) {
				externalEndPoint = externalEndPoint  + '/search?q='+termAndToken+'&start='+offset+'&object_type=Site_Category&site_category_sort_order='+filterObj.sortBy;
			} else {
				if(filterObj.size == 10000) {
					externalEndPoint = externalEndPoint  + '/search?object_type=Site_Category&site_category_sort_order='+filterObj.sortBy;
				} else {
					externalEndPoint = externalEndPoint  + '/search?start='+offset+'&object_type=Site_Category&site_category_sort_order='+filterObj.sortBy;
				}
			}

        } else if ('Content_Authored'.equalsIgnoreCase(SearchForType)) {
			requestBody.put('status', 'published');
			requestBody.put('sortBy', filterObj.sortBy);
			externalEndPoint = externalEndPoint  + '/content/publish-content/?q='+termAndToken+'&size=16&start='+offset;

        } else if ('Content'.equalsIgnoreCase(SearchForType) && 'favorites'.equalsIgnoreCase(filterObj.filter) ) {
			requestBody.put('type', filterObj.type);
			if(filterObj.ContentIds!= null){
                requestBody.put('favourite_ids', filterObj.ContentIds);
            }
			
			externalEndPoint = externalEndPoint  + '/search?q='+termAndToken+'&start='+offset+'&object_type='+SearchForType;
		
		} else if ('Content'.equalsIgnoreCase(SearchForType) ) {
			Set<Id> groupsIManageIdSet =  UserContext.groupsIManageIdSet;
			List<Id> groupsIManageIdList = new List<Id>();
			groupsIManageIdList.addAll(groupsIManageIdSet);

			Set<Id> groupsIContentManageIdList = new Set<Id>();
			for(Simpplr_Site__c site :UserContext.sitesIManageContentsMap.values())
			{
				groupsIContentManageIdList.add(site.chatter_Group_Id__c);
			}
			groupsIManageIdList.addAll(groupsIContentManageIdList);

			if(filterObj.source!= null){
                requestBody.put('source', filterObj.source);
            }
			requestBody.put('type', filterObj.type);
			if(filterObj.authorId!= null){
                requestBody.put('author', filterObj.authorId);
            }

			if (String.isNotBlank(filterObj.sortBy)) {
				requestBody.put('sortBy', filterObj.sortBy);
			}
			requestBody.put('groups_i_manage_ids', groupsIManageIdList);
			requestBody.put('is_app_manager',UserContext.isUserAppModerator);
	
			requestBody.put('validation_period', SimpplrContext.validationPeriodMonth);
			requestBody.put('manage_site_content_filter', filterObj.filter);
			if(!contentIds.isEmpty()) {
				requestBody.put('contentContributed', contentIds);
			}
			if(filterObj.ContentIds!= null){
                requestBody.put('id', filterObj.ContentIds);
            }
			
			externalEndPoint = externalEndPoint  + '/search?q='+termAndToken+'&start='+offset+'&object_type='+SearchForType;
		
		} else if ('ContentOnboarding'.equalsIgnoreCase(SearchForType) ) {
            Set<Id> myOnboardingContentIds = new Set<Id>();
            Set<Id> siteIds = new Set<Id>();
            List<Site_Role__c> siteRoleList = null;
            siteRoleList = UserContext.mySitesRolesList;
            for(Site_Role__c role:siteRoleList) {
                siteIds.add(role.Site__c);
            }
            String orgOnboarding = ServiceConstants.CONTENT_STATUS_ORG_ONBOARDING;
            String siteOnboarding = ServiceConstants.CONTENT_STATUS_SITE_ONBOARDING;
          	Map<Id, Simpplr_Content__c> myContentMap = new Map<Id, Simpplr_Content__c>([SELECT Id FROM Simpplr_Content__c WHERE Is_Published__c = true AND Is_Deleted__c = false AND (Content_Onboarding_Status__c = :orgOnboarding OR (Site__c IN :siteIds AND Content_Onboarding_Status__c = :siteOnboarding))]);
			requestBody.put('onboarding_content_ids', myContentMap.keySet());
			requestBody.put('onboarding_content_request',true);
			requestBody.put('sort_by', 'relevance');
			if('site'.equalsIgnoreCase(filterObj.sortBy)){
				requestBody.put('onboarding_content_search', false);
			} else {
				requestBody.put('onboarding_content_search', true);
			}
			
			externalEndPoint = externalEndPoint  + '/search?q='+termAndToken+'&start='+offset+'&object_type=Content';

		} else if ('Pages_Category'.equalsIgnoreCase(SearchForType)) {
			externalEndPoint = externalEndPoint  + '/search?q='+termAndToken+'&start='+offset+'&object_type='+SearchForType + '&pages_category_sort_order=newest';
			
        } else if ('Chatter_Group'.equalsIgnoreCase(SearchForType)) {
			externalEndPoint = externalEndPoint  + '/search?q='+termAndToken+'&start='+offset+'&object_type=chattergroup';
			
        } else if ('Audience_Field_Values'.equalsIgnoreCase(SearchForType)) {
			externalEndPoint = externalEndPoint  + '/people/get_field_data';

			requestBody.put('ppl_segment_id', filterObj.ppl_segment_id);
			requestBody.put('agg_field', filterObj.fieldName);
			
        } else if ('Links'.equalsIgnoreCase(SearchForType)) {
			externalEndPoint = externalEndPoint  + '/search?q='+termAndToken+'&start='+offset+'&object_type=Links';
			requestBody.put('search_links_in_segment', SimpplrContext.isSegmentsEnabled && SimpplrContext.isSegmentAppsNLinksEnabled);

		} else if ('Tiles'.equalsIgnoreCase(SearchForType)) {
			externalEndPoint = externalEndPoint  + '/search?q='+termAndToken+'&start='+offset+'&object_type=Tiles';

        } else if ('Content_Template'.equalsIgnoreCase(SearchForType)) {
			externalEndPoint = externalEndPoint  + '/search?q='+termAndToken+'&start='+offset+'&object_type='+SearchForType;
			requestBody.put('type', filterObj.type);
			requestBody.put('sortBy', filterObj.sortBy);

        } else if ('Question'.equalsIgnoreCase(SearchForType)) {
			externalEndPoint = externalEndPoint  + '/search?q='+termAndToken+'&start='+offset+'&object_type='+SearchForType;

		} else {
			// ToDo --- DS0001 - below 10 lines should be there only for user - inside if.. inside this else
			if ('Site'.equalsIgnoreCase(SearchForType) && ('canCreateNewsletter'.equalsIgnoreCase(filterObj.filter) || 'canCreateAlert'.equalsIgnoreCase(filterObj.filter) || (filterObj.canSubmitQuestion != null && filterObj.canSubmitQuestion))){
				requestBody.put('filter', filterObj.filter);
				Set<Id> groupsIManageIdSet =  UserContext.groupsIManageIdSet;
				requestBody.put('groups_i_manage_ids', groupsIManageIdSet);
				requestBody.put('can_send_newsletter', userContext.canSendNewsletter);
				requestBody.put('can_send_alert', userContext.canSendAlerts);
				requestBody.put('can_submit_question', filterObj.canSubmitQuestion);
			}
			
			String custom_field_1 = (filterObj.custom_field_1 == 'all' || filterObj.custom_field_1 == null) ? null : filterObj.custom_field_1;
			String custom_field_2 = (filterObj.custom_field_2 == 'all' || filterObj.custom_field_2 == null) ? null : filterObj.custom_field_2;
			String custom_field_3 = (filterObj.custom_field_3 == 'all' || filterObj.custom_field_3 == null) ? null : filterObj.custom_field_3;
			String custom_field_4 = (filterObj.custom_field_4 == 'all' || filterObj.custom_field_4 == null) ? null : filterObj.custom_field_4;
			String custom_field_5 = (filterObj.custom_field_5 == 'all' || filterObj.custom_field_5 == null) ? null : filterObj.custom_field_5;	
			String custom_field_6 = (filterObj.custom_field_6 == 'all' || filterObj.custom_field_6 == null) ? null : filterObj.custom_field_6;	
			String custom_field_7 = (filterObj.custom_field_7 == 'all' || filterObj.custom_field_7 == null) ? null : filterObj.custom_field_7;					
			String custom_field_8 = (filterObj.custom_field_8 == 'all' || filterObj.custom_field_8 == null) ? null : filterObj.custom_field_8;	
			String custom_field_9 = (filterObj.custom_field_9 == 'all' || filterObj.custom_field_9 == null) ? null : filterObj.custom_field_9;	
			String custom_field_10 = (filterObj.custom_field_10 == 'all' || filterObj.custom_field_10 == null) ? null : filterObj.custom_field_10;	
			String custom_field_11 = (filterObj.custom_field_11 == 'all' || filterObj.custom_field_11 == null) ? null : filterObj.custom_field_11;	
			String custom_field_12 = (filterObj.custom_field_12 == 'all' || filterObj.custom_field_12 == null) ? null : filterObj.custom_field_12;	
			String custom_field_13 = (filterObj.custom_field_13 == 'all' || filterObj.custom_field_13 == null) ? null : filterObj.custom_field_13;	
			String custom_field_14 = (filterObj.custom_field_14 == 'all' || filterObj.custom_field_14 == null) ? null : filterObj.custom_field_14;	
			String custom_field_15 = (filterObj.custom_field_15 == 'all' || filterObj.custom_field_15 == null) ? null : filterObj.custom_field_15;	
			String custom_field_16 = (filterObj.custom_field_16 == 'all' || filterObj.custom_field_16 == null) ? null : filterObj.custom_field_16;	
			String custom_field_17 = (filterObj.custom_field_17 == 'all' || filterObj.custom_field_17 == null) ? null : filterObj.custom_field_17;	
			String custom_field_18 = (filterObj.custom_field_18 == 'all' || filterObj.custom_field_18 == null) ? null : filterObj.custom_field_18;	
			String custom_field_19 = (filterObj.custom_field_19 == 'all' || filterObj.custom_field_19 == null) ? null : filterObj.custom_field_19;	
			String custom_field_20 = (filterObj.custom_field_20 == 'all' || filterObj.custom_field_20 == null) ? null : filterObj.custom_field_20;	
			String custom_field_21 = (filterObj.custom_field_21 == 'all' || filterObj.custom_field_21 == null) ? null : filterObj.custom_field_21;	
			String custom_field_22 = (filterObj.custom_field_22 == 'all' || filterObj.custom_field_22 == null) ? null : filterObj.custom_field_22;	
			String custom_field_23 = (filterObj.custom_field_23 == 'all' || filterObj.custom_field_23 == null) ? null : filterObj.custom_field_23;	
			String custom_field_24 = (filterObj.custom_field_24 == 'all' || filterObj.custom_field_24 == null) ? null : filterObj.custom_field_24;
			String custom_field_25 = (filterObj.custom_field_25 == 'all' || filterObj.custom_field_25 == null) ? null : filterObj.custom_field_25;

			requestBody.put('custom_field_1', custom_field_1);
			requestBody.put('custom_field_2', custom_field_2);
			requestBody.put('custom_field_3', custom_field_3);
			requestBody.put('custom_field_4', custom_field_4);
			requestBody.put('custom_field_5', custom_field_5);	
			requestBody.put('custom_field_6', custom_field_6);	
			requestBody.put('custom_field_7', custom_field_7);											
			requestBody.put('custom_field_8', custom_field_8);	
			requestBody.put('custom_field_9', custom_field_9);	
			requestBody.put('custom_field_10', custom_field_10);	
			requestBody.put('custom_field_11', custom_field_11);	
			requestBody.put('custom_field_12', custom_field_12);	
			requestBody.put('custom_field_13', custom_field_13);	
			requestBody.put('custom_field_14', custom_field_14);	
			requestBody.put('custom_field_15', custom_field_15);	
			requestBody.put('custom_field_16', custom_field_16);	
			requestBody.put('custom_field_17', custom_field_17);	
			requestBody.put('custom_field_18', custom_field_18);	
			requestBody.put('custom_field_19', custom_field_19);	
			requestBody.put('custom_field_20', custom_field_20);	
			requestBody.put('custom_field_21', custom_field_21);	
			requestBody.put('custom_field_22', custom_field_22);	
			requestBody.put('custom_field_23', custom_field_23);	
			requestBody.put('custom_field_24', custom_field_24);	
			requestBody.put('custom_field_25', custom_field_25);	

			SearchForType = 'User'.equalsIgnoreCase(SearchForType) ? 'People':SearchForType;

			externalEndPoint += '/search?start='+offset+'&object_type='+SearchForType;
			if(String.isNotBlank(termAndToken)) {
				externalEndPoint += '&q='+termAndToken;
				
			}
			
			String orderBy;
			if('hire_date'.equalsIgnoreCase(filterObj.sortBy)) {
				orderBy = 'joining_date';
				externalEndPoint += '&joiningDateInLastNDays=-999';

			} else if(String.isNotBlank(filterObj.sortBy)) {
				orderBy = filterObj.sortBy;
			
			} else if(String.isBlank(termAndToken)) {
				orderBy = 'alphabetical';	

			}

			if(String.isNotBlank(orderBy)) {
				externalEndPoint += '&order_by=' + orderBy;
			}
			if(String.isNotBlank(filterObj.ppl_segment_id)) {
				externalEndPoint += '&ppl_segment_id=' + filterObj.ppl_segment_id;
			}
		}

		if (isCorrectionEnabled == false){
			externalEndPoint += '&autocorrect=false';
		}

        if (String.isNotBlank(filterObj.requestType)) {
            requestBody.put('request_type', filterObj.requestType);
		}

		if (filterObj.size != null) {
			 externalEndPoint += '&size='+filterObj.size;
		}
		
        responseObj = getResponseFromElastic(externalEndPoint, requestBody);
		return responseObj;
    }
    
    public String getResponseFromElastic(String externalEndPoint, 
            Map<String, Object> requestBody) {
        String searchResultJSON = '';
        String simpDri = Utility.externalRequestAuthToken() + 
                ' ' + SimpplrContext.simpplrOrgId.substring(0, 15) +
                ' ' + UserContext.userId.substring(0, 15);

		HttpRequest req = new HttpRequest();
		req.setEndpoint(externalEndPoint);
		req.setMethod('POST');
		logger.logdebug('DRI========>'+simpDri);
		req.setHeader('simpplr-dri', simpDri);
		req.setTimeout(60000);
		req.setBody(Json.serialize(requestBody));
		logger.logDebug('ExternalSearchService.getResponseFromElastic()----request url----' + req.getEndpoint());
		logger.logDebug('ExternalSearchService.getResponseFromElastic()----request body----' + req.getBody());
		Http http = new Http();
		HTTPResponse res = http.send(req);
		logger.logError('ExternalSearchService.getResponseFromElastic()----response body----' + res.getBody());
        
        if (res.getStatusCode() == 200) {
			searchResultJSON = res.getBody();
        
        } else {
			logger.logError('ExternalSearchService.getResponseFromElastic()----status code----' + res.getStatusCode());
			throw new SimpplrException(String.valueOf(res.getStatusCode()));
        }

        return searchResultJSON; 
    }

    public String getPeopleStats(Criteria.ExternalSearchReq filterObj){
        logger.logError('ExternalSearchService.getPeopleStats()----filterObj----' + filterObj);
        Map<String, Object> requestBody = new Map<String, Object>();
        String externalEndPoint = SimpplrContext.simpplrAPIEndpoint + '/seps';
        String termAndToken = EncodingUtil.urlEncode(filterObj.term, 'UTF-8').replaceAll('\\+','%20');
        String SearchForType = 'People';
		Integer peopleIdsCount = 2000;
        externalEndPoint = externalEndPoint  + '/search?q=' + termAndToken + 
                '&start=0'  + '&object_type=' + SearchForType + '&people_id_count=' + peopleIdsCount;
            
        if (String.isNotBlank(filterObj.requestType)) {
            requestBody.put('request_type', filterObj.requestType);
        }

        if (String.isNotBlank(filterObj.siteId)) {
            requestBody.put('site_id', filterObj.siteId);
        }

        return  getResponseFromElastic(externalEndPoint, requestBody);
        
    }
    
    public List<PeopleListWrapper> getSiteMembers(Criteria.ExternalSearchReq filterObj){
        logger.logDebug('ExternalSearchService.getSiteMembers()----filterObj----' + filterObj);
        List<ExternalSearchWrapper.AIResponse> topResultsWrapperList = new List<ExternalSearchWrapper.AIResponse>();
        List<PeopleListWrapper> listOfPeopleWrap = new List<PeopleListWrapper>();
        Integer offset = 0;  
        searchTerm = String.isBlank(filterObj.term) ? '' : filterObj.term;

        if (filterObj.nextPageToken != null) {
           offset =  Integer.valueOf(filterObj.nextPageToken);
        }

        Map<String, Object> requestBody = new Map<String, Object>();
        String externalEndPoint = SimpplrContext.simpplrAPIEndpoint + '/seps';
        String termAndToken = EncodingUtil.urlEncode(searchTerm, 'UTF-8').replaceAll('\\+','%20');
        String SearchForType = 'People';
        externalEndPoint = externalEndPoint  + '/search?q=' + termAndToken + 
                '&start=' + offset  + '&object_type=' + SearchForType;
            
        if (String.isNotBlank(filterObj.requestType)) {
            requestBody.put('request_type', filterObj.requestType);
        }

        if (String.isNotBlank(filterObj.siteId)) {
            requestBody.put('site_id', filterObj.siteId);
        }

		String searchResultJSON = getResponseFromElastic(externalEndPoint, requestBody);
		logger.logDebug('ExternalSearchService.getSiteMembers()----searchResultJSON----' + searchResultJSON);
		ExternalSearchWrapper.AIResponse responseWrapperAI = (ExternalSearchWrapper.AIResponse)JSON.deserialize(searchResultJSON, ExternalSearchWrapper.AIResponse.class);
        logger.logDebug('ExternalSearchService.getSiteMembers()----responseWrapperAI----' +responseWrapperAI);
        listOfPeopleWrap = new ExternalSearchResultToWrapper().extSiteMembersToPeopleListWrap(responseWrapperAI);
        return  listOfPeopleWrap; 
    } 
    
    public List<PeopleListWrapper> getSiteMemberRequest(Criteria.ExternalSearchReq filterObj){
        logger.logError('ExternalSearchService.getSiteMembers()----filterObj----' + filterObj);
        List<ExternalSearchWrapper.AIResponse> topResultsWrapperList = new List<ExternalSearchWrapper.AIResponse>();
        List<PeopleListWrapper> listOfPeopleWrap = new List<PeopleListWrapper>();
        Integer offset = 0;  
        searchTerm = String.isBlank(filterObj.term) ? '' : filterObj.term;

        if (filterObj.nextPageToken != null) {
           offset =  Integer.valueOf(filterObj.nextPageToken);
        }

        Map<String, Object> requestBody = new Map<String, Object>();
        String externalEndPoint = SimpplrContext.simpplrAPIEndpoint + '/seps';
        String termAndToken = EncodingUtil.urlEncode(searchTerm, 'UTF-8').replaceAll('\\+','%20');
        String SearchForType = 'People';
        externalEndPoint = externalEndPoint  + '/search?q=' + termAndToken + 
                '&start=' + offset  + '&object_type=' + SearchForType;
            
        if (String.isNotBlank(filterObj.requestType)) {
            requestBody.put('request_type', filterObj.requestType);
        }

        if (String.isNotBlank(filterObj.siteId)) {
            requestBody.put('site_id', filterObj.siteId);
        }

		String searchResultJSON = getResponseFromElastic(externalEndPoint, requestBody);
		logger.logDebug('ExternalSearchService.getSiteMembers()----searchResultJSON----' + searchResultJSON);
		ExternalSearchWrapper.AIResponse responseWrapperAI = (ExternalSearchWrapper.AIResponse)JSON.deserialize(searchResultJSON, ExternalSearchWrapper.AIResponse.class);
        listOfPeopleWrap = new ExternalSearchResultToWrapper().extSiteMemberRequestToPeopleListWrap(responseWrapperAI);
        return listOfPeopleWrap;
        
    }

    public List<PeopleListWrapper> getMustReadRecordHistory(Criteria.ExternalSearchReq filterObj){
        logger.logError('ExternalSearchService.getMustReadRecordHistory()----filterObj----' + filterObj);
        List<ExternalSearchWrapper.AIResponse> topResultsWrapperList = new List<ExternalSearchWrapper.AIResponse>();
        List<PeopleListWrapper> listOfPeopleWrap = new List<PeopleListWrapper>();
        Integer offset = 0;  
        searchTerm = String.isBlank(filterObj.term) ? '' : filterObj.term;

        if (filterObj.nextPageToken != null) {
           offset =  Integer.valueOf(filterObj.nextPageToken);
        }

        Map<String, Object> requestBody = new Map<String, Object>();
        String externalEndPoint = SimpplrContext.simpplrAPIEndpoint + '/seps';
        String termAndToken = EncodingUtil.urlEncode(searchTerm, 'UTF-8').replaceAll('\\+','%20');
        String SearchForType = 'people';
        externalEndPoint = externalEndPoint  + '/' + SearchForType +  '/' + filterObj.requestType + '/search?q=' + termAndToken + '&start=' + offset;

        if (String.isNotBlank(filterObj.siteId)) {
            requestBody.put('site_id', filterObj.siteId);
        }

        if (String.isNotBlank(filterObj.collaborationId)) {
            requestBody.put('collaboration_id', filterObj.collaborationId);
        }

        if (String.isNotBlank(filterObj.contentId)) {
            requestBody.put('content_id', filterObj.contentId);
        }

        if (String.isNotBlank(filterObj.filter)) {
            requestBody.put('filter', filterObj.filter);
        }

        if (String.isNotBlank(filterObj.nextPageToken)) {
            requestBody.put('nextPageToken', filterObj.nextPageToken);
        }

        if (String.isNotBlank(filterObj.requestType)) {
            requestBody.put('request_type', filterObj.requestType);
        }

        if (String.isNotBlank(filterObj.audienceType)) {
            requestBody.put('audience_type', filterObj.audienceType);
        }

        String searchResultJSON = getResponseFromElastic(externalEndPoint, requestBody); 
        logger.logDebug('ExternalSearchService.getMustReadRecordHistory()----searchResultJSON----' + searchResultJSON);
        ExternalSearchWrapper.AIResponse responseWrapperAI = (ExternalSearchWrapper.AIResponse)JSON.deserialize(searchResultJSON, ExternalSearchWrapper.AIResponse.class);
        listOfPeopleWrap = new ExternalSearchResultToWrapper().extSearchResponseToPeopleListWrap(responseWrapperAI, filterObj.filter);
		nextPageToken = ((responseWrapperAI.hits.start+Integer.valueOf(filterObj.size))<(responseWrapperAI.hits.total.value)) ? String.valueOf(responseWrapperAI.hits.start+Integer.valueOf(filterObj.size)):null;
		totalResults = responseWrapperAI.hits.total.value;
        return listOfPeopleWrap;
        
    }
    
    
    public Integer getContentPublishedCount(String peopleId){
        logger.logError('ExternalSearchService.getContentPublishedCount()----peopleId----'+ peopleId);
       
        Map<String, Object> requestBody = new Map<String, Object>();
        String externalEndPoint = SimpplrContext.simpplrAPIEndpoint + '/seps';
        String SearchForType = 'Content';
        externalEndPoint = externalEndPoint  + '/search?object_type=' + SearchForType;
            
        requestBody.put('peopleId', peopleId);
        requestBody.put('listOfAllowedFeatures', ManageContentDao.allowedFeaturesInAppList);
        requestBody.put('manage_site_content_filter', 'owned');
    
        String searchResultJSON = getResponseFromElastic(externalEndPoint, requestBody);
        logger.logDebug('ExternalSearchService.getContentPublishedCount()----searchResultJSON----' + searchResultJSON);
        ExternalSearchWrapper.ContentPublishedCount responseWrapperAI = (ExternalSearchWrapper.ContentPublishedCount)JSON.deserialize(searchResultJSON, ExternalSearchWrapper.ContentPublishedCount.class);
        return responseWrapperAI.count;
        
    }
	
	private void removeDisabledProfileFields (ExternalSearchWrapper.SearchDataWrapper rec) {
		
		if(!SimpplrContext.isPPTitleDisplay){
				rec.title = null;
		}
		if(!SimpplrContext.isPPDepartmentDisplay){
			rec.department = null;
		}
		if(!SimpplrContext.isPPCityDisplay){
			rec.city = null;
		}
		if(!SimpplrContext.isPPStateDisplay){
			rec.state = null;
		}
		if(!SimpplrContext.isPPCountryDisplay){
			rec.country = null;
		}
		if(!SimpplrContext.isPPPhoneDisplay){
			rec.phone = null;
		}
		if(!SimpplrContext.isPPMobilePhoneDisplay){
			rec.mobile_phone = null;
		}
		if(!SimpplrContext.isPPBirthDateDisplay){
				rec.birth_date = null;
		}
		if(!SimpplrContext.isPPJoiningDateDisplay){
			rec.joining_date = null;
		}
		
		if(!SimpplrContext.isPPManagerDisplay){
			rec.manager = null;
		}
		if(!SimpplrContext.isPPCategoryDisplay){
			rec.people_category = null;
		}
		if(!SimpplrContext.isPPStreetDisplay){
			rec.street = null;
		}
    }
    
    public List<PeopleCategoryListingWrapper> getPeopleCategory(Criteria.ExternalSearchReq filterObj){
        logger.logError('ExternalSearchService.getPeopleCategory()----filterObj----' + filterObj);
        Integer offset =  filterObj.nextPageToken != null ? Integer.valueOf(filterObj.nextPageToken) : 0;
        Integer recordLimit = SimpplrContext.simpplrDefaultPageSize + 1;

        Map<String, Object> requestBody = new Map<String, Object>();
        String externalEndPoint = SimpplrContext.simpplrAPIEndpoint + '/seps';
        String SearchForType = 'People_Category';
        externalEndPoint = externalEndPoint  + '/search?object_type=' + SearchForType + '&start=' + offset  + '&size=' + recordLimit;

        String searchResultJSON = getResponseFromElastic(externalEndPoint, requestBody);
        logger.logDebug('ExternalSearchService.getPeopleCategory()----searchResultJSON----' + searchResultJSON);
        ExternalSearchWrapper.AIResponse responseWrapperAI = (ExternalSearchWrapper.AIResponse)JSON.deserialize(searchResultJSON, ExternalSearchWrapper.AIResponse.class);
        return convertToPeopleCategoryListWrapper(responseWrapperAI.hits.hit);
    }

    private List<PeopleCategoryListingWrapper> convertToPeopleCategoryListWrapper(List<ExternalSearchWrapper.SearchDataWrapper> hitList){
        List<PeopleCategoryListingWrapper> listOfPeopleCategoryWrap = new List<PeopleCategoryListingWrapper>();
        List<String> listOfcategoryIds = new List<String>();
        for (ExternalSearchWrapper.SearchDataWrapper extPeopleCategoryObj : hitList) {
            listOfcategoryIds.add(extPeopleCategoryObj.id);
        }
        Map<String, Integer> peopleCountMap = new PeopleDAO().getPeopleCountMap(listOfcategoryIds);
        for (ExternalSearchWrapper.SearchDataWrapper extPeopleCategoryObj : hitList) {
            PeopleCategoryListingWrapper categoryWrapObj = new PeopleCategoryListingWrapper();
            categoryWrapObj.id = extPeopleCategoryObj.id;
            categoryWrapObj.name = extPeopleCategoryObj.name;
            categoryWrapObj.userCount = peopleCountMap.containsKey(extPeopleCategoryObj.id) ? peopleCountMap.get(extPeopleCategoryObj.id) : 0;
            listOfPeopleCategoryWrap.add(categoryWrapObj);
        }
        return listOfPeopleCategoryWrap;
    }

    public Set<String> getPeopleIds(String searchTerm, Integer size){
        logger.logError('ExternalSearchService.getPeopleIds()----');
		String termAndToken = EncodingUtil.urlEncode(searchTerm, 'UTF-8').replaceAll('\\+','%20');
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('fieldsToReturn', new List<String>{'id'});
        String externalEndPoint = SimpplrContext.simpplrAPIEndpoint + '/seps';
        String SearchForType = 'People';
        externalEndPoint = externalEndPoint  + '/search?q=' + termAndToken + '&object_type=' + SearchForType + '&size=' + size;

        String searchResultJSON = getResponseFromElastic(externalEndPoint, requestBody);
        logger.logDebug('ExternalSearchService.getPeopleIds()----searchResultJSON----' + searchResultJSON);
        ExternalSearchWrapper.AIResponse responseWrapperAI = (ExternalSearchWrapper.AIResponse)JSON.deserialize(searchResultJSON, ExternalSearchWrapper.AIResponse.class);

        Set<String> setOfPeopleIds = new Set<String>();
        for (ExternalSearchWrapper.SearchDataWrapper extPeopleObj : responseWrapperAI.hits.hit) {
            setOfPeopleIds.add(extPeopleObj.id);
        }
        return setOfPeopleIds;
    }

    public List<String> getLatestHiresId(Integer size, Integer daysLimit){
        logger.logError('ExternalSearchService.getLatestHiresId()----');

        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('joiningDateInLastNDays', daysLimit);
        String externalEndPoint = SimpplrContext.simpplrAPIEndpoint + '/seps';
        externalEndPoint = externalEndPoint  + '/search?object_type=People&size=' + size + '&order_by=joining_date';

        String searchResultJSON = getResponseFromElastic(externalEndPoint, requestBody);
        logger.logDebug('ExternalSearchService.getLatestHiresId()----searchResultJSON----' + searchResultJSON);
        ExternalSearchWrapper.AIResponse responseWrapperAI = (ExternalSearchWrapper.AIResponse)JSON.deserialize(searchResultJSON, ExternalSearchWrapper.AIResponse.class);

        List<String> listOfPeopleIds = new List<String>();
        for (ExternalSearchWrapper.SearchDataWrapper extPeopleObj : responseWrapperAI.hits.hit) {
            listOfPeopleIds.add(extPeopleObj.id);
        }
        return listOfPeopleIds;
    }

	/**
     * @description getUsersCountByCountry is used to get count of users by country
     * @return Map<String, Integer> map of country and user count
     */
	public Map<String, Integer> getUsersCountByCountry(){
		logger.logDebug('ExternalSearchService.getUsersCountByCountry()----');
		Map<String, Integer>  userCountByCountry = new Map<String, Integer> ();
		Map<String, Object> requestBody = new Map<String, Object>();
		String externalEndPoint = SimpplrContext.simpplrAPIEndpoint + '/seps';
        String SearchForType = 'People';
		String groupBy = 'country';
        externalEndPoint = externalEndPoint  + '/search?object_type='  + SearchForType + '&group_by=' + groupBy;
        String searchResultJSON = getResponseFromElastic(externalEndPoint, requestBody);
		ExternalSearchWrapper.Aggregate externalSearchAggregateResult = (ExternalSearchWrapper.Aggregate)JSON.deserialize(searchResultJSON, ExternalSearchWrapper.Aggregate.class);
		
		if(externalSearchAggregateResult != null && externalSearchAggregateResult.hits !=null && externalSearchAggregateResult.hits.aggregation !=null ){
			for(ExternalSearchWrapper.Aggregation usersOnCountry: externalSearchAggregateResult.hits.aggregation){
				if(String.IsNotBlank(usersOnCountry.Key)){
					userCountByCountry.put(usersOnCountry.Key, usersOnCountry.doc_count);
				}
			}
		}

		return userCountByCountry;
	}

	public List<String> getNewHiresOnJoinigDate(String joiningDate, String filter_value, String filter_by){

        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('joining_date', joiningDate);
		requestBody.put('filter_by', filter_by);
		requestBody.put('filter_value', filter_value);
        String externalEndPoint = SimpplrContext.simpplrAPIEndpoint + '/seps';
        externalEndPoint = externalEndPoint  + '/people/get_people_ids' ;
		
        String searchResultJSON = getResponseFromElastic(externalEndPoint, requestBody);
        logger.logDebug('ExternalSearchService.getNewHiresOnJoinigDate()----searchResultJSON----' + searchResultJSON);
        ExternalSearchWrapper.AIResponse responseWrapperAI = (ExternalSearchWrapper.AIResponse)JSON.deserialize(searchResultJSON, ExternalSearchWrapper.AIResponse.class);

        List<String> listOfPeopleIds = new List<String>();
        for (ExternalSearchWrapper.SearchDataWrapper extPeopleObj : responseWrapperAI.hits.hit) {
            listOfPeopleIds.add(extPeopleObj.id);
        }
        return listOfPeopleIds;
    }
	/**
     * 
     * @Description:  [This method search for content template ids from elastic for a particular site]
     * @Parameters: contentTemplateCriteriaObj - search criteria object, searchForType - search object for elastic
     * @Returns:  [Returns the list of Content Template Ids based on request criteria]
    */
    public Set<String> searchContentTemplates(Criteria.ExternalSearchReq contentTemplateCriteriaObj, String searchForType) {
        logger.logDebug('ExternalSearchService.searchContentTemplates()----contentTemplateCriteriaObj----' + contentTemplateCriteriaObj);

        searchTerm = String.isBlank(contentTemplateCriteriaObj.term) ? '' : contentTemplateCriteriaObj.term;
        Integer offset = 0;  

        if (contentTemplateCriteriaObj.nextPageToken != null) {
           offset =  Integer.valueOf(contentTemplateCriteriaObj.nextPageToken);
        }
        String searchResultJSON = getExternalSearchResults(searchTerm, offset, searchForType, 
                contentTemplateCriteriaObj.isCorrectionEnabled, contentTemplateCriteriaObj.siteId, contentTemplateCriteriaObj);
        
        logger.logDebug('ExternalSearchService.searchContentTemplates()----searchResultJSON----' + searchResultJSON);
        ExternalSearchWrapper.AIResponse responseWrapperAI = (ExternalSearchWrapper.AIResponse)JSON.deserialize(searchResultJSON, ExternalSearchWrapper.AIResponse.class);
        
        Set<String> contentTemplateIdSet = new Set<String>();
        for (ExternalSearchWrapper.SearchDataWrapper templateObj : responseWrapperAI.hits.hit) {
            contentTemplateIdSet.add(templateObj.id);
        }
        return contentTemplateIdSet;
    }

	public List<String> getAuthoredByPeopleContentList(Criteria.ExternalSearchReq contentTemplateCriteriaObj) {
        logger.logDebug('ExternalSearchService.getAuthoredByPeopleContentList()----contentTemplateCriteriaObj----' + contentTemplateCriteriaObj);

        searchTerm = String.isBlank(contentTemplateCriteriaObj.term) ? '' : contentTemplateCriteriaObj.term;
        Integer offset = 0;  

        if (contentTemplateCriteriaObj.nextPageToken != null) {
           offset =  Integer.valueOf(contentTemplateCriteriaObj.nextPageToken);
        }
        String searchResultJSON = getExternalSearchResults(searchTerm, offset, 'Content_Authored', 
                false, null, contentTemplateCriteriaObj);
        
        logger.logDebug('ExternalSearchService.getAuthoredByPeopleContentList()----searchResultJSON----' + searchResultJSON);
        ExternalSearchWrapper.AIResponse responseWrapperAI = (ExternalSearchWrapper.AIResponse)JSON.deserialize(searchResultJSON, ExternalSearchWrapper.AIResponse.class);
        
        List<String> contentIdList = new List<String>();
        for (ExternalSearchWrapper.SearchDataWrapper templateObj : responseWrapperAI.hits.hit) {
            contentIdList.add(templateObj.id);
        }
        return contentIdList;
    }
}