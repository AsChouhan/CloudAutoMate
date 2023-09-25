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

Simpplr.FileDetail.MSModule = (function (Simpplr, $){
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
		let curr_endpoint = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&action=getEFSAccessToken&provider=sharepoint';
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
		var xhr = {};
		var accessToken = reqData.accessToken;
		var fileId = reqData.fileInfo.id;
		
		if (window.XMLHttpRequest) {
			xhr = new XMLHttpRequest();
		}
		
		xhr.open("POST", "https://graph.microsoft.com/beta/drives/" + driveId + 
				"/items/" + fileId +"/preview", true);
		xhr.setRequestHeader('Authorization','Bearer '+accessToken);        
		xhr.setRequestHeader("Accept", "application/json, text/plain");
		xhr.onreadystatechange = function () {
		
			if (xhr.readyState == xhr.DONE) {
				console.log(xhr.response)
			}
			
		}	
		
		xhr.send();
	}
	
	helper.generatePdfPreview = function (reqData, exportFlag) {
		var xhr = {};
		helper.showProgressBar();
		var accessToken = reqData.accessToken;
		var fileId = reqData.fileInfo.id;
		var driveId = reqData.fileInfo.driveId;
		
		if (window.XMLHttpRequest) {
			xhr = new XMLHttpRequest();
		}
		
		xhr.open("POST", "https://graph.microsoft.com/beta/drives/" + driveId + 
				"/items/" + fileId +"/preview", true);
		
		
		xhr.setRequestHeader('Authorization','Bearer '+accessToken);   
		xhr.setRequestHeader("Accept", "application/json, text/plain");
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
	
	if (fileInfoObj.provider === 'sharepoint' || fileInfoObj.provider === 'onedrive') {
		Simpplr.FileDetail.MSModule.generateFilePreview(fileInfoObj);
	}
});

function checkForBlockedDownload(message){
	var fileInfoObjStr = document.getElementById('fileInfoId');
	if (typeof fileInfoObjStr !== 'undefined' && fileInfoObjStr !== null) {
		fileInfoObjStr = fileInfoObjStr.value;
		fileInfoObj = JSON.parse(fileInfoObjStr);
	}
	var url = fileInfoObj.downloadURL;
	var xhr = new XMLHttpRequest();
	xhr.onreadystatechange = function() {
		if (xhr.readyState === 4) {
			if(xhr.status == 200){
				window.open(url,'_blank');
			}
			else{
				window?.Simpplr?.Flashes?.danger(message,true);
			}
		}
	}
	xhr.open('GET', url, true);
	xhr.send('');
}
