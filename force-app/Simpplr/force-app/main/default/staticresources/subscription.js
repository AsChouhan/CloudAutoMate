Simpplr.Salesforce.Subscription =  (function(Simpplr, $){
	var module = {};
	var SFDC = {}; 
   	var resultDefObj = {};
   	
  	module.search = function (data) {
	  	var endPoint = Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SubscriptionDataServer&action=search';
	  
      	return Simpplr.Salesforce.sendRequest({
          	data : {'data' : JSON.stringify(data)},
          	method : 'GET',
          	endpoint : endPoint
      	});
  	}
  	
  	module.get = function (data) {
	  	var endPoint = Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SubscriptionDataServer&action=get';
	  
      	return Simpplr.Salesforce.sendRequest({
          	data : {'subscriptionId': data},
          	method : 'GET',
          	endpoint : endPoint
      	});
  	}
  	
  	module.save = function (subscriptionId, data) {
	  	var endPoint = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SubscriptionDataServer&action=save';
	  	
	  	data.subscriptionId = subscriptionId; 
	  	
      	return Simpplr.Salesforce.sendRequest({
          	data : {'data': JSON.stringify(data)},
          	method : 'POST',
          	endpoint : endPoint
      	});
	}

	module.rerun = function (subscriptionId) {
		var endPoint = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SubscriptionDataServer&action=rerun';
		
		return Simpplr.Salesforce.sendRequest({
			data : {'subscriptionId': subscriptionId},
			method : 'GET',
			endpoint : endPoint
		});
  } 

  	
  	module.delete = function (data, deleteUnfollow) {
	  	var endPoint = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SubscriptionDataServer&action=delete';
	  
      	return Simpplr.Salesforce.sendRequest({
          	data : {'subscriptionId': data, 'deleteUnfollow': deleteUnfollow},
          	method : 'GET',
          	endpoint : endPoint
      	});
  	}
  	
  	return module; 
})(Simpplr, jQuery);