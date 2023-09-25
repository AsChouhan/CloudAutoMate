Simpplr.Salesforce.SiteCategory = Simpplr.Salesforce.SiteCategory || {};
Simpplr.Salesforce.SiteCategory = {
  get :function (categoryId) {
  	return Simpplr.Salesforce.sendRequest({
        data: {'data' : JSON.stringify({'categoryId': categoryId})},
        method:'POST',
        endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CategoryDataServer&action=getSiteCategory'
    });
  },
  search :function (data) {
  	return Simpplr.Salesforce.sendRequest({
        data: {'data' : JSON.stringify(data)},
        method:'POST',
        endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=CategoryDataServer&action=searchSiteCategory'
    });
  },
  delete :function (data) {
  	return Simpplr.Salesforce.sendRequest({
        data: {'data' : JSON.stringify(data)},
        method:'POST',
        endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CategoryDataServer&action=deleteSiteCategory' 
    });
  },
  save :function (categoryId, data) {
  	data.categoryId = categoryId;
  	return Simpplr.Salesforce.sendRequest({
        data: {'data' : JSON.stringify(data)},
        method:'POST',
        endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CategoryDataServer&action=saveSiteCategory'
    });
  },
  setOrder :function (sortOrder) {
  	var data = {'categoryIds':sortOrder};
  	Simpplr.Salesforce.log('Page.updateSiteCategoryPosition---data---'+ JSON.stringify(data));
  	
  	return Simpplr.Salesforce.sendRequest({
        data: {'data' : JSON.stringify(data)},
        method:'POST',
        endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CategoryDataServer&action=updateSiteCategoryPosition'
    });
  }
}