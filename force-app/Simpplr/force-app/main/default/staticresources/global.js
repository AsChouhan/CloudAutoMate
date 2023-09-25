Simpplr.Salesforce.Global = {

	search :function (data) {
  	Simpplr.Salesforce.log('Global.search---data---'+ JSON.stringify(data));
  	
  	var searchEndpoint = Simpplr.Salesforce.Endpoints.ReadOnly +'?target=GlobalSearchDataServer';
  	var actionVar = 'search';
  	if(data.section === 'BoxFile' || data.section === 'GoogleDriveFile' || data.section === 'DropboxFile' || data.section === 'SharePointFile' || data.section === 'OneDriveFile') {
  		searchEndpoint = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=GlobalSearchDataServer';
      
    } else if(data.section === 'ServiceNow') {
        searchEndpoint = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ServiceNowDataServer';
        actionVar = 'getKnowledgebaseItems';
        
    } else if (data.section === 'NativeVideo'){
        searchEndpoint = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ExternalSearchDataServer';
        actionVar = 'externalSearch';

    } else if (data.section === 'Confluence'){
        searchEndpoint = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AtlassianDataServer';
        actionVar = 'searchConfluence';
    }
  	
    if(data.siteId !== undefined && data.siteId != null) {
  		searchEndpoint += '&siteId='+data.siteId;
  	}
  	return Simpplr.Salesforce.sendRequest({
    	data: {'data' : JSON.stringify(data)},
     	method:'POST',
      	endpoint:searchEndpoint + '&action=' + actionVar + '&searchForType=' + data.section
  	});
  },
  
  saveSearchStats :function (data) {
  console.log(location.href);
  	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=GlobalSearchDataServer&action=saveSearchStats'
      });
  },
  
  saveSearchResultSelect:function (paramsObject) {
  	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(paramsObject)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=GlobalSearchDataServer&action=saveSearchResultSelect'
      });
  },
  
  disconnectApp : function (appName) {
		var requestObj = {appName: appName};
		return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(requestObj)},
	      	method : 'POST',
	      	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=disconnectApp'
		});
	},
  
  autoComplete : function (data) {
 	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=GlobalSearchDataServer&action=searchAutoComplete'
      }); 	
  },
  
  externalAutoComplete : function (data) {
 	return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ExternalSearchDataServer&action=externalAutoComplete'
      }); 	
  },
  
  externalSearch :function (data) {
  	Simpplr.Salesforce.log('Global.externalSearch---data---'+ JSON.stringify(data));
  	var searchEndpoint = Simpplr.Salesforce.Endpoints.ReadOnly +'?target=ExternalSearchDataServer';
      
    var actionVar = 'externalSearch';
  	if(data.section === 'BoxFile' || data.section === 'GoogleDriveFile' || data.section === 'DropboxFile' || data.section === 'SharePointFile' || data.section === 'OneDriveFile' || data.section === 'NativeVideo') {
  		searchEndpoint = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ExternalSearchDataServer';
      
    } else if(data.section === 'ServiceNow') {
        searchEndpoint = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ServiceNowDataServer';
        actionVar = 'getKnowledgebaseItems';

    } else if(data.section === 'Confluence') {
        searchEndpoint = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AtlassianDataServer';
        actionVar = 'searchConfluence';
    }

    if(data.siteId !== undefined && data.siteId != null) {
        searchEndpoint += '&siteId='+data.siteId;
    }
  	  	
      return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:searchEndpoint + '&action='+ actionVar + '&searchForType=' + data.section
      });
  }
}