trigger SiteMembershipRequest on Site_Membership_Request__c(after insert, after update, after delete, after undelete) {
    try {
        SiteMembershipRequestTriggerHandler handler = new SiteMembershipRequestTriggerHandler();

        ObjectHandler objHandler = new ObjectHandler();
        objHandler.triggerHandler('Site_Membership_Request__c');
        
        if (Trigger.isInsert && Trigger.isAfter) {
           handler.OnAfterInsert(Trigger.newMap);
       
        } else if(Trigger.isUpdate && Trigger.isAfter) {
           handler.OnAfterUpdate(Trigger.newMap);
       }

    } catch (Exception e) { 
       //Ignore excpetions
    }

}