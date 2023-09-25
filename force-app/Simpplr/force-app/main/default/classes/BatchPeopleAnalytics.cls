/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class BatchPeopleAnalytics implements Database.Batchable<SObject>, Database.AllowsCallouts {
	
	private static final List<Integer> SYNC_STATUS_SENT = new List<Integer> {1,3,5};
	private static final List<Integer> SYNC_STATUS_VERIFICAION_PENDING = new List<Integer> {1,3};
	DateTime startDateTime;
	DateTime endDateTime;
	Date startDate;
	Date endDate;
	String recordType;
	String packageName;
	Set<Id> peopleIdSet;
	Set<String> peopleUserIdSet;
	Set<String> soqlLikeUserIdSet;
	Map<ID,ID> userToPeopleMap;
	Map<ID,Integer> peopleToBookMarkGivenMap;
	Map<ID,Integer> peopleToBookMarkReceivedMap;
	Map<ID,Integer> peopleToMentionMap;
	Map<ID,Integer> peopleToFeedItemMap;
	Map<ID,Integer> peopleToReplyReceivedMap;
	Map<ID,Integer> peopleToReplyMadeMap;
	Map<ID,Integer> peopleToFollowingMap;
	Map<ID,Integer> peopleToFollowerMap;
	Map<ID,Integer> peopleToLikeGivenMap;
	Map<ID,Integer> peopleToLikeReceivedMap;
	Map<ID,Integer> peopleToShareGivenMap;
	Map<ID,Integer> peopleToShareReceivedMap;
	Map<ID,Integer> peopleToContentMap;
	Map<ID, Integer>peopleToProfileViewMap;
	List<Object> analyticWrapperList;
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public BatchPeopleAnalytics (String recordType, Date dateArg){
		packageName = SimpplrContext.packageName;
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
    public database.querylocator start(Database.BatchableContext bc){
    	String query;
    	if('initAnalyticsData'.equalsIgnoreCase(recordType)){
        query = 'select id,user__c from People__c where User__r.UserType=\'Standard\' and createddate < :enddatetime ';
		if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
			 query = query + ' and user__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =:packageName  and createddate < :enddatetime) ';
		}
    	
    	} else if('sendAnalyticsDataToAWS'.equalsIgnoreCase(recordType)){
    		query = 'select Id, Name, Bookmarks_Made__c, Bookmarks_Received__c, Content_Published__c, Date__c, Feed_Mentions__c, Followers__c, Following__c,'
    				+' Likes_Made__c, Likes_Received__c, People__c, Posts__c, Replies_Made__c, Replies_Received__c, Shares_Made__c, Shares_Received__c,'
    				+' Views_Received__c, CreatedDate, LastModifiedDate, Sync_Status__c from Analytics_Top_People__c where Sync_Status__c !=:SYNC_STATUS_SENT ';
    	
    	} else if('sendPeopleDataToAWS'.equalsIgnoreCase(recordType)) { 
    		query = ' Select  People__c, People__r.Full_Name__c, People__r.Title__c, People__r.Company_Name__c, People__r.Department__c, People__r.Division__c, People__r.City__c, People__r.Street__c, People__r.State__c, People__r.Country__c, People__r.Postal_Code__c, ' + 
             		' People__r.Can_Access_Analytics__c, People__r.Can_Control_Dashboard__c, People__r.Can_Send_Alert__c, People__r.Can_Send_Newsletter__c, People__r.Segment__c, People__r.People_Category__c,People__r.Mobile_Token_Android__c,People__r.Mobile_Token_iOS__c, ' +
             		' People__r.App_Moderation_Permission__c, People__r.Unlisted_Site_Moderation_Permission__c, People__r.Is_Influencer__c, People__r.Is_Campaign_Manager__c, People__r.People_Category__r.Name__c, People__r.Segment__r.Name__c, ' +
             		' People__r.Profile_Photo_Fill_DateTime__c, People__r.Cover_Photo_Fill_DateTime__c, People__r.AboutMe_Fill_DateTime__c, People__r.Phone_Fill_DateTime__c, People__r.Mobile_Fill_DateTime__c, People__r.Birthdate_Fill_DateTime__c, People__r.Email__c,' +
             		' People__r.First_Login_DateTime__c, People__r.Last_Edited_DateTime__c, People__r.Last_Sync_DateTime__c, People__r.User__c, People__r.User__r.IsActive, People__r.User__r.LanguageLocaleKey, ' + 
             		' Allow_Simpplr_Emails__c, Email_Comments_After_Me__c, Email_Comments_On_My_Post__c, Email_Comments_On_Post_I_Like__c, Email_Endorses_Me__c, Email_Follows_Me__c, Email_Like_My_Post_Or_Comment__c, Email_Mentions_Me__c, Email_My_Content_Like__c, '+
             		' Email_My_Content_Post__c, Email_My_Content_Share__c, Email_Posts_On_My_Profile__c, Email_Shares_My_Post__c, Receive_Content_Moderation_Notifications__c, Email_Content_Digest_Frequency__c, '+
             		' Email_My_Content_Approved__c, Email_My_Content_Rejected__c, Email_Notification_Digest_Frequency__c, Email_Content_Submitted_for_Moderation__c, Email_Private_Site_Membership_Requests__c, Email_Digest_Frequency__c,Email_Onboarding_Frequency__c, '+
					' Email_PrivateSiteMembership_Response__c, Email_Content_Submission_Response__c, Actionable_Notification_Frequency__c, Content_Digest_Frequency__c, Default_Site_Digest_Frequency__c, Notification_Digest_Frequency__c, Email_Content_Useful__c, User__c, Receive_Content_Useful_Notifications__c, Email_Event_Invite_More__c,  Email_Updates_Content_Sites_I_Follow__c, '+ 
					' Receive_Content_Update_Notifications__c,  Email_Made_Site_Manager_Or_Owner__c, Email_Content_Marked_As_Must_Read__c, Email_My_Content_Like_Or_Share__c, Email_Posts_To_Me__c, Native_Mob_Content_Submit_Moderation__c, Native_Mob_Private_Site_Membership_Req__c, Native_Mob_Update_Content_Site_I_Follow__c, Native_Mobile_Event_Invite_More__c, Native_Mobile_Follows_Me__c, Native_Mobile_My_Content_Like_Or_Share__c, Email_Site_Analytics_Frequency__c,  '+
					' Native_Mob_Comments_On_My_Post__c, Native_Mob_Like_My_Post_Or_Comment__c, Native_Mob_My_Content_Post__c, Native_Mob_Posts_To_Me__c, Email_Subscription_Moderation__c, People__r.User__r.Show_Simpplr__c, People__r.Has_Read_All_Onboarding_Content__c,'+
                    ' Email_My_Content_Validation_Expired__c, Email_My_Content_Validation_Required__c, Box_Access_Token__c, Email_Alerts__c, SMS_Alerts__c, SMS_Must_Reads__c, SMS_Content_Promotion_Message__c, Native_Mobile_Alerts__c, Native_Mob_Content_Marked_As_Must_Read__c, ' +
                    ' People__r.Custom_Field_1__c, People__r.Custom_Field_2__c, People__r.Custom_Field_3__c, People__r.Custom_Field_4__c, People__r.Custom_Field_5__c,layout__c,Email_Updates_Event_I_RSVP_Yes__c,Email_Updates_Event_I_Author_Organize__c, ' +
                    ' People__r.Custom_Field_6__c, People__r.Custom_Field_7__c, People__r.Custom_Field_8__c, People__r.Custom_Field_9__c, People__r.Custom_Field_10__c, ' +
                    ' People__r.Custom_Field_11__c, People__r.Custom_Field_12__c, People__r.Custom_Field_13__c, People__r.Custom_Field_14__c, People__r.Custom_Field_15__c, ' +
                    ' People__r.Custom_Field_16__c, People__r.Custom_Field_17__c, People__r.Custom_Field_18__c, People__r.Custom_Field_19__c, People__r.Custom_Field_20__c, ' +
                    ' People__r.Custom_Field_21__c, People__r.Custom_Field_22__c, People__r.Custom_Field_23__c, People__r.Custom_Field_24__c, People__r.Custom_Field_25__c, ' +     		
                    ' People__r.Is_Protected_Author_Allowlisted__c, People__r.Is_Protected_Author__c, People__r.External_Photo_URL__c, Email_Subscription_Request__c, People__r.createddate, People__r.User_Last_Deactivated__c, People__r.Enable_Org_Level_Onboarding__c, People__r.Has_simpplr_license__c, People__r.User_Id__c, People__r.User__r.SmallPhotoURL ' +        		
                    ' from People_Preference__c where People__c !=null '; 
            
            List<Package_Upgrade_History__c> uhList=[select id, createddate from Package_Upgrade_History__c order by createddate desc limit 1];
            DateTime cutOffTime = DateTime.now().addDays(-3);
            if(!uhList.isEmpty() && uhList[0].createddate < cutOffTime) {
                query += ' And People__r.User__r.UserType=\'Standard\' and (LastModifiedDate >=:startDate or People__r.User__r.LastModifiedDate >:startDate)  ';    			
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
    			initAnalyticsData((List<People__c>)listOfsObject);
    		
    		} else if('sendAnalyticsDataToAWS'.equalsIgnoreCase(recordType)) {
    			PushAnalyticsDataHelper analyticsHandler = new PushAnalyticsDataHelper();
    			analyticsHandler.sendToAnalticsTopPeopleListToAWS(listOfsObject);
    		
    		} else if('sendPeopleDataToAWS'.equalsIgnoreCase(recordType)) { 
    			PushAnalyticsDataHelper analyticsHandler = new PushAnalyticsDataHelper();
    			analyticsHandler.sendPeopleListToAWS(listOfsObject);
    		}
	    
        } catch(Exception ex) {
    		Utility.sendBatchFailedExceptionEmail('BatchPeopleAnalytics', ex);
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
    			BatchPeopleAnalytics job = new BatchPeopleAnalytics('sendPeopleDataToAWS', startDate);
    			Database.executeBatch(job, 1000);
    			
    		} else if('sendPeopleDataToAWS'.equalsIgnoreCase(recordType)){
				BatchPeopleAnalytics job = new BatchPeopleAnalytics('sendAnalyticsDataToAWS', startDate);
	    		Database.executeBatch(job, 1000);
    		
    		} else {
                List<Analytics_Login__c> listOfLogins = [select id from Analytics_Login__c where date__c = yesterday limit 1];
                if(listOfLogins.isEmpty()) {
                    BatchAdoptionAnalytics adoptionJob = new BatchAdoptionAnalytics();
                    Database.executeBatch(adoptionJob, 500);
                    
                    // Send Social Analytics records to AWS
                    BatchPushAnalyticsData analyticsjob = new BatchPushAnalyticsData('carousel_content', true);
                    Database.executeBatch(analyticsjob, 500);
                }
            }
    }
     
    private void initAnalyticsData (List<People__c> peopleList){
    
    		peopleIdSet = new Set<Id>();
        peopleUserIdSet = new Set<String>();
        soqlLikeUserIdSet = new Set<String>();
        userToPeopleMap = new Map<ID,ID>(); 
        peopleToBookMarkGivenMap = new Map<ID,Integer>();
        peopleToBookMarkReceivedMap = new Map<ID,Integer>();
        peopleToMentionMap = new Map<ID,Integer>();
        peopleToFeedItemMap = new Map<ID,Integer>();
        peopleToReplyReceivedMap = new Map<ID,Integer>();
        peopleToReplyMadeMap = new Map<ID,Integer>();
        peopleToFollowingMap = new Map<ID,Integer>();
        peopleToFollowerMap = new Map<ID,Integer>();
        peopleToLikeGivenMap = new Map<ID,Integer>();
        peopleToLikeReceivedMap = new Map<ID,Integer>();
        peopleToShareGivenMap = new Map<ID,Integer>();
        peopleToShareReceivedMap = new Map<ID,Integer>();
        peopleToContentMap = new Map<ID,Integer>();
        peopleToProfileViewMap = new map<ID,Integer>();
        List<Analytics_Top_People__c> pplAnalyticsList = new List<Analytics_Top_People__c>();
        
        for(People__c pplObj : peopleList) {
            userToPeopleMap.put(pplObj.user__c,pplObj.id);
            soqlLikeUserIdSet.add('%'+pplObj.user__c+'%');
            peopleIdSet.add(pplObj.Id);
            peopleUserIdSet.add(pplObj.user__c);
        }   
        
        // Calculate bookmark                                                                
        calculateBookmark(peopleIdSet);
        
        // calculate mentions for user
        peopleToMentionMap = calculateMentions(peopleIdSet);
        
        // calculate number of posts for user
        peopleToFeedItemMap = calculatePosts(peopleUserIdSet,userToPeopleMap);
		
        // Replies received count
		calculateReplyGot(peopleUserIdSet,userToPeopleMap);
        
        // calculate Entity Suubscription count
        calculateEntitySubscription(peopleUserIdSet,userToPeopleMap);                                       
        
        // Calculate Likes count                                                
        calculateLike(peopleIdSet);
		
        // Share received count                                                               
        calculateShare(peopleIdSet);
		
        // Content published 
        calculateContentPublished(peopleIdSet);
        
        //Profile View
        calculateProfileView(peopleIdSet);
		
		
		map<ID,ID>mapPeopleIdAnalyticsID = new map<ID,ID>();
		for(Analytics_Top_People__c atp : [select id, People__c from Analytics_Top_People__c where People__c IN: peopleIdSet AND Date__c =: startdate]){
			mapPeopleIdAnalyticsID.put(atp.People__c, atp.ID);
		}
    
        Analytics_Top_People__c analyticsPeopleObj;                                             
        for(People__c pplObj : peopleList) {
            
			if(mapPeopleIdAnalyticsID.containsKey(pplObj.ID)){
				analyticsPeopleObj = new Analytics_Top_People__c(ID = mapPeopleIdAnalyticsID.get(pplObj.ID));
				analyticsPeopleObj.Sync_Status__c = null;
			}else{
				analyticsPeopleObj = new Analytics_Top_People__c();
			}
            analyticsPeopleObj.People__c = pplObj.id;
            analyticsPeopleObj.Date__c = startdate;
            if (peopleToBookMarkGivenMap.get(pplObj.id) != NULL){
                analyticsPeopleObj.Bookmarks_Made__c = peopleToBookMarkGivenMap.get(pplObj.id);
            } else {
            	analyticsPeopleObj.Bookmarks_Made__c = 0;
            }
            
            if (peopleToBookMarkReceivedMap.get(pplObj.id) != NULL){
                analyticsPeopleObj.Bookmarks_Received__c = peopleToBookMarkReceivedMap.get(pplObj.id);
            } else {
            	analyticsPeopleObj.Bookmarks_Received__c = 0;
            }
            
            if (peopleToContentMap.get(pplObj.id) != NULL){
                analyticsPeopleObj.Content_Published__c = peopleToContentMap.get(pplObj.id);
            } else {
            	analyticsPeopleObj.Content_Published__c = 0;
            }
            
            if (peopleToMentionMap.get(pplObj.id) != NULL){
                analyticsPeopleObj.Feed_Mentions__c = peopleToMentionMap.get(pplObj.id);
            } else {
            	analyticsPeopleObj.Feed_Mentions__c = 0;
            } 
            
            if (peopleToFollowerMap.get(pplObj.id) != NULL){
                analyticsPeopleObj.Followers__c = peopleToFollowerMap.get(pplObj.id);
            } else {
            	analyticsPeopleObj.Followers__c = 0;
            }
            
            if (peopleToFollowingMap.get(pplObj.id) != NULL){
                analyticsPeopleObj.Following__c = peopleToFollowingMap.get(pplObj.id);
            } else {
            	analyticsPeopleObj.Following__c = 0;
            }
            
            if (peopleToLikeGivenMap.get(pplObj.id) != NULL){
                analyticsPeopleObj.Likes_Made__c = peopleToLikeGivenMap.get(pplObj.id);
            } else {
            	analyticsPeopleObj.Likes_Made__c = 0;
            }
            
            if (peopleToLikeReceivedMap.get(pplObj.id) != NULL){
                analyticsPeopleObj.Likes_Received__c = peopleToLikeReceivedMap.get(pplObj.id);
            } else {
            	analyticsPeopleObj.Likes_Received__c = 0;
            }
            
            if (peopleToFeedItemMap.get(pplObj.id) != NULL){
                analyticsPeopleObj.Posts__c = peopleToFeedItemMap.get(pplObj.id);
            } else {
            	analyticsPeopleObj.Posts__c = 0;
            }
            
            if (peopleToReplyMadeMap.get(pplObj.id) != NULL){
                analyticsPeopleObj.Replies_Made__c = peopleToReplyMadeMap.get(pplObj.id);
            } else {
            	analyticsPeopleObj.Replies_Made__c = 0;
            }
            
            if (peopleToReplyReceivedMap.get(pplObj.id) != NULL){
                analyticsPeopleObj.Replies_Received__c = peopleToReplyReceivedMap.get(pplObj.id);
            } else {
            	analyticsPeopleObj.Replies_Received__c = 0;
            }
            
            if (peopleToShareGivenMap.get(pplObj.id) != NULL){
                analyticsPeopleObj.Shares_Made__c = peopleToShareGivenMap.get(pplObj.id);
            } else {
            	analyticsPeopleObj.Shares_Made__c = 0;
            }
            
            if (peopleToShareReceivedMap.get(pplObj.id) != NULL){
                analyticsPeopleObj.Shares_Received__c = peopleToShareReceivedMap.get(pplObj.id);
            } else {
            	analyticsPeopleObj.Shares_Received__c = 0;
            }
            
            if(peopleToProfileViewMap.containsKey(pplObj.id)){
            	analyticsPeopleObj.Views_Received__c = peopleToProfileViewMap.get(pplObj.id);
            }else{
            	analyticsPeopleObj.Views_Received__c = 0;
            }
            pplAnalyticsList.add(analyticsPeopleObj);
        }

        List<Schema.SObjectField> fieldList = new List<Schema.SObjectField> {
            Analytics_Top_People__c.Sync_Status__c,
            Analytics_Top_People__c.People__c,
            Analytics_Top_People__c.Date__c,
            Analytics_Top_People__c.Bookmarks_Made__c,
            Analytics_Top_People__c.Bookmarks_Received__c,
            Analytics_Top_People__c.Content_Published__c,
            Analytics_Top_People__c.Feed_Mentions__c,
            Analytics_Top_People__c.Followers__c,
            Analytics_Top_People__c.Following__c,
            Analytics_Top_People__c.Likes_Made__c,
            Analytics_Top_People__c.Likes_Received__c,
            Analytics_Top_People__c.Posts__c,
            Analytics_Top_People__c.Replies_Made__c,
            Analytics_Top_People__c.Replies_Received__c,
            Analytics_Top_People__c.Shares_Made__c,
            Analytics_Top_People__c.Shares_Received__c,
            Analytics_Top_People__c.Views_Received__c
        };
        
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().upsertAsUser(pplAnalyticsList, fieldList);
    }
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private void calculateBookmark(Set<Id> peopleIdSet){
    	Integer tempCount = 0;
		
		List<Bookmark__c> bookmarkList = [SELECT Id,People__c,Bookmark_Receiver__c FROM Bookmark__c WHERE (People__c IN : peopleIdSet OR Bookmark_Receiver__c IN : peopleIdSet) AND (createdDate >=: startDateTime AND createdDate <: endDateTime) AND Is_Deleted__c = false];
        for (Bookmark__c bm : bookmarkList){
            tempCount = 0;
            if (peopleToBookMarkGivenMap.containsKey(bm.people__c)){
                tempCount = peopleToBookMarkGivenMap.get(bm.people__c)+1;
                peopleToBookMarkGivenMap.put(bm.people__c,tempCount);
            } else {
                peopleToBookMarkGivenMap.put(bm.people__c,1);
            }
			
            if(peopleToBookMarkReceivedMap.containsKey(bm.Bookmark_Receiver__c)){
				tempCount = 0;
				tempCount = peopleToBookMarkReceivedMap.get(bm.Bookmark_Receiver__c)+1;
				peopleToBookMarkReceivedMap.put(bm.Bookmark_Receiver__c,tempCount);
			} else {
				peopleToBookMarkReceivedMap.put(bm.Bookmark_Receiver__c,1);
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
    private Map<ID,Integer> calculateMentions(Set<Id> peopleIdSet){
    	
    	Integer tempCount = 0;
    	Map<ID,Integer> peopleToMentionMap = new Map<ID,Integer>();
    	
    	List<App_Notification__c> notificationList = [SELECT Id,Sent_To__c FROM App_Notification__c 
	                                                    WHERE Sent_To__c IN : peopleIdSet  
	                                                    AND Sub_Type__c = 'Mention' AND Is_Deleted__c = false
	                                                    AND (CreatedDate >=: startDateTime AND CreatedDate <: endDateTime)];
	        
        
        for (App_Notification__c notiObj : notificationList){
			
	    	tempCount = 0;
            if (peopleToMentionMap.containsKey(notiObj.Sent_To__c)){
                tempCount = peopleToMentionMap.get(notiObj.Sent_To__c)+1;
                peopleToMentionMap.put(notiObj.Sent_To__c,tempCount);
            } else {
                peopleToMentionMap.put(notiObj.Sent_To__c,1);
            }
        }
        return peopleToMentionMap;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private Map<ID,Integer> calculatePosts(Set<String> peopleUserIdSet,Map<ID,ID> userToPeopleMap){
    	
    	Integer tempCount = 0;
    	Map<ID,Integer> peopleToFeedItemMap = new Map<ID,Integer>();
    	Map<String,String> feedItemToCreatedByMap = new Map<String,String>();
    	ID peopleId; 
    	
    	//UserFeed
	    String userFeedQuery = 'SELECT Id, createdById,parent.type FROM FeedItem WHERE createdById IN : peopleUserIdSet'+
	    					' AND parent.type =\'User\' '+
	    					' And type!=\'TrackedChange\' AND (createdDate >=: startDateTime AND createdDate <: endDateTime)';
	    if(SimpplrContext.isCommunitiesEnabled){
	    	userFeedQuery = userFeedQuery + ' AND (NetworkScope=\'AllNetworks\' OR NetworkScope=null)';
	    } 
	    userFeedQuery = userFeedQuery + ' LIMIT 15000';
	    List<FeedItem> userFeedItemList = Database.query(userFeedQuery);
	    
        for (FeedItem feedItemObj : userFeedItemList){
            tempCount = 0;
            if (userToPeopleMap.get(feedItemObj.createdById) != NULL ){
                peopleId = userToPeopleMap.get(feedItemObj.createdById);
                if (peopleToFeedItemMap.containsKey(peopleId)){
                    tempCount = peopleToFeedItemMap.get(peopleId)+1;
                    peopleToFeedItemMap.put(peopleId,tempCount);
                } else {
                    peopleToFeedItemMap.put(peopleId,1);
                }
            }
        }
        
        //GroupFeed
        String groupFeedQuery = 'SELECT Id, createdById,parent.type FROM FeedItem WHERE createdById IN : peopleUserIdSet'+
	    					' AND parent.type =\'CollaborationGroup\' '+
	    					' And type!=\'TrackedChange\' AND (createdDate >=: startDateTime AND createdDate <: endDateTime)';
	    if(SimpplrContext.isCommunitiesEnabled){
	    	groupFeedQuery = groupFeedQuery + ' AND (NetworkScope=\'AllNetworks\' OR NetworkScope=null)';
	    } 
	    groupFeedQuery = groupFeedQuery + ' LIMIT 15000';
	    List<FeedItem> groupFeedItemList = Database.query(groupFeedQuery);
	    
        for (FeedItem feedItemObj : groupFeedItemList){
            tempCount = 0;
            if (userToPeopleMap.get(feedItemObj.createdById) != NULL ){
                peopleId = userToPeopleMap.get(feedItemObj.createdById);
                if (peopleToFeedItemMap.containsKey(peopleId)){
                    tempCount = peopleToFeedItemMap.get(peopleId)+1;
                    peopleToFeedItemMap.put(peopleId,tempCount);
                } else {
                    peopleToFeedItemMap.put(peopleId,1);
                }
            }
        }
        
        //ContentFeed 
        String contentFeedParentType = PageContext.namespacePrefix + 'Simpplr_Content__c';
        Set<String> ignoredfeedItemTypes = new Set<String>{'TrackedChange','LinkPost'};
        String contentFeedQuery = 'SELECT Id, createdById,parent.type FROM FeedItem WHERE createdById IN : peopleUserIdSet'+
	    					' AND parent.type =:contentFeedParentType '+
	    					' And type!=:ignoredfeedItemTypes AND (createdDate >=: startDateTime AND createdDate <: endDateTime)';
	    if(SimpplrContext.isCommunitiesEnabled){
	    	contentFeedQuery = contentFeedQuery + ' AND (NetworkScope=\'AllNetworks\' OR NetworkScope=null)';
	    } 
	    contentFeedQuery = contentFeedQuery + ' LIMIT 15000';
	    List<FeedItem> contentFeedItemList = Database.query(contentFeedQuery);
	    
        for (FeedItem feedItemObj : contentFeedItemList){
            tempCount = 0;
            if (userToPeopleMap.get(feedItemObj.createdById) != NULL ){
                peopleId = userToPeopleMap.get(feedItemObj.createdById);
                if (peopleToFeedItemMap.containsKey(peopleId)){
                    tempCount = peopleToFeedItemMap.get(peopleId)+1;
                    peopleToFeedItemMap.put(peopleId,tempCount);
                } else {
                    peopleToFeedItemMap.put(peopleId,1);
                }
            }
        }
        
        return peopleToFeedItemMap;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private void calculateReplyGot(Set<String> peopleUserIdSet,Map<ID,ID> userToPeopleMap){
    	
    	Integer tempCount = 0;
		ID peopleId;
    	Set<String> feedItemIdSet = new Set<String>();
		Set <String> newUsersSet = new Set<String>();
    	Map<ID,ID> feedItemToCreatedByMap = new Map<ID,ID>();
		
		// query for reply received and reply made count
		List<FeedComment> feedCommentList = new List<FeedComment>();
		String queryForFeedCommentList = 'SELECT Id,FeedItemId,CreatedById FROM FeedComment '+
												'WHERE createdById IN : peopleUserIdSet '+
												'AND (createdDate >=: startDateTime AND createdDate <: endDateTime)';
		if(SimpplrContext.isCommunitiesEnabled){
			queryForFeedCommentList = queryForFeedCommentList+' and feeditemid in (select id from feeditem where networkscope = null or networkscope = \'allnetworks\')';
		}
		feedCommentList = Database.query(queryForFeedCommentList);
		
        for (FeedComment fc : feedCommentList){ 
        	feedItemIdSet.add(fc.FeedItemId);
			
			//Calculate Replies made
            if (userToPeopleMap.containsKey(fc.createdById)){
                peopleId = userToPeopleMap.get(fc.createdById);
                if (peopleToReplyMadeMap.containsKey(peopleId)){
					tempCount = 0;
                    tempCount = peopleToReplyMadeMap.get(peopleId)+1;
                    peopleToReplyMadeMap.put(peopleId,tempCount);
                } else {
                    peopleToReplyMadeMap.put(peopleId,1);
                }
            }
        }
		
        List<FeedItem> feedCommentsFeedItemList = [SELECT Id, createdById FROM FeedItem WHERE Id IN : feedItemIdSet];
        
        for (FeedItem feedItemObj : feedCommentsFeedItemList){
        	feedItemToCreatedByMap.put(feedItemObj.Id,feedItemObj.createdById);
        	if (!userToPeopleMap.containsKey(feedItemObj.createdById)){
        		newUsersSet.add(feedItemObj.createdById);
        	}
        }	
        
        List<People__c> newPeopleList = [SELECT id, user__c FROM People__c WHERE user__c IN : newUsersSet];
        for(People__c pplObj : newPeopleList) {
            userToPeopleMap.put(pplObj.user__c,pplObj.id);
        }
        
        ID feedItemCreatorId;
        for (FeedComment fc : feedCommentList){
			
			//Calculate Replies received
	        if (feedItemToCreatedByMap.containskey(fc.FeedItemId)){
	        	feedItemCreatorId = feedItemToCreatedByMap.get(fc.FeedItemId);
	        	if (userToPeopleMap.containsKey(feedItemToCreatedByMap.get(fc.FeedItemId))){
	                peopleId = userToPeopleMap.get(feedItemCreatorId);
	                if (peopleToReplyReceivedMap.containsKey(peopleId)){
						tempCount = 0;
	                    tempCount = peopleToReplyReceivedMap.get(peopleId)+1;
	                    peopleToReplyReceivedMap.put(peopleId,tempCount);
	                } else {
	                    peopleToReplyReceivedMap.put(peopleId,1);
	                }
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
	private void calculateEntitySubscription(Set<String> peopleUserIdSet,Map<ID,ID> userToPeopleMap){
    	
    	Integer tempCount = 0;
    	ID peopleId;
    	
		// Query to Calcualte how many people a user is following and followers 
		List<EntitySubscription> entitySubscriptionList = new List<EntitySubscription>();
		String queryForEntitySubscriptionList = 'SELECT Id,ParentId,SubscriberId FROM EntitySubscription '+
														'WHERE (SubscriberId IN : peopleUserIdSet OR ParentId IN : peopleUserIdSet) '+
														'AND (createdDate >=: startDateTime AND createdDate <: endDateTime)';
		if(SimpplrContext.isCommunitiesEnabled){
			queryForEntitySubscriptionList = queryForEntitySubscriptionList+ ' and NetworkId = null';
		}
		entitySubscriptionList = Database.query(queryForEntitySubscriptionList);
			
        for (EntitySubscription es : entitySubscriptionList){
            if (userToPeopleMap.containsKey(es.SubscriberId)){
                peopleId = userToPeopleMap.get(es.SubscriberId);
                if (peopleToFollowingMap.containsKey(peopleId)){
                	tempCount = 0;
                    tempCount = peopleToFollowingMap.get(peopleId)+1;
                    peopleToFollowingMap.put(peopleId,tempCount);
                } else {
                    peopleToFollowingMap.put(peopleId,1);
                }
            }
            
            if (userToPeopleMap.containsKey(es.ParentId)){ 
                peopleId = userToPeopleMap.get(es.ParentId); 
                if (peopleToFollowerMap.containsKey(peopleId)){
                	tempCount = 0;
                    tempCount = peopleToFollowerMap.get(peopleId)+1;
                    peopleToFollowerMap.put(peopleId,tempCount);
                } else {
                    peopleToFollowerMap.put(peopleId,1);
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
	private void calculateLike(Set<Id> peopleIdSet){
    	
    	Integer tempCount = 0;
	    // Query to fetch like made and like received
	    List<Like__c> likeList = [SELECT Id,People__c,Like_Receiver__c FROM Like__c WHERE (People__c IN : peopleIdSet OR Like_Receiver__c IN : peopleIdSet) AND (createdDate >=: startDateTime AND createdDate <: endDateTime)];
																	
        for (Like__c likeObj : likeList){
            if (peopleToLikeReceivedMap.containsKey(likeObj.Like_Receiver__c)){
            	tempCount = 0;
                tempCount = peopleToLikeReceivedMap.get(likeObj.Like_Receiver__c)+1;
                peopleToLikeReceivedMap.put(likeObj.Like_Receiver__c,tempCount);
            } else {
                peopleToLikeReceivedMap.put(likeObj.Like_Receiver__c,1);
            }
            
            if (peopleToLikeGivenMap.containsKey(likeObj.People__c)){
            	tempCount = 0;
                tempCount = peopleToLikeGivenMap.get(likeObj.People__c)+1;
                peopleToLikeGivenMap.put(likeObj.People__c,tempCount);
            } else {
                peopleToLikeGivenMap.put(likeObj.People__c,1);
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
	private void calculateShare(Set<Id> peopleIdSet){
    	
    	Integer tempCount = 0;
    	// Query to fetch share made and share received                                                        
	    List<Share__c> shareList = [SELECT Id,People__c,Share_Receiver__c FROM Share__c WHERE (People__c IN : peopleIdSet OR Share_Receiver__c IN : peopleIdSet) AND (createdDate >=: startDateTime AND createdDate <: endDateTime)];
        for (Share__c shareObj : shareList){
            if (peopleToShareReceivedMap.containsKey(shareObj.Share_Receiver__c)){
            	tempCount = 0;
                tempCount = peopleToShareReceivedMap.get(shareObj.Share_Receiver__c)+1;
                peopleToShareReceivedMap.put(shareObj.Share_Receiver__c,tempCount);
            } else {
                peopleToShareReceivedMap.put(shareObj.Share_Receiver__c,1);
            }
            
            if (peopleToShareGivenMap.containsKey(shareObj.People__c)){
            	tempCount = 0;
                tempCount = peopleToShareGivenMap.get(shareObj.People__c)+1;
                peopleToShareGivenMap.put(shareObj.People__c,tempCount);
            } else {
                peopleToShareGivenMap.put(shareObj.People__c,1);
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
	private void calculateContentPublished(Set<Id> peopleIdSet){
    	
    	Integer tempCount = 0;
    	
        List<Simpplr_Content__c> contentList = [SELECT Id,Primary_Author__c FROM Simpplr_Content__c 
                                                    WHERE Primary_Author__c IN : peopleIdSet 
                                                    And Status__c='Approved'
                                                    AND (Publish_Start_DateTime__c >=: startDateTime AND Publish_Start_DateTime__c <: endDateTime)];
        for (Simpplr_Content__c contObj : contentList){
            tempCount = 0;
            if (peopleToContentMap.containsKey(contObj.Primary_Author__c)){
                tempCount = peopleToContentMap.get(contObj.Primary_Author__c)+1;
                peopleToContentMap.put(contObj.Primary_Author__c,tempCount);
            } else {
                peopleToContentMap.put(contObj.Primary_Author__c,1);
            }
        }
    }
    
    private void calculateProfileView(Set<Id> peopleIdSet){
    	Integer tempCount = 0;
    	
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1', peopleIdSet);
        soqlParamMap.put('soqlParam2', startDateTime);
        soqlParamMap.put('soqlParam3', endDateTime);
        String socialAnlytcsQuery = 'select id, Page_Name__c,People_Profile__c from Simpplr_Social_Analytics__c where People_Profile__c IN :soqlParam1 and Page_Name__c=\'Profile\' AND (createdDate >=: soqlParam2 AND createdDate <: soqlParam3)';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<Simpplr_Social_Analytics__c> socialAnalyticsList = (List<Simpplr_Social_Analytics__c>)SIMPESAPI.accessController().queryAsUser(socialAnlytcsQuery, soqlParamMap);
		for(Simpplr_Social_Analytics__c sa: socialAnalyticsList){
			tempCount = 0;
			if(peopleToProfileViewMap.containsKey(sa.People_Profile__c)){
				tempCount = peopleToProfileViewMap.get(sa.People_Profile__c)+1;
				peopleToProfileViewMap.put(sa.People_Profile__c, tempCount);
			}else{
				peopleToProfileViewMap.put(sa.People_Profile__c, 1);
			}
		}
    }
}