public with sharing class PushAnalyticsDataHelper {

	private static final String organizationId = UserInfo.getOrganizationId().subString(0,15);  
	private static final String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';  
    public void sendAnalyticsAdoptionListToAWS(sObject[] listOfsObject){
		
		List<AnalyticsWrapper.AnalyticsAdoption> analyticWrapperList = new List<AnalyticsWrapper.AnalyticsAdoption>();
		AnalyticsWrapper.AnalyticsAdoption analyticsObj;

		for (Analytics_Adoption__c aa : (List<Analytics_Adoption__c>)listOfsObject) {
			analyticsObj = new AnalyticsWrapper.AnalyticsAdoption();
    		analyticsObj.record_date = aa.Date__c;
			analyticsObj.desktop = Integer.valueOf(aa.Desktop__c);
			analyticsObj.desktop_app = Integer.valueOf(aa.DesktopApp__c);
			analyticsObj.is_active = aa.Is_Active__c;
			analyticsObj.is_contributer = aa.Is_Contributor__c;
			analyticsObj.is_observer = aa.Is_Observer__c;
			analyticsObj.is_participant = aa.Is_Participant__c;
			analyticsObj.used_native_ios = aa.Has_Used_Native_IOS_App__c;
			analyticsObj.used_native_android = aa.Has_Used_Native_Android_App__c;
			analyticsObj.used_hybrid_ios = aa.Has_Used_Hybrid_IOS_App__c;
			analyticsObj.used_hybrid_android = aa.Has_Used_Hybrid_Android_App__c;
			analyticsObj.mobile = Integer.valueOf(aa.Mobile__c);
			analyticsObj.mobile_app = Integer.valueOf(aa.MobileApp__c);
			analyticsObj.page_views = Integer.valueOf(aa.Page_Views__c);
			analyticsObj.content_views = Integer.valueOf(aa.Content_Views__c);
			analyticsObj.total_logins = Integer.valueOf(aa.Total_Logins__c);
			analyticsObj.people_id = aa.People__c;
			analyticsObj.user = aa.People__r.User_Hash__c;
			analyticsObj.record_id = aa.Id;
			
			if (aa.Sync_Status__c == null) {
				aa.Sync_Status__c = 1;

			} else if (aa.Sync_Status__c > 5) {
				aa.Sync_Status__c = 5;
			
			} else {
				aa.Sync_Status__c = aa.Sync_Status__c + 1;
			}

			if (String.isNotBlank(aa.People__c)) {
				analyticsObj.org_id_people_id = organizationId + String.valueOf(aa.People__c).subString(0,15);
				analyticWrapperList.add(analyticsObj);
			}

		}

		sendDataToAWS('analytics_adoption', analyticWrapperList);
		update listOfsObject;
    }
    
    public void sendAdoptionEmailListToAWS(sObject[] listOfsObject) {
		List<AnalyticsWrapper.AdoptionEmail> analyticWrapperList = new List<AnalyticsWrapper.AdoptionEmail>();
		AnalyticsWrapper.AdoptionEmail analyticsObj;

		for (Adoption_Email__c aa : (List<Adoption_Email__c>)listOfsObject) {
			analyticsObj = new AnalyticsWrapper.AdoptionEmail();
			analyticsObj.email_month = Integer.valueOf(aa.Adoption_Email_Month__c);
			analyticsObj.email_json = aa.Adoption_Email_JSON__c;
		    analyticsObj.record_id = aa.Id;

		    if (aa.Sync_Status__c == null) {
		    	aa.Sync_Status__c = 1;
		    
			} else if (aa.Sync_Status__c > 5) {
		    	aa.Sync_Status__c = 5;
		    
			} else {
		    	aa.Sync_Status__c = aa.Sync_Status__c + 1;
		    }

		    analyticWrapperList.add(analyticsObj);
		}
		
		sendDataToAWS('analytics_adoption_email', analyticWrapperList);
		update listOfsObject;
    }

    public void sendAnalticsContentCountListToAWS(sObject[] listOfsObject){
    	List<AnalyticsWrapper.AnalyticsContentCount> analyticWrapperList = new List<AnalyticsWrapper.AnalyticsContentCount>();
    	AnalyticsWrapper.AnalyticsContentCount analyticsObj;
		
		for (Analytics_Content_Count__c aa : (List<Analytics_Content_Count__c>)listOfsObject){
			analyticsObj = new AnalyticsWrapper.AnalyticsContentCount();
			analyticsObj.record_date = aa.Date__c;
		    analyticsObj.albums = Integer.valueOf(aa.Albums__c);
		    analyticsObj.blogs = Integer.valueOf(aa.Blogs__c);
		    analyticsObj.bookmarks = Integer.valueOf(aa.Bookmarks__c);
		    analyticsObj.events = Integer.valueOf(aa.Events__c);
		    analyticsObj.likes = Integer.valueOf(aa.Likes__c);
		    analyticsObj.pages = Integer.valueOf(aa.Pages__c);
		    analyticsObj.posts = Integer.valueOf(aa.Posts__c);
		    analyticsObj.replies = Integer.valueOf(aa.Replies__c);
		    analyticsObj.shares = Integer.valueOf(aa.Shares__c);
		    analyticsObj.site = aa.Site__c;
		    analyticsObj.views = Integer.valueOf(aa.Views__c);
		    analyticsObj.record_id = aa.Id;
		    
			if (String.isNotBlank(aa.Site__c)) {
		    		analyticsObj.org_id_site_id = organizationId + String.valueOf(aa.Site__c).subString(0,15);
		    }

		    if (aa.Sync_Status__c == null) {
	    		aa.Sync_Status__c = 1;
		    
			} else if (aa.Sync_Status__c > 5) {
		    	aa.Sync_Status__c = 5;
		    
			} else {
		    	aa.Sync_Status__c = aa.Sync_Status__c + 1;
		    }

		    analyticWrapperList.add(analyticsObj);
		}
		
		sendDataToAWS('analytics_content_count', analyticWrapperList);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id,Analytics_Content_Count__c>((List<Analytics_Content_Count__c>)listOfsObject), new List<Schema.SObjectField>{
			Analytics_Content_Count__c.Sync_Status__c
		});
    }

    public void sendAnalticsFeedCountListToAWS(sObject[] listOfsObject){
    	List<AnalyticsWrapper.AnalyticsFeedCount> analyticWrapperList = new List<AnalyticsWrapper.AnalyticsFeedCount>();
    	AnalyticsWrapper.AnalyticsFeedCount analyticsObj;
		
		for (Analytics_Feed_Count__c aa : (List<Analytics_Feed_Count__c>)listOfsObject){
			analyticsObj = new AnalyticsWrapper.AnalyticsFeedCount();
			analyticsObj.record_date = aa.Date__c;
		    analyticsObj.likes = Integer.valueOf(aa.Likes__c);
		    analyticsObj.posts = Integer.valueOf(aa.Posts__c);
		    analyticsObj.replies = Integer.valueOf(aa.Replies__c);
		    analyticsObj.shares = Integer.valueOf(aa.Shares__c);
		    analyticsObj.site = aa.Site__c;
		    analyticsObj.record_id = aa.Id;
		    
			if(String.isNotBlank(aa.Site__c)) {
		    		analyticsObj.org_id_site_id = organizationId + String.valueOf(aa.Site__c).subString(0,15);
		    }

    		if(aa.Sync_Status__c == null) {
	    		aa.Sync_Status__c = 1;
		    
			} else if (aa.Sync_Status__c > 5) {
		    	aa.Sync_Status__c = 5;
		    
			} else {
		    	aa.Sync_Status__c = aa.Sync_Status__c + 1;
		    }

			analyticWrapperList.add(analyticsObj);
		}
		
		sendDataToAWS('analytics_feed_count', analyticWrapperList);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id,Analytics_Feed_Count__c>((List<Analytics_Feed_Count__c>)listOfsObject), new List<Schema.SObjectField>{
			Analytics_Feed_Count__c.Sync_Status__c
		});
    }
         
    public void sendAnalticsLoginListToAWS(sObject[] listOfsObject){
    		List<AnalyticsWrapper.AnalyticsLogin> analyticWrapperList = new List<AnalyticsWrapper.AnalyticsLogin>();
    		AnalyticsWrapper.AnalyticsLogin analyticsObj;
		for(Analytics_Login__c aa : (List<Analytics_Login__c>)listOfsObject){
			analyticsObj = new AnalyticsWrapper.AnalyticsLogin();
		    analyticsObj.record_date = aa.Date__c;
		    analyticsObj.average_logins_per_user = aa.Average_logins_per_user__c;
		    analyticsObj.desktop = Integer.valueOf(aa.Desktop__c);
		    analyticsObj.desktop_app = Integer.valueOf(aa.DesktopApp__c);
		   	analyticsObj.mobile = Integer.valueOf(aa.Mobile__c);
		    analyticsObj.mobile_app = Integer.valueOf(aa.MobileApp__c);
		    analyticsObj.page_views = Integer.valueOf(aa.Page_Views__c);
		    analyticsObj.total_active_salesforce_user = Integer.valueOf(aa.Total_Active_Salesforce_User__c);
		    analyticsObj.total_simpplr_users = Integer.valueOf(aa.Total_Simpplr_Users__c);
		    analyticsObj.unique_logins = Integer.valueOf(aa.Unique_logins__c);
		    analyticsObj.users_logged_in = Integer.valueOf(aa.Users_Logged_In__c);
		    analyticsObj.total_logins = Integer.valueOf(aa.Total_Logins__c);
		    analyticsObj.likes = Integer.valueOf(aa.Likes__c);
		    analyticsObj.posts = Integer.valueOf(aa.Posts__c);
		    analyticsObj.replies = Integer.valueOf(aa.Replies__c);
		    analyticsObj.shares = Integer.valueOf(aa.Shares__c);
		    analyticsObj.content_views = Integer.valueOf(aa.Content_Views__c);
    			analyticsObj.hybrid_android_app = Integer.valueOf(aa.Hybrid_Android_App__c);
    			analyticsObj.hybrid_ios_app = Integer.valueOf(aa.Hybrid_IOS_App__c);
    			analyticsObj.native_android_app = Integer.valueOf(aa.Native_Android_App__c);
    			analyticsObj.native_ios_app = Integer.valueOf(aa.Native_IOS_App__c);
		    analyticsObj.record_id = aa.Id;
		    if(aa.Sync_Status__c == null) {
	    		aa.Sync_Status__c = 1;
		    } else if (aa.Sync_Status__c > 5) {
		    	aa.Sync_Status__c = 5;
		    } else {
		    	aa.Sync_Status__c = aa.Sync_Status__c + 1;
		    }
    
			analyticWrapperList.add(analyticsObj);
		}
		
		sendDataToAWS('analytics_login', analyticWrapperList);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<id,Analytics_Login__c>((List<Analytics_Login__c>)listOfsObject),new List<Schema.SObjectField>{Analytics_Login__c.Sync_Status__c});
    }

    public void sendAnalticsPageViewListToAWS(sObject[] listOfsObject){
    		List<AnalyticsWrapper.AnalyticsPageView> analyticWrapperList = new List<AnalyticsWrapper.AnalyticsPageView>();
    		AnalyticsWrapper.AnalyticsPageView analyticsObj;
		for(Analytics_PageView__c aa : (List<Analytics_PageView__c>)listOfsObject){
			analyticsObj = new AnalyticsWrapper.AnalyticsPageView();
		    analyticsObj.record_date = aa.Date__c;
		    analyticsObj.desktop = Integer.valueOf(aa.Desktop__c);
		    analyticsObj.desktop_app = Integer.valueOf(aa.DesktopApp__c);
		    analyticsObj.mobile = Integer.valueOf(aa.Mobile__c);
		    analyticsObj.mobile_app = Integer.valueOf(aa.MobileApp__c);
		    analyticsObj.record_id = aa.Id;
		    if(aa.Sync_Status__c == null) {
	    		aa.Sync_Status__c = 1;
		    } else if (aa.Sync_Status__c > 5) {
		    	aa.Sync_Status__c = 5;
		    } else {
		    	aa.Sync_Status__c = aa.Sync_Status__c + 1;
		    }
			analyticWrapperList.add(analyticsObj);
		}
		
		sendDataToAWS('analytics_page_view', analyticWrapperList);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id,Analytics_PageView__c>((List<Analytics_PageView__c>)listOfsObject), new List<Schema.SObjectField>{
			Analytics_PageView__c.Sync_Status__c
		});
    }

    public void sendAnalticsSearchResultSelectListToAWS(sObject[] listOfsObject){
    		List<AnalyticsWrapper.AnalyticsSearchResultSelect> analyticWrapperList = new List<AnalyticsWrapper.AnalyticsSearchResultSelect>();
    		AnalyticsWrapper.AnalyticsSearchResultSelect analyticsObj;
		for(Analytics_Search_Result_Select__c aa : (List<Analytics_Search_Result_Select__c>)listOfsObject){
			analyticsObj = new AnalyticsWrapper.AnalyticsSearchResultSelect();
			analyticsObj.content = aa.Content__c;
		    analyticsObj.context = aa.Context__c;
		    analyticsObj.created_by_people = aa.Created_By_People__c;
		    if(String.isNotBlank(aa.Created_By_People__c)) {
		    	analyticsObj.org_id_created_by_people_id = organizationId + String.valueOf(aa.Created_By_People__c).subString(0,15);
		    }
		    analyticsObj.file_id = aa.File_Id__c;
		    analyticsObj.is_external = aa.Is_External__c;
		    if('user'.equalsIgnoreCase(aa.Item_Type__c) || 'person'.equalsIgnoreCase(aa.Item_Type__c)) {
		    	analyticsObj.item_type = 'people';
		    } else {
		    	analyticsObj.item_type = aa.Item_Type__c;
		    }
		    analyticsObj.people = aa.People__c;
		    analyticsObj.position = Integer.valueOf(aa.Position__c);
		    analyticsObj.score = Integer.valueOf(aa.Score__c);
		    analyticsObj.section = aa.Section__c;
		    analyticsObj.site = aa.Site__c;
		    analyticsObj.site_context = aa.Site_Context__c;
		    analyticsObj.subsection = aa.Subsection__c;
		    analyticsObj.term = aa.Term__c;
		    analyticsObj.record_id = aa.Id;
		    if(String.isNotBlank(aa.Content__c)) {
		    		analyticsObj.org_id_content_id = organizationId + String.valueOf(aa.Content__c).subString(0,15);
		    }
		    if(String.isNotBlank(aa.Site__c)) {
		    		analyticsObj.org_id_site_id = organizationId + String.valueOf(aa.Site__c).subString(0,15);
		    }
		    if(String.isNotBlank(aa.People__c)) {
		    		analyticsObj.org_id_people_id = organizationId + String.valueOf(aa.People__c).subString(0,15);
		    }
		    analyticsObj.record_date = aa.createddate.date();
    		analyticsObj.record_date_time = Utility.dateTimeStringInGMT(aa.createddate, dateTimeFormat);
		    if(aa.Sync_Status__c == null) {
	    		aa.Sync_Status__c = 1;
		    } else if (aa.Sync_Status__c > 5) {
		    	aa.Sync_Status__c = 5;
		    } else {
		    	aa.Sync_Status__c = aa.Sync_Status__c + 1;
		    }
			analyticWrapperList.add(analyticsObj);
		}
		sendDataToAWS('analytics_search_result_select', analyticWrapperList);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id,Analytics_Search_Result_Select__c>((List<Analytics_Search_Result_Select__c>)listOfsObject), new List<Schema.SObjectField>{
			Analytics_Search_Result_Select__c.Sync_Status__c
		});
    }

    public void sendAnalticsSocialCampaignListToAWS(sObject[] listOfsObject){
    		List<AnalyticsWrapper.AnalyticsSocialCampaign> analyticWrapperList = new List<AnalyticsWrapper.AnalyticsSocialCampaign>();
    		AnalyticsWrapper.AnalyticsSocialCampaign analyticsObj;
		for(Analytics_Social_Campaign__c aa : (List<Analytics_Social_Campaign__c>)listOfsObject){
			analyticsObj = new AnalyticsWrapper.AnalyticsSocialCampaign();
			analyticsObj.record_date = aa.Date__c;
		    analyticsObj.likes = Integer.valueOf(aa.Likes__c);
		    analyticsObj.shares = Integer.valueOf(aa.Shares__c);
		    analyticsObj.social_campaign_share = aa.Social_Campaign_Share__c;
		    analyticsObj.network_share = aa.Social_Campaign_Share__r.Network_Shared__c;
		    analyticsObj.social_campaign = aa.Social_Campaign_Share__r.Social_Campaign__c; 	
		    analyticsObj.record_id = aa.Id;
		    if(aa.Sync_Status__c == null) {
	    		aa.Sync_Status__c = 1;
		    } else if (aa.Sync_Status__c > 5) {
		    	aa.Sync_Status__c = 5;
		    } else {
		    	aa.Sync_Status__c = aa.Sync_Status__c + 1;
		    }
			analyticWrapperList.add(analyticsObj);
		}
		
		sendDataToAWS('analytics_social_campaign', analyticWrapperList);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<id,Analytics_Social_Campaign__c>((List<Analytics_Social_Campaign__c>)listOfsObject),new List<Schema.SObjectField>{Analytics_Social_Campaign__c.Sync_Status__c});
    }

    public void sendAnalticsTopContentListToAWS(sObject[] listOfsObject){
		List<AnalyticsWrapper.AnalyticsTopContent> analyticWrapperList = new List<AnalyticsWrapper.AnalyticsTopContent>();
		AnalyticsWrapper.AnalyticsTopContent analyticsObj;
	for(Analytics_Top_Content__c aa : (List<Analytics_Top_Content__c>)listOfsObject){
		analyticsObj = new AnalyticsWrapper.AnalyticsTopContent();
		analyticsObj.id = organizationId + String.valueOf(aa.Id).subString(0,15);
		analyticsObj.record_id = aa.Id;
		analyticsObj.content = aa.Content__c;
		analyticsObj.content_type = aa.Content__r.Type__c;
		analyticsObj.site = aa.Content__r.Site__c;
		analyticsObj.record_date = aa.Date__c;
		analyticsObj.bookmarks = Integer.valueOf(aa.Bookmarks__c);
		analyticsObj.likes = Integer.valueOf(aa.Likes__c);
		analyticsObj.is_validated = aa.is_validated__c;
		analyticsObj.is_validation_expired = aa.is_validation_expired__c;
		analyticsObj.is_validation_pending = aa.is_validation_pending__c;
		analyticsObj.popularity_score = Integer.valueOf(aa.Popularity_Score__c);
		analyticsObj.posts = Integer.valueOf(aa.Posts__c);
		analyticsObj.replies = Integer.valueOf(aa.Replies__c);
		analyticsObj.shares = Integer.valueOf(aa.Shares__c);
		analyticsObj.unuseful = Integer.valueOf(aa.Unuseful__c);
		analyticsObj.useful = Integer.valueOf(aa.Useful__c);
		analyticsObj.views = Integer.valueOf(aa.Views__c);
		if(String.isNotBlank(aa.Content__r.Site__c)) {
				analyticsObj.org_id_site_id = organizationId + String.valueOf(aa.Content__r.Site__c).subString(0,15);
		}
		if(String.isNotBlank(aa.Content__c)) {
			analyticsObj.org_id_content_id = organizationId + String.valueOf(aa.Content__c).subString(0,15);
			if(aa.Sync_Status__c == null) {
				aa.Sync_Status__c = 1;
			} else if (aa.Sync_Status__c > 5) {
				aa.Sync_Status__c = 5;
			} else {
				aa.Sync_Status__c = aa.Sync_Status__c + 1;
			}
			analyticWrapperList.add(analyticsObj);
		} else {
			aa.Sync_Status__c = 5;
		}
	}
	
	sendDataToAWS('analytics_top_content', analyticWrapperList);
	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	SIMPESAPI.accessController().updateAsUser(new Map<id,Analytics_Top_Content__c>((List<Analytics_Top_Content__c>)listOfsObject),new List<Schema.SObjectField>{
											Analytics_Top_Content__c.Sync_Status__c
										});
}

	public void sendAnalyticsTopicSuggestionDataToAWS(sObject[] listOfsObject){
		List<AIWrapper.AnalyticsTopicSuggestion> analyticTopicSuggestionWrapperList = new List<AIWrapper.AnalyticsTopicSuggestion>();
		AIWrapper.AnalyticsTopicSuggestion analyticsTopicSuggestionObj;
		List<Analytics_Topic_Suggestion__c> listOfTopicSuggestion=(List<Analytics_Topic_Suggestion__c>)listOfsObject;
		for(Analytics_Topic_Suggestion__c aa : listOfTopicSuggestion){
			analyticsTopicSuggestionObj = new AIWrapper.AnalyticsTopicSuggestion();
		    analyticsTopicSuggestionObj.id = organizationId + String.valueOf(aa.Id).subString(0,15);
		    analyticsTopicSuggestionObj.record_id = aa.Id;
			analyticsTopicSuggestionObj.content_id = aa.Content__c;
			analyticsTopicSuggestionObj.suggested_topics=(List<String>) Json.deserialize(aa.Suggested_Topics__c, Type.forName('List<String>'));
			analyticsTopicSuggestionObj.content_topics =(List<String>) Json.deserialize(aa.Content_Topics__c, Type.forName('List<String>'));
			analyticsTopicSuggestionObj.record_date = aa.Date__c;
			analyticsTopicSuggestionObj.people_id = aa.people__c;
		    if(String.isNotBlank(aa.Content__c)) {
			    analyticsTopicSuggestionObj.org_id_content_id = organizationId + String.valueOf(aa.Content__c).subString(0,15);
			    if(aa.Sync_Status__c == null) {
		    		aa.Sync_Status__c = 1;
			    } else if (aa.Sync_Status__c > 5) {
			    	aa.Sync_Status__c = 5;
			    } else {
			    	aa.Sync_Status__c = aa.Sync_Status__c + 1;
			    }
				analyticTopicSuggestionWrapperList.add(analyticsTopicSuggestionObj);
		    } else {
		    	aa.Sync_Status__c = 5;
		    }
		}
		
		sendDataToAWS('analytics_topic_suggestion', analyticTopicSuggestionWrapperList);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id, Analytics_Topic_Suggestion__c>(listOfTopicSuggestion), new List<Schema.SObjectField>{
                	 Analytics_Topic_Suggestion__c.Sync_Status__c});
    }
                    
    public void sendToAnalticsTopPeopleListToAWS(sObject[] listOfsObject){
    		List<AnalyticsWrapper.AnalyticsTopPeople> analyticWrapperList = new List<AnalyticsWrapper.AnalyticsTopPeople>();
    		AnalyticsWrapper.AnalyticsTopPeople analyticsObj;
		for(Analytics_Top_People__c aa : (List<Analytics_Top_People__c>)listOfsObject){
			analyticsObj = new AnalyticsWrapper.AnalyticsTopPeople();
		    analyticsObj.id = organizationId + String.valueOf(aa.Id).subString(0,15);
		    analyticsObj.record_id = aa.Id;
			analyticsObj.record_date = aa.Date__c;
		    analyticsObj.bookmarks_made = Integer.valueOf(aa.Bookmarks_Made__c);
		    analyticsObj.bookmarks_received = Integer.valueOf(aa.Bookmarks_Received__c);
		    analyticsObj.feed_mentions = Integer.valueOf(aa.Feed_Mentions__c);
		    analyticsObj.content_published = Integer.valueOf(aa.Content_Published__c);
		    analyticsObj.followers = Integer.valueOf(aa.Followers__c);
		    analyticsObj.following = Integer.valueOf(aa.Following__c);
		    analyticsObj.likes_made = Integer.valueOf(aa.Likes_Made__c);
		    analyticsObj.likes_received = Integer.valueOf(aa.Likes_Received__c);
		    analyticsObj.posts = Integer.valueOf(aa.Posts__c);
		    analyticsObj.replies_made = Integer.valueOf(aa.Replies_Made__c);
		    analyticsObj.replies_received = Integer.valueOf(aa.Replies_Received__c);
		    analyticsObj.shares_made = Integer.valueOf(aa.Shares_Made__c);
		    analyticsObj.shares_received = Integer.valueOf(aa.Shares_Received__c);
		    analyticsObj.views_received = Integer.valueOf(aa.Views_Received__c);
		    analyticsObj.people_id = aa.People__c;
		    if(String.isNotBlank(aa.People__c)) {
			    analyticsObj.org_id_people_id = organizationId + String.valueOf(aa.People__c).subString(0,15);
			    if(aa.Sync_Status__c == null) {
		    		aa.Sync_Status__c = 1;
			    } else if (aa.Sync_Status__c > 5) {
			    	aa.Sync_Status__c = 5;
			    } else {
			    	aa.Sync_Status__c = aa.Sync_Status__c + 1;
			    }
				analyticWrapperList.add(analyticsObj);
		    } else {
		    	aa.Sync_Status__c = 5;
		    }
		}
		sendDataToAWS('analytics_top_people', analyticWrapperList);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<id,Analytics_Top_People__c>((List<Analytics_Top_People__c>)listOfsObject),new List<Schema.SObjectField>
																	{Analytics_Top_People__c.Sync_Status__c});
    }
    
    public void sendAnalticsTopSearchListToAWS(sObject[] listOfsObject){
    		List<AnalyticsWrapper.AnalyticsTopSearch> analyticWrapperList = new List<AnalyticsWrapper.AnalyticsTopSearch>();
    		AnalyticsWrapper.AnalyticsTopSearch analyticsObj;
		for(Analytics_Top_Search__c aa : (List<Analytics_Top_Search__c>)listOfsObject){
			analyticsObj = new AnalyticsWrapper.AnalyticsTopSearch();
			analyticsObj.record_date = aa.Date__c;
		    analyticsObj.search_results_count = Integer.valueOf(aa.Search_Results_Count__c);
		    analyticsObj.search_text = aa.Search_Text__c;
		    analyticsObj.search_type = aa.Search_Type__c;
		    analyticsObj.record_id = aa.Id;
		    analyticsObj.site = aa.Site__c;
		    if(aa.Sync_Status__c == null) {
	    		aa.Sync_Status__c = 1;
		    } else if (aa.Sync_Status__c > 5) {
		    	aa.Sync_Status__c = 5;
		    } else {
		    	aa.Sync_Status__c = aa.Sync_Status__c + 1;
		    }
    
			analyticWrapperList.add(analyticsObj);
		}
		
		sendDataToAWS('analytics_top_search', analyticWrapperList);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<id,Analytics_Top_Search__c>((List<Analytics_Top_Search__c>)listOfsObject),new List<Schema.SObjectField>{Analytics_Top_Search__c.Sync_Status__c});
    }

    public void sendAnalticsTopSiteListToAWS(sObject[] listOfsObject){
    		List<AnalyticsWrapper.AnalyticsTopSite> analyticWrapperList = new List<AnalyticsWrapper.AnalyticsTopSite>();
    		AnalyticsWrapper.AnalyticsTopSite analyticsObj;
		for(Analytics_Top_Site__c aa : (List<Analytics_Top_Site__c>)listOfsObject){
			analyticsObj = new AnalyticsWrapper.AnalyticsTopSite();
		    analyticsObj.id = organizationId + String.valueOf(aa.Id).subString(0,15);
		    analyticsObj.record_id = aa.Id;
			analyticsObj.record_date = aa.Date__c;
		    analyticsObj.content_published = Integer.valueOf(aa.Content_Published__c);
		    analyticsObj.likes = Integer.valueOf(aa.Likes__c);
		    analyticsObj.members = Integer.valueOf(aa.Members__c);
		    analyticsObj.popularity_score = Integer.valueOf(aa.Popularity_Score__c);
		    analyticsObj.posts = Integer.valueOf(aa.Posts__c);
		    analyticsObj.replies = Integer.valueOf(aa.Replies__c);
		    analyticsObj.views = Integer.valueOf(aa.Views__c);
			analyticsObj.shares = Integer.valueOf(aa.Shares__c);
			analyticsObj.bookmarks = Integer.valueOf(aa.Bookmarks__c);
		    analyticsObj.content_hybrid_app_views = Integer.valueOf(aa.Content_Hybrid_App_Views__c);
		    analyticsObj.dashboard_hybrid_app_views = Integer.valueOf(aa.Dashboard_Hybrid_App_Views__c);
		    analyticsObj.dashboard_mobile_browser_views = Integer.valueOf(aa.Dashboard_Mobile_Browser_Views__c);
		    analyticsObj.content_mobile_browser_views = Integer.valueOf(aa.Content_Mobile_Browser_Views__c);
		    analyticsObj.content_web_browser_views = Integer.valueOf(aa.Content_Web_Browser_Views__c);
		    analyticsObj.dashboard_web_browser_views = Integer.valueOf(aa.Dashboard_Web_Browser_Views__c);
		    analyticsObj.site = aa.Site__c;
		    if(String.isNotBlank(aa.Site__c)) {
			    analyticsObj.org_id_site_id = organizationId + String.valueOf(aa.Site__c).subString(0,15);
			    if(aa.Sync_Status__c == null) {
		    		aa.Sync_Status__c = 1;
			    } else if (aa.Sync_Status__c > 5) {
			    	aa.Sync_Status__c = 5;
			    } else {
			    	aa.Sync_Status__c = aa.Sync_Status__c + 1;
			    }
				analyticWrapperList.add(analyticsObj);
		    } else {
		    	aa.Sync_Status__c = 5;
		    }
		}
		
		sendDataToAWS('analytics_top_site', analyticWrapperList);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id,Analytics_Top_Site__c>((List<Analytics_Top_Site__c>)listOfsObject), new List<Schema.SObjectField>{
			Analytics_Top_Site__c.Sync_Status__c
		});
    }

    public void sendAnalticsTopTopicListToAWS(sObject[] listOfsObject){
    		List<AnalyticsWrapper.AnalyticsTopTopic> analyticWrapperList = new List<AnalyticsWrapper.AnalyticsTopTopic>();
    		AnalyticsWrapper.AnalyticsTopTopic analyticsObj;
		for(Analytics_Top_Topic__c aa : (List<Analytics_Top_Topic__c>)listOfsObject){
			analyticsObj = new AnalyticsWrapper.AnalyticsTopTopic();
			analyticsObj.record_date = aa.Date__c;
			analyticsObj.followers = Integer.valueOf(aa.Followers__c);
			analyticsObj.posts = Integer.valueOf(aa.Posts__c);
			analyticsObj.comments = Integer.valueOf(aa.Comments__c);
			analyticsObj.contents = Integer.valueOf(aa.Contents__c);
		    analyticsObj.views = Integer.valueOf(aa.Views__c);
		    analyticsObj.topic_name = aa.Topic_Name__c;
		    analyticsObj.record_id = aa.Id;
		    analyticsObj.topic_id = aa.Topic_Id__c;
		    analyticsObj.org_id_topic_id = organizationId + String.valueOf(aa.Topic_Id__c).subString(0,15);
		    if(aa.Sync_Status__c == null) {
	    		aa.Sync_Status__c = 1;
		    } else if (aa.Sync_Status__c > 5) {
		    	aa.Sync_Status__c = 5;
		    } else {
		    	aa.Sync_Status__c = aa.Sync_Status__c + 1;
		    }
    
			analyticWrapperList.add(analyticsObj);
		}
		
		sendDataToAWS('analytics_top_topic', analyticWrapperList);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id,Analytics_Top_Topic__c>((List<Analytics_Top_Topic__c>)listOfsObject), new List<Schema.SObjectField>{
			Analytics_Top_Topic__c.Sync_Status__c
		});
    }
    
    public void sendSiteListToAWS(sObject[] listOfsObject){ 
    		List<AnalyticsWrapper.Site> siteWrapperList = new List<AnalyticsWrapper.Site>();
    		AnalyticsWrapper.Site siteObj;
			List<String> listOfCollaborationGroupIds = new List<String>(); 
			Set <Id> siteIdSet = new set<Id>();
			Map<Id,String> siteLayoutMap = new Map<Id,String>() ;
			for(Simpplr_Site__c aa : (List<Simpplr_Site__c>)listOfsObject){
				listOfCollaborationGroupIds.add(aa.Chatter_Group_Id__c);
				siteIdSet.add(aa.id);
				siteLayoutMap.put(aa.Id, aa.Layout__c);
			}
			Map<Id, CollaborationGroup> collaborationGroupMap =  new Map<Id, CollaborationGroup>([SELECT Id, MemberCount from CollaborationGroup where id=:listOfCollaborationGroupIds]);	
				
		for(Simpplr_Site__c aa : (List<Simpplr_Site__c>)listOfsObject){
			siteObj = new AnalyticsWrapper.Site();
			siteObj.id = organizationId + String.valueOf(aa.id).subString(0,15);
			if(collaborationGroupMap.containsKey(aa.Chatter_Group_Id__c)) {
				siteObj.member_count = Integer.valueOf(collaborationGroupMap.get(aa.Chatter_Group_Id__c).MemberCount);
			}
			siteObj.site_type = aa.Site_Type__c;
		    siteObj.site_name = aa.Name;
		    siteObj.site_id = aa.Id;
		    siteObj.is_active = aa.Is_Active__c;
		    siteObj.chatter_group_id =  aa.Chatter_Group_Id__c;
		    siteObj.is_featured  = aa.is_Featured__c;
			siteObj.is_newsletter_allowed = aa.is_Newsletter_Allowed__c;
			siteObj.is_alert_enabled = aa.is_Alert_Enabled__c;
			siteObj.is_must_read_enabled = aa.Is_Must_Read_Enabled__c;
			siteObj.has_albums = aa.has_Albums__c;
			siteObj.has_events = aa.has_Events__c;
			siteObj.has_pages = aa.has_Pages__c;
			siteObj.cover_content_document = aa.Cover_Content_Document__c;
			siteObj.title_content_document = aa.title_content_Document__c;
			siteObj.site_category = aa.site_category__c;
			siteObj.site_category_name = aa.site_Category__r.Name__c;
			siteObj.show_in_simpplr = aa.show_In_Simpplr__c;
			siteObj.landing_page = aa.landing_page__c;
			siteObj.origin = aa.origin__c;
			siteObj.site_created_date =  Utility.dateTimeStringInGMT(aa.CreatedDate, dateTimeFormat);
			siteObj.file_storage_source = aa.File_Storage_Source__c ;
			siteObj.allow_file_upload_app_permission = aa.Allow_File_Upload_App_Permission__c;
			if(siteLayoutMap !=null && siteLayoutMap.containsKey(aa.id)){
				siteObj.layout = siteLayoutMap.get(aa.id);
			}
            siteObj.is_onboarding_enabled = aa.Is_Onboarding_Enabled__c;
			siteWrapperList.add(siteObj);
		}
		
		sendDataToAWS('site', siteWrapperList);
	}
	
	public void sendTilesConfigListToAWS(sObject[] listOfsObject){ 
		List<AnalyticsWrapper.TilesConfig> tilesConfigWrapperList = new List<AnalyticsWrapper.TilesConfig>();
		AnalyticsWrapper.TilesConfig tilesConfigObj;
		
	    for(Tiles_Config__c aa : (List<Tiles_Config__c>)listOfsObject){
		    tilesConfigObj = new AnalyticsWrapper.TilesConfig();
			tilesConfigObj.id = organizationId + String.valueOf(aa.id).subString(0,15);
			tilesConfigObj.org_id = organizationId;
			tilesConfigObj.layout_column = aa.Layout_Column__c;
			tilesConfigObj.location = aa.Location__c;
			tilesConfigObj.tiles_order = aa.Order__c;
			if(String.isNotBlank(aa.People__c)) {
		    	tilesConfigObj.org_id_people_id = organizationId + String.valueOf(aa.People__c).subString(0,15);
			}
			if(String.isNotBlank(aa.Segment__c)) {
		    	tilesConfigObj.org_id_segment_id = organizationId + String.valueOf(aa.Segment__c).subString(0,15);
			}
			if(String.isNotBlank(aa.Site__c)) {
		    	tilesConfigObj.org_id_site_id = organizationId + String.valueOf(aa.Site__c).subString(0,15);
		    }
			tilesConfigObj.type = aa.Type__c;
			tilesConfigObj.variant = aa.Variant__c;
			tilesConfigObj.is_deleted = aa.Is_Deleted__c;
			tilesConfigObj.created_at = Utility.dateTimeStringInGMT(aa.CreatedDate, dateTimeFormat);
			tilesConfigObj.updated_at = Utility.dateTimeStringInGMT(aa.lastmodifieddate, dateTimeFormat);

			if(aa.Sync_Status__c == null) {
	    		aa.Sync_Status__c = 1;
		    } else if (aa.Sync_Status__c > 5) {
		    	aa.Sync_Status__c = 5;
		    } else {
		    	aa.Sync_Status__c = aa.Sync_Status__c + 1;
		    }
			tilesConfigWrapperList.add(tilesConfigObj);
		}
	
		sendDataToAWS('tiles_config', tilesConfigWrapperList);
		update listOfsObject;
	}
	
	public void sendSiteRoleListToAWS(sObject[] listOfsObject){ 
		List<AnalyticsWrapper.SiteRole> siteRoleWrapperList = new List<AnalyticsWrapper.SiteRole>();
		AnalyticsWrapper.SiteRole siteRoleObj;
		
	    for(Site_Role__c aa : (List<Site_Role__c>)listOfsObject){
		    siteRoleObj = new AnalyticsWrapper.SiteRole();
			siteRoleObj.id = organizationId + String.valueOf(aa.id).subString(0,15);
			siteRoleObj.org_id = organizationId;
			siteRoleObj.is_content_manager = aa.Is_Content_Manager__c;
			siteRoleObj.is_deleted = aa.Is_Deleted__c;
			siteRoleObj.is_manager = aa.Is_Manager__c;
			siteRoleObj.is_member = aa.Is_Member__c;
			if(String.isNotBlank(aa.People__c)) {
		    	siteRoleObj.org_id_people_id = organizationId + String.valueOf(aa.People__c).subString(0,15);
				siteRoleObj.people_id = aa.People__c;
			}
			if(String.isNotBlank(aa.Site__c)) {
		    	siteRoleObj.org_id_site_id = organizationId + String.valueOf(aa.Site__c).subString(0,15);
				siteRoleObj.site = aa.Site__c;
		    }
			if(String.isNotBlank(aa.Unique_Id1__c)) {
		    	siteRoleObj.site_id_people_id = aa.Unique_Id1__c;
		    }
			if(String.isNotBlank(aa.User__c)) {
		    	siteRoleObj.user_id = aa.User__c;
		    }

			if(aa.Sync_Status__c == null) {
	    		aa.Sync_Status__c = 1;
		    } else if (aa.Sync_Status__c > 5) {
		    	aa.Sync_Status__c = 5;
		    } else {
		    	aa.Sync_Status__c = aa.Sync_Status__c + 1;
		    }
            siteRoleObj.is_content_manager = aa.Is_Content_Manager__c;
			siteRoleWrapperList.add(siteRoleObj);
		}
	
		sendDataToAWS('site_role', siteRoleWrapperList);
		update listOfsObject;
	}
	
	public void sendContentAuditTrailListToAWS(sObject[] listOfsObject){ 
		List<AnalyticsWrapper.ContentAuditTrail> contentAuditTrailWrapperList = new List<AnalyticsWrapper.ContentAuditTrail>();
		AnalyticsWrapper.ContentAuditTrail contentAuditTrailObj;
		
	    for(Content_Audit_Trail__c aa : (List<Content_Audit_Trail__c>)listOfsObject){
		    contentAuditTrailObj = new AnalyticsWrapper.ContentAuditTrail();
			contentAuditTrailObj.id = organizationId + String.valueOf(aa.id).subString(0,15);
			contentAuditTrailObj.org_id = organizationId;
			if(aa.Action_DateTime__c != null) {
		    	contentAuditTrailObj.action_datetime = aa.Action_DateTime__c.formatGMT(dateTimeFormat);
			}
			if(String.isNotBlank(aa.Content__c)) {
				contentAuditTrailObj.org_id_content_id = organizationId + String.valueOf(aa.Content__c).subString(0,15);
			}
			contentAuditTrailObj.comment = aa.Comment__c;
			if(String.isNotBlank(aa.Action_By__c)) {
		    	contentAuditTrailObj.org_id_action_by_people_id = organizationId + String.valueOf(aa.Action_By__c).subString(0,15);
			}
			if(String.isNotBlank(aa.Dismiss_By__c)) {
		    	contentAuditTrailObj.org_id_dismiss_by_people_id = organizationId + String.valueOf(aa.Dismiss_By__c).subString(0,15);
			}
			if(String.isNotBlank(aa.New_Author__c)) {
		    	contentAuditTrailObj.org_id_new_author_people_id = organizationId + String.valueOf(aa.New_Author__c).subString(0,15);
			}
			if(String.isNotBlank(aa.Old_Author__c)) {
		    	contentAuditTrailObj.org_id_old_author_people_id = organizationId + String.valueOf(aa.Old_Author__c).subString(0,15);
			}
			if(String.isNotBlank(aa.New_Site__c)) {
		    	contentAuditTrailObj.org_id_new_site_id = organizationId + String.valueOf(aa.New_Site__c).subString(0,15);
			}
			if(String.isNotBlank(aa.Old_Site__c)) {
		    	contentAuditTrailObj.org_id_old_site_id = organizationId + String.valueOf(aa.Old_Site__c).subString(0,15);
			}
			contentAuditTrailObj.action = aa.Action__c;

			if(aa.Sync_Status__c == null) {
	    		aa.Sync_Status__c = 1;
		    } else if (aa.Sync_Status__c > 5) {
		    	aa.Sync_Status__c = 5;
		    } else {
		    	aa.Sync_Status__c = aa.Sync_Status__c + 1;
		    }
			contentAuditTrailWrapperList.add(contentAuditTrailObj);
		}
	
		sendDataToAWS('content_audit_trail', contentAuditTrailWrapperList);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id, Content_Audit_Trail__c>((List<Content_Audit_Trail__c>)listOfsObject),
		new List<Schema.SObjectField>{
			Content_Audit_Trail__c.Sync_Status__c
		});
    }
    
    public void sendContentListToAWS(sObject[] listOfsObject){
    		List<AnalyticsWrapper.Content> contentWrapperList = new List<AnalyticsWrapper.Content>();
			set<Id> contentIdSet = new set <Id>();
			Map<String, Integer> contentAssignmentTopicCountMap = new Map<String, Integer>();
			Map<Id,Simpplr_Content__c> contentMap = new Map<Id,Simpplr_Content__c>();
			Map<id,Integer> rsvpRemovedMap = new Map<Id,Integer>();
		for(Simpplr_Content__c aa : (List<Simpplr_Content__c>)listOfsObject){
			contentMap.put(aa.id,aa);
			if(aa.Type__c == 'Event'){
				contentIdSet.add(aa.id);
			}
		}
			
			List<AggregateResult> aggrList = [SELECT Object_Id__c ContentId, COUNT(Id) peopleCount FROM App_Notification__c WHERE Is_Deleted__c = false AND Category__c = 'RSVP_Removed' and Object_Id__c in :contentIdSet WITH SECURITY_ENFORCED GROUP BY Object_Id__c];
		for(AggregateResult ar: aggrList) {
            rsvpRemovedMap.put((String) ar.get('ContentId'), (Integer) ar.get('peopleCount'));

		}
		List<AggregateResult> aggrTopicList = [SELECT EntityId, COUNT(TopicId) topicsCount FROM TopicAssignment WHERE entitytype = 'Simpplr_Content' AND EntityId IN: contentMap.keyset() WITH SECURITY_ENFORCED GROUP BY EntityId];

		for(AggregateResult ar: aggrTopicList) {
            contentAssignmentTopicCountMap.put((String) ar.get('EntityId'), (Integer) ar.get('topicsCount'));
        }

			AnalyticsWrapper.Content contentObj;
		for(Simpplr_Content__c aa : (List<Simpplr_Content__c>)listOfsObject){
			contentObj = new AnalyticsWrapper.Content();
			contentObj.id = organizationId + String.valueOf(aa.id).subString(0,15);
			contentObj.content_type = aa.Type__c;
		    contentObj.content_title = Utility.encryptString(aa.Title__c);
		    contentObj.content_id = aa.Id;
			contentObj.content_sub_type  = aa.content_sub_type__c;
			contentObj.album_image_count = aa.Album_Image_Count__c;
			contentObj.album_video_count = aa.Album_Video_Count__c;
			contentObj.event_rsvp_allowed = aa.Event_RSVP_Allowed__c;
			contentObj.event_rsvp_deadline = aa.Event_RSVP_By_DateTime__c == null ? null : aa.Event_RSVP_By_DateTime__c.formatGMT(dateTimeFormat);
			contentObj.topic_count = contentAssignmentTopicCountMap.get(aa.id);
			if(rsvpRemovedMap.containsKey(aa.id)){
				contentObj.rsvp_removed_count = rsvpRemovedMap.get(aa.id);
			}
			if(aa.First_Publish_DateTime__c!= null) {
		    	contentObj.first_publish_date = aa.First_Publish_DateTime__c.format('yyyy-MM-dd');
		    }
		    if(aa.Publish_Start_DateTime__c != null) {
		    	contentObj.publish_start_date = aa.Publish_Start_DateTime__c.formatGMT(dateTimeFormat);
		    }
		    if(aa.Publish_End_DateTime__c != null) {
		    	contentObj.publish_end_date = aa.Publish_End_DateTime__c.formatGMT(dateTimeFormat);
		    }
			if(aa.Last_Validated_DateTime__c != null) {
		    	contentObj.last_validated_date_time = aa.Last_Validated_DateTime__c.formatGMT(dateTimeFormat);
		    }
			if(aa.Read_Time__c != null) {
		    	contentObj.read_time = aa.Read_Time__c != null ? Integer.valueOf(aa.Read_Time__c) : null;
		    }
		    contentObj.is_deleted = aa.is_Deleted__c;
		    if(String.isNotBlank(aa.Site__c)) {
			    contentObj.site = aa.Site__c;
			    contentObj.org_id_site_id = organizationId + String.valueOf(aa.Site__c).subString(0,15);
		    }
		    contentObj.author_id = aa.Primary_Author__c;
			contentObj.status = aa.Status__c;
			contentObj.version = aa.Version__c;
		    if(String.isNotBlank(aa.Primary_Author__c)) {
		    	contentObj.org_id_people_id = organizationId + String.valueOf(aa.Primary_Author__c).subString(0,15);
		    }
            contentObj.onboarding_status = aa.Content_Onboarding_Status__c;
            contentObj.onboarding_added_date = aa.Onboarding_Added_Date__c;
			contentWrapperList.add(contentObj);
		}
		
		sendDataToAWS('content', contentWrapperList);
    }
    
    public void sendPeopleListToAWS(sObject[] listOfsObject){
		List<Simpplr_Site__c> siteList = [SELECT Id, Chatter_Group_Id__c FROM Simpplr_Site__c WHERE
											Is_Deleted__c = false AND Is_Active__c = true AND
											show_in_simpplr__c = true WITH SECURITY_ENFORCED];

		List<String> chatterGroupIdList = new List<String>();
		for (Simpplr_Site__c siteObj : siteList){
			chatterGroupIdList.add(siteObj.Chatter_Group_Id__c);
		}

		List<String> userIdList = new List<String>();
		Set<Id> peopleId = new Set<Id>();
		for(People_Preference__c peoplePrefObj : (List<People_Preference__c>) listOfsObject){
			userIdList.add(peoplePrefObj.People__r.User__c);
			peopleId.add(peoplePrefObj.people__c);
		}

		String memberVsGroupCountQuery = 'SELECT MemberId, COUNT(CollaborationGroupId) groupcount FROM CollaborationGroupMember WHERE '
										+ ' CollaborationGroupId IN :chatterGroupIdList AND '
										+ ' CollaborationRole = \'Admin\' AND '
										+ ' Member.IsActive = true AND '
										+ ' MemberId IN :userIdList WITH SECURITY_ENFORCED GROUP BY MemberId';
		List<AggregateResult> aggrList = Database.query(memberVsGroupCountQuery);
		Map<String, Integer> userIdVsManagedGroupCountmap = new Map<String, Integer>();
		for(AggregateResult aggResult : aggrList){
			Integer count = (Integer) aggResult.get('groupcount');
			String userId = (String) aggResult.get('MemberId');
			
			userIdVsManagedGroupCountmap.put(userId, count);
		}
        Map<Id, Set<String>> integrationMap=new Map <Id, Set<String>>();              
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', peopleId);
        String queryStr ='select id,name,Active__c,Connected__c,App_Integration__r.id,App_Integration__r.name,People__c from People_Integration__c where '+
                                   				' People__c in :soqlParam1 and Is_Deleted__c=false' ;
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<People_Integration__c> peopleList = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);											
    
        for(People_Integration__c peopleObj : peopleList){
            Set<String> integrationSet = new Set<String>();
            if(integrationMap.containsKey(peopleObj.People__c)){
				integrationSet=integrationMap.get(peopleObj.People__c);
			}
			integrationSet.add(peopleObj.name);
			integrationMap.put(peopleObj.People__c,integrationSet);        	
        }        
		List<AnalyticsWrapper.People> peopleWrapperList = new List<AnalyticsWrapper.People>();
		AnalyticsWrapper.People peopleObj;
		for(People_Preference__c aa : (List<People_Preference__c>)listOfsObject){
			peopleObj = new AnalyticsWrapper.People();
			peopleObj.id = organizationId + String.valueOf(aa.people__c).subString(0,15);
		    peopleObj.people_id = aa.people__c;
		   	peopleObj.people_category = aa.people__r.People_Category__c;
		   	peopleObj.people_category_name = aa.people__r.People_Category__r.Name__c;
	    	peopleObj.segment_id = aa.people__r.Segment__c;
	    	peopleObj.segment_name = aa.people__r.Segment__r.Name__c;
		    peopleObj.title = aa.people__r.Title__c;
		    peopleObj.department = aa.people__r.Department__c;
		    peopleObj.company_name = aa.people__r.Company_Name__c;
		    peopleObj.people_name = Utility.encryptString(aa.people__r.Full_Name__c);
		    peopleObj.division = aa.people__r.Division__c;
		    peopleObj.city = aa.people__r.City__c;
		    peopleObj.state = aa.people__r.State__c;
		    peopleObj.street = aa.people__r.Street__c;
		    peopleObj.country = aa.people__r.Country__c;
		    peopleObj.app_moderation_permission = aa.people__r.app_moderation_permission__c;
		    peopleObj.unlisted_site_moderation_permission = aa.people__r.unlisted_site_moderation_permission__c;
		    peopleObj.can_access_analytics = aa.people__r.Can_access_analytics__c;
		    peopleObj.can_control_dashboard = aa.people__r.Can_control_dashboard__c;
		    peopleObj.can_send_alert = aa.people__r.Can_send_alert__c;
		    peopleObj.is_influencer = aa.people__r.Is_influencer__c;
		    peopleObj.is_campaign_manager = aa.people__r.Is_campaign_manager__c;
		    peopleObj.is_active = aa.people__r.User__r.IsActive;
			peopleObj.email = aa.people__r.email__c;
			String profilePhotoUrl = Utility.getProfilePhotoURL(aa.people__r.User__r.SmallPhotoURL);
			peopleObj.has_profile_photo = String.isNotBlank(profilePhotoUrl) ? true : false;
			peopleObj.language = aa.people__r.User__r.LanguageLocaleKey;
			peopleObj.email_updates_event_i_rsvp_yes = aa.Email_Updates_Event_I_RSVP_Yes__c ;
			peopleObj.email_updates_event_i_author_organize = aa.Email_Updates_Event_I_Author_Organize__c;
			if(aa.people__r.Mobile_Token_Android__c != null){
				peopleObj.mobile_app_type = 'Android';
			}else if (aa.people__r.Mobile_Token_iOS__c != null){
				peopleObj.mobile_app_type = 'iOS';
			}
			
			Set<String> integrationsEnabledSet = integrationMap.get(aa.People__c);
			if( integrationsEnabledSet!= null) {
				 if(integrationsEnabledSet.contains('googledrive')){
					peopleObj.integration_shared_drive_enabled=true;	

				}
				if(integrationsEnabledSet.contains('onedrive')){
					peopleObj.integration_onedrive_enabled=true;	

				}
				if(integrationsEnabledSet.contains('dropbox')){
					peopleObj.integration_dropbox_enabled=true;	

				}
				if(integrationsEnabledSet.contains('sharepoint')){
					peopleObj.integration_sharepoint_enabled=true;		

				}
				if(integrationsEnabledSet.contains('linkedin')){
					peopleObj.integration_linkedin_enabled=true;	

				}
				if(integrationsEnabledSet.contains('twitter')){
					peopleObj.integration_twitter_enabled=true;	

				}
				if(integrationsEnabledSet.contains('servicenow')){
					peopleObj.integration_servicenow_enabled=true;	

				}
				if(integrationsEnabledSet.contains('slackContentShare')){
					peopleObj.integration_slack_content_share_enabled=true;   

				}
				if(integrationsEnabledSet.contains('slackUnfurl')){
					peopleObj.integration_slack_unfurl_enabled=true;    

				}
				if(integrationsEnabledSet.contains('googlecalendar')){
					peopleObj.integration_google_calendar_enabled=true;    

				}
			}
			peopleObj.integration_box_enabled = String.isNotBlank(aa.Box_Access_Token__c);
			// Custom fields
			peopleObj.custom_field_1 = Utility.encryptString(aa.people__r.Custom_Field_1__c);
			peopleObj.custom_field_2 = Utility.encryptString(aa.people__r.Custom_Field_2__c);
			peopleObj.custom_field_3 = Utility.encryptString(aa.people__r.Custom_Field_3__c);
			peopleObj.custom_field_4 = Utility.encryptString(aa.people__r.Custom_Field_4__c);
			peopleObj.custom_field_5 = Utility.encryptString(aa.people__r.Custom_Field_5__c);
			peopleObj.custom_field_6 = Utility.encryptString(aa.people__r.Custom_Field_6__c);
			peopleObj.custom_field_7 = Utility.encryptString(aa.people__r.Custom_Field_7__c);
			peopleObj.custom_field_8 = Utility.encryptString(aa.people__r.Custom_Field_8__c);
			peopleObj.custom_field_9 = Utility.encryptString(aa.people__r.Custom_Field_9__c);
			peopleObj.custom_field_10 = Utility.encryptString(aa.people__r.Custom_Field_10__c);
			peopleObj.custom_field_11 = Utility.encryptString(aa.people__r.Custom_Field_11__c);
			peopleObj.custom_field_12 = Utility.encryptString(aa.people__r.Custom_Field_12__c);
			peopleObj.custom_field_13 = Utility.encryptString(aa.people__r.Custom_Field_13__c);
			peopleObj.custom_field_14 = Utility.encryptString(aa.people__r.Custom_Field_14__c);
			peopleObj.custom_field_15 = Utility.encryptString(aa.people__r.Custom_Field_15__c);
			peopleObj.custom_field_16 = Utility.encryptString(aa.people__r.Custom_Field_16__c);
			peopleObj.custom_field_17 = Utility.encryptString(aa.people__r.Custom_Field_17__c);
			peopleObj.custom_field_18 = Utility.encryptString(aa.people__r.Custom_Field_18__c);
			peopleObj.custom_field_19 = Utility.encryptString(aa.people__r.Custom_Field_19__c);
			peopleObj.custom_field_20 = Utility.encryptString(aa.people__r.Custom_Field_20__c);
			peopleObj.custom_field_21 = Utility.encryptString(aa.people__r.Custom_Field_21__c);
			peopleObj.custom_field_22 = Utility.encryptString(aa.people__r.Custom_Field_22__c);
			peopleObj.custom_field_23 = Utility.encryptString(aa.people__r.Custom_Field_23__c);
			peopleObj.custom_field_24 = Utility.encryptString(aa.people__r.Custom_Field_24__c);
			peopleObj.custom_field_25 = Utility.encryptString(aa.people__r.Custom_Field_25__c);								
		    
			if(userIdVsManagedGroupCountmap.containsKey(aa.people__r.User__c) &&
						userIdVsManagedGroupCountmap.get(aa.people__r.User__c) > 0){
				peopleObj.is_site_manager = true;
				peopleObj.managing_site_count = userIdVsManagedGroupCountmap.get(aa.people__r.User__c);
			} else {
				peopleObj.is_site_manager = false;
				peopleObj.managing_site_count = 0;
			}

		    peopleObj.cover_photo_fill_datetime = aa.people__r.Cover_Photo_Fill_DateTime__c == null ? null : aa.people__r.Cover_Photo_Fill_DateTime__c.formatGMT(dateTimeFormat);
		    peopleObj.aboutme_fill_datetime = aa.people__r.AboutMe_Fill_DateTime__c == null ? null : aa.people__r.AboutMe_Fill_DateTime__c.formatGMT(dateTimeFormat);
		    peopleObj.phone_fill_datetime = aa.people__r.Phone_Fill_DateTime__c == null ? null : aa.people__r.Phone_Fill_DateTime__c.formatGMT(dateTimeFormat);
		    peopleObj.mobile_fill_datetime = aa.people__r.Mobile_Fill_DateTime__c == null ? null : aa.people__r.Mobile_Fill_DateTime__c.formatGMT(dateTimeFormat);
			peopleObj.birthdate_fill_datetime = aa.people__r.Birthdate_Fill_DateTime__c == null ? null : aa.people__r.Birthdate_Fill_DateTime__c.formatGMT(dateTimeFormat);
		    
		    peopleObj.last_edited_datetime = aa.people__r.Last_Edited_DateTime__c == null ? null : aa.people__r.Last_Edited_DateTime__c.formatGMT(dateTimeFormat);
		    peopleObj.last_sync_datetime = aa.people__r.Last_Sync_DateTime__c == null ? null : aa.people__r.Last_Sync_DateTime__c.formatGMT(dateTimeFormat);
		    peopleObj.first_login_datetime = aa.people__r.First_Login_DateTime__c == null ? null : aa.people__r.First_Login_DateTime__c.formatGMT(dateTimeFormat);
			
			if(aa.people__r.Profile_Photo_Fill_DateTime__c != null) {
				peopleObj.profile_photo_fill_datetime = aa.people__r.Profile_Photo_Fill_DateTime__c.formatGMT(dateTimeFormat);	

			} else if(String.isNotBlank(aa.People__r.External_Photo_URL__c)) {
				peopleObj.profile_photo_fill_datetime = peopleObj.last_edited_datetime;

			}
			
			peopleobj.allow_simpplr_emails = aa.allow_simpplr_emails__c;
			peopleobj.email_endorses_me = aa.email_endorses_me__c;
			peopleobj.email_my_content_post = aa.email_my_content_post__c;
			peopleobj.email_notification_digest_frequency = aa.email_notification_digest_frequency__c;
			peopleobj.email_digest_frequency = aa.email_digest_frequency__c;
			peopleobj.content_digest_frequency = aa.content_digest_frequency__c;
			peopleobj.receive_content_useful_notifications = aa.receive_content_useful_notifications__c;
			peopleobj.email_made_site_manager_or_owner = aa.email_made_site_manager_or_owner__c;
			peopleobj.native_mob_content_submit_moderation = aa.native_mob_content_submit_moderation__c;
			peopleobj.native_mobile_event_invite_more = aa.native_mobile_event_invite_more__c;
			peopleobj.native_mob_comments_on_my_post = aa.native_mob_comments_on_my_post__c;
			peopleobj.email_subscription_moderation = aa.email_subscription_moderation__c;
			peopleobj.email_comments_after_me = aa.email_comments_after_me__c;
			peopleobj.email_follows_me = aa.email_follows_me__c;
			peopleobj.email_my_content_share = aa.email_my_content_share__c;
			peopleobj.email_content_digest_frequency = aa.email_content_digest_frequency__c;
			peopleobj.email_content_submitted_for_moderation = aa.email_content_submitted_for_moderation__c;
			peopleobj.email_private_site_membership_response = aa.email_privateSiteMembership_response__c;
			peopleobj.default_site_digest_frequency = aa.default_site_digest_frequency__c;
			peopleobj.email_event_invite_more = aa.email_event_invite_more__c;
			peopleobj.email_content_marked_as_must_read = aa.email_content_marked_as_must_read__c;
			peopleobj.native_mob_private_site_membership_req = aa.native_mob_private_site_membership_req__c;
			peopleobj.native_mobile_follows_me = aa.native_mobile_follows_me__c;
			peopleobj.native_mob_like_my_post_or_comment = aa.native_mob_like_my_post_or_comment__c;
			peopleobj.email_comments_on_my_post = aa.email_comments_on_my_post__c;
			peopleobj.email_like_my_post_or_comment = aa.email_like_my_post_or_comment__c;
			peopleobj.email_posts_on_my_profile = aa.email_posts_on_my_profile__c;
			peopleobj.email_my_content_approved = aa.email_my_content_approved__c;
			peopleobj.email_private_site_membership_requests = aa.email_private_site_membership_requests__c;
			peopleobj.email_content_submission_response = aa.email_content_submission_response__c;
			peopleobj.notification_digest_frequency = aa.notification_digest_frequency__c;
			peopleobj.email_updates_content_sites_i_follow = aa.email_updates_content_sites_i_follow__c;
			peopleobj.email_my_content_like_or_share = aa.email_my_content_like_or_share__c;
			peopleobj.native_mob_update_content_site_i_follow = aa.native_mob_update_content_site_i_follow__c;
			peopleobj.native_mobile_my_content_like_or_share = aa.native_mobile_my_content_like_or_share__c;
			peopleobj.native_mob_my_content_post = aa.native_mob_my_content_post__c;
			peopleobj.email_comments_on_post_i_like = aa.email_comments_on_post_i_like__c;
			peopleobj.email_mentions_me = aa.email_mentions_me__c;
			peopleobj.email_shares_my_post = aa.email_shares_my_post__c;
			peopleobj.email_my_content_rejected = aa.email_my_content_rejected__c;
			peopleobj.actionable_notification_frequency = aa.actionable_notification_frequency__c;
			peopleobj.email_content_useful = aa.email_content_useful__c;
			peopleobj.receive_content_update_notifications = aa.receive_content_update_notifications__c;
			peopleobj.email_posts_to_me = aa.email_posts_to_me__c;
			peopleobj.email_site_analytics_frequency = aa.email_site_analytics_frequency__c;
			peopleobj.native_mob_posts_to_me = aa.native_mob_posts_to_me__c;
			peopleObj.show_in_simpplr = aa.People__r.User__r.Show_Simpplr__c;
			peopleObj.email_my_content_validation_required = aa.Email_My_Content_Validation_Required__c ;
			peopleObj.email_my_content_validation_expired = aa.Email_My_Content_Validation_Expired__c;
			peopleObj.layout = aa.layout__c ;

			peopleObj.email_alerts = aa.Email_Alerts__c;
			peopleObj.sms_alerts = aa.SMS_Alerts__c;
			peopleObj.sms_must_reads = aa.SMS_Must_Reads__c;
			peopleObj.sms_content_promotion_message = aa.SMS_Content_Promotion_Message__c; // TODO - DS0001 - People Integration
			peopleObj.native_mobile_alerts = aa.Native_Mobile_Alerts__c;
			peopleObj.native_mob_content_marked_as_must_read = aa.Native_Mob_Content_Marked_As_Must_Read__c;

			peopleObj.is_protected_author = aa.people__r.Is_Protected_Author__c;
			peopleObj.is_protected_author_allowlisted = aa.people__r.Is_Protected_Author_Allowlisted__c;

			peopleObj.people_created_at = Utility.dateTimeStringInGMT(aa.people__r.createddate, dateTimeFormat);
			peopleObj.people_last_deactivated_at = Utility.dateTimeStringInGMT(aa.people__r.User_Last_Deactivated__c, dateTimeFormat);
			peopleObj.enable_org_level_onboarding = aa.People__r.Enable_Org_Level_Onboarding__c;
			peopleObj.has_simpplr_license = aa.People__r.Has_simpplr_license__c;
			peopleObj.onboarding_email_frequency = aa.Email_Onboarding_Frequency__c;
			peopleObj.has_read_all_onboarding_content = aa.People__r.Has_Read_All_Onboarding_Content__c;
			peopleObj.user_id = aa.People__r.User_Id__c;

			
			peopleWrapperList.add(peopleObj);
		}
		
		sendDataToAWS('people', peopleWrapperList);
    }
    
    public void sendTopicListToAWS(sObject[] listOfsObject){
    		List<AnalyticsWrapper.Topic> topicWrapperList = new List<AnalyticsWrapper.Topic>();
    		AnalyticsWrapper.Topic topicObj;
		for(Topic aa : (List<Topic>)listOfsObject){
			topicObj = new AnalyticsWrapper.Topic();
			topicObj.id = organizationId + String.valueOf(aa.id).subString(0,15);
		    topicObj.topic_name = aa.Name;
		    topicObj.topic_id = aa.Id;
			topicWrapperList.add(topicObj);
		}
		
		sendDataToAWS('topic', topicWrapperList);
    }
    
	public void sendCarouselContentListToAWS(sObject[] listOfsObject) {
		List<AnalyticsWrapper.Carousel_Content> carouselContentWrapperList = new List<AnalyticsWrapper.Carousel_Content>();
    	AnalyticsWrapper.Carousel_Content analyticsObj;
		for(Carousel_Content__c aa : (List<Carousel_Content__c>)listOfsObject){
			analyticsObj = new AnalyticsWrapper.Carousel_Content();
			analyticsObj.id = organizationId + String.valueOf(aa.id).subString(0,15);
			analyticsObj.record_id = aa.id;
		    
			if(String.isNotBlank(aa.Simpplr_Content__c)) {
		    	analyticsObj.org_id_content_id = organizationId + String.valueOf(aa.Simpplr_Content__c).subString(0,15);
		    }
			if(String.isNotBlank(aa.Site__c)) {
				analyticsObj.site = aa.Site__c;
				analyticsObj.org_id_site_id = organizationId + String.valueOf(aa.Site__c).subString(0,15);
			}
			if(String.isNotBlank(aa.social_campaign__c)) {
				analyticsObj.org_id_social_campaign = organizationId + String.valueOf(aa.social_campaign__c);
			}
			analyticsObj.is_deleted = aa.is_deleted__c;
			analyticsObj.item_type = aa.item_type__c;
			if(aa.order__c != null) {
				analyticsObj.item_order = Integer.valueOf(aa.order__c);
			}
			analyticsObj.segment = aa.segment__c;
			if(aa.created_by_People__c != null) {
				analyticsObj.org_id_inserted_by_people_id = organizationId + String.valueOf(aa.created_by_People__c);
			}
			if(aa.deleted_by_people__c != null) {
				analyticsObj.org_id_deleted_by_people_id = organizationId + String.valueOf(aa.deleted_by_people__c);
			}
			analyticsObj.inserted_at = Utility.dateTimeStringInGMT(aa.createddate, dateTimeFormat);
			if(aa.is_deleted__c) {
				analyticsObj.deleted_at = Utility.dateTimeStringInGMT(aa.lastmodifieddate, dateTimeFormat);
			}
			
			carouselContentWrapperList.add(analyticsObj);
		}
		
		sendDataToAWS('carousel_content', carouselContentWrapperList);
	}
     public void sendSocialAnalyticsListToAWS(sObject[] listOfsObject){
    		List<AnalyticsWrapper.SocialAnalytics> analyticWrapperList = new List<AnalyticsWrapper.SocialAnalytics>();
    		AnalyticsWrapper.SocialAnalytics analyticsObj;
		for(Simpplr_Social_Analytics__c aa : (List<Simpplr_Social_Analytics__c>)listOfsObject){
			analyticsObj = new AnalyticsWrapper.SocialAnalytics();
		    analyticsObj.record_id = aa.Id;
		    analyticsObj.search_results_count = Integer.valueOf(aa.Search_Results_Count__c);
		    analyticsObj.page_name = aa.Page_Name__c;
			analyticsObj.page_group = aa.Page_Group__c;
			analyticsObj.page_analytics_category = aa.Page_Analytics_Category__c;
			analyticsObj.utm_source = aa.UTM_Source__c;
			analyticsObj.utm_medium = aa.UTM_Medium__c;
			analyticsObj.utm_term = aa.UTM_Term__c;
			analyticsObj.utm_content = aa.UTM_Content__c;
		    if(String.isNotBlank(aa.People__c)) {
		    	analyticsObj.people_id = aa.People__c;
		    	analyticsObj.org_id_people_id = organizationId + String.valueOf(aa.People__c).subString(0,15);
		    }
		    analyticsObj.user = aa.User__c;
		    analyticsObj.search_results_summary = aa.Search_Results_Summary__c;
		    analyticsObj.origin = aa.Origin__c;
		    analyticsObj.page_url = aa.Page_URL__c;
		    analyticsObj.interaction = aa.Interaction__c;
		    if(String.isNotBlank(aa.Simpplr_Site__c)) {
		    		analyticsObj.org_id_site_id = organizationId + String.valueOf(aa.Simpplr_Site__c).subString(0,15);
		    }
		    if(String.isNotBlank(aa.Content__c)) {
		    		analyticsObj.org_id_content_id = organizationId + String.valueOf(aa.Content__c).subString(0,15);
		    }
		    analyticsObj.people_profile = aa.People_Profile__c;
		    analyticsObj.file_id = aa.File_Id__c;
		    analyticsObj.user_agent = aa.User_Agent__c;
		    analyticsObj.topic_id = aa.Topic_ID__c;
		    analyticsObj.search_text = aa.Search_Text__c;
		    analyticsObj.origin_mobile_browser = aa.Origin_Mobile_Browser__c;
		    analyticsObj.origin_mobile_app = aa.Origin_Mobile_App__c;
		    analyticsObj.origin_desktop_app = aa.Origin_Desktop_App__c;
		    analyticsObj.origin_native_mobile_app = aa.Origin_Native_Mobile_App__c;
		    analyticsObj.mailer = aa.Mailer__c;
			analyticsObj.login_history_id = aa.Login_History_Id__c;
			analyticsObj.referer = aa.Referer__c;
		    analyticsObj.record_date = aa.createddate.date();
			analyticsObj.record_date_time = Utility.dateTimeStringInGMT(aa.createddate, dateTimeFormat);
			
		    if(aa.Sync_Status__c == null) {
	    		aa.Sync_Status__c = 1;
		    } else if (aa.Sync_Status__c > 5) {
		    	aa.Sync_Status__c = 5;
		    } else {
		    	aa.Sync_Status__c = aa.Sync_Status__c + 1;
		    }
			analyticWrapperList.add(analyticsObj);
		}
		
		sendDataToAWS('social_analytics', analyticWrapperList);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id,Simpplr_Social_Analytics__c>((List<Simpplr_Social_Analytics__c>)listOfsObject), new List<Schema.SObjectField>{
			Simpplr_Social_Analytics__c.Sync_Status__c
		});
    }
    
    public void sendMailerListToAWS(sObject[] listOfsObject){
		List<AnalyticsWrapper.Mailer> mailerWrapperList = new List<AnalyticsWrapper.Mailer>();
		AnalyticsWrapper.Mailer mailerObj;
		for(Mailer__c aa : (List<Mailer__c>)listOfsObject){
			mailerObj = new AnalyticsWrapper.Mailer();
			mailerObj.id = organizationId + String.valueOf(aa.id).subString(0,15);
			mailerObj.record_id = aa.id;
			mailerObj.from_address = aa.From_Address_Id__c;
			mailerObj.from_address_id =  aa.From_Address__c;
			if(String.isNotBlank(aa.Site__c)) {
		    		mailerObj.org_id_site_id = organizationId + String.valueOf(aa.Site__c).subString(0,15);
		    }
			mailerObj.name = aa.name__c;
			mailerObj.actual_recipient_count = aa.actual_recipient_count__c == null ? 0: Integer.valueOf(aa.actual_recipient_count__c);
			mailerObj.total_click_count = aa.total_click_count__c == null ? 0 : Integer.valueOf(aa.total_click_count__c);
			mailerObj.open_count = aa.open_count__c == null ? 0 : Integer.valueOf(aa.open_count__c);
			mailerObj.unique_click_count = aa.unique_click_count__c == null ? 0 : Integer.valueOf(aa.unique_click_count__c);
			mailerObj.sent_date_time = aa.Sent_Time__c.formatGMT(dateTimeFormat);
			mailerWrapperList.add(mailerObj);
		}
		
		sendDataToAWS('newsletter', mailerWrapperList);
    }
    
    public void sendSocialCampaignListToAWS(sObject[] listOfsObject){
        List<AnalyticsWrapper.SocialCampaign> analyticWrapperList = new List<AnalyticsWrapper.SocialCampaign>();
        AnalyticsWrapper.SocialCampaign campaignObj;
        
        for(Social_Campaign__c scObj : (List<Social_Campaign__c>)listOfsObject){
            campaignObj = new AnalyticsWrapper.SocialCampaign();

            campaignObj.id = organizationId + String.valueOf(scObj.Id).subString(0,15);
            campaignObj.record_id = scObj.Id;
            campaignObj.record_date = Utility.dateTimeStringInGMT(scObj.createddate, dateTimeFormat);
            campaignObj.facebook_share_enabled = scObj.facebook_share_enabled__c;
            campaignObj.linkedin_share_enabled = scObj.linkedIn_share_enabled__c;
            campaignObj.twitter_share_enabled = scObj.twitter_share_enabled__c;
            campaignObj.total_facebook_share_count = Integer.valueOf(scObj.total_facebook_share_count__c);
            campaignObj.total_linkedin_share_count = Integer.valueOf(scObj.total_linkedIn_share_Count__c);
            campaignObj.total_twitter_share_count = Integer.valueOf(scObj.total_twitter_share_count__c);
            campaignObj.url = scObj.url__c;
            campaignObj.is_deleted = scObj.Is_deleted__c;
            campaignObj.is_active = scObj.Is_Active__c;
            
            analyticWrapperList.add(campaignObj);
        }

        sendDataToAWS('social_campaign', analyticWrapperList);
    }

	public void sendSegmentDataToAWS(sObject[] listOfsObject){
        List<AnalyticsWrapper.Segment> analyticWrapperList = new List<AnalyticsWrapper.Segment>();
        AnalyticsWrapper.Segment segmentObj; 
        
        for(Segment__c sObj : (List<Segment__c>) listOfsObject){
            segmentObj = new AnalyticsWrapper.Segment();

            segmentObj.id = organizationId + String.valueOf(sObj.Id).subString(0,15);
            segmentObj.segment_id = sObj.Id;
            segmentObj.org_id = organizationId;
			segmentObj.segment_name = sObj.Name__c;
			segmentObj.branding_json = sObj.Branding_JSON__c;
			segmentObj.branding_css_class = sObj.Branding_CSS_Class__c;
			segmentObj.branding_css = sObj.Branding_CSS__c;
			segmentObj.branding_costom_font_css = sObj.Branding_Custom_Font_CSS__c;
			segmentObj.branding_logo = sObj.Branding_Logo__c;
			segmentObj.branding_json = sObj.Branding_JSON__c;
			segmentObj.favicons_folder = sObj.Favicons_Folder__c;
			segmentObj.segment_attribute_value_json = sObj.Segment_Attribute_Value_JSON__c;
			segmentObj.branding_package_version = sObj.Branding_Package_Version__c;
			segmentObj.carousel_layout = sObj.Carousel_Layout__c;
			segmentObj.custom_links_json = sObj.Custom_Links_JSON__c;
			segmentObj.sso_provider = sObj.SSO_Provider__c;
			segmentObj.sso_custom_json = sObj.SSO_Custom_JSON__c;
            
            analyticWrapperList.add(segmentObj);
        }

        sendDataToAWS('segment', analyticWrapperList);
    }

	public void sendSegmentSiteDataToAWS(sObject[] listOfsObject){
        List<AnalyticsWrapper.SegmentSite> analyticWrapperList = new List<AnalyticsWrapper.SegmentSite>();
        AnalyticsWrapper.SegmentSite segmentObj;
        
        for(Segment_Site__c ssObj : (List<Segment_Site__c>) listOfsObject){
            segmentObj = new AnalyticsWrapper.SegmentSite();

            segmentObj.id = organizationId + String.valueOf(ssObj.Id).subString(0,15);
            segmentObj.segment_id = ssObj.Id;
            segmentObj.org_id = organizationId;
            segmentObj.site_id = ssObj.Site__c;
			segmentObj.is_featured = ssObj.Is_Featured__c; 

			if(String.isNotBlank(ssObj.Site__c)) {
				segmentObj.org_id_site_id = organizationId + String.valueOf(ssObj.Site__c).subString(0,15);
		    }
			if(String.isNotBlank(ssObj.Segment__c)) {
				segmentObj.org_id_segment_id = organizationId + String.valueOf(ssObj.Segment__c).subString(0,15);
		    }
			segmentObj.item_order = Integer.valueOf(ssObj.Order__c);

            analyticWrapperList.add(segmentObj);
        }

        sendDataToAWS('segment_site', analyticWrapperList);
    }

	public void sendAudienceDataToAWS(sObject[] listOfsObject){
		List<AnalyticsWrapper.Audience> analyticWrapperList = new List<AnalyticsWrapper.Audience>();
		AnalyticsWrapper.Audience audienceObj;

		for(Audience__c aObj: (List<Audience__c>) listOfsObject) {
			audienceObj = new AnalyticsWrapper.Audience();

			audienceObj.org_id = organizationId;
			audienceObj.audience_member_count = aObj.Audience_Member_Count__c;
			audienceObj.audience_rule_json = aObj.Audience_Rule_Json__c;
			audienceObj.has_city_condition = aObj.Has_City_Condition__c;
			audienceObj.has_company_name_condition = aObj.Has_Company_Name_Condition__c;
			audienceObj.has_country_condition = aObj.Has_Country_Condition__c;
			audienceObj.has_department_condition = aObj.Has_Department_Condition__c;
			audienceObj.has_division_condition = aObj.Has_Division_Condition__c;
			audienceObj.has_people_category_condition = aObj.Has_People_Category_Condition__c;
			audienceObj.has_state_condition = aObj.Has_State_Condition__c;
			audienceObj.has_title_condition = aObj.Has_Title_Condition__c;
			audienceObj.Id = organizationId + String.valueOf(aObj.id).subString(0,15);

			if(String.isNotBlank(aObj.Segment__c)) {
				audienceObj.org_id_segment_id = organizationId + String.valueOf(aobj.Segment__c).subString(0,15);
		    }
			if (aObj.Sync_Status__c == null) {
		    	aObj.Sync_Status__c = 1;
		    
			} else if (aObj.Sync_Status__c > 5) {
		    	aObj.Sync_Status__c = 5;
		    
			} else {
		    	aObj.Sync_Status__c = aObj.Sync_Status__c + 1;
		    }
			analyticWrapperList.add(audienceObj);
		}
		sendDataToAWS('audience', analyticWrapperList);
		update listOfsObject;
	}
	public void sendSubscriptionDataToAWS(sObject[] listOfsObject){

		List<AnalyticsWrapper.Subscription> analyticWrapperList = new List<AnalyticsWrapper.Subscription>();
		AnalyticsWrapper.Subscription subscriptionObj;
		for(Subscription__c sObj: (List<Subscription__c>) listOfsObject) {
			subscriptionObj = new AnalyticsWrapper.Subscription();
			subscriptionObj.org_id = organizationId;
			subscriptionObj.Id = organizationId + String.valueOf(sObj.id).subString(0,15);
			subscriptionObj.action_type = sObj.Action_Type__c;
			subscriptionObj.recipient = sObj.Recipient__c;
			subscriptionObj.audience = sObj.Audience__c;
			if(String.isNotBlank(sObj.Audience__c)) {
				subscriptionObj.org_id_audience_id = organizationId + String.valueOf(sObj.Audience__c).subString(0,15);
			}
			subscriptionObj.status = sObj.Status__c;
			subscriptionObj.type = sObj.Type__c;
			if (sObj.Sync_Status__c == null) {
		    	sObj.Sync_Status__c = 1;
		    
			} else if (sObj.Sync_Status__c > 5) {
		    	sObj.Sync_Status__c = 5;
		    
			} else {
		    	sObj.Sync_Status__c = sObj.Sync_Status__c + 1;
		    }
			analyticWrapperList.add(subscriptionObj);
		}

		sendDataToAWS('subscription', analyticWrapperList);
		update listOfsObject ;
	}


	public void sendSubscriptionEntityDataToAWS(sObject[] listOfsObject){
		List<AnalyticsWrapper.SubscriptionEntity> analyticWrapperList = new List<AnalyticsWrapper.SubscriptionEntity>();
		AnalyticsWrapper.SubscriptionEntity subscriptionEntityObj;
		for(Subscription_Entity__c seObj: (List<Subscription_Entity__c>) listOfsObject) {
			subscriptionEntityObj = new AnalyticsWrapper.SubscriptionEntity();
			subscriptionEntityObj.org_id = organizationId;
			subscriptionEntityObj.Id = organizationId + String.valueOf(seObj.id).subString(0,15);
			if(seObj.Action_On__c != null){
			subscriptionEntityObj.action_on = seObj.Action_On__c.formatGMT(dateTimeFormat);
			}
			subscriptionEntityObj.processing_required = seObj.Processing_Required__c;
			subscriptionEntityObj.status = seObj.status__c ;
			subscriptionEntityObj.site = seObj.site__c;
			if(String.isNotBlank(seObj.site__c)) {
		    	subscriptionEntityObj.org_id_site_id = organizationId + String.valueOf(seObj.site__c).subString(0,15);
			}
			subscriptionEntityObj.people = seObj.people__c;
			if(String.isNotBlank(seObj.people__c)) {
		    	subscriptionEntityObj.org_id_people_id = organizationId + String.valueOf(seObj.people__c).subString(0,15);
			}
			subscriptionEntityObj.subscription = seObj.Subscription__c ;
			if(String.isNotBlank(seObj.Subscription__c)) {
				subscriptionEntityObj.org_id_subscription_id = organizationId + String.valueOf(seObj.Subscription__c).subString(0,15);

			}
			if (seObj.Sync_Status__c == null) {
		    	seObj.Sync_Status__c = 1;
		    
			} else if (seObj.Sync_Status__c > 5) {
		    	seObj.Sync_Status__c = 5;
		    
			} else {
		    	seObj.Sync_Status__c = seObj.Sync_Status__c + 1;
		    }
			analyticWrapperList.add(subscriptionEntityObj);
		}

		sendDataToAWS('subscription_entity', analyticWrapperList);
		update listOfsObject ;
	}


	public void sendAppDefaultDataToAWS(sObject[] listOfsObject){
		List<AnalyticsWrapper.app_default> analyticWrapperList = new List<AnalyticsWrapper.app_default>();
		AnalyticsWrapper.app_default appDefaultObj;
		Map<String, Object> adMap ;
		for(App_Default__c adObj: (List<App_Default__c>) listOfsObject) {
			appDefaultObj = new AnalyticsWrapper.app_default();
			if(adObj.data__c != null ){				

				if('email_notifications'.equalsIgnoreCase(adObj.type__c)){
					adMap = (Map<String, Object>)JSON.deserializeUntyped(adObj.data__c);
					appDefaultObj.top_stories_frequency = (string)adMap.get('topStoriesFrequency');
					appDefaultObj.site_analytics_frequency = (string)adMap.get('siteAnalyticsFrequency');
					appDefaultObj.email_updates_content_sites_follow = (Boolean)adMap.get('emailUpdatesContentSitesFollow');
					appDefaultObj.email_shares_post_made = (Boolean)adMap.get('emailSharesPostMade');
					appDefaultObj.email_private_site_membership_response = (Boolean)adMap.get('emailPrivateSiteMembershipResponse');
					appDefaultObj.email_posts_to_me = (Boolean) adMap.get('emailPostsToMe');
					appDefaultObj.email_notification_frequency = (String)adMap.get('emailNotificationFrequency');
					appDefaultObj.email_likes_shares_content_published = (Boolean)adMap.get('emailLikesSharesContentPublished');
					appDefaultObj.email_likes_post_or_comment_made = (Boolean)adMap.get('emailLikesPostOrCommentMade');
					appDefaultObj.email_for_content_useful = (Boolean)adMap.get('emailForContentUseful');
					appDefaultObj.email_follows_me = (Boolean)adMap.get('emailFollowsMe');
					appDefaultObj.email_event_invite_more = (Boolean)adMap.get('emailEventInviteMore');
					appDefaultObj.email_endorse_expertise = (Boolean)adMap.get('emailEndorseExpertise');
					appDefaultObj.email_content_submission_response = (Boolean)adMap.get('emailContentSubmissionResponse');
					appDefaultObj.email_content_marked_as_must_read =(Boolean)adMap.get('emailContentMarkedAsMustRead');
					appDefaultObj.email_comments_post_made = (Boolean)adMap.get('emailCommentsPostMade');
					appDefaultObj.email_comments_post_like = (Boolean)adMap.get('emailCommentsPostLike');
					appDefaultObj.email_comments_content_published = (Boolean)adMap.get('emailCommentsContentPublished');
					appDefaultObj.email_comments_after_me = (Boolean)adMap.get('emailCommentsAfterMe');
					appDefaultObj.email_alerts = (Boolean)adMap.get('emailAlerts');
					appDefaultObj.digest_frequency = (String)adMap.get('digestFrequency');
					appDefaultObj.allow_simpplr_emails = (String)adMap.get('allowSimpplrEmails');
					appDefaultObj.email_knowledge_review = (Boolean)adMap.get('emailKnowledgeReview');
					appDefaultObj.email_knowledge_expired = (Boolean)adMap.get('emailKnowledgeExpired');
					appDefaultObj.email_subscription_moderation = (Boolean)adMap.get('emailSubscriptionModeration');
			
				} else if ('sms_notifications'.equalsIgnoreCase(adObj.type__c)){
					adMap = (Map<String, Object>)JSON.deserializeUntyped(adObj.data__c);
					appDefaultObj.sms_content_marked_as_must_read =(Boolean)adMap.get('smsContentMarkedAsMustRead');
					appDefaultObj.sms_alerts =(Boolean)adMap.get('smsAlerts');
					appDefaultObj.sms_content_promotion_message =(Boolean)adMap.get('smsContentPromotionMessage');

				} else if('native_mobile_notifications'.equalsIgnoreCase(adObj.type__c)){
					adMap = (Map<String, Object>)JSON.deserializeUntyped(adObj.data__c);
					appDefaultObj.mobile_app_content_marked_as_must_read =(Boolean)adMap.get('mobileAppContentMarkedAsMustRead');
					appDefaultObj.mobile_app_alerts =(Boolean)adMap.get('mobileAppAlerts');
					appDefaultObj.mobile_app_updates_content_sites_follow =(Boolean)adMap.get('mobileAppUpdatesContentSitesFollow');
					
					appDefaultObj.mobile_app_follows_me =(Boolean)adMap.get('mobileAppFollowsMe');
					appDefaultObj.mobile_app_endorse_expertise =(Boolean)adMap.get('mobileAppEndorseExpertise');
					
					appDefaultObj.mobile_app_comments_post_made =(Boolean)adMap.get('mobileAppCommentsPostMade');
					appDefaultObj.mobile_app_reply_after_me =(Boolean)adMap.get('mobileAppReplyAfterMe');
					appDefaultObj.mobile_app_reply_liked_post =(Boolean)adMap.get('mobileAppReplyOnLikedPost');
					appDefaultObj.mobile_app_likes_post_or_comment_made =(Boolean)adMap.get('mobileAppLikesPostOrCommentMade');
					appDefaultObj.mobile_app_shares_my_post =(Boolean)adMap.get('mobileAppSharesMyPost');
					appDefaultObj.mobile_app_post_to_me =(Boolean)adMap.get('mobileAppPostsToMe');

					appDefaultObj.mobile_app_comments_content_published =(Boolean)adMap.get('mobileAppCommentsContentPublished');
					appDefaultObj.mobile_app_likes_or_shares_content_published= (Boolean)adMap.get('mobileAppLikesOrSharesContentPublished');
					appDefaultObj.mobile_app_content_approval_rejection =(Boolean)adMap.get('mobileAppContentApprovalRejection');

					appDefaultObj.mobile_app_event_invite_more =(Boolean)adMap.get('mobileAppEventInviteMore');
					appDefaultObj.mobile_app_event_updates_attending =(Boolean)adMap.get('mobileAppEventUpdatesAttending');
					appDefaultObj.mobile_app_event_updates_authored_organised =(Boolean)adMap.get('mobileAppEventUpdatesAuthoredOrganized');

					appDefaultObj.mobile_app_private_site_membership_request =(Boolean)adMap.get('mobileAppPrivateSiteMembershipRequest');
					appDefaultObj.mobile_app_content_submitted_for_moderation =(Boolean)adMap.get('mobileAppContentSubmittedForModeration');
					
				} else if('home-feed'.equalsIgnoreCase(adObj.type__c)){
					adMap = (Map<String, Object>)JSON.deserializeUntyped(adObj.data__c);
					appDefaultObj.feed_setting =(String)adMap.get('feedSetting');
					appDefaultObj.feed_filter =(String)adMap.get('feedFilter');
					appDefaultObj.app_default_last_modified_by_name =(String)adMap.get('appDefaultLastModifiedByName');
					appDefaultObj.app_default_last_modified_by_url =(String)adMap.get('appDefaultLastModifiedByURL');
					appDefaultObj.app_default_last_modified_date =(String)adMap.get('appDefaultLastModifiedDate');
					
				} else if('home-default'.equalsIgnoreCase(adObj.type__c)){
					List<String> listOfTiles = adObj.data__c.split(',');	
					List<AnalyticsWrapper.TilesConfig> tilesConfigWrapperList = new List<AnalyticsWrapper.TilesConfig>();
					Map<String, Object> soqlParamMap = new Map<String, Object>();
					soqlParamMap.put('soqlParam1', listOfTiles);
					String query = 'select id,Layout_Column__c,Variant__c,Type__c,Order__c,Location__c from Tiles_Config__c where id in :soqlParam1';
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					List<Tiles_Config__c> tilesConfigList = (List<Tiles_Config__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
					for (Tiles_Config__c tilesObj: tilesConfigList){

								AnalyticsWrapper.TilesConfig tilesConfigObj = new AnalyticsWrapper.TilesConfig();
								tilesConfigObj.id =  organizationId + String.valueOf(tilesObj.id).subString(0,15);
								tilesConfigObj.layout_column = tilesObj.Layout_Column__c;
								tilesConfigObj.location = tilesObj.Location__c;
								tilesConfigObj.tiles_order = tilesObj.Order__c;
								tilesConfigObj.variant = tilesObj.Variant__c;
								tilesConfigObj.type = tilesObj.Type__c;
		
								tilesConfigWrapperList.add(tilesConfigObj);
						}
					appDefaultObj.tiles_config_json = json.serialize(tilesConfigWrapperList);

				} else if ('summaries_and_digest'.equalsIgnoreCase(adObj.type__c)){
					adMap = (Map<String, Object>)JSON.deserializeUntyped(adObj.data__c);
					appDefaultObj.onboarding_email_frequency = (string)adMap.get('emailOnboardingFrequency');
				}

		}
			appDefaultObj.org_id = organizationId ;
			appDefaultObj.id = organizationId + String.valueOf(adObj.id).subString(0,15);
			appDefaultObj.overwrite_batch_in_progress = adObj.OverwriteBatchInProgress__c;
			appDefaultObj.type = adObj.type__c;
			appDefaultObj.layout = adObj.layout__c ;
			appDefaultObj.people_id = adObj.people__c;
			
			if(String.isNotBlank(adObj.people__c)) {
		    	appDefaultObj.org_id_people_id = organizationId + String.valueOf(adObj.people__c).subString(0,15);

			}
			appDefaultObj.segment_id = adObj.segment__c;
			if(String.isNotBlank(adObj.segment__c)) {
		    	appDefaultObj.org_id_people_id = organizationId + String.valueOf(adObj.segment__c).subString(0,15);
			}
			
			if (adObj.Sync_Status__c == null) {
		    	adObj.Sync_Status__c = 1;
		    
			} else if (adObj.Sync_Status__c > 5) {
		    	adObj.Sync_Status__c = 5;
		    
			} else {
		    	adObj.Sync_Status__c = adObj.Sync_Status__c + 1;
			}
			analyticWrapperList.add(appDefaultObj);
		}
			sendDataToAWS('app_default', analyticWrapperList);
			update listOfsObject;

	}
    
    private void sendDataToAWS(String recordType, Object[] listOfsObject){
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('orgId',organizationId);
        requestBody.put('isTest',isTest());
        requestBody.put('objectType',recordType);
        requestBody.put('listObjectViews',listOfsObject);
        String endpoint = 'https://services.simpplr.com/dataprocessor/analytics-data.php?dri=' + Utility.requestAdoptionDataAuthToken();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(60000);
        req.setBody(Json.serialize(requestBody));
        Http http = new Http();
        HttpResponse res;
		if (!test.isRunningTest()) {
			res = http.send(req);
			if(res.getStatusCode() != 200) {
				throw new SimpplrException('Status - ' + res.getStatusCode() + 'received.');     	
			}
		}
     }
     
     private Integer isTest() {
     	Integer isTest = 0;
     	if(SimpplrContext.isSandbox || String.isBlank(SimpplrContext.packageName) || SimpplrContext.isTestOrg) {
     		isTest = 1;
     	}
     	return isTest;
     }

	 public void sendAppConfigToAWS(sObject[] listOfsObject) {
		List<App_Config__c> appConfigList = (List<App_Config__c>)listOfsObject;
		if(appConfigList != null && appConfigList.isEmpty() == false){
			AnalyticsWrapper.App_Config appConfigWrapperObj = new AnalyticsWrapper.App_Config();
			App_COnfig__c aa = appConfigList[0];
			appConfigWrapperObj.org_name = UserInfo.getOrganizationName();
			appConfigWrapperObj.ad_integration_enabled = aa.ad_integration_enabled__c;
			appConfigWrapperObj.album = String.isNotBlank(aa.Allowed_Features__c) ? aa.Allowed_Features__c.containsIgnoreCase(ServiceConstants.TYPE_ALBUM)?true:false: false;
			appConfigWrapperObj.allow_comments = aa.allow_comments__c;
			appConfigWrapperObj.allow_file_share_with_public_link = aa.allow_file_share_with_public_link__c;
			appConfigWrapperObj.allow_file_upload = aa.allow_file_upload__c;
			appConfigWrapperObj.allow_file_upload_site_managers = aa.Allow_File_Upload_Site_Managers__c;
			appConfigWrapperObj.allow_follow = aa.allow_follow__c;
			appConfigWrapperObj.allow_only_influencers_to_create_blog = aa.allow_only_influencers_to_create_blog__c;
			appConfigWrapperObj.allow_public_contribution = aa.allow_public_contribution__c;
			appConfigWrapperObj.allow_site_add = aa.allow_site_add__c;
			appConfigWrapperObj.allowed_features = aa.allowed_features__c;
			appConfigWrapperObj.app_dashboard_mode = aa.app_dashboard_mode__c;
			appConfigWrapperObj.app_download_info_url = aa.app_download_info_url__c;
			appConfigWrapperObj.app_home_dashboard_tile_ids = aa.app_home_dashboard_tile_ids__c;
			appConfigWrapperObj.feed_placeholder = aa.feed_placeholder__c;
			appConfigWrapperObj.app_integrations_enabled = aa.app_integrations_enabled__c;
			appConfigWrapperObj.app_languages_enabled = aa.app_languages_enabled__c;
			appConfigWrapperObj.app_name = aa.app_name__c;
			appConfigWrapperObj.app_page_title = aa.app_page_title__c;
			appConfigWrapperObj.at_bookmark_enabled = aa.at_bookmark_enabled__c;
			appConfigWrapperObj.at_collaborationgroup_enabled = aa.at_collaborationgroup_enabled__c;
			appConfigWrapperObj.at_collaborationgroupmember_enabled = aa.at_collaborationgroupmember_enabled__c;
			appConfigWrapperObj.at_contentdocument_enabled = aa.AT_ContentDocument_Enabled__c;
			appConfigWrapperObj.at_contentdocumentlink_enabled = aa.at_contentdocumentlink_enabled__c;
			appConfigWrapperObj.at_contentversion_enabled = aa.at_contentversion_enabled__c;
			appConfigWrapperObj.at_feed_itemenabled = aa.at_feed_itemenabled__c;
			appConfigWrapperObj.at_feedcomment_enabled = aa.at_feedcomment_enabled__c;
			appConfigWrapperObj.at_file_enabled = aa.at_file_enabled__c;
			appConfigWrapperObj.at_folder_enabled = aa.at_folder_enabled__c;
			appConfigWrapperObj.at_like_enabled = aa.at_like_enabled__c;
			appConfigWrapperObj.at_people_category_enabled = aa.at_people_category_enabled__c;
			appConfigWrapperObj.at_people_enabled = aa.at_people_category_enabled__c;
			appConfigWrapperObj.at_people_preference_enabled = aa.at_people_preference_enabled__c;
			appConfigWrapperObj.at_share_enabled = aa.at_share_enabled__c;
			appConfigWrapperObj.at_simpplr_content_enabled = aa.at_simpplr_content_enabled__c;
			appConfigWrapperObj.at_simpplr_site_enabled = aa.at_simpplr_site_enabled__c;
			appConfigWrapperObj.at_simpplr_social_analytics_enabled = aa.at_simpplr_social_analytics_enabled__c;
			appConfigWrapperObj.at_user_enabled = aa.at_user_enabled__c;
			appConfigWrapperObj.at_user_trigger_type = aa.at_user_trigger_type__c;
			appConfigWrapperObj.audit_trail_enabled = aa.audit_trail_enabled__c;
			appConfigWrapperObj.auto_convert_chattergroup_to_site = aa.auto_convert_chattergroup_to_site__c;
			appConfigWrapperObj.auto_provisioning_process_enabled = aa.auto_provisioning_process_enabled__c;
			appConfigWrapperObj.aws_file_upload_enabled = aa.aws_file_upload_enabled__c;
			appConfigWrapperObj.blog = String.isNotBlank(aa.Allowed_Features__c) ? aa.Allowed_Features__c.containsIgnoreCase(ServiceConstants.TYPE_BLOGPOST)?true:false: false;
			appConfigWrapperObj.box_integration_enabled = aa.box_integration_enabled__c;
			appConfigWrapperObj.box_user_id = aa.box_user_id__c;
			appConfigWrapperObj.branding_css_class = aa.branding_css_class__c;
			appConfigWrapperObj.branding_css = aa.branding_css__c;
			appConfigWrapperObj.branding_custom_font_css = aa.branding_custom_font_css__c;
			appConfigWrapperObj.branding_json = aa.branding_json__c;
			appConfigWrapperObj.branding_logo = aa.branding_logo__c;
			appConfigWrapperObj.calendar_app_enabled = aa.calendar_app_enabled__c;
			appConfigWrapperObj.calendar_google_enabled = aa.calendar_google_enabled__c;
			appConfigWrapperObj.calendar_office365_enabled = aa.calendar_office365_enabled__c;
			appConfigWrapperObj.calendar_outlook_web_enabled = aa.calendar_outlook_web_enabled__c;
			appConfigWrapperObj.carousel_layout = aa.carousel_layout__c;
			appConfigWrapperObj.carousel_speed = aa.carousel_speed__c != null ? Integer.valueOf(aa.carousel_speed__c):0 ;
			appConfigWrapperObj.chatter_email_off_profiles = aa.chatter_email_off_profiles__c;
			appConfigWrapperObj.communities_basepath = aa.communities_basepath__c;
			appConfigWrapperObj.communities_enabled = aa.communities_enabled__c;
			appConfigWrapperObj.content_history_enabled = aa.content_history_enabled__c;
			appConfigWrapperObj.custom_links_json = aa.custom_links_json__c;
			appConfigWrapperObj.default_page_size = aa.default_page_size__c != null ? Integer.valueOf(aa.default_page_size__c):0 ;
			appConfigWrapperObj.embedly_enabled = aa.embedly_enabled__c;
			appConfigWrapperObj.employee_advocacy_enabled = aa.employee_advocacy_enabled__c;
			appConfigWrapperObj.event = String.isNotBlank(aa.Allowed_Features__c) ? aa.Allowed_Features__c.containsIgnoreCase(ServiceConstants.TYPE_EVENT)?true:false: false;
			appConfigWrapperObj.expertise_controlled_by = aa.expertise_controlled_by__c;
			appConfigWrapperObj.expertise_create_controlled_by = aa.Expertise_Create_Controlled_By__c;
			appConfigWrapperObj.external_analytics_enabled = aa.External_Analytics_Enabled__c;
			appConfigWrapperObj.external_analytics_url = aa.External_Analytics_URL__c;
			appConfigWrapperObj.external_search_active = aa.External_Search_Active__c;
			appConfigWrapperObj.external_search_app_connected = aa.External_Search_App_Connected__c;
			appConfigWrapperObj.external_search_base_url = aa.External_Search_Base_URL__c;
			appConfigWrapperObj.external_search_connected_by_people = aa.External_Search_Connected_By_People__c;
			appConfigWrapperObj.external_search_enabled_by_people = aa.External_Search_Enabled_By_People__c;
			appConfigWrapperObj.external_search_enabled = aa.External_Search_Enabled__c;
			appConfigWrapperObj.external_search_file_connected = aa.External_search_file_connected__c;
			appConfigWrapperObj.external_search_provider = aa.External_Search_Provider__c;
			appConfigWrapperObj.favicons_folder = aa.Favicons_Folder__c;
			appConfigWrapperObj.feed_enabled = aa.Feed_Enabled__c;
			appConfigWrapperObj.feed_mode = aa.Feed_Mode__c;
			appConfigWrapperObj.feed_page_size = aa.Feed_Page_Size__c != null ? Integer.valueOf(aa.Feed_Page_Size__c):0  ;
			appConfigWrapperObj.feed_refresh_interval = aa.Feed_Refresh_Interval__c != null ? Integer.valueOf(aa.Feed_Refresh_Interval__c) :0;
			appConfigWrapperObj.feed_rich_text_enabled = aa.Feed_Rich_Text_Enabled__c;
			appConfigWrapperObj.feed_show_track_change_posts = aa.Feed_Show_Track_Change_Posts__c;
			appConfigWrapperObj.feedback_share_with_simpplr = aa.Feedback_Share_with_Simpplr__c;
			appConfigWrapperObj.feedback_to_emails = aa.Feedback_To_Emails__c;
			appConfigWrapperObj.file_storage_setting_level = aa.File_Storage_Setting_Level__c;
			appConfigWrapperObj.file_storage_source = aa.File_Storage_Source__c;
			appConfigWrapperObj.flow_external_search_enabled = aa.External_Search_Enabled__c;
			appConfigWrapperObj.ga_demography_interests = aa.GA_Demography_Interests__c;
			appConfigWrapperObj.ga_enabled = aa.GA_Enabled__c;
			appConfigWrapperObj.ga_enhanced_link_attribution = aa.GA_Enhanced_Link_Attribution__c;
			appConfigWrapperObj.go_to_salesforce_enabled = aa.Go_To_Salesforce_Enabled__c;
			appConfigWrapperObj.golive_chatter_email_setup = aa.GoLive_Chatter_Email_Setup__c;
			appConfigWrapperObj.home_carousel_enabled = aa.Home_Carousel_Enabled__c;
			appConfigWrapperObj.last_edited_datetime = aa.Last_Edited_DateTime__c;
			appConfigWrapperObj.last_major_upgrade_datetime = aa.Last_Major_Upgrade_DateTime__c;
			appConfigWrapperObj.layout = aa.Layout__c;
			appConfigWrapperObj.lightning_ux_tab_open_setting = aa.Lightning_UX_Tab_Open_Setting__c;
			appConfigWrapperObj.login_timeout = aa.Login_Timeout__c!= null ? Integer.valueOf(aa.Login_Timeout__c):0 ;
			appConfigWrapperObj.logout_custom_page_enabled = aa.Logout_Custom_Page_Enabled__c;
			appConfigWrapperObj.logout_custom_page_url = aa.Logout_Custom_Page_URL__c;
			appConfigWrapperObj.microsoft_teams_integration_enabled = aa.Microsoft_Teams_Integration_Enabled__c;
			appConfigWrapperObj.mobile_app_bundle_id_android = aa.Mobile_App_Bundle_ID_Android__c;
			appConfigWrapperObj.mobile_app_bundle_id_ios = aa.Mobile_App_Bundle_ID_iOS__c;
			appConfigWrapperObj.mobile_app_deeplinking_enabled = aa.Mobile_App_Deeplinking_Enabled__c;
			appConfigWrapperObj.mobile_promotion_enabled = aa.Mobile_Promotion_Enabled__c;
			appConfigWrapperObj.branded_app_distribution_enabled = aa.Branded_App_Distribution_Enabled__c;
			appConfigWrapperObj.mute_content_post_in_sitefeed_enabled = aa.Mute_Content_Post_In_SiteFeed_Enabled__c;
			appConfigWrapperObj.newsletter_tracker_last_data_id = aa.Newsletter_Tracker_Last_Data_Id__c;
			appConfigWrapperObj.notification_refresh_interval = aa.Notification_Refresh_Interval__c != null ? Integer.valueOf(aa.Notification_Refresh_Interval__c):0 ;
			appConfigWrapperObj.nps_survey_days_to_end = aa.NPS_Survey_Days_To_End__c != null ? Integer.valueOf(aa.NPS_Survey_Days_To_End__c):0 ;
			appConfigWrapperObj.nps_survey_enabled = aa.NPS_Survey_Enabled__c;
			appConfigWrapperObj.okta_enabled = aa.Okta_Enabled__c;
			appConfigWrapperObj.okta_link = aa.Okta_Link__c;
			appConfigWrapperObj.okta_people_name_format = aa.Okta_People_Name_Format__c;
			appConfigWrapperObj.onelogin_enabled = aa.OneLogin_Enabled__c;
			appConfigWrapperObj.onelogin_link = aa.OneLogin_Link__c;
			appConfigWrapperObj.org_chart_enabled = aa.Org_Chart_Enabled__c;
			appConfigWrapperObj.package_name = aa.Package_Name__c;
			appConfigWrapperObj.package_version = aa.Package_Version__c;
			appConfigWrapperObj.release_name = ServiceConstants.RELEASE_VERSION;
			appConfigWrapperObj.page = String.isNotBlank(aa.Allowed_Features__c) ? aa.Allowed_Features__c.containsIgnoreCase(ServiceConstants.TYPE_PAGE)?true:false: false;
			appConfigWrapperObj.pds_about_me = aa.PDS_About_Me__c;
			appConfigWrapperObj.pds_birth_date = aa.PDS_Birth_Date__c;
			appConfigWrapperObj.pds_city = aa.PDS_City__c;
			appConfigWrapperObj.pds_community_nickname = aa.PDS_Community_Nickname__c;
			appConfigWrapperObj.pds_company_name = aa.PDS_Company_Name__c;
			appConfigWrapperObj.pds_country = aa.PDS_Country__c;
			appConfigWrapperObj.pds_department = aa.PDS_Department__c;
			appConfigWrapperObj.pds_division = aa.PDS_Division__c;
			appConfigWrapperObj.pds_email = aa.PDS_Email__c;
			appConfigWrapperObj.pds_employee_number = aa.PDS_Employee_Number__c;
			appConfigWrapperObj.pds_enable_formatting = aa.PDS_Enable_Formatting__c;
			appConfigWrapperObj.pds_extension = aa.PDS_Extension__c;
			appConfigWrapperObj.pds_fax = aa.PDS_Fax__c;
			appConfigWrapperObj.pds_first_name = aa.PDS_First_Name__c;
			appConfigWrapperObj.pds_first_pull_sync_all_fields = aa.PDS_First_Pull_Sync_All_Fields__c;
			appConfigWrapperObj.pds_joining_date = aa.PDS_Joining_Date__c;
			appConfigWrapperObj.pds_last_name = aa.PDS_Last_Name__c;
			appConfigWrapperObj.pds_manager_id = aa.PDS_Manager_Id__c;
			appConfigWrapperObj.pds_max_sync_attempts = aa.PDS_Max_Sync_Attempts__c != null ? Integer.valueOf(aa.PDS_Max_Sync_Attempts__c):0 ;
			appConfigWrapperObj.pds_middle_name = aa.PDS_Middle_Name__c;
			appConfigWrapperObj.pds_mobile_phone = aa.PDS_Mobile_Phone__c;
			appConfigWrapperObj.pds_phone = aa.PDS_Phone__c;
			appConfigWrapperObj.pds_photo = aa.PDS_Photo__c;
			appConfigWrapperObj.pds_postal_code = aa.PDS_Postal_Code__c;
			appConfigWrapperObj.pds_role = aa.PDS_Role__c;
			appConfigWrapperObj.pds_source_application = aa.PDS_Source_Application__c;
			appConfigWrapperObj.pds_state = aa.PDS_State__c;
			appConfigWrapperObj.pds_street = aa.PDS_Street__c;
			appConfigWrapperObj.pds_manager_unique_identifier_key = aa.PDS_Manager_Unique_Identifier_Key__c;
			appConfigWrapperObj.pds_unique_identifier = aa.PDS_Unique_Identifier__c;
			appConfigWrapperObj.pds_title = aa.PDS_Title__c;
			appConfigWrapperObj.pds_workday_enabled = aa.PDS_Workday_Enabled__c;
			appConfigWrapperObj.pds_ukg_pro_enabled = aa.PDS_UKG_Pro_Enabled__c;
			appConfigWrapperObj.people_category_enabled = aa.people_category_enabled__c;
			appConfigWrapperObj.people_catgeory_plural = aa.people_catgeory_plural__c;
			appConfigWrapperObj.people_catgeory_singular = aa.people_catgeory_singular__c;
			appConfigWrapperObj.pp_about_me_display = aa.pp_about_me_display__c;
			appConfigWrapperObj.pp_about_me_editable = aa.pp_about_me_editable__c;
			appConfigWrapperObj.pp_birthdate_display = aa.pp_birthdate_display__c;
			appConfigWrapperObj.pp_birthdate_editable = aa.pp_birthdate_editable__c;
			appConfigWrapperObj.pp_category_display = aa.pp_category_display__c;
			appConfigWrapperObj.pp_category_editable = aa.pp_category_editable__c;
			appConfigWrapperObj.pp_city_display = aa.pp_city_display__c;
			appConfigWrapperObj.pp_city_editable = aa.pp_city_editable__c;
			appConfigWrapperObj.pp_company_name_display = aa.pp_company_name_display__c;
			appConfigWrapperObj.pp_company_name_editable = aa.pp_company_name_editable__c;
			appConfigWrapperObj.pp_country_display = aa.pp_country_display__c;
			appConfigWrapperObj.pp_country_editable = aa.pp_country_editable__c;
			appConfigWrapperObj.pp_department_display = aa.pp_department_display__c;
			appConfigWrapperObj.pp_department_editable = aa.pp_department_editable__c;
			appConfigWrapperObj.pp_departments_count = aa.pp_departments_count__c != null ? Integer.valueOf(aa.pp_departments_count__c):0 ;
			appConfigWrapperObj.pp_division_display = aa.pp_division_display__c;
			appConfigWrapperObj.pp_division_editable = aa.pp_division_editable__c;
			appConfigWrapperObj.pp_employees_count = aa.pp_employees_count__c!= null ? Integer.valueOf(aa.pp_employees_count__c):0 ;
			appConfigWrapperObj.pp_extension_display = aa.pp_extension_display__c;
			appConfigWrapperObj.pp_extension_editable = aa.pp_extension_editable__c;
			appConfigWrapperObj.pp_firstname_display = aa.pp_firstname_display__c;
			appConfigWrapperObj.pp_firstname_editable = aa.pp_firstname_editable__c;
			appConfigWrapperObj.pp_joiningdate_display = aa.pp_joiningdate_display__c;
			appConfigWrapperObj.pp_joiningdate_editable = aa.pp_joiningdate_editable__c;
			appConfigWrapperObj.pp_lastname_display = aa.pp_lastname_display__c;
			appConfigWrapperObj.pp_lastname_editable = aa.pp_lastname_editable__c;
			appConfigWrapperObj.pp_locations_count = aa.pp_locations_count__c != null ? Integer.valueOf(aa.pp_locations_count__c):0 ;
			appConfigWrapperObj.pp_manager_display = aa.pp_manager_display__c;
			appConfigWrapperObj.pp_manager_editable = aa.pp_manager_editable__c;
			appConfigWrapperObj.pp_mobilephone_display = aa.pp_mobilephone_display__c;
			appConfigWrapperObj.pp_mobilephone_editable = aa.pp_mobilephone_editable__c;
			appConfigWrapperObj.pp_phone_display = aa.pp_phone_display__c;
			appConfigWrapperObj.pp_phone_editable = aa.pp_phone_editable__c;
			appConfigWrapperObj.pp_state_display = aa.pp_state_display__c;
			appConfigWrapperObj.pp_state_editable = aa.pp_state_editable__c;
			appConfigWrapperObj.pp_street_display = aa.pp_street_display__c;
			appConfigWrapperObj.pp_street_editable = aa.pp_street_editable__c;
			appConfigWrapperObj.pp_timezone_display = aa.pp_timezone_display__c;
			appConfigWrapperObj.pp_timezone_editable = aa.pp_timezone_editable__c;
			appConfigWrapperObj.pp_title_display = aa.pp_title_display__c;
			appConfigWrapperObj.pp_title_editable = aa.pp_title_editable__c;
			appConfigWrapperObj.pp_user_custom_fields = aa.pp_user_custom_fields__c;
			appConfigWrapperObj.pp_video_display = aa.pp_video_display__c;
			appConfigWrapperObj.pp_video_editable = aa.pp_video_editable__c;
			appConfigWrapperObj.pp_video_provider = aa.pp_video_provider__c;
			appConfigWrapperObj.search_content_allowed_field = aa.search_content_allowed_field__c;
			appConfigWrapperObj.search_people_allowed_field = aa.search_people_allowed_field__c;
			appConfigWrapperObj.sed_daily_digest_size = aa.sed_daily_digest_size__c != null ? Integer.valueOf(aa.sed_daily_digest_size__c ):0;
			appConfigWrapperObj.sed_from_email = aa.SED_From_Email__c;
			appConfigWrapperObj.sed_weekly_digest_size = aa.sed_weekly_digest_size__c != null ? Integer.valueOf(aa.sed_weekly_digest_size__c):0 ;
			appConfigWrapperObj.segment_apps_links_enabled = aa.Segment_Apps_Links_Enabled__c;
			appConfigWrapperObj.segment_branding_enabled = aa.segment_branding_enabled__c;
			appConfigWrapperObj.segment_column_name = aa.segment_column_name__c;
			appConfigWrapperObj.segment_enabled = aa.segment_enabled__c;
			appConfigWrapperObj.show_hidden_folders = aa.show_hidden_folders__c;
			appConfigWrapperObj.show_logo_on_mobile = aa.show_logo_on_mobile__c;
			appConfigWrapperObj.simpplr_desktop_notification_allowed = aa.simpplr_desktop_notification_allowed__c;
			appConfigWrapperObj.simpplr_emails_allowed = aa.simpplr_emails_allowed__c;
			appConfigWrapperObj.simpplr_mobile_notification_allowed = aa.simpplr_mobile_notification_allowed__c;
			appConfigWrapperObj.simpplr_setup_complete = aa.simpplr_setup_complete__c;
			appConfigWrapperObj.simpplr_top_stories_emails_allowed = aa.simpplr_top_stories_emails_allowed__c;
			appConfigWrapperObj.site_carousel_enabled = aa.site_carousel_enabled__c;
			appConfigWrapperObj.site_dashboard_mode = aa.site_dashboard_mode__c;
			appConfigWrapperObj.slack_integration_enabled = aa.slack_integration_enabled__c;
			appConfigWrapperObj.slack_link_unfurl_enabled = aa.slack_link_unfurl_enabled__c;
			appConfigWrapperObj.social_campaign_policy_url = aa.social_campaign_policy_url__c;
			appConfigWrapperObj.social_tiles_enabled = aa.social_tiles_enabled__c;
			appConfigWrapperObj.sp_integration_enabled = aa.sp_integration_enabled__c;
			appConfigWrapperObj.sso_custom_json = aa.sso_custom_json__c;
			appConfigWrapperObj.sso_provider = aa.sso_provider__c;
			appConfigWrapperObj.start_of_week = aa.start_of_week__c;
			appConfigWrapperObj.use_connectapi_for_feed_update_check = aa.use_connectapi_for_feed_update_check__c;
			appConfigWrapperObj.vbrick_enabled = aa.vbrick_enabled__c;
			appConfigWrapperObj.validation_period = aa.Validation_Period__c;
			appConfigWrapperObj.content_governance_enabled = aa.Content_Governance_Enabled__c;
			appConfigWrapperObj.enterprise_search_enabled = aa.Enterprise_Search_Enabled__c;
			appConfigWrapperObj.enterprise_search_provider = aa.enterprise_search_provider__c;
			appConfigWrapperObj.enterprise_search_url = aa.enterprise_search_url__c;
			appConfigWrapperObj.ukg_pro_user_division_key = aa.PDS_User_Division_Key__c;
			appConfigWrapperObj.ukg_pro_birthdate_key = aa.PDS_Birth_Date_Key__c;
			appConfigWrapperObj.ukg_pro_department_key = aa.PDS_Department_Key__c;
			appConfigWrapperObj.sp_upgrade_status = aa.SP_Upgrade_Status__c;
			appConfigWrapperObj.data_key = aa.Data_Key__c;
			appConfigWrapperObj.site_level_onboarding = aa.Site_Level_Onboarding__c;

            
			String appIntQuery =  'select id, name, connected__c,Is_My_Drive_Enabled__c, Data__c from app_integration__c where is_deleted__c = false';

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<App_integration__c> appIntegrationObj = (List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, null);
		
			for( app_integration__c appInt :appIntegrationObj) {
     
				if(appInt.name == 'dropbox'){
					appConfigWrapperObj.integration_dropbox_enabled = appInt.connected__c;
				
				} else if(appInt.name == 'googledrive'){
					appConfigWrapperObj.integration_shared_drive_enabled = appInt.connected__c;
					appConfigWrapperObj.integration_my_drive_enabled = appInt.Is_My_Drive_Enabled__c;
				
                } else if(appInt.name == 'onedrive'){
                    appConfigWrapperObj.integration_onedrive_enabled = true;
            
                } else if(appInt.name == 'adsi'){
                    appConfigWrapperObj.integration_active_directory_enabled = appInt.connected__c;

                } else if(appInt.name == 'servicenow'){
                    appConfigWrapperObj.integration_servicenow_enabled = appInt.connected__c;
            
                } else if(appInt.name == 'sharepoint'){
                    appConfigWrapperObj.integration_sharepoint_enabled = true;

					if(!String.isBlank(appInt.Data__c)){
						Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(appInt.Data__c);
						if(requestDataMap.get('showOpenInSharePoint') != null){
							appConfigWrapperObj.show_open_in_share_point = Boolean.valueOf(requestDataMap.get('showOpenInSharePoint'));
						}
					}
                } else if(appInt.name == 'slack'){
                    appConfigWrapperObj.integration_slack_enabled = true;  
         
                } else if(appInt.name == 'facebook'){
                    appConfigWrapperObj.integration_facebook_enabled = true;
            
                } else if(appInt.name == 'linkedin'){
                    appConfigWrapperObj.integration_linkedin_enabled = true;         
  
                } else if(appInt.name == 'twitter'){
                    appConfigWrapperObj.integration_twitter_enabled = true;

				} else if(appInt.name == 'salesforce'){
                    appConfigWrapperObj.integration_servicenow_notification_enabled = appInt.connected__c;
				} else if(appInt.name == 'googlecalendar'){
					appConfigWrapperObj.integration_google_calendar_enabled = true;
				}
			}

			appConfigWrapperObj.integration_box_enabled = aa.box_integration_enabled__c;
			appConfigWrapperObj.integration_microsoft_teams_enabled = aa.Microsoft_Teams_Integration_Enabled__c;
			appConfigWrapperObj.integration_okta_enabled = aa.Okta_Enabled__c;
			appConfigWrapperObj.integration_onelogin_enabled = aa.OneLogin_Enabled__c;
			appConfigWrapperObj.integration_workday_enabled = aa.PDS_Workday_Enabled__c;
			appConfigWrapperObj.integration_vbrick_enabled = aa.vbrick_enabled__c;
			appConfigWrapperObj.integration_google_analytics_enabled = aa.GA_Enabled__c;
			appConfigWrapperObj.integration_smartsearch_enabled = aa.External_search_app_connected__c; 
			appConfigWrapperObj.integration_ukg_pro_enabled = aa.PDS_UKG_Pro_Enabled__c;

			List<PackageLicense> listOfPackageLicense = [SELECT Id, AllowedLicenses, UsedLicenses, ExpirationDate, CreatedDate FROM PackageLicense where namespaceprefix=: 'Simpplr' WITH SECURITY_ENFORCED];                
			if(!listOfPackageLicense.isEmpty()){
				PackageLicense packageLicense = listOfPackageLicense[0];

				appConfigWrapperObj.allowed_licenses = packageLicense.AllowedLicenses;
				appConfigWrapperObj.used_licenses = packageLicense.UsedLicenses;
		
				appConfigWrapperObj.package_installation_date = Utility.dateTimeStringInGMT(packageLicense.CreatedDate, dateTimeFormat);
				appConfigWrapperObj.package_expiration_date = Utility.dateTimeStringInGMT(packageLicense.ExpirationDate, dateTimeFormat);
			}
			appConfigWrapperObj.record_created_at = Utility.dateTimeStringInGMT(aa.createddate, dateTimeFormat);
			appConfigWrapperObj.record_updated_at = Utility.dateTimeStringInGMT(aa.lastmodifieddate, dateTimeFormat);
			List<AnalyticsWrapper.App_Config> appCOnfigWrapperList = new List<AnalyticsWrapper.App_Config>();
			appCOnfigWrapperList.add(appConfigWrapperObj);
			sendDataToAWS('app_config', appCOnfigWrapperList);
		}
	}

	public void sendUserProvisioningConfigToAWS(sObject[] listOfsObject) {
		List<User_Provisioning_Config__c> userProvList = (List<User_Provisioning_Config__c>)listOfsObject;
        if(userProvList != null && userProvList.isEmpty() == false){
			AnalyticsWrapper.User_Provisioning_Config userProvWrapperObj = new AnalyticsWrapper.User_Provisioning_Config();
            User_Provisioning_Config__c up = userProvList[0];
			userProvWrapperObj.id = organizationId + String.valueOf(up	.id).subString(0,15);
			userProvWrapperObj.org_id = organizationId;
			userProvWrapperObj.org_name = UserInfo.getOrganizationName();
			userProvWrapperObj.about = up.About__c;
			userProvWrapperObj.birthdate = up.Birthdate__c;
			userProvWrapperObj.birthdate_field = up.Birthdate_Field__c;
			userProvWrapperObj.city = up.City__c;
			userProvWrapperObj.company_name = up.Company_Name__c;
			userProvWrapperObj.company_name_field = up.Company_Name_Field__c;
			userProvWrapperObj.country = up.Country__c;
			userProvWrapperObj.create_new_users = up.Create_New_Users__c;
			userProvWrapperObj.deactive_user = up.Deactive_User__c;
			userProvWrapperObj.department = up.Department__c;
			userProvWrapperObj.division = up.Division__c;
			userProvWrapperObj.employee_number = up.Employee_Number__c;
			userProvWrapperObj.fax = up.Fax__c;
			userProvWrapperObj.federationid = up.FedrationId__c;
			userProvWrapperObj.firstname = up.Firstname__c;
			userProvWrapperObj.joining_date = up.Joining_Date__c;
			userProvWrapperObj.joining_date_field = up.Joining_Date_Field__c;
			userProvWrapperObj.language = up.Language__c;
			userProvWrapperObj.language_type = up.Language_Type__c;
			userProvWrapperObj.lastname = up.Lastname__c;
			userProvWrapperObj.locale = up.Locale__c;
			userProvWrapperObj.locale_type = up.Locale_Type__c;
			userProvWrapperObj.manager = up.Manager__c;
			userProvWrapperObj.manager_unique_identifier = up.Manager_Unique_Identifier__c;
			userProvWrapperObj.mobilephone = up.MobilePhone__c;
			userProvWrapperObj.phone = up.Phone__c;
			userProvWrapperObj.phoneextension = up.PhoneExtension__c;
			userProvWrapperObj.postalcode = up.PostalCode__c;
			userProvWrapperObj.profile = up.Profile__c;
			userProvWrapperObj.profile_type = up.Profile_Type__c;
			userProvWrapperObj.provisioning_source = up.Provisioning_Source__c;
			userProvWrapperObj.query_filter = up.Query_Filter__c;
			userProvWrapperObj.send_emails = up.Send_Emails__c;
			userProvWrapperObj.state = up.State__c;
			userProvWrapperObj.street = up.Street__c;
			userProvWrapperObj.timezone = up.Timezone__c;
			userProvWrapperObj.timezonesidkey = up.TimezoneSidKey__c;
			userProvWrapperObj.unique_identifier = up.Unique_Identifier__c;
			userProvWrapperObj.user_email = up.User_Email__c;
			userProvWrapperObj.user_provisioning_config_name = up.Name;
			userProvWrapperObj.user_title = up.User_Title__c;
			userProvWrapperObj.username = up.Username__c;
			userProvWrapperObj.username_suffix = up.Username_Suffix__c;
			userProvWrapperObj.created_at = Utility.dateTimeStringInGMT(up.createddate, dateTimeFormat);
			userProvWrapperObj.updated_at = Utility.dateTimeStringInGMT(up.lastmodifieddate, dateTimeFormat);
			List<AnalyticsWrapper.User_Provisioning_Config> userProvWrapperList = new List<AnalyticsWrapper.User_Provisioning_Config>();
            userProvWrapperList.add(userProvWrapperObj);
           	sendDataToAWS('user_provisioning_config', userProvWrapperList);
		}

	}
	public void sendFeedItemDataToAWS(sObject[] listOfsObject, String feedTypeArg){
		List<AnalyticsWrapper.FeedItem> listOfFeedItemWrap = new List<AnalyticsWrapper.FeedItem>();
		Map<Id, FeedItem> mapOfFeedItemIDWithFeedObj = new Map<Id, FeedItem>((List<FeedItem>)listOfsObject);
       	AnalyticsWrapper.FeedItem feedItemWrapObj;
		List<Feed_Cache__c> listOfFeedCache = new List<Feed_Cache__c>();
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', mapOfFeedItemIDWithFeedObj.keySet());
		String query = 'SELECT Id, Context__c, Feed_Comment_Id__c, Feed_Id__c,  '+
				' Feed_Item_Type__c, Feed_Post_Type__c, Group_Mention_1__c, '+
				' group_Mention_2__c, Group_Mentions__c , Is_Deleted__c ,Mention_1__c, Mention_2__c, '+
				' Mentions__c '+
				' FROM Feed_Cache__c  '+
				' WHERE Is_Deleted__c=false AND Feed_Id__c IN :soqlParam1'+
				' AND Feed_Post_Type__c = \'Post\'';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		listOfFeedCache = (List<Feed_Cache__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		Map<String, Feed_Cache__c> mapOfFeedItemIdWithObj = new Map<String, Feed_Cache__c>();
		
		if (!listOfFeedCache.isEmpty()) {

			for (Feed_Cache__c feedCacheObj: listOfFeedCache) {
				mapOfFeedItemIdWithObj.put(feedCacheObj.Feed_Id__c, feedCacheObj);
			}

		}

       	for (FeedItem feedObj: mapOfFeedItemIDWithFeedObj.values()) {
        	feedItemWrapObj = new AnalyticsWrapper.FeedItem();
			feedItemWrapObj.id = organizationId + String.valueOf(feedObj.id).subString(0,15);
			feedItemWrapObj.feed_item_id = feedObj.id;
			feedItemWrapObj.comment_count = feedObj.commentCount;
			feedItemWrapObj.has_content = feedObj.hasContent;
			feedItemWrapObj.like_count = feedObj.likeCount;
			feedItemWrapObj.link_url = feedObj.linkUrl;
			feedItemWrapObj.title = feedObj.title;
			feedItemWrapObj.type = feedObj.type;
			feedItemWrapObj.is_deleted = feedObj.isDeleted;
			feedItemWrapObj.parent_type = feedObj.parent.Type;
			feedItemWrapObj.created_by_id = feedObj.createdById;
			feedItemWrapObj.parent_id = feedObj.parentId;
			feedItemWrapObj.record_date = Utility.dateTimeStringInGMT(feedObj.createddate, dateTimeFormat);
			
			if ('people'.equalsIgnoreCase(feedTypeArg)) {
				feedItemWrapObj.org_id_people_id = organizationId + String.valueOf(feedObj.parentId).subString(0,15);

			} else if ('site'.equalsIgnoreCase(feedTypeArg)) {
				feedItemWrapObj.org_id_site_id = organizationId + String.valueOf(feedObj.parentId).subString(0,15);

			} else if ('content'.equalsIgnoreCase(feedTypeArg)) {
				feedItemWrapObj.org_id_content_id = organizationId + String.valueOf(feedObj.parentId).subString(0,15);
			}
			
			if (mapOfFeedItemIdWithObj.keySet().Contains(feedObj.id)) {
				Feed_Cache__c feedCacheObj = new Feed_Cache__c();
				feedCacheObj = mapOfFeedItemIdWithObj.get(feedObj.id);
				feedItemWrapObj.feed_item_type = feedCacheObj.feed_item_type__c ;
				feedItemWrapObj.feed_post_type = feedCacheObj.feed_post_type__c ;
				feedItemWrapObj.group_mention_1 = feedCacheObj.group_mention_1__c ;
				feedItemWrapObj.group_mention_2 = feedCacheObj.group_mention_2__c ;
				feedItemWrapObj.group_mention_3 = feedCacheObj.group_mention_3__c ;
				feedItemWrapObj.group_mention_4 = feedCacheObj.group_mention_4__c ;
				feedItemWrapObj.group_mention_5 = feedCacheObj.group_mention_5__c ;
				feedItemWrapObj.group_mentions = feedCacheObj.group_mentions__c ;
				feedItemWrapObj.is_deleted = feedCacheObj.is_deleted__c ;
				feedItemWrapObj.mention_1 = feedCacheObj.mention_1__c ;
				feedItemWrapObj.mention_2 = feedCacheObj.mention_2__c ;
				feedItemWrapObj.mention_3 = feedCacheObj.mention_3__c ;
				feedItemWrapObj.mention_4 = feedCacheObj.mention_4__c ;
				feedItemWrapObj.mention_5 = feedCacheObj.mention_5__c;
				feedItemWrapObj.mentions = feedCacheObj.mentions__c;
			}
			
           	listOfFeedItemWrap.add(feedItemWrapObj);
        }

        sendDataToAWS('feed_item', listOfFeedItemWrap);
	}

	public void sendFeedCommentDataToAWS(sObject[] listOfsObject){
		List<AnalyticsWrapper.FeedComment> listOfFeedCommentWrap = new List<AnalyticsWrapper.FeedComment>();
		Map<Id, FeedComment> mapOfFeedCommentIDWithCmntObj = new Map<Id, FeedComment>((List<FeedComment>)listOfsObject);

       	AnalyticsWrapper.FeedComment feedCommentWrapObj;
		List<Feed_Cache__c> listOfFeedCache = new List<Feed_Cache__c>();
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', mapOfFeedCommentIDWithCmntObj.keySet());
		String query = 'SELECT Id, Context__c, Feed_Comment_Id__c, Feed_Id__c,  '+
				' Feed_Item_Type__c, Feed_Post_Type__c, Group_Mention_1__c, '+
				' group_Mention_2__c, Group_Mentions__c , Is_Deleted__c ,Mention_1__c, Mention_2__c, '+
				' Mentions__c '+
				' FROM Feed_Cache__c  '+
				' WHERE Is_Deleted__c=false AND Feed_Comment_Id__c IN :soqlParam1'+
				' AND Feed_Post_Type__c = \'Comment\'';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		listOfFeedCache = (List<Feed_Cache__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		Map<String, Feed_Cache__c> mapOfFeedCmntIdWithObj = new Map<String, Feed_Cache__c>();
		
		if (!listOfFeedCache.isEmpty()) {

			for (Feed_Cache__c feedCacheObj: listOfFeedCache) {
				mapOfFeedCmntIdWithObj.put(feedCacheObj.Feed_Comment_Id__c, feedCacheObj);
			}

		}

       	for (FeedComment feedCmntObj: mapOfFeedCommentIDWithCmntObj.values()){
        	feedCommentWrapObj = new AnalyticsWrapper.FeedComment();
			feedCommentWrapObj.id = organizationId + String.valueOf(feedCmntObj.id).subString(0,15); 
			feedCommentWrapObj.feed_comment_id = feedCmntObj.id; 
			feedCommentWrapObj.comment_body = feedCmntObj.commentBody ;
			feedCommentWrapObj.comment_type = feedCmntObj.commentType ;
			feedCommentWrapObj.org_id_feed_item_id = organizationId + String.valueOf(feedCmntObj.feedItemId).subString(0,15); 
			feedCommentWrapObj.org_id_inserted_by_id = organizationId + String.valueOf(feedCmntObj.insertedById).subString(0,15); 
			feedCommentWrapObj.status = feedCmntObj.status ;
			feedCommentWrapObj.related_record_id = feedCmntObj.relatedRecordId ; 
			feedCommentWrapObj.created_by_id = feedCmntObj.createdById ; 
			feedCommentWrapObj.feed_item_id = feedCmntObj.FeedItemId ; 
			feedCommentWrapObj.parent_id = feedCmntObj.ParentId ; 
			feedCommentWrapObj.is_deleted = feedCmntObj.IsDeleted ;
			feedCommentWrapObj.record_date = Utility.dateTimeStringInGMT(feedCmntObj.createddate, dateTimeFormat);
			feedCommentWrapObj.org_id_created_by_id = organizationId + String.valueOf(feedCmntObj.createdById).subString(0,15); 

			if (mapOfFeedCmntIdWithObj.keySet().Contains(feedCmntObj.id)) {
				Feed_Cache__c feedCacheObj = new Feed_Cache__c();
				feedCacheObj = mapOfFeedCmntIdWithObj.get(feedCmntObj.id);
				feedCommentWrapObj.group_mention_1 = feedCacheObj.group_mention_1__c ;
				feedCommentWrapObj.group_mention_2 = feedCacheObj.group_mention_2__c ;
				feedCommentWrapObj.group_mention_3 = feedCacheObj.group_mention_3__c ;
				feedCommentWrapObj.group_mention_4 = feedCacheObj.group_mention_4__c ;
				feedCommentWrapObj.group_mention_5 = feedCacheObj.group_mention_5__c ;
				feedCommentWrapObj.group_mentions = feedCacheObj.group_mentions__c ;
				feedCommentWrapObj.is_deleted = feedCacheObj.is_deleted__c ;
				feedCommentWrapObj.mention_1 = feedCacheObj.mention_1__c ;
				feedCommentWrapObj.mention_2 = feedCacheObj.mention_2__c ;
				feedCommentWrapObj.mention_3 = feedCacheObj.mention_3__c ;
				feedCommentWrapObj.mention_4 = feedCacheObj.mention_4__c ;
				feedCommentWrapObj.mention_5 = feedCacheObj.mention_5__c;
				feedCommentWrapObj.mentions = feedCacheObj.mentions__c;
			}

           	listOfFeedCommentWrap.add(feedCommentWrapObj);
        }

        sendDataToAWS('feed_comment', listOfFeedCommentWrap);
	}
	
	public void sendFeedPollChoiceDataToAWS(sObject[] listOfsObject){
		List<AnalyticsWrapper.FeedPollChoice> listOfFeedPollChoiceWrap = new List<AnalyticsWrapper.FeedPollChoice>();
       	AnalyticsWrapper.FeedPollChoice feedPollChoiceWrapObj;

       	for (FeedPollChoice feedPollChObj: (List<FeedPollChoice>)listOfsObject){
        	feedPollChoiceWrapObj = new AnalyticsWrapper.FeedPollChoice();
			feedPollChoiceWrapObj.id = organizationId + String.valueOf(feedPollChObj.id).subString(0,15); 
			feedPollChoiceWrapObj.position = feedPollChObj.position;
			feedPollChoiceWrapObj.org_id_feed_item_id = organizationId + String.valueOf(feedPollChObj.feeditemId).subString(0,15); 
           	feedPollChoiceWrapObj.choice_body = feedPollChObj.choiceBody;
			feedPollChoiceWrapObj.feed_poll_choice_id = feedPollChObj.id;
			listOfFeedPollChoiceWrap.add(feedPollChoiceWrapObj);
        }

        sendDataToAWS('feed_poll_choice', listOfFeedPollChoiceWrap);
	}
	public void sendAnalticsContentReadershipListToAWS (sObject[] listOfsObject){
		List<AnalyticsWrapper.WeeklyContentReadershipData> listOfContentReadership = new List<AnalyticsWrapper.WeeklyContentReadershipData>();
		
		for(Analytics_Weekly_Content_Readership__c aObj: (List<Analytics_Weekly_Content_Readership__c>) listOfsObject) {
			AnalyticsWrapper.WeeklyContentReadershipData contentReadershipWrapperObj =new AnalyticsWrapper.WeeklyContentReadershipData()  ;
			contentReadershipWrapperObj.content=aObj.Content__c;
			contentReadershipWrapperObj.org_id = organizationId ;
			contentReadershipWrapperObj.org_id_content_id= organizationId + String.valueOf(aObj.Content__c).subString(0,15);
			contentReadershipWrapperObj.content_owner_subscription_count= Integer.valueOf(aObj.Content_Owner_Subscription_Count__c);
			contentReadershipWrapperObj.site_subscription_count=Integer.valueOf(aObj.Site_Member_Count__c);
			contentReadershipWrapperObj.week=Integer.valueOf(aObj.Week__c);
			contentReadershipWrapperObj.content_readership=Integer.valueOf(aObj.Content_Readership__c);
			if (aObj.Sync_Status__c == null) {
				aObj.Sync_Status__c = 1;
	
			} else if (aObj.Sync_Status__c > 5) {
				aObj.Sync_Status__c = 5;
			
			} else {
				aObj.Sync_Status__c = aObj.Sync_Status__c + 1;
			}
			
			listOfContentReadership.add(ContentReadershipWrapperObj);

		}
			sendDataToAWS('analytics_weekly_content_readership', listOfContentReadership);
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,Analytics_Weekly_Content_Readership__c>((List<Analytics_Weekly_Content_Readership__c>)listOfsObject), new List<Schema.SObjectField>{
				Analytics_Weekly_Content_Readership__c.Sync_Status__c
			});
		}
		public void sendPeopleExpertiseDataToAWS(sObject[] listOfsObject){
			List<AnalyticsWrapper.PeopleExpertise> listOfPeopleExpertise = new List<AnalyticsWrapper.PeopleExpertise>();
			   AnalyticsWrapper.PeopleExpertise peopleExpertise;
	
			   for (People_Expertise_Detail__c expertiseObj: (List<People_Expertise_Detail__c>)listOfsObject){
				peopleExpertise = new AnalyticsWrapper.PeopleExpertise();
				peopleExpertise.id = organizationId + String.valueOf(expertiseObj.id).subString(0,15); 
				peopleExpertise.org_id = organizationId ;
				peopleExpertise.expertise_name = expertiseObj.People_Expertise__r.Expertise__r.Display_Name__c;
				peopleExpertise.endorser_id = expertiseObj.Endorser__c ;
				if(String.isNotBlank(expertiseObj.Endorser__c)) {
					peopleExpertise.org_id_endorser_id = organizationId + String.valueOf(expertiseObj.Endorser__c).subString(0,15);
				}
				peopleExpertise.people_id = expertiseObj.People_Expertise__r.People__c ;
				if(String.isNotBlank(expertiseObj.People_Expertise__r.People__c)) {
					peopleExpertise.org_id_people_id = organizationId + String.valueOf(expertiseObj.People_Expertise__r.People__c).subString(0,15);
				}
				peopleExpertise.is_self_endorsed = expertiseObj.People_Expertise__r.Is_Self_Endorsed__c ;
				peopleExpertise.is_self_hidden = expertiseObj.People_Expertise__r.is_self_hidden__c ;
				if (expertiseObj.Sync_Status__c == null) {
					expertiseObj.Sync_Status__c = 1;
				
				} else if (expertiseObj.Sync_Status__c > 5) {
					expertiseObj.Sync_Status__c = 5;
				
				} else {
					expertiseObj.Sync_Status__c = expertiseObj.Sync_Status__c + 1;
				}				
				listOfPeopleExpertise.add(peopleExpertise);

			}
	
			sendDataToAWS('people_expertise', listOfPeopleExpertise);
			update listOfsObject;
		}
		public void sendAnalyticsFileDataToAWS(sObject[] listOfsObject){
			List<AnalyticsWrapper.AnalyticsFile> listOfAnalyticsFile = new List<AnalyticsWrapper.AnalyticsFile>();
			   AnalyticsWrapper.analyticsFile analyticsFile;
	
			   for (Analytics_File__c fileObj: (List<Analytics_File__c>)listOfsObject){
				analyticsFile = new AnalyticsWrapper.analyticsFile();
				analyticsFile.id = organizationId + String.valueOf(fileObj.id).subString(0,15); 
				analyticsFile.org_id = organizationId ;
				analyticsFile.action = fileObj.action__c;
				analyticsFile.context = fileObj.Context__c;
				analyticsFile.file_id = fileObj.File_Id__c;
				analyticsFile.is_bookmarked = fileObj.Is_Bookmarked__c;
				analyticsFile.is_new = fileObj.Is_New__c;
				analyticsFile.file_name = fileObj.Name;
				analyticsFile.file_extension = fileObj.File_Extension__c;
				analyticsFile.owner_id = fileObj.Owner_Id__c;
				analyticsFile.provider = fileObj.Provider__c;
				analyticsFile.site_id = fileObj.Site_Id__c;
				if(String.isNotBlank(fileObj.Site_Id__c)) {
					analyticsFile.org_id_site_id = organizationId + String.valueOf(fileObj.Site_Id__c).subString(0,15);
				}
				analyticsFile.size = Integer.valueof(fileObj.Size__c);
				analyticsFile.source = fileObj.Source__c;
				analyticsFile.title = fileObj.Title__c;
				analyticsFile.type = fileObj.Type__c;
				analyticsFile.created_at = Utility.dateTimeStringInGMT(fileObj.CreatedDate, dateTimeFormat);
				if (fileObj.Sync_Status__c == null) {
					fileObj.Sync_Status__c = 1;
				
				} else if (fileObj.Sync_Status__c > 5) {
					fileObj.Sync_Status__c = 5;
				
				} else {
					fileObj.Sync_Status__c = fileObj.Sync_Status__c + 1;
				}				
				listOfAnalyticsFile.add(analyticsFile);

			}
	
			sendDataToAWS('analytics_file', listOfAnalyticsFile);
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<id,Analytics_File__c>((List<Analytics_File__c>)listOfsObject),new List<Schema.SObjectField>{Analytics_File__c.Sync_Status__c});
		}

		public void sendFileDataToAWS(sObject[] listOfsObject){
			List<AnalyticsWrapper.File> listOfFile = new List<AnalyticsWrapper.File>();
			   AnalyticsWrapper.File file;
	
			   for (File__c fileObj: (List<File__c>)listOfsObject){
				file = new AnalyticsWrapper.file();
				file.id = organizationId + String.valueOf(fileObj.id).subString(0,15); 
				file.org_id = organizationId ;
				file.allow_comments = fileObj.Allow_Comments__c;
				file.author_id = fileObj.Author__c;
				if(String.isNotBlank(fileObj.Author__c)) {
					file.org_id_author_id = organizationId + String.valueOf(fileObj.Author__c).subString(0,15);
				}
				file.content_document = fileObj.Content_Document__c;
				file.content_name= fileObj.Content_Name__c;
				file.content_version = fileObj.Content_Version__c ;
				file.description = fileObj.Description__c;
				file.downloads = fileObj.Downloads__c;
				file.duration = fileObj.Duration__c;
				file.external_Id = fileObj.External_Id__c;
				file.feed_comment = fileObj.Feed_Comment__c;
				file.feed_item_id = fileObj.Feed_Item__c;
				file.fileInfo_last_updated_Datetime = Utility.dateTimeStringInGMT(fileObj.FileInfo_Last_Updated_DateTime__c,dateTimeFormat);
				file.folder_id = fileObj.Folder__c;
				if(String.isNotBlank(fileObj.Folder__c)) {
					file.org_id_folder_id = organizationId + String.valueOf(fileObj.Folder__c).subString(0,15);
				}
				file.is_deleted = fileObj.Is_Deleted__c;
				file.is_title_image = fileObj.Is_Title_Image__c;
				file.likes = fileObj.Likes__c;
				file.location = fileObj.Location__c;
				file.mime_type = fileObj.MIME_Type__c;
				file.order = fileObj.Order__c	;
				file.repository = fileObj.Repository__c;
				file.shares = fileObj.Shares__c;
				file.content_id = fileObj.Simpplr_Content__c;
				if(String.isNotBlank(fileObj.Simpplr_Content__c)) {
					file.org_id_content_id = organizationId + String.valueOf(fileObj.Simpplr_Content__c).subString(0,15);
				}
				file.site_id = fileObj.Site__c;
				if(String.isNotBlank(fileObj.Site__c)) {
					file.org_id_site_id = organizationId + String.valueOf(fileObj.Site__c).subString(0,15);
				}
				file.size = fileObj.Size__c;
				file.subscribers = fileObj.Subscribers__c;
				file.thumbnail_url = fileObj.Thumbnail_URL__c;
				file.title = fileObj.title__c;
				file.title_image_type = fileObj.Title_Image_Type__c;
				file.video_provider = fileObj.Video_Provider__c;
				file.views = fileObj.Views__c;
				file.sp_instance_id = fileObj.SP_Instance_Id__c;
				if (fileObj.Sync_Status__c == null) {
					fileObj.Sync_Status__c = 1;
				
				} else if (fileObj.Sync_Status__c > 5) {
					fileObj.Sync_Status__c = 5;
				
				} else {
					fileObj.Sync_Status__c = fileObj.Sync_Status__c + 1;
				}				
				listOfFile.add(file);

			}
	
			sendDataToAWS('file', listOfFile);
			update listOfsObject;
		}
		public void sendFolderDataToAWS(sObject[] listOfsObject){
			List<AnalyticsWrapper.Folder> listOfFolder = new List<AnalyticsWrapper.Folder>();
			   AnalyticsWrapper.Folder Folder;
	
			   for (Folder__c folderObj: (List<Folder__c>)listOfsObject){
				Folder = new AnalyticsWrapper.Folder();
				Folder.id = organizationId + String.valueOf(folderObj.id).subString(0,15); 
				Folder.org_id = organizationId ;
				Folder.box_collaboration_id = folderObj.Box_Collaboration_Id__c;
				Folder.efs_drive_id =folderObj.EFS_Drive_Id__c;
				Folder.efs_read_collaboration_id =folderObj.EFS_Read_Collaboration_Id__c;
				Folder.external_folder_id = folderObj.External_Folder_Id__c;
				Folder.efs_read_write_collaboration_id = folderObj.EFS_Read_Write_Collaboration_Id__c;
				Folder.efs_search_collaboration_id = folderObj.EFS_Search_Collaboration_Id__c;
				Folder.drive_type = folderObj.Drive_Type__c;
				Folder.is_external_system_folder = folderObj.Is_External_System_Folder__c;
				Folder.is_deleted = folderObj.Is_Deleted__c;
				Folder.is_hidden = folderObj.Is_Hidden__c;
				Folder.is_system_folder = folderObj.Is_System_Folder__c;
				Folder.linked_folder_owner = folderObj.Linked_Folder_Owner__c;
				Folder.name = folderObj.Name__c;
				Folder.parent_folder =  folderObj.Parent_Folder__c;
				Folder.path = folderObj.Path__c;
				Folder.people_id = folderObj.People__c;
				Folder.sp_instance_id = folderObj.SP_Instance_Id__c;

				if(String.isNotBlank(folderObj.People__c)) {
					Folder.org_id_people_id = organizationId + String.valueOf(folderObj.People__c).subString(0,15);
				}
				Folder.permissions	= folderObj.Permissions__c;
				Folder.site_id = folderObj.Site__c;
				if(String.isNotBlank(folderObj.Site__c)) {
					Folder.org_id_site_id = organizationId + String.valueOf(folderObj.Site__c).subString(0,15);
				}
				Folder.type = folderObj.Type__c;
				if (folderObj.Sync_Status__c == null) {
					folderObj.Sync_Status__c = 1;
				
				} else if (folderObj.Sync_Status__c > 5) {
					folderObj.Sync_Status__c = 5;
				
				} else {
					folderObj.Sync_Status__c = folderObj.Sync_Status__c + 1;
				}				
				listOfFolder.add(Folder);

			}
	
			sendDataToAWS('folder', listOfFolder);
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,Folder__c>((List<Folder__c>)listOfsObject), new List<Schema.SObjectField>{
				Folder__c.Sync_Status__c
			});
		}
		
		public void sendContentInteractionDataToAWS(sObject[] listOfsObject){
			List<AnalyticsWrapper.ContentInteraction> listOfContentInteraction = new List<AnalyticsWrapper.ContentInteraction>();
			   AnalyticsWrapper.ContentInteraction contentInteraction;
			   for (Content_Interaction__c contentInteractionObj: (List<Content_Interaction__c>)listOfsObject){
				contentInteraction = new AnalyticsWrapper.ContentInteraction();
				contentInteraction.id = organizationId + String.valueOf(contentInteractionObj.id).subString(0,15); 
				contentInteraction.org_id = organizationId ;
				contentInteraction.unique_key = contentInteractionObj.Unique_Key__c;
				contentInteraction.people_id = contentInteractionObj.People__c;
				contentInteraction.content_id =contentInteractionObj.Content__c;
				contentInteraction.view_count =contentInteractionObj.View_Count__c;
				contentInteraction.last_activity_date = Utility.dateTimeStringInGMT(contentInteractionObj.LastActivityDate, dateTimeFormat);
				contentInteraction.last_modified_date = Utility.dateTimeStringInGMT(contentInteractionObj.LastModifiedDate, dateTimeFormat);
				contentInteraction.created_date = Utility.dateTimeStringInGMT(contentInteractionObj.CreatedDate, dateTimeFormat);
				contentInteraction.is_deleted = contentInteractionObj.IsDeleted;
				contentInteraction.is_read = contentInteractionObj.Is_Read__c;
				contentInteraction.scroll_depth = contentInteractionObj.Scroll_Depth__c;
				if(String.isNotBlank(contentInteractionObj.People__c)) {
					contentInteraction.org_id_people_id = organizationId + String.valueOf(contentInteractionObj.People__c).subString(0,15);
				}
				if (contentInteractionObj.Sync_Status__c == null) {
					contentInteractionObj.Sync_Status__c = 1;
				
				} else if (contentInteractionObj.Sync_Status__c > 5) {
					contentInteractionObj.Sync_Status__c = 5;
				
				} else {
					contentInteractionObj.Sync_Status__c = contentInteractionObj.Sync_Status__c + 1;
				}				
				listOfContentInteraction.add(contentInteraction);

			}
			sendDataToAWS('content_interaction', listOfContentInteraction);
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,Content_Interaction__c>((List<Content_Interaction__c>)listOfsObject), new List<Schema.SObjectField>{
				Content_Interaction__c.Sync_Status__c
			});
		}

		public void sendLikesDataToAWS(sObject[] listOfsObject){
			List<AnalyticsWrapper.Likes> listOfLikes = new List<AnalyticsWrapper.Likes>();
			AnalyticsWrapper.Likes likes;
			Map<String,String> feedItemIdVsSiteIdMap = getFeedItemIdVsSiteIdMap(listOfsObject, 'like');
			for (Like__c likesObj: (List<Like__c>)listOfsObject){
				likes = new AnalyticsWrapper.Likes();
				likes.id = organizationId + String.valueOf(likesObj.id).subString(0,15); 
				likes.org_id = organizationId ;
				likes.people_id = likesObj.People__c;
				if(String.isNotBlank(likesObj.People__c)) {
					likes.org_id_people_id = organizationId + String.valueOf(likesObj.People__c).subString(0,15);
				}
				likes.like_receiver = likesObj.Like_Receiver__c;
				likes.Is_deleted = likesObj.Is_Deleted__c;
				likes.file= likesObj.File__c;
				likes.content_id = likesObj.Content__c;
				if(String.isNotBlank(likesObj.Content__c)) {
					likes.org_id_content_id = organizationId + String.valueOf(likesObj.Content__c).subString(0,15);
				}
				likes.site = likesObj.Content__r.site__c;
				if(String.isNotBlank(likesObj.Content__r.site__c)) {
					likes.org_id_site_id = organizationId + String.valueOf(likesObj.Content__r.site__c).subString(0,15);
				}
				likes.feed_item_id = likesObj.Feed_Item_Id__c;
				if(String.isNotBlank(likesObj.Feed_Item_Id__c)) {
					likes.org_id_feed_item_id = organizationId + String.valueOf(likesObj.Feed_Item_Id__c).subString(0,15);
					likes.site = feedItemIdVsSiteIdMap != null && feedItemIdVsSiteIdMap.containsKey(likesObj.Feed_Item_Id__c) && feedItemIdVsSiteIdMap.get(likesObj.Feed_Item_Id__c) != null ? feedItemIdVsSiteIdMap.get(likesObj.Feed_Item_Id__c) :'';
				}
				likes.feed_item_comment_id = likesObj.Feed_Item_Comment_Id__c ;
				likes.external_file_id = likesObj.External_File_Id__c;
				likes.record_date = Utility.dateTimeStringInGMT(likesObj.createddate, dateTimeFormat);
				if (likesObj.Sync_Status__c == null) {
					likesObj.Sync_Status__c = 1;
				
				} else if (likesObj.Sync_Status__c > 5) {
					likesObj.Sync_Status__c = 5;
				
				} else {
					likesObj.Sync_Status__c = likesObj.Sync_Status__c + 1;
				}				
				listOfLikes.add(likes);

			}
			sendDataToAWS('likes', listOfLikes);
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,Like__c>((List<Like__c>)listOfsObject), new List<Schema.SObjectField>{
				Like__c.Sync_Status__c
			});
		}

		public Map<String,String> getFeedItemIdVsSiteIdMap(sObject[] listOfsObject, String objectVal){
			Map<String,String> feedItemIdVsSiteIdMap = new Map<String,String>();
			Set<String> feedItemIdsSet = new Set<String>();
			Map<String,String> chatterGrpIdVsSiteIdMap = new Map<String,String>();
			Map<String,String> feedItemIdVsChatterGrpIdMap = new Map<String,String>();
			if('like'.equalsIgnoreCase(objectVal)){
				for (Like__c likesObj: (List<Like__c>)listOfsObject){
					if(String.isNotBlank(likesObj.Feed_Item_Id__c)){
						feedItemIdsSet.add(likesObj.Feed_Item_Id__c);
					}
				}
			}else{
				for (Share__c shareObj: (List<Share__c>)listOfsObject){
					if(String.isNotBlank(shareObj.Feed_Item_Id__c)){
						feedItemIdsSet.add(shareObj.Feed_Item_Id__c);
					}
				}
			}
			
			if(!feedItemIdsSet.isEmpty()){
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', feedItemIdsSet); 
				String feedQuery = 'SELECT Id, ParentId from FeedItem where Id IN:soqlParam1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<FeedItem> feedObjectList = (List<FeedItem>)SIMPESAPI.accessController().queryAsUser(feedQuery, soqlParamMap);
				if(!feedObjectList.isEmpty()){
					for(FeedItem feedObj: feedObjectList){
						if(feedObj.ParentId != null && String.valueOf(feedObj.ParentId).startsWith('0F9')){
							feedItemIdVsChatterGrpIdMap.put(String.valueOf(feedObj.Id), String.valueOf(feedObj.ParentId));
						}
					}
					Map<String, Object> soqlParamMap2 = new Map<String, Object>();
					soqlParamMap2.put('soqlParam1', feedItemIdVsChatterGrpIdMap.values()); 
					String siteQuery = 'SELECT Id, chatter_group_id__c from simpplr_site__c where chatter_group_id__c IN:soqlParam1';
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					List<simpplr_site__c> siteObjectList = (List<simpplr_site__c>)SIMPESAPI.accessController().queryAsUser(siteQuery, soqlParamMap2);
					if(!siteObjectList.isEmpty()){
						for(simpplr_site__c siteObj: siteObjectList){
							chatterGrpIdVsSiteIdMap.put(siteObj.Chatter_Group_Id__c, siteObj.Id);
						}

						for(String feedItemId:feedItemIdVsChatterGrpIdMap.keySet()){
							feedItemIdVsSiteIdMap.put(feedItemId, chatterGrpIdVsSiteIdMap.get(feedItemIdVsChatterGrpIdMap.get(feedItemId)));
						}
					}
				}
			}
			
			return feedItemIdVsSiteIdMap;
		}

		public void sendBookmarkDataToAWS(sObject[] listOfsObject){
			List<AnalyticsWrapper.Bookmark> listOfBookmark = new List<AnalyticsWrapper.Bookmark>();
			AnalyticsWrapper.Bookmark bookmark;
			for (Bookmark__c bookmarkObj: (List<Bookmark__c>)listOfsObject){
				bookmark = new AnalyticsWrapper.Bookmark();
				bookmark.id = organizationId + String.valueOf(bookmarkObj.id).subString(0,15); 
				bookmark.org_id = organizationId ;
				bookmark.people_id = bookmarkObj.People__c;
				if(String.isNotBlank(bookmarkObj.People__c)) {
					bookmark.org_id_people_id = organizationId + String.valueOf(bookmarkObj.People__c).subString(0,15);
				}
				bookmark.bookmark_receiver = bookmarkObj.Bookmark_Receiver__c;
				bookmark.Is_deleted = bookmarkObj.Is_Deleted__c;
				bookmark.feed_item_id = bookmarkObj.Feed_Item_Id__c;
				if(String.isNotBlank(bookmarkObj.Feed_Item_Id__c)) {
					bookmark.org_id_feed_item_id = organizationId + String.valueOf(bookmarkObj.Feed_Item_Id__c).subString(0,15);
				}
				bookmark.external_file_id = bookmarkObj.External_File_Id__c;
				bookmark.content_id = bookmarkObj.Simpplr_Content__c;
				if(String.isNotBlank(bookmarkObj.Simpplr_Content__c)) {
					bookmark.org_id_content_id = organizationId + String.valueOf(bookmarkObj.Simpplr_Content__c).subString(0,15);
				}
				bookmark.record_date = Utility.dateTimeStringInGMT(bookmarkObj.createddate, dateTimeFormat);
				bookmark.site = bookmarkObj.Simpplr_Site__c;
				if(String.isNotBlank(bookmarkObj.Simpplr_Site__c)) {
					bookmark.org_id_site_id = organizationId + String.valueOf(bookmarkObj.Simpplr_Site__c).subString(0,15);
				}
				
				if (bookmarkObj.Sync_Status__c == null) {
					bookmarkObj.Sync_Status__c = 1;
				
				} else if (bookmarkObj.Sync_Status__c > 5) {
					bookmarkObj.Sync_Status__c = 5;
				
				} else {
					bookmarkObj.Sync_Status__c = bookmarkObj.Sync_Status__c + 1;
				}				
				listOfBookmark.add(bookmark);

			}
			sendDataToAWS('bookmark', listOfBookmark);
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,Bookmark__c>((List<Bookmark__c>)listOfsObject), new List<Schema.SObjectField>{
				Bookmark__c.Sync_Status__c
			});
		}

		public void sendShareDataToAWS(sObject[] listOfsObject){
			List<AnalyticsWrapper.Share> listOfshare = new List<AnalyticsWrapper.Share>();
			AnalyticsWrapper.Share share;
			Map<String,String> feedItemIdVsSiteIdMap = getFeedItemIdVsSiteIdMap(listOfsObject, 'share');
			for (Share__c shareObj: (List<Share__c>)listOfsObject){
				share = new AnalyticsWrapper.Share();
				share.id = organizationId + String.valueOf(shareObj.id).subString(0,15); 
				share.org_id = organizationId ;
				share.people_id = shareObj.People__c;
				if(String.isNotBlank(shareObj.People__c)) {
					share.org_id_people_id = organizationId + String.valueOf(shareObj.People__c).subString(0,15);
				}
				share.share_receiver = shareObj.Share_Receiver__c;
				share.Is_deleted = shareObj.Is_Deleted__c;
				share.external_file_id = shareObj.External_File_Id__c;
				share.content_id = shareObj.Content__c;
				if(String.isNotBlank(shareObj.Content__c)) {
					share.org_id_content_id = organizationId + String.valueOf(shareObj.Content__c).subString(0,15);
				}
				share.record_date = Utility.dateTimeStringInGMT(shareObj.createddate, dateTimeFormat);
				share.site = shareObj.Content__r.site__c;
				if(String.isNotBlank(shareObj.Content__r.site__c)) {
					share.org_id_site_id = organizationId + String.valueOf(shareObj.Content__r.site__c).subString(0,15);
				}
				share.feed_item_id = shareObj.Feed_Item_Id__c;
				if(String.isNotBlank(shareObj.Feed_Item_Id__c)) {
					share.org_id_feed_item_id = organizationId + String.valueOf(shareObj.Feed_Item_Id__c).subString(0,15);
					share.site = feedItemIdVsSiteIdMap != null && feedItemIdVsSiteIdMap.containsKey(shareObj.Feed_Item_Id__c) && feedItemIdVsSiteIdMap.get(shareObj.Feed_Item_Id__c) != null ? feedItemIdVsSiteIdMap.get(shareObj.Feed_Item_Id__c) :'';
				}
				
				if (shareObj.Sync_Status__c == null) {
					shareObj.Sync_Status__c = 1;
				
				} else if (shareObj.Sync_Status__c > 5) {
					shareObj.Sync_Status__c = 5;
				
				} else {
					shareObj.Sync_Status__c = shareObj.Sync_Status__c + 1;
				}				
				listOfShare.add(share);

			}
			sendDataToAWS('share', listOfShare);
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,Share__c>((List<Share__c>)listOfsObject), new List<Schema.SObjectField>{
				Share__c.Sync_Status__c
			});
		}

	
}