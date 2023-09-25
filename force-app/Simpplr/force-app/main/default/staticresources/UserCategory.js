Simpplr.Salesforce.UserCategory = Simpplr.Salesforce.UserCategory || {};
Simpplr.Salesforce.UserCategory = (function (Simpplr, $){
	var module = {};
	
  	module.search = function (data) {
      	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=PeopleCategoryDataServer&action=search'
  		});
  	},
  	
  	module.delete  = function (data) {
      	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=PeopleCategoryDataServer&action=delete'
  		});
  	},
  	
  	module.create  = function (data) {
      	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=PeopleCategoryDataServer&action=create'
  		});
  	},
  	
  	module.rename  = function (idArg, nameArg) {
  		var data = {id:idArg, name:nameArg};
      	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=PeopleCategoryDataServer&action=rename'
  		});
  	}
  	return module;
  	
})(Simpplr, jQuery);