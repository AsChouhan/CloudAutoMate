trigger Alert on Alert__c (after insert, after update, after delete, after undelete) {
    try{
        AlertTriggerHandler handler = new AlertTriggerHandler();

        ObjectHandler objHandler = new ObjectHandler();
        objHandler.triggerHandler('Alert__c');

       if(Trigger.isInsert && Trigger.isAfter){
           handler.OnAfterInsert(Trigger.newMap);
       }else if(Trigger.isUpdate && Trigger.isAfter){
           handler.OnAfterUpdate(Trigger.newMap);
       } else if(Trigger.isDelete && Trigger.isAfter){ 
            handler.OnAfterDelete(Trigger.old);
       }
   }catch (Exception e){
       //Ignore excpetions
   }
}