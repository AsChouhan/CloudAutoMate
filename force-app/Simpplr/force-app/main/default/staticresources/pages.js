Simpplr.Salesforce.Page = {
  search :function (data) {
  	var endPoint = Simpplr.Salesforce.Endpoints.ReadOnly +'?target=PageDataServer&action=search';
  	if(data.siteId !== undefined) {
  		endPoint += '&siteId='+data.siteId;
  	}
  	return Simpplr.Salesforce.sendRequest({
      data: {'data' : JSON.stringify(data)},
      method:'POST',
      endpoint: endPoint
  	});
  },
  updateCategoryPosition :function (siteId, categoryIds) {
  	var data = {'siteId':siteId, 'categoryIds':categoryIds};
  	Simpplr.Salesforce.log('Page.updateCategoryPosition---data---'+ JSON.stringify(data));
    return Simpplr.Salesforce.sendRequest({
        data: {'data' : JSON.stringify(data)},
        method:'POST',
        endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CategoryDataServer&action=updateCategoryPosition&siteId='+siteId
    });
  },
  
  updatePagePosition : function(siteId, categoryId, pageIdsArray){
  	var data = {'siteId':siteId, 'categoryId':categoryId, 'pageIdsArray':pageIdsArray};
  	Simpplr.Salesforce.log('Page.updatePagePosition---data---'+ JSON.stringify(data));
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data' : JSON.stringify(data)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteAddPageDataServer&action=updatePagePosition&siteId='+siteId
	});
  },
  
  moveToTop : function(siteId, categoryId, pageId){
  	var data = {'siteId':siteId, 'categoryId':categoryId,'pageId':pageId};
  	Simpplr.Salesforce.log('Page.moveToTop---data---'+ JSON.stringify(data));
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data' : JSON.stringify(data)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteAddPageDataServer&action=moveToTop&siteId='+siteId
	});
  },
  moveToBottom : function(siteId, categoryId, pageId){
  	var data = {'siteId':siteId, 'categoryId':categoryId,'pageId':pageId};
  	Simpplr.Salesforce.log('Page.moveToBottom---data---'+ JSON.stringify(data));
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data' : JSON.stringify(data)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteAddPageDataServer&action=moveToBottom&siteId='+siteId
	});
  }
}