Simpplr.Salesforce.NewsletterV2 =  (function(Simpplr, $){

	var module = {};  
	
  	module.save = function (newsletterId, data) {
      	return Simpplr.Salesforce.sendRequest({
          	data : {'data' : JSON.stringify(data), 'newsletterId': newsletterId},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadOnly +'?target=NewsletterV2DataServer&action=save'
      	});
  	}
  	
  	module.get = function (newsletterId) {
      	return Simpplr.Salesforce.sendRequest({
          	data :  {'newsletterId' : newsletterId},
          	method : 'GET',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadOnly +'?target=NewsletterV2DataServer&action=get'
      	});
  	}
  	
  	module.getAuditLog = function (newsletterId) {
        return Simpplr.Salesforce.sendRequest({
            data: {'newsletterId': newsletterId},
            method:'GET',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=NewsletterV2DataServer&action=getAuditLog'
        });
  	}
  	
  	module.getSnapshot = function (newsletterId) {
      	return Simpplr.Salesforce.sendRequest({
          	data: {'newsletterId': newsletterId},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadOnly +'?target=NewsletterV2DataServer&action=getSnapshot'
      	});
  	}
  	
  	module.delete = function (newsletterId) {
	  	return Simpplr.Salesforce.sendRequest({
		  data: {'newsletterId': newsletterId},
		  method:'POST',
		  endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=NewsletterV2DataServer&action=delete'
		});
  	}
  	
  	module.send = function (newsletterId) {
	  	return Simpplr.Salesforce.sendRequest({
		  data: {'newsletterId': newsletterId},
		  method:'POST',
		  endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=NewsletterV2DataServer&action=send'
		});
  	}
  	
  	module.sendPreview = function (newsletterId, data) {
	  	return Simpplr.Salesforce.sendRequest({
		  data: {'newsletterId': newsletterId, 'data': JSON.stringify(data)},
		  method:'POST',
		  endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=NewsletterV2DataServer&action=sendPreview'
		});
  	}
  	
  	module.search = function (data) {
	  	return Simpplr.Salesforce.sendRequest({
		  data: {'data': JSON.stringify(data)},
		  method:'POST',
		  endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=NewsletterV2DataServer&action=search'
		});
  	}
  	
	module.validate = function (data) {
		return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(data)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=NewsletterV2DataServer&action=validate'
      	});
    }

	module.getAnalyticsOverview = function (newsletterId) {
		return Simpplr.Salesforce.sendRequest({
		  	data: {'newsletterId': newsletterId },
			method:'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=NewsletterV2DataServer&action=getAnalyticsOverview'
		});
	}
	  
	module.getAnalyticsClicksListing = function (newsletterId, order) {
		return Simpplr.Salesforce.sendRequest({
			data: {'newsletterId': newsletterId, 'order': order},
			method:'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=NewsletterV2DataServer&action=getAnalyticsClicksListing'
		});
	}
	  
	module.getAnalyticsHeatmap = function (newsletterId) {
		return Simpplr.Salesforce.sendRequest({
			data: {'newsletterId': newsletterId },
			method:'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=NewsletterV2DataServer&action=getAnalyticsHeatmap'
		});
	}

	module.getEmailIdentities = function () {
		return Simpplr.Salesforce.sendRequest({
			data: {'data' : ''},
			method:'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=NewsletterV2DataServer&action=getEmailIdentities'
		});
	}

	module.getEmailIdentityDetails = function (id) {
        return Simpplr.Salesforce.sendRequest({
            data: {'id' : id},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=NewsletterV2DataServer&action=getEmailIdentityDetails'
        });
    }

	module.createEmailIdentity = function (data) {
		return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(data)},
			method:'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=NewsletterV2DataServer&action=createEmailIdentity'
		});
	}

	module.updateEmailIdentity = function (id, data) {
		return Simpplr.Salesforce.sendRequest({
			data: {'id' : id, 'data' : JSON.stringify(data)},
			method:'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=NewsletterV2DataServer&action=updateEmailIdentity'
		});
	}

	module.deleteEmailIdentity = function (id) {
		return Simpplr.Salesforce.sendRequest({
			data: {'id' : id},
			method:'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=NewsletterV2DataServer&action=deleteEmailIdentity'
		});
	}

	module.syncEmailIdentity = function (id) {
        return Simpplr.Salesforce.sendRequest({
            data: {'id' : id},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=NewsletterV2DataServer&action=syncEmailIdentity'
        });
    }

	module.getFilterOptions = function () {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : ''},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +"?target=NewsletterV2DataServer&action=getFilterOptions"
        });
    }

	module.getContentAnalytics = function (days) {
		return Simpplr.Salesforce.sendRequest({
			data: {days},
			method:'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +"?target=NewsletterV2DataServer&action=getContentAnalytics"
		});
	}

	module.sessionHeartbeat = function (data) {
		return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(data)},
			method:'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +"?target=NewsletterV2DataServer&action=sessionHeartbeat"
		});
	}

	module.getCategories = function () {
		return Simpplr.Salesforce.sendRequest({
			data: {'data' : ''},
			method:'GET',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +"?target=NewsletterV2DataServer&action=getCategories"
		});
	}

	module.saveCategory = function (data) {
		return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(data)},
			method:'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +"?target=NewsletterV2DataServer&action=saveCategory"
		});
	}

	module.getDetailedCategories = function () {
		return Simpplr.Salesforce.sendRequest({
			data: {'data' : ''},
			method:'GET',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +"?target=NewsletterV2DataServer&action=getDetailedCategories"
		});
	}

	module.getCategoryOverview = function (categoryId) {
		return Simpplr.Salesforce.sendRequest({
			data: {'categoryId' : categoryId},
			method:'GET',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +"?target=NewsletterV2DataServer&action=getCategoryOverview"
		});
	}

	module.getCategoryNewsletters = function (data) {
		return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(data)},
			method:'GET',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +"?target=NewsletterV2DataServer&action=getCategoryNewsletters"
		});
	}

	module.getCategoryUnsentNewsletters = function (data) {
		return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(data)},
			method:'GET',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +"?target=NewsletterV2DataServer&action=getCategoryUnsentNewsletters"
		});
	}

	module.getArchivedNewsletters = function (data) {
		return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(data), 'forIds' : false},
			method:'GET',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +"?target=NewsletterV2DataServer&action=getArchivedNewsletters"
		});
	}

	module.getArchivedNewsletterIds = function (data) {
		return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(data), 'forIds' : true},
			method:'GET',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +"?target=NewsletterV2DataServer&action=getArchivedNewsletters"
		});
	}

	module.getAllSenderAddresses = function (data) {
		return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(data)},
			method:'GET',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +"?target=NewsletterV2DataServer&action=getAllSenderAddresses"
		});
	}

	module.getAllDomains = function (data) {
		return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(data)},
			method:'GET',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +"?target=NewsletterV2DataServer&action=getAllDomains"
		});
	}

	module.createDomain = function (data) {
		return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(data)},
			method:'GET',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +"?target=NewsletterV2DataServer&action=createDomain"
		});
	}

	module.createSenderAddress = function (data) {
		return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(data)},
			method:'GET',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +"?target=NewsletterV2DataServer&action=createSenderAddress"
		});
	}

	module.updateSenderAddress = function (id, data) {
		return Simpplr.Salesforce.sendRequest({
			data: {'id' : id, 'data' : JSON.stringify(data)},
			method:'GET',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +"?target=NewsletterV2DataServer&action=updateSenderAddress"
		});
	}

	module.deleteSenderAddress = function (id) {
		return Simpplr.Salesforce.sendRequest({
			data: {'id' : id},
			method:'GET',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +"?target=NewsletterV2DataServer&action=deleteSenderAddress"
		});
	}

	module.deleteDomain = function (id) {
		return Simpplr.Salesforce.sendRequest({
			data: {'id' : id},
			method:'GET',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +"?target=NewsletterV2DataServer&action=deleteDomain"
		});
	}

	return module;
	
})(Simpplr, jQuery);