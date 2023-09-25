Simpplr.Salesforce.Answer =  (function(Simpplr, $){
	var module = {};
	
	module.get = function (answerId, siteId) { 
  		return Simpplr.Salesforce.sendRequest({
          	data : { "answerId": answerId, "siteId": siteId },
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AnswerDataServer&action=get'
      	});
  	}
	
	module.create = function (data) {
		return Simpplr.Salesforce.sendRequest({
			data : {'data' : JSON.stringify(data)},
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AnswerDataServer&action=create'
		});
	}
	 
	module.update = function (data, answerId) {
		return Simpplr.Salesforce.sendRequest({
			data : {'answerId': answerId, 'data' : JSON.stringify(data)},
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AnswerDataServer&action=update'
		});
	}

	module.search = function (data) {
		return Simpplr.Salesforce.sendRequest({
			data : {'data' : JSON.stringify(data)},
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AnswerDataServer&action=search'
		});
	}

	module.approve = function (answerId, siteId) {
		return Simpplr.Salesforce.sendRequest({
			data : { "answerId": answerId, "siteId": siteId },
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AnswerDataServer&action=approve'
		});
	}

	module.unapprove = function (answerId, siteId) {
		return Simpplr.Salesforce.sendRequest({
			data : { "answerId": answerId, "siteId": siteId },
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AnswerDataServer&action=unapprove'
		});
	}

	return module;
})(Simpplr, jQuery);