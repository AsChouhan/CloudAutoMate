Simpplr.Salesforce.NewsletterTemplate =  (function(Simpplr, $){

	var module = {}; 
	
  	module.save = function (id, data) {
      	return Simpplr.Salesforce.sendRequest({
          	data : {'templateId' : id, 'data' : JSON.stringify(data)},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=NewsletterTemplateDataServer&action=save'
      	});
  	}
  	
  	module.get = function (id) {
      	return Simpplr.Salesforce.sendRequest({
          	data : {'templateId' : id},
          	method : 'GET',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=NewsletterTemplateDataServer&action=get'
      	});
  	}
  	
  	module.delete = function (id) {
        return Simpplr.Salesforce.sendRequest({
            data: {'templateId': id},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=NewsletterTemplateDataServer&action=delete'
        });
  	}
  	
  	module.search = function (data) {
      	return Simpplr.Salesforce.sendRequest({
          	data: {'data': JSON.stringify(data)},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=NewsletterTemplateDataServer&action=search'
      	});
  	}
  	
	return module;
	
})(Simpplr, jQuery);