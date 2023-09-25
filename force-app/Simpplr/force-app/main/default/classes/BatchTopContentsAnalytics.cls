/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/

public with sharing class BatchTopContentsAnalytics implements Database.Batchable<SObject>, Database.AllowsCallouts{

    private static final List<Integer> SYNC_STATUS_SENT = new List<Integer> {1,3,5};
    // this map will hold the final/consolidated records that will be inserted into analytics table 
    public Map<Id, Analytics_Top_Content__c> consolidatedMap;
    public Map<Id, Analytics_Top_Content__c> contentSharesCountMap;
	public Map<Id, Analytics_Top_Content__c> contentBookMarksCountMap;
	public Map<Id, Analytics_Top_Content__c> contentViewsCountMap;
	public Map<Id, Analytics_Top_Content__c> contentPostsCountMap;
	public Map<Id, Analytics_Top_Content__c> contentCommentsCountMap;
	public Map<Id, Analytics_Top_Content__c> contentLikesCountMap;
	public Map<Id, Analytics_Top_Content__c> contentUnusefulCountMap;
	public Map<Id, Analytics_Top_Content__c> contentUsefulCountMap;
    DateTime startDateTime ;
    DateTime endDateTime ;
    Date startDate ;
    Date endDate;
    String recordType;
    List<Object> analyticWrapperList;
    
    /**
    * 
    * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
    * Parameters:
    * parameter_name -- [Explanation of the purpose of this parameter to the method.
    *      
    * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public BatchTopContentsAnalytics(String recordType, Date dateArg) {
    	
        startDate = dateArg;
        endDate = dateArg.addDays(1) ;
        this.recordType = recordType;
        
        startDateTime = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day(), 0, 0, 0);  
        endDateTime = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day(), 0, 0, 0);    
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public database.querylocator start(Database.BatchableContext bc) {
    	String query;
    	
    	if('initAnalyticsData'.equalsIgnoreCase(recordType)){
			query = 'SELECT Id'
						+ ' FROM Simpplr_Content__c ' 
						+ ' where (LastModifiedDate >=: startDateTime OR (Publish_Start_DateTime__c >=: startDateTime AND Publish_Start_DateTime__c <: endDateTime))'
						+ ' And Status__c = \'Approved\' ';

    	} else if('sendAnalyticsDataToAWS'.equalsIgnoreCase(recordType)){
    		query = 'select Id, Name, Bookmarks__c, Content__c, Date__c, Is_Published__c, Likes__c, Popularity_Score__c, Posts__c, Replies__c, Content__r.Site__c, '
    				+' Shares__c, Unuseful__c, Useful__c, Views__c, CreatedDate, LastModifiedDate, Content__r.Type__c, Sync_Status__c, is_validated__c, is_validation_expired__c, is_validation_pending__c from Analytics_Top_Content__c' 
    				+' where Sync_Status__c !=:SYNC_STATUS_SENT ';
    	
		} else if('sendAnalyticsTopicSuggestionDataToAWS'.equalsIgnoreCase(recordType)){
			query = 'SELECT Suggested_Topics__c, Content__c, People__c, Date__c, Sync_Status__c, Content_Topics__c, LastModifiedDate, CreatedDate, Name, Id FROM Analytics_Topic_Suggestion__c' 
					+' where Sync_Status__c !=:SYNC_STATUS_SENT ';
					
		
    	} else if('sendContentDataToAWS'.equalsIgnoreCase(recordType)) {
    		query = 'select Id, Site__c, Type__c, Title__c, Is_Deleted__c, primary_author__c, First_Publish_DateTime__c, Publish_Start_DateTime__c, Publish_End_DateTime__c, Last_Validated_DateTime__c, Status__c, Content_Sub_Type__c, Album_Video_Count__c, Album_Image_Count__c, Version__c,Event_RSVP_By_DateTime__c,Event_RSVP_Allowed__c, Read_Time__c, Content_Onboarding_Status__c, Onboarding_Added_Date__c from Simpplr_Content__c ';
    		
    		List<Package_Upgrade_History__c> uhList=[select id, createddate from Package_Upgrade_History__c order by createddate desc limit 1];
    		DateTime cutOffTime = DateTime.now().addDays(-3);
    		if(!uhList.isEmpty() && uhList[0].createddate < cutOffTime) {
    			query += ' Where LastModifiedDate >=:startDate ';    			
    		}

    	} 
    	
    	return Database.getQueryLocator(query);
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public void execute(Database.BatchableContext bc, List<sObject> listOfsObject) {
    	
    		try {
	    		if('initAnalyticsData'.equalsIgnoreCase(recordType)){
		    		initAnalyticsData((List<Simpplr_Content__c>)listOfsObject);
		    		
	    		}else if('sendAnalyticsDataToAWS'.equalsIgnoreCase(recordType)) {
	    			PushAnalyticsDataHelper analyticsHandler = new PushAnalyticsDataHelper();
	    			analyticsHandler.sendAnalticsTopContentListToAWS(listOfsObject);
					
				}else if('sendAnalyticsTopicSuggestionDataToAWS'.equalsIgnoreCase(recordType)) {
	    			PushAnalyticsDataHelper analyticsHandler = new PushAnalyticsDataHelper();
	    			analyticsHandler.sendAnalyticsTopicSuggestionDataToAWS(listOfsObject);
			
				} else if('sendContentDataToAWS'.equalsIgnoreCase(recordType)) { 
	    			PushAnalyticsDataHelper analyticsHandler = new PushAnalyticsDataHelper();
	    			List<Simpplr_Content__c> updatedContentList = new List<Simpplr_Content__c>(); 
	    			for(Simpplr_Content__c contentObj : (List<Simpplr_Content__c>)listOfsObject) {
	    				if(contentObj.First_Publish_DateTime__c != null && contentObj.First_Publish_DateTime__c.year() > 2034) {
	    					contentObj.First_Publish_DateTime__c = contentObj.First_Publish_DateTime__c.addYears(-20);
	    					updatedContentList.add(contentObj);
	    				}
	    			}
	    			analyticsHandler.sendContentListToAWS(listOfsObject);

					if(!updatedContentList.isEmpty()){
						
						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
						SIMPESAPI.accessController().updateAsUser(new Map<Id, Simpplr_Content__c>(updatedContentList), new List<Schema.SObjectField>{Simpplr_Content__c.First_Publish_DateTime__c});
					}
	    		}
	    } catch(Exception ex) {
	    		Utility.sendBatchFailedExceptionEmail('BatchTopContentsAnalytics', ex);
	    	}
    }
    
    private void initAnalyticsData(List<Simpplr_Content__c> listOfContent) {
    		List<Id> toBeProcessedContentIds = new List<Id>();
		contentSharesCountMap = new Map<Id, Analytics_Top_Content__c>();
		contentBookMarksCountMap = new Map<Id, Analytics_Top_Content__c>();
		contentViewsCountMap = new Map<Id, Analytics_Top_Content__c>();
		contentPostsCountMap = new Map<Id, Analytics_Top_Content__c>();
		contentCommentsCountMap = new Map<Id, Analytics_Top_Content__c>();
		contentLikesCountMap = new Map<Id, Analytics_Top_Content__c>();
		contentUnusefulCountMap = new Map<Id, Analytics_Top_Content__c>();
		contentUsefulCountMap = new Map<Id, Analytics_Top_Content__c>();
		consolidatedMap = new Map <Id, Analytics_Top_Content__c>();
	    	for(Simpplr_Content__c contentObj : listOfContent) {
	    		toBeProcessedContentIds.add(contentObj.Id);
	    	}
		updateConsolidatedMap(toBeProcessedContentIds); 
		saveBatchData();
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public void finish(Database.BatchableContext bc) {
    	
		if('initAnalyticsData'.equalsIgnoreCase(recordType)){
			BatchTopContentsAnalytics job = new BatchTopContentsAnalytics('sendContentDataToAWS', startDate);
			Database.executeBatch(job, 500);
		
		} else if('sendContentDataToAWS'.equalsIgnoreCase(recordType)){
			BatchTopContentsAnalytics job = new BatchTopContentsAnalytics('sendAnalyticsDataToAWS', startDate);
	    	Database.executeBatch(job, 1000);
		
		} else if('sendAnalyticsDataToAWS'.equalsIgnoreCase(recordType)){
			BatchTopContentsAnalytics job = new BatchTopContentsAnalytics('sendAnalyticsTopicSuggestionDataToAWS', startDate);
			Database.executeBatch(job, 1000);	
		
		} else {
			BatchPeopleAnalytics job = new BatchPeopleAnalytics('initAnalyticsData', startDate);
			Database.executeBatch(job, 100);
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
    private void saveBatchData() {
    	try {
	    	List<Analytics_Top_Content__c> analyticsList = (List<Analytics_Top_Content__c>)consolidatedMap.values();
	    	
	    	// save map values/data

			if(analyticsList.isEmpty() == false){

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().upsertAsUser(analyticsList, new List<Schema.SObjectField> {
						Analytics_Top_Content__c.Sync_Status__c,
						Analytics_Top_Content__c.Bookmarks__c,
						Analytics_Top_Content__c.Likes__c,
						Analytics_Top_Content__c.Shares__c,
						Analytics_Top_Content__c.Posts__c,
						Analytics_Top_Content__c.Replies__c,
						Analytics_Top_Content__c.Views__c,
						Analytics_Top_Content__c.Unuseful__c,
						Analytics_Top_Content__c.Useful__c,
						Analytics_Top_Content__c.Content__c,
						Analytics_Top_Content__c.Date__c,
						Analytics_Top_Content__c.is_validated__c,
						Analytics_Top_Content__c.is_validation_expired__c,
						Analytics_Top_Content__c.is_validation_pending__c
				});
			}
		
    	} catch(Exception ex) {
    		Utility.sendBatchFailedExceptionEmail('BatchTopContentsAnalytics', ex);
    	}
    }

	private Map<String, Set<String>> getKnowledgePageDetails(List<Id> contentIdList){
		Map<String, Set<String>> knowlegdePageDataMap = new Map<String, Set<String>>();

		Datetime expiry28DaysEndDate = startDateTime.addDays(28);
		Datetime expiryStartDateTime = startDateTime.addMonths(- SimpplrContext.validationPeriodMonth);
		Datetime expiry28DaysStartDateTime = expiryStartDateTime.addDays(28);

		List<Content_Audit_Trail__c> validationExpiredContentList = [SELECT content__c FROM Content_Audit_Trail__c WHERE
						Content__r.Type__c = 'Page' AND Content__r.Content_Sub_Type__c = 'knowledge' AND
						Action__c = 'Validation Expired' AND
						Content__r.Is_Unpublished__c = true AND Content__r.Is_Deleted__c = false AND
						Action_DateTime__c >= :startDateTime AND Action_DateTime__c < :endDateTime AND Content__c IN :contentIdList]; 	

		List<Content_Audit_Trail__c> validatedContentList = [SELECT content__c FROM Content_Audit_Trail__c WHERE Content__r.Type__c = 'Page'
					  AND Content__r.Content_Sub_Type__c = 'knowledge' AND 
					  Action__c = 'Validated' AND Content__r.Last_Validated_DateTime__c >= :startDateTime AND
					  Action_DateTime__c < :endDateTime AND Content__c IN :contentIdList];	

		List<Content_Audit_Trail__c> validatedPendingContentList = [SELECT content__c FROM Content_Audit_Trail__c WHERE Content__r.Type__c = 'Page'
					  AND Content__r.Content_Sub_Type__c = 'knowledge' AND 
					  Content__r.Is_Published__c = true AND Content__r.Is_Deleted__c = false AND 
					   (Content__r.Publish_End_DateTime__c = null OR Content__r.Publish_End_DateTime__c >= :expiry28DaysEndDate) AND 
					   ( 
					 	(Content__r.Last_Validated_DateTime__c = null AND Content__r.Publish_Start_DateTime__c <= :expiry28DaysStartDateTime) 
					 	OR 
					 	(Content__r.Last_Validated_DateTime__c != null AND Content__r.Last_Validated_DateTime__c <= :expiry28DaysStartDateTime) 
					   ) AND Content__c IN :contentIdList ];	

		Set<String> validationExpiredContentIdSet = new Set<String>();
 		for(Content_Audit_Trail__c obj : validationExpiredContentList){
			 validationExpiredContentIdSet.add(obj.content__c);
		}

		Set<String> validatedContentIdSet = new Set<String>();
 		for(Content_Audit_Trail__c obj : validatedContentList){
			 validatedContentIdSet.add(obj.content__c);
		}

		Set<String> validationRequiredContentIdSet = new Set<String>();
 		for(Content_Audit_Trail__c obj : validatedPendingContentList){
			 validationRequiredContentIdSet.add(obj.content__c);
		}

		knowlegdePageDataMap.put('validationExpiredContent', validationExpiredContentIdSet);
		knowlegdePageDataMap.put('validatedContent', validatedContentIdSet);
		knowlegdePageDataMap.put('validationRequiredContent', validationRequiredContentIdSet);

		return knowlegdePageDataMap;		
	}
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private void getContentShares(List<Id> toBeProcessedContentIds) {
    	Analytics_Top_Content__c analyticsObj = new Analytics_Top_Content__c();
    	
    	List<AggregateResult> sSAList = [Select Content__c contentId, count(Id) SharesCount from Share__c 
    										where CreatedDate >=: startDateTime AND CreatedDate <: endDateTime 
    										and Content__c IN :toBeProcessedContentIds
    										GROUP BY Content__c ];
    	
    	for(AggregateResult ar : sSAList) {
    		String contentId = (Id)ar.get('contentId');
    		
    		if(String.isNotBlank(contentId)) {
    			analyticsObj = new Analytics_Top_Content__c();
    			analyticsObj.Shares__c = (Decimal)ar.get('SharesCount');
    			analyticsObj.Content__c = contentId;
    			
    			contentSharesCountMap.put(contentId, analyticsObj);
    		}
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
    private void getContentBookMarks(List<Id> toBeProcessedContentIds) {
    	Analytics_Top_Content__c analyticsObj = new Analytics_Top_Content__c();
    	
    	List<AggregateResult> sSAList = [Select Simpplr_Content__c contentId, count(Id) BookMarksCount from Bookmark__c 
    										where CreatedDate >=: startDateTime AND CreatedDate <: endDateTime  AND Is_Deleted__c = false
    										and Simpplr_Content__c IN :toBeProcessedContentIds
    										GROUP BY Simpplr_Content__c ];
    	
    	for(AggregateResult ar : sSAList) {
    		String contentId = (Id)ar.get('contentId');
    		
    		if(String.isNotBlank(contentId)) {
    			analyticsObj = new Analytics_Top_Content__c();
    			analyticsObj.BookMarks__c = (Decimal)ar.get('BookMarksCount');
    			analyticsObj.Content__c = contentId;
    			
    			contentBookMarksCountMap.put(contentId, analyticsObj);
    		}
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
    private void getContentViews(List<Id> toBeProcessedContentIds) {
    	Analytics_Top_Content__c analyticsObj = new Analytics_Top_Content__c();
    	
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', startDateTime);
		soqlParamMap.put('soqlParam2', endDateTime);
		soqlParamMap.put('soqlParam3', toBeProcessedContentIds);
		String socialAnlytcsQuery = 'Select Content__c contentId, count(Id) ViewsCount from Simpplr_Social_Analytics__c  ' +
			' where CreatedDate >=: soqlParam1 AND CreatedDate <: soqlParam2 ' +
			' and Interaction__c = \'View\' and Content__c IN :soqlParam3 ' +
			' GROUP BY Content__c';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<AggregateResult> sSAList = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(socialAnlytcsQuery, soqlParamMap);
    	
    	for(AggregateResult ar : sSAList) {
    		String contentId = (Id)ar.get('contentId');
    		
    		if(String.isNotBlank(contentId)) {
    			analyticsObj = new Analytics_Top_Content__c();
    			analyticsObj.Views__c = (Decimal)ar.get('ViewsCount');
    			analyticsObj.Content__c = contentId;
    			
    			contentViewsCountMap.put(contentId, analyticsObj);
    		}
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
    private void getContentPosts(List<Id> toBeProcessedContentIds) {
    	Analytics_Top_Content__c analyticsObj = new Analytics_Top_Content__c();
    	
		// Content Feed/Posts
		Set<String> ignoredfeedItemTypes = new Set<String>{'TrackedChange','LinkPost'};
    	List<AggregateResult> contentFeedList = [select ParentId, count(Id) PostsCount from Simpplr_Content__Feed 
    											where CreatedDate >=: startDateTime AND CreatedDate <: endDateTime
												and ParentId IN :toBeProcessedContentIds 
												And type!=:ignoredfeedItemTypes
    											GROUP BY ParentId ];
    	
    	for(AggregateResult ar : contentFeedList) {
    		String contentId = (Id)ar.get('ParentId');
    		
    		if(String.isNotBlank(contentId)) {
	    		analyticsObj = new Analytics_Top_Content__c();
	    		analyticsObj.Posts__c = (Decimal)ar.get('PostsCount');
	    		analyticsObj.Content__c = contentId;
	    		contentPostsCountMap.put(contentId, analyticsObj);
    		}
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
    private void getContentComments(List<Id> toBeProcessedContentIds) {
    	Analytics_Top_Content__c analyticsObj = new Analytics_Top_Content__c();
    	
    	List<AggregateResult> feedList = [select ParentId, count(Id) ReplyCount from FeedComment 
    											where CreatedDate >=: startDateTime AND CreatedDate <: endDateTime 
    											and ParentId IN :toBeProcessedContentIds 
    											GROUP BY ParentId ];
    	
    	for(AggregateResult ar : feedList) {
    		String contentId = (Id)ar.get('ParentId');
    		
    		if(String.isNotBlank(contentId)) {
    			analyticsObj = new Analytics_Top_Content__c();
	    		analyticsObj.Replies__c = (Decimal)ar.get('ReplyCount');
	    		analyticsObj.Content__c = contentId;
    		
    			contentCommentsCountMap.put(contentId, analyticsObj);
    		}
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
    private void getContentLikes(List<Id> toBeProcessedContentIds) {
    	Analytics_Top_Content__c analyticsObj = new Analytics_Top_Content__c();
    	
    	// New likes on content (content likes only.. excluding feed likes)
    	List<AggregateResult> likeObjList = [Select Content__c contentId, count(Id) LikesCount From Like__c 
    											where CreatedDate >=: startDateTime AND CreatedDate <: endDateTime 
    											AND Content__c IN :toBeProcessedContentIds 
    											GROUP BY Content__c ];
    	
    	for(AggregateResult ar : likeObjList) {
    		String contentId = (Id)ar.get('contentId');
    		
    		if(String.isNotBlank(contentId)) {
	    		analyticsObj = new Analytics_Top_Content__c();
	    		analyticsObj.Likes__c = (Decimal)ar.get('LikesCount');
	    		analyticsObj.Content__c = contentId;
	    		contentLikesCountMap.put(contentId, analyticsObj);
    		}
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
    private void getContentUnuseful(List<Id> toBeProcessedContentIds) {
    	Analytics_Top_Content__c analyticsObj = new Analytics_Top_Content__c();
    	
    	// Content - Useful count
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', startDateTime);
		soqlParamMap.put('soqlParam2', endDateTime);
		soqlParamMap.put('soqlParam3', toBeProcessedContentIds);
		String feedbackQuery = 'Select Simpplr_Content__c contentId, count(Id) UnusefulCount From Content_Feedback__c ' +
			' where CreatedDate >=: soqlParam1 AND CreatedDate <: soqlParam2 ' +
			' AND Was_Content_Useful__c = false AND Is_Deleted__c = false ' +
			' AND Simpplr_Content__c IN :soqlParam3 ' +
			' GROUP BY Simpplr_Content__c';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<AggregateResult> unusefulObjList = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(feedbackQuery, soqlParamMap);
    	
    	for(AggregateResult ar : unusefulObjList) {
    		String contentId = (Id)ar.get('contentId');
    		
    		if(String.isNotBlank(contentId)) {
	    		analyticsObj = new Analytics_Top_Content__c();
	    		analyticsObj.Unuseful__c = (Decimal)ar.get('UnusefulCount');
	    		analyticsObj.Content__c = contentId;
	    		contentUnusefulCountMap.put(contentId, analyticsObj);
    		}
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
    private void getContentUseful(List<Id> toBeProcessedContentIds) {
    	Analytics_Top_Content__c analyticsObj = new Analytics_Top_Content__c();
    	
    	// Content - Useful count
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', startDateTime);
		soqlParamMap.put('soqlParam2', endDateTime);
		soqlParamMap.put('soqlParam3', toBeProcessedContentIds);
		String feedbackQuery = 'Select Simpplr_Content__c contentId, count(Id) UsefulCount From Content_Feedback__c ' +
			' where CreatedDate >=: soqlParam1 AND CreatedDate <: soqlParam2 ' +
			' AND Was_Content_Useful__c = true AND Is_Deleted__c = false ' +
			' AND Simpplr_Content__c IN :soqlParam3 ' +
			' GROUP BY Simpplr_Content__c';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<AggregateResult> usefulObjList = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(feedbackQuery, soqlParamMap);
    	
    	for(AggregateResult ar : usefulObjList) {
    		String contentId = (Id)ar.get('contentId');
    		
    		if(String.isNotBlank(contentId)) {
	    		analyticsObj = new Analytics_Top_Content__c();
	    		analyticsObj.Useful__c = (Decimal)ar.get('UsefulCount');
	    		analyticsObj.Content__c = contentId;
	    		contentUsefulCountMap.put(contentId, analyticsObj);
    		}
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
    private void updateConsolidatedMap(List<Id> toBeProcessedContentIds) {
    	Analytics_Top_Content__c analyticsObj = null;
		map<ID,ID>mapContentToAnalytic = new map<ID,ID>();
		
		getContentShares(toBeProcessedContentIds);                           // ------ Shares
		getContentBookMarks(toBeProcessedContentIds);                        // ------ Bookmarks
		getContentViews(toBeProcessedContentIds);                            // ------ Views
		getContentPosts(toBeProcessedContentIds);                            // ------ Posts
		getContentComments(toBeProcessedContentIds);                         // ------ Comments
		getContentLikes(toBeProcessedContentIds);                            // ------ Likes
		getContentUnuseful(toBeProcessedContentIds);                         // ------ Unuseful
		getContentUseful(toBeProcessedContentIds);                           // ------ Useful
			
		list<Analytics_Top_Content__c> existTopContentAnalytic = [select id, Content__c from Analytics_Top_Content__c where Content__c IN : toBeProcessedContentIds and Date__c =: startDate];
		for(Analytics_Top_Content__c atc: existTopContentAnalytic){
			mapContentToAnalytic.put(atc.Content__c, atc.ID);
		}

		Map<String, Set<String>> contentMap = null;
		if(SimpplrContext.isContentGovernanceEnabled){
			contentMap = getKnowledgePageDetails(toBeProcessedContentIds);
		}

    	for(Id contentID : toBeProcessedContentIds){
			
			if(mapContentToAnalytic.containsKey(contentID)){
				analyticsObj = new Analytics_Top_Content__c(ID = mapContentToAnalytic.get(contentID));
				analyticsObj.Sync_Status__c = null;
			}else{
				analyticsObj = new Analytics_Top_Content__c();
			}
			analyticsObj.Bookmarks__c =0;
			analyticsObj.Likes__c =0;
			analyticsObj.Shares__c =0;
			analyticsObj.Posts__c =0;
			analyticsObj.Replies__c	=0;
			analyticsObj.Views__c =0;
			analyticsObj.Unuseful__c =0;
			analyticsObj.Useful__c =0;
			
			if(contentSharesCountMap.containskey(contentID)){
    			analyticsObj.Shares__c = contentSharesCountMap.get(contentID).Shares__c;
			}
			if(contentBookMarksCountMap.containskey(contentID)){
    			analyticsObj.BookMarks__c = contentBookMarksCountMap.get(contentID).BookMarks__c;
			}
			if(contentViewsCountMap.containskey(contentID)){
   				analyticsObj.Views__c = contentViewsCountMap.get(contentID).Views__c;
			}
			if(contentPostsCountMap.containskey(contentID)){
   				analyticsObj.Posts__c = contentPostsCountMap.get(contentID).Posts__c;
			}
			if(contentCommentsCountMap.containskey(contentID)){
   				analyticsObj.Replies__c = contentCommentsCountMap.get(contentID).Replies__c;
			}
			if(contentLikesCountMap.containskey(contentID)){
   				analyticsObj.Likes__c = contentLikesCountMap.get(contentID).Likes__c;
			}
			if(contentUnusefulCountMap.containskey(contentID)){
   				analyticsObj.Unuseful__c = contentUnusefulCountMap.get(contentID).Unuseful__c;
			}
			if(contentUsefulCountMap.containskey(contentID)){
   				analyticsObj.Useful__c = contentUsefulCountMap.get(contentID).Useful__c;
			}
			analyticsObj.Content__c = contentID;
			analyticsObj.Date__c = startDate;

			if(contentMap != null){
				analyticsObj.is_validated__c = contentMap.get('validatedContent').contains(contentID);
				analyticsObj.is_validation_expired__c = contentMap.get('validationExpiredContent').contains(contentID);
				analyticsObj.is_validation_pending__c = contentMap.get('validationRequiredContent').contains(contentID);

			} else {
				analyticsObj.is_validated__c = false;
				analyticsObj.is_validation_expired__c = false;
				analyticsObj.is_validation_pending__c = false;

			}
			
			consolidatedMap.put(analyticsObj.Content__c, analyticsObj);
		}
    }
}