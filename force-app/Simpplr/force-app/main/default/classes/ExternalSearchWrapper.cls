public with sharing class ExternalSearchWrapper {
	public class AIResponse{
		public SearchDataWrapperCollection hits;
		public FacetWrapper facets;
		public String did_you_mean_term;
		public String did_you_mean_link;
		public String showing_results_for_term;
		public String showing_results_for_link;
		public String search_instead_for_term;
		public String search_instead_for_link;
		public String no_results_for_term;
		public String status;
		public String message;
		public String exception_traceback;
		public List<FilterAttributeWrapper> results;
		public List<String> member_people_id_list;
	}

	/**
	* @description Aggregate wrapper for count query form AWS
	*/
	public class Aggregate{
		public Hits hits;
		public String status;
	}
	/**
	* @description Aggregation wrapper for count query form AWS
	*/
	public class Aggregation {
		public String key;
		public Integer doc_count;
	}
	/**
	* @description Hits wrapper for count query form AWS
	*/
	public class Hits {
		public Integer start;
		public Total total;
		public List<Aggregation> aggregation;
	}
	/**
	* @description Total wrapper for count query form AWS
	*/
	public class Total {
		public Integer value;
		public String relation;
	}


	public class SearchDataWrapperCollection {
		public TotalWrapper total;	
		public List<SearchDataWrapper> hit;
		public Integer start;	
		public String status;
	}
	public class TotalWrapper { 
		public Integer value;
	}
	public class AutoCompleteResponse{
		public String status;
		public String message;
		public String exception_traceback;
		public List<SearchDataWrapper> matches;
	}
	public class SearchDataWrapper {
		public String community_nickname;
		//public String score;
		public Double score;
		public String content_sub_type;
		public String last_validated_date_time;
		public Boolean is_deleted;
		public Boolean question_answer_enabled;
		public String collaborationgroup_name;
		public String chatter_group_id; 
		public String site_r_name;
		public Boolean is_follow_mandatory;
		public String joining_date;
		public String birth_date;
		public String user_r_show_simpplr;
		public String last_name;
		public String custom_field_1;
		public String custom_field_2;
		public String custom_field_3;
		public String custom_field_4;
		public String custom_field_5;
		public String custom_field_6;
		public String custom_field_7;
		public String custom_field_8;
		public String custom_field_9;
		public String custom_field_10;
		public String custom_field_11;
		public String custom_field_12;
		public String custom_field_13;
		public String custom_field_14;
		public String custom_field_15;
		public String custom_field_16;
		public String custom_field_17;
		public String custom_field_18;
		public String custom_field_19;
		public String custom_field_20;
		public String custom_field_21;
		public String custom_field_22;
		public String custom_field_23;
		public String custom_field_24;
		public String custom_field_25;								
		public String custom_profile_field_1;
		public String custom_profile_field_2;
		public String custom_profile_field_3;
		public String custom_profile_field_4;
		public String custom_profile_field_5;
		public String custom_profile_field_6;
		public String custom_profile_field_7;
		public String custom_profile_field_8;
		public String custom_profile_field_9;
		public String custom_profile_field_10;
		public String custom_profile_field_11;
		public String custom_profile_field_12;
		public String custom_profile_field_13;
		public String custom_profile_field_14;
		public String custom_profile_field_15;
		public String custom_profile_field_16;
		public String custom_profile_field_17;
		public String custom_profile_field_18;
		public String custom_profile_field_19;
		public String custom_profile_field_20;
		public String custom_profile_field_21;
		public String custom_profile_field_22;
		public String custom_profile_field_23;
		public String custom_profile_field_24;
		public String custom_profile_field_25;
		public Boolean user_r_isactive;
		public String first_name;
		public String mobile_phone;
		public String people_category_r_name;
		public String user;
		public String type;
		public String object_type;
		public String email;
		public String owner_id;
		public String user_r_usertype;
		public String owner_name;
		public String department;
		public String id;
		public String hasRead;
		public String state;
		public String file_data;
		public String city;
		public String title;
		public String phone;
		public String employee_number;
		public String manager;
		public String isdeleted;
		public String street;
		public Boolean show_in_simpplr;
		public Boolean is_published;
		public Boolean is_site_featured;
		public String postal_code;
		public String people_category;
		public String site_category;
		public String site_category_r_name;
		public String collaborationgroup_description;
		public String site_type;
		public Boolean is_newsletter_allowed;
		public Boolean is_alert_enabled;
		public String img;
		public String imgLandscape;
		public String imgContentDocumentId;
		public String imgLandscapeContentDocumentId;
		public String imgContentVersionId;
		public String imgLandscapeContentVersionId;
		public String title_content_document;
		public String title_content_version;
		public Boolean is_influencer;
		public Boolean has_simpplr_license;
		public String name;
		public String primary_author_r_ppl_segment_id;
		public String primary_author_r_department;
		public String primary_author_r_people_category;
		public String country;
		public String company_name;
		public String division;
		public String origin;
		public Boolean has_pages;
		public Boolean has_albums;
		public Boolean has_events;
		public String landing_page;
		public String about_me;
		public String read_only;
		public String createdbyid;
		public String must_read_read_count;
		public Boolean is_active;
		public String lastmodifieddate;
		public String event_end_datetime;
		public Integer event_rsvp_limit;
		public String event_start_datetime;
		public Boolean event_is_all_day;
		public String album_image_count;
		public String allow_follow;
		public String subscribers;
		public String primary_author;
		public String allow_comments;
		public String album_video_count;
		public Boolean is_must_read;
		public String publish_start_datetime;
		public String event_rsvp_by_datetime;
		public String last_edited_datetime;
		public String site_r_allowed_features; // for content
		public Boolean site_r_is_active;
		public String site_r_landing_page;
		public String site_r_title_content_version;
		public String site_r_title_content_document;
		public Integer siteMemberCount;
		public String isexec;
		public String seat_count;
		public String status;
		public String createddate;
		public String hide_title_image;
		public String organizers;
		public String shares;
		public String is_archived;
		public String primary_author_r_name;
		public String likes;
		public String lastmodifiedbyid;
		public String is_home_page_cover_story;
		public String display_summary;
		public String summary;
		public String feed_posts;
		public String site;
		public String unique_view_count;
		public String site_name;
		public String comments;
		public String text_intro;
		public String feed_comments;
		public String posts;
		public String total_view_count;
		public String views;
		public Integer likes_int;
		public Integer total_view_count_int;
		public Integer attending_count;
		public String excerpt;
		public String content_golive_date;
		public String tags;
		public String publish_start_date;
		public String publish_end_datetime;
		public String event_timezonesidkey;
		public Boolean site_r_show_in_simpplr;
		public Boolean site_r_is_deleted;
		public String site_r_site_type;
		public String site_r_chatter_group_id;
		public String pages_category_r_name;
		public String pages_category;
		public String file_size;
		public Boolean event_rsvp_allowed;
		public String description;
		public String contentVersionId;
		public String file_name;
		public String body;
		public Integer expertise_user_count;
		public String expertise_name;
		public String topic_name;
		public String site_category_name;
		public mergeWrapper merge_from_expertise;
		public mergeWrapper merge_to_expertise;
		public String merge_from_topic;
		public String merge_to_topic;
		public Boolean event_rsvp_show_maybe;
		public Boolean site_r_has_pages;
		public Boolean site_r_has_albums;
		public Boolean site_r_has_events;
		public List<AttachedFile> listOfAttachment = new List<AttachedFile>();
		public List<ChatterGroupId> listOfChatterGroupId = new List<ChatterGroupId>();
		public String ppl_segment_id;
		public String fileExtension;
		public List<SiteWrapper> sites;
		public List<String> listOfChatterGroupMembr = new List<String>();
		public List<TopicWrapper> topics = new List<TopicWrapper>();
        public List<ExpertiseWrapper> expertise = new List<ExpertiseWrapper>();
        public SiteRole current_site_role;
        public SiteMembershipRequest current_site_membership_request;

		public String alert_message;
		public String alert_url;
		public String author;
		public String notification_author_r_name;
		public Datetime display_from_datetime;
		public Datetime display_to_datetime;
		public Boolean notification_sent;
		public String external_id;
		public Boolean is_dismissible;
		public Boolean is_expired;
		public Boolean is_link_alert;
		public Boolean is_manually_expired;
		public Boolean is_scheduled;
		public String members_type;
		public String recipient;
		public Decimal recipient_count;
		public String recipient_site;
		public Decimal seen_count;
		public String audience;
        public String segment;
		public Boolean accessible_to_everyone;
		public String links_label;
        public String original_links_url;
		public String tile_title;
		public String tile_description;
		public String tile_type;
		public String tile_variant;
		public String tile_location;
		public List<TilesLinkItem> tile_link_items;

		public Boolean is_enabled; // NOPMD - json key, suppressed codacy error
		public Boolean is_system_template; // NOPMD - json key, suppressed codacy error

		public Boolean is_onboarding_enabled;
		public String onboarding_status;
		public String onboarding_added_date;
		public Boolean enable_org_level_onboarding;

		public String question_title;
		public String question_description;
		public String question_body;
		public String questioned_by;
		public String questioned_by_r_name;
		public Integer answer_count;
		public Boolean has_approved_answer;
		public Boolean is_duplicate;

		public String content_r_id;
		public String content_r_type;
		public String content_r_title;
		
		public String slack_user_id;
		public String slack_user_name;
		public String slack_tenant_id;	
	}

	public class mergeWrapper{
		public String id;
		public String name;
	}

	public class AttachedFile{
		public String contentDocumentId;
		public String contentVersionId;
		public String fileType;
	}
	
	public class SiteWrapper{
		public String site_type;
		public String id;
		public String name;
		public String chatter_group_id;
		public String landing_page;
	}
	
	public class FacetWrapper {
		public ObjectTypeWrapper field_agg;
		public ObjectTypeWrapper object_type;
	}
	
	public class ChatterGroupId {
		public String id;
		public String site_type;
		public Boolean is_active;
		public Boolean is_deleted;
	}
	public class ObjectTypeWrapper {
		public List<BucketWrapper> buckets;
	}
	public class BucketWrapper {
		public Integer count;	
		public String url;	
		public String value;
		public String people_category_id;	
	}
	
	public class TopContentsWrapper {
		public String nextPageToken;
		public Object totalRecords;
		public SectionCounts sectionCounts;
		public List<ItemWrapper> listOfItems;
		public String term;
		public String suggestedTerm;
		public String shareddriveName;
		public Boolean isMyDriveFolderLinked;
	}

	public class SectionCounts {
		public Integer Content;
		public Integer Site;
		public Integer User;
		public Integer File;
		public Integer BoxFile;
		public Integer GoogleDriveFile;
		public Integer DropboxFile;
		public Integer CrmFile;
		public Integer Tiles;
		public Integer Links;
		public Integer Question;
	}

	public class ItemWrapper {
		public Double relevancyScore;
		public Boolean matchedOnTopic;
		public Boolean matchedOnExpertise;
		public String itemType;
		public Object item;
	}
	
	public class CategoryWrapper {
		public String id;
		public String name;
		public String site;
		public String object_type;
		public Boolean is_deleted;
        public String add_site_access;
        public String lastmodifieddate;
        public String createddate;
    }

	public class EventRSVPResponseWrapper {
		public String id;
		public String content_id;
		public String people_id;
		public String rsvp_response;
        public String object_type;
        public String lastmodifieddate;
        public String createddate;
    }
    
    public class SiteMembershipRequest {
        public String id;
        public String object_type;
        public Boolean is_deleted;
        public String action_by;
        public String action_by_name; 
        public String action_datetime;
        public String request_datetime;
        public String request_by;
        public String site_id;
		public String collaboration_group_member_request_id;
        public String status;
        public String request_by_name; 
        public String people_id_site_id;
        public String lastmodifieddate;
        public String createddate;

    }

    public class SiteRole {
        public String id;
		public String object_type;
		public Boolean is_manager;
		public Boolean is_member;
		public String people_id;
        public Boolean is_content_manager;
        public String site_id;
        public String user_id;
        public Boolean is_deleted;
        public Boolean is_owner;
        public String lastmodifieddate;
        public String createddate;

    }
    
	public class TopicWrapper {
		public String id {get;set;}
		public String name {get;set;}
		public Integer talkingAbout{get;set;}
		public PeopleLiteWrapper CreatedBy{get;set;}
	}

    public class ExpertiseWrapper {
		public String id;
		public String name;
		public Integer count;
	}

	public class FilterAttributeWrapper {
		public String id;
		public String name;
    }
    
    public class PeopleStatResponse {
        public Integer member_count; 
        public Integer membership_request_count;
		public List<String> member_people_id_list;
    }
    
    public class Newsletter {
        public String id;
        public String object_type;
        public String site; 
        public Boolean is_deleted;
        public List<NewsletterContentDetail> content_details;
        public String notification_author_r_name; 
        public String subject;
        public String name;
        public String status;
        public String senddate;
        public String recipient_site;
        public String recipient_audience; 
        public String recipient;
        public String createddate;
        public String primary_author;
        public String sent_by;
        public String lastmodifieddate;
    }

    public class NewsletterContentDetail {
        public String content_id;
        public String content_r_title;
        public String content_r_display_summary;
    }

	/**
	* @description CustomLink
	*/
	public class CustomLink {
        public String links_url;
        public Boolean links_on_off;
        public String object_type;
        public String links_label;
        public Integer links_item_order;
        public String ppl_segment_id;
    }

	/**
	* @description ContentPublishedCount
	*/
    public class ContentPublishedCount {
        public Integer count;
    }

    /**
    * @description To create Tiles object data wrt to AWS data model
    */
    public class TilesConfig {
        public String id;
        public String object_type;
        public String tile_title;
        public String tile_description;
        public Boolean is_deleted;
        public Boolean is_manager_driven;
        public String segment;
        public String people_id;
        public List<TilesLinkItem> tile_link_items;
        public Boolean is_active;
        public Boolean is_newly_pushed;
        public String site;
        public String site_r_name;
        public String site_r_chatter_group_id;
        public Boolean site_r_is_active;
        public Boolean site_r_is_deleted;
        public Boolean site_r_show_in_simpplr;
        public String site_r_site_type;
        public String site_r_title_content_version;
        public String site_r_landing_page;
        public String tile_location;
        public String tile_type;
        public String tile_variant;
        public String createdbyid;
        public String createddate;
        public String lastmodifiedbyid;
        public String lastmodifieddate;
    }

    /**
    * @description object for url and text
    */
    public class TilesLinkItem{
        public String link_url;
        public String link_text;
    }
	/**
	* @description AudienceFieldValues
	*/
	public class AudienceFieldValues {
		public String id;
		public String name;
	}

    public class MustReadAudit {
        public String id;
        public String object_type;
        public String content_id;
        public Boolean is_deleted;
        public String lastmodifieddate;
        public String createddate;
    }

    public class MustReadConfirmHistory {
        public String id;
        public String object_type;
        public String content_id;
        public String people_id;
        public Boolean is_deleted;
        public String lastmodifieddate;
        public String createddate;
    }

}