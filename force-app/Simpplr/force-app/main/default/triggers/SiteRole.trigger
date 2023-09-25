trigger SiteRole on Site_Role__c (before insert, after insert, before update, after update, after delete, after undelete) {
    try{
        SiteRoleTriggerHandler handler = new SiteRoleTriggerHandler();

        ObjectHandler objHandler = new ObjectHandler();
        objHandler.triggerHandler('Site_Role__c');

        if(Trigger.isBefore) {
            if(Trigger.isInsert) {
                handler.OnBeforeInsert(Trigger.new);
            } else if(Trigger.isUpdate) {
                handler.OnBeforeUpdate(Trigger.new);
            }
        } else if(Trigger.isInsert && Trigger.isAfter){
           handler.OnAfterInsert(Trigger.newMap);
       }else if(Trigger.isUpdate && Trigger.isAfter){
           handler.OnAfterUpdate(Trigger.newMap);
       }
       CacheManagerUtil.clearCacheContainsKey(ServiceConstants.CACHE_TILE);
   }catch (Exception e){ 
       //Ignore excpetions
   }
}