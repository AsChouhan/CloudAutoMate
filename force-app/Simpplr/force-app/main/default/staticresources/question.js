Simpplr.Salesforce.Questions =  (function(Simpplr, $){
	var module = {};
	
	module.get = function (questionId, siteId) { 
  		return Simpplr.Salesforce.sendRequest({
          	data : { "questionId": questionId, "siteId": siteId },
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=QuestionsDataServer&action=get'
      	});
  	}
	
	module.create = function (data) {
		return Simpplr.Salesforce.sendRequest({
			data : {'data' : JSON.stringify(data)},
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=QuestionsDataServer&action=create'
		});
	}
	 
	module.update = function (data, questionId) {
		return Simpplr.Salesforce.sendRequest({
			data : {'questionId': questionId, 'data' : JSON.stringify(data)},
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=QuestionsDataServer&action=update'
		});
	}

	module.delete = function (questionId, siteId) {
		return Simpplr.Salesforce.sendRequest({
			data : { "questionId": questionId, "siteId": siteId },
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=QuestionsDataServer&action=delete'
		});
	}

  	module.search = function (data) {
  		return Simpplr.Salesforce.sendRequest({
          	data : {'data' : JSON.stringify(data)},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=QuestionsDataServer&action=search'
      	});
	}
  	
	module.suggestion = function (data) {
  		return Simpplr.Salesforce.sendRequest({
          	data : {'data' : JSON.stringify(data)},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=QuestionsDataServer&action=suggestion'
      	});
	}

	module.markDuplicate = function (questionId, originalQuestionId, siteId) {
		return Simpplr.Salesforce.sendRequest({
			data : { "questionId":questionId, "originalQuestionId": originalQuestionId, "siteId": siteId },
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=QuestionsDataServer&action=markAsDuplicate'
		});
	}
	module.markNotDuplicate = function (questionId, siteId) {
		return Simpplr.Salesforce.sendRequest({
			data : { "questionId":questionId, "siteId": siteId },
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=QuestionsDataServer&action=markAsNotDuplicate'
		});
	}
	module.markPublished = function (questionId, siteId) {
		return Simpplr.Salesforce.sendRequest({
			data : { "questionId":questionId, "siteId": siteId },
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=QuestionsDataServer&action=publish'
		});
	}

	module.markUnpublished = function (questionId, siteId) {
		return Simpplr.Salesforce.sendRequest({
			data : { "questionId":questionId, "siteId": siteId },
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=QuestionsDataServer&action=unpublish'
		});
	}
  
 	
	return module;
	
})(Simpplr, jQuery);