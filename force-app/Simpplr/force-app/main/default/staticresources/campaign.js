Simpplr.Salesforce.Campaign = {

	get :function (campaignId) {
		return Simpplr.Salesforce.sendRequest({
			data: {'campaignId' : campaignId},
			method:'POST',
			endpoint: Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CampaignDataServer&action=get'
		});
	},
  
	search :function (data) {
		return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(data)},
			method:'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CampaignDataServer&action=search'
		});
	},
  
	delete :function (campaignId) {
		return Simpplr.Salesforce.sendRequest({
			data: {'campaignId' : campaignId},
			method:'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CampaignDataServer&action=delete'
		});
	},
	
	setActive :function (campaignId, isActive) {
		return Simpplr.Salesforce.sendRequest({
			data: {'campaignId' : campaignId, 'isActive' : isActive},
			method:'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CampaignDataServer&action=setActive'
		});
	},
	
	save :function (campaignId, data) {
		return Simpplr.Salesforce.sendRequest({
			data: {'campaignId' : campaignId, 'data' : JSON.stringify(data)},
			method:'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CampaignDataServer&action=save'
		});
	},
	
	share :function (campaignId, network, message) {
		var data = {campaignId : campaignId, network : network, message : message};
		return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(data)},
			method:'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CampaignDataServer&action=share'
		});
	},
	
    shareToFeed : function (campaignId, data) {
     	var deferred = $.Deferred();
     	if (typeof data.urlName !== 'undefined' && data.urlName.length >= 255) {
	   		data.urlName = data.urlName.substring(0, 200);
     	}
     	if (typeof data.url !== 'undefined') {
			 data['url'] = data['url'].replace(/\//g, '\\\\/');
		 }
     	
     	if (typeof data !== undefined) {
	     	var requestObj = {
				action:'share',
				campaignId: campaignId,
				subjectId:data['subjectId'],
				Type:data['type'], 
				url:data['url'],
				urlName:data['urlName'],
				textToPost : data['body']
			};
        	
        	return Simpplr.Salesforce.sendRequest({
          		data : requestObj,
          		method : 'POST',
          		endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ChatterInteractionDataServer'
      		});
			
		} else {
			deferred.reject(false);
		}
     	return deferred;
    },	
	
	getShareHistory :function (data) {
		return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(data)},
			method:'GET',
			endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CampaignDataServer&action=getShareHistory'
		});
	}
}