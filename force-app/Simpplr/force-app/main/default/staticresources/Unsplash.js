Simpplr.Salesforce.Unsplash =  (function(Simpplr, $){

	var module = {};  
	
	module.getPhotos = function (query, page, perpage) {
		return Simpplr.Salesforce.sendRequest({
			data : {query, page, perpage},
			method : "POST",
			endpoint : Simpplr.Salesforce.Endpoints.ReadOnly +"?target=NewsletterV2DataServer&action=getPhotos"
		});
	};

	module.trackDownload = function (data) {
		return Simpplr.Salesforce.sendRequest({
			data : {"data" : JSON.stringify(data)},
			method : "POST",
			endpoint : Simpplr.Salesforce.Endpoints.ReadOnly +"?target=NewsletterV2DataServer&action=trackDownload"
		});
	};

	return module;
	
})(Simpplr, jQuery);