public without sharing class BatchSiteDataSync implements Database.Batchable<SObject>, Database.stateful {
    private Exception exceptionDetailsObj;
    	
    public database.querylocator start(Database.BatchableContext bc){
    	
    	String query = ' SELECT Id, Chatter_Group_Id__c, Site_Type__c, Is_Active__c, Is_Deleted__c, ' +
    				   ' Site_Category__c ' +
    				   ' from Simpplr_Site__c ' +
    				   ' where Is_Deleted__c = false And chatter_Group_Id__c != \'S06I000000MPPLR\' ';
    				    
    	return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, sObject[] objects){
    	try{
		    	List<Simpplr_Site__c> listOfSites = (List<Simpplr_Site__c>)objects;
		    	List<String> listOfCollaborationGroupIds = new List<String>(); 
		
		    	for(Simpplr_Site__c siteObject : listOfSites) {
		    		listOfCollaborationGroupIds.add(siteObject.Chatter_Group_Id__c);
		    	}
		    	Map<Id, CollaborationGroup> mapOfCollaborationGroup = new Map<Id, CollaborationGroup>([select id, IsArchived, CollaborationType 
		    															   from CollaborationGroup where id=:listOfCollaborationGroupIds]);
		    	
		    	List<Simpplr_Site__c> listOfUpdatedSites = new List<Simpplr_Site__c>();
		    	for(Simpplr_Site__c siteObject : listOfSites) {
		    		CollaborationGroup cgObject = mapOfCollaborationGroup.get(siteObject.Chatter_Group_Id__c);
		    		if(cgObject == null) {
		    			
		    			siteObject.Is_Active__c = false;
		    			siteObject.Is_Deleted__c = true;
		    			siteObject.Site_Category__c = null;
		    			listOfUpdatedSites.add(siteObject);
		    			
		    		} else if(siteObject.Is_Active__c == cgObject.IsArchived || 
		    				  cgObject.CollaborationType.equalsIgnoreCase(siteObject.Site_Type__c) == false) {
		    			
		    			siteObject.Is_Active__c = !cgObject.IsArchived;
		    			siteObject.Site_Type__c = cgObject.CollaborationType;
		    			if(siteObject.Is_Active__c == false) {
							siteObject.Site_Category__c = null;
						}
		    			listOfUpdatedSites.add(siteObject);
		    		}
		    	}
		    	if(listOfUpdatedSites.size() > 0) {
		    		update listOfSites;
		    	}
    		}catch(Exception ex) {
    		exceptionDetailsObj =  ex;
    		throw ex;
   		}
    }
    
    public void finish(Database.BatchableContext bc) {
    	AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
	Boolean canStartNextBatch = false;
	if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
		canStartNextBatch = true;
	} else {
		Utility.sendExceptionEmail('BatchSiteDataSync', exceptionDetailsObj);
	}
		
    	BatchRemoveBoxGroup job = new BatchRemoveBoxGroup();
		Database.executeBatch(job,5);
    }
}