global with sharing class BatchLocationNormalization implements Database.Batchable<SObject>, Database.AllowsCallouts  {
    global Set<Id> peopleSet;
    public BatchLocationNormalization(){
    
    }
    public BatchLocationNormalization(Set<Id> peopleSet){
        this.peopleSet=peopleSet;
    }	
    global database.querylocator start(Database.BatchableContext bc){
		String query = 'SELECT id, Country__c, City__c, State__c, Street__c, raw_city__c, raw_state__c, raw_country__c, Location_Normalization_Status__c '
  				+ ' FROM People__c WHERE User__r.IsActive = true AND Location_Normalization_Status__c = null AND (City__c != null OR State__c != null OR Country__c != null)';
    	return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, sObject[] objects){
}
    global void finish(Database.BatchableContext bc){}
    
}