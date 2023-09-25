trigger PeopleExpertise on People_Expertise__c (after insert, after update, after delete, after undelete) {
    try {
    	PeopleExpertiseTriggerHandler handler = new PeopleExpertiseTriggerHandler();

    	ObjectHandler objHandler = new ObjectHandler();
    	objHandler.triggerHandler('People_Expertise__c');
    	
		if(Trigger.isAfter && Trigger.isUpdate){
			handler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
	    }
	} catch (Exception ex) {
		//Ignore any exception coming in Trigger
	}
}