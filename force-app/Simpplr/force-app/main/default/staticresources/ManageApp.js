Simpplr.Salesforce.ManageApp = Simpplr.Salesforce.ManageApp || {};
Simpplr.Salesforce.ManageApp = (function (Simpplr, $){
	var module = {};
    
    module.getGeneralSetupConfig = function () {
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=getGeneralSetupConfig'
        });
    };

    module.getGovernanceSetupConfig = function () {
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=getGovernanceSetupConfig'
        });
    };

    module.getCategoryPeopleConfig = function () { 
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SettingDataServer&action=getCategoryPeopleConfig'
        });
    };

    module.getLicensingPeopleConfig = function () {
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SettingDataServer&action=getLicensingPeopleConfig'
        });
    };

    module.getUserSyncingPeopleConfig = function () {
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SettingDataServer&action=getUserSyncingPeopleConfig'
        });
    };

    module.getProfileFieldsPeopleConfig = function () {
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SettingDataServer&action=getProfileFieldsPeopleConfig'
        });
    };

    module.getNavigationSetupConfig = function () {
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SettingDataServer&action=getNavigationSetupConfig'
        });
    };

    module.getEmailSetupConfig = function () {
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SettingDataServer&action=getEmailSetupConfig'
        });
    };

    module.getTroubleshootingConfig = function () {
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SettingDataServer&action=getTroubleshootingConfig'
        });
    };
    
    module.getMobileAppConfig = function () {
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SettingDataServer&action=getMobileAppConfig'
        });
    };

    module.getPrivilegesConfig = function () {
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SettingDataServer&action=getPrivilegesConfig'
        });
    };

    module.getEmailNotificationsSettings = function () {
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SettingDataServer&action=getEmailNotificationsSettings'
        });
    };


    module.getDefaultFeedSettings = function () {
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SettingDataServer&action=getDefaultFeedSettings'
        });
    };

    module.getSMSNotificationsSettings = function () {
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SettingDataServer&action=getSMSNotificationsSettings'
        });
    };

    module.getNativeMobileAppNotificationsSettings = function () {
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SettingDataServer&action=getNativeMobileAppNotificationsSettings'
        });
    };

    module.getBrowserNotificationsSettings = function () {
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SettingDataServer&action=getBrowserNotificationsSettings'
        });
    };

    module.getSummariesAndDigestSettings = function () {
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SettingDataServer&action=getSummariesAndDigestSettings'
        });
    };

    module.getAnalyticsEmbedsIntegrationsConfig = function () {
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SettingDataServer&action=getAnalyticsEmbedsIntegrationsConfig'
        });
    };

    module.getCalendarIntegrationsConfig = function () {
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SettingDataServer&action=getCalendarIntegrationsConfig'
        });
    };

    module.getFilesIntegrationsConfig = function () {
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SettingDataServer&action=getFilesIntegrationsConfig'
        });
    };

    module.getDomainsIntegrationsConfig = function () {
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SettingDataServer&action=getDomainsIntegrationsConfig'
        });
    };

    module.getMessagingIntegrationsConfig = function () {
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SettingDataServer&action=getMessagingIntegrationsConfig'
        });
    };

    module.getPeopleIntegrationsConfig = function () {
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SettingDataServer&action=getPeopleIntegrationsConfig'
        });
    };

    module.getSearchIntegrationsConfig = function () {
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=getSearchIntegrationsConfig'
        });
    };

    module.getSsoIntegrationsConfig = function () {
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SettingDataServer&action=getSsoIntegrationsConfig'
        });
    };

    module.getSupportIntegrationsConfig = function () {
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SettingDataServer&action=getSupportIntegrationsConfig'
        });
    };

    module.getCampaignsIntegrationsConfig = function () {
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SettingDataServer&action=getCampaignsIntegrationsConfig'
        });
    };

    module.getUserProvisioningConfig = function () {
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SettingDataServer&action=getUserProvisioningConfig'
        });
    };

    module.getUKGUserFieldConfig = function () {
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SettingDataServer&action=getUKGUserFieldConfig'
        });
    };

    
    module.getListenerSuiteSetupConfig = function () {
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SettingDataServer&action=getListenerSuiteSetupConfig'
        });
    };

    module.getRecognitionSetupConfig = function () {
        return Simpplr.Salesforce.sendRequest({
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SettingDataServer&action=getRecognitionSetupConfig'
        });
    };


	module.saveGeneralSetupConfig = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=saveGeneralSetupConfig'
        });
    };
    
	module.saveGovernanceSetupConfig = function (data) {
        
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=saveGovernanceSetupConfig'
        });
    };

    module.connectApp = function (appName) {
        var requestObj = {appName: appName};
        return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(requestObj)},
	      	method : 'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=connectApp'
        });
    };

    module.disconnectApp = function (appName, paramObj) {
        var requestObj = {appName: appName};
        if(paramObj && paramObj.spDisconnectAndUpgrade){
            requestObj.spUpgradeAndDisconnect = true;
        }
		return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(requestObj)},
	      	method : 'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=disconnectApp'
        });
    };

	module.saveNavigationSetupConfig = function (data) {
		
		if (typeof data !== 'undefined' && typeof data.isOrgChartEnabled !== 'undefined') {
			
			if (data.isOrgChartEnabled === 'true') {
				data.isOrgChartEnabled = true;
			
			} else if (data.isOrgChartEnabled === 'false') {
				data.isOrgChartEnabled = false; 
			}
			
		}
		
		Simpplr.Salesforce.log('ManageApp.saveNavigationSetupConfig---data---'+ JSON.stringify(data));
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=saveNavigationSetupConfig'
        });
    };
    
    module.saveEmailSetupConfig = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=saveEmailSetupConfig'
        });
    };
    
    module.saveCategoryPeopleConfig = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=saveCategoryPeopleConfig'
        });
    };

    module.saveLicensingPeopleConfig = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=saveLicensingPeopleConfig'
        });
    };
    
    module.saveCategoriesPeopleConfig = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=saveCategoriesPeopleConfig'
        });
    };
    
    module.saveUserSyncingPeopleConfig = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=saveUserSyncingPeopleConfig'
        });
    };
    
    module.saveProfileFieldsPeopleConfig = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=saveProfileFieldsPeopleConfig'
        });
    };
    
    module.savePrivilegesConfig = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=savePrivilegesConfig'
        });
    };
    
    module.saveTroubleshootingConfig = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=saveTroubleshootingConfig'
        });
    };    
    module.saveMobileAppConfig = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=saveMobileAppConfig'
        });
    };    
    module.saveEmailNotificationsSettings = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=saveEmailNotificationsSettings'
        });
    };  
    
    module.saveDefaultFeedSettings = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=saveDefaultFeedSettings'
        });
    };  

    module.saveSMSNotificationsSettings = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=saveSMSNotificationsSettings'
        });
    }; 

    module.saveNativeMobileAppNotificationsSettings = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=saveNativeMobileAppNotificationsSettings'
        });
    }; 

    module.saveBrowserNotificationsSettings = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=saveBrowserNotificationsSettings'
        });
    }; 

    module.saveSummariesAndDigestSettings = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=saveSummariesAndDigestSettings'
        });
    }; 

    module.saveAnalyticsEmbedsIntegrationsConfig = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=saveAnalyticsEmbedsIntegrationsConfig'
        });
    };

    module.saveCalendarIntegrationsConfig = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=saveCalendarIntegrationsConfig'
        });
    };

    module.saveFilesIntegrationsConfig = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=saveFilesIntegrationsConfig'
        });
    };

    module.saveDomainsIntegrationsConfig = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=saveDomainsIntegrationsConfig'
        });
    };

    module.startGoogleMultiInstanceUpgradeFlow = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method: 'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite + '?target=SettingDataServer&action=startGoogleMultiInstanceUpgradeFlow'
        });
    };

    module.saveMessagingIntegrationsConfig = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=saveMessagingIntegrationsConfig'
        });
    };

    module.savePeopleIntegrationsConfig = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=savePeopleIntegrationsConfig'
        });
    };

    module.saveSearchIntegrationsConfig = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=saveSearchIntegrationsConfig'
        });
    };

    module.saveSsoIntegrationsConfig = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=saveSsoIntegrationsConfig'
        });
    };

    module.saveSupportIntegrationsConfig = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=saveSupportIntegrationsConfig'
        });
    };

    module.saveCampaignsIntegrationsConfig = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=saveCampaignsIntegrationsConfig'
        });
    };

    module.saveUserProvisioningConfig = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=saveUserProvisioningConfig'
        });
    };

    module.saveListenerSuiteSetupConfig = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=saveListenerSuiteSetupConfig'
        });
    };

    module.saveRecognitionSetupConfig = function (data) {
        return Simpplr.Salesforce.sendRequest({
            data: {'data' : JSON.stringify(data)},
            method:'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SettingDataServer&action=saveRecognitionSetupConfig'
        });
    };

    module.startSlackUpgradeFlow = function () {
        return Simpplr.Salesforce.sendRequest({
            method: 'POST',
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite + '?target=SettingDataServer&action=startSlackUpgradeFlow'
        });
    };

	return module;
})(Simpplr, jQuery);