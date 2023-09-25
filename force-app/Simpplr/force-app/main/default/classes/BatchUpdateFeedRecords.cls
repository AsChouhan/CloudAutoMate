/**
 * @description Batch Update Feed Records
 */
public without sharing class BatchUpdateFeedRecords implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.stateful { 
    private String batchType;
    private Exception exceptionDetailsObj;
    private String newChatterGroupId;
    private String oldSiteName;
    private String siteType;
    private List<String> listOfContentIdToMove;
    
    /**
     * @description Batch Update Feed Records
     */
    public BatchUpdateFeedRecords(String batchType, List<String> listOfContentIdToMove, String newChatterGroupId, String oldSiteName,String siteType) {
        this.batchType = batchType;
        this.listOfContentIdToMove = listOfContentIdToMove;
        this.newChatterGroupId=newChatterGroupId;
        this.oldSiteName=oldSiteName;
        this.siteType=siteType;
    }
    
	/**
     * @description Start
     */
    public database.querylocator start(Database.BatchableContext bc){
        String query = null;
        if('moveContent'.equalsIgnoreCase(batchType)){
            query = 'SELECT ParentId, body, Id FROM FeedItem WHERE ParentId = :listOfContentIdToMove';
        }
    	
    	return Database.getQueryLocator(query);
    }
    
	/**
     * @description Execute
     */
    public void execute(Database.BatchableContext bc, List<sObject> listOfsObject){
    	try {
            List<FeedItem> feedItemList = (List<FeedItem>) listOfsObject;
            List<String> feedItemIdList = new List<String> ();
            if('moveContent'.equalsIgnoreCase(batchType)){
                for(FeedItem feedItem : feedItemList) {
                    String bodyStr=feedItem.body;
                    String processedStr;
                    if(siteType.equalsIgnoreCase('unlisted')){
                        processedStr =bodyStr.replace('@'+oldSiteName,'');
                    }else{
                        processedStr =bodyStr.replace('@'+oldSiteName,'@['+newChatterGroupId+']');
                    }
                    if(!Test.isRunningTest()) {
                        feedItemIdList.add(feedItem.id);
                	AIDataProvider.deleteNonToxicEditedContentList(feedItemIdList);
                        FeedServiceProvider.updateFeedElement(null, feedItem.id, processedStr,'', null, null);
                    }
                }
    
            }
            
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
            Utility.sendExceptionEmail('BatchUpdateFeedRecords', exceptionDetailsObj);
        }

    }
}