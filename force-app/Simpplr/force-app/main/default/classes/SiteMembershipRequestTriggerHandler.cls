public with sharing class SiteMembershipRequestTriggerHandler {
    public void OnAfterInsert(Map<Id, Site_Membership_Request__c> newMap){
		OnAfterInsertOrUpdate(newMap);
	}
	
	public void OnAfterUpdate(Map<Id, Site_Membership_Request__c> newMap){
		OnAfterInsertOrUpdate(newMap);
	}
	 
     private void OnAfterInsertOrUpdate(Map<Id, Site_Membership_Request__c> newMap) {
		List<External_Search_Data_Trail__c> listToInsert = new List<External_Search_Data_Trail__c>();
        
        if(SimpplrContext.isExternalSearchAppConnected &&  
                SimpplrContext.isFeatureEnabled('Full_External_Search')) {

			for (Site_Membership_Request__c siteMemReqObj : newMap.values()) {
	    		External_Search_Data_Trail__c obj = new External_Search_Data_Trail__c();
	    		obj.Site_Membership_request__c = siteMemReqObj.Id;
	    		obj.Type__c = 'Site_Membership_Request';
	    		listToInsert.add(obj);
            }
            
			if(listToInsert.size() > 0) {
				List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
		
				fieldList.add(External_Search_Data_Trail__c.Site_Membership_request__c);
				fieldList.add(External_Search_Data_Trail__c.Type__c);

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().insertAsUser(listToInsert, fieldList);
			}
        }
        
	}
}