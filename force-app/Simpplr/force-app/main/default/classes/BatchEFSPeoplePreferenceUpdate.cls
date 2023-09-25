public without sharing class BatchEFSPeoplePreferenceUpdate implements Database.Batchable<SObject>, Database.Stateful {
	private String req = null;
    private Exception exceptionDetailsObj;
    private String appName = null;
    
    public BatchEFSPeoplePreferenceUpdate(String typ){
    	req = typ;
    }
    
    public database.querylocator start(Database.BatchableContext bc) {
    	String query = '';
    	if(req.equalsIgnoreCase('SETMOUNTFLAG')) {
    		query = 'SELECT Id, Batch_Flag__c, Is_Deleted__c,Group_Id_Set__c,Unsuccessful_Group_Id_Set__c FROM People_Integration__c ' +
    				'WHERE User__c != NULL AND Connected__c = TRUE AND Batch_Flag__c = FALSE AND Is_Deleted__c = FALSE';
    	} else {
    		query = ' SELECT Id, Is_Deleted__c, Unsuccessful_Group_Id_Set__c, Group_Id_Set__c,'+
    			' Access_Token_Requested_Datetime__c, Refresh_Token__c, ' +
				' Refresh_Token_Requested_Datetime__c, Access_Token__c, name,  User_Name__c, Batch_Flag__c,'+ 
   				' User__c, User_Email__c, Token_Type__c, My_Drive_Id__c ' +
   				' FROM People_Integration__c WHERE User__c != NULL AND Is_Deleted__c = false';
    	} 

    	return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, sObject[] objects){
    	try{
	    	List<People_Integration__c> peopleIntegList = (List<People_Integration__c>)objects;
	    	for(People_Integration__c peopleIntegObj : peopleIntegList) {
	    		if('ADMINDEL'.equalsIgnoreCase(req)){
			    	peopleIntegObj.Is_Deleted__c = true;
	    		} else if('APPDEL'.equalsIgnoreCase(req)){
	    			peopleIntegObj.Group_Id_Set__c = null;
	    			peopleIntegObj.Unsuccessful_Group_Id_Set__c = null;
	    		} else if('SETMOUNTFLAG'.equalsIgnoreCase(req)){
	    			peopleIntegObj.Batch_Flag__c = true;
	    		}
	    	}
	    	if(peopleIntegList.size() > 0) {
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        		SIMPESAPI.accessController().updateAsUser(new Map<Id, People_Integration__c>(peopleIntegList), new List<Schema.SObjectField>{
											People_Integration__c.Is_Deleted__c,
											People_Integration__c.Group_Id_Set__c,
											People_Integration__c.Unsuccessful_Group_Id_Set__c,
											People_Integration__c.Batch_Flag__c
                                        });
	    	}
    	}catch(Exception ex) {
    		exceptionDetailsObj =  ex;
    		throw ex;
   		}
    }
    
    public void finish(Database.BatchableContext bc) {
    	AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus 
    								from AsyncApexJob where Id = :bc.getJobId()];
		Boolean canStartNextBatch = false;
		if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
			canStartNextBatch = true;
		} else {
			Utility.sendExceptionEmail('BatchEFSPeoplePreferenceUpdate', exceptionDetailsObj);
		}
    }
}