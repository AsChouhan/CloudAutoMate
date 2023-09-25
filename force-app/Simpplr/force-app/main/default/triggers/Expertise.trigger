trigger Expertise on Expertise__c (after insert, after update, after delete, after undelete) {
    try{
        ExpertiseTriggerHandler handler = new ExpertiseTriggerHandler();

        ObjectHandler objHandler = new ObjectHandler();
        objHandler.triggerHandler('Expertise__c');
       
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