trigger TilesConfig on Tiles_Config__c (after insert, after update, after delete, after undelete) {
    try{
        TilesConfigTriggerHandler handler = new TilesConfigTriggerHandler();

        ObjectHandler objHandler = new ObjectHandler();
        objHandler.triggerHandler('Tiles_Config__c');

        if(Trigger.isAfter) {
            if(Trigger.isInsert) {
                handler.OnAfterInsert(Trigger.newMap);
            } else if(Trigger.isUpdate){
                handler.OnAfterUpdate(Trigger.newMap);
            }
        }
        CacheManagerUtil.clearCacheContainsKey(ServiceConstants.CACHE_TILE);
    }catch (Exception e){
        Utility.sendExceptionEmail('TilesConfig', e);
    }
}