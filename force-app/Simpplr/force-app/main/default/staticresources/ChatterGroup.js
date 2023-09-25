Simpplr.Salesforce.ChatterGroup = Simpplr.Salesforce.ChatterGroup || {};
Simpplr.Salesforce.ChatterGroup = (function (Simpplr, $){
	var module = {};
	
	module.convertToSite = function (chatterGroupId) {
		var data = {'chatterGroupId':chatterGroupId};
		return Simpplr.Salesforce.sendRequest({
          data: {'chatterGroupId' : chatterGroupId},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ChatterGroupDataServer&action=convertToSite'
  		});
		
	}
	
	module.search = function (params) {
		Simpplr.Salesforce.log('ChatterGroup.search---data---'+ JSON.stringify(data));
		var data = {'params':params};
		return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(params)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ChatterGroupDataServer&action=search'
  		});
	}
    
	return module;
})(Simpplr, jQuery);