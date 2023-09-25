public without sharing class BatchUpdateSiteRecords implements Database.Batchable<SObject>, Database.stateful {
    private Exception exceptionDetailsObj;
    public BatchUpdateSiteRecords() {

    }

    /**
     * @description Start
     */
    public Database.queryLocator start(Database.BatchableContext bc){
        String query = null;
        query = 'Select Id, Member_Count__c, Follower_Count__c from Simpplr_Site__c';

        return Database.getQueryLocator(query);
    }

    /**
     * @description Execute
     */
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        try{

            List<Simpplr_Site__c> siteList = (List<Simpplr_Site__c>) scope;
            
            for(Simpplr_Site__c site : siteList){
                site.Follower_Count__c = 0;
                site.Member_Count__c = 0;
            }

            updateSiteMemberAndFollowerCount(siteList);

        } catch(Exception ex) {
            exceptionDetailsObj =  ex;
    		throw ex;
    	}
    }

    /**
     * @description Finish
     */
    public void finish(Database.BatchableContext bc){
        AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
        Boolean canStartNextBatch = false;
        if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
            canStartNextBatch = true;

        } else {
            Utility.sendExceptionEmail('BatchUpdateSiteRecords', exceptionDetailsObj);
        }
    }

    public void updateSiteMemberAndFollowerCount(List<Simpplr_Site__c> siteList ){

        Map<Id, Simpplr_Site__c> siteMap = new  Map<Id, Simpplr_Site__c>(siteList);
        list<Simpplr_Site__c> sitesToUpdate = new List<Simpplr_site__c>();

        for(AggregateResult ar : [Select Site__c siteId, count(id) memberCount 
                                    FROM Site_Role__c WHERE Is_Deleted__c = false AND Is_Member__c = true AND Site__c in: siteMap.keyset()
                                    AND(People__r.User__r.Show_Simpplr__c = 'Yes' OR (People__r.User__r.Show_Simpplr__c != 'No' AND People__r.User__r.isActive = true)) 
                                    group by Site__c]) {
                                        
            siteMap.get((Id)ar.get('siteId')).Member_Count__c = (Integer)ar.get('memberCount');
        }
        
        for(AggregateResult ar : [Select Site__c siteId, count(id) followerCount 
                                FROM Site_Role__c WHERE Is_Deleted__c = false AND Is_Member__c = false AND  site__c in: siteMap.keyset()
                                AND (People__r.User__r.Show_Simpplr__c = 'Yes' OR (People__r.User__r.Show_Simpplr__c != 'No' AND People__r.User__r.isActive=true)) 
                                group by Site__c]) {

            siteMap.get((Id)ar.get('siteId')).Follower_Count__c = (Integer)ar.get('followerCount');
        }

        update siteMap.values();

    }
}