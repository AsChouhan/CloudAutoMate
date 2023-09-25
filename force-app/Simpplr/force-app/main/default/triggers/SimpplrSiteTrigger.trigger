/**
* @Trigger [Trigger Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
trigger SimpplrSiteTrigger on Simpplr_Site__c (before insert, before delete, before update, after insert, after update, after delete, after undelete) { 
	try {
		if(String.isBlank(SimpplrContext.packageName) || UserInfo.isCurrentUserLicensed(SimpplrContext.packageName)) {
			if(SimpplrContext.isATSimpplrSiteEnabled != null && SimpplrContext.isATSimpplrSiteEnabled) {
				SimpplrSiteTriggerHandler handler = new SimpplrSiteTriggerHandler();

				ObjectHandler objHandler = new ObjectHandler();
				objHandler.triggerHandler('Simpplr_Site__c');
				
				/* Before Insert */
			    if(Trigger.isBefore && Trigger.isInsert){
			        handler.OnBeforeInsert(Trigger.new);
			    }
			    
			    /* After Insert */
			    else if(Trigger.isAfter && Trigger.isInsert){
			        handler.OnAfterInsert(Trigger.newMap);
			    }
			    
			    /* Before Update */
			    else if(Trigger.isBefore && Trigger.isUpdate){
			        handler.OnBeforeUpdate(Trigger.oldMap, Trigger.newMap);
			    }
			    
			    /* After Update */
			    else if(Trigger.isAfter && Trigger.isUpdate){
			        handler.OnAfterUpdate(Trigger.oldMap, Trigger.newMap);
			    }
			    
			    /* Before Delete */
			    else if(Trigger.isBefore && Trigger.isDelete){
			        handler.OnBeforeDelete(Trigger.oldMap);
			    }
			    
			    /* After Delete */
			    else if(Trigger.isAfter && Trigger.isDelete){
			        handler.OnAfterDelete(Trigger.oldMap);
			    }
		    }
	    }
		CacheManagerUtil.clearCacheContainsKey(ServiceConstants.CACHE_CAROUSEL);
	} catch (Exception ex) {
		//Ignore any exception coming in Trigger
	}
}