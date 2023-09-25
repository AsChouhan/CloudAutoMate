Simpplr = Simpplr || {};
Simpplr.Salesforce = Simpplr.Salesforce || {};
Simpplr.Salesforce = {
	Endpoints :{ 
		ReadOnly: __isApexRestEnabled ? (__packageVersion==="unmanaged") ? "/services/apexrest/DataServerRO":"/services/apexrest/Simpplr/DataServerRO" : "/apex/DataServerRO",
		ReadWrite:__isApexRestEnabled ? (__packageVersion==="unmanaged") ? "/services/apexrest/DataServerRW":"/services/apexrest/Simpplr/DataServerRW" : "/apex/DataServerRW"
	},
	RestEndpoints :{ 
		ReadOnly: __salesforceOrgDomainUrl + ((__packageVersion==="unmanaged") ? "/services/apexrest/DataServerRO": "/services/apexrest/Simpplr/DataServerRO"),
		ReadWrite: __salesforceOrgDomainUrl + ((__packageVersion==="unmanaged") ? "/services/apexrest/DataServerRW": "/services/apexrest/Simpplr/DataServerRW")
	},
	VisualforceEndpoints :{ 
		ReadOnly: "/apex/DataServerRO",
		ReadWrite: "/apex/DataServerRW"
	},
	Links:{
		FileDetail: "/apex/FileDetail"		
	},
	
    sendRequest : function(request, def){
		var d = def || $.Deferred();
        $.ajax({
            type: request.method,
            url: request.endpoint,
            data : request.data,
            beforeSend: function(xhrObj){
				if (request.endpoint.includes("/services/apexrest/")) {
					xhrObj.setRequestHeader('Authorization', 'Bearer '  + __sfdcSessionId);

				} else {
					xhrObj.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
					xhrObj.setRequestHeader("Accept","application/json");
					xhrObj.setRequestHeader("x-simpplr-csrf", __sfdcCsrfToken);
					xhrObj.setRequestHeader("x-http-verb", request.method);
				}
				
            }
        }).done(function(response) {
            if (response != undefined && 'success' === (response.status || '').toLowerCase()) {
                d.resolve(response);
            } else {
            	if (typeof response.message !== "undefined") {
            		
            		if(response.message.indexOf('STORAGE_LIMIT_EXCEEDED')>=0){
            			response.message = "Unable to perform action - storage full";
            		}
            		
            		d.reject(response);
            	} else {
                	d.reject(response);
                }
            }
            
        }).fail(function(exceptionData) {
        	if (typeof exceptionData.responseJSON !== 'undefined' && 
				typeof exceptionData.responseJSON[0].errorCode !== 'undefined' &&  
				exceptionData.responseJSON[0].errorCode === 'REQUEST_LIMIT_EXCEEDED') {

				__isApexRestEnabled  = false; 
				Simpplr.Salesforce.Endpoints = { 
					ReadOnly: "/apex/DataServerRO",
					ReadWrite: "/apex/DataServerRW"
				}

				if(request.endpoint.includes('DataServerRW')){ request.endpoint = Simpplr.Salesforce.Endpoints.ReadWrite + request.endpoint.substr(request.endpoint.indexOf('?'));}
				if(request.endpoint.includes('DataServerRO')){ request.endpoint = Simpplr.Salesforce.Endpoints.ReadOnly + request.endpoint.substr(request.endpoint.indexOf('?'));}

				Simpplr.Salesforce.sendRequest(request, d);
			}else{

				var exceptionResultObj = {
					"status": "error",
					"message": null,
					"i18nmessage": null,
					"result": null
				};

				if(__isApexRestEnabled){
					exceptionResultObj.result  = exceptionData.responseText;
				}
				
				if (typeof exceptionData !== 'undefined' && typeof exceptionData.responseText !== 'undefined') {
					var errorStr = exceptionData.responseText;
					var indexOfErrorMsg = errorStr.indexOf('id="theErrorPage:theError"');
					
					if (errorStr.indexOf('<html') >= 0 && errorStr.indexOf('</html>') >= 0){
						
						if (indexOfErrorMsg >= 0) { 
							var processStr = ''
							processStr = errorStr.substring(indexOfErrorMsg, errorStr.length);
							processStr = processStr.substring(processStr.indexOf('>') + 1, processStr.indexOf('</span>'));
							Simpplr.Salesforce.log(processStr);
							exceptionResultObj.message = processStr;
							exceptionResultObj.i18nmessage = processStr;
						
						} else if (errorStr.indexOf('/visualforce/session') >= 0) {
							exceptionResultObj.message = "SESSION_TIMEOUT";
							exceptionResultObj.i18nmessage = "SESSION_TIMEOUT";
						}
						
					}
					
				}
				
				d.reject(exceptionResultObj);
			}
        	
        });
        
        return d;
        
    },

	sendVisualforceRequest : function(request, def){
        var d = def || $.Deferred();
        $.ajax({
            type: request.method,
            url: request.endpoint,
            data : request.data,
            beforeSend: function(xhrObj){
				xhrObj.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
				xhrObj.setRequestHeader("Accept","application/json");
				xhrObj.setRequestHeader("x-simpplr-csrf", __sfdcCsrfToken);
				xhrObj.setRequestHeader("x-http-verb", request.method);	
            }
        }).done(function(response) {

            if (response != undefined && 'success' === (response.status || '').toLowerCase()) {
                d.resolve(response);
            
            } else {
            	
            	if (typeof response.message !== "undefined") {
            		
            		if(response.message.indexOf('STORAGE_LIMIT_EXCEEDED')>=0){
            			response.message = "Unable to perform action - storage full";
            		}
            		
            		d.reject(response);
            	} else {
                	d.reject(response);
                }
            }
            
        }).fail(function(exceptionData) {
        	
        	var exceptionResultObj = {
                "status": "error",
                "message": null,
                "i18nmessage": null,
                "result": null
	        };
	        
        	if (typeof exceptionData !== 'undefined' && typeof exceptionData.responseText !== 'undefined') {
        		var errorStr = exceptionData.responseText;
        		var indexOfErrorMsg = errorStr.indexOf('id="theErrorPage:theError"');
        		
        		if (errorStr.indexOf('<html') >= 0 && errorStr.indexOf('</html>') >= 0){
        			
        			if (indexOfErrorMsg >= 0) { 
        				var processStr = ''
        				processStr = errorStr.substring(indexOfErrorMsg, errorStr.length);
        				processStr = processStr.substring(processStr.indexOf('>') + 1, processStr.indexOf('</span>'));
        				Simpplr.Salesforce.log(processStr);
        				exceptionResultObj.message = processStr;
        				exceptionResultObj.i18nmessage = processStr;
        			
        			} else if (errorStr.indexOf('/visualforce/session') >= 0) {
        				exceptionResultObj.message = "SESSION_TIMEOUT";
        				exceptionResultObj.i18nmessage = "SESSION_TIMEOUT";
        			}
        			
        		}
        		
        	}
        	
        	d.reject(exceptionResultObj);
        });
        
        return d;
        
    },

	sendApexRestRequest : function(request){
        var d = $.Deferred();
        $.ajax({
            type: request.method,
            url: request.endpoint,
            data : request.data,
            beforeSend: function(xhrObj){
					xhrObj.setRequestHeader('Authorization', 'Bearer '  + __sfdcSessionId);
            }
        }).done(function(response) {
            if (response != undefined && 'success' === (response.status || '').toLowerCase()) {
                d.resolve(response);
            } else {
				d.reject(response);
            }
            
        }).fail(function(exceptionData) {
			if (typeof exceptionData.responseJSON !== 'undefined' && 
				typeof exceptionData.responseJSON[0].errorCode !== 'undefined' &&  
				exceptionData.responseJSON[0].errorCode === 'REQUEST_LIMIT_EXCEEDED') {
				
				
				if(request.endpoint.includes('DataServerRW')){ request.endpoint = Simpplr.Salesforce.VisualforceEndpoints.ReadWrite + request.endpoint.substr(request.endpoint.indexOf('?'));}
				if(request.endpoint.includes('DataServerRO')){ request.endpoint = Simpplr.Salesforce.VisualforceEndpoints.ReadOnly + request.endpoint.substr(request.endpoint.indexOf('?'));}

				Simpplr.Salesforce.sendVisualforceRequest(request, d);

			}else{

				var exceptionResultObj = {
					"status": "error",
					"message": "Could not perform action",
					"i18nmessage": null,
					"result": exceptionData.responseText
				};
				
				d.reject(exceptionResultObj);
			}

        });
        
        return d;
        
    },

    setQueryParamToForm : function(){
        $.each($.QueryString,function(key,value){
          $("[name="+key+"]").val(value);
        });
    },
    
    rejectAjaxcall : function () {
    	var deferred = $.Deferred();
    	deferred.reject('Invalid parameters passed to method.');
    	return deferred;
    },
    
    log : function () {
		if (Simpplr.Settings.isJsDebugEnabled) {
	    	console.log.apply(console, arguments);
    	}
	}
}


