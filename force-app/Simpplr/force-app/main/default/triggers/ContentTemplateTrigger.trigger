/**
 * @description       : trigger for Content_Template__c
 * @author            : simpplr.com
 * @group             : Content
 * @last modified on  : 03-21-2022
 * @last modified by  : simpplr.com
**/
trigger ContentTemplateTrigger on Content_Template__c (after insert, after update, after delete, after undelete) {
    try{
        ContentTemplateTriggerHandler handler = new ContentTemplateTriggerHandler();

        ObjectHandler objHandler = new ObjectHandler();
        objHandler.triggerHandler('Content_Template__c');
        
        if(Trigger.isInsert && Trigger.isAfter){
            handler.onAfterInsert(Trigger.newMap);
        }else if(Trigger.isUpdate && Trigger.isAfter){
            handler.onAfterUpdate(Trigger.newMap);
        } else if(Trigger.isDelete && Trigger.isAfter){ 
            handler.onAfterDelete(Trigger.old);
        }else if(Trigger.isUndelete && Trigger.isAfter){ 
            handler.onAfterUnDelete(Trigger.newMap);
        }
   }catch (Exception e){
       System.debug(LoggingLevel.INFO, 'Error occured => ' + e.getMessage()); // NOPMD - Ignore exceptions, suppressed codacy error
   }
}