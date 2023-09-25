public class PushExternalDataV2 {

    
    @InvocableMethod(label='Push External Data V2')
    public static void pushData(List<Id> propertyId) {
        try {
            logger.logInfo('InvocableMethod PushExternalDataV2.getUserId => ' + UserInfo.getUserId());
            logger.logInfo('PushExternalDataV2.propertyId => ' + propertyId);
            //Ensure external sync enabled and initial load completed
            if(SimpplrContext.isExternalDataSyncEnabled && SimpplrContext.isFlowExternalSyncEnabled){
                logger.logInfo('PushExternalDataV2.isExternalDataSyncEnabled => ' + SimpplrContext.isExternalDataSyncEnabled);
                logger.logInfo('PushExternalDataV2.isFlowExternalSyncEnabled => ' + SimpplrContext.isFlowExternalSyncEnabled);
                pushDataToExternalService(propertyId);
            }
        } catch (Exception exp) {
            logger.logError('PushExternalDataV2.pushData()---Exception occured----', exp);
        }
        try {
            logger.flushLogsToDB();    
        } catch (Exception e) {
            System.debug('Exception - ' + e.getMessage());
            // Do not want to log this exception 
        }
    }

    public static void pushDataToExternalService(List<Id> trailRecordIds){
        // 01 Fetch trail records
        logger.logInfo('PushExternalDataV2.pushDataToExternalService => ' + trailRecordIds);
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1', trailRecordIds);
        String queryStr = 'SELECT Id, Type__c, Input_Object_Id__c, Request_Id__c, Operation_Type__c, Is_Async_Context__c FROM External_Data_Trail__c WHERE Id IN :soqlParam1 ORDER BY Sequence__c ASC';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<External_Data_Trail__c> listOfDataTrailObj = (List<External_Data_Trail__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);

        logger.logInfo('PushExternalDataV2.listOfDataTrailObj => ' + JSON.serialize(listOfDataTrailObj));
        Map<String, CDCModel.EventHeader> mapEventHeaders = new Map<String, CDCModel.EventHeader>();

        // 02 Group record Ids by record type
        if(listOfDataTrailObj != null && !listOfDataTrailObj.isEmpty()){

            Integer loopCounter = 0;
            Boolean limitRecordsTobeSynced = false;

            logger.logInfo('PushExternalDataV2.System.isBatch() => ' + System.isBatch());
            // If this method invoked from batch, dont not limit the records to be sync
            // System.isBatch flag alway false if this method invoked from flow action
            if(!System.isBatch()){
                //Fetch the context from trail records, if true limit to number of records to 10 to avoid heap errors. The skipped records will be processed separately by the batch
                limitRecordsTobeSynced = listOfDataTrailObj[0].Is_Async_Context__c;
                logger.logInfo('PushExternalDataV2.limitRecordsTobeSynced => ' + limitRecordsTobeSynced);
            }

            for(External_Data_Trail__c trailObj: listOfDataTrailObj){
                if(String.isNotBlank(trailObj.Input_Object_Id__c) && String.isNotBlank(trailObj.Type__c)){
                    String recordType = trailObj.Type__c;
                    String key = trailObj.Request_Id__c + '~' + recordType + '~' + trailObj.Operation_Type__c;
                    CDCModel.EventHeader eventHeader = mapEventHeaders.get(key);
                    if(eventHeader != null){
                        eventHeader.recordIds.add(trailObj.Input_Object_Id__c);
                    }else{
                        eventHeader = new CDCModel.EventHeader();
                        eventHeader.requestId = trailObj.Request_Id__c;
                        eventHeader.recordType = recordType;
                        eventHeader.operationType = trailObj.Operation_Type__c;
                        eventHeader.recordIds.add(trailObj.Input_Object_Id__c);
                    }
                    mapEventHeaders.put(key, eventHeader);
                    loopCounter = loopCounter + 1;

                    if(limitRecordsTobeSynced == true 
                        && loopCounter > PushExternalDataHelper.CDC_ASYNC_RECORDS_SYNC_LIMIT){
                        break;
                    }
                }
            }
        }

        // release heap memory
        listOfDataTrailObj.clear();

        // 03 Fetch records via soql for all record types
        PushExternalDataHelper pushHelper = new PushExternalDataHelper();
        List<CDCModel.Event> listCDCEvents = pushHelper.getEventsData(mapEventHeaders);

        // 04 Make process callout to external service
        if(listCDCEvents != null && !listCDCEvents.isEmpty()){
            String body = JSON.serialize(listCDCEvents);
            // release heap memory
            listCDCEvents.clear();
            PushExternalDataService pushObj = new PushExternalDataService(body, trailRecordIds);
            pushObj.execute();
        }
        logger.logInfo('PushExternalDataV2.pushObj.execute() DONE');
    }

}