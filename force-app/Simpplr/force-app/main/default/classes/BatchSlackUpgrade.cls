/**
 * @description This batch is used to clear slack 1.0 configs for the migration to new Simpplr slack
 * There are different batch types which are excuted one after the other to achieve cleaning
 */
public with sharing class BatchSlackUpgrade implements Database.Batchable<sObject> {

    private static final String BATCH_REMOVE_SITE_CONFIGS = 'removeSiteConfigs';
    private static final String BATCH_REMOVE_PEOPLE_CONNECTION = 'removePeopleConnection';

    private String batchType;

    public BatchSlackUpgrade(String batchType) {
        this.batchType = batchType;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = '';
        if(this.batchType.equalsIgnoreCase(BATCH_REMOVE_SITE_CONFIGS)) {
            query = 'SELECT Id, Name, Slack_Channel_Id__c,Slack_Channel_Name__c,Slack_Site_Manager__c, Slack_Comment_Enabled__c, Slack_Integration_Enabled__c,Slack_Post_Enabled__c, Slack_Url__c, Slack_Access_Token__c FROM Simpplr_Site__c WHERE Is_Active__c = true AND Is_Deleted__c = false AND Show_In_Simpplr__c = true AND Slack_Channel_Id__c != NULL';

        } else if (this.batchType.equalsIgnoreCase(BATCH_REMOVE_PEOPLE_CONNECTION)) {
            query = 'SELECT Id FROM People_Integration__c WHERE Name = \'' + IntegrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE + '\'';

        }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> listOfSObjects) {

        if(this.batchType.equalsIgnoreCase(BATCH_REMOVE_SITE_CONFIGS)) {
            updateSlackSiteConfigs((List<Simpplr_Site__c>)listOfSObjects);

        } else if(this.batchType.equalsIgnoreCase(BATCH_REMOVE_PEOPLE_CONNECTION)) {
            deletePeopleInteRecord((List<People_Integration__c>)listOfSObjects);

        }
    }

    public void finish(Database.BatchableContext bc) {

        if(this.batchType.equalsIgnoreCase(BATCH_REMOVE_SITE_CONFIGS)) {
            BatchSlackUpgrade job = new BatchSlackUpgrade(BATCH_REMOVE_PEOPLE_CONNECTION);
            Database.executeBatch(job, 1000);
        }
    }

    public void updateSlackSiteConfigs(List<Simpplr_Site__c> listOfSites) {
        if(!listOfSites.isEmpty()) {
            for(Simpplr_Site__c siteObj: listOfSites) {
                siteObj.Slack_Channel_Id__c = '';
				siteObj.Slack_Channel_Name__c = '';
				siteObj.Slack_Site_Manager__c = null;
				siteObj.Slack_Comment_Enabled__c = false;
				siteObj.Slack_Integration_Enabled__c = false;
				siteObj.Slack_Post_Enabled__c = false;
				siteObj.Slack_Url__c = '';
				siteObj.Slack_Access_Token__c = '';
            }
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
            SIMPESAPI.accessController().updateAsUser(new Map<Id, Simpplr_Site__c>(listOfSites), new List<Schema.SObjectField>{
                Simpplr_Site__c.Slack_Channel_Id__c, 
                Simpplr_Site__c.Slack_Channel_Name__c, 
                Simpplr_Site__c.Slack_Site_Manager__c, 
                Simpplr_Site__c.Slack_Comment_Enabled__c, 
                Simpplr_Site__c.Slack_Integration_Enabled__c, 
                Simpplr_Site__c.Slack_Post_Enabled__c, 
                Simpplr_Site__c.Slack_Url__c, 
                Simpplr_Site__c.Slack_Access_Token__c
            });
        }
    }

    public void deletePeopleInteRecord(List<People_Integration__c> listOfPeopleInt) {
        if(!listOfPeopleInt.isEmpty()) {
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		    SIMPESAPI.accessController().deleteAsUser(listOfPeopleInt);
        }
    }

}