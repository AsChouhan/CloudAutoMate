Simpplr.Salesforce.MicrosoftTeams =  (function(Simpplr, $){

	var module = {};
	
	module.getJoinedTeams = function () {
      	return Simpplr.Salesforce.sendRequest({
          	data : {'data' : ''},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=MicrosoftTeamsDataServer&action=getJoinedTeams'
      	});
  	}

    module.getJoinedChannels = function (teamId) {
        var requestObj = {
            teamId : teamId
        };
        return Simpplr.Salesforce.sendRequest({
            data : {'data' : JSON.stringify(requestObj)},
            method : 'POST',
            endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=MicrosoftTeamsDataServer&action=getJoinedChannels'
        });
    }
  	
  	module.shareContent = function (teamId, channelId, contentUrl, message) {
        var requestObj = {
            teamId : teamId,
            channelId : channelId,
            contentUrl : contentUrl,
            message : message
        };
      	return Simpplr.Salesforce.sendRequest({
          	data : {'data' : JSON.stringify(requestObj)},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=MicrosoftTeamsDataServer&action=shareContent'
      	});
  	}
  	 
  	return module;
	
})(Simpplr, jQuery);