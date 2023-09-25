/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class BatchContentCountAnalytics implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    
    private static final List<Integer> SYNC_STATUS_SENT = new List<Integer> {1,3,5};
    // this map will hold the final/consolidated records that will be inserted into analytics table 
    public Map<Id, Analytics_Content_Count__c> consolidatedMap = new Map <Id, Analytics_Content_Count__c>();
    
    public Map<Id, Id> contentIdNSiteIdMap = new Map<Id, Id>();
    
    DateTime startDateTime ;
    DateTime endDateTime ;
    Date startDate ;
    Date endDate ;
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
    public BatchContentCountAnalytics(String recordType, Date dateArg) {
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
    public BatchContentCountAnalytics() {
        endDate = System.today();
        startDate = endDate.addDays(-1);
        
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
    	query = 'SELECT Id FROM Simpplr_Content__c where (LastModifiedDate >=: startDateTime OR (Publish_Start_DateTime__c >=: startDateTime AND Publish_Start_DateTime__c <: endDateTime))'
    					+ ' And Type__c IN (\'News\', \'Page\', \'Event\', \'Album\', \'BlogPost\')';
    	} else if('sendAnalyticsDataToAWS'.equalsIgnoreCase(recordType)){
    		query = 'select Id, Albums__c, Blogs__c, Bookmarks__c, Date__c,Events__c,Likes__c, Pages__c, Posts__c, Replies__c,Shares__c, Site__c,'
    				+' Views__c, Sync_Status__c from Analytics_Content_Count__c where Sync_Status__c !=:SYNC_STATUS_SENT ';
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
	    	List<Id> toBeProcessedContentIds = new List<Id>(); 
	    	for(sObject sObj : listOfsObject) {
	    		Simpplr_Content__c contentObj = (Simpplr_Content__c)sObj;
	    		toBeProcessedContentIds.add(contentObj.Id);
	    	}
	    	
	    	
	    	updateConsolidatedMap(getContentPublished(toBeProcessedContentIds));                                               // ------ Published 
	    	
	    	updateConsolidatedMap(getContentShares(toBeProcessedContentIds));                           // ------ Shares 
	    	
	    	updateConsolidatedMap(getContentBookMarks(toBeProcessedContentIds));                        // ------ Bookmarks 
	    	
	    	updateConsolidatedMap(getContentViews(toBeProcessedContentIds));                            // ------ Views 
	    	
	    	updateConsolidatedMap(getContentPosts(toBeProcessedContentIds));                            // ------ Posts 
	    	
	    	updateConsolidatedMap(getContentComments(toBeProcessedContentIds));                         // ------ Comments 
	    	
	    	updateConsolidatedMap(getContentLikes(toBeProcessedContentIds));                            // ------ Likes 
    		} else if('sendAnalyticsDataToAWS'.equalsIgnoreCase(recordType)) {
    			PushAnalyticsDataHelper analyticsHandler = new PushAnalyticsDataHelper();
    			analyticsHandler.sendAnalticsContentCountListToAWS(listOfsObject);
    		}
    	} catch(Exception ex) {
			Utility.sendBatchFailedExceptionEmail('BatchContentCountAnalytics', ex);
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
    public void finish(Database.BatchableContext bc){
    	
		if('initAnalyticsData'.equalsIgnoreCase(recordType)){
			saveBatchData();
		}
		if( 'initAnalyticsData'.equalsIgnoreCase(recordType)) {
			BatchContentCountAnalytics job = new BatchContentCountAnalytics('sendAnalyticsDataToAWS', startDate);
			Database.executeBatch(job, 100);
	    	
	    	} else {
	    		BatchPageViewAnalytics job = new BatchPageViewAnalytics('initAnalyticsData', startDate);
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
	    	List<Analytics_Content_Count__c> analyticsList = (List<Analytics_Content_Count__c>)consolidatedMap.values();
	    	
	    	// save map values/data
	    	insert analyticsList;
    	} catch(Exception ex) {
    		Utility.sendBatchFailedExceptionEmail('BatchContentCountAnalytics', ex);
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
    private Map<Id, Analytics_Content_Count__c> getContentPublished(List<Id> toBeProcessedContentIds) {
    	Analytics_Content_Count__c analyticsObj = new Analytics_Content_Count__c();
    	Map<Id, Analytics_Content_Count__c> publishedContentCountMap = new Map <Id, Analytics_Content_Count__c>();
    	
    	List<AggregateResult> contentList = [select Site__c siteId, Type__c contentType, count(Id) ContentCount from Simpplr_Content__c 
    											where Status__c='Approved' AND Id IN :toBeProcessedContentIds  
    											AND Type__c IN ('News', 'Page', 'Event', 'Album', 'BlogPost') 
    											AND Publish_Start_DateTime__c >=: startDateTime AND Publish_Start_DateTime__c <: endDateTime 
    											GROUP BY Site__c, Type__c ];
    	
    	for(AggregateResult ar : contentList) {
    		String siteId = (Id)ar.get('siteId');
    		
			if(publishedContentCountMap.containsKey(siteId) == true) {
	    		analyticsObj = publishedContentCountMap.get(siteId);
			}
			else {
				analyticsObj = new Analytics_Content_Count__c();
				analyticsObj.Pages__c = 0;
				analyticsObj.Events__c = 0;
				analyticsObj.Albums__c = 0;
				analyticsObj.Blogs__c = 0;
			}
			
    		if('Page'.equalsIgnoreCase((String)ar.get('contentType'))) {
    			analyticsObj.Pages__c += (Decimal)ar.get('ContentCount');
    		}
    		if('Event'.equalsIgnoreCase((String)ar.get('contentType'))) {
    			analyticsObj.Events__c += (Decimal)ar.get('ContentCount');
    		}
    		if('Album'.equalsIgnoreCase((String)ar.get('contentType'))) {
    			analyticsObj.Albums__c += (Decimal)ar.get('ContentCount');
    		}
    		if('BlogPost'.equalsIgnoreCase((String)ar.get('contentType'))) {
    			analyticsObj.Blogs__c += (Decimal)ar.get('ContentCount');
    		}
    		
    		analyticsObj.Site__c = siteId;
    		publishedContentCountMap.put(siteId, analyticsObj);
    	}
    	
    	return publishedContentCountMap;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private Map<Id, Analytics_Content_Count__c> getContentShares(List<Id> toBeProcessedContentIds) {
    	Analytics_Content_Count__c analyticsObj = new Analytics_Content_Count__c();
    	Map<Id, Analytics_Content_Count__c> contentSharesCountMap = new Map<Id, Analytics_Content_Count__c>();
    	
    	List<AggregateResult> sSAList = [Select Content__c contentId, count(Id) SharesCount from Share__c 
    										where CreatedDate >=: startDateTime AND CreatedDate <: endDateTime 
    										and Content__c IN :toBeProcessedContentIds
    										GROUP BY Content__c ];
    	
    	List<Id> allContentIds = new List<Id>(); // contentId list for contents which have new feeds
    	for(AggregateResult ar : sSAList) {
    		allContentIds.add((Id)ar.get('contentId'));
    	}
    	contentIdNSiteIdMap = getContentIdAndSiteIdMap(allContentIds);
    	
    	for(AggregateResult ar : sSAList) {
    		String contentId = (Id)ar.get('contentId');
    		String siteId = contentIdNSiteIdMap.get(contentId);
    		
			Decimal sharesCount = 0;
    		if(contentSharesCountMap.containsKey(siteId) == true && contentSharesCountMap.get(siteId).Shares__c != null) {
    			sharesCount = contentSharesCountMap.get(siteId).Shares__c;
    		}
			
			analyticsObj = new Analytics_Content_Count__c();
			analyticsObj.Shares__c = sharesCount + (Decimal)ar.get('SharesCount');
			analyticsObj.Site__c = siteId;
			
			contentSharesCountMap.put(siteId, analyticsObj);
    	}
    	
    	return contentSharesCountMap;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private Map<Id, Analytics_Content_Count__c> getContentBookMarks(List<Id> toBeProcessedContentIds) {
    	Analytics_Content_Count__c analyticsObj = new Analytics_Content_Count__c();
    	Map<Id, Analytics_Content_Count__c> contentBookMarksCountMap = new Map<Id, Analytics_Content_Count__c>();
    	
    	List<AggregateResult> sSAList = [Select Simpplr_Content__c contentId, count(Id) BookMarksCount from Bookmark__c 
    										where CreatedDate >=: startDateTime AND CreatedDate <: endDateTime 
    										AND Simpplr_Content__c IN :toBeProcessedContentIds AND Is_Deleted__c = false
    										GROUP BY Simpplr_Content__c ];
    	
    	List<Id> allContentIds = new List<Id>(); // contentId list for contents which have new feeds
    	for(AggregateResult ar : sSAList) {
    		allContentIds.add((Id)ar.get('contentId'));
    	}
    	contentIdNSiteIdMap = getContentIdAndSiteIdMap(allContentIds);
    	
    	for(AggregateResult ar : sSAList) {
    		String contentId = (Id)ar.get('contentId');
    		String siteId = contentIdNSiteIdMap.get(contentId);
    		
			Decimal bookmarkCount = 0;
    		if(contentBookMarksCountMap.containsKey(siteId) == true && contentBookMarksCountMap.get(siteId).BookMarks__c != null) {
    			bookmarkCount = contentBookMarksCountMap.get(siteId).BookMarks__c;
    		}
			
			analyticsObj = new Analytics_Content_Count__c();
			analyticsObj.BookMarks__c = bookmarkCount + (Decimal)ar.get('BookMarksCount');
			analyticsObj.Site__c = siteId;
			
			contentBookMarksCountMap.put(siteId, analyticsObj);
    	}
    	
    	return contentBookMarksCountMap;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private Map<Id, Analytics_Content_Count__c> getContentViews(List<Id> toBeProcessedContentIds) {
    	Analytics_Content_Count__c analyticsObj = new Analytics_Content_Count__c();
    	Map<Id, Analytics_Content_Count__c> contentViewsCountMap = new Map<Id, Analytics_Content_Count__c>();
    	
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', startDateTime);
		soqlParamMap.put('soqlParam2', endDateTime);
		soqlParamMap.put('soqlParam3', toBeProcessedContentIds);
		String socialAnlytcsQuery = ' Select Content__c contentId, count(Id) ViewsCount from Simpplr_Social_Analytics__c ' +
			' where CreatedDate >=: soqlParam1 AND CreatedDate <: soqlParam2 ' +
			' and Interaction__c = \'View\' and Content__c IN :soqlParam3 ' +
			' GROUP BY Content__c';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<AggregateResult> sSAList = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(socialAnlytcsQuery, soqlParamMap);
    	
    	List<Id> allContentIds = new List<Id>();
    	for(AggregateResult ar : sSAList) {
    		allContentIds.add((Id)ar.get('contentId'));
    	}
    	contentIdNSiteIdMap = getContentIdAndSiteIdMap(allContentIds);
    	
    	for(AggregateResult ar : sSAList) {
    		String contentId = (Id)ar.get('contentId');
    		String siteId = contentIdNSiteIdMap.get(contentId);
    		
			Decimal viewsCount = 0;
    		if(contentViewsCountMap.containsKey(siteId) == true && contentViewsCountMap.get(siteId).Views__c != null) {
    			viewsCount = contentViewsCountMap.get(siteId).Views__c;
    		}
			
			analyticsObj = new Analytics_Content_Count__c();
			analyticsObj.Views__c = viewsCount + (Decimal)ar.get('ViewsCount');
			analyticsObj.Site__c = siteId;
			
			contentViewsCountMap.put(siteId, analyticsObj);
    	}
    	
    	return contentViewsCountMap;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private Map<Id, Analytics_Content_Count__c> getContentPosts(List<Id> toBeProcessedContentIds) {
    	Analytics_Content_Count__c analyticsObj = new Analytics_Content_Count__c();
    	Map<Id, Analytics_Content_Count__c> contentPostsCountMap = new Map <Id, Analytics_Content_Count__c>();
    	
    	// Content Feed/Posts
    	List<AggregateResult> contentFeedList = [select ParentId, count(Id) PostsCount from Simpplr_Content__Feed 
    											where CreatedDate >=: startDateTime AND CreatedDate <: endDateTime 
    											and ParentId IN :toBeProcessedContentIds 
    											GROUP BY ParentId ];
    	
    	List<Id> allContentIds = new List<Id>(); // contentId list for contents which have new feeds
    	for(AggregateResult ar : contentFeedList) {
    		allContentIds.add((Id)ar.get('ParentId'));
    	}
    	contentIdNSiteIdMap = getContentIdAndSiteIdMap(allContentIds);
    	
    	for(AggregateResult ar : contentFeedList) {
    		String contentId = (Id)ar.get('ParentId');
    		String siteId = contentIdNSiteIdMap.get(contentId);
    		
    		Decimal postsCount = 0;
    		if(contentPostsCountMap.containsKey(siteId) == true && contentPostsCountMap.get(siteId).Posts__c != null) {
    			postsCount = contentPostsCountMap.get(siteId).Posts__c;
    		}
			
			analyticsObj = new Analytics_Content_Count__c();
    		analyticsObj.Posts__c = postsCount + (Decimal)ar.get('PostsCount');
    		analyticsObj.Site__c = siteId;
    		contentPostsCountMap.put(siteId, analyticsObj);
    	}
    	
    	return contentPostsCountMap;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private Map<Id, Analytics_Content_Count__c> getContentComments(List<Id> toBeProcessedContentIds) {
    	Analytics_Content_Count__c analyticsObj = new Analytics_Content_Count__c();
    	Map<Id, Analytics_Content_Count__c> contentCommentsCountMap = new Map <Id, Analytics_Content_Count__c>();
    	
    	// Site Feed
    	List<AggregateResult> feedList = [select ParentId, count(Id) ReplyCount from FeedComment 
    											where CreatedDate >=: startDateTime AND CreatedDate <: endDateTime
    											and ParentId IN :toBeProcessedContentIds 
    											GROUP BY ParentId ];
    	
    	List<Id> allContentIds = new List<Id>(); // contentId list for contents which have new feeds
    	for(AggregateResult ar : feedList) {
    		allContentIds.add((Id)ar.get('ParentId'));
    	}
    	contentIdNSiteIdMap = getContentIdAndSiteIdMap(allContentIds);
    	
    	for(AggregateResult ar : feedList) {
    		String contentId = (Id)ar.get('ParentId');
    		String siteId = contentIdNSiteIdMap.get(contentId);
    		
			Decimal repliesCount = 0;
    		if(contentCommentsCountMap.containsKey(siteId) == true && contentCommentsCountMap.get(siteId).Replies__c != null) {
    			repliesCount = contentCommentsCountMap.get(siteId).Replies__c;
    		}
			
			analyticsObj = new Analytics_Content_Count__c();
    		analyticsObj.Replies__c = repliesCount + (Decimal)ar.get('ReplyCount');
    		analyticsObj.Site__c = siteId;
		
			contentCommentsCountMap.put(siteId, analyticsObj);
    	}
    	
    	return contentCommentsCountMap;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private Map<Id, Analytics_Content_Count__c> getContentLikes(List<Id> toBeProcessedContentIds) {
    	Analytics_Content_Count__c analyticsObj = new Analytics_Content_Count__c();
    	Map<Id, Analytics_Content_Count__c> contentLikesCountMap = new Map <Id, Analytics_Content_Count__c>();
    	
    	// New likes on content (content likes only.. excluding feed likes)
    	List<AggregateResult> likeObjList = [Select Content__c contentId, count(Id) LikesCount From Like__c 
    											where CreatedDate >=: startDateTime AND CreatedDate <: endDateTime 
    											AND Content__c IN :toBeProcessedContentIds 
    											GROUP BY Content__c ];
    	
    	List<Id> allContentIds = new List<Id>(); // contentId list for contents which have new feeds
    	for(AggregateResult ar : likeObjList) {
    		allContentIds.add((Id)ar.get('contentId'));
    	}
    	contentIdNSiteIdMap = getContentIdAndSiteIdMap(allContentIds);
    	
    	for(AggregateResult ar : likeObjList) {
    		String contentId = (Id)ar.get('contentId');
    		String siteId = contentIdNSiteIdMap.get(contentId);
    		
    		Decimal likesCount = 0;
    		if(contentLikesCountMap.containsKey(siteId) == true && contentLikesCountMap.get(siteId).Likes__c != null) {
    			likesCount = contentLikesCountMap.get(siteId).Likes__c;
    		}
			
			analyticsObj = new Analytics_Content_Count__c();
    		analyticsObj.Likes__c = likesCount + (Decimal)ar.get('LikesCount');
    		analyticsObj.Site__c = siteId;
    		contentLikesCountMap.put(siteId, analyticsObj);
    	}
    	
    	return contentLikesCountMap;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private void updateConsolidatedMap(Map<Id, Analytics_Content_Count__c> analyticsSMap) {
    	Analytics_Content_Count__c analyticsObj = null;
    	for(Analytics_Content_Count__c aSObj : analyticsSMap.values()) {
    		
    		if(aSObj.Bookmarks__c == null)           { aSObj.Bookmarks__c = 0;           }
    		if(aSObj.Likes__c == null)               { aSObj.Likes__c = 0;               }
    		if(aSObj.Shares__c == null)              { aSObj.Shares__c = 0;              }
    		if(aSObj.Posts__c == null)               { aSObj.Posts__c = 0;               }
    		if(aSObj.Replies__c == null)             { aSObj.Replies__c = 0;             }
    		if(aSObj.Views__c == null)               { aSObj.Views__c = 0;               }
    		if(aSObj.Pages__c == null)               { aSObj.Pages__c = 0;               }
    		if(aSObj.Events__c == null)              { aSObj.Events__c = 0;              }
    		if(aSObj.Albums__c == null)              { aSObj.Albums__c = 0;              }
    		if(aSObj.Blogs__c == null)               { aSObj.Blogs__c = 0;               }
    		
    		analyticsObj = consolidatedMap.get(aSObj.Site__c);
    		
    		if(analyticsObj != null) {
    			if(analyticsObj.Bookmarks__c == null)           { analyticsObj.Bookmarks__c = 0;           }
	    		if(analyticsObj.Likes__c == null)               { analyticsObj.Likes__c = 0;               }
	    		if(analyticsObj.Shares__c == null)              { analyticsObj.Shares__c = 0;              }
	    		if(analyticsObj.Posts__c == null)               { analyticsObj.Posts__c = 0;               }
	    		if(analyticsObj.Replies__c == null)             { analyticsObj.Replies__c = 0;             }
	    		if(analyticsObj.Views__c == null)               { analyticsObj.Views__c = 0;               }
	    		if(analyticsObj.Pages__c == null)               { analyticsObj.Pages__c = 0;               }
	    		if(analyticsObj.Events__c == null)              { analyticsObj.Events__c = 0;              }
	    		if(analyticsObj.Albums__c == null)              { analyticsObj.Albums__c = 0;              }
	    		if(analyticsObj.Blogs__c == null)               { analyticsObj.Blogs__c = 0;               }
	    		
    			aSObj.Bookmarks__c         += analyticsObj.Bookmarks__c;
    			aSObj.Likes__c             += analyticsObj.Likes__c;
    			aSObj.Shares__c            += analyticsObj.Shares__c;
    			aSObj.Posts__c             += analyticsObj.Posts__c;
    			aSObj.Replies__c           += analyticsObj.Replies__c;
   				aSObj.Views__c             += analyticsObj.Views__c;
   				aSObj.Pages__c             += analyticsObj.Pages__c;
   				aSObj.Events__c            += analyticsObj.Events__c;
   				aSObj.Albums__c            += analyticsObj.Albums__c;
   				aSObj.Blogs__c             += analyticsObj.Blogs__c;
    		}
    		aSObj.Date__c = startDate;
    		consolidatedMap.put(aSObj.Site__c, aSObj);
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
    private Map<Id, Id> getContentIdAndSiteIdMap(List<Id> contentIdList) {
    	Map<Id, Id> contentIdAndSiteIdMap = new Map<Id, Id>();
    	
    	List<Simpplr_Content__c> contentList = [Select Id, Site__c from Simpplr_Content__c where Id IN :contentIdList];
    	
    	for(Simpplr_Content__c contentObj : contentList) {
    		contentIdAndSiteIdMap.put(contentObj.Id, contentObj.Site__c);
    	}
    	
    	return contentIdAndSiteIdMap;
    }
}