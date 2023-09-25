/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class BatchTopSitesAnalytics implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    
    private static final List<Integer> SYNC_STATUS_SENT = new List<Integer> {1,3,5};
    // this map will hold the final/consolidated records that will be inserted into analytics table 
    public Map<Id, Analytics_Top_Site__c> consolidatedMap = new Map <Id, Analytics_Top_Site__c>();
    Map<Id, Analytics_Top_Site__c> siteCommentLikesFilesCountMap;
    public Boolean ranOneTime = false;
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
    public BatchTopSitesAnalytics(String recordType, Date dateArg) {
        startDate = dateArg;
        endDate = dateArg.addDays(1);
        
        this.recordType = recordType;
        
        startDateTime = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day(), 0, 0, 0);  
        endDateTime = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day(), 0, 0, 0);    
    }
    
    public BatchTopSitesAnalytics(Date dateArg) {
    		this.recordType = 'initAnalyticsData'; 
        startDate = dateArg;
        endDate = dateArg.addDays(1);
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
    public BatchTopSitesAnalytics() {
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
    public database.querylocator start(Database.BatchableContext bc){
    	String query;
    
    	if('initAnalyticsData'.equalsIgnoreCase(recordType)){
    		query = 'SELECT Id, Chatter_Group_Id__c FROM Simpplr_Site__c where Is_Active__c = true and Is_Deleted__c = false And Chatter_Group_Id__c != \'S06I000000MPPLR\' ';
    	
    	} else if ('sendAnalyticsDataToAWS'.equalsIgnoreCase(recordType)){
    		query = 'select Id, Name, Content_Published__c, Date__c, Likes__c, Members__c, Popularity_Score__c, Posts__c, Replies__c, Bookmarks__c, Shares__c, '
    				+' Site__c, Views__c,Content_Hybrid_App_Views__c,Content_Mobile_Browser_Views__c,Content_Web_Browser_Views__c,'
    				+'Dashboard_Hybrid_App_Views__c,Dashboard_Mobile_Browser_Views__c,Dashboard_Web_Browser_Views__c,'
    				+'Sync_Status__c from Analytics_Top_Site__c where Sync_Status__c !=:SYNC_STATUS_SENT ';
    
		} else if('sendSiteDataToAWS'.equalsIgnoreCase(recordType)) {
				query = ' select Id, Site_Type__c, Name, Is_Active__c, Is_Featured__c, Is_Newsletter_Allowed__c, Is_Alert_Enabled__c, Is_Must_Read_Enabled__c, Has_Albums__c, Has_Events__c, Has_Pages__c, Chatter_Group_Id__c, Cover_Content_Document__c, ' +
						' Allow_File_Upload_App_Permission__c, Title_Content_Document__c, Site_Category__c, Site_Category__r.Name__c, Show_In_Simpplr__c, landing_page__c, Origin__c, CreatedDate,File_Storage_Source__c, Layout__c, Is_Onboarding_Enabled__c from Simpplr_Site__c ';
				
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
    public void execute(Database.BatchableContext bc, List<sObject> listOfsObject){
	    	try {
	    		if('initAnalyticsData'.equalsIgnoreCase(recordType)){
		    		List<Simpplr_Site__c> siteList = (List<Simpplr_Site__c>)listOfsObject;
		    		Map<Id, Id> groupIdNSiteIdMap = new Map<Id, Id>();
			    	for(Simpplr_Site__c siteObj : siteList) {
			    		groupIdNSiteIdMap.put(siteObj.Chatter_Group_Id__c, siteObj.Id);
			    	}
					updateConsolidatedMap(groupIdNSiteIdMap);
					ranOneTime = true;
	    		
	    		} else if('sendAnalyticsDataToAWS'.equalsIgnoreCase(recordType)) {
	    			PushAnalyticsDataHelper analyticsHandler = new PushAnalyticsDataHelper();
	    			analyticsHandler.sendAnalticsTopSiteListToAWS(listOfsObject);
	    		
	    		} else if('sendSiteDataToAWS'.equalsIgnoreCase(recordType)) { 
	    			PushAnalyticsDataHelper analyticsHandler = new PushAnalyticsDataHelper();
	    			analyticsHandler.sendSiteListToAWS(listOfsObject);
	    			
	    		}
	    } catch(Exception ex) {
			Utility.sendBatchFailedExceptionEmail('BatchTopSitesAnalytics', ex);
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
		saveBatchData();
    		
    		if('initAnalyticsData'.equalsIgnoreCase(recordType)){
	    		BatchTopSitesAnalytics job = new BatchTopSitesAnalytics('sendSiteDataToAWS', startDate);
	    		Database.executeBatch(job, 1000);
    		
    		} else if('sendSiteDataToAWS'.equalsIgnoreCase(recordType)){
			BatchTopSitesAnalytics job = new BatchTopSitesAnalytics('sendAnalyticsDataToAWS', startDate);
	    		Database.executeBatch(job, 1000);
	    		
    		} else {
			BatchTopContentsAnalytics job = new BatchTopContentsAnalytics('initAnalyticsData', startDate);
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
	    	List<Analytics_Top_Site__c> analyticsList = (List<Analytics_Top_Site__c>)consolidatedMap.values();
	    	
	    	// save map values/data
	    	upsert analyticsList;
    	} catch(Exception ex) {
    		Utility.sendBatchFailedExceptionEmail('BatchTopSitesAnalytics', ex);
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
	private Map<Id, Analytics_Top_Site__c> getFeedLikes4Site(Map<Id, Id> groupIdNSiteIdMap) {
		Map<Id, Analytics_Top_Site__c> siteFeedLikesCountMap = new Map<Id, Analytics_Top_Site__c>();
	    	Analytics_Top_Site__c analyticsObj = new Analytics_Top_Site__c();
	    	
	    	List<CollaborationGroupFeed> feedList = [select Id, ParentId, (select Id from FeedLikes where CreatedDate >=: startDateTime AND CreatedDate <: endDateTime)
	    											from CollaborationGroupFeed 
	    											where SystemModstamp >=: startDateTime AND ParentId IN : groupIdNSiteIdMap.keySet() ];
	    	
	    	for(CollaborationGroupFeed cGFObj : feedList) {
	    		String siteId = groupIdNSiteIdMap.get(cGFObj.ParentId);
	    		
	    		if(String.isNotBlank(siteId)) {
	    			Decimal likesCount = 0;
		    		if(siteFeedLikesCountMap.containsKey(siteId) == true && siteFeedLikesCountMap.get(siteId).Likes__c != null) {
		    			likesCount = siteFeedLikesCountMap.get(siteId).Likes__c;
		    		}
		    		analyticsObj = new Analytics_Top_Site__c();
		    		analyticsObj.Likes__c = likesCount + cGFObj.FeedLikes.size();
		    		analyticsObj.Site__c = siteid;
		    		siteFeedLikesCountMap.put(siteid, analyticsObj);
	    		}
	    	}
	    	return siteFeedLikesCountMap;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private Map<Id, Analytics_Top_Site__c> getContentLikes4Site(Map<Id, Id> groupIdNSiteIdMap) {
	    	Map<Id, Analytics_Top_Site__c> siteContentLikesCountMap = new Map<Id, Analytics_Top_Site__c>();
	    	Analytics_Top_Site__c analyticsObj = new Analytics_Top_Site__c();
	    	
	    	// New likes on content (content likes only.. excluding feed likes)
	    	List<AggregateResult> likeObjList = [Select Content__r.Site__c siteId, count(Id) LikesCount From Like__c 
	    											where CreatedDate >=: startDateTime AND CreatedDate <: endDateTime AND Content__c != null 
	    											and Content__r.Site__c IN  :groupIdNSiteIdMap.values()
	    											GROUP BY Content__r.Site__c];
	    	
	    	for(AggregateResult ar : likeObjList) {
	    		String siteId = (Id)ar.get('siteId');
	    		
	    		if(String.isNotBlank(siteId)) {
	    			Decimal likesCount = 0;
		    		if(siteContentLikesCountMap.containsKey(siteId) == true && siteContentLikesCountMap.get(siteId).Likes__c != null) {
		    			likesCount = siteContentLikesCountMap.get(siteId).Likes__c;
		    		}
		    		
		    		analyticsObj = new Analytics_Top_Site__c();
		    		analyticsObj.Likes__c = likesCount + (Decimal)ar.get('LikesCount');
		    		analyticsObj.Site__c = siteid;
		    		siteContentLikesCountMap.put(siteid, analyticsObj);
	    		}
	    	}
	    	
	    	// feed like for content
	    	List<Simpplr_Content__Feed> feedObjList = [select Id, Parent.Site__c, (select Id from FeedLikes where CreatedDate >=: startDateTime AND CreatedDate <: endDateTime) 
	    											FROM Simpplr_Content__Feed where SystemModstamp >=: startDateTime 
	    											and Parent.Site__c IN  :groupIdNSiteIdMap.values()];
	    	
	    	for(Simpplr_Content__Feed cfObj : feedObjList) {
	    		String siteId = cfObj.Parent.Site__c;
	    		
	    		if(String.isNotBlank(siteId)) {
		    		Decimal likesCount = 0;
		    		if(siteContentLikesCountMap.containsKey(siteId) == true && siteContentLikesCountMap.get(siteId).Likes__c != null) {
		    			likesCount = siteContentLikesCountMap.get(siteId).Likes__c;
		    		}
		    		analyticsObj = new Analytics_Top_Site__c();
		    		analyticsObj.Likes__c = likesCount + cfObj.FeedLikes.size();
		    		analyticsObj.Site__c = siteid;
		    		siteContentLikesCountMap.put(siteid, analyticsObj);
	    		}
	    	}
	    	return siteContentLikesCountMap;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private Map<Id, Analytics_Top_Site__c> getCommentLikes_Site(Map<Id, Id> groupIdNSiteIdMap) {
    		Map<Id, Analytics_Top_Site__c> siteCommentLikesCountMap = new Map<Id, Analytics_Top_Site__c>();
		Analytics_Top_Site__c analyticsObj = new Analytics_Top_Site__c();
    	
    		// New likes on comments
	    	Map<Id, Id> mapofFeedItemIdAndSiteId = new Map<Id, Id>(); 
	    	List<Like__c> likeObjList = [Select Id, Feed_Item_Comment_Id__c, Feed_Item_Id__c From Like__c 
	    												where CreatedDate >=: startDateTime AND CreatedDate <: endDateTime 
	    												AND Feed_Item_Id__c != null AND Feed_Item_Comment_Id__c != null];
	    	List<Id> feedItemList = new List<Id>();
	    	for(Like__c likeObj : likeObjList) {
	    		feedItemList.add(likeObj.Feed_Item_Id__c);
	    	}
	    	
	    	List<CollaborationGroupFeed> listOfSiteFeed = [select id,parentid from CollaborationGroupFeed where id=:feedItemList and parentid=:groupIdNSiteIdMap.keySet()];
	    	for(CollaborationGroupFeed feedObj:listOfSiteFeed) {
	    		if(groupIdNSiteIdMap.containsKey(feedObj.parentid)) {
	    			mapofFeedItemIdAndSiteId.put(feedObj.id, groupIdNSiteIdMap.get(feedObj.parentid));
	    		}
	    	}
	    	
	    	List<Simpplr_Content__Feed> listOfContentFeed = [select id, parent.site__c from Simpplr_Content__Feed where id=:feedItemList and parent.site__c=:groupIdNSiteIdMap.values()];
	    	for(Simpplr_Content__Feed contentFeedObj:listOfContentFeed) {
	    		mapofFeedItemIdAndSiteId.put(contentFeedObj.id, contentFeedObj.parent.site__c);
	    	}
	    	
	    	for(Like__c likeObj : likeObjList) {
	    		String siteId = mapofFeedItemIdAndSiteId.get(likeObj.Feed_Item_Id__c);
	    		
	    		if(String.isNotBlank(siteId)) {
	    			Decimal likesCount = 0;
		    		if(siteCommentLikesCountMap.containsKey(siteId) == true && siteCommentLikesCountMap.get(siteId).Likes__c != null) {
		    			likesCount = siteCommentLikesCountMap.get(siteId).Likes__c;
		    		}
		    		analyticsObj = new Analytics_Top_Site__c();
		    		analyticsObj.Likes__c = likesCount + 1;
		    		analyticsObj.Site__c = siteid;
		    		siteCommentLikesCountMap.put(siteId, analyticsObj);
	    		}
	    	}
	    	return siteCommentLikesCountMap;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private void fillSiteCommentLikesFilesCountMap(Map<Id, Id> groupIdNSiteIdMap) {
    		siteCommentLikesFilesCountMap = new Map<Id, Analytics_Top_Site__c>();
	    	Analytics_Top_Site__c analyticsObj = new Analytics_Top_Site__c();
	    	
    		// New likes on files
	    	List<Like__c> likeObjList = [Select Id, External_File_Id__c From Like__c 
	    												where CreatedDate >=: startDateTime AND CreatedDate <: endDateTime 
	    												AND External_File_Id__c != null AND External_File_Id__c like '069%'];
	    	List<Id> contentDocumentList = new List<Id>();
	    	for(Like__c likeObj : likeObjList) {
	    		contentDocumentList.add(likeObj.External_File_Id__c);
	    	}
	    	
	    	List<ContentVersion> cVList = [select Id, PathOnClient from ContentVersion  where ContentDocumentId in :contentDocumentList
	    										AND PathOnClient like 'simp_cont_%' ];
	    	
	    	for(ContentVersion cVObj : cVList) {
	    		List<String> parts = cVObj.PathOnClient.split('#');
	    		
	    		if(parts.size() > 1) {
		    		String siteId = validateId(parts[1]);
		    		if(String.isNotBlank(siteId)) {
			    		analyticsObj = new Analytics_Top_Site__c();
			    		analyticsObj.Site__c = siteid;
			    		
			    		if(siteCommentLikesFilesCountMap.get(siteId) != null) {
			    			analyticsObj.Likes__c = siteCommentLikesFilesCountMap.get(siteId).Likes__c + 1;
			    		}
			    		else {
			    			analyticsObj.Likes__c = 1;
			    		}
			    		
			    		siteCommentLikesFilesCountMap.put(siteId, analyticsObj);
		    		}
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
    private Map<Id, Analytics_Top_Site__c> getTopSitesPublishedContent(Map<Id, Id> groupIdNSiteIdMap) {
	    	Map<Id, Analytics_Top_Site__c> publishedTopContentCountMap = new Map<Id, Analytics_Top_Site__c>();
	    	Analytics_Top_Site__c analyticsObj = new Analytics_Top_Site__c();
	    	
	    	List<AggregateResult> contentList = [select Site__c siteId, count(Id) ContentCount from Simpplr_Content__c 
	    											where Status__c='Approved' AND Site__c IN :groupIdNSiteIdMap.values() 
	    											AND (First_Publish_DateTime__c >=: startDateTime AND First_Publish_DateTime__c <: endDateTime) 
	    											GROUP BY Site__c 
	    											order by count(Id) DESC ];
	    	
	    	for(AggregateResult ar : contentList) {
	    		String siteId = (Id)ar.get('siteId');
	    		
	    		if(String.isNotBlank(siteId)) {
		    		analyticsObj = new Analytics_Top_Site__c();
		    		analyticsObj.Content_Published__c = (Decimal)ar.get('ContentCount');
		    		analyticsObj.Site__c = siteId;
		    		publishedTopContentCountMap.put(siteId, analyticsObj);
	    		}
	    	}
	    	return publishedTopContentCountMap;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private Map<Id, Analytics_Top_Site__c> getTopSitesMembers(Map<Id, Id> groupIdNSiteIdMap) {
    		Map<Id, Analytics_Top_Site__c> siteViewedMemberCountMap = new Map<Id, Analytics_Top_Site__c>();
	    	Analytics_Top_Site__c analyticsObj = new Analytics_Top_Site__c();
	    	
	    	List<AggregateResult> sSAList = [Select CollaborationGroupId, count(MemberId) MembersCount From CollaborationGroupMember 
	    										where CreatedDate >=: startDateTime AND CreatedDate <: endDateTime 
	    										AND CollaborationGroupId IN :groupIdNSiteIdMap.keySet()
	    										GROUP BY CollaborationGroupId ];
	    	
	    	for(AggregateResult ar : sSAList) {
	    		String siteId = groupIdNSiteIdMap.get((Id)ar.get('CollaborationGroupId'));
	    		
	    		if(String.isNotBlank(siteId)) {
		    		analyticsObj = new Analytics_Top_Site__c();
		    		analyticsObj.Members__c = (Decimal)ar.get('MembersCount');
		    		analyticsObj.Site__c = siteId;
		    		siteViewedMemberCountMap.put(siteId, analyticsObj);
	    		}
	    	}
	    	return siteViewedMemberCountMap;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private Map<Id, Analytics_Top_Site__c> getTopSitesPosts(Map<Id, Id> groupIdNSiteIdMap) {
	    	Map<Id, Analytics_Top_Site__c> publishedSitePostCountMap = new Map<Id, Analytics_Top_Site__c>();
	    	Analytics_Top_Site__c analyticsObj = new Analytics_Top_Site__c();
	    	
	    	// Site Feed
	    	List<AggregateResult> feedList = [select ParentId, count(Id) PostsCount from CollaborationGroupFeed 
	    											where CreatedDate >=: startDateTime AND CreatedDate <: endDateTime 
	    											AND ParentId IN :groupIdNSiteIdMap.keySet()
	    											GROUP BY ParentId];
	    	
	    	for(AggregateResult ar : feedList) {
	    		String siteId = groupIdNSiteIdMap.get((Id)ar.get('ParentId'));
	    		
	    		if(String.isNotBlank(siteId)) {
		    		analyticsObj = new Analytics_Top_Site__c();
		    		analyticsObj.Posts__c = (Decimal)ar.get('PostsCount');
		    		analyticsObj.Site__c = siteId;
		    		publishedSitePostCountMap.put(siteId , analyticsObj);
	    		}
	    	}
	    	
	    	// Site-Content Feed
	    	List<AggregateResult> contentFeedList = [select Parent.Site__c siteId, count(Id) PostsCount 
	    											from Simpplr_Content__Feed 
	    											where CreatedDate >=: startDateTime AND CreatedDate <: endDateTime
	    											AND Parent.Site__c IN :groupIdNSiteIdMap.values()
	    											GROUP BY Parent.Site__c];
	    	
	    	for(AggregateResult ar : contentFeedList) {
	    		String siteId = (Id)ar.get('siteId');
	    		
	    		if(String.isNotBlank(siteId)) {
	    			Decimal postCount = 0;
		    		if(publishedSitePostCountMap.containsKey(siteId) == true && publishedSitePostCountMap.get(siteId).Posts__c != null) {
		    			postCount = publishedSitePostCountMap.get(siteId).Posts__c;
		    		}
		    		
		    		analyticsObj = new Analytics_Top_Site__c();
		    		analyticsObj.Posts__c = postCount + (Decimal)ar.get('PostsCount');
		    		analyticsObj.Site__c = siteId;
		    		publishedSitePostCountMap.put(siteid, analyticsObj);
	    		}
	    	}
	    	return publishedSitePostCountMap;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private Map<Id, Analytics_Top_Site__c> getTopSitesComments(Map<Id, Id> groupIdNSiteIdMap) {
	    	Map<Id, Analytics_Top_Site__c> publishedTopSiteCountMap = new Map<Id, Analytics_Top_Site__c>();
	    	Analytics_Top_Site__c analyticsObj = new Analytics_Top_Site__c();
	    	
	    	List<Simpplr_Content__Feed> feedList1 = [select Id, ParentId from Simpplr_Content__Feed 
	    											where Parent.Site__c =:groupIdNSiteIdMap.values()
	    											And SystemModstamp >=: startDateTime AND SystemModstamp <: endDateTime];
	    	
	    	List<Id> allContentIds = new List<Id>(); // contentId list for contents which have new feeds
	    	for(Simpplr_Content__Feed contentFeedObj : feedList1) {
	   			allContentIds.add(contentFeedObj.ParentId);
	    	}
	    Map<Id, Id>	contentIdNSiteIdMap = getContentIdAndSiteIdMap(allContentIds);
	    	
	    	// Site Comments
	    	List<AggregateResult> feedList2 = [select ParentId, count(Id) ReplyCount from FeedComment 
	    											where (ParentId IN :groupIdNSiteIdMap.keySet() OR ParentId in :allContentIds) 
	    											AND CreatedDate >=: startDateTime AND CreatedDate <: endDateTime 
	    											GROUP BY ParentId];
	    	
	    	Map<Id,Simpplr_Site__c> allSimpplrGroupIdAndSiteMap = New Map<Id,Simpplr_Site__c>();
			for(Simpplr_Site__c site : Utility.getAllSimpplrSiteMap().values()){
				allSimpplrGroupIdAndSiteMap.put(site.chatter_Group_Id__c, site);
			}
					
	    	for(AggregateResult ar : feedList2) {
	    		String siteId;
	    		String parentId = (Id)ar.get('ParentId');
	    		
	    		if(parentId.startsWith('0F9')) {
	    			siteId = allSimpplrGroupIdAndSiteMap.get(parentId).Id;
	    		}
	    		else {
	    			siteId = contentIdNSiteIdMap.get(parentId);
	    		}
	
	    		if(String.isNotBlank(siteId)) {
	    			Decimal rplyCount = 0;
		    		if(publishedTopSiteCountMap.containsKey(siteId) == true && publishedTopSiteCountMap.get(siteId).Replies__c != null) {
		    			rplyCount = publishedTopSiteCountMap.get(siteId).Replies__c;
		    		}
		    		analyticsObj = new Analytics_Top_Site__c();
		    		analyticsObj.Replies__c = rplyCount + (Decimal)ar.get('ReplyCount');
		    		analyticsObj.Site__c = siteId;
	    		
	    			publishedTopSiteCountMap.put(siteid, analyticsObj);
	    		}
	    	}
	    	return publishedTopSiteCountMap;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private Map<Id, Analytics_Top_Site__c> getTopSitesViewed(Map<Id, Id> groupIdNSiteIdMap) {
	    	Map<Id, Analytics_Top_Site__c> siteViewedCountMap = new Map<Id, Analytics_Top_Site__c>();
	    	
	    	Analytics_Top_Site__c analyticsObj = new Analytics_Top_Site__c();
	    	
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', startDateTime);
			soqlParamMap.put('soqlParam2', endDateTime);
			soqlParamMap.put('soqlParam3', groupIdNSiteIdMap.values());
			String socialAnlytcsQuery = 'Select Simpplr_Site__c siteId, count(Id) ViewsCount from Simpplr_Social_Analytics__c ' +
				' where CreatedDate >=: soqlParam1 AND CreatedDate <: soqlParam2 ' +
				' and Interaction__c = \'View\' and Simpplr_Site__c in :soqlParam3 ' +
				' GROUP BY Simpplr_Site__c';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<AggregateResult> sSAList = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(socialAnlytcsQuery, soqlParamMap);
	    	
			soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', startDateTime);
			soqlParamMap.put('soqlParam2', endDateTime);
			soqlParamMap.put('soqlParam3', groupIdNSiteIdMap.values());
			socialAnlytcsQuery = 'select count(id) viewsCount, Simpplr_Site__c siteId, Origin_Mobile_App__c mobileApp, Origin_Mobile_Browser__c mobileBrowser from Simpplr_Social_Analytics__c ' +
				' where CreatedDate >=: soqlParam1 AND CreatedDate <: soqlParam2 ' +
				' and Interaction__c = \'View\' and Simpplr_Site__c in :soqlParam3 ' +
				' and page_name__c = \'Site Dashboard\' ' +
				' and Origin_Desktop_App__c=false and Origin_Native_Mobile_App__c=false ' +
				' group by Simpplr_Site__c, Origin_Mobile_App__c, Origin_Mobile_Browser__c';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<AggregateResult> sSAList2 = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(socialAnlytcsQuery, soqlParamMap);

			soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', startDateTime);
			soqlParamMap.put('soqlParam2', endDateTime);
			soqlParamMap.put('soqlParam3', groupIdNSiteIdMap.values());
			socialAnlytcsQuery = 'select count(id) viewsCount, Simpplr_Site__c siteId, Origin_Mobile_App__c mobileApp, Origin_Mobile_Browser__c mobileBrowser from Simpplr_Social_Analytics__c ' +
				' where CreatedDate >=: soqlParam1 AND CreatedDate <: soqlParam2 ' +
				' and Interaction__c = \'View\' and Simpplr_Site__c in :soqlParam3 ' +
				' and page_name__c = \'SiteContent\' ' +
				' and Origin_Desktop_App__c=false and Origin_Native_Mobile_App__c=false ' +
				' group by Simpplr_Site__c, Origin_Mobile_App__c, Origin_Mobile_Browser__c';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<AggregateResult> sSAList3 = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(socialAnlytcsQuery, soqlParamMap);

	    	for(AggregateResult ar : sSAList) {
	    		String siteId = (Id)ar.get('siteId');
	    		
	    		if(String.isNotBlank(siteId)) {
	    			analyticsObj = new Analytics_Top_Site__c();
	    			analyticsObj.Views__c = (Decimal)ar.get('ViewsCount');
	    			analyticsObj.Site__c = siteId;
	    			
	    			siteViewedCountMap.put(siteId, analyticsObj);
	    		}
	    	}
	    	
	    	for(AggregateResult ar : sSAList2) {
	    		String siteId = (Id)ar.get('siteId');
	    		Boolean mobileApp = (Boolean)ar.get('mobileApp');
	    		Boolean mobileBrowser = (Boolean)ar.get('mobileBrowser');
	    		
	    		if(String.isNotBlank(siteId)) {
	    			
	    			analyticsObj = siteViewedCountMap.get(siteId);
	    			
					if(mobileApp){
						analyticsObj.Dashboard_Hybrid_App_Views__c = (Decimal)ar.get('viewsCount');
					
					} else if(mobileBrowser){
						analyticsObj.Dashboard_Mobile_Browser_Views__c = (Decimal)ar.get('viewsCount');
					
					} else{
						analyticsObj.Dashboard_Web_Browser_Views__c = (Decimal)ar.get('viewsCount');
					}
	    			
	    			siteViewedCountMap.put(siteId, analyticsObj);
	    		}
	    	}

			for(AggregateResult ar : sSAList3) {
	    		String siteId = (Id)ar.get('siteId');
	    		Boolean mobileApp = (Boolean)ar.get('mobileApp');
	    		Boolean mobileBrowser = (Boolean)ar.get('mobileBrowser');
	    		
	    		if(String.isNotBlank(siteId)) {
	    			
	    			analyticsObj = siteViewedCountMap.get(siteId);
	    			
					if(mobileApp){
						analyticsObj.Content_Hybrid_App_Views__c = (Decimal)ar.get('viewsCount');
					
					} else if(mobileBrowser){
						analyticsObj.Content_Mobile_Browser_Views__c = (Decimal)ar.get('viewsCount');
					
					}else{
						analyticsObj.Content_Web_Browser_Views__c = (Decimal)ar.get('viewsCount');
					}
	    			
	    			siteViewedCountMap.put(siteId, analyticsObj);
	    		}
	    	}

	    	return siteViewedCountMap;
    }
	
	private Map<Id, Analytics_Top_Site__c> getTopSiteBookmarks(Map<Id, Id> groupIdNSiteIdMap) {
    	Map<Id, Analytics_Top_Site__c> topSiteBookmarksMap = new Map<Id, Analytics_Top_Site__c>();
    	
    	List<AggregateResult> sSAList = [Select Simpplr_Site__c siteId, count(Id) BookMarksCount from Bookmark__c 
    										where CreatedDate >=: startDateTime AND CreatedDate <: endDateTime  AND Is_Deleted__c = false
    										and Simpplr_Site__c IN :groupIdNSiteIdMap.values()
    										GROUP BY Simpplr_Site__c];

    	Analytics_Top_Site__c analyticsObj = null;
		for(AggregateResult ar : sSAList) {
    		String siteId = (Id)ar.get('siteId');
    		
    		if(String.isNotBlank(siteId)) {
    			analyticsObj = new Analytics_Top_Site__c();
    			analyticsObj.BookMarks__c = (Decimal)ar.get('BookMarksCount');
    			analyticsObj.Site__c = siteId;
    			
    			topSiteBookmarksMap.put(siteId, analyticsObj);
    		}
    	}

		return topSiteBookmarksMap;
    }

	private Map<Id, Analytics_Top_Site__c> getTopSiteShares(Map<Id, Id> groupIdNSiteIdMap) {
		Map<Id, Analytics_Top_Site__c> topSiteSharesMap = new Map<Id, Analytics_Top_Site__c>();
    	
    	List<AggregateResult> sSAList = [Select Content__r.Site__c siteId, count(Id) SharesCount from Share__c 
    										where CreatedDate >=: startDateTime AND CreatedDate <: endDateTime 
    										and Content__r.Site__c IN :groupIdNSiteIdMap.values()
											and Content__r.Site__c != null
    										GROUP BY Content__r.Site__c];
    	
		Analytics_Top_Site__c analyticsObj = null;
    	for(AggregateResult ar : sSAList) {
    		String siteId = (Id)ar.get('siteId');
    		
    		if(String.isNotBlank(siteId)) {
    			analyticsObj = new Analytics_Top_Site__c();
    			analyticsObj.Shares__c = (Decimal)ar.get('SharesCount');
    			analyticsObj.Site__c = siteId;
    			
    			topSiteSharesMap.put(siteId, analyticsObj);
    		}
    	}

		return topSiteSharesMap;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private void updateConsolidatedMap(Map<Id, Id> groupIdNSiteIdMap) {
		Analytics_Top_Site__c analyticsObj = null;
    	
		Map<Id, Analytics_Top_Site__c> siteFeedLikesCountMap = getFeedLikes4Site(groupIdNSiteIdMap);
		Map<Id, Analytics_Top_Site__c> siteContentLikesCountMap = getContentLikes4Site(groupIdNSiteIdMap);
		Map<Id, Analytics_Top_Site__c> siteCommentLikesCountMap = getCommentLikes_Site(groupIdNSiteIdMap);		
		Map<Id, Analytics_Top_Site__c> publishedTopContentCountMap = getTopSitesPublishedContent(groupIdNSiteIdMap); 
		Map<Id, Analytics_Top_Site__c> siteViewedMemberCountMap = getTopSitesMembers(groupIdNSiteIdMap);
		Map<Id, Analytics_Top_Site__c> publishedSitePostCountMap = getTopSitesPosts(groupIdNSiteIdMap); 
		Map<Id, Analytics_Top_Site__c> publishedTopSiteCountMap = getTopSitesComments(groupIdNSiteIdMap);
		Map<Id, Analytics_Top_Site__c> siteViewedCountMap = getTopSitesViewed(groupIdNSiteIdMap); 
		Map<Id, Analytics_Top_Site__c> siteSharesMap = getTopSiteShares(groupIdNSiteIdMap);
		Map<Id, Analytics_Top_Site__c> siteBookmarksMap = getTopSiteBookmarks(groupIdNSiteIdMap); 
	    	
		if(ranOneTime == false) {
			fillSiteCommentLikesFilesCountMap(groupIdNSiteIdMap);
		}
		Map<ID,Id>mapSiteToAnalytic = new map<ID,ID>();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', groupIdNSiteIdMap.values());
		soqlParamMap.put('soqlParam2', startDate);
		String topSiteQuery = 'select id, Site__c ' +
			' from Analytics_Top_Site__c ' +
			' where Site__c IN :soqlParam1 ' +
			' and Date__c =: soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Analytics_Top_Site__c> listOfExistingSiteAnalyticsForToday = (List<Analytics_Top_Site__c>)SIMPESAPI.accessController().queryAsUser(topSiteQuery, soqlParamMap);
		for(Analytics_Top_Site__c ats: listOfExistingSiteAnalyticsForToday){
			mapSiteToAnalytic.put(ats.Site__c, ats.ID);
		}
		for(Id siteID : groupIdNSiteIdMap.values()) {
			
			if(mapSiteToAnalytic.containsKey(siteID)){
				analyticsObj = new Analytics_Top_Site__c(ID = mapSiteToAnalytic.get(siteID));
				analyticsObj.Sync_Status__c = null;
			}else{
				analyticsObj = new Analytics_Top_Site__c();
			}
			analyticsObj.Site__c = siteID;
			analyticsObj.Date__c = startDate;
			analyticsObj.Content_Published__c = 0;
			analyticsObj.Likes__c = 0;
			analyticsObj.Members__c = 0;
			analyticsObj.Posts__c = 0;
			analyticsObj.Replies__c = 0;
			analyticsObj.Views__c = 0;
			analyticsObj.Shares__c = 0;
			analyticsObj.Bookmarks__c = 0;
			
			Boolean found = false;
			if(siteFeedLikesCountMap.containskey(siteID)){
				analyticsObj.Likes__c         += siteFeedLikesCountMap.get(siteID).Likes__c;
				found = true;
			}
			if(siteContentLikesCountMap.containskey(siteID)){
				analyticsObj.Likes__c         += siteContentLikesCountMap.get(siteID).Likes__c;
				found = true;
			}
			if(siteCommentLikesCountMap.containskey(siteID)){
   				analyticsObj.Likes__c += siteCommentLikesCountMap.get(siteID).Likes__c;
   				found = true;
			}
			if(siteCommentLikesFilesCountMap.containskey(siteID)){
   				analyticsObj.Likes__c += siteCommentLikesFilesCountMap.get(siteID).Likes__c;
   				found = true;
			}
			if(publishedTopContentCountMap.containskey(siteID)){
   				analyticsObj.Content_Published__c += publishedTopContentCountMap.get(siteID).Content_Published__c;
   				found = true;
			}
			if(siteViewedMemberCountMap.containskey(siteID)){
   				analyticsObj.Members__c          += siteViewedMemberCountMap.get(siteID).Members__c;
   				found = true;
			}
			if(publishedSitePostCountMap.containskey(siteID)){
   				analyticsObj.Posts__c          += publishedSitePostCountMap.get(siteID).Posts__c;
   				found = true;
			}
			if(publishedTopSiteCountMap.containskey(siteID)){
   				analyticsObj.Replies__c          += publishedTopSiteCountMap.get(siteID).Replies__c;
   				found = true;
			}
			if(siteSharesMap.containskey(siteID)){
   				analyticsObj.Shares__c          += siteSharesMap.get(siteID).Shares__c;
   				found = true;
			}
			if(siteBookmarksMap.containskey(siteID)){
   				analyticsObj.Bookmarks__c          += siteBookmarksMap.get(siteID).Bookmarks__c;
   				found = true;
			}
			if(siteViewedCountMap.containskey(siteID)){
   				analyticsObj.Views__c          += siteViewedCountMap.get(siteID).Views__c;
   				analyticsObj.Content_Hybrid_App_Views__c = siteViewedCountMap.get(siteID).Content_Hybrid_App_Views__c == null ? 0 : siteViewedCountMap.get(siteID).Content_Hybrid_App_Views__c;
   				analyticsObj.Content_Mobile_Browser_Views__c = siteViewedCountMap.get(siteID).Content_Mobile_Browser_Views__c == null ? 0 : siteViewedCountMap.get(siteID).Content_Mobile_Browser_Views__c;
   				analyticsObj.Content_Web_Browser_Views__c  = siteViewedCountMap.get(siteID).Content_Web_Browser_Views__c == null ? 0 : siteViewedCountMap.get(siteID).Content_Web_Browser_Views__c;
   				analyticsObj.Dashboard_Hybrid_App_Views__c = siteViewedCountMap.get(siteID).Dashboard_Hybrid_App_Views__c == null ? 0 : siteViewedCountMap.get(siteID).Dashboard_Hybrid_App_Views__c;
   				analyticsObj.Dashboard_Mobile_Browser_Views__c = siteViewedCountMap.get(siteID).Dashboard_Mobile_Browser_Views__c == null ? 0 : siteViewedCountMap.get(siteID).Dashboard_Mobile_Browser_Views__c;
   				analyticsObj.Dashboard_Web_Browser_Views__c  = siteViewedCountMap.get(siteID).Dashboard_Web_Browser_Views__c == null ? 0 : siteViewedCountMap.get(siteID).Dashboard_Web_Browser_Views__c;
   				
   				found = true;
			}
			if(found) {
				consolidatedMap.put(analyticsObj.Site__c, analyticsObj);
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
    private Map<Id, Id> getContentIdAndSiteIdMap(List<Id> contentIdList) {
    	Map<Id, Id> contentIdAndSiteIdMap = new Map<Id, Id>();
    	
    	List<Simpplr_Content__c> contentList = [Select Id, Site__c from Simpplr_Content__c where Id IN :contentIdList];
    	
    	for(Simpplr_Content__c contentObj : contentList) {
    		contentIdAndSiteIdMap.put(contentObj.Id, contentObj.Site__c);
    	}
    	
    	return contentIdAndSiteIdMap;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private String validateId(String Idparam) {
        String id = String.escapeSingleQuotes(Idparam);
        if((id.length() == 15 || id.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', id)) {
            return id;
        }
        return null;
	}
    
}