trigger EventRSVPResponse on Event_RSVP_Response__c (after insert, after update, after delete, after undelete) {
    try{
        EventRSVPResponseTriggerHandler handler = new EventRSVPResponseTriggerHandler();

        ObjectHandler objHandler = new ObjectHandler();
        objHandler.triggerHandler('Event_RSVP_Response__c');
        
       if(Trigger.isInsert && Trigger.isAfter){
           handler.OnAfterInsert(Trigger.newMap);
       }else if(Trigger.isUpdate && Trigger.isAfter){
           handler.OnAfterUpdate(Trigger.newMap);
       }
   }catch (Exception e){ 
       //Ignore excpetions
   }
}