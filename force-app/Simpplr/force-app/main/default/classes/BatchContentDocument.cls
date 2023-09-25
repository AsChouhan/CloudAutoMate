public with sharing class BatchContentDocument implements Database.Batchable<SObject>, Database.Stateful {
    String batchType;
    Set<Id> simpplrContentIds;
    Set<String> setOfContentApprovers;
    Boolean isManagerOrOwner;
    Boolean isContentManager;

    public BatchContentDocument(String batchType, Set<Id> simpplrContentIds, Set<String> setOfContentApprovers, Boolean isManagerOrOwner, Boolean isContentManager) {
        this.batchType = batchType;
        this.simpplrContentIds = simpplrContentIds;
        this.setOfContentApprovers = setOfContentApprovers;
        this.isManagerOrOwner = isManagerOrOwner;
        this.isContentManager = isContentManager;
    }

    public database.querylocator start(Database.BatchableContext bc) {
        String query;
        if('updateAccessToFiles'.equalsIgnoreCase(batchType)) {
            query = 'SELECT Id, Content_Document__c, Repository__c FROM File__c'
                + ' WHERE Simpplr_Content__c = :simpplrContentIds AND Is_Deleted__c = false';
        }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> listOfsObject){
        try {
            if('updateAccessToFiles'.equalsIgnoreCase(batchType)) {
                List<File__c> fileList = (List<File__c>)listOfsObject;
                FileDao fileDaoObj = new FileDao();		
                if(isContentManager || isManagerOrOwner) {
                    fileDaoObj.createContentDocumentLinks(fileList, setOfContentApprovers);
                } else {
                    fileDaoObj.removeContentDocumentLinks(fileList, setOfContentApprovers);
                }
            }
        } catch(Exception ex) {
    		Utility.sendBatchFailedExceptionEmail('BatchContentDocument', ex);
    	}
    }

    public void finish(Database.BatchableContext bc) {}
}