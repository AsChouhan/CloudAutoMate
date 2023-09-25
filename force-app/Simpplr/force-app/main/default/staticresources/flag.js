Simpplr.Salesforce.Flag =  (function(Simpplr, $){
	var module = {};
   	
  	module.dismiss = function (taskId) {
      	return Simpplr.Salesforce.sendRequest({
          	data : {'data' : taskId},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FlagDataServer&action=dismiss'
      	});
  	}
  	
  	module.dismissOnboarding = function (itemToBeDismissed) {
      	return Simpplr.Salesforce.sendRequest({
          	data : {'data' : itemToBeDismissed},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FlagDataServer&action=dismissOnboarding'
      	});
  	}
  	
  	module.resetOnboarding = function () {
      	return Simpplr.Salesforce.sendRequest({
          	data : {'data' : ''},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FlagDataServer&action=resetOnboarding'
      	});
  	}
  	
  	
  	
	return module;
})(Simpplr, jQuery);