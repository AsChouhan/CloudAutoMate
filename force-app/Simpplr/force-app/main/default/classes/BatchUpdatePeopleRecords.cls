public with sharing class BatchUpdatePeopleRecords implements Database.Batchable<SObject>, Database.stateful { 
    private String batchType;
    private Exception exceptionDetailsObj;
    private List<String> fieldListToEmpty;
    private Map<String, Schema.SObjectField> stringToObjFieldMap = new Map<String, Schema.SObjectField>{
        'Custom_Field_1__c' => People__c.Custom_Field_1__c,
        'Custom_Field_2__c' => People__c.Custom_Field_2__c,
        'Custom_Field_3__c' => People__c.Custom_Field_3__c,
        'Custom_Field_4__c' => People__c.Custom_Field_4__c,
        'Custom_Field_5__c' => People__c.Custom_Field_5__c,
        'Custom_Field_6__c' => People__c.Custom_Field_6__c,
        'Custom_Field_7__c' => People__c.Custom_Field_7__c,
        'Custom_Field_8__c' => People__c.Custom_Field_8__c,
        'Custom_Field_9__c' => People__c.Custom_Field_9__c,
        'Custom_Field_10__c' => People__c.Custom_Field_10__c,
        'Custom_Field_11__c' => People__c.Custom_Field_11__c,
        'Custom_Field_12__c' => People__c.Custom_Field_12__c,
        'Custom_Field_13__c' => People__c.Custom_Field_13__c,
        'Custom_Field_14__c' => People__c.Custom_Field_14__c,
        'Custom_Field_15__c' => People__c.Custom_Field_15__c,
        'Custom_Field_16__c' => People__c.Custom_Field_16__c,
        'Custom_Field_17__c' => People__c.Custom_Field_17__c,
        'Custom_Field_18__c' => People__c.Custom_Field_18__c,
        'Custom_Field_19__c' => People__c.Custom_Field_19__c,
        'Custom_Field_20__c' => People__c.Custom_Field_20__c,
        'Custom_Field_21__c' => People__c.Custom_Field_21__c,
        'Custom_Field_22__c' => People__c.Custom_Field_22__c,
        'Custom_Field_23__c' => People__c.Custom_Field_23__c,
        'Custom_Field_24__c' => People__c.Custom_Field_24__c,
        'Custom_Field_25__c' => People__c.Custom_Field_25__c
    };
    
    public BatchUpdatePeopleRecords() {

    }

    public BatchUpdatePeopleRecords(String batchType, List<String> fieldListToEmpty) {
        this.batchType = batchType;
        this.fieldListToEmpty = fieldListToEmpty;
    }

    public database.querylocator start(Database.BatchableContext bc){
        String query = null;
        if('clearCustomFields'.equalsIgnoreCase(batchType)){
            query = 'SELECT Id, Custom_Field_1__c, Custom_Field_2__c, Custom_Field_3__c, Custom_Field_4__c, Custom_Field_5__c, ' +
                ' Custom_Field_6__c, Custom_Field_7__c, Custom_Field_8__c, Custom_Field_9__c, Custom_Field_10__c, ' +
                ' Custom_Field_11__c, Custom_Field_12__c, Custom_Field_13__c, Custom_Field_14__c, Custom_Field_15__c, ' +
                ' Custom_Field_16__c, Custom_Field_17__c, Custom_Field_18__c, Custom_Field_19__c, Custom_Field_20__c, ' +
                ' Custom_Field_21__c, Custom_Field_22__c, Custom_Field_23__c, Custom_Field_24__c, Custom_Field_25__c ' + 
                ' FROM People__c';

        } else if('clearSyncField'.equalsIgnoreCase(batchType)) {
            query = ' Select id, Sync_Field__c, Employee_Number__c FROM People__c';
                    
        } 
    	
    	return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> listOfsObject){
    	try {
            List<People__c> peopleList = (List<People__c>) listOfsObject;
            List<Schema.SObjectField> sObjectFieldList = new List<Schema.SObjectField>();
            
            if('clearCustomFields'.equalsIgnoreCase(batchType)){

                for(String customFieldname : fieldListToEmpty){
                    sObjectFieldList.add(stringToObjFieldMap.get(customFieldname));
                }

                for(People__c peopleObj : peopleList) {
                    for(String customFieldname : fieldListToEmpty){
                        peopleObj.put(SimpplrContext.namespacePrefix + customFieldname, '');
                    }    
                }
    
            } else if('clearSyncField'.equalsIgnoreCase(batchType)) {

                sObjectFieldList.add(People__c.Sync_Field__c);
                sObjectFieldList.add(People__c.Employee_Number__c);

                for(People__c peopleObj : peopleList) {
                    peopleObj.Sync_Field__c = null;
                    peopleObj.Employee_Number__c = null;
                }
                        
            }
            
            if(!peopleList.isEmpty()){
                SIMPESAPI.accessController().updateAsUser(new Map<Id, People__c>(peopleList), sObjectFieldList);
            }
            
    	} catch(Exception ex) {
            exceptionDetailsObj =  ex;
    		throw ex;

    	}
    }
    
    public void finish(Database.BatchableContext bc){
        AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
        Boolean canStartNextBatch = false;
        if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
            canStartNextBatch = true;

        } else {
            Utility.sendExceptionEmail('BatchUpdatePeopleRecords', exceptionDetailsObj);
        }

        if(canStartNextBatch) {
            if('clearCustomFields'.equalsIgnoreCase(batchType)){
                // Do Nothing

            }
        }
    }
}