if (typeof Simpplr !== 'undefined') {
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
} 

Simpplr.FileDetail.SFModule = (function (Simpplr, $){ 
	var module = {};
		
		module.generateFilePreview = function (fileInfo) {
			if (fileInfo.size < 3000000) { 
				let curr_endpoint = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FilePreviewDataServer&fileId=' + fileInfo.id;
				$.ajax({
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
				}).done(function(data) {
					var base64Data = data.result.substring(data.result.indexOf(',') + 1, data.result.length)
					var binary_string =  window.atob(base64Data);
				    var len = binary_string.length;
				    var bytes = new Uint8Array( len );
				    
				    for (var i = 0; i < len; i++)        {
				        bytes[i] = binary_string.charCodeAt(i);
				    }
				    
					PDFViewerApplication.open(bytes.buffer);
				});
		        
			} 
			
		}
	return module;
})(Simpplr, $);

$(document).ready(function() {
	var fileInfoObjStr = document.getElementById('fileInfoId');
	
	if (typeof fileInfoObjStr !== 'undefined' && fileInfoObjStr !== null) {
		fileInfoObjStr = fileInfoObjStr.value;
		fileInfoObj = JSON.parse(fileInfoObjStr);
	}
	
	if ((fileInfoObj.provider === 'intranet' || fileInfoObj.provider === 'crm') && fileInfoObj.type == 'PDF') {
		Simpplr.FileDetail.SFModule.generateFilePreview(fileInfoObj);
	}
});