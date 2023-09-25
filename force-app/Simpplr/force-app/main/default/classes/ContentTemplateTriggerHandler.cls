/**
 * @description       : trigger handler class for Content_Template__c
 * @author            : simpplr.com
 * @group             : content
 * @last modified on  : 03-21-2022
 * @last modified by  : simpplr.com
**/
public with sharing class ContentTemplateTriggerHandler {
    /**
    * @description trigger context after insert
    * @param newMap new map
    **/
    public void onAfterInsert(Map<Id,Content_Template__c> newMap){
		onAfterInsertOrUpdate(newMap);
	}
	
	/**
	* @description trigger context  after update
	* @param newMap new map
	**/
	public void onAfterUpdate(Map<Id,Content_Template__c> newMap){
		onAfterInsertOrUpdate(newMap);
	}

	/**
	* @description trigger context  after undelete
	* @param newMap new map
	**/
	public void onAfterUnDelete(Map<Id,Content_Template__c> newMap){
		onAfterInsertOrUpdate(newMap);
	}
	 
    /**
    * @description handler after insert or update
    * @param newMap new map
    **/
    private void onAfterInsertOrUpdate(Map<Id,Content_Template__c> newMap) {		
		insertExternalSearchDataTrail(newMap.values());
	}

	/**
	* @description trigger context 
	* @param listContentTemplates list of deleted content templates
	**/
	public void onAfterDelete(List<Content_Template__c> listContentTemplates) {
		insertExternalSearchDataTrail(listContentTemplates);
	}

    /**
    * @description trigger context after delete
    * @param listContentTemplates list of content templates changes to be pushed to elastic
    **/
    public void insertExternalSearchDataTrail(List<Content_Template__c> listContentTemplates) {
        List<External_Search_Data_Trail__c> listToInsert = new List<External_Search_Data_Trail__c>();		
		if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			for (Content_Template__c contentTemplate : listContentTemplates) {
	    		External_Search_Data_Trail__c obj = new External_Search_Data_Trail__c();
				obj.Content_Template__c = contentTemplate.Id;
				obj.Type__c = 'Content_Template';
	    		listToInsert.add(obj);		
            } 

			if (Schema.sObjectType.External_Search_Data_Trail__c.isCreateable() && listToInsert.isEmpty() == false) {

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().insertAsUser(listToInsert, new List<Schema.SObjectField>{
					External_Search_Data_Trail__c.Content_Template__c,
					External_Search_Data_Trail__c.Type__c});
			
			}
        }
    }
}