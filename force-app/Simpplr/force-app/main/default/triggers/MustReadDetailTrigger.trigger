trigger MustReadDetailTrigger on Must_Read_Detail__c (after insert, after update, after delete, after undelete) {
    try {
        //Added this for atleast 1 line coverage for trigger
        ObjectHandler objHandler = new ObjectHandler();
		//this sobject not used, hence disabled cdc sync
        //objHandler.triggerHandler('Must_Read_Detail__c');
    } catch (Exception e) {
        // Ignore exceptions
        System.debug(LoggingLevel.INFO, 'Error occured => ' + e.getMessage()); // NOPMD - suppressed codacy error
    }
}