Simpplr.Salesforce.Utility = Simpplr.Salesforce.Utility || {};
Simpplr.Salesforce.Utility = (function (Simpplr, $){
	
	var module = {};
	
    module.createAnalyticsRecord = function (data) {
    	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AnalyticsTrackingDataServer'
     	});
	};
	
	module.createAnalyticsFileUploadRecord = function (data) {
    	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AnalyticsTrackingDataServer&action=createAnalyticsFileUploadRecord'
     	});
    };
    
    module.getSecurityToken = function(){
		return Simpplr.Salesforce.sendRequest({
			method: 'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadWrite+'?target=UtilityDataServer&action=getSecurityToken'
		});
	};

	module.getAppConfig = function(){
		return Simpplr.Salesforce.sendRequest({
			method: 'GET',
			endpoint:Simpplr.Salesforce.Endpoints.ReadWrite+'?target=UtilityDataServer&action=getAppConfig'
		});
	};

	module.getCurrentUserSettings = function(){
		return Simpplr.Salesforce.sendRequest({
			method: 'GET',
			endpoint:Simpplr.Salesforce.Endpoints.ReadWrite+'?target=UtilityDataServer&action=getCurrentUserSettings'
		});
	};

	module.getDeferredAppConfig = function(){
		return Simpplr.Salesforce.sendRequest({
			method: 'GET',
			endpoint:Simpplr.Salesforce.Endpoints.ReadWrite+'?target=UtilityDataServer&action=getDeferredAppConfig'
		});
	};

	module.getProfileFields = function(){
		return Simpplr.Salesforce.sendRequest({
			method: 'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly + '?target=UtilityDataServer&action=getProfileFields'
		});
	};
	
	module.suggestTopics = function(text, title){
		var data = {"text": text, "title": title};
		return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(data)}, 
			method:'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=UtilityDataServer&action=suggestTopics'
		});
	};

	module.deleteDismissibleFlashes = function(data){
		return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(data)}, 
			method:'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=UtilityDataServer&action=deleteDismissibleFlashes'
		});
	};	
	
	module.getSchedulingSlots = function(){
		return Simpplr.Salesforce.sendRequest({
			method: 'GET',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly + '?target=UtilityDataServer&action=getSchedulingSlots'
		});
	};
	
	module.getFromAddresses = function (params) {
		var data = {'params':params};
		return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(data)},
       		method:'GET',
       		endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=UtilityDataServer&action=getFromAddresses'
   			});
	};

    module.dateToUsersTZ = function(date){
		return moment.utc(date).utcOffset(Simpplr.Utility.getUtcOffset()).format();
    };

	module.getListenerSuiteJwt = function(){
		return Simpplr.Salesforce.sendRequest({
			method: 'GET',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly + '?target=UtilityDataServer&action=getListenerSuiteJwt'
		});
	};

	module.getJWTToken = function(){
		return Simpplr.Salesforce.sendRequest({
			method: 'GET',
			endpoint:Simpplr.Salesforce.Endpoints.ReadWrite + '?target=UtilityDataServer&action=getJWTToken'
		});
	};

	module.getSSJWTToken = function(){
		return Simpplr.Salesforce.sendRequest({
			method: 'GET',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly + '?target=UtilityDataServer&action=getSSJWTToken'
		});
	};

	module.getAvailableTimezones = function(){
		return Simpplr.Salesforce.sendRequest({
			method: 'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly+'?target=UtilityDataServer&action=getAvailableTimezones'
		});
	};

	return module;
})(Simpplr, jQuery);