public with sharing class AppIntegrationTriggerHandler {
	
	public void onAfterUpdate(Map<Id, App_Integration__c> newMap){
        clearCache();
	}

	public void onAfterInsert(Map<Id, App_Integration__c> newMap){
        clearCache();
	}    

	public void onAfterDelete(){
        clearCache();
	}        

    private void clearCache() {
        String platformCacheAppConfigStr = 'Local.Cache.appIntegrations';

        if (!String.isblank(SimpplrContext.namespacePrefix)) {
            platformCacheAppConfigStr = 'Simpplr.Cache.appIntegrations';
        }

        if (SimpplrContext.isPlatformCachingFeatureEnabled && 
                Cache.Org.contains(platformCacheAppConfigStr)) {  
            Cache.Org.remove(platformCacheAppConfigStr);
        }        
    }
}