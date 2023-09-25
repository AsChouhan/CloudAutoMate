public with sharing class BatchDeleteIntegrationRecords implements Database.Batchable<SObject>{
    
    List<String> connectedApps = new List<String>();
	Set<String> domainSet = new Set<String>();
	private String batchContext = '';
	private Boolean runBoxSyncBatch = false;
	private final String BATCH_DELETE_DISCONNECTED_ATLASSIAN_INTEGRATION = 'deleteAtlassianDisconnectedRecords';
	private final String BATCH_REMOVE_DOMAIN_PEOPLE_INTEGRATION = 'removeDomainPeopleIntegration';

    public BatchDeleteIntegrationRecords(List<String> connectedApps){
    	this.connectedApps = connectedApps;
    }

	public BatchDeleteIntegrationRecords(List<String> connectedApps, Boolean runBoxSyncBatch) {
		this.connectedApps = connectedApps;
		this.runBoxSyncBatch = runBoxSyncBatch;
	}
    
	/**
	 * @description constructor with connected apps and batchContext
	 * @param connectedApps
	 * @param batchContext
	 */
	public BatchDeleteIntegrationRecords(List<String> connectedApps, String batchContext) {
		this.connectedApps = connectedApps;
		this.batchContext = batchContext;
	}

	public BatchDeleteIntegrationRecords(List<String> connectedApps, String batchContext, Set<String> domainSet) {
		this.connectedApps = connectedApps;
		this.batchContext = batchContext;
		this.domainSet = domainSet;
	}
	
    public database.querylocator start(Database.BatchableContext bc){
    	String query = 'Select id, People__c from People_integration__c where App_Integration__r.name IN : connectedApps';
		if(batchContext.equalsIgnoreCase(BATCH_REMOVE_DOMAIN_PEOPLE_INTEGRATION) && domainSet != null) {
			query += ' AND Domain__c IN : domainSet AND Is_Deleted__c = False';
		}
    	return database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> listOfsObject){

		List<People_integration__c> listToDelete =  (List<People_integration__c>)listOfsObject;
		if(batchContext.equalsIgnoreCase(BATCH_REMOVE_DOMAIN_PEOPLE_INTEGRATION)) {
			softDeletePeopleIntegrationRecords(listToDelete);

		} else {
			if(batchContext.equalsIgnoreCase(BATCH_DELETE_DISCONNECTED_ATLASSIAN_INTEGRATION)) {
				Set<Id> dismissedPeopleIdSet = new Set<Id>();
				for(People_Integration__c people : listToDelete) {
					dismissedPeopleIdSet.add(people.people__c);
				}
				if(dismissedPeopleIdSet.size() > 0) {
					HelpDao helpDaoObj = new HelpDao();
					helpDaoObj.insertHelptextViewRecords(dismissedPeopleIdSet, ServiceConstants.HELP_TEXT_ATLASSIAN_DISMISSED_TASK, 
					ServiceConstants.DISMISSIBLE_FLASHES_TASK_TYPE_MAP.get('ERROR'));
				}
			}
			SIMPESAPI.accessController().setArrayOperationMode(SIMPSFDCAccessController.OperationMode.BEST_EFFORT);
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().deleteAsUser(listToDelete);
		}
    }

	public void softDeletePeopleIntegrationRecords(List<People_integration__c> listToDelete) {
		// list to soft delete people integration records
		List<People_Integration__c> peopleIntegrationDeleteList = new List<People_Integration__c>();
		for(People_Integration__c peopleIntegrationObj : listToDelete) {
			peopleIntegrationObj.Is_Deleted__c = true;
			peopleIntegrationObj.Connected__c = false;
			peopleIntegrationDeleteList.add(peopleIntegrationObj);
		}
		SIMPESAPI.accessController().updateAsUser(new Map<Id, People_Integration__c>(peopleIntegrationDeleteList), 
			new List<Schema.SObjectField>{
				People_Integration__c.Is_Deleted__c,
				People_Integration__c.Connected__c
			});	
	}
    
    public void finish(Database.BatchableContext bc) {

		if(batchContext.equalsIgnoreCase(BATCH_REMOVE_DOMAIN_PEOPLE_INTEGRATION)) {
			// Don't do anything incase of batchType - removeDomainPeopleIntegration
			return;
		}
	
    	//delete parent object records
		Map<String, Object> sqlParamMap = new Map<String, Object>();
		sqlParamMap.put('soqlParam1', connectedApps);

		String appIntQuery = 'SELECT id FROM App_integration__c WHERE name in :soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_integration__c> listOfAppIntegration = (List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, sqlParamMap);

    	if(listOfAppIntegration.size()>0){
			SIMPESAPI.accessController().setArrayOperationMode(SIMPSFDCAccessController.OperationMode.BEST_EFFORT);
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().deleteAsUser(listOfAppIntegration);	
    	}

		if (runBoxSyncBatch) {
			// removed box enabled condition to put it within batch to chain integation batches
			BatchBoxSync syncJob = new BatchBoxSync('refreshUserToken',true);
			Database.executeBatch(syncJob, 10);
		}
    }
}