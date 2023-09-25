Simpplr.Salesforce.ContentTemplate = {
    
    search :function (data) {
        Simpplr.Salesforce.log('ContentTemplate.search---data---'+ JSON.stringify(data));
  	    return Simpplr.Salesforce.sendRequest({
	    data: {'data' : JSON.stringify(data)},
	    method:'POST',
	    endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ContentTemplateDataServer&action=search'
	    });
    },

    save :function (templateType,id,data) {
        Simpplr.Salesforce.log('ContentTemplate.save---templateType---'+ templateType);
            var actionName = "";
            var endPointURL = "";
            
            if("page" === templateType){
                if(id == null){
                    actionName = "savePageTemplate";
                } else {
                    data.id = id;
                    actionName = "updatePageTemplate";
                }
                endPointURL = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ContentTemplateDataServer&action='+actionName + '&siteId=' + data.siteId; 
            }
            
            if(id !== null){
                endPointURL += '&contentTemplateId=' + id;
            }
      
            return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint: endPointURL
          });
        },

    delete :function (siteId, contentId) {},

    get :function (data) {
        Simpplr.Salesforce.log('ContentTemplate.get---data---'+ JSON.stringify(data));
        var endPointURL = "";
        endPointURL = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ContentTemplateDataServer&action=get&contentTemplateId=' + data.contentTemplateId;
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : ''},
            method:'GET',
            endpoint: endPointURL
            });
    },

}