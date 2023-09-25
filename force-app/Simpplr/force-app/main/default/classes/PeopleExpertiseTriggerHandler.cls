public with sharing class PeopleExpertiseTriggerHandler {
    public void onAfterUpdate(Map<Id,People_Expertise__c> mapOfOldRecord, Map<Id,People_Expertise__c> mapOfNewRecord) {
        List<External_Search_Data_Trail__c> listToInsert = new List<External_Search_Data_Trail__c>();
        String mergeFrom = null; 
        String mergeTo = null;

        if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
            for(People_Expertise__c peopleExpertiseObj : mapOfNewRecord.values()){
                mergeFrom = mapOfNewRecord.get(peopleExpertiseObj.id).Expertise__c;
                mergeTo =  mapOfOldRecord.get(peopleExpertiseObj.id).Expertise__c;
            }
            
            if(mergeTo != mergeFrom) { 
                Map<String, Object> soqlParamMap = new Map<String, Object>();
                soqlParamMap.put('soqlParam1', mergeTo);
                soqlParamMap.put('soqlParam2', mergeFrom);
                String esdtQuery = 'Select Id, Merge_To__c, Merge_From__c From External_Search_Data_Trail__c where Merge_To__c =:soqlParam1 And Merge_From__c =:soqlParam2';
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                List<External_Search_Data_Trail__c> listToExternalSearchDataTrail = (List<External_Search_Data_Trail__c>)SIMPESAPI.accessController().queryAsUser(esdtQuery, soqlParamMap);
                if(listToExternalSearchDataTrail.isEmpty()) {
                    External_Search_Data_Trail__c obj = new External_Search_Data_Trail__c();
                    obj.Type__c = 'Merge_Expertise';
                    obj.Merge_To__c = mergeTo;
                    obj.Merge_From__c = mergeFrom;      
                    listToInsert.add(obj);
                    
                    List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
                    
                    if( !listToInsert.isEmpty()) {
                        fieldList.add(External_Search_Data_Trail__c.Type__c);
                        fieldList.add(External_Search_Data_Trail__c.Merge_To__c);
                        fieldList.add(External_Search_Data_Trail__c.Merge_From__c);

                        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                        SIMPESAPI.accessController().insertAsUser(listToInsert, fieldList);
                    }
                }
            }           
        }    
	}
}