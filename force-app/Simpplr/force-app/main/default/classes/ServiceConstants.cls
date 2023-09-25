/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public class ServiceConstants {
    public static final String PATCH_VERSION = '000';
	public static final String RELEASE_VERSION = 'S2023-04-01';
	public static final String MIGRATION_VERSION = 'S2023-04-01'; // {versionName}-{versionNumber}-{progressiveCount(optional)} ::::::: versionNumber -> major or minor number
	public static final String PACKAGE_VERSION = 'unmanaged';

    //AI API versions
    public static final String TOPIC_SUGGESTION_API_VERSION = '1.0';
    public static final String RELATED_CONTENT_API_VERSION = '1.0';
    public static final String PAGE_RECOMMENDATION_API_VERSION = '1.0';
    public static final String CONTENT_MODERATION_API_VERSION = '1.0';
    public static final String PERSONALIZED_CAROUSEL_API_VERSION = '1.0';

	public static final Integer TOTAL_NUMBER_OF_MIGRATION_BATCHES = 4;
	public static final String FILES_NOT_FOUND = 'It\'s not possible to show files - folder is missing';
	
	public static final String SITE_LIBRARY_PREFIX = 'A0F29C47EA374DF79BDB3A280F1B7D5C';

    public static final String TYPE_PAGE = 'Page';
    public static final String TYPE_EVENT = 'Event';
    public static final String TYPE_ALBUM = 'Album';
    public static final String TYPE_BLOGPOST = 'BlogPost';

    public static final String REPORTED = 'reported';
    
    public static final String CONTENT_SUB_TYPE_KNOWLEDGE = 'knowledge';

    public static final String IMAGE_LOCATION_INLINE = 'inline';
    public static final String IMAGE_LOCATION_ATTACHMENT = 'attachment';
    public static final String FILE_LOCATION_FEED = 'feed';
    public static final String IMAGE_LOCATION_COVER = 'cover';
    
    public static final String FILE_LOCATION_COVER = 'cover';
    public static final String FILE_LOCATION_ATTACHMENT = 'attachment';
    public static final String FILE_LOCATION_INLINE = 'inline';
    public static final String FILE_LOCATION_MEDIA = 'media';
    
    public static final String TITLE_IMAGE_TYPE_ORIGINAL = 'original';
    public static final String TITLE_IMAGE_TYPE_WIDESCREEN = 'widescreen';
    public static final String TITLE_IMAGE_TYPE_THUMBNAIL = 'thumbnail';
            
    public static final String FILTER_WRITE_FOLDERS = 'write_folders';
    
    public static final String STATUS_UPDATE = 'Update';
    public static final String STATUS_APPROVED = 'Approved';
    public static final String CONTENT_STATUS_SUBMIITED = 'Submitted';
    public static final String CONTENT_VALIDATION_EXPIRED = 'ValidationExpired';
    public static final String CONTENT_VALIDATION_REQUIRED = 'ValidationRequired';
    public static final String CONTENT_STATUS_ORG_OR_SITE_ONBOARDING = 'orgOrSiteOnboarding';
    public static final String CONTENT_STATUS_ORG_ONBOARDING = 'orgOnboarding';
    public static final String CONTENT_STATUS_SITE_ONBOARDING = 'siteOnboarding';
    public static final String CONTENT_STATUS_NOT_ONBOARDING = 'none';
    																
    public static final String DEFAULT_APP_LEVEL_ALLOWED_FEATURES = 'Page,Event,Album,File,Blog,Dashboard,Feed';
    public static final String DEFAULT_SITE_LEVEL_ALLOWED_FEATURES = 'Dashboard,Feed,Page,Event,Album,File,About';
    public static final String DEFAULT_UNLISTED_SITE_ALLOWED_FEATURES = 'Dashboard,Feed,File,About';
    
    // Default site features - when a ChatterGroup is converted to a site or a new Chatter Group is created..
    public static final String DEFAULT_SITE_ALLOWED_FEATURES = 'Feed,File,About';

    public static final String ALLOW_FILE_UPLOAD_IN_SELECTED_SITE = 'allFilesInSelectedSites';
    public static final String ALLOW_FILE_UPLOAD_AS_All_USER = 'sameAsAllUsers';
    public static final String ALLOW_FILE_UPLOAD_IN_ALL_SITES = 'allFiles';
    public static final Integer FEATURE_FLAG_CACHE_EXPIRY_IN_SECONDS = 900;
    
    public static final Map<String, String> SUBSCRIPTION_STATUS_MAP = new Map<String, String>{
																		'pending' => 'Processing Pending',
																		'complete' => 'Processing Completed'
    };

   	public static final Map<String, String> DEFAULT_SITE_SYSTEM_FOLDERS_MAP = new Map<String, String>{
    	'CONTENT_FILES' => 'Content Files',
    	'CRM_FILES' => 'CRM Files',
    	'FEED_FILES' => 'Feed Files',
        'QUESTION_FILES' => 'Question Files'
    };
    
    public static final List<String> STORAGE_TYPE_LIST = new List<String> {
    	'Intranet', 'CRM', 'Box', 'gdrive', 'Dropbox', 'sharepoint', 'onedrive'
    };
    
   	public static final Map<String, String> SITE_SYSTEM_FOLDERS_TYPE_MAP = new Map<String, String>{
    	'BOX_FILES' => 'Box',
    	'CRM_FILES' => 'CRM',
    	'CONTENT_FILES' => 'Intranet',
    	'CONTENT_IMAGES' => 'Intranet',
    	'FEED_FILES' => 'Intranet',
    	'GDRIVE_FILES' => 'gdrive',
    	'DROPBOX_FILES'=> 'Dropbox',
    	'SHAREPOINT_FILES'=> 'Sharepoint',
    	'ONEDRIVE_FILES'=> 'Onedrive',
    	'QUESTION_FILES' => 'Intranet'
    };

    public static final Map<String, String> DISMISSIBLE_FLASHES_TASK_TYPE_MAP = new Map<String, String> {
        'ERROR' => 'error',
        'WARNING' => 'warning',
        'INFORMATION' => 'information'
    };
    public static final String HELP_TEXT_ATLASSIAN_DISMISSED_TASK = 'atlassian-expired-user-disconnect';   
    public static final Integer ALERT_REFRESH_INTERVAL = 60; 
    public static final String ALLOW_LEADERCAST_ALL_USER = 'all';
    public static final String ALLOW_LEADERCAST_APP_MANAGERS = 'appManagers';
    public static final String ALLOW_LEADERCAST_SELECTED_SITES_USERS = 'selectedSitesAndUsers';
    
    public static final Map<String, String> DEFAULT_SITE_SYSTEM_SUB_FOLDERS_MAP = new Map<String, String>{
        'ALBUMS' => 'Albums',
        'IMAGES' => 'Images',
        'FILES' => 'Files',    
        'VIDEOS' => 'Videos'
    };
    public static final String SITE_VIDEOS_SYSTEM_FOLDER = 'Site Videos';
    
    public static final String GLOBAL_DEFAULT_PAGES_CATEGORIES = 'Uncategorized';
    public static final String UNCATEGORIZED_CATEGORY_STR = 'Uncategorized';
    
    /******* video site embed url*******/
    
    /************ CollaboarationGroup Types  **********/
    public static final String PRIVATE_SITE = 'Private';
    public static final String PUBLIC_SITE = 'Public';
    public static final String UNLISTED_SITE = 'Unlisted';
    
    public static final String API_ONLY_USER_PERMISSION_NAME = 'permissionsapiuseronly';
    
    public static final String TYPE_CRM_LIBRARY = 'CRM';
    
    public static final String STORAGE_TYPE_BOX_STRING = 'box';
    public static final String STORAGE_TYPE_GDRIVE_STRING = 'gdrive';
    public static final String STORAGE_TYPE_GOOGLE_DRIVE_STRING = 'googledrive';
    public static final String STORAGE_TYPE_DROPBOX_STRING = 'dropbox';
    public static final String STORAGE_TYPE_INTRANET_STRING = 'intranet';
    public static final String STORAGE_TYPE_ONEDRIVE_STRING = 'onedrive';
    public static final String STORAGE_TYPE_SHAREPOINT_STRING = 'sharepoint';
    public static final String STORAGE_TYPE_CRM_STRING = 'crm';

    public static final String GOOGLE_DRIVE_TYPE_MYDRIVE = 'mydrive';
    public static final String GOOGLE_DRIVE_TYPE_SHARED_DRIVE = 'shareddrive';

    public static final String SAVE_DOMAIN_INTEGRATION_TYPE_ADD = 'add';
    public static final String SAVE_DOMAIN_INTEGRATION_TYPE_REMOVE = 'remove';

    public static final String VIDEO_PROVIDER_NATIVE = 'native_video';
    
    public static final String CONTENT_STATUS_REJECTED = 'Rejected';
    public static final String CONTENT_STATUS_APPROVED = 'Approved';
    public static final String CONTENT_STATUS_DELETED = 'Delete';
    public static final String CONTENT_STATUS_DRAFT = 'Draft';
    public static final String CONTENT_STATUS_CREATE_DRAFT = 'DraftCreated';
    public static final String CONTENT_STATUS_UPDATE_DRAFT = 'DraftUpdated';
    public static final String CONTENT_STATUS_UPDATE = 'Updated';
    public static final String CONTENT_STATUS_PREDRAFT = 'PreDraft';
    public static final String CONTENT_STATUS_SUBMITTED = 'Submitted';
    public static final String CONTENT_STATUS_INACTIVE = 'Inactive';
    public static final String CONTENT_STATUS_PUBLISH = 'Published';
    public static final String CONTENT_STATUS_UNPUBLISH = 'Unpublished';
    public static final String CONTENT_STATUS_PENDING = 'Pending';
    
    public static final String SP_UPGRADE_STATUS_NOT_STARTED_YET = 'notStartedYet';
    public static final String SP_UPGRADE_STATUS_COMPLETED = 'completed';
    public static final String SP_UPGRADE_STATUS_FAILED = 'failed';
    public static final String SP_UPGRADE_STATUS_IN_PROGRESS = 'inProgress';
    public static final String SP_UPGRADE_STATUS_NOT_REQUIRED = 'notRequired';
    
    public static final String CONTENT_ONBOARDING_ALL_SITES = 'allSites';
    public static final String CONTENT_ONBOARDING_SELECTED_SITES = 'selectedSites';
    
    public static final String EMAIL_SIMPPLR_USER_SERVICES = 'user-services@simpplr.com';
    public static final String EMAIL_SIMPPLR_SUPPORT = 'support@simpplr.com';
    
 	public static final String DASHBOARD_OWNER_SITE_MANAGER = 'Site Manager';
 	public static final String DASHBOARD_OWNER_USER = 'User';
    public static final String DASHBOARD_OWNER_APP_MANAGER = 'Manager';
    public static final String SITE_DASHBOARD_OWNER_APP_MANAGER = 'App Manager';
 	public static final String DASHBOARD_OWNER_SEGMENT_MANAGER = 'Manager';
 	
    public static final String SHAREPOINT_ADMINISTRATOR = 'SharePoint Administrator';

 	
 	public static final String SITE_LANDING_PAGE_STRING = 'siteLandingPage';
 	
 	/* ERROR CODES SimpplrV2*/
    public static final String ERROR_404 = '404';
    public static final String ERROR_429 = '429';
    public static final String ERROR_403 = '403';
    public static final String ERROR_412 = '412';
    public static final String ERROR_500 = '500';
    public static final String MIGRATION_ERROR = 'Migration in Progress';
    public static final String ALBUM_WITHOUT_IMAGE_VIDEO_ERR = 'It is not possible to publish an Album without pictures or videos';
    public static final String UNEXPECTED_ERROR = 'Some unexpected error occurred !!';
    public static final String MISSING_TARGET_PARAM = 'MISSING_TARGET_PARAM';
    public static final String OPERATION_ON_INACTIVE_USER_CONTENT = 'OPERATION_ON_INACTIVE_USER_CONTENT';
    public static final String SUBSCRIPTION_LOCKED_ERROR = 'This Subscription is currently locked - please try again later';
    public static final String ERROR_CONTENT_DELETED = 'Could not perform action - Content has been deleted';
    
    public static final String SF_EXCEPTION = 'Could not perform action';

    /****************************CSRF prevention related constants********************************/

    public static final String HEADER_AUTH = 'Authorization';
	public static final String HEADER_HTTP_VERB = 'x-http-verb';
	public static final String HEADER_CSRF_TOKEN = 'x-simpplr-csrf';
	public static final String COOKIE_CSRF_TOKEN = 'csrf-token';
    public static final String COOKIE_CSRF_TOKEN_TYPE = 'Lax';
	public static final Integer COOKIE_EXPIRE_TIME = 2*60*60; //2 hours value in seconds
    
    /****************************Email Notification Setting related variables********************************/
    public static final Integer EMAIL_HEADER_TOKENS_MAX_SIZE = 12;
    public static final Integer CONTENT_TITLE_IN_NOTIFICATION_MAX_LENGTH = 150;
    public static final Integer SITE_TITLE_IN_NOTIFICATION_MAX_LENGTH = 150;
    public static final Integer SNIPPET_IN_NOTIFICATION_MAX_LENGTH = 125;
    public static final Integer SNIPPET_IN_SERVICE_NOW_DESCRIPTION_MAX_LENGTH = 35;
    
    public static final String CRYPTO_INITIALIZATION_VECTOR = 'Izi6VeytTMNiEAz5';

    public static final Integer WORKDAY_MAX_SYNC = 3;
    public static final Integer WORKDAY_MIN_SYNC = 1;

    public static final String ANALYTICS_VECTOR = 'Wpt8CaquPQCsAZo1';
	
    public static final Integer AUDIENCE_MEMBER_LIMIT = 5;
	public static final Map<String, String> FILE_TYPES_MAP = new Map<String, String>{
		'WORD_X' => 'WORD',
		'EXCEL_X' => 'EXCEL',
		'POWER_POINT' => 'POWERPOINT',
		'POWER_POINT_X' => 'POWERPOINT',
		'VND.GOOGLE-APPS.AUDIO' => 'GAUDIO',			// audio/webm
		'VND.GOOGLE-APPS.DOCUMENT' => 'GDOC',			// application/msword
		'VND.GOOGLE-APPS.DRAWING' => 'GDRAW',			// 
		'VND.GOOGLE-APPS.FILE' => 'GFILE',				// 
		'VND.GOOGLE-APPS.FORM' => 'GFORM',				// 
		'VND.GOOGLE-APPS.FUSIONTABLE' => 'GFTABLE',		// 
		'VND.GOOGLE-APPS.MAP' => 'GMAP',				// 
		'VND.GOOGLE-APPS.PHOTO' => 'GPHOTO',			// 
		'VND.GOOGLE-APPS.PRESENTATION' => 'GSLIDES',	// application/vnd.ms-powerpoint
		'VND.GOOGLE-APPS.SCRIPT' => 'GSCRIPT',			// 
		'VND.GOOGLE-APPS.SITES' => 'GSITE',				// 
		'VND.GOOGLE-APPS.SPREADSHEET' => 'GSHEET',		// application/vnd.ms-excel
		'VND.GOOGLE-APPS.UNKNOWN' => 'UNKNOWN',			// 
		'VND.GOOGLE-APPS.VIDEO' => 'GVIDEO',			// video/webm
		'VND.GOOGLE-APPS.DRIVE-SDK' => 'GSDK',			// 
		'OCTET-STREAM' => 'UNKNOWN'						//
	};
	
	public static final Set<String> GDRIVE_DOWNLOADABLE_TYPES = new Set<String> {
		'VND.GOOGLE-APPS.DOCUMENT',
		'VND.GOOGLE-APPS.DRAWING',
		'VND.GOOGLE-APPS.PRESENTATION',
		'VND.GOOGLE-APPS.SPREADSHEET'
	};
    
    public static final String DEFAULT_TILE_LAYOUT = 'd';
    public static final Set<String> FEED_ON_DASHBOARD_LAYOUT_SET = new Set<String>{
    	'e', 'o', 'g', 'p', 'q', 'r'
    };
    
    public static final String DATETIME_FORMAT = 'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ';
    public static final String LISTING_DATETIME_FORMAT = 'MMM d, yyyy hh:mm a';
    public static final String DATE_FORMAT = 'MMM d, yyyy';
    
    public static final String EMAIL_DATETIME_FORMAT = 'MMMM dd, yyyy hh:mm a';//'EEEE, MMM dd, yyyy hh:mm a';
    public static final String EMAIL_DIGEST_HEADER_DATETIME_FORMAT = 'MMMM dd, yyyy ';//'EEEE, MMM dd, yyyy hh:mm a';
    public static final String CATEGORY_UNCATEGORIZED = 'Uncategorized';
    
    public static final String SIMPPLR_SCHEDULE_JOB = 'SIMPPLR SCHEDULE JOB';
    public static final String SIMPPLR_DEEPLINKING_REDIRECTOR_URL = 'https://services.simpplr.com/contentredirector.php?pageURL=';
    public static final String BOX_CONNECT_URL = 'https://www.box.com/api/oauth2/authorize?response_type=code';
    public static final Integer BOX_API_FOLDER_ITEMS_LIMIT = 1000;
    public static final String NATIVE_VIDEO_BASE_URL ='https://cdnapisec.kaltura.com/p/'; 

    public static final String ZEUS_MICROSERVICE_DEV_URL = 'https://api.dev.zeus.simpplr.xyz';
    public static final String ZEUS_MICROSERVICE_QA_URL = 'https://api.qa.simpplr.xyz';
    public static final String ZEUS_MICROSERVICE_PROD_URL = 'https://api.app.simpplr.com';

    
    public static final String SISENSE_ANALYTICS_DEV_URL = 'https://d1sz1qsu9mu2a4.cloudfront.net';
    public static final String SISENSE_ANALYTICS_QA_URL = 'https://d3c2n1io4rndpe.cloudfront.net';
    public static final String SISENSE_ANALYTICS_PROD_URL = 'https://d1t0q8np0idfmx.cloudfront.net';

    public static final String Simpplr_MFE_DEV_URL = 'https://web.dev.zeus.simpplr.xyz';
    public static final String Simpplr_MFE_QA_URL = 'https://web.qa.simpplr.xyz';
    public static final String Simpplr_MFE_PROD_URL = 'https://web.app.simpplr.com';

    public static final String USER_SYNC_SOURCES_WITH_VALUES = 'Salesforce,Workday,activedirectory';
    
    public static String EVENT_ORGANIZER{get{
        return 'Organizer';
    }}
    
    public static String RSVP_YES{get{
        return 'Yes';
    }}
    
    public static final String ERROR_INVALID_REQUEST_PARAMETERS = 'Invalid Request Perameter';
 	
 	public static final string DEFAULT_DATA_CATEGORY = 'Internal';
    public static final string ARTICLE_BODY_CUSTOM_FIELD = 'Description__c';
    public static final string LANGUAGE = 'en_US';
    public static final string PUBLISH_STATUS = 'Online'; 
    
    public static final String FOLDER_NAME_ERROR_MESSAGE = 'Folder name cannot contain any of these characters: /, \\';
    public static final String FOLDER_DUPLICATE_NAME_ERROR_MESSAGE = 'It\'s not possible to duplicate folder names';
    
    public static final String INVALID_LIB_TILE_ID_MESSAGE = 'Invalid Library Tile id';
    public static final String INVALID_TILE_ID_MESSAGE = 'Invalid Tile id';
    public static final String UNAUTHORIZED_ACCESS_EXCEPTION_MESSAGE = 'You are not permitted to perform this action.'; 
    public static final String CONFLUENCE_REFRESH_TOKEN_EXPIRED = 'confluence.refresh_token.expired';
    public static final String CONTENT_VERSION_UNIQUE_IDENTIFIER = 'd3bbdcf8-c900-4ed7-ad24-b2b8f1089dc4';  
    public static final String REMOVE_FILE_SEARCH_IDENTIFIER = 'a8uybdu8-e423-7de4-da42-b4r9t1078pf7';
    public static final String FEED_EXT_FILE_SEPRATOR = '\u2063\uFEFF\u200b\uFEFF\u2063';
    public static final String RECOGNITION_FILE_SEPRATOR = '\u2063\uFEFF\uFEFF\u200b\uFEFF\uFEFF\u2063';
    public static final String QNA_QUESTION_SEPERATOR = '\u2063\uFEFF\uFEFF\uFEFF\u200b\uFEFF\uFEFF\uFEFF\u2063';
    public static final String RECOGNITION_ATTRIBUTES_SEPRATOR = '~ ';
    
    public static final String FILE_CONNECT_API_SUB_URL = '/services/data/v45.0/connect/files/';
    public static final String COLLABORATION_GROUP_DELETE_ERROR_MESSAGE = 'This group has been promoted as a Site and can not be deleted now. If you want to delete this group, you will have to delete all related contents or you can just archive this group';
    public static final String SITE_MEMBER_REQUEST_APPROVED_MESSAGE = 'Site membership request already approved/rejected';

    public static final String recognitionChatterFeedBody = 'Recognised people with award, do not edit in chatter. to view full post please use Simpplr-App';
	
	public static final String VIDEO_PROVIDER_ZOOM = 'zoom';
	public static final String VIDEO_PROVIDER_SKYPE = 'skype';
    public static final String FILE_MIME_TYPE_IMAGE = 'Image';
    public static final String FILE_MIME_TYPE_VIDEO = 'Video';

    public static final Map<String, String> SUPPORTED_LOCALE_MAP = new Map<String, String>{
    	'en_US' => 'en_US',    'en_GB' => 'en_GB',      'en_AU' =>  'en_US',    'en_MY' =>  'en_US',
        'en_IN' => 'en_US',    'en_PH' => 'en_US',      'en_CA' =>  'en_US',    'en_HK' =>  'en_US',
        'en_IE' => 'en_UK',    'en_SG' => 'en_US',      'en_ZA' =>  'en_US',

    	'fr'    => 'fr_FR',    'fr_CA' => 'fr_CA',      'fr_BE' => 'fr_FR',      'fr_LU' => 'fr_FR',
        'fr_CH' => 'fr_FR',

        'es'    => 'es_ES',    'es_MX' => 'es_ES',      'es_AR' => 'es_ES',      'es_BO' => 'es_ES',
        'es_CL' => 'es_ES',    'es_CO' => 'es_ES',      'es_CR' => 'es_ES',      'es_DO' => 'es_ES', 
        'es_EC' => 'es_ES',    'es_SV' => 'es_ES',      'es_GT' => 'es_ES',      'es_HN' => 'es_ES', 
        'es_NI' => 'es_ES',    'es_PA' => 'es_ES',      'es_PY' => 'es_ES',      'es_PE' => 'es_ES',
        'es_PR' => 'es_ES',    'es_US' => 'es_ES',      'es_UY' => 'es_ES',      'es_VE' => 'es_ES',
        
        'it'    => 'it_IT',    'it_CH' => 'it_IT',      'ja'    =>  'ja_JP',
        
        'de'    => 'de_DE',    'de_AT' => 'de_DE',      'de_CH' => 'de_DE',       'de_BE' =>  'de_DE',
        'de_LU' => 'de_DE',

        'hy'    => 'hy_AM',     'bg'   => 'bg_BG',      'da'    => 'da_DA',

        'pt_BR' => 'pt_BR',     'pt_PT' => 'pt_BR',     'ro' => 'ro_RO',        'ro_MD' =>   'ro_RO',

        'nl_NL' => 'nl_NL',     'nl_BE' => 'nl_BE',

        'ms' => 'ms_MY',        'th'    => 'th_TH',     'el' => 'el_GR',

        'zh_CN' => 'zh_CN'

    };

    public static final Map<Integer, String> ID_VS_KALTURA_SUPPORTED_LANGUAGE_MAP = new Map<Integer, String>{
        2131 => 'Korean', 2091 => 'Mandarin Chinese', 2071 => 'Dutch', 1992 => 'Thai', 772 => 'French', 782 => 'Italian',
        792 => 'Portuguese', 812 => 'Arabic', 822 => 'Japanese', 832 => 'Hindi', 842 => 'Turkish', 852 => 'English',
        742 => 'Russian', 752 => 'German', 762 => 'Spanish', 6733 => 'Taiwanese Mandarin',
        6743 => 'French (Canada)', 6663 => 'Tamil', 6673 => 'Urdu', 6683 => 'Welsh', 6693 => 'Irish', 6703 => 'Malayalam',
        6713 => 'Vietnamese', 6723 => 'Ukrainian', 6643 => 'Norwegian', 6653 => 'Zulu', 3011 => 'Indonesian',
        2991 => 'Romanian', 2971 => 'Polish', 2931 => 'Greek'
    };

    public static final Map<String, Integer> SIMPPLR_LANG_VS_KALTURA_LANG_ID_MAP = new Map<String, Integer>{
        'en_US' => 852, 'en_GB' => 852, 'en_MY' => 852, 'en_HK' => 852, 'en_AU' => 852, 'en_CA' => 852, 'en_ZA' => 852, 'en_IE' => 852, 'en_UK' => 852,
        
        'fr' => 772, 'fr_CA' => 772, 'fr_BE' => 772, 'fr_LU' => 772, 'fr_CH' => 772, 'fr_FR' => 772,

        'el' => 2931, 'th' => 1992,
        
        'es'    =>  762,    'es_MX' =>  762,      'es_AR' =>  762,      'es_BO' =>  762,
        'es_CL' =>  762,    'es_CO' =>  762,      'es_CR' =>  762,      'es_DO' =>  762, 
        'es_EC' =>  762,    'es_SV' =>  762,      'es_GT' =>  762,      'es_HN' =>  762, 
        'es_NI' =>  762,    'es_PA' =>  762,      'es_PY' =>  762,      'es_PE' =>  762,
        'es_PR' =>  762,    'es_US' =>  762,      'es_UY' =>  762,      'es_VE' =>  762,
        'es_ES' => 762,

        'it_IT' => 782, 'it'  => 782, 'it_CH' => 782,
        
        'ja' =>  822,

        'de' => 752,        'de_AT' => 752,      'de_CH' => 752,       'de_BE' =>  752,
        'de_LU' => 752,     'de_DE' => 752,      'da' => 752,          'da_DA' => 752,

        'zh_CN' => 2091,
        
        'nl_NL' => 2071,    'nl_BE' => 2071,
        
        'pt_BR' => 792,     'pt_PT' => 792,

        'ro' => 742,        'ro_MD' =>   742,    'ro_RO' => 742
    };
	
	public static final Map<String, Integer> CAPTION_STATUS_MAP = new Map<String, Integer>{
		'other' => 0,
        'inProgress' => 1,
		'success' => 2,
		'failure' => 3,
        'captionRollback' => 4
	};
    /************ Platform Caching  **********/
    public static final String CACHE_CAROUSEL = 'cacheCarousel';
    public static final String CACHE_TILE = 'cacheTile';
    public static final String UPGRADE_STATUS_COMPLETED = 'completed';
    public static final String UPGRADE_STATUS_NOT_REQUIRED = 'notRequired';
    public static final String UPGRADE_STATUS_NOT_STARTED_YET = 'notStartedYet';
    public static final String SINGLE_DOMAIN = 'singleDomain';
    public static final String UPGRADE_STATUS_IN_PROGRESS = 'inProgress';

    public static final String FEED_COMMENT_BODY_PLACEHOLDER = 'SIMPPLR-7851eb59-2d2d-4630-8f2a-01d7046cdee4';
    public static final String FEED_BODY_PLACEHOLDER = 'SIMPPLR-7851eb59-2d2d-4630-8f2a-01d7046cdee3';

    /************** Branding Default Values ****************/
    public static final Map<String, String> DEFAULT_BRANDING = new Map<String, String>{
        'general_primaryColor'          => '1ea0e6',
        'general_primaryDarkModeColor'  => '1ea0e6',
        'general_lightModelinkColor'  => '1ea0e6',                //CONT-10737
        'general_darkModelinkColor'   => '1ea0e6',                //CONT-10737
        'general_brandingAnchorPrimarycolor'  => '1ea0e6',        //CONT-10737


        'general_backgroundColor'       => 'f6f6f6',
        'alert_backgroundColor'         => '333333',
        'alert_textColor'               => 'ffffff',
        'header_preset'                 => 'default',
        'header_backgroundColor'        => 'ffffff',
        'header_textColor'              => '333333',
        'header_iconColor'              => 'c5c5c5',
        'header_notificationBubble'     => 'EB5F5F',
        'footer_preset'                 => 'default',
        'footer_backgroundColor'        => 'ffffff',
        'footer_textColor'              => '858585',
        'analytics_analytics'           => 'default',
        'logo_faviconPath'              => 'https://static.simpplr.com/assets/img/favicon'
    };
}