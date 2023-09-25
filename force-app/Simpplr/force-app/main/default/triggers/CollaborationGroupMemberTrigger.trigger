/**
* @Trigger [Trigger Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
trigger CollaborationGroupMemberTrigger on CollaborationGroupMember (after delete, after insert, after undelete,after update, before delete, before insert, before update){
	try {
		if(String.isBlank(SimpplrContext.packageName) || UserInfo.isCurrentUserLicensed(SimpplrContext.packageName)) {
			if(SimpplrContext.isATCollaborationGroupMemberEnabled != null && SimpplrContext.isATCollaborationGroupMemberEnabled) {
				CollaborationGroupMemberTriggerGatway handler = new CollaborationGroupMemberTriggerGatway();
				
				ObjectHandler objHandler = new ObjectHandler();
				objHandler.triggerHandler('CollaborationGroupMember');
			
			    /* Before Insert */
			    if(Trigger.isInsert && Trigger.isBefore){
			        handler.OnBeforeInsert(Trigger.new); 
			    }
			    /* After Insert */
			    else if(Trigger.isInsert && Trigger.isAfter){
			        handler.OnAfterInsert([select id,MemberId,CollaborationGroupId,CollaborationRole,CollaborationGroup.OwnerId from CollaborationGroupMember where Id IN :Trigger.new]);
			    }
			    /* Before Update */
			    else if(Trigger.isUpdate && Trigger.isBefore){
			        handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
			    }
			    /* After Update */
			    else if(Trigger.isUpdate && Trigger.isAfter){
			        handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap,Trigger.oldMap);
			    }
			    /* Before Delete */
			    else if(Trigger.isDelete && Trigger.isBefore){
			        handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
			    }
			    /* After Delete */
			    else if(Trigger.isDelete && Trigger.isAfter){ 
			        handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
			    }
			
			    /* After Undelete */
			    else if(Trigger.isUnDelete){
			        handler.OnUndelete(Trigger.new);
			    }
			}
		}
	} catch (Exception ex) {
		//Ignore any exception coming in Trigger
	}
}