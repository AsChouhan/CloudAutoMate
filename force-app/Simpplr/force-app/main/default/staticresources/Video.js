Simpplr.Salesforce.Video = Simpplr.Salesforce.Video || {};
Simpplr.Salesforce.Video = (function (Simpplr, $){
	
	var module = {};
    module.getAccessToken = function () {
    	return Simpplr.Salesforce.sendRequest({
          method:'GET',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=VideoDataServer&action=getAccessToken'
     	});
	};

	module.revokeSession = function (session) {
    	return Simpplr.Salesforce.sendRequest({
		  data: {'session' : session},	
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=VideoDataServer&action=revokeSession'
     	});
	};
   
	module.addVideoToCategory = function (data) {
    	return Simpplr.Salesforce.sendRequest({
		  data: {'data' : JSON.stringify(data)},	
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=VideoDataServer&action=addVideoToCategory'
     	});
	};

	module.getVideoReferences = function (data) {
    	return Simpplr.Salesforce.sendRequest({
		  data: {'data' : JSON.stringify(data)},	
      method:'POST',
      endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=VideoDataServer&action=getVideoReferences'
   });
	};

	module.setFavorited  = function (id, setFavoritedBool) {
    	var deferred = $.Deferred();
    	var actionName = "";
    	if(setFavoritedBool){
    		actionName = "bookmark";
    	}else{
    		actionName = "unbookmark";
    	}
    	if (typeof id !== undefined) {
    	
				$.ajax({
					url:    Simpplr.Salesforce.VisualforceEndpoints.ReadWrite +'?target=ToggleBookmarkDataServer',
					method: 'get',
					data : {recordId: id, action:actionName, context: 'native_video'},
					beforeSend: function(xhrObj){
						xhrObj.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
						xhrObj.setRequestHeader("Accept","application/json");
						xhrObj.setRequestHeader("x-simpplr-csrf", __sfdcCsrfToken);
						xhrObj.setRequestHeader("x-http-verb", 'POST');
					}
				}).done(function(data) {
					deferred.resolve(data);
				}).fail(function(xhr, reason, error) {
					deferred.reject();
				});
				
		} else {
			deferred.reject(false);
		}
     	return deferred;
    }

	module.getThumbnail = function (entryId) {
    	return Simpplr.Salesforce.sendRequest({
		  data: {'entryId' : entryId},	
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=VideoDataServer&action=getThumbnail'
     	});
	};

	module.addToFolder = function (siteId, directory,  mediaParams, uploadVideoResponse) {
		var data = {"siteId": siteId, "directory": directory, "mediaParams": mediaParams, "uploadVideoResponse": uploadVideoResponse};
		return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=VideoDataServer&action=addToFolder&siteId=' + siteId
        });
	}

	module.updateVideoStatus = function (entryId, status) {
		var data = {'entryId': entryId, 'status': status};
		return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=VideoDataServer&action=updateVideoStatus'
        });
	}

	module.get = function (id) {
		var data = {'id': id};
		return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=VideoDataServer&action=get'
        });
	}

	module.getCaptionsLanguages = function () {
		return Simpplr.Salesforce.sendRequest({
			method:'GET',
			endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=VideoDataServer&action=getCaptionsLanguages'
		});
	}

	module.syncPeopleData = function () {
		return Simpplr.Salesforce.sendRequest({
			method:'GET',
			endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=VideoDataServer&action=syncPeopleData'
		});
	}

	module.search = function (data) {
		return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(data)},
			method:'GET',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=VideoDataServer&action=search'
		});
	}

	module.getByIds = function (ids) {
		return Simpplr.Salesforce.sendRequest({
			data: {'ids' : JSON.stringify(ids)},
			method:'GET',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=VideoDataServer&action=getByIds'
		});
	}

	module.setLiked = function (fileId, likeState) {
		var deferred = $.Deferred();
		var actionName = "";
		if (likeState) {
			actionName = "like";
		} else {
			actionName = "unlike";
		}
		if (typeof fileId !== "undefined") {

			$.ajax({
				url: Simpplr.Salesforce.VisualforceEndpoints.ReadWrite + "?target=ChatterInteractionDataServer",
				method: "get",
				data: { recordId: fileId, action: actionName, likeType: "file" },
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
	};

	return module;
})(Simpplr, jQuery);

