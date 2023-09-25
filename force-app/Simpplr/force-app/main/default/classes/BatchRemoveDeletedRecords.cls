public with sharing class BatchRemoveDeletedRecords implements Database.Batchable<SObject>  {
	
	public string query;
	
	public BatchRemoveDeletedRecords(string query){
        this.query=query;
    }
    
	public database.querylocator start(Database.BatchableContext bc){
    	return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, sObject[] objects){
    	try{
	    	if(objects.size() > 0) {
	    		//delete objects;
	    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
    			SIMPESAPI.accessController().deleteAsUser(objects);
	    	}
    	}catch(Exception ex){
    	}
    }
    
    public void finish(Database.BatchableContext bc){}
}