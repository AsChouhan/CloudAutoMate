trigger ContentAuditTrailTrigger on Content_Audit_Trail__c (after insert, after update, after delete, after undelete) {
    try {
        ObjectHandler objHandler = new ObjectHandler();
        objHandler.triggerHandler('Content_Audit_Trail__c');
    } catch (Exception e) {
        System.debug(LoggingLevel.INFO, 'Error occured => ' + e.getMessage()); // NOPMD - Ignore exceptions, suppressed codacy error
    }
}