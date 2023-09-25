Simpplr.Salesforce.Analytics = (function (Simpplr, $){
	var module = {};

	module.getCompanyStats = function () {
      return Simpplr.Salesforce.sendRequest({
          method:'GET',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=peopledataserver&action=getCompanyStats'
		});
	};
	
	module.getAdoptionAverage = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getAdoptionAverage'
      	});
	};
	
	module.getMonthlyReports = function() {
		return Simpplr.Salesforce.sendRequest({
          	method:'GET',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getMonthlyReports'
      	});
	};

	module.getAdoptionData = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getAdoptionData'
      	});
	};

	module.getLoginsOverTime = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getLoginsOverTime'
      	});
	};
	
	module.getLoginsList = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getLoginsList'
      	});
	};

	module.getPageviews = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getPageviews'
      	});
	};
	
	module.getEngagement = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getEngagement'
      	});
	};
	
	module.getEngagementList = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getEngagementList'
      	});
	};
	
	module.getPeoplePerformance = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getPeoplePerformance'
      	});
	};

	module.getPeopleOverview = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getPeopleOverview'
      	});
	};

	module.getPeopleProfileCompleteness = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getPeopleProfileCompleteness'
      	});
	};

	module.getPerformanceContent = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getPerformanceContent'
      	});
	};
	
	module.getLowActivitySites = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getLowActivitySites'
      	});
	};

	module.getInstallStats = function () {
      return Simpplr.Salesforce.sendRequest({
          method:'GET',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=peopledataserver&action=getInstallStats'
		});
	};
	
	module.getViewsOverTime  = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getViewsOverTime '
      	});
	};

	module.getContentViewsOverTime  = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getContentViewsOverTime '
      	});
	};
	
	module.getContentViews = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getContentViews'
      	});
	};

	module.getConsumptionOverTime = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getConsumptionOverTime'
      	});
	};

	module.getContentViewsByType = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getContentViewsByType'
      	});
	};
	
	module.getSiteViews = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getSiteViews'
      	});
	};

	module.getSiteViewsTotal = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getSiteViewsTotal'
      	});
	};
	
	module.getSiteCounts = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getSiteCounts'
      	});
	};
	
	module.getSitePopularity = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getSitePopularity'
      	});
	};
	
	module.getSitePublications = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getSitePublications'
      	});
	};
	
	module.getContentPopularity = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getContentPopularity'
      	});
	};
	
	module.getContentPublications = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getContentPublications'
      	});
	};
	
	module.getContentViewsList = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getContentViewsList'
      	});
	};
	
	module.getViewsList = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getViewsList'
      	});
	};

	module.getAppPageViews = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getAppPageViews'
      	});
	};
	
	module.getCampaigns = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getCampaigns'
      	});
	};
	
	module.getNewsletters = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getNewsletters'
      	});
	};
	
	module.getSearches = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getSearches'
      	});
	};
	
	module.getSearchList = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getSearchList'
      	});
	};

	module.getKnowledgePageStats  = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getKnowledgePageStats '
      	});
	};

	module.getLastSyncDate  = function(type) {
		var data = {'type' : type};
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(data)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getLastSyncDate '
      	});
	};

	module.getContentReferralSources  = function(data) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(data)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getContentReferralSources '
      	});
	};	
	
	module.getContentEngagement  = function(data) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(data)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getContentEngagement '
      	});
	};
	module.getRecommendationByType = function (data) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(data)},
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AnalyticsDataServer&action=getRecommendationByType'
		});
	}; 
	module.getCustomerSegmentAdoption = function () {
		return Simpplr.Salesforce.sendRequest({
			data : {'data' : ''},
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AnalyticsDataServer&action=getCustomerSegmentAdoption'
		});
	};
	module.getAppAdoption = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getAppAdoption'
      	});
	};

	module.getVideoPopularity = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getVideoPopularity'
      	});
	};

	module.getVideoAdoption = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getVideoAdoption'
      	});
	};

	module.getViewedByMetricData = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsDataServer&action=getViewedByMetricData'
      	});
	};
	  
return module;
})(Simpplr, jQuery);