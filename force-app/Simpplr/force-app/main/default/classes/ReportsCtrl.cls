public with sharing class ReportsCtrl extends BaseCtrl {
	
	public transient final String STR_ACTIVE { get { return labelMap.get('common.csv_active');}}
	public transient final String STR_ADOPTION { get { return labelMap.get('common.csv_adoption');}}
  public transient final String STR_ALBUMS { get { return labelMap.get('common.csv_albums');}}
  public transient final String STR_BLOG_POSTS { get { return labelMap.get('common.csv_blog_posts');}}
  public transient final String STR_CITY { get { return labelMap.get('common.csv_city');}}
  public transient final String STR_COMPANY_NAME { get { return labelMap.get('common.csv_company_name');}}
  public transient final String STR_COUNT { get { return labelMap.get('common.csv_count');}}
  public transient final String STR_COUNTRY { get { return labelMap.get('common.csv_country');}}
  public transient final String STR_CATEGORY { get { return labelMap.get('common.csv_category');}}
  public transient final String STR_DATE { get { return labelMap.get('common.csv_date');}}
  public transient final String STR_DEPARTMENT { get { return labelMap.get('common.csv_department');}}
  public transient final String STR_DIVISION { get { return labelMap.get('common.csv_division');}}
  public transient final String STR_EMAIL { get { return labelMap.get('common.csv_email');}}
  public transient final String STR_TITLE { get { return labelMap.get('common.csv_title');}}
  public transient final String STR_EVENTS { get { return labelMap.get('common.csv_events');}}
  public transient final String STR_FAVORITES { get { return labelMap.get('common.csv_favorites');}}
  public transient final String STR_FILTERED_TO { get { return labelMap.get('common.csv_filtered_to');}}
  public transient final String STR_HEADER_CREATED_ON { get { return labelMap.get('common.csv_header_created_on');}}
  public transient final String STR_HEADER_FROM { get { return labelMap.get('common.csv_header_from');}}
  public transient final String STR_HEADER_TO { get { return labelMap.get('common.csv_header_to');}}
  public transient final String STR_HYBRID_APP { get { return labelMap.get('common.csv_hybrid_app');}}
  public transient final String STR_INACTIVE { get { return labelMap.get('common.csv_inactive');}}
  public transient final String STR_LIKES { get { return labelMap.get('common.csv_likes');}}
  public transient final String STR_LOGINS { get { return labelMap.get('common.csv_logins');}}
  public transient final String STR_MANAGERS { get { return labelMap.get('common.csv_managers');}}
  public transient final String STR_MEMBERS { get { return labelMap.get('common.csv_members');}}
  public transient final String STR_FOLLOWERS { get { return labelMap.get('common.csv_followers');}}
  public transient final String STR_MOBILE_BROWSERS { get { return labelMap.get('common.csv_mobile_browser');}}
  public transient final String STR_MONTH { get { return labelMap.get('common.csv_month');}}
  public transient final String STR_NAME { get { return labelMap.get('common.csv_name');}}
  public transient final String STR_POSTS { get { return labelMap.get('common.csv_posts');}}
  public transient final String STR_FEED_POSTS_CONTENT_COMMENTS { get { return labelMap.get('common.csv_feed_posts_content_comments');}}
  public transient final String STR_PAGES { get { return labelMap.get('common.csv_pages');}}
  public transient final String STR_WEBPAGE_CATEGORY { get { return labelMap.get('common.csv_webpage_category');}}
  public transient final String STR_TOTAL_PEOPLE { get { return labelMap.get('common.csv_total_people');}}
  public transient final String STR_PERCENTAGE_OF_TOTAL_VIEWS { get { return labelMap.get('common.csv_percentage_of_total_views');}}
  public transient final String STR_PERSON { get { return labelMap.get('common.csv_person');}}
  public transient final String STR_REPLIES { get { return labelMap.get('common.csv_replies');}}
  public transient final String STR_SEGMENT { get { return labelMap.get('common.csv_segment');}}
  public transient final String STR_SHARES { get { return labelMap.get('common.csv_shares');}}
  public transient final String STR_STATE { get { return labelMap.get('common.csv_state');}}
  public transient final String STR_STATUS { get { return labelMap.get('common.csv_status');}}
  public transient final String STR_TIME { get { return labelMap.get('common.csv_time');}}
  public transient final String STR_TOTAL { get { return labelMap.get('common.csv_total');}}
  public transient final String STR_TOTAL_POPULARITY { get { return labelMap.get('common.csv_total_popularity');}}
  public transient final String STR_TOTAL_TYPE { get { return labelMap.get('common.csv_total_type_views');}}
  public transient final String STR_TOTAL_VIEWS { get { return labelMap.get('common.csv_total_views');}}
  public transient final String STR_TYPE { get { return labelMap.get('common.csv_type');}}
  public transient final String STR_USER_NAME { get { return labelMap.get('common.csv_user_name');}}
  public transient final String STR_WEB_BROWSER { get { return labelMap.get('common.csv_web_browser');}}
  public transient final String STR_ANALYTICS_ADOPTION { get { return labelMap.get('csv.analytics.adoption');}}
  public transient final String STR_ANALYTICS_ADOPTION_CONTRIBUTORS { get { return labelMap.get('csv.analytics.adoption.contributors');}}
  public transient final String STR_ANALYTICS_ADOPTION_DATE_LAST_LOGIN { get { return labelMap.get('csv.analytics.adoption.date_last_login');}}
  public transient final String STR_ANALYTICS_ADOPTION_NO_LOGIN { get { return labelMap.get('csv.analytics.adoption.no_login');}}
  public transient final String STR_ANALYTICS_ADOPTION_NUMBER_LOGINS_PERIODS { get { return labelMap.get('csv.analytics.adoption.number_logins_period');}}
  public transient final String STR_ANALYTICS_ADOPTION_OBSERVERS { get { return labelMap.get('csv.analytics.adoption.observers');}}
  public transient final String STR_ANALYTICS_ADOPTION_ONLY_ACTIVE_USERS { get { return labelMap.get('csv.analytics.adoption.only_active_users');}}
	public transient final String STR_ANALYTICS_ADOPTION_PAGE_VIEWS_PERIOD { get { return labelMap.get('csv.analytics.adoption.page_views_period');}}
  public transient final String STR_ANALYTICS_ADOPTION_PARTICIPANTS { get { return labelMap.get('csv.analytics.adoption.participants');}}
  public transient final String STR_ANALYTICS_AVG_VIEWS_PER_USER { get { return labelMap.get('csv.analytics.avg_views_per_user');}}
  public transient final String STR_ANALYTICS_CONTENT_AUTHOR { get { return labelMap.get('csv.analytics.content.author');}}
  public transient final String STR_ANALYTICS_CONTENT_TITLE { get { return labelMap.get('csv.analytics.content.content_title');}}
  public transient final String STR_ANALYTICS_CONTENT_TYPE { get { return labelMap.get('csv.analytics.content.content_type');}}
  public transient final String STR_ANALYTICS_CONTENT_PUBLISHED_DATE { get { return labelMap.get('csv.analytics.content.published_date');}}
  public transient final String STR_ANALYTICS_CONTENT_SITE { get { return labelMap.get('csv.analytics.content.site');}}
  public transient final String STR_ANALYTICS_CONTENT_URL { get { return labelMap.get('csv.analytics.content.url');}}
  public transient final String STR_ANALYTICS_CONTENT_DEPT_NAME { get { return labelMap.get('csv.analytics.content_specific.department_name');}}
  public transient final String STR_ANALYTICS_CONTENT_FIRST_VIEWED { get { return labelMap.get('csv.analytics.content_specific.first_viewed');}}
  public transient final String STR_ANALYTICS_CONTENT_JOB_TITLE { get { return labelMap.get('csv.analytics.content_specific.job_title');}}
  public transient final String STR_ANALYTICS_CONTENT_LAST_VIEWED { get { return labelMap.get('csv.analytics.content_specific.last_viewed');}}
  public transient final String STR_ANALYTICS_CONTENT_LOCATION { get { return labelMap.get('csv.analytics.content_specific.location');}}
  public transient final String STR_ANALYTICS_CONTENT_PHONE { get { return labelMap.get('csv.analytics.content_specific.phone');}}
  public transient final String STR_ANALYTICS_CONTENT_TOTAL_VIEWS { get { return labelMap.get('csv.analytics.content_specific.total_views');}}
  public transient final String STR_ANALYTICS_ENGAGEMENT_CONTENT_ALBUM_COUNT { get { return labelMap.get('csv.analytics.engagement.content.album_count');}}
  public transient final String STR_ANALYTICS_ENGAGEMENT_CONTENT_ALBUM_COUNT_PLURAL { get { return labelMap.get('csv.analytics.engagement.content.album_count_plural');}}
  public transient final String STR_ANALYTICS_ENGAGEMENT_CONTENT_BLOGPOST_COUNT { get { return labelMap.get('csv.analytics.engagement.content.blog_post_count');}}
  public transient final String STR_ANALYTICS_ENGAGEMENT_CONTENT_BLOGPOST_COUNT_PLURAL { get { return labelMap.get('csv.analytics.engagement.content.blog_post_count_plural');}}
  public transient final String STR_ANALYTICS_ENGAGEMENT_CONTENT_EVENT_COUNT { get { return labelMap.get('csv.analytics.engagement.content.event_count');}}
  public transient final String STR_ANALYTICS_ENGAGEMENT_CONTENT_EVENT_COUNT_PLURAL { get { return labelMap.get('csv.analytics.engagement.content.event_count_plural');}}
  public transient final String STR_ANALYTICS_ENGAGEMENT_CONTENT_PAGE_COUNT { get { return labelMap.get('csv.analytics.engagement.content.page_count');}}
  public transient final String STR_ANALYTICS_ENGAGEMENT_CONTENT_PAGE_COUNT_PLURAL { get { return labelMap.get('csv.analytics.engagement.content.page_count_plural');}}
  public transient final String STR_ANALYTICS_OFFICE_LOCATION { get { return labelMap.get('csv.analytics.office_location');}}
  public transient final String STR_ANALYTICS_PEOPLE_CONTENT_PUBLISHED { get { return labelMap.get('csv.analytics.people.content_published');}}
  public transient final String STR_ANALYTICS_PEOPLE_FAV_RECIEVED { get { return labelMap.get('csv.analytics.people.favorites_received');}}
  public transient final String STR_ANALYTICS_PEOPLE_FEED_POSTS { get { return labelMap.get('csv.analytics.people.feed_posts');}}
  public transient final String STR_ANALYTICS_PEOPLE_LIKES_MADE { get { return labelMap.get('csv.analytics.people.likes_made');}}
  public transient final String STR_ANALYTICS_PEOPLE_LIKES_RECIEVED { get { return labelMap.get('csv.analytics.people.likes_received');}}
  public transient final String STR_ANALYTICS_PEOPLE_PROFILE_VIEWS { get { return labelMap.get('csv.analytics.people.profile_views');}}
  public transient final String STR_ANALYTICS_PEOPLE_REPLIES { get { return labelMap.get('csv.analytics.people.replies');}}
  public transient final String STR_ANALYTICS_PEOPLE_OTHER_USERS { get { return labelMap.get('csv.analytics.people.replies_other_users');}}
  public transient final String STR_ANALYTICS_PEOPLE_SHARES_RECIEVED { get { return labelMap.get('csv.analytics.people.shares_received');}}
  public transient final String STR_ANALYTICS_SEARCH_CLICK_THROUGH_SINGULAR { get { return labelMap.get('csv.analytics.search.click_through');}}
  public transient final String STR_ANALYTICS_SEARCH_CLICK_THROUGH_PLURAL { get { return labelMap.get('csv.analytics.search.click_throughs');}}
  public transient final String STR_ANALYTICS_SEARCH_TERM { get { return labelMap.get('csv.analytics.search.search_term');}}
  public transient final String STR_ANALYTICS_SEARCH_SEARCHES_MADE { get { return labelMap.get('csv.analytics.search.searches_made');}}
  public transient final String STR_ANALYTICS_SITE_PERCENT_VIEWS_BROWSER { get { return labelMap.get('csv.analytics.site_specific.content.percentage_views_browser');}}
  public transient final String STR_ANALYTICS_SITE_CONTENT_PERCENT_VIEWS_MOBILE_APP { get { return labelMap.get('csv.analytics.site_specific.content.percentage_views_mobile_app');}}
  public transient final String STR_ANALYTICS_SITE_CONTENT_PERCENT_VIEWS_MOBILE_BROWSER { get { return labelMap.get('csv.analytics.site_specific.content.percentage_views_mobile_browser');}}
  public transient final String STR_ANALYTICS_SITE_DASHBOARD_PERCENT_VIEWS_BROWSER { get { return labelMap.get('csv.analytics.site_specific.dashboard.percentage_views_browser');}}
  public transient final String STR_ANALYTICS_SITE_DASHBOARD_PERCENT_VIEWS_MOBILE_APP { get { return labelMap.get('csv.analytics.site_specific.dashboard.percentage_views_mobile_app');}}
  public transient final String STR_ANALYTICS_SITE_DASHBOARD_PERCENT_VIEWS_MOBILE_BROWSER { get { return labelMap.get('csv.analytics.site_specific.dashboard.percentage_views_mobile_browser');}}
  public transient final String STR_ANALYTICS_SITE_TOTAL_CONTENT_VIEWS { get { return labelMap.get('csv.analytics.site_specific.total_content_views');}}
  public transient final String STR_ANALYTICS_SITE_TOTAL_DASHBOARD_VIEWS { get { return labelMap.get('csv.analytics.site_specific.total_dashboard_views');}}
	public transient final String STR_ANALYTICS_SITE_FOR_SITE { get { return labelMap.get('csv.analytics.sites.for_site');}}
  public transient final String STR_ANALYTICS_SITE_POPULARITY_SCORE { get { return labelMap.get('csv.analytics.sites.popularity_score');}}
  public transient final String STR_ANALYTICS_SITE_NAME { get { return labelMap.get('csv.analytics.sites.site_name');}}
  public transient final String STR_ANALYTICS_SITE_SITE_VIEWS { get { return labelMap.get('csv.analytics.sites.site_views');}}
  public transient final String STR_ANALYTICS_SITE_VIEWS { get { return labelMap.get('csv.analytics.sites.views');}}
  public transient final String STR_ANALYTICS_USERS_LOGGED_IN { get { return labelMap.get('csv.analytics.users_logged_in');}}
  public transient final String STR_ANALYTICS_ACTIVE_USERS_ADOPTION { get { return labelMap.get('csv.analytics.active_users_adoption');}}
  public transient final String STR_ANALYTICS_VIEWED_CONTENT { get { return labelMap.get('csv.analytics.viewed_content');}}
  public transient final String STR_CAMPAIGN_HISTORY_FULL_NAME { get { return labelMap.get('csv.campaign_history.full_name');}}
  public transient final String STR_CAMPAIGN_HISTORY_RESHARES { get { return labelMap.get('csv.campaign_history.reshares');}}
  public transient final String STR_CAMPAIGN_HISTORY_SOCIAL_NTWRK_SHARES { get { return labelMap.get('csv.campaign_history.social_network_shared');}}
  public transient final String STR_CAMPAIGN_HISTORY_TIME_SHARED { get { return labelMap.get('csv.campaign_history.time_shared');}}
  public transient final String STR_EVENT { get { return labelMap.get('csv.event.event');}}
  public transient final String STR_EVENT_RSVP { get { return labelMap.get('csv.event.rsvp');}}
  public transient final String STR_EVENT_RSVP_NOTE { get { return labelMap.get('csv.event.rsvp_note');}}
  public transient final String STR_CONTENT_TYPE_BLOG_POST { get { return labelMap.get('common.blog_post');}}
  public transient final String STR_CONTENT_TYPE_EVENT { get { return labelMap.get('common.event');}}
  public transient final String STR_CONTENT_TYPE_PAGE { get { return labelMap.get('common.page');}}
  public transient final String STR_CONTENT_TYPE_ALBUM { get { return labelMap.get('common.album');}}
  public transient final String STR_ANALYTICS_LAST_VALIDATED { get { return labelMap.get('csv.last_validated');}}
  public transient final String STR_ANALYTICS_VALIDATION_EXPIRED { get { return labelMap.get('csv.validation_expired');}}
  public transient final String STR_ANALYTICS_VALIDATION_REQUIRED { get { return labelMap.get('csv.validation_required');}}
  public transient final String STR_CONTENT_VIEWS { get { return labelMap.get('common.csv_content_views');}}
  public transient final String STR_UNIQUE_CONTENT_VIEWS { get { return labelMap.get('common.csv_unique_content_views');}}
  public transient final String STR_CONTENT_LIKES { get { return labelMap.get('common.csv_content_likes');}}
  public transient final String STR_CONTENT_COMMENTS { get { return labelMap.get('common.csv_content_comments');}}
  public transient final String STR_CONTENT_REPLIES { get { return labelMap.get('common.csv_content_replies');}}
  public transient final String STR_CONTENT_SHARES { get { return labelMap.get('common.csv_content_shares');}}
  public transient final String STR_CONTENT_FAVOURITES { get { return labelMap.get('common.csv_content_favourites');}}

  public transient final String STR_FILE_NAME_ADOPTION_DATA { get { return labelMap.get('csv.file_names.adoption_data');}}
	public transient final String STR_FILE_NAME_ADOPTION_LOGINS { get { return labelMap.get('csv.file_names.adoption_logins');}}
  public transient final String STR_FILE_NAME_ADOPTION_OVERVIEW { get { return labelMap.get('csv.file_names.adoption_overview');}}
  public transient final String STR_FILE_NAME_ADOPTION_PAGE_VIEWS { get { return labelMap.get('csv.file_names.adoption_page_views');}}
  public transient final String STR_FILE_NAME_ADOPTION_TREND { get { return labelMap.get('csv.file_names.adoption_trend');}}
	public transient final String STR_FILE_NAME_APP_NAME_MUST_READS { get { return labelMap.get('csv.file_names.app_name_must_reads');}}
  public transient final String STR_FILE_NAME_CONTENT_PUBLSHD { get { return labelMap.get('csv.file_names.content_published');}}
  public transient final String STR_FILE_NAME_CONTENT_VIEWS { get { return labelMap.get('csv.file_names.content_views');}}
  public transient final String STR_FILE_NAME_CONTENT_VIEWS_BY_TOP_DEPT { get { return labelMap.get('csv.file_names.content_views_by_top_departments');}}
  public transient final String STR_FILE_NAME_CONTENT_VIEWS_BY_TOP_LOCATIONS { get { return labelMap.get('csv.file_names.content_views_by_top_locations');}}
  public transient final String STR_FILE_NAME_ENGAGEMENT { get { return labelMap.get('csv.file_names.engagement');}}
  public transient final String STR_FILE_NAME_ENGAGEMENT_CONTENT_FVRT { get { return labelMap.get('csv.file_names.engagement_content_favorites');}}
  public transient final String STR_FILE_NAME_ENGMNT_CONTENT_LIKES { get { return labelMap.get('csv.file_names.engagement_content_likes');}}
  public transient final String STR_FILE_NAME_ENGMNT_CONTENT_POSTS { get { return labelMap.get('csv.file_names.engagement_content_posts');}}
  public transient final String STR_FILE_NAME_ENGMNT_CONTENT_PBLSHD { get { return labelMap.get('csv.file_names.engagement_content_published');}}
  public transient final String STR_FILE_NAME_ENGMNT_CONTENT_REPLIES { get { return labelMap.get('csv.file_names.engagement_content_replies');}}
  public transient final String STR_FILE_NAME_ENGMNT_CONTENT_SHARES { get { return labelMap.get('csv.file_names.engagement_content_shares');}}
  public transient final String STR_FILE_NAME_ENGMNT_CONTENT_TYPES { get { return labelMap.get('csv.file_names.engagement_content_types');}}
  public transient final String STR_FILE_NAME_ENGMNT_CONTENT_VIEWS { get { return labelMap.get('csv.file_names.engagement_content_views');}}
  public transient final String STR_FILE_NAME_ENGMNT_FEED_LIKES { get { return labelMap.get('csv.file_names.engagement_feed_likes');}}
  public transient final String STR_FILE_NAME_ENGMNT_FEED_POSTS { get { return labelMap.get('csv.file_names.engagement_feed_posts');}}
  public transient final String STR_FILE_NAME_ENGMNT_FEED_REPLIES { get { return labelMap.get('csv.file_names.engagement_feed_replies');}}
  public transient final String STR_FILE_NAME_ENGMNT_FEED_SHARES { get { return labelMap.get('csv.file_names.engagement_feed_shares');}}
	public transient final String STR_FILE_NAME_FVRT_RCVD { get { return labelMap.get('csv.file_names.favorites_received');}}
  public transient final String STR_FILE_NAME_FEED_POSTS { get { return labelMap.get('csv.file_names.feed_posts');}}
  public transient final String STR_FILE_NAME_LEAST_SEARCHES_PRFRMD { get { return labelMap.get('csv.file_names.least_searches_performed');}}
  public transient final String STR_FILE_NAME_LEAST_VIEWED_CONTENT { get { return labelMap.get('csv.file_names.least_viewed_content');}}
  public transient final String STR_FILE_NAME_LIKES_MADE { get { return labelMap.get('csv.file_names.likes_made');}}
  public transient final String STR_FILE_NAME_LIKES_RCVD { get { return labelMap.get('csv.file_names.likes_received');}}
  public transient final String STR_FILE_NAME_MONTHLY_REPORT { get { return labelMap.get('csv.file_names.monthly_report');}}
  public transient final String STR_FILE_NAME_MOST_SEARCHES_PRFRMD { get { return labelMap.get('csv.file_names.most_searches_performed');}}
  public transient final String STR_FILE_NAME_MOST_VIEWED { get { return labelMap.get('csv.file_names.most_viewed_content');}} 
  public transient final String STR_FILE_NAME_ORDER_CONTENT_PBLSHD { get { return labelMap.get('csv.file_names.order_content_published');}}
  public transient final String STR_FILE_NAME_ORDER_CONTENT_VIEWS_BY { get { return labelMap.get('csv.file_names.order_content_views_by');}}
  public transient final String STR_FILE_NAME_ORDER_CURRENTLY_PBLSHD { get { return labelMap.get('csv.file_names.order_currently_published');}}
  public transient final String STR_FILE_NAME_ORDER_ENGAGED_BY { get { return labelMap.get('csv.file_names.order_engaged_by');}}
  public transient final String STR_FILE_NAME_ORDER_LOGINS { get { return labelMap.get('csv.file_names.order_logins');}}
  public transient final String STR_FILE_NAME_ORDER_PAGE_VIEWS { get { return labelMap.get('csv.file_names.order_page_views');}}
  public transient final String STR_FILE_NAME_ORDER_POPULAR_CONTENT { get { return labelMap.get('csv.file_names.order_popular_content');}}
  public transient final String STR_FILE_NAME_ORDER_POPULAR_CONTENTS { get { return labelMap.get('csv.file_names.order_popular_contents');}}
  public transient final String STR_FILE_NAME_ORDER_POPULAR_VIDEOS { get { return labelMap.get('csv.file_names.order_popular_videos');}}
  public transient final String STR_FILE_NAME_VIDEOS { get { return labelMap.get('csv.file_names.videos');}}
  public transient final String STR_FILE_NAME_ORDER_GOVERNANCE_LIST { get { return labelMap.get('csv.file_names.order_governance_list');}}
  public transient final String STR_FILE_NAME_ORDER_POPULAR_SITES { get { return labelMap.get('csv.file_names.order_popular_sites');}}
  public transient final String STR_FILE_NAME_ORDER_VIEWED_CONTENT { get { return labelMap.get('csv.file_names.order_viewed_content');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_CONTENT_FVRTS { get { return labelMap.get('csv.file_names.performance_content_favorites');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_CONTENT_POSTS { get { return labelMap.get('csv.file_names.performance_content_posts');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_CONTENT_REPLIES { get { return labelMap.get('csv.file_names.performance_content_replies');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_CONTENT_SHARES { get { return labelMap.get('csv.file_names.performance_content_shares');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_CONTENT_UNUSEFUL { get { return labelMap.get('csv.file_names.performance_content_unuseful');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_CONTENT_USEFUL { get { return labelMap.get('csv.file_names.performance_content_useful');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_CONTENT_VIEWS { get { return labelMap.get('csv.file_names.performance_content_views');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_CONTENT_FAV { get { return labelMap.get('csv.file_names.performance_content_favorites');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_PPL_CONTENT_PUBLISHED { get { return labelMap.get('csv.file_names.performance_people_content_published');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_FAV_MADE { get { return labelMap.get('csv.file_names.performance_people_favorites_made');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_PPL_FAV_RECIEVED { get { return labelMap.get('csv.file_names.performance_people_favorites_received');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_PPL_FOLLOWERS { get { return labelMap.get('csv.file_names.performance_people_followers');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_PPL_FOLLOWING { get { return labelMap.get('csv.file_names.performance_people_following');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_PPL_LIKES_MADE { get { return labelMap.get('csv.file_names.performance_people_likes_made');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_PPL_LIKES_RECEIVED { get { return labelMap.get('csv.file_names.performance_people_likes_received');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_PPL_MENTIONS { get { return labelMap.get('csv.file_names.performance_people_mentions');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_PPL_POSTS { get { return labelMap.get('csv.file_names.performance_people_posts');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_PPL_PROFILE_VIEW { get { return labelMap.get('csv.file_names.performance_people_profile_view');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_PPL_REPLIES_MADE { get { return labelMap.get('csv.file_names.performance_people_replies_made');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_PPL_REPLIES_RCVD { get { return labelMap.get('csv.file_names.performance_people_replies_received');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_PPL_SHARES_MADE { get { return labelMap.get('csv.file_names.performance_people_shares_made');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_PPL_SHARES_RECIEVED { get { return labelMap.get('csv.file_names.performance_people_shares_received');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_SEARCH_NO_RESULTS { get { return labelMap.get('csv.file_names.performance_search_no_results_search_terms');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_SEARCH_TERMS { get { return labelMap.get('csv.file_names.performance_search_search_terms');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_SITES_CONTENT_PUBLISHED { get { return labelMap.get('csv.file_names.performance_sites_content_published');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_SITES_LIKES { get { return labelMap.get('csv.file_names.performance_sites_likes');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_SITES_MEMBERS { get { return labelMap.get('csv.file_names.performance_sites_members');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_SITES_POSTS { get { return labelMap.get('csv.file_names.performance_sites_posts');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_SITES_REPLIES { get { return labelMap.get('csv.file_names.performance_sites_replies');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_SITES_VIEWS { get { return labelMap.get('csv.file_names.performance_sites_views');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_TOPICS_ENDORSEMENTS { get { return labelMap.get('csv.file_names.performance_topics_endorsements');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_TOPICS_EXPERTISE { get { return labelMap.get('csv.file_names.performance_topics_expertise');}}
  public transient final String STR_FILE_NAME_PERFORMANCE_TOPICS_VIEWS { get { return labelMap.get('csv.file_names.performance_topics_views');}}
  public transient final String STR_FILE_NAME_PROFILE_VIEWS { get { return labelMap.get('csv.file_names.profile_views');}}
  public transient final String STR_FILE_NAME_REPLIES { get { return labelMap.get('csv.file_names.replies');}}
  public transient final String STR_FILE_NAME_REPLIES_FROM_OTHER_USERS { get { return labelMap.get('csv.file_names.replies_from_other_users');}}
  public transient final String STR_FILE_NAME_ATTENDEES_RSVP_YES { get { return labelMap.get('csv.file_names.rsvp');}}
  public transient final String STR_FILE_NAME_PEOPLE_EXPERTISE { get { return labelMap.get('common.csv_total_people');}}
  public transient final String STR_FILE_NAME_SEARCHES { get { return labelMap.get('csv.file_names.searches');}}
  public transient final String STR_FILE_NAME_SGMNT_MEMBERS { get { return labelMap.get('csv.file_names.segment_members');}}
  public transient final String STR_FILE_NAME_SHARES_RCVD { get { return labelMap.get('csv.file_names.shares_received');}}
  public transient final String STR_FILE_NAME_SOCIAL_CMPGN_HSTRY { get { return labelMap.get('csv.file_names.social_campaign_history');}}
  public transient final String STR_FILE_NAME_SUBSCRIPTION_MEMBERS { get { return labelMap.get('csv.file_names.subscription_members');}}
  public transient final String STR_FILE_NAME_AUDIENCE_MEMBERS { get { return labelMap.get('csv.file_names.audience_members');}}
  public transient final String STR_FILE_NAME_TOP_CLICK_THROUGH_TERMS { get { return labelMap.get('csv.file_names.top_click_through_terms');}}
  public transient final String STR_FILE_NAME_TOP_CLCK_THROUGH_TYPES { get { return labelMap.get('csv.file_names.top_click_through_types');}}
  public transient final String STR_FILE_NAME_TOP_SEARCH_TERMS { get { return labelMap.get('csv.file_names.top_search_terms');}}
  public transient final String STR_FILE_NAME_TOP_SEARCH_TERMS_NO_RESULTS { get { return labelMap.get('csv.file_names.top_search_terms_no_results');}}
  public transient final String STR_FILE_NAME_UNASSIGNED_SGMNT_USERS { get { return labelMap.get('csv.file_names.unassigned_segment_users');}}
  public transient final String STR_FILE_NAME_UNASSIGNED_USERS { get { return labelMap.get('csv.file_names.unassigned_users');}}
  public transient final String STR_FILE_NAME_CONTENT_VIEWS_BY_TYPE { get { return labelMap.get('csv.file_names.content_views_by_type');}}
  public transient final String STR_FILE_NAME_CONTENT_VIEWS_OVER_TIME { get { return labelMap.get('csv.file_names.content_views_over_time');}}
  public transient final String STR_FILE_NAME_KNOWLEDGE_PAGE { get { return labelMap.get('csv.file_names.knowledge_page');}}
  public transient final String STR_FILE_NAME_CONTENT_REFERRAL_SOURCE { get { return labelMap.get('csv.file_names.content_referral_source');}}

  public transient final String STR_RPRT_HDR_ATTENDEES_RSVP_YES { get { return labelMap.get('csv.report_header.rsvp');}}
  public transient final String STR_RPRT_HDR_CONTENT_REFERRAL_SOURCE { get { return labelMap.get('csv.report_header.content_referral_source');}}
  public transient final String STR_RPRT_HDR_KNOWLEDGE_PAGE { get { return labelMap.get('csv.report_header.knowledge_page');}}
  public transient final String STR_RPRT_HDR_CONTENT_VIEWS_OVER_TIME { get { return labelMap.get('csv.report_header.content_views_over_time');}}
  public transient final String STR_RPRT_HDR_ADOPTION_DATA { get { return labelMap.get('csv.report_header.adoption_data');}}
  public transient final String STR_RPRT_HDR_ADOPTION_LOGINS { get { return labelMap.get('csv.report_header.adoption_logins');}}
  public transient final String STR_RPRT_HDR_ADOPTION_OVERVIEW { get { return labelMap.get('csv.report_header.adoption_overview');}}
  public transient final String STR_RPRT_HDR_ADOPTION_PAGE_VIEWS { get { return labelMap.get('csv.report_header.adoption_page_views');}}
  public transient final String STR_RPRT_HDR_ADOPTION_TREND { get { return labelMap.get('csv.report_header.adoption_trend');}}
  public transient final String STR_RPRT_HDR_CONTENT_PUBLISHED { get { return labelMap.get('csv.report_header.content_published');}}
  public transient final String STR_RPRT_HDR_CONTENT_VIEWS { get { return labelMap.get('csv.report_header.content_views');}}
  public transient final String STR_RPRT_HDR_CONTENT_VIEWS_BY_TOP_DEPT { get { return labelMap.get('csv.report_header.content_views_by_top_departments');}}
  public transient final String STR_RPRT_HDR_CONTENT_VIEWS_BY_TOP_LOCATION { get { return labelMap.get('csv.report_header.content_views_by_top_locations');}}
  public transient final String STR_RPRT_HDR_ENGAGEMENT { get { return labelMap.get('csv.report_header.engagement');}}
  public transient final String STR_RPRT_HDR_ENGMNT_CONTENT_FVRTS { get { return labelMap.get('csv.report_header.engagement_content_favorites');}}
  public transient final String STR_RPRT_HDR_ENGMNT_CONTENT_LIKES { get { return labelMap.get('csv.report_header.engagement_content_likes');}}
  public transient final String STR_RPRT_HDR_ENGMNT_CONTENT_POSTS { get { return labelMap.get('csv.report_header.engagement_content_posts');}}
  public transient final String STR_RPRT_HDR_ENGMNT_CONTENT_PBLSHD { get { return labelMap.get('csv.report_header.engagement_content_published');}}
  public transient final String STR_RPRT_HDR_ENGMNT_CONTENT_REPLIES { get { return labelMap.get('csv.report_header.engagement_content_replies');}}
  public transient final String STR_RPRT_HDR_ENGMNT_CONTENT_SHARES { get { return labelMap.get('csv.report_header.engagement_content_shares');}}
  public transient final String STR_RPRT_HDR_ENGMNT_CONTENT_TYPES { get { return labelMap.get('csv.report_header.engagement_content_types');}}
  public transient final String STR_RPRT_HDR_ENGMNT_CONTENT_VIEWS { get { return labelMap.get('csv.report_header.engagement_content_views');}}
  public transient final String STR_RPRT_HDR_ENGMNT_FEED_LIKES { get { return labelMap.get('csv.report_header.engagement_feed_likes');}}
  public transient final String STR_RPRT_HDR_ENGMNT_FEED_POSTS { get { return labelMap.get('csv.report_header.engagement_feed_posts');}}
  public transient final String STR_RPRT_HDR_ENGMNT_FEED_REPLIES { get { return labelMap.get('csv.report_header.engagement_feed_replies');}}
  public transient final String STR_RPRT_HDR_ENGMNT_FEED_SHARES { get { return labelMap.get('csv.report_header.engagement_feed_shares');}}
  public transient final String STR_RPRT_HDR_FVRTS_RCVD { get { return labelMap.get('csv.report_header.favorites_received');}}
  public transient final String STR_RPRT_HDR_FEED_POSTS { get { return labelMap.get('csv.report_header.feed_posts');}}
  public transient final String STR_RPRT_HDR_LEAST_SEARCHES_PRFRMD { get { return labelMap.get('csv.report_header.least_searches_performed');}}
  public transient final String STR_RPRT_HDR_LEAST_VIEWED_CONTENT { get { return labelMap.get('csv.report_header.least_viewed_content');}}
  public transient final String STR_RPRT_HDR_LIKES_MADE { get { return labelMap.get('csv.report_header.likes_made');}}
  public transient final String STR_RPRT_HDR_LIKES_RCVD { get { return labelMap.get('csv.report_header.likes_received');}}
  public transient final String STR_RPRT_HDR_MONTHLY_RPRT { get { return labelMap.get('csv.report_header.monthly_report');}}
  public transient final String STR_RPRT_HDR_MOST_SEARCHES_PRFRMD { get { return labelMap.get('csv.report_header.most_searches_performed');}}
  public transient final String STR_RPRT_HDR_MOST_VIEWED_CONTENT { get { return labelMap.get('csv.report_header.most_viewed_content');}}
  public transient final String STR_RPRT_HDR_MUST_READS { get { return labelMap.get('csv.report_header.must_reads');}}
  public transient final String STR_RPRT_HDR_ORDER_CONTENT_PUBLISHED { get { return labelMap.get('csv.report_header.order_content_published');}}
  public transient final String STR_RPRT_HDR_MOST_CONTENT_VIEWS_BY { get { return labelMap.get('csv.report_header.most_content_views_by');}}
  public transient final String STR_RPRT_HDR_LEAST_CONTENT_VIEWS_BY { get { return labelMap.get('csv.report_header.least_content_views_by');}}
  public transient final String STR_RPRT_HDR_MOST_ENGAGED_BY { get { return labelMap.get('csv.report_header.most_engaged_by');}}
  public transient final String STR_RPRT_HDR_LEAST_ENGAGED_BY { get { return labelMap.get('csv.report_header.least_engaged_by');}}
  public transient final String STR_RPRT_HDR_MOST_LOGINS { get { return labelMap.get('csv.report_header.most_logins');}}
  public transient final String STR_RPRT_HDR_LEAST_LOGINS { get { return labelMap.get('csv.report_header.least_logins');}}
  public transient final String STR_RPRT_HDR_MOST_PAGE_VIEWS { get { return labelMap.get('csv.report_header.most_page_views');}}
  public transient final String STR_RPRT_HDR_LEAST_PAGE_VIEWS { get { return labelMap.get('csv.report_header.least_page_views');}}
  public transient final String STR_RPRT_HDR_MOST_POPULAR_CONTENT { get { return labelMap.get('csv.report_header.most_popular_content');}}
  public transient final String STR_RPRT_HDR_LEAST_POPULAR_CONTENT { get { return labelMap.get('csv.report_header.least_popular_content');}}
  public transient final String STR_RPRT_HDR_MOST_POPULAR_CONTENTS { get { return labelMap.get('csv.report_header.most_popular_contents');}}
  public transient final String STR_RPRT_HDR_LEAST_POPULAR_CONTENTS { get { return labelMap.get('csv.report_header.least_popular_contents');}}
  public transient final String STR_RPRT_HDR_ORDER_GOVERNANCE_LIST {get { return labelMap.get('csv.report_header.order_governance_list');}}
  public transient final String STR_RPRT_HDR_MOST_POPULAR_SITES { get { return labelMap.get('csv.report_header.most_popular_sites');}}
  public transient final String STR_RPRT_HDR_LEAST_POPULAR_SITES { get { return labelMap.get('csv.report_header.least_popular_sites');}}
  public transient final String STR_RPRT_HDR_MOST_VIEWED_CNTNT { get { return labelMap.get('csv.report_header.most_viewed_content');}}
  public transient final String STR_RPRT_HDR_LEAST_VIEWED_CNTNT { get { return labelMap.get('csv.report_header.least_viewed_content');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_CNTNT_FVRT { get { return labelMap.get('csv.report_header.performance_content_favorites');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_CNTNT_POSTS { get { return labelMap.get('csv.report_header.performance_content_posts');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_CNTNT_REPLIES { get { return labelMap.get('csv.report_header.performance_content_replies');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_CNTNT_SHARES { get { return labelMap.get('csv.report_header.performance_content_shares');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_CNTNT_UNUSEFUL { get { return labelMap.get('csv.report_header.performance_content_unuseful');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_CNTNT_USEFUL { get { return labelMap.get('csv.report_header.performance_content_useful');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_CNTNT_VIEWS { get { return labelMap.get('csv.report_header.performance_content_views');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_PPL_CONTENT_PBLSHD { get { return labelMap.get('csv.report_header.performance_people_content_published');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_PPL_FVRT_MADE { get { return labelMap.get('csv.report_header.performance_people_favorites_made');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_PPL_FVRT_RCVD { get { return labelMap.get('csv.report_header.performance_people_favorites_received');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_PPL_FOLLOWERS { get { return labelMap.get('csv.report_header.performance_people_followers');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_PPL_FOLLOWING { get { return labelMap.get('csv.report_header.performance_people_following');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_PPL_LIKES_MADE { get { return labelMap.get('csv.report_header.performance_people_likes_made');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_PPPL_LIKES_RCVD { get { return labelMap.get('csv.report_header.performance_people_likes_received');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_PPL_MENTIONS { get { return labelMap.get('csv.report_header.performance_people_mentions');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_PPL_POSTS { get { return labelMap.get('csv.report_header.performance_people_posts');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_PPL_PRFL_VIEWS { get { return labelMap.get('csv.report_header.performance_people_profile_view');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_PPL_REPLIES_MADE { get { return labelMap.get('csv.report_header.performance_people_replies_made');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_PPL_REPLIES_RCVD { get { return labelMap.get('csv.report_header.performance_people_replies_received');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_PPL_SHARES_MADE { get { return labelMap.get('csv.report_header.performance_people_shares_made');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_PPL_SHARES_RCVD { get { return labelMap.get('csv.report_header.performance_people_shares_received');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_SEARCH_NO_RESULT { get { return labelMap.get('csv.report_header.performance_search_no_results_search_terms');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_SEARCH { get { return labelMap.get('csv.report_header.performance_search_search_terms');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_SITES_CNTNT_PBLSHD { get { return labelMap.get('csv.report_header.performance_sites_content_published');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_SITES_LIKES { get { return labelMap.get('csv.report_header.performance_sites_likes');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_SITES_MEMBERS { get { return labelMap.get('csv.report_header.performance_sites_members');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_SITES_POSTS { get { return labelMap.get('csv.report_header.performance_sites_posts');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_SITES_REPLIES { get { return labelMap.get('csv.report_header.performance_sites_replies');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_SITES_VIEWS { get { return labelMap.get('csv.report_header.performance_sites_views');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_TOPICS_ENDRSMNT { get { return labelMap.get('csv.report_header.performance_topics_endorsements');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_TOPICS_EXPERTISE { get { return labelMap.get('csv.report_header.performance_topics_expertise');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_TOPIC_FOLLOWERS { get { return labelMap.get('csv.report_header.performance_topics_followers');}}
  public transient final String STR_RPRT_HDR_PERFORMANCE_TOPIC_VIEWS { get { return labelMap.get('csv.report_header.performance_topics_views');}}
  public transient final String STR_RPRT_HDR_PROFILE_VIEWS { get { return labelMap.get('csv.report_header.profile_views');}}
  public transient final String STR_RPRT_HDR_REPLIES { get { return labelMap.get('csv.report_header.replies');}}
  public transient final String STR_RPRT_HDR_REPLIES_FRM_OTHER_USERS { get { return labelMap.get('csv.report_header.replies_from_other_users');}}
  public transient final String STR_RPRT_HDR_SEARCHES { get { return labelMap.get('csv.report_header.searches');}}
  public transient final String STR_RPRT_HDR_SGMNT_MEMBERS { get { return labelMap.get('csv.report_header.segment_members');}}
  public transient final String STR_RPRT_HDR_SHARES_RCVD { get { return labelMap.get('csv.report_header.shares_received');}}
  public transient final String STR_RPRT_HDR_SOCIAL_CAMPAIGN_HSTRY { get { return labelMap.get('csv.report_header.social_campaign_history');}}
  public transient final String STR_RPRT_HDR_SUBSCRIPTION_MEMBERS { get { return labelMap.get('csv.report_header.subscription_members');}}
  public transient final String STR_RPRT_HDR_AUDIENCE_MEMBERS { get { return labelMap.get('csv.report_header.audience_members');}}
  public transient final String STR_RPRT_HDR_TOP_CLICK_THROUGH_TERMS { get { return labelMap.get('csv.report_header.top_click_through_terms');}}
  public transient final String STR_RPRT_HDR_TOP_CLICK_THROUGH_TYPES { get { return labelMap.get('csv.report_header.top_click_through_types');}}
  public transient final String STR_RPRT_HDR_TOP_SEARCH_TERMS { get { return labelMap.get('csv.report_header.top_search_terms');}}
  public transient final String STR_RPRT_HDR_TOP_SEARCH_TERMS_NO_RESULTS { get { return labelMap.get('csv.report_header.top_search_terms_no_results');}}
  public transient final String STR_RPRT_HDR_UNASSIGNED_SGMNT_USERS { get { return labelMap.get('csv.report_header.unassigned_segment_users');}}
  public transient final String STR_RPRT_HDR_UNASSIGNED_USERS { get { return labelMap.get('csv.report_header.unassigned_users');}}
	public transient final String STR_RPRT_HDR_PEOPLE_COMPLETENESS { get { return labelMap.get('csv.report_header.people_completeness');}}
	public transient final String STR_RPRT_HDR_CONTENT_VIEWS_BY_TYPE { get { return labelMap.get('csv.report_header.content_view_by_type');}}
	public transient final String STR_RPRT_HDR_PEOPLE_EXPERTISE { get { return labelMap.get('analytics.page_group.people');}}

	public transient final String STR_MOST { get { return labelMap.get('common.csv_most');}}
	public transient final String STR_LEAST { get { return labelMap.get('common.csv_least');}}
	public transient final String STR_ROLE { get { return labelMap.get('common.csv_role');}}
	public transient final String STR_TOPIC_NAME { get { return labelMap.get('common.csv_topic_name');}}
	public transient final String STR_RPRT_HDR_CURRENTLY_PBLSHD { get { return labelMap.get('csv.report_header.currently_published');}}

	public transient final String STR_RPRT_HDR_SEARCH_LIST { get { return labelMap.get('csv.report_header.search_list');}}
	public transient final String STR_RPRT_HDR_SITE_VIEWS_FOR_SITE { get { return labelMap.get('csv.report_header.site_views_for_site');}}
	public transient final String STR_RPRT_HDR_APP_PAGE_VIEWS_FOR_TYPE { get { return labelMap.get('csv.report_header.app_page_views_for_type');}}
	public transient final String STR_RPRT_HDR_PERFORMANCE_CNTNT_LIKES { get { return labelMap.get('csv.report_header.performance_content_likes');}}
	public transient final String STR_RPRT_HDR_USERS_PBLSHD_MOST_CNTNT { get { return labelMap.get('csv.report_header.users_published_most_content');}}
	public transient final String STR_RPRT_HDR_USERS_MOST_FVRT { get { return labelMap.get('csv.report_header.users_most_favorited');}}
	public transient final String STR_RPRT_HDR_SITE_MOST_CNTNT_PBLSHD { get { return labelMap.get('csv.report_header.site_most_content_published');}}
	public transient final String STR_RPRT_HDR_SITE_LEAST_CNTNT_PBLSHD { get { return labelMap.get('csv.report_header.site_least_content_published');}}
	public transient final String STR_RPRT_HDR_MOST_SEARCHES_BY_RESULT_TYPE { get { return labelMap.get('csv.report_header.most_searches_by_result_type');}}
	public transient final String STR_RPRT_HDR_LEAST_SEARCHES_BY_RESULT_TYPE { get { return labelMap.get('csv.report_header.least_searches_by_result_type');}}

	public transient final String STR_FILE_NAME_CURRENTLY_PBLSHD { get { return labelMap.get('csv.file_name.currently_published');}}
	public transient final String STR_FILE_NAME_SEARCH_LIST { get { return labelMap.get('csv.file_name.search_list');}}
	public transient final String STR_FILE_NAME_SITE_VIEWS_FOR_SITE { get { return labelMap.get('csv.file_name.site_views_for_site');}}
	public transient final String STR_FILE_NAME_APP_PAGE_VIEWS_FOR_TYPE { get { return labelMap.get('csv.file_name.app_page_views_for_type');}}
	public transient final String STR_FILE_NAME_PERFORMANCE_CNTNT_LIKES { get { return labelMap.get('csv.file_name.performance_content_likes');}}
	public transient final String STR_FILE_NAME_PERFORMANCE_TOPICS_FOLLOWERS { get { return labelMap.get('csv.file_name.performance_topics_followers');}}
	public transient final String STR_FILE_NAME_CNTNT_VIEWS_FIELD_NAME { get { return labelMap.get('csv.file_name.content_views_field_name');}}
	public transient final String STR_FILE_NAME_PAGE_VIEWS { get { return labelMap.get('csv.file_name.page_views');}}
	public transient final String STR_FILE_NAME_LOGINS { get { return labelMap.get('csv.file_name.logins');}}
	public transient final String STR_FILE_NAME_ENGAGED_BY { get { return labelMap.get('csv.file_name.engaged_by');}}
	public transient final String STR_FILE_NAME_PEOPLE_COMPLETENESS { get { return labelMap.get('csv.file_name.people_completeness');}}

	public transient final String STR_DASHBOARD { get { return labelMap.get('common.csv_dashboard');}}
	public transient final String STR_CONTENT { get { return labelMap.get('common.csv_content');}}
	public transient final String STR_RPRT_HDR_PPL_MADE_MOST_POSTS { get { return labelMap.get('csv.report_header.people.made_most_posts');}}
	public transient final String STR_RPRT_HDR_PPL_LIKED_MOST_CNTNT_POSTS_REPLIES { get { return labelMap.get('csv.report_header.people.liked_most_content_posts_replies');}}
	public transient final String STR_RPRT_HDR_PPL_RCVD_MOST_LIKES_CNTNT_POSTS_REPLIES { get { return labelMap.get('csv.report_header.people.received_most_likes_content_posts_replies');}}
	public transient final String STR_RPRT_HDR_PPL_MOST_VIEWED_PROFILES { get { return labelMap.get('csv.report_header.people.most_viewed_profiles');}}
	public transient final String STR_RPRT_HDR_PPL_REPLIED_MOST_FEEDS { get { return labelMap.get('csv.report_header.people.replied_most_feeds');}}
	public transient final String STR_RPRT_HDR_PPL_MOST_REPLIES_ON_POSTS { get { return labelMap.get('csv.report_header.people.most_replies_on_posts');}}
	public transient final String STR_RPRT_HDR_PPL_CNTNT_POSTS_MOST_SHARED { get { return labelMap.get('csv.report_header.people.content_posts_most_shared');}}
	public transient final String STR_FILE_NAME_ADOPTION_ORDER_LOGINS_FIELDNAME { get { return labelMap.get('csv.file_name.adoption.order_logins_fieldname');}}
	public transient final String STR_FILE_NAME_CONTENT_VIEWS_ENGAGEMENT { get { return labelMap.get('csv.file_names.content_views_engagement');}}
	public transient final String STR_UNLISTED_SITE_NAME { get { return labelMap.get('analytics.sites_tiles.unlisted_site');}}
	public transient final String STR_PRIVATE_SITE_CONTENT { get { return labelMap.get('analytics.content_tiles.private_site_content');}}
	public transient final String STR_UNLISTED_SITE_CONTENT { get { return labelMap.get('analytics.content_tiles.unlisted_site_content');}}

	public transient final String STR_PROFILE_COMPLETENESS_PROFILE_IMAGE { get { return labelMap.get('csv.profile_completeness.profile_photo');}}
	public transient final String STR_PROFILE_COMPLETENESS_PHONE_NUMBER { get { return labelMap.get('csv.profile_completeness.phone_number');}}
	public transient final String STR_PROFILE_COMPLETENESS_ABOUT_TEXT { get { return labelMap.get('csv.profile_completeness.about_text');}}
	public transient final String STR_PROFILE_COMPLETENESS_BIRTHDAY { get { return labelMap.get('csv.profile_completeness.birthday');}}

	public transient final String STR_CONTENT_VIEW_PAGE_VIEWS { get { return labelMap.get('csv.content_views.page_views');}}
	public transient final String STR_CONTENT_VIEW_EVENT_VIEWS { get { return labelMap.get('csv.content_views.event_views');}}
	public transient final String STR_CONTENT_VIEW_ALBUM_VIEWS { get { return labelMap.get('csv.content_views.album_views');}}
	public transient final String STR_CONTENT_VIEW_BLOG_VIEWS { get { return labelMap.get('csv.content_views.blog_views');}}

	public transient final String STR_ANALYTICS_REFERRAL_REFERRAL_SOURCE { get { return labelMap.get('csv.referral.referral_source');}}
	public transient final String STR_ANALYTICS_REFERRAL_CONTENT_ITEMS { get { return labelMap.get('csv.referral.content_items');}}
	public transient final String STR_ANALYTICS_REFERRAL_REFERRALS { get { return labelMap.get('csv.referral.referrals');}}
	public transient final String STR_ANALYTICS_REFERRAL_REFERRALS_PER_ITEM { get { return labelMap.get('csv.referral.referrals_per_item');}}
	public transient final String STR_ANALYTICS_VIDEO_VIDEO_TITLE { get { return labelMap.get('csv.video.video_title');}}
	public transient final String STR_ANALYTICS_VIDEO_UPLOADER { get { return labelMap.get('csv.video.video_uploader');}}
	public transient final String STR_ANALYTICS_VIDEO_UPLOADED_DATE { get { return labelMap.get('csv.video.video_uploaded_date');}}
	public transient final String STR_ANALYTICS_VIDEO_VIEWS { get { return labelMap.get('csv.video.video_views');}}
	public transient final String STR_ANALYTICS_VIDEO_VIEWERS { get { return labelMap.get('csv.video.video_viewers');}}
	public transient final String STR_ANALYTICS_WATCH_TIME { get { return labelMap.get('csv.video.watch_time');}}
	public transient final String STR_ANALYTICS_TOTAL_VIDEOS_PLAYED { get { return labelMap.get('csv.video.total_videos_played');}}
	public transient final String STR_ANALYTICS_AUDIENCE_ROLE { get { return labelMap.get('csv.content_views.audience_role');}}
	public transient final String STR_ANALYTICS_SITE_ROLE { get { return labelMap.get('csv.content_views.site_role');}}
	/*Page Group Translation
	
	public transient final String STR_KEY_1 = 'analytics.content_referral.home_carousel';
	public transient final String STR_KEY_2 = 'analytics.content_referral.site_carousel';
	public transient final String STR_KEY_3 = 'analytics.content_referral.home_feed';
	public transient final String STR_KEY_4 = 'analytics.content_referral.site_feed';
	public transient final String STR_KEY_5 = 'analytics.content_referral.home_dashboard_tile';
	public transient final String STR_KEY_6 = 'analytics.content_referral.site_dashboard_tile';
	public transient final String STR_KEY_7 = 'analytics.content_referral.favorites';
	public transient final String STR_KEY_8 = 'analytics.content_referral.must_read_listing';
	public transient final String STR_KEY_9 = 'analytics.content_referral.events_listing';
	public transient final String STR_KEY_10 = 'analytics.content_referral.user_published';
	public transient final String STR_KEY_11 = 'analytics.content_referral.my_content';
	public transient final String STR_KEY_12 = 'analytics.content_referral.site_pages_content';
	public transient final String STR_KEY_13 = 'analytics.content_referral.search_results';
	public transient final String STR_KEY_14 = 'analytics.content_referral.search_auto_complete';
	public transient final String STR_KEY_15 = 'analytics.content_referral.recent_search';
	public transient final String STR_KEY_16 = 'analytics.content_referral.topic_content_listing';
	public transient final String STR_KEY_17 = 'analytics.content_referral.global_analytics_content_tab';
	public transient final String STR_KEY_18 = 'analytics.content_referral.top_stories';
	public transient final String STR_KEY_19 = 'analytics.content_referral.newsletter';
	public transient final String STR_KEY_20 = 'analytics.content_referral.activity_notifications_email';
	public transient final String STR_KEY_21 = 'analytics.content_referral.slack';
	public transient final String STR_KEY_22 = 'analytics.content_referral.in_app_notification';
	public transient final String STR_KEY_23 = 'analytics.content_referral.site_content_tab';
	public transient final String STR_KEY_24 = 'analytics.content_referral.sms_must_read';
	public transient final String STR_KEY_25 = 'analytics.content_referral.related_content';
	public transient final String STR_KEY_26 = 'analytics.content_referral.analytics_monthly_report';
	public transient final String STR_KEY_27 = 'analytics.content_referral.content_notifications';
	public transient final String STR_KEY_28 = 'analytics.content_referral.global_auto_complete';
	public transient final String STR_KEY_29 = 'analytics.content_referral.home_feed_smart_post';
	public transient final String STR_KEY_30 = 'analytics.content_referral.site_smart_feed_onboarding_section';
	public transient final String STR_KEY_31 = 'analytics.content_referral.site_content_onboarding_section';
	public transient final String STR_KEY_32 = 'analytics.content_referral.home_onboarding_smart_post';
	
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
 	private ExternalAnalyticsService externalAnalyticsServiceObj = new ExternalAnalyticsService();
	private final String ACTION_VALUE_GET_RSVP_LIST = 'getRsvpList';
	 
	private final String ACTION_GET_LOGINS = 'getLogins';
	private final String ACTION_GET_PAGE_VIEWS = 'getPageviews';
	private final String ACTION_GET_ADOPTION = 'getAdoption';
	private final String ACTION_GET_ADOPTION_COUNTS = 'getAdoptionCounts';
	private final String ACTION_GET_ADOPTION_AVERAGE = 'getAdoptionAverage';
	
	private final String ACTION_GET_PERFORMANCE_SITES_MEMBERS = 'getPerformanceSitesMembers';
	private final String ACTION_GET_PERFORMANCE_SITES_POSTS = 'getPerformanceSitesPosts';
	private final String ACTION_GET_PERFORMANCE_SITES_LIKES = 'getPerformanceSitesLikes';
	private final String ACTION_GET_PERFORMANCE_SITES_REPLIES = 'getPerformanceSitesReplies';
	private final String ACTION_GET_PERFORMANCE_SITES_VIEWS = 'getPerformanceSitesViews';
	private final String ACTION_GET_PERFORMANCE_SITES_PUBLISHED = 'getPerformanceSitespublished';
	
	private final String ACTION_GET_PERFORMANCE_PEOPLE_FAVORITES = 'getPerformancePeopleFavorites';
	private final String ACTION_GET_PERFORMANCE_PEOPLE_FAVORITES_RECEIVED = 'getPerformancePeopleFavorites_Received';
	private final String ACTION_GET_PERFORMANCE_PEOPLE_PUBLISHED = 'getPerformancePeoplePublished';
	private final String ACTION_GET_PERFORMANCE_PEOPLE_MENTIONS = 'getPerformancePeopleMentions';
	private final String ACTION_GET_PERFORMANCE_PEOPLE_POSTS = 'getPerformancePeoplePosts';
	private final String ACTION_GET_PERFORMANCE_PEOPLE_REPLIES = 'getPerformancePeopleReplies';
	private final String ACTION_GET_PERFORMANCE_PEOPLE_REPLIES_RECEIVED = 'getPerformancePeopleReplies_Received';
	private final String ACTION_GET_PERFORMANCE_PEOPLE_FOLLOWERS = 'getPerformancePeopleFollowers';
	private final String ACTION_GET_PERFORMANCE_PEOPLE_FOLLOWING = 'getPerformancePeopleFollowing';
	private final String ACTION_GET_PERFORMANCE_PEOPLE_LIKES = 'getPerformancePeopleLikes';
	private final String ACTION_GET_PERFORMANCE_PEOPLE_LIKES_RECEIVED = 'getPerformancePeopleLikes_Received';
	private final String ACTION_GET_PERFORMANCE_PEOPLE_SHARES = 'getPerformancePeopleShares';
	private final String ACTION_GET_PERFORMANCE_PEOPLE_SHARES_RECEIVED = 'getPerformancePeopleShares_Received';
	
	private final String ACTION_GET_PERFORMANCE_CONTENT_FAVORITES = 'getPerformanceContentFavorites';
	private final String ACTION_GET_PERFORMANCE_CONTENT_LIKES = 'getPerformanceContentLikes';
	private final String ACTION_GET_PERFORMANCE_CONTENT_POSTS = 'getPerformanceContentPosts';
	private final String ACTION_GET_PERFORMANCE_CONTENT_REPLIES = 'getPerformanceContentReplies';
	private final String ACTION_GET_PERFORMANCE_CONTENT_SHARES = 'getPerformanceContentShares';
	private final String ACTION_GET_PERFORMANCE_CONTENT_UNUSEFUL = 'getPerformanceContentUnuseful';
	private final String ACTION_GET_PERFORMANCE_CONTENT_USEFUL = 'getPerformanceContentUseful';
	private final String ACTION_GET_PERFORMANCE_CONTENT_VIEWS = 'getPerformanceContentViews';
	private final String ACTION_GET_CONTENT_VIEWS_BY_TYPE_CSV = 'getContentViewsByTypeCsv';
	private final String ACTION_GET_CONTENT_VIEWS_OVER_TIME_CSV = 'getContentViewsOverTimeCsv';
	
	private final String ACTION_GET_PERFORMANCE_TOPIC_ENDORSEMENTS = 'getPerformanceTopicsEndorsements';
	private final String ACTION_GET_PERFORMANCE_TOPIC_EXPERTISE = 'getPerformanceTopicsExpertise';
	private final String ACTION_GET_PERFORMANCE_TOPIC_FOLLOWERS = 'getPerformanceTopicsFollowers';
	private final String ACTION_GET_PERFORMANCE_TOPIC_VIEWS = 'getPerformanceTopicsViews';
	
	private final String ACTION_GET_PERFORMANCE_SEARCH = 'getPerformanceSearch';
	
	private final String ACTION_GET_PERFORMANCE_ZERO_SEARCH_RESULTS = 'getPerformanceZeroSearchResults';
	
	private final String ACTION_GET_ENGAGEMENT_FEED_POSTS = 'getEngagementFeedPosts';
	private final String ACTION_GET_ENGAGEMENT_FEED_LIKES = 'getEngagementFeedLikes';
	private final String ACTION_GET_ENGAGEMENT_FEED_REPLIES = 'getEngagementFeedReplies';
	private final String ACTION_GET_ENGAGEMENT_FEED_SHARES = 'getEngagementFeedShares';
	
	private final String ACTION_GET_ENGAGEMENT_CONTENT_FAVORITES = 'getEngagementContentFavorites';
	private final String ACTION_GET_ENGAGEMENT_CONTENT_LIKES = 'getEngagementContentLikes';
	private final String ACTION_GET_ENGAGEMENT_CONTENT_POSTS = 'getEngagementContentPosts';
	private final String ACTION_GET_ENGAGEMENT_CONTENT_PUBLISHED = 'getEngagementContentPublished';
	private final String ACTION_GET_ENGAGEMENT_CONTENT_REPLIES = 'getEngagementContentReplies';
	private final String ACTION_GET_ENGAGEMENT_CONTENT_SHARES = 'getEngagementContentShares';
	private final String ACTION_GET_ENGAGEMENT_CONTENT_VIEWS = 'getEngagementContentViews';
	private final String ACTION_GET_ENGAGEMENT_CONTENT_TYPES = 'getEngagementContentTypes';
	private final string ACTION_GET_PERFORMANCE_PEOPLE_PROFILE_VIEWS = 'getPerformancePeopleprofile_views';
	private final String ACTION_GET_MUST_READ_HISTORY = 'getMustReadHistory';
	private final String ACTION_GET_SEGMENTATION_PEOPLE = 'getSegmentationMembers';
	private final String ACTION_GET_AUDIENCE_PEOPLE = 'getAudienceMembers';
	private final String ACTION_GET_PEOPLE_EXPERTISE = 'getPeopleExpertise';
	private final String ACTION_CAMPAIGN_SHARE_HISTORY_DATA = 'getCampaignShareData';
	private final String ACTION_GET_UNASSIGNED_SEGMENT_USERS = 'getUnassignedSegmentUsers';
	private final String ACTION_GET_UNASSIGNED_USERS = 'getUnassignedUsers';
	
	private final String ACTION_GET_CONTENT_VIEWS = 'getContentViews';
	private final String ACTION_GET_CONTENT_VIEWS_CSV = 'getContentViewsCsv';
	private final String ACTION_GET_CONTENT_VIEWS_TOP_DEPARTMENTS_CSV = 'getContentViewsTopDepartmentsCsv';
	private final String ACTION_GET_CONTENT_VIEWS_TOP_LOCATIONS_CSV = 'getContentViewsTopLocationsCsv';
	private final String ACTION_GET_VIEWS_OVER_TIME_CSV = 'getViewsOverTimeCsv';
	private final String ACTION_GET_LOGINS_OVER_TIME_CSV = 'getLoginsOverTimeCsv';
	private final String ACTION_GET_CONTENT_VIEWS_LIST = 'getContentViewsList';
	private final String ACTION_GET_VIEWS_LIST = 'getViewsList';
	private final String ACTION_GET_LOGINS_LIST = 'getLoginsList';
	private final String ACTION_GET_ENGAGEMENT_LIST = 'getEngagementList';
	private final String ACTION_GET_CONTENT_POPULAR = 'getContentPopularity';
	private final String ACTION_GET_GOVERNANCE_LIST = 'getGovernanceList';
	private final String ACTION_GET_SITE_PUBLICATIONS = 'getSitePublication';
	private final String ACTION_GET_SITE_POPULAR = 'getSitePopularity';
	private final String ACTION_GET_APP_PAGE_VIEWS = 'getAppPageViews';
	private final String ACTION_GET_CONTENT_PUBLICATIONS = 'getContentPublications';
	private final String ACTION_GET_MONTHLY_REPORT = 'getMonthlyReports';
	private final String ACTION_GET_PEOPLE_PERFORMANCE = 'getPeoplePerformance';
	private final String ACTION_GET_PERFORMANCE_CONTENT = 'getPerformanceContent';
	private final String ACTION_GET_SITE_VIEWS = 'getSiteViews';
	private final String ACTION_GET_SITE_VIEWS_TOTAL = 'getSiteViewsTotal';
	private final String ACTION_GET_ENGAGEMENT = 'getEngagement';
	private final String ACTION_GET_ADOPTION_DATA = 'getAdoptionData';
	private final String ACTION_GET_SEARCHES = 'getSearches';
	private final String ACTION_GET_SEARCH_LIST ='getSearchList';
	private final String ACTION_GET_SITE_COUNTS = 'getSiteCounts';
	private final String ACTION_GET_PEOPLE_PROFILE_COMPLETENESS = 'getPeopleProfileCompleteness';
	private final String ACTION_GET_KNOWLEDGE_PAGE_STATS = 'getKnowledgePageCsv';
	private final String ACTION_GET_CONTENT_REERRAL_SOURCES = 'getContentReferralSources';
	private final String ACTION_GET_CONTENT_ENGAGEMENT_CSV = 'getContentEngagementCsv';
	private final String ACTION_GET_APP_ADOPTION = 'getAppAdoption';
	private final String ACTION_GET_VIDEO_POPULARITY = 'getVideoPopularity';
	private final String ACTION_GET_VIDEO_ADOPTION = 'getVideoAdoption';
	private final String ACTION_GET_VIDEO_ADOPTION_CSV ='getVideoAdoptionCsv';
 

	private final String REQUEST_PARAM_ACTION = 'action';
	private final String REQUEST_PARAM_TYPE = 'type';
	
	public List<RsvpCsvWrapper> rsvpCsvWrapperList{get;set;}
	public List<AnalyticsWrapper.PerformanceSitesData> performanceSiteDataList{get;set;}
	public List<AnalyticsWrapper.PerformancePeopleData> performancePeopleDataList{get;set;}
	public List<AnalyticsWrapper.PerformanceContentData> performanceContentDataList{get;set;}
	public List<AnalyticsWrapper.PerformanceContentData> performanceContentDataListForExternalAnalytics{get;set;}
	public List<AnalyticsWrapper.PerformanceTopicsData> performanceTopicsDataList {get;set;}
	public List<AnalyticsWrapper.PerformanceSearchData> performanceSearchDataList{get;set;}
	public List<AnalyticsWrapper.EngagementfeedData> performanceEngagementFeedList{get;set;}
	public List<AnalyticsWrapper.EngagementContentData> performanceEngagementContentList{get;set;}
	public List<AnalyticsWrapper.EngagementContentTypesData> performanceEngagementContentTypesList{get;set;}
	public List<CampaignWrapper.CampaignReportWrapper> campaignHistoryReportList{get;set;}
	public List<AnalyticsWrapper.ProfileCompletenessCsvWrapper> peopleCompletenessList{get;set;}
	public List<AnalyticsWrapper.ContentViewsCsvWrapper> contentViewsByTypeList{get;set;}
	public List<AnalyticsWrapper.ContentReferralSourceData> contentReferralSourceDataList{get;set;}

	public AnalyticsWrapper.ContentRelatedData contentRelatedDate{get;set;}
	public List<AnalyticsWrapper.ViewsOverTime> viewList{get;set;}
	
	public List<AnalyticsWrapper.PeoplePerformanceData> peopleData{get;set;}
	public String peopleDataCSVHeader{get;set;}
	public List<String> peopleDataCSVValueList{get;set;}

	public List<AnalyticsWrapper.ContentInformation> contentInfo{get;set;}
	public List<AnalyticsWrapper.videoPopularity> videoInfo{get;set;}
	public List<AnalyticsWrapper.videoAdoptionCsv> videoAdoptionInfo{get;set;}
	public AnalyticsWrapper.videoAdoption videoAdoption{get;set;}
	public List<AnalyticsWrapper.LabelValueData> governanceInfo{get;set;}
	public AnalyticsWrapper.SiteCountData siteCounts{get;set;}
	public List<AnalyticsWrapper.MonthlyReportData> listOfMonthlyReportData{get;set;}
	public AnalyticsWrapper.EngagementData engagement{get;set;}
	public List<AnalyticsWrapper.ViewsOverTime> searchData{get;set;}
	
	public String contentId{get;set;}
	public String contentTitle{get;set;}
	public String segmentName{get;set;}
	public String campaignId;
	public String toDate{get;set;}
	public String fromdate{get;set;}
	public String fileName{get;set;}
	public String reportHeader{get;set;}
	public String contentType;
	public String siteId{get;set;}
	public Integer total{get;set;}
	public String groupBy;
	public String orderBy;
	public String filterBy{get;set;}
	public String resultType{get;set;}
	public String filterValue;
	public String action{get;set;}
	public String metric{get;set;}
	public String typeParam{get;set;}
	public String filterValueName{get;set;}
	public List<String> listOfHeaders{set;get;}
	public List<String> expertiseId{set;get;}
	public String currentDateTime{get{
		String currentDateStr = '';
	 	Datetime cDT = System.now();
		currentDateStr = LocaleContext.getLocalisedDateAsDDMMMMYYYYhhmmss(cDT, UserContext.languageLocaleKey);

		return currentDateStr;
	}set;}

	public String localizedToDate{get{
		return String.isBlank(toDate) ? '' : LocaleContext.getLocalisedDateCSV(toDate, UserContext.languageLocaleKey);
	}set;}

	public String localizedFromDate{get{
		return String.isBlank(fromdate) ? '' : LocaleContext.getLocalisedDateCSV(fromdate, UserContext.languageLocaleKey);
	}set;}
	
	public String engagementType{get{
		return readParam(REQUEST_PARAM_TYPE);
	}set;}
	
    public Boolean isSegmentsEnabled{get;set;}
	
	public Boolean isEventEnabled{get;set;}
	public Boolean isPageEnabled{get;set;}
	public Boolean isAlbumEnabled{get;set;}
	public Boolean isBlogEnabled{get;set;}
	public Boolean isCategoryEnabled{get;set;}

	public AnalyticsWrapper.AdoptionOverview adoptionOverviewObj{get;set;}
	public AnalyticsWrapper.AdoptionAverageData adoptionAverageData{get;set;}
	public List<AnalyticsWrapper.AdoptionData> adoptionDataList{get;set;}
	public List<AnalyticsWrapper.AdoptionCSV> adoptionCSV{get;set;}
	public AnalyticsWrapper.adoptionCSVData adoptionCSVData{get;set;}
	public List<AnalyticsWrapper.ContentViewsCSV> contentViewsCSV{get;set;}
	public List<AnalyticsWrapper.LoginsData> loginsDataList{get;set;}
	public List<AnalyticsWrapper.PageViewsData> pageViewsDataDataList{get;set;}
	public MustReadHistoryData mustReadHistoryObject {get;set;}
	public List<AnalyticsWrapper.KnowledgePageWrapperCsv> knowledgePageCsvData {get;set;}

	public List<PeopleListWrapper> listOfUnassignedSegmentUsers{get;set;}
	public List<PeopleListWrapper> listOfSegmentationUsers{get;set;}
	public List<PeopleListWrapper> listOfAudienceUsers{get;set;}
	public List<PeopleListWrapper> listOfPeopleExpertise{get;set;}
	
	private Map<String, Integer> siteRoleVsPeopleCountMap = null;
	private AnalyticsDao analyticsDaoObj = new AnalyticsDao();
	private SegmentDao segmentDaoObj = new SegmentDao();
	
	public String currentSiteId{ 
		get{ 
			if(String.isBlank(SiteContext.siteId)){
				return null;
			} else {
				return SiteContext.siteId;
			}
		}
	}
	public String currentSiteName{
		get{
	 		return SiteContext.siteName;
		 }
	}
	
	public String siteName{get{
		String sName;
		if(String.isNotBlank(currentSiteName)) {
			sName = STR_ANALYTICS_SITE_FOR_SITE.replace('{{siteName}}', currentSiteName);
			sName = sName.replaceAll('"','""');
			sName = STR_ANALYTICS_CONTENT_SITE + ': ' + sName;
		}
		return sName;
	}}

	private void initSiteRoleVsPeopleCountMap(){
		if(String.isNotBlank(SiteContext.chatterGroupId)){
			siteRoleVsPeopleCountMap = new Map<String, Integer> ();
			String packageName = SimpplrContext.packageName;
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', SiteContext.siteId);
			soqlParamMap.put('soqlParam2', packageName);
			String siteRoleQuery = 'select count(Id) memberCount, Is_Content_Manager__c isContentManager, Is_Manager__c isManager, Is_Member__c isMember from Site_Role__c' +
				' where Site__c =:soqlParam1 and Is_Deleted__c = false ';
			if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false) {
				siteRoleQuery += ' And User__c in (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =:soqlParam2) ';
			}
			siteRoleQuery += ' GROUP BY Is_Content_Manager__c, Is_Manager__c, Is_Member__c ';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<AggregateResult> aggResultList = (List<AggregateResult>) SIMPESAPI.accessController().queryAsUser(siteRoleQuery, soqlParamMap);
			Integer managerCount = 0;
			Integer memberCount = 0;
			Integer followerCount = 0;
			for(AggregateResult aggResult : aggResultList){
				Integer count = (Integer) aggResult.get('memberCount');
				Boolean isMember = Boolean.valueOf(aggResult.get('isMember'));
				Boolean isManager = Boolean.valueOf(aggResult.get('isManager'));
				Boolean isContentManager = Boolean.valueOf(aggResult.get('isContentManager'));

				if(isManager || isContentManager) {
					managerCount += count;
					memberCount += count;
				} else if(isMember) {
					memberCount += count;
				} else {
					followerCount += count;
				}
			}
			siteRoleVsPeopleCountMap.put('followers', followerCount);
			siteRoleVsPeopleCountMap.put('members', memberCount);
			siteRoleVsPeopleCountMap.put('managers', managerCount);
		}	
	}

	public String siteManagersCount {get{
		String managerCountlabelStr;
		if(String.isBlank(siteManagersCount) && siteRoleVsPeopleCountMap != null) {
			Integer count = siteRoleVsPeopleCountMap.get('managers');

			managerCountlabelStr = STR_MANAGERS + ': ' + count;															
		}

		return managerCountlabelStr;
	}}

	public String fromToHeader {get{
		String fromToDateHeader;
		if(String.isNotBlank(fromDate) && String.isNotBlank(toDate)) {
			fromToDateHeader = STR_HEADER_FROM + ': ' + localizedFromDate + ' ' + STR_HEADER_TO + ': ' + localizedToDate ;															
		}
		return fromToDateHeader;
	}}

	public String siteMembersCount {get{
		String memberCountlabelStr;
		if(String.isBlank(siteMembersCount) && siteRoleVsPeopleCountMap != null) {
			Integer count = siteRoleVsPeopleCountMap.get('members');

			memberCountlabelStr = STR_MEMBERS + ': ' + count;												
		}

		return memberCountlabelStr;
	}}

	public String siteMembersNFollowersCount {get{
		String memberCountlabelStr;
		if(String.isBlank(siteMembersNFollowersCount) && siteRoleVsPeopleCountMap != null) {
			Integer count = siteRoleVsPeopleCountMap.get('members') + siteRoleVsPeopleCountMap.get('followers');

			memberCountlabelStr = STR_MEMBERS + ': ' + count;												
		}

		return memberCountlabelStr;
	}}
   
	public String siteFollowersCount {get{
		String followerCountlabelStr;
		if(String.isBlank(siteFollowersCount) && siteRoleVsPeopleCountMap != null) {
			Integer count = siteRoleVsPeopleCountMap.get('followers');

			followerCountlabelStr = STR_FOLLOWERS + ': ' + count;												
		}

		return followerCountlabelStr;
	}}
   
    public ReportsCtrl() {
       total = 0;
       isSegmentsEnabled = SimpplrContext.isSegmentsEnabled;
			 isCategoryEnabled = SimpplrContext.isPeopleCategoryEnable;
    }
    
    /**
   * 
   * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
   * Parameters:
   *      parameter_name -- [Explanation of the purpose of this parameter to the method.
   *      
   * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
   */    
    public static String pageName {get{
    	if(String.isEmpty(pageName)){
    		pageName = PageContext.namespacePrefix + 'Reports';
    	}
    	return pageName;
    }set;}
    
    /**
   * 
   * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
   * Parameters:
   *      parameter_name -- [Explanation of the purpose of this parameter to the method.
   *      
   * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
   */
    public override String getPageFeature() {
    	return AccessManager.FEATURE_ANALYTICS;
    }
    
    /*
    *
    */
    public String getPageTitle() {
    	return  'Reports' + ' - ' + SiteContext.siteName + AppPageTitle;
    }
    
    public String newLine{get{
    	return '\r\n';
    }set;}
    	
    /*** 
   * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
   * Parameters:
   *      parameter_name -- [Explanation of the purpose of this parameter to the method.
   *      
   * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
   */
    public PageReference init() {
        PageReference returnPage = null;
        
    	try{
	    	String action = readParam(REQUEST_PARAM_ACTION);
	    	this.action = action;
    		if(ACTION_CAMPAIGN_SHARE_HISTORY_DATA.equalsIgnoreCase(action)){
    			
	    	}else if(ACTION_GET_CONTENT_VIEWS_CSV.equalsIgnoreCase(action)){
				
			}else if(!AccessManager.hasPageAccess(getPageFeature())) {
		        throw new SimpplrException(ServiceConstants.ERROR_404);
	    	}
	    	
	    	Map<String,Object> mapOfParameters = new Map<String,Object>();
	    	if(readparam('to')!=null){
	    		mapOfParameters.put('to',readparam('to'));
	    		toDate = readparam('to');
	    	}
	    	if(readparam('from')!=null){
	    		mapOfParameters.put('from',readparam('from'));
	    		fromdate = readparam('from');
	    	}
	    	if(readparam('metric')!=null){
	    		this.metric = String.valueof(readparam('metric'));
	    		mapOfParameters.put('metric',readparam('metric'));
	    	}
	    	if(readparam('contentType')!=null){
	    		mapOfParameters.put('contentType',readparam('contentType'));
	    		contentType = readparam('contentType');
	    	}
	    	if(readparam('siteId')!=null){
	    		mapOfParameters.put('siteId',readparam('siteId'));
	    		siteId = readparam('siteId');
	    	}
	    	if(readparam('contentId')!=null){
	    		mapOfParameters.put('contentId',readparam('contentId'));
	    		contentId = readparam('contentId');
	    	}
	    	if(readparam('groupBy')!=null){
	    		mapOfParameters.put('groupBy',readparam('groupBy'));
	    	}
	    	if(readparam('orderBy')!=null){
	    		mapOfParameters.put('orderBy',readparam('orderBy'));
	    	}
	    	if(readparam('filterValue')!=null){
				this.filterValue = readparam('filterValue');
	    		mapOfParameters.put('filterValue',this.filterValue);
	    	}
	    	if(readparam('filterBy')!=null){
				this.filterBy = readparam('filterBy');
	    		mapOfParameters.put('filterBy', this.filterBy);
	    	}
	    	if(readparam('resultType')!=null){
	    		mapOfParameters.put('resultType',readparam('resultType'));
	    		if('category'.equalsIgnoreCase(readparam('resultType'))){
	    			this.resultType = SimpplrContext.peopleCategorySingular;
	    		} else {
	    			this.resultType = readparam('resultType').capitalize();
	    		}
	    	}
	    	if(readparam('type')!=null){
	    		mapOfParameters.put('type',readparam('type'));
	    		typeParam = readparam('type');
	    	}
			if(readparam('includeName')!=null){
	    		mapOfParameters.put('includeName',readparam('includeName'));
	    		typeParam = readparam('includeName');
	    	}	
	    	campaignId = readParam('campaignId');
	    	
	    	if(String.isNotBlank(contentId)){
	    		List<Simpplr_Content__c> simpContentList = [select id, Title__c from Simpplr_Content__c where id=:contentId WITH SECURITY_ENFORCED limit 1];
	    		
	    		if(!simpContentList.isEmpty()){
	    			contentTitle = simpContentList[0].Title__c;
	    		}
	    	}
	    	
			initSiteRoleVsPeopleCountMap();

	    	if(ACTION_VALUE_GET_RSVP_LIST.equalsIgnoreCase(action)) {
				fileName = STR_FILE_NAME_ATTENDEES_RSVP_YES;
				reportHeader = STR_RPRT_HDR_ATTENDEES_RSVP_YES;
		    	if (String.isNotBlank(contentId)){
					rsvpCsvWrapperList = getRsvpResponseList(contentId);
					String title = getContentTitle(contentId);
					fileName = fileName.replace('{{eventName}}', title.replaceAll('"','""'));	
					reportHeader = reportHeader.replace('{{eventName}}', title.replaceAll('"','""'));	
					reportHeader = reportHeader + ' ' + currentDateTime;
				}
				
			} else if(ACTION_GET_PEOPLE_EXPERTISE.equalsIgnoreCase(action)) {
				fileName = STR_FILE_NAME_PEOPLE_EXPERTISE;
				reportHeader = STR_RPRT_HDR_PEOPLE_EXPERTISE;	
				String expertiseId = readParam('expertiseId');
				String term = readParam('term');
		    	if (String.isNotBlank(expertiseId)){
		    		listOfPeopleExpertise = getPeopleExpertiseList(expertiseId,term);
		    	}
	    	} else if (ACTION_GET_LOGINS.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_ADOPTION_LOGINS;
	    		reportHeader = STR_RPRT_HDR_ADOPTION_LOGINS;
	    		loginsDataList = getLogins(mapOfParameters);
	    	}else if (ACTION_GET_PAGE_VIEWS.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_ADOPTION_PAGE_VIEWS;
	    		reportHeader = STR_RPRT_HDR_ADOPTION_PAGE_VIEWS;
	    		pageViewsDataDataList = getPageviews(mapOfParameters);
	    	}else if (ACTION_GET_ADOPTION.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_ADOPTION_TREND;
	    		reportHeader = STR_RPRT_HDR_ADOPTION_TREND;
	    		adoptionDataList = getAdoption(mapOfParameters);
	    	}else if (ACTION_GET_ADOPTION_AVERAGE.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_ADOPTION_OVERVIEW;
	    		reportHeader = STR_RPRT_HDR_ADOPTION_OVERVIEW;
	    		adoptionOverviewObj = (AnalyticsWrapper.AdoptionOverview) getAdoptionOverview(mapOfParameters);
	    		
	    	}else if(ACTION_GET_CONTENT_REERRAL_SOURCES.equalsIgnoreCase(action)){
				contentReferralSourceDataList = (List<AnalyticsWrapper.ContentReferralSourceData>) getContentReferralSources(mapOfParameters);

				if(String.isNotBlank(contentId)){
					fileName = STR_FILE_NAME_CONTENT_REFERRAL_SOURCE.replace('{{sourceName}}', contentReferralSourceDataList[0].contentTitle);
					reportHeader = STR_RPRT_HDR_CONTENT_REFERRAL_SOURCE.replace('{{sourceName}}', contentReferralSourceDataList[0].contentTitle);

				} else if(String.isNotBlank(currentSiteId)){
					fileName = STR_FILE_NAME_CONTENT_REFERRAL_SOURCE.replace('{{sourceName}}', contentReferralSourceDataList[0].siteName);
					reportHeader = STR_RPRT_HDR_CONTENT_REFERRAL_SOURCE.replace('{{sourceName}}', contentReferralSourceDataList[0].siteName);

				} else {
					fileName = STR_FILE_NAME_CONTENT_REFERRAL_SOURCE.replace('-{{sourceName}}', '');
					reportHeader = STR_RPRT_HDR_CONTENT_REFERRAL_SOURCE.replace('- {{sourceName}}', '');

				}

			}	
	    	
	    	else if (ACTION_GET_PERFORMANCE_SITES_MEMBERS.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_SITES_MEMBERS;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_SITES_MEMBERS;
	    		performanceSiteDataList = getPerformanceSitesMembersList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_SITES_POSTS.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_SITES_POSTS;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_SITES_POSTS;
	    		performanceSiteDataList = getPerformanceSitesPostsList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_SITES_LIKES.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_SITES_LIKES;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_SITES_LIKES;
	    		performanceSiteDataList = getPerformanceSitesLikesList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_SITES_REPLIES.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_SITES_REPLIES;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_SITES_REPLIES;
	    		performanceSiteDataList = getPerformanceSitesRepliesList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_SITES_VIEWS.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_SITES_VIEWS;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_SITES_VIEWS;
	    		performanceSiteDataList = getPerformanceSitesViewsList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_SITES_PUBLISHED.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_SITES_CONTENT_PUBLISHED;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_SITES_CNTNT_PBLSHD;
	    		performanceSiteDataList = getPerformanceSitesPublishedList(mapOfParameters);
	    	}
	    	
	    	else if (ACTION_GET_PERFORMANCE_PEOPLE_FAVORITES.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_FAV_MADE;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_PPL_FVRT_MADE;
	    		performancePeopleDataList = getPerformancePeopleBookmarksMadeList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_PEOPLE_FAVORITES_RECEIVED.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_PPL_FAV_RECIEVED;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_PPL_FVRT_RCVD;
	    		performancePeopleDataList = getPerformancePeopleBookmarksReceivedList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_PEOPLE_PUBLISHED.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_PPL_CONTENT_PUBLISHED;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_PPL_CONTENT_PBLSHD;
	    		performancePeopleDataList = getPerformancePeopleContentPublishedList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_PEOPLE_MENTIONS.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_PPL_MENTIONS;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_PPL_MENTIONS;
	    		performancePeopleDataList = getPerformancePeopleMentionsList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_PEOPLE_POSTS.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_PPL_POSTS;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_PPL_POSTS;
	    		performancePeopleDataList = getPerformancePeoplePostsList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_PEOPLE_REPLIES.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_PPL_REPLIES_MADE;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_PPL_REPLIES_MADE;
	    		performancePeopleDataList = getPerformancePeopleRepliesMadeList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_PEOPLE_REPLIES_RECEIVED.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_PPL_REPLIES_RCVD;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_PPL_REPLIES_RCVD;
	    		performancePeopleDataList = getPerformancePeopleRepliesReceivedList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_PEOPLE_FOLLOWERS.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_PPL_FOLLOWERS;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_PPL_FOLLOWERS;
	    		performancePeopleDataList = getPerformancePeopleFollowersList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_PEOPLE_FOLLOWING.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_PPL_FOLLOWING;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_PPL_FOLLOWING;
	    		performancePeopleDataList = getPerformancePeopleFollowingList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_PEOPLE_LIKES.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_PPL_LIKES_MADE;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_PPL_LIKES_MADE;
	    		performancePeopleDataList = getPerformancePeopleLikesMadeList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_PEOPLE_LIKES_RECEIVED.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_PPL_LIKES_RECEIVED;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_PPPL_LIKES_RCVD;
	    		performancePeopleDataList = getPerformancePeopleLikesReceivedList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_PEOPLE_SHARES.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_PPL_SHARES_MADE;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_PPL_SHARES_MADE;
	    		performancePeopleDataList = getPerformancePeopleSharesMadeList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_PEOPLE_SHARES_RECEIVED.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_PPL_SHARES_RECIEVED;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_PPL_SHARES_RCVD;
	    		performancePeopleDataList = getPerformancePeopleSharesReceivedList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_PEOPLE_PROFILE_VIEWS.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_PPL_PROFILE_VIEW;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_PPL_PRFL_VIEWS;
	    		performancePeopleDataList = getPerformancePeopleProfileViewsList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_CONTENT_FAVORITES.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_CONTENT_FAV;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_CNTNT_FVRT;
	    		performanceContentDataList = getPerformanceContentBookmarksList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_CONTENT_LIKES.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_CNTNT_LIKES;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_CNTNT_LIKES;
	    		performanceContentDataList = getPerformanceContentLikesList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_CONTENT_POSTS.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_CONTENT_POSTS;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_CNTNT_POSTS;
	    		performanceContentDataList = getPerformanceContentPostsList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_CONTENT_REPLIES.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_CONTENT_REPLIES;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_CNTNT_REPLIES;
	    		performanceContentDataList = getPerformanceContentRepliesList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_CONTENT_SHARES.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_CONTENT_SHARES;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_CNTNT_SHARES;
	    		performanceContentDataList = getPerformanceContentSharesList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_CONTENT_UNUSEFUL.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_CONTENT_UNUSEFUL;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_CNTNT_UNUSEFUL;
	    		performanceContentDataList = getPerformanceContentUnusefulList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_CONTENT_USEFUL.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_CONTENT_USEFUL;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_CNTNT_USEFUL;
	    		performanceContentDataList = getPerformanceContentUsefulList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_CONTENT_VIEWS.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_CONTENT_VIEWS;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_CNTNT_VIEWS;
	    		performanceContentDataList = getPerformanceContentViewsList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_TOPIC_ENDORSEMENTS.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_TOPICS_ENDORSEMENTS;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_TOPICS_ENDRSMNT;
	    		performanceTopicsDataList = getPerformanceTopicsEndorsementList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_TOPIC_EXPERTISE.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_TOPICS_EXPERTISE;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_TOPICS_EXPERTISE;
	    		performanceTopicsDataList = getPerformanceTopicsExpertiseList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_TOPIC_FOLLOWERS.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_TOPICS_FOLLOWERS;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_TOPIC_FOLLOWERS;
	    		performanceTopicsDataList = getPerformanceTopicsFollowersList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_TOPIC_VIEWS.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_TOPICS_VIEWS;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_TOPIC_VIEWS;
	    		performanceTopicsDataList = getPerformanceTopicsViewsList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_SEARCH.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_SEARCH_TERMS;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_SEARCH;
	    		performanceSearchDataList = getPerformanceSearchList(mapOfParameters);
	    	}else if (ACTION_GET_PERFORMANCE_ZERO_SEARCH_RESULTS.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_PERFORMANCE_SEARCH_NO_RESULTS;
	    		reportHeader = STR_RPRT_HDR_PERFORMANCE_SEARCH_NO_RESULT;
	    		performanceSearchDataList = getPerformanceZeroSearchResultsList(mapOfParameters);
	    	}
	    	
	    	else if (ACTION_GET_ENGAGEMENT_FEED_POSTS.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_ENGMNT_FEED_POSTS;
	    		reportHeader = STR_RPRT_HDR_ENGMNT_FEED_POSTS;
	    		performanceEngagementFeedList = getPerformanceEngagementFeedPostsList(mapOfParameters);
	    	}else if (ACTION_GET_ENGAGEMENT_FEED_LIKES.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_ENGMNT_FEED_LIKES;
	    		reportHeader = STR_RPRT_HDR_ENGMNT_FEED_LIKES;
	    		performanceEngagementFeedList = getPerformanceEngagementFeedLikesList(mapOfParameters);
	    	}else if (ACTION_GET_ENGAGEMENT_FEED_REPLIES.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_ENGMNT_FEED_REPLIES;
	    		reportHeader = STR_RPRT_HDR_ENGMNT_FEED_REPLIES;
	    		performanceEngagementFeedList = getPerformanceEngagementFeedRepliesList(mapOfParameters);
	    	}else if (ACTION_GET_ENGAGEMENT_FEED_SHARES.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_ENGMNT_FEED_SHARES;
	    		reportHeader = STR_RPRT_HDR_ENGMNT_FEED_SHARES;
	    		performanceEngagementFeedList = getPerformanceEngagementFeedSharesList(mapOfParameters);
	    	}
	    	
	    	else if (ACTION_GET_ENGAGEMENT_CONTENT_FAVORITES.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_ENGAGEMENT_CONTENT_FVRT;
	    		reportHeader = STR_RPRT_HDR_ENGMNT_CONTENT_FVRTS;
	    		performanceEngagementContentList = getperformanceEngagementContentBookmarkList(mapOfParameters);
	    	}else if (ACTION_GET_ENGAGEMENT_CONTENT_LIKES.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_ENGMNT_CONTENT_LIKES;
	    		reportHeader = STR_RPRT_HDR_ENGMNT_CONTENT_LIKES;
	    		performanceEngagementContentList = getperformanceEngagementContentLikesList(mapOfParameters);
	    	}else if (ACTION_GET_ENGAGEMENT_CONTENT_POSTS.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_ENGMNT_CONTENT_POSTS;
	    		reportHeader = STR_RPRT_HDR_ENGMNT_CONTENT_POSTS;
	    		performanceEngagementContentList = getperformanceEngagementContentPostsList(mapOfParameters);
	    	}else if (ACTION_GET_ENGAGEMENT_CONTENT_PUBLISHED.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_ENGMNT_CONTENT_PBLSHD;
	    		reportHeader = STR_RPRT_HDR_ENGMNT_CONTENT_PBLSHD;
	    		performanceEngagementContentList = getperformanceEngagementContentPublishedList(mapOfParameters);
	    	}else if (ACTION_GET_ENGAGEMENT_CONTENT_REPLIES.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_ENGMNT_CONTENT_REPLIES;
	    		reportHeader = STR_RPRT_HDR_ENGMNT_CONTENT_REPLIES;
	    		performanceEngagementContentList = getperformanceEngagementContentRepliesList(mapOfParameters);
	    	}else if (ACTION_GET_ENGAGEMENT_CONTENT_SHARES.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_ENGMNT_CONTENT_SHARES;
	    		reportHeader = STR_RPRT_HDR_ENGMNT_CONTENT_SHARES;
	    		performanceEngagementContentList = getperformanceEngagementContentSharesList(mapOfParameters);
	    	}else if (ACTION_GET_ENGAGEMENT_CONTENT_VIEWS.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_ENGMNT_CONTENT_VIEWS;
	    		reportHeader = STR_RPRT_HDR_ENGMNT_CONTENT_VIEWS;
	    		performanceEngagementContentList = getperformanceEngagementContentViewsList(mapOfParameters);
	    	}else if (ACTION_GET_ENGAGEMENT_CONTENT_TYPES.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_ENGMNT_CONTENT_TYPES;
	    		reportHeader = STR_RPRT_HDR_ENGMNT_CONTENT_TYPES;
	    		performanceEngagementContentTypesList = getPerformanceEngagementContentTypesList(mapOfParameters);
	    	} else if(ACTION_CAMPAIGN_SHARE_HISTORY_DATA.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_SOCIAL_CMPGN_HSTRY;
	    		reportHeader = STR_RPRT_HDR_SOCIAL_CAMPAIGN_HSTRY;
	    		CampaignDataServer campaignDataServerObj = new CampaignDataServer();
	    		campaignHistoryReportList = campaignDataServerObj.getCampaignShareHistoryReport(campaignId);
	    	
	    	}else if(ACTION_GET_MUST_READ_HISTORY.equalsIgnoreCase(action)) {
	    		Simpplr_Content__c simpContentObj = [select id,Title__c  from Simpplr_Content__c where id=:contentId WITH SECURITY_ENFORCED limit 1];
	    		fileName = STR_FILE_NAME_APP_NAME_MUST_READS
													.replace('{{applicationName}}', SimpplrContext.applicationName)
													.replace('{{contentId}}', contentId);
	    		reportHeader = STR_RPRT_HDR_MUST_READS
													.replace('{{applicationName}}', SimpplrContext.applicationName)
													.replace('{{contentId}}', simpContentObj.Title__c);
	    		String filter = readparam('filter');
	    		mustReadHistoryObject = getMustReadHistory(contentId,filter);
	    	
	    	} else if(ACTION_GET_UNASSIGNED_SEGMENT_USERS.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_UNASSIGNED_SGMNT_USERS;
	    		reportHeader = STR_RPRT_HDR_UNASSIGNED_SGMNT_USERS;
	    		listOfUnassignedSegmentUsers = getUnassignedSegmentUsers(null);	    

	    	}  else if(ACTION_GET_UNASSIGNED_USERS.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_UNASSIGNED_USERS;
	    		reportHeader = STR_RPRT_HDR_UNASSIGNED_USERS;
	    		String profileField = readParam('field');
	    		listOfUnassignedSegmentUsers = getUnassignedSegmentUsers(profileField);	    			
	    	} else if(ACTION_GET_SEGMENTATION_PEOPLE.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_SGMNT_MEMBERS;
	    		reportHeader = STR_RPRT_HDR_SGMNT_MEMBERS;
	    		String segmentId = readParam('segmentId');
	    		String subscriptionId = readParam('subscriptionId');
	    		String term = readParam('term');
	    		String limitToSubsegmentStr = readParam('limitToSubsegment');
	    		Boolean limitToSubsegment = (String.isNotBlank(limitToSubsegmentStr) && 'true'.equalsIgnoreCase(limitToSubsegmentStr));
	    		
	    		if(String.isNotBlank(subscriptionId)){
	    			fileName = STR_FILE_NAME_SUBSCRIPTION_MEMBERS;
	    			reportHeader = STR_RPRT_HDR_SUBSCRIPTION_MEMBERS;
	    			
	    			listOfSegmentationUsers = getSubscriptionMembers(subscriptionId, term, limitToSubsegment);
	    		} else if (String.isNotBlank(segmentId)){
	    			listOfSegmentationUsers = getSegmentMembers(segmentId, term, limitToSubsegment);
	    		}
	    	} else if(ACTION_GET_AUDIENCE_PEOPLE.equalsIgnoreCase(action)) {
				fileName = STR_FILE_NAME_SGMNT_MEMBERS;
	    		reportHeader = STR_RPRT_HDR_SGMNT_MEMBERS;
	    		String audienceId = readParam('audienceId');
	    		String term = readParam('term');
	    		
	    		if(String.isNotBlank(audienceId)){
	    			fileName = STR_FILE_NAME_AUDIENCE_MEMBERS;
				reportHeader = STR_RPRT_HDR_AUDIENCE_MEMBERS;
					
				listOfAudienceUsers = getAudienceMembers(audienceId, term);
				listOfHeaders = new List<String>();
				listOfHeaders.add(STR_USER_NAME);
				listOfHeaders.add(STR_EMAIL);
				listOfHeaders.add(STR_COMPANY_NAME);
				if(listOfAudienceUsers[0].segmentName != null)
				{
					segmentName = listOfAudienceUsers[0].segmentName;
					listOfHeaders.add(STR_SEGMENT);
				}	
				listOfHeaders.add(STR_DIVISION);
				listOfHeaders.add(STR_DEPARTMENT);
				listOfHeaders.add(STR_CITY);
				listOfHeaders.add(STR_STATE);
				listOfHeaders.add(STR_COUNTRY);			
			} 
				
			} else if(ACTION_GET_CONTENT_VIEWS_CSV.equalsIgnoreCase(action)){
	    		reportHeader = STR_FILE_NAME_CONTENT_VIEWS;
	    		fileName = STR_RPRT_HDR_CONTENT_VIEWS;
				String siteId = (mapOfParameters != null && mapOfParameters.containsKey('siteId') && String.isNotBlank((String)mapOfParameters.get('siteId'))) ? String.valueOf(mapOfParameters.get('siteId')) : null;
	    		if(String.isNotBlank(siteId)){ //For all content types except blog post
					this.action = 'getContentViewsWithAudienceMetricCsv';
				}
				contentViewsCSV = getContentViews(mapOfParameters);
	    		
	    	}else if(ACTION_GET_CONTENT_VIEWS_TOP_DEPARTMENTS_CSV.equalsIgnoreCase(action)){
	    		reportHeader = STR_FILE_NAME_CONTENT_VIEWS_BY_TOP_DEPT;
	    		fileName = STR_RPRT_HDR_CONTENT_VIEWS_BY_TOP_DEPT;
	    		contentRelatedDate = getContentViewsByDepts(mapOfParameters);
	    		
	    	}else if(ACTION_GET_CONTENT_VIEWS_TOP_LOCATIONS_CSV.equalsIgnoreCase(action)){
	    		reportHeader = STR_FILE_NAME_CONTENT_VIEWS_BY_TOP_LOCATIONS;
	    		fileName = STR_RPRT_HDR_CONTENT_VIEWS_BY_TOP_LOCATION;
	    		contentRelatedDate = getContentViewsByLocations(mapOfParameters);
	    		
	    	} else if(ACTION_GET_SITE_VIEWS_TOTAL.equalsIgnoreCase(action)) {
				reportHeader = STR_RPRT_HDR_SITE_VIEWS_FOR_SITE.replace('{{siteName}}', currentSiteName);
				fileName = STR_FILE_NAME_SITE_VIEWS_FOR_SITE.replace('{{siteName}}', currentSiteName);
	    		listOfHeaders = new List<String>();
	    		listOfHeaders.add(STR_TOTAL_VIEWS);
	    		listOfHeaders.add(STR_ANALYTICS_SITE_PERCENT_VIEWS_BROWSER);
	    		listOfHeaders.add(STR_ANALYTICS_SITE_CONTENT_PERCENT_VIEWS_MOBILE_BROWSER);
	    		listOfHeaders.add(STR_ANALYTICS_SITE_CONTENT_PERCENT_VIEWS_MOBILE_APP);
	    		
				contentRelatedDate = getSiteViewsTotal(mapOfParameters);

			} else if(ACTION_GET_APP_PAGE_VIEWS.equalsIgnoreCase(action)) {
				reportHeader = STR_RPRT_HDR_APP_PAGE_VIEWS_FOR_TYPE;
				fileName = STR_FILE_NAME_APP_PAGE_VIEWS_FOR_TYPE;
	    		
				viewList = getAppPageViews(mapOfParameters);

			} else if(ACTION_GET_VIEWS_OVER_TIME_CSV.equalsIgnoreCase(action) ||
	    				ACTION_GET_LOGINS_OVER_TIME_CSV.equalsIgnoreCase(action)){
	    		if(ACTION_GET_VIEWS_OVER_TIME_CSV.equalsIgnoreCase(action)){
		    		fileName = STR_FILE_NAME_ADOPTION_PAGE_VIEWS;
		    		reportHeader = STR_RPRT_HDR_ADOPTION_PAGE_VIEWS;
	    		}else if(ACTION_GET_LOGINS_OVER_TIME_CSV.equalsIgnoreCase(action)){
	    			fileName = STR_FILE_NAME_ADOPTION_LOGINS;
		    		reportHeader = STR_RPRT_HDR_ADOPTION_LOGINS;

					this.setFilterValueName();
	    		}
	    		adoptionCSVData = getPageAndLoginViewsOverTime(mapOfParameters,action);
	    		
	    	} else if(ACTION_GET_PEOPLE_PERFORMANCE.equalsIgnoreCase(action)){
	    		String metric = (String)mapOfParameters.get('metric');
	    		String siteId = mapOfParameters.containsKey('siteId') ? (String)mapOfParameters.get('siteId') : null;	
    			if('contentPublished'.equalsIgnoreCase(metric)){
    				reportHeader = STR_RPRT_HDR_USERS_PBLSHD_MOST_CNTNT;
    				fileName = STR_FILE_NAME_CONTENT_PUBLSHD;
    				
    			} else if('favoritesReceived'.equalsIgnoreCase(metric)){
    				reportHeader = STR_RPRT_HDR_USERS_MOST_FVRT;
    				fileName = STR_FILE_NAME_FVRT_RCVD; 
    				
    			} else if('feedPosts'.equalsIgnoreCase(metric)){
    				reportHeader = STR_RPRT_HDR_PPL_MADE_MOST_POSTS;
    				fileName = STR_FILE_NAME_FEED_POSTS;
    				
    			} else if('likesMade'.equalsIgnoreCase(metric)){
    				reportHeader = STR_RPRT_HDR_PPL_LIKED_MOST_CNTNT_POSTS_REPLIES;
    				fileName = STR_FILE_NAME_LIKES_MADE; 
    				
    			} else if('likesReceived'.equalsIgnoreCase(metric)){
    				reportHeader = STR_RPRT_HDR_PPL_RCVD_MOST_LIKES_CNTNT_POSTS_REPLIES;
    				fileName = STR_FILE_NAME_LIKES_RCVD;
    				
    			} else if('profileViews'.equalsIgnoreCase(metric)){
    				reportHeader = STR_RPRT_HDR_PPL_MOST_VIEWED_PROFILES;
    				fileName = STR_FILE_NAME_PROFILE_VIEWS; 
    				
    			} else if('replies'.equalsIgnoreCase(metric)){
    				reportHeader = STR_RPRT_HDR_PPL_REPLIED_MOST_FEEDS;
    				fileName = STR_FILE_NAME_REPLIES;
    				
    			} else if('repliesFrom'.equalsIgnoreCase(metric)){
    				reportHeader = STR_RPRT_HDR_PPL_MOST_REPLIES_ON_POSTS;
    				fileName = STR_FILE_NAME_REPLIES_FROM_OTHER_USERS;
    				
    			} else if('sharesReceived'.equalsIgnoreCase(metric)){
    				reportHeader = STR_RPRT_HDR_PPL_CNTNT_POSTS_MOST_SHARED;
    				fileName = STR_FILE_NAME_SHARES_RCVD;
    			}

					peopleData = getPeoplePerformance(mapOfParameters);
					Boolean includeSiteInfo = false;
					if(String.isNotBlank(siteId)){
						includeSiteInfo = true;      //for csv on user adoption tiles on site level analytics
					}

					peopleDataCSVHeader = getPeopleDataCSVHeader(isSegmentsEnabled, isCategoryEnabled, includeSiteInfo);
					if(includeSiteInfo){
						peopleDataCSVValueList = getPeopleDataCSVForSiteValueList(peopleData, isSegmentsEnabled, isCategoryEnabled);
					}else{
						peopleDataCSVValueList = getPeopleDataCSVValueList(peopleData, isSegmentsEnabled, isCategoryEnabled);
					}
    			
	    	}else if(ACTION_GET_CONTENT_VIEWS_LIST.equalsIgnoreCase(action) && this.resultType == null){
    			reportHeader = STR_RPRT_HDR_LEAST_VIEWED_CONTENT;
    			if('top'.equalsIgnoreCase((String) mapOfParameters.get('orderBy'))){
    				reportHeader = STR_RPRT_HDR_MOST_VIEWED_CONTENT;
						fileName = STR_FILE_NAME_MOST_VIEWED;
    			} else {
						fileName = STR_FILE_NAME_LEAST_VIEWED_CONTENT;
					}
	    		contentInfo = getContentViewsWhenFilterNull(mapOfParameters);
	    		
	    	}else if(ACTION_GET_CONTENT_VIEWS_LIST.equalsIgnoreCase(action) || 
						ACTION_GET_LOGINS_LIST.equalsIgnoreCase(action) ||
						    ACTION_GET_APP_ADOPTION.equalsIgnoreCase(action) ||
	    					ACTION_GET_ENGAGEMENT_LIST.equalsIgnoreCase(action) ||
	    						ACTION_GET_VIEWS_LIST.equalsIgnoreCase(action)){
	    		
	    		listOfHeaders = new List<String>();		
	    		if(ACTION_GET_CONTENT_VIEWS_LIST.equalsIgnoreCase(action)){
					if('top'.equalsIgnoreCase((String) mapOfParameters.get('orderBy'))){
						reportHeader = STR_RPRT_HDR_MOST_CONTENT_VIEWS_BY;
					} else {
						reportHeader = STR_RPRT_HDR_LEAST_CONTENT_VIEWS_BY;
					}				
					fileName = STR_FILE_NAME_CNTNT_VIEWS_FIELD_NAME;
						
    				listOfHeaders.add('Views');

	    		} else if(ACTION_GET_LOGINS_LIST.equalsIgnoreCase(action) || ACTION_GET_APP_ADOPTION.equalsIgnoreCase(action)){
					if('top'.equalsIgnoreCase((String) mapOfParameters.get('orderBy'))){
						reportHeader = STR_RPRT_HDR_MOST_LOGINS;
					} else {
	    				reportHeader = STR_RPRT_HDR_LEAST_LOGINS;
					}
					fileName = STR_FILE_NAME_ADOPTION_ORDER_LOGINS_FIELDNAME;

					listOfHeaders.add('');
	    			
	    		} else if(ACTION_GET_ENGAGEMENT_LIST.equalsIgnoreCase(action)){
					if('top'.equalsIgnoreCase((String) mapOfParameters.get('orderBy'))){
						reportHeader = STR_RPRT_HDR_MOST_ENGAGED_BY;
					} else {
						reportHeader = STR_RPRT_HDR_LEAST_ENGAGED_BY;
					}
					fileName = STR_FILE_NAME_ENGAGED_BY;

	    			listOfHeaders.add('');
	    		
	    		} else if(ACTION_GET_VIEWS_LIST.equalsIgnoreCase(action)){
					if('top'.equalsIgnoreCase((String) mapOfParameters.get('orderBy'))){
						reportHeader = STR_RPRT_HDR_MOST_PAGE_VIEWS;
					} else {
						reportHeader = STR_RPRT_HDR_LEAST_PAGE_VIEWS;
					}	
					fileName = STR_FILE_NAME_PAGE_VIEWS;

	    			listOfHeaders.add('');
	    		}
	    		//add category name to headers and columns
	    		if('segment'.equalsIgnoreCase(this.resultType)){
						reportHeader = reportHeader.replace('{{fieldname}}', STR_SEGMENT);
						fileName = fileName.replace('{{fieldName}}', STR_SEGMENT);

						listOfHeaders.add(0, STR_SEGMENT + listOfHeaders.get(0));
					
					} else if('department'.equalsIgnoreCase(this.resultType)){
						reportHeader = reportHeader.replace('{{fieldname}}', STR_DEPARTMENT);
						fileName = fileName.replace('{{fieldName}}', STR_DEPARTMENT);

						listOfHeaders.add(0, STR_DEPARTMENT + listOfHeaders.get(0));
						
					} else if('location'.equalsIgnoreCase(this.resultType)){
						reportHeader = reportHeader.replace('{{fieldname}}', STR_ANALYTICS_CONTENT_LOCATION);
						fileName = fileName.replace('{{fieldName}}', STR_ANALYTICS_CONTENT_LOCATION);

						listOfHeaders.add(0, STR_ANALYTICS_CONTENT_LOCATION + listOfHeaders.get(0));
						
					} else if('category'.equalsIgnoreCase(readparam('resultType'))){
						reportHeader = reportHeader.replace('{{fieldname}}', SimpplrContext.peopleCategorySingular);
						fileName = fileName.replace('{{fieldName}}', SimpplrContext.peopleCategorySingular);

						listOfHeaders.add(0, SimpplrContext.peopleCategorySingular);
						
					}

					//add order to headers
	    		if(mapOfParameters.containsKey('orderBy')){
	    			String orderStr = 'top'.equalsIgnoreCase((String)mapOfParameters.get('orderBy')) ? STR_MOST : STR_LEAST;
					fileName = fileName.replace('{{order}}', orderStr);
	    		}
	    		
	    		viewList = getCountViewsList(mapOfParameters, action);
	    	
	    	} else if(ACTION_GET_CONTENT_POPULAR.equalsIgnoreCase(action)){
				if('top'.equalsIgnoreCase((String) mapOfParameters.get('orderBy'))){
    				reportHeader = STR_RPRT_HDR_MOST_POPULAR_CONTENTS;
				} else {
					reportHeader = STR_RPRT_HDR_LEAST_POPULAR_CONTENTS;
				}		
				fileName = STR_FILE_NAME_ORDER_POPULAR_CONTENTS;

	    		if(mapOfParameters.containsKey('orderBy')){
	    			String orderStr = 'top'.equalsIgnoreCase((String)mapOfParameters.get('orderBy')) ? STR_MOST : STR_LEAST;
					fileName = fileName.replace('{{order}}', orderStr);
	    		}

			contentInfo = getContentPopularity(mapOfParameters);
	    		
			} else if(ACTION_GET_VIDEO_POPULARITY.equalsIgnoreCase(action)){
	    		reportHeader = STR_FILE_NAME_ORDER_POPULAR_VIDEOS;
					fileName = STR_FILE_NAME_ORDER_POPULAR_VIDEOS;

	    		if(mapOfParameters.containsKey('orderBy')){
	    			String orderStr = 'top'.equalsIgnoreCase((String)mapOfParameters.get('orderBy')) ? STR_MOST : STR_LEAST;
	    			reportHeader = reportHeader.replace('{{order}}', orderStr);
						fileName = fileName.replace('{{order}}', orderStr);
	    		}

	    		videoInfo = getVideoPopularity(mapOfParameters);
	    		
			}
			else if(ACTION_GET_VIDEO_ADOPTION_CSV.equalsIgnoreCase(action)){
	    		reportHeader = STR_FILE_NAME_VIDEOS;
					fileName = STR_FILE_NAME_VIDEOS;				
	    			videoAdoptionInfo = getVideoAdoption(mapOfParameters);
	    		
	    	}
			
			
			else if(ACTION_GET_GOVERNANCE_LIST.equalsIgnoreCase(action)){
	    		reportHeader = STR_RPRT_HDR_ORDER_GOVERNANCE_LIST;
					fileName = STR_FILE_NAME_ORDER_GOVERNANCE_LIST;

	    		if(mapOfParameters.containsKey('orderBy')){
	    			String orderStr = 'top'.equalsIgnoreCase((String)mapOfParameters.get('orderBy')) ? STR_MOST : STR_LEAST;
	    			reportHeader = reportHeader.replace('{{order}}', orderStr);
						fileName = fileName.replace('{{order}}', orderStr);
	    		}

	    		governanceInfo = getGovernanceList(mapOfParameters);
	    		
	    	} else if(ACTION_GET_SITE_PUBLICATIONS.equalsIgnoreCase(action) ||
	    				ACTION_GET_SITE_POPULAR.equalsIgnoreCase(action)){
	    		
	    		if(ACTION_GET_SITE_PUBLICATIONS.equalsIgnoreCase(action)){

					if('top'.equalsIgnoreCase((String) mapOfParameters.get('orderBy'))){
						reportHeader = STR_RPRT_HDR_SITE_MOST_CNTNT_PBLSHD;
					}else {
						reportHeader = STR_RPRT_HDR_SITE_LEAST_CNTNT_PBLSHD;
					}
	    			fileName = STR_FILE_NAME_CONTENT_PUBLSHD;
	    		}else if(ACTION_GET_SITE_POPULAR.equalsIgnoreCase(action)){
					if('top'.equalsIgnoreCase((String) mapOfParameters.get('orderBy'))){
						reportHeader = STR_RPRT_HDR_MOST_POPULAR_SITES;
					} else {
	    				reportHeader = STR_RPRT_HDR_LEAST_POPULAR_SITES;
					}
					fileName = STR_FILE_NAME_ORDER_POPULAR_SITES;
	    		}
	    		if(mapOfParameters.containsKey('orderBy')){
	    			String orderStr = 'top'.equalsIgnoreCase((String)mapOfParameters.get('orderBy')) ? STR_MOST : STR_LEAST;
					fileName = fileName.replace('{{order}}', orderStr);
	    		}
	    		
	    		viewList = getViewsList(mapOfParameters, action);
	    	
	    	} else if(ACTION_GET_CONTENT_PUBLICATIONS.equalsIgnoreCase(action)){
	    		if(Boolean.valueOf(readParam('onlyPublished'))){
					mapOfParameters.put('onlyPublished', true);
					fromdate = null;
					toDate = null;
					reportHeader = STR_RPRT_HDR_CURRENTLY_PBLSHD;
						fileName = STR_FILE_NAME_CURRENTLY_PBLSHD;
	    		} else{
	    			reportHeader = STR_RPRT_HDR_CONTENT_PUBLISHED;
						fileName = STR_FILE_NAME_CONTENT_PUBLSHD;
	    		}
	    		contentInfo = getContentPublications(mapOfParameters);
	    		
	    	} else if(ACTION_GET_MONTHLY_REPORT.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_MONTHLY_REPORT;
	    		reportHeader = STR_RPRT_HDR_MONTHLY_RPRT;
	    		listOfMonthlyReportData = getMonthlyReport();
	    	} else if(ACTION_GET_PERFORMANCE_CONTENT.equalsIgnoreCase(action)){
					if('popularity'.equalsIgnoreCase(this.metric) && ('bottom'.equalsIgnoreCase(readparam('orderBy')))){
	    				reportHeader = STR_RPRT_HDR_LEAST_POPULAR_CONTENT;
						fileName = STR_FILE_NAME_ORDER_POPULAR_CONTENT;
	    			} else if('popularity'.equalsIgnoreCase(this.metric) && ('top'.equalsIgnoreCase(readparam('orderBy')))){
	    				reportHeader = STR_RPRT_HDR_MOST_POPULAR_CONTENT;
						fileName = STR_FILE_NAME_ORDER_POPULAR_CONTENT;
	    			}else if('views'.equalsIgnoreCase(this.metric) && ('bottom'.equalsIgnoreCase(readparam('orderBy')))){
	    				reportHeader = STR_RPRT_HDR_LEAST_VIEWED_CNTNT;
						fileName = STR_FILE_NAME_ORDER_VIEWED_CONTENT;
	    			} else if('views'.equalsIgnoreCase(this.metric) && ('top'.equalsIgnoreCase(readparam('orderBy')))){
	    				reportHeader = STR_RPRT_HDR_MOST_VIEWED_CNTNT;
						fileName = STR_FILE_NAME_ORDER_VIEWED_CONTENT;
	    			}

					if('bottom'.equalsIgnoreCase(readparam('orderBy'))){
						fileName = fileName.replace('{{order}}', STR_LEAST);
	    			} else {
						fileName = fileName.replace('{{order}}', STR_MOST);
	    			}
					
	    		performanceContentDataListForExternalAnalytics = getPerformanceContentList(mapOfParameters);
	    	} else if(ACTION_GET_ENGAGEMENT.equalsIgnoreCase(action)){
	    		reportHeader = STR_RPRT_HDR_ENGAGEMENT;
					fileName = STR_FILE_NAME_ENGAGEMENT;
	    		viewList = getEngagement(mapOfParameters,action);
	    		
			} else if(ACTION_GET_CONTENT_ENGAGEMENT_CSV.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_CONTENT_VIEWS_ENGAGEMENT;
				reportHeader = STR_FILE_NAME_CONTENT_VIEWS_ENGAGEMENT;

				viewList = getEngagement(mapOfParameters,action);
	    		
	    	} else if(ACTION_GET_ADOPTION_DATA.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_ADOPTION_DATA;
	    		reportHeader = STR_RPRT_HDR_ADOPTION_DATA;
	    		contentRelatedDate = getAdoptiondata(mapOfParameters);
	    	} else if(ACTION_GET_SEARCHES.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_SEARCHES;
	    		reportHeader = STR_RPRT_HDR_SEARCHES;
	    		listOfHeaders = new List<String>();
	    		listOfHeaders.add(STR_DATE);
	    		listOfHeaders.add(STR_ANALYTICS_SEARCH_SEARCHES_MADE);

	    		searchData = getSearchdata(mapOfParameters,'getSearches');
	    		
	    	} else if(ACTION_GET_SEARCH_LIST.equalsIgnoreCase(action)){
	    		fileName = STR_FILE_NAME_SEARCH_LIST;
	    		listOfHeaders = new List<String>();
	    		if(typeParam!=null){
	    			if('terms'.equalsIgnoreCase(typeParam)){
							fileName = STR_FILE_NAME_TOP_SEARCH_TERMS;
	    				reportHeader = STR_RPRT_HDR_TOP_SEARCH_TERMS;
	    				listOfHeaders.add(STR_ANALYTICS_SEARCH_TERM);
	    				listOfHeaders.add(STR_ANALYTICS_SEARCH_SEARCHES_MADE);
	    				
	    			} else if('searchesZeroResults'.equalsIgnoreCase(typeParam)){
							fileName = STR_FILE_NAME_TOP_SEARCH_TERMS_NO_RESULTS;
	    				reportHeader = STR_RPRT_HDR_TOP_SEARCH_TERMS_NO_RESULTS;
	    				listOfHeaders.add(STR_ANALYTICS_SEARCH_TERM);
	    				listOfHeaders.add(STR_ANALYTICS_SEARCH_SEARCHES_MADE);
	    				
	    			} else if('clickThroughTerms'.equalsIgnoreCase(typeParam)){
							fileName = STR_FILE_NAME_TOP_CLICK_THROUGH_TERMS;
	    				reportHeader = STR_RPRT_HDR_TOP_CLICK_THROUGH_TERMS;
	    				listOfHeaders.add(STR_ANALYTICS_SEARCH_TERM);
	    				listOfHeaders.add(STR_ANALYTICS_SEARCH_CLICK_THROUGH_PLURAL);
	    				
	    			} else if('clickThroughTypes'.equalsIgnoreCase(typeParam)){
							fileName = STR_FILE_NAME_TOP_CLCK_THROUGH_TYPES;
	    				reportHeader = STR_RPRT_HDR_TOP_CLICK_THROUGH_TYPES;
	    				listOfHeaders.add(STR_TYPE);
	    				listOfHeaders.add(STR_ANALYTICS_SEARCH_CLICK_THROUGH_SINGULAR);
	    				listOfHeaders.add(STR_ANALYTICS_SEARCH_CLICK_THROUGH_PLURAL);
	    				
	    			} else if('searches'.equalsIgnoreCase(typeParam) && 'top'.equalsIgnoreCase(readparam('orderBy'))){
							fileName = STR_FILE_NAME_MOST_SEARCHES_PRFRMD;
	    				reportHeader = STR_RPRT_HDR_MOST_SEARCHES_BY_RESULT_TYPE.replace('{{resultType}}', this.resultType);
	    				listOfHeaders.add(this.resultType);
	    				listOfHeaders.add(STR_ANALYTICS_SEARCH_SEARCHES_MADE);
	    				
	    			} else if('searches'.equalsIgnoreCase(typeParam) && 'bottom'.equalsIgnoreCase(readparam('orderBy'))){
							fileName = STR_FILE_NAME_LEAST_SEARCHES_PRFRMD;
	    				reportHeader = STR_RPRT_HDR_LEAST_SEARCHES_BY_RESULT_TYPE.replace('{{resultType}}', this.resultType);
	    				listOfHeaders.add(this.resultType);
	    				listOfHeaders.add(STR_ANALYTICS_SEARCH_SEARCHES_MADE);
	    				
	    			}
	    		}
	    		searchData = getSearchListData(mapOfParameters,'getSearchList');

	    	} else if(ACTION_GET_PEOPLE_PROFILE_COMPLETENESS.equalsIgnoreCase(action)){
					reportHeader = STR_RPRT_HDR_PEOPLE_COMPLETENESS;
					fileName = STR_FILE_NAME_PEOPLE_COMPLETENESS;

					peopleCompletenessList = getPeopleProfileCompletenessList(mapOfParameters);
			} else if(ACTION_GET_CONTENT_VIEWS_BY_TYPE_CSV.equalsIgnoreCase(action)){
				reportHeader = STR_RPRT_HDR_CONTENT_VIEWS_BY_TYPE;
				fileName = STR_FILE_NAME_CONTENT_VIEWS_BY_TYPE;

				if(String.isNotBlank(siteName)){
					reportHeader = siteName + ' ' + reportHeader;
				}

				contentViewsByTypeList = getContentViewsByType(mapOfParameters);
			} else if(ACTION_GET_CONTENT_VIEWS_OVER_TIME_CSV.equalsIgnoreCase(action)){
				reportHeader = STR_RPRT_HDR_CONTENT_VIEWS_OVER_TIME;
				fileName = STR_FILE_NAME_CONTENT_VIEWS_OVER_TIME;

				adoptionCSVData = getPageAndLoginViewsOverTime(mapOfParameters, action);
			} else if (ACTION_GET_KNOWLEDGE_PAGE_STATS.equalsIgnoreCase(action)){
				reportHeader = STR_RPRT_HDR_KNOWLEDGE_PAGE;
				fileName = STR_FILE_NAME_KNOWLEDGE_PAGE;
				
				knowledgePageCsvData = getKnowledgePageCsv(mapOfParameters);
			}

	    	fileName = fileName + ' ' + currentDateTime;
	    	
    	}catch(Exception e){
	    	returnPage = handleAndTranslateException(returnPage, e);
	    }
	    return returnPage;
    }
    
    /**
   * 
   * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
   * Parameters:
   *      parameter_name -- [Explanation of the purpose of this parameter to the method.
   *      
   * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
   */
   	public class RsvpCsvWrapper{
		public String event {get;set;}   
		public String people {get;set;}
		public String response {get;set;}
		public String responseText {get;set;}
		public String email{set;get;}
		public String city{set;get;}
		public String state{set;get;}
		public String country{set;get;}
		public String department{set;get;}
		public String companyName{set;get;}
		public String division{set;get;}
		public String title{set;get;}
		Public List<String> customFieldValueList{set;get;}
		public List<String> CustomFieldNameList{get;set;}

		public RsvpCsvWrapper(Event_RSVP_Response__c rsvpResponseObj){
			this.event = (rsvpResponseObj.Content__r.Title__c).replaceAll('"','""');
			this.people = rsvpResponseObj.People__r.Full_Name__c;
			this.response = rsvpResponseObj.RSVP_Response__c;
			if(String.isNotBlank(rsvpResponseObj.RSVP_Response_Text__c)) {
				this.responseText = (rsvpResponseObj.RSVP_Response_Text__c).replaceAll('"','""');
			}
			this.city = rsvpResponseObj.people__r.city__c;
			this.country = rsvpResponseObj.people__r.country__c;
			this.state = rsvpResponseObj.people__r.state__c;
			this.department = rsvpResponseObj.people__r.department__c;
			this.companyName = rsvpResponseObj.people__r.company_name__c;
			this.division = rsvpResponseObj.people__r.division__c;
			this.email = rsvpResponseObj.people__r.email__c;
			this.title = rsvpResponseObj.people__r.title__c;
			
			List<String> customFieldValue = new List<String>();
			List<String> CustomFieldName= new List<String>();
			if(String.isNotBlank(SimpplrContext.PPUserCustomFields)) {
				List<CustomProfileField> customFieldList = (List<CustomProfileField>)Json.deserialize(SimpplrContext.PPUserCustomFields, List<CustomProfileField>.class);
				for(CustomProfileField customField:customFieldList) {
					if('Custom_Field_1__c'.equalsIgnoreCase(customField.columnName)) {
						customFieldValue.add(rsvpResponseObj.people__r.Custom_Field_1__c);
						CustomFieldName.add(customField.singular);
					}
					else if('Custom_Field_2__c'.equalsIgnoreCase(customField.columnName)) {
						customFieldValue.add(rsvpResponseObj.people__r.Custom_Field_2__c);
						CustomFieldName.add(customField.singular);
					}
					else if('Custom_Field_3__c'.equalsIgnoreCase(customField.columnName)) {
						customFieldValue.add(rsvpResponseObj.people__r.Custom_Field_3__c);
						CustomFieldName.add(customField.singular);
					}
					else if('Custom_Field_4__c'.equalsIgnoreCase(customField.columnName)) {
						customFieldValue.add(rsvpResponseObj.people__r.Custom_Field_4__c);
						CustomFieldName.add(customField.singular);
					}
					else if('Custom_Field_5__c'.equalsIgnoreCase(customField.columnName)) {
						customFieldValue.add(rsvpResponseObj.people__r.Custom_Field_5__c);
						CustomFieldName.add(customField.singular);
					} 
					else if('Custom_Field_6__c'.equalsIgnoreCase(customField.columnName)) {
						customFieldValue.add(rsvpResponseObj.people__r.Custom_Field_6__c);
						CustomFieldName.add(customField.singular);
					}
					else if('Custom_Field_7__c'.equalsIgnoreCase(customField.columnName)) {
						customFieldValue.add(rsvpResponseObj.people__r.Custom_Field_7__c);
						CustomFieldName.add(customField.singular);
					}
					else if('Custom_Field_8__c'.equalsIgnoreCase(customField.columnName)) {
						customFieldValue.add(rsvpResponseObj.people__r.Custom_Field_8__c);
						CustomFieldName.add(customField.singular);
					}
					else if('Custom_Field_9__c'.equalsIgnoreCase(customField.columnName)) {
						customFieldValue.add(rsvpResponseObj.people__r.Custom_Field_9__c);
						CustomFieldName.add(customField.singular);
					}
					else if('Custom_Field_10__c'.equalsIgnoreCase(customField.columnName)) {
						customFieldValue.add(rsvpResponseObj.people__r.Custom_Field_10__c);
						CustomFieldName.add(customField.singular);
					}
					else if('Custom_Field_11__c'.equalsIgnoreCase(customField.columnName)) {
						customFieldValue.add(rsvpResponseObj.people__r.Custom_Field_11__c);
						CustomFieldName.add(customField.singular);
					}
					else if('Custom_Field_12__c'.equalsIgnoreCase(customField.columnName)) {
						customFieldValue.add(rsvpResponseObj.people__r.Custom_Field_12__c);
						CustomFieldName.add(customField.singular);
					}
					else if('Custom_Field_13__c'.equalsIgnoreCase(customField.columnName)) {
						customFieldValue.add(rsvpResponseObj.people__r.Custom_Field_13__c);
						CustomFieldName.add(customField.singular);
					}
					else if('Custom_Field_14__c'.equalsIgnoreCase(customField.columnName)) {
						customFieldValue.add(rsvpResponseObj.people__r.Custom_Field_14__c);
						CustomFieldName.add(customField.singular);
					}
					else if('Custom_Field_15__c'.equalsIgnoreCase(customField.columnName)) {
						customFieldValue.add(rsvpResponseObj.people__r.Custom_Field_15__c);
						CustomFieldName.add(customField.singular);
					}
					else if('Custom_Field_16__c'.equalsIgnoreCase(customField.columnName)) {
						customFieldValue.add(rsvpResponseObj.people__r.Custom_Field_16__c);
						CustomFieldName.add(customField.singular);
					}
					else if('Custom_Field_17__c'.equalsIgnoreCase(customField.columnName)) {
						customFieldValue.add(rsvpResponseObj.people__r.Custom_Field_17__c);
						CustomFieldName.add(customField.singular);
					}
					else if('Custom_Field_18__c'.equalsIgnoreCase(customField.columnName)) {
						customFieldValue.add(rsvpResponseObj.people__r.Custom_Field_18__c);
						CustomFieldName.add(customField.singular);
					}
					else if('Custom_Field_19__c'.equalsIgnoreCase(customField.columnName)) {
						customFieldValue.add(rsvpResponseObj.people__r.Custom_Field_19__c);
						CustomFieldName.add(customField.singular);
					}
					else if('Custom_Field_20__c'.equalsIgnoreCase(customField.columnName)) {
						customFieldValue.add(rsvpResponseObj.people__r.Custom_Field_20__c);
						CustomFieldName.add(customField.singular);
					}
					else if('Custom_Field_21__c'.equalsIgnoreCase(customField.columnName)) {
						customFieldValue.add(rsvpResponseObj.people__r.Custom_Field_21__c);
						CustomFieldName.add(customField.singular);
					}
					else if('Custom_Field_22__c'.equalsIgnoreCase(customField.columnName)) {
						customFieldValue.add(rsvpResponseObj.people__r.Custom_Field_22__c);
						CustomFieldName.add(customField.singular);
					}
					else if('Custom_Field_23__c'.equalsIgnoreCase(customField.columnName)) {
						customFieldValue.add(rsvpResponseObj.people__r.Custom_Field_23__c);
						CustomFieldName.add(customField.singular);
					}					
					else if('Custom_Field_24__c'.equalsIgnoreCase(customField.columnName)) {
						customFieldValue.add(rsvpResponseObj.people__r.Custom_Field_24__c);
						CustomFieldName.add(customField.singular);
					}					
					else if('Custom_Field_25__c'.equalsIgnoreCase(customField.columnName)) {
						customFieldValue.add(rsvpResponseObj.people__r.Custom_Field_25__c);
						CustomFieldName.add(customField.singular);
					}										
				}
			}
			this.customFieldValueList = customFieldValue;
			this.CustomFieldNameList = CustomFieldName; 
		}
   	}
   	public class AnalyticsPerformanceCsvWrapper{
   		public String name {get;set;}
   		public Integer count {get;set;}
   		public AnalyticsPerformanceCsvWrapper(){
   			count =0;
   		}
   	}

	private void setFilterValueName(){
		if(String.isNotBlank(this.filterBy)){
			this.filterValueName = STR_FILTERED_TO + ' ' + this.filterBy.capitalize();

			String filterValueStr = this.filterValue;
			if('segment'.equalsIgnoreCase(this.filterBy)){
				Map<String, Object> soqlParamMap = new  Map<String, Object>();
				soqlParamMap.put('soqlParam1', filterValueStr);
				String query = 'SELECT Name__c FROM Segment__c WHERE id =: soqlParam1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
				List<Segment__c> segList = (List<Segment__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);

				if(segList != null && !segList.isEmpty()){
					filterValueStr = segList[0].Name__c;
				}
			} else if ('category'.equalsIgnoreCase(this.filterBy)){
				String pCatQuery = 'SELECT Name__c FROM People_Category__c WHERE Id = :soqlParam1';

				Map<String, Object> sqlParamMap = new Map<String, Object>();
				sqlParamMap.put('soqlParam1', filterValueStr);

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<People_Category__c> peopleCatList = (List<People_Category__c>)SIMPESAPI.accessController().queryAsUser(pCatQuery, sqlParamMap);

				if(peopleCatList != null && !peopleCatList.isEmpty()){
					filterValueStr = peopleCatList[0].Name__c;
				}
			} else if ('location'.equalsIgnoreCase(this.filterBy)){
				List<String> locationList = filterValueStr.split('@@');
				
				filterValueStr = '';
				for(String locPartStr : locationList){
					if(String.isNotBlank(locPartStr) && !'null'.equalsIgnoreCase(locPartStr.trim())){
						filterValueStr += locPartStr.trim() + ', ';
					}
				}

				filterValueStr = filterValueStr.removeEnd(', ');
			}	

			this.filterValueName += ' - ' + filterValueStr;
		}
	}

	private List<AnalyticsWrapper.KnowledgePageWrapperCsv> getKnowledgePageCsv(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.KnowledgePageWrapperCsv> knowledgePageWrapperList = new List<AnalyticsWrapper.KnowledgePageWrapperCsv>();

		if(SimpplrContext.isExternalAnalyticsEnabled){
    		knowledgePageWrapperList = (List<AnalyticsWrapper.KnowledgePageWrapperCsv>) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters, 'getKnowledgePageCsv', null);
    	}

		return knowledgePageWrapperList;
	}   
   	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public List<RsvpCsvWrapper> getRsvpResponseList(String contentId){
		List<RsvpCsvWrapper> rsvpCsvWrapList = new List <RsvpCsvWrapper> ();
		List<Event_RSVP_Response__c> rsvpResponseList = [SELECT Content__c,Is_Deleted__c,People__c,People__r.Full_Name__c,people__r.company_name__c,
													people__r.division__c,people__r.city__c,people__r.state__c,people__r.country__c,
													people__r.department__c,people__r.email__c,people__r.title__c,Content__r.Title__c,
															RSVP_Response__c,RSVP_Response_Text__c,people__r.Custom_Field_1__c,people__r.Custom_Field_2__c,
															people__r.Custom_Field_3__c,people__r.Custom_Field_4__c,people__r.Custom_Field_5__c,
															people__r.Custom_Field_6__c,people__r.Custom_Field_7__c,people__r.Custom_Field_8__c,
															people__r.Custom_Field_9__c,people__r.Custom_Field_10__c,people__r.Custom_Field_11__c,
															people__r.Custom_Field_12__c,people__r.Custom_Field_13__c,people__r.Custom_Field_14__c,
															people__r.Custom_Field_15__c,people__r.Custom_Field_16__c,people__r.Custom_Field_17__c,
															people__r.Custom_Field_18__c,people__r.Custom_Field_19__c,people__r.Custom_Field_20__c,
															people__r.Custom_Field_21__c,people__r.Custom_Field_22__c,people__r.Custom_Field_23__c,
															people__r.Custom_Field_24__c,people__r.Custom_Field_25__c
															FROM Event_RSVP_Response__c WHERE Content__c =: contentId AND Is_Deleted__c = false WITH SECURITY_ENFORCED];
		for (Event_RSVP_Response__c rsvpResObj : rsvpResponseList){
			RsvpCsvWrapper wrapObj = new RsvpCsvWrapper(rsvpResObj);
			rsvpCsvWrapList.add(wrapObj);
		}
		return rsvpCsvWrapList;
	}

	public List<AnalyticsWrapper.ContentReferralSourceData> getContentReferralSources(Map<String, Object> mapOfParameters){
		List<AnalyticsWrapper.ContentReferralSourceData> contentReferralSourceDataList;
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		contentReferralSourceDataList = (List<AnalyticsWrapper.ContentReferralSourceData>) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters, 'getContentReferralSources', null);
    	}
		return contentReferralSourceDataList;
	}
	
	public List<AnalyticsWrapper.LoginsData> getLogins(Map<String,Object> mapOfParameters){
		AnalyticsWrapper.Logins loginsDataObj;
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		loginsDataObj = (AnalyticsWrapper.Logins) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getLogins',null);
    	}else{
    		loginsDataObj =  analyticsDaoObj.getLoginsAnalytics((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'));
		}
		return loginsDataObj.data;
    }	 
    
	public List<AnalyticsWrapper.PageViewsData> getPageviews(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PageViewsData> pageViewsDataList;
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		pageViewsDataList = ((AnalyticsWrapper.PageViews) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPageViews',null)).data;
    	}else{
    		 pageViewsDataList =  analyticsDaoObj.getPageviewsAnalytics((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to')).data;
		}
		return pageViewsDataList;
    }
    
	public List<AnalyticsWrapper.AdoptionData> getAdoption(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.AdoptionData> adoptionDataList;
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		adoptionDataList = ((List<AnalyticsWrapper.AdoptionData>) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getAdoption',null));
    	}else{
    		adoptionDataList =  analyticsDaoObj.getAdoptionAnalytics((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'));
		}
		return adoptionDataList;
    }
    
	public Object getAdoptionOverview(Map<String,Object> mapOfParameters){
		AnalyticsWrapper.AdoptionOverview adoptionOverviewObj;
		if(SimpplrContext.isExternalAnalyticsEnabled){
           Map<String,Object> mapReturned = ((Map<String,Object>) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getAdoptionOverview',null));
           adoptionOverviewObj = getAdoptionOverview(mapReturned, (String)mapOfParameters.get('from'), (String)mapOfParameters.get('to'),String.isBlank((String)mapOfParameters.get('filterValue')));
           
       	}else{
            String orderBy = 'Name';
            if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
                orderBy = 'CreatedDate';
            }
            adoptionOverviewObj =  analyticsDaoObj.getAdoptionOverview((String)mapOfParameters.get('from'), (String)mapOfParameters.get('to'), orderBy);
        }
		return adoptionOverviewObj;
    }   
    
	private AnalyticsWrapper.AdoptionOverview getAdoptionOverview(Map<String,Object> mapReturned, String fromDate, String toDate,Boolean includeNoLogin){
		Date tDate = setStringToDateFormat(toDate);
    	Date maxUserCreateDate = tDate.addDays(1);
    	
		AnalyticsWrapper.AdoptionOverview adoptionOverviewObj = new AnalyticsWrapper.AdoptionOverview();
		adoptionOverviewObj.contributorCount = (Integer)mapReturned.get('contributorCount');
		adoptionOverviewObj.participantCount = (Integer)mapReturned.get('participantCount');
		adoptionOverviewObj.observerCount = (Integer)mapReturned.get('observerCount');
		
		Set<String> contributorSet = (Set<String>)JSON.deserialize(JSON.serialize(mapReturned.get('contributorList')),Set<String>.class);
		Set<String> participantSet = (Set<String>)JSON.deserialize(JSON.serialize(mapReturned.get('participantList')),Set<String>.class);
		Set<String> observerSet = (Set<String>)JSON.deserialize(JSON.serialize(mapReturned.get('observerList')),Set<String>.class);
		
		List<String> userFieldToShow;
		if(SimpplrContext.isSegmentsEnabled){
			userFieldToShow = new List<String>{STR_NAME,STR_EMAIL,STR_ADOPTION,STR_SEGMENT,STR_COMPANY_NAME,STR_DIVISION,STR_DEPARTMENT,STR_CITY,STR_STATE,STR_COUNTRY};
		}else{
			userFieldToShow = new List<String>{STR_NAME,STR_EMAIL,STR_ADOPTION,STR_COMPANY_NAME,STR_DIVISION,STR_DEPARTMENT,STR_CITY,STR_STATE,STR_COUNTRY};
		}
		if(SimpplrContext.isPeopleCategoryEnable){
			userFieldToShow.add(SimpplrContext.peopleCategorySingular);
		}
		userFieldToShow.add(STR_ANALYTICS_CONTENT_JOB_TITLE);
		if('Workday'.equalsIgnorecase(SimpplrContext.PDSSourceApplication) && SimpplrContext.isPDSRole){
			userFieldToShow.add(STR_ROLE);
		}
		
		List<String> fieldAPIList = Utility.getLabelWithUserFieldAPIMap(userFieldToShow);
		Map<String,User> userMap = getUserMap(fieldAPIList);
		
		String peopleQuery = 'SELECT id,role__c,People_Category__r.name__c,Title__c, User__c,Full_Name__c, Email__c,Company_Name__c, Division__c, City__c,Country__c,State__c,Department__c, Segment__r.Name__c ';
		peopleQuery += ' From People__c where User__r.CreatedDate < :maxUserCreateDate And (Id IN:contributorSet OR  Id IN:participantSet OR Id IN:observerSet) ';
		if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			peopleQuery += ' order by CreatedDate Desc ';
		} else {
			peopleQuery += ' order by Full_Name__c';
		}
		List<People__c> peopleList = (List<People__c>) Database.query(peopleQuery);
		
		Set<String> setOfUsersLoggedIn = new Set<String>();
		setOfUsersLoggedIn.addAll(contributorSet);
		setOfUsersLoggedIn.addAll(participantSet);
		setOfUsersLoggedIn.addAll(observerSet);
		
		if(includeNoLogin){
			String noLoginPeopleQuery = 'SELECT id,role__c,People_Category__r.name__c,Title__c, User__c,Full_Name__c, Email__c,Company_Name__c, Division__c, City__c,Country__c,State__c,Department__c, Segment__r.Name__c ';
			noLoginPeopleQuery += ' From People__c where User__r.IsActive = true And User__r.CreatedDate < :maxUserCreateDate And Id !=:setOfUsersLoggedIn ';
							   
			if(Utility.isApiOnlyUserQueryable()){
				noLoginPeopleQuery += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
			} else {
				noLoginPeopleQuery += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\')) ';
			}

			if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
				noLoginPeopleQuery += ' order by CreatedDate Desc ';
			} else {
				noLoginPeopleQuery += ' order by Full_Name__c';
			}
			peopleList.addAll((List<People__c>) Database.query(noLoginPeopleQuery));
		}
		List<AnalyticsWrapper.AdoptionOverviewData> participantAdoptionOverviewDataList = new List<AnalyticsWrapper.AdoptionOverviewData>();
		List<AnalyticsWrapper.AdoptionOverviewData> contributorAdoptionOverviewDataList = new List<AnalyticsWrapper.AdoptionOverviewData>();
		List<AnalyticsWrapper.AdoptionOverviewData> observerAdoptionOverviewDataList = new List<AnalyticsWrapper.AdoptionOverviewData>();
		List<AnalyticsWrapper.AdoptionOverviewData> inactiveAdoptionOverviewDataList = new List<AnalyticsWrapper.AdoptionOverviewData>();
		List<AnalyticsWrapper.AdoptionOverviewData> listToReturn = new List<AnalyticsWrapper.AdoptionOverviewData>();
		
		for(People__c peopleObj : peopleList){
			if(participantSet.contains(peopleObj.id)){
				participantAdoptionOverviewDataList.add(new AnalyticsWrapper.AdoptionOverviewData(peopleObj, STR_ANALYTICS_ADOPTION_PARTICIPANTS, userMap.get(peopleObj.user__c), fieldAPIList));
				
			} else if(observerSet.contains(peopleObj.id)){
				observerAdoptionOverviewDataList.add(new AnalyticsWrapper.AdoptionOverviewData(peopleObj, STR_ANALYTICS_ADOPTION_OBSERVERS, userMap.get(peopleObj.user__c), fieldAPIList));
				
			} else if(contributorSet.contains(peopleObj.id)){
				contributorAdoptionOverviewDataList.add(new AnalyticsWrapper.AdoptionOverviewData(peopleObj, STR_ANALYTICS_ADOPTION_CONTRIBUTORS, userMap.get(peopleObj.user__c), fieldAPIList));
				
			} else{
				inactiveAdoptionOverviewDataList.add(new AnalyticsWrapper.AdoptionOverviewData(peopleObj, STR_ANALYTICS_ADOPTION_NO_LOGIN, userMap.get(peopleObj.user__c), fieldAPIList));
			}
		}
		
		listToReturn.addAll(contributorAdoptionOverviewDataList);
		listToReturn.addAll(participantAdoptionOverviewDataList);
		listToReturn.addAll(observerAdoptionOverviewDataList);
		listToReturn.addAll(inactiveAdoptionOverviewDataList);
		
		adoptionOverviewObj.adoptionOverviewDataList = listToReturn;
		adoptionOverviewObj.customFields = userFieldToShow;
		adoptionOverviewObj.inactiveCount = inactiveAdoptionOverviewDataList.size();
	   	return adoptionOverviewObj;
	}
	
	private Date setStringToDateFormat(String myDate) {
	  String[] strDate = myDate.split('-');
	  Integer intDate = integer.valueOf(strDate[2]);
	  Integer intMonth = integer.valueOf(strDate[1]);
	  Integer intYear = integer.valueOf(strDate[0]);
	  Date d = Date.newInstance(intYear, intMonth, intDate);
	  return d;
  	}
	
	private Map<String,User> getUserMap(List<String> fieldAPIList){
    	Map<String,User> userMap;
	    
		String userFieldQueryString = 'SELECT id,';
		for(String str: fieldAPIList){
			userFieldQueryString += str +',';
		}
		userFieldQueryString = userFieldQueryString.removeEnd(',') + ' From user ';
		userMap = new Map<String,User>((List<User>) Database.query(userFieldQueryString));
	    return userMap;
    }
	
	public List<AnalyticsWrapper.PerformanceSitesData> getPerformanceSitesMembersList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformanceSitesData> performanceSiteDataList = new List<AnalyticsWrapper.PerformanceSitesData>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceSiteDataList = ((AnalyticsWrapper.PerformanceSites) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformanceSites',null)).data;
    	}else{
    		performanceSiteDataList = analyticsDaoObj.getPerformanceSitesMembers((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'));
		}
		return performanceSiteDataList;
    }
    
    public List<AnalyticsWrapper.PerformanceSitesData> getPerformanceSitesPostsList(Map<String,Object> mapOfParameters){
	    List<AnalyticsWrapper.PerformanceSitesData> performanceSiteDataList = new List<AnalyticsWrapper.PerformanceSitesData>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceSiteDataList = ((AnalyticsWrapper.PerformanceSites) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformanceSites',null)).data;
    	}else{
    		performanceSiteDataList =  analyticsDaoObj.getPerformanceSitesPosts((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'));
		}
		return performanceSiteDataList;
    }
    
    public List<AnalyticsWrapper.PerformanceSitesData> getPerformanceSitesLikesList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformanceSitesData> performanceSiteDataList = new List<AnalyticsWrapper.PerformanceSitesData>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceSiteDataList = ((AnalyticsWrapper.PerformanceSites) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformanceSites',null)).data;
    	}else{
    		performanceSiteDataList =  analyticsDaoObj.getPerformanceSitesLikes((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'));
		}
		return performanceSiteDataList;
    }
    
    public List<AnalyticsWrapper.PerformanceSitesData> getPerformanceSitesRepliesList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformanceSitesData> performanceSiteDataList = new List<AnalyticsWrapper.PerformanceSitesData>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceSiteDataList = ((AnalyticsWrapper.PerformanceSites) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformanceSites',null)).data;
    	}else{
    		performanceSiteDataList =  analyticsDaoObj.getPerformanceSitesReplies((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'));
		}
		return performanceSiteDataList;
    }
    
    public List<AnalyticsWrapper.PerformanceSitesData> getPerformanceSitesViewsList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformanceSitesData> performanceSiteDataList = new List<AnalyticsWrapper.PerformanceSitesData>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceSiteDataList = ((AnalyticsWrapper.PerformanceSites) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformanceSites',null)).data;
    	}else{
    		performanceSiteDataList =  analyticsDaoObj.getPerformanceSitesViews((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'));
		}
		return performanceSiteDataList;
    }
    
    public List<AnalyticsWrapper.PerformanceSitesData> getPerformanceSitesPublishedList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformanceSitesData> performanceSiteDataList = new List<AnalyticsWrapper.PerformanceSitesData>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceSiteDataList = ((AnalyticsWrapper.PerformanceSites) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformanceSites',null)).data;
    	}else{
    		performanceSiteDataList =  analyticsDaoObj.getPerformanceSitesContentPublished((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'));
		}
		return performanceSiteDataList;
    }
    
     public List<AnalyticsWrapper.PerformancePeopleData> getPerformancePeopleBookmarksMadeList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformancePeopleData> performancePeopleDataList = new List<AnalyticsWrapper.PerformancePeopleData>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performancePeopleDataList = ((AnalyticsWrapper.PerformancePeople) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformancePeople',null)).data;
    	}else{
    		performancePeopleDataList = analyticsDaoObj.getPerformancePeopleBookmarks((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'));
		}
		return performancePeopleDataList;
    }
    
     public List<AnalyticsWrapper.PerformancePeopleData> getPerformancePeopleBookmarksReceivedList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformancePeopleData> performancePeopleDataList = new List<AnalyticsWrapper.PerformancePeopleData>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performancePeopleDataList = ((AnalyticsWrapper.PerformancePeople) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformancePeople',null)).data;
    	}else{
    		performancePeopleDataList =  analyticsDaoObj.getPerformancePeopleBookmarksReceived((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'));
		}
		return performancePeopleDataList;
    }
    
     public List<AnalyticsWrapper.PerformancePeopleData> getPerformancePeopleContentPublishedList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformancePeopleData> performancePeopleDataList = new List<AnalyticsWrapper.PerformancePeopleData>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performancePeopleDataList = ((AnalyticsWrapper.PerformancePeople) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformancePeople',null)).data;
    	}else{
    		performancePeopleDataList =  analyticsDaoObj.getPerformancePeoplePublished((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'));
		}

		return performancePeopleDataList;
    }
    
     public List<AnalyticsWrapper.PerformancePeopleData> getPerformancePeopleMentionsList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformancePeopleData> performancePeopleDataList = new List<AnalyticsWrapper.PerformancePeopleData>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performancePeopleDataList = ((AnalyticsWrapper.PerformancePeople) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformancePeople',null)).data;
    	}else{
    		performancePeopleDataList =  analyticsDaoObj.getPerformancePeopleMentions((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'));
		}
		return performancePeopleDataList;
    }
    
     public List<AnalyticsWrapper.PerformancePeopleData> getPerformancePeoplePostsList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformancePeopleData> performancePeopleDataList = new List<AnalyticsWrapper.PerformancePeopleData>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performancePeopleDataList = ((AnalyticsWrapper.PerformancePeople) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformancePeople',null)).data;
    	}else{
    		performancePeopleDataList =  analyticsDaoObj.getPerformancePeoplePosts((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'));
		}
		return performancePeopleDataList;
    }
    
     public List<AnalyticsWrapper.PerformancePeopleData> getPerformancePeopleRepliesMadeList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformancePeopleData> performancePeopleDataList = new List<AnalyticsWrapper.PerformancePeopleData>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performancePeopleDataList = ((AnalyticsWrapper.PerformancePeople) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformancePeople',null)).data;
    	}else{
    		performancePeopleDataList =  analyticsDaoObj.getPerformancePeopleReplies((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'));
		}
		return performancePeopleDataList;
    }
    
     public List<AnalyticsWrapper.PerformancePeopleData> getPerformancePeopleRepliesReceivedList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformancePeopleData> performancePeopleDataList = new List<AnalyticsWrapper.PerformancePeopleData>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performancePeopleDataList = ((AnalyticsWrapper.PerformancePeople) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformancePeople',null)).data;
    	}else{
    		performancePeopleDataList =  analyticsDaoObj.getPerformancePeopleRepliesReceived((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'));
		}
		return performancePeopleDataList;
    }
    
     public List<AnalyticsWrapper.PerformancePeopleData> getPerformancePeopleFollowersList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformancePeopleData> performancePeopleDataList = new List<AnalyticsWrapper.PerformancePeopleData>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performancePeopleDataList = ((AnalyticsWrapper.PerformancePeople) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformancePeople',null)).data;
    	}else{
    		performancePeopleDataList =  analyticsDaoObj.getPerformancePeopleFollowers((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'));
		}
		return performancePeopleDataList;
    }
    
     public List<AnalyticsWrapper.PerformancePeopleData> getPerformancePeopleFollowingList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformancePeopleData> performancePeopleDataList = new List<AnalyticsWrapper.PerformancePeopleData>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performancePeopleDataList = ((AnalyticsWrapper.PerformancePeople) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformancePeople',null)).data;
    	}else{
    		performancePeopleDataList =  analyticsDaoObj.getPerformancePeopleFollowing((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'));
		}
		return performancePeopleDataList;
    }
    
     public List<AnalyticsWrapper.PerformancePeopleData> getPerformancePeopleLikesMadeList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformancePeopleData> performancePeopleDataList = new List<AnalyticsWrapper.PerformancePeopleData>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performancePeopleDataList = ((AnalyticsWrapper.PerformancePeople) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformancePeople',null)).data;
    	}else{
    		performancePeopleDataList =  analyticsDaoObj.getPerformancePeopleLikes((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'));
		}
		return performancePeopleDataList;
    }
    
     public List<AnalyticsWrapper.PerformancePeopleData> getPerformancePeopleLikesReceivedList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformancePeopleData> performancePeopleDataList = new List<AnalyticsWrapper.PerformancePeopleData>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performancePeopleDataList = ((AnalyticsWrapper.PerformancePeople) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformancePeople',null)).data;
    	}else{
    		performancePeopleDataList =  analyticsDaoObj.getPerformancePeopleLikesReceived((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'));
		}
		return performancePeopleDataList;
    }
    
     public List<AnalyticsWrapper.PerformancePeopleData> getPerformancePeopleSharesMadeList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformancePeopleData> performancePeopleDataList = new List<AnalyticsWrapper.PerformancePeopleData>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performancePeopleDataList = ((AnalyticsWrapper.PerformancePeople) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformancePeople',null)).data;
    	}else{
    		performancePeopleDataList =  analyticsDaoObj.getPerformancePeopleShares((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'));
		}
		return performancePeopleDataList;
    }
    
     public List<AnalyticsWrapper.PerformancePeopleData> getPerformancePeopleSharesReceivedList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformancePeopleData> performancePeopleDataList = new List<AnalyticsWrapper.PerformancePeopleData>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performancePeopleDataList = ((AnalyticsWrapper.PerformancePeople) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformancePeople',null)).data;
    	}else{
    		performancePeopleDataList =  analyticsDaoObj.getPerformancePeopleSharesReceived((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'));
		}
		return performancePeopleDataList;
    }
    
    public List<AnalyticsWrapper.PerformancePeopleData> getPerformancePeopleProfileViewsList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformancePeopleData> performancePeopleDataList = new List<AnalyticsWrapper.PerformancePeopleData>();
		
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performancePeopleDataList = ((AnalyticsWrapper.PerformancePeople) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformancePeople',null)).data;
    	}else{
    		performancePeopleDataList = analyticsDaoObj.getPerformancePeopleProfileViews((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'));
    	}
		return performancePeopleDataList;
    }
    
     public List<AnalyticsWrapper.PerformanceContentData> getPerformanceContentBookmarksList(Map<String,Object> mapOfParameters){
     	List<AnalyticsWrapper.PerformanceContentData> performanceContentDataList;
     	if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceContentDataList = ((AnalyticsWrapper.PerformanceContent) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformanceContent',null)).data;
    	}else{
	     	if(contentType != null){
	     		performanceContentDataList =  analyticsDaoObj.getPerformanceContentBookmarks((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'),(String)mapOfParameters.get('contentType'),(String)mapOfParameters.get('siteId'));
	     	}else{
	     		performanceContentDataList =  analyticsDaoObj.getPerformanceContentBookmarksAll((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'),(String)mapOfParameters.get('siteId'));
	     	}
     	}
		return performanceContentDataList;
    }
    
     public List<AnalyticsWrapper.PerformanceContentData> getPerformanceContentLikesList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformanceContentData> performanceContentDataList;
     	if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceContentDataList = ((AnalyticsWrapper.PerformanceContent) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformanceContent',null)).data;
    	}else{
	     	if(contentType != null){
	     		performanceContentDataList =  analyticsDaoObj.getPerformanceContentLikes((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'),(String)mapOfParameters.get('contentType'),(String)mapOfParameters.get('siteId'));
	     	}else{
	     		performanceContentDataList =  analyticsDaoObj.getPerformanceContentLikesAll((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'),(String)mapOfParameters.get('siteId'));
	     	}
     	}
		return performanceContentDataList;
    }
    
     public List<AnalyticsWrapper.PerformanceContentData> getPerformanceContentPostsList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformanceContentData> performanceContentDataList;
     	if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceContentDataList = ((AnalyticsWrapper.PerformanceContent) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformanceContent',null)).data;
    	}else{
	     	if(contentType != null){
	     		performanceContentDataList =  analyticsDaoObj.getPerformanceContentPosts((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'),(String)mapOfParameters.get('contentType'),(String)mapOfParameters.get('siteId'));
	     	}else{
	     		performanceContentDataList =  analyticsDaoObj.getPerformanceContentPostsAll((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'),(String)mapOfParameters.get('siteId'));
	     	}
     	}
		return performanceContentDataList;
    }
    
     public List<AnalyticsWrapper.PerformanceContentData> getPerformanceContentRepliesList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformanceContentData> performanceContentDataList;
     	if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceContentDataList = ((AnalyticsWrapper.PerformanceContent) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformanceContent',null)).data;
    	}else{
	     	if(contentType != null){
	     		performanceContentDataList =  analyticsDaoObj.getPerformanceContentReplies((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'),(String)mapOfParameters.get('contentType'),(String)mapOfParameters.get('siteId'));
	     	}else{
	     		performanceContentDataList =  analyticsDaoObj.getPerformanceContentRepliesAll((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'),(String)mapOfParameters.get('siteId'));
	     	}
     	}
		return performanceContentDataList;
    }
    
     public List<AnalyticsWrapper.PerformanceContentData> getPerformanceContentSharesList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformanceContentData> performanceContentDataList;
     	if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceContentDataList = ((AnalyticsWrapper.PerformanceContent) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformanceContent',null)).data;
    	}else{
	     	if(contentType != null){
	     		performanceContentDataList =  analyticsDaoObj.getPerformanceContentShares((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'),(String)mapOfParameters.get('contentType'),(String)mapOfParameters.get('siteId'));
	     	}else{
	     		performanceContentDataList =  analyticsDaoObj.getPerformanceContentSharesAll((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'),(String)mapOfParameters.get('siteId'));
	     	}
     	}
		return performanceContentDataList;
    }
    
    public List<AnalyticsWrapper.PerformanceContentData> getPerformanceContentUnusefulList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformanceContentData> performanceContentDataList;
     	if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceContentDataList = ((AnalyticsWrapper.PerformanceContent) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformanceContent',null)).data;
    	}else{
	     	if(contentType != null){
	     		performanceContentDataList =  analyticsDaoObj.getPerformanceContentUnuseful((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'),(String)mapOfParameters.get('contentType'),(String)mapOfParameters.get('siteId'));
	     	}else{
	     		performanceContentDataList =  analyticsDaoObj.getPerformanceContentUnusefulAll((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'),(String)mapOfParameters.get('siteId'));
	     	}
     	}
		return performanceContentDataList;
    }
    
    public List<AnalyticsWrapper.PerformanceContentData> getPerformanceContentUsefulList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformanceContentData> performanceContentDataList;
     	if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceContentDataList = ((AnalyticsWrapper.PerformanceContent) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformanceContent',null)).data;
    	}else{
	     	if(contentType != null){
	     		performanceContentDataList =  analyticsDaoObj.getPerformanceContentUseful((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'),(String)mapOfParameters.get('contentType'),(String)mapOfParameters.get('siteId'));
	     	}else{
	     		performanceContentDataList =  analyticsDaoObj.getPerformanceContentUsefulAll((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'),(String)mapOfParameters.get('siteId'));
	     	}
     	}
		return performanceContentDataList;
    }
    
     public List<AnalyticsWrapper.PerformanceContentData> getPerformanceContentViewsList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformanceContentData> performanceContentDataList;
     	if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceContentDataList = ((AnalyticsWrapper.PerformanceContent) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformanceContent',null)).data;
    	}else{
	     	if(contentType != null){
	     		performanceContentDataList =  analyticsDaoObj.getPerformanceContentViews((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'),(String)mapOfParameters.get('contentType'),(String)mapOfParameters.get('siteId'));
	     	}else{
	     		performanceContentDataList =  analyticsDaoObj.getPerformanceContentViewsAll((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'),(String)mapOfParameters.get('siteId'));
	     	}
     	}
		return performanceContentDataList;
    }
    
    public List<AnalyticsWrapper.PerformanceTopicsData> getPerformanceTopicsEndorsementList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformanceTopicsData> performanceTopicsDataList;
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceTopicsDataList = ((AnalyticsWrapper.PerformanceTopics) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformanceTopics',null)).data;
    	}else{
			performanceTopicsDataList =  analyticsDaoObj.getPerformanceTopicsEndorsements((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'));
		}
		return performanceTopicsDataList;
    }
    
    public List<AnalyticsWrapper.PerformanceTopicsData> getPerformanceTopicsExpertiseList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformanceTopicsData> performanceTopicsDataList;
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceTopicsDataList = ((AnalyticsWrapper.PerformanceTopics) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformanceTopics',null)).data;
    	}else{
			performanceTopicsDataList =  analyticsDaoObj.getPerformanceTopicsExpertise((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'));
		}
		return performanceTopicsDataList;
    }
    
    public List<AnalyticsWrapper.PerformanceTopicsData> getPerformanceTopicsFollowersList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformanceTopicsData> performanceTopicsDataList;
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceTopicsDataList = ((AnalyticsWrapper.PerformanceTopics) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformanceTopics',null)).data;
    	}else{
			performanceTopicsDataList = analyticsDaoObj.getPerformanceTopicsFollowers((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'));
		}
		return performanceTopicsDataList;
    }
    
    public List<AnalyticsWrapper.PerformanceTopicsData> getPerformanceTopicsViewsList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformanceTopicsData> performanceTopicsDataList;
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceTopicsDataList = ((AnalyticsWrapper.PerformanceTopics) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformanceTopics',null)).data;
    	}else{
			performanceTopicsDataList =  analyticsDaoObj.getPerformanceTopicsViews((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'));
		}
		return performanceTopicsDataList;
    }
    
    public List<AnalyticsWrapper.PerformanceSearchData> getPerformanceSearchList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformanceSearchData> performanceSearchDataList;
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceSearchDataList = ((AnalyticsWrapper.PerformanceSearch) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformanceSearch',null)).data;
    	}else{
    		performanceSearchDataList =  analyticsDaoObj.getPerformanceSearch((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'));
		}
		List<AnalyticsWrapper.PerformanceSearchData> extractedPerformanceSearchDataList = new List<AnalyticsWrapper.PerformanceSearchData>();
		Integer counter = 0;
    	while(counter<50 && counter<performanceSearchDataList.size()) {
	    	extractedPerformanceSearchDataList.add(performanceSearchDataList[counter++]);
	    }
		return extractedPerformanceSearchDataList;
    }
    
     public List<AnalyticsWrapper.PerformanceSearchData> getPerformanceZeroSearchResultsList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.PerformanceSearchData> performanceSearchDataList;
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceSearchDataList = ((AnalyticsWrapper.PerformanceSearch) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformanceZeroSearchResults',null)).data;
    	}else{
    		performanceSearchDataList =  analyticsDaoObj.getPerformanceZeroSearchResults((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'));
		}
		
		List<AnalyticsWrapper.PerformanceSearchData> extractedPerformanceSearchDataList = new List<AnalyticsWrapper.PerformanceSearchData>();
		Integer counter = 0;
    	while(counter<50 && counter<performanceSearchDataList.size()) {
	    	extractedPerformanceSearchDataList.add(performanceSearchDataList[counter++]);
	    }
		return extractedPerformanceSearchDataList;
    }
    
    public List<AnalyticsWrapper.EngagementfeedData> getPerformanceEngagementFeedPostsList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.EngagementfeedData> performanceEngagementFeedList = new List<AnalyticsWrapper.EngagementfeedData>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceEngagementFeedList = ((List<AnalyticsWrapper.EngagementfeedData>) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getEngagementFeed',null));
    	}else{
		 	performanceEngagementFeedList = analyticsDaoObj.getEngagementFeedPosts((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'),(String)mapOfParameters.get('siteId'));
		}
		return performanceEngagementFeedList;
    }
    
    public List<AnalyticsWrapper.EngagementfeedData> getPerformanceEngagementFeedLikesList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.EngagementfeedData> performanceEngagementFeedList = new List<AnalyticsWrapper.EngagementfeedData>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceEngagementFeedList = ((List<AnalyticsWrapper.EngagementfeedData>) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getEngagementFeed',null));
    	}else{
    		performanceEngagementFeedList = analyticsDaoObj.getEngagementFeedLikes((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'),(String)mapOfParameters.get('siteId'));
		}
		return performanceEngagementFeedList;
    }
    
    public List<AnalyticsWrapper.EngagementfeedData> getPerformanceEngagementFeedRepliesList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.EngagementfeedData> performanceEngagementFeedList = new List<AnalyticsWrapper.EngagementfeedData>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceEngagementFeedList = ((List<AnalyticsWrapper.EngagementfeedData>) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getEngagementFeed',null));
    	}else{
    		performanceEngagementFeedList =  analyticsDaoObj.getEngagementFeedReplies((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'),(String)mapOfParameters.get('siteId'));
		}
		return performanceEngagementFeedList;
    }
    
    public List<AnalyticsWrapper.EngagementfeedData> getPerformanceEngagementFeedSharesList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.EngagementfeedData> performanceEngagementFeedList = new List<AnalyticsWrapper.EngagementfeedData>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceEngagementFeedList = ((List<AnalyticsWrapper.EngagementfeedData>) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getEngagementFeed',null));
    	}else{
    		performanceEngagementFeedList =  analyticsDaoObj.getEngagementFeedShares((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'),(String)mapOfParameters.get('siteId'));
		}
		return performanceEngagementFeedList;
    }
    
    public List<AnalyticsWrapper.EngagementContentData> getperformanceEngagementContentBookmarkList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.EngagementContentData> performanceEngagementContentList = new List<AnalyticsWrapper.EngagementContentData>(); 
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceEngagementContentList = ((List<AnalyticsWrapper.EngagementContentData>) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getEngagementContent',null));
    	}else{
    		performanceEngagementContentList = analyticsDaoObj.getEngagementContentBookmarks((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'),(String)mapOfParameters.get('siteId'));
		}
		return performanceEngagementContentList;
    }
    
    public List<AnalyticsWrapper.EngagementContentData> getperformanceEngagementContentLikesList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.EngagementContentData> performanceEngagementContentList = new List<AnalyticsWrapper.EngagementContentData>(); 
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceEngagementContentList = ((List<AnalyticsWrapper.EngagementContentData>) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getEngagementContent',null));
    	}else{
    		performanceEngagementContentList =  analyticsDaoObj.getEngagementContentLikes((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'),(String)mapOfParameters.get('siteId'));
		}
		return performanceEngagementContentList;
    }
    
    public List<AnalyticsWrapper.EngagementContentData> getperformanceEngagementContentPostsList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.EngagementContentData> performanceEngagementContentList = new List<AnalyticsWrapper.EngagementContentData>(); 
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceEngagementContentList = ((List<AnalyticsWrapper.EngagementContentData>) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getEngagementContent',null));
    	}else{
    		performanceEngagementContentList =  analyticsDaoObj.getEngagementContentPosts((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'),(String)mapOfParameters.get('siteId'));
		}
		return performanceEngagementContentList;
    }
    
    public List<AnalyticsWrapper.EngagementContentData> getperformanceEngagementContentPublishedList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.EngagementContentData> performanceEngagementContentList = new List<AnalyticsWrapper.EngagementContentData>(); 
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceEngagementContentList = ((List<AnalyticsWrapper.EngagementContentData>) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getEngagementContent',null));
    	}else{
    		performanceEngagementContentList =  analyticsDaoObj.getEngagementContentPublished((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'),(String)mapOfParameters.get('siteId'));
		}
		return performanceEngagementContentList;
    }
    
    public List<AnalyticsWrapper.EngagementContentData> getperformanceEngagementContentRepliesList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.EngagementContentData> performanceEngagementContentList = new List<AnalyticsWrapper.EngagementContentData>(); 
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceEngagementContentList = ((List<AnalyticsWrapper.EngagementContentData>) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getEngagementContent',null));
    	}else{
    		performanceEngagementContentList =  analyticsDaoObj.getEngagementContentReplies((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'),(String)mapOfParameters.get('siteId'));
		}
		return performanceEngagementContentList;
    }
    
    public List<AnalyticsWrapper.EngagementContentData> getperformanceEngagementContentSharesList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.EngagementContentData> performanceEngagementContentList = new List<AnalyticsWrapper.EngagementContentData>(); 
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceEngagementContentList = ((List<AnalyticsWrapper.EngagementContentData>) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getEngagementContent',null));
    	}else{
    		performanceEngagementContentList =  analyticsDaoObj.getEngagementContentShares((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'),(String)mapOfParameters.get('siteId'));
		}
		return performanceEngagementContentList;
    }
    
    public List<AnalyticsWrapper.EngagementContentData> getperformanceEngagementContentViewsList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.EngagementContentData> performanceEngagementContentList = new List<AnalyticsWrapper.EngagementContentData>(); 
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceEngagementContentList = ((List<AnalyticsWrapper.EngagementContentData>) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getEngagementContent',null));
    	}else{
    		performanceEngagementContentList =  analyticsDaoObj.getEngagementContentViews((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'),(String)mapOfParameters.get('siteId'));
		}
		return performanceEngagementContentList;
    }
    
    public List<AnalyticsWrapper.EngagementContentTypesData> getPerformanceEngagementContentTypesList(Map<String,Object> mapOfParameters){
		List<AnalyticsWrapper.EngagementContentTypesData> performanceEngagementContentTypesList = new List<AnalyticsWrapper.EngagementContentTypesData>(); 
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		performanceEngagementContentTypesList = ((List<AnalyticsWrapper.EngagementContentTypesData>) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getEngagementContentTypes',null));
    	}else{
    		performanceEngagementContentTypesList =  analyticsDaoObj.getEngagementContentTypes((String)mapOfParameters.get('from'),(String)mapOfParameters.get('to'),(String)mapOfParameters.get('siteId'));
		}
		
		isEventEnabled = SimpplrContext.AllowedFeatures.containsIgnoreCase(AccessManager.FEATURE_EVENT);
		isPageEnabled = SimpplrContext.AllowedFeatures.containsIgnoreCase(AccessManager.FEATURE_PAGE);
		isAlbumEnabled = SimpplrContext.AllowedFeatures.containsIgnoreCase(AccessManager.FEATURE_ALBUM);
		isBlogEnabled = SimpplrContext.AllowedFeatures.containsIgnoreCase(AccessManager.FEATURE_BLOG);
    		
    		if(String.isNotBlank(siteId)) {
    			isEventEnabled = isEventEnabled && SiteContext.hasEvents;
    			isPageEnabled = isPageEnabled && SiteContext.hasPages;
    			isAlbumEnabled = isAlbumEnabled && SiteContext.hasAlbums;
    		}
		return performanceEngagementContentTypesList;
    }
    
    public AnalyticsWrapper.AdoptionCSVData getPageAndLoginViewsOverTime(Map<String,Object> mapOfParameters,String action){
    	AnalyticsWrapper.AdoptionCSVData adoptionData = new AnalyticsWrapper.AdoptionCSVData();

		if(SimpplrContext.isExternalAnalyticsEnabled){
			adoptionData = getPageAndLoginViewsOverTimeData((List<Object>) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters, action, null), action);
		}

		return adoptionData;
    }

		private AnalyticsWrapper.AdoptionCSVData getPageAndLoginViewsOverTimeData(List<Object> objectList, String action){
			List<AnalyticsWrapper.AdoptionCSV> loginsOverTimeList = new List<AnalyticsWrapper.AdoptionCSV>();
			
			List<String> userFieldToShow;
			String valueHeaderName = STR_ANALYTICS_ADOPTION_PAGE_VIEWS_PERIOD;
			if(ACTION_GET_LOGINS_OVER_TIME_CSV.equalsIgnoreCase(action)){
					valueHeaderName =  null ;
			}
			if(SimpplrContext.isSegmentsEnabled){
				userFieldToShow = new List<String>{STR_ANALYTICS_ADOPTION_DATE_LAST_LOGIN, valueHeaderName, STR_NAME, STR_EMAIL, STR_SEGMENT, STR_COMPANY_NAME, STR_DIVISION, STR_DEPARTMENT, STR_CITY, STR_STATE, STR_COUNTRY};
			}else {
				userFieldToShow = new List<String>{STR_ANALYTICS_ADOPTION_DATE_LAST_LOGIN, valueHeaderName, STR_NAME, STR_EMAIL, STR_COMPANY_NAME, STR_DIVISION, STR_DEPARTMENT, STR_CITY, STR_STATE, STR_COUNTRY};
			}
			if(SimpplrContext.isPeopleCategoryEnable){
				userFieldToShow.add(SimpplrContext.peopleCategorySingular);
			}
			userFieldToShow.add(STR_ANALYTICS_CONTENT_JOB_TITLE);
			if('Workday'.equalsIgnorecase(SimpplrContext.PDSSourceApplication) && SimpplrContext.isPDSRole){
				userFieldToShow.add(STR_ROLE);
			}
			
			List<String> fieldAPIList = Utility.getLabelWithUserFieldAPIMap(userFieldToShow);
			Map<String,User> userMap = getUserMap(fieldAPIList);

			List<String> ids = new List<String>();
			ids = fetchIds(objectList);
			Map<String,people__c> peopleMap = new Map<String,people__c>([select id, Full_Name__c, user__c, user__r.isactive, Company_Name__c, Email__c, Segment__r.name__c,
																			Division__c, Department__c, city__c, state__c, country__c, role__c, title__c, People_Category__r.name__c
																			from people__c where id IN:ids]);
			
			for(Object obj : objectList){
				Map<String,Object> mapOfParams = (Map<String,Object>)obj;
				String key = (String)mapOfParams.get('id');
				
				if(peopleMap.containskey(key)){
					People__c peopleObj = peopleMap.get(key);
					AnalyticsWrapper.AdoptionCSV dataObj = new AnalyticsWrapper.AdoptionCSV();
					List<String> fieldValues = new List<String>();

					fieldValues.add((String) mapOfParams.get('label'));
					if(!ACTION_GET_LOGINS_OVER_TIME_CSV.equalsIgnoreCase(action)){
					fieldValues.add(String.valueOf((Integer) mapOfParams.get('value')));
					}
					fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.Full_Name__c));
					fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.Email__c));
					if(SimpplrContext.isSegmentsEnabled){
						fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.Segment__r.Name__c));
					}
					fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.Company_Name__c));
					fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.Division__c));
					fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.Department__c));
					fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.City__c));
					fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.State__c));
					fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.Country__c));
					if(SimpplrContext.isPeopleCategoryEnable){
						fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.People_Category__r.name__c));
					}
					fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.title__c));
					if('Workday'.equalsIgnorecase(SimpplrContext.PDSSourceApplication) && SimpplrContext.isPDSRole){
						fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.role__c));
					}

					User userObj = userMap.get(peopleObj.user__c);
					for(String field: fieldAPIList){
						fieldValues.add(addFieldValueInDoubleQuotes(String.valueOf(userObj.get(field))));
					}
					
					dataObj.fieldValues = fieldValues;

					loginsOverTimeList.add(dataObj);
				}
			}

			AnalyticsWrapper.AdoptionCSVData data = new AnalyticsWrapper.AdoptionCSVData();
			data.adoptionCSVList = loginsOverTimeList;
 			data.fieldsList = userFieldToShow;

			return data;
		}

		private String addFieldValueInDoubleQuotes(String fieldVal){
			String valToReturn = String.isNotBlank(fieldVal) ? '"'+fieldVal.replace('"','""')+'"' :'';
			return valToReturn;
		}

		private List<String> fetchIds(List<Object> objectList){
			List<String> ids = new List<String>();
			for(Object obj : objectList){
				Map<String,Object> record = (Map<String,Object>)obj;
				ids.add((String)record.get('id'));
			}
			return ids;
		}
    
    public List<AnalyticsWrapper.ContentViewsCSV> getContentViews(Map<String,Object> mapOfParameters){
    	List<AnalyticsWrapper.ContentViewsCSV> contentViewsData = new List<AnalyticsWrapper.ContentViewsCSV>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		contentViewsData = ((List<AnalyticsWrapper.ContentViewsCSV>) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getContentViewsCsv',null));
    	}
		return contentViewsData;
    }
    
    public AnalyticsWrapper.ContentRelatedData getContentViewsByDepts(Map<String,Object> mapOfParameters){
    	AnalyticsWrapper.ContentRelatedData contentViewsByDeptsData = new AnalyticsWrapper.ContentRelatedData();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		contentViewsByDeptsData = (AnalyticsWrapper.ContentRelatedData) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getContentViews',null);
    	}
		return contentViewsByDeptsData;
    }
    
     public AnalyticsWrapper.ContentRelatedData getContentViewsByLocations(Map<String,Object> mapOfParameters){
    	AnalyticsWrapper.ContentRelatedData contentViewsByLocationsData = new AnalyticsWrapper.ContentRelatedData();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		contentViewsByLocationsData = (AnalyticsWrapper.ContentRelatedData) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getContentViews',null);
    	}
		return contentViewsByLocationsData;
	}
	
	public List<AnalyticsWrapper.ViewsOverTime> getAppPageViews(Map<String,Object> mapOfParameters){
    	List<AnalyticsWrapper.ViewsOverTime> viewsList = new List<AnalyticsWrapper.ViewsOverTime>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		viewsList = ((List<AnalyticsWrapper.ViewsOverTime>) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getAppPageViews',null));
    	}
		return viewsList;
    }

	public AnalyticsWrapper.ContentRelatedData getSiteViewsTotal(Map<String,Object> mapOfParameters){
    	AnalyticsWrapper.ContentRelatedData contentData = new AnalyticsWrapper.ContentRelatedData();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		contentData = ((AnalyticsWrapper.ContentRelatedData) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getSiteViewsTotal',null));
    	}
    	contentData.totalCountForCSV = 0;
    	for( AnalyticsWrapper.ViewsOverTime obj : contentData.viewsOverTime){
    		contentData.totalCountForCSV += obj.value;
    	}
		return contentData;
    }
    
    public AnalyticsWrapper.ContentRelatedData getAdoptiondata(Map<String,Object> mapOfParameters){
    	AnalyticsWrapper.ContentRelatedData contentData = new AnalyticsWrapper.ContentRelatedData();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		contentData = ((AnalyticsWrapper.ContentWrapper) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getAdoptionData',null)).data;
    	}
		return contentData;
    }
    
    public List<AnalyticsWrapper.ViewsOverTime> getSearchdata(Map<String,Object> mapOfParameters,String action){
    	List<AnalyticsWrapper.ViewsOverTime> searchData = new List<AnalyticsWrapper.ViewsOverTime>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		searchData = ((AnalyticsWrapper.SearchData) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,action,null)).searchesOverTime;
    	}
		return searchData;
    }
    public List<AnalyticsWrapper.ViewsOverTime> getSearchListData(Map<String,Object> mapOfParameters,String action){
    	List<AnalyticsWrapper.ViewsOverTime> searchData = new List<AnalyticsWrapper.ViewsOverTime>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		searchData = ((AnalyticsWrapper.SearchData) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,action,null)).searchList;
    	}
		return searchData;
    }
    
    public List<AnalyticsWrapper.ContentInformation> getContentPublications(Map<String,Object> mapOfParameters){
    	List<AnalyticsWrapper.ContentInformation> contentPublications = new List<AnalyticsWrapper.ContentInformation>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		contentPublications = (List<AnalyticsWrapper.ContentInformation>) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters, 'getContentPublicationsCsv', null);
    	}
		return contentPublications;
    }
    
    public AnalyticsWrapper.SiteCountData getSiteCounts(Map<String,Object> mapOfParameters){
    	AnalyticsWrapper.SiteCountData siteCounts = new AnalyticsWrapper.SiteCountData();
			if(SimpplrContext.isExternalAnalyticsEnabled){
    		siteCounts = (AnalyticsWrapper.SiteCountData) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters, 'getSiteCounts', null);
    	}
		return siteCounts;
    }
    
    public List<AnalyticsWrapper.MonthlyReportData> getMonthlyReport(){
    	List<AnalyticsWrapper.MonthlyReportData> monthlyReport = new List<AnalyticsWrapper.MonthlyReportData>();
			if(SimpplrContext.isExternalAnalyticsEnabled){
    		monthlyReport = ((AnalyticsWrapper.MonthlyReport) externalAnalyticsServiceObj.getExternalAnalyticsResults(null,'getMonthlyReports',null)).data;

				for(AnalyticsWrapper.MonthlyReportData reportData : monthlyReport){
					String month = (reportData.month < 10 ? ('0' + reportData.month) : reportData.month + '');
					reportData.label = LocaleContext.getLabel(UserContext.languageLocaleKey, 'common.date.month.short.' + month) + ' ' + reportData.year;
				}
    	}
			return monthlyReport;
    }
    
    public List<AnalyticsWrapper.PerformanceContentData> getPerformanceContentList(Map<String,Object> mapOfParameters){
    	List<AnalyticsWrapper.PerformanceContentData> contentData = new List<AnalyticsWrapper.PerformanceContentData>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		contentData = ((AnalyticsWrapper.PerformanceContent) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPerformanceContent',null)).data;
    	}
		return contentData;
    }
    
    public List<AnalyticsWrapper.ViewsOverTime> getEngagement(Map<String,Object> mapOfParameters,String action){
		this.setFilterValueName();
    	AnalyticsWrapper.EngagementData engagementData = new AnalyticsWrapper.EngagementData();
		if(SimpplrContext.isExternalAnalyticsEnabled){
			if(action == 'getEngagement'){
    			engagementData = ((AnalyticsWrapper.Engagement) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getEngagement',null)).data;
				if(mapOfParameters.containsKey('filterBy') && 'site'.equalsIgnoreCase((String)mapOfParameters.get('filterBy'))){
					listOfHeaders = new List<String>{STR_DATE,STR_LIKES,STR_POSTS,STR_REPLIES,STR_SHARES,STR_FAVORITES};
				}else{
					listOfHeaders = new List<String>{STR_DATE,STR_LIKES,STR_FEED_POSTS_CONTENT_COMMENTS,STR_REPLIES,STR_SHARES,STR_FAVORITES};
				}	

		}else if(action == 'getContentEngagementCsv'){
			engagementData = ((AnalyticsWrapper.Engagement) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getContentEngagementCsv',null)).data;
		}
	}
    	List<AnalyticsWrapper.ViewsOverTime> engagementDataToReturn = new List<AnalyticsWrapper.ViewsOverTime>();
    	
    	for(AnalyticsWrapper.ViewsOverTime record : engagementData.likes){
    		AnalyticsWrapper.ViewsOverTime obj = new AnalyticsWrapper.ViewsOverTime(); 
    		obj.label = record.label;
    		obj.likes = record.value;
    		engagementDataToReturn.add(obj);
    	}
    	
    	Integer i = 0;
    	for(AnalyticsWrapper.ViewsOverTime record : engagementData.comments){
    		engagementDataToReturn.get(i).posts = record.value;
    		i++;
    	}
		i=0;
    	for(AnalyticsWrapper.ViewsOverTime record : engagementData.shares){
    		engagementDataToReturn.get(i).shares = record.value;
    		i++;
    	}
		i=0;
    	for(AnalyticsWrapper.ViewsOverTime record : engagementData.replies){
    		engagementDataToReturn.get(i).replies = record.value;
    		i++;
    	}
		i=0;
    	for(AnalyticsWrapper.ViewsOverTime record : engagementData.favorites){
    		engagementDataToReturn.get(i).favorites = record.value;
    		i++;
		}
		if (engagementData.contentViews !=null  && engagementData.contentViews.size()>0){
			i=0;
			for(AnalyticsWrapper.ViewsOverTime record : engagementData.contentViews){
			engagementDataToReturn.get(i).contentViews = record.value;
			i++;
			}
		}

		if (engagementData.uniqueContentViews !=null  && engagementData.uniqueContentViews.size()>0){
			i=0;
			for(AnalyticsWrapper.ViewsOverTime record : engagementData.uniqueContentViews){
			engagementDataToReturn.get(i).uniqueContentViews = record.value;
			i++;
			}
		}
    	
		return engagementDataToReturn;
    }
    
    public List<AnalyticsWrapper.ViewsOverTime> getViewsList(Map<String,Object> mapOfParameters,String action){
    	List<AnalyticsWrapper.ViewsOverTime> viewsList = new List<AnalyticsWrapper.ViewsOverTime>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		viewsList = ((List<AnalyticsWrapper.ViewsOverTime>) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,action,null));
    	}
		return viewsList;
    }
    
     public List<AnalyticsWrapper.ContentInformation> getContentPopularity(Map<String,Object> mapOfParameters){
    	List<AnalyticsWrapper.ContentInformation> contentPopularity = new List<AnalyticsWrapper.ContentInformation>();
		if(SimpplrContext.isExternalAnalyticsEnabled){

    		contentPopularity = ((List<AnalyticsWrapper.ContentInformation>) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getContentPopularity',null));
			
			for(AnalyticsWrapper.ContentInformation contentData : contentPopularity){
				if('BlogPost'.equalsIgnoreCase(contentData.type)){
					contentData.type = LocaleContext.getLabel(UserContext.languageLocaleKey, 'common.blog_post');

				} else if('Event'.equalsIgnoreCase(contentData.type)){
					contentData.type = LocaleContext.getLabel(UserContext.languageLocaleKey, 'common.event');
				
				} else if('Page'.equalsIgnoreCase(contentData.type)){
					contentData.type = LocaleContext.getLabel(UserContext.languageLocaleKey, 'common.page');
			
				} else if('Album'.equalsIgnoreCase(contentData.type)){
					contentData.type = LocaleContext.getLabel(UserContext.languageLocaleKey, 'common.album');
				}
			}

    	}
		return contentPopularity;
	}
	
	public List<AnalyticsWrapper.videoPopularity> getVideoPopularity(Map<String,Object> mapOfParameters){
    	List<AnalyticsWrapper.videoPopularity> videoPopularity = new List<AnalyticsWrapper.videoPopularity>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
			    videoPopularity = ((List<AnalyticsWrapper.videoPopularity>) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getVideoPopularity',null));
			}    	
		return videoPopularity;
	}
	
	public List<AnalyticsWrapper.videoAdoptionCsv> getVideoAdoption(Map<String,Object> mapOfParameters){
    	List<AnalyticsWrapper.videoAdoptionCsv> videoAdoption = new List<AnalyticsWrapper.videoAdoptionCsv>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
			    videoAdoption = ((List<AnalyticsWrapper.videoAdoptionCsv>) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getVideoAdoptionCsv',null));
			}    	
		return videoAdoption;
	}

	public List<AnalyticsWrapper.LabelValueData> getGovernanceList(Map<String,Object> mapOfParameters){
    	List<AnalyticsWrapper.LabelValueData> governanceList = new List<AnalyticsWrapper.LabelValueData>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		governanceList = ((List<AnalyticsWrapper.LabelValueData>) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getGovernanceList',null));
    	}
		return governanceList;
    }
    
     public List<AnalyticsWrapper.ViewsOverTime> getCountViewsList(Map<String,Object> mapOfParameters,String action){
    	List<AnalyticsWrapper.ViewsOverTime> viewsList = new List<AnalyticsWrapper.ViewsOverTime>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		viewsList = ((AnalyticsWrapper.ViewsList) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,action,null)).data;
    	}
		return viewsList;
    }
    
    public List<AnalyticsWrapper.ContentInformation> getContentViewsWhenFilterNull(Map<String,Object> mapOfParameters){
    	List<AnalyticsWrapper.ContentInformation> viewsList = new List<AnalyticsWrapper.ContentInformation>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		viewsList = (List<AnalyticsWrapper.ContentInformation>) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getContentViewsList',null);

            for(AnalyticsWrapper.ContentInformation contentData : viewsList){
				if('BlogPost'.equalsIgnoreCase(contentData.type)){
					contentData.type = LocaleContext.getLabel(UserContext.languageLocaleKey, 'common.blog_post');

				} else if('Event'.equalsIgnoreCase(contentData.type)){
					contentData.type = LocaleContext.getLabel(UserContext.languageLocaleKey, 'common.event');
				
				} else if('Page'.equalsIgnoreCase(contentData.type)){
					contentData.type = LocaleContext.getLabel(UserContext.languageLocaleKey, 'common.page');
			
				} else if('Album'.equalsIgnoreCase(contentData.type)){
					contentData.type = LocaleContext.getLabel(UserContext.languageLocaleKey, 'common.album');
				}
			}

    	}
		return viewsList;
    }
    
    public List<AnalyticsWrapper.PeoplePerformanceData> getPeoplePerformance(Map<String,Object> mapOfParameters){
    	List<AnalyticsWrapper.PeoplePerformanceData> viewsList = new List<AnalyticsWrapper.PeoplePerformanceData>();
		if(SimpplrContext.isExternalAnalyticsEnabled){
    		viewsList = ((AnalyticsWrapper.PeoplePerformanceWrappper) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters,'getPeoplePerformance',null)).data;
    	}
		return viewsList;
    }

    private MustReadHistoryData getMustReadHistory(String contentId, String filter) {
    	MustReadHistoryData mRHObj = new MustReadHistoryData();
		
		List<MustReadHistoryWrapper> mustHistorWrapperList = new List<MustReadHistoryWrapper>();
		PeopleDao peopleDaoObj = new PeopleDao();
		List<Must_Read_Audit__c> mrAuditList = peopleDaoObj.getMustReadAuditList(contentId);
		String mrAuditId;
		String cgId;
		String audienceType;
		if(mrAuditList.isEmpty() == false){
			mrAuditId = mrAuditList[0].id;
			audienceType = mrAuditList[0].Audience_Type__c;
			cgId = mrAuditList[0].Content__r.Site__r.Chatter_group_Id__c;
		}

    	List<People__c> listOfPeople = peopleDaoObj.getMustReadRecordHistory(contentId,null, filter,cgId,mrAuditId, audienceType, null,0);
    	for(People__c peopleObj : listOfPeople) {
    		MustReadHistoryWrapper wrapperObj = new MustReadHistoryWrapper();
    		wrapperObj.name = peopleObj.Full_Name__c;
    		wrapperObj.email =  peopleObj.Email__c;
    		wrapperObj.city =  peopleObj.City__c;
    		wrapperObj.state =  peopleObj.State__c;
    		wrapperObj.country =  peopleObj.Country__c;
    		wrapperObj.department =  peopleObj.Department__c;
    		if(peopleObj.Must_Read_Confirmed_By__r.isEmpty()) {
    			wrapperObj.status = 'Unread';
    			wrapperObj.readDateTime = '';
    		} else {
    			wrapperObj.readDateTime = peopleObj.Must_Read_Confirmed_By__r[0].Confirm_DateTime__c.format('yyyy-MM-dd HH:mm:ss');
    			wrapperObj.status = 'Read';
    		}

			List<String> customFieldValues = new List<String>();
			if(SimpplrContext.isPPCompanyNameDisplay) {
				customFieldValues.add(addFieldValueInDoubleQuotes(peopleObj.Company_Name__c));
			}
			if(SimpplrContext.isPPDivisionDisplay) {
				customFieldValues.add(addFieldValueInDoubleQuotes(peopleObj.Division__c));
			}
			if(SimpplrContext.isPeopleCategoryEnable){
				customFieldValues.add(addFieldValueInDoubleQuotes(peopleObj.People_Category__r.Name__c));
			}
			customFieldValues.add(addFieldValueInDoubleQuotes(peopleObj.Title__c));
			if('Workday'.equalsIgnorecase(SimpplrContext.PDSSourceApplication) && SimpplrContext.isPDSRole){
				customFieldValues.add(addFieldValueInDoubleQuotes(peopleObj.Role__c));
			}
			wrapperObj.mRHCustomFieldValues = customFieldValues;

    		mustHistorWrapperList.add(wrapperObj);
    	}

		mRHObj.mRHCustomFieldNameList = new List<String>();
		
		if(SimpplrContext.isPPCompanyNameDisplay) {
			mRHObj.mRHCustomFieldNameList.add(STR_COMPANY_NAME);
		}
		if(SimpplrContext.isPPDivisionDisplay) {
			mRHObj.mRHCustomFieldNameList.add(STR_DIVISION);
		}
		if(SimpplrContext.isPeopleCategoryEnable){
			mRHObj.mRHCustomFieldNameList.add(SimpplrContext.peopleCategorySingular);
		}
		mRHObj.mRHCustomFieldNameList.add(STR_ANALYTICS_CONTENT_JOB_TITLE);
		if('Workday'.equalsIgnorecase(SimpplrContext.PDSSourceApplication) && SimpplrContext.isPDSRole){
			mRHObj.mRHCustomFieldNameList.add(STR_ROLE);
		}
		
		mRHObj.mRHDataList = mustHistorWrapperList;
    	return mRHObj;
    } 
    
	public List<PeopleListWrapper> getUnassignedSegmentUsers(String profileField) {
		List<PeopleListWrapper> unassignedSegmentUsers =  segmentDaoObj.getUnassignedSegmentUsers(profileField);
		return unassignedSegmentUsers;
    } 
    
    public List<PeopleListWrapper> getSubscriptionMembers(String subscriptionId, String term, Boolean limitToSubsegment) {
		PeopleDao peopleDaoObj = new PeopleDao();
		
		return PeopleListWrapper.peopleListToWrapper(peopleDaoObj.getPeopleBySubscriptionId(subscriptionId, term, null, null, limitToSubsegment));
	}
	
	public List<PeopleListWrapper> getPeopleExpertiseList(String expertiseId, String term) {
		PeopleDao peopleDaoObj = new PeopleDao();
		return PeopleListWrapper.peopleListToWrapper(peopleDaoObj.getPeopleExpertiseList(expertiseId, term, null, null));
	}

	public List<PeopleListWrapper> getAudienceMembers(String audienceId, String term) {
		PeopleDao peopleDaoObj = new PeopleDao();
		
		return PeopleListWrapper.peopleListToWrapper(peopleDaoObj.getPeopleByAudienceId(audienceId, term, null, null));
    }
    
    public List<PeopleListWrapper> getSegmentMembers(String segmentId, String term, Boolean limitToSubsegment) {
		PeopleDao peopleDaoObj = new PeopleDao();
		
		return PeopleListWrapper.peopleListToWrapper(peopleDaoObj.getPeopleBySegmentId(segmentId, term, null, null, limitToSubsegment));
    }

		public List<AnalyticsWrapper.ProfileCompletenessCsvWrapper> getPeopleProfileCompletenessList(Map<String,Object> mapOfParameters){
	    List<AnalyticsWrapper.ProfileCompletenessCsvWrapper> peopleCompletenessList = new List<AnalyticsWrapper.ProfileCompletenessCsvWrapper>();
			if(SimpplrContext.isExternalAnalyticsEnabled){
					peopleCompletenessList = ((List<AnalyticsWrapper.ProfileCompletenessCsvWrapper>) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters, 'getPeopleProfileCompletenessCsvV2', null));
			}

			return peopleCompletenessList;
    }

		public List<AnalyticsWrapper.ContentViewsCsvWrapper> getContentViewsByType(Map<String,Object> mapOfParameters){
	    List<AnalyticsWrapper.ContentViewsCsvWrapper> contentViewsList = new List<AnalyticsWrapper.ContentViewsCsvWrapper>();
			if(SimpplrContext.isExternalAnalyticsEnabled){
					contentViewsList = ((List<AnalyticsWrapper.ContentViewsCsvWrapper>) externalAnalyticsServiceObj.getExternalAnalyticsResults(mapOfParameters, 'getContentViewsByTypeCsv', null));
			}

			return contentViewsList;
    }

	public class MustReadHistoryData {
		public List<String> mRHCustomFieldNameList {get;set;}
		public List<MustReadHistoryWrapper> mRHDataList {get;set;}
	}
    
    public class MustReadHistoryWrapper {
		public String name {get;set;}
		public String status {get;set;}
		public String email {get;set;}
		public String readDateTime {get;set;}
		public String city{set;get;}
		public String state{set;get;}
		public String country{set;get;}
		public String department{set;get;}
		public List<String> mRHCustomFieldValues {get;set;}
    }
		private String getPeopleDataCSVHeader(Boolean isSegmentsEnabled, Boolean isCategoryEnabled, Boolean includeSiteInfo) {
			String returnVal = STR_NAME + ',' + STR_EMAIL + ',' + STR_COMPANY_NAME;
			if(includeSiteinfo){
				returnVal = STR_USER_NAME + ',' + STR_TITLE + ',' + STR_ANALYTICS_SITE_NAME;
			}
			if(isSegmentsEnabled) {
				returnVal += ',' + STR_SEGMENT;
			}
			if(includeSiteinfo){
				returnVal += ',' + STR_ANALYTICS_AUDIENCE_ROLE + ',' + STR_ANALYTICS_SITE_ROLE + ',' + STR_ANALYTICS_CONTENT_DEPT_NAME + ',' + STR_CITY + ',' + STR_STATE + ',' + STR_COUNTRY + ',' + STR_ANALYTICS_CONTENT_PHONE + ',' + STR_EMAIL;
			}else{
				returnVal += ',' + STR_DIVISION + ',' + STR_DEPARTMENT + ',' + STR_CITY + ',' + STR_STATE + ',' + STR_COUNTRY;
			}
			if(isCategoryEnabled) {
				returnVal += ',' + SimpplrContext.peopleCategorySingular;
			}
			returnVal += ',' + STR_COUNT;
			
			return returnVal;
		}

		private List<String> getPeopleDataCSVValueList(List<AnalyticsWrapper.PeoplePerformanceData> peopleData, Boolean isSegmentsEnabled, Boolean isCategoryEnabled) {
			List<String> returnList = new List<String>();
			
			for(AnalyticsWrapper.PeoplePerformanceData peopleWrapperObj: peopleData) {
				String peopleDataStr = '"' + peopleWrapperObj.label.replace('"', '""') + '","' + peopleWrapperObj.email + '","' + peopleWrapperObj.companyName + '"';
				if(isSegmentsEnabled) {
					if(String.isNotBlank(peopleWrapperObj.segment)) {
						peopleDataStr += ',"' + peopleWrapperObj.segment + '"';
					} else {
						peopleDataStr += ',""';
					}
				}
				peopleDataStr += ',"' + peopleWrapperObj.division + '","' + peopleWrapperObj.department + '","' + peopleWrapperObj.city + '","' + peopleWrapperObj.state + '","' + peopleWrapperObj.country + '"';
				
				if(isCategoryEnabled) {
					if(String.isNotBlank(peopleWrapperObj.category)) {
						peopleDataStr += ',"' + peopleWrapperObj.category + '"';
					} else {
						peopleDataStr += ',""';
					}
				}
				peopleDataStr += ',"' + peopleWrapperObj.value + '"';
				
				peopleDataStr = peopleDataStr.replaceAll('"null"', '""');

				returnList.add(peopleDataStr);
			}

			return returnList;
		}
		public String getContentTitle(String contentId) {
			String title = null;
			List<Simpplr_Content__c> contObjList = [Select id, title__c From Simpplr_Content__c where id =: contentId WITH SECURITY_ENFORCED LIMIT 1];
			if(!contObjList.isEmpty()){
				title = contObjList[0].title__c;
			}	
			return title;
		}
	/**
	 * @description This method is used to set values list from people data 
	 * @param peopleData
	 * @param extraColumnChecksMap
	 * @return  `List<String>`
	*/	
	private List<String> getPeopleDataCSVForSiteValueList(List<AnalyticsWrapper.PeoplePerformanceData> peopleData, Boolean isSegmentsEnabled, Boolean isCategoryEnabled) {
		List<String> returnList = new List<String>();
		
		for(AnalyticsWrapper.PeoplePerformanceData peopleWrapperObj: peopleData) {
			String peopleDataStr = '"' + peopleWrapperObj.label.replace('"', '""') + '","' + peopleWrapperObj.title + '","' + peopleWrapperObj.siteName + '"';
			if(isSegmentsEnabled) {
				if(String.isNotBlank(peopleWrapperObj.segment)) {
					peopleDataStr += ',"' + peopleWrapperObj.segment + '"';
				} else {
					peopleDataStr += ',""';
				}
			}
			peopleDataStr += ',"' + peopleWrapperObj.role + '","' + peopleWrapperObj.siteRole + '","' + peopleWrapperObj.department + '","' + peopleWrapperObj.city + '","' + peopleWrapperObj.state + '","' + peopleWrapperObj.country + '","' + peopleWrapperObj.phone + '","' + peopleWrapperObj.email + '"';
			
			if(isCategoryEnabled) {
				if(String.isNotBlank(peopleWrapperObj.category)) {
					peopleDataStr += ',"' + peopleWrapperObj.category + '"';
				} else {
					peopleDataStr += ',""';
				}
			}
			peopleDataStr += ',"' + peopleWrapperObj.value + '"';
			peopleDataStr = peopleDataStr.replaceAll('"null"', '""');
			returnList.add(peopleDataStr);
		}

		return returnList;
	}
}