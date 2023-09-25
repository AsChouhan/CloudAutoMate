/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class BatchTopicAnalytics implements Database.Batchable<SObject>, Database.AllowsCallouts {
    
    /**
    * Class [Class Name] 
    * Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
    *
    */
    private static final List<Integer> SYNC_STATUS_SENT = new List<Integer> {1,3,5};
    DateTime startDateTime ;
	DateTime endDateTime ;
	Date startDate ;
	Date endDate ;
	String recordType;
	List<Object> analyticWrapperList;
	
    public BatchTopicAnalytics (String recordType, Date dateArg){
		startDate = dateArg;
		endDate = dateArg.addDays(1);
		this.recordType = recordType;
		
		startDateTime = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day(), 0, 0, 0);  
		endDateTime = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day(), 0, 0, 0);	
	}
	
	public BatchTopicAnalytics (){
		
		endDate = System.today();
		startDate = endDate.addDays(-1);
		this.recordType = 'initAnalyticsData';
		
		startDateTime = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day(), 0, 0, 0);  
		endDateTime = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day(), 0, 0, 0);	
	}
	
    public class TopicAnalyticsWrapper{
        Integer viewCount;
        String topicName;
        Integer followersCount;
    }

    public class TopicAssignmentCountWrapper{
        Integer posts;
        Integer comments;

        TopicAssignmentCountWrapper(Integer posts, Integer comments){
            this.posts = posts;
            this.comments = comments;
        }
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public Database.QueryLocator start(Database.BatchableContext BC){
        Set<String> topicIdSet = new Set<String>();
        String BASE_QUERY;
        
        if('initAnalyticsData'.equalsIgnoreCase(recordType)){
        
            Map<String, Object> soqlParamMap = new Map<String, Object>();
            soqlParamMap.put('soqlParam1', startDateTime);
            soqlParamMap.put('soqlParam2', endDateTime);
            String socialAnlytcsQuery = 'SELECT topic_id__c FROM Simpplr_Social_Analytics__c WHERE topic_id__c != null ' +
                ' AND Interaction__c=\'View\' AND (createdDate >=: soqlParam1 AND createdDate <: soqlParam2)';
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	        for ( Simpplr_Social_Analytics__c sa :  (List<Simpplr_Social_Analytics__c>)SIMPESAPI.accessController().queryAsUser(socialAnlytcsQuery, soqlParamMap)){
	            topicIdSet.add(sa.topic_id__c);                                                             
	        }
	        
	        for ( EntitySubscription es : [SELECT ParentId, SubscriberId FROM EntitySubscription
	        								WHERE Parent.type = 'Topic'
	        								AND (createdDate >=: startDateTime AND createdDate <: endDateTime)] ){
	        	topicIdSet.add(es.ParentId);
            }
            
            List<String> allowedEntityTypeList = new List<String>{
                'FeedItem', 'Simpplr_Content'
            };
            for(TopicAssignment ta : [SELECT TopicId, entitytype
                                    FROM TopicAssignment
                                    WHERE (createdDate >=: startDateTime AND createdDate <: endDateTime) AND
                                    TopicId IN : topicIdSet AND entitytype IN :allowedEntityTypeList]) {
                topicIdSet.add(ta.TopicId);

            }
	        
	        BASE_QUERY= 'Select Id FROM TOPIC where id IN : topicIdSet';
			if(SimpplrContext.isCommunitiesEnabled){
	    		BASE_QUERY = BASE_QUERY+' AND NetworkId = null';
	    		
	    		} 
    		
        } else if('sendAnalyticsDataToAWS'.equalsIgnoreCase(recordType)){
    
	    		BASE_QUERY = 'select Id, Date__c, Followers__c, Topic_Id__c, Topic_Name__c, Views__c, Sync_Status__c, Contents__c, Posts__c, Comments__c '
	    					+' from Analytics_Top_Topic__c where Sync_Status__c !=:SYNC_STATUS_SENT ';
    		
    		} else if('sendTopicDataToAWS'.equalsIgnoreCase(recordType)) { 
    			BASE_QUERY = 'select Id, Name from Topic where SystemModstamp >=: startDateTime ';
    			if(SimpplrContext.isCommunitiesEnabled){
		    		BASE_QUERY = BASE_QUERY+' AND NetworkId = null';
		    	} 
    		}
        return Database.getQueryLocator(BASE_QUERY);
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public void execute(Database.BatchableContext BC, List<sObject> listOfsObject){
        try {
        		if('initAnalyticsData'.equalsIgnoreCase(recordType)){
        			initAnalyticsData((List<Topic>)listOfsObject);
        			
        		} else if('sendAnalyticsDataToAWS'.equalsIgnoreCase(recordType)) {
        			PushAnalyticsDataHelper analyticsHandler = new PushAnalyticsDataHelper();
        			analyticsHandler.sendAnalticsTopTopicListToAWS(listOfsObject);
        		
        		} else if('sendTopicDataToAWS'.equalsIgnoreCase(recordType)) { 
	    			PushAnalyticsDataHelper analyticsHandler = new PushAnalyticsDataHelper();
	    			analyticsHandler.sendTopicListToAWS(listOfsObject);
	    		}
        } catch(Exception ex) {
            Utility.sendBatchFailedExceptionEmail('BatchTopicAnalytics', ex);
        }
    }
    
    private void initAnalyticsData(List<Topic> listOfTopics) {
    		
        Set<String> topicIdSet = new Set<String>(); 
        
        for (Topic tp : listOfTopics) {
            topicIdSet.add(tp.id);      
        }
        Map<String,TopicAnalyticsWrapper> topicAnalyticsCountMap = new Map<String,TopicAnalyticsWrapper>();

        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1', startDateTime);
        soqlParamMap.put('soqlParam2', endDateTime);
        soqlParamMap.put('soqlParam3', topicIdSet);
        String socialAnlytcsQuery = 'SELECT topic_id__c,Topic_Name__c FROM Simpplr_Social_Analytics__c ' +
            ' WHERE topic_id__c != null  ' +
            ' AND Interaction__c=\'View\' AND (createdDate >=: soqlParam1 AND createdDate <: soqlParam2) ' +
            ' AND topic_id__c IN : soqlParam3';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<Simpplr_Social_Analytics__c> socialAnalyticsList = (List<Simpplr_Social_Analytics__c>)SIMPESAPI.accessController().queryAsUser(socialAnlytcsQuery, soqlParamMap);
  
        for(Simpplr_Social_Analytics__c socialAnalObj  : socialAnalyticsList){
            if(topicAnalyticsCountMap.get(socialAnalObj.Topic_Id__c) == null){
                TopicAnalyticsWrapper wrapperObj = new TopicAnalyticsWrapper();
                wrapperObj.viewCount = 0;
                wrapperObj.topicName = socialAnalObj.Topic_Name__c;
                wrapperObj.followersCount = 0;
                topicAnalyticsCountMap.put(socialAnalObj.Topic_Id__c, wrapperObj); 
            }
            topicAnalyticsCountMap.get(socialAnalObj.Topic_Id__c).viewCount = topicAnalyticsCountMap.get(socialAnalObj.Topic_Id__c).viewCount+1;
        }
        
        List<EntitySubscription> entitySubscriptionList = [SELECT id, ParentId, SubscriberId FROM EntitySubscription
                                        WHERE (createdDate >=: startDateTime AND createdDate <: endDateTime) AND ParentId IN : topicIdSet];
                                        
    
        for(EntitySubscription entitySubscriptionObj: entitySubscriptionList){
            if(topicAnalyticsCountMap.get(entitySubscriptionObj.ParentId) == null){
                TopicAnalyticsWrapper wrapperObj = new TopicAnalyticsWrapper();
                wrapperObj.viewCount = 0;
                wrapperObj.topicName = entitySubscriptionObj.ParentId;
                wrapperObj.followersCount = 0;
                topicAnalyticsCountMap.put(entitySubscriptionObj.ParentId, wrapperObj); 
            }
            topicAnalyticsCountMap.get(entitySubscriptionObj.ParentId).followersCount = topicAnalyticsCountMap.get(entitySubscriptionObj.ParentId).followersCount + 1;
        }
        
        if(!topicAnalyticsCountMap.isEmpty()){
        	set<String> idSet = new set<String>();
        	idSet = topicAnalyticsCountMap.keySet();
        	String BASE_QUERY= 'Select Id,Name FROM TOPIC where id IN:idSet';
			if(SimpplrContext.isCommunitiesEnabled){
	    		BASE_QUERY = BASE_QUERY+' AND NetworkId = null';
	    	}
			List<Topic> listOfTopic = new List<Topic>();
			listOfTopic = Database.query(BASE_QUERY);
            Map<Id,Topic> topicMap = new Map<Id,Topic>();
            for(Topic topicObj : listOfTopic){
            	topicMap.put(topicObj.id,topicObj);
            }
            for(String topicId : topicMap.keySet()){
                if(topicAnalyticsCountMap.get(topicId) != null){
                    topicAnalyticsCountMap.get(topicId).topicName = topicMap.get(topicId).Name;
                }
            }
        }

        List<String> actionEnumList = new List<String>{
            'comment',
            'post'
        };
        List<TopicUserEvent> tueList = [SELECT TopicId, ActionEnum FROM TopicUserEvent 
                                        WHERE (createdDate >=: startDateTime AND createdDate <: endDateTime) AND
                                        TopicId IN : topicIdSet AND ActionEnum IN :actionEnumList];

        Map<String, TopicAssignmentCountWrapper> topicAssignmentFeedCountMap = new Map<String, TopicAssignmentCountWrapper>(); 
        TopicAssignmentCountWrapper tAWrapper = null;  
        Integer postCount = 0;
        Integer commentCount = 0;                          
        for(TopicUserEvent tueObj : tueList){
            postCount = 'post'.equalsIgnoreCase(tueObj.ActionEnum) ? 1 : 0;
            commentCount = 'comment'.equalsIgnoreCase(tueObj.ActionEnum) ? 1 : 0;

            if(topicAssignmentFeedCountMap.containsKey(tueObj.TopicId)){
                tAWrapper = topicAssignmentFeedCountMap.get(tueObj.TopicId);

                tAWrapper.comments += commentCount;
                tAWrapper.posts += postCount;

            } else {
                tAWrapper = new TopicAssignmentCountWrapper(postCount, commentCount);
                
            }

            topicAssignmentFeedCountMap.put(tueObj.TopicId, tAWrapper);
        }
        
        // Prepare topic assigned to simpplr content map
        Map<String, Integer> topicAssignmentContentCountMap = new Map<String, Integer>(); 
        List<AggregateResult> aggrList = [SELECT TopicId, COUNT(Id) contents FROM TopicAssignment WHERE entitytype = 'Simpplr_Content'
                                        AND (createdDate >=: startDateTime AND createdDate <: endDateTime) AND
                                        TopicId IN : topicIdSet GROUP BY TopicId];


        for(AggregateResult ar: aggrList) {
            topicAssignmentContentCountMap.put((String) ar.get('TopicId'), (Integer) ar.get('contents'));
        }

        List<Analytics_Top_Topic__c> analyticTopicList = new List<Analytics_Top_Topic__c>();
        for(String topicId : topicAnalyticsCountMap.keySet()){
            Analytics_Top_Topic__c analyticTopicObj = new Analytics_Top_Topic__c();
            analyticTopicObj.Topic_Id__c = topicId;
            analyticTopicObj.Topic_Name__c = topicAnalyticsCountMap.get(topicId).topicName;
            analyticTopicObj.Date__c = startDate;
            analyticTopicObj.Views__c = topicAnalyticsCountMap.get(topicId).viewCount;
            analyticTopicObj.Followers__c = topicAnalyticsCountMap.get(topicId).followersCount;
            
            analyticTopicObj.Contents__c = 0;
            if(topicAssignmentContentCountMap.containsKey(topicId)){
                analyticTopicObj.Contents__c = topicAssignmentContentCountMap.get(topicId);
            }

            analyticTopicObj.Posts__c = 0;
            analyticTopicObj.Comments__c = 0;
            if(topicAssignmentFeedCountMap.containsKey(topicId)){
                analyticTopicObj.Posts__c = topicAssignmentFeedCountMap.get(topicId).posts;
                analyticTopicObj.Comments__c = topicAssignmentFeedCountMap.get(topicId).comments;
            }    
            
            analyticTopicList.add(analyticTopicObj);
        }
        
        if(!analyticTopicList.isEmpty()){

            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
            SIMPESAPI.accessController().insertAsUser(analyticTopicList, new List<Schema.SObjectField>{
                Analytics_Top_Topic__c.Topic_Id__c,
                Analytics_Top_Topic__c.Topic_Name__c,
                Analytics_Top_Topic__c.Date__c,
                Analytics_Top_Topic__c.Views__c,
                Analytics_Top_Topic__c.Followers__c,
                Analytics_Top_Topic__c.Contents__c,
                Analytics_Top_Topic__c.Posts__c,
                Analytics_Top_Topic__c.Comments__c
            });
        }
    		
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public void finish(Database.BatchableContext BC){
    	if('initAnalyticsData'.equalsIgnoreCase(recordType)){
		BatchTopicAnalytics job = new BatchTopicAnalytics('sendAnalyticsDataToAWS', startDate);
	    Database.executeBatch(job, 1000);
    	
    	} else if('sendAnalyticsDataToAWS'.equalsIgnoreCase(recordType)) {
    		BatchTopicAnalytics job = new BatchTopicAnalytics('sendTopicDataToAWS', startDate);
    		Database.executeBatch(job, 1000);
	
	} else {
	    BatchFeedAnalytics job = new BatchFeedAnalytics('initAnalyticsData', startDate);
       	Database.executeBatch(job, 100);
    	}
    }
    
}