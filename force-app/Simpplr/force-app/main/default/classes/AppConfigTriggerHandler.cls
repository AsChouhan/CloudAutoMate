public with sharing class AppConfigTriggerHandler {
	
	public void OnAfterUpdate(Map<Id, App_Config__c> newMap){
        String platformCacheAppConfigStr = 'Local.Cache.appConfig';

        if (!String.isblank(SimpplrContext.namespacePrefix)) {
            platformCacheAppConfigStr = 'Simpplr.Cache.appConfig';
        }

        if (SimpplrContext.isPlatformCachingFeatureEnabled && 
                Cache.Org.contains(platformCacheAppConfigStr)) {  
            Cache.Org.remove(platformCacheAppConfigStr);
        }
        
	}
}