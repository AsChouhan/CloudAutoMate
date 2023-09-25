global with sharing class BatchChangingStatus implements Database.Batchable<SObject>  {
    global string query;
    
    public BatchChangingStatus(string query){
        this.query=query;
    }
    
    global database.querylocator start(Database.BatchableContext bc){
    	return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, sObject[] objects){
    	try{
    		List<Simpplr_Content__c> updateSimpplrContent = new List<Simpplr_Content__c>();
	    	for(Simpplr_Content__c simpplrContentobj:(List<Simpplr_Content__c>) objects){
				updateSimpplrContent.add(new Simpplr_Content__c(id=simpplrContentobj.id, Status__c=ServiceConstants.CONTENT_STATUS_INACTIVE));
	    	}
	    	if(updateSimpplrContent!=null && updateSimpplrContent.size()>0){
	    		//update updateSimpplrContent;
	    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
    			SIMPESAPI.accessController().updateAsUser(new Map<Id,Simpplr_Content__c>(updateSimpplrContent),new List<Schema.SObjectField>{
    													Simpplr_Content__c.Status__c});
	    	}
    	}catch(Exception ex){
    		throw ex;
    	}
    }
    
    global void finish(Database.BatchableContext bc){}
    
}