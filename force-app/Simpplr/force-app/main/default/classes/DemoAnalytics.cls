public with sharing class DemoAnalytics {

    public String getDummyAnalyticsData(String action, Map<String,Object> reqBody) {
		logger.logDebug('reqBody-------------------'+reqBody);
		String res = '';
		String endpoint=action;
		String groupBy=String.valueOf(reqBody.get('groupBy'));
		String type =String.valueOf(reqBody.get('type'));
		String orderBy =String.valueOf(reqBody.get('orderBy'));
		String resultType =String.valueOf(reqBody.get('resultType'));
		String filterBy =reqBody.get('filterBy')!=null ? String.valueOf(reqBody.get('filterBy')) : '';
		String siteId =String.valueOf(reqBody.get('siteId'));
		String contentId =String.valueOf(reqBody.get('contentId'));
		String metric =String.valueOf(reqBody.get('metric'));
        Boolean onlyPublished = (reqBody!=null && reqBody.containsKey('onlyPublished')) ? (Boolean)reqBody.get('onlyPublished'):false;
		String fromDt =reqBody.get('from')!=null ? String.valueOf(reqBody.get('from')) : '';
		String toDt =reqBody.get('to')!=null ? String.valueOf(reqBody.get('to')) : '';
        Boolean includeMembers = (reqBody!=null && reqBody.containsKey('includeMembers')) ? (Boolean)reqBody.get('includeMembers'):null;
        Boolean includeFollowers = (reqBody!=null && reqBody.containsKey('includeFollowers')) ? (Boolean)reqBody.get('includeFollowers'):null;
        Boolean includeOthers = (reqBody!=null && reqBody.containsKey('includeOthers')) ? (Boolean)reqBody.get('includeOthers'):null;
        
		Integer noOfDays=90;
        Integer multiplyFactor=1;
		if(String.isNotBlank(fromDt) && String.isNotBlank(toDt)){
			Date fromDate = Date.valueOf(fromDt);
			Date toDate = Date.valueOf(toDt);
			noOfDays = fromDate.daysBetween(toDate);
		}
        if(endpoint.equalsIgnoreCase('getEngagement')){
            if(filterBy.equalsIgnoreCase('site')&&endpoint.equalsIgnoreCase('getEngagement')){  
                metric='siteEngagement';
            }else if(filterBy.equalsIgnoreCase('content')&&endpoint.equalsIgnoreCase('getEngagement')){  
                metric='pageEngagement';
            }else{
                metric='appEngagement';
            }
        } 
        if(String.isNotBlank(siteId)){
            if(endpoint.equalsIgnoreCase('getContentPublications')){  
                metric='siteContentPublications';
            }else if(endpoint.equalsIgnoreCase('getContentViewsByType')){  
                metric='siteContentViewsByType';
            }else if(endpoint.equalsIgnoreCase('getContentReferralSources')){  
                metric='siteContentReferralSources';
            }else if(endpoint.equalsIgnoreCase('getKnowledgePageStats')){  
                metric='siteKnowledgePageStats';
            }
        } 
        if(String.isNotBlank(contentId)){
            if(endpoint.equalsIgnoreCase('getContentReferralSources')){  
                metric='pageContentReferralSources';
            }
            else if(endpoint.equalsIgnoreCase('getContentViewsList')){  
                metric='pageContentViewsList';
            }
        }
        if(onlyPublished == true && endpoint.equalsIgnoreCase('getContentPublications')){
            metric='appOnlyPublished';
        }
        if((endpoint.equalsIgnoreCase('getViewedByMetricData') || endpoint.equalsIgnoreCase('getConsumptionOverTime')) && String.isNotBlank(siteId)){
            Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', siteId); 
            String siteQuery = 'SELECT Id, Site_Type__c FROM Simpplr_Site__c where Id =:soqlParam1 LIMIT 1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<simpplr_site__c> siteObjectList = (List<simpplr_site__c>)SIMPESAPI.accessController().queryAsUser(siteQuery, soqlParamMap);
            String siteType = !siteObjectList.isEmpty() ? siteObjectList[0].Site_Type__c : '';
            if(endpoint.equalsIgnoreCase('getViewedByMetricData')){
                resultType = (String.isNotBlank(siteType) && (siteType.equalsIgnoreCase('Private') || siteType.equalsIgnoreCase('Unlisted'))) ? 'privateSite' : 'publicSite';
            }else if(endpoint.equalsIgnoreCase('getConsumptionOverTime')){
                resultType = (String.isNotBlank(siteType) && (siteType.equalsIgnoreCase('Private') || siteType.equalsIgnoreCase('Unlisted'))) ? 'all' : '';
            }
        }	  
        if(includeMembers != null && includeFollowers != null && includeOthers != null){
            if(includeMembers && includeFollowers && includeOthers == false) {
                resultType='membersfollowers';
            }else if(includeMembers && includeFollowers == false && includeOthers == false) {
                resultType='onlymembers';
            }else if(includeMembers == false && includeFollowers && includeOthers == false) {
                resultType='onlyfollowers';
            }else if(includeMembers == false && includeFollowers && includeOthers) {
                resultType='followersothers';
            }else if(includeMembers && includeFollowers == false && includeOthers) {
                resultType='membersothers';
            }else if(includeMembers == false && includeFollowers == false && includeOthers) {
                resultType='onlyothers';
            }else if(includeMembers && includeFollowers && includeOthers) {
                resultType='all';
            }
		}
        if(endpoint.equalsIgnoreCase('getViewedByMetricData') && String.isBlank(siteId)){
            resultType = 'publicSite'; // for Blogs demo data , resultType publicSite is used
        }
		String queryStr = 'SELECT Multiply_Factor__c, Type__c, Tile_heading__c, Result_type__c, Tab__c, Json_Data_7Days__c, Json_Data_30Days__c, Json_Data__c, Analytics_Type__c, Endpoint__c, Id, Name FROM Demo_Analytics__c  where Endpoint__c = :endpoint  ';
		if(String.isNotBlank(type)) {
			queryStr +='AND Type__c = :type  ';
		}
		if(String.isNotBlank(orderBy)) {
			queryStr +='AND OrderBy__c = :orderBy  ';
		}
		if(String.isNotBlank(resultType)) {
			queryStr +='AND Result_type__c = :resultType  ';
		}else{
			resultType='';
			queryStr +='AND Result_type__c = :resultType  ';
		}
		if(String.isNotBlank(metric)) {
			queryStr +='AND Metric__c = :metric  ';
		}		
		if(Test.isRunningTest()) {
            res = '{}';
		} else {
			List<SObject> sObjectList = Database.query(queryStr);
            logger.logDebug('DemoAnalytics.getDummyAnalyticsData()----Record Id----' + sObjectList[0].id);
            multiplyFactor = sObjectList[0].get('Multiply_Factor__c')==null ? 1:Integer.valueOf(sObjectList[0].get('Multiply_Factor__c'));
            if(noOfDays <= 7){
				res = sObjectList[0].get('Json_Data_7Days__c')==null ? '':String.valueOf(sObjectList[0].get('Json_Data_7Days__c'));
			
            } else if(noOfDays > 7 && noOfDays<=30) {
				res = sObjectList[0].get('Json_Data_30Days__c')==null ? '':String.valueOf(sObjectList[0].get('Json_Data_30Days__c'));
			
            } else {
                noOfDays = 90;
				res = sObjectList[0].get('Json_Data__c')==null ? '':String.valueOf(sObjectList[0].get('Json_Data__c'));			
			}
		}
		Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(res);
		Map<String, Object> result = (Map<String, Object>)m.get('result');
		if('getLoginsOverTime'.equalsIgnoreCase(action)){  
			res = getDateAdjustedLoginsOverTimeData(noOfDays, JSON.serialize(result),multiplyFactor);

		} else if('getContentViewsOverTime'.equalsIgnoreCase(action)) {
            res = getDateAdjustedContentViewsOverTime(noOfDays, JSON.serialize(result.get('data')));			
		
        } else if('getEngagement'.equalsIgnoreCase(action) || 'getContentEngagement'.equalsIgnoreCase(action)){ 
			res = getDateAdjustedEngagementData(noOfDays, JSON.serialize(result));

		} else if('getSearches'.equalsIgnoreCase(action)){
            res = getDateAdjustedSearchesData(noOfDays, JSON.serialize(result.get('data')));			
		
        } else if('getContentViews'.equalsIgnoreCase(action)){
			res = getDateAdjustedContentViewsData(noOfDays, JSON.serialize(result));
		
        } else if('getSiteViews'.equalsIgnoreCase(action) || 'getSiteViewsTotal'.equalsIgnoreCase(action)){
			res = getDateAdjustedSiteViewsData(noOfDays, JSON.serialize(result));

		} else if('getAdoptionAverage'.equalsIgnoreCase(action)) { 
			res = getMultipledAdoptionAverageData(JSON.serialize(result),multiplyFactor);	

		} else if('getPeopleOverview'.equalsIgnoreCase(action)){
			res = getMultipledPeopleOverviewData(JSON.serialize(result),multiplyFactor);

		} else if('getAdoptionData'.equalsIgnoreCase(action)){
			res = getMultipledAdoptionData(JSON.serialize(result),multiplyFactor);

		} else if('getNewsletters'.equalsIgnoreCase(action)){
            res = JSON.serialize(result);

        } else if('getCampaigns'.equalsIgnoreCase(action)){
            res = JSON.serialize(result);

        } else if('getMonthlyReports'.equalsIgnoreCase(action)){
            res = getMonthsShiftedMonthlyReports(JSON.serialize(result));
        
        } else if('getLastSyncDate'.equalsIgnoreCase(action)){
            res = getLastSyncSwiftedDate(JSON.serialize(result));
        
        } else if('getConsumptionOverTime'.equalsIgnoreCase(action)){
			res = getDateAdjustedConsumptionOverTimeData(noOfDays, JSON.serialize(result));
		
        }
		return res;
	}

    @TestVisible
    public Object getDummyPeoplePerformanceData(String responseBody) {
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        Map<String, Object> result = (Map<String, Object>)m.get('result');
        List<Object> objectList = (List<Object>)result.get('data');
        AnalyticsWrapper.PeoplePerformanceWrappper wrapperObj = new AnalyticsWrapper.PeoplePerformanceWrappper();
		List<AnalyticsWrapper.PeoplePerformanceData> dataList = new List<AnalyticsWrapper.PeoplePerformanceData>();
		
		for(Object obj : objectList){
			Map<String,Object> mapOfParams = (Map<String,Object>)obj;
			String key = (String)mapOfParams.get('id');
			AnalyticsWrapper.PeoplePerformanceData dataObj = new AnalyticsWrapper.PeoplePerformanceData();
            String label = (String)mapOfParams.get('label');
            dataObj.label = label;
            dataObj.value = Integer.valueOf(mapOfParams.get('count'));
            dataList.add(dataObj);
		}
		wrapperObj.data = dataList;

		return wrapperObj;
    } 

    @TestVisible
    public Object getDummySegmentData(String action,String responseBody) {
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        Map<String, Object> result = (Map<String, Object>)m.get('result');
        List<Object> objectList = (List<Object>)result.get('data');
        AnalyticsWrapper.ViewsList contentViewsList = new AnalyticsWrapper.ViewsList();
		List<AnalyticsWrapper.ViewsOverTime> viewsOverTimeList = new List<AnalyticsWrapper.ViewsOverTime>();
        for(Object obj : objectList){
            AnalyticsWrapper.ViewsOverTime viewsOverTimeObj = new AnalyticsWrapper.ViewsOverTime();
            Map<String,Object> mapOfParams = (Map<String,Object>)obj;
            viewsOverTimeObj.label = (String)mapOfParams.get('label');
            
            if('getEngagementList'.equalsIgnoreCase(action)){
                viewsOverTimeObj.likes = mapofParams.containskey('likes') ? (Integer)mapofParams.get('likes') : 0;
                viewsOverTimeObj.shares = mapofParams.containskey('shares') ? (Integer)mapofParams.get('shares') : 0;
                viewsOverTimeObj.posts = mapofParams.containskey('posts') ? (Integer)mapofParams.get('posts') : 0;
                viewsOverTimeObj.replies = mapofParams.containskey('replies') ? (Integer)mapofParams.get('replies') : 0;
                viewsOverTimeObj.favorites = mapofParams.containskey('favorites') ? (Integer)mapofParams.get('favorites') : 0;
            }else {
                viewsOverTimeObj.uniqueViews = mapofParams.containsKey('uniqueViews') ? (Integer)mapofParams.get('uniqueViews') : 0;
                viewsOverTimeObj.value = (Integer)((Map<String,Object>)obj).get('value');
                viewsOverTimeObj.percentageValue = (Double)((Map<String,Object>)obj).get('percentageValue');
            }
            viewsOverTimeList.add(viewsOverTimeObj);
		}
		contentViewsList.data = viewsOverTimeList;
		return contentViewsList;
    }

    @TestVisible
    public Object getDummySearchSegmentData(String action,String responseBody) {
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        Map<String, Object> result = (Map<String, Object>)m.get('result');
        Map<String, Object> searchData = (Map<String, Object>)result.get('data');
        List<Object> objectList = (List<Object>)searchData.get('searchList');
        AnalyticsWrapper.SearchData sData = new AnalyticsWrapper.SearchData();
		List<AnalyticsWrapper.ViewsOverTime> viewsOverTimeList = new List<AnalyticsWrapper.ViewsOverTime>();
        for(Object obj : objectList){
            AnalyticsWrapper.ViewsOverTime viewsOverTimeObj = new AnalyticsWrapper.ViewsOverTime();
            Map<String,Object> mapOfParams = (Map<String,Object>)obj;
            viewsOverTimeObj.label = (String)mapOfParams.get('label');
            viewsOverTimeObj.value = (Integer)((Map<String,Object>)obj).get('value');
            
            viewsOverTimeList.add(viewsOverTimeObj);
		}
		sData.searchList = viewsOverTimeList;
		return sData;

    }

    public Object getDummyVideoPopularityData(String responseBody) {
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        Map<String, Object> result = (Map<String, Object>)m.get('result');
        List<AnalyticsWrapper.videoPopularity> videoPopularityList = (List<AnalyticsWrapper.videoPopularity>) JSON.deserialize(JSON.serialize(result.get('data')), List<AnalyticsWrapper.videoPopularity>.class);
	
		return videoPopularityList;

    }

    @TestVisible
    private String getLastSyncSwiftedDate(String resultJson) {
        Date dateToday=Date.today();
        String responseJson='{"status":"success","result":{"updatedAt":'+JSON.serialize(dateToday)+'},"message":"Analytics data returned successfully","recordCount":0}';
        return responseJson;
    }

    @TestVisible
    private String getMonthsShiftedMonthlyReports(String resultJson) {
        String responseJson;
        AnalyticsWrapper.MonthlyReport resObj = (AnalyticsWrapper.MonthlyReport)JSON.deserialize(resultJson, AnalyticsWrapper.MonthlyReport.class);
        List<AnalyticsWrapper.MonthlyReportData> listOfResults=resObj.data;
        String[] monthsArr=new String[]{'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
        Date dateToday=Date.today();
        date newDate = dateToday.addMonths(-1);
        for(Integer i=0;i<listOfResults.size();i++){
            AnalyticsWrapper.MonthlyReportData listItem=listOfResults.get(i);
            listItem.year = newDate.year();
            listItem.month = newDate.month();
            listItem.label = monthsArr[newDate.month()-1]+' '+String.valueOf(newDate.year());
            newDate = newDate.addMonths(-1);
        }
        responseJson='{"status":"success","result":{"data":'+JSON.serialize(listOfResults)+'},"message":"Analytics data returned successfully","recordCount":0}';
        return responseJson;
    }

    @TestVisible
    private String getMultipledPeopleOverviewData(String resultJson,Integer multiplyFactor) {
        AnalyticsWrapper.PeopleOverview resObj=(AnalyticsWrapper.PeopleOverview)JSON.deserialize(resultJson, AnalyticsWrapper.PeopleOverview.class);
        AnalyticsWrapper.PeopleOverviewData data=resObj.data;
        data.totalUserCount=data.totalUserCount*multiplyFactor;
        data.locationCount=data.locationCount*multiplyFactor;
        data.departmentCount=data.departmentCount*multiplyFactor;
        data.customCategoryCount=data.customCategoryCount*multiplyFactor;
        data.activeUserCount=data.activeUserCount*multiplyFactor;
        String responseJson='{"status":"success","result":{"data":'+JSON.serialize(data)+'},"message":"Analytics data returned successfully","recordCount":0}';
        return responseJson;
    }

    @TestVisible
    private String getMultipledAdoptionAverageData(String resultJson,Integer multiplyFactor) {
        AnalyticsWrapper.AdoptionAverage resObj=(AnalyticsWrapper.AdoptionAverage)JSON.deserialize(resultJson, AnalyticsWrapper.AdoptionAverage.class);
        List<AnalyticsWrapper.AdoptionAverageData> dataList=resObj.data;
        for(Integer i=0;i<dataList.size();i++){
            AnalyticsWrapper.AdoptionAverageData listItem=dataList.get(i);
            listItem.count=listItem.count*multiplyFactor;
        }   
        String responseJson='{"status":"success","result":{"data":'+JSON.serialize(dataList)+'},"message":"Analytics data returned successfully","recordCount":0}';
        return responseJson;
    }

    @TestVisible
    private String getMultipledAdoptionData(String resultJson,Integer multiplyFactor) {
        AnalyticsWrapper.ContentWrapper resObj=(AnalyticsWrapper.ContentWrapper)JSON.deserialize(resultJson, AnalyticsWrapper.ContentWrapper.class);
        AnalyticsWrapper.ContentRelatedData data=resObj.data;
        data.usersWhoViewedContent=data.usersWhoViewedContent*multiplyFactor;
        data.usersLoggedInCount=data.usersLoggedInCount*multiplyFactor;
        data.totalUserCount=data.totalUserCount*multiplyFactor;
        data.totalUniqueUserCount=data.totalUniqueUserCount*multiplyFactor;
        data.mobileLogins=data.mobileLogins*multiplyFactor;
        data.mobileAppLogins=data.mobileAppLogins*multiplyFactor;
        data.desktopLogins=data.desktopLogins*multiplyFactor;
        String responseJson='{"status":"success","result":{"data":'+JSON.serialize(data)+'},"message":"Analytics data returned successfully","recordCount":0}';
        return responseJson;
    }

    @TestVisible
    private String getDateAdjustedContentViewsOverTime(Integer noOfDays, String resultJson) {
        String responseJson;
        AnalyticsWrapper.ContentViewsOverTimeData resObj = (AnalyticsWrapper.ContentViewsOverTimeData) JSON.deserialize(resultJson, AnalyticsWrapper.ContentViewsOverTimeData.class);
        List<AnalyticsWrapper.ViewsOverTime> contentViewsList=resObj.contentViews;
        List<AnalyticsWrapper.ViewsOverTime> uniqueContentViewsOverTimeList=resObj.uniqueContentViewsOverTime;
        AnalyticsWrapper.ContentViewsOverTimeData resObjUpdated=new AnalyticsWrapper.ContentViewsOverTimeData();
        List<AnalyticsWrapper.ViewsOverTime> contentViewsListUpdated=new List<AnalyticsWrapper.ViewsOverTime>();
        List<AnalyticsWrapper.ViewsOverTime> uniqueContentViewsOverTimeListUpdated=new List<AnalyticsWrapper.ViewsOverTime>();
        Date dateToday=Date.today();
        DateTime myDateTime = (DateTime) dateToday;
        String dayOfWeekToday = myDateTime.format('E');
        Integer backswift=0;
        Integer noOfDaysResult=0;
        for(Integer i=contentViewsList.size()-1;i>=0;i--){
            AnalyticsWrapper.ViewsOverTime listItem1=contentViewsList.get(i);
            AnalyticsWrapper.ViewsOverTime listItem2=uniqueContentViewsOverTimeList.get(i);
            if(noOfDays==90){
                Date tempDate=dateToday;
                String firstDt=String.valueOf(tempDate);
                Date endDate = tempDate.addDays( 6 );
                String endDt=String.valueOf(endDate);
                listItem1.label=firstDt+'/'+endDt;
                listItem2.label=firstDt+'/'+endDt;
                dateToday = dateToday.addDays( -7 );
            }else{
                Date ddd=Date.valueOf(listItem1.label);
                DateTime dtm = (DateTime) ddd;
                String dayfind = dtm.format('E');
                if(backswift==0){
                    while(!dayOfWeekToday.equalsIgnoreCase(dayfind)){
                        i--;
                        listItem1=contentViewsList.get(i);
                        ddd=Date.valueOf(listItem1.label);
                        dtm = (DateTime) ddd;
                        dayfind = dtm.format('E');
                        
                    }
                    backswift=1;
                }
                if(backswift==1 && noOfDaysResult<=noOfDays){
                    AnalyticsWrapper.ViewsOverTime listItem1Updated= new AnalyticsWrapper.ViewsOverTime();
                    listItem1Updated.label=String.valueOf(dateToday);
                    listItem1Updated.value=listItem1.value;
                    AnalyticsWrapper.ViewsOverTime listItem2Updated= new AnalyticsWrapper.ViewsOverTime();
                    listItem2Updated.label=String.valueOf(dateToday);
                    listItem2Updated.value=listItem2.value;
                    dateToday = dateToday.addDays( -1 );
                    contentViewsListUpdated.add(listItem1Updated);
                    uniqueContentViewsOverTimeListUpdated.add(listItem2Updated);
                    noOfDaysResult++;
                }
            }
        }    
        if(noOfDays==90){
            responseJson='{"status":"success","result":{"data":'+JSON.serialize(resObj)+'},"recordCount":0}';
        }else{
            List<AnalyticsWrapper.ViewsOverTime> uniqueContentViewslistReversed=new List<AnalyticsWrapper.ViewsOverTime>();
            for(Integer i = uniqueContentViewsOverTimeListUpdated.size() - 1; i >= 0; i--){
                uniqueContentViewslistReversed.add(uniqueContentViewsOverTimeListUpdated[i]);
            }
            List<AnalyticsWrapper.ViewsOverTime> contentViewslistReversed=new List<AnalyticsWrapper.ViewsOverTime>();
            for(Integer i = contentViewsListUpdated.size() - 1; i >= 0; i--){
                contentViewslistReversed.add(contentViewsListUpdated[i]);
            }
            resObjUpdated.uniqueContentViewsOverTime=uniqueContentViewslistReversed;
            resObjUpdated.contentViews=contentViewslistReversed;
            resObjUpdated.desktopContentViews=resObj.desktopContentViews;
            resObjUpdated.mobileContentViews=resObj.mobileContentViews;
            resObjUpdated.mobileAppContentViews=resObj.mobileAppContentViews;
            resObjUpdated.uniqueContentViews=resObj.uniqueContentViews;
            responseJson='{"status":"success","result":{"data":'+JSON.serialize(resObjUpdated)+'},"recordCount":0}';
        }
        return responseJson;
    }

    @TestVisible
    private String getDateAdjustedLoginsOverTimeData(Integer noOfDays, String resultJson,Integer multiplyFactor) {
        String responseJson;
        AnalyticsWrapper.ContentWrapper resObj=(AnalyticsWrapper.ContentWrapper)JSON.deserialize(resultJson, AnalyticsWrapper.ContentWrapper.class);
        AnalyticsWrapper.ContentRelatedData data=resObj.data;
        List<AnalyticsWrapper.ViewsOverTime> listOfResults=data.loginsOverTime;
        List<AnalyticsWrapper.ViewsOverTime> listOfResultsUpdated=new List<AnalyticsWrapper.ViewsOverTime>();
        Date dateToday=Date.today();
        DateTime myDateTime = (DateTime) dateToday;
        String dayOfWeekToday = myDateTime.format('E');
        Integer backswift=0;
        Integer noOfDaysResult=0;
        for(Integer i=listOfResults.size()-1;i>=0;i--){
            AnalyticsWrapper.ViewsOverTime listItem=listOfResults.get(i);
            if(noOfDays==90){
                Date tempDate=dateToday;
                String firstDt=String.valueOf(tempDate);
                Date endDate = tempDate.addDays( 6 );
                String endDt=String.valueOf(endDate);
                listItem.label=firstDt+'/'+endDt;
                listItem.value=listItem.value*multiplyFactor;
                listItem.totalUsers=listItem.totalUsers*multiplyFactor;
                dateToday = dateToday.addDays( -7 );
            }else{
                Date ddd=Date.valueOf(listItem.label);
                DateTime dtm = (DateTime) ddd;
                String dayfind = dtm.format('E');
                if(backswift==0){
                    while(!dayOfWeekToday.equalsIgnoreCase(dayfind)){
                        i--;
                        listItem=listOfResults.get(i);
                        ddd=Date.valueOf(listItem.label);
                        dtm = (DateTime) ddd;
                        dayfind = dtm.format('E');
                        
                    }
                    backswift=1;
                }
                if(backswift==1 && noOfDaysResult<=noOfDays){
                    AnalyticsWrapper.ViewsOverTime listItemUpdated= new AnalyticsWrapper.ViewsOverTime();
                    listItemUpdated.label=String.valueOf(dateToday);
                    listItemUpdated.value=listItem.value*multiplyFactor;
                    listItemUpdated.id=listItem.id;
                    listItemUpdated.totalUsers=listItem.totalUsers*multiplyFactor;
                    dateToday = dateToday.addDays( -1 );
                    listOfResultsUpdated.add(listItemUpdated);
                    noOfDaysResult++;
                }
            }
        }
        if(noOfDays==90){
            data.totalUserCount=data.totalUserCount*multiplyFactor;
            data.usersLoggedInCount=data.usersLoggedInCount*multiplyFactor;
            data.pageViewCount=data.pageViewCount*multiplyFactor;
            data.contentViewCount=data.contentViewCount*multiplyFactor;
            data.desktopLogins=data.desktopLogins*multiplyFactor;
            data.mobileLogins=data.mobileLogins*multiplyFactor;
            data.mobileAppLogins=data.mobileAppLogins*multiplyFactor;
            data.totalUniqueUserCount=data.totalUniqueUserCount*multiplyFactor;
            data.usersWhoViewedContent=data.usersWhoViewedContent*multiplyFactor;
            responseJson='{"status":"success","result":{"data":'+JSON.serialize(data)+'},"message":"Analytics data returned successfully","recordCount":0}';
        }else{
            List<AnalyticsWrapper.ViewsOverTime> listReversed=new List<AnalyticsWrapper.ViewsOverTime>();
            for(Integer i = listOfResultsUpdated.size() - 1; i >= 0; i--){
                listReversed.add(listOfResultsUpdated[i]);
            }
            AnalyticsWrapper.ContentRelatedData dataUpdated=new AnalyticsWrapper.ContentRelatedData();
            dataUpdated.loginsOverTime=listReversed;
            dataUpdated.totalUserCount=data.totalUserCount*multiplyFactor;
            dataUpdated.usersLoggedInCount=data.usersLoggedInCount*multiplyFactor;
            dataUpdated.pageViewCount=data.pageViewCount*multiplyFactor;
            dataUpdated.contentViewCount=data.contentViewCount*multiplyFactor;
            dataUpdated.contentPublished=data.contentPublished;
            dataUpdated.desktopLogins=data.desktopLogins*multiplyFactor;
            dataUpdated.mobileLogins=data.mobileLogins*multiplyFactor;
            dataUpdated.mobileAppLogins=data.mobileAppLogins*multiplyFactor;
            dataUpdated.loggedInPercentage=data.loggedInPercentage;
            dataUpdated.averageContentViewsPerUser=data.averageContentViewsPerUser;
            dataUpdated.averageLoginsPerUser=data.averageLoginsPerUser;
            dataUpdated.totalUniqueUserCount=data.totalUniqueUserCount*multiplyFactor;
            dataUpdated.usersWhoViewedContent=data.usersWhoViewedContent*multiplyFactor;
            responseJson='{"status":"success","result":{"data":'+JSON.serialize(dataUpdated)+'},"message":"Analytics data returned successfully","recordCount":0}';
        }
        return responseJson;
    }

    @TestVisible
    private String getDateAdjustedEngagementData(Integer noOfDays, String resultJson) {
        String responseJson;
        AnalyticsWrapper.Engagement resObj = (AnalyticsWrapper.Engagement)JSON.deserialize(resultJson, AnalyticsWrapper.Engagement.class);
        AnalyticsWrapper.EngagementData data=resObj.data;
        List<AnalyticsWrapper.ViewsOverTime> likesList=data.likes;
        List<AnalyticsWrapper.ViewsOverTime> commentsList=data.comments;
        List<AnalyticsWrapper.ViewsOverTime> sharesList=data.shares;
        List<AnalyticsWrapper.ViewsOverTime> repliesList=data.replies;
        List<AnalyticsWrapper.ViewsOverTime> favoritesList=data.favorites;
        Date tempDt = Date.today().addDays( -1*noOfDays );
        String trackingStartdate=String.valueOf(tempDt);
        AnalyticsWrapper.EngagementData dataUpdated=new AnalyticsWrapper.EngagementData();
        List<AnalyticsWrapper.ViewsOverTime> likesListUpdated=new List<AnalyticsWrapper.ViewsOverTime>();
        List<AnalyticsWrapper.ViewsOverTime> commentsListUpdated=new List<AnalyticsWrapper.ViewsOverTime>();
        List<AnalyticsWrapper.ViewsOverTime> sharesListUpdated=new List<AnalyticsWrapper.ViewsOverTime>();
        List<AnalyticsWrapper.ViewsOverTime> repliesListUpdated=new List<AnalyticsWrapper.ViewsOverTime>();
        List<AnalyticsWrapper.ViewsOverTime> favoritesListUpdated=new List<AnalyticsWrapper.ViewsOverTime>();
        Date dateToday=Date.today();
        DateTime myDateTime = (DateTime) dateToday;
        String dayOfWeekToday = myDateTime.format('E');
        Integer backswift=0;
        Integer noOfDaysResult=0;
        for(Integer i=likesList.size()-1;i>=0;i--){
            AnalyticsWrapper.ViewsOverTime listItem1=likesList.get(i);
            AnalyticsWrapper.ViewsOverTime listItem2=commentsList.get(i);
            AnalyticsWrapper.ViewsOverTime listItem3=sharesList.get(i);
            AnalyticsWrapper.ViewsOverTime listItem4=repliesList.get(i);
            AnalyticsWrapper.ViewsOverTime listItem5=favoritesList.get(i);
            if(noOfDays==90){
                Date tempDate=dateToday;
                String firstDt=String.valueOf(tempDate);
                Date endDate = tempDate.addDays( 6 );
                String endDt=String.valueOf(endDate);
                listItem1.label=firstDt+'/'+endDt;
                listItem2.label=firstDt+'/'+endDt;
                listItem3.label=firstDt+'/'+endDt;
                listItem4.label=firstDt+'/'+endDt;
                listItem5.label=firstDt+'/'+endDt;
                dateToday = dateToday.addDays( -7 );
            }else{
                Date ddd=Date.valueOf(listItem1.label);
                DateTime dtm = (DateTime) ddd;
                String dayfind = dtm.format('E');
                if(backswift==0){
                    while(!dayOfWeekToday.equalsIgnoreCase(dayfind)){
                        i--;
                        listItem1=likesList.get(i);
                        ddd=Date.valueOf(listItem1.label);
                        dtm = (DateTime) ddd;
                        dayfind = dtm.format('E');
                        
                    }
                    backswift=1;
                }
                if(backswift==1 && noOfDaysResult<=noOfDays){
                    AnalyticsWrapper.ViewsOverTime listItem1Updated= new AnalyticsWrapper.ViewsOverTime();
                    listItem1Updated.label=String.valueOf(dateToday);
                    listItem1Updated.value=listItem1.value;
                    likesListUpdated.add(listItem1Updated);
                    AnalyticsWrapper.ViewsOverTime listItem2Updated= new AnalyticsWrapper.ViewsOverTime();
                    listitem2updated.label=string.valueof(datetoday);
                    listitem2updated.value=listitem2.value;
                    commentslistupdated.add(listitem2updated);
                    AnalyticsWrapper.ViewsOverTime listItem3Updated= new AnalyticsWrapper.ViewsOverTime();
                    listItem3Updated.label=String.valueOf(dateToday);
                    listItem3Updated.value=listItem3.value;
                    sharesListUpdated.add(listItem3Updated);
		            AnalyticsWrapper.ViewsOverTime listItem4Updated= new AnalyticsWrapper.ViewsOverTime();
                    listItem4Updated.label=String.valueOf(dateToday);
                    listItem4Updated.value=listItem4.value;
                    repliesListUpdated.add(listItem4Updated);
		            AnalyticsWrapper.ViewsOverTime listItem5Updated= new AnalyticsWrapper.ViewsOverTime();
                    listItem5Updated.label=String.valueOf(dateToday);
                    listItem5Updated.value=listItem5.value;
                    favoritesListUpdated.add(listItem5Updated);
                    dateToday = dateToday.addDays( -1 );
                    noOfDaysResult++;
                }
            }
        }	
        if(noOfDays==90){
            responseJson='{"status":"success","result":{"trackingStartdate":"'+trackingStartdate+'","data":'+JSON.serialize(data)+'},"message":"Content Engagement data returned successfully","recordCount":0}';
        }else{
            List<AnalyticsWrapper.ViewsOverTime> likeslistReversed=new List<AnalyticsWrapper.ViewsOverTime>();
            for(Integer i = likesListUpdated.size() - 1; i >= 0; i--){
                likeslistReversed.add(likesListUpdated[i]);
            }
            List<AnalyticsWrapper.ViewsOverTime> commentslistReversed=new List<AnalyticsWrapper.ViewsOverTime>();
            for(Integer i = commentsListUpdated.size() - 1; i >= 0; i--){
                commentslistReversed.add(commentsListUpdated[i]);
            }
            List<AnalyticsWrapper.ViewsOverTime> shareslistReversed=new List<AnalyticsWrapper.ViewsOverTime>();
            for(Integer i = sharesListUpdated.size() - 1; i >= 0; i--){
                shareslistReversed.add(sharesListUpdated[i]);
            }
            List<AnalyticsWrapper.ViewsOverTime> replieslistReversed=new List<AnalyticsWrapper.ViewsOverTime>();
            for(Integer i = repliesListUpdated.size() - 1; i >= 0; i--){
                replieslistReversed.add(repliesListUpdated[i]);
            }
            List<AnalyticsWrapper.ViewsOverTime> favouritelistReversed=new List<AnalyticsWrapper.ViewsOverTime>();
            for(Integer i = favoritesListUpdated.size() - 1; i >= 0; i--){
                favouritelistReversed.add(favoritesListUpdated[i]);
            }
            dataUpdated.likes=likeslistReversed;
            dataUpdated.comments=commentslistReversed;
            dataUpdated.replies=replieslistReversed;
            dataUpdated.shares=shareslistReversed;
            dataUpdated.favorites=favouritelistReversed;
            responseJson='{"status":"success","result":{"trackingStartdate":"'+trackingStartdate+'","data":'+JSON.serialize(dataUpdated)+'},"message":"Content Engagement data returned successfully","recordCount":0}';
        }
        return responseJson;
    }

    @TestVisible
    private String getDateAdjustedSearchesData(Integer noOfDays, String resultJson) {
        String responseJson;
        AnalyticsWrapper.SearchData resObj = (AnalyticsWrapper.SearchData)JSON.deserialize(resultJson, AnalyticsWrapper.SearchData.class);
        List<AnalyticsWrapper.ViewsOverTime> listOfResults=resObj.searchesOverTime;
        AnalyticsWrapper.SearchData resObjUpdated=new AnalyticsWrapper.SearchData();
        List<AnalyticsWrapper.ViewsOverTime> listOfResultsUpdated=new List<AnalyticsWrapper.ViewsOverTime>();
        Date dateToday=Date.today();
        DateTime myDateTime = (DateTime) dateToday;
        String dayOfWeekToday = myDateTime.format('E');
        Integer backswift=0;
        Integer noOfDaysResult=0;
        for(Integer i=listOfResults.size()-1;i>=0;i--){
            AnalyticsWrapper.ViewsOverTime listItem=listOfResults.get(i);
            if(noOfDays==90){
                Date tempDate=dateToday;
                String firstDt=String.valueOf(tempDate);
                Date endDate = tempDate.addDays( 6 );
                String endDt=String.valueOf(endDate);
                listItem.label=firstDt+'/'+endDt;
                dateToday = dateToday.addDays( -7 );
            }else{
                Date ddd=Date.valueOf(listItem.label);
                DateTime dtm = (DateTime) ddd;
                String dayfind = dtm.format('E');
                if(backswift==0){
                    while(!dayOfWeekToday.equalsIgnoreCase(dayfind)){
                        i--;
                        listItem=listOfResults.get(i);
                        ddd=Date.valueOf(listItem.label);
                        dtm = (DateTime) ddd;
                        dayfind = dtm.format('E');
                        
                    }
                    backswift=1;
                }
                if(backswift==1 && noOfDaysResult<=noOfDays){
                    AnalyticsWrapper.ViewsOverTime listItemUpdated= new AnalyticsWrapper.ViewsOverTime();
                    listItemUpdated.label=String.valueOf(dateToday);
                    listItemUpdated.value=listItem.value;
                    dateToday = dateToday.addDays( -1 );
                    listOfResultsUpdated.add(listItemUpdated);
                    noOfDaysResult++;
                }
            }
        }
        if(noOfDays==90){
            responseJson='{"status":"success","result":{"data":'+JSON.serialize(resObj)+'},"message":"Analytics data returned successfully","recordCount":0}';
        }else{
            List<AnalyticsWrapper.ViewsOverTime> listReversed=new List<AnalyticsWrapper.ViewsOverTime>();
            for(Integer i = listOfResultsUpdated.size() - 1; i >= 0; i--){
                listReversed.add(listOfResultsUpdated[i]);
            }
            resObjUpdated.totalCount=resObj.totalCount;
            resObjUpdated.searchesOverTime=listReversed;
            responseJson='{"status":"success","result":{"data":'+JSON.serialize(resObjUpdated)+'},"message":"Analytics data returned successfully","recordCount":0}';
        }	
        return responseJson;
    }

    @TestVisible
    private String getDateAdjustedSiteViewsData(Integer noOfDays, String resultJson) {
        String responseJson;
        AnalyticsWrapper.ContentRelatedData resObj = (AnalyticsWrapper.ContentRelatedData)JSON.deserialize(resultJson, AnalyticsWrapper.ContentRelatedData.class);
        List<AnalyticsWrapper.ViewsOverTime> listOfResults=resObj.viewsOverTime;
        AnalyticsWrapper.ContentRelatedData resObjUpdated=new AnalyticsWrapper.ContentRelatedData();
        List<AnalyticsWrapper.ViewsOverTime> listOfResultsUpdated=new List<AnalyticsWrapper.ViewsOverTime>();
        Date dateToday=Date.today();
        DateTime myDateTime = (DateTime) dateToday;
        String dayOfWeekToday = myDateTime.format('E');
        Integer backswift=0;
        Integer noOfDaysResult=0;
        for(Integer i=listOfResults.size()-1;i>=0;i--){
            AnalyticsWrapper.ViewsOverTime listItem=listOfResults.get(i);
            if(noOfDays==90){
                Date tempDate=dateToday;
                String firstDt=String.valueOf(tempDate);
                Date endDate = tempDate.addDays( 6 );
                String endDt=String.valueOf(endDate);
                listItem.label=firstDt+'/'+endDt;
                dateToday = dateToday.addDays( -7 );
            }else{
                Date ddd=Date.valueOf(listItem.label);
                DateTime dtm = (DateTime) ddd;
                String dayfind = dtm.format('E');
                if(backswift==0){
                    while(!dayOfWeekToday.equalsIgnoreCase(dayfind)){
                        i--;
                        listItem=listOfResults.get(i);
                        ddd=Date.valueOf(listItem.label);
                        dtm = (DateTime) ddd;
                        dayfind = dtm.format('E');
                        
                    }
                    backswift=1;
                }
                if(backswift==1 && noOfDaysResult<=noOfDays){
                    AnalyticsWrapper.ViewsOverTime listItemUpdated= new AnalyticsWrapper.ViewsOverTime();
                    listItemUpdated.label=String.valueOf(dateToday);
                    listItemUpdated.value=listItem.value;
                    dateToday = dateToday.addDays( -1 );
                    listOfResultsUpdated.add(listItemUpdated);
                    noOfDaysResult++;
                }
            }
        }
        if(noOfDays==90) {
            responseJson = '{"status":"success","result":'+JSON.serialize(resObj)+',"recordCount":0}';
        }else{
            List<AnalyticsWrapper.ViewsOverTime> listReversed=new List<AnalyticsWrapper.ViewsOverTime>();
            for(Integer i = listOfResultsUpdated.size() - 1; i >= 0; i--){
                listReversed.add(listOfResultsUpdated[i]);
            }
            resObjUpdated.mobilePercentage=resObj.mobilePercentage;
            resObjUpdated.desktopPercentage=resObj.desktopPercentage;
            resObjUpdated.mobileAppPercentage=resObj.mobileAppPercentage;
            resObjUpdated.viewsOverTime=listReversed;
            responseJson = '{"status":"success","result":'+JSON.serialize(resObjUpdated)+',"recordCount":0}';
        }
        return responseJson;
    }

    @TestVisible
    private String getDateAdjustedContentViewsData(Integer noOfDays, String resultJson) {
        String responseJson;
        AnalyticsWrapper.ContentRelatedData resObj = (AnalyticsWrapper.ContentRelatedData)JSON.deserialize(resultJson, AnalyticsWrapper.ContentRelatedData.class);
        if(resObj == null)
            return '{}';
        List<AnalyticsWrapper.ViewsOverTime> listOfResults=resObj.viewsOverTime;
        AnalyticsWrapper.ContentRelatedData resObjUpdated=new AnalyticsWrapper.ContentRelatedData();
        List<AnalyticsWrapper.ViewsOverTime> listOfResultsUpdated=new List<AnalyticsWrapper.ViewsOverTime>();
        Date dateToday=Date.today();
        DateTime myDateTime = (DateTime) dateToday;
        String dayOfWeekToday = myDateTime.format('E');
        Integer backswift=0;
        Integer noOfDaysResult=0;
        for(Integer i=listOfResults.size()-1;i>=0;i--){
            AnalyticsWrapper.ViewsOverTime listItem=listOfResults.get(i);
            if(noOfDays==90){
                Date tempDate=dateToday;
                String firstDt=String.valueOf(tempDate);
                Date endDate = tempDate.addDays( 6 );
                String endDt=String.valueOf(endDate);
                listItem.label=firstDt+'/'+endDt;
                dateToday = dateToday.addDays( -7 );
            }else{
                Date ddd=Date.valueOf(listItem.label);
                DateTime dtm = (DateTime) ddd;
                String dayfind = dtm.format('E');
                if(backswift==0){
                    while(!dayOfWeekToday.equalsIgnoreCase(dayfind)){
                        i--;
                        listItem=listOfResults.get(i);
                        ddd=Date.valueOf(listItem.label);
                        dtm = (DateTime) ddd;
                        dayfind = dtm.format('E');
                        
                    }
                    backswift=1;
                }
                if(backswift==1 && noOfDaysResult<=noOfDays){
                    AnalyticsWrapper.ViewsOverTime listItemUpdated= new AnalyticsWrapper.ViewsOverTime();
                    listItemUpdated.label=String.valueOf(dateToday);
                    listItemUpdated.value=listItem.value;
                    dateToday = dateToday.addDays( -1 );
                    listOfResultsUpdated.add(listItemUpdated);
                    noOfDaysResult++;
                }
            }
        }
        if(noOfDays==90){
            responseJson = '{"status":"success","result":'+JSON.serialize(resObj)+',"message":"Analytics data returned successfully","recordCount":0}';
        }else{
            List<AnalyticsWrapper.ViewsOverTime> listReversed=new List<AnalyticsWrapper.ViewsOverTime>();
            for(Integer i = listOfResultsUpdated.size() - 1; i >= 0; i--){
                listReversed.add(listOfResultsUpdated[i]);
            }
            resObjUpdated.totalViewCount=resObj.totalViewCount;
            resObjUpdated.uniqueViewCount=resObj.uniqueViewCount;
            resObjUpdated.viewsOverTime=listReversed;
            resObjUpdated.topDepartments=resObj.topDepartments;
            resObjUpdated.topLocations=resObj.topLocations;
            responseJson = '{"status":"success","result":'+JSON.serialize(resObjUpdated)+',"message":"Analytics data returned successfully","recordCount":0}';
        }
        return responseJson;
    }

    /**
	 * @description This method is used to shift dates for demo data for getConsumptionOverTime Endpoint
	 * @param noOfDays
	 * @param resultJson
     * @return  `String`
	*/
    @TestVisible
    private String getDateAdjustedConsumptionOverTimeData(Integer noOfDays, String resultJson) {
        String responseJson;
        AnalyticsWrapper.ContentRelatedData resObj = (AnalyticsWrapper.ContentRelatedData)JSON.deserialize(resultJson, AnalyticsWrapper.ContentRelatedData.class);
        if(resObj == null)
            return '{}';
        List<AnalyticsWrapper.ViewsOverTime> viewsOverTimeList = resObj.viewsOverTime;
        List<AnalyticsWrapper.ViewsOverTime> uniqueViewsOverTimeList = resObj.uniqueViewsOverTime;
        AnalyticsWrapper.ContentRelatedData resObjUpdated = new AnalyticsWrapper.ContentRelatedData();
        List<AnalyticsWrapper.ViewsOverTime> viewsOverTimeListUpdated = new List<AnalyticsWrapper.ViewsOverTime>();
        List<AnalyticsWrapper.ViewsOverTime> uniqueViewsOverTimeListUpdated = new List<AnalyticsWrapper.ViewsOverTime>();
        if(noOfDays==90){
            viewsOverTimeListUpdated = getViewsOverTime90DaysData(noOfDays, viewsOverTimeList);
            uniqueViewsOverTimeListUpdated = getViewsOverTime90DaysData(noOfDays, uniqueViewsOverTimeList);
        }else{
            viewsOverTimeListUpdated = getViewsOverTime30DaysData(noOfDays, viewsOverTimeList);
            uniqueViewsOverTimeListUpdated = getViewsOverTime30DaysData(noOfDays, uniqueViewsOverTimeList);
        }
        List<AnalyticsWrapper.ViewsOverTime> viewsOverTimeReversedList=new List<AnalyticsWrapper.ViewsOverTime>();
        List<AnalyticsWrapper.ViewsOverTime> uniqueViewsOverTimeReversedList=new List<AnalyticsWrapper.ViewsOverTime>();
        for(Integer index = viewsOverTimeListUpdated.size() - 1; index >= 0; index--){
            viewsOverTimeReversedList.add(viewsOverTimeListUpdated[index]);
            uniqueViewsOverTimeReversedList.add(uniqueViewsOverTimeListUpdated[index]);
        }
        resObjUpdated.totalViewCount = resObj.totalViewCount;
        resObjUpdated.uniqueViewCount = resObj.uniqueViewCount;
        resObjUpdated.viewsOverTime = viewsOverTimeReversedList;
        resObjUpdated.uniqueViewsOverTime = uniqueViewsOverTimeReversedList;
        responseJson = '{"status":"success","result":'+JSON.serialize(resObjUpdated)+',"message":"Analytics data returned successfully","recordCount":0}';
        return responseJson;
    }

    
    /**
	 * @description This method is used to shift dates for demo week wise data in getConsumptionOverTime Endpoint
	 * @param noOfDays
	 * @param viewsOverTimeList
     * @return  `List<AnalyticsWrapper.ViewsOverTime>`
	*/
    private List<AnalyticsWrapper.ViewsOverTime> getViewsOverTime90DaysData(Integer noOfDays, List<AnalyticsWrapper.ViewsOverTime> viewsOverTimeList) {
        List<AnalyticsWrapper.ViewsOverTime> viewsOverTimeListUpdated = new List<AnalyticsWrapper.ViewsOverTime>();
        Date dateToday=Date.today();
        Date dateVal = dateToday.addDays(-1);
        for(Integer index = viewsOverTimeList.size()-1; index >= 0; index--){
            AnalyticsWrapper.ViewsOverTime viewsOverTimeObj=viewsOverTimeList.get(index);
            AnalyticsWrapper.ViewsOverTime viewsOverTimeObjUpdated= new AnalyticsWrapper.ViewsOverTime();
            Date tempDate = dateVal;
            String firstDt = String.valueOf(tempDate);
            Date endDate = tempDate.addDays( 6 );
            String endDt = String.valueOf(endDate);
            viewsOverTimeObjUpdated.label = firstDt+'/'+endDt;
            viewsOverTimeObjUpdated.value = viewsOverTimeObj.value;
            viewsOverTimeListUpdated.add(viewsOverTimeObjUpdated);
            dateVal = dateVal.addDays( -7 );
        }
        return viewsOverTimeListUpdated;
    }

    /**
	 * @description This method is used to shift dates for day wise data in getConsumptionOverTime Endpoint
	 * @param noOfDays
	 * @param viewsOverTimeList
     * @return  `List<AnalyticsWrapper.ViewsOverTime>`
	*/
    private List<AnalyticsWrapper.ViewsOverTime> getViewsOverTime30DaysData(Integer noOfDays, List<AnalyticsWrapper.ViewsOverTime> viewsOverTimeList) {
        List<AnalyticsWrapper.ViewsOverTime> viewsOverTimeListUpdated = new List<AnalyticsWrapper.ViewsOverTime>();
        Date dateToday=Date.today();
        Date dateVal = dateToday.addDays(-1);
        DateTime myDateTime = (DateTime) dateVal;
        String dayOfWeekToday = myDateTime.format('E');
        Integer backswift=0;
        Integer noOfDaysResult=0;
        for(Integer index = viewsOverTimeList.size()-1; index >= 0; index--){
            AnalyticsWrapper.ViewsOverTime viewsOverTimeObj=viewsOverTimeList.get(index);
            Date dateVar=Date.valueOf(viewsOverTimeObj.label);
            DateTime dateTimeVar = (DateTime) dateVar;
            String dayfind = dateTimeVar.format('E');
            if(backswift == 0){
                while(!dayOfWeekToday.equalsIgnoreCase(dayfind)){
                    index--;
                    viewsOverTimeObj = viewsOverTimeList.get(index);
                    dateVar = Date.valueOf(viewsOverTimeObj.label);
                    dateTimeVar = (DateTime) dateVar;
                    dayfind = dateTimeVar.format('E');
                }
                backswift=1;
            }
            if(backswift==1 && noOfDaysResult<=noOfDays){
                if(viewsOverTimeObj.value > 0){
                    AnalyticsWrapper.ViewsOverTime viewsOverTimeObjUpdated= new AnalyticsWrapper.ViewsOverTime();
                    viewsOverTimeObjUpdated.label=String.valueOf(dateVal);
                    viewsOverTimeObjUpdated.value=viewsOverTimeObj.value;
                    viewsOverTimeListUpdated.add(viewsOverTimeObjUpdated);
                }
                dateVal = dateVal.addDays( -1 );
                noOfDaysResult++;
            }
        }
        return viewsOverTimeListUpdated;
    }
    
}