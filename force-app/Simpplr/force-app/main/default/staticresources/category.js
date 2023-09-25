Simpplr.Salesforce.PageCategory = {
  search :function (data) {
  	Simpplr.Salesforce.log('PageCategory.search---data---'+ JSON.stringify(data));
  	return Simpplr.Salesforce.sendRequest({
        data: {'data' : JSON.stringify(data)},
        method:'POST',
        endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CategoryDataServer&action=search'
    });
  },
  delete :function (param) {
		var deferred = new $.Deferred();
	   	Simpplr.Salesforce.log('PageCategory.delete---param---'+ JSON.stringify(param));
	  		
   		$.ajax({
        	data: {'data' : JSON.stringify(param)},
         	method:'POST',
         	url:Simpplr.Salesforce.VisualforceEndpoints.ReadWrite +'?target=CategoryDataServer&action=delete',
			beforeSend: function(xhrObj){
				xhrObj.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
				xhrObj.setRequestHeader("Accept","application/json");
				xhrObj.setRequestHeader("x-simpplr-csrf", __sfdcCsrfToken);
				xhrObj.setRequestHeader("x-http-verb", 'POST');
			}
         	
      	}).done(function(data) {
			if ('success' === data.status) {
				deferred.resolve(data);
			} else {
				deferred.reject(data);
			}
		});
   	  	
      	return deferred;
  },
  create :function (data) {
	  	var deferred = new $.Deferred();
	  	Simpplr.Salesforce.log('PageCategory.create---data---'+ JSON.stringify(data));
	  	
	  	$.ajax({
        	data: {'data' : JSON.stringify(data)},
         	method:'POST',
         	url:Simpplr.Salesforce.VisualforceEndpoints.ReadWrite +'?target=CategoryDataServer&action=create',
			beforeSend: function(xhrObj){
				xhrObj.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
				xhrObj.setRequestHeader("Accept","application/json");
				xhrObj.setRequestHeader("x-simpplr-csrf", __sfdcCsrfToken);
				xhrObj.setRequestHeader("x-http-verb", 'POST');
			}
         	
      	}).done(function(data) {
			if ('success' === data.status) {
				deferred.resolve(data);
			} else {
				deferred.reject(data);
			}
		});
   	  	
      	return deferred;
  },
  edit :function (id,data) {
  		var deferred = new $.Deferred();
	  	Simpplr.Salesforce.log('PageCategory.edit---id---'+ JSON.stringify(id));
	  	Simpplr.Salesforce.log('PageCategory.edit---data---'+ JSON.stringify(data));
	    data['id'] = id;
  		
  		$.ajax({
        	data: {'data' : JSON.stringify(data)},
         	method:'POST',
         	url:Simpplr.Salesforce.VisualforceEndpoints.ReadWrite +'?target=CategoryDataServer&action=edit',
			beforeSend: function(xhrObj){
				xhrObj.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
				xhrObj.setRequestHeader("Accept","application/json");
				xhrObj.setRequestHeader("x-simpplr-csrf", __sfdcCsrfToken);
				xhrObj.setRequestHeader("x-http-verb", 'POST');
			}
         	
      	}).done(function(data) {
			if ('success' === data.status) {
				deferred.resolve(data);
			} else {
				deferred.reject(data);
			}
		});
   	  	
      	return deferred;
  }
}