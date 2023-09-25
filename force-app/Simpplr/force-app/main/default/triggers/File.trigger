trigger File on File__c (after insert, after update, after delete, after undelete) {
    try{
        FileTriggerHandler handler = new FileTriggerHandler();

        ObjectHandler objHandler = new ObjectHandler();
        objHandler.triggerHandler('File__c');
        
       if(Trigger.isInsert && Trigger.isAfter){
           handler.OnAfterInsert(Trigger.new);
       }else if(Trigger.isUpdate && Trigger.isAfter){
           handler.OnAfterUpdate(Trigger.new);
       }
   }catch (Exception e){ 
       //Ignore excpetions
   }
}