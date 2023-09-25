public with sharing class AlertTriggerHandler {
    public void OnAfterInsert(Map<Id,Alert__c> newMap){
		onAfterInsertOrUpdate(newMap);
	}
	
	public void OnAfterUpdate(Map<Id,Alert__c> newMap){
		onAfterInsertOrUpdate(newMap);
	}
	 
     private void onAfterInsertOrUpdate(Map<Id,Alert__c> newMap) {		
		List<External_Search_Data_Trail__c> listToInsert = new List<External_Search_Data_Trail__c>();
        if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {

			for (Alert__c AlertObj : newMap.values()) {
	    		External_Search_Data_Trail__c obj = new External_Search_Data_Trail__c();
	    		obj.Alert__c = AlertObj.Id;
	    		obj.Type__c = 'Alert';
	    		listToInsert.add(obj);
            }

			if ( !listToInsert.isEmpty() ) {
				List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();

 				fieldList.add(External_Search_Data_Trail__c.Alert__c);
 				fieldList.add(External_Search_Data_Trail__c.Type__c);

 				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
 				SIMPESAPI.accessController().insertAsUser(listToInsert, fieldList);
			}
        }
	}

	public void OnAfterDelete(List<Alert__c> alertList) {
		List<External_Search_Data_Trail__c> listToInsert = new List<External_Search_Data_Trail__c>();		
		if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			for (Alert__c AlertObj : alertList) {
	    		External_Search_Data_Trail__c obj = new External_Search_Data_Trail__c();
				obj.Alert__c = AlertObj.Id;
				obj.Type__c = 'Alert';
	    		listToInsert.add(obj);		
            }

			if ( !listToInsert.isEmpty() ) {
				List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();

 				fieldList.add(External_Search_Data_Trail__c.Alert__c);
 				fieldList.add(External_Search_Data_Trail__c.Type__c);

 				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
 				SIMPESAPI.accessController().insertAsUser(listToInsert, fieldList);
			}
        }
        
	}
}