Simpplr.Salesforce.User = Simpplr.Salesforce.User || {};
Simpplr.Salesforce.UserLocation = Simpplr.Salesforce.UserLocation || {};
Simpplr.Salesforce.User = (function (Simpplr, $){
	var module = {};
	 
  	module.search = function (data) {
      	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=peopledataserver&action=search'
  		});
  	},
	
	module.getAllPeopleData = function (data) {
		return Simpplr.Salesforce.sendRequest({
		data: {'data' : JSON.stringify(data)},
		method:'POST',
		endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=peopledataserver&action=getAllPeopleData'
		});
	},

  	module.getPeopleByUserId = function (userId) {
      	return Simpplr.Salesforce.sendRequest({
          data: {'data' : userId},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=peopledataserver&action=getPeopleByUserId&userId='+userId
  		});
	  },
	  
	module.getFieldValues = function (params) {
		return Simpplr.Salesforce.sendRequest({
		data: {'data' : JSON.stringify(params)},
		method:'POST',
		endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=peopledataserver&action=getFieldValues'
	});
	},
  	
  	module.getReportings = function (userId){
		return Simpplr.Salesforce.sendRequest({
	      data: {'sfUserId' : JSON.stringify(userId)},
	      method:'POST',
	      endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=PeopleDataServer&action=orgChart'
		});
	},
	
	module.setFollowing =  function (id, isFollowingBoolean) {
		var deferred = $.Deferred();
        var actionName = "";
        
		if (isFollowingBoolean) {
            actionName = "followUser";
            
		} else {
			actionName = "unfollowUser";
        }
        
        var dataObj =   {
            sfUserId : id
        }      
        
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(dataObj)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ToggleFollowDataServer&action='+actionName
        });
		
    },
    
	module.getEndorsements =function(data){
		return Simpplr.Salesforce.sendRequest({
          data: {'sfUserId' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=peopledataserver&action=getEndorsements'
  		});
	},
	
	module.removeEndorsement=function(userId, expertiseId){
		var data={ sfUserId:userId, expertiseId:expertiseId };
		return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=peopledataserver&action=removeEndorsement'
  		});
	},
	
	module.removeExpertise=function(userId, expertiseId){
		var data={ sfUserId:userId,expertiseId:expertiseId };
		return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=peopledataserver&action=removeExpertise'
  		});
	},
	
	module.addEndorsement =function (userId, expertiseId){
		var data={sfUserId:userId, expertiseId:expertiseId};
		return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=peopledataserver&action=addEndorsement'
  		});
	},
	
	module.setFavorited = function (id, setFavoritedBool) {
		var actionName = "";
		if(setFavoritedBool){
			actionName = "favoritepeople";
		}else{
			actionName = "unfavoritepeople";
		}
		return Simpplr.Salesforce.sendRequest({
	    	data : {peopleId : id},
	      	method : 'POST',
	      	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ToggleBookmarkDataServer&action='+actionName
		});
	},
	
	module.getGoogleCalendars = function () {
		return Simpplr.Salesforce.sendRequest({
	      	method : 'GET',
	      	endpoint : Simpplr.Salesforce.Endpoints.ReadOnly +'?target=peopledataserver&action=getGoogleCalendars'
		});
	},

	module.getCustomFields = function () {
		return Simpplr.Salesforce.sendRequest({
	      	method : 'GET',
	      	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=peopledataserver&action=getCustomFields'
		});
	},
	
	module.connectApp = function (appName, retURL) {
		var requestObj = {appName: appName, retURL: retURL};
		return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(requestObj)},
	      	method : 'POST',
	      	endpoint : Simpplr.Salesforce.Endpoints.ReadOnly +'?target=peopledataserver&action=connectApp'
		});
	},
	
	module.getRedirectUrl = function (appName, retURL) {
		var requestObj = {appName: appName, retURL: retURL};
		return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(requestObj)},
	      	method : 'POST',
	      	endpoint : Simpplr.Salesforce.Endpoints.ReadOnly +'?target=peopledataserver&action=getRedirectUrl'
		});
	},	
	 
	module.disconnectApp = function (appName) {
		var requestObj = {appName: appName};
		return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(requestObj)},
	      	method : 'POST',
	      	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=peopledataserver&action=disconnectApp'
		});
	},		
	
	module.getFollowStats = function (peopleId){
		var data={peopleId:peopleId};
		return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=peopledataserver&action=getFollowStats'
  		});
	},
	
	module.get = function (peopleId, sfUserId, includeCustomFields,includeHiddenProfileFields){
		var data={peopleId:peopleId, sfUserId : sfUserId, includeCustomFields:includeCustomFields,includeHiddenProfileFields:includeHiddenProfileFields};
		return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=peopledataserver&action=getUser'
  		});
	},
	
	module.setCoverImage = function(peopleId, file){
        return Simpplr.Salesforce.sendRequest({
          data: {'peopleId': peopleId, 'file': JSON.stringify(file)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=PeopleDataServer&action=setCoverImage'
        });
	},
	
	module.setProfileImage = function(peopleId, fileObj){
        
        var requestObj = {
        	action : fileObj != null ? 'setprofilephoto' : 'removeprofilephoto',
        	fileId : fileObj != null ? fileObj.contentDocumentId : null,
			communityId : null,
			versionNumber: null,
			peopleId : peopleId 
		};
		
  		return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(requestObj)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ConnectAPIInteractionDataServer'
        });
	},
	
	module.getOrgChart = function(data) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(data)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=peopledataserver&action=getOrgChart'
      	});
	},
	module.getOrgChartOnProfile = function(data) {
		return Simpplr.Salesforce.sendRequest({
        	data: {'data' : JSON.stringify(data)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=peopledataserver&action=getOrgChartOnProfile'
      	});
	},
	
	module.getUserWebpushTokens = function() {
		return Simpplr.Salesforce.sendRequest({
			method : 'GET',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=peopledataserver&action=getUserWebpushTokens'
		});
	},

	module.getByIds = function (listOfUserId) {
        return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(listOfUserId)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=peopledataserver&action=getByIds'
      	});
    }, 

	module.getCount = function (data) {
        return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(data)},
          	method:'GET',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=peopledataserver&action=getCount'
      	});
    }

	return module;
})(Simpplr, jQuery);

Simpplr.Salesforce.UserLocation = (function (Simpplr, $){
	var module = {};
	
	module.search = function (data) {
      	return Simpplr.Salesforce.sendRequest({
      	 data: {'data' : JSON.stringify(data)},
          method:'GET',
          endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=peopledataserver&action=searchLocation'
  		});
  	},
  	
  	module.get = function (locationId) {
      	return Simpplr.Salesforce.sendRequest({
      	 data: {'locationId' : locationId},
          method:'GET',
          endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=peopledataserver&action=getLocation'
  		});
  	} 
	return module;
})(Simpplr, jQuery);

Simpplr.Salesforce.UserDepartment = (function (Simpplr, $){
	var module = {};
	
	module.search = function (data) {
      	return Simpplr.Salesforce.sendRequest({
      	 data: {'data' : JSON.stringify(data)},
          method:'GET',
          endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=peopledataserver&action=searchDepartment'
  		});
  	}
  	return module;
})(Simpplr, jQuery);