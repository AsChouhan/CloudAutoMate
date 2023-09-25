if (typeof Simpplr !== 'undefined' && Object.keys(Simpplr).length!=0) {
	Simpplr = Simpplr;
	
} else {
   Simpplr = {
	Salesforce: {
		Endpoints:{
			ReadWrite: "/apex/DataServerRW"
   	 	}
   	 }
   };
}

Simpplr.FileDetail = Simpplr.FileDetail || {};
var fileInfoObj = {
	type: '',
	id: '',
	folderPath: ''  
} ;

Simpplr.FileDetail.DBModule = (function (Simpplr, $){
	var helper = {}; 
	
	helper.getAccessToken = function () {
		let curr_endpoint = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&action=getDropboxAccessToken';
		var accessReq = $.ajax({
			url:    curr_endpoint,
			method: 'POST',
			beforeSend: function(xhrObj){
				if (curr_endpoint.includes("/services/apexrest/")) {
					xhrObj.setRequestHeader('Authorization', 'Bearer '  + __sfdcSessionId);

				} else {
					xhrObj.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
					xhrObj.setRequestHeader("Accept","application/json");
					xhrObj.setRequestHeader("x-simpplr-csrf", __sfdcCsrfToken);
					xhrObj.setRequestHeader("x-http-verb", 'POST');
				}
				
            }
		});
		
		return accessReq;
		
	}
	   
	helper.resetAccessToken = function () {
		let curr_endpoint = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&action=resetEFSAccessToken';
		var accessReq = $.ajax({
			url:    curr_endpoint,
			method: 'POST',
			data:   {data: JSON.stringify('data')},
			beforeSend: function(xhrObj){
				if (curr_endpoint.includes("/services/apexrest/")) {
					xhrObj.setRequestHeader('Authorization', 'Bearer '  + __sfdcSessionId);

				} else {
					xhrObj.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
					xhrObj.setRequestHeader("Accept","application/json");
					xhrObj.setRequestHeader("x-simpplr-csrf", __sfdcCsrfToken);
					xhrObj.setRequestHeader("x-http-verb", 'POST');
				}
				
            }
		});
		
		accessReq.done(function(data) {
			console.log('Token Reset:'+data);
		});
	}
	
	helper.generateImagePreview = function (reqData) {
		var accessToken = reqData.accessToken;
		var fileId = reqData.fileInfo.folderPath;
		var form = new FormData();
		form.append("drat", accessToken);
		form.append("path", fileId);
		console.log('###'+ fileId + '###' +accessToken);
		var settings = {
			"async": true,
			"crossDomain": true,
			"url": "https://services.simpplr.com/upload/dropbox/get_preview.php",
			"method": "POST",
			"processData": false,
			"contentType": false,
			"data": form
		}
		
		
		$.ajax(settings).done(function (response) {
			console.log('##################################');
			console.log(response);
			console.log('##################################');
	 		document.getElementById('imageRendition').src = response.data;
		});
		
		
		$.ajax(settings).fail(function(response){ 
			console.log(response);
			console.log('Error getting preview of File=== ' + response.status);
			console.log(arguments);
		});
	
	
	
		/*var xhr = {};
		var accessToken = reqData.accessToken;
		var fileId = reqData.fileInfo.folderPath;
		//console.log('accessToken == '+ reqData.accessToken);
		var dbx = new Dropbox({ accessToken: reqData.accessToken});
	        var base64dataVar;
	        dbx.filesDownload({path: fileId})
	            .then(function(response) {
	                var reader = new FileReader();
	                reader.readAsDataURL(response.fileBlob);
	                reader.onloadend = function() {
	                    base64dataVar = reader.result;                
	                    document.getElementById('imageRendition').src = base64dataVar;
	                }
	                
	            })
	            .catch(function(error) {
	                Simpplr.Salesforce.log('Error Creating the File');
	                //Simpplr.Salesforce.log(arguments);
	                //deferred.reject(arguments);
	            }); */
	}
	
	helper.generatePreviewOfPdf = function (reqData) {
		var xhr = {};
		var accessToken = reqData.accessToken;
		console.log(accessToken);
		var fileId = reqData.fileInfo.id;
		
		if (window.XMLHttpRequest) {
			xhr = new XMLHttpRequest();
		}
		
		xhr.open("GET", "https://www.googleapis.com/drive/v3/files/"+fileId+"?alt=media", true);
		xhr.setRequestHeader('Authorization','Bearer '+accessToken);   
		xhr.responseType = "arraybuffer"; 
		xhr.onreadystatechange = function () {
		
			if (xhr.readyState == xhr.DONE) {
				PDFViewerApplication.open(new Uint8Array(xhr.response)); 
			}
			
		}
		
		xhr.send();
	}
	
	
	
	var module = {}; 
	
	module.generateFilePreview = function (fileInfo) {
		helper.getAccessToken().done(function(data) {
			var accessTokenStr = '';
			
			if (typeof data.result !== 'undefined' &&  data.result !== null) {
				accessTokenStr = data.result
			} 
			
			console.log('acc === '+ accessTokenStr);
			
			var reqObj = {
				fileInfo: fileInfo,
				accessToken: accessTokenStr
			};
			
			
				
			var form = new FormData();
			//form.append("rev", versionIdStr);
			form.append("drat", accessTokenStr);
			form.append("path", fileInfo.folderPath);
			
			var settings = {
				"async": true,
				"crossDomain": true,
				"url": "https://services.simpplr.com/upload/dropbox/get_preview.php",
				"method": "POST",
				"processData": false,
				"contentType": false,
				"data": form
			}
			
			$.ajax(settings).done(function (response) {
			 	if (response.contentType === 'text/html') {
			 		console.log('##### HTML ###');
			 		var htmlEncodingPrefix = 'data:text/html;charset=utf-8,';
			 		document.getElementById('preview-frame-html').src = htmlEncodingPrefix + encodeURIComponent(response.data);
			 	} else if(response.contentType === 'application/pdf') {
			 		console.log('##### PDF ###');
			 		//document.getElementById('loader').style.display = 'none';
			 		PDFViewerApplication.open(new Uint8Array(_base64ToArrayBuffer(response.data))); 
			 	} else {
			 		console.log('##### IMAGES ###');
			 		console.log(document.getElementById('imageRendition'));
			 		var imagePreviewPrefix = 'data:image/png;base64,';
			 		document.getElementById('imageRendition').src = imagePreviewPrefix + response.data;
			 	}
			});
			
			$.ajax(settings).fail(function(response){ 
				console.log(response);
				console.log('Error getting preview of File=== ' + response.status);
				console.log(arguments);
			});
				
			function _base64ToArrayBuffer(base64) {
			    var binary_string =  window.atob(base64);
			    var len = binary_string.length;
			    var bytes = new Uint8Array( len );
			    for (var i = 0; i < len; i++)        {
			        bytes[i] = binary_string.charCodeAt(i);
			    }
			    return bytes.buffer;
			}
				
		});
		
	}
	
	return module;
    
})(Simpplr, $);

var fileInfoObjStr = document.getElementById('fileInfoId');

if (typeof fileInfoObjStr !== 'undefined' && fileInfoObjStr !== null) {
	fileInfoObjStr = fileInfoObjStr.value;
	fileInfoObj = JSON.parse(fileInfoObjStr);
}

if (fileInfoObj.provider === 'dropbox') {
	console.log('====DBAPI ====== ');
	console.log(fileInfoObj);
	Simpplr.FileDetail.DBModule.generateFilePreview(fileInfoObj);
}
