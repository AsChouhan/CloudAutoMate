public with sharing class BatchSocialCampaignAnalytics implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.stateful{
	
	private static final List<Integer> SYNC_STATUS_SENT = new List<Integer> {1,3,5};
	private String FACEBOOK = 'Facebook';
	private String TWITTER = 'Twitter';
	private String LINKEDIN = 'Linkedin';
	private Exception exceptionDetailsObj;
	String recordType;
	DateTime startDateTime;
	DateTime endDateTime;
	Date startDate;
	Date endDate;
	List<Object> analyticWrapperList;
	
	public BatchSocialCampaignAnalytics (String recordType, Date dateArg){
		startDate = dateArg;
		endDate = dateArg.addDays(1);
		this.recordType = recordType;
		
		startDateTime = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day(), 0, 0, 0);  
		endDateTime = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day(), 0, 0, 0);	
	}
	
	public Database.QueryLocator start(Database.BatchableContext BC){
		String query;
		
		if('initAnalyticsData'.equalsIgnoreCase(recordType)){
        query = 'SELECT Id, Social_Campaign__c, External_Post_Id__c, Network_Shared__c, People__c, Total_Shares__c, Total_Likes__c,  CreatedDate '+
        		' FROM Social_Campaign_Share__c WHERE Network_Shared__c = \'Twitter\' AND (Social_Campaign__r.Is_Active__c = true OR CreatedDate = LAST_N_DAYS:7) AND Social_Campaign__r.Is_Deleted__c = false ';
		
		} else if('sendSocialCampaignData'.equalsIgnoreCase(recordType)){
			query = 'SELECT Id, Audience__c, Facebook_Share_Enabled__c, LinkedIn_Share_Enabled__c, Total_Facebook_Share_Count__c, ' + 
					' Total_LinkedIn_Share_Count__c, Total_Twitter_Share_Count__c, Twitter_Share_Enabled__c, URL__c, CreatedDate, ' +
					' Is_Active__c, Is_Deleted__c ' +
					' FROM Social_Campaign__c  ';
					
			List<Package_Upgrade_History__c> uhList=[select id, createddate from Package_Upgrade_History__c order by createddate desc limit 1];
    		DateTime cutOffTime = DateTime.now().addDays(-3);
    		if(!uhList.isEmpty() && uhList[0].createddate < cutOffTime) {
    			query += ' where  (LastModifiedDate = LAST_N_DAYS:365 or LastModifiedDate=today) ';    			
    		}
		
		} else if('sendSocialCampaignAnlyticsData'.equalsIgnoreCase(recordType)){
			query = 'select Id, Date__c, Likes__c, Shares__c, Social_Campaign_Share__c, Sync_Status__c, Social_Campaign_Share__r.Network_Shared__c,  Social_Campaign_Share__r.Social_Campaign__c ' + 
					' from Analytics_Social_Campaign__c where Sync_Status__c !=:SYNC_STATUS_SENT ';
		}
		
		return Database.getQueryLocator(query);
    }
    
    //limit to 50
    public void execute(Database.BatchableContext BC, List<sObject> listOfsObject){
    	
    	try{
    		if('initAnalyticsData'.equalsIgnoreCase(recordType)){
		    	Set<Id> peopleIdSet = new Set<Id>();
		    	List<Social_Campaign_Share__c> campaignShareList = (List<Social_Campaign_Share__c>)listOfsObject;
		    	for(Social_Campaign_Share__c campaignShareObj : campaignShareList){
		    		peopleIdSet.add(campaignShareObj.people__c);
		    	}
		    	//Get Map of networkType and AccessToken per people
		    	Map<Id, Map<String,String>> mapOfPeopleIdToNetworkAccessToken = getMapOfPeopleIdToNetworkAccessToken(peopleIdSet);
		    	//Map of yesterday social campaign anal record
		    	Map<String, AnalyticsData> mapOfPostIdToPastAnalytics = getMapOfPostIdToPastAnalytics(campaignShareList);
		    	List<Analytics_Social_Campaign__c> campShareAnalList = new List<Analytics_Social_Campaign__c>();
		    	for(Social_Campaign_Share__c campaignShareObj : campaignShareList){
		    		if(mapOfPeopleIdToNetworkAccessToken.get(campaignShareObj.People__c) != null){
		    			String authString =(mapOfPeopleIdToNetworkAccessToken.get(campaignShareObj.People__c)).get(campaignShareObj.Network_Shared__c);
		    			List<String> authStringTokens = String.isNotBlank(authString)? authString.split(':-:'):new List<String>();
		    			String accessToken = authStringTokens.isEmpty() == false ? authStringTokens[0]:'';
		    			String accessTokenSecret = authStringTokens.isEmpty() == false && authStringTokens.size() == 2? authStringTokens[1]:'';
						if(String.isNotBlank(accessToken)){
							//gets share and like wrapper object per post
							AnalyticsData analyticsDataObj = getCampaignAnalytics(accessToken, accessTokenSecret, campaignShareObj);
							//gets new analytics records to be inserted
							if(analyticsDataObj.likeCount > 0 || analyticsDataObj.shareCount > 0){
								Analytics_Social_Campaign__c campShareAnalObj= getCampShareAnalRecordTobeInsertedList(campaignShareObj.id , mapOfPostIdToPastAnalytics.get(campaignShareObj.External_Post_Id__c), analyticsDataObj);
								if(campShareAnalObj.Likes__c > 0 || campShareAnalObj.Shares__c > 0) {
									campShareAnalList.add(campShareAnalObj);
								}
							}
						}
		    		}	
		    	}
		    	
		    	if(campShareAnalList.isEmpty() == false){

					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
					SIMPESAPI.accessController().insertAsUser(campShareAnalList, new List<Schema.SObjectField>{
						Analytics_Social_Campaign__c.Likes__c,
						Analytics_Social_Campaign__c.Shares__c,
						Analytics_Social_Campaign__c.Date__c,
						Analytics_Social_Campaign__c.Social_Campaign_Share__c
					});
		    	}
    		} else if('sendSocialCampaignAnlyticsData'.equalsIgnoreCase(recordType)) {
    			PushAnalyticsDataHelper analyticsHandler = new PushAnalyticsDataHelper();
    			analyticsHandler.sendAnalticsSocialCampaignListToAWS(listOfsObject);
    		} else if('sendSocialCampaignData'.equalsIgnoreCase(recordType)){
    			PushAnalyticsDataHelper analyticsHandler = new PushAnalyticsDataHelper();
    			analyticsHandler.sendSocialCampaignListToAWS(listOfsObject);
    		}
    	}catch(Exception ex) {
    		exceptionDetailsObj =  ex;
    		throw ex;
   		}
    }
    
    public void finish(Database.BatchableContext BC){
    	
    	if (!Test.isRunningTest()) {
	    	if('initAnalyticsData'.equalsIgnoreCase(recordType)){
			    AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
				Boolean canStartNextBatch = false;
				if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
					canStartNextBatch = true;
				} else {
					Utility.sendExceptionEmail('BatchSocialCampaignAnalytics', exceptionDetailsObj);
				}
			
				BatchSocialCampaignAnalytics campaignBatchJob = new BatchSocialCampaignAnalytics('sendSocialCampaignData', startDate);
		    	DataBase.executeBatch(campaignBatchJob, 500);
		    			
	    	} else if('sendSocialCampaignData'.equalsIgnoreCase(recordType)){
				BatchSocialCampaignAnalytics campaignBatchJob = new BatchSocialCampaignAnalytics('sendSocialCampaignAnlyticsData', startDate);
				DataBase.executeBatch(campaignBatchJob, 500);
	
	    	} else if('sendSocialCampaignAnlyticsData'.equalsIgnoreCase(recordType)){
				BatchPullNewsletterTrackerData job = new BatchPullNewsletterTrackerData();
		    	DataBase.executeBatch(job, 1);
	    	}
    	}
    }

    @testVisible
    private  Analytics_Social_Campaign__c getCampShareAnalRecordTobeInsertedList(Id campShareId, AnalyticsData pastAnalyticsDataObj, AnalyticsData analyticsDataObj){
    	Analytics_Social_Campaign__c campShareAnalObj = new Analytics_Social_Campaign__c();
    	campShareAnalObj.Likes__c = pastAnalyticsDataObj != null ? (analyticsDataObj.likeCount - pastAnalyticsDataObj.likeCount):analyticsDataObj.likeCount;
    	campShareAnalObj.Shares__c = pastAnalyticsDataObj != null ? (analyticsDataObj.shareCount - pastAnalyticsDataObj.shareCount):analyticsDataObj.shareCount;
    	campShareAnalObj.Date__c = (Date.today()).addDays(-1);//TBD
    	campShareAnalObj.Social_Campaign_Share__c = campShareId;
    	
    	return campShareAnalObj;
    }
    
    @testVisible
    private Map<String, AnalyticsData> getMapOfPostIdToPastAnalytics(List<Social_Campaign_Share__c> campaignShareList){
    	
    	Map<String, AnalyticsData> mapOfPostIdToPastAnalytics = new Map<String, AnalyticsData>();
    	for(Social_Campaign_Share__c campShareObj : campaignShareList){
    		AnalyticsData analDataObj = new AnalyticsData();
    		analDataObj.shareCount = campShareObj.Total_Shares__c != null ? (campShareObj.Total_Shares__c).intValue():0;
    		analDataObj.likeCount = campShareObj.Total_Likes__c != null ? (campShareObj.Total_Likes__c).intValue():0;
    		mapOfPostIdToPastAnalytics.put(campShareObj.External_Post_Id__c, analDataObj);
    	}
    	
		return mapOfPostIdToPastAnalytics;
    }
    @testVisible
    private AnalyticsData getCampaignAnalytics(String accessToken, String accessTokenSecret, Social_Campaign_Share__c campShareObj){
    	AnalyticsData analyticsData = new AnalyticsData();
    	String campaignNetworkType = campShareObj.Network_Shared__c;
    	String externalPostId = campShareObj.External_Post_Id__c;
    	String campaignId = campShareObj.Social_Campaign__c;
    	if(FACEBOOK.equalsIgnoreCase(campaignNetworkType)){
    		analyticsData.shareCount = getFBShareCount(accessToken, externalPostId);
    		analyticsData.likeCount = getFBLikeCount(accessToken, externalPostId);
    		analyticsData.networkType = FACEBOOK;
    	} else if(TWITTER.equalsIgnoreCase(campaignNetworkType)){
    		if(String.isNotBlank(accessTokenSecret)){
	    		AnalyticsData adObj = getTwitterAnalytics(accessToken, accessTokenSecret, externalPostId);
	    		analyticsData.shareCount = adObj.shareCount;
	    		analyticsData.likeCount = adObj.likeCount;
	    		analyticsData.networkType = TWITTER;
    		}
    	} 
    	analyticsData.externalPostId = externalPostId;
    	analyticsData.campaignId = campaignId;
    	return analyticsData;
    }
    
    @testVisible
    private Integer getFBShareCount(string accessToken, String externalPostId){
    	Integer shareCount = 0;
    	String endPoint = IntegrationConstants.FACEBOOK_POSTING_ENDPOINT+externalPostId+'?fields=shares';
    	String authorisationString = 'Bearer '+accessToken;
    	HttpResponse resp = new HttpResponse();
    	if(Test.isRunningTest() == false){
    		resp = Utility.getJsonResponseFromExternalSystem(IntegrationConstants.GET_REQUEST_TYPE, endpoint, authorisationString, null);
    	} else {
    		resp.setBody('{"shares":{"count":3},"id":"112588529488242_121311325282629"}');
    		resp.setStatusCode(200);
    	}
    	if(resp.getStatusCode()==200){
    		Map<String, Object> responseObjMap = (Map<String,Object>)JSON.deserializeUntyped(resp.getBody());
		Map<String,Object> shareObj = (Map<String,Object>)responseObjMap.get('shares');
    		shareCount = shareObj != null ? (Integer)shareObj.get('count') : 0;
    	}
    	return shareCount;
    }
    
    @testVisible
    private Integer getFBLikeCount(string accessToken, String externalPostId){
    	Integer likeCount = 0;
    	String endPoint = IntegrationConstants.FACEBOOK_POSTING_ENDPOINT+externalPostId+'/likes?summary=true';
    	String authorisationString = 'Bearer '+accessToken;
    	HttpResponse resp = new HttpResponse();
    	if(Test.isRunningTest() == false){
    		resp = Utility.getJsonResponseFromExternalSystem(IntegrationConstants.GET_REQUEST_TYPE, endpoint, authorisationString, null);
    	} else {
    		resp.setBody('{"data":[{"id":"112588529488242","name":"Open Graph Test User"}],"paging":{"cursors":{"before":"MTEyNTg4NTI5NDg4MjQy","after":"MTEyNTg4NTI5NDg4MjQy"}},"summary":{"total_count":1,"can_like":true,"has_liked":true}}');
    		resp.setStatusCode(200);
    	}
    	if(resp.getStatusCode()==200){
    		Map<String, Object> responseObjMap = (Map<String,Object>)JSON.deserializeUntyped(resp.getBody());
		Map<String,Object> summaryObj = (Map<String,Object>)responseObjMap.get('summary');
    		likeCount = summaryObj != null ? (Integer)summaryObj.get('total_count') : 0;
    	}
    	return likeCount;
    }
    
    @testVisible
    private AnalyticsData getTwitterAnalytics(String accessToken, String accessTokenSecret,String externalPostId){
    	AnalyticsData adObj = new AnalyticsData();
    	adObj.likeCount = 0;
	   	adObj.shareCount = 0;
    	String endPoint = IntegrationConstants.TWITTER_GET_TWEET_DETAILS+externalPostId;
    	Map<String, String> authtokensMap = new Map<String, String>();
		authtokensMap.put('token', accessToken);
		authtokensMap.put('secret', accessTokenSecret);
		authtokensMap.put('twitterPostId', externalPostId);
		TwitterService ts = new TwitterService();
		String authorisationString = ts.generateTwitterAuthorisationString(authtokensMap);
    	HttpResponse resp = new HttpResponse();
    	if(Test.isRunningTest() == false){
    		resp = Utility.getJsonResponseFromExternalSystem(IntegrationConstants.GET_REQUEST_TYPE, endpoint, authorisationString, null);
    	} else {
    		resp.setBody('{"created_at":"Mon Sep 25 10:24:34 +0000 2017","id":912261536982327300,"id_str":"912261536982327296","text":"https://t.co/NdjSo2YLJI Anubhav Timeline #page @salesforce","truncated":false,"entities":{"hashtags":[{"text":"page","indices":[41,46]}],"symbols":[],"user_mentions":[{"screen_name":"salesforce","name":"Salesforce","id":33612317,"id_str":"33612317","indices":[47,58]}],"urls":[{"url":"https://t.co/NdjSo2YLJI","expanded_url":"https://www.urlencoder.org/","display_url":"urlencoder.org","indices":[0,23]}]},"source":"<a href=\"https://abc.com\" rel=\"nofollow\">Test Anubhav</a>","in_reply_to_status_id":null,"in_reply_to_status_id_str":null,"in_reply_to_user_id":null,"in_reply_to_user_id_str":null,"in_reply_to_screen_name":null,"user":{"id":908651116484730900,"id_str":"908651116484730882","name":"Anubhav Gupta","screen_name":"anubhavgupta25","location":"","description":"","url":null,"entities":{"description":{"urls":[]}},"protected":false,"followers_count":1,"friends_count":0,"listed_count":0,"created_at":"Fri Sep 15 11:18:02 +0000 2017","favourites_count":1,"utc_offset":19800,"time_zone":"New Delhi","geo_enabled":false,"verified":false,"statuses_count":12,"lang":"en","contributors_enabled":false,"is_translator":false,"is_translation_enabled":false,"profile_background_color":"F5F8FA","profile_background_image_url":null,"profile_background_image_url_https":null,"profile_background_tile":false,"profile_image_url":"http://abs.twimg.com/sticky/default_profile_images/default_profile_normal.png","profile_image_url_https":"https://abs.twimg.com/sticky/default_profile_images/default_profile_normal.png","profile_link_color":"1DA1F2","profile_sidebar_border_color":"C0DEED","profile_sidebar_fill_color":"DDEEF6","profile_text_color":"333333","profile_use_background_image":true,"has_extended_profile":false,"default_profile":true,"default_profile_image":true,"following":false,"follow_request_sent":false,"notifications":false,"translator_type":"none"},"geo":null,"coordinates":null,"place":null,"contributors":null,"is_quote_status":false,"retweet_count":2,"favorite_count":1,"favorited":true,"retweeted":true,"possibly_sensitive":false,"possibly_sensitive_appealable":false,"lang":"tl"}');
    		resp.setStatusCode(200);	
    	}
    	if(resp.getStatusCode()==200){
	    	Map<String, Object> responseObjMap = (Map<String,Object>)JSON.deserializeUntyped(resp.getBody());
	    	adObj.likeCount = (Integer)responseObjMap.get('favorite_count');
	    	adObj.shareCount = (Integer)responseObjMap.get('retweet_count');
    	}
    	return adObj;
    }
    
    @testVisible
    private Map<Id, Map<String,String>> getMapOfPeopleIdToNetworkAccessToken(Set<Id> peopleIdSet){
    	Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', peopleIdSet);
		soqlParamMap.put('soqlParam2', DateTime.now());
    	String queryStr = 'SELECT Access_Token__c, Access_Token_Secret__c, App_Integration__r.Name, People__c '+
    					 ' FROM People_Integration__c WHERE  People__c IN:soqlParam1 AND Access_Token_Expiration_Datetime__c >=:soqlParam2 AND Is_Deleted__c = false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<People_Integration__c> peopleIntList = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);			 
    	Map<Id, Map<String, String>> mapOfPeopleIdToNetworkAccessToken = new Map<Id, Map<String, String>>();
    	
    	for(People_Integration__c peopleIntObj : peopleIntList){
    		if(mapOfPeopleIdToNetworkAccessToken.get(peopleIntObj.People__c) ==  null){
    			mapOfPeopleIdToNetworkAccessToken.put(peopleIntObj.People__c, new Map<String,String>());
    		}
    		mapOfPeopleIdToNetworkAccessToken.get(peopleIntObj.People__c).put(peopleIntObj.App_Integration__r.Name,peopleIntObj.Access_Token__c+':-:'+peopleIntObj.Access_Token_Secret__c);
    	}
    	return mapOfPeopleIdToNetworkAccessToken;
    }
    @testVisible
    private class AnalyticsData{
    	Integer likeCount;
    	Integer shareCount;
    	String networkType;
    	String externalPostId;
    	String campaignid;
    }
}