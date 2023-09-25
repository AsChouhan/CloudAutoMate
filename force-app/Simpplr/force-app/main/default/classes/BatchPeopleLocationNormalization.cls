public with sharing class BatchPeopleLocationNormalization implements Database.Batchable<SObject>, Database.AllowsCallouts  {

    public database.querylocator start(Database.BatchableContext bc){
		String query = 'SELECT id, Country__c, City__c, State__c, Street__c, raw_city__c, raw_state__c, raw_country__c, Location_Normalization_Status__c '
  				+ ' FROM People__c WHERE User__r.IsActive = true AND Location_Normalization_Status__c = null AND (City__c != null OR State__c != null OR Country__c != null)';
    	return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, sObject[] objects){
		List<People__c> peopleListToUpdate = (List<People__c>) objects;
		normalizeLocation(peopleListToUpdate);
}
    public void normalizeLocation(List<People__c> peopleListToUpdate) {
		try{
			MySettingDataServer mySetting = new MySettingDataServer();
			peopleListToUpdate = mySetting.getNormalizedLocation(peopleListToUpdate);

	    	if(peopleListToUpdate!=null && peopleListToUpdate.size()>0){
	    		//update updateSimpplrContent;
	    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
    			SIMPESAPI.accessController().updateAsUser(new Map<Id,People__c>(peopleListToUpdate),
				new List<Schema.SObjectField>{
					People__c.Country__c,
					People__c.City__c,
					People__c.State__c,
					People__c.raw_city__c,
					People__c.raw_state__c,
					People__c.raw_country__c,
					People__c.Location_Normalization_Status__c
				});
	    	}
    	}catch(Exception ex){
    		throw ex;
    	}

	} 
    public void finish(Database.BatchableContext bc){}
    
}