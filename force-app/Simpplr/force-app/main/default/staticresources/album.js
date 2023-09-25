Simpplr.Salesforce.Album =  (function(Simpplr, $){
	var module = {};
	var SFDC = {}; 
   	SFDC.File = {};
   	SFDC.File.mapOfDeferred = {};
   	var resultDefObj = {};
   	
  	module.search = function (data) {
	  	var endPoint = Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AlbumDataServer&action=search';
	  	if(data.siteId !== undefined) {
	  		endPoint += '&siteId='+data.siteId;
	  	}
      	return Simpplr.Salesforce.sendRequest({
          	data : {'data' : JSON.stringify(data)},
          	method : 'GET',
          	endpoint : endPoint
      	});
  	}
  	
  	module.uploadPhoto = function(albumId, data) {
  		sforce.connection.sessionId = Simpplr.CurrentUser.sessionId;
        SFDC.File.albumId = albumId;
        var dateObj = new Date();
    	var token = 'simp_cont_album#'+Simpplr.Settings.SITE_ID+'#' + dateObj.getTime() + data.title;
    	
        var base64value = data.base64;
        var contentObj= new sforce.SObject("ContentVersion");
        contentObj.versionData = base64value; 
        contentObj.title = data.title; 
        contentObj.Origin = 'H';
        contentObj.pathOnClient = token;
        SFDC.File.mapOfDeferred[token] = $.Deferred();
       	
        resultDefObj =  SFDC.File.mapOfDeferred[token].then(function(data) {
      		return data;
        });
        
        
        sforce.connection.create([contentObj], {onSuccess : SFDC.File.objectSaveSuccess,
	    		onFailure : SFDC.File.objectSaveFailed, 
	    		onProgress : function (evt) { 
	    			var loaded = (evt.loaded/evt.total)*100;
	                SFDC.File.Deferred.notify(loaded);
	            }
	    }); 
	    
	    return resultDefObj;
  	}
  	
  	SFDC.File.objectSaveSuccess = function (result) {
  		Simpplr.Salesforce.log('Album.objectSaveSuccess---result---'+ JSON.stringify(result));
        if (result[0].getBoolean("success")) {
           	var queryResult = sforce.connection.query("SELECT Id, Title, PathOnClient, ContentDocumentId,PublishStatus FROM ContentVersion WHERE Id="+"'"+result[0].id+"'"+"");
			records = queryResult.getArray("records");
            
            for (var i = 0; i< records.length; i++) {
				var token = records[i].PathOnClient;
                var requestObj = {
                	id : SFDC.File.albumId,
                    fileContentVersionId : records[i].Id,
                    fileContentDocId : records[i].ContentDocumentId,
                    fileDescription : records[i].Title
				} 
           	}
           	
           	var request = {
				data: {'data' : JSON.stringify(requestObj)},
			  	method:'POST',
			  	endpoint:Simpplr.Salesforce.VisualforceEndpoints.ReadWrite +'?target=SiteAddAlbumDataServer&action=addPhoto' 
			};
			
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
	               SFDC.File.mapOfDeferred[token].resolve(response);
	               
	            } else {
	                SFDC.File.mapOfDeferred[token].reject();
	            }
	            
	        }).fail(function() {
	           SFDC.File.Deferred.reject();
	        }); 
		
        }
      }
    
    SFDC.File.objectSaveFailed = function () {
        SFDC.File.data = {}; 
    	var Deferred = $.Deferred();
		Deferred.reject();
    }
  	
  	module.addVideo = function(albumId, data) {
  		var requestObj = {
  			videoUrl: data.url,
  			id: albumId,
  			videoProvider: data.provider,
  			videoId: data.id,
			size: data.size
  		};
  		
  		if (typeof data.thumbnailImg !== 'undefined') {
  			requestObj.videoThumbsnailImg = data.thumbnailImg;
		}
		if(typeof data.title !== 'undefined') {
			requestObj.videoTitle = data.title;			
		}
		
  		return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(requestObj)},
		  	method: 'POST',
		  	endpoint: Simpplr.Salesforce.Endpoints.ReadWrite + '?target=SiteAddAlbumDataServer&action=addVideo'
		}); 
			
  	}
  	
  	module.submitMedia = function (albumIdArg,albumMediaListArg) {
  		var requestObj = {
  			albumMediaList : albumMediaListArg,
  			albumId : albumIdArg
  		};
  		var respo = Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(requestObj)},
		  	method:'POST',
		  	endpoint: Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteAddAlbumDataServer&action=submitMedia'

		}); 
		return respo;
  	}
  	
  	module.getMedia = function(data) {
		return Simpplr.Salesforce.sendRequest({
          	data : {'data' : JSON.stringify(data)},
          	method : 'GET',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FileDataServer&action=getMedia'
      	});
			
	}
	
	module.setMediaLiked = function(fileID, setLikedBool) {
	
		if(setLikedBool){
			actionName = "like";
		}else{
			actionName = "unlike";
		}
		return Simpplr.Salesforce.sendRequest({
          	data : {recordId: fileID, action:actionName, likeType: 'media'},
          	method : 'GET',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ChatterInteractionDataServer'
      	});
			
	}
  	
  	return module; 
})(Simpplr, jQuery);