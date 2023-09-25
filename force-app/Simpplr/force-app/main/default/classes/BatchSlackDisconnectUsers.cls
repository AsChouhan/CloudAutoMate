public without sharing class BatchSlackDisconnectUsers implements Database.Batchable<sObject>{
	
	public Database.QueryLocator start(Database.BatchableContext BC){
		String query ='select User_Name__c, User_Email__c, Connected__c from People_Integration__c where Connected__c = true AND Name=\''+IntegrationConstants.INTEGRATION_TYPE_SLACK_UNFURL+'\'';

		return Database.getQueryLocator(query);
	}
	
	public void execute(Database.BatchableContext BC, sObject[] listOfsObject){
		List<People_Integration__c> listOfslackConnectedPeopleInteg = (List<People_Integration__c >)listOfsObject;
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().deleteAsUser(listOfslackConnectedPeopleInteg);
		
	}
    
    public void finish(Database.BatchableContext BC){
    	
	}
}