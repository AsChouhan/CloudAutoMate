Simpplr.Salesforce.Notification = {

	search :function (param) {
	     	return Simpplr.Salesforce.sendRequest({
			  data: {'data' : JSON.stringify(param)},
			  method:'POST',
			  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=NotificationDataServer&action=search'
			});
	      	  
  	},
  	
  	markAllNonActionableAsRead :function () {
  		var def = $.Deferred();
      		$.ajax({
          		data: {'id':''},
          		method:'POST',
          		url:Simpplr.Salesforce.VisualforceEndpoints.ReadWrite +'?target=NotificationDataServer&action=markAllNonActionableAsRead',
				beforeSend: function(xhrObj){
					xhrObj.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
					xhrObj.setRequestHeader("Accept","application/json");
					xhrObj.setRequestHeader("x-simpplr-csrf", __sfdcCsrfToken);
					xhrObj.setRequestHeader("x-http-verb", 'POST');
				}
      		}).done(function(data){
      				def.resolve(data);
      			})
      		.fail(function(){
      			def.reject();
      		});
      		return def;
  	},
  	
  	markAllTypeAsSeen :function (type) {
  		return Simpplr.Salesforce.sendRequest({
	          data : {'type':type},
	          method:'POST',
	          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=NotificationDataServer&action=markAllTypeAsSeen'
	      });
	  },

	markAllAsSeen :function (type) {
		return Simpplr.Salesforce.sendRequest({
			data : {'type':type},
			method:'POST',	
			endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=NotificationDataServer&action=markAllTypeAsSeen'
		});
	},
	  
	sendMobilePromotionLink: function (param) {	
  		return Simpplr.Salesforce.sendRequest({
				data : param,
	          	method:'POST',
	          	endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=NotificationDataServer&action=sendMobilePromotionLink'
	      });
	},
	  
	sendBrandedAppDistributionLink: function (param) {	
		return Simpplr.Salesforce.sendRequest({
			data : param,
			method:'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=NotificationDataServer&action=sendBrandedAppDistributionLink'
		});
	},

	bulkSendBrandedAppDistributionLink: function (param) {	
		return Simpplr.Salesforce.sendRequest({
			data : param,
			method:'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=NotificationDataServer&action=buldSendBrandedAppDistributionLink'
		});
	},

	saveWebPushPromptFlag: function(webPushPromptFlag) {
		return Simpplr.Salesforce.sendRequest({
			data: {'webPushPromptFlag': webPushPromptFlag},
          	method:'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=peopledataserver&action=saveWebPushPromptFlag'
		});
	},

	sendInAppPushNotifications :function (param) {
		return Simpplr.Salesforce.sendRequest({
		data: {'data' : JSON.stringify(param)},
		method:'POST',
		endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=NotificationDataServer&action=sendInAppPushNotifications'
		});	   
	}
}
