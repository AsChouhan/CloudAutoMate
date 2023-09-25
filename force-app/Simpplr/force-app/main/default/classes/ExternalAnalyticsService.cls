public with sharing class ExternalAnalyticsService{
	
	
	public static String loggedInUserId = UserContext.id;
	private Integer size;
	private Set<String> actionsWithSiteFilter = new Set<String> {'getAdoptionData', 'getEngagementFeed', 'getEngagementContent', 'getPerformanceContent','getSitePopularity','getSitePublication','getContentViewsList','getContentPopularity','getLowActivitySites'};
	
	public Object getExternalAnalyticsResults(Map<String,Object> mapOfParams,String action,Integer size){
		String fromdate = mapOfParams!=null ? (String)mapOfParams.get('from') :null; 
		String toDate = mapOfParams!=null ? (String)mapOfParams.get('to'):null;
		String metric = (mapOfParams!=null && mapOfParams.containsKey('metric')) ? (String)mapOfParams.get('metric') : null;
		String contentType = (mapOfParams!=null && mapOfParams.containsKey('contentType')) ? (String)mapOfParams.get('contentType') : null;
		String siteId = (mapOfParams!=null && mapOfParams.containsKey('siteId')) ? (String)mapOfParams.get('siteId') : null;
		String contentId = (mapOfParams!=null && mapOfParams.containsKey('contentId')) ? (String)mapOfParams.get('contentId') : null;
		List<String> contentIdList = (mapOfParams!=null && mapOfParams.containsKey('contentIdList')) ? (List<String>)mapOfParams.get('contentIdList') : null;
		String groupBy = (mapOfParams !=null && mapOfParams.containsKey('groupBy')) ? (String)mapOfParams.get('groupBy') : null;
		String orderBy = (mapOfParams!=null && mapOfParams.containsKey('orderBy')) ? (String)mapOfParams.get('orderBy') : null;
		String filterBy = (mapOfParams!=null && mapOfParams.containsKey('filterBy')) ? (String)mapOfParams.get('filterBy') : null;
		String filterValue = (mapOfParams!=null && mapOfParams.containsKey('filterValue')) ? (String)mapOfParams.get('filterValue') : null;
		String resultType = (mapOfParams!=null && mapOfParams.containsKey('resultType')) ? (String)mapOfParams.get('resultType') : null;
		String type = (mapOfParams!=null && mapOfParams.containsKey('type')) ? (String)mapOfParams.get('type') : null;
		Boolean excludeDeviceData = (mapOfParams!=null && mapOfParams.containsKey('excludeDeviceData')) ? (Boolean)mapOfParams.get('excludeDeviceData') : null;
		Boolean excludeLoginsOverTime = (mapOfParams!=null && mapOfParams.containsKey('excludeLoginsOverTime')) ? (Boolean)mapOfParams.get('excludeLoginsOverTime') : null;
		Boolean onlyPublished = (mapOfParams!=null && mapOfParams.containsKey('onlyPublished')) ? (Boolean)mapOfParams.get('onlyPublished'):false;
		Set<String> nonPublicSitesAccessibleSet = (mapOfParams!=null && mapOfParams.containsKey('nonPublicSitesAccessibleSet')) ? (Set<String>)mapOfParams.get('nonPublicSitesAccessibleSet'):null;
		Boolean includeMembers = (mapOfParams!=null && mapOfParams.containsKey('includeMembers')) ? Boolean.valueOf(mapOfParams.get('includeMembers')) : null;
		Boolean includeFollowers = (mapOfParams!=null && mapOfParams.containsKey('includeFollowers')) ? Boolean.valueOf(mapOfParams.get('includeFollowers')) : null;
		Boolean includeOthers = (mapOfParams!=null && mapOfParams.containsKey('includeOthers')) ? Boolean.valueOf(mapOfParams.get('includeOthers')) : null;
		Boolean includeName = (mapOfParams!=null && mapOfParams.containsKey('includeName')) ? Boolean.valueOf(mapOfParams.get('includeName')) : null;
		
		String responseObj ='';
		ResponseWrapper localResult = null;
		
		String endPointURL = getExternalAnalyticsEndpoint() + action;
		Map<String, Object> requestBody = new Map<String, Object>();
		
		if(String.isNotBlank(fromdate)) {
			requestBody.put('from', fromdate);
		}
		if(String.isNotBlank(toDate)) {
			requestBody.put('to', toDate);
		}
		if(String.isNotBlank(metric)) {
			requestBody.put('metric', metric);
		}
		if(String.isNotBlank(type)) {
			requestBody.put('type', type);
		}
		if(excludeDeviceData!=null){
			requestBody.put('excludeDeviceData', excludeDeviceData);
		}
		if(excludeLoginsOverTime!=null){
			requestBody.put('excludeLoginsOverTime', excludeLoginsOverTime);
		}
		if(!'getVideoAdoption'.equalsIgnoreCase(action) && !'getVideoAdoptionCsv'.equalsIgnoreCase(action)){
			requestBody.put('org_id', UserInfo.getOrganizationId().subString(0,15));
		}else{
			requestBody.put('org_id', UserInfo.getOrganizationId());
			requestBody.put('peopleId', UserContext.peopleId.substring(0,15));	
		}
		if(size!=null){
			this.size=size;
			requestBody.put('size', size);
		}
		if(String.isNotBlank(contentType)){
			requestBody.put('contentType', contentType);
		}
		if(String.isNotBlank(filterBy)){
			requestBody.put('filterBy', filterBy);
			if(String.isNotBlank(filterValue)){
				requestBody.put('filterValue', filterValue);
			}
		}
		if(String.isNotBlank(resultType)){
			requestBody.put('resultType', resultType);
		}
		if(String.isNotBlank(groupBy)){
			requestBody.put('groupBy', groupBy);
		}
		if(String.isNotBlank(orderBy)){
			requestBody.put('orderBy', orderBy);
		}
		if(String.isNotBlank(contentId)){
			requestBody.put('contentId', contentId);
		}
		if(contentIdList != null){
			requestBody.put('contentIdList', contentIdList);
		}
		
		requestBody.put('onlyPublished', onlyPublished);

		if(String.isNotBlank(siteId)){
			requestBody.put('siteId', siteId);
		
		} else if(actionsWithSiteFilter.contains(action)) {
			
			if(UserContext.hasModifyAllDataPermission){
				requestBody.put('nonPublicSitesAccessible',null);
			} else if(UserContext.canAccessAnalytics || UserContext.isUserAppModerator) {
				String query = 'select id from CollaborationGroup where id IN (select CollaborationGroupId from CollaborationGroupMember where memberId=:loggedInUserId) and CollaborationType!=\'Public\'';
				if('getLowActivitySites'.equalsIgnoreCase(action)){
					query += ' AND IsArchived=false';
				}
				if(SimpplrContext.isCommunitiesEnabled){
					query = query+' AND NetworkId = null';
				}
				Map<String,CollaborationGroup> groupMap = new Map<String,CollaborationGroup>((List<CollaborationGroup>)Database.query(query));
				if(UserContext.hasManageUnlistedSitePermission){
					if('getLowActivitySites'.equalsIgnoreCase(action)){
						groupMap.putAll([select id from CollaborationGroup where CollaborationType = 'Unlisted' AND IsArchived=false]);
					}else{
						groupMap.putAll([select id from CollaborationGroup where CollaborationType = 'Unlisted']);
					}
				}
				
				Map<String,Simpplr_Site__c> siteMap = new Map<String,Simpplr_Site__c>([select id from Simpplr_Site__c where Chatter_Group_Id__c IN:groupMap.keySet()]);
				requestBody.put('nonPublicSitesAccessible', siteMap.keySet());
			} 
		}

		if(includeMembers != null){
			requestBody.put('includeMembers', includeMembers);
		}	
		if(includeFollowers != null){
			requestBody.put('includeFollowers', includeFollowers);
		}
		if(includeOthers != null){
			requestBody.put('includeOthers', includeOthers);
		}
		if(includeName != null){
			requestBody.put('includeName', includeName);
		}

		if(('getContentViewsCsv'.equalsIgnoreCase(action) || 'getPeoplePerformance'.equalsIgnoreCase(action)) && String.isNotBlank(siteId)){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', siteId); 
			String siteQuery = 'SELECT chatter_group_id__c from simpplr_site__c where Id =:soqlParam1 LIMIT 1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<simpplr_site__c> siteObjectList = (List<simpplr_site__c>)SIMPESAPI.accessController().queryAsUser(siteQuery, soqlParamMap);
			if(!siteObjectList.isEmpty()){
				String chatterGrpId = siteObjectList[0].chatter_group_id__c;
				Map<String, Object> soqlParamMap1 = new Map<String, Object>();
				soqlParamMap1.put('soqlParam1', chatterGrpId); 
				String collaborationGrpQuery = 'select id, OwnerId from CollaborationGroup where Id =:soqlParam1 ';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<CollaborationGroup> collaborationGroupList = (List<CollaborationGroup>)SIMPESAPI.accessController().queryAsUser(collaborationGrpQuery, soqlParamMap1);
				requestBody.put('ownerId', (collaborationGroupList.isEmpty() ? '' : collaborationGroupList[0].OwnerId));
			}
		}

		if(nonPublicSitesAccessibleSet != null ){
			requestBody.put('nonPublicSitesAccessible', nonPublicSitesAccessibleSet);
		}

		String nonAccessibleUnlistedSiteStr = LocaleContext.getLabel(UserContext.languageLocaleKey, 'analytics.sites_tiles.unlisted_site');
		String nonAccessiblePrivateSiteContentStr = LocaleContext.getLabel(UserContext.languageLocaleKey, 'analytics.content_tiles.private_site_content');
		String nonAccessibleUnlistedSiteContentStr = LocaleContext.getLabel(UserContext.languageLocaleKey, 'analytics.content_tiles.unlisted_site_content');

		// Add API related localizations
		Map<String, String> labelMap = new Map<String, String>{
			'nonAccessibleUnlistedSite' => Utility.encryptString('** ' + nonAccessibleUnlistedSiteStr + ' **'),
			'nonAccessiblePrivateSiteContent' => Utility.encryptString('** ' + nonAccessiblePrivateSiteContentStr + ' **'),
			'nonAccessibleUnlistedSiteContent' => Utility.encryptString('** ' + nonAccessibleUnlistedSiteContentStr + ' **'),
			'analytics.knowledge_page.published' => LocaleContext.getLabel(UserContext.languageLocaleKey, 'analytics.knowledge_page.published'),
			'analytics.knowledge_page.validated' => LocaleContext.getLabel(UserContext.languageLocaleKey, 'analytics.knowledge_page.validated'),
			'analytics.knowledge_page.validation_expired' => LocaleContext.getLabel(UserContext.languageLocaleKey, 'analytics.knowledge_page.validation_expired'),
			'analytics.knowledge_page.validation_required' => LocaleContext.getLabel(UserContext.languageLocaleKey, 'analytics.knowledge_page.validation_required')
		};

		requestBody.put('labelMap', labelMap);

		HttpRequest req = new HttpRequest();
		req.setEndpoint(endPointURL);
		req.setMethod('POST');
		req.setHeader('Content-Type', 'application/json');
		req.setHeader('Authorization', Utility.externalRequestAuthToken());
		req.setTimeout(60000);
		req.setBody(Json.serialize(requestBody));
		
		String responseBody='';
		if(SimpplrContext.isDemoAnalyticsEnabled==true) {
			DemoAnalytics demoAnalyticsObj = new DemoAnalytics();
			responseBody=demoAnalyticsObj.getDummyAnalyticsData(action,requestBody);
			if('getPeoplePerformance'.equalsIgnoreCase(action)) {
				return demoAnalyticsObj.getDummyPeoplePerformanceData(responseBody);				
			} else if(('getEngagementList'.equalsIgnoreCase(action) || 'getContentViewsList'.equalsIgnoreCase(action) || 'getAppAdoption'.equalsIgnoreCase(action) || 'getViewsList'.equalsIgnoreCase(action)) && 'segment'.equalsIgnoreCase(resultType)){
				return demoAnalyticsObj.getDummySegmentData(action,responseBody);
			} else if('getSearchList'.equalsIgnoreCase(action) && 'segment'.equalsIgnoreCase(resultType)){
				return demoAnalyticsObj.getDummySearchSegmentData(action,responseBody);
			} else if('getVideoPopularity'.equalsIgnoreCase(action)){
				return demoAnalyticsObj.getDummyVideoPopularityData(responseBody);
			}
		}else{
			Http http = new Http();
			HTTPResponse res = http.send(req);
			logger.logDebug('ExternalAnalyticsService.getExternalAnalyticsResults()----Endpoint----' + endPointURL + '----Request Body----' + requestBody);
			logger.logDebug('ExternalAnalyticsService.getExternalAnalyticsResults()----Status Code----'+res.getStatusCode()+'-----Response Body----'+res.getBody());
			if (res.getStatusCode() == 403){
				throw new SimpplrException(ServiceConstants.ERROR_403);
				
			} else if (res.getStatusCode() == 404) {
				throw new SimpplrException(ServiceConstants.ERROR_404);
				
			} else if (res.getStatusCode() == 500) {
				throw new SimpplrException(ServiceConstants.ERROR_500);
				
			} else if(res.getStatusCode() != 200) {
				throw new SimpplrException('Status ' + res.getStatusCode()  + ' received from server');
				
			}
			responseBody=res.getBody();						
		}
		return convertToWrapper(action, responseBody,resultType,siteId,metric);
		
	}		

	private Object convertToWrapper(String action, String responseJson,String resultType,String siteId,String metric) {
		Object wrapObj;
		
		Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(responseJson);
        if(!m.containsKey('result'))
            return wrapObj;
		if('getContentListViews'.equalsIgnoreCase(action)){
			List<AnalyticsWrapper.ContentRelatedData> objList = new List<AnalyticsWrapper.ContentRelatedData>();
			for (Object instance : (List<Object>)m.get('result')) {
				AnalyticsWrapper.ContentRelatedData obj = (AnalyticsWrapper.ContentRelatedData)JSON.deserialize(JSON.serialize(instance), AnalyticsWrapper.ContentRelatedData.class);
				objList.add(obj);
			}
			return objList;
		}
		Map<String, Object> result = (Map<String, Object>)m.get('result');
		
		if('getPerformanceSites'.equalsIgnoreCase(action)) {
			wrapObj = convertToPerformanceSites((List<Object>)result.get('data'));
		
		} else if('getPeoplePerformance'.equalsIgnoreCase(action)) {
			wrapObj = convertToPerformancePeople(result);
			
		} else if ('getPerformanceContent'.equalsIgnoreCase(action)) {
			Boolean hasLowActivityContent = (Boolean) result.get('hasLowActivityContent');

			wrapObj = convertToPerformanceContent((List<Object>)result.get('data'), siteId, metric, hasLowActivityContent);
			
		} else if('getPerformanceTopics'.equalsIgnoreCase(action)){
			wrapObj = convertToPerformanceTopics((List<Object>)result.get('data'));
			
		} else if('getPerformanceSearch'.equalsIgnoreCase(action)  || 'getPerformanceZeroSearchResults'.equalsIgnoreCase(action)) {
			wrapObj = convertToPerformanceSearch((List<Object>)result.get('data'));
			
		} else if('getAdoptionOverview'.equalsIgnoreCase(action)){
			wrapObj = result;
			
		} else if('getEngagementFeed'.equalsIgnoreCase(action)) {
			wrapObj = (List<AnalyticsWrapper.EngagementfeedData>)JSON.deserialize(JSON.serialize((List<Object>)result.get('data')),List<AnalyticsWrapper.EngagementfeedData>.class);
		
		} else if('getEngagementContentTypes'.equalsIgnoreCase(action)){
			wrapObj = (List<AnalyticsWrapper.EngagementContentTypesData>)JSON.deserialize(JSON.serialize((List<Object>)result.get('data')),List<AnalyticsWrapper.EngagementContentTypesData>.class);
				
		} else if('getEngagementContent'.equalsIgnoreCase(action)) {
			wrapObj = (List<AnalyticsWrapper.EngagementContentData>)JSON.deserialize(JSON.serialize((List<Object>)result.get('data')),List<AnalyticsWrapper.EngagementContentData>.class);
		
		} else if('getAdoptionAverage'.equalsIgnoreCase(action)) { 
			wrapObj = (List<AnalyticsWrapper.AdoptionAverageData>)JSON.deserialize(JSON.serialize((List<Object>)result.get('data')), List<AnalyticsWrapper.AdoptionAverageData>.class);
				
		} else if('getViewsOverTime'.equalsIgnoreCase(action) || 'getLoginsOverTime'.equalsIgnoreCase(action)){
			wrapObj = (AnalyticsWrapper.ContentWrapper)JSON.deserialize(JSON.serialize(result), AnalyticsWrapper.ContentWrapper.class);
		
		} else if('getLoginsOverTimeCsv'.equalsIgnoreCase(action)){
			wrapObj = (List<Object>) result.get('loginsOverTime');
			
		} else if('getViewsOverTimeCsv'.equalsIgnoreCase(action)){
			wrapObj = (List<Object>) result.get('views');
			
		} else if('getContentViews'.equalsIgnoreCase(action)){
			wrapObj = (AnalyticsWrapper.ContentRelatedData)JSON.deserialize(JSON.serialize(result), AnalyticsWrapper.ContentRelatedData.class);
		
		} else if('getContentViewsCsv'.equalsIgnoreCase(action)){
			wrapObj = getContentViewsCsv((List<Object>)result.get('views'));
		
		} else if(('getContentViewsList'.equalsIgnoreCase(action) && String.isNotBlank(resultType)) || 'getLoginsList'.equalsIgnoreCase(action) || 'getEngagementList'.equalsIgnoreCase(action) || 'getViewsList'.equalsIgnoreCase(action) || 'getAppAdoption'.equalsIgnoreCase(action)){
			wrapObj = convertToContentAndLoginAndEngagementListByCategory((List<Object>)result.get('data'),resultType,action);
		
		} else if(('getContentViewsList'.equalsIgnoreCase(action) && String.isBlank(resultType))){
			wrapObj = convertToContentViewsListWrapperWhenFilterIsNull((List<Object>)result.get('data'));
			
		} else if('getContentPopularity'.equalsIgnoreCase(action)){
			wrapObj = convertToContentPopularityListWrapper((List<Object>)result.get('data'));
			
		} else if('getGovernanceList'.equalsIgnoreCase(action)){
			wrapObj = convertToGovernanceListWrapper((List<Object>)result.get('data'));
			
		} else if('getSitePopularity'.equalsIgnoreCase(action)){
			wrapObj = convertToSitePopularityListWrapper((List<Object>)((Map<String,Object>)result.get('data')).get('sites'));
		
		} else if('getSitePublication'.equalsIgnoreCase(action)){
			wrapObj = convertToViewsOverTimeListForSites((List<Object>)((Map<String,Object>)result.get('data')).get('sites'));
			
		} else if('getLowActivitySites'.equalsIgnoreCase(action)){
			wrapObj = getLowActivitySitesData((List<Object>)result.get('listOfSites'));
		
		} else if('getMonthlyReports'.equalsIgnoreCase(action)){
			wrapObj = (AnalyticsWrapper.MonthlyReport)JSON.deserialize(JSON.serialize(result), AnalyticsWrapper.MonthlyReport.class);
		} else if('getSiteViews'.equalsIgnoreCase(action)){
			wrapObj = (AnalyticsWrapper.ContentRelatedData)JSON.deserialize(JSON.serialize(result), AnalyticsWrapper.ContentRelatedData.class);
		
		} else if('getSiteViewsTotal'.equalsIgnoreCase(action)) {
			wrapObj = (AnalyticsWrapper.ContentRelatedData)JSON.deserialize(JSON.serialize(result), AnalyticsWrapper.ContentRelatedData.class);
		} else if('getEngagement'.equalsIgnoreCase(action)){
			wrapObj = (AnalyticsWrapper.Engagement)JSON.deserialize(JSON.serialize(result), AnalyticsWrapper.Engagement.class);
		} else if('getAdoptionData'.equalsIgnoreCase(action)){
			wrapObj = (AnalyticsWrapper.ContentWrapper)JSON.deserialize(JSON.serialize(result), AnalyticsWrapper.ContentWrapper.class);
		
		} else if('getSearchList'.equalsIgnoreCase(action)){
			if(String.isBlank(resultType)){
				wrapObj = (AnalyticsWrapper.SearchData)JSON.deserialize(JSON.serialize(result.get('data')), AnalyticsWrapper.SearchData.class);
			}else {
				wrapObj = getSearchesByResultType((List<Object>)((Map<String,Object>)result.get('data')).get('searchList'),resultType);
			}
			
		} else if('getSearches'.equalsIgnoreCase(action)){
			wrapObj = (AnalyticsWrapper.SearchData)JSON.deserialize(JSON.serialize(result.get('data')), AnalyticsWrapper.SearchData.class);

		} else if('getPeopleOverview'.equalsIgnoreCase(action)){
			wrapObj = (AnalyticsWrapper.PeopleOverviewData) JSON.deserialize(JSON.serialize(result.get('data')), AnalyticsWrapper.PeopleOverviewData.class);

		} else if('getSiteCounts'.equalsIgnoreCase(action)){
			wrapObj = (AnalyticsWrapper.SiteCountData) JSON.deserialize(JSON.serialize(result.get('data')), AnalyticsWrapper.SiteCountData.class);

		} else if('getPeopleProfileCompletenessV2'.equalsIgnoreCase(action)){
			wrapObj = convertToPeopleCompleteness(result);

		} else if('getPeopleProfileCompletenessCsvV2'.equalsIgnoreCase(action)){
			wrapObj = convertToPeopleCompletenessCsv((List<Object>) result.get('data'));

		} else if('getContentPublications'.equalsIgnoreCase(action)){
			wrapObj = (AnalyticsWrapper.ContentInformation) JSON.deserialize(JSON.serialize(result.get('data')), AnalyticsWrapper.ContentInformation.class);

		} else if('getContentPublicationsCsv'.equalsIgnoreCase(action)){
			wrapObj = convertToContentPublicationsCsv((List<Object>) result.get('data'));

		} else if('getContentViewsByType'.equalsIgnoreCase(action)){
			wrapObj = (AnalyticsWrapper.ContentViewsByTypeData) JSON.deserialize(JSON.serialize(result.get('data')), AnalyticsWrapper.ContentViewsByTypeData.class);

		} else if('getContentViewsByTypeCsv'.equalsIgnoreCase(action)){
			wrapObj = convertToContentViewsByTypeCsv((List<Object>) result.get('data'));

		} else if('getContentViewsOverTime'.equalsIgnoreCase(action)){
			wrapObj = (AnalyticsWrapper.ContentViewsOverTimeData) JSON.deserialize(JSON.serialize(result.get('data')), AnalyticsWrapper.ContentViewsOverTimeData.class);

		} else if ('getContentViewsOverTimeCsv'.equalsIgnoreCase(action)) {
			wrapObj = (List<Object>) result.get('views');

		} else if('getKnowledgePageStats'.equalsIgnoreCase(action)){
			wrapObj = (List<AnalyticsWrapper.LabelValueData>) JSON.deserialize(JSON.serialize(result.get('data')), List<AnalyticsWrapper.LabelValueData>.class);

		} else if('getKnowledgePageCsv'.equalsIgnoreCase(action)){
			wrapObj = convertToKnowledgePage((List<Object>) result.get('data'));

		} else if('getLastSyncDate'.equalsIgnoreCase(action)){
			wrapObj = (AnalyticsWrapper.LastSyncData) JSON.deserialize(JSON.serialize(result), AnalyticsWrapper.LastSyncData.class);

		} else if('getAppPageViews'.equalsIgnoreCase(action)){
			wrapObj = convertToAppPageViewsListWrapper((List<Object>) result.get('data'));

		} else if('getContentReferralSources'.equalsIgnoreCase(action)){
			wrapObj = localizeReferrals((List<AnalyticsWrapper.ContentReferralSourceData>) JSON.deserialize(JSON.serialize(result.get('data')), List<AnalyticsWrapper.ContentReferralSourceData>.class));

		}else if('getContentEngagement'.equalsIgnoreCase(action)){
			wrapObj = (AnalyticsWrapper.Engagement)JSON.deserialize(JSON.serialize(result), AnalyticsWrapper.Engagement.class);
		}
		else if('getContentEngagementCsv'.equalsIgnoreCase(action)){
			wrapObj = (AnalyticsWrapper.Engagement)JSON.deserialize(JSON.serialize(result), AnalyticsWrapper.Engagement.class);
		}
		else if('getRecommendationByType'.equalsIgnoreCase(action)){
			wrapObj = (AnalyticsWrapper.Recommendation)JSON.deserialize(JSON.serialize(result), AnalyticsWrapper.Recommendation.class);
		}
		else if('getCustomerSegmentAdoption'.equalsIgnoreCase(action)){
			wrapObj = (AnalyticsWrapper.CustomerSegmentAdoption)JSON.deserialize(JSON.serialize(result), AnalyticsWrapper.CustomerSegmentAdoption.class);
		
		}else if('getVideoPopularity'.equalsIgnoreCase(action)){
			wrapObj = localizeVideoData((List<AnalyticsWrapper.videoPopularity>) JSON.deserialize(JSON.serialize(result.get('data')), List<AnalyticsWrapper.videoPopularity>.class));

		}else if('getVideoAdoption'.equalsIgnoreCase(action)){
			wrapObj = (AnalyticsWrapper.videoAdoptionData) JSON.deserialize(JSON.serialize(result.get('data')), AnalyticsWrapper.videoAdoptionData.class);

		}else if('getVideoAdoptionCsv'.equalsIgnoreCase(action)){
			wrapObj = (List<AnalyticsWrapper.videoAdoptionCsv>) JSON.deserialize(JSON.serialize(result.get('data')), List<AnalyticsWrapper.videoAdoptionCsv>.class);

		}else if('getViewedByMetricData'.equalsIgnoreCase(action)){
			wrapObj = (AnalyticsWrapper.ViewedEngagementData)JSON.deserialize(JSON.serialize(result), AnalyticsWrapper.ViewedEngagementData.class);

		} else if('getConsumptionOverTime'.equalsIgnoreCase(action)){
			wrapObj = (AnalyticsWrapper.ContentRelatedData)JSON.deserialize(JSON.serialize(result), AnalyticsWrapper.ContentRelatedData.class);
			
		} else if('getCampaigns'.equalsIgnoreCase(action)){
			wrapObj = (AnalyticsWrapper.Campaign)JSON.deserialize(JSON.serialize(result), AnalyticsWrapper.Campaign.class);
			
		}

		return wrapObj;		
	}

	private List<AnalyticsWrapper.ContentReferralSourceData> localizeReferrals(List<AnalyticsWrapper.ContentReferralSourceData> contentReferralDataList){
		
		for(AnalyticsWrapper.ContentReferralSourceData dataObj : contentReferralDataList){
			
			dataObj.label = LocaleContext.getLabel(UserContext.languageLocaleKey, 'analytics.content_referral.' + dataObj.label);
			dataObj.contentTitle = Utility.decryptString(dataObj.contentTitle);
		}

		return contentReferralDataList;
	}

	private List<AnalyticsWrapper.videoPopularity> localizeVideoData(List<AnalyticsWrapper.videoPopularity> videoPopularityList){
		Set<Id> peopleIdSet = new Set<Id>();
		Set<String> fileIdSet = new Set<String>();
			for(AnalyticsWrapper.videoPopularity dataObj : videoPopularityList){
				peopleIdSet.add(dataObj.uploader);
				fileIdSet.add(dataObj.videoId);
			}
			Map<Id,String> sfPeopleMap = new Map<Id,String>();
			Map<String,String> sffileMap = new Map<String,String>();
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fileIdSet);
			String filesQuery ='SELECT id, title__c, External_Id__c, Repository__c,'+
									' Size__c, Thumbnail_URL__c FROM File__c where External_Id__c IN:soqlParam1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<File__c> fileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
			List<People__c> peopleList = [SELECT id, Full_Name__c, Company_Name__c, Email__c,
										Division__c, Department__c, city__c, state__c, country__c
										FROM people__c where id IN:peopleIdSet WITH SECURITY_ENFORCED];

			for(people__c peopleObj:peopleList){
				sfPeopleMap.put(String.valueOf(peopleObj.id).substring(0,15),peopleObj.Full_Name__c);
			}
			for(File__c fileObj:fileList){
				sffileMap.put(fileObj.External_Id__c,fileObj.title__c);
			}
	
			for(AnalyticsWrapper.videoPopularity videoObj : videoPopularityList){
				videoObj.uploader = sfPeopleMap.get(videoObj.uploader);	
				videoObj.url =  PageContext.getPageURL(Pages.app) + '?u=/video/' + videoObj.videoId;
				videoObj.label = sffileMap.get(videoObj.videoId) != null ? sffileMap.get(videoObj.videoId) : videoObj.label;

			}	

		return videoPopularityList;
	}

	private List<AnalyticsWrapper.KnowledgePageWrapperCsv> convertToKnowledgePage(List<Object> objectList) {
		List<AnalyticsWrapper.KnowledgePageWrapperCsv> dataList = new List<AnalyticsWrapper.KnowledgePageWrapperCsv>();
		
		AnalyticsWrapper.KnowledgePageWrapperCsv dataObj = null;
		for(Object obj : objectList){
			dataObj = new AnalyticsWrapper.KnowledgePageWrapperCsv();

			Map<String, Object> responseMap = (Map<String, Object>) obj;
			String key = (String) responseMap.get('id');
			String contentType = (String) responseMap.get('type');

			dataObj.name = Utility.decryptString((String) responseMap.get('name'));
			dataObj.url =  PageContext.getPageURL(Pages.app) + '?u=/site/' + ((String) responseMap.get('siteId')) + '/' + contentType.toLowerCase() + '/' + key;
			dataObj.type = contentType;
			dataObj.siteName = Utility.decryptString((String) responseMap.get('siteName'));
			dataObj.authorName = Utility.decryptString((String) responseMap.get('authorName'));
			dataObj.publishedDate = responseMap.get('publishedDate') != null ? ((String) responseMap.get('publishedDate')).split(' ')[0] : '';
			dataObj.lastValidatedDateTime = responseMap.get('lastValidatedDateTime') != null ? ((String) responseMap.get('lastValidatedDateTime')).split(' ')[0] : '';
			dataObj.validationRequired = (Boolean) responseMap.get('validationRequired');
			dataObj.validationExpired = responseMap.get('validationExpired') != null ? ((String) responseMap.get('validationExpired')).split(' ')[0] : '';
			dataObj.views = (Integer) responseMap.get('views');

			dataList.add(dataObj);

		}

		return dataList;
	}

	private List<AnalyticsWrapper.ContentViewsCsvWrapper> convertToContentViewsByTypeCsv(List<Object> objectList){
		List<AnalyticsWrapper.ContentViewsCsvWrapper> cvcList = new List<AnalyticsWrapper.ContentViewsCsvWrapper>();
		
		List<String> peopleIdList = fetchIds(objectList);
		if(peopleIdList != null && !peopleIdList.isEmpty()){
			Map<String, people__c> sfPeopleMap = new Map<String, people__c>([SELECT id, Full_Name__c, Company_Name__c, Email__c,
																		Division__c, Department__c, city__c, state__c, country__c
																		FROM people__c where id IN:peopleIdList]);
			AnalyticsWrapper.ContentViewsCsvWrapper cvcWrapper = null;
			if(!sfPeopleMap.isEmpty()){
				Map<String, Object> peopleDataMap = null;
				String peopleid = null;
				for(Object resultObj : objectList){
					peopleDataMap = (Map<String, Object>) resultObj;
					peopleid = (String) peopleDataMap.get('id');
					
					if(sfPeopleMap.containsKey(peopleid)){
						cvcWrapper = new AnalyticsWrapper.ContentViewsCsvWrapper();

						cvcWrapper.name = sfPeopleMap.get(peopleid).Full_Name__c;
						cvcWrapper.email = sfPeopleMap.get(peopleid).Email__c;
						cvcWrapper.companyName = sfPeopleMap.get(peopleid).Company_Name__c;
						cvcWrapper.division = sfPeopleMap.get(peopleid).Division__c;
						cvcWrapper.department = sfPeopleMap.get(peopleid).Department__c;
						cvcWrapper.country = sfPeopleMap.get(peopleid).country__c;
						cvcWrapper.state = sfPeopleMap.get(peopleid).state__c;
						cvcWrapper.city = sfPeopleMap.get(peopleid).city__c;
						cvcWrapper.pageViews = (long) peopleDataMap.get('pageViews');
						cvcWrapper.eventViews = (long) peopleDataMap.get('eventViews');
						cvcWrapper.albumViews = (long) peopleDataMap.get('albumViews');
						cvcWrapper.blogViews = (long) peopleDataMap.get('blogViews');

						cvcList.add(cvcWrapper);
					}
				}
			}															
		}	

		return cvcList;
	}

	private List<AnalyticsWrapper.ContentInformation> convertToContentPublicationsCsv(List<Object> objectList){
		List<AnalyticsWrapper.ContentInformation> cpdList = new List<AnalyticsWrapper.ContentInformation>();
		AnalyticsWrapper.ContentInformation cpd = null;
		Map<String, Object> contentobj = null;
		String contentId = null;
		String authorId = null;
		String siteId = null;
		String siteType = null;
		for(Object obj : objectList){
			contentobj = (Map<String, Object>) obj;

			contentId = (String) contentObj.get('content_id');
			authorId = (String) contentObj.get('authorId');
			siteId = (String) contentObj.get('siteId');
			siteType = (String) contentObj.get('siteType');

			cpd = new AnalyticsWrapper.ContentInformation();

			cpd.title = Utility.decryptString((String) contentObj.get('content_title'));
			cpd.type = (String) contentObj.get('content_type');			

			cpd.siteName = Utility.decryptString((String) contentObj.get('siteName'));
			cpd.authorName = Utility.decryptString((String) contentObj.get('authorName'));
			cpd.publishedDate = (String) contentObj.get('publishedAt');

			if('Unlisted'.equalsIgnoreCase(siteType)){
				cpd.url = '';
			} else {
				if('Page'.equalsIgnoreCase(cpd.type) || 'Event'.equalsIgnoreCase(cpd.type) || 'Album'.equalsIgnoreCase(cpd.type)){
					cpd.url =  PageContext.getPageURL(Pages.app)+'?u=/site/'+siteId+'/'+cpd.type.toLowerCase()+'/'+contentId;
				}else if('BlogPost'.equalsIgnoreCase(cpd.type)){
					cpd.url =  PageContext.getPageURL(Pages.app)+'?u=/people/'+authorId+'/blog/'+contentId;
				} 
			}

			if('BlogPost'.equalsIgnoreCase(cpd.type)){
				cpd.type = LocaleContext.getLabel(UserContext.languageLocaleKey, 'common.blog_post');

			} else if('Event'.equalsIgnoreCase(cpd.type)){
				cpd.type = LocaleContext.getLabel(UserContext.languageLocaleKey, 'common.event');
				
			} else if('Page'.equalsIgnoreCase(cpd.type)){
				cpd.type = LocaleContext.getLabel(UserContext.languageLocaleKey, 'common.page');
			
			} else if('Album'.equalsIgnoreCase(cpd.type)){
				cpd.type = LocaleContext.getLabel(UserContext.languageLocaleKey, 'common.album');
			
			}
			
			cpdList.add(cpd);
		}

		return cpdList;
	}

	private List<AnalyticsWrapper.ProfileCompletenessCsvWrapper> convertToPeopleCompletenessCsv(List<Object> objectList){
		List<AnalyticsWrapper.ProfileCompletenessCsvWrapper> profileCompleteCsvWrapperList = new List<AnalyticsWrapper.ProfileCompletenessCsvWrapper>();
		List<String> peopleIdList = fetchIds(objectList);

		if(peopleIdList != null && !peopleIdList.isEmpty()){
			Map<String, people__c> sfPeopleMap = new Map<String, people__c>([SELECT id, Full_Name__c, Company_Name__c, Email__c,
																		Division__c, Department__c, city__c, state__c, country__c
																		FROM people__c where id IN:peopleIdList]);
																		
			AnalyticsWrapper.ProfileCompletenessCsvWrapper pccWrapperObj = null;
			if(!sfPeopleMap.isEmpty()){
				Map<String, Object> peopleDataMap = null;
				String peopleid = null;
				for(Object resultObj : objectList){
					peopleDataMap = (Map<String, Object>) resultObj;
					peopleid = (String) peopleDataMap.get('id');
					
					if(sfPeopleMap.containsKey(peopleid)){
						pccWrapperObj = new AnalyticsWrapper.ProfileCompletenessCsvWrapper();

						pccWrapperObj.id = peopleid;
						pccWrapperObj.name = sfPeopleMap.get(peopleid).Full_Name__c;
						pccWrapperObj.email = sfPeopleMap.get(peopleid).Email__c;
						pccWrapperObj.companyName = sfPeopleMap.get(peopleid).Company_Name__c;
						pccWrapperObj.division = sfPeopleMap.get(peopleid).Division__c;
						pccWrapperObj.department = sfPeopleMap.get(peopleid).Department__c;
						pccWrapperObj.country = sfPeopleMap.get(peopleid).country__c;
						pccWrapperObj.state = sfPeopleMap.get(peopleid).state__c;
						pccWrapperObj.city = sfPeopleMap.get(peopleid).city__c;
						pccWrapperObj.profileImage = (Boolean) peopleDataMap.get('isProfileImage');
						pccWrapperObj.phoneNumber = (Boolean) peopleDataMap.get('isPhoneNumber');
						pccWrapperObj.aboutText = (Boolean) peopleDataMap.get('isAboutText');
						pccWrapperObj.birthday = (Boolean) peopleDataMap.get('isBirthday');

						profileCompleteCsvWrapperList.add(pccWrapperObj);
					}
				}
			}															
		}
		
		return profileCompleteCsvWrapperList;
	}

	private AnalyticsWrapper.ProfileCompleteness convertToPeopleCompleteness(Map<String, Object> resultObj){
		AnalyticsWrapper.ProfileCompleteness profileCompObj = new AnalyticsWrapper.ProfileCompleteness();
		if(resultObj != null){
			List<AnalyticsWrapper.ProfileCompletenessData> profileDataList = new List<AnalyticsWrapper.ProfileCompletenessData>();
			AnalyticsWrapper.ProfileCompletenessData profiledata = null;
			
			for(String key : resultObj.keySet()){
				profiledata = new AnalyticsWrapper.ProfileCompletenessData();
				
				if(key.equalsIgnoreCase('totalUserCount')){
					profileCompObj.totalUserCount = (Integer) resultObj.get(key);
				}
				if(key.equalsIgnoreCase('profilePhotoCount')){
					profiledata.label =  LocaleContext.getLabel(UserContext.languageLocaleKey, 'analytics.profile_completeness.profile_photo');
					profiledata.value = (Integer) resultObj.get(key);

					profileDataList.add(profiledata);
				}
				if(key.equalsIgnoreCase('phoneCount')){
					profiledata.label = LocaleContext.getLabel(UserContext.languageLocaleKey, 'analytics.profile_completeness.phone');
					profiledata.value = (Integer) resultObj.get(key);
					
					profileDataList.add(profiledata);
				}
				if(key.equalsIgnoreCase('aboutMeCount')){
					profiledata.label = LocaleContext.getLabel(UserContext.languageLocaleKey, 'analytics.profile_completeness.about_text');
					profiledata.value = (Integer) resultObj.get(key);
					
					profileDataList.add(profiledata);
				}
				if(key.equalsIgnoreCase('birthdateCount')){
					profiledata.label = LocaleContext.getLabel(UserContext.languageLocaleKey, 'analytics.profile_completeness.birthday');
					profiledata.value = (Integer) resultObj.get(key);
					
					profileDataList.add(profiledata);
				}
			}

			profileCompObj.profileCompletenessList = profileDataList;
		}

		return profileCompObj;
	}
	
	private AnalyticsWrapper.PerformanceSites convertToPerformanceSites(List<Object> objectList) {
		AnalyticsWrapper.PerformanceSites wrapperObj = new AnalyticsWrapper.PerformanceSites();
		List<AnalyticsWrapper.PerformanceSitesData> dataList = new List<AnalyticsWrapper.PerformanceSitesData>();

		for(Object record : objectList){
			AnalyticsWrapper.PerformanceSitesData dataObj = new AnalyticsWrapper.PerformanceSitesData();
			Map<String, Object> rec = (Map<String, Object>) record;

			dataObj.name = Utility.decryptString((String) rec.get('site_name'));
			dataObj.isActive = (Boolean) rec.get('isActive');
			dataObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + ((String) rec.get('id')) + '/' + ((String) rec.get('landingPage'));
			dataObj.count = (Integer) rec.get('count');

			dataList.add(dataObj);
		}
		dataList.sort();
		wrapperObj.data = (size!=null) ? (List<AnalyticsWrapper.PerformanceSitesData>)getListToReturn(dataList,List<AnalyticsWrapper.PerformanceSitesData>.class) : dataList;
		
		return wrapperObj;
	}
	
	private AnalyticsWrapper.PeoplePerformanceWrappper convertToPerformancePeople(Map<String, Object> result) {
		List<Object> objectList = (List<Object>)result.get('data');
		long totalRecordsCount = result.containsKey('totalRecordsCount') ? (long)result.get('totalRecordsCount') : null;
		Map<String,Integer> idWithCountMap = fetchIdsWithCountMap(objectList);
		Map<String,people__c> peopleMap = new Map<String,people__c>([select id,Full_Name__c,user__r.isactive,Company_Name__c,Email__c,Segment__r.name__c,
																		Division__c,Department__c,city__c,state__c,country__c, People_Category__r.name__c
																		, Phone__c, Title__c from people__c where id IN:idWithCountMap.keySet()]);

		AnalyticsWrapper.PeoplePerformanceWrappper wrapperObj = new AnalyticsWrapper.PeoplePerformanceWrappper();
		List<AnalyticsWrapper.PeoplePerformanceData> dataList = new List<AnalyticsWrapper.PeoplePerformanceData>();
		
		for(Object obj : objectList){
			Map<String,Object> mapOfParams = (Map<String,Object>)obj;
			String key = (String)mapOfParams.get('id');
			String siteName = mapOfParams.containsKey('siteName') ? (String)mapOfParams.get('siteName') : null;
			String siteRole = mapOfParams.containsKey('siteRole') ? (String)mapOfParams.get('siteRole') : null;
			String role = mapOfParams.containsKey('role') ? (String)mapOfParams.get('role') : null;
			AnalyticsWrapper.PeoplePerformanceData dataObj = new AnalyticsWrapper.PeoplePerformanceData();
			if(peopleMap.containskey(key)){
				dataObj.label = peopleMap.get(key).Full_Name__c;
				dataObj.isActive = peopleMap.get(key).user__r.isactive;
				dataObj.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + key;
				dataObj.value = idWithCountMap.get(key);
				dataObj.email = peopleMap.get(key).Email__c;
				dataObj.companyName = peopleMap.get(key).Company_Name__c;
				dataObj.segment = peopleMap.get(key).Segment__r.name__c;
				dataObj.division = peopleMap.get(key).Division__c;
				dataObj.department = peopleMap.get(key).Department__c;
				dataObj.city = peopleMap.get(key).city__c;
				dataObj.state = peopleMap.get(key).state__c;
				dataObj.country = peopleMap.get(key).country__c;
				if(SimpplrContext.isPeopleCategoryEnable){
					dataObj.category = peopleMap.get(key).People_Category__r.name__c;
				}
				dataObj.phone = peopleMap.get(key).Phone__c;
				dataObj.title = peopleMap.get(key).Title__c;
				if(String.isNotBlank(siteName)){
					dataObj.siteName = siteName;
				}
				if(String.isNotBlank(role)){
					dataObj.role = LocaleContext.getLabel(UserContext.languageLocaleKey, 'analytics.role_group.' + role);
				}
				if(String.isNotBlank(siteRole)){
					dataObj.siteRole = LocaleContext.getLabel(UserContext.languageLocaleKey, 'analytics.role_group.' + siteRole);
				}
				
				dataList.add(dataObj);
			}
		}
		wrapperObj.data = dataList;
		wrapperObj.totalRecordsCount = totalRecordsCount;

		return wrapperObj;
	}
	
	private AnalyticsWrapper.PerformanceContent convertToPerformanceContent(List<Object> objectList, String siteId, String metric, Boolean hasLowActivityContent) {
		AnalyticsWrapper.PerformanceContent wrapperObj = new AnalyticsWrapper.PerformanceContent();
		List<AnalyticsWrapper.PerformanceContentData> dataList = new List<AnalyticsWrapper.PerformanceContentData>();
		
		AnalyticsWrapper.PerformanceContentData dataObj = null;
		for(Object obj : objectList){
			dataObj = new AnalyticsWrapper.PerformanceContentData();

			Map<String, Object> responseMap = (Map<String, Object>) obj;
			String key = (String) responseMap.get('id');
			String contentType = (String) responseMap.get('type');

			dataObj.name = Utility.decryptString((String) responseMap.get('name')); 
			if('Page'.equalsIgnoreCase(contentType) || 'Event'.equalsIgnoreCase(contentType) || 'Album'.equalsIgnoreCase(contentType)){
				dataObj.url =  PageContext.getPageURL(Pages.app) + '?u=/site/' + ((String) responseMap.get('siteId')) + '/' + contentType.toLowerCase() + '/' + key;
			}else if('BlogPost'.equalsIgnoreCase(contentType)){
				dataObj.url =  PageContext.getPageURL(Pages.app) + '?u=/people/' + ((String) responseMap.get('authorId')) + '/blog/' + key;
			}
			
			dataObj.count = (Integer) responseMap.get('count');
			dataObj.type = contentType;
			dataObj.siteName = Utility.decryptString((String) responseMap.get('siteName'));
			dataObj.authorName = Utility.decryptString((String) responseMap.get('authorName'));
			dataObj.publishedDate = ((String) responseMap.get('publishedDate')).split(' ')[0];
			dataObj.status = (String) responseMap.get('status');
			if('popularity'.equalsIgnoreCase(metric)){
				dataObj.shares = (Integer) responseMap.get('shares');
				dataObj.replies = (Integer) responseMap.get('replies');
				dataObj.favorites = (Integer) responseMap.get('favorites');
				dataObj.posts = (Integer) responseMap.get('posts');
				dataObj.likes = (Integer) responseMap.get('likes');
				dataObj.views = (Integer) responseMap.get('views');
				dataObj.value = (Integer) responseMap.get('popularityScore');
			}else{
				dataObj.views = (Integer) responseMap.get('count');
			}
			dataList.add(dataObj);

		}
		wrapperObj.data = dataList;

		if('views'.equalsIgnoreCase(metric)){
			wrapperObj.hasLowActivityContent = hasLowActivityContent;
		}
		
		return wrapperObj;
	}
	
	private AnalyticsWrapper.PerformanceTopics convertToPerformanceTopics(List<Object> objectList) {
		Map<String,Integer> idWithCountMap = fetchIdsWithCountMap(objectList);
		Map<String,Topic> topicMap = new Map<String,Topic>([select id,name from Topic where id IN:idWithCountMap.keySet()]);
			
		AnalyticsWrapper.PerformanceTopics wrapperObj = new AnalyticsWrapper.PerformanceTopics();
		List<AnalyticsWrapper.PerformanceTopicsData> dataList = new List<AnalyticsWrapper.PerformanceTopicsData>();
		
		for(String key : idWithCountMap.keySet()){
			AnalyticsWrapper.PerformanceTopicsData dataObj = new AnalyticsWrapper.PerformanceTopicsData();
			if(topicMap.containskey(key)){
				dataObj.name = topicMap.get(key).name;
				dataObj.url = PageContext.getPageURL(Pages.app)+ '?u=/topic/' + key;
				dataObj.count = idWithCountMap.get(key);
				dataList.add(dataObj);
			}
		}
		dataList.sort();
		wrapperObj.data = (size!=null) ? (List<AnalyticsWrapper.PerformanceTopicsData>)getListToReturn(dataList,List<AnalyticsWrapper.PerformanceTopicsData>.class) : datalist;
		return wrapperObj;
	}
	
	private AnalyticsWrapper.PerformanceSearch convertToPerformanceSearch(List<Object> objectList) {
		AnalyticsWrapper.PerformanceSearch wrapperObj = new AnalyticsWrapper.PerformanceSearch();
		List<AnalyticsWrapper.PerformanceSearchData> dataList = new List<AnalyticsWrapper.PerformanceSearchData>();
		for(Object record : objectList){
			AnalyticsWrapper.PerformanceSearchData dataObj = new AnalyticsWrapper.PerformanceSearchData();
			Map<String,Object> rec = (Map<String,Object>)record;
			dataObj.name = (String)rec.get('name');
			dataObj.url = PageContext.getPageURL(Pages.app) + '?u=/search&term=' + EncodingUtil.urlEncode(dataObj.name, 'UTF-8');
			dataObj.count = (Integer)rec.get('count');
			dataList.add(dataObj);
		}
		wrapperObj.data = dataList;
		return wrapperObj;
	}
	
	private AnalyticsWrapper.SearchData getSearchesByResultType(List<Object> objectList,String resultType){
		AnalyticsWrapper.SearchData sdata = new AnalyticsWrapper.SearchData();
		
		List<String> ids = new List<String>();
		ids = fetchIds(objectList);
		
		Map<String,Segment__c> segmentMap;
		Map<String,People_Category__c> categoryMap = new Map<String,People_Category__c>();
		
		if('segment'.equalsignoreCase(resultType)){		
			Map<String, Object> soqlParamMap = new  Map<String, Object>();
			soqlParamMap.put('soqlParam1', ids);
			String query = 'select id,name__c from Segment__c where id IN :soqlParam1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			segmentMap = new Map<String,Segment__c>((List<Segment__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap));
			
		} else if('category'.equalsignoreCase(resultType)){
			String pCatQuery = 'SELECT Id, Name__c FROM People_Category__c WHERE Id IN :soqlParam1';

			Map<String, Object> sqlParamMap = new Map<String, Object>();
			sqlParamMap.put('soqlParam1', ids);

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<People_Category__c> pCatList = (List<People_Category__c>)SIMPESAPI.accessController().queryAsUser(pCatQuery, sqlParamMap);

			for(People_Category__c pCatObj : pCatList) {
				categoryMap.put(pCatObj.Id, pCatObj);
			}
		}
		List<AnalyticsWrapper.ViewsOverTime> viewsOverTimeList = new List<AnalyticsWrapper.ViewsOverTime>();
		for(Object obj : objectList){
			Map<String,Object> rec = (Map<String,Object>)obj;
			String id = (String)rec.get('id');
			AnalyticsWrapper.ViewsOverTime viewsOverTimeObj = new AnalyticsWrapper.ViewsOverTime();
			if('segment'.equalsignoreCase(resultType)){
				viewsOverTimeObj.label = segmentMap.get(id).name__c;
			
			}else if('category'.equalsignoreCase(resultType)){
				if(categoryMap.containsKey(id)) {
		    		viewsOverTimeObj.label = categoryMap.get(id).name__c;
		    		viewsOverTimeObj.url = PageContext.getPageURL(Pages.app) + '?u=/people&userCategory=' + id;
				
				} else if(ServiceConstants.UNCATEGORIZED_CATEGORY_STR.equalsIgnoreCase(id)) {
					viewsOverTimeObj.label = ServiceConstants.UNCATEGORIZED_CATEGORY_STR;
		    		viewsOverTimeObj.url = PageContext.getPageURL(Pages.app) + '?u=/people&userCategory=' + ServiceConstants.UNCATEGORIZED_CATEGORY_STR;
				
				}
			
			} else if('department'.equalsIgnoreCase(resultType)){
				viewsOverTimeObj.label = (String)rec.get('label');
				viewsOverTimeObj.url = PageContext.getPageURL(Pages.app) + '?u=/people&department=' + EncodingUtil.urlEncode(viewsOverTimeObj.label, 'UTF-8');
			
			}else if('location'.equalsIgnoreCase(resultType)){
				viewsOverTimeObj.label = (String)rec.get('label');
				viewsOverTimeObj.url = PageContext.getPageURL(Pages.app) + '?u=/people&location=' + EncodingUtil.urlEncode((String)rec.get('id'), 'UTF-8');
			}
			viewsOverTimeObj.value = (Integer)((Map<String,Object>)obj).get('value');
    		viewsOverTimeList.add(viewsOverTimeObj);
		}
		
		sdata.searchList = viewsOverTimeList;
		return sdata;
	}
	
	private List<AnalyticsWrapper.ContentViewsCSV> getContentViewsCsv(List<Object> objectList){
		List<AnalyticsWrapper.ContentViewsCSV> contentViewsList = new List<AnalyticsWrapper.ContentViewsCSV>();
		
		List<String> ids = new List<String>();
		ids = fetchIds(objectList);
		Map<String,people__c> peopleMap = new Map<String,people__c>([select id,Full_Name__c,Email__c,Phone__c,title__c,
																		Department__c,city__c,state__c,country__c 
																		from people__c where id IN:ids]);
		
		for(Object obj : objectList){
			Map<String,Object> mapOfParams = (Map<String,Object>)obj;
			String key = (String)mapOfParams.get('id');
			AnalyticsWrapper.ContentViewsCSV dataObj = new AnalyticsWrapper.ContentViewsCSV();
			if(peopleMap.containskey(key)){
				dataObj.totalViews = (Integer)mapOfParams.get('totalViews');
				dataObj.lastViewed = (String)mapOfParams.get('lastViewed');
				dataObj.firstViewed = (String)mapOfParams.get('firstViewed');
				if(mapOfParams.containsKey('siteName') && String.isNotBlank((String)mapOfParams.get('siteName'))){ //For all content types except blog post
					dataObj.siteName = mapOfParams.containsKey('siteName') ? (String)mapOfParams.get('siteName') : '';
					dataObj.role = mapOfParams.containsKey('role') ? LocaleContext.getLabel(UserContext.languageLocaleKey, 'analytics.role_group.' + (String)mapOfParams.get('role')) : '';
					dataObj.siteRole = mapOfParams.containsKey('siteRole') ? LocaleContext.getLabel(UserContext.languageLocaleKey, 'analytics.role_group.' + (String)mapOfParams.get('siteRole')) : '';
				}
				
				dataObj.name = peopleMap.get(key).Full_Name__c;
				dataObj.email = peopleMap.get(key).Email__c;
				dataObj.phone = peopleMap.get(key).phone__c;
				dataObj.department = peopleMap.get(key).Department__c;
				dataObj.jobTitle = peopleMap.get(key).title__c;
				dataObj.status = (String)mapOfParams.get('status');
				dataObj.location = Utility.buildLocation(peopleMap.get(key).city__c,peopleMap.get(key).state__c,peopleMap.get(key).country__c);
				contentViewsList.add(dataObj);
			}
		}
		return contentViewsList;
	}

	private List<AnalyticsWrapper.ContentInformation> convertToContentViewsListWrapperWhenFilterIsNull(List<Object> objectList){
		List<AnalyticsWrapper.ContentInformation> contentInfoList = new List<AnalyticsWrapper.ContentInformation>();
		Map<String, Object> recordObj = null;
		AnalyticsWrapper.ContentInformation info = null;
		String id = null;
		for(Object obj : objectList){
			recordObj = (Map<String, Object>) obj;
			id = (String) recordObj.get('id');
			String contentType = (String) recordObj.get('type');
			
			info = new AnalyticsWrapper.ContentInformation();
			info.label = Utility.decryptString((String) recordObj.get('label'));
			info.title = info.label;
			info.type = contentType;
			info.authorName = Utility.decryptString((String) recordObj.get('authorName'));
			info.sitename = Utility.decryptString((String) recordObj.get('siteName'));
			info.publishedDate = ((String) recordObj.get('publishedDate')).split(' ')[0];
			info.value = (Integer) recordObj.get('value');
			info.status = (String) recordObj.get('status');
			info.id = id;
			info.siteId = (String) recordObj.get('siteId');

			if('Page'.equalsIgnoreCase(contentType) || 'Event'.equalsIgnoreCase(contentType) || 'Album'.equalsIgnoreCase(contentType)){
				info.url =  PageContext.getPageURL(Pages.app)+'?u=/site/'+(String) recordObj.get('siteId')+'/'+contentType.toLowerCase()+'/'+id;
			}else if('BlogPost'.equalsIgnoreCase(contentType)){
				info.url =  PageContext.getPageURL(Pages.app)+'?u=/people/'+(String) recordObj.get('authorId')+'/blog/'+id;
			}
			
			contentInfoList.add(info);
		}

		return contentInfoList;
	}
	
	private AnalyticsWrapper.ViewsList convertToContentAndLoginAndEngagementListByCategory(List<Object> objectList,String resultType,String action){
		 AnalyticsWrapper.ViewsList contentViewsList = new AnalyticsWrapper.ViewsList();
		 List<AnalyticsWrapper.ViewsOverTime> viewsOverTimeList = new List<AnalyticsWrapper.ViewsOverTime>();
		 if('segment'.equalsIgnoreCase(resultType)){
			List<String> ids = new List<String>();
			ids = fetchIds(objectList);
			Map<String, Object> soqlParamMap = new  Map<String, Object>();
			soqlParamMap.put('soqlParam1', ids);
			String query = 'select id,name__c from Segment__c where id IN :soqlParam1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			Map<String,Segment__c> segmentMap = new Map<String,Segment__c>((List<Segment__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap));
			
			for(Object obj : objectList){
				Map<String,Object> mapofParams = (Map<String,Object>)obj;
				String id = (String)mapofParams.get('id');
				if(segmentMap.containsKey(id)){
					AnalyticsWrapper.ViewsOverTime viewsOverTimeObj = new AnalyticsWrapper.ViewsOverTime();
					viewsOverTimeObj.label = segmentMap.get(id).name__c;
					
					if('getEngagementList'.equalsIgnoreCase(action)){
						viewsOverTimeObj.likes = mapofParams.containskey('likes') ? (Integer)mapofParams.get('likes') : 0;
						viewsOverTimeObj.shares = mapofParams.containskey('shares') ? (Integer)mapofParams.get('shares') : 0;
						viewsOverTimeObj.posts = mapofParams.containskey('posts') ? (Integer)mapofParams.get('posts') : 0;
						viewsOverTimeObj.replies = mapofParams.containskey('replies') ? (Integer)mapofParams.get('replies') : 0;
						viewsOverTimeObj.favorites = mapofParams.containskey('favorites') ? (Integer)mapofParams.get('favorites') : 0;
					} else {
						viewsOverTimeObj.uniqueViews = mapofParams.containsKey('uniqueViews') ? (Integer)mapofParams.get('uniqueViews') : 0;
						viewsOverTimeObj.value = (Integer)((Map<String,Object>)obj).get('value');
						viewsOverTimeObj.percentageValue = (Double)((Map<String,Object>)obj).get('percentageValue');
					}
		    		viewsOverTimeList.add(viewsOverTimeObj);
				}
			}
			
		} else if('category'.equalsIgnoreCase(resultType)){
			List<String> ids = new List<String>();
			ids = fetchIds(objectList);

			Map<String,People_Category__c> categoryMap = new Map<String,People_Category__c>();
		
			String pCatQuery = 'SELECT Id, Name__c FROM People_Category__c WHERE Id IN :soqlParam1';

			Map<String, Object> sqlParamMap = new Map<String, Object>();
			sqlParamMap.put('soqlParam1', ids);

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<People_Category__c> pCatList = (List<People_Category__c>)SIMPESAPI.accessController().queryAsUser(pCatQuery, sqlParamMap);

			for(People_Category__c pCatObj : pCatList) {
				categoryMap.put(pCatObj.Id, pCatObj);
			}

			for(Object obj : objectList){
				Map<String,Object> mapofParams = (Map<String,Object>)obj;
				String id = (String)mapofParams.get('id');
				if(categoryMap.containsKey(id)){
					AnalyticsWrapper.ViewsOverTime viewsOverTimeObj = new AnalyticsWrapper.ViewsOverTime();
					viewsOverTimeObj.label = categoryMap.get(id).name__c;
					viewsOverTimeObj.url = PageContext.getPageURL(Pages.app) + '?u=/people&userCategory=' + id;
					
					if('getEngagementList'.equalsIgnoreCase(action)){
						viewsOverTimeObj.likes = mapofParams.containskey('likes') ? (Integer)mapofParams.get('likes') : 0;
						viewsOverTimeObj.shares = mapofParams.containskey('shares') ? (Integer)mapofParams.get('shares') : 0;
						viewsOverTimeObj.posts = mapofParams.containskey('posts') ? (Integer)mapofParams.get('posts') : 0;
						viewsOverTimeObj.replies = mapofParams.containskey('replies') ? (Integer)mapofParams.get('replies') : 0;
						viewsOverTimeObj.favorites = mapofParams.containskey('favorites') ? (Integer)mapofParams.get('favorites') : 0;
					}else{
						viewsOverTimeObj.uniqueViews = mapofParams.containsKey('uniqueViews') ? (Integer)mapofParams.get('uniqueViews') : 0;
						viewsOverTimeObj.value = (Integer)((Map<String,Object>)obj).get('value');
						viewsOverTimeObj.percentageValue = (Double)((Map<String,Object>)obj).get('percentageValue');
					}
		    		viewsOverTimeList.add(viewsOverTimeObj);
				} else if(ServiceConstants.UNCATEGORIZED_CATEGORY_STR.equalsIgnoreCase(id)) {
					AnalyticsWrapper.ViewsOverTime viewsOverTimeObj = new AnalyticsWrapper.ViewsOverTime();
					viewsOverTimeObj.label = ServiceConstants.UNCATEGORIZED_CATEGORY_STR;
					viewsOverTimeObj.url = PageContext.getPageURL(Pages.app) + '?u=/people&userCategory=Uncategorized';
					
					if('getEngagementList'.equalsIgnoreCase(action)){
						viewsOverTimeObj.likes = mapofParams.containskey('likes') ? (Integer)mapofParams.get('likes') : 0;
						viewsOverTimeObj.shares = mapofParams.containskey('shares') ? (Integer)mapofParams.get('shares') : 0;
						viewsOverTimeObj.posts = mapofParams.containskey('posts') ? (Integer)mapofParams.get('posts') : 0;
						viewsOverTimeObj.replies = mapofParams.containskey('replies') ? (Integer)mapofParams.get('replies') : 0;
						viewsOverTimeObj.favorites = mapofParams.containskey('favorites') ? (Integer)mapofParams.get('favorites') : 0;
					} else if('getContentViewsList'.equalsIgnoreCase(action)){
						viewsOverTimeObj.status = (String) mapofParams.get('status');
						viewsOverTimeObj.value = (Integer)((Map<String,Object>)obj).get('value');
						viewsOverTimeObj.uniqueViews = mapofParams.containsKey('uniqueViews') ? (Integer)mapofParams.get('uniqueViews') : 0;
					} else{
						viewsOverTimeObj.value = (Integer)((Map<String,Object>)obj).get('value');
						viewsOverTimeObj.percentageValue = (Double)((Map<String,Object>)obj).get('percentageValue');
					}
		    		viewsOverTimeList.add(viewsOverTimeObj);
				}
			}
			
		} else{
		
			for(Object record : objectList){
				AnalyticsWrapper.ViewsOverTime viewsOverTimeObj = new AnalyticsWrapper.ViewsOverTime();
				Map<String,Object> rec = (Map<String,Object>)record;
				viewsOverTimeObj.label = (String)rec.get('label');
				if('department'.equalsIgnoreCase(resultType)){
					viewsOverTimeObj.url = PageContext.getPageURL(Pages.app) + '?u=/people&department=' + EncodingUtil.urlEncode(viewsOverTimeObj.label, 'UTF-8');
				}else if('location'.equalsIgnoreCase(resultType)){
					viewsOverTimeObj.url = PageContext.getPageURL(Pages.app) + '?u=/people&location=' + EncodingUtil.urlEncode((String)rec.get('id'), 'UTF-8');
				}
				if('getEngagementList'.equalsIgnoreCase(action)){
					viewsOverTimeObj.likes = rec.containskey('likes') ? (Integer)rec.get('likes') : 0;
					viewsOverTimeObj.shares = rec.containskey('shares') ? (Integer)rec.get('shares') : 0;
					viewsOverTimeObj.posts = rec.containskey('posts') ? (Integer)rec.get('posts') : 0;
					viewsOverTimeObj.replies = rec.containskey('replies') ? (Integer)rec.get('replies') : 0;
					viewsOverTimeObj.favorites = rec.containskey('favorites') ? (Integer)rec.get('favorites') : 0;
				} else{
					viewsOverTimeObj.uniqueViews = rec.containsKey('uniqueViews') ? (Integer)rec.get('uniqueViews') : 0;
					viewsOverTimeObj.value = (Integer)rec.get('value');
					viewsOverTimeObj.percentageValue = (Double)rec.get('percentageValue');
				}
				viewsOverTimeList.add(viewsOverTimeObj);
			}
			
		}
		contentViewsList.data = viewsOverTimeList;
		return contentViewsList;
	}
	
	private List<AnalyticsWrapper.ViewsOverTime> getLowActivitySitesData(List<Object> objectList){
		List<AnalyticsWrapper.ViewsOverTime> dataList = new List<AnalyticsWrapper.ViewsOverTime>();
		
		for(Object obj : objectList){
			Map<String, Object> mapOfObject = (Map<String, Object>)obj;
			String key = (String) mapOfObject.get('id');
			AnalyticsWrapper.ViewsOverTime dataObj = new AnalyticsWrapper.ViewsOverTime();

			dataObj.label = Utility.decryptString((String) mapOfObject.get('name'));
			dataObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + key + '/' + ((String) mapOfObject.get('landingPage'));
			dataObj.access = ((String) mapOfObject.get('access')).toLowerCase();
			dataObj.hasAccess = (Boolean) mapOfObject.get('hasAccess');
			dataObj.id = key;
			dataObj.name = Utility.decryptString((String) mapOfObject.get('name'));
			dataObj.canManage = UserContext.sitesIManageIdSet.contains(key) ? true : false;
			dataObj.totalViewCount = (Integer) mapOfObject.get('views');

			dataList.add(dataObj);
		}

		return dataList;
	}
	
	private List<AnalyticsWrapper.ViewsOverTime> convertToViewsOverTimeListForSites(List<Object> objectList){
		List<AnalyticsWrapper.ViewsOverTime> dataList = new List<AnalyticsWrapper.ViewsOverTime>();
		
		for(Object obj : objectList){
			Map<String,Object> mapOfObject = (Map<String,Object>)obj;
			AnalyticsWrapper.ViewsOverTime dataObj = new AnalyticsWrapper.ViewsOverTime();
			
			dataObj.label = Utility.decryptString((String) mapOfObject.get('label'));
			dataObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + ((String) mapOfObject.get('id')) + '/' + (String) mapOfObject.get('landingPage');
			dataObj.access = ((String) mapOfObject.get('access')).toLowerCase();
			dataObj.isActive = (Boolean) mapOfObject.get('isActive');
			dataObj.value = (Integer) mapOfObject.get('count');
			dataObj.albums = (integer) mapOfObject.get('albums');
			dataObj.events = (integer) mapOfObject.get('events');
			dataObj.pages = (integer) mapOfObject.get('pages');
			dataObj.id = ((String) mapOfObject.get('id'));

			dataList.add(dataObj);
		}
		return dataList;
	}

	private List<AnalyticsWrapper.ViewsOverTime> convertToAppPageViewsListWrapper(List<Object> objectList){
		List<AnalyticsWrapper.ViewsOverTime> dataList = new List<AnalyticsWrapper.ViewsOverTime>();
		
		for(Object obj : objectList){
			Map<String,Object> mapOfObject = (Map<String,Object>)obj;
			AnalyticsWrapper.ViewsOverTime dataObj = new AnalyticsWrapper.ViewsOverTime();
			
			dataObj.page = (String) mapOfObject.get('page');
			dataObj.page = LocaleContext.getLabel(UserContext.languageLocaleKey, 'analytics.page_group.' + dataObj.page);
			dataObj.uniqueViewsCount = (Integer) mapOfObject.get('uniqueViewsCount');
			dataObj.uniqueViewsPercentage = (Decimal) mapOfObject.get('uniqueViewsPercentage');
			dataObj.uniqueViewsPercentage = dataObj.uniqueViewsPercentage.setScale(2);
			dataObj.totalViewsCount = (Integer) mapOfObject.get('totalViewsCount');
			dataObj.totalViewsPercentage = (Decimal) mapOfObject.get('totalViewsPercentage');
			dataObj.totalViewsPercentage = dataObj.totalViewsPercentage.setScale(2);

			dataList.add(dataObj);
		}
		return dataList;
	}
	
	private List<AnalyticsWrapper.ContentInformation> convertToContentPopularityListWrapper(List<Object> objectList){
		List<AnalyticsWrapper.ContentInformation> listToReturn = new List<AnalyticsWrapper.ContentInformation>();
		AnalyticsWrapper.ContentInformation contentData = null;
		for(Object obj : objectList){
			Map<String, Object> mapOfParams = (Map<String, Object>) obj;
			String id = (String) mapOfParams.get('id');
			String contentType = (String) mapOfParams.get('type');
			contentData = new AnalyticsWrapper.ContentInformation();
			
			contentData.label = Utility.decryptString((String) mapOfParams.get('label'));
			contentData.title = Utility.decryptString((String) mapOfParams.get('title'));
			contentData.type = contentType;
			contentData.authorName = Utility.decryptString((String) mapOfParams.get('authorName'));
			contentData.sitename = Utility.decryptString((String) mapOfParams.get('siteName'));
			contentData.publishedDate = ((String) mapOfParams.get('publishedDate')).split(' ')[0];
			contentData.shares = (Integer) mapOfParams.get('shares');
			contentData.views = (Integer) mapOfParams.get('views');
			contentData.replies = (Integer) mapOfParams.get('replies');
			contentData.favorites = (Integer) mapOfParams.get('favorites');
			contentData.posts = (Integer) mapOfParams.get('posts');
			contentData.likes = (Integer) mapOfParams.get('likes');
			contentData.totalCount = (Integer) mapOfParams.get('popularityScore');
			contentData.value = (Integer) mapOfParams.get('value');
			contentData.status =  (String) mapOfParams.get('status');
			contentData.id = id;
			contentData.siteId = (String) mapOfParams.get('siteId');

			if('Page'.equalsIgnoreCase(contentType) || 
				'Event'.equalsIgnoreCase(contentType) ||
				 'Album'.equalsIgnoreCase(contentType)){

				contentData.url =  PageContext.getPageURL(Pages.app) + '?u=/site/' + ((String) mapOfParams.get('siteId')) + '/' + contentType.toLowerCase() + '/' + id;
			}else if('BlogPost'.equalsIgnoreCase(contentType)){

				contentData.url =  PageContext.getPageURL(Pages.app) + '?u=/people/' + ((String) mapOfParams.get('authorId')) + '/blog/' + id;
			}

			listToReturn.add(contentData);
		}

		return listToReturn;
	}

	private List<AnalyticsWrapper.LabelValueData> convertToGovernanceListWrapper(List<Object> objectList){
		List<AnalyticsWrapper.LabelValueData> listToReturn = new List<AnalyticsWrapper.LabelValueData>();
		AnalyticsWrapper.LabelValueData governanceData = null;
		for(Object obj : objectList){
			Map<String, Object> mapOfParams = (Map<String, Object>) obj;
			governanceData = new AnalyticsWrapper.LabelValueData();
			
			governanceData.label = (String) mapOfParams.get('label');

			listToReturn.add(governanceData);
		}

		return listToReturn;
	}
	
	private List<AnalyticsWrapper.ViewsOverTime> convertToSitePopularityListWrapper(List<Object> objectList){
		List<AnalyticsWrapper.ViewsOverTime> viewsOverTimeList = new List<AnalyticsWrapper.ViewsOverTime>();
		List<String> ids = new List<String>();
		
		for(Object obj : objectList){
			Map<String,Object> mapOfObj = (Map<String,Object>) obj;
			
			String id = mapOfObj.containsKey('id') ? (String) mapOfObj.get('id') : null;
			AnalyticsWrapper.ViewsOverTime viewsOverTime = new AnalyticsWrapper.ViewsOverTime();
			
			viewsOverTime.label = Utility.decryptString((String) mapOfObj.get('label'));
			viewsOverTime.access = ((String) mapOfObj.get('access')).toLowerCase();
			viewsOverTime.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + id + '/' + (String) mapOfObj.get('landingPage');
			viewsOverTime.likes = mapOfObj.containsKey('likes') ? (Integer)mapOfObj.get('likes') : 0;
			viewsOverTime.favorites = mapOfObj.containsKey('favorites') ? (Integer)mapOfObj.get('favorites') : 0;
			viewsOverTime.shares = mapOfObj.containsKey('shares') ? (Integer)mapOfObj.get('shares') : 0;
			viewsOverTime.replies = mapOfObj.containsKey('replies') ? (Integer)mapOfObj.get('replies') : 0;
			viewsOverTime.posts = mapOfObj.containsKey('posts') ? (Integer)mapOfObj.get('posts') : 0;
			viewsOverTime.views = mapOfObj.containsKey('views') ? (Integer)mapOfObj.get('views') : 0;
			viewsOverTime.value = mapOfObj.containsKey('popularityScore') ? (Integer)mapOfObj.get('popularityScore') : 0;
			viewsOverTime.id = id;

			viewsOverTimeList.add(viewsOverTime);
		}
		
		return viewsOverTimeList;
	}
	
	private List<String> fetchIds(List<Object> objectList){
		List<String> ids = new List<String>();
		for(Object obj : objectList){
			Map<String,Object> record = (Map<String,Object>)obj;
			ids.add((String)record.get('id'));
		}
		return ids;
	}
	
	private Map<String,Integer> fetchIdsWithCountMap(List<Object> data){
		Map<String,Integer> idWithCountMap = new Map<String,Integer>();
		integer counter = 0;
		for(Object record : data){
			Map<String,Object> rec = (Map<String,Object>)record;
			idWithCountMap.put((String)rec.get('id'),(Integer)rec.get('count'));
			counter++;
		}
		return idWithCountMap;
	}
	
	private  List<Object> getListToReturn(List<Object> objlst, System.Type clazz){
		if(objlst.size()<=10){
			return objlst;
		}else{
			Integer counter = 0;
			List<Object> returnList = (List<Object>)clazz.newInstance();
			while(counter<10 && counter<objlst.size()) {
	    		returnList.add(objlst[counter++]);
	    	}
	    	return returnList;
		}
		
	}

	private String getExternalAnalyticsEndpoint() {
		String endPoint;
		if(SimpplrContext.isSandbox || SimpplrContext.isTestOrg || String.isBlank(SimpplrContext.packageName)) { 
			endPoint = 'https://staging.analytics.simpplr.com/analytics/';
		} else {
			endPoint = SimpplrContext.appConfig.External_Analytics_URL__c;
		}
		return endPoint;
	}
}