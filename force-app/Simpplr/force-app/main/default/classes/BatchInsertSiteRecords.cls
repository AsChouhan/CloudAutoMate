public with sharing class BatchInsertSiteRecords implements Database.Batchable<SObject>,Database.Stateful {
    private final String BATCH_CREATE_SITE = 'createSiteIfNotPresent';
    private final String BATCH_CREATE_QUEUE_SOBJECT_RECORD = 'createSiteQueueSobjectRecords';
    private final String BATCH_CREATE_SITE_SHARE_RECORD = 'createSiteShareRecords';

    private boolean isSetupBatch;
    private String batchType;
    private List<String> siteIdsList = new List<String>();
    private Exception exceptionDetailsObj;
    private Boolean isCalledFromScheduler = false;
    
    /**
     * @description BatchInsertSiteRecords constructor
     */
    public BatchInsertSiteRecords() {
        this.batchType = BATCH_CREATE_SITE;
    	this.isSetupBatch = false;
    }
    
    /**
     * @description BatchInsertSiteRecords parameterized constructor
     * @param isSetupBatch
     */
    public BatchInsertSiteRecords(Boolean isSetupBatch) {
        this.batchType = BATCH_CREATE_SITE;
        this.isSetupBatch = isSetupBatch;
    }

    /**
     * @description BatchInsertSiteRecords parameterized constructor
     * @param isSetupBatch
     * @param isCalledFromScheduler
     */
    public BatchInsertSiteRecords(Boolean isSetupBatch, Boolean isCalledFromScheduler) {
        this.batchType = BATCH_CREATE_SITE;
        this.isSetupBatch = isSetupBatch;
        this.isCalledFromScheduler = isCalledFromScheduler;
    }    
    
    /**
     * @description BatchInsertSiteRecords parameterized constructor
     * @param batchType
     * @param isSetupBatch
     * @param siteIdsList
     * @param isCalledFromScheduler
     */
    public BatchInsertSiteRecords(String batchType, Boolean isSetupBatch, List<String> siteIdsList, Boolean isCalledFromScheduler) {
        this.batchType = batchType;
        this.isSetupBatch = isSetupBatch;
        this.siteIdsList = siteIdsList;
        this.isCalledFromScheduler = isCalledFromScheduler;
    }
    
    /**
     * @description start method of batch
     * @param batchContext
     * @return querylocator
     */
    public database.querylocator start(Database.BatchableContext bc){
        List<String> listOfChatterGroupIds = new List<String>();
        String query;
        if(BATCH_CREATE_SITE.equalsIgnoreCase(batchType)) {
            for(Simpplr_Site__c siteObj : [select chatter_group_id__c from Simpplr_Site__c where chatter_group_id__c != 'S06I000000MPPLR']) {
                listOfChatterGroupIds.add(siteObj.chatter_group_id__c);
            }
            query = 'select id, OwnerId, Name, CollaborationType, IsArchived from CollaborationGroup where id not in :listOfChatterGroupIds ';
            if(SimpplrContext.isCommunitiesEnabled){
                    query = query+'AND NetworkId = null';
            }
        } else if(BATCH_CREATE_QUEUE_SOBJECT_RECORD.equalsIgnoreCase(batchType)) {
            query = 'select id, Chatter_Group_Id__c from Simpplr_Site__c where id in :siteIdsList';

        } else if(BATCH_CREATE_SITE_SHARE_RECORD.equalsIgnoreCase(batchType)) {
            query = 'select id, Chatter_Group_Id__c, Site_Type__c from Simpplr_Site__c where id in :siteIdsList';
        }
        return Database.getQueryLocator(query);
    }
    
    /**
     * @description execute method of batch
     * @param batchContext
     * @param listOfsObject
     */
    public void execute(Database.BatchableContext bc, List<sObject> listOfsObject){
    	
    	try{
            if(BATCH_CREATE_SITE.equalsIgnoreCase(batchType)) {
                List<CollaborationGroup> listOfCollaborationGroup = (List<CollaborationGroup>)listOfsObject;
                SiteDao siteDaoObj = new SiteDao();
                List<Simpplr_Site__c> siteList = siteDaoObj.createSimpplrSites(listOfCollaborationGroup);
                List<Group> listOfUserGroups = new List<Group>();
                Set<String> setOfGroupNames = new Set<String>();  
                for(Simpplr_Site__c siteObj : siteList) {
                    siteIdsList.add(siteObj.Id);
                    setOfGroupNames.add('Simpplr_' + siteObj.Chatter_Group_Id__c + '_Standard');
                    setOfGroupNames.add('Simpplr_' + siteObj.Chatter_Group_Id__c + '_Admin');
                }
                List<Group> listOfGroups = [select id, DeveloperName from Group where DeveloperName=:setOfGroupNames];
                Set<String> setOfExistingGroupNames = new Set<String>();
                for(Group grp:listOfGroups) {
                    setOfExistingGroupNames.add(grp.DeveloperName);
                }
                Group groupObj; 
                for(CollaborationGroup cg : listOfCollaborationGroup) {
                    
                    String standardGrpName = 'Simpplr_' + cg.Id + '_Standard';
                    if(!setOfExistingGroupNames.contains(standardGrpName)) {
                        groupObj = new Group();
                        groupObj.DeveloperName = standardGrpName;
                        groupObj.DoesSendEmailToMembers = false;
                        groupObj.type='Queue';
                        groupObj.Name = standardGrpName; 
                        listOfUserGroups.add(groupObj);
                    }
                    
                    String adminGrpName = 'Simpplr_' + cg.Id + '_Admin';
                    if(!setOfExistingGroupNames.contains(adminGrpName)) {
                        groupObj = new Group();
                        groupObj.DeveloperName = adminGrpName;
                        groupObj.DoesSendEmailToMembers = false;
                        groupObj.type='Queue';
                        groupObj.Name = adminGrpName;
                        listOfUserGroups.add(groupObj);
                    }
                }
                if(listOfUserGroups.size() > 0) {
                    insert listOfUserGroups;
                }
            } else if(BATCH_CREATE_QUEUE_SOBJECT_RECORD.equalsIgnoreCase(batchType)) {
                List<Simpplr_Site__c> listOfSimpplrSites = (List<Simpplr_Site__c>)listOfsObject;
                List<String> chatterGroupIds = new List<String>();
                for(Simpplr_Site__c siteRecord : listOfSimpplrSites) {
                    chatterGroupIds.add(siteRecord.Chatter_Group_Id__c);
                }
                Map<Id, CollaborationGroup> collaborationGroupMap = new Map<Id, CollaborationGroup>([
                    SELECT Id, OwnerId FROM CollaborationGroup WHERE Id IN :chatterGroupIds
                ]);
                Map<String, String> mapOfGroupNamesAndOwnerId = new Map<String, String>();
                for(Simpplr_Site__c siteRecord : listOfSimpplrSites) {
                    mapOfGroupNamesAndOwnerId.put('Simpplr_' + siteRecord.Chatter_Group_Id__c + '_Standard', collaborationGroupMap.get(siteRecord.Chatter_Group_Id__c).OwnerId);
                    mapOfGroupNamesAndOwnerId.put('Simpplr_' + siteRecord.Chatter_Group_Id__c + '_Admin', collaborationGroupMap.get(siteRecord.Chatter_Group_Id__c).OwnerId);
                }
                List<Group> listOfGroups = [SELECT Id,Developername, (SELECT Id, SobjectType FROM QueueSobjects) FROM Group WHERE Developername =: mapOfGroupNamesAndOwnerId.keySet()];
                SimpplrSiteServices.createQueueSobjectNGroupMember(listOfGroups, mapOfGroupNamesAndOwnerId);
            } else if(BATCH_CREATE_SITE_SHARE_RECORD.equalsIgnoreCase(batchType)) {
                List<Simpplr_Site__c> listOfSimpplrSites = (List<Simpplr_Site__c>)listOfsObject;
                
                Set<String> setOfGroupNames = new Set<String>();
                for(Simpplr_Site__c siteRecord : listOfSimpplrSites) {
                    setOfGroupNames.add('Simpplr_' + siteRecord.Chatter_Group_Id__c + '_Standard');
                    setOfGroupNames.add('Simpplr_' + siteRecord.Chatter_Group_Id__c + '_Admin');
                }
                List<Group> listOfGroups = [SELECT Id,Developername FROM Group WHERE Developername =: setOfGroupNames];
                Map<String, String> mapOfGroupNameAndGroupId = new Map<String, String>();
                for(Group groupObj:listOfGroups) {
                    mapOfGroupNameAndGroupId.put(groupObj.developername, groupObj.id);
                }

                List<Simpplr_Site__c> siteListToUpdate = new List<Simpplr_Site__c>();
                for(Simpplr_Site__c siteRecord : listOfSimpplrSites) {
                    String key = 'Simpplr_' + siteRecord.Chatter_Group_Id__c + '_Admin';
                    if(mapOfGroupNameAndGroupId.containsKey(key)) {
                        siteListToUpdate.add(new Simpplr_Site__c(Id = siteRecord.Id, OwnerId = mapOfGroupNameAndGroupId.get(key)));
                    }
                }
                update siteListToUpdate;
                Utility.createSimpplrSiteShareRecords(listOfSimpplrSites, true);
            }
    	}catch(Exception ex) {
    		exceptionDetailsObj =  ex;
    		throw ex;
   		}
    }
    
    /**
     * @description finish method of batch
     * @param batchContext
     */
    public void finish(Database.BatchableContext bc){
    	
    	AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
	Boolean canStartNextBatch = false;
	if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
		canStartNextBatch = true;
	} else {
		Utility.sendExceptionEmail('BatchInsertSiteRecords', exceptionDetailsObj);
	}
        if(BATCH_CREATE_SITE.equalsIgnoreCase(batchType)) {
            BatchInsertSiteRecords siteJob = new BatchInsertSiteRecords(BATCH_CREATE_QUEUE_SOBJECT_RECORD, isSetupBatch, siteIdsList, isCalledFromScheduler);
            Database.executeBatch(siteJob, 200);

            if(isSetupBatch) {
                String mailSubject='Setup batch for Site creation completed.';
                String mailBodyHtml='Dear User'+ ', <br/><br/> Setup batch for Site creation started by you has been completed.';
                mailBodyHtml+=' <br/> <br/> Thanks.!';
                EmailUtility emailUtilObj=new EmailUtility();
                emailUtilObj.sendMailToCurrentUser(mailSubject, mailBodyHtml);
                
            } else {
                BatchSiteDataSync job = new BatchSiteDataSync();
                Database.executeBatch(job,1000);
            }
        } else if(BATCH_CREATE_QUEUE_SOBJECT_RECORD.equalsIgnoreCase(batchType)) {
            if(canStartNextBatch){
                BatchInsertSiteRecords job = new BatchInsertSiteRecords(BATCH_CREATE_SITE_SHARE_RECORD, isSetupBatch, siteIdsList, isCalledFromScheduler);
                Database.executeBatch(job, 200);
            } else {

                if(isCalledFromScheduler) {
                    // Added to execute nigthly jobs sequentially
                    SchedulerSimpplrServices.executeNextJob('insertSiteRecords'); 
                }                 
            }

            if(isSetupBatch) {
                BatchMigrateSiteRecords job = new BatchMigrateSiteRecords('migrateCollaborationGroupMembers');
                Database.executeBatch(job,200);
            }
        } else if(BATCH_CREATE_SITE_SHARE_RECORD.equalsIgnoreCase(batchType)) {

            if(isCalledFromScheduler) {
                // Added to execute nigthly jobs sequentially
                SchedulerSimpplrServices.executeNextJob('insertSiteRecords'); 
            } 
        }
    }
}