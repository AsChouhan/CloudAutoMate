Simpplr.Salesforce.OneDrive =  (function(Simpplr, $){
	var module = {};
	var resultStrucutureObj = {
        "status": "success",
        "message": null,
        "i18nmessage": null,
        "result": {
            "title": "",
            "size": "",
            "contentVersionId": "",
            "fileType" : "",
            "source" : "intranet",
            "downloadUrl": "",
            "fileUrl": ""
        }
    };
	
	var convertMSAPIStructureToFile = function (resultObj, rootDirectoryArg, siteId) {
        var newObj = $.extend(true, {}, resultStrucutureObj);
		var fileURLTemp;
		
	    fileURLTemp = Simpplr.Salesforce.Links.FileDetail + '?fileId='+ resultObj.id + '&rootdirectory=' + rootDirectoryArg + '&provider=onedrive&permission=readwrite';
	    if (siteId != null || siteId !='') {
	    	fileURLTemp = fileURLTemp + '&siteId=' + siteId;
	    }
        newObj.result.id = resultObj.id;
        newObj.result.rootDirectory = rootDirectoryArg;
        newObj.result.title = resultObj.name;
        newObj.result.fileExtension = newObj.result.title.substring(newObj.result.title.lastIndexOf('.')+1).toUpperCase();
		newObj.result.name = resultObj.name;
		newObj.result.type = newObj.result.title.substring(newObj.result.title.lastIndexOf('.')+1).toUpperCase();
		newObj.result.url = fileURLTemp;
        newObj.result.fileUrl = fileURLTemp;
        newObj.result.canDelete = false;
		newObj.result.canMove = false;
        newObj.result.externalUrl = resultObj.webUrl;
        newObj.result.canDownload = true;
        newObj.result.canCreateNewVersion = false;
        newObj.result.canChangeName = false;
        newObj.result.context = 'onedrive';
        newObj.result.provider = 'onedrive';
        newObj.result.thumbnailImg = '';
        newObj.result.type = newObj.result.title.substring(newObj.result.title.lastIndexOf('.')+1).toUpperCase();
        newObj.result.size = resultObj.size;
        newObj.result.modifiedAt = resultObj.lastModifiedDateTime;
        
        newObj.result.owner = {};
        newObj.result.owner.id = Simpplr.CurrentUser.peopleId;
        newObj.result.owner.name = Simpplr.CurrentUser.name;
        newObj.result.owner.url = '/apex/app?u=/people/' + Simpplr.CurrentUser.peopleId;
        
        newObj.result.site = {};
        newObj.result.site.id = '';
        newObj.result.site.name = '';
        newObj.result.site.url = '';
        return newObj;
    }
    
	module.getAccessToken = function () {
  		Simpplr.Salesforce.log(arguments);
    	var accessReq = $.ajax({
			url:    Simpplr.Salesforce.VisualforceEndpoints.ReadWrite +'?target=FileDataServer&action=getEFSAccessToken&provider=onedrive',
			method: 'POST',
			data:   {data: JSON.stringify('data')},
			beforeSend: function(xhrObj){
				xhrObj.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
				xhrObj.setRequestHeader("Accept","application/json");
				xhrObj.setRequestHeader("x-simpplr-csrf", __sfdcCsrfToken);
				xhrObj.setRequestHeader("x-http-verb", 'POST');
			}
		});
		
		return accessReq;
    }

  	module.resetAccessToken = function (data) {
  		return Simpplr.Salesforce.sendRequest({
          	data : {'data' : JSON.stringify(data)},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&action=resetEFSAccessToken&provider=onedrive'
      	});
  	}
  	
  	module.getFolders = function (parentDirectoryId, thisDirectory) {
    	Simpplr.Salesforce.log('Onedrive.getFolders---thisDirectory---'+ JSON.stringify(thisDirectory));
    	var data = {directory:parentDirectoryId ,currentDirectory:thisDirectory.id};
    	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&action=getEFSLinkFolders&provider=onedrive'
  		});
  	}
  	
  	module.setFolderName = function(folderId, provider, fileTitle, rootDirectory) {
		Simpplr.Salesforce.log('Onedrive.setFolderName---folderId---'+ JSON.stringify(folderId));
		Simpplr.Salesforce.log('Onedrive.setFolderName---provider---'+ JSON.stringify(provider));
		Simpplr.Salesforce.log('Onedrive.setFolderName---fileTitle---'+ JSON.stringify(fileTitle));
		Simpplr.Salesforce.log('Onedrive.setFolderName---rootDirectory---'+ JSON.stringify(rootDirectory));
		var data={folderId : folderId, provider : provider, name: fileTitle, rootDirectory : rootDirectory};
		return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&action=setFolderName'
  		});
	}
  	
	module.createFolder = function (data) {
    	Simpplr.Salesforce.log('Onedrive.createFolder---data---'+ JSON.stringify(data));
    	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&siteId=' + data.siteId + '&action=createEFSFolder&provider=onedrive'
  		});
  	}
  	
  	module.deleteFile = function(fileIdArg, providerArg, siteIdArg, rootDirectory) {
		var data={fileId : fileIdArg, provider : providerArg, fileSiteId: siteIdArg, rootDirectory: rootDirectory};
		return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&action=deleteFile&siteId=' + siteIdArg
  		});
	}
	
	module.deleteFolder = function(folderIdArg, providerArg, siteId, rootDirectory) {
		var data={folderId : folderIdArg, provider : providerArg, siteId: siteId, rootDirectory:rootDirectory};
		return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&action=deleteFolder'
  		});
	}
	
	module.linkFolder = function (data) {
    	Simpplr.Salesforce.log('Onedrive.linkFolder---data---'+ JSON.stringify(data));
    	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&siteId=' + data.siteId + '&action=linkOnedriveFolder'
  		});
  	}	
  	
	module.unlinkFolder = function(folderId, provider, rootDirectory, siteId) {
		Simpplr.Salesforce.log('Onedrive.unlinkFolder---folderId---'+ JSON.stringify(folderId));
		var data = {folderId : folderId, provider : provider, rootDirectory : rootDirectory, siteId : siteId};
    	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&siteId=' + siteId + '&action=unlinkOnedriveFolder'
  		});
	}

    module.moveFiles = function (siteId, fileobjArray, source, target) {
    	console.log(fileobjArray);
    	var data = {
	    				'siteId': siteId,
	    				'fileArray': fileobjArray,
	    				'sourceRoot':  source.rootDirectory,
	    				'source': source.id,
	    				'destinationRoot':  target.rootDirectory,
	    				'destination': target.id,
	    				'provider': 'onedrive'
    				};
    	Simpplr.Salesforce.log('File.moveFiles---data---'+ JSON.stringify(data));
    	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&siteId=' + siteId + '&action=moveFiles'
     	});
    }	
	
	module.getLinkableItems = function (folderType, folderId, directory, siteId, rootDirectory) {
    	var data = {folderType : folderType, folderId : folderId, siteId : siteId, rootDirectory : rootDirectory};
    	Simpplr.Salesforce.log('Onedrive.getLinkableItems---data---'+ JSON.stringify(data));
    	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&action=getOnedriveLinkableItems'
  		});
  	}
	
	module.getDownloadUrl = function (fileObjArg, versionIdArg) {
		console.log(arguments);
		var def = $.Deferred();
		var versionId = (versionIdArg ? versionIdArg : fileObjArg.latestPublishedVersionId);
		var folderPath = fileObjArg.id;
		var resultObj = {};		
		if (versionId && versionId.length > 4 ){
			
			if (!versionId.startsWith("rev:")) {
				versionId = "rev:" + versionId;
			}
			
			folderPath = versionId;
		}
		
		var msDownloadURL = 'https://graph.microsoft.com/v1.0/drives/' +  fileObjArg.rootDirectory + 
				'/items/' + fileObjArg.id;

		$.ajax({
			url:    Simpplr.Salesforce.VisualforceEndpoints.ReadWrite +'?target=FileDataServer&action=getEFSAccessToken&provider=onedrive',
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
			
			$.ajax({
				url:    msDownloadURL,
				method: 'GET',
				headers: {"Authorization": "Bearer "+ accessToken,
						"Accept": "application/json, text/plain"}
			
			}).done(function (data) {
				var actualDownloadUrl = data["@microsoft.graph.downloadUrl"];
				
				resultObj = { 
						status:'success',
						message: '',
						debugLogs:[],
						i18nmessage: '',
						responseTimeStamp:  '',
						result: {"url": actualDownloadUrl}
				};
				 
				def.resolve(resultObj);
				
			}).fail(function(ex){
				if(ex.status === 401) {
					resultObj = { 
						status:"error",
						message: "Something went wrong. OneDrive has been disconnected.",
						debugLogs:[],
						i18nmessage: '',
						responseTimeStamp:  '',
						result: null
					};
					def.reject(resultObj);
				} else {
					def.reject(ex);
				}
			});
			
		}).fail(function(exc){
			def.reject(exc);
		});
		
		return def; 
  	}
  	
  	module.generateFilePreview = function () {
  	
  	}
  	
  	module.upload = function (fileObj){
  		var deferred = $.Deferred();
		fileObj.driveId = fileObj.rootDirectory;
		var filePath;
		
  		if (typeof fileObj.directoryId === 'undefined' ) {
  			filePath = '/root:/' + fileObj.name +':';
  		} else if(fileObj.directoryId.startsWith("/root")) {
  			filePath = fileObj.directoryId + '/' + fileObj.name +':';
  		} else {
  			filePath = '/items/' + fileObj.directoryId + ':/' + fileObj.name +':';
  		}
  		
  		var mapOfProviderWithCharsToIgnore = {
			"onedrive": ["\\", "/", "~","%" , "&", "*", ",","}", ",", ":", "<", ">", "?", "|" ,"“"]
		};
		
		var charsToIgnore = mapOfProviderWithCharsToIgnore[fileObj.provider];
		
		for (var i in charsToIgnore) {
		 	
			if (fileObj.name.indexOf(charsToIgnore[i]) >= 0) {
		   		var errorObj = $.extend(true, {}, resultStrucutureObj);
			 	errorObj.status = "error";
			 	errorObj.message = "It's not possible to upload file - please rename without special characters";
			 	errorObj.result = null;
			 	errorObj.i18nmessage = "It's not possible to upload file - please rename without special characters";
		     	deferred.reject(errorObj);
		     	return deferred;
		   }
		   
		}
		
		var fileReaderObj = new FileReader();
		//var blobObj = helper.base64toBlob(fileObj.base64, fileObj.type);
		var objForUpload = {};
		var isUploadSessionRequired = true; 
		
		if (fileObj.size < 4000000) {
			objForUpload = fileObj;
			isUploadSessionRequired = false;
			
		} 
		 
		/* Creating blank file in MS then we are going to update it*/
		$.ajax({
			url: 'https://graph.microsoft.com/v1.0/drives/' + fileObj.driveId + 
					filePath + '/content',
  			type: 'PUT',
  			beforeSend: function(xhrObj){
                xhrObj.setRequestHeader("Authorization", "Bearer " + fileObj.accessToken);
                xhrObj.setRequestHeader("Content-Type", "application/octet-stream");
            }, 
            processData:false, 
            contentType:false,
			data: objForUpload
			
		}).done(function(uploadedFile){
			
			if (!isUploadSessionRequired) { 
				deferred.resolve(convertMSAPIStructureToFile(uploadedFile, fileObj.rootDirectory,fileObj.siteId));
				
			} else {
				fileObj.id = uploadedFile.id;
				
				/*Creating an upload session for file upload*/
				$.ajax({
					url: 'https://graph.microsoft.com/v1.0/drives/' + fileObj.driveId + '/items/' 
		      					+ fileObj.id + '/createUploadSession',
		  			type: 'POST',
		  			headers: { 
		  				"Authorization" : "Bearer " + fileObj.accessToken
		  			},
		  			data : {}
				}).done(function(data){
					/* uploading file using upload URL returned by SF*/
					var rangeheaderVal = "bytes 0-" + (fileObj.size - 1) + "/" + fileObj.size;
					$.ajax({
			  			url: data.uploadUrl,
			  			type: 'PUT',
			  			beforeSend: function(xhrObj){
			                xhrObj.setRequestHeader("Authorization", "Bearer " + fileObj.accessToken);
			                xhrObj.setRequestHeader("Content-Type", "application/octet-stream");
							xhrObj.setRequestHeader("Content-Range", rangeheaderVal);
			            }, 
			            processData:false, 
			            contentType:false,
			  			data: fileObj
			      	}).done(function(data) {
			      		deferred.resolve(convertMSAPIStructureToFile(data, fileObj.rootDirectory, fileObj.siteId));
			      	}).fail(function(usEx){
			      		Simpplr.Salesforce.log('Upload Session exception - ' + usEx.responseJSON.error.code);
						if(usEx.responseJSON.error.code === 'accessDenied') {
							var usErrObj = $.extend(true, {}, resultStrucutureObj);
						 	usErrObj.status = "error";
						 	usErrObj.message = "403";
						 	usErrObj.result = null;
						 	usErrObj.i18nmessage = "403";
					     	deferred.reject(usErrObj);
						} else {
							deferred.reject(usEx);
						}
			      	});
				}).fail(function(cusEx){
		      		Simpplr.Salesforce.log('CreateUploadSession exception - ' + cusEx.responseJSON.error.code);
		      		Simpplr.Salesforce.log(cusEx);
		      		deferred.reject(cusEx);
				});
			} 
		}).fail(function(upEx){
			Simpplr.Salesforce.log('Upload exception - ' + upEx.responseJSON.error.code);
			if(upEx.responseJSON.error.code === 'accessDenied') {
				var upErrObj = $.extend(true, {}, resultStrucutureObj);
			 	upErrObj.status = "error";
			 	upErrObj.message = "403";
			 	upErrObj.result = null;
			 	upErrObj.i18nmessage = "403";
		     	deferred.reject(upErrObj);
			} else {
				deferred.reject(upEx);
			}
		});
		
		return deferred;
	}
  	
  	module.getVersionHistory = function (fileIdArg, providerArg, driveIdArg){
  		var data={fileId: fileIdArg, provider: providerArg, driveId: driveIdArg};
		return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&action=getVersionHistory'
  		});

  	}
  	
  	module.uploadNewVersion = function(id, provider, fileObj, pathOnClient, versionId, driveId) {
  		var deferred = $.Deferred();
  		
  		if (typeof fileObj.itemId === 'undefined' ) {
  			fileObj.itemId = 'root';
  		}
  		
  		var mapOfProviderWithCharsToIgnore = {
			"onedrive": ["\\", "/", "~","%" , "&", "*", ",","}", ",", ":", "<", ">", "?", "|" ,"“"]
		};
		
		var charsToIgnore = mapOfProviderWithCharsToIgnore[fileObj.provider];
		
		for (var i in charsToIgnore) {
		 	
			if (fileObj.name.indexOf(charsToIgnore[i]) >= 0) {
		   		var errorObj = $.extend(true, {}, resultStrucutureObj);
			 	errorObj.status = "error";
			 	errorObj.message = "It's not possible to upload file - please rename without special characters";
			 	errorObj.result = null;
			 	errorObj.i18nmessage = "It's not possible to upload file - please rename without special characters";
		     	deferred.reject(errorObj);
		     	return deferred;
		   }
		   
		}
		
		var fileReaderObj = new FileReader();
		var objForUpload = {};
		var isUploadSessionRequired = true; 
		
		if (fileObj.size < 4000000) {
			objForUpload = fileObj;
			isUploadSessionRequired = false;
			
		} 

		$.ajax({
			url:    Simpplr.Salesforce.VisualforceEndpoints.ReadWrite +'?target=FileDataServer&action=getEFSAccessToken&provider=onedrive',
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
			/* Creating blank file in MS then we are going to update it*/
			$.ajax({
				url: 'https://graph.microsoft.com/v1.0/drives/' + driveId + 
						'/items/' + id +'/content',
	  			type: 'PUT',
	  			beforeSend: function(xhrObj){
	                xhrObj.setRequestHeader("Authorization", "Bearer " + accessToken);
	                xhrObj.setRequestHeader("Content-Type", "application/octet-stream");
	            }, 
	            processData:false, 
	            contentType:false,
				data: objForUpload
				
			}).done(function(uploadedFile){
				
				if (!isUploadSessionRequired) { 
					deferred.resolve(convertMSAPIStructureToFile(uploadedFile, fileObj.rootdirectory, fileObj.siteId));
					
				} else{
					fileObj.id = uploadedFile.id;
					/*Creating an upload session for file upload*/
					$.ajax({
						url: 'https://graph.microsoft.com/v1.0/drives/' + driveId + '/items/' 
			      					+ id + '/createUploadSession',
			  			type: 'POST',
			  			headers: { 
			  				"Authorization" : "Bearer " + accessToken
			  			},
			  			data : {}
			        	
					}).done(function(data){
					
						/* uploading file using upload URL returned by MS*/
						$.ajax({
				  			url: data.uploadUrl,
				  			type: 'PUT',
				  			beforeSend: function(xhrObj){
				                xhrObj.setRequestHeader("Authorization", "Bearer " + fileObj.accessToken);
				                xhrObj.setRequestHeader("Content-Type", "application/octet-stream");
				            }, 
				            processData:false, 
				            contentType:false,
				  			data: objForUpload
				      	}).done(function(data) {
				      		deferred.resolve(convertMSAPIStructureToFile(data, fileObj.rootDirectory, fileObj.siteId));
				      	}).fail(function(usEx){
							Simpplr.Salesforce.log('Upload Session exception - ' + usEx.responseJSON.error.code);
							if(usEx.responseJSON.error.code === 'accessDenied') {
								var usErrObj = $.extend(true, {}, resultStrucutureObj);
							 	usErrObj.status = "error";
							 	usErrObj.message = "403";
							 	usErrObj.result = null;
							 	usErrObj.i18nmessage = "403";
						     	deferred.reject(usErrObj);
							} else {
								deferred.reject(usEx);
							}
				      	});
					}).fail(function(ex){
						deferred.reject(ex);
					});
				} 
			}).fail(function(upEx){
				Simpplr.Salesforce.log('Upload exception - ' + upEx.responseJSON.error.code);
				if(upEx.responseJSON.error.code === 'accessDenied') {
					var upErrObj = $.extend(true, {}, resultStrucutureObj);
				 	upErrObj.status = "error";
				 	upErrObj.message = "403";
				 	upErrObj.result = null;
				 	upErrObj.i18nmessage = "403";
			     	deferred.reject(upErrObj);
				} else {
					deferred.reject(upEx);
				}
			});
		}).fail(function(ex){
			deferred.reject(ex);
		});	
		
		return deferred;
  	}
    
	return module;
})(Simpplr, jQuery);