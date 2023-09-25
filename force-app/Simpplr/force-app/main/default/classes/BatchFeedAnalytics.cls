/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class BatchFeedAnalytics implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts{
	
	private static final List<Integer> SYNC_STATUS_SENT = new List<Integer> {1,3,5};
	Map<String,Map<String,Integer>> siteToFeedRealtedCountMap = new Map<String,Map<String,Integer>>();
	Set<String> parentTypeSet = new Set<String>{'User', 'CollaborationGroup', PageContext.namespacePrefix + 'Simpplr_Content__c'};
	DateTime startDateTime ;
	DateTime endDateTime ;
	Date startDate ;
	Date endDate ;
	String recordType;
	List<Object> analyticWrapperList;
	
	public BatchFeedAnalytics (String recordType, Date dateArg){
		startDate = dateArg;
		endDate = dateArg.addDays(1);
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
    public database.querylocator start(Database.BatchableContext bc){
    		String query;
    	
    		if('initAnalyticsData'.equalsIgnoreCase(recordType)){
    			query = 'SELECT id, parentId,CommentCount,LikeCount,CreatedDate FROM FeedItem WHERE parent.type IN : parentTypeSet And '+
    							'((createdDate >=: startDateTime AND createdDate <: endDateTime) '+
    							'OR (SystemModstamp >=: startDateTime AND SystemModstamp <: endDateTime))';
    							
			if(SimpplrContext.isCommunitiesEnabled){
        		query = query+' AND (NetworkScope=null OR NetworkScope=\'AllNetworks\')';
			} 
			
    		} else if('sendAnalyticsDataToAWS'.equalsIgnoreCase(recordType)) {
        		query = 'select Id, Date__c, Likes__c, Posts__c, Replies__c, Shares__c, Site__c, Sync_Status__c from Analytics_Feed_Count__c where Sync_Status__c !=:SYNC_STATUS_SENT ';
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
    		
    	String simpplrContentPrefix = Utility.getSimpplrContentPrefix();
	    try {
	    	if('initAnalyticsData'.equalsIgnoreCase(recordType)){
	        List<FeedItem> feedIemList = (List<FeedItem>)listOfsObject;
	        Set<String> chatterGroupIdSet = new Set<String>();
	        Set<String> feedItemIdSet = new Set<String>();
	        Set<String> simpplrContentIdSet = new Set<String>();
	        Set<String> siteIdSet = new Set<String>();
	        
	        Map<String,String> chatterGroupIdToSiteMap = new Map<String,String>();
	        Map<String,String> feedItemToChatterGroupIdMap = new Map<String,String>();
	        Map<String,String> feedItemToParentMap = new Map<String,String>();
	        Map<String,String> feedItemToSiteMap = new Map<String,String>();
	        Map<String,String> contentToSiteMap = new Map<String,String>();
	        
	        for(FeedItem feedItemObj : feedIemList) {
	        	feedItemIdSet.add(feedItemObj.id);
	        	if (String.isNotBlank(feedItemObj.parentId)){
	        		if( String.valueOf(feedItemObj.parentId).startsWith('0F9')){
		        		chatterGroupIdSet.add(feedItemObj.parentId);
		        		feedItemToChatterGroupIdMap.put(feedItemObj.id,feedItemObj.parentId);
		        	} else if (String.valueOf(feedItemObj.parentId).startsWith(simpplrContentPrefix)){
		        		simpplrContentIdSet.add(feedItemObj.parentId);
		        	} else {
		        		feedItemToParentMap.put(feedItemObj.id,feedItemObj.parentId);
		        	}
	        	}
	        	
	        }
	        List<Simpplr_Content__c> simpplrContentList = [SELECT Id,Site__c FROM Simpplr_Content__c WHERE Id IN : simpplrContentIdSet];
	        for (Simpplr_Content__c sc : simpplrContentList){
	        	siteIdSet.add(sc.Site__c);
	        	contentToSiteMap.put(sc.id,sc.Site__c);
	        }
	        List<Simpplr_Site__c> siteList = [SELECT Id,Chatter_Group_Id__c FROM Simpplr_Site__c 
	        														WHERE Chatter_Group_Id__c IN : chatterGroupIdSet OR Id IN :siteIdSet];
	        for(Simpplr_Site__c site : siteList){
	        	chatterGroupIdToSiteMap.put(site.Chatter_Group_Id__c,site.Id);
	        }
	        for (FeedItem fi : feedIemList){
	        	if (fi.parentId != NULL && String.valueOf(fi.parentId).startsWith(simpplrContentPrefix)){
	        		if (contentToSiteMap.get(fi.parentId) != NULL ){
	        			feedItemToSiteMap.put(fi.Id,contentToSiteMap.get(fi.parentId));
	        		}
	        	} else if (fi.parentId != NULL && String.valueOf(fi.parentId).startsWith('0F9')){
	        		if (chatterGroupIdToSiteMap.get(fi.parentId) != NULL ){
	        			feedItemToSiteMap.put(fi.Id,chatterGroupIdToSiteMap.get(fi.parentId));
	        		}
	        	}
	        }
	        Integer postCount = 0;
	        
	        DateTime dT;
	        Date createdDateOnly;
	        String siteId;
	        Map<String,Integer> tempCountMap;
	        for(FeedItem feedItemObj : feedIemList) {
	        	tempCountMap = new Map<String,Integer>();
	        	postCount = 0;
	        	// Code for new post under a site
	        	dT = feedItemObj.createdDate;
				createdDateOnly = date.newinstance(dT.year(), dT.month(), dT.day());
	            if(feedItemObj.createdDate >= startDateTime && feedItemObj.createdDate < endDateTime) {
	            	if(feedItemToSiteMap.containsKey(feedItemObj.id)){
	            		siteId = feedItemToSiteMap.get(feedItemObj.id);
	            		if(siteToFeedRealtedCountMap.containsKey(siteId)){
	            			tempCountMap = siteToFeedRealtedCountMap.get(siteId); 
	            			if (tempCountMap != NULL && tempCountMap.containsKey('PostCount')){
	            				postCount = tempCountMap.get('PostCount') + 1;
		            			tempCountMap.put('PostCount',postCount);
		            			siteToFeedRealtedCountMap.put(siteId,tempCountMap);
	            			} else {
		            			tempCountMap.put('PostCount',1);
		            			siteToFeedRealtedCountMap.put(siteId,tempCountMap);
		            		}
	            			
	            		} else {
	            			tempCountMap.put('PostCount',1);
	            			siteToFeedRealtedCountMap.put(siteId,tempCountMap);
	            		}
					} else if( !String.valueOf(feedItemObj.parentId).startsWith('0F9')){
	            		if(siteToFeedRealtedCountMap.containsKey('FeedOtherThanSite')){
	            			tempCountMap = siteToFeedRealtedCountMap.get('FeedOtherThanSite');
	            			if (tempCountMap != NULL && tempCountMap.containsKey('PostCount')){
	            				postCount = tempCountMap.get('PostCount') + 1;
		            			tempCountMap.put('PostCount',postCount);
		            			siteToFeedRealtedCountMap.put('FeedOtherThanSite',tempCountMap);	
	            			} else {
		            			tempCountMap.put('PostCount',1);
		            			siteToFeedRealtedCountMap.put('FeedOtherThanSite',tempCountMap);
		            		}
	            			
	            		} else {
	            			tempCountMap.put('PostCount',1);
	            			siteToFeedRealtedCountMap.put('FeedOtherThanSite',tempCountMap);
	            		}
	            	}
	            }
	        }   
	        
	        // Code to count replies
			List<FeedComment> feedCommentList = [SELECT Id,FeedItemId,CreatedById FROM FeedComment 
	                                                                    WHERE FeedItemId IN : feedItemIdSet 
	                                                                    AND (createdDate >=: startDateTime AND createdDate <: endDateTime)];
	        
	          
	        String chatterGrpId ;
	        Integer repliesCount =0;                                                              
	        for (FeedComment fc : feedCommentList){
	        	repliesCount =0;
	        	tempCountMap = new Map<String,Integer>();
	            if(feedItemToSiteMap.containsKey(fc.FeedItemId)){
	            	siteid = feedItemToSiteMap.get(fc.FeedItemId);
	            	
	            	if(siteToFeedRealtedCountMap.containsKey(siteid)){
	            		tempCountMap = siteToFeedRealtedCountMap.get(siteid);
	            		if(tempCountMap != NULL && tempCountMap.containsKey('RepliesCount')){
	            			repliesCount = tempCountMap.get('RepliesCount')+1;
	                		tempCountMap.put('RepliesCount',repliesCount);
	            			siteToFeedRealtedCountMap.put(siteid,tempCountMap);
	            		} else {
	                		tempCountMap.put('RepliesCount',1);
	            			siteToFeedRealtedCountMap.put(siteid,tempCountMap);
	                	}
	            		
	            	} else {
	            		tempCountMap.put('RepliesCount',1);
	        			siteToFeedRealtedCountMap.put(siteid,tempCountMap);
	            	}
	            	
	            } else {
	        		if(siteToFeedRealtedCountMap.containsKey('FeedOtherThanSite')){
	        			tempCountMap = siteToFeedRealtedCountMap.get('FeedOtherThanSite');
	        			if (tempCountMap != NULL && tempCountMap.containsKey('RepliesCount')){
	        				repliesCount = tempCountMap.get('RepliesCount') + 1;
	            			tempCountMap.put('RepliesCount',repliesCount);
	            			siteToFeedRealtedCountMap.put('FeedOtherThanSite',tempCountMap);
	        			} else {
	            			tempCountMap.put('RepliesCount',1);
	            			siteToFeedRealtedCountMap.put('FeedOtherThanSite',tempCountMap);
	            		}
	        			
	        		} else {
	        			tempCountMap.put('RepliesCount',1);
	        			siteToFeedRealtedCountMap.put('FeedOtherThanSite',tempCountMap);
	        		}
	        	}	
	        }	                                                               
	                                                                         
	        
	        // Like count for feed post                                                                   
	        List<FeedItem> feedList = [SELECT Id, ParentId, 
	        								(SELECT Id FROM FeedLikes WHERE createdDate >=: startDateTime AND createdDate <: endDateTime)
	                                        FROM FeedItem WHERE (SystemModstamp >=: startDateTime AND SystemModstamp <: endDateTime) 
	                                        AND Id IN : feedItemIdSet];
	                                               
	        Integer likeCount = 0;
	        siteId = '';                                       
	        for (FeedItem feedItemObj : feedList){
	        	if(feedItemToSiteMap.containsKey(feedItemObj.id)){
	        		siteId = feedItemToSiteMap.get(feedItemObj.id);
	        		for(FeedLike fd : feedItemObj.FeedLikes){
	        			likeCount = 0;
	        			tempCountMap = new Map<String,Integer>();
		        		if(siteToFeedRealtedCountMap.containsKey(siteId)){
	        				tempCountMap = siteToFeedRealtedCountMap.get(siteId);
	        				if(tempCountMap != NULL && tempCountMap.containsKey('LikeCount')){
			        			likeCount = tempCountMap.get('LikeCount') + 1;
			        			tempCountMap.put('LikeCount',likeCount);
			        			siteToFeedRealtedCountMap.put(siteId,tempCountMap);
	        				} else {
	        					tempCountMap.put('LikeCount',1);
		        				siteToFeedRealtedCountMap.put(siteId,tempCountMap);
	        				}	
		        				
		        		} else {
		        			tempCountMap.put('LikeCount',1);
		        			siteToFeedRealtedCountMap.put(siteId,tempCountMap);
		        		}
	        		}
	        	} else if( !String.valueOf(feedItemObj.parentId).startsWith('0F9')){
	        		for(FeedLike fd : feedItemObj.FeedLikes){
	        			tempCountMap = new Map<String,Integer>();
	        			likeCount = 0;
		        		if(siteToFeedRealtedCountMap.containsKey('FeedOtherThanSite')){
		        			tempCountMap = siteToFeedRealtedCountMap.get('FeedOtherThanSite');
		        			if(tempCountMap != NULL && tempCountMap.get('LikeCount') != NULL){
		        				likeCount = tempCountMap.get('LikeCount') + 1;
		        				tempCountMap.put('LikeCount',likeCount);
		        				siteToFeedRealtedCountMap.put('FeedOtherThanSite',tempCountMap);
		        			} else {
		        				tempCountMap.put('LikeCount',1);
		        				siteToFeedRealtedCountMap.put('FeedOtherThanSite',tempCountMap);
		        			}
		        		} else {
		        			tempCountMap.put('LikeCount',1);
		        			siteToFeedRealtedCountMap.put('FeedOtherThanSite',tempCountMap);
		        		}
	        		}	
	        	}
			}  
	        // likes for replies 
	        likeCountOnReplies (feedItemToSiteMap,feedItemIdSet,startDateTime,endDateTime);
	        // Share Count                                                     
	       	Integer ShareCount = 0;
	       	List<Share__c> shareList = [SELECT id,createdDate,Feed_Item_Id__c,Content__c FROM Share__c WHERE 
	       										(createdDate >=: startDateTime AND createdDate <: endDateTime)  
	       										AND Feed_Item_Id__c IN : feedItemIdSet];
	       									//AND (Content__c IN : simpplrContentIdSet OR Feed_Item_Id__c IN : feedItemIdSet)];
	       
			for (Share__c fc : shareList){
				tempCountMap = new Map<String,Integer>();
				ShareCount = 0;
				if(feedItemToSiteMap.containsKey(fc.Feed_Item_Id__c)){
	            	siteid = feedItemToSiteMap.get(fc.Feed_Item_Id__c);
	            	
	            	if(siteToFeedRealtedCountMap.containsKey(siteid)){
	            		tempCountMap = siteToFeedRealtedCountMap.get(siteid);
	            		if(tempCountMap != NULL && tempCountMap.containsKey('ShareCount')){
	            			ShareCount = tempCountMap.get('ShareCount')+1;
	                		tempCountMap.put('ShareCount',ShareCount);
	            			siteToFeedRealtedCountMap.put(siteid,tempCountMap);
	            		} else {
	                		tempCountMap.put('ShareCount',1);
	            			siteToFeedRealtedCountMap.put(siteid,tempCountMap);
	                	}
	            		
	            	} else {
	            		tempCountMap.put('ShareCount',1);
	        			siteToFeedRealtedCountMap.put(siteid,tempCountMap);
	            	}
	            	
	            } else if( feedItemToParentMap.containsKey(fc.Feed_Item_Id__c)){
	        		if(siteToFeedRealtedCountMap.containsKey('FeedOtherThanSite')){
	        			tempCountMap = siteToFeedRealtedCountMap.get('FeedOtherThanSite');
	        			if (tempCountMap != NULL && tempCountMap.containsKey('ShareCount')){
	        				ShareCount = tempCountMap.get('ShareCount') + 1;
	            			tempCountMap.put('ShareCount',ShareCount);
	            			siteToFeedRealtedCountMap.put('FeedOtherThanSite',tempCountMap);
	        			} else {
	            			tempCountMap.put('ShareCount',1);
	            			siteToFeedRealtedCountMap.put('FeedOtherThanSite',tempCountMap);
	            		}
	        			
	        		} else {
	        			tempCountMap.put('ShareCount',1);
	        			siteToFeedRealtedCountMap.put('FeedOtherThanSite',tempCountMap);
	        		}
	        	}	
			}
	    } else if('sendAnalyticsDataToAWS'.equalsIgnoreCase(recordType)) {
	    		PushAnalyticsDataHelper analyticsHandler = new PushAnalyticsDataHelper();
	    		analyticsHandler.sendAnalticsFeedCountListToAWS(listOfsObject);
	    }
		} catch(Exception ex) {
    		Utility.sendBatchFailedExceptionEmail('BatchFeedAnalytics', ex);
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
	    	if (!Test.isRunningTest()) {
	    		
	    		if('initAnalyticsData'.equalsIgnoreCase(recordType)){
	    			BatchFeedAnalytics job = new BatchFeedAnalytics('sendAnalyticsDataToAWS', startDate);
       			Database.executeBatch(job, 100);
	    		
	    		} else { 
		    		BatchReadershipAnalytics job = new BatchReadershipAnalytics('initAnalyticsData', startDate);
       				Database.executeBatch(job, 50);
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
    private void saveBatchData() {
    	try {
	    	List<Analytics_Feed_Count__c> feedCountList = new List<Analytics_Feed_Count__c>();
	    	
	    	if (siteToFeedRealtedCountMap.keySet().size() > 0){
	    		
	    		for (String site : siteToFeedRealtedCountMap.keySet()){
		    		Analytics_Feed_Count__c analyticsFeedCount = new Analytics_Feed_Count__c();
		    		analyticsFeedCount.date__c = startdate;
		    		analyticsFeedCount.Likes__c = (Decimal.valueOf(siteToFeedRealtedCountMap.get(site).get('LikeCount')) == NULL ? 0 : 
		    														Decimal.valueOf(siteToFeedRealtedCountMap.get(site).get('LikeCount')));
		    		analyticsFeedCount.Posts__c = (Decimal.valueOf(siteToFeedRealtedCountMap.get(site).get('PostCount')) == NULL ? 0 :
		    														Decimal.valueOf(siteToFeedRealtedCountMap.get(site).get('PostCount')));
		    		analyticsFeedCount.Replies__c = (Decimal.valueOf(siteToFeedRealtedCountMap.get(site).get('RepliesCount')) == NULL ? 0 : 
		    														Decimal.valueOf(siteToFeedRealtedCountMap.get(site).get('RepliesCount')));
		    		if( !'FeedOtherThanSite'.equalsIgnoreCase(site)){
		    			analyticsFeedCount.Site__c = site;
		    		}	
		    		analyticsFeedCount.Shares__c = (Decimal.valueOf(siteToFeedRealtedCountMap.get(site).get('ShareCount')) == NULL ? 0 : 
		    														Decimal.valueOf(siteToFeedRealtedCountMap.get(site).get('ShareCount')));
		    		feedCountList.add(analyticsFeedCount);
		    	}
	    	} else {
	    		
	    		List<Simpplr_Site__c> siteList = [SELECT Id FROM Simpplr_Site__c WHERE Is_Active__c = true AND Is_Deleted__c = false];
	    		
	    		for (Simpplr_Site__c site : siteList){
		    		
		    		Analytics_Feed_Count__c analyticsFeedCount = new Analytics_Feed_Count__c();
		    		analyticsFeedCount.date__c = startdate;
		    		analyticsFeedCount.Likes__c = 0;
		    		analyticsFeedCount.Posts__c = 0;
		    		analyticsFeedCount.Replies__c = 0;
	    			analyticsFeedCount.Site__c = site.Id;
		    		analyticsFeedCount.Shares__c = 0;
		    		feedCountList.add(analyticsFeedCount);
	    		}	
	    	}
	    	
	    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(feedCountList, new List<Schema.SObjectField>{
					Analytics_Feed_Count__c.date__c,
					Analytics_Feed_Count__c.Likes__c,
					Analytics_Feed_Count__c.Posts__c,
					Analytics_Feed_Count__c.Replies__c,
					Analytics_Feed_Count__c.Site__c,
					Analytics_Feed_Count__c.Shares__c});

    	} catch(Exception ex) {
    		Utility.sendBatchFailedExceptionEmail('BatchFeedAnalytics', ex); 
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
	private void likeCountOnReplies (Map<String,String> feedItemToSiteMap,Set<String> feedItemIdSet,DateTime startDateTime,DateTime endDateTime){
		
		Map<String,Integer> tempCountMap;
		Integer likeCount = 0;
        String siteId ; 
		List<Like__c> likeList = [SELECT Id,Feed_Item_Id__c,Feed_Item_Comment_Id__c
											FROM Like__c 
                                            WHERE Feed_Item_Id__c IN : feedItemIdSet AND Feed_Item_Comment_Id__c != NULL 
                                            AND (createdDate >=: startDateTime AND createdDate <: endDateTime)];
	                                               
                                              
        for (Like__c fc : likeList){
        	siteId = '';
        	likeCount = 0;
        	tempCountMap = new Map<String,Integer>();
        	if(feedItemToSiteMap.containsKey(fc.Feed_Item_Id__c)){
        		siteId = feedItemToSiteMap.get(fc.Feed_Item_Id__c);
        		if(siteToFeedRealtedCountMap.containsKey(siteId)){
    				tempCountMap = siteToFeedRealtedCountMap.get(siteId);
    				if(tempCountMap != NULL && tempCountMap.containsKey('LikeCount')){
	        			likeCount = tempCountMap.get('LikeCount') + 1;
	        			tempCountMap.put('LikeCount',likeCount);
	        			siteToFeedRealtedCountMap.put(siteId,tempCountMap);
    				} else {
    					tempCountMap.put('LikeCount',1);
        				siteToFeedRealtedCountMap.put(siteId,tempCountMap);
    				}	
        				
        		} else {
        			tempCountMap.put('LikeCount',1);
        			siteToFeedRealtedCountMap.put(siteId,tempCountMap);
        		}
        	} else {
    			tempCountMap = new Map<String,Integer>();
    			likeCount = 0;
        		if(siteToFeedRealtedCountMap.containsKey('FeedOtherThanSite')){
        			tempCountMap = siteToFeedRealtedCountMap.get('FeedOtherThanSite');
        			if(tempCountMap != NULL && tempCountMap.get('LikeCount') != NULL){
        				likeCount = tempCountMap.get('LikeCount') + 1;
        				tempCountMap.put('LikeCount',likeCount);
        				siteToFeedRealtedCountMap.put('FeedOtherThanSite',tempCountMap);
        			} else {
        				tempCountMap.put('LikeCount',1);
        				siteToFeedRealtedCountMap.put('FeedOtherThanSite',tempCountMap);
        			}
        		} else {
        			tempCountMap.put('LikeCount',1);
        			siteToFeedRealtedCountMap.put('FeedOtherThanSite',tempCountMap);
        		}
        	}	
		}
	}
}