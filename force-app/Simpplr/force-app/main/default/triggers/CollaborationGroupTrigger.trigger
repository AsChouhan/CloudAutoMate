/**
* @Trigger [CollaborationGroup] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
trigger CollaborationGroupTrigger on CollaborationGroup (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
	try {
		if(String.isBlank(SimpplrContext.packageName) || UserInfo.isCurrentUserLicensed(SimpplrContext.packageName)) {
			if(SimpplrContext.isATCollaborationGroupEnabled != null && SimpplrContext.isATCollaborationGroupEnabled) {
				CollaborationGroupTriggerHandler handler = new CollaborationGroupTriggerHandler();

				ObjectHandler objHandler = new ObjectHandler();
				objHandler.triggerHandler('CollaborationGroup');
				
				/* Before Insert */
			    if(Trigger.isBefore && Trigger.isInsert){
			        handler.OnBeforeInsert(Trigger.new);
			    }
			    
			    /* After Insert */
			    else if(Trigger.isAfter && Trigger.isInsert){
			        List<String> contentObjectNameList = new List<String>();
					String packageName = String.isNotBlank(SimpplrContext.packageName) ? SimpplrContext.packageName + '__' : '';
					contentObjectNameList.add(packageName + 'Simpplr_Content__c');
					contentObjectNameList.add(packageName + 'Simpplr_Site__c');
			        CollaborationGroupTriggerHelper.createUserGroup(contentObjectNameList, Trigger.new);
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
	} catch (Exception ex) {
		//Ignore any exception coming in Trigger
		if(ex.getMessage().containsIgnoreCase('STORAGE_LIMIT_EXCEEDED')) {
			throw ex;
		}
	}    
}