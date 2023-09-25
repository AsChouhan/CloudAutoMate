public with sharing class PagesCategoryHandler {
	
	public void OnAfterInsert(Map<Id,Pages_Category__c> newMap){
		OnAfterInsertOrUpdate(newMap);
	}
	
	public void OnAfterUpdate(Map<Id,Pages_Category__c> newMap){
		OnAfterInsertOrUpdate(newMap);
	}
	
     private void OnAfterInsertOrUpdate(Map<Id,Pages_Category__c> newMap) {
		List<External_Search_Data_Trail__c> listToInsert = new List<External_Search_Data_Trail__c>();
		if(SimpplrContext.isExternalSearchAppConnected){
			for(Pages_Category__c pagesCategory : newMap.values()) {
	    		External_Search_Data_Trail__c obj = new External_Search_Data_Trail__c();
	    		obj.Pages_Category__c = pagesCategory.Id;
	    		obj.Type__c = 'Pages_Category';
	    		listToInsert.add(obj);
	    	}
			
			if(listToInsert.size() > 0) {
				List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
		
				fieldList.add(External_Search_Data_Trail__c.Pages_Category__c);
				fieldList.add(External_Search_Data_Trail__c.Type__c);

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().insertAsUser(listToInsert, fieldList);
			}
		}
	}
}