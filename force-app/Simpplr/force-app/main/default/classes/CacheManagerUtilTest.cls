@isTest
public with sharing class CacheManagerUtilTest {
    
    @isTest
	static void clearCarouselCacheTest(){
        
        App_Config__c appConfigRecord = new App_Config__c(App_Name__c = 'TestAppName',App_Dashboard_Mode__c='Manager');
        insert appConfigRecord;
        Cache.OrgPartition.createFullyQualifiedPartition('Local', 'Cache');
        Cache.Org.getPartition('Cache').put('cacheCarousel', 'data');
        Test.startTest();
        CacheManagerUtil.clearCacheContainsKey(ServiceConstants.CACHE_CAROUSEL);
        Test.stopTest();

        System.assertEquals(null, Cache.Org.getPartition('Cache').get('cacheCarousel'), 'Cache not deleted');
    }

}