public with sharing class EventRSVPResponseTriggerHandler {
    public void onAfterInsert(Map<Id,Event_RSVP_Response__c> newMap){
		onAfterInsertOrUpdate(newMap);
	}
	
	public void onAfterUpdate(Map<Id,Event_RSVP_Response__c> newMap){
		onAfterInsertOrUpdate(newMap);
	}
	 
     private void onAfterInsertOrUpdate(Map<Id,Event_RSVP_Response__c> newMap) {
		List<External_Search_Data_Trail__c> listToInsert = new List<External_Search_Data_Trail__c>();
        
        if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {

			for (Event_RSVP_Response__c eventRSVPResponseObj : newMap.values()) {
	    		External_Search_Data_Trail__c obj = new External_Search_Data_Trail__c();
	    		obj.Event_RSVP_Response__c = eventRSVPResponseObj.Id;
	    		obj.Type__c = 'Event_RSVP_Response';
	    		listToInsert.add(obj);
            } 
			if(listToInsert.isEmpty() == false) {
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().insertAsUser(listToInsert,new List<Schema.SObjectField>
								{
									External_Search_Data_Trail__c.Event_RSVP_Response__c,
									External_Search_Data_Trail__c.Type__c
								});
			}
            
        }
        
	}

}