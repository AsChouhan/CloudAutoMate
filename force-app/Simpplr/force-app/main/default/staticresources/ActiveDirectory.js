Simpplr.Salesforce.ActiveDirectory =  (function(Simpplr, $){
	var module = {};
   	module.group = {};
  	module.search = function (data) {
	  
    }

    module.groupSearch = function (data) {
        var endPoint = Simpplr.Salesforce.Endpoints.ReadOnly + '?target=ActiveDirectoryDataServer&action=groupSearch';
        
        return Simpplr.Salesforce.sendRequest({
            data : {'data' : JSON.stringify(data)},
            method : 'GET',
            endpoint : endPoint
        });
    } 

    module.getActiveDirectoryGroups = function (data) {
        var endPoint = Simpplr.Salesforce.Endpoints.ReadOnly + '?target=ActiveDirectoryDataServer&action=getActiveDirectoryGroups';
        
        return Simpplr.Salesforce.sendRequest({
            data : {'data' : JSON.stringify(data)},
            method : 'GET',
            endpoint : endPoint
        });
    }

    module.getActiveDirectoryGroupMembers = function (data) {
        var endPoint = Simpplr.Salesforce.Endpoints.ReadOnly + '?target=ActiveDirectoryDataServer&action=getActiveDirectoryGroupMembers';
        
        return Simpplr.Salesforce.sendRequest({
            data : {'data' : JSON.stringify(data)},
            method : 'GET',
            endpoint : endPoint
        });
    }

    module.getSelectedGroupTypes = function () {
        var endPoint = Simpplr.Salesforce.Endpoints.ReadOnly + '?target=ActiveDirectoryDataServer&action=getSelectedGroupTypes';
        
        return Simpplr.Salesforce.sendRequest({
            method : 'GET',
            endpoint : endPoint
        });
    }    

      return module; 
    })(Simpplr, jQuery);