public with sharing class SiteCategoryHandler {
	
	public void onAfterInsert (Map<Id,Site_Category__c> newMap) {
		onAfterInsertOrUpdate(newMap);
	}
	
	public void onAfterUpdate (Map<Id,Site_Category__c> newMap) {
		onAfterInsertOrUpdate(newMap);
	}
    
    private void onAfterInsertOrUpdate (Map<Id,Site_Category__c> newMap) {
		List<External_Search_Data_Trail__c> listToInsert = new List<External_Search_Data_Trail__c>();

		if (SimpplrContext.isExternalSearchAppConnected) {

			for (Site_Category__c siteCategory : newMap.values()) {
	    		External_Search_Data_Trail__c obj = new External_Search_Data_Trail__c();
	    		obj.Site_Category__c = siteCategory.Id;
	    		obj.Type__c = 'Site_Category';
	    		listToInsert.add(obj);
    		}

			if(listToInsert.size() > 0) {
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().insertAsUser(listToInsert, new List<Schema.SObjectField>{
						External_Search_Data_Trail__c.Site_Category__c,
						External_Search_Data_Trail__c.Type__c
				});
			}
		}

	}

}