/**
 * @description       : This class used to process salesforce data sync failures to external service
 * @author            : simpplr.com
 * @last modified on  : 04-22-2022
 * @last modified by  : simpplr.com
**/
public without sharing class BatchPushExternalData implements Database.Batchable<SObject>, Database.Stateful,Database.AllowsCallouts {



    public final Integer CDC_MAX_RETRY_COUNT = 5;
    //This is to avoid conflict with live transactions
    public final Integer CDC_BUFFER_TIME_IN_MINUTE = -5;
    public final String CDC_GENERAL_CATEGORY_SYNC = 'CDC_GENERAL_CATEGORY_SYNC';
    public final String CDC_HEAVY_CATEGORY_SYNC = 'CDC_HEAVY_CATEGORY_SYNC';
    public final String CDC_STD_CATEGORY_SYNC = 'CDC_STD_CATEGORY_SYNC';

    private String batchType;
    private Boolean runNextBatchInSequence;

    private String recordType;
    private Datetime startTime;
    private Datetime endTime;
    private Key_Value_Setting__c keyValueSetting;
    private List<String> cdcStdObjects;

    // sobjects with huge record size can be added to this list ~= 1MB
    public final Set<String> CDC_HEAVY_SOBJECTS = new Set<String>{
        'Simpplr_Content__c'
    }; 

    // Ṃaster list of all sobject types to be synced external on schedule basis
    public static final List<String> CDC_SCHEDULED_SOBJECTS = new List<String>{
        'User',
        'Profile',
        'EntitySubscription',
        'PackageLicense'
    };

    // This constant maintains the sobject types without IsDeleted field
    public final Set<String> CDC_SOBJECTS_WO_ISDELETED_FIELD = new Set<String>{
        'User',
        'Profile',
        'PackageLicense'
    };

    // Default SystemModstamp, declaration not required
    public final Map<String, String> CDC_SOBJECTS_STAMP_FIELD = new Map<String, String>{
        'EntitySubscription' => 'CreatedDate'
    };

    /** 
     * The sbjects which require clean up of deleted records in finish method
     * And does not support retrieval of deleted records via SOQL using ALL rows
     * And support replication ie. Database.getDeleted & Database.getUpdated
    */
    public final Set<String> CDC_SOBJECTS_DEL_PROCESS_REQ = new Set<String>{
        'EntitySubscription',
        'Profile'
    };

    public BatchPushExternalData(Boolean runNextBatchInSequence) {
        this.batchType = CDC_GENERAL_CATEGORY_SYNC;
        this.runNextBatchInSequence = runNextBatchInSequence;
    }

    public BatchPushExternalData(String batchType, Boolean runNextBatchInSequence) {
        this.batchType = batchType;
        this.runNextBatchInSequence = runNextBatchInSequence;
    }

    public BatchPushExternalData setRecordType(String recordType){
        this.recordType = recordType;
        return this;
    }

    public BatchPushExternalData setCDCStdObjects(List<String> cdcStdObjects){
        this.cdcStdObjects = cdcStdObjects;
        return this;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = '';
        if(CDC_STD_CATEGORY_SYNC.equalsIgnoreCase(batchType)){
            endTime = Datetime.now();
            // read custom setting to fetch last synced datetime
            startTime = getLastSyncDateTime();

            query = 'SELECT Id';
            if(!CDC_SOBJECTS_WO_ISDELETED_FIELD.contains(recordType)){
                query += ', IsDeleted';
            }

            query += ' FROM ' + String.escapeSingleQuotes(recordType);

            // default timestamp field
            String timeStampField = 'SystemModstamp';
            if(CDC_SOBJECTS_STAMP_FIELD.get(recordType) != null){
                timeStampField = CDC_SOBJECTS_STAMP_FIELD.get(recordType);
            }

            query += ' WHERE '+String.escapeSingleQuotes(timeStampField)+' >= :startTime AND '+String.escapeSingleQuotes(timeStampField)+' < :endTime';

            if(!CDC_SOBJECTS_WO_ISDELETED_FIELD.contains(recordType)){
                query += ' ALL ROWS';
            }
        }else{
            // CDC_GENERAL_CATEGORY_SYNC, CDC_HEAVY_CATEGORY_SYNC
            endTime = Datetime.now().addMinutes(CDC_BUFFER_TIME_IN_MINUTE);
            query = 'SELECT Id FROM External_Data_Trail__c WHERE Retry_Count__c < :CDC_MAX_RETRY_COUNT';

            if(CDC_GENERAL_CATEGORY_SYNC.equalsIgnoreCase(batchType)) {
                query += ' AND Type__c NOT IN :CDC_HEAVY_SOBJECTS';
            }else if(CDC_HEAVY_CATEGORY_SYNC.equalsIgnoreCase(batchType)) {
                query += ' AND Type__c IN :CDC_HEAVY_SOBJECTS';
            }
            
            if(!Test.isRunningTest()){
                query += ' AND CreatedDate < :endTime';
            }

            query += ' ORDER BY Sequence__c ASC';
        }
        logger.logDebug('query => '+ query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> listOfsObject) {
         try {
            logger.logDebug('BatchPushExternalData.execute() start => ' + batchType);
            if(CDC_STD_CATEGORY_SYNC.equalsIgnoreCase(batchType)){
                insertExternalDataTrail(listOfsObject);
            }else{
                List<External_Data_Trail__c> listOfDataTrialObj = (List<External_Data_Trail__c>) listOfsObject;
        
                List<Id> trailRecordIds = new List<Id>();
                for(External_Data_Trail__c trailObj: listOfDataTrialObj){
                    trailRecordIds.add(trailObj.Id);
                }
                logger.logDebug('trailRecordIds => ' + trailRecordIds);
                PushExternalDataV2.pushData(trailRecordIds);
                PushExternalDataHelper.updateTrailsRetryCount(trailRecordIds);
            }
        } catch (Exception exp) {
            logger.logError('BatchPushExternalData.execute()---Exception occured----', exp);

            throw exp;
        }
    }

    public void finish(Database.BatchableContext bc){
        logger.logDebug('BatchPushExternalData.finish batchType => ' + batchType);

        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors FROM AsyncApexJob WHERE Id = :bc.getJobId()];
		Boolean isSuccess = (job.Status == 'Completed' && job.NumberOfErrors == 0) ? true : false;
        logger.logDebug('BatchPushExternalData.finish isSuccess => ' + isSuccess);

        if(CDC_STD_CATEGORY_SYNC.equalsIgnoreCase(batchType) && isSuccess) {

            if(CDC_SOBJECTS_DEL_PROCESS_REQ.contains(recordType)){
                // Process deleted records if defined
                processDeletedRecords();
            }
            // For given record type, update custom setting with latest datetime
            saveSyncDateTime();
        }

        if(runNextBatchInSequence){
            if(CDC_GENERAL_CATEGORY_SYNC.equalsIgnoreCase(batchType)) {
                // Process heavy objects next after processing other objects with less batch size of 10
                BatchPushExternalData batchObj = new BatchPushExternalData(CDC_HEAVY_CATEGORY_SYNC, true);
                Database.executeBatch(batchObj, 10);
            } else if(CDC_HEAVY_CATEGORY_SYNC.equalsIgnoreCase(batchType)) {
                // Initialize all cdc standard objects to be synced externally before invoking batch
                cdcStdObjects = BatchPushExternalData.CDC_SCHEDULED_SOBJECTS.clone();
                // First time invoke of batch for std objects configured with CDC_SCHEDULED_SOBJECTS
                invokeBatchForSTDObjectsSync();
            } else if(CDC_STD_CATEGORY_SYNC.equalsIgnoreCase(batchType) 
                && cdcStdObjects != null 
                && !cdcStdObjects.isEmpty()) {
                    // sequencially invoke batch with new record time
                    // Number of times batch invoked depends on records in CDC_SCHEDULED_SOBJECTS. 
                    invokeBatchForSTDObjectsSync();
            }
        }
    }


    /**
    * @description Process deleted records to insert trail records works only for replication supported sobjects.
    **/
    public void processDeletedRecords(){
        // buffer time, its observed that records not retrieved instantly
        Datetime startDateTime = startTime.addMinutes(-5);

        //if startDateTime is more than 30 days ago, set it at 30 days + 5 minutes to avoid INVALID_REPLICATION_DATE 
        if(startDateTime < Datetime.now().addMinutes(-60*24*30)){
            startDateTime = Datetime.now().addMinutes((-60*24*30)+5);
        }
        // To avoid INVALID_REPLICATION_DATE: startDate before org replication enabled date
        if(Test.isRunningTest()){
            startDateTime = endTime.addMinutes(-1);
        }

        Database.GetDeletedResult deletedResult = Database.getDeleted(recordType, startDateTime, endTime);
        List<Database.DeletedRecord> deletedRecords = deletedResult.getDeletedRecords();

        if(deletedRecords != null && !deletedRecords.isEmpty()){
            Integer loopCounter = 0;
            Integer recordsLimit = 9000;
            Datetime lastRecordDeletedAt = endTime;
            Boolean applyRecordsLimit = deletedRecords.size() > recordsLimit ? true : false;

            Set<String> listOfDelIds = new Set<String>();
            for(Database.DeletedRecord deletedRecord :deletedRecords){
                // TODO process deleted record
                listOfDelIds.add(deletedRecord.getId());
                if(applyRecordsLimit){
                    lastRecordDeletedAt = deletedRecord.getDeletedDate();
                    if(loopCounter > recordsLimit){
                        break;
                    }
                    loopCounter += 1;
                }
            }

            if(applyRecordsLimit){
                endTime = lastRecordDeletedAt;
            }

            insertExternalDataTrail(listOfDelIds);
        }
    }

    /**
    * @description insert trail records to sync data to external service
    **/
    public void insertExternalDataTrail(List<sObject> listOfsObject) {
        String requestId = Request.getCurrent().getRequestId();
        // this is handled with batch size
        Boolean limitRecordsTobeSynced = false;
        List<External_Data_Trail__c> listToInsert = new List<External_Data_Trail__c>();		
        for(sObject sobj : listOfsObject) {
            External_Data_Trail__c trailObj = new External_Data_Trail__c(
                Input_Object_Id__c = sobj.Id, 
                Type__c = recordType, 
                Request_Id__c = requestId, 
                Operation_Type__c = 'AFTER_UPDATE',
                Is_Async_Context__c = limitRecordsTobeSynced
            );

            if(trailObj.isSet('IsDeleted') && trailObj.IsDeleted){
                trailObj.Operation_Type__c = 'AFTER_DELETE';
            }

            listToInsert.add(trailObj);
        } 

        if (Schema.sObjectType.External_Data_Trail__c.isCreateable() && listToInsert.isEmpty() == false) {

            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().insertAsUser(listToInsert, new List<Schema.SObjectField>{
                External_Data_Trail__c.Input_Object_Id__c,
                External_Data_Trail__c.Type__c,
                External_Data_Trail__c.Request_Id__c,
                External_Data_Trail__c.Operation_Type__c,
                External_Data_Trail__c.Is_Async_Context__c});
        }
    }

    /**
    * @description insert trail records to sync data to external service
    **/
    public void insertExternalDataTrail(Set<String> listOfDelIds) {
        String requestId = Request.getCurrent().getRequestId();
        // this is handled with batch size
        Boolean limitRecordsTobeSynced = false;
        List<External_Data_Trail__c> listToInsert = new List<External_Data_Trail__c>();		
        for(String recordId : listOfDelIds) {
            External_Data_Trail__c trailObj = new External_Data_Trail__c(
                Input_Object_Id__c = recordId, 
                Type__c = recordType, 
                Request_Id__c = requestId, 
                Operation_Type__c = 'AFTER_DELETE',
                Is_Async_Context__c = limitRecordsTobeSynced
            );
            listToInsert.add(trailObj);
        } 

        if (Schema.sObjectType.External_Data_Trail__c.isCreateable() && listToInsert.isEmpty() == false) {

            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().insertAsUser(listToInsert, new List<Schema.SObjectField>{
                External_Data_Trail__c.Input_Object_Id__c,
                External_Data_Trail__c.Type__c,
                External_Data_Trail__c.Request_Id__c,
                External_Data_Trail__c.Operation_Type__c,
                External_Data_Trail__c.Is_Async_Context__c});

        }
    }

    /**
    * @description Initialize batch class and set recordtype and remaining cdc std objects and execute
    **/
    private void invokeBatchForSTDObjectsSync(){
        BatchPushExternalData batchObj = new BatchPushExternalData(CDC_STD_CATEGORY_SYNC, true);
        logger.logDebug('cdcStdObjects => ' + cdcStdObjects);
        // remove first element and set as record type
        batchObj.setRecordType(cdcStdObjects.remove(0))
                .setCDCStdObjects(cdcStdObjects);
        logger.logDebug('cdcStdObjects => ' + cdcStdObjects);
        Database.executeBatch(batchObj, 100);
    }

    /**
    * @description update custom setting with latest synced datetime for given record type
    **/
    private void saveSyncDateTime(){
        if(keyValueSetting == null){
            keyValueSetting = new Key_Value_Setting__c(Name = 'CDC_SYNC_DT_' + recordType);
        }
        keyValueSetting.DateTime_Value__c = endTime;

        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        SIMPESAPI.accessController().upsertAsUser(new List<Key_Value_Setting__c>{keyValueSetting}, new List<Schema.SObjectField>{
            Key_Value_Setting__c.Name
        });
    }


    /**
    * @description return last sync datetime from CS else default value
    **/
    private Datetime getLastSyncDateTime(){
        // Initial default value, this value selected assuming historical migration takes max 5 hours
        // Extra buffer given to avoid missing of records, usually migration takes 1-2 hours.
        Datetime lastSyncDateTime = Datetime.now().addHours(-5);
        keyValueSetting = Key_Value_Setting__c.getInstance('CDC_SYNC_DT_' +recordType);
        if(keyValueSetting != null && keyValueSetting.DateTime_Value__c != null){
            lastSyncDateTime = keyValueSetting.DateTime_Value__c;
        }
        return lastSyncDateTime;
    }

}