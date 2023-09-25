public with sharing class BatchDeleteAppNotifications implements Database.Batchable<SObject> {
    private String contentId;

    public BatchDeleteAppNotifications(String contentId) {
        this.contentId = contentId;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT id, Is_Deleted__c, Object_Id__c FROM App_Notification__c WHERE Object_Id__c = \''+contentId+'\' AND Is_Deleted__c = false';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, SObject[] listOfRecords) {
        if(listOfRecords.size() > 0) {
            List<App_Notification__c> appNotiList = (List<App_Notification__c>)listOfRecords;
            for (App_Notification__c noti : appNotiList){
                noti.Is_Deleted__c = true;
            }
            //delete objects;
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
            SIMPESAPI.accessController().updateAsUser(new Map<Id,App_Notification__c>(appNotiList), new List<Schema.SObjectField>{App_Notification__c.Is_Deleted__c});
        }
    }

    public void finish(Database.BatchableContext bc) {

    }
}