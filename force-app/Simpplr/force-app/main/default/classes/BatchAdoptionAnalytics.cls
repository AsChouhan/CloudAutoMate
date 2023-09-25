/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class BatchAdoptionAnalytics implements Database.Batchable<SObject>, Database.AllowsCallouts {
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    
    private static final List<Integer> SYNC_STATUS_SENT = new List<Integer> {1,3,5};
    DateTime startDateTime ;
	DateTime endDateTime ;
	Date startDate ;
	Date endDate ;
	String packageName;
	String endpoint;
	String recordType;
	List<Object> analyticWrapperList;
	
    public BatchAdoptionAnalytics (String recordType, Date dateArg){
		packageName = SimpplrContext.packageName;
		startDate = dateArg;
		endDate = dateArg.addDays(1) ;
		this.recordType = recordType;
		
		startDateTime = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day(), 0, 0, 0);  
		endDateTime = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day(), 0, 0, 0);	
	}
	
	public BatchAdoptionAnalytics (Date dateArg){
		this.recordType = 'initAnalyticsData';
		packageName = SimpplrContext.packageName;
		startDate = dateArg;
		endDate = dateArg.addDays(1);
		
		startDateTime = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day(), 0, 0, 0);  
		endDateTime = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day(), 0, 0, 0);	
	}
	
	public BatchAdoptionAnalytics (){
		packageName = SimpplrContext.packageName;
		this.recordType = 'initAnalyticsData';
		endDate = System.today();
		startDate = endDate.addDays(-1);
		
		startDateTime = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day(), 0, 0, 0);  
		endDateTime = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day(), 0, 0, 0);	
	}
    
	public Database.QueryLocator start(Database.BatchableContext BC){
		String query;
		
		if('initAnalyticsData'.equalsIgnoreCase(recordType)){
			query = 'select id,user__c from People__c where User__r.UserType=\'Standard\' and createddate < :enddatetime ';
			if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
				 query = query + ' and user__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: packageName and createddate < :enddatetime) ';
			}
		} else if('sendAnalyticsDataToAWS'.equalsIgnoreCase(recordType)){
			query =  'select Id, Date__c, People__r.User_Hash__c, People__c, Is_Contributor__c, Is_Participant__c, Is_Observer__c, Is_Active__c,Has_Used_Hybrid_Android_App__c, ' 
    			+ ' Has_Used_Hybrid_IOS_App__c, Has_Used_Native_Android_App__c, Has_Used_Native_IOS_App__c, Total_Logins__c, Desktop__c, DesktopApp__c, Mobile__c, MobileApp__c, Page_Views__c, Content_Views__c, Sync_Status__c '
    			+ ' from Analytics_Adoption__c where Sync_Status__c !=:SYNC_STATUS_SENT ';
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
    public void execute(Database.BatchableContext BC, List<sObject> listOfsObject){
		try {
		if('initAnalyticsData'.equalsIgnoreCase(recordType)){
			initAnalyticsData((List<People__c>)listOfsObject);
		
		} else if('sendAnalyticsDataToAWS'.equalsIgnoreCase(recordType)) {
			PushAnalyticsDataHelper analyticsHandler = new PushAnalyticsDataHelper();
			analyticsHandler.sendAnalyticsAdoptionListToAWS(listOfsObject);
		}
    	} catch(Exception ex) {
    		Utility.sendBatchFailedExceptionEmail('BatchAdoptionAnalytics', ex);
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
			BatchAdoptionAnalytics job = new BatchAdoptionAnalytics('sendAnalyticsDataToAWS', startDate);
			DataBase.executeBatch(job, 1000);
	    	} else {
			BatchLoginAnalytics loginBatch = new BatchLoginAnalytics(startDate);
			DataBase.executeBatch(loginBatch, 2000);
	    	}
    }
     
    private void initAnalyticsData(List<People__c> peopleList){
    		Map<Id,People__c> userIdToPeopleMap = new Map<Id,People__c>();
			for(People__c peopleObj : peopleList){
				userIdToPeopleMap.put(peopleObj.User__c,peopleObj);
			}
			
			Set<String> simpplrUserIdSet = new Set<String>();
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', peopleList);
			soqlParamMap.put('soqlParam2', startDateTime);
			soqlParamMap.put('soqlParam3', endDateTime);
			String socialAnlytcsQuery = 'select User__c, Interaction__c, Origin_Device_Type__c, Origin_Native_Mobile_App__c, Origin_Desktop_App__c,Origin_Mobile_App__c, Origin_Mobile_Browser__c, Content__r.Primary_Author__r.User__c, Content__c from Simpplr_Social_Analytics__c where People__c IN: soqlParam1 and Interaction__c=\'View\' and (createdDate >=: soqlParam2 AND createdDate <: soqlParam3)';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Simpplr_Social_Analytics__c> socialAnalyticsList = (List<Simpplr_Social_Analytics__c>)SIMPESAPI.accessController().queryAsUser(socialAnlytcsQuery, soqlParamMap);
			for(Simpplr_Social_Analytics__c socialObj : socialAnalyticsList){
				simpplrUserIdSet.add(socialObj.User__c);
			}
			
	    	List<LoginHistory> loginHistoryList = [select userid, status from LoginHistory where userid IN:userIdToPeopleMap.keySet() and (LoginTime >=: startDateTime AND LoginTime <: endDateTime)];
			Map<Id,Integer> userLoginCountMap = new Map<Id,Integer>();
	    	for(LoginHistory loggedInUser : loginHistoryList){
	    		if(loggedInUser.status.equalsIgnoreCase('Success')){
		    		if(userIdToPeopleMap.keySet().contains(loggedInUser.userId)){
		    			if(userLoginCountMap.get(loggedInUser.userId) == null){
	    					userLoginCountMap.put(loggedInUser.userId, 0);
	    				}
	    				userLoginCountMap.put(loggedInUser.userId, userLoginCountMap.get(loggedInUser.userId)+1);
	    				simpplrUserIdSet.add(loggedInUser.userId);
		    		}
	    		}
	    	}
	
	    	Map<String,Integer> contributorMap = new Map<String,Integer>();
	    	Set<String> parentTypeSet = new Set<String>{'User', 'CollaborationGroup', PageContext.namespacePrefix + 'Simpplr_Content__c'};
	    	
	    	//User FeedItems
	    	String queryForUserFeedItem = 'select createdById from FeedItem where createdById IN: simpplrUserIdSet and parent.type =\'User\' And type!=\'TrackedChange\' AND (createdDate >=: startDateTime AND createdDate <: endDateTime)';
	    	if(SimpplrContext.isCommunitiesEnabled){
	    		queryForUserFeedItem = queryForUserFeedItem + ' and (networkscope = null or networkscope = \'allnetworks\')';
	    	}
	    	queryForUserFeedItem = queryForUserFeedItem + ' LIMIT 15000 ';
	    	
	    	List<FeedItem> userFeedItemList = Database.query(queryForUserFeedItem);
	    	for(FeedItem feedItemObj : userFeedItemList){
	    		if(contributorMap.get(feedItemObj.createdById) == null){
	    			contributorMap.put(feedItemObj.createdById, 0);
	    		}
	    		contributorMap.put(feedItemObj.createdById,contributorMap.get(feedItemObj.createdById)+1);
	    	}
	    	
	    	//CollaborationGroup FeedItems
	    	String queryForGroupFeedItem = 'select createdById from FeedItem where createdById IN: simpplrUserIdSet and parent.type =\'CollaborationGroup\' And type!=\'TrackedChange\' And (createdDate >=: startDateTime AND createdDate <: endDateTime)';
	    	if(SimpplrContext.isCommunitiesEnabled){
	    		queryForGroupFeedItem = queryForGroupFeedItem + ' and (networkscope = null or networkscope = \'allnetworks\')';
	    	}
	    	queryForGroupFeedItem = queryForGroupFeedItem + ' LIMIT 15000 ';
	    	
	    	List<FeedItem> groupFeedItemList = Database.query(queryForGroupFeedItem);
	    	for(FeedItem feedItemObj : groupFeedItemList){
	    		if(contributorMap.get(feedItemObj.createdById) == null){
	    			contributorMap.put(feedItemObj.createdById, 0);
	    		}
	    		contributorMap.put(feedItemObj.createdById,contributorMap.get(feedItemObj.createdById)+1);
	    	}
	    	
	    	//Content FeedItems
	    	String parentType = PageContext.namespacePrefix + 'Simpplr_Content__c';
			Set<String> ignoredfeedItemTypes = new Set<String>{'TrackedChange','LinkPost'};
	    	String queryForContentFeedItem = 'select createdById from FeedItem where createdById IN: simpplrUserIdSet and parent.type =:parentType And type!=:ignoredfeedItemTypes And (createdDate >=: startDateTime AND createdDate <: endDateTime)';
	    	if(SimpplrContext.isCommunitiesEnabled){
	    		queryForContentFeedItem = queryForContentFeedItem + ' and (networkscope = null or networkscope = \'allnetworks\')';
	    	}
	    	queryForContentFeedItem = queryForContentFeedItem + ' LIMIT 15000 ';
	    	
	    	List<FeedItem> contentFeedItemList = Database.query(queryForContentFeedItem);
	    	for(FeedItem feedItemObj : contentFeedItemList){
	    		if(contributorMap.get(feedItemObj.createdById) == null){
	    			contributorMap.put(feedItemObj.createdById, 0);
	    		}
	    		contributorMap.put(feedItemObj.createdById,contributorMap.get(feedItemObj.createdById)+1);
	    	}
			
			//FeedComments	    	
	    	List<FeedComment> feedCommentList = new List<FeedComment>();
	    	String queryForFeedComment = 'select createdById from FeedComment where createdById IN: simpplrUserIdSet and (createdDate >=: startDateTime AND createdDate <: endDateTime)';
	    	if(SimpplrContext.isCommunitiesEnabled){
	    		queryForFeedComment = queryForFeedComment + ' and feeditemid in (select id from feeditem where networkscope = null or networkscope = \'allnetworks\')';
	    	}
	    	feedCommentList = Database.query(queryForFeedComment);
	    	for(FeedComment feedCommentObj : feedCommentList){
	    		if(contributorMap.get(feedCommentObj.createdById) == null){
	    			contributorMap.put(feedCommentObj.createdById, 0);
	    		}
	    		contributorMap.put(feedCommentObj.createdById, contributorMap.get(feedCommentObj.createdById)+1);
	    	}	
	    	
	    	List<Simpplr_Content__c> contentList = [select  Primary_Author__r.User__c from Simpplr_Content__c where Primary_Author__r.User__c IN: simpplrUserIdSet and (createdDate >=: startDateTime AND createdDate <: endDateTime)];
	    	for(Simpplr_Content__c contentObj : contentList){
	    		if(contributorMap.get(contentObj.Primary_Author__r.User__c) == null){
	    			contributorMap.put(contentObj.Primary_Author__r.User__c, 0);
	    		}
	    		contributorMap.put(contentObj.Primary_Author__r.User__c,contributorMap.get(contentObj.Primary_Author__r.User__c)+1);
	    	}
	    	
	    	Map<String,Integer> participantMap = new Map<String,Integer>();
	    	
	    	List<Like__c> likeList = [select CreatedById from Like__c where createdById IN: simpplrUserIdSet and (createdDate >=: startDateTime AND createdDate <: endDateTime)];
	    	for(Like__c LikeObj : likeList){
	    		if(!contributorMap.keySet().contains(LikeObj.CreatedById)){
	    			if(participantMap.get(LikeObj.CreatedById) == null){
	    				participantMap.put(LikeObj.CreatedById,0);
	    			}
		    		participantMap.put(LikeObj.CreatedById,participantMap.get(LikeObj.CreatedById)+1);
	    		}
	    	}
	    	
	    	List<Share__c> shareList = [select CreatedById from Share__c where CreatedById IN: simpplrUserIdSet and (createdDate >=: startDateTime AND createdDate <: endDateTime)];
	    	for(Share__c shareObj : shareList){
	    		if(!contributorMap.keySet().contains(shareObj.CreatedById)){
	    			if(participantMap.get(shareObj.CreatedById) == null){
	    				participantMap.put(shareObj.CreatedById,0);
	    			}
	    			participantMap.put(shareObj.CreatedById,participantMap.get(shareObj.CreatedById)+1);
	    		}
	    	}
	    	
	    	List<Bookmark__c> bookmarkList = [select CreatedById from Bookmark__c  where CreatedById IN: simpplrUserIdSet and (createdDate >=: startDateTime AND createdDate <: endDateTime) AND Is_Deleted__c = false];
	    	for(Bookmark__c bookmarkObj : bookmarkList){
	    		if(!contributorMap.keySet().contains(bookmarkObj.CreatedById)){
	    			if(participantMap.get(bookmarkObj.CreatedById) ==  null){
	    				participantMap.put(bookmarkObj.CreatedById, 0);
	    			}
	    			participantMap.put(bookmarkObj.CreatedById, participantMap.get(bookmarkObj.CreatedById)+1);
	    		}
	    	}
	    	
	    	Set<String> participationType = new Set<String>{'Follow','Endorse','Event Invite','Review', 'Report', 'Update', 'Rated'};
	    	List<App_Notification__c> notificationList = [select Sent_By__r.User__c,Sub_Type__c from App_Notification__c where Sub_Type__c IN:participationType AND Is_Deleted__c = false and CreatedById IN: simpplrUserIdSet and (createdDate >=: startDateTime AND createdDate <: endDateTime)];
	    	for(App_Notification__c notiObj : notificationList){
	    		
	    		if('Endorse'.equalsIgnoreCase(notiObj.Sub_Type__c)){
	    			if(contributorMap.containsKey(notiObj.Sent_By__r.User__c)){
	    				contributorMap.put(notiObj.Sent_By__r.User__c, contributorMap.get(notiObj.Sent_By__r.User__c)+1);
	    			}else {
	    				contributorMap.put(notiObj.Sent_By__r.User__c, 1);
	    			}
	    			if(participantMap.containsKey(notiObj.Sent_By__r.User__c)){
	    				participantMap.remove(notiObj.Sent_By__r.User__c);
	    			}
	    		} else if(!contributorMap.keySet().contains(notiObj.Sent_By__r.User__c)){
	    			if(participantMap.get(notiObj.Sent_By__r.User__c) ==  null){
	    				participantMap.put(notiObj.Sent_By__r.User__c,0);
	    			}
	    			participantMap.put(notiObj.Sent_By__r.User__c, participantMap.get(notiObj.Sent_By__r.User__c)+1);
	    		}
	    	}
	    	
	    	Map<String,Integer> observerMap = new Map<String,Integer>();
	    	Map<Id,Integer> pageViewCountMap = new Map<Id,Integer>();
			Map<Id,Integer> contentViewCountMap = new Map<Id,Integer>();
	    	Map<Id,Integer> desktopCountMap = new Map<Id,Integer>();
	    	Map<Id,Integer> desktopAppCountMap = new Map<Id,Integer>();
	    	Map<Id,Integer> mobileCountMap = new Map<Id,Integer>();
	    	Map<Id,Integer> mobileAppCountMap = new Map<Id,Integer>();
	    	Set<String> nativeIOSUserSet = new Set<String>();
	    	Set<String> nativeAndroidUserSet = new Set<String>();
	    	Set<String> hybridIOSUserSet = new Set<String>();
	    	Set<String> hybridAndroidUserSet = new Set<String>();
	    	
	    	for(Simpplr_Social_Analytics__c socialAnalObj : socialAnalyticsList){
	    		if(userLoginCountMap.get(socialAnalObj.user__c) == null){
	    			userLoginCountMap.put(socialAnalObj.user__c, 1);
				}
	    		if(pageViewCountMap.get(socialAnalObj.user__c)==null){
	    			pageViewCountMap.put(socialAnalObj.user__c,0);
	    		}
	    		pageViewCountMap.put(socialAnalObj.user__c,pageViewCountMap.get(socialAnalObj.user__c)+1);
	    		
				if(contentViewCountMap.get(socialAnalObj.user__c)==null){
	    			contentViewCountMap.put(socialAnalObj.user__c,0);
	    		}
				if(String.isNotBlank(socialAnalObj.content__c)) {
					contentViewCountMap.put(socialAnalObj.user__c,contentViewCountMap.get(socialAnalObj.user__c)+1);
				}
	    		if(socialAnalObj.Origin_Desktop_App__c){
	    			if(desktopAppCountMap.get(socialAnalObj.user__c)==null){
	    				desktopAppCountMap.put(socialAnalObj.user__c,0);	
	    			}
	    			desktopAppCountMap.put(socialAnalObj.user__c,desktopAppCountMap.get(socialAnalObj.user__c)+1);
	    		} else if(socialAnalObj.Origin_Mobile_App__c){
	    			if(mobileAppCountMap.get(socialAnalObj.user__c)==null){
	    				mobileAppCountMap.put(socialAnalObj.user__c,0);	
	    			}
	    			mobileAppCountMap.put(socialAnalObj.user__c,mobileAppCountMap.get(socialAnalObj.user__c)+1);
	    		} else if(socialAnalObj.Origin_Mobile_Browser__c) {
	    			if(mobileCountMap.get(socialAnalObj.user__c)==null){
	    				mobileCountMap.put(socialAnalObj.user__c,0);	
	    			}
	    			mobileCountMap.put(socialAnalObj.user__c,mobileCountMap.get(socialAnalObj.user__c)+1);
	    		} else {
	    			if(desktopCountMap.get(socialAnalObj.user__c)==null){
	    				desktopCountMap.put(socialAnalObj.user__c,0);	
	    			}
	    			desktopCountMap.put(socialAnalObj.user__c,desktopCountMap.get(socialAnalObj.user__c)+1);
	    		}
	    		
	    		if(!participantMap.keySet().contains(socialAnalObj.User__c)) {
		    		if(!contributorMap.keySet().contains(socialAnalObj.User__c)){
		    			if(observerMap.get(socialAnalObj.User__c) == null){
		    				observerMap.put(socialAnalObj.User__c,0);
		    			}
		    			observerMap.put(socialAnalObj.User__c,observerMap.get(socialAnalObj.User__c)+1);
		    		}
	    		}
	    		
	    		if(socialAnalObj.Origin_Native_Mobile_App__c && 'ios'.equalsIgnoreCase(socialAnalObj.Origin_Device_Type__c)){
	    			nativeIOSUserSet.add(socialAnalObj.User__c);
	    		}
	    		if(socialAnalObj.Origin_Native_Mobile_App__c && 'android'.equalsIgnoreCase(socialAnalObj.Origin_Device_Type__c)){
	    			nativeAndroidUserSet.add(socialAnalObj.User__c);
	    		}
	    		if(socialAnalObj.Origin_Mobile_App__c && 'ios'.equalsIgnoreCase(socialAnalObj.Origin_Device_Type__c)){
	    			hybridIOSUserSet.add(socialAnalObj.User__c);
	    		}
	    		if(socialAnalObj.Origin_Mobile_App__c && 'android'.equalsIgnoreCase(socialAnalObj.Origin_Device_Type__c)){
	    			hybridAndroidUserSet.add(socialAnalObj.User__c);
	    		}
	    		
	    	}
	    	
	    	List<Analytics_Adoption__c> adoptionList = new List<Analytics_Adoption__c>();
	    	for(String userId : simpplrUserIdSet){
	    		
	    		Analytics_Adoption__c adoptionObj = new Analytics_Adoption__c();
	    		adoptionObj.Date__c = startDate;
		    	adoptionObj.User__c = userId;

	    		if(userIdToPeopleMap.get(userId) != null){
	    			adoptionObj.People__c = userIdToPeopleMap.get(userId).id;
	    		}
	    		if(userLoginCountMap.get(userId) != null){
	    			if(userLoginCountMap.get(userId) >0){ 
	    				adoptionObj.Total_Logins__c = userLoginCountMap.get(userId) != null ? userLoginCountMap.get(userId) : 0;
	    			}
	    		}
    			if(contributorMap.get(userId) != null || observerMap.get(userId) != null || participantMap.get(userId) != null){
    				adoptionObj.Is_Contributor__c = contributorMap.get(userId) != null;
		    		adoptionObj.Is_Observer__c = observerMap.get(userId) != null;
		    		adoptionObj.Is_Participant__c = participantMap.get(userId) != null;
		    		adoptionObj.Is_Active__c = contributorMap.get(userId) != null || observerMap.get(userId) != null || participantMap.get(userId) != null;
		    		adoptionObj.Desktop__c = desktopCountMap.get(userId) != null? desktopCountMap.get(userId) :0;
		    		adoptionObj.DesktopApp__c = desktopAppCountMap.get(userId) != null?desktopAppCountMap.get(userId) :0;
		    		adoptionObj.Mobile__c = mobileCountMap.get(userId) != null ? mobileCountMap.get(userId) : 0;
		    		adoptionObj.MobileApp__c = mobileAppCountMap.get(userId) != null?mobileAppCountMap.get(userId) : 0;
		    		adoptionObj.Page_Views__c = pageViewCountMap.get(UserId) != null ?pageViewCountMap.get(UserId) : 0;
					adoptionObj.Content_Views__c = contentViewCountMap.get(UserId) != null ? contentViewCountMap.get(UserId) : 0;
		    		
		    		adoptionObj.Has_Used_Native_IOS_App__c = nativeIOSUserSet.contains(userId) ? true : false;
		    		adoptionObj.Has_Used_Native_Android_App__c = nativeAndroidUserSet.contains(userId) ? true : false;
		    		adoptionObj.Has_Used_Hybrid_IOS_App__c = hybridIOSUserSet.contains(userId) ? true : false;
		    		adoptionObj.Has_Used_Hybrid_Android_App__c = hybridAndroidUserSet.contains(userId) ? true : false;
		    		
			    	adoptionList.add(adoptionObj);
		    		
    			}
	    	}
	    	
	    	if( !adoptionList.isEmpty() ) {
	    		List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();

				fieldList.add(Analytics_Adoption__c.Date__c);
				fieldList.add(Analytics_Adoption__c.User__c);
				fieldList.add(Analytics_Adoption__c.People__c);
				fieldList.add(Analytics_Adoption__c.Total_Logins__c);
				fieldList.add(Analytics_Adoption__c.Is_Contributor__c);
				fieldList.add(Analytics_Adoption__c.Is_Observer__c);
				fieldList.add(Analytics_Adoption__c.Is_Participant__c);
				fieldList.add(Analytics_Adoption__c.Is_Active__c);
				fieldList.add(Analytics_Adoption__c.Desktop__c);
				fieldList.add(Analytics_Adoption__c.DesktopApp__c);
				fieldList.add(Analytics_Adoption__c.Mobile__c);
				fieldList.add(Analytics_Adoption__c.MobileApp__c);
				fieldList.add(Analytics_Adoption__c.Page_Views__c);
				fieldList.add(Analytics_Adoption__c.Content_Views__c);
				fieldList.add(Analytics_Adoption__c.Has_Used_Native_IOS_App__c);
				fieldList.add(Analytics_Adoption__c.Has_Used_Native_Android_App__c);
				fieldList.add(Analytics_Adoption__c.Has_Used_Hybrid_IOS_App__c);
				fieldList.add(Analytics_Adoption__c.Has_Used_Hybrid_Android_App__c);

 				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
 				SIMPESAPI.accessController().insertAsUser(adoptionList, fieldList);
	    	}
    }
}