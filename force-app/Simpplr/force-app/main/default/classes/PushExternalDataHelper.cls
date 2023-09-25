public without sharing class PushExternalDataHelper {



    public static final String CDC_DELETE_EVENT = 'DELETE';
    public static final String CDC_SERVICE_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/cdc/realtime-sync';

    public static final Integer CDC_ASYNC_RECORDS_SYNC_LIMIT = 10;
    
	// Maintain the case same as salesforce
    public static final Map<String, List<String>> MAP_PARENT_CHILD_SOBJECTS = new Map<String, List<String>>{
        'FeedItem' => new List<String>{
            'FeedItemId~FeedPollChoice'
        }
    };

    // Ensure to keep the fields in lower case and object names same as salesforce
    public static final Map<String, Set<String>> MAP_SOBJECT_FILTER_OUT_FIELDS = new Map<String, Set<String>>{
        'ContentVersion' => new Set<String>{
            'versiondata'
        }
    };

    // Ensure to keep case of object same as salesforce
    public static final Map<String, String> MAP_CDC_OPERATION_TYPE = new Map<String, String>{
        'AFTER_INSERT' => 'INSERT',
        'AFTER_UPDATE' => 'UPDATE',
        'AFTER_DELETE' => 'DELETE',
        'AFTER_UNDELETE' => 'INSERT'
    };

    public List<CDCModel.Event> getEventsData(Map<String, CDCModel.EventHeader> mapEventHeaders){

        List<CDCModel.Event> listCDCEvents = new List<CDCModel.Event>();
        // Ensure max records types per transaction are less than 5 to avoid more loops
        for(CDCModel.EventHeader eventHeader: mapEventHeaders.values()){
            CDCModel.Event cdcEvent = new CDCModel.Event();
            cdcEvent.header = eventHeader;
            cdcEvent.header.operationType = PushExternalDataHelper.MAP_CDC_OPERATION_TYPE.get(eventHeader.operationType);
            
            if(cdcEvent.header.operationType != PushExternalDataHelper.CDC_DELETE_EVENT){
                cdcEvent.records = getRecords(eventHeader.recordType, eventHeader.recordIds);
                if(cdcEvent.records != null && !cdcEvent.records.isEmpty()){
                    listCDCEvents.add(cdcEvent);
                }
            }else{
                listCDCEvents.add(cdcEvent);
            }

            // Get the related child records if defined
            if(PushExternalDataHelper.MAP_PARENT_CHILD_SOBJECTS.containsKey(eventHeader.recordType)){
                setEventsDataChild(listCDCEvents, cdcEvent.header);
            }
        }
        return listCDCEvents;
    }

    public void setEventsDataChild(List<CDCModel.Event> listCDCEvents, CDCModel.EventHeader parentEventHeader){
        // Get the related child records if defined
        List<String> childsObjectTypes = PushExternalDataHelper.MAP_PARENT_CHILD_SOBJECTS.get(parentEventHeader.recordType);
        if(childsObjectTypes != null && !childsObjectTypes.isEmpty()){
            for(String childDetailsStr: childsObjectTypes){
                List<String> listchildDetails = childDetailsStr.split('~');
                String parentReference = listchildDetails[0];
                String childRecordType = listchildDetails[1];

                CDCModel.Event cdcEvent = new CDCModel.Event();
                cdcEvent.header.requestId = parentEventHeader.requestId;
                cdcEvent.header.recordType = childRecordType;
                cdcEvent.header.operationType = parentEventHeader.operationType;

                if(cdcEvent.header.operationType != PushExternalDataHelper.CDC_DELETE_EVENT){
                    Map<Id, sObject> listRecordsMap = getRecordsChild(cdcEvent.header, parentReference, false);
                    cdcEvent.records = listRecordsMap.values();
                    cdcEvent.header.recordIds = new Set<String>((List<String>) new List<Id>(listRecordsMap.keySet()));
                    listCDCEvents.add(cdcEvent);
                }else{
                    CDCModel.Child dependentChild = new CDCModel.Child();
                    dependentChild.recordType = childRecordType;
                    dependentChild.parentReference = parentReference;
                    parentEventHeader.dependentChildObjects.add(dependentChild);
                }
            }
        }
    }

    /**
    * @description retrieve records for given recordtype
    * @param recordType record type
    * @param recordIds record ids
    * @return List<sObject> records retrieved via soql
    **/
    public List<sObject> getRecords(String recordType, Set<String> recordIds){
        List<sObject> listRecords = new List<sObject>();
        
        if(recordIds != null && !recordIds.isEmpty()){
            // retrieve deleted records as well 
            SObjectType sObjType = getSObjectType(recordType);
            List<String> listFields = getsObjectFields(sObjType, recordType);

            String queryStr = getQuery(recordType, listFields);
            queryStr += ' WHERE Id IN :recordIds';
            if(SimpplrContext.isCommunitiesEnabled && listFields.contains('networkid')){
                queryStr = queryStr + ' AND NetworkId = null';
            }
            listRecords = (List<sObject>)Database.query(queryStr);
        }

        return listRecords;
    }

    /**
    * @description retrieve child records for given recordtype
    * @param childRecordType record type
    * @param parentReference record ids
    * @param parentRecordIds record ids
    * @return List<sObject> records retrieved via soql
    **/
    public Map<Id, sObject> getRecordsChild(CDCModel.EventHeader eventHeader, String parentReference, Boolean includeDeleted){
        Map<Id, sObject> listRecordsMap = new Map<Id, sObject>();

        if(eventHeader.recordIds != null && !eventHeader.recordIds.isEmpty()){
            // retrieve deleted records as well 
            String queryStr = '';
            SObjectType sObjType = getSObjectType(eventHeader.recordType);
            List<String> listFields = getsObjectFields(sObjType, eventHeader.recordType);
            if(includeDeleted != true){
                queryStr = getQuery(eventHeader.recordType, listFields);
                queryStr += ' WHERE ' + String.escapeSingleQuotes(parentReference) + ' IN :eventHeader.recordIds';
                if(SimpplrContext.isCommunitiesEnabled && listFields.contains('networkid')){
                    queryStr = queryStr + ' AND NetworkId = null';
                }
            }else{
                queryStr = 'SELECT Id FROM ' + String.escapeSingleQuotes(eventHeader.recordType);
                queryStr += ' WHERE ' + String.escapeSingleQuotes(parentReference) + ' IN :eventHeader.recordIds ALL ROWS';
                if(SimpplrContext.isCommunitiesEnabled && listFields.contains('networkid')){
                    queryStr = queryStr + ' AND NetworkId = null';
                }
                queryStr += ' ALL ROWS';
            }
            listRecordsMap = new Map<Id, sObject>(Database.query(queryStr));
        }

        return listRecordsMap;
    }

    /**
    * @description get sobject type for given record type in string
    * @param typeStr input record type in string
    * @return SObjectType sobject type
    **/
    public SObjectType getSObjectType(String typeStr){
        return ((SObject)Type.forName(typeStr).newInstance()).getSObjectType();
    }

    /**
    * @description returns fields for given sobject type
    * @param sObjType input sobject type
    * @param recordType input sobject name
    * @return List<String> list of fields
    **/
    public List<String> getsObjectFields(SObjectType sObjType, String recordType){
        //This gives field names in lowercase
        Set<String> setFields = sObjType.getDescribe().fields.getMap().keySet();
        // Remove some fields data sync to external service
        if(PushExternalDataHelper.MAP_SOBJECT_FILTER_OUT_FIELDS.containsKey(recordType)){
            Set<String> setFilterOutFields = PushExternalDataHelper.MAP_SOBJECT_FILTER_OUT_FIELDS.get(recordType);
            if(setFilterOutFields != null && !setFilterOutFields.isEmpty()){
                setFields.removeAll(setFilterOutFields);
            }
        }
        return new List<String>(setFields);
    }

    /**
    * @description get query string with all fields for given object name and fields
    * @param recordType object name
    * @param listFields list Fields
    * @return String query string
    **/
    public String getQuery(String recordType, List<String> listFields) {
        String queryStr = 'SELECT ' + String.join(listFields,',') + ' FROM ' + String.escapeSingleQuotes(recordType);
        return queryStr;
    }


    // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // Static methods - START
    // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    /**
    * @description This method used to delete trail records post data push to external service
    * @param trailRecordIds trail record ids
    **/
    public static void deleteTrails(List<String> trailRecordIds){
        List<External_Data_Trail__c> listOfDataTrialObj = [SELECT Id FROM External_Data_Trail__c WHERE Id IN :trailRecordIds];

        if(listOfDataTrialObj != null && !listOfDataTrialObj.isEmpty()){

            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().deleteAsUser(listOfDataTrialObj);
        }
    }

    /**
    * @description This method used to increment the retry count
    * @param trailRecordIds trail record ids
    **/
    public static void updateTrailsRetryCount(List<Id> trailRecordIds){
        List<External_Data_Trail__c> listOfDataTrialObj = [SELECT Id, Retry_Count__c FROM External_Data_Trail__c WHERE Id IN :trailRecordIds];

        for(External_Data_Trail__c trailObj: listOfDataTrialObj){
            trailObj.Retry_Count__c  = trailObj.Retry_Count__c != null ? (trailObj.Retry_Count__c + 1) : 1;
        }

        if(listOfDataTrialObj != null && !listOfDataTrialObj.isEmpty()){
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, External_Data_Trail__c>(listOfDataTrialObj), new List<Schema.SObjectField>{
                External_Data_Trail__c.Retry_Count__c
            });
        }
    }

}