/**
* @description handler class for Tiles_Config Trigger
*/
public with sharing class TilesConfigTriggerHandler {
    /**
    * @description run for after insert trigger
    * @param newMap
    */
    public void onAfterInsert(Map<Id,Tiles_Config__c> newMap){
        onAfterInsertOrUpdate(newMap);
    }
    
    /**
    * @description run for after update trigger
    * @param newMap
    */
    public void onAfterUpdate(Map<Id,Tiles_Config__c> newMap){
        onAfterInsertOrUpdate(newMap);
    }
    
    private void onAfterInsertOrUpdate(Map<Id,Tiles_Config__c> newMap) {
        List<External_Search_Data_Trail__c> listToInsert = new List<External_Search_Data_Trail__c>();
        Set<String> setOfTileType = new Set<String>{'links', 'html', 'site_info'};
        if(RecursionCheck.canIRun()) {

            for (Tiles_Config__c tilesConfigObj : newMap.values()) {
                if(String.isNotBlank(tilesConfigObj.Type__c) && setOfTileType.contains(tilesConfigObj.Type__c.toLowerCase())) {
                    External_Search_Data_Trail__c obj = new External_Search_Data_Trail__c();
                    obj.Tiles_Config__c = tilesConfigObj.Id;
                    obj.Type__c = 'Tiles';
                    listToInsert.add(obj);
                }
            }

            if(listToInsert.size() > 0) {
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                SIMPESAPI.accessController().insertAsUser(listToInsert, 
                    new List<Schema.SObjectField>{
                        External_Search_Data_Trail__c.Tiles_Config__c,
                        External_Search_Data_Trail__c.Type__c
                    });
            }
        }
    }
}