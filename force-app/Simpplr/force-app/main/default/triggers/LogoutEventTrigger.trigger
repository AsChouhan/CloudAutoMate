trigger LogoutEventTrigger on LogoutEventStream (after insert) {
    try {
        LogoutEventTriggerHandler handler = new LogoutEventTriggerHandler();
         /* After Insert */
		if(Trigger.isAfter && Trigger.isInsert){
			handler.OnAfterInsert(Trigger.new[0]);
        }

    } catch (Exception e) {
        // Ignore exceptions
    }
}