public with sharing class PeopleCategoryTriggerHandler {
	
	public void onAfterInsert(Map<Id,People_Category__c> newMap) {
		onAfterInsertOrUpdate(newMap);
	}
	
	public void onAfterUpdate(Map<Id,People_Category__c> newMap) {
		onAfterInsertOrUpdate(newMap);
	}
	
	private void onAfterInsertOrUpdate(Map<Id,People_Category__c> newMap) {
		List<External_Search_Data_Trail__c> listToInsert = new List<External_Search_Data_Trail__c>();
		if(SimpplrContext.isExternalSearchAppConnected){
			for(People_Category__c pplCategory : newMap.values()) {
	    		External_Search_Data_Trail__c obj = new External_Search_Data_Trail__c();
	    		obj.People_Category__c = pplCategory.Id;
	    		obj.Type__c = 'People_Category';
	    		listToInsert.add(obj);
    		}
			if(listToInsert.isEmpty() == false) {
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().insertAsUser(listToInsert,new List<Schema.SObjectField>
								{
									External_Search_Data_Trail__c.People_Category__c,
									External_Search_Data_Trail__c.Type__c
								});
			}
		}
	}
}