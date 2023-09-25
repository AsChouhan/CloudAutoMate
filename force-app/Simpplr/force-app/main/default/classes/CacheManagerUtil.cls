public with sharing class CacheManagerUtil {
	public static void clearCacheContainsKey(String cacheName){
		Boolean isHomeAppManagerControlled = ServiceConstants.DASHBOARD_OWNER_APP_MANAGER.equalsIgnoreCase(SimpplrContext.AppDashboardMode);
		if(Test.isRunningTest() || (isHomeAppManagerControlled && SimpplrContext.isKitaPSARChangesEnabled)){
			for(String key : Cache.Org.getPartition('Cache').getKeys()){
				if(key.contains(cacheName)){
					Cache.Org.getPartition('Cache').remove(key);
				}
			}
		}
	}
		
}