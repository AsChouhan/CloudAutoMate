Simpplr.Salesforce.Box =  (function(Simpplr, $){

	var module = {};
	
	module.getDownloadUrl = function (fileObjArg, versionIdArg) {
		var def = $.Deferred();
		
		var boxFileId = fileObjArg.id;
    	var data = {fileId : boxFileId, versionId : versionIdArg};
    	
    	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&action=getDownloadUrl'
  		}).done(function(data) {
			Simpplr.Salesforce.log(JSON.stringify(data));
			def.resolve(JSON.stringify(data));
		});
  	}
  	
  	module.getFolders = function (directoryArg) {
    	Simpplr.Salesforce.log('File.getFolders---directoryArg---'+ JSON.stringify(directoryArg));
    	var data = {directory: directoryArg};
    	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&action=getBoxLinkableFolders'
  		});
  	}
	
	module.disconnectUser = function (data) {
    	Simpplr.Salesforce.log('File.disconnectUser---data---'+ JSON.stringify(data));
    	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&action=disconnectUser'
     	});
    }
    
    module.disconnectAdmin = function (data) {
    	Simpplr.Salesforce.log('Box.disconnectAdmin---data---'+ JSON.stringify(data));
    	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&action=disconnectAdmin'
     	});
    }
    
	module.getAccessToken = function () {
  		Simpplr.Salesforce.log(arguments);
    	var deferred = $.Deferred();
    	var data = {};
    	$.ajax({
			url:    Simpplr.Salesforce.VisualforceEndpoints.ReadWrite +'?target=FileDataServer&action=getAccessToken',
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
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&action=resetCurrentUserBoxAccessToken'
      	});
  	}
  	
	module.unlinkFolder = function(folderId, provider, boxfolderId, siteId) {
		var data = {folderId : folderId, siteId : siteId};
    	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&siteId=' + data.siteId + '&action=unlinkFolder'
  		});
	}
	
	module.createFolder = function (data) {
    	Simpplr.Salesforce.log('File.createBoxFolder---data---'+ JSON.stringify(data));
    	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&siteId=' + data.siteId + '&action=createBoxFolder'
  		});
  	}
  	 
  	module.linkFolder = function (data) {
    	Simpplr.Salesforce.log('Box.linkFolder---data---'+ JSON.stringify(data));
    	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&siteId=' + data.siteId + '&action=linkFolder'
  		});
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