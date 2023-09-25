public with sharing class SiteRoleTriggerHandler {
	public void OnBeforeInsert(List<Site_Role__c> newList) {
		for(Site_Role__c siteRole : newList) {
			siteRole.Unique_Id1__c = siteRole.Site__c + '' + siteRole.People__c;
		}
	}
	
	public void OnBeforeUpdate(List<Site_Role__c> newList) {
		for(Site_Role__c siteRole : newList) {
			if(siteRole.Is_Deleted__c) {
				siteRole.Unique_Id1__c = null;
			} else {
				siteRole.Unique_Id1__c = siteRole.Site__c + '' + siteRole.People__c;
			}
		}
	}

    public void OnAfterInsert(Map<Id,Site_Role__c> newMap){
		OnAfterInsertOrUpdate(newMap);
	}
	
	public void OnAfterUpdate(Map<Id,Site_Role__c> newMap){
		OnAfterInsertOrUpdate(newMap);
	}
	 
    private void OnAfterInsertOrUpdate(Map<Id,Site_Role__c> newMap) {
		 if(Utility.isSiteRoleUpdationFromMigration) {
			 return;
		 }
		List<External_Search_Data_Trail__c> listToInsert = new List<External_Search_Data_Trail__c>();
        
        if(SimpplrContext.isExternalSearchAppConnected && RecursionCheck.canIRun()) {

			for (Site_Role__c siteRoleObj : newMap.values()) {
	    		External_Search_Data_Trail__c obj = new External_Search_Data_Trail__c();
	    		obj.Site_Role__c = siteRoleObj.Id;
	    		obj.Type__c = 'Site_Role';
	    		listToInsert.add(obj);
            }

			if(listToInsert.size() > 0) {
				List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
		
				fieldList.add(External_Search_Data_Trail__c.Site_Role__c);
				fieldList.add(External_Search_Data_Trail__c.Type__c);

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().insertAsUser(listToInsert, fieldList);
			}
        }

		Set<Id> siteIds = new Set<Id>();

		for (Site_Role__c siteRoleObj : newMap.values()){
			siteIds.add(siteRoleObj.site__c);
		}
		Map<Id,Simpplr_Site__c> siteMap = new Map<Id,Simpplr_Site__c>([SELECT Id, Follower_Count__c, Member_Count__c FROM Simpplr_Site__c WHERE Id IN: siteIds ]);

		for (Id siteId : siteMap.keySet()) {
			siteMap.get(siteId).Follower_Count__c = 0;
			siteMap.get(siteId).Member_Count__c = 0;
		} 

		for(AggregateResult ar : [Select Site__c siteId, count(id) memberCount 
								FROM Site_Role__c WHERE Is_Deleted__c = false AND Is_Member__c = true AND Site__c in: siteMap.keyset()
								AND(People__r.User__r.Show_Simpplr__c = 'Yes' OR (People__r.User__r.Show_Simpplr__c != 'No' AND People__r.User__r.isActive = true)) 
								group by Site__c]) {
			
			siteMap.get((Id)ar.get('siteId')).Member_Count__c = (Integer)ar.get('memberCount');
		}

		for(AggregateResult ar : [Select Site__c siteId, count(id) followerCount 
								FROM Site_Role__c WHERE Is_Deleted__c = false AND Is_Member__c = false AND  site__c in: siteMap.keyset()
								AND (People__r.User__r.Show_Simpplr__c = 'Yes' OR (People__r.User__r.Show_Simpplr__c != 'No' AND People__r.User__r.isActive=true)) 
								group by Site__c]) {

			siteMap.get((Id)ar.get('siteId')).Follower_Count__c = (Integer)ar.get('followerCount');
		}
		
		update siteMap.values();
	}
}