Simpplr.Salesforce.Dropbox =  (function(Simpplr, $){
	var module = {};
	
  	module.disconnectAdmin = function (data) {
  		return Simpplr.Salesforce.sendRequest({
          	data : {'data' : JSON.stringify(data)},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=disconnectDropboxAdmin'
      	});
  	}

	module.getAccessToken = function () {
  		Simpplr.Salesforce.log(arguments);
    	var deferred = $.Deferred();
    	var data = {};
    	$.ajax({
			url:    Simpplr.Salesforce.VisualforceEndpoints.ReadWrite +'?target=FileDataServer&action=getEFSAccessToken',
			method: 'POST',
			data:   {data: JSON.stringify(data)},
			beforeSend: function(xhrObj){
				xhrObj.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
				xhrObj.setRequestHeader("Accept","application/json");
				xhrObj.setRequestHeader("x-simpplr-csrf", __sfdcCsrfToken);
				xhrObj.setRequestHeader("x-http-verb", 'POST');
			}
		}).done(function(data) {
			Simpplr.Salesforce.log(JSON.stringify(data));
			deferred.resolve(data);
		});
			
		return deferred;
    }

  	module.resetAccessToken = function (data) {
  		return Simpplr.Salesforce.sendRequest({
          	data : {'data' : JSON.stringify(data)},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&action=resetEFSAccessToken'
      	});
  	}
  	
  	module.getFolders = function (parentDirectoryId, thisDirectory) {
    	Simpplr.Salesforce.log('Dropbox.getFolders---thisDirectory---'+ JSON.stringify(thisDirectory));
    	var data = {directory:parentDirectoryId ,currentDirectory:thisDirectory.id};
    	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&action=getEFSLinkFolders'
  		});
  	}
  	
	module.createFolder = function (data) {
    	Simpplr.Salesforce.log('Dropbox.createFolder---data---'+ JSON.stringify(data));
    	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&siteId=' + data.siteId + '&action=createEFSFolder'
  		});
  	}
  	
    
  	module.getDownloadUrl = function (fileObjArg, versionIdArg) {
		console.log(arguments);
    	var def = $.Deferred();
    	var versionId = (versionIdArg ? versionIdArg : fileObjArg.latestPublishedVersionId);
    	var folderPath = fileObjArg.id;
			
		if (versionId && versionId.length > 4 ){
			
			if (!versionId.startsWith("rev:")) {
				versionId = "rev:" + versionId;
			}
			
			folderPath = versionId;
		}
		
		$.ajax({
			url:    Simpplr.Salesforce.VisualforceEndpoints.ReadWrite +'?target=FileDataServer&action=getDropboxAccessToken',
			method: 'GET',
			beforeSend: function(xhrObj){
				xhrObj.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
				xhrObj.setRequestHeader("Accept","application/json");
				xhrObj.setRequestHeader("x-simpplr-csrf", __sfdcCsrfToken);
				xhrObj.setRequestHeader("x-http-verb", 'POST');
			}
		}).done(function (data) {
			var accessToken = data.result;
			if (window.XMLHttpRequest) {
				var  xhrObj = new XMLHttpRequest();
			  	
			   	xhrObj.onload = function () {
				
					var resultObj = { 
				  		status:'success',
						message: '',
						debugLogs:[],
						i18nmessage: '',
						responseTimeStamp:  '',
				  	};
					  	
					if (this.status === 200) { 
						 
						if (xhrObj.response instanceof Blob) {  
						  	resultObj.result =  xhrObj.response;
					  		def.resolve(resultObj);
					  		
					  	} else {
					  		resultObj.result =  null;
					  		resultObj.status = 'error';
					  		resultObj.message = 'Unable to perform action';
					  		def.reject(resultObj);
					  	}
	
					} else {
						Simpplr.Salesforce.log(arguments);
						resultObj.result =  null;
				  		resultObj.status = 'error';
				  		resultObj.message = 'Unable to perform action';
				  		def.reject(resultObj);
					}
					
			  	};
			  	xhrObj.open("POST", "https://services.simpplr.com/upload/dropbox/download.php");
			  	xhrObj.responseType = "blob";
	        	xhrObj.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
			  	var postData = "drat=" + accessToken + "&path=" + folderPath;
				xhrObj.send(postData);      
			}	
				
		});
		
		return def; 
  	}
  	
  	module.getVersionHistory = function(fileIdArg, providerArg) {
  		var data={fileId : fileIdArg, provider : providerArg};
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(data)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&action=getVersionHistory'
  		});
  	}
  	
  	
    
	return module;
})(Simpplr, jQuery);
