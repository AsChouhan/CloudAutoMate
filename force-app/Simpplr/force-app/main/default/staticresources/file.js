Simpplr.Salesforce.File = (function (Simpplr, $) {
	var module = {};
	var resultDefObj = {};
	var globalDeferred = $.Deferred();
	/*fileURL attribute added as it is used by redactor image uplaod plugin. if you see any error due to this, fix the error do not remove the attribute.*/
	var resultStrucutureObj = {
		"status": "success",
		"message": null,
		"i18nmessage": null,
		"result": {
			"title": "",
			"size": "",
			"contentVersionId": "",
			"fileType": "",
			"fileExtension": "",
			"source": "intranet",
			"downloadUrl": "",
			"fileUrl": ""
		}
	};

	uint8ToString = function (buf) {
		var i, length, out = '';

		for (i = 0, length = buf.length; i < length; i += 1) {
			out += String.fromCharCode(buf[i]);
		}

		return out;
	}



	/*fileURL attribute added as it is used by redactor image uplaod plugin. if you see any error due to this, fix the error do not remove the attribute.*/
	var convertoToResultStructure = function (resultObj) {
		var newObj = $.extend(true, {}, resultStrucutureObj);
		newObj.result.id = resultObj.contentDocumentId;
		newObj.result.url = resultObj.url;
		newObj.result.downloadUrl = resultObj.downloadUrl;
		newObj.result.fileUrl = ('fileUrl' in resultObj) ? resultObj.fileUrl : resultObj.downloadUrl;
		newObj.result.contentVersionId = resultObj.id;
		newObj.result.contentDocumentId = resultObj.contentDocumentId;
		newObj.result.title = resultObj.title;
		newObj.result.fileType = resultObj.FileType;
		newObj.result.fileExtension = resultObj.FileType;
		newObj.result.context = 'intranet';
		newObj.result.provider = 'intranet';
		newObj.result.type = resultObj.FileType;
		newObj.result.size = resultObj.ContentSize;
		newObj.result.owner = resultObj.owner;
		newObj.result.modifiedAt = resultObj.modifiedAt;
		newObj.result.canDelete = true;
		newObj.result.canMove = true;
		newObj.result.canCreateNewVersion = true;
		newObj.result.pathOnClient = resultObj.pathOnClient;
		newObj.result.thumbnailImg = resultObj.thumbnailImg;
		newObj.result.isImage = resultObj.isImage;
		newObj.result.isNew = true;
		newObj.result.canCreatePublicShareLink = true;

		return newObj;
	}

	var convertBoxStructureToFile = function (resultObj, directoryArg, rootDirectoryArg, siteId) {
		var pageURl = location.href;
		var indexOfDirParam = pageURl.indexOf('&directory=');
		var indexOfRootDirParam = pageURl.indexOf('&rootDirectory=');

		var directory;
		var rootDirectory;

		if (indexOfDirParam > 0 && indexOfRootDirParam > 0) {
			indexOfDirParam = indexOfDirParam + 11;
			indexOfRootDirParam = indexOfRootDirParam + 15;
			directory = pageURl.substring(indexOfDirParam, pageURl.length);

			if (directory.indexOf('&') > 0) {
				directory = directory.substring(0, directory.indexOf('&'));
			}

			rootDirectory = pageURl.substring(indexOfRootDirParam, pageURl.length);

			if (rootDirectory.indexOf('&') > 0) {
				rootDirectory = rootDirectory.substring(0, rootDirectory.indexOf('&'));
			}

		} else {
			directory = directoryArg;
			rootDirectory = rootDirectoryArg;
		}
		var fileURLTemp;

		fileURLTemp = Simpplr.Salesforce.Links.FileDetail + '?fileId=' + resultObj.id + '&rootDirectory=' + rootDirectory + '&directory=' + directory + '&provider=box';
		if (siteId !== '') {
			fileURLTemp = fileURLTemp + '&siteId=' + siteId;
		}

		var newObj = $.extend(true, {}, resultStrucutureObj);
		newObj.result.id = resultObj.id;
		newObj.result.boxFileId = resultObj.id;
		newObj.result.boxUrl = fileURLTemp;
		newObj.result.canChangeName = true;
		newObj.result.canMove = true;
		newObj.result.createdAt = resultObj.created_at;
		newObj.result.createdAtDateTime = resultObj.content_created_at;
		newObj.result.isDir = !(resultObj.type === 'file');
		newObj.result.isDownloadableOniOS = true;
		newObj.result.isFolder = !(resultObj.type === 'file');
		newObj.result.location = 'Box';
		newObj.result.modifiedAtDateTime = resultObj.content_modified_at;
		newObj.result.name = resultObj.name;
		newObj.result.size = resultObj.size;
		newObj.result.sortBy = 'createdNewest';
		newObj.result.title = resultObj.name;
		newObj.result.url = fileURLTemp;
		newObj.result.fileUrl = fileURLTemp;
		newObj.result.externalUrl = 'https://app.box.com/files/0/f/' + directory + '/1/f_' + resultObj.id;

		/* newObj.result.downloadUrl = fileURLTemp; */
		newObj.result.canDelete = true;
		newObj.result.canCreateNewVersion = true;
		newObj.result.canChangeName = false;
		newObj.result.isBookmarked = false;
		newObj.result.context = 'box';
		newObj.result.provider = 'box';
		newObj.result.thumbnailImg = '';
		newObj.result.type = newObj.result.title.substring(newObj.result.title.lastIndexOf('.') + 1).toUpperCase();
		newObj.result.fileExtension = newObj.result.type;
		newObj.result.size = resultObj.size;
		newObj.result.modifiedAt = resultObj.content_modified_at;

		newObj.result.owner = {};
		newObj.result.owner.id = Simpplr.CurrentUser.peopleId;
		newObj.result.owner.name = Simpplr.CurrentUser.name;
		newObj.result.owner.url = '/apex/app?u=/people/' + Simpplr.CurrentUser.peopleId;

		newObj.result.site = {};
		newObj.result.site.id = '';
		newObj.result.site.name = '';
		newObj.result.site.url = '';

		var parent = {};
		parent.id = resultObj.parent.id;
		parent.name = resultObj.parent.name;
		newObj.result.listOfParents = [];
		newObj.result.listOfParents.push(parent);

		return newObj;
	}

	var convertGDAPIStructureToFile = function (resultObj, directoryArg) {
		var fileURLTemp;

		fileURLTemp = Simpplr.Salesforce.Links.FileDetail + '?fileId=' + resultObj.id + '&directory=' + directoryArg + '&provider=googledrive';
		if (Simpplr.Settings.SITE_ID !== '') {
			fileURLTemp = fileURLTemp + '&siteId=' + Simpplr.Settings.SITE_ID;
		}

		var newObj = $.extend(true, {}, resultStrucutureObj);
		newObj.result.id = resultObj.id;
		newObj.result.title = resultObj.name;
		newObj.result.fileExtension = newObj.result.title.substring(newObj.result.title.lastIndexOf('.') + 1).toUpperCase();
		newObj.result.name = resultObj.name;
		newObj.result.url = fileURLTemp;
		newObj.result.fileUrl = fileURLTemp;
		/* newObj.result.downloadUrl = fileURLTemp; */
		newObj.result.canDelete = false;
		if (Simpplr.Settings.SITE_ID !== '') {
			newObj.result.canMove = true;
		}
		newObj.result.canDownload = true;
		newObj.result.gdriveUrl = resultObj.webViewLink;
		newObj.result.externalUrl = resultObj.webViewLink;
		newObj.result.canCreateNewVersion = true;
		newObj.result.canChangeName = false;
		newObj.result.isBookmarked = false;
		newObj.result.context = 'googledrive';
		newObj.result.provider = 'googledrive';
		newObj.result.thumbnailImg = '';
		newObj.result.type = newObj.result.title.substring(newObj.result.title.lastIndexOf('.') + 1).toUpperCase();
		newObj.result.size = resultObj.size;
		newObj.result.modifiedAt = resultObj.modifiedTime;

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

	var convertDBAPIStructureToFile = function (resultObj, directoryArg, siteId) {
		var fileURLTemp;
		directoryArg = encodeURIComponent(directoryArg);

		fileURLTemp = Simpplr.Salesforce.Links.FileDetail + '?fileId=' + resultObj.id + '&directory=' + directoryArg + '&provider=dropbox';
		if (siteId !== '') {
			fileURLTemp = fileURLTemp + '&siteId=' + siteId;
		}

		var newObj = $.extend(true, {}, resultStrucutureObj);
		newObj.result.id = resultObj.id;
		newObj.result.title = resultObj.name;
		newObj.result.fileExtension = newObj.result.title.substring(newObj.result.title.lastIndexOf('.') + 1).toUpperCase();
		newObj.result.name = resultObj.name;
		newObj.result.url = fileURLTemp;
		newObj.result.fileUrl = fileURLTemp;
		/* newObj.result.downloadUrl = fileURLTemp; */
		newObj.result.canDelete = true;

		if (Simpplr.Settings.SITE_ID !== '') {
			newObj.result.canMove = true;
		}

		newObj.result.externalUrl = 'https://www.dropbox.com/home' + directoryArg + '/' + resultObj.name;
		newObj.result.canDownload = true;
		newObj.result.dropboxUrl = resultObj.webViewLink;
		newObj.result.canCreateNewVersion = true;
		newObj.result.canChangeName = false;
		newObj.result.isBookmarked = false;
		newObj.result.context = 'dropbox';
		newObj.result.provider = 'dropbox';
		newObj.result.thumbnailImg = '';
		newObj.result.type = newObj.result.title.substring(newObj.result.title.lastIndexOf('.') + 1).toUpperCase();
		newObj.result.size = resultObj.size;
		newObj.result.modifiedAt = resultObj.modifiedTime;

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

	module.getLikers = function (data) {
		return Simpplr.Salesforce.sendRequest({
			data: { 'data': JSON.stringify(data) },
			method: 'GET',
			endpoint: Simpplr.Salesforce.Endpoints.ReadWrite + '?target=FileLikerDataServer'
		});
	};

	module.upload = function (fileObj) {
		var deferred = $.Deferred();
		var mapOfProviderWithCharsToIgnore = {
			"intranet": ["#"],
			"box": ["\\", "/"],
			"dropbox": ["\\", "/"],
			"onedrive": ["\\", "/", "~", "%", "&", "*", ",", "}", ",", ":", "<", ">", "?", "|", "“"]
		};

		var charsToIgnore = mapOfProviderWithCharsToIgnore[fileObj.provider];

		// for files uploaded from computer/local storage
		if (fileObj.provider == null) {
			charsToIgnore = ["#"];
		}

		for (var i in charsToIgnore) {

			if (fileObj.name.indexOf(charsToIgnore[i]) >= 0) {
				var errorObj = $.extend(true, {}, resultStrucutureObj);
				errorObj.status = "error";
				errorObj.message = "It's not possible to upload file - please rename without special characters";
				errorObj.result = {
					"isValidFileName": false
				};
				errorObj.i18nmessage = "It's not possible to upload file - please rename without special characters";
				deferred.reject(errorObj);
				return deferred;
			}

		}

		if (typeof fileObj !== undefined && typeof fileObj.provider !== undefined && fileObj.provider === 'box') {
			var folderId = fileObj.directory || '0';
			var rootFolderId = fileObj.rootDirectory || '0';
			var siteId = fileObj.siteId || '';
			var formData = new FormData();
			formData.append('file', fileObj);
			formData.append('parent_id', folderId);

			$.ajax({
				url: 'https://upload.box.com/api/2.0/files/content',
				method: 'POST',
				data: formData,
				crossDomain: true,
				processData: false,
				contentType: false,
				headers: { 'Authorization': 'Bearer ' + fileObj.accessToken }

			}).done(function (data) {
				deferred.resolve(convertBoxStructureToFile(data.entries[0], folderId, rootFolderId, siteId));
			}).fail(function () {
				deferred.reject(arguments);
			});
		} else if (typeof fileObj !== undefined && typeof fileObj.provider !== undefined && fileObj.provider === 'googledrive') {
			var gdFoldId = fileObj.directory || 'root';
			var gdFileData = {};
			var parArray = new Array();
			parArray[0] = gdFoldId;
			gdFileData["parents"] = parArray;
			gdFileData["name"] = fileObj.name;
			gdFileData["mimeType"] = fileObj.type;

			var boundary = Simpplr.CurrentUser.peopleId;

			var blob = new Blob(["--boundary_" + boundary + '\n'
				+ "Content-Type: application/json; charset=UTF-8" + "\n\n"
				+ JSON.stringify(gdFileData)
				+ "\n\n"
				+ "--boundary_" + boundary + "\n"
				+ "Content-Type: " + fileObj.type + "\"\n\n",
				fileObj,
			"\n--boundary_" + boundary + "--"],
				{ type: 'multipart/related; boundary=\"boundary_' + boundary + '\"' });

			var gdFileReq = $.ajax({
				url: 'https://www.googleapis.com/upload/drive/v3/files?supportsAllDrives=true&uploadType=multipart&fields=id,name,webViewLink,size,modifiedTime',
				type: 'POST',
				headers: { "Authorization": "Bearer " + fileObj.accessToken, "Content-Type": 'multipart/related; boundary=\"boundary_' + Simpplr.CurrentUser.peopleId + '\"' },
				data: blob,
				cache: false,
				contentType: false,
				processData: false,
				crossDomain: true
			});

			gdFileReq.done(function (data) {
				deferred.resolve(convertGDAPIStructureToFile(data, gdFoldId));
			});

			gdFileReq.fail(function (data) {
				deferred.reject(arguments);
			});

		} else if (typeof fileObj !== undefined && typeof fileObj.provider !== undefined && fileObj.provider === 'dropbox') {

			// get access token 

			$.ajax({
				url: Simpplr.Salesforce.VisualforceEndpoints.ReadWrite + '?target=FileDataServer&action=getDropboxAccessToken',
				method: 'POST',
				beforeSend: function(xhrObj){
					xhrObj.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
					xhrObj.setRequestHeader("Accept","application/json");
					xhrObj.setRequestHeader("x-simpplr-csrf", __sfdcCsrfToken);
					xhrObj.setRequestHeader("x-http-verb", 'POST');
				}
			}).done(function (data) {
				var siteId = fileObj.siteId || '';
				var folderPath = (fileObj.directory && fileObj.directory != 'root') ? fileObj.directory : '';
				var form = new FormData();
				form.append("drat", data.result);
				form.append("path", folderPath + '/' + fileObj.name);
				form.append("upfile", fileObj, fileObj.name);
				form.append("mode", "add");

				var settings = {
					"async": true,
					"crossDomain": true,
					"url": "https://services.simpplr.com/upload/dropbox/upload.php",
					"method": "POST",
					"processData": false,
					"contentType": false,
					"data": form
				}

				$.ajax(settings).done(function (response) {
					deferred.resolve(convertDBAPIStructureToFile(response.data, folderPath, siteId));
				});

				$.ajax(settings).fail(function (response) {
					deferred.reject(arguments);
				});


			}).fail(function () {
				deferred.reject(arguments);
			});


		} else {
			var fileUploadSForceSuccess = function (result) {
				fileUploadSuccess(result[0]);
			}
			var fileUploadSuccess = function (result) {


				if (result.success) {

					var queryResult = sforce.connection.query("SELECT Id, Title, FileType, ContentSize,ContentDocumentId, PublishStatus, Owner.name, Owner.id, LastModifiedDate, pathOnClient FROM ContentVersion WHERE Id=" + "'" + result.id + "'" + "");
					records = queryResult.getArray("records");
					var fileDetailPageURL = '/apex/FileDetail?fileId=';

					if (fileObj.siteId != '') {
						fileDetailPageURL = '/apex/FileDetail?siteId=' + fileObj.siteId + '&fileId=';
					}

					for (var i = 0; i < records.length; i++) {
						var thumbnailImg = '';
						var isImage = false;
						if (records[i].FileType && records[i].FileType.match(/(jpg|jpeg|png|gif)/i)) {
							thumbnailImg = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB240BY180&versionId=' + records[i].Id;
							isImage = true;
						}

						var resultObj = {
							id: records[i].Id,
							url: fileDetailPageURL + records[i].ContentDocumentId,
							downloadUrl: '/sfc/servlet.shepherd/version/Download/' + records[i].Id + '?asPdf=false&operationContext=CHATTER',
							fileUrl: '/sfc/servlet.shepherd/version/Download/' + records[i].Id + '?asPdf=false&operationContext=CHATTER',
							contentDocumentId: records[i].ContentDocumentId,
							title: records[i].Title,
							FileType: records[i].FileType,
							fileExtension: records[i].FileType,
							thumbnailImg: thumbnailImg,
							isImage: isImage,
							ContentSize: records[i].ContentSize,
							modifiedAt: Simpplr.Salesforce.Utility.dateToUsersTZ(records[i].LastModifiedDate),
							pathOnClient: records[i].PathOnClient,
							owner: { id: records[i].Owner.Id, name: records[i].Owner.Name, url: Simpplr.Settings.appUrl + '?u=/redirect-to-profile/' + records[i].Owner.Id }
						}
					}

					deferred.resolve(convertoToResultStructure(resultObj));

				} else {
					var exceptionResultObj = {
						"status": "error",
						"message": null,
						"i18nmessage": null,
						"result": null
					};

					if (typeof result.errors !== 'undefined' &&
						typeof result.errors.message !== 'undefined' &&
						result.errors.statusCode == 'STORAGE_LIMIT_EXCEEDED') {
						exceptionResultObj.message = 'Unable to perform action - storage full';
						exceptionResultObj.i18nmessage = 'Unable to perform action - storage full';
					}

					deferred.reject(exceptionResultObj);
				}
			}

			var objectSaveFailed = function () {
				deferred.reject();
			}

			sforce.connection.sessionId = __sfdcSessionId;
			var basePathOnClient = '';

			if (fileObj.siteId != '') { /**** If SiteId exists in URL (Site-root and Site-Folders) ****/
				if (fileObj.provider != undefined && fileObj.provider.toLowerCase() == 'intranet') {
					if (fileObj.directory != null) {
						basePathOnClient = 'A0F29C47EA374DF79BDB3A280F1B7D5C#' + fileObj.siteId + '#' + fileObj.directory + '#';
					} else {
						basePathOnClient = 'A0F29C47EA374DF79BDB3A280F1B7D5C#' + fileObj.siteId + '##';
					}
				}

				/**** Content Images ****/
				if (fileObj.location == 'cover') {
					if (fileObj.type == 'original') {
						basePathOnClient = 'simp_cont_original#' + fileObj.siteId + '#';
					} else if (fileObj.type == 'thumbnail' || fileObj.type == 'banner') {
						basePathOnClient = 'simp_cont_cropped#' + fileObj.siteId + '#' + 'a8uybdu8-e423-7de4-da42-b4r9t1078pf7#';
					}
				} else if (fileObj.location == 'attachment') {
					basePathOnClient = 'simp_cont_attach#' + fileObj.siteId + '#';
				} else if (fileObj.location == 'inline') {
					basePathOnClient = 'simp_cont_inline#' + fileObj.siteId + '#';
				}
			} else {

				/**** Content Images (Blogs) ****/
				if (fileObj.location == 'cover') {
					if (fileObj.type == 'original') {
						basePathOnClient = 'simp_cont_original#BlogPost#';
					} else if (fileObj.type == 'thumbnail' || fileObj.type == 'banner') {
						basePathOnClient = 'simp_cont_cropped#BlogPost#' + 'a8uybdu8-e423-7de4-da42-b4r9t1078pf7#';
					}
				} else if (fileObj.location == 'attachment') {
					basePathOnClient = 'simp_cont_attach#BlogPost#';
				} else if (fileObj.location == 'inline') {
					basePathOnClient = 'simp_cont_inline#BlogPost#';
				}
			}

			// 'H' for Chatter File, 'C' for Content Document
			if (fileObj instanceof Blob) {
				var client = new forcetk.Client();
				client.setSessionToken(__sfdcSessionId);
				client.createBlob('ContentVersion', {
					Origin: 'H',
					PathOnClient: basePathOnClient + fileObj.name,
					Title: fileObj.name
				}, fileObj.name, 'VersionData', fileObj, function (response) {
					fileUploadSuccess(response);

				}, function (request, status, response) {
					objectSaveFailed(response);

				}, function (evt) {
					var loaded = (evt.loaded / evt.total) * 100;
					deferred.notify(loaded);
				});
			} else if (fileObj instanceof Object) {
				var contentObj = new sforce.SObject("ContentVersion");
				contentObj.versionData = fileObj.base64;
				contentObj.title = fileObj.title || fileObj.name;
				contentObj.Origin = 'H';
				contentObj.pathOnClient = basePathOnClient + (fileObj.title || fileObj.name);
				sforce.connection.create([contentObj], {
					onSuccess: fileUploadSForceSuccess, onFailure: objectSaveFailed,
					onProgress: function (evt) {
						var loaded = (evt.loaded / evt.total) * 100;
						deferred.notify(loaded);
					}
				});
			} else {
				deferred.reject();
			}

		}

		return deferred;
	};

	module.get = function (contentVersionId) {
		var deferred = $.Deferred();
		var queryResult = sforce.connection.query("SELECT Id, Title, FileType, ContentSize,ContentDocumentId, PublishStatus, Owner.name, Owner.id, LastModifiedDate, pathOnClient FROM ContentVersion WHERE Id=" + "'" + contentVersionId + "'" + "");
		records = queryResult.getArray("records");
		var fileDetailPageURL = '/apex/FileDetail?fileId=';

		for (var i = 0; i < records.length; i++) {
			var thumbnailImg = '';
			var isImage = false;
			if (records[i].FileType && records[i].FileType.match(/(jpg|jpeg|png|gif)/i)) {
				thumbnailImg = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB240BY180&versionId=' + records[i].Id;
				isImage = true;
			}

			var resultObj = {
				id: records[i].Id,
				url: fileDetailPageURL + records[i].ContentDocumentId,
				downloadUrl: '/sfc/servlet.shepherd/version/Download/' + records[i].Id + '?asPdf=false&operationContext=CHATTER',
				fileUrl: '/sfc/servlet.shepherd/version/Download/' + records[i].Id + '?asPdf=false&operationContext=CHATTER',
				contentDocumentId: records[i].ContentDocumentId,
				title: records[i].Title,
				FileType: records[i].FileType,
				fileExtension: records[i].FileType,
				thumbnailImg: thumbnailImg,
				isImage: isImage,
				ContentSize: records[i].ContentSize,
				modifiedAt: Simpplr.Salesforce.Utility.dateToUsersTZ(records[i].LastModifiedDate),
				pathOnClient: records[i].PathOnClient,
				owner: { id: records[i].Owner.Id, name: records[i].Owner.Name, url: Simpplr.Settings.appUrl + '?u=/redirect-to-profile/' + records[i].Owner.Id }
			}
		}

		return deferred.resolve(convertoToResultStructure(resultObj));
	}

	module.getBase64 = function (contentDocumentId) {
		var deferred = $.Deferred();
		var arrayBufferToBase64 = function (buffer) {
			var binary = '';
			var bytes = new Uint8Array(buffer);
			var len = bytes.byteLength;
			for (var i = 0; i < len; i++) {
				binary += String.fromCharCode(bytes[i]);
			}
			var response = { "result": window.btoa(binary) };
			return response;
		}
		var fileDownloadSuccess = function (response) {
			deferred.resolve(arrayBufferToBase64(response));
		}
		var fileDownloadFailed = function (response) {
			deferred.reject();
		}


		var downloadUrl = '/services/data/v45.0/connect/files/' + contentDocumentId + '/content';
		var client = new forcetk.Client();
		client.setSessionToken(__sfdcSessionId);
		client.getChatterFile(downloadUrl, null, fileDownloadSuccess, fileDownloadFailed, false);
		return deferred;
	}

	module.resetCurrentUserBoxAccessToken = function () {
		var def = $.Deferred();
		var deferred = $.Deferred();
		var data = {};
		$.ajax({
			url: Simpplr.Salesforce.VisualforceEndpoints.ReadWrite + '?target=FileDataServer&action=resetCurrentUserBoxAccessToken',
			method: 'POST',
			data: { data: JSON.stringify(data) },
			beforeSend: function(xhrObj){
				xhrObj.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
				xhrObj.setRequestHeader("Accept","application/json");
				xhrObj.setRequestHeader("x-simpplr-csrf", __sfdcCsrfToken);
				xhrObj.setRequestHeader("x-http-verb", 'POST');
			}
		});
		def.resolve();
		return def;
	}

	module.search = function (data) {
		var searchFilesEndpointURL = Simpplr.Salesforce.Endpoints.ReadWrite + '?target=FileDataServer&action=search';
		if (typeof data.siteId != 'undefined') {
			searchFilesEndpointURL += ('&siteId=' + data.siteId);
		}
		return Simpplr.Salesforce.sendRequest({
			data: { 'data': JSON.stringify(data) },
			method: 'get',
			endpoint: searchFilesEndpointURL
		});
	};

	module.uploadNewVersion = function (id, provider, fileObj, pathOnClient, versionId) {
		var deferred = $.Deferred();
		var mapOfProviderWithCharsToIgnore = {
			"intranet": ["#"],
			"box": ["\\", "/"],
			"dropbox": ["\\", "/"]
		};

		var charsToIgnore = mapOfProviderWithCharsToIgnore[provider];

		for (var i in charsToIgnore) {

			if (fileObj.name.indexOf(charsToIgnore[i]) >= 0) {
				var errorObj = $.extend(true, {}, resultStrucutureObj);
				errorObj.status = "error";
				errorObj.message = "It's not possible to upload file - please rename without special characters";
				errorObj.result = {
					"isValidFileName": false
				};
				errorObj.i18nmessage = "It's not possible to upload file - please rename without special characters";
				deferred.reject(errorObj);
				return deferred;
			}

		}

		if (provider === 'box') {
			var pageURl = location.href;
			var indexOfDirParam = pageURl.indexOf('&directory=');
			var indexOfRootDirParam = pageURl.indexOf('&rootDirectory=');

			var directory;
			var rootDirectory;

			if (indexOfDirParam > 0 && indexOfRootDirParam > 0) {
				indexOfDirParam = indexOfDirParam + 11;
				indexOfRootDirParam = indexOfRootDirParam + 15;
				directory = pageURl.substring(indexOfDirParam, pageURl.length);

				if (directory.indexOf('&') > 0) {
					directory = directory.substring(0, directory.indexOf('&'));
				}

				rootDirectory = pageURl.substring(indexOfRootDirParam, pageURl.length);

				if (rootDirectory.indexOf('&') > 0) {
					rootDirectory = rootDirectory.substring(0, rootDirectory.indexOf('&'));
				}

			} else {
				rootDirectory = 0;
				directory = 0;
			}

			var formData = new FormData();
			formData.append('file', fileObj);
			formData.append('parent_id', directory);

			//"If-Match" : "{!fileObj.etag}", to be added once Joe will return this key
			$.ajax({
				url: Simpplr.Salesforce.VisualforceEndpoints.ReadWrite + '?target=FileDataServer&action=getAccessToken',
				method: 'POST',
				data: { data: JSON.stringify('data') },
				beforeSend: function(xhrObj){
					xhrObj.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
					xhrObj.setRequestHeader("Accept","application/json");
					xhrObj.setRequestHeader("x-simpplr-csrf", __sfdcCsrfToken);
					xhrObj.setRequestHeader("x-http-verb", 'POST');
				}
			}).done(function (data) {

				$.ajax({
					url: 'https://upload.box.com/api/2.0/files/' + id + '/content',
					type: "POST",
					crossDomain: true,
					processData: false,
					contentType: false,
					data: formData,
					headers: { "Authorization": "Bearer " + data.result }

				}).done(function (data) {
					deferred.resolve(convertBoxStructureToFile(data.entries[0]));
				}).fail(function () {
					deferred.reject(arguments);
				});
			});

		} else if (provider === 'googledrive') {
			var gdFoldId = fileObj.directory;
			var accessReq = $.ajax({
				url: Simpplr.Salesforce.VisualforceEndpoints.ReadWrite + '?target=FileDataServer&provider=googledrive&action=getGoogleDriveAccessToken',
				method: 'POST',
				data: { data: JSON.stringify('data') },
				beforeSend: function(xhrObj){
					xhrObj.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
					xhrObj.setRequestHeader("Accept","application/json");
					xhrObj.setRequestHeader("x-simpplr-csrf", __sfdcCsrfToken);
					xhrObj.setRequestHeader("x-http-verb", 'POST');
				}
			});

			accessReq.done(function (data) {
				var versionUpload = $.ajax({
					url: 'https://www.googleapis.com/upload/drive/v3/files/' + id + '?supportsAllDrives=true&uploadType=media&fields=id,name,webViewLink,size,modifiedTime',
					method: 'POST',
					data: fileObj,
					crossDomain: true,
					contentType: false,
					processData: false,
					headers: { "Authorization": "Bearer " + data.result, "X-HTTP-Method-Override": "PATCH" }
				});

				versionUpload.done(function (data, textStatus, jqXHR) {
					deferred.resolve(convertGDAPIStructureToFile(data, gdFoldId));
				});

				versionUpload.fail(function () {
					deferred.reject(arguments);
				});
			});

			accessReq.fail(function () {
				deferred.reject(arguments);
			});

			$.ajax({
				url: Simpplr.Salesforce.VisualforceEndpoints.ReadWrite + '?target=FileDataServer&action=resetGoogleDriveAccessToken',
				method: 'POST',
				data: { data: JSON.stringify('data') },
				beforeSend: function(xhrObj){
					xhrObj.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
					xhrObj.setRequestHeader("Accept","application/json");
					xhrObj.setRequestHeader("x-simpplr-csrf", __sfdcCsrfToken);
					xhrObj.setRequestHeader("x-http-verb", 'POST');
				}
			});

		} else if (provider === 'dropbox') {

			$.ajax({
				url: Simpplr.Salesforce.VisualforceEndpoints.ReadWrite + '?target=FileDataServer&action=getDropboxAccessToken',
				method: 'POST',
				beforeSend: function(xhrObj){
					xhrObj.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
					xhrObj.setRequestHeader("Accept","application/json");
					xhrObj.setRequestHeader("x-simpplr-csrf", __sfdcCsrfToken);
					xhrObj.setRequestHeader("x-http-verb", 'POST');
				}
			}).done(function (res) {
				var siteId = fileObj.siteId || '';
				var folderPath = (id && id != 'root') ? id : '';
				var form = new FormData();
				var versionIdStr = versionId;

				if (versionIdStr !== undefined && versionIdStr.startsWith("rev:")) {
					versionIdStr = versionId.substring(versionId.indexOf("rev:") + 4, versionId.length);
				}
				form.append("rev", versionIdStr);
				form.append("drat", res.result);
				form.append("path", folderPath);
				form.append("upfile", fileObj, fileObj.name);
				form.append("mode", "update");

				var settings = {
					"async": true,
					"crossDomain": true,
					"url": "https://services.simpplr.com/upload/dropbox/upload.php",
					"method": "POST",
					"processData": false,
					"contentType": false,
					"data": form
				}

				$.ajax(settings).done(function (response) {
					deferred.resolve(convertDBAPIStructureToFile(response.data, folderPath, siteId));
				});

				$.ajax(settings).fail(function (response) {
					deferred.reject(arguments);
				});


			}).fail(function () {
				deferred.reject(arguments);
			});

		} else {
			var fileUploadNewVersionSForceSuccess = function (result) {
				fileUploadNewVersionSuccess(result[0]);
			}

			var fileUploadNewVersionSuccess = function (result) {
				if (result.success) {
					var queryResult = sforce.connection.query("SELECT Id, Title, FileType, ContentSize,ContentDocumentId, PublishStatus, Owner.name, Owner.id, LastModifiedDate, pathOnClient FROM ContentVersion WHERE Id=" + "'" + result.id + "'" + "");
					records = queryResult.getArray("records");
					var fileDetailPageURL = '/apex/FileDetail?fileId=';

					if (fileObj.siteId != '') {
						fileDetailPageURL = '/apex/FileDetail?siteId=' + fileObj.siteId + '&fileId=';
					}

					for (var i = 0; i < records.length; i++) {
						var thumbnailImg = '';
						var isImage = false;
						if (records[i].FileType && records[i].FileType.match(/(jpg|jpeg|png|gif)/i)) {
							thumbnailImg = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB240BY180&versionId=' + records[i].Id;
							isImage = true;
						}
						var resultObj = {
							id: records[i].Id,
							url: fileDetailPageURL + records[i].ContentDocumentId,
							downloadUrl: '/sfc/servlet.shepherd/version/Download/' + records[i].Id + '?asPdf=false&operationContext=CHATTER',
							fileUrl: '/sfc/servlet.shepherd/version/Download/' + records[i].Id + '?asPdf=false&operationContext=CHATTER',
							contentDocumentId: records[i].ContentDocumentId,
							title: records[i].Title,
							FileType: records[i].FileType,
							fileExtension: records[i].FileType,
							ContentSize: records[i].ContentSize,
							thumbnailImg: thumbnailImg,
							isImage: isImage,
							modifiedAt: Simpplr.Salesforce.Utility.dateToUsersTZ(records[i].LastModifiedDate),
							pathOnClient: records[i].PathOnClient,
							owner: { id: records[i].Owner.Id, name: records[i].Owner.Name, url: Simpplr.Settings.appUrl + '?u=/redirect-to-profile/' + records[i].Owner.Id }
						}
					}

					deferred.resolve(convertoToResultStructure(resultObj));

				} else {

					var exceptionResultObj = {
						"status": "error",
						"message": null,
						"i18nmessage": null,
						"result": null
					};

					if (typeof result[0].errors !== 'undefined' &&
						typeof result[0].errors.message !== 'undefined' &&
						result[0].errors.statusCode == 'STORAGE_LIMIT_EXCEEDED') {
						exceptionResultObj.message = 'Unable to perform action - storage full';
						exceptionResultObj.i18nmessage = 'Unable to perform action - storage full';
					}

					deferred.reject(exceptionResultObj);
				}

				return deferred;
			}

			var objectSaveFailed = function () {
				deferred.reject();
				return deferred;
			}

			sforce.connection.sessionId = __sfdcSessionId;
			if (fileObj instanceof Blob) {
				var client = new forcetk.Client();
				client.setSessionToken(__sfdcSessionId);
				client.createBlob('ContentVersion', {
					Origin: 'H',
					PathOnClient: pathOnClient.substring(0, pathOnClient.lastIndexOf('#')) + '#' + fileObj.name,
					Title: fileObj.name,
					ContentDocumentId: id
				}, fileObj.name, 'VersionData', fileObj, function (response) {
					fileUploadNewVersionSuccess(response);

				}, function (request, status, response) {
					objectSaveFailed(response);

				}, function (evt) {
					var loaded = (evt.loaded / evt.total) * 100;
					deferred.notify(loaded);
				});
			} else if (fileObj instanceof Object) {
				var contentObj = new sforce.SObject("ContentVersion");
				contentObj.versionData = fileObj.base64;
				contentObj.title = fileObj.title;
				contentObj.Origin = 'H';
				contentObj.pathOnClient = fileObj.title;
				contentObj.ContentDocumentId = id;
				sforce.connection.create([contentObj], {
					onSuccess: fileUploadNewVersionSForceSuccess, onFailure: objectSaveFailed,
					onProgress: function (evt) {
						var loaded = (evt.loaded / evt.total) * 100;
						deferred.notify(loaded);
					}
				});
			} else {
				deferred.reject();
			}
		}

		return deferred;
	}

	module.createFolder = function (data) {
		return Simpplr.Salesforce.sendRequest({
			data: { 'data': JSON.stringify(data) },
			method: 'POST',
			endpoint: Simpplr.Salesforce.Endpoints.ReadWrite + '?target=FileDataServer&siteId=' + data.siteId + '&action=createFolder'
		});
	}

	module.createBoxFolder = function (data) {
		return Simpplr.Salesforce.sendRequest({
			data: { 'data': JSON.stringify(data) },
			method: 'POST',
			endpoint: Simpplr.Salesforce.Endpoints.ReadWrite + '?target=FileDataServer&siteId=' + data.siteId + '&action=createBoxFolder'
		});
	}

	module.createEFSFolder = function (data) {
		if (data.siteId == null) { data.siteId = ""; }
		return Simpplr.Salesforce.sendRequest({
			data: { 'data': JSON.stringify(data) },
			method: 'POST',
			endpoint: Simpplr.Salesforce.Endpoints.ReadWrite + '?target=FileDataServer&siteId=' + data.siteId + '&action=createEFSFolder'
		});
	}

	module.delete = function (fileIdArg, providerArg, siteIdArg) {
		var data = { fileId: fileIdArg, provider: providerArg, fileSiteId: siteIdArg };
		return Simpplr.Salesforce.sendRequest({
			data: { 'data': JSON.stringify(data) },
			method: 'POST',
			endpoint: Simpplr.Salesforce.Endpoints.ReadWrite + '?target=FileDataServer&action=deleteFile&siteId=' + siteIdArg
		});
	}

	module.remove = function (fileIdArg, providerArg, siteIdArg) {
		var data = { fileId: fileIdArg, provider: providerArg, fileSiteId: siteIdArg };
		return Simpplr.Salesforce.sendRequest({
			data: { 'data': JSON.stringify(data) },
			method: 'POST',
			endpoint: Simpplr.Salesforce.Endpoints.ReadWrite + '?target=FileDataServer&action=removeFile&siteId=' + siteIdArg
		});
	}

	module.setFavorited = function (id, setFavoritedBool, context) {
		var deferred = $.Deferred();
		var actionName = "";
		if (setFavoritedBool) {
			actionName = "bookmark";
		} else {
			actionName = "unbookmark";
		}
		if (typeof id !== undefined) {

			$.ajax({
				url: Simpplr.Salesforce.VisualforceEndpoints.ReadWrite + '?target=ToggleBookmarkDataServer',
				method: 'get',
				data: { recordId: id, action: actionName, context: context },
				beforeSend: function(xhrObj){
					xhrObj.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
					xhrObj.setRequestHeader("Accept","application/json");
					xhrObj.setRequestHeader("x-simpplr-csrf", __sfdcCsrfToken);
					xhrObj.setRequestHeader("x-http-verb", 'POST');
				}
			}).done(function (data) {
				deferred.resolve(data);
			}).fail(function (xhr, reason, error) {
				deferred.reject();
			});

		} else {
			deferred.reject(false);
		}
		return deferred;
	}

	module.share = function (fileObj, data) { //fileId
		var deferred = $.Deferred();

		if (typeof fileObj !== 'undefined') {
			var fileId = fileObj.id;
		}

		var fileStarter = '';
		var fileEnd = '';
		var seprator = ' | ';
		var newLine = '\n';
		var bodyToFileSeprator = '\u2063\uFEFF\u200b\uFEFF\u2063';
		var listOfExtProvider = ['box', 'googledrive', 'dropbox', 'onedrive', 'sharepoint', 'intranet', 'native_video'];

		if (listOfExtProvider.includes(fileObj.context.toLowerCase())) {
			data.body = data.body + bodyToFileSeprator + fileStarter + fileObj.title +
				seprator + fileId + seprator + fileObj.size + seprator + fileObj.type +
				seprator + fileObj.context + seprator + fileObj.url + fileEnd;
		}
		if (typeof data.urlName !== 'undefined' && data.urlName != null && data.urlName.length >= 255) {
			data.urlName = data.urlName.substring(0, 200);
		}

		data['url'] = data['url'].replace(/\//g, '\\\\/');

		if (typeof data !== undefined) {
			var requestObj = {
				action: 'share',
				subjectId: data['subjectId'],
				Type: data['type'],
				url: data['url'],
				urlName: data['urlName'],
				textToPost: data.body
			};

			return Simpplr.Salesforce.sendRequest({
				data: requestObj,
				method: 'POST',
				endpoint: Simpplr.Salesforce.Endpoints.ReadWrite + '?target=ChatterInteractionDataServer'
			});

		} else {
			deferred.reject(false);
		}

		return deferred;
	}

	module.setLiked = function (fileId, setLikedBool) {

		var deferred = $.Deferred();
		var actionName = "";
		if (setLikedBool) {
			actionName = "like";
		} else {
			actionName = "unlike";
		}
		if (typeof fileId !== undefined) {

			$.ajax({
				url: Simpplr.Salesforce.VisualforceEndpoints.ReadWrite + '?target=ChatterInteractionDataServer',
				method: 'get',
				data: { recordId: fileId, action: actionName, likeType: 'file' },
				beforeSend: function(xhrObj){
					xhrObj.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
					xhrObj.setRequestHeader("Accept","application/json");
					xhrObj.setRequestHeader("x-simpplr-csrf", __sfdcCsrfToken);
					xhrObj.setRequestHeader("x-http-verb", 'POST');
				}
			}).done(function (data) {
				deferred.resolve(data);
			}).fail(function (xhr, reason, error) {
				deferred.reject();
			});

		} else {
			deferred.reject(false);
		}
		return deferred;
	}

	module.setFolderName = function (folderIdArg, providerArg, nameArg, siteIdArg) {
		var data = { folderId: folderIdArg, provider: providerArg, name: nameArg, siteId: siteIdArg };
		return Simpplr.Salesforce.sendRequest({
			data: { 'data': JSON.stringify(data) },
			method: 'POST',
			endpoint: Simpplr.Salesforce.Endpoints.ReadWrite + '?target=FileDataServer&action=setFolderName'
		});
	}

	module.setFolderPermissions = function (folderIdArg, providerArg, permissionsArg, folderNameArg, siteIdArg) {
		var data = { folderId: folderIdArg, provider: providerArg, permissions: permissionsArg, name: folderNameArg };
		return Simpplr.Salesforce.sendRequest({
			data: { 'data': JSON.stringify(data) },
			method: 'POST',
			endpoint: Simpplr.Salesforce.Endpoints.ReadWrite + '?target=FileDataServer&siteId=' + siteIdArg + '&action=setFolderPermissions'
		});
	}

	module.deleteFolder = function (folderIdArg, providerArg) {
		var data = { folderId: folderIdArg, provider: providerArg };
		return Simpplr.Salesforce.sendRequest({
			data: { 'data': JSON.stringify(data) },
			method: 'POST',
			endpoint: Simpplr.Salesforce.Endpoints.ReadWrite + '?target=FileDataServer&action=deleteFolder'
		});
	}

	module.edit = function (folderIdArg, providerArg) {
		var data = { folderId: folderIdArg, provider: providerArg };
		return Simpplr.Salesforce.sendRequest({
			data: { 'data': JSON.stringify(data) },
			method: 'POST',
			endpoint: Simpplr.Salesforce.Endpoints.ReadWrite + '?target=FileDataServer&action=updateFolderName'
		});
	}

	module.getPublicUrl = function (fileIdArg, providerArg) {
		var data = { fileId: fileIdArg, provider: providerArg };
		return Simpplr.Salesforce.sendRequest({
			data: { 'data': JSON.stringify(data) },
			method: 'POST',
			endpoint: Simpplr.Salesforce.Endpoints.ReadWrite + '?target=FileDataServer&action=getPublicUrl'
		});
	};


	module.setDescription = function (idArg, providerArg, descriptionArg, titleArg, languageIdArg) {
		var data = { fileId: idArg, description: descriptionArg, provider: providerArg, languageId: languageIdArg, title: titleArg };
		return Simpplr.Salesforce.sendRequest({
			data: { 'data': JSON.stringify(data) },
			method: 'POST',
			endpoint: Simpplr.Salesforce.Endpoints.ReadWrite + '?target=FileDataServer&action=setDescription'
		});
	}

	module.moveFiles = function (siteId, fileobjArray, sourceFolderId, destinationFolderId, fileProvider) {
		var data = {
			'siteId': siteId,
			'fileArray': fileobjArray,
			'source': sourceFolderId,
			'destination': destinationFolderId,
			'provider': fileProvider
		};
		return Simpplr.Salesforce.sendRequest({
			data: { 'data': JSON.stringify(data) },
			method: 'POST',
			endpoint: Simpplr.Salesforce.Endpoints.ReadWrite + '?target=FileDataServer&siteId=' + siteId + '&action=moveFiles'
		});
	}

	module.linkCrmFolder = function (data) {
		return Simpplr.Salesforce.sendRequest({
			data: { 'data': JSON.stringify(data) },
			method: 'POST',
			endpoint: Simpplr.Salesforce.Endpoints.ReadWrite + '?target=FileDataServer&siteId=' + data.siteId + '&action=linkCrmFolder'
		});
	}

	module.unlinkCrmFolder = function (folderId, provider, rootDirectory, siteId) {
		var data = {
			'folderId': folderId
		};
		return Simpplr.Salesforce.sendRequest({
			data: { 'data': JSON.stringify(data) },
			method: 'POST',
			endpoint: Simpplr.Salesforce.Endpoints.ReadWrite + '?target=FileDataServer&siteId=' + siteId + '&action=unlinkCrmFolder'
		});
	}

	module.getCrmFolders = function (directory, rootDirectory, siteId) {
		var data = {
			'directory': directory,
			'rootDirectory': rootDirectory
		};
		return Simpplr.Salesforce.sendRequest({
			data: { 'data': JSON.stringify(data) },
			method: 'POST',
			endpoint: Simpplr.Salesforce.Endpoints.ReadOnly + '?target=FileDataServer&siteId=' + siteId + '&action=getCrmFolders'
		});
	}

	module.getVersionHistory = function (fileIdArg, providerArg) {
		var data = { fileId: fileIdArg, provider: providerArg };
		return Simpplr.Salesforce.sendRequest({
			data: { 'data': JSON.stringify(data) },
			method: 'POST',
			endpoint: Simpplr.Salesforce.Endpoints.ReadWrite + '?target=FileDataServer&action=getVersionHistory'
		});
	}

	module.getFileTypes = function () {
		return Simpplr.Salesforce.sendRequest({
			method: 'GET',
			endpoint: Simpplr.Salesforce.Endpoints.ReadWrite + '?target=FileDataServer&action=getFileTypes'
		});
	}

	module.syncAllCompanyGoogleDriveGroup = function () {
		return Simpplr.Salesforce.sendRequest({
			method: 'GET',
			endpoint: Simpplr.Salesforce.Endpoints.ReadWrite + '?target=FileDataServer&action=syncAllCompanyGoogleDriveGroup'
		});
	}

	module.getFileFolderPermission = function (data) {
		Simpplr.Salesforce.log('File.getFileFolderPermission---data---' + JSON.stringify(data));
		return Simpplr.Salesforce.sendRequest({
			data: { 'data': JSON.stringify(data) },
			method: 'POST',
			endpoint: Simpplr.Salesforce.Endpoints.ReadWrite + '?target=FileDataServer&action=getFileFolderPermission'
		});
	}

	module.getAudienceCSVDownloadURL = function (fileIdArg) {  
		var data = {fileId: fileIdArg};	
		return Simpplr.Salesforce.sendRequest({
			method: 'POST',
			data: {'data' : JSON.stringify(data)},
			endpoint:Simpplr.Salesforce.Endpoints.ReadWrite + '?target=FileDataServer&action=getAudienceCSVDownloadURL'
		});
	};

	return module;
})(Simpplr, jQuery);