Simpplr.Salesforce.Site = Simpplr.Salesforce.Site || {};
Simpplr.Salesforce.Site = (function (Simpplr, $){
	var module = {};
	
	var resultStrucutureObj = {
                    "status": "success",
                    "message": null,
                    "i18nmessage": null,
                    "result": {
                        "id": "",
                        "contentVersionId": "",
                        "contentDocumentId" : "",
                    }
                };
                
	var convertoToResultStructure = function (resultObj) {
        var newObj = $.extend(true, {}, resultStrucutureObj);
        newObj.result.id = resultObj.contentDocumentId;
        newObj.result.contentVersionId = resultObj.id;
        newObj.result.contentDocumentId = resultObj.contentDocumentId;
        
        return newObj;
    }
    
	module.get = function (siteId, chatterGroupId) {
		return Simpplr.Salesforce.sendRequest({
			data: {'siteId' : siteId, 'chatterGroupId' : chatterGroupId},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteDataServer&action=getsiteDetailData'
      	}); 
	};
	
	/* TODO: please pass siteId in url param as above method*/
	module.search = function (data) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(data)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SiteDataServer&action=search'
      	});
	};
	
	module.getMembers = function (data) {

		return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=peopledataserver&action=search'
  		});
		
	};

	module.getPeople = function (data) {

		return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=peopledataserver&action=search'
  		});
		
	};

	module.setPeoplePermission = function (siteId, userId, permission) {
  	  	var data = {"siteId":siteId,"sfUserId":userId,"permission":permission, "provider":""};
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(data)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ManageSiteDataServer&action=setPeoplePermission&siteId='+siteId
  	  	});
		
	};
	
	module.setFollowing =  function (id, isFollowingBoolean) {
		var toggleFollowEndPoint = Simpplr.Salesforce.VisualforceEndpoints.ReadWrite +'?target=ToggleFollowDataServer';
		var deferred = new $.Deferred();
		var actionName = "";
		if(isFollowingBoolean){
			actionName = "followSite";
		}else{
			actionName = "unfollowSite";
		}
		$.ajax({
			url:    toggleFollowEndPoint,
			method: 'get',
			data:   {
						siteId : id,
						action :actionName
					},
			beforeSend: function(xhrObj){
				xhrObj.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
				xhrObj.setRequestHeader("Accept","application/json");
				xhrObj.setRequestHeader("x-simpplr-csrf", __sfdcCsrfToken);
				xhrObj.setRequestHeader("x-http-verb", 'POST');
			}
		}).done(function(data) {
			if ('success' === data.status) {
				deferred.resolve(data);
			} else {
				deferred.reject(data);
			}
		});
		
		return deferred;
	}
	
	module.setFavorited = function (id, setFavoritedBool) {
		var actionName = "";
		if(setFavoritedBool){
			actionName = "addfavorite";
		}else{
			actionName = "removefavorite";
		}
		
		return Simpplr.Salesforce.sendRequest({
            data: {siteId : id, action :actionName},
            method: 'GET',
            endpoint: Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ToggleBookmarkDataServer'
        });
	}
	
	module.save =  function (siteId, data) {
		if(siteId == null) {
			return Simpplr.Salesforce.sendRequest({
	            data: {'data' : JSON.stringify(data)},
	            method:'POST',
	            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteDataServer&action=createSite'
	        });
        } else {
        	return Simpplr.Salesforce.sendRequest({
	            data: {'data' : JSON.stringify(data)},
	            method:'POST',
	            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ManageSiteDataServer&action=saveSiteDetail&siteId=' + siteId
	        });
        }
	}
	
	module.setImage = function(siteId, imageFile){
        return Simpplr.Salesforce.sendRequest({
          data: {'siteId': siteId, 'imageFile': JSON.stringify(imageFile)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteDataServer&action=setImage'
        });
	},
	
	module.rejectMembershipRequest = function(requestId, siteType){
		var data={requestId: requestId,siteType:siteType};
        return Simpplr.Salesforce.sendRequest({
          data: {'data': JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteDataServer&action=rejectMembershipRequest'
        });
	},
	module.approveMembershipRequest = function(requestId, siteType){
		var data={requestId: requestId, siteType:siteType};
		return Simpplr.Salesforce.sendRequest({
          data: {'data': JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteDataServer&action=approveMembershipRequest'
        });
	}, 
	
	module.setCoverImage = function(siteId, imageFile){
        return Simpplr.Salesforce.sendRequest({
          data: {'siteId': siteId, 'imageFile': JSON.stringify(imageFile)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteDataServer&action=setCoverImage'
        });
	},	
	module.getPeopleStats = function(siteId, term){
		var data={siteId: siteId, term: term};
        return Simpplr.Salesforce.sendRequest({
          data: {'data': JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteDataServer&action=getPeopleStats'
        });
	},

	module.setFeatured = function(segmentId, listOfSiteIds, makeFeaturedBool) {
		var data={segmentId: segmentId, listOfSiteIds: listOfSiteIds, makeFeaturedBool:makeFeaturedBool};
		return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteDataServer&action=setFeatured'
     	 });
	};

	module.setPrivate = function(idsArray, makePrivateBool) {
		var data={idsArray:idsArray,makePrivateBool:makePrivateBool};
		return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteDataServer&action=setPrivate'
      	});
	};
	
	module.setActivated = function(idsArray, makeActivatedBool) {
		var data={idsArray:idsArray,makeActivatedBool:makeActivatedBool};
		return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteDataServer&action=setActivated'
      	});
	};
	
	module.setCategory = function(idsArray, categoryObj) {
		var data={idsArray:idsArray,categoryObj:categoryObj};
		return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteDataServer&action=setCategory'
      	});
		
	};
	
	module.arrangeFeaturedSites = function(segmentId, IdsArray) {
		var data={segmentId:segmentId,IdsArray:IdsArray};
		return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteDataServer&action=arrangeFeaturedSites'
      	});
		
	};
	
	module.request = function(Id) {
		return Simpplr.Salesforce.sendRequest({
		  data: {'data' : Id},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteDataServer&action=request'
      	});
	};
	module.getFollowRequest = function (requestIdArg, notificationId) {
        return Simpplr.Salesforce.sendRequest({
            data : {
					type : 'privateSiteAccess',
					requestId :requestIdArg,
					action: 'Get'
			},
            method:'POST',
            endpoint: Simpplr.Salesforce.Endpoints.ReadWrite +'?target=RequestApprovalDataServer'
        });
	};
	
	module.approveFollowRequest = function (requestIdArg, notificationId) {
        return Simpplr.Salesforce.sendRequest({
            data : {
					type : 'privateSiteAccess',
					requestId :requestIdArg,
					action: 'Approve'
			},
            method:'POST',
            endpoint: Simpplr.Salesforce.Endpoints.ReadWrite +'?target=RequestApprovalDataServer'
        });
    };
    
    module.rejectFollowRequest = function (requestIdArg, notificationId) {
        return Simpplr.Salesforce.sendRequest({
            data: {
					type : 'privateSiteAccess',
					requestId :requestIdArg,
					action: 'Reject'
			},
            method:'POST',
            endpoint: Simpplr.Salesforce.Endpoints.ReadWrite +'?target=RequestApprovalDataServer'
        });
    };
    
    
    module.removeMember = function (siteId, userId, provider) {
  	  	var data = {"siteId":siteId,"sfUserId":userId, "provider": provider};
      	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ManageSiteDataServer&action=removeMember&siteId='+siteId
  	  });
  	};
	  
	module.removePeople = function (siteId, userId) {
		var data = {"siteId":siteId,"sfUserId":userId};
	  	return Simpplr.Salesforce.sendRequest({
	  		data: {'data' : JSON.stringify(data)},
	  		method:'POST',
	  		endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ManageSiteDataServer&action=removePeople&siteId='+siteId
		});
  	};

  	module.addMember = function (siteId, arrayOfUserIds, provider) {
  	  var data = {"siteId":siteId,"sfUserIds":arrayOfUserIds, "provider": provider};
      return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ManageSiteDataServer&action=addMember&siteId='+siteId
  	  });
  	};
	  
	module.addPeople = function (siteId, arrayOfUserDetail) {
  	  var data = {"siteId":siteId,"userDetail":arrayOfUserDetail};
      return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ManageSiteDataServer&action=addPeople&siteId='+siteId
  	  });
  	};

  	module.revertToChatterGroup = function (siteId) {
		var data = {'siteId':siteId};
		return Simpplr.Salesforce.sendRequest({
			data: {'siteId' : siteId},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteDataServer&action=revertToChatterGroup'
      	});
	};
	
  	module.approveSubscription = function (siteId, subscriptionId) {
		return Simpplr.Salesforce.sendRequest({
			data: {'siteId' : siteId, 'subscriptionId' : subscriptionId},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteDataServer&action=approveSubscription'
      	});
	};	
	
  	module.rejectSubscription = function (siteId, subscriptionId) {
		return Simpplr.Salesforce.sendRequest({
			data: {'siteId' : siteId, 'subscriptionId' : subscriptionId},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteDataServer&action=rejectSubscription'
      	});
	};	
	
     module.disconnectApp = function (siteId, appName) {
        return Simpplr.Salesforce.sendRequest({
            data: {'siteId' : siteId, 'appName' : appName},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ManageSiteDataServer&action=disconnectApp&siteId=' + siteId
        });
	}; 	
	
	module.getExternalAppsSettings = function (data) {
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ManageSiteDataServer&action=getExternalAppsSettings&siteId=' + data.siteId
        });
	};
	
	module.saveSiteExternalAppsConfig = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ManageSiteDataServer&action=saveSiteExternalAppsConfig&siteId=' + data.siteId
        });
	};

	module.getByIds = function (listOfSiteId, includeMemberFollowerCount) {
        return Simpplr.Salesforce.sendRequest({
			data: {'listOfSiteId' : JSON.stringify(listOfSiteId), 'includeMemberFollowerCount' : includeMemberFollowerCount},			
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SiteDataServer&action=getByIds'
      	});
    }

	module.createDuplicate = function (siteId, shouldCopyDashboard, shouldCopyPageCategories) {
		return Simpplr.Salesforce.sendRequest({
			data: {"data": JSON.stringify({"siteId": siteId, "shouldCopyDashboard": shouldCopyDashboard, "shouldCopyPageCategories": shouldCopyPageCategories})},
			method: 'POST',
			endpoint: Simpplr.Salesforce.Endpoints.ReadWrite + "?target=SiteDataServer&action=createDuplicate"
		});
	};

	module.transferAccount = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +"?target=ManageSiteDataServer&action=transferAccount"
        });
	};
    
	return module;
})(Simpplr, jQuery);