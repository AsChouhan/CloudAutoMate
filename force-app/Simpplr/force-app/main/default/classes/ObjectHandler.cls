public virtual without sharing class ObjectHandler {

    // Instance variables
    public String operationType;
    public String requestId;
    public Boolean isCurrentUserLicensed;
    public List<sObject> listRecords;

    // This flag be used to disable external data in some scenarios
    // Default value is NULL
    public static Boolean skipExternalDataPush = null;
    public static final Set<String> SYNC_ALLOWED_TRIGGER_CONTEXTS = new Set<String>{'AFTER_INSERT', 'AFTER_UPDATE', 'AFTER_UNDELETE', 'AFTER_DELETE'};

    public ObjectHandler(){
        isCurrentUserLicensed = (String.isBlank(SimpplrContext.packageName) || UserInfo.isCurrentUserLicensed(SimpplrContext.packageName)) ? true : false;
        operationType = Trigger.operationType.name();
    }

    public void triggerHandler(String recordType) {
        try {
            if(recordType.contains('Logs__c') && operationType.equalsIgnoreCase('AFTER_DELETE')) {
                return;
            }
            if(isCurrentUserLicensed 
                && ObjectHandler.SYNC_ALLOWED_TRIGGER_CONTEXTS.contains(operationType)
                && ((SimpplrContext.isExternalDataSyncEnabled 
                        && ObjectHandler.skipExternalDataPush != true 
                        && !Test.isRunningTest()) 
                    || (ObjectHandler.skipExternalDataPush == false 
                        && Test.isRunningTest()))
            ){
                //Fetch sobject records based on trigger context
                initHandler();
                insertExternalDataTrail(recordType);
            }
        } catch (Exception e) {
            // handle exceptions, print error message on logs
            System.debug(LoggingLevel.INFO, 'Error occured => ' + e.getMessage()); // NOPMD - suppressed codacy error
        }
    }

    public void initHandler(){
        requestId = Request.getCurrent().getRequestId();
        setTriggerRecords();
    }

    public void setTriggerRecords() {
        listRecords = new List<sObject>();
        switch on Trigger.operationType {
            when AFTER_INSERT, AFTER_UPDATE, AFTER_UNDELETE{
                listRecords = Trigger.newMap.values();
            }
            when AFTER_DELETE{
                listRecords = Trigger.old;
            }
        }
    }
    
    public void insertExternalDataTrail(String recordType) {
        Boolean isAsyncContext = System.isBatch();
        List<External_Data_Trail__c> listToInsert = new List<External_Data_Trail__c>();		
        if(listRecords != null && !listRecords.isEmpty()){
            for(sObject sobj : listRecords) {
                listToInsert.add(new External_Data_Trail__c(
                    Input_Object_Id__c = sobj.Id, 
                    Type__c = recordType, 
                    Request_Id__c = requestId, 
                    Operation_Type__c = operationType,
                    Is_Async_Context__c = isAsyncContext
                ));		
            } 
        }

        if (Schema.sObjectType.External_Data_Trail__c.isCreateable()) {
            insert listToInsert;
        }
    }
    
}