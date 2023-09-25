trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert, after update, after delete, after undelete) {
    try {
		if(String.isBlank(SimpplrContext.packageName) || UserInfo.isCurrentUserLicensed(SimpplrContext.packageName)) {
	   		if(SimpplrContext.isATContentDocumentLinkEnabled != null && SimpplrContext.isATContentDocumentLinkEnabled) {
	   			ContentDocumentLinkTriggerHandler handler = new ContentDocumentLinkTriggerHandler();

	   			ObjectHandler objHandler = new ObjectHandler();
	   			objHandler.triggerHandler('ContentDocumentLink');
	   			
	   			if (Trigger.isAfter) {
	   				if (Trigger.isDelete) {
						handler.OnAfterDelete(Trigger.old);
						
			  		}else if (Trigger.isInsert){
						handler.OnAfterInsert(Trigger.new);
			   		}
	   			}
	   		}
		}
		 		
	} catch (Exception ex) {
		//Ignore any exception coming in Trigger
	}
}