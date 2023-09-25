public with sharing class ExpertiseTriggerHandler {
    public void onAfterInsert(Map<Id,Expertise__c> newMap){
		OnAfterInsertOrUpdate(newMap);
	}
	
	public void onAfterUpdate(Map<Id,Expertise__c> newMap){
		OnAfterInsertOrUpdate(newMap);
	}
	 
     private void onAfterInsertOrUpdate(Map<Id,Expertise__c> newMap) {
		List<External_Search_Data_Trail__c> listToInsert = new List<External_Search_Data_Trail__c>();
		List<External_Search_Data_Trail__c> listToInsertInReverseOrder = new List<External_Search_Data_Trail__c>();
        
        if(SimpplrContext.isFeatureEnabled('Full_External_Search') && RecursionCheck.canIRun()){
			for (Expertise__c expertiseObj : newMap.values()) {
	    		External_Search_Data_Trail__c obj = new External_Search_Data_Trail__c();
				obj.Expertise__c = expertiseObj.Id;
	    		obj.Type__c = 'Expertise';
				listToInsert.add(obj);
			} 
			if(listToInsert.isEmpty() == false) {
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().insertAsUser(listToInsert,new List<Schema.SObjectField>
								{
									External_Search_Data_Trail__c.Expertise__c,
									External_Search_Data_Trail__c.Type__c
								});
			}
            
        }
        
	}

	public void onAfterDelete(List<Expertise__c> expetiseList) {
		List<External_Search_Data_Trail__c> listToInsert = new List<External_Search_Data_Trail__c>();
		if(SimpplrContext.isFeatureEnabled('Full_External_Search') && RecursionCheck.canIRun()){
			for (Expertise__c expertiseObj : expetiseList) {
	    		External_Search_Data_Trail__c obj = new External_Search_Data_Trail__c();
				obj.Expertise__c = expertiseObj.Id;
				obj.Type__c = 'Expertise';
	    		listToInsert.add(obj);		
            } 
			if(listToInsert.isEmpty() == false) {
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().insertAsUser(listToInsert,new List<Schema.SObjectField>
								{
									External_Search_Data_Trail__c.Expertise__c,
									External_Search_Data_Trail__c.Type__c
								});
			} 
        }
        
	}
}