Simpplr.Salesforce.ServiceNow =  (function(Simpplr, $){

	var module = {};
	
	module.disconnectAdmin = function (data) {
		return Simpplr.Salesforce.sendRequest({
			data : {'data' : JSON.stringify(data)},
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=disconnectServicenowAdmin'
		});
	}

	module.getKnowledgeBases = function (params) {
      	return Simpplr.Salesforce.sendRequest({
          	data : {'data' : JSON.stringify(params)},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ServiceNowDataServer&action=getKnowledgeBases'
      	});
  	}
  	
  	module.search = function (params) {
      	return Simpplr.Salesforce.sendRequest({
          	data : {'data' : JSON.stringify(params)},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ServiceNowDataServer&action=getKnowledgeBaseItems'
      	});
	  }
	  
	  module.getIncidents = function (params) {
		return Simpplr.Salesforce.sendRequest({
			data : {'data' : JSON.stringify(params)},
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ServiceNowDataServer&action=getIncidents'
		});
	}

	module.createIncident = function (params) {
		return Simpplr.Salesforce.sendRequest({
			data : {'data' : JSON.stringify(params)},
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ServiceNowDataServer&action=createIncident'
		});
	}

	module.getCategory = function () {
		return Simpplr.Salesforce.sendRequest({
			data : {'data' : '{}'},
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ServiceNowDataServer&action=getCategory'
		});
	}

	module.getSubCategory = function (categoryName) {
		return Simpplr.Salesforce.sendRequest({
			data : {'data' : '{}'},
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ServiceNowDataServer&action=getSubCategory&categoryName='+categoryName
		});
	}
	
	module.upload = function (fileObj, incidentId, accessToken){
		var deferred = $.Deferred();
		$.ajax({
			url: Simpplr.Settings.links.serviceNowInstanceUrl+'/api/now/attachment/file' + 
				 '?table_name=incident' + 
				 '&table_sys_id=' + incidentId +
				 '&file_name=' + fileObj.name,
			type: 'POST',               
			crossDomain : true,
			processData : false,
			headers: {
				"Content-Type": 'application/json',
				"Content-Length": fileObj.length,
				"Authorization": "Bearer "+accessToken,
				"Accept": "application/json"
			},  
			data: fileObj,          
		}).done(function(data) {
			deferred.resolve('success');
		}).fail(function (data){                                     
			deferred.reject('failure');
		});
	  
	 	 return deferred;
	}
	
	module.getAccessToken = function () {
		var accessReq = $.ajax({
			  url:    Simpplr.Salesforce.VisualforceEndpoints.ReadWrite +'?target=ServiceNowDataServer&action=getAccessToken',
		 	 method: 'POST',
		  	data:   {data: JSON.stringify('data')},
			  beforeSend: function(xhrObj){
				xhrObj.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
				xhrObj.setRequestHeader("Accept","application/json");
				xhrObj.setRequestHeader("x-simpplr-csrf", __sfdcCsrfToken);
				xhrObj.setRequestHeader("x-http-verb", 'POST');
			}
	 	 });
	  
	  return accessReq;
	}


	module.revokeAccessToken = function () {
		var accessReq = $.ajax({
			url:    Simpplr.Salesforce.VisualforceEndpoints.ReadWrite +'?target=ServiceNowDataServer&action=revokeAccessToken',
		 	method: 'POST',
		  	data:   {data: JSON.stringify('data')},
			beforeSend: function(xhrObj){
				xhrObj.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
				xhrObj.setRequestHeader("Accept","application/json");
				xhrObj.setRequestHeader("x-simpplr-csrf", __sfdcCsrfToken);
				xhrObj.setRequestHeader("x-http-verb", 'POST');
			}
	 	 });
	  
	  return accessReq;
	}
	

  	return module;
	
})(Simpplr, jQuery);