Simpplr.Salesforce.Audience =  (function(Simpplr, $){
	var module = {};
	var SFDC = {}; 
   	var resultDefObj = {};
   	
  	module.getAvailableFields = function () {
      	return Simpplr.Salesforce.sendRequest({
          	data : {'data' : JSON.stringify(data)},
          	method : 'GET',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AudienceDataServer&action=getAvailableFields'
      	});
  	}
  	
  	module.getFieldValues = function (params) {
      	return Simpplr.Salesforce.sendRequest({
			data : {'data' : JSON.stringify(params)},
          	method : 'GET',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AudienceDataServer&action=getFieldValues'
      	});
	}

	module.get = function (audienceId,fromEditModal) {
		var data = {'audienceId': audienceId,'fromEditModal':fromEditModal};
		return Simpplr.Salesforce.sendRequest({
			data : {'data' : JSON.stringify(data)},
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite + '?target=AudienceDataServer&action=get'
		});
	}

	module.search = function (params) {
		return Simpplr.Salesforce.sendRequest({
			data : {'data' : JSON.stringify(params)},
			method : 'GET',
			endpoint : Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AudienceDataServer&action=search'
		});
	}

	module.delete = function (audienceId) {
		var data = {'audienceId': audienceId};
		return Simpplr.Salesforce.sendRequest({
			data : {'data' : JSON.stringify(data)},
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite + '?target=AudienceDataServer&action=delete'
		});
	}

	module.save = function (audienceId, data) {
		var endPoint = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AudienceDataServer&action=save';
		 
		data.audienceId = audienceId; 
		
		return Simpplr.Salesforce.sendRequest({
			data : {'data': JSON.stringify(data)},
			method : 'POST',
			endpoint : endPoint
		});
	}

	module.getByIds = function (listOfAudienceId) {
        return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(listOfAudienceId)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AudienceDataServer&action=getByIds'
      	});
    }


  	return module; 
})(Simpplr, jQuery);