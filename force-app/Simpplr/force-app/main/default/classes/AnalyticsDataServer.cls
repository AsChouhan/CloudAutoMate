/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class AnalyticsDataServer extends DataServer{ 
	
	/**
		public transient final String STR_KEY_1 = 'date.month.short.01';
		public transient final String STR_KEY_2 = 'date.month.short.02';
		public transient final String STR_KEY_3 = 'date.month.short.03';
		public transient final String STR_KEY_4 = 'date.month.short.04';
		public transient final String STR_KEY_5 = 'date.month.short.05';
		public transient final String STR_KEY_6 = 'date.month.short.06';
		public transient final String STR_KEY_7 = 'date.month.short.07';
		public transient final String STR_KEY_8 = 'date.month.short.08';
		public transient final String STR_KEY_9 = 'date.month.short.09';
		public transient final String STR_KEY_10 = 'date.month.short.10';
		public transient final String STR_KEY_11 = 'date.month.short.11';
		public transient final String STR_KEY_12 = 'date.month.short.12';

		public transient final String STR_KEY_13 = 'analytics.sites_tiles.unlisted_site';
		public transient final String STR_KEY_14 = 'analytics.content_tiles.private_site_content';
		public transient final String STR_KEY_15 = 'analytics.content_tiles.unlisted_site_content';

		public transient final String STR_KEY_16 = 'analytics.profile_completeness.profile_photo';
		public transient final String STR_KEY_17 = 'analytics.profile_completeness.phone';
		public transient final String STR_KEY_18 = 'analytics.profile_completeness.about_text';
		public transient final String STR_KEY_19 = 'analytics.profile_completeness.birthday';

		public transient final String STR_KEY_20 = 'analytics.knowledge_page.published';
		public transient final String STR_KEY_21 = 'analytics.knowledge_page.validated';
		public transient final String STR_KEY_22 = 'analytics.knowledge_page.validation_expired';
		public transient final String STR_KEY_23 = 'analytics.knowledge_page.validation_required';

		public transient final String STR_KEY_24 = 'analytics.content_referral.home_carousel';
		public transient final String STR_KEY_25 = 'analytics.content_referral.site_carousel';
		public transient final String STR_KEY_26 = 'analytics.content_referral.home_feed';
		public transient final String STR_KEY_27 = 'analytics.content_referral.site_feed';
		public transient final String STR_KEY_30 = 'analytics.content_referral.home_dashboard_tile';
		public transient final String STR_KEY_31 = 'analytics.content_referral.site_dashboard_tile';
		public transient final String STR_KEY_32 = 'analytics.content_referral.favorites';
		public transient final String STR_KEY_33 = 'analytics.content_referral.must_read_listing';
		public transient final String STR_KEY_34 = 'analytics.content_referral.events_listing';
		public transient final String STR_KEY_35 = 'analytics.content_referral.user_published';
		public transient final String STR_KEY_36 = 'analytics.content_referral.my_content';
		public transient final String STR_KEY_37 = 'analytics.content_referral.site_pages_content';
		public transient final String STR_KEY_38 = 'analytics.content_referral.search_results';
		public transient final String STR_KEY_40 = 'analytics.content_referral.search_auto_complete';
		public transient final String STR_KEY_42 = 'analytics.content_referral.recent_search';
		public transient final String STR_KEY_43 = 'analytics.content_referral.topic_content_listing';
		public transient final String STR_KEY_44 = 'analytics.content_referral.global_analytics_content_tab';
		public transient final String STR_KEY_49 = 'analytics.content_referral.top_stories';
		public transient final String STR_KEY_50 = 'analytics.content_referral.newsletter';
		public transient final String STR_KEY_51 = 'analytics.content_referral.activity_notifications_email';
		public transient final String STR_KEY_52 = 'analytics.content_referral.slack';
		public transient final String STR_KEY_53 = 'analytics.content_referral.in_app_notification';
		public transient final String STR_KEY_54 = 'analytics.content_referral.site_content_tab';
		public transient final String STR_KEY_55 = 'analytics.content_referral.sms_must_read';
		public transient final String STR_KEY_56 = 'analytics.content_referral.related_content';
		public transient final String STR_KEY_57 = 'analytics.content_referral.analytics_monthly_report';
		public transient final String STR_KEY_58 = 'analytics.content_referral.content_notifications';
		public transient final String STR_KEY_59 = 'analytics.content_referral.global_auto_complete';
		public transient final String STR_KEY_60 = 'analytics.content_referral.home_feed_smart_post';
		public transient final String STR_KEY_61 = 'analytics.content_referral.site_smart_feed_onboarding_section';
		public transient final String STR_KEY_62 = 'analytics.content_referral.site_content_onboarding_section';
		public transient final String STR_KEY_63 = 'analytics.content_referral.home_onboarding_smart_post';
		
	**/
	/*Page Group Translation
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_ALERTS_LISTING { get { return labelMap.get('analytics.page_group.alerts_listing');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_ALERT_ANALYTICS { get { return labelMap.get('analytics.page_group.analytics');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_AUDIENCES_LISTING { get { return labelMap.get('analytics.page_group.audiences_listing');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_SOCIAL_CAMPAIGNS_LISTING { get { return labelMap.get('analytics.page_group.social_campaigns_listing');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_HOME_FEED { get { return labelMap.get('analytics.page_group.home_feed');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_HOME_FEED_SINGLE_POST { get { return labelMap.get('analytics.page_group.home_feed_single_post');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_HOME_DASHBOARD { get { return labelMap.get('analytics.page_group.home_dashboard');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_MANAGE_APP { get { return labelMap.get('analytics.page_group.manage_app');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_MANAGE_CONTENT { get { return labelMap.get('analytics.page_group.manage_content');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_MANAGE_SITES { get { return labelMap.get('analytics.page_group.manage_sites');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_MANAGE_TOPICS { get { return labelMap.get('analytics.page_group.manage_topics');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_MUST_READS { get { return labelMap.get('analytics.page_group.must_reads');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_MY_SETTINGS { get { return labelMap.get('analytics.page_group.my_settings');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_NEWSLETTER { get { return labelMap.get('analytics.page_group.newsletter');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_NOTIFICATION { get { return labelMap.get('analytics.page_group.notifications');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_ORG_CHART { get { return labelMap.get('analytics.page_group.org_chart');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_PEOPLE { get { return labelMap.get('analytics.page_group.people');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_PRIVATE_SITE_FOLLOW_REQUEST { get { return labelMap.get('analytics.page_group.private_site_follow_request');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_PROFILE{ get { return labelMap.get('analytics.page_group.profile');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_PROFILE_CALENDAR { get { return labelMap.get('analytics.page_group.profile_calendar');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_SEARCH_RESULTS { get { return labelMap.get('analytics.page_group.search_results');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_SEGEMENTS_SUBSCRIPTIONS { get { return labelMap.get('analytics.page_group.segments_subscriptions');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_SERVICE_NOW { get { return labelMap.get('analytics.page_group.service_now');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_SITE_ABOUT { get { return labelMap.get('analytics.page_group.site_about');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_SITE_ADD { get { return labelMap.get('analytics.page_group.site_add');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_SITE_ALBUMS { get { return labelMap.get('analytics.page_group.site_albums');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_DASHBOARD { get { return labelMap.get('analytics.page_group.site_dashboard');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_SITE_EDIT { get { return labelMap.get('analytics.page_group.site_edit');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_SITE_EVENTS { get { return labelMap.get('analytics.page_group.site_events');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_SITE_FEED { get { return labelMap.get('analytics.page_group.site_feed');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_SITE_FILES { get { return labelMap.get('analytics.page_group.site_files');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_SITE_PAGES { get { return labelMap.get('analytics.page_group.site_pages');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_SITES { get { return labelMap.get('analytics.page_group.sites');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_TOPIC_DETAIL { get { return labelMap.get('analytics.page_group.topic_detail');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_CONTENT_DETAIL { get { return labelMap.get('analytics.page_group.content_detail');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_EDIT_CONTENT { get { return labelMap.get('analytics.page_group.edit_content');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_ADD_CONTENT { get { return labelMap.get('analytics.page_group.add_content');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_FILE_DETAIL { get { return labelMap.get('analytics.page_group.file_detail');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_FAVORITES { get { return labelMap.get('analytics.page_group.favorites');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_USER_PUBLISHED_CONTENT { get { return labelMap.get('analytics.page_group.user_published_content');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_SITE_CONTENT_LISTING { get { return labelMap.get('analytics.page_group.site_content_listing');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_SITES_LISTING { get { return labelMap.get('analytics.page_group.sites_listing');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_EVENTS { get { return labelMap.get('analytics.page_group.events');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_APPS_AND_LINKS { get { return labelMap.get('analytics.page_group.apps_and_links');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_VIDEO_DETAIL { get { return labelMap.get('analytics.page_group.video_detail');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_QUESTIONS_DETAILS { get { return labelMap.get('analytics.page_group.questions_details');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_MANAGE_QUESTION { get { return labelMap.get('analytics.page_group.manage_question');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_MANAGE_VIDEOS { get { return labelMap.get('analytics.page_group.manage_videos');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_ANSWERS_DETAILS { get { return labelMap.get('analytics.page_group.answers_details');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_ONBOARDING { get { return labelMap.get('analytics.page_group.onboarding');}}
	public transient final String STR_KEY_ANALYTICS_PAGE_GROUP_RECOGNITION_CENTER { get { return labelMap.get('analytics.page_group.recognition_center');}}
	*/
	private AnalyticsDao analyticsDaoObj = new AnalyticsDao();
	private ExternalAnalyticsService externalAnalyticsServiceObj = new ExternalAnalyticsService();
	
	private final String ACTION_GET_CONTENT_POPULAR = 'getContentPopularity';
	private final String ACTION_GET_GOVERNANCE_LIST = 'getGovernanceList';
	private final String ACTION_GET_CONTENT_VIEWS = 'getContentViews';
	private final String ACTION_GET_CONTENT_VIEWS_CSV = 'getContentViewsCsv';
	private final String ACTION_GET_CONTENT_VIEWS_TOP_DEPARTMENTS_CSV = 'getContentViewsTopDepartmentsCsv';
	private final String ACTION_GET_CONTENT_VIEWS_TOP_LOCATIONS_CSV = 'getContentViewsTopLocationsCsv';
	private final String ACTION_GET_CONTENT_VIEWS_LIST ='getContentViewsList';
	private final String ACTION_GET_VIEWS_LIST ='getViewsList';
	private final String ACTION_GET_CONTENT_VIEWS_OVER_TIME = 'getContentViewsOverTime';
	private final String ACTION_GET_CONTENT_VIEWS_OVER_TIME_CSV = 'getContentViewsOverTimeCsv';
	private final String ACTION_GET_VIEWS_OVER_TIME = 'getViewsOverTime';
	private final String ACTION_GET_VIEWS_OVER_TIME_CSV = 'getViewsOverTimeCsv';
	private final String ACTION_GET_CONTENT_VIEWS_BY_TYPE = 'getContentViewsByType';
	private final String ACTION_GET_CONTENT_VIEWS_BY_TYPE_CSV = 'getContentViewsByTypeCsv';
	private final String ACTION_GET_APP_PAGE_VIEWS = 'getAppPageViews';
	
	private final String ACTION_GET_ENGAGEMENT = 'getEngagement';
	private final String ACTION_GET_ENGAGEMENT_LIST = 'getEngagementList';

	private final String ACTION_GET_CONTENT_PUBLICATIONS = 'getContentPublications';
	private final String ACTION_GET_KNOWLEDGE_PAGE_STATS = 'getKnowledgePageStats';
	private final String ACTION_GET_CONTENT_KNOWLEDGE_PAGE_CSV = 'getKnowledgePageCsv';
	
	private final String ACTION_GET_SITE_VIEWS = 'getSiteViews';
	private final String ACTION_GET_SITE_VIEWS_TOTAL = 'getSiteViewsTotal';
	private final String ACTION_GET_PERFORMANCE_CONTENT = 'getPerformanceContent';
	
	private final String ACTION_GET_NEWSLETTERS = 'getNewsletters';
	private final String ACTION_GET_CAMPAIGNS = 'getCampaigns';
	private final String ACTION_GET_SITE_POPULAR = 'getSitePopularity';
	private final String ACTION_GET_ADOPTION_AVERAGE = 'getAdoptionAverage';
	
	private final String ACTION_GET_SITE_PUBLICATIONS = 'getSitePublications';
	private final String ACTION_GET_LOGINS_LIST = 'getLoginsList';
	private final String ACTION_GET_MONTHLY_REPORT = 'getMonthlyReports';
	private final String ACTION_GET_LOW_SITE_ACTIVITY = 'getLowActivitySites';
	private final String ACTION_GET_PEOPLE_PERFORMANCE = 'getPeoplePerformance';
	private final String ACTION_GET_SITE_COUNTS = 'getSiteCounts';
	private final String ACTION_GET_LOGINS_OVER_TIME = 'getLoginsOverTime';
	private final String ACTION_GET_LOGINS_OVER_TIME_CSV = 'getLoginsOverTimeCsv';
	private final String ACTION_GET_ADOPTION_DATA = 'getAdoptionData';
	private final String ACTION_GET_PEOPLE_PROFILE_COMPLETENESS = 'getPeopleProfileCompleteness';
	private final String ACTION_GET_PEOPLE_OVERVIEW = 'getPeopleOverview';
	private final String ACTION_GET_SEARCHES = 'getSearches';
	private final String ACTION_GET_SEARCH_LIST ='getSearchList';
	private final String ACTION_GET_LAST_SYNC_DATE = 'getLastSyncDate';
	private final String ACTION_GET_CONTENT_REERRAL_SOURCES = 'getContentReferralSources';
	private final String ACTION_GET_CONTENT_ENGAGEMENT = 'getContentEngagement';
	private final String ACTION_GET_CONTENT_ENGAGEMENT_CSV = 'getContentEngagementCsv';
	private final String ACTION_GET_RECOMMENDATION ='getRecommendationByType';
	private final String ACTION_GET_CUSTOMER_SEGMENT_ADOPTION ='getCustomerSegmentAdoption';
	private final String ACTION_GET_APP_ADOPTION ='getAppAdoption';
	private final String ACTION_GET_VIDEO_POPULARITY ='getVideoPopularity';
	private final String ACTION_GET_VIDEO_ADOPTION ='getVideoAdoption';
	private final String ACTION_GET_VIDEO_ADOPTION_CSV ='getVideoAdoptionCsv';
	private final String ACTION_ANALYTICS_CSV_DOWNLOAD_POST_PROCESS = 'analyticsCsvDownloadPostProcess';
	private final String ACTION_GET_VIEWED_BY_METRIC_DATA = 'getViewedByMetricData';
	private final String ACTION_GET_CONSUMPTION_OVER_TIME = 'getConsumptionOverTime';
	private final String NPS_Data_URL = 'https://services.simpplr.com/nps/push-nps-data.php?dri=';
	private final String REQUEST_PARAM_DATA = 'data';
	private String toDate;
	private String fromDate;
	private String siteId;
	private String metric;
	
    public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
    public override void handleRequest() {
        try {
        	
        	logger.logDebug('AnalyticsDataServer----entered handleRequest----');
        	
	    	String action = readParam(REQUEST_PARAM_ACTION);
	    	
        	String requestData = readParam(REQUEST_PARAM_DATA);
        	
        	if(ACTION_GET_ADOPTION_AVERAGE.equalsIgnoreCase(action)) {
                response = getAdoptionAverage(requestData);
                
            } else if(ACTION_GET_CONTENT_VIEWS.equalsIgnoreCase(action)){
            	response = getContentViews(requestData);
            	
            } else if(ACTION_GET_VIEWS_OVER_TIME.equalsIgnoreCase(action)){
            	response = getViewsOverTime(requestData);
            	
            } else if(ACTION_GET_LOGINS_OVER_TIME.equalsIgnoreCase(action)){
            	response = getLoginViewsOverTime(requestData);
           
            } else if(ACTION_GET_ADOPTION_DATA.equalsIgnoreCase(action)){
            	response = getAdoptiondata(requestData);
            	
            }else if(ACTION_GET_CONTENT_VIEWS_LIST.equalsIgnoreCase(action)){
            	response = getContentViewsList(requestData);
            
            }else if(ACTION_GET_VIEWS_LIST.equalsIgnoreCase(action)){
            	 response = getViewsList(requestData);
            	 
            } else if(ACTION_GET_SEARCH_LIST.equalsIgnoreCase(action)){
            	response = getSearchList(requestData);
            	
           	}else if(ACTION_GET_SEARCHES.equalsIgnoreCase(action)){
            	response = getSearches(requestData);
            		
            } else if(ACTION_GET_CONTENT_POPULAR.equalsIgnoreCase(action)){
            	response = getContentPopularity(requestData);
            	
            } else if(ACTION_GET_GOVERNANCE_LIST.equalsIgnoreCase(action)){
            	response = getGovernanceList(requestData);
            	
            } else if(ACTION_GET_CONTENT_PUBLICATIONS.equalsIgnoreCase(action)){
            	 response = getContentPublications(requestData);
            	 
            } else if(ACTION_GET_SITE_PUBLICATIONS.equalsIgnoreCase(action)){
            	response = getSitePublications(requestData);
            	
            } else if(ACTION_GET_SITE_POPULAR.equalsIgnoreCase(action)){
            	response = getSitePopularity(requestData);
            	
            } else if(ACTION_GET_LOGINS_LIST.equalsIgnoreCase(action)){
            	response = getLoginsList(requestData);
           
            } else if(ACTION_GET_MONTHLY_REPORT.equalsIgnoreCase(action)){
            	response = getMonthlyReport();
            	
            } else if(ACTION_GET_LOW_SITE_ACTIVITY.equalsIgnoreCase(action)){
            	response = getLowSiteActivity(requestData);
            	
            } else if(ACTION_GET_PEOPLE_PERFORMANCE.equalsIgnoreCase(action)){
            	response = getPeoplePerformance(requestData);
            
            } else if(ACTION_GET_SITE_COUNTS.equalsIgnoreCase(action)){
            	response = getSiteCounts(requestData);
            
            } else if(ACTION_GET_SITE_VIEWS.equalsIgnoreCase(action)){
            	response = getSiteViews(requestData);
            	
            } else if(ACTION_GET_SITE_VIEWS_TOTAL.equalsIgnoreCase(action)) {
				response = getSiteViewsTotal(requestData);

			} else if(ACTION_GET_NEWSLETTERS.equalsIgnoreCase(action)){
            	response = getNewsletters(requestData);
            	
            } else if(ACTION_GET_CAMPAIGNS.equalsIgnoreCase(action)){
            	response = getCampaigns(requestData);
            	
            }else if(ACTION_GET_PERFORMANCE_CONTENT.equalsIgnoreCase(action)){
            	response = getPerformanceContent(requestData);
            	 
            } else if(ACTION_GET_ENGAGEMENT_LIST.equalsIgnoreCase(action)){
            	response = getEngagementList(requestData);
            	
            } else if(ACTION_GET_ENGAGEMENT.equalsIgnoreCase(action)){
            	response = getEngagement(requestData);
            	
            } else if(ACTION_GET_PEOPLE_PROFILE_COMPLETENESS.equalsIgnoreCase(action)){
				response = getPeopleProfileCompleteness(requestData);

            } else if(ACTION_GET_PEOPLE_OVERVIEW.equalsIgnoreCase(action)){
				response = getPeopleOverview(requestData);

			} else if(ACTION_GET_CONTENT_VIEWS_BY_TYPE.equalsIgnoreCase(action)){
				response = getContentViewsByType(requestData);

			} else if(ACTION_GET_CONTENT_VIEWS_OVER_TIME.equalsIgnoreCase(action)){
				response = getContentViewsOverTime(requestData);

			} else if(ACTION_GET_KNOWLEDGE_PAGE_STATS.equalsIgnoreCase(action)){
				response = getKnowledgePageStats(requestData);

			} else if(ACTION_GET_LAST_SYNC_DATE.equalsIgnoreCase(action)){
				response = getLastSyncDate(requestData);

			} else if(ACTION_GET_APP_PAGE_VIEWS.equalsIgnoreCase(action)) {
				response = getAppPageViews(requestData);

			} else if(ACTION_GET_CONTENT_REERRAL_SOURCES.equalsIgnoreCase(action)){
				response = getContentReferralSources(requestData);

			}else if(ACTION_GET_CONTENT_ENGAGEMENT.equalsIgnoreCase(action)){
				response = getContentEngagement(requestData);

			}else if(ACTION_GET_RECOMMENDATION.equalsIgnoreCase(action)){
            	response = getRecommendationByType(requestData);
            	
			}else if(ACTION_GET_CUSTOMER_SEGMENT_ADOPTION.equalsIgnoreCase(action)){
            	response = getCustomerSegmentAdoption();
            	
            }else if(ACTION_GET_APP_ADOPTION.equalsIgnoreCase(action)){
            	response = getAppAdoption(requestData);
            	
            }else if(ACTION_GET_VIDEO_POPULARITY.equalsIgnoreCase(action)){
				response = getVideoPopularity(requestData);
			
			}else if(ACTION_GET_VIDEO_ADOPTION.equalsIgnoreCase(action)){
				response = getVideoAdoption(requestData);
			} else if(ACTION_ANALYTICS_CSV_DOWNLOAD_POST_PROCESS.equalsIgnoreCase(action)){
				response = analyticsCsvDownloadPostProcess(requestData);

			} else if(ACTION_GET_VIEWED_BY_METRIC_DATA.equalsIgnoreCase(action)){
				response = getViewedByMetricData(requestData);
			} else if(ACTION_GET_CONSUMPTION_OVER_TIME.equalsIgnoreCase(action)){
				response = getConsumptionOverTime(requestData);
			}


			else{
                throw new SimpplrException(ExceptionCode.INVALID_PARAMETER.name());
            }
            
        } catch (Exception ex) {
        	response = buildResponseWrapper(RESPONSE_STATUS_ERROR,MessageHelper.translateSFMessageToErrorCode(ex), null);
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
	private ResponseWrapper getContentReferralSources(String requestData){
		ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.ContentReferralSource ContentReferralSourceObj = new AnalyticsWrapper.ContentReferralSource();
        	String fromDate = String.valueOf(requestDataMap.get('from'));
			String toDate = String.valueOf(requestDataMap.get('to'));
			String siteId = String.valueOf(requestDataMap.get('siteId'));
        	String contentId = String.valueOf(requestDataMap.get('contentId'));
        	
        	ContentReferralSourceObj.data = (List<AnalyticsWrapper.ContentReferralSourceData>) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap, 'getContentReferralSources', 10);
			if(toDate != null && fromdate != null){
				ContentReferralSourceObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action=' + ACTION_GET_CONTENT_REERRAL_SOURCES + '&to=' + toDate + '&from=' + fromDate;
			}
			if(String.isNotBlank(siteId)){
        		ContentReferralSourceObj.csvUrl += '&siteId=' + siteId;
        	}
        	if(String.isNotBlank(contentId)){
        		ContentReferralSourceObj.csvUrl += '&contentId=' + contentId;
        	}
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS,null, ContentReferralSourceObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		
        return localResult;
	}
    
	 /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	private ResponseWrapper getAdoptionAverage(String requestData){  
        ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	AnalyticsWrapper.AdoptionAverage adoptionAverageDataObj = new AnalyticsWrapper.AdoptionAverage();
        	String fromDate = String.valueOf(requestDataMap.get('from'));
			String toDate = String.valueOf(requestDataMap.get('to'));
			String filterBy = String.valueOf(requestDataMap.get('filterBy'));
        	String filterValue = String.valueOf(requestDataMap.get('filterValue'));
        	String groupBy = String.valueOf(requestDataMap.get('groupBy'));
        	
        	adoptionAverageDataObj.data = (List<AnalyticsWrapper.AdoptionAverageData>) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getAdoptionAverage',null);
			if(toDate!=null && fromdate!=null){
				adoptionAverageDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_ADOPTION_AVERAGE+'&to='+toDate+'&from='+fromDate+'&groupBy='+groupBy ;
			}
			if(String.isNotBlank(filterBy)){
        		adoptionAverageDataObj.csvUrl += '&filterBy='+filterBy;
        	}
        	if(String.isNotBlank(filterValue)){
        		adoptionAverageDataObj.csvUrl += '&filterValue='+ (String.isNotBlank(filterValue) ? EncodingUtil.urlEncode(filterValue, 'UTF-8') : filterValue);
        	}
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS,null, adoptionAverageDataObj);	        
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult; 
	}
	
	private ResponseWrapper getViewsOverTime(String requestData){
		ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
        	String groupBy = String.valueOf(requestDataMap.get('groupBy'));
        	String filterBy = String.valueOf(requestDataMap.get('filterBy'));
        	String filterValue = String.valueOf(requestDataMap.get('filterValue'));
        	
        	AnalyticsWrapper.ContentWrapper pageViewsOverdata =  (AnalyticsWrapper.ContentWrapper) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getViewsOverTime',null);
        	pageViewsOverdata.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_VIEWS_OVER_TIME_CSV+'&to='+toDate+'&from='+fromDate;
			if(String.isNotBlank(groupBy)){
        		pageViewsOverdata.csvUrl += '&groupBy='+groupBy;
        	}
        	if(String.isNotBlank(filterBy)){
        		pageViewsOverdata.csvUrl += '&filterBy='+filterBy;
        	}
        	if(String.isNotBlank(filterValue)){
        		pageViewsOverdata.csvUrl += '&filterValue='+ (String.isNotBlank(filterValue) ? EncodingUtil.urlEncode(filterValue, 'UTF-8') : filterValue);
        	}
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, pageViewsOverdata);
        	
        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult;
	}

	private ResponseWrapper getContentViewsOverTime(String requestData){
		ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
        	String groupBy = String.valueOf(requestDataMap.get('groupBy'));
        	String filterBy = String.valueOf(requestDataMap.get('filterBy'));
        	String filterValue = String.valueOf(requestDataMap.get('filterValue'));

        	AnalyticsWrapper.ContentViewsOverTimeWrapper contentViewsOverWrapper = new AnalyticsWrapper.ContentViewsOverTimeWrapper();
        	AnalyticsWrapper.ContentViewsOverTimeData contentViewsOverdata =  (AnalyticsWrapper.ContentViewsOverTimeData) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap, 'getContentViewsOverTime', null);
        	
			contentViewsOverWrapper.data = contentViewsOverdata;
			contentViewsOverWrapper.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_CONTENT_VIEWS_OVER_TIME_CSV+'&to='+toDate+'&from='+fromDate;
			if(String.isNotBlank(groupBy)){
        		contentViewsOverWrapper.csvUrl += '&groupBy='+groupBy;
        	}
        	if(String.isNotBlank(filterBy)){
        		contentViewsOverWrapper.csvUrl += '&filterBy='+filterBy;
        	}
        	if(String.isNotBlank(filterValue)){
        		contentViewsOverWrapper.csvUrl += '&filterValue='+ (String.isNotBlank(filterValue) ? EncodingUtil.urlEncode(filterValue, 'UTF-8') : filterValue);
        	}
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, contentViewsOverWrapper);
        	
        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult;
	}

	private ResponseWrapper getKnowledgePageStats(String requestData){
		ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
			String siteId = String.valueOf(requestDataMap.get('siteId'));

        	List<AnalyticsWrapper.LabelValueData> knowledgePageDataList =  (List<AnalyticsWrapper.LabelValueData>) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap, 'getKnowledgePageStats', null);
        	String url = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_CONTENT_KNOWLEDGE_PAGE_CSV+'&to='+toDate+'&from='+fromDate;

			if(String.isNotBlank(siteId)){
				url += '&siteId=' + siteId;
			}

			AnalyticsWrapper.KnowledgePageWrapper knowledgePagesWrapper = new AnalyticsWrapper.KnowledgePageWrapper();
			knowledgePagesWrapper.data = knowledgePageDataList;
			knowledgePagesWrapper.csvUrl = url;
			
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, knowledgePagesWrapper);
        	
        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult;
	}
	
	private ResponseWrapper getLoginViewsOverTime(String requestData){
		ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
        	String groupBy = String.valueOf(requestDataMap.get('groupBy'));
        	String filterBy = String.valueOf(requestDataMap.get('filterBy'));
        	String filterValue = String.valueOf(requestDataMap.get('filterValue'));
        	
        	AnalyticsWrapper.ContentWrapper loginViewsOverdata = (AnalyticsWrapper.ContentWrapper) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getLoginsOverTime',null);
        	loginViewsOverdata.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_LOGINS_OVER_TIME_CSV+'&to='+toDate+'&from='+fromDate;
			if(String.isNotBlank(groupBy)){
        		loginViewsOverdata.csvUrl += '&groupBy='+groupBy;
        	}
        	if(String.isNotBlank(filterBy)){
        		loginViewsOverdata.csvUrl += '&filterBy='+filterBy;
        	}
        	if(String.isNotBlank(filterValue)){
        		loginViewsOverdata.csvUrl += '&filterValue='+ (String.isNotBlank(filterValue) ? EncodingUtil.urlEncode(filterValue, 'UTF-8') : filterValue);
        	}
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS,null, loginViewsOverdata);
        	
        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult;
	}
	
	private ResponseWrapper getAdoptiondata(String requestData){
		ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
        	String groupBy = String.valueOf(requestDataMap.get('groupBy'));
        	String filterBy = String.valueOf(requestDataMap.get('filterBy'));
        	String filterValue = String.valueOf(requestDataMap.get('filterValue'));
        	Boolean excludeDeviceData = 'true'.equalsIgnoreCase((String)requestDataMap.get('excludeDeviceData'));
        	Boolean excludeLoginsOverTime = 'true'.equalsIgnoreCase((String)requestDataMap.get('excludeLoginsOverTime'));
        	
        	AnalyticsWrapper.ContentWrapper adoptiondata = (AnalyticsWrapper.ContentWrapper) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getAdoptionData',null);
        	adoptiondata.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_ADOPTION_DATA+'&to='+toDate+'&from='+fromDate+'&groupBy='+groupBy+'&filterBy='+filterBy+'&filterValue='+(String.isNotBlank(filterValue) ? EncodingUtil.urlEncode(filterValue, 'UTF-8') : filterValue)+'&excludeLoginsOverTime='+excludeLoginsOverTime+'&excludeDeviceData='+excludeDeviceData;
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS,null,adoptiondata);
        	
        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult;
	}
	
	private ResponseWrapper getContentViews(String requestData){
		ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
        	String contentId = String.valueOf(requestDataMap.get('contentId'));
        	String groupBy = String.valueOf(requestDataMap.get('groupBy'));
        	
        	AnalyticsWrapper.ContentWrapper contentWrapperObj = new AnalyticsWrapper.ContentWrapper(); 
        	contentWrapperObj.data = (AnalyticsWrapper.ContentRelatedData) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getContentViews',null);
        	contentWrapperObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_CONTENT_VIEWS_CSV+'&to='+toDate+'&from='+fromDate+'&groupBy='+groupBy+'&contentId='+contentId;
        	contentWrapperObj.csvUrlTopDepartments = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_CONTENT_VIEWS_TOP_DEPARTMENTS_CSV+'&to='+toDate+'&from='+fromDate+'&groupBy='+groupBy+'&contentId='+contentId;
        	contentWrapperObj.csvUrlTopLocations = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_CONTENT_VIEWS_TOP_LOCATIONS_CSV+'&to='+toDate+'&from='+fromDate+'&groupBy='+groupBy+'&contentId='+contentId;
        	
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS,null, contentWrapperObj);
        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		return localResult;
	}
	
	
	private ResponseWrapper getViewsList(String requestData){
		ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData); 
        	String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
        	String filterBy = String.valueOf(requestDataMap.get('filterBy'));
        	String filterValue = String.valueOf(requestDataMap.get('filterValue'));
        	String resultType = String.valueOf(requestDataMap.get('resultType'));
        	String orderBy = String.valueOf(requestDataMap.get('orderBy'));
        	
        	AnalyticsWrapper.ViewsList pageViewsList = (AnalyticsWrapper.ViewsList) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getViewsList',10);
            if(pageViewsList != null) {
                pageViewsList.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_VIEWS_LIST+'&to='+toDate+'&from='+fromDate+'&resultType='+resultType+'&orderBy='+orderBy;
                if(String.isNotBlank(filterBy)){
                    pageViewsList.csvUrl += '&filterBy='+filterBy;
                }
                if(String.isNotBlank(filterValue)){
                    pageViewsList.csvUrl += '&filterValue='+ (String.isNotBlank(filterValue) ? EncodingUtil.urlEncode(filterValue, 'UTF-8') : filterValue);
                }
            }
            localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS,null,pageViewsList);
        
        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		return localResult;
	}
	
	private ResponseWrapper getContentViewsList(String requestData){
		ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
        	String resultType = String.valueOf(requestDataMap.get('resultType'));
        	String orderBy = String.valueOf(requestDataMap.get('orderBy'));
			String contentId = String.valueOf(requestDataMap.get('contentId'));
        	
        	if(String.isBlank(resultType)){
        		AnalyticsWrapper.ContentViews contentViewsList = new AnalyticsWrapper.ContentViews();
        		contentViewsList.data = (List<AnalyticsWrapper.ContentInformation>) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getContentViewsList',10);
	        	contentViewsList.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_CONTENT_VIEWS_LIST+'&to='+toDate+'&from='+fromDate+'&orderBy='+orderBy;
        		localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS,null, contentViewsList);
        		
        	}else{
	        	AnalyticsWrapper.ViewsList contentViewsList = (AnalyticsWrapper.ViewsList) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getContentViewsList', null);

				contentViewsList.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_CONTENT_VIEWS_LIST+'&to='+toDate+'&from='+fromDate+'&resultType='+resultType+'&orderBy='+orderBy;
				if(String.isNotBlank(contentId)){
					contentViewsList.csvUrl += '&contentId='+contentId;
				}

        		localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS,null,contentViewsList);

        
        	}
        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		return localResult;
	}
	 
	private ResponseWrapper getSearchList(String requestData){
		ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
        	String type = String.valueOf(requestDataMap.get('type'));
        	String resultType = String.valueOf(requestDataMap.get('resultType'));
        	String orderBy = String.valueOf(requestDataMap.get('orderBy'));
			String filterBy = String.valueOf(requestDataMap.get('filterBy'));
			String filterValue = String.valueOf(requestDataMap.get('filterValue'));
        	
        	AnalyticsWrapper.SearchList searchList = new AnalyticsWrapper.SearchList();
        	AnalyticsWrapper.SearchData searchData = (AnalyticsWrapper.SearchData) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getSearchList',10);
        	searchList.data = searchData;
        	searchList.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_SEARCH_LIST+'&to='+toDate+'&from='+fromDate+'&orderBy='+orderBy + '&type='+type;
        	if(String.isNotBlank(resultType)) {
        		searchList.csvUrl += '&resultType='+resultType;
        	}
			if(String.isNotBlank(filterBy)){
        		searchList.csvUrl += '&filterBy='+filterBy;
        	}
        	if(String.isNotBlank(filterValue)){
        		searchList.csvUrl += '&filterValue='+ EncodingUtil.urlEncode(filterValue, 'UTF-8');
        	}
        	
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, searchList);
        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		return localResult;
	}
	
	private ResponseWrapper getSearches(String requestData){
		ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
        	String groupBy = String.valueOf(requestDataMap.get('groupBy'));
			String filterBy = String.valueOf(requestDataMap.get('filterBy'));
			String filterValue = String.valueOf(requestDataMap.get('filterValue'));
        	
        	AnalyticsWrapper.SearchList searchViewsList = new AnalyticsWrapper.SearchList();
        	AnalyticsWrapper.SearchData searchViewsData = (AnalyticsWrapper.SearchData) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getSearches',10);
        	searchViewsList.data = searchViewsData;
        	searchViewsList.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_SEARCHES+'&to='+toDate+'&from='+fromDate+'&groupBy='+groupBy;
			if(String.isNotBlank(filterBy)){
        		searchViewsList.csvUrl += '&filterBy='+filterBy;
        	}
        	if(String.isNotBlank(filterValue)){
        		searchViewsList.csvUrl += '&filterValue='+ EncodingUtil.urlEncode(filterValue, 'UTF-8');
        	}
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, searchViewsList);
        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		return localResult;
	}
	
	private ResponseWrapper getMonthlyReport(){
		ResponseWrapper localResult = null;
        try {
        	AnalyticsWrapper.MonthlyReport report = (AnalyticsWrapper.MonthlyReport) externalAnalyticsServiceObj.getExternalAnalyticsResults(null,'getMonthlyReports',10);
        	report.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_MONTHLY_REPORT;

			for(AnalyticsWrapper.MonthlyReportData reportData : report.data){
				String month = (reportData.month < 10 ? ('0' + reportData.month) : reportData.month + '');
				reportData.label = LocaleContext.getLabel(UserContext.languageLocaleKey, 'date.month.short.' + month) + ' ' + reportData.year;
			}
        	
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, report);
        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		return localResult;
	}
	
	private ResponseWrapper getLoginsList(String requestData){
		ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
        	String filterBy = String.valueOf(requestDataMap.get('filterBy'));
        	String filterValue = String.valueOf(requestDataMap.get('filterValue'));
        	String resultType = String.valueOf(requestDataMap.get('resultType'));
        	String orderBy = String.valueOf(requestDataMap.get('orderBy'));
        	
        	AnalyticsWrapper.ViewsList loginViewsList = (AnalyticsWrapper.ViewsList) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getLoginsList',10);

        	loginViewsList.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_LOGINS_LIST+'&to='+toDate+'&from='+fromDate+'&resultType='+resultType+'&orderBy='+orderBy;
        	if(String.isNotBlank(filterBy)){
        		loginViewsList.csvUrl += '&filterBy='+filterBy;
        	}
        	if(String.isNotBlank(filterValue)){
        		loginViewsList.csvUrl += '&filterValue='+ (String.isNotBlank(filterValue) ? EncodingUtil.urlEncode(filterValue, 'UTF-8') : filterValue);
        	}
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS,null,loginViewsList);
        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		return localResult;
	}
	
	private ResponseWrapper getContentPopularity(String requestData){
		ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
        	String orderBy = String.valueOf(requestDataMap.get('orderBy'));
        	
        	AnalyticsWrapper.ContentPopular popularityList = new AnalyticsWrapper.ContentPopular();
        	List<AnalyticsWrapper.ContentInformation> contentViewsList = (List<AnalyticsWrapper.ContentInformation>) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getContentPopularity',10);
        	popularityList.data = contentViewsList;
        	popularityList.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_CONTENT_POPULAR+'&to='+toDate+'&from='+fromDate+'&orderBy='+orderBy;
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, popularityList);
        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		return localResult;
	}

	private ResponseWrapper getGovernanceList(String requestData){
		ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
        	String orderBy = String.valueOf(requestDataMap.get('orderBy'));
        	
        	AnalyticsWrapper.GovernanceWrapper governanceList = new AnalyticsWrapper.GovernanceWrapper();
        	List<AnalyticsWrapper.LabelValueData> governanceLabelList = (List<AnalyticsWrapper.LabelValueData>) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getGovernanceList',10);
        	governanceList.data = governanceLabelList;
        	governanceList.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_GOVERNANCE_LIST+'&to='+toDate+'&from='+fromDate;
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, governanceList);
        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		return localResult;
	}
	
	private ResponseWrapper getSitePopularity(String requestData){
		ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
        	String orderBy = String.valueOf(requestDataMap.get('orderBy'));
        	
        	AnalyticsWrapper.SiteWrapper sitePopularity = new AnalyticsWrapper.SiteWrapper();
        	sitePopularity.data = new AnalyticsWrapper.SiteData();
        	sitePopularity.data.sites = (List<AnalyticsWrapper.ViewsOverTime>) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getSitePopularity',10);
        	sitePopularity.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_SITE_POPULAR+'&to='+toDate+'&from='+fromDate+'&orderBy='+orderBy;
        	
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, sitePopularity);
        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		return localResult;
	}
	
	private ResponseWrapper getLowSiteActivity(String requestData){
		ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
    		List<AnalyticsWrapper.ViewsOverTime> lowActivitySites = (List<AnalyticsWrapper.ViewsOverTime>) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getLowActivitySites',10);
    		Map<String, Object> result = new Map<String, Object>(); 
        	result.put('listOfSites', lowActivitySites);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS,null, result);
        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		return localResult;
	}
	
	private  ResponseWrapper getPeoplePerformance(String requestData){
		ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
        	String metric = String.valueOf(requestDataMap.get('metric'));
			String siteId = requestDataMap != null && requestDataMap.containsKey('siteId') ? String.valueOf(requestDataMap.get('siteId')) : null;
        	
        	AnalyticsWrapper.PeoplePerformanceWrappper peoplePerformance = (AnalyticsWrapper.PeoplePerformanceWrappper) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getPeoplePerformance',10);
        	peoplePerformance.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PEOPLE_PERFORMANCE+'&includeName=true&to='+toDate+'&from='+fromDate+'&metric='+metric;
        	if(String.isNotBlank(siteId)){
				peoplePerformance.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PEOPLE_PERFORMANCE+'&includeName=true&to='+toDate+'&from='+fromDate+'&metric='+metric+'&siteId='+siteId;
			}
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null,peoplePerformance);
        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		return localResult;
	}
	
	private ResponseWrapper getEngagement(String requestData){
		ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
        	String filterBy = String.valueOf(requestDataMap.get('filterBy'));
        	String filterValue = String.valueOf(requestDataMap.get('filterValue'));
        	String groupBy = String.valueOf(requestDataMap.get('groupBy'));
        	
        	AnalyticsWrapper.Engagement engagement = (AnalyticsWrapper.Engagement) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getEngagement',null);
        	engagement.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_ENGAGEMENT+'&to='+toDate+'&from='+fromDate+'&groupBy='+groupBy;
        	
        	if(String.isNotBlank(filterBy) && 'site'.equalsIgnoreCase(filterBy)){
        		engagement.csvUrl += '&siteId='+filterValue;
        	}
        	if(String.isNotBlank(filterBy)){
        		engagement.csvUrl += '&filterBy='+filterBy;
        	}
        	if(String.isNotBlank(filterValue)){
        		engagement.csvUrl += '&filterValue='+ (String.isNotBlank(filterValue) ? EncodingUtil.urlEncode(filterValue, 'UTF-8') : filterValue);
        	}
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null,engagement);
        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		return localResult;
	}
	
	private ResponseWrapper getEngagementList(String requestData){
		ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
        	String filterBy = String.valueOf(requestDataMap.get('filterBy'));
        	String filterValue = String.valueOf(requestDataMap.get('filterValue'));
        	String resultType = String.valueOf(requestDataMap.get('resultType'));
        	String orderBy = String.valueOf(requestDataMap.get('orderBy'));
        	
        	AnalyticsWrapper.ViewsList engagementList = (AnalyticsWrapper.ViewsList) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getEngagementList',10);
        	engagementList.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_ENGAGEMENT_LIST+'&to='+toDate+'&from='+fromDate+'&orderBy='+orderBy+'&resultType='+resultType;
        	if(String.isNotBlank(filterBy)){
        		engagementList.csvUrl += '&filterBy='+filterBy;
        	}
        	if(String.isNotBlank(filterValue)){
        		engagementList.csvUrl += '&filterValue='+ (String.isNotBlank(filterValue) ? EncodingUtil.urlEncode(filterValue, 'UTF-8') : filterValue);
        	}
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS,null,engagementList);
        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR,null, null);
        }
		return localResult;
	}
	
	private ResponseWrapper getPerformanceContent(String requestData){
		ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
        	String metric = String.valueOf(requestDataMap.get('metric'));
        	String orderBy = String.valueOf(requestDataMap.get('orderBy'));
        	String siteId = String.valueOf(requestDataMap.get('siteId'));
        	
        	AnalyticsWrapper.PerformanceContent contentPerformance = (AnalyticsWrapper.PerformanceContent) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getPerformanceContent',10);
        	contentPerformance.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_PERFORMANCE_CONTENT+'&to='+toDate+'&from='+fromDate+'&metric='+metric+'&orderBy='+orderBy+'&siteId='+siteId;
        	
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, contentPerformance);
        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		return localResult;
	}
	
	public ResponseWrapper getCampaigns(String requestData){
		ResponseWrapper localResult = null;
        try {
			AnalyticsWrapper.Campaign campaigns = new AnalyticsWrapper.Campaign();
			if(SimpplrContext.isDemoAnalyticsEnabled==true) {
				Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
				DemoAnalytics demoAnalyticsObj = new DemoAnalytics();
				String Jsondata = demoAnalyticsObj.getDummyAnalyticsData('getCampaigns',requestDataMap);
				campaigns = (AnalyticsWrapper.Campaign)JSON.deserialize(Jsondata, AnalyticsWrapper.Campaign.class);
			}else{
				Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        		campaigns = (AnalyticsWrapper.Campaign) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getCampaigns',null);
			}
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS,null, campaigns);
        	
        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		return localResult;
	}
	
	private ResponseWrapper getNewsletters(String requestData){
		ResponseWrapper localResult = null;
        try {
			AnalyticsWrapper.Newsletter newsletter = new AnalyticsWrapper.Newsletter();
        	if(SimpplrContext.isDemoAnalyticsEnabled==true) {
				Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
				DemoAnalytics demoAnalyticsObj = new DemoAnalytics();
				String Jsondata = demoAnalyticsObj.getDummyAnalyticsData('getNewsletters',requestDataMap);
				newsletter = (AnalyticsWrapper.Newsletter)JSON.deserialize(Jsondata, AnalyticsWrapper.Newsletter.class);
			}else{
				// filter out sites
				String unlistedCondition = '';
				List<CollaborationGroupMember> memberList;
				Set<Id> cgGrpIdSet = new Set<Id>();
				String query = 'select id from CollaborationGroup where IsArchived=false';
				if(UserContext.hasManageUnlistedSitePermission) {
					unlistedCondition += ' OR Collaborationtype = \'Unlisted\'';
				}
				if(UserContext.hasModifyAllDataPermission){
					
				}else if(UserContext.isUserAppModerator || UserContext.canSendNewsletter){
					memberList = [SELECT Id,CollaborationRole,CollaborationGroupId FROM CollaborationGroupMember 
														WHERE memberId=:UserContext.id AND CollaborationRole = 'Admin' WITH SECURITY_ENFORCED];
					for(CollaborationGroupMember cgMember :memberList){
						cgGrpIdSet.add(cgMember.CollaborationGroupId);
					}
					query += ' AND (ID IN:cgGrpIdSet OR Collaborationtype=\'Public\''+unlistedCondition+')';
				} else{
					memberList = [SELECT Id,CollaborationRole,CollaborationGroupId FROM CollaborationGroupMember 
														WHERE memberId=:UserContext.id AND CollaborationRole = 'Admin' WITH SECURITY_ENFORCED];
					for(CollaborationGroupMember cgMember :memberList){
						cgGrpIdSet.add(cgMember.CollaborationGroupId);
					}
					query = query + ' AND (Id IN:cgGrpIdSet'+unlistedCondition+')';
				}
				
				if(SimpplrContext.isCommunitiesEnabled){
					query = query+' AND NetworkId = null';
				}
				Map<Id,CollaborationGroup> collabGrpMap = new Map<Id,CollaborationGroup>((List<CollaborationGroup>)Database.query(query));
				
				Map<String,Simpplr_Site__c> siteMap = new Map<String,Simpplr_Site__c>([select id from simpplr_site__c where is_active__c=true and is_deleted__c=false and show_in_simpplr__c=true and Chatter_Group_Id__c IN:collabGrpMap.keySet()]);
				
				Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
				String fromDate = String.valueOf(requestDataMap.get('from'));
				String toDate = String.valueOf(requestDataMap.get('to'));
				AnalyticsWrapper.NewsletterData newsletterData = new AnalyticsWrapper.NewsletterData();
				
				List<String> fromDateStringPartList = fromDate.split('-');
				List<String> toDateStringPartList = toDate.split('-');
				Datetime fDateTime = DateTime.newInstance(Integer.valueOf(fromDateStringPartList[0]),
						Integer.valueOf(fromDateStringPartList[1]),
						Integer.valueOf(fromDateStringPartList[2]));
				Datetime tDateTime = DateTime.newInstance(Integer.valueOf(toDateStringPartList[0]),
						Integer.valueOf(toDateStringPartList[1]),
						Integer.valueOf(toDateStringPartList[2]), 23, 59,59);
				
				Map<String, Object> soqlParamMap = new  Map<String, Object>();
				soqlParamMap.put('soqlParam1', siteMap.keySet());
				soqlParamMap.put('soqlParam2', fDateTime);
				soqlParamMap.put('soqlParam3', tDateTime);
				String queryStr  = 'select sum(Actual_Recipient_Count__c) totalRecipientCount,count(id) sentCount,sum(Open_Count__c) openCount,sum(Total_Click_Count__c) clickCount from mailer__c where Is_Deleted__c=false AND (site__c=null or site__c IN:soqlParam1) AND Status__c=\'Sent\' AND Sent_Time__c>=:soqlParam2 AND Sent_Time__c<=:soqlParam3';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
				List<AggregateResult> groupedData = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUSer(queryStr, soqlParamMap);
				for(AggregateResult res : groupedData){
					newsletterData.sentCount = Integer.valueOf(res.get('sentCount'));
					if(newsletterData.sentCount > 0) {
						newsletterData.totalRecipientCount = Integer.valueOf(res.get('totalRecipientCount'));
						newsletterData.averageOpenPercentage = ((Integer.valueOf(res.get('openCount')) * 100.0)/newsletterData.totalRecipientCount).setScale(2);
						newsletterData.averageClickPercentage = ((Integer.valueOf(res.get('clickCount'))*100.0)/newsletterData.totalRecipientCount).setScale(2);
					} else {
						newsletterData.totalRecipientCount = 0;
						newsletterData.averageOpenPercentage = 0;
						newsletterData.averageClickPercentage = 0;
					}
				}
				
				// sent count in last 30 days
				String queryStr1  = 'select count(id) sentCount from mailer__c where Is_Deleted__c=false AND Status__c=\'Sent\' AND Sent_Time__c= LAST_N_DAYS:30';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
				List<AggregateResult> groupedResult = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUSer(queryStr1, null);
				for(AggregateResult res : groupedResult){
					newsletterData.recentlysentCount = Integer.valueOf(res.get('sentCount'));
				}
				newsletter.data = newsletterData;
			}
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, newsletter);
        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		return localResult;
	}

	private ResponseWrapper getSiteViews(String requestData){
		ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
        	String siteId = String.valueOf(requestDataMap.get('siteId'));
        	String groupBy = String.valueOf(requestDataMap.get('groupBy'));
        	String type = String.valueOf(requestDataMap.get('type'));
        	AnalyticsWrapper.ContentWrapper siteViewsDataObj = new AnalyticsWrapper.ContentWrapper(); 
        	
        	siteViewsDataObj.data = (AnalyticsWrapper.ContentRelatedData) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getSiteViews',null);
        	siteViewsDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_SITE_VIEWS+'&to='+toDate+'&from='+fromDate+'&siteId='+siteId+'&groupBy='+groupBy+'&type='+type;
        	
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, siteViewsDataObj);
        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		return localResult;
	}
	
	private ResponseWrapper getAppPageViews(String requestData){
		ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
        	String siteId = String.valueOf(requestDataMap.get('siteId'));
			String contentId = String.valueOf(requestDataMap.get('contentId'));
			String filterBy = String.valueOf(requestDataMap.get('filterBy'));
        	String filterValue = String.valueOf(requestDataMap.get('filterValue'));
        	
			AnalyticsWrapper.AppPageViews appPageViews = new AnalyticsWrapper.AppPageViews();
        	appPageViews.data= (List<AnalyticsWrapper.ViewsOverTime>) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getAppPageViews',10);
			appPageViews.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_APP_PAGE_VIEWS+'&to='+toDate+'&from='+fromDate;
			if(String.isNotBlank(siteId)) {
        		appPageViews.csvUrl += '&siteId='+siteId;
			}
			
			if(String.isNotBlank(contentId)) {
        		appPageViews.csvUrl += '&contentId='+contentId;
			}
			if(String.isNotBlank(filterBy)){
        		appPageViews.csvUrl += '&filterBy='+filterBy;
        	}
        	if(String.isNotBlank(filterValue)){
        		appPageViews.csvUrl += '&filterValue='+ (String.isNotBlank(filterValue) ? EncodingUtil.urlEncode(filterValue, 'UTF-8') : filterValue);
        	}
        	
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, appPageViews);
        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		return localResult;
	}

	private ResponseWrapper getSiteViewsTotal(String requestData) {
		ResponseWrapper localResult = null;
		try {
			Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
        	String siteId = String.valueOf(requestDataMap.get('siteId'));
        	String groupBy = String.valueOf(requestDataMap.get('groupBy'));
        	AnalyticsWrapper.ContentWrapper siteViewsDataObj = new AnalyticsWrapper.ContentWrapper(); 
        	
        	siteViewsDataObj.data = (AnalyticsWrapper.ContentRelatedData) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getSiteViewsTotal',null);
        	siteViewsDataObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_SITE_VIEWS_TOTAL+'&to='+toDate+'&from='+fromDate+'&siteId='+siteId+'&groupBy='+groupBy;
        	
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, siteViewsDataObj);
		} catch (Exception e) {
			logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return localResult;
	}
	
	private ResponseWrapper getSiteCounts(String requestData){
		ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	
        	AnalyticsWrapper.SiteCount siteCounts = new AnalyticsWrapper.SiteCount();
        	siteCounts.data = (AnalyticsWrapper.SiteCountData) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap, 'getSiteCounts', null);
        	siteCounts.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_SITE_COUNTS+'&to='+toDate+'&from='+fromDate;
        	
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, siteCounts);
        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		return localResult;
	}
	
	private ResponseWrapper getSitePublications(String requestData){
		ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
        	String orderBy = String.valueOf(requestDataMap.get('orderBy'));
        	
        	AnalyticsWrapper.SiteWrapper sitePublications = new AnalyticsWrapper.SiteWrapper();
        	sitePublications.data = new AnalyticsWrapper.SiteData();
        	sitePublications.data.sites = (List<AnalyticsWrapper.ViewsOverTime>) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getSitePublication',10);
        	sitePublications.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action=getSitePublication&to='+toDate+'&from='+fromDate+'&orderBy='+orderBy;
        	
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, sitePublications);
        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		return localResult;
	}
	
	private ResponseWrapper getContentPublications(String requestData){
		ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
        	String siteId = String.valueOf(requestDataMap.get('siteId'));
        	Boolean onlyPublished = requestDataMap.containsKey('onlyPublished') ? (Boolean)requestDataMap.get('onlyPublished'):false;
        	
        	AnalyticsWrapper.ContentPublications contentPublications = new AnalyticsWrapper.ContentPublications();

        	contentPublications.data = (AnalyticsWrapper.ContentInformation) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap, 'getContentPublications', null);
        	contentPublications.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_CONTENT_PUBLICATIONS+'&to='+toDate+'&from='+fromDate+'&onlyPublished='+onlyPublished;
        	if(String.isNotBlank(siteId)) {
        		contentPublications.csvUrl += '&siteId='+siteId;
        	}
        	
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, contentPublications);
        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		return localResult;
	}

	private ResponseWrapper getPeopleProfileCompleteness(String requestData){
		ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
			String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
        	AnalyticsWrapper.ProfileCompletenessWrapper wrapperObj = new AnalyticsWrapper.ProfileCompletenessWrapper();

			wrapperObj.data = (AnalyticsWrapper.ProfileCompleteness) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap, 'getPeopleProfileCompletenessV2', null);
			wrapperObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ ACTION_GET_PEOPLE_PROFILE_COMPLETENESS +'&to='+toDate+'&from='+fromDate;
        	
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, wrapperObj);
		
		}catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		return localResult;
	}

	private ResponseWrapper getPeopleOverview(String requestData){
		ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);

        	AnalyticsWrapper.PeopleOverview peopleOverview = new AnalyticsWrapper.PeopleOverview();
        	peopleOverview.data = (AnalyticsWrapper.PeopleOverviewData) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap, 'getPeopleOverview', null);

        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, peopleOverview);

        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		return localResult;
	}	

	private ResponseWrapper getContentViewsByType(String requestData){
		ResponseWrapper localResult = null;
        try {
        	Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(requestData);
			String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
        	String siteId = String.valueOf(requestDataMap.get('siteId'));

        	AnalyticsWrapper.ContentViewsByTypeWrapper contentViewWrapper = new AnalyticsWrapper.ContentViewsByTypeWrapper();
        	contentViewWrapper.data = (AnalyticsWrapper.ContentViewsByTypeData) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap, 'getContentViewsByType', null);
			contentViewWrapper.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ ACTION_GET_CONTENT_VIEWS_BY_TYPE_CSV +'&to='+toDate+'&from='+fromDate;

			if(String.isNotBlank(siteId)){
				contentViewWrapper.csvUrl += '&siteId=' + siteId;
			}

        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, contentViewWrapper);

        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }

		return localResult;
	}

	private ResponseWrapper getLastSyncDate(String requestData) {
		ResponseWrapper localResult = null;
		try {
			Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(requestData);
			String type = String.valueOf(requestDataMap.get('type'));

			AnalyticsWrapper.LastSyncData lastSyncData = (AnalyticsWrapper.LastSyncData)externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap, 'getLastSyncDate', null);
			
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, lastSyncData);
		} catch(Exception e) {
			logger.logError(e);
			localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return localResult;
	}

	private ResponseWrapper getContentEngagement(String requestData) {
		ResponseWrapper localResult = null;
		try {
			Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(requestData);
			String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
        	String siteId = String.valueOf(requestDataMap.get('siteId'));
			String contentId = String.valueOf(requestDataMap.get('contentId'));
			String filterBy = String.valueOf(requestDataMap.get('filterBy'));
        	String filterValue = String.valueOf(requestDataMap.get('filterValue'));
			String groupBy = String.valueOf(requestDataMap.get('groupBy'));

			AnalyticsWrapper.Engagement contentEngagement = (AnalyticsWrapper.Engagement) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getContentEngagement',null);
        	contentEngagement.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_CONTENT_ENGAGEMENT_CSV+'&to='+toDate+'&from='+fromDate+'&groupBy='+groupBy;
			
			if(String.isNotBlank(filterBy)){
        		contentEngagement.csvUrl += '&filterBy='+filterBy;
        	}
        	if(String.isNotBlank(filterValue)){
        		contentEngagement.csvUrl += '&filterValue='+ (String.isNotBlank(filterValue) ? EncodingUtil.urlEncode(filterValue, 'UTF-8') : filterValue);
        	}
			
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, contentEngagement);
		} catch(Exception e) {
			logger.logError(e);
			localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return localResult;
	}
	private ResponseWrapper getRecommendationByType(String requestData) {
		ResponseWrapper localResult = null;
		try {	
			Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(requestData);
			String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
			String filterBy = String.valueOf(requestDataMap.get('filterBy'));
        	String filterValue = String.valueOf(requestDataMap.get('filterValue'));
			String groupBy = String.valueOf(requestDataMap.get('groupBy'));
			String type = String.valueOf(requestDataMap.get('type'));
					
			AnalyticsWrapper.Recommendation getRecommendation = (AnalyticsWrapper.Recommendation) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getRecommendationByType',null);
		
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, getRecommendation);
		} catch(Exception e) {
			logger.logError(e);
			localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return localResult;
	}
	private ResponseWrapper getCustomerSegmentAdoption() {
		ResponseWrapper localResult = null;
		try {	
						
			AnalyticsWrapper.CustomerSegmentAdoption getCustomerSegmentAdoption = (AnalyticsWrapper.CustomerSegmentAdoption) externalAnalyticsServiceObj.getExternalAnalyticsResults(null,'getCustomerSegmentAdoption',null);
		
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, getCustomerSegmentAdoption);
		} catch(Exception e) {
			logger.logError(e);
			localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return localResult;
	}

	private ResponseWrapper getAppAdoption(String requestData){
		ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
        	String filterBy = String.valueOf(requestDataMap.get('filterBy'));
        	String filterValue = String.valueOf(requestDataMap.get('filterValue'));
        	String resultType = String.valueOf(requestDataMap.get('resultType'));
        	String orderBy = String.valueOf(requestDataMap.get('orderBy'));
        	
        	AnalyticsWrapper.ViewsList appAdoptionList = (AnalyticsWrapper.ViewsList) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getAppAdoption',10);

        	appAdoptionList.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_APP_ADOPTION+'&to='+toDate+'&from='+fromDate+'&resultType='+resultType+'&orderBy='+orderBy;
        	if(String.isNotBlank(filterBy)){
        		appAdoptionList.csvUrl += '&filterBy='+filterBy;
        	}
        	if(String.isNotBlank(filterValue)){
        		appAdoptionList.csvUrl += '&filterValue='+ (String.isNotBlank(filterValue) ? EncodingUtil.urlEncode(filterValue, 'UTF-8') : filterValue);
        	}
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS,null,appAdoptionList);
        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		return localResult;
	}

	private ResponseWrapper getVideoPopularity(String requestData){
		ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
			String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
        	String orderBy = String.valueOf(requestDataMap.get('orderBy'));
			AnalyticsWrapper.videoStats videoStatsList = new AnalyticsWrapper.videoStats() ;
			List<AnalyticsWrapper.videoPopularity> videoPopularityList = (List<AnalyticsWrapper.videoPopularity>) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getVideoPopularity',10);
			videoStatsList.data = videoPopularityList;
			videoStatsList.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_VIDEO_POPULARITY+'&to='+toDate+'&from='+fromDate+'&orderBy='+orderBy;
        	
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS,null,videoStatsList);
        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		return localResult;
	}

	private ResponseWrapper getVideoAdoption(String requestData){
		ResponseWrapper localResult = null;
        try {
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
			String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
			String orderBy = String.valueOf(requestDataMap.get('orderBy'));
			AnalyticsWrapper.videoAdoption obj = new AnalyticsWrapper.videoAdoption();
			AnalyticsWrapper.videoAdoptionData videoAdoption = (AnalyticsWrapper.videoAdoptionData) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getVideoAdoption',10);
			obj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_VIDEO_ADOPTION_CSV+'&to='+toDate+'&from='+fromDate+'&orderBy='+orderBy;
			obj.data = videoAdoption ;
			localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, obj);

        }catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		return localResult;
	}

	/**
     * @description This method is used to process Csv Download for more than 10K records
     * @param requestData 
     * @return  `ResponseWrapper`
    */
    @TestVisible
	private ResponseWrapper analyticsCsvDownloadPostProcess(String requestData) {
		logger.logDebug('analyticsCsvDownloadPostProcess()--'+requestData);
        ResponseWrapper responseWrapperObj = null;

        try{
            Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(requestData);
			
			AnalyticsDao daoObj = new AnalyticsDao();
            String insertedObjId = daoObj.saveCsvDownloadDetails(requestDataMap);

			// Send Email 
			if(SimpplrContext.enableEmail) {
				String csvDownloadRedirectUrl = SimpplrContext.salesforceBaseUrl + Page.PageRedirector.getUrl() + '?pageToRedirect=managecsvdownload&Id=' + insertedObjId ;
				NotificationDispatcher.sendEmailForCsvDownload(csvDownloadRedirectUrl, requestDataMap);
			}
			//Send Notification
			NotificationDispatcher.sendInAppNotificationForCsvDownload(insertedObjId, requestDataMap);

			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
        } catch (Exception ex) {
            logger.logError('AnalyticsDataServer.analyticsCsvDownloadPostProcess()---Exception occured----', ex);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return responseWrapperObj;
    }
	
	/**
     * @description This method is used to get Viewed By Matric Data
     * @param requestData 
     * @return  `ResponseWrapper`
    */
    @TestVisible
	private ResponseWrapper getViewedByMetricData(String requestData) {
		logger.logDebug('getViewedByMetricData()--'+requestData);
		ResponseWrapper localResult = null;
		try {
			Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(requestData);
			String fromDate = String.valueOf(requestDataMap.get('from'));
        	String toDate = String.valueOf(requestDataMap.get('to'));
        	String siteId = (requestDataMap!= null && requestDataMap.containsKey('siteId')) ? String.valueOf(requestDataMap.get('siteId')) : null;
			String contentId = String.valueOf(requestDataMap.get('contentId'));
			String groupBy = String.valueOf(requestDataMap.get('groupBy'));
			AnalyticsWrapper.ContentEngagement contentEngagement = new AnalyticsWrapper.ContentEngagement();
        	AnalyticsWrapper.ViewedEngagementData viewedEngagementData = (AnalyticsWrapper.ViewedEngagementData) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getViewedByMetricData',10);
			if(String.isNotBlank(siteId)){
				contentEngagement.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_CONTENT_VIEWS_CSV+'&to='+toDate+'&from='+fromDate+'&groupBy='+groupBy+'&contentId='+contentId+'&siteId='+siteId;
			}else{
				//for Blog Post 
				contentEngagement.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action='+ACTION_GET_CONTENT_VIEWS_CSV+'&to='+toDate+'&from='+fromDate+'&groupBy='+groupBy+'&contentId='+contentId;
			}
        	contentEngagement.viewedData = viewedEngagementData;
			
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, contentEngagement);
		} catch(Exception ex) {
			logger.logError('AnalyticsDataServer.getViewedByMetricData()---Exception occured----', ex);
			localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return localResult;
	}
	
	/**
     * @description This method is used to get Consumption Over Time
     * @param requestData 
     * @return  `ResponseWrapper`
    */
    @TestVisible
	private ResponseWrapper getConsumptionOverTime(String requestData) {
		logger.logDebug('getConsumptionOverTime()--'+requestData);
		ResponseWrapper localResult = null;
		try {
			Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(requestData);
			
			AnalyticsWrapper.ContentWrapper contentWrapperObj = new AnalyticsWrapper.ContentWrapper(); 
        	contentWrapperObj.data = (AnalyticsWrapper.ContentRelatedData) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getConsumptionOverTime',null);
			
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, contentWrapperObj);
		} catch(Exception ex) {
			logger.logError('AnalyticsDataServer.getConsumptionOverTime()---Exception occured----', ex);
			localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return localResult;
	}
}