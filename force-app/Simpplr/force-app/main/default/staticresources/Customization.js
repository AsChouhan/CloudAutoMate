Simpplr.Salesforce.Customization = Simpplr.Salesforce.Customization || {};

Simpplr.Salesforce.Customization = (function (Simpplr, $){

	var module = {};
    module.getValues = function (segmentId) {
    	Simpplr.Salesforce.log(arguments);
    	
		var deferred = $.Deferred();
		$.ajax({
			data : {'segmentId' : segmentId},
			method: 'GET',
			url: Simpplr.Salesforce.VisualforceEndpoints.ReadWrite +'?target=UtilityDataServer&action=getValues' ,
			beforeSend: function(xhrObj){
				xhrObj.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
				xhrObj.setRequestHeader("Accept","application/json");
				xhrObj.setRequestHeader("x-simpplr-csrf", __sfdcCsrfToken);
				xhrObj.setRequestHeader("x-http-verb", 'POST');
			}
		}).done(function(data) {
			deferred.resolve(data);
		});
		
		return deferred;
    };
    
    module.refresh = function (segmentId, values, css, classNames) {
    	Simpplr.Salesforce.log('Customization.refresh--values---');
        Simpplr.Salesforce.log(arguments);
     	return Simpplr.Salesforce.sendRequest({
	        data: {'segmentId' : segmentId , 'values' : JSON.stringify(values),'css' : css,'classNames':JSON.stringify(classNames)},
			method: 'POST',
			endpoint: Simpplr.Salesforce.Endpoints.ReadWrite +'?target=UtilityDataServer&action=refreshCustomizations'
      });
    };
    
    module.save = function (segmentId, values, css, classNames) {
      return Simpplr.Salesforce.sendRequest({
          data: {'segmentId' : segmentId, 'values' : JSON.stringify(values),'css' : css,'classNames':JSON.stringify(classNames)},
          method:'POST',
          endpoint: Simpplr.Salesforce.Endpoints.ReadWrite +'?target=UtilityDataServer&action=saveCustomizations' 
      });
    };
	
	module.upload = function (uploadType, segmentId, fileObj) {
		
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
			
			if (segmentId === null) {
				formDataObj.append("segment_id", Simpplr.Settings.organizationId);
			
			} else {
				formDataObj.append("segment_id", segmentId);
			}
			
			formDataObj.append("type", uploadType);
			formDataObj.append("image", fileObj, fileObj.name);
			
			if (typeof data !== 'undefined') {
				var responseObj = {
		            "status": "success",
		            "message": null,
		            "i18nmessage": null,
		            "result": {
		                "thumbnailImg": ""
		            }
	        		}
		        
				$.ajax({
					url: 'https://services.simpplr.com/upload/s3/app_asset_upload.php',
					method: 'POST',
					data: formDataObj,
					async: true,
					crossDomain: true,
					contentType: false, 
					processData: false
					
				}).done(function(awsResponse){
					responseObj.result.thumbnailImg = awsResponse.imageURL;
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