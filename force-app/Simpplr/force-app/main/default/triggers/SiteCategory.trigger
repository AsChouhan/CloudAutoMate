trigger SiteCategory on Site_Category__c (after insert, after update, after delete, after undelete) {
     try{
    	SiteCategoryHandler handler = new SiteCategoryHandler();

    	ObjectHandler objHandler = new ObjectHandler();
    	objHandler.triggerHandler('Site_Category__c');
    	
    	if(Trigger.isInsert && Trigger.isAfter){
			handler.onAfterInsert(Trigger.newMap);
	    }else if(Trigger.isUpdate && Trigger.isAfter){
	    	handler.onAfterUpdate(Trigger.newMap);
	    }
    }catch (Exception e){
    	//Ignore excpetions
    }
}