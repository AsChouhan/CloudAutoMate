Simpplr.Salesforce.PostInstall = Simpplr.Salesforce.PostInstall || {};
Simpplr.Salesforce.PostInstall = (function (Simpplr, $){
	var module = {};
	
	module.startInitialSetup = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=PostInstallSetupServer&action=startInitialSetup'
        });
    };
    
    module.resetConfigs = function (params, userParams) {
        var url = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=PostInstallSetupServer&action=' + params.action;
        if('tile' in userParams) {
        	url = url + '&tileId=' + userParams.tile;
        	if(userParams.action == 'activate') {
        		url = url + '&active=true';
        	} else {
        		url = url + '&active=false';
        	}
        	if('makeFirst' in userParams) {
	        	url = url + '&makeFirst=true';
	        } else {
	        	url = url + '&makeFirst=false';
	        }
        }
        Simpplr.Salesforce.log(url);
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : ''},
            method:'POST',
            endpoint:url
        });
        
    };
    
    return module;
})(Simpplr, jQuery);