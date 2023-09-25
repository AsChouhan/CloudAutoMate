public with sharing class TopicTriggerHandler {
    public void OnAfterInsert(Map<Id,Topic> newMap){
		OnAfterInsertOrUpdate(newMap);
	}
	
	public void OnAfterUpdate(Map<Id,Topic> newMap){
		OnAfterInsertOrUpdate(newMap);
	}
	 
     private void OnAfterInsertOrUpdate(Map<Id,Topic> newMap) {
		List<External_Search_Data_Trail__c> listToInsert = new List<External_Search_Data_Trail__c>();    
        if(SimpplrContext.isFeatureEnabled('Full_External_Search') && RecursionCheck.shouldIRun) {
			for(Topic topicObj : newMap.values()) {
	    		External_Search_Data_Trail__c obj = new External_Search_Data_Trail__c();
	    		obj.Topic__c = topicObj.Id;
	    		obj.Type__c = 'Topic';
	    		listToInsert.add(obj);
            }
			
			if(listToInsert.size() > 0) {
				List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
		
				fieldList.add(External_Search_Data_Trail__c.Topic__c);
				fieldList.add(External_Search_Data_Trail__c.Type__c);

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().insertAsUser(listToInsert, fieldList);
			}
        }     
	}

	public void OnAfterDelete(List<Topic> topicList) {
		List<External_Search_Data_Trail__c> listToInsert = new List<External_Search_Data_Trail__c>();
		if(SimpplrContext.isFeatureEnabled('Full_External_Search') && RecursionCheck.shouldIRun) {
			for(Topic topicObj : topicList) {
	    		External_Search_Data_Trail__c obj = new External_Search_Data_Trail__c();
				obj.Topic__c = topicObj.Id;
				obj.Type__c = 'Topic';
	    		listToInsert.add(obj);		
            }

			if(listToInsert.size() > 0) {
				List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
		
				fieldList.add(External_Search_Data_Trail__c.Topic__c);
				fieldList.add(External_Search_Data_Trail__c.Type__c);

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().insertAsUser(listToInsert, fieldList);
			}
        }   
	}
}