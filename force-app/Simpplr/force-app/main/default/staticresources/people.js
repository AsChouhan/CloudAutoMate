Simpplr = Simpplr || {};
Simpplr.Salesforce = Simpplr.Salesforce || {};
Simpplr.Salesforce.People = Simpplr.Salesforce.People || {};
Simpplr.Salesforce.Statistics = Simpplr.Salesforce.Statistics || {};

Simpplr.Salesforce.People = (function (Simpplr, $){
	var module = {};

  	module.search = function (data) {
  		Simpplr.Salesforce.log('-----arguments------');
  		Simpplr.Salesforce.log(arguments);
      	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=peopledataserver&action=search'
      });
  	}
	
	return module;
})
Simpplr.Salesforce.Statistics = (function (Simpplr, $){
	var module = {};
	
  	module.getCompanyStats = function () {
  	Simpplr.Salesforce.log('in getCompanyStats');
      return Simpplr.Salesforce.sendRequest({
          method:'GET',
          endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=peopledataserver&action=getCompanyStats'
		});
	}
	return module;
})
(Simpplr, jQuery);