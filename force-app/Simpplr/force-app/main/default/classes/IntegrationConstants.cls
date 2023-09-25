public with sharing class IntegrationConstants {
	public static final String POST_REQUEST_TYPE = 'POST'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String GET_REQUEST_TYPE = 'GET'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String CHARSET_UTF8 = 'UTF-8'; // NOPMD - correct naming convension, suppressed codacy error
	
	public static final String INTEGRATION_TYPE_FACEBOOK = 'facebook'; // NOPMD - correct naming convension, suppressed codacy error
    public static final String INTEGRATION_TYPE_TWITTER = 'twitter'; // NOPMD - correct naming convension, suppressed codacy error
    public static final String INTEGRATION_TYPE_LINKEDIN = 'linkedin'; // NOPMD - correct naming convension, suppressed codacy error
    public static final String INTEGRATION_TYPE_ADSI = 'adsi'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String INTEGRATION_TYPE_ACTIVE_DIRECTORY = 'activedirectory'; // NOPMD - correct naming convension, suppressed codacy error
    public static final String INTEGRATION_TYPE_GOOGLE_USER_SYNC = 'googleusersync'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String INTEGRATION_TYPE_BOX = 'box'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String INTEGRATION_TYPE_NATIVE_VIDEO = 'native_video'; // NOPMD - correct naming convension, suppressed codacy error
    public static final String INTEGRATION_TYPE_GDRIVE = 'gdrive'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String INTEGRATION_TYPE_GOOGLE_DRIVE = 'googledrive'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String INTEGRATION_TYPE_GOOGLE_CALENDAR = 'googlecalendar'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String INTEGRATION_TYPE_DROPBOX = 'dropbox'; // NOPMD - correct naming convension, suppressed codacy error
    public static final String INTEGRATION_TYPE_SHAREPOINT = 'sharepoint'; // NOPMD - correct naming convension, suppressed codacy error
    public static final String INTEGRATION_TYPE_ONEDRIVE = 'onedrive'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String INTEGRATION_TYPE_SLACK_UNFURL = 'slackUnfurl'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String INTEGRATION_TYPE_SLACK_CONTENT_SHARE = 'slackContentShare'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String INTEGRATION_TYPE_SLACK = 'slack'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String INTEGRATION_TYPE_SERVICE_ACCOUNT = 'serviceAccount'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String SLACK_CLIENT_ID = '568914607847.569791311750'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String SLACK_CLIENT_SECRET = '4fb44368a380d5c89600655736b6de58'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String INTEGRATION_TYPE_SERVICE_NOW = 'servicenow'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String INTEGRATION_TYPE_SALESFORCE = 'salesforce'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String INTEGRATION_TYPE_ATLASSIAN = 'atlassian'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String INTEGRATION_TYPE_OUTLOOK_CALENDAR = 'outlookcalendar';	
    public static final String INTEGRATION_TYPE_MICROSOFT_TEAMS = 'microsoftteams'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String INTEGRATION_TYPE_MICROSOFT_TEAMS_ADMIN = 'microsoftTeamsAdmin'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String MICROSOFT_TEAMS_CLIENT_ID = 'b90c5341-89fc-4c6f-a620-de03c35a4712'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String MICROSOFT_TEAMS_CLIENT_SECRET = '0rP8Q~RwEaDPrpdJIkGHxkQFbyrbqCMt1j_Vidna'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String INTEGRATION_SLACK_UNFURL = 'slack-unfurl'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String INTEGRATION_FLOW_APP = 'app'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String INTEGRATION_FLOW_STANDARD = 'standard'; // NOPMD - correct naming convension, suppressed codacy error
	public static final List<String> MULTI_DOMAIN_APPS_NAME_LIST = new List<String> {'googledrive', 'googlecalendar'}; // NOPMD - correct naming convension, suppressed codacy error

	public static final String FACEBOOK_CLIENT_ID = '135272853692202'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String FACEBOOK_CLIENT_SECRET = '3ce89060f10154ec22a89f6338c1a53f'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String TWITTER_CLIENT_ID = '2wpdIHl0g3Rj5gDnUVGR7kT4f'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String TWITTER_CLIENT_SECRET = 'wwZ3fZsPUoGM0QFPOH7LXGGpLNV62y9BF2SgEgdN9icbHd78fS'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String LINKEDIN_CLIENT_ID = '81h0xlrtfvx49p'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String LINKEDIN_CLIENT_SECRET = '7WYJtr7UmhfPr07J'; // NOPMD - correct naming convension, suppressed codacy error
	 
    public static final String TWITTER_REQUEST_ENDPOINT = 'https://api.twitter.com/oauth/request_token'; // NOPMD - correct naming convension, suppressed codacy error
    public static final String TWITTER_AUTH_ENDPOINT = 'https://api.twitter.com/oauth/authenticate?oauth_token='; // NOPMD - correct naming convension, suppressed codacy error
    public static final String TWITTER_TOKEN_ENDPOINT = 'https://api.twitter.com/oauth/access_token?oauth_verifier='; // NOPMD - correct naming convension, suppressed codacy error
    public static final String TWITTER_GET_TWEET_DETAILS = 'https://api.twitter.com/1.1/statuses/show.json?id='; // NOPMD - correct naming convension, suppressed codacy error
    
    public static final String FACEBOOK_POSTING_ENDPOINT = 'https://graph.facebook.com/'; // NOPMD - correct naming convension, suppressed codacy error
    public static final String TWITTER_POST_ENDPOINT = 'https://api.twitter.com/1.1/statuses/update.json?status='; // NOPMD - correct naming convension, suppressed codacy error
    public static final String LINKEDIN_POST_ENDPOINT = 'https://api.linkedin.com/v2/ugcPosts'; // NOPMD - correct naming convension, suppressed codacy error
    
	public static final String SLACK_UNFURL_CLIENT_ID = '411869716676.415101245410'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String SLACK_UNFURL_CLIENT_SECRET = '9f2c43fdeab31890799783e2b5833330'; // NOPMD - correct naming convension, suppressed codacy error

	public static final String GOOGLE_CALENDAR_CLIENT_ID = '305062543529-g8bt3b2kfs63mrfb0360ehrqgmtqdgee.apps.googleusercontent.com'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String GOOGLE_CALENDAR_CLIENT_SECRET = 'OeFOIw12JqtltnS7n0g8Qzt4'; // NOPMD - correct naming convension, suppressed codacy error

	public static final String BOX_CLIENT_ID = 'adnbssmrpihybholqr6q38fhtt6y1npm'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String BOX_CLIENT_SECRET = '8wTIucraMhUHgkEaZXmQMsdOlIPZLw9F'; // NOPMD - correct naming convension, suppressed codacy error

	//Added these keys for backword competibility
	public static final String ADSI_CLIENT_ID = 'cfca14ca-05d2-4e5e-830f-10a54e1574cf'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String ADSI_CLIENT_SECRET = 'Ljt/MJXLOx53pI8JbG2wS40uezlJkIXQs7y6vgZCYDY='; // NOPMD - correct naming convension, suppressed codacy error

	public static final String ACTIVE_DIRECTORY_CLIENT_ID = 'edb63807-54f7-4c86-a43c-c32ecc478567'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String ACTIVE_DIRECTORY_CLIENT_SECRET = 'G6S8Q~YemSSG.gzcTIrCdPCao6FZZZlFMBcs3cP9'; // NOPMD - correct naming convension, suppressed codacy error

	public static final String OUTLOOK_CALENDAR_CLIENT_ID = 'dummy_client_id'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String OUTLOOK_CALENDAR_CLIENT_SECRET = 'dummy_client_secret'; // NOPMD - correct naming convension, suppressed codacy error

	public static final String ATLASSIAN_CLIENT_ID = 'F37KdYLzRkRIhRkqyZfu5vI85HE2csC4'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String ATLASSIAN_CLIENT_SECRET = 'Dummy'; // NOPMD - correct naming convension, suppressed codacy error
    public static final String GOOGLE_DRIVE_TYPE_MYDRIVE = 'mydrive'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String GOOGLE_DRIVE_TYPE_SHARED_DRIVE = 'shareddrive'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String ACCESS_TOKEN = 'access_token'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String REFRESH_TOKEN ='refresh_token'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String EXPIRES_IN = 'expires_in'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String ERROR = 'error'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String GRANT_TYPE = 'grant_type'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String CONTENT_TYPE = 'Content-Type'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String URL_ENCODED_FORM = 'application/x-www-form-urlencoded'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String CLIENT_ID = 'client_id'; // NOPMD - correct naming convension, suppressed codacy error
	public static final string CLIENT_SECRET = 'client_secret'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String COMPLETED = 'Completed'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String AUTHORIZATION = 'Authorization'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String CONTNENT_TYPE_JSON = 'application/json'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String POST_ALERT_TO_EXTERNAL_APP = 'alert'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String POST_SITE_FEED_CONTENT = 'siteFeedContent'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String ZEUS_IDENTITY_CLIENT_ID_DEV = '524c3b49-567f-4634-b57e-c7390b2bdc2d'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String ZEUS_IDENTITY_CLIENT_SECRET_DEV = 'RhBxkggC4HsQnvNbXO3LKFzg1uhFi8o'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String ZEUS_IDENTITY_CLIENT_ID_QA = '99525dc4-c2a3-48bf-97d8-99f2797f7b9d'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String ZEUS_IDENTITY_CLIENT_SECRET_QA = '6M1Dz11mJy2IxlNJyHzsPoE5D9a3CwRu'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String ZEUS_IDENTITY_CLIENT_ID_PROD = '49d48f58-d3ec-45cc-8e56-7e631d2db8ee'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String ZEUS_IDENTITY_CLIENT_SECRET_PROD = '4XUWtwFXd3F5G3GEPojc6SMnM0hekWtR'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String ZEUS_HEADER_ACCOUNT_ID = 'x-smtip-tid'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String ZEUS_HEADER_USER_ID = 'x-smtip-uid'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String ZEUS_HEADER_APP = 'x-smtip-app'; // NOPMD - correct naming convension, suppressed codacy error
	public static final String ZEUS_APP_TYPE_ODIN = 'odin'; // NOPMD - correct naming convension, suppressed codacy error

	public static final Map<String, String> TOKEN_ENDPOINT_MAP = new Map<String, String> {
    		INTEGRATION_TYPE_BOX => '',
    		INTEGRATION_TYPE_GDRIVE => 'https://accounts.google.com/o/oauth2/token',
    		INTEGRATION_TYPE_DROPBOX => 'https://api.dropboxapi.com/oauth2/token',
    		INTEGRATION_TYPE_SHAREPOINT => 'https://login.microsoftonline.com/common/oauth2/token',
    		INTEGRATION_TYPE_ONEDRIVE => 'https://login.microsoftonline.com/common/oauth2/token',
	    	INTEGRATION_TYPE_ADSI => 'https://login.microsoftonline.com/common/oauth2/token',
	    	INTEGRATION_TYPE_FACEBOOK => 'https://graph.facebook.com/v2.10/oauth/access_token',
	    	INTEGRATION_TYPE_LINKEDIN => 'https://www.linkedin.com/oauth/v2/accessToken'
			
    };

	public static final List<String> ENTERPRISE_SEARCH_INTEGRATION_NAME_LIST = new List<String>{
		'enterpriseSearch1', 'enterpriseSearch2', 'enterpriseSearch3', 'enterpriseSearch4', 'enterpriseSearch5'
	};

	public static final Set<String> calendarTypes = new Set<String> { 'googlecalendar', 'outlookcalendar' };
}