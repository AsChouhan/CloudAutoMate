public with sharing class BatchInsertTilesConfig implements Database.Batchable<sObject>{
    String tileId;	
    
    public BatchInsertTilesConfig(String tileId){
    	this.tileId = tileId;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
    	String query;
    	String packageName = SimpplrContext.packageName;
    	String loggedInPeopleId = UserContext.peopleId;
    	String loggedInPeopleSegmentId = UserContext.segmentId;
		query = 'Select Id,user__c from People__c where User__r.UserType=\'Standard\' And User__r.isActive=true And id != :loggedInPeopleId and segment__c =:loggedInPeopleSegmentId ';
		query += ' and id in (select People__c from People_Preference__c where tiles_initialized__c=true) ';
		if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
		 	query = query + ' and user__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =:packageName)';
		}
		return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, sObject[] listOfsObject){
		List<People__c > listOfPeople = (List<People__c >)listOfsObject;
		createTilesToPushOnAllHomeDashboard(listOfPeople);
		updateOrderOfExistingTiles(listOfPeople);	
    }
    
    private void createTilesToPushOnAllHomeDashboard(List<People__c > listOfPeople){
		TileService tileServiceObj = new TileService();
		List<Tiles_Config__c> listOfTilesToInsert= new List<Tiles_Config__c>();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', tileId);
		String query = 'SELECT Id, Name__c, Type__c,Data__c, Variant__c FROM Tiles_Config__c Where id =:soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Tiles_Config__c> tileToPushOnAllHomeDashboard = (List<Tiles_Config__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		for (People__c pplObj : listOfPeople){
			Tiles_Config__c tileConfigObject = new Tiles_Config__c();
		
			tileConfigObject.Name__c = tileToPushOnAllHomeDashboard[0].Name__c;
			tileConfigObject.Data__c = tileToPushOnAllHomeDashboard[0].Data__c;
			tileConfigObject.Type__c = tileToPushOnAllHomeDashboard[0].Type__c;
			tileConfigObject.Variant__c = tileToPushOnAllHomeDashboard[0].Variant__c;
			tileConfigObject.Location__c = 'Home Dashboard';
			tileConfigObject.Layout_Column__c = 1;
			tileConfigObject.Order__c = 0;
			tileConfigObject.People__c=pplObj.Id;
			tileConfigObject.Is_Newly_Pushed__c = true;
			tileConfigObject.Variant_Type__c = tileToPushOnAllHomeDashboard[0].Variant__c+ '_' +tileToPushOnAllHomeDashboard[0].Type__c;
			listOfTilesToInsert.add(tileConfigObject);
    	}
		
		List<Schema.SObjectField> listOfColumnsToBeSet = new List<Schema.SObjectField>{Tiles_Config__c.Name__c,
																						Tiles_Config__c.Type__c,
																						Tiles_Config__c.Variant__c,
																						Tiles_Config__c.Data__c,
																						Tiles_Config__c.Location__c,
																						Tiles_Config__c.People__c,
																						Tiles_Config__c.Layout_Column__c,
																						Tiles_Config__c.Order__c,
																						Tiles_Config__c.Is_Newly_Pushed__c,
																						Tiles_Config__c.Variant_Type__c};
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().insertAsUser(listOfTilesToInsert, listOfColumnsToBeSet);
		
    }
    
    private void updateOrderOfExistingTiles(List<People__c > listOfPeople){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', listOfPeople);
			String query = 'Select Id, Order__c,People__c from Tiles_Config__c where Layout_Column__c = 1 And Is_Deleted__c = false And People__c = :soqlParam1 Order by People__c, Order__c, CreatedDate DESC';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Tiles_Config__c> userTilesList = (List<Tiles_Config__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
	    	Map<String, Integer> mapOfTileOrder = new Map<String, Integer>();
	    	Integer orderCount = 1;
	    	for(Tiles_Config__c userTileObj : userTilesList) {
	    		if(!mapOfTileOrder.containsKey(userTileObj.People__c)){
	    			mapOfTileOrder.put(userTileObj.People__c, 1);
	    		} else {
	    			mapOfTileOrder.put(userTileObj.People__c, mapOfTileOrder.get(userTileObj.People__c)+1);
	    		}
	    		userTileObj.Order__c = mapOfTileOrder.get(userTileObj.People__c);
				
	    	}
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
 		SIMPESAPI.accessController().updateAsUser(new Map<Id, Tiles_Config__c>(userTilesList),new List<Schema.SObjectField>{Tiles_Config__c.Order__c});
    }
    
    public void finish(Database.BatchableContext BC){}
}