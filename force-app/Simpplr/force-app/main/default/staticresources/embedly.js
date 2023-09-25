Simpplr.Salesforce.Embedly =  (function(Simpplr, $){
	var module = {};
  	module.oembed = function (params) {
      	return Simpplr.Salesforce.sendRequest({
          	data : {'data' : JSON.stringify(params)},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadOnly +'?target=UtilityDataServer&action=oembed'
      	});
  	}
  	
  	return module; 
})(Simpplr, jQuery);