trigger ContentDocumentTrigger on ContentDocument (before delete, after insert, after update, after delete, after undelete) {
	try {
		if(String.isBlank(SimpplrContext.packageName) || UserInfo.isCurrentUserLicensed(SimpplrContext.packageName)) {
	   		if(SimpplrContext.isATContentDocumentEnabled != null && SimpplrContext.isATContentDocumentEnabled) {
			   ContentDocumentTriggerHandler handler = new ContentDocumentTriggerHandler();

			   ObjectHandler objHandler = new ObjectHandler();
			   objHandler.triggerHandler('ContentDocument');
			   
			    if (Trigger.isBefore && Trigger.isDelete) {
					handler.OnBeforeDelete(Trigger.old);

			    } else if (Trigger.isUpdate && Trigger.isAfter){
					handler.OnAfterUpdate(Trigger.new);

			    } else if (Trigger.isDelete && Trigger.isAfter) {
                    handler.OnAfterDelete(Trigger.old);
                }
	   		}
		}
		 		
	} catch (Exception ex) {
		//Ignore any exception coming in Trigger
	}
}