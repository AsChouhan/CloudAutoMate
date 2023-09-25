public with sharing class SimpplrSiteTriggerHandler {
    public void OnBeforeInsert (List<Simpplr_Site__c> listOfNewSimpplrSites) {
    	
    	SimpplrSiteTriggerGatway.assignUncategorizedCategory(listOfNewSimpplrSites);
    }
    
    public void OnAfterInsert (Map<Id, Simpplr_Site__c> mapOfNewSimpplrSites) {
    	SimpplrSiteTriggerGatway.insertSiteRecord(mapOfNewSimpplrSites);
    	SimpplrSiteTriggerGatway.createPagesCategories(mapOfNewSimpplrSites);
    	SimpplrSiteTriggerGatway.disableAutoArchiveForCollaborationGroups(mapOfNewSimpplrSites);
    	if(!Test.isRunningTest() && Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
    		system.enqueueJob(new SimpplrSiteServices.QueueableCreateGroupMemberNQueueSobjectRecords(mapOfNewSimpplrSites.values()));
    	}
    }
    
    public void OnBeforeUpdate (Map<Id, Simpplr_Site__c> mapOfOldSimpplrSites, Map<Id, Simpplr_Site__c> mapOfNewSimpplrSites) {
    	SimpplrSiteTriggerGatway.assignUncategorizedCategory(mapOfNewSimpplrSites.values());
    	SimpplrSiteTriggerGatway.updateSubscriptions(mapOfOldSimpplrSites, mapOfNewSimpplrSites);
    }
    
    public void OnAfterUpdate (Map<Id, Simpplr_Site__c> mapOfOldSimpplrSites, 
			Map<Id, Simpplr_Site__c> mapOfNewSimpplrSites) {
    	SimpplrSiteTriggerGatway.resetMustReadRecordForSites(mapOfOldSimpplrSites,mapOfNewSimpplrSites);
    	SimpplrSiteTriggerGatway.expireOrDeleteAlerts(mapOfOldSimpplrSites,mapOfNewSimpplrSites);
    	SimpplrSiteTriggerGatway.updateIntegrationFolders(mapOfOldSimpplrSites,mapOfNewSimpplrSites);
    	SimpplrSiteTriggerGatway.shareTitleImageWithAllCompany(mapOfOldSimpplrSites,mapOfNewSimpplrSites);
    	SimpplrSiteTriggerGatway.updateSimpplrSiteShareRecords(mapOfOldSimpplrSites,mapOfNewSimpplrSites);
    	
    	if (SimpplrContext.isExternalSearchAppConnected) {
    		List<External_Search_Data_Trail__c> listToInsert = new List<External_Search_Data_Trail__c>();
    		
			for (Id siteId : mapOfNewSimpplrSites.keySet()) {

    			if (mapOfOldSimpplrSites.containsKey(siteId) && 
						(mapOfOldSimpplrSites.get(siteId).Last_Edited_DateTime__c < 
						mapOfNewSimpplrSites.get(siteId).Last_Edited_DateTime__c)){
    				External_Search_Data_Trail__c obj = new External_Search_Data_Trail__c();
		    		obj.Site__c = siteId;
		    		obj.Type__c = 'Site';
		    		listToInsert.add(obj);
    			}

    		}

    		if (listToInsert.size() > 0) {
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().insertAsUser(listToInsert, new List<Schema.SObjectField>{
						External_Search_Data_Trail__c.Site__c,
						External_Search_Data_Trail__c.Type__c
						});

    		}

    	} 
    	
    }
    
    public void OnBeforeDelete (Map<Id, Simpplr_Site__c> mapOfOldSimpplrSites) {
    	
    }
    
    public void OnAfterDelete (Map<Id, Simpplr_Site__c> mapOfOldSimpplrSites) {
    	
    }
    
}