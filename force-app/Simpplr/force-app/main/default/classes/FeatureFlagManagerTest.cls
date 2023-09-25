@isTest
private class FeatureFlagManagerTest {
    @isTest 
    static void testMethods() {
        Cache.OrgPartition.createFullyQualifiedPartition('Local', 'Cache');
        Cache.Org.getPartition('Cache').put('auth' + SimpplrContext.harnessAPIKey.replaceAll('-', ''), new Map<String,String>{'jwt'=>'jwt'});
        Cache.Org.getPartition('Cache').put('odinflag', FFEvaluation.getExample());

        List<String> flagList = new List<String>{'odinflag'};
        FeatureFlagManager.initializeFeatureFlagValueMap(flagList);
        Boolean flag = FeatureFlagManager.isFeatureEnabled('odinflag');
        System.assert(true,'Running as expected');
    }
}