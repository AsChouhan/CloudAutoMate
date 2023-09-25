trigger PagesCategory on Pages_Category__c (after insert, after update, after delete, after undelete) {
     try{
    	PagesCategoryHandler handler = new PagesCategoryHandler();

    	ObjectHandler objHandler = new ObjectHandler();
    	objHandler.triggerHandler('Pages_Category__c');
    	
    	if(Trigger.isInsert && Trigger.isAfter){
			handler.OnAfterInsert(Trigger.newMap);
	    }else if(Trigger.isUpdate && Trigger.isAfter){
	    	handler.OnAfterUpdate(Trigger.newMap);
	    }
    }catch (Exception e){
    	//Ignore excpetions
    }
}