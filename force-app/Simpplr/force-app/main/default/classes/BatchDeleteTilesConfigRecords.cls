public with sharing class BatchDeleteTilesConfigRecords implements Database.Batchable<SObject>{
    
    String peopleId;
    String batchType;

    public BatchDeleteTilesConfigRecords(String peopleId, String batchType){
        this.peopleId = peopleId;
        this.batchType = batchType;
    }
    
    public database.querylocator start(Database.BatchableContext bc){
    	String query = 'Select id, Data__c from Tiles_Config__c where Type__c= \'content\' And Variant__c = \'latest_popular\' ';
    	return database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> listOfsObject) {   
        if('googleCalendar'.equalsIgnoreCase(batchType)) {
            List<Tiles_Config__c> tilesConfigList =  (List<Tiles_Config__c>) listOfsObject;
            deleteGoogleCalendarTiles(tilesConfigList);
        }
    	
    }

    private void deleteGoogleCalendarTiles(List<Tiles_Config__c> tilesConfigList) {
        List<Tiles_Config__c> toBeDeletedList = new List<Tiles_Config__c>();
        for(Tiles_Config__c tileObj : tilesConfigList) {
            TileDataWrapper.TileDataSettings tiledataSettings = (TileDataWrapper.TileDataSettings)JSON.deserialize(tileObj.data__c, TileDataWrapper.TileDataSettings.class);
            if('googleCalendar'.equalsIgnoreCase(tiledataSettings.siteFilter)) {
                tileObj.is_deleted__c = true;
                toBeDeletedList.add(tileObj);
            }
        }
        if(!toBeDeletedList.isEmpty()) {
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().deleteAsUser(toBeDeletedList);
        }

    }
    
    public void finish(Database.BatchableContext bc) {    	
    }
}