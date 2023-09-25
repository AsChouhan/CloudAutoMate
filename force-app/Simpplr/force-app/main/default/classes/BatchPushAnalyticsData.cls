public with sharing class BatchPushAnalyticsData implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.stateful {
    
    private static final List<Integer> SYNC_STATUS_SENT = new List<Integer> {1,3,5};
    private String recordType;
    private String query;
    private Date dateObj;
    private Boolean runNextBatchInSequence;
    public Date recordDate;
    private Exception exceptionDetailsObj;
    
    private DateTime startDateTime;
    private DateTime endDateTime;
    
    public BatchPushAnalyticsData(Date recordDate) {
        this.recordDate = recordDate;
    }

    public BatchPushAnalyticsData(String recordType, Boolean runNextBatchInSequence) {
        this.recordType = recordType;
        this.runNextBatchInSequence = runNextBatchInSequence;
    }
    
    public BatchPushAnalyticsData(String recordType, DateTime startDateTime, DateTime endDateTime) {
    		this.recordType = recordType;
    		this.startDateTime =  startDateTime;
    		this.endDateTime = endDateTime;
    		this.runNextBatchInSequence = false;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
    	String parentType;
    	switch on recordType {
    		
			when 'site'{
				query = ' select Id, Site_Type__c, Name, Is_Active__c, Is_Featured__c, Is_Newsletter_Allowed__c, Is_Alert_Enabled__c, Is_Must_Read_Enabled__c, Has_Albums__c, Has_Events__c, Has_Pages__c, Chatter_Group_Id__c, Cover_Content_Document__c, ' +
						' Allow_File_Upload_App_Permission__c, Title_Content_Document__c, Site_Category__c, Site_Category__r.Name__c, Show_In_Simpplr__c, landing_page__c, Origin__c, CreatedDate,File_Storage_Source__c, Layout__c, Is_Onboarding_Enabled__c from Simpplr_Site__c';
			}
				when 'content' {
				query = 'select Id, Site__c, Type__c, Title__c, Is_Deleted__c, primary_author__c, First_Publish_DateTime__c, Publish_Start_DateTime__c, Publish_End_DateTime__c, Last_Validated_DateTime__c, Status__c, Content_Sub_Type__c, Album_Video_Count__c, Album_Image_Count__c, Version__c,Event_RSVP_By_DateTime__c,Event_RSVP_Allowed__c, Read_Time__c, Content_Onboarding_Status__c, Onboarding_Added_Date__c from Simpplr_Content__c  ';
			}
			when 'topic' {
			query = 'select Id, Name from Topic ';
			if(SimpplrContext.isCommunitiesEnabled){
						query += ' Where NetworkId = null';
					} 
			}
			when 'people' {
				query = ' Select  People__c, People__r.Full_Name__c, People__r.Title__c, People__r.Company_Name__c, People__r.Department__c, People__r.Division__c, People__r.City__c, People__r.Street__c, People__r.State__c, People__r.Country__c, People__r.Postal_Code__c, ' + 
             		' People__r.Can_Access_Analytics__c, People__r.Can_Control_Dashboard__c, People__r.Can_Send_Alert__c, People__r.Can_Send_Newsletter__c, People__r.Segment__c, People__r.People_Category__c,people__r.Mobile_Token_Android__c,people__r.Mobile_Token_iOS__c,  ' +
             		' People__r.App_Moderation_Permission__c, People__r.Unlisted_Site_Moderation_Permission__c, People__r.Is_Influencer__c, People__r.Is_Campaign_Manager__c, People__r.People_Category__r.Name__c, People__r.Segment__r.Name__c, ' +
             		' People__r.Profile_Photo_Fill_DateTime__c, People__r.Cover_Photo_Fill_DateTime__c, People__r.AboutMe_Fill_DateTime__c, People__r.Phone_Fill_DateTime__c, People__r.Mobile_Fill_DateTime__c, People__r.birthdate_fill_datetime__c,' +
             		' People__r.First_Login_DateTime__c, People__r.Last_Edited_DateTime__c, People__r.Last_Sync_DateTime__c, People__r.User__c, People__r.User__r.IsActive, People__r.User__r.LanguageLocaleKey, People__r.Email__c,' + 
					' People__r.Custom_Field_1__c, People__r.Custom_Field_2__c, People__r.Custom_Field_3__c, People__r.Custom_Field_4__c, People__r.Custom_Field_5__c, ' +
					' People__r.Custom_Field_6__c, People__r.Custom_Field_7__c, People__r.Custom_Field_8__c, People__r.Custom_Field_9__c, People__r.Custom_Field_10__c, ' +
					' People__r.Custom_Field_11__c, People__r.Custom_Field_12__c, People__r.Custom_Field_13__c, People__r.Custom_Field_14__c, People__r.Custom_Field_15__c, ' +
					' People__r.Custom_Field_16__c, People__r.Custom_Field_17__c, People__r.Custom_Field_18__c, People__r.Custom_Field_19__c, People__r.Custom_Field_20__c, ' +
					' People__r.Custom_Field_21__c, People__r.Custom_Field_22__c, People__r.Custom_Field_23__c, People__r.Custom_Field_24__c, People__r.Custom_Field_25__c, ' +
					' People__r.Is_Protected_Author_Allowlisted__c, People__r.Is_Protected_Author__c, People__r.createddate, People__r.Has_simpplr_license__c, People__r.Has_Read_All_Onboarding_Content__c, People__r.User_Id__c, ' +
             		' Allow_Simpplr_Emails__c, Email_Comments_After_Me__c, Email_Comments_On_My_Post__c, Email_Comments_On_Post_I_Like__c, Email_Endorses_Me__c, Email_Follows_Me__c, Email_Like_My_Post_Or_Comment__c, Email_Mentions_Me__c, Email_My_Content_Like__c, '+
             		' Email_My_Content_Post__c, Email_My_Content_Share__c, Email_Posts_On_My_Profile__c, Email_Shares_My_Post__c, Receive_Content_Moderation_Notifications__c, Email_Content_Digest_Frequency__c, Email_Onboarding_Frequency__c,  '+
             		' Email_My_Content_Approved__c, Email_My_Content_Rejected__c, Email_Notification_Digest_Frequency__c, Email_Content_Submitted_for_Moderation__c, Email_Private_Site_Membership_Requests__c, Email_Digest_Frequency__c, '+
					' Email_PrivateSiteMembership_Response__c, Email_Content_Submission_Response__c, Actionable_Notification_Frequency__c, Content_Digest_Frequency__c, Default_Site_Digest_Frequency__c, Notification_Digest_Frequency__c, Email_Content_Useful__c, User__c, Receive_Content_Useful_Notifications__c, Email_Event_Invite_More__c,  Email_Updates_Content_Sites_I_Follow__c, '+ 
					' Receive_Content_Update_Notifications__c,  Email_Made_Site_Manager_Or_Owner__c, Email_Content_Marked_As_Must_Read__c, Email_My_Content_Like_Or_Share__c, Email_Posts_To_Me__c, Native_Mob_Content_Submit_Moderation__c, Native_Mob_Private_Site_Membership_Req__c, Native_Mob_Update_Content_Site_I_Follow__c, Native_Mobile_Event_Invite_More__c, Native_Mobile_Follows_Me__c, Native_Mobile_My_Content_Like_Or_Share__c, Email_Site_Analytics_Frequency__c,  '+
					' Native_Mob_Comments_On_My_Post__c, Native_Mob_Like_My_Post_Or_Comment__c, Native_Mob_My_Content_Post__c, Native_Mob_Posts_To_Me__c, Email_Subscription_Moderation__c, People__r.User__r.Show_Simpplr__c, People__r.External_Photo_URL__c, People__r.User_Last_Deactivated__c, '+
					' Email_My_Content_Validation_Expired__c, Email_My_Content_Validation_Required__c, Box_Access_Token__c,Layout__c, Email_Alerts__c, SMS_Alerts__c, SMS_Must_Reads__c, SMS_Content_Promotion_Message__c, Native_Mobile_Alerts__c, Native_Mob_Content_Marked_As_Must_Read__c,Email_Updates_Event_I_RSVP_Yes__c,Email_Updates_Event_I_Author_Organize__c, Email_Subscription_Request__c, People__r.Enable_Org_Level_Onboarding__c, People__r.User__r.SmallPhotoURL ' +        		        		
             		' from People_Preference__c where People__r.User__r.UserType=\'Standard\' ';
			}
			when 'analytics_adoption' {
				query = 'select Id, Date__c, people__r.user_hash__c, people__c, Is_Contributor__c, Is_Participant__c, Is_Observer__c, Is_Active__c,Has_Used_Hybrid_Android_App__c,' 
					+ ' Has_Used_Hybrid_IOS_App__c, Has_Used_Native_Android_App__c, Has_Used_Native_IOS_App__c, Total_Logins__c, Desktop__c, ' 
					+ ' DesktopApp__c, Mobile__c, MobileApp__c, Page_Views__c, Content_Views__c, Sync_Status__c ' 
					+ ' from Analytics_Adoption__c where Sync_Status__c !=:SYNC_STATUS_SENT ';
				
			}
			when 'analytics_content_count'{
				query = ' select Id, Albums__c, Blogs__c, Bookmarks__c, Date__c,Events__c,Likes__c, Pages__c,' +
						' Posts__c, Replies__c,Shares__c, Site__c, Views__c, Sync_Status__c from Analytics_Content_Count__c where Sync_Status__c !=:SYNC_STATUS_SENT ';
						
			}
			when 'analytics_feed_count' {
				query = ' select Id, Date__c, Likes__c, Posts__c, Replies__c, Shares__c, Site__c, Sync_Status__c ' + 
							' from Analytics_Feed_Count__c where Sync_Status__c !=:SYNC_STATUS_SENT ';
				
			}
			when 'analytics_login' {
				query = ' select Id, Average_logins_per_user__c, Date__c, Desktop__c, DesktopApp__c, Mobile__c, MobileApp__c, Hybrid_Android_App__c, Hybrid_IOS_App__c, Native_Android_App__c, Native_IOS_App__c,' +
						' Page_Views__c, Total_Active_Salesforce_User__c, Total_Logins__c, Total_Simpplr_Users__c, Unique_logins__c, Users_logged_in__c, Likes__c, ' +
						' Posts__c, Replies__c, Shares__c, Content_Views__c, Sync_Status__c from Analytics_Login__c where Sync_Status__c !=:SYNC_STATUS_SENT ';
						
			}
			when 'analytics_page_view' {
				query = ' select Id, Date__c, Desktop__c, DesktopApp__c, Mobile__c, MobileApp__c, Sync_Status__c ' + 
							' from Analytics_PageView__c where Sync_Status__c !=:SYNC_STATUS_SENT ';
				
			}
			when 'analytics_search_result_select' {
				query = ' select Id, Content__c, Context__c, Created_By_People__c, File_Id__c, Is_External__c, Item_Type__c, People__c, Position__c, Score__c, ' +
						' Page_Position__c,Section__c, Site__c, Site_Context__c, Subsection__c, Term__c, CreatedDate, Sync_Status__c ' + 
						' from Analytics_Search_Result_Select__c where Sync_Status__c !=:SYNC_STATUS_SENT ';
						
			}
			when 'analytics_social_campaign' {
				query = ' select Id, Date__c, Likes__c, Shares__c, Social_Campaign_Share__c, Sync_Status__c, Social_Campaign_Share__r.Network_Shared__c,  Social_Campaign_Share__r.Social_Campaign__c ' + 
							' from Analytics_Social_Campaign__c where Sync_Status__c !=:SYNC_STATUS_SENT ';
				
			}
			when 'analytics_top_content' {
				query = ' select Id, Bookmarks__c, Content__c, Date__c, Is_Published__c, Likes__c, Popularity_Score__c, Posts__c, Replies__c,' +
						' Shares__c, Unuseful__c, Useful__c, Views__c, Content__r.Site__c, Content__r.Type__c, Sync_Status__c, is_validated__c, is_validation_expired__c, is_validation_pending__c ' + 
						' from Analytics_Top_Content__c where Sync_Status__c !=:SYNC_STATUS_SENT ';
						
			}
			when 'analytics_top_people' {
				query = 'select Id, Bookmarks_Made__c, Bookmarks_Received__c, Content_Published__c, Date__c, Feed_Mentions__c, Followers__c, Following__c,'
						+' Likes_Made__c, Likes_Received__c, People__c, Posts__c, Replies_Made__c, Replies_Received__c, Shares_Made__c, Shares_Received__c,'
						+' Views_Received__c, Sync_Status__c from Analytics_Top_People__c where Sync_Status__c !=:SYNC_STATUS_SENT ';
						
			}
			when 'analytics_top_search' {
				query = ' select Id, Date__c, Search_Results_Count__c, Search_Text__c, Search_Type__c, Site__c, Sync_Status__c ' + 
							' from Analytics_Top_Search__c where Sync_Status__c !=:SYNC_STATUS_SENT ';
				
			}
			when 'analytics_top_site' {
				query = ' select Id, Content_Published__c, Date__c, Likes__c, Members__c, Popularity_Score__c, Posts__c, Replies__c,Bookmarks__c, Shares__c,' +
							' Site__c, Views__c, Sync_Status__c,Content_Hybrid_App_Views__c,Content_Mobile_Browser_Views__c,Content_Web_Browser_Views__c,' + 
							'Dashboard_Hybrid_App_Views__c,Dashboard_Mobile_Browser_Views__c,Dashboard_Web_Browser_Views__c '+
							' from Analytics_Top_Site__c where Sync_Status__c !=:SYNC_STATUS_SENT ';
				
			}
			when 'analytics_top_topic' {
				query = 'select Id, Date__c, Endorsements__c, Expertise__c, Followers__c, Topic_Id__c, Contents__c, Posts__c, Comments__c, '
							+' Topic_Name__c, Views__c, Sync_Status__c from Analytics_Top_Topic__c where Sync_Status__c !=:SYNC_STATUS_SENT ';
			}
			when 'carousel_content' {
				query = ' select Id, simpplr_content__c, site__c, social_campaign__c, is_deleted__c, item_type__c, order__c, ' + 
						' createddate, created_by_People__c, lastmodifieddate, deleted_by_people__c, segment__c from Carousel_Content__c ';
						
				List<Package_Upgrade_History__c> uhList=[select id, createddate from Package_Upgrade_History__c order by createddate desc limit 1];
				DateTime cutOffTime = DateTime.now().addDays(-3);
				if(!uhList.isEmpty() && uhList[0].createddate < cutOffTime) {
					query += ' Where LastModifiedDate >= Yesterday ';    			
				}
			}
			when 'tiles_config' {
				query = 'select Id, Is_Deleted__c, Layout_Column__c, Location__c, Order__c, People__c, Segment__c, Site__c, Type__c, ' +
						' Variant__c, Sync_Status__c, CreatedDate, lastmodifieddate from Tiles_Config__c where Sync_Status__c !=:SYNC_STATUS_SENT ';
			}
			when 'site_role' {
				query = 'select Id, Is_Content_Manager__c, Is_Deleted__c, Is_Manager__c, People__c, Site__c, ' +
						'Is_Member__c, Unique_Id1__c, User__c, ' +
						' Sync_Status__c, CreatedDate, lastmodifieddate from Site_Role__c where Sync_Status__c !=:SYNC_STATUS_SENT ';
			}
			when 'content_audit_trail' {
				query = 'select Id, Action_DateTime__c, Content__c, Comment__c, Action_By__c, Dismiss_By__c, New_Author__c, Old_Author__c, New_Site__c, Old_Site__c, Action__c, ' +
						' Sync_Status__c, CreatedDate, lastmodifieddate from Content_Audit_Trail__c where Sync_Status__c !=:SYNC_STATUS_SENT ';
			}

			when 'app_config' {
				query = 'SELECT ad_integration_enabled__c, allow_comments__c, allow_file_share_with_public_link__c, allow_file_upload__c, Allow_File_Upload_Site_Managers__c, allow_follow__c, allow_only_influencers_to_create_blog__c, ' +
						' allow_public_contribution__c, allow_site_add__c, allowed_features__c, app_dashboard_mode__c, app_download_info_url__c, app_home_dashboard_tile_ids__c, app_integrations_enabled__c, ' +
						' app_languages_enabled__c, app_name__c, app_page_title__c, app_start_help_url__c, at_bookmark_enabled__c, ' + 
						' at_collaborationgroup_enabled__c, at_collaborationgroupmember_enabled__c, at_contentdocument_enabled__c, at_contentdocumentlink_enabled__c, at_contentversion_enabled__c, ' + 
						' at_feed_itemenabled__c, at_feedcomment_enabled__c, at_file_enabled__c, at_folder_enabled__c, at_like_enabled__c, at_people_category_enabled__c, at_people_enabled__c, ' + 
						' at_people_preference_enabled__c, at_share_enabled__c, at_simpplr_content_enabled__c, at_simpplr_site_enabled__c, at_simpplr_social_analytics_enabled__c, at_user_enabled__c, ' + 
						' at_user_trigger_type__c, audit_trail_enabled__c, auto_convert_chattergroup_to_site__c, auto_provisioning_process_enabled__c, aws_file_upload_enabled__c, ' + 
						' box_integration_enabled__c, box_user_id__c, branding_css_class__c, branding_css__c, branding_custom_font_css__c, branding_json__c, branding_logo__c, calendar_app_enabled__c, ' + 
						' calendar_google_enabled__c, calendar_office365_enabled__c, calendar_outlook_web_enabled__c, carousel_layout__c, carousel_speed__c, ' + 
						' chatter_email_off_profiles__c, communities_basepath__c, communities_enabled__c, content_history_enabled__c, custom_links_json__c, default_page_size__c, ' + 
						' embedly_enabled__c, employee_advocacy_enabled__c, expertise_controlled_by__c, external_analytics_enabled__c, external_analytics_url__c, external_search_active__c, ' + 
						' external_search_app_connected__c, external_search_base_url__c, external_search_connected_by_people__c, external_search_enabled_by_people__c, external_search_enabled__c, ' + 
						' external_search_file_connected__c, external_search_provider__c, favicons_folder__c, feed_enabled__c, feed_page_size__c, ' + 
						' feed_refresh_interval__c, feed_rich_text_enabled__c, feed_show_track_change_posts__c, feedback_share_with_simpplr__c, feedback_to_emails__c, file_storage_setting_level__c, ' + 
						' file_storage_source__c, first_visit_welcome_url__c, flow_external_search_enabled__c, ga_demography_interests__c, ga_enabled__c, ' + 
						' ga_enhanced_link_attribution__c, go_to_salesforce_enabled__c, golive_chatter_email_setup__c, Feed_Placeholder__c, ' +
						' home_carousel_enabled__c, last_edited_datetime__c, last_major_upgrade_datetime__c, layout__c, ' +
						' lightning_ux_tab_open_setting__c, login_timeout__c, logout_custom_page_enabled__c, logout_custom_page_url__c, microsoft_teams_integration_enabled__c, ' +
						' mobile_app_bundle_id_android__c, mobile_app_bundle_id_ios__c, mobile_app_deeplinking_enabled__c, '+
						' mute_content_post_in_sitefeed_enabled__c, newsletter_tracker_last_data_id__c, notification_refresh_interval__c, nps_survey_days_to_end__c, nps_survey_enabled__c, ' + 
						' okta_enabled__c, okta_link__c, okta_people_name_format__c, onelogin_enabled__c, onelogin_link__c, org_chart_enabled__c, package_name__c, package_version__c, pds_about_me__c, ' + 
						' pds_birth_date__c, pds_city__c, pds_community_nickname__c, pds_company_name__c, pds_country__c, pds_department__c, pds_division__c, pds_email__c, pds_employee_number__c, ' + 
						' pds_enable_formatting__c, pds_extension__c, pds_fax__c, pds_first_name__c, pds_first_pull_sync_all_fields__c, pds_joining_date__c, pds_last_name__c, pds_manager_id__c, ' + 
						' pds_max_sync_attempts__c, pds_middle_name__c, pds_mobile_phone__c, pds_phone__c, pds_photo__c, pds_postal_code__c, pds_role__c, pds_source_application__c, pds_state__c, ' + 
						' pds_street__c, pds_manager_unique_identifier_key__c,pds_unique_identifier__c, pds_title__c, pds_workday_enabled__c, people_category_enabled__c, people_catgeory_plural__c, people_catgeory_singular__c, pp_about_me_display__c, ' + 
						' pp_about_me_editable__c, pp_birthdate_display__c, pp_birthdate_editable__c, pp_category_display__c, pp_category_editable__c, pp_city_display__c, pp_city_editable__c, ' + 
						' pp_company_name_display__c, pp_company_name_editable__c, pp_country_display__c, pp_country_editable__c, pp_department_display__c, pp_department_editable__c, ' + 
						' pp_departments_count__c, pp_division_display__c, pp_division_editable__c, pp_employees_count__c, pp_extension_display__c, pp_extension_editable__c, pp_firstname_display__c, ' + 
						' pp_firstname_editable__c, pp_joiningdate_display__c, pp_joiningdate_editable__c, pp_lastname_display__c, pp_lastname_editable__c, pp_locations_count__c, pp_manager_display__c, ' + 
						' pp_manager_editable__c, pp_mobilephone_display__c, pp_mobilephone_editable__c, pp_phone_display__c, pp_phone_editable__c, pp_state_display__c, pp_state_editable__c, ' + 
						' pp_street_display__c, pp_street_editable__c, pp_timezone_display__c, pp_timezone_editable__c, pp_title_display__c, pp_title_editable__c, pp_user_custom_fields__c, ' + 
						' pp_video_display__c, pp_video_editable__c, pp_video_provider__c, search_content_allowed_field__c, search_people_allowed_field__c, sed_daily_digest_size__c, ' + 
						' sed_from_email__c, sed_weekly_digest_size__c, Segment_Apps_Links_Enabled__c, segment_branding_enabled__c, segment_column_name__c, segment_enabled__c, show_hidden_folders__c, show_logo_on_mobile__c, ' + 
						' simpplr_desktop_notification_allowed__c, simpplr_emails_allowed__c, simpplr_mobile_notification_allowed__c, simpplr_setup_complete__c, simpplr_top_stories_emails_allowed__c, ' + 
						' site_carousel_enabled__c, site_dashboard_mode__c, slack_integration_enabled__c, slack_link_unfurl_enabled__c, social_campaign_policy_url__c, social_tiles_enabled__c, ' + 
						' sp_integration_enabled__c, sso_custom_json__c, sso_provider__c, start_of_week__c, use_connectapi_for_feed_update_check__c, vbrick_enabled__c, Validation_Period__c, Content_Governance_Enabled__c, ' + 
						' Enterprise_Search_Enabled__c, Enterprise_Search_Provider__c, Enterprise_Search_Url__c, Feed_Mode__c, Mobile_Promotion_Enabled__c, PDS_UKG_Pro_Enabled__c, Data_Key__c, Site_Level_Onboarding__c,  ' +
						' CreatedDate, LastModifiedDate,Expertise_Create_Controlled_By__c,PDS_Department_Key__c, PDS_User_Division_Key__c, PDS_Birth_Date_Key__c, SP_Upgrade_Status__c, Branded_App_Distribution_Enabled__c from App_Config__c ';
			}			
			when 'user_provisioning_config' {
				query = 'SELECT Id, about__c, birthdate__c, birthdate_Field__c, city__c, company_Name__c, company_Name_Field__c, country__c, create_New_Users__c, deactive_User__c, department__c, division__c, employee_Number__c, fax__c,'+
				 		' fedrationId__c, firstname__c, joining_Date__c, joining_Date_Field__c, language__c, language_Type__c, lastname__c, locale__c, locale_Type__c, manager__c, manager_Unique_Identifier__c, mobilePhone__c, phone__c, '+
						' phoneExtension__c, postalCode__c, profile__c, profile_Type__c, provisioning_Source__c, query_Filter__c, send_Emails__c, state__c, street__c, timezone__c, timezoneSidKey__c, unique_Identifier__c,user_Email__c, Name, '+
						' user_Title__c, username__c, username_Suffix__c, createddate, lastmodifieddate from User_Provisioning_Config__c';
				
						
			}
			when 'app_default' {
				query = 'SELECT Id, Data__c,Sync_Status__c, Last_Modified_By_People__c, Layout__c, Name, OverwriteBatchInProgress__c, '
						+ ' People__c, Segment__c,type__c '	
						+ ' FROM app_default__c where Sync_Status__c !=:SYNC_STATUS_SENT ';	
		}

			when 'social_analytics' {
					query = 'Select Id, User__c, Page_Name__c, Page_Group__c, Page_Analytics_Category__c, UTM_Source__c, UTM_Medium__c, UTM_Content__c, UTM_TERM__c, Search_Results_Count__c,Search_Results_Summary__c, Origin__c, Page_URL__c, Interaction__c, Simpplr_Site__c, Content__c, People_Profile__c,'
					+' People__c, File_Id__c, User_Agent__c, Topic_ID__c, Search_Text__c, Origin_Mobile_Browser__c, Origin_Mobile_App__c, Origin_Desktop_App__c, Origin_Native_Mobile_App__c,'
					+' Mailer__c, Login_History_Id__c, Referer__c, Sync_Status__c, createddate from Simpplr_Social_Analytics__c where Sync_Status__c !=:SYNC_STATUS_SENT ';
					
					if(startDateTime == null) {
						query += ' And CreatedDate = YESTERDAY';
						
					} else {
						query += ' And CreatedDate >=: startDateTime And CreatedDate <=: endDateTime ';
						
					}
			
			}

			when 'segment' {
					query = 'SELECT Id, Name__c, Branding_JSON__c, branding_css_class__c, branding_css__c, branding_custom_font_css__c, '
							+ ' branding_logo__c, favicons_folder__c, segment_attribute_value_json__c, '
							+ ' branding_package_version__c, carousel_layout__c, '
							+ ' Custom_Links_JSON__c, SSO_Provider__c, SSO_Custom_JSON__c '
							+ ' FROM Segment__c ';
					
			}
			
			when 'segment_site' {
					query = 'SELECT Id, Site__c, Is_Featured__c, Segment__c, Order__c '
					+' FROM Segment_Site__c';
					
			}

			when 'feed_item_people' {
				query = 'SELECT Id, body, CommentCount, HasContent, parent.type,   ' +
						'  LikeCount, LinkUrl, ParentId, Title, Type, isDeleted, createdById, createdDate ' +
						' FROM FeedItem WHERE CreatedDate = YESTERDAY AND parent.type=\'User\'';
			}

			when 'feed_item_site' {
				query = 'SELECT Id, body, CommentCount, HasContent, parent.type,   ' +
						'  LikeCount, LinkUrl, ParentId, Title, Type, isDeleted, createdById, createdDate ' +
						' FROM FeedItem WHERE CreatedDate = YESTERDAY AND parent.type=\'CollaborationGroup\'';
			}

			when 'feed_item_content' {
				parentType = PageContext.namespacePrefix + 'Simpplr_Content__c';
				query = 'SELECT Id, body, CommentCount, HasContent, parent.type,   ' +
						'  LikeCount, LinkUrl, ParentId, Title, Type, isDeleted, createdById, createdDate ' +
						' FROM FeedItem WHERE CreatedDate = YESTERDAY AND parent.type=:parentType ';
			}

			when 'feed_comment' {
				query = 'SELECT Id, CommentBody, CommentType, FeedItemId, InsertedById, CreatedById, ' +
						' Status, ParentId, RelatedRecordId, createddate, isDeleted ' +
						' FROM FeedComment WHERE CreatedDate = YESTERDAY'; 
			}

			when 'feed_poll_choice' {
				query = 'SELECT Id, position, choiceBody, feeditemId ' +
						' FROM feedPollChoice WHERE CreatedDate = YESTERDAY';
			}

			when 'audience' {
				query = 'SELECT Segment__c,Sync_Status__c, Audience_Member_Count__c, Audience_Rule_Json__c,' +
				        'Has_City_Condition__c, Has_Company_Name_Condition__c, Has_Country_Condition__c,' +
						'Has_Department_Condition__c, Has_Division_Condition__c, Has_People_Category_Condition__c, Has_State_Condition__c, ' +
						'Has_Title_Condition__c  ' +
						'FROM Audience__c where Sync_Status__c !=:SYNC_STATUS_SENT ';
			}
			when 'subscription' {
				query = 'SELECT Action_Type__c,Sync_Status__c, Created_By_People__c, Modified_By_People__c,' +
				        'Recipient__c, Audience__c, Status__c, Type__c ' +
						'FROM Subscription__c where Sync_Status__c !=:SYNC_STATUS_SENT ';
			}

			when 'subscriptionentity' {
				query = 'SELECT Action_By__c,Sync_Status__c, Action_Comment__c, Action_On__c, ' +
				        'Processing_Required__c, Subscription__c, People__c, Site__c,Status__c ' +
						'FROM Subscription_Entity__c where Sync_Status__c !=:SYNC_STATUS_SENT ';
			}
			when 'people_expertise' {
				query = 'SELECT id,Endorser__c,People_Expertise__r.Is_Self_Endorsed__c,People_Expertise__r.is_self_hidden__c,People_Expertise__r.People__c,' +
				        'People_Expertise__r.Expertise__r.name,People_Expertise__r.Expertise__r.Display_Name__c,Sync_Status__c FROM People_Expertise_Detail__c ' +
						'WHERE Sync_Status__c!=:SYNC_STATUS_SENT ' ;
					
			}
			when 'analytics_file' {
				query = 'SELECT Action__c,Sync_Status__c,Context__c,CreatedById,CreatedDate,External_Url__c,File_Extension__c,File_Id__c,File_Url__c,Id,Is_Bookmarked__c, '+
						'Is_New__c,Name,Owner_Id__c,Provider__c,Site_Id__c,Size__c,Source__c,Title__c,Type__c FROM Analytics_File__c ' +
						'WHERE Sync_Status__c!=:SYNC_STATUS_SENT ' ;
					
			}

			when 'file' {
				query = 'SELECT Allow_Comments__c,Author__c,Content_Document__c,Content_Name__c,Content_Version__c,CreatedById,CreatedDate,Description__c,Downloads__c, '+
						'Duration__c,External_Id__c,Feed_Comment__c,Feed_Item__c,FileInfo_Last_Updated_DateTime__c,Folder__c,Id,IsDeleted,Is_Deleted__c,Is_Title_Image__c, '+
						'LastModifiedById,LastModifiedDate,Likes__c,Location__c,Metadata__c,MIME_Type__c,Name,Order__c,OwnerId,Repository__c,Shares__c,Simpplr_Content__c,Site__c, '+
						'Size__c,Subscribers__c,Sync_Status__c,SystemModstamp,Text__c,Thumbnail_URL__c,Thumbnail__c,Title_Image_Type__c,Title__c,Url__c,Video_Provider__c,Views__c, '+
						' SP_Instance_Id__c FROM File__c ' +
						'WHERE Sync_Status__c!=:SYNC_STATUS_SENT ' ;
					
			}
			when 'folder' {
				query = 'SELECT Box_Collaboration_Id__c,Drive_Type__c,CreatedById,CreatedDate,EFS_Drive_Id__c,EFS_Read_Collaboration_Id__c,EFS_Read_Write_Collaboration_Id__c,EFS_Search_Collaboration_Id__c, '+
						'EFS_Shared_Folder_Id__c,External_Folder_Id__c,Id,IsDeleted,Is_Deleted__c,Is_External_System_Folder__c,Is_Hidden__c,Is_System_Folder__c,LastModifiedById,LastModifiedDate, '+
						'Linked_Folder_Owner__c,Name,Name__c,OwnerId,Parent_Folder__c,Path__c,People__c,Permissions__c,Site__c,Sync_Status__c,SystemModstamp,Type__c, SP_Instance_Id__c FROM Folder__c '+
						'WHERE Sync_Status__c!=:SYNC_STATUS_SENT ' ;
					
			}
			
			when 'content_interaction' {
				query = 'SELECT Sync_Status__c, Scroll_Depth__c, Is_Read__c, View_Count__c, Unique_Key__c, People__c, Content__c, LastActivityDate, SystemModstamp, LastModifiedById, '+
						'LastModifiedDate, CreatedById, CreatedDate, Name, IsDeleted, Id FROM Content_Interaction__c '+
						'WHERE Sync_Status__c!=:SYNC_STATUS_SENT AND Sync_Status__c!=null'  ;
					
			}
			
			when 'likes' {
				query = 'SELECT People__c, Like_Receiver__c, Is_Deleted__c, File__c, Feed_Item_Id__c, Feed_Item_Comment_Id__c, '+
						'External_File_Id__c, Content__c, Content__r.site__c, CreatedDate, Name, IsDeleted, Id, OwnerId, Sync_Status__c FROM Like__c '+
						'WHERE Sync_Status__c!=:SYNC_STATUS_SENT'  ;
					
			}
			
			when 'bookmark' {
				query = 'SELECT Type__c, Simpplr_Site__c, Simpplr_Content__c, People__c, Is_Deleted__c, Feed_Item_Id__c,  '+
						'External_File_Id__c, Bookmark_Receiver__c, CreatedDate, Name, IsDeleted, OwnerId, Id, Sync_Status__c FROM Bookmark__c '+
						'WHERE Sync_Status__c!=:SYNC_STATUS_SENT AND Sync_Status__c!=null'  ;
					
			}
			
			when 'share' {
				query = 'SELECT Social_Campaign__c, Share_Receiver__c, People__c, Is_Deleted__c, Feed_Item_Id__c, External_File_Id__c, '+
						'Content__c, Content__r.site__c, CreatedDate, Name, IsDeleted, OwnerId, Id, Sync_Status__c FROM Share__c '+
						'WHERE Sync_Status__c!=:SYNC_STATUS_SENT'  ;
					
			}


    	}

    	return Database.getQueryLocator(query);
	}
    
   	public void execute(Database.BatchableContext BC, List<sObject> listOfsObject) {
        
		try{
			PushAnalyticsDataHelper analyticsHandler = new PushAnalyticsDataHelper();
	        switch on recordType {
			
				when 'site' {
					analyticsHandler.sendSiteListToAWS(listOfsObject);
				}
				
				when 'content' {
					analyticsHandler.sendContentListToAWS(listOfsObject);
				}
				
				when 'people' {
						analyticsHandler.sendPeopleListToAWS(listOfsObject);
				}    		
				
				when 'topic' {
						analyticsHandler.sendTopicListToAWS(listOfsObject);
				}
				when 'people_expertise' {
					analyticsHandler.sendPeopleExpertiseDataToAWS(listOfsObject);
				}
				
				when 'analytics_adoption' {
					analyticsHandler.sendAnalyticsAdoptionListToAWS(listOfsObject);
				}
				
				when 'analytics_content_count' {
					analyticsHandler.sendAnalticsContentCountListToAWS(listOfsObject);
				}
				
				when 'analytics_feed_count' {
						analyticsHandler.sendAnalticsFeedCountListToAWS(listOfsObject);
				}
				
				when 'analytics_login' {
					analyticsHandler.sendAnalticsLoginListToAWS(listOfsObject);
				}
				
				when 'analytics_page_view' {
						analyticsHandler.sendAnalticsPageViewListToAWS(listOfsObject);
				}
				
				when 'analytics_search_result_select' {
						analyticsHandler.sendAnalticsSearchResultSelectListToAWS(listOfsObject);
				}
				
				when 'analytics_social_campaign' {
					analyticsHandler.sendAnalticsSocialCampaignListToAWS(listOfsObject);
				}
				
				when 'analytics_top_content' {
					analyticsHandler.sendAnalticsTopContentListToAWS(listOfsObject);
				}
				
				when 'analytics_top_people' {
					analyticsHandler.sendToAnalticsTopPeopleListToAWS(listOfsObject);
				}
				
				when 'analytics_top_search' {
					analyticsHandler.sendAnalticsTopSearchListToAWS(listOfsObject);
				}
				
				when 'analytics_top_site' {
					analyticsHandler.sendAnalticsTopSiteListToAWS(listOfsObject);
				}
				
				when 'analytics_top_topic' {
				analyticsHandler.sendAnalticsTopTopicListToAWS(listOfsObject);
				}
				
				when 'carousel_content' {
					analyticsHandler.sendCarouselContentListToAWS(listOfsObject);
				}

				when 'tiles_config' {
					analyticsHandler.sendTilesConfigListToAWS(listOfsObject);
				}

				when 'site_role' {
					analyticsHandler.sendSiteRoleListToAWS(listOfsObject);
				}

				when 'content_audit_trail' {
					analyticsHandler.sendContentAuditTrailListToAWS(listOfsObject);
				}
				
				when 'app_config' {
					analyticsHandler.sendAppConfigToAWS(listOfsObject);
				}

				when 'user_provisioning_config' {
					analyticsHandler.sendUserProvisioningConfigToAWS(listOfsObject);
				}

				when 'app_default' {
					analyticsHandler.sendAppDefaultDataToAWS(listOfsObject) ;
				}
				
				when 'social_analytics' {
					analyticsHandler.sendSocialAnalyticsListToAWS(listOfsObject);
				}
				
				when 'segment' {
					analyticsHandler.sendSegmentDataToAWS(listOfsObject);
				}

				when 'segment_site' {
					analyticsHandler.sendSegmentSiteDataToAWS(listOfsObject);
				}
				when 'feed_item_people' {
					analyticsHandler.sendFeedItemDataToAWS(listOfsObject, 'people');
				}

				when 'feed_item_site' {
					analyticsHandler.sendFeedItemDataToAWS(listOfsObject, 'site');
				}

				when 'feed_item_content' {
					analyticsHandler.sendFeedItemDataToAWS(listOfsObject, 'content');
				}

				when 'feed_comment' {
					analyticsHandler.sendFeedCommentDataToAWS(listOfsObject);
				}

				when 'feed_poll_choice' {
					analyticsHandler.sendFeedPollChoiceDataToAWS(listOfsObject);
				}

				when 'audience' {
					analyticsHandler.sendAudienceDataToAWS(listOfsObject);
				}
				when 'subscription' {
					analyticsHandler.sendSubscriptionDataToAWS(listOfsObject);
				}
				when 'subscriptionentity' {
					analyticsHandler.sendSubscriptionEntityDataToAWS(listOfsObject);
				}
				when 'analytics_file' {
					analyticsHandler.sendAnalyticsFileDataToAWS(listOfsObject);
				
				}
				when 'file' {
					analyticsHandler.sendFileDataToAWS(listOfsObject);
				}
				when 'folder' {
					analyticsHandler.sendFolderDataToAWS(listOfsObject);
				}
				when 'content_interaction' {
					analyticsHandler.sendContentInteractionDataToAWS(listOfsObject);
				}
				when 'likes' {
					analyticsHandler.sendLikesDataToAWS(listOfsObject);
				}
				when 'bookmark' {
					analyticsHandler.sendBookmarkDataToAWS(listOfsObject);
				}
				when 'share' {
					analyticsHandler.sendShareDataToAWS(listOfsObject);
				}
				

    		}

        } catch (Exception ex) {
            exceptionDetailsObj =  ex;
            throw ex;
        }
    }
    
    public void finish(Database.BatchableContext BC) {
    	
		if (runNextBatchInSequence) {
			switch on recordType {
				when 'site' {
				BatchPushAnalyticsData job = new BatchPushAnalyticsData('content', runNextBatchInSequence);
				Database.executeBatch(job,500);
				}
				when 'content' {
				BatchPushAnalyticsData job = new BatchPushAnalyticsData('people', runNextBatchInSequence);
				Database.executeBatch(job,1000);
			}
			when 'people' {
				BatchPushAnalyticsData job = new BatchPushAnalyticsData('topic', runNextBatchInSequence);
				Database.executeBatch(job,1000);
			}
			when 'topic' {
				BatchPushAnalyticsData job = new BatchPushAnalyticsData('people_expertise', runNextBatchInSequence);
				Database.executeBatch(job,1000);
			}
			when 'people_expertise' {
				BatchPushAnalyticsData job = new BatchPushAnalyticsData('analytics_adoption', runNextBatchInSequence);
				Database.executeBatch(job,1000);
			}
			when 'analytics_adoption' {
				BatchPushAnalyticsData job = new BatchPushAnalyticsData('analytics_content_count', runNextBatchInSequence);
				Database.executeBatch(job,1000);
				}
				when 'analytics_content_count' {
			BatchPushAnalyticsData job = new BatchPushAnalyticsData('analytics_feed_count', runNextBatchInSequence);
			Database.executeBatch(job,1000);
			}
			when 'analytics_feed_count' {
				BatchPushAnalyticsData job = new BatchPushAnalyticsData('analytics_login', runNextBatchInSequence);
				Database.executeBatch(job,1000);
			}
			when 'analytics_login' {
				BatchPushAnalyticsData job = new BatchPushAnalyticsData('analytics_page_view', runNextBatchInSequence);
				Database.executeBatch(job,1000);
			}
			when 'analytics_page_view' {
			BatchPushAnalyticsData job = new BatchPushAnalyticsData('analytics_search_result_select', runNextBatchInSequence);
				Database.executeBatch(job,1000);
			}
			when 'analytics_search_result_select' {
				BatchPushAnalyticsData job = new BatchPushAnalyticsData('analytics_social_campaign', runNextBatchInSequence);
				Database.executeBatch(job,1000);
			}
			when 'analytics_social_campaign' {
				BatchPushAnalyticsData job = new BatchPushAnalyticsData('analytics_top_content', runNextBatchInSequence);
				Database.executeBatch(job,1000);
			}
			when 'analytics_top_content' {
				BatchPushAnalyticsData job = new BatchPushAnalyticsData('analytics_top_people', runNextBatchInSequence);
				Database.executeBatch(job,1000);
			}
			when 'analytics_top_people' {
				BatchPushAnalyticsData job = new BatchPushAnalyticsData('analytics_top_search', runNextBatchInSequence);
				Database.executeBatch(job,1000);
			}
			when 'analytics_top_search' {
				BatchPushAnalyticsData job = new BatchPushAnalyticsData('analytics_top_site', runNextBatchInSequence);
				Database.executeBatch(job,1000);
			}
			when 'analytics_top_site' {
				BatchPushAnalyticsData job = new BatchPushAnalyticsData('analytics_top_topic', runNextBatchInSequence);
				Database.executeBatch(job,1000);
			}
			when 'carousel_content' {
				BatchPushAnalyticsData job2 = new BatchPushAnalyticsData('tiles_config', true);
				Database.executeBatch(job2, 500);
			}
			when 'tiles_config' {
				BatchPushAnalyticsData job2 = new BatchPushAnalyticsData('site_role', true);
				Database.executeBatch(job2, 500);
			}
			when 'site_role' {
				BatchPushAnalyticsData job2 = new BatchPushAnalyticsData('content_audit_trail', true);
				Database.executeBatch(job2, 500);
			}
			when 'content_audit_trail' {
				BatchPushAnalyticsData job2 = new BatchPushAnalyticsData('app_config', true);
				Database.executeBatch(job2, 500);
			}
			
			when 'app_config' {
				BatchPushAnalyticsData job2 = new BatchPushAnalyticsData('user_provisioning_config', true);
				Database.executeBatch(job2, 500);
			}

			when 'user_provisioning_config' {
				BatchPushAnalyticsData job2 = new BatchPushAnalyticsData('app_default', true);
				Database.executeBatch(job2, 500);
			}

			when 'app_default' {
				BatchPushAnalyticsData job = new BatchPushAnalyticsData('segment_site', true);
				Database.executeBatch(job, 500);
			}

			when 'segment_site' {
				BatchPushAnalyticsData job = new BatchPushAnalyticsData('subscription', true);
				Database.executeBatch(job, 500);
			}

			when 'subscription' {
				BatchPushAnalyticsData job = new BatchPushAnalyticsData('subscriptionentity', true);
				Database.executeBatch(job, 500);
			}

			when 'subscriptionentity' {
				BatchPushAnalyticsData job = new BatchPushAnalyticsData('analytics_file', true);
				Database.executeBatch(job, 500);
			}
			when 'analytics_file' {
				BatchPushAnalyticsData job = new BatchPushAnalyticsData('file', true);
				Database.executeBatch(job, 500);
			}
			when 'file' {
				BatchPushAnalyticsData job = new BatchPushAnalyticsData('folder', true);
				Database.executeBatch(job, 500);
			}
			when 'folder' {
				BatchPushAnalyticsData job = new BatchPushAnalyticsData('content_interaction', true);
				Database.executeBatch(job, 500);
			}
			when 'content_interaction' {
				BatchPushAnalyticsData job = new BatchPushAnalyticsData('feed_item_people', true);
				Database.executeBatch(job, 500);
			}

			when 'feed_item_people' {
				BatchPushAnalyticsData job = new BatchPushAnalyticsData('feed_item_site', true);
				Database.executeBatch(job,1000);
			}	

			when 'feed_item_site' {
				BatchPushAnalyticsData job = new BatchPushAnalyticsData('feed_item_content', true);
				Database.executeBatch(job,1000);
			}	

			when 'feed_item_content' {
				BatchPushAnalyticsData job = new BatchPushAnalyticsData('feed_comment', true);
				Database.executeBatch(job,1000);
			}	

			when 'feed_comment' {
				BatchPushAnalyticsData job = new BatchPushAnalyticsData('likes', true);
				Database.executeBatch(job,1000);
			}
			
			when 'likes' {
				BatchPushAnalyticsData job = new BatchPushAnalyticsData('bookmark', true);
				Database.executeBatch(job,1000);
			}	
			
			when 'bookmark' {
				BatchPushAnalyticsData job = new BatchPushAnalyticsData('share', true);
				Database.executeBatch(job,1000);
			}	

			when 'share' {
				BatchPushAnalyticsData job = new BatchPushAnalyticsData('audience', true);
				Database.executeBatch(job,500);
			}

			when 'audience' {
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', SYNC_STATUS_SENT);
				String socialAnlytcsQuery = 'select CreatedDate from Simpplr_Social_Analytics__c ' +
					' where Sync_Status__c !=:soqlParam1 and createddate !=today ' +
					' order by createddate desc Limit 1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<Simpplr_Social_Analytics__c> socialAnalyticsList = (List<Simpplr_Social_Analytics__c>)SIMPESAPI.accessController().queryAsUser(socialAnlytcsQuery, soqlParamMap);
				if(socialAnalyticsList.isEmpty() == false) {
					DateTime endDateTime = socialAnalyticsList[0].CreatedDate;
					DateTime startDateTime = endDateTime.addMonths(-1);
					BatchPushAnalyticsData job = new BatchPushAnalyticsData('social_analytics', startDateTime, endDateTime);
					Database.executeBatch(job,500);
				}
			}	

			}
		}
    }
}