trigger ExternalDataTrailTrigger on External_Data_Trail__c (after delete) {

    List<Logs__c> logList = new List<Logs__c>();
    for(External_Data_Trail__c sobj : Trigger.old) {
        if('Logs__c'.equals(sobj.Type__c)){
            logList.add(new Logs__c(id = sobj.Input_Object_Id__c));
        }
    } 
    if(logList.size()>0){
        delete logList;
    }
    // delete INVOCABLE_ACTION logs if debug is disabled otherwise keep logs for debugging CDC/realtime sync process
    Boolean isDebugOn = SimpplrContext.isDebugEnabled && System.now() < SimpplrContext.debugTurnOffTime;
    if(!isDebugOn){
        List<Logs__c> logList = [select id from Logs__c where Log_Type__c='INVOCABLE_ACTION'];
        if(logList.size()>0) delete logList;
    }
}