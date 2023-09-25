public with sharing class FeatureFlagManager {
    @TestVisible
    private static Map<String, Boolean> featureFlagValueMap = new Map<String, Boolean>(); 
    public static void initializeFeatureFlagValueMap(List<String> featureList) {

        String cacheNamespace = String.isblank(SimpplrContext.namespacePrefix) ? 'Local' : 'Simpplr';
        String cachePartition = 'Cache';                
                
        FFOrgCache cache = new FFOrgCache(cacheNamespace, cachePartition);
        FFConfig config = new FFConfig.builder()
                                        .evalExpireAfter(ServiceConstants.FEATURE_FLAG_CACHE_EXPIRY_IN_SECONDS)
                                        .cache(cache).build();
        // Set up the target properties.
        FFTarget target = FFTarget.builder().identifier('apex-anonymous-' + SimpplrContext.simpplrOrgId)
                                            .name('apex-anonymous-' + SimpplrContext.simpplrOrgId)
                                            .anonymous(true)
                                            .attributes(
                                                new Map<String, String> {
                                                    'orgId'=> SimpplrContext.simpplrOrgId
                                                }
                                            ).build();

        FFClient client = new FFClient(SimpplrContext.harnessAPIKey, target, config);
        Map<String, Boolean> featureMap = new  Map<String, Boolean>();
        for(String key : featureList) {
            featureFlagValueMap.put(key, client.evaluate(key, false));            
        }
    }

    public static Boolean isFeatureEnabled(String feature) { 
		Boolean featureValue = false; 
		if(featureFlagValueMap.containsKey(feature)) { 
			featureValue = featureFlagValueMap.get(feature); 
		} 
		return featureValue; 
	}
}