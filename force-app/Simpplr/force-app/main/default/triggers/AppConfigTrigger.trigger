trigger AppConfigTrigger on App_Config__c (after insert, after update, after delete, after undelete) {
    try {
        ObjectHandler objHandler = new ObjectHandler();
        objHandler.triggerHandler('App_Config__c');

        if (Trigger.isUpdate && Trigger.isAfter){
            new AppConfigTriggerHandler().onAfterUpdate(trigger.newMap);

            //Process failed cdc records and ensure external sync enabled and initial load completed
            App_Config__c oldObj = trigger.oldMap.values()[0];
            App_Config__c newObj = trigger.newMap.values()[0];
            if(oldObj.Flow_External_Sync_Enabled__c == false && newObj.Flow_External_Sync_Enabled__c == true){
                Database.executeBatch(new BatchPushExternalData(true), 100);
            }
        } 
        
    } catch (Exception e) {
        // Ignore exceptions
        System.debug(LoggingLevel.INFO, 'Error occured => ' + e.getMessage()); // NOPMD - suppressed codacy error
    }
}