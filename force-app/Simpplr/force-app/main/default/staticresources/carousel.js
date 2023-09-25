Simpplr.Salesforce.Carousel = {

  get :function (data) { 
  	var payLoad = {"siteId": data.siteId, "segmentId": data.segmentId};
  	return Simpplr.Salesforce.sendRequest({
        data: {'data' : JSON.stringify(payLoad)},
        method:'POST',
        endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CarouselDataServer&action=get'
    });
  },
  
  setState :function (data, layout) {
  	return Simpplr.Salesforce.sendRequest({
        data: {'data' : JSON.stringify(data)},
        method:'POST',
        endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CarouselDataServer&action=setLayout'
    });
  },
  
  saveOrder :function (data, orderOfItemIds) {
	  	var data = {"siteId": data.siteId, "segmentId": data.segmentId, "orderOfItemIds": JSON.stringify(orderOfItemIds)};
	  	return Simpplr.Salesforce.sendRequest({
	        data: {'data' : JSON.stringify(data)},
	        method:'POST',
	        endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CarouselDataServer&action=saveOrder'
	    });
	  },
  
  removeItem :function (data, carouselItemId) {
  	var payLoad = {"siteId": data.siteId, "segmentId": data.segmentId, "carouselItemId": carouselItemId};
  	return Simpplr.Salesforce.sendRequest({
        data: {'data' : JSON.stringify(payLoad)},
        method:'POST',
        endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CarouselDataServer&action=removeItem'
    });
  },
  
  removeCampaignItem :function (data, campaignId) {
	  	var payLoad = {"siteId": data.siteId, "segmentId": data.segmentId, "campaignId": campaignId};
	  	return Simpplr.Salesforce.sendRequest({
	        data: {'data' : JSON.stringify(payLoad)},
	        method:'POST',
	        endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CarouselDataServer&action=removeCampaignItem'
	    });
	  },
  
  removeContentItem :function (data, contentId) {
  	var data = {"siteId": data.siteId, "segmentId": data.segmentId, "isInAllSegments": data.isInAllSegments, "contentId": contentId};
  	return Simpplr.Salesforce.sendRequest({
        data: {'data' : JSON.stringify(data)},
        method:'POST',
        endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CarouselDataServer&action=removeContentItem'
    });
  },
  
  addItem :function (data, type, dataModel) {
  	var payLoad = {"siteId": data.siteId, "segmentId": data.segmentId, "isInAllSegments": data.isInAllSegments, "type": type, "model": JSON.stringify(dataModel)};
  	return Simpplr.Salesforce.sendRequest({
        data: {'data' : JSON.stringify(payLoad)},
        method:'POST',
        endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CarouselDataServer&action=addItem'
    });
  },
	getAnalytics : function() {
		return Simpplr.Salesforce.sendRequest({
        method:'GET',
        endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CarouselDataServer&action=getAnalytics'
    });
	},
}