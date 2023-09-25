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
	id: '' 
} ;

Simpplr.FileDetail.GDModule = (function (Simpplr, $){
	var helper = {}; 
	
	helper.showProgressBar = function () {
	
		if ($('#loadingBar').hasClass('hidden')){
		
			if ($('#loadingBar div').hasClass('indeterminate')){
				$('#loadingBar div').addClass('indeterminate');
			}
			
			$('#loadingBar').removeClass('hidden');
		
		} else {
			
			if (!$('#loadingBar div').hasClass('indeterminate')){
				$('#loadingBar div').addClass('indeterminate');
				$('#loadingBar div').css('width','100%');
			}
			
		}
		
	}
	
	helper.hideProgressBar = function () {
		$('#loadingBar').addClass('hidden');
	}
	
	helper.getAccessToken = function () {
		let curr_endpoint = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&provider=googledrive&action=getGoogleDriveAccessToken';
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
		
		return accessReq;
		
	}
	   
	helper.resetAccessToken = function () {
		let curr_endpoint = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&provider=googledrive&action=resetGoogleDriveAccessToken';
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
		var xhr = {};
		var accessToken = reqData.accessToken;
		var fileId = reqData.fileInfo.id;
		
		if (window.XMLHttpRequest) {
			xhr = new XMLHttpRequest();
		}
		
		xhr.open("GET", "https://www.googleapis.com/drive/v3/files/"+fileId+"?alt=media&supportsAllDrives=true", true); 
		xhr.setRequestHeader('Authorization','Bearer '+accessToken);        
		xhr.responseType = "blob"; 
		xhr.onreadystatechange = function () {
		
			if (xhr.readyState == xhr.DONE) {
				var reader = new window.FileReader();
 				reader.readAsDataURL(xhr.response);
 				reader.onloadend = function() {
					var base64Data = reader.result;                
					$('#imageRendition').attr('src', base64Data);
					helper.resetAccessToken();
				}
			}
		}	
		
		xhr.send();
	}
	
	helper.generatePdfPreview = function (reqData, exportFlag) {
		var xhr = {};
		helper.showProgressBar();
		var accessToken = reqData.accessToken;
		console.log(accessToken);
		var fileId = reqData.fileInfo.id;
		
		if (window.XMLHttpRequest) {
			xhr = new XMLHttpRequest();
		}
		
		if (exportFlag) {
			xhr.open("GET", "https://www.googleapis.com/drive/v3/files/"+fileId+"/export?mimeType=application/pdf&alt=media&supportsAllDrives=true", true);
		
		} else {
			xhr.open("GET", "https://www.googleapis.com/drive/v3/files/"+fileId+"?alt=media&supportsAllDrives=true", true);
		}
		
		xhr.setRequestHeader('Authorization','Bearer '+accessToken);   
		xhr.responseType = "arraybuffer"; 
		xhr.onreadystatechange = function () {
		
			if (xhr.readyState == xhr.DONE) {
				
				if (typeof PDFViewerApplication !== 'undefined') {
					PDFViewerApplication.open(new Uint8Array(xhr.response)); 
					helper.hideProgressBar();
          			helper.resetAccessToken();
				}
				
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
			
			var reqObj = {
				fileInfo: fileInfo,
				accessToken: accessTokenStr
			};
				
			if (fileInfo.type.indexOf('JPEG') >= 0 || fileInfo.type.indexOf('PNG') >= 0 ||
					fileInfo.type.indexOf('JPG') >= 0 ) {
				helper.generateImagePreview(reqObj);
			
			} else if (fileInfo.type == 'GDOC' || fileInfo.type == 'GSLIDES' || 
					fileInfo.type == 'GSHEET' || fileInfo.type == 'GDRAW') {
				helper.generatePdfPreview(reqObj, true);
				
			} else {
				helper.generatePdfPreview(reqObj, false);
			}
			
		});
		
	}
	
	return module;
    
})(Simpplr, $);

$(document).ready(function() {
	var fileInfoObjStr = document.getElementById('fileInfoId');
	
	if (typeof fileInfoObjStr !== 'undefined' && fileInfoObjStr !== null) {
		fileInfoObjStr = fileInfoObjStr.value;
		fileInfoObj = JSON.parse(fileInfoObjStr);
	}
	
	if (fileInfoObj.provider === 'googledrive') {
		Simpplr.FileDetail.GDModule.generateFilePreview(fileInfoObj);
	}
});
