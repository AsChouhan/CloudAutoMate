Simpplr.Salesforce.Atlassian =  (function(Simpplr, $){

	var module = {};
	
	module.getConfluenceSpaces = function (params) {
  		//Simpplr.Salesforce.log('Atlassian.getConfluenceSpaces------');
      	return Simpplr.Salesforce.sendRequest({
          	data : {'data' : JSON.stringify(params)},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AtlassianDataServer&action=getConfluenceSpaces'
      	});
  	};

	module.getConfluenceContributors = function (params) {
		//Simpplr.Salesforce.log('Atlassian.getConfluenceContributors------');
		return Simpplr.Salesforce.sendRequest({
			data : {'data' : JSON.stringify(params)},
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AtlassianDataServer&action=getConfluenceUsers'
		});
	};
  		
	return module;
	
})(Simpplr, jQuery);