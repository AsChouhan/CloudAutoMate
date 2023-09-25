Simpplr.Salesforce.Newsletter =  (function(Simpplr, $){

	var module = {};
	
  	module.sendPreview = function (newsletterId, itemData, email) {
  		var data={'newsletterId': newsletterId, 'itemData': itemData, 'email': email};
  		Simpplr.Salesforce.log('Newsletter.sendPreview---data---'+ JSON.stringify(data));
      	return Simpplr.Salesforce.sendRequest({
          	data : {'data' : JSON.stringify(data)},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=NewsletterDataServer&action=sendPreview'
      	});
  	}
  	
  	module.sendNow = function (newsletterId, itemData) {
		var data={'newsletterId' : newsletterId,'itemData':itemData};
  		Simpplr.Salesforce.log('Newsletter.sendNow---data---'+ JSON.stringify(data));
      	return Simpplr.Salesforce.sendRequest({
          	data : {'data' : JSON.stringify(data)},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=NewsletterDataServer&action=sendNow'
      	});
  	}
  	
  	module.get = function (newsletterId) {
  	Simpplr.Salesforce.log('-----------Newsletter.get()--------------'+newsletterId);
  	return Simpplr.Salesforce.sendRequest({
  		data: {'newsletterId': newsletterId},
  		method:'GET',
  		endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=NewsletterDataServer&action=get'
  	});
  	}
  	
  	module.saveDraft = function (data, sendPreview) {
  		var data={'data' : data,'sendPreview':sendPreview};
  		Simpplr.Salesforce.log('Newsletter.saveDraft---data---'+ JSON.stringify(data));
      	return Simpplr.Salesforce.sendRequest({
          	data: {'data': JSON.stringify(data)},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=NewsletterDataServer&action=saveDraft'
      	});
  	}
  	
  	module.update = function (newsletterId, itemData) {
	  	var data={newsletterId:newsletterId, itemData:itemData};
	  	Simpplr.Salesforce.log('Newsletter.update---data---'+ JSON.stringify(data));
	  	return Simpplr.Salesforce.sendRequest({
		  data: {'data': JSON.stringify(data)},
		  method:'POST',
		  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=NewsletterDataServer&action=update'
		});
  	}
  	
  	module.delete = function (newsletterId) {
	  	Simpplr.Salesforce.log('Newsletter.delete---'+newsletterId);
	  	return Simpplr.Salesforce.sendRequest({
		  data: {'newsletterId': newsletterId},
		  method:'POST',
		  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=NewsletterDataServer&action=delete'
		});
  	}
  	
  	module.edit = function (newsletterId) {
	  	Simpplr.Salesforce.log('Newsletter.edit---'+newsletterId);
	  	return Simpplr.Salesforce.sendRequest({
		  data: {'newsletterId': newsletterId},
		  method:'POST',
		  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=NewsletterDataServer&action=edit'
		});
  	}
  	
  	module.schedule = function (newsletterId, itemData) {
	  	var data={newsletterId:newsletterId, itemData:itemData};
	  	Simpplr.Salesforce.log('Newsletter.schedule---data---'+ JSON.stringify(data));
	  	return Simpplr.Salesforce.sendRequest({
		  data: {'data': JSON.stringify(data)},
		  method:'POST',
		  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=NewsletterDataServer&action=schedule'
		});
  	}
  	
	module.search = function (params) {
		Simpplr.Salesforce.log('Newsletter.search---params---'+ JSON.stringify(params));
		return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(params)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=NewsletterDataServer&action=search'
      	});
	}
	module.uploadImageToAWS = function (contentVersionId) {
		return Simpplr.Salesforce.sendRequest({
			data: {'contentVersionId': contentVersionId},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&action=uploadImageToAWS'
      	});
	}
	module.upload = function (blob) {
		var defObj = $.Deferred();
		var getDRIRequest = $.ajax({
			url: Simpplr.Salesforce.VisualforceEndpoints.ReadOnly +'?target=UtilityDataServer&action=getDRI',
			method: 'GET',
			beforeSend: function(xhrObj){
				xhrObj.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
				xhrObj.setRequestHeader("Accept","application/json");
				xhrObj.setRequestHeader("x-simpplr-csrf", __sfdcCsrfToken);
				xhrObj.setRequestHeader("x-http-verb", 'POST');
            }
			
		});
		
		getDRIRequest.done(function(data) {
			var formDataObj =  new FormData();
			formDataObj.append("rat", data.result);
			formDataObj.append("org_id", Simpplr.Settings.organizationId); 
			formDataObj.append("folder_name", "newsletter");
			formDataObj.append("image", blob, "blob");
			
			if (typeof data !== 'undefined') {
				var responseObj = {
		            "status": "success",
		            "message": null,
		            "i18nmessage": null,
		            "result": {
		                		"bannerUrl": ""
		            		}
	        		};
		        
				$.ajax({
					url: 'https://services.simpplr.com/upload/s3/app_asset_upload.php',
					method: 'POST',
					data: formDataObj,
					async: true,
					crossDomain: true,
					contentType: false, 
					processData: false
					
				}).done(function(awsResponse){
					responseObj.result.url = awsResponse.imageURL;
	            		defObj.resolve(responseObj);
				}).fail(function(error){
					defObj.reject(error);
				});
				
			}
			
		}).fail(function(error){
			defObj.reject(error);
		});
		
		return defObj;
	}
  	
	return module;
	
})(Simpplr, jQuery);