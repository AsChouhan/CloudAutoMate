Simpplr.Salesforce.Alert =  (function(Simpplr, $){

	var module = {};
	
	module.get = function (alertId) {
  		Simpplr.Salesforce.log('Alert.get---alertId---'+ alertId);
      	return Simpplr.Salesforce.sendRequest({
          	data : {'data' : alertId},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AlertDataServer&action=getAlert'
      	});
  	}
  	
  	module.search = function (params) {
  		Simpplr.Salesforce.log('Alert.search------'+ JSON.stringify(params));
      	return Simpplr.Salesforce.sendRequest({
          	data : {'data' : JSON.stringify(params)},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AlertDataServer&action=searchAlert'
      	});
  	}
  	
  	module.displayNow = function (alertId) {
  		Simpplr.Salesforce.log('Alert.displayNow---alertId---'+ alertId);
      	return Simpplr.Salesforce.sendRequest({
          	data : {'data' : alertId},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AlertDataServer&action=displayNow'
      	});
  	}
  	 
  	module.save = function (id, itemData) {
  		Simpplr.Salesforce.log('Alert.save------id---'+ id);
  		Simpplr.Salesforce.log('Alert.save------data----'+ JSON.stringify(itemData));
  		if(id == null){
  			return Simpplr.Salesforce.sendRequest({
	          	data : {'data' : JSON.stringify(itemData)},
	          	method : 'POST',
	          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AlertDataServer&action=create'
	      	});
  		} else {
  			var data = {alertId:id, itemData:itemData};
  			return Simpplr.Salesforce.sendRequest({
	          	data : {'data' : JSON.stringify(data)},
	          	method : 'POST',
	          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AlertDataServer&action=update'
	      	});
  		}
  	}
  	
  	 
  	module.expireNow = function (alertId) {
  		Simpplr.Salesforce.log('Alert.expireNow---alertId---'+ alertId);
      	return Simpplr.Salesforce.sendRequest({
          	data : {'data' : alertId},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AlertDataServer&action=expireNow'
      	});
  	}
  	
  	module.delete = function (alertId) {
  		Simpplr.Salesforce.log('Alert.delete---alertId---'+ alertId);
      	return Simpplr.Salesforce.sendRequest({
          	data : {'data' : alertId},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AlertDataServer&action=delete'
      	});
  	}
  	
  	module.getActive = function () {
  		Simpplr.Salesforce.log('Alert.getActive------');
      	return Simpplr.Salesforce.sendRequest({
          	data : {'data' : ''},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AlertDataServer&action=getActive'
      	});
  	} 
  	 
  	module.markAsDismissed = function (alertId) {
  		Simpplr.Salesforce.log('Alert.markAsDismissed---alertId---'+ alertId);
      	return Simpplr.Salesforce.sendRequest({
          	data : {'data' : alertId},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AlertDataServer&action=markAsDismissed'
      	});
  	}
  	 
  	 	
	return module;
	
})(Simpplr, jQuery);