Simpplr.Salesforce.Slack =  (function(Simpplr, $){

	var module = {};
	
	module.getAvailableChannels = function () {
      	return Simpplr.Salesforce.sendRequest({
          	data : {'data' : ''},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SlackDataServer&action=getAvailableChannels'
      	});
  	}
  	
  	module.shareContent = function (params) {
      	return Simpplr.Salesforce.sendRequest({
          	data : {'data' : JSON.stringify(params)},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SlackDataServer&action=shareContent'
      	});
  	}

	module.enableSlackUnfurl = function (appName) {
		return Simpplr.Salesforce.sendRequest({
			data : {'data' : ''},
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SlackDataServer&action=enableSlackUnfurl&appName='+appName
		});
	}
  	 
  	return module;
	
})(Simpplr, jQuery);