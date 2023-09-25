trigger SocialCampaignTrigger on Social_Campaign__c (after insert, after update, after delete, after undelete) {
    try {
        CacheManagerUtil.clearCacheContainsKey(ServiceConstants.CACHE_CAROUSEL);
        ObjectHandler objHandler = new ObjectHandler();
        objHandler.triggerHandler('Social_Campaign__c');
    } catch (Exception e) {
        // Ignore exceptions
        System.debug(LoggingLevel.INFO, 'Error occured => ' + e.getMessage()); // NOPMD - suppressed codacy error
    }
}