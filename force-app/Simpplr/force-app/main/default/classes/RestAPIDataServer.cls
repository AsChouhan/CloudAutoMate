public with sharing class RestAPIDataServer extends DataServer{
	
	//public transient string jsonString {set; get;}
	private transient Map<String, String> urlParams;
    private transient String matchingString  {set; get;}
    private transient String timeStamp  {set; get;}
    private transient String resultValue  {set; get;}
    private transient String error  {set; get;}
	private transient String loggedInUserId {set; get;}

    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public override void handleRequest() {
    	logger.logDebug('RestAPIDataServer----entered handleRequest----');
    	if(String.isBlank(SimpplrContext.packageName) || UserInfo.isCurrentUserLicensed(SimpplrContext.packageName)) {
    		urlParams = mapOfRequestParameters;
	    	loggedInUserId = UserContext.id;
	    	matchingString = '';
	    	matchingString = '';
	    	error = '';
	    	resultString = '{"status": "error","message": "Invalid Parameters passed."}';
	    	try {
	        	if(urlParams.containsKey('object')) {
	        		if(urlParams.get('object').equalsIgnoreCase('sites')) {
	        			if(urlParams.containsKey('filter')) {
	        				matchingString = urlParams.get('filter').trim();    
	        			}
	        			response = getMatchingSitesRW(matchingString, loggedInUserId);
	        		} else if(urlParams.get('object').equalsIgnoreCase('users')) {
	        			if(urlParams.containsKey('filter')) {
	        				matchingString = urlParams.get('filter').trim();    
	        			}
	        			response = getMatchingUsersRW(matchingString);
	        		} else if(urlParams.get('object').equalsIgnoreCase('notification')) {
	        			if(urlParams.containsKey('timeStamp')) {
	        				timeStamp = urlParams.get('timeStamp');    
	        			}
	        			response = getNotification(timeStamp);
	        		} else if(urlParams.get('object').equalsIgnoreCase('notificationCount')) {
	        			response = getNotificationCount();
	        		} else {
	        			error = 'Invalid parameters passed. Please check the parameters and try again.'; 
	        		}        	
	        	} else {
	        		error = 'Invalid parameters passed. Please check the parameters and try again.'; 
	        	}        	
	        } catch (Exception ex) {
	        	logger.logError('The server encountered an error while processing your request.',ex);
	            error = 'The server encountered an error while processing your request. ' + ex.getMessage();    
	        }
    	} else {
    		error = 'You do not have license to use Simpplr.'; 
    	}
    	
    	
        if(String.isBlank(error)) {
            resultString = '{"status": "success","data": ' + resultValue + ',"error": ""}';
        } else {
            resultString = '{"status": "failed","data": "[]","error": "'+ error + '"}';
        }
    }
    
    
	@TestVisible
	private ResponseWrapper getMatchingSitesRW(string matchingString, String loggedInUserId) {
		logger.logDebug('RestAPIDataServer.getMatchingSites()----matchingString----'+matchingString);
		logger.logDebug('RestAPIDataServer.getMatchingSites()----loggedInUserId----'+loggedInUserId);
		String retVal = '';
		Schema.DescribeSObjectResult d = CollaborationGroup.sObjectType.getDescribe();
		Map<String, Schema.SobjectField> cgFieldMap = d.fields.getMap();
		String query = 'Select Id, Name, CollaborationType From CollaborationGroup WHERE isArchived = false AND ';
		if(String.isNotBlank(matchingString)) {
			query = query + ' name like \'%' + String.escapeSingleQuotes(matchingString) +'%\' AND ';
		}
		query = query + ' (CollaborationType = \'public\' or CollaborationType = \'private\') AND ' 
			+ ' id in (SELECT CollaborationGroupID FROM CollaborationGroupMember WHERE ' 
			+ ' MemberId = \'' + loggedInUserId + '\') order by Name ASC';
		if (cgFieldMap.containsKey('networkid')) {
			query += ' And NetworkId = null ';
		}
		List<CollaborationGroup> lstCollaborationGroup = Database.query(query);
		List<Map<String, String>> lstMap = new List<Map<String, String>>();
		
        for(CollaborationGroup currentCollaborationGroup : lstCollaborationGroup) {
        	Map<String, String> groupDataMap = new Map<String, String>();
        	groupDataMap.put('id', currentCollaborationGroup.id);
        	groupDataMap.put('name', currentCollaborationGroup.name.replace('"', '&quot;'));
        	groupDataMap.put('collaborationtype', currentCollaborationGroup.CollaborationType);
            lstMap.add(groupDataMap);
        }
        ResponseWrapper localResult = buildResponseWrapper('success', 'Site response created successfully', lstMap); 		
        logger.logDebug('RestAPIDataServer.getMatchingSites()----return value----'+JSON.serialize(localResult));
		return localResult;
	}
	
	@TestVisible
	private ResponseWrapper getMatchingUsersRW(string matchingString) {
		logger.logDebug('RestAPIDataServer.getMatchingUsersRW()----matchingString----'+matchingString);
		String retVal = '';
		String query = 'select id, name, username, email from user where isactive = true and usertype = \'standard\'';
		if(String.isNotBlank(matchingString)) {
			query = query + ' AND name like \'%' + String.escapeSingleQuotes(matchingString) +'%\'';
		}
		query = query + ' order by name LIMIT 50000';
        List<User> lstUser = Database.query(query);
        List<Map<String, String>> lstMap = new List<Map<String, String>>();
        for(User currentUser : lstUser) {
        	Map<String, String> groupDataMap = new Map<String, String>();
        	groupDataMap.put('id', currentUser.id);
        	groupDataMap.put('name', currentUser.name.replace('"', '&quot;'));
        	groupDataMap.put('username', currentUser.username);
        	groupDataMap.put('publicphotourl', '');
        	groupDataMap.put('email', currentUser.email);
            lstMap.add(groupDataMap);           
        }
        ResponseWrapper localResult = buildResponseWrapper('success', 'User list created successfully', lstMap); 		
        logger.logDebug('RestAPIDataServer.getMatchingUsersRW()----return value----'+JSON.serialize(localResult));
		return localResult;
	}
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    @TestVisible
	private ResponseWrapper getNotification(String timeStamp) {
    	
    	List<NotificationListingWrapper> listOfNotificationWrapper = new List<NotificationListingWrapper>();
		NotificationListingWrapper.PaginationWrapper notificationPaginatorObj = new NotificationListingWrapper.PaginationWrapper();
    	if(SimpplrContext.SimpplrDesktopNotificationAllowed){
	    	List<App_Notification__c> notificationList = new List<App_Notification__c>();
	    	Datetime sinceTime;
	    	String peopleId = UserContext.peopleId;
	    	String BASE_QUERY = ' Select Type__c, Submitter_Comment__c,Sub_Type__c, Simpplr_Site__c, Simpplr_Site__r.Landing_Page__c, Status__c, ' +
								' Sent_By__r.User__r.smallPhotoUrl, Sent_By__r.Full_Name__c, Sent_By__c,Sent_to__c, Object_Type__c, Content__r.Type__c, Content__r.Title__c, ' +
								' Object_Id__c, Is_Read__c, Is_New__c, Id, GUID__c, CreatedDate,Created_DateTime__c, ' +
								' Action_By__r.User__r.smallPhotoUrl, Action_By__r.Full_Name__c, Action_By__c ' + 
								' From App_Notification__c  WHERE Is_Deleted__c = false AND Sent_to__c=:peopleId AND Is_Deleted__c=false And (Simpplr_Site__c = null OR (Simpplr_Site__r.Is_active__c = true And Simpplr_Site__r.Show_In_Simpplr__c = true)) '; 
	    	
	    	String queryStr =  BASE_QUERY; 
			
			if (!String.isBlank(timeStamp)) {			
				sinceTime = DateTime.newInstance(long.valueOf(timeStamp));			
	    	} else {
	    		sinceTime = DateTime.now().addMinutes(-5);
	    	}
	    	queryStr += ' And CreatedDate >=:sinceTime';
			
			queryStr += ' Order By CreatedDate desc';
			notificationList = Database.query(queryStr);
			notificationList = getPullNotiBasedOnUserPref(notificationList);
			if (notificationList.size() > 0){
				for (App_Notification__c notificationObj : notificationList) {
	    			NotificationListingWrapper notificationListingWrapperObj = new NotificationListingWrapper();
	    			notificationListingWrapperObj = ObjectToWrapperAdapter.notificationToWrapper(notificationObj,'dn');
	    			if(String.isBlank(notificationListingWrapperObj.user.img)) {
	    				notificationListingWrapperObj.user.img = notificationListingWrapperObj.user.name.Substring(0,1).toUpperCase() + '.png';
	    			}
	    			listOfNotificationWrapper.add(notificationListingWrapperObj);
	    		}
			}
	        notificationPaginatorObj.listOfItems.addAll(listOfNotificationWrapper);
			notificationPaginatorObj.viewAllLink = PageContext.getPageURL(Pages.Notifications);
	    	notificationPaginatorObj.totalCounts = new NotificationListingWrapper.countWrapper();
	    	notificationPaginatorObj.totalCounts.activity = 0;
	    	notificationPaginatorObj.totalCounts.actionable = 0;    	
	    	notificationPaginatorObj.newCounts = new NotificationListingWrapper.countWrapper();
	    	notificationPaginatorObj.newCounts.activity = 0;
	    	notificationPaginatorObj.newCounts.actionable = 0;
    	}
		ResponseWrapper localResult = buildResponseWrapper('success', 'Notification response successfully', notificationPaginatorObj); 
		return localResult;
	}
	
	/**
	* 
	* Purpose:  getNotificationCount: gets the notification count for a user
	* Parameters:
	*      parameter_name -- NA
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    @TestVisible
	private ResponseWrapper getNotificationCount() {
		ResponseWrapper localResult = null;
		
		try {
			String peopleId = UserContext.peopleId;
			Map<String, Object> notificationCountMap = new Map<String, Object>();
	    	notificationCountMap.put('totalCounts', NotificationContentProvider.getTotalNotificationCount(peopleId));
	    	notificationCountMap.put('newCounts', NotificationContentProvider.getNewNotificationCount(peopleId, 'REST'));
	    	
	    	localResult = buildResponseWrapper('success', 'Notification Count response has been retrieved successfully.', notificationCountMap);
		}catch(Exception ex){
			logger.logError('Could not retrieve notification count data',ex);
        	localResult = buildResponseWrapper('error', null, null);
		} 
		
		return localResult;
	}
	
	private static List<App_Notification__c> getPullNotiBasedOnUserPref(List<App_Notification__c> listOfSN) {
		Set<String> targetPeopleSet = new Set<String>();
		List<App_Notification__c> snList = new List<App_Notification__c>();
		for(App_Notification__c listOfSNObj: listOfSN) {
			targetPeopleSet.add(listOfSNObj.Sent_to__c);
		}
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', targetPeopleSet);
		String query = 'SELECT Id,people__r.Full_Name__c, Desktop_Allow_Notifications__c, Desktop_Comments_After_Me__c, Desktop_Comments_On_My_Post__c, Desktop_Comments_On_Post_I_Like__c, Desktop_Content_Submitted_For_Moderation__c, Desktop_Endorses_Me__c, Desktop_Follows_Me__c, Desktop_Like_My_Post_Or_Comment__c, Desktop_Mentions_Me__c, Desktop_My_Content_Approved__c, Desktop_My_Content_Like__c, Desktop_My_Content_Post__c, Desktop_My_Content_Rejected__c, Desktop_My_Content_Share__c, Desktop_Posts_On_My_Profile__c, Desktop_Private_Site_Membership_Requests__c, Desktop_Shares_My_Post__c, Desktop_PrivateSiteMembership_Response__c, Desktop_Content_Submission_Response__c, Allow_Simpplr_Emails__c FROM People_Preference__c where People__c IN : soqlParam1 ';	
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<People_Preference__c> peoplePrefList = (List<People_Preference__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
		Map<String,People_Preference__c> peoplePrefMap = new Map<String,People_Preference__c>();
		for(People_Preference__c peoplePref : peoplePrefList) {
			peoplePrefMap.put(peoplePref.people__c,peoplePref);
		}
		for(App_Notification__c noti : listOfSN){
			Boolean sendNotiCheck = false;
			if(peoplePrefMap.get(noti.Sent_To__c) != null){
				if(peoplePrefMap.get(noti.Sent_To__c).Desktop_Allow_Notifications__c){
					if(noti.sub_type__c.equalsIgnoreCase('follow')){
						if(peoplePrefMap.get(noti.Sent_To__c).Desktop_Follows_Me__c) {
							sendNotiCheck = true;	
						}
		    		} else if(noti.sub_type__c.equalsIgnoreCase('Endorse')){
		    			if(peoplePrefMap.get(noti.Sent_To__c).Desktop_Endorses_Me__c) {
							sendNotiCheck = true;	
						}
		    		} else if(noti.sub_type__c.equalsIgnoreCase('update')){
		    			if(noti.status__c.equalsIgnoreCase('Approved')|| noti.status__c.equalsIgnoreCase('Rejected')) {
		    				if(noti.Object_Type__c.equalsIgnorecase('CollaborationGroupMemberRequest')){
		    					if(peoplePrefMap.get(noti.Sent_To__c).Desktop_PrivateSiteMembership_Response__c) {
									sendNotiCheck = true;	
								}
		    				} else {
		    					if(peoplePrefMap.get(noti.Sent_To__c).Desktop_My_Content_Rejected__c) {
									sendNotiCheck = true;	
								}
		    				}
		    			} 
		    		} else if(noti.sub_type__c.equalsIgnoreCase('post')){
		    			if(String.isBlank(noti.Simpplr_Site__c)){
		    				if(peoplePrefMap.get(noti.Sent_To__c).Desktop_Posts_On_My_Profile__c) {
								sendNotiCheck = true;	
							}
		    			} else {
		    				if(peoplePrefMap.get(noti.Sent_To__c).Desktop_My_Content_Post__c) {
								sendNotiCheck = true;	
							}
		    			}
		    		} else if(noti.sub_type__c.equalsIgnoreCase('like')){
		    				if(noti.Object_type__c.equalsIgnoreCase('FeedItem') || noti.Object_type__c.equalsIgnoreCase('FeedComment')) {
		    					if(peoplePrefMap.get(noti.Sent_To__c).Desktop_Like_My_Post_Or_Comment__c) {
									sendNotiCheck = true;	
								}			
		    				} else {
		   						if(peoplePrefMap.get(noti.Sent_To__c).Desktop_My_Content_Like__c) {
									sendNotiCheck = true;	
								}
		   					} 			
		    		} else if(noti.sub_type__c.equalsIgnoreCase('comment')){
		    			if(noti.Submitter_Comment__c.containsIgnoreCase('also replied')){
		    				if(peoplePrefMap.get(noti.Sent_To__c).Desktop_Comments_After_Me__c) {
								sendNotiCheck = true;	
							}
		    			} else if(noti.Submitter_Comment__c.containsIgnoreCase('you liked')) {
			    			if(peoplePrefMap.get(noti.Sent_To__c).Desktop_Comments_On_Post_I_Like__c) {
								sendNotiCheck = true;	
							}
		    			} else {
		    				if(peoplePrefMap.get(noti.Sent_To__c).Desktop_Comments_On_My_Post__c) {
								sendNotiCheck = true;	
							}
		    			}
		    		} else if(noti.sub_type__c.equalsIgnoreCase('mention')){
		    			if(peoplePrefMap.get(noti.Sent_To__c).Desktop_Mentions_Me__c) {
							sendNotiCheck = true;	
						}
		    		} else if(noti.sub_type__c.equalsIgnoreCase('share')){
		    			if(noti.Object_Type__c.equalsIgnoreCase('FeedItem')) {
		    				if(peoplePrefMap.get(noti.Sent_To__c).Desktop_Shares_My_Post__c) {
								sendNotiCheck = true;	
							}	
		    			} else {
		    				if(peoplePrefMap.get(noti.Sent_To__c).Desktop_My_Content_Share__c) {
								sendNotiCheck = true;	
							}
		    			}
		    			
		    		} else if(noti.sub_type__c.equalsIgnoreCase('review')){
		    			if(noti.Object_Type__c.equalsIgnoreCase('CollaborationGroupMemberRequest')) {
		    				if(peoplePrefMap.get(noti.Sent_To__c).Desktop_Private_Site_Membership_Requests__c) {
								sendNotiCheck = true;	
							}	
		    			} else {
		    				if(peoplePrefMap.get(noti.Sent_To__c).Desktop_Content_Submitted_For_Moderation__c) {
								sendNotiCheck = true;	
							}
		    			}
		    			
		    		}
				}
	    		if(sendNotiCheck) {
	    			snList.add(noti);
	    		}
			}
		}
		return snList;
	}
}