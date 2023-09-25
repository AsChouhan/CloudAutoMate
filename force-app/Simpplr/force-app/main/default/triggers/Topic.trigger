trigger Topic on Topic (after insert, after update, after delete, after undelete) {
    try{
        if(String.isBlank(SimpplrContext.packageName) || UserInfo.isCurrentUserLicensed(SimpplrContext.packageName)) {
            TopicTriggerHandler handler = new TopicTriggerHandler();

            ObjectHandler objHandler = new ObjectHandler();
            objHandler.triggerHandler('Topic');

            if(Trigger.isInsert && Trigger.isAfter){
                handler.OnAfterInsert(Trigger.newMap);
            }else if(Trigger.isUpdate && Trigger.isAfter){
                handler.OnAfterUpdate(Trigger.newMap);
            } else if(Trigger.isDelete && Trigger.isAfter){ 
                    handler.OnAfterDelete(Trigger.old);
            }
        }
    }catch (Exception e){ 
       //Ignore excpetions
    }
}