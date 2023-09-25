trigger People on People__c (before insert, before update, after insert, after update, after delete, after undelete) {
    try {
    	PeopleTriggerHandler handler = new PeopleTriggerHandler();
		if(String.isBlank(SimpplrContext.packageName) || UserInfo.isCurrentUserLicensed(SimpplrContext.packageName)) {
			if(SimpplrContext.isATPeopleEnabled != null && SimpplrContext.isATPeopleEnabled) {

				ObjectHandler objHandler = new ObjectHandler();
				objHandler.triggerHandler('People__c');
				
				/* Before Insert */
			    if(Trigger.isBefore && Trigger.isInsert){
			        handler.OnBeforeInsert(Trigger.new);
			    
			    /* Before Update */
			    } else if(Trigger.isBefore && Trigger.isUpdate){
			        handler.OnBeforeUpdate(Trigger.oldMap, Trigger.newMap);
			    
			    /* After Insert */
			    } else 	if(Trigger.isAfter && Trigger.isInsert){
					handler.OnAfterInsert(Trigger.newMap);
			    
			    /* After Update */
			    }else if(Trigger.isAfter && Trigger.isUpdate){
					handler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
				}
		    }
	    }
	} catch (Exception ex) {
		//Ignore any exception coming in Trigger
	}
}