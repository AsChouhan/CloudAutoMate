public with sharing class BatchReadershipAnalytics implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    
    Map<Simpplr_Content__c,Analytics_Weekly_Content_Readership__c> contentReadershipMap ;
    private static final List<Integer> SYNC_STATUS_SENT = new List<Integer> {1,2,3,4,5};
    Double contentOwnerSubscriptionCount ;
    Double contentSiteSubscriptionCount ;    
    Double totalSubscriberCount;
    Set<Id> contentOwnerId ;
    Set<Id> collaborationGroupId ;
    Map<Id,Integer> getContentOwnerSubscriptionMap;
    Map<Id,Integer> getSiteSubscriptionMap ;
    Map<Id,Integer> contentViewsMap ;
    DateTime startDateTime ;
    DateTime endDateTime ;
    Date startDate ;
    Date endDate;
    String recordType;

    Set<Id> week0ContentSet ;
    Set<Id> week1ContentSet ;
    Set<Id> week2ContentSet ;
    Set<Id> week3ContentSet ;
    Set<Id> week4ContentSet ;
   

    public BatchReadershipAnalytics(String recordType, Date dateArg) {
        startDate = dateArg;
        endDate = dateArg.addDays(-28) ;
        this.recordType = recordType;
        
        startDateTime = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day(), 23, 59, 59);  
        endDateTime = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day(), 0, 0, 0);    
    }
    public database.querylocator start(Database.BatchableContext bc) {
        String query;
        
        if('initAnalyticsData'.equalsIgnoreCase(recordType)){
            query = 'SELECT Id,ownerid,primary_author__r.user__r.id,Site__r.Chatter_Group_Id__c,First_Publish_DateTime__c,Type__c'
                  + ' FROM Simpplr_Content__c ' 
                  + ' where (First_Publish_DateTime__c <=: startDateTime AND First_Publish_DateTime__c >=: endDateTime)'
                  + ' And Status__c = \'Approved\' ';
      
            } else if('sendAnalyticsDataToAWS'.equalsIgnoreCase(recordType)){
              query = 'select Id, Content__c, Content_Owner_Subscription_Count__c, Content_Readership__c, Site_Member_Count__c,'
                  +' Week__c,Sync_Status__c from Analytics_Weekly_Content_Readership__c    ' 
                  +' where Sync_Status__c !=:SYNC_STATUS_SENT ';
                  
            } 
        return Database.getQueryLocator(query);

    }
    public void execute(Database.BatchableContext bc, List<sObject> listOfsObject) {
        contentReadershipMap =new Map<Simpplr_Content__c,Analytics_Weekly_Content_Readership__c>();
        try {
            if('initAnalyticsData'.equalsIgnoreCase(recordType)){
                List<Simpplr_Content__c> simmplrContentList = (List<Simpplr_Content__c>)listOfsObject;
                For(Simpplr_Content__c simpplrContentObj: simmplrContentList){
                    Analytics_Weekly_Content_Readership__c analyticsObj =new Analytics_Weekly_Content_Readership__c();
                   Date contentPublishDate ;
                   contentPublishDate=simpplrContentObj.First_Publish_DateTime__c.date();
                   if(contentPublishDate == startDate){
                    analyticsObj.Week__c=0;
                    analyticsObj.Content__c=simpplrContentObj.id;      
                    contentReadershipMap.put(simpplrContentObj ,analyticsObj) ;      
                   }
                   else if (contentPublishDate == startDate.addDays(-7)){
                    analyticsObj.Week__c=1;
                    analyticsObj.Content__c=simpplrContentObj.id;  
                    contentReadershipMap.put(simpplrContentObj ,analyticsObj) ;      
                   }
                   else if (contentPublishDate == startDate.addDays(-14)){
                    analyticsObj.Week__c=2;
                    analyticsObj.Content__c=simpplrContentObj.id;   
                    contentReadershipMap.put(simpplrContentObj ,analyticsObj) ;      
                   }
                   else if (contentPublishDate == startDate.addDays(-21)){
                    analyticsObj.Week__c=3;
                    analyticsObj.Content__c=simpplrContentObj.id; 
                    contentReadershipMap.put(simpplrContentObj ,analyticsObj) ;      
                   }
                   else if (contentPublishDate == startDate.addDays(-28)){
                    analyticsObj.Week__c=4;
                    analyticsObj.Content__c=simpplrContentObj.id; 
                        contentReadershipMap.put(simpplrContentObj ,analyticsObj) ;    
                   }
               }
                  initAnalyticsData(contentReadershipMap);
                  saveBatchData();
            }
            else if('sendAnalyticsDataToAWS'.equalsIgnoreCase(recordType)) {
                PushAnalyticsDataHelper analyticsDataHelper = new PushAnalyticsDataHelper();
                    analyticsDataHelper.sendAnalticsContentReadershipListToAWS(listOfsObject);
            }
          
        }
            catch(Exception ex) {
                Utility.sendBatchFailedExceptionEmail('BatchReadershipAnalytics', ex);
        }      
    
    }

    private void initAnalyticsData(Map<Simpplr_Content__c,Analytics_Weekly_Content_Readership__c> contentReadershipMap) {
        contentOwnerId= new Set<Id>();
        collaborationGroupId =new Set<Id>(); 
        getContentOwnerSubscriptionMap =new Map<Id,Integer>();
        getSiteSubscriptionMap =new Map<Id,Integer>();
        contentViewsMap=new Map<Id,Integer>();
        For(Simpplr_Content__c simpplrContentObj :  contentReadershipMap.keyset()){
            contentOwnerId.add(simpplrContentObj.primary_author__r.user__r.id);  
            collaborationGroupId.add(simpplrContentObj.Site__r.Chatter_Group_Id__c)   ;   
        }
        getContentOwnerSubscriptionMap=getSubscriptionCount(contentOwnerId,'contentOwnerSubscription');
        getSiteSubscriptionMap =getSubscriptionCount(collaborationGroupId,'contentSiteSubscription');
        contentViewsMap=getContentViewsCount(contentReadershipMap);

        For(Simpplr_Content__c simpplrContentObj :  contentReadershipMap.keyset()){
            if(getContentOwnerSubscriptionMap.containsKey(simpplrContentObj.primary_author__r.user__r.id)){
            contentOwnerSubscriptionCount=Double.valueof(getContentOwnerSubscriptionMap.get(simpplrContentObj.primary_author__r.user__r.id));
            contentReadershipMap.get(simpplrContentObj).Content_Owner_Subscription_Count__c=contentOwnerSubscriptionCount ;
         }
          if(getSiteSubscriptionMap.containsKey(simpplrContentObj.Site__r.Chatter_Group_Id__c)){
            contentSiteSubscriptionCount=Double.valueof(getSiteSubscriptionMap.get(simpplrContentObj.Site__r.Chatter_Group_Id__c));
            contentReadershipMap.get(simpplrContentObj).Site_Member_Count__c=contentSiteSubscriptionCount;
           }
           contentReadershipMap.get(simpplrContentObj).Content_Readership__c = contentViewsMap.get(simpplrContentObj.id) == null ? 0 : contentViewsMap.get(simpplrContentObj.id);           
            
        }
       
    }    
    
    
    //Utility Method to get Content Views Weekly
    private Map<id,Integer> getContentViewsCount(Map<Simpplr_Content__c,Analytics_Weekly_Content_Readership__c> contentReadershipMap ){
        Map<id,Integer> weeklyContentViewsMap =new Map<id,Integer>(); 
        week0ContentSet =new Set<Id>(); 
        week1ContentSet=new Set<Id>();
        week2ContentSet=new Set<Id>();
        week3ContentSet=new Set<Id>();
        week4ContentSet=new Set<Id>();
       
        For(Simpplr_Content__c contentObj:contentReadershipMap.keyset()){
            if(contentReadershipMap.get(contentObj).Week__c == 0){
            week0ContentSet.add(contentObj.id);
        }
            if(contentReadershipMap.get(contentObj).Week__c == 1){
            week1ContentSet.add(contentObj.id);
        }
            if(contentReadershipMap.get(contentObj).Week__c == 2){
            week2ContentSet.add(contentObj.id);
        }
            if(contentReadershipMap.get(contentObj).Week__c == 3){
            week3ContentSet.add(contentObj.id);
        }
            if(contentReadershipMap.get(contentObj).Week__c == 4){
            week4ContentSet.add(contentObj.id);
        }
      }
    if(!week0ContentSet.isEmpty())  {
        For(AggregateResult week0groupedResults: [SELECT Content__c ContentId, COUNT(Id) ViewCount FROM content_interaction__c where Content__c in: week0ContentSet  group by Content__c] ){
            weeklyContentViewsMap.put((Id)week0groupedResults.get('ContentId'),Integer.valueOf(week0groupedResults.get('ViewCount')));
      }
    }
    if(!week1ContentSet.isEmpty())  {
        For(AggregateResult week1groupedResults: [SELECT Content__c ContentId, COUNT(Id) ViewCount FROM content_interaction__c where Content__c in: week1ContentSet  group by Content__c] ){
            weeklyContentViewsMap.put((Id)week1groupedResults.get('ContentId'),Integer.valueOf(week1groupedResults.get('ViewCount')));
      }
    } 
    if(!week2ContentSet.isEmpty())  {
        For(AggregateResult week2groupedResults: [SELECT Content__c ContentId, COUNT(Id) ViewCount FROM content_interaction__c where Content__c in: week2ContentSet group by Content__c] ){
            weeklyContentViewsMap.put((Id)week2groupedResults.get('ContentId'),Integer.valueOf(week2groupedResults.get('ViewCount')));
      }
    }
    if(!week3ContentSet.isEmpty())  {
        For(AggregateResult week3groupedResults: [SELECT Content__c ContentId, COUNT(Id) ViewCount FROM content_interaction__c where Content__c in: week3ContentSet group by Content__c] ){
            weeklyContentViewsMap.put((Id)week3groupedResults.get('ContentId'),Integer.valueOf(week3groupedResults.get('ViewCount')));
      }
    }
    if(!week4ContentSet.isEmpty())  {
        For(AggregateResult week4groupedResults: [SELECT Content__c ContentId, COUNT(Id) ViewCount FROM content_interaction__c where Content__c in: week4ContentSet  group by Content__c] ){
            weeklyContentViewsMap.put((Id)week4groupedResults.get('ContentId'),Integer.valueOf(week4groupedResults.get('ViewCount')));
      }
    }
         return weeklyContentViewsMap;
    }
    //Utility Method to get subscriber count
    private Map<id,Integer> getSubscriptionCount(Set<Id> toBeProcessedIds, String entityName){
        Map<Id,Integer>  getSubscriptionMap =new Map<id,Integer> ();
        if(entityName == 'contentOwnerSubscription'){
        List<AggregateResult> sSAList = [SELECT ParentId,count(SubscriberId) SubscriberCount FROM EntitySubscription 
        where parentid in:  toBeProcessedIds GROUP BY ParentId ];
        For(AggregateResult groupedResults:sSAList){
            getSubscriptionMap.put((Id)groupedResults.get('ParentId'),Integer.valueOf(groupedResults.get('SubscriberCount'))); 

        } 
    }
    else if(entityName=='contentSiteSubscription'){
        List<CollaborationGroup> collaborationGroupList = [select id,membercount from CollaborationGroup where id in:toBeProcessedIds] ;
        For(CollaborationGroup collaborationObj: collaborationGroupList){
            getSubscriptionMap.put(collaborationObj.id,collaborationObj.membercount);

        }

    }
        
        return getSubscriptionMap ;
    }

    public void finish(Database.BatchableContext bc){
        if('initAnalyticsData'.equalsIgnoreCase(recordType)){
            BatchReadershipAnalytics job = new BatchReadershipAnalytics('sendAnalyticsDataToAWS', startDate);
            DataBase.executeBatch(job, 1000); 
                   
        }else if('sendAnalyticsDataToAWS'.equalsIgnoreCase(recordType)){
            if(SimpplrContext.isNativeVideo) {
                BatchManageVideo job = new BatchManageVideo('sendNativeVideoDataToAws', startDate);
                DataBase.executeBatch(job, 1);

            } else if(SimpplrContext.isEmployeeAdvocacyEnabled && SimpplrContext.appIntegrationEnabledSet.size() > 0) {
                BatchSocialCampaignAnalytics campaignBatchJob = new BatchSocialCampaignAnalytics('initAnalyticsData', startDate);
                DataBase.executeBatch(campaignBatchJob, 10);

            } else {
                BatchPullNewsletterTrackerData job = new BatchPullNewsletterTrackerData();
                DataBase.executeBatch(job, 1);
            }
        }        
    } 


    private void saveBatchData() {
        try {
            if(!contentReadershipMap.isEmpty()){
            insert contentReadershipMap.values() ;
            }       
        }
        catch(Exception ex) {
            Utility.sendBatchFailedExceptionEmail('BatchReadershipAnalytics', ex); 
        }
    }

}