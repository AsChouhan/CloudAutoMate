Simpplr.Salesforce.GoogleDrive =  (function(Simpplr, $){
	var module = {};
	
  	module.disconnectAdmin = function (data) {
  		return Simpplr.Salesforce.sendRequest({
          	data : {'data' : JSON.stringify(data)},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite + '?target=SettingDataServer&action=disconnectGoogleDriveAdmin'
      	});
  	}
  	
  	module.disconnectUser = function (data) {
		var requestObj = {appName: 'googledrive'};
		return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(requestObj)},
	      	method : 'POST',
	      	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite + '?target=peopledataserver&action=disconnectApp'
		});
  	}

	module.getAccessToken = function () {
  		Simpplr.Salesforce.log(arguments);
    	var deferred = $.Deferred();
    	var data = {};
    	$.ajax({
			url:    Simpplr.Salesforce.VisualforceEndpoints.ReadWrite +'?target=FileDataServer&provider=googledrive&action=getGoogleDriveAccessToken',
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
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&action=resetGoogleAccessToken'
      	});
  	}
  	
  	module.getFolders = function (parentDirectoryId, dataArg, siteId) {
        Simpplr.Salesforce.log('GoogleDrive.getFolders---dataArg---'+ JSON.stringify(dataArg));
                
        var data = {directory:parentDirectoryId, currentDirectory:dataArg.id, 
                storage:"googledrive", type:dataArg.type, nextPageToken:dataArg.nextPageToken,
				size:dataArg.size, term:dataArg.term, siteId};
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&action=getGoogleDriveLinkFolders'
        });
    }
      
    module.createFolder = function (data) {
    	Simpplr.Salesforce.log('GoogleDrive.createFolder---data---'+ JSON.stringify(data));
    	if(data.siteId == null) { data.siteId = ""; }
    	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&siteId=' + data.siteId + '&action=createGoogleFolder'
  		});
  	}
  	
  	module.linkFolder = function (data) {
        Simpplr.Salesforce.log('GoogleDrive.linkFolder---data---'+ JSON.stringify(data));
        
    	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&siteId=' + data.siteId + '&action=linkGoogleDriveFolder'
  		}); 
  	}	

  	module.getSiteSharedDrive = function (data) {
        Simpplr.Salesforce.log('GoogleDrive.getSiteSharedDrive---data---'+ JSON.stringify(data));
        
    	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=FileDataServer&siteId=' + data.siteId + '&action=getSiteSharedDriveDetails'
  		}); 
  	}	
  	
	module.unlinkFolder = function(folderId, provider, rootDirectory, siteId) {
		Simpplr.Salesforce.log('GoogleDrive.unlinkFolder---folderId---'+ JSON.stringify(folderId));
		var data = {folderId : folderId, provider : provider, siteId : siteId};
    	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&siteId=' + data.siteId + '&action=unLinkGoogleDriveFolder'
  		});
	}

  	module.getDownloadUrl = function (fileObj, versionIdArg) {
    	console.log(arguments);
    	var def = $.Deferred();
    	var fileIdArg = fileObj.id;
    	var canExport = false;
    	
    	if (fileObj.type.toLowerCase() == 'gdoc' || fileObj.type.toLowerCase() == 'gslides' || fileObj.type.toLowerCase() == 'gsheet' || fileObj.type.toLowerCase() == 'gdraw') {
    		canExport = true;
    	}
		
		Simpplr.Salesforce.log(fileObj.type + ' -- ' + canExport);
		
    	$.ajax({
			url:    Simpplr.Salesforce.VisualforceEndpoints.ReadWrite +'?target=FileDataServer&provider=googledrive&action=getGoogleDriveAccessToken',
			method: 'POST',
			data:   {data: JSON.stringify('data')},
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
				
				if (canExport) {
					xhrObj.open("GET", "https://www.googleapis.com/drive/v3/files/"+fileIdArg+"/export?supportsAllDrives=true&mimeType=application/pdf&alt=media", true);
				} else if (typeof versionIdArg !== 'undefined' && versionIdArg != '' && versionIdArg != null) {
					xhrObj.open("GET", "https://www.googleapis.com/drive/v3/files/" + fileIdArg + "/revisions/" + versionIdArg + "?alt=media&supportsAllDrives=true", true);
				} else {
					xhrObj.open("GET", "https://www.googleapis.com/drive/v3/files/"+fileIdArg+"?alt=media&supportsAllDrives=true", true);
				}
				
				Simpplr.Salesforce.log('Access Token:' + accessToken);
			   	xhrObj.setRequestHeader('Authorization','Bearer '+accessToken);        
			  	xhrObj.responseType = "blob";
			  	
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
			  	
				xhrObj.send();      
			}	
		});
		
		return def;
  	}
  	
  	module.getVersionHistory = function (fileIdArg, providerArg){
  		var data={fileId : fileIdArg, provider : providerArg};
		return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&action=getVersionHistory'
  		});
  	}
    
	return module;
})(Simpplr, jQuery);