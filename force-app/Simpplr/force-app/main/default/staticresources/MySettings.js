Simpplr.Salesforce.MySettings = Simpplr.Salesforce.MySettings || {};

Simpplr.Salesforce.MySettings = (function (Simpplr, $){
	var module = {};
	
	module.saveDashboardSettings = function (data) { 		
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=MySettingDataServer&action=saveDashboardSettings'
        });
    };

	module.saveProfileSettings = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=MySettingDataServer&action=saveProfileSettings'
        });
    };

    module.saveMobileNoOnProfileSettings = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=MySettingDataServer&action=saveMobileNoOnProfileSettings'
        });
    };
    

	module.saveFeedSettings = function (data) {
        
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=MySettingDataServer&action=saveFeedSettings'
        });
    };
    
    module.saveEmailNotificationsSettings = function (data) {
        
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=MySettingDataServer&action=saveEmailNotificationsSettings'
        });
    };
    
    module.saveAppManagerNotificationsSettings = function (data) {
        
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=MySettingDataServer&action=saveAppManagerNotificationsSettings'
        });
    };
    
    module.saveMobileAppNotificationsSettings = function (data) {
        
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=MySettingDataServer&action=saveMobileAppNotificationsSettings'
        });
    };
    
    module.saveNativeMobileAppNotificationsSettings = function (data) {
        
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=MySettingDataServer&action=saveNativeMobileAppNotificationsSettings'
        });
    };

    module.saveBrowserNotificationsSettings = function (data) {
        
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=MySettingDataServer&action=saveBrowserNotificationsSettings'
        });
    };
    
    module.saveDesktopAppNotificationsSettings = function (data) {
        
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=MySettingDataServer&action=saveDesktopAppNotificationsSettings'
        });
    };

    module.saveSummariesAndDigestSettings = function (data) {
        
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=MySettingDataServer&action=saveSummariesAndDigestSettings'
        });
    };
    
    module.saveExternalAppSettings = function (data) {
        
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=MySettingDataServer&action=saveExternalAppSettings'
        });
    };
    
    module.getEmailNotificationsSettings = function (peopleId) {
        
        return Simpplr.Salesforce.sendRequest({
            data: {'peopleId' : peopleId},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=MySettingDataServer&action=getEmailNotificationsSettings'
        });
    };
    
    module.getMobileAppNotificationsSettings = function (peopleId) {
        
        return Simpplr.Salesforce.sendRequest({
            data: {'peopleId' : peopleId},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=MySettingDataServer&action=getMobileAppNotificationsSettings'
        });
    };

    module.getAppManagerNotificationsSettings = function (peopleId) {
        
        return Simpplr.Salesforce.sendRequest({
            data: {'peopleId' : peopleId},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=MySettingDataServer&action=getAppManagerNotificationsSettings'
        });
    };

    module.getNativeMobileAppNotificationsSettings = function (peopleId) {
        
        return Simpplr.Salesforce.sendRequest({
            data: {'peopleId' : peopleId},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=MySettingDataServer&action=getNativeMobileAppNotificationsSettings'
        });
    };

    module.getBrowserNotificationsSettings = function (peopleId) {
        
        return Simpplr.Salesforce.sendRequest({
            data: {'peopleId' : peopleId},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=MySettingDataServer&action=getBrowserNotificationsSettings'
        });
    };

    module.getExternalAppsSettings = function (peopleId) {
        
        return Simpplr.Salesforce.sendRequest({
            data: {'peopleId' : peopleId},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=MySettingDataServer&action=getExternalAppsSettings'
        });
    };

    module.getSMSNotificationsSettings = function (peopleId) {
        
        return Simpplr.Salesforce.sendRequest({
            data: {'peopleId' : peopleId},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=MySettingDataServer&action=getSMSNotificationsSettings'
        });
    };

    module.saveSMSNotificationsSettings = function (data) {
        
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=MySettingDataServer&action=saveSMSNotificationsSettings'
        });
    };

    module.getSummariesAndDigestSettings = function (peopleId) {
        
        return Simpplr.Salesforce.sendRequest({
            data: {'peopleId' : peopleId},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=MySettingDataServer&action=getSummariesAndDigestSettings'
        });
    };

    
	return module;
})(Simpplr, jQuery);