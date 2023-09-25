trigger LogsTrigger on Logs__c ( before insert, after insert, before update, after update, before delete, after delete) {

    String textValue = '';
    if(Trigger.isAfter && Trigger.isInsert){
        textValue = JSON.serialize(Trigger.newMap.values());
    }
    // Added condition to not push PushExternalDataV2 Flows related logs and keep it in Logs__c table only for review. 
    if(!textValue.contains('PushExternalDataV2')){
        try {
            ObjectHandler objHandler = new ObjectHandler();
            objHandler.triggerHandler('Logs__c');
        } catch (Exception e) {
            // Ignore exceptions
            System.debug('Error occured => ' + e.getMessage()); // NOPMD - suppressed codacy error
        }
    }

}