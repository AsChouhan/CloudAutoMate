Simpplr.Salesforce.Segment =  (function(Simpplr, $){
	var module = {};
	var SFDC = {}; 
   	var resultDefObj = {};
   	
  	module.search = function (data) {
      	return Simpplr.Salesforce.sendRequest({
          	data : {'data' : JSON.stringify(data)},
          	method : 'GET',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SegmentDataServer&action=search'
      	});
  	}
  	
  	module.setEnabled = function (profileField, isBrandingSegmented, data, shouldInherit, isAppsAndLinksSegmented) {
      	return Simpplr.Salesforce.sendRequest({
          	data : {'profileField': profileField, 'isBrandingSegmented': isBrandingSegmented, 'isAppsAndLinksSegmented': isAppsAndLinksSegmented, 'data' : JSON.stringify(data), 'shouldInherit': shouldInherit},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SegmentDataServer&action=setEnabled'
      	});
  	}
  	
  	module.get = function (segmentId) {
      	return Simpplr.Salesforce.sendRequest({
          	data : {'segmentId' : segmentId},
          	method : 'GET',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SegmentDataServer&action=get'
      	});
  	}
  	
  	module.setManagers = function (segmentId, listOfManagers) {
      	return Simpplr.Salesforce.sendRequest({
          	data : {'segmentId' : segmentId, 'listOfManagers' : JSON.stringify(listOfManagers)},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SegmentDataServer&action=setManagers'
      	});
  	}
  	
  	module.allowBranding = function (isEnabled) {
      	return Simpplr.Salesforce.sendRequest({
          	data : {'isEnabled' : isEnabled},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SegmentDataServer&action=allowBranding'
      	});
  	}  	  	  
  	
    module.allowAppsAndLinks = function (isEnabled) {
        return Simpplr.Salesforce.sendRequest({
            data : {'isEnabled' : isEnabled},
            method : 'POST',
            endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SegmentDataServer&action=allowAppsAndLinks'
        });
    }
  	
  	module.setup = function (data) {
      	return Simpplr.Salesforce.sendRequest({
          	data : {'data' : JSON.stringify(data)},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SegmentDataServer&action=setup'
      	});
  	}
  	
  	module.getPossibleSubsegments = function (profileField) {
      	return Simpplr.Salesforce.sendRequest({
          	data : {'profileField': profileField},
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SegmentDataServer&action=getPossibleSubsegments'
      	});
  	}

	module.getByIds = function (listOfSegmentId) {
        return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(listOfSegmentId)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SegmentDataServer&action=getByIds'
      	});
    }
  	
  	return module; 
})(Simpplr, jQuery);