trigger AppIntegrationTrigger on App_Integration__c (after insert, after update, after delete, after undelete) {
    try {
        ObjectHandler objHandler = new ObjectHandler();
        objHandler.triggerHandler('App_Integration__c');

        if (Trigger.isUpdate && Trigger.isAfter){
            new AppIntegrationTriggerHandler().onAfterUpdate(trigger.newMap);
        } 

        if (Trigger.isDelete && Trigger.isAfter){
            new AppIntegrationTriggerHandler().onAfterDelete();
        } 
        
        if (Trigger.isInsert && Trigger.isAfter){
            new AppIntegrationTriggerHandler().onAfterInsert(trigger.newMap);
        }         

    } catch (Exception e) {
        // Ignore exceptions
        System.debug(LoggingLevel.INFO, 'Error occured => ' + e.getMessage()); // NOPMD - suppressed codacy error
    }
}