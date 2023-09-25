Simpplr.Salesforce.AnalyticsLegacy = (function (Simpplr, $){
	var module = {};

	module.getAdoptionCounts = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsLegacyDataServer&action=getAdoptionCounts'
      	});
	};
	
	module.getAdoptionAverage = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsLegacyDataServer&action=getAdoptionAverage'
      	});
	};

	module.getAdoption = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsLegacyDataServer&action=getAdoption'
      	});
	};

	module.getLogins = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsLegacyDataServer&action=getLogins'
      	});
	};

	module.getPageviews = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsLegacyDataServer&action=getPageviews'
      	});
	};

	module.getEngagementFeed = function(params) {
		
		action = 'getEngagementFeed';
		if('metric' in params){
			action += params.metric;
		}
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsLegacyDataServer&action='+action
      	});
	};

	module.getEngagementContent = function(params) {
		
		action = 'getEngagementContent';
		if('metric' in params){
			action += params.metric;
		}
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsLegacyDataServer&action='+action
      	});
	};

	module.getEngagementContentTypes = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsLegacyDataServer&action=getEngagementContentTypes'
      	});
	};
	
	module.getPerformanceSites = function(params) {
		
		action = 'getPerformanceSites';
		if('metric' in params){
			action += params.metric;
		}
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsLegacyDataServer&action='+action
      	});
	};

	module.getPerformancePeople = function(params) {
		
		action = 'getPerformancePeople';
		if('metric' in params){
			action += params.metric;
		}
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsLegacyDataServer&action='+action
      	});
	};

	module.getPerformanceContent = function(params) {
		
		action = 'getPerformanceContent';
		if('metric' in params){
			action += params.metric;
		}
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsLegacyDataServer&action='+action
      	});
	};

	module.getPerformanceTopics = function(params) {
		
		action = 'getPerformanceTopics';
		if('metric' in params){
			action += params.metric;
		}
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsLegacyDataServer&action='+action
      	});
	};

	module.getPerformanceSearch = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsLegacyDataServer&action=getPerformanceSearch'
      	});
	};
	
	module.getPerformanceZeroSearchResults = function(params) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnalyticsLegacyDataServer&action=getPerformanceZeroSearchResults'
      	});
	};
	
return module;
})(Simpplr, jQuery);