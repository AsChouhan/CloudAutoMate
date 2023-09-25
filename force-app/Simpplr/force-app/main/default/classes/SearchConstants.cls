public class SearchConstants {
	
    public static final String APIS_UPSERT = SimpplrContext.simpplrAPIEndpoint + '/search/index-data';
    public static final String ENCRYPT_ORG_ID = Utility.externalRequestAuthToken();
    public static final String REQUEST_METHOD_DELETE = 'aws_search/delete_aws_search_token';
	public static final String REQUEST_METHOD_CREATE = 'aws_search/get_token';
	public static final String REQUEST_METHOD_REGENERATE = 'aws_search/regenerate_aws_search_token';
	public static final String REQUEST_METHOD_UPLOAD_FILE_DATA = 'aws_search/upload_file';
	public static final String METADATA_ENDPOINT = 'https://connectedsearch.simpplr.com/';
	public static final String AWS_ANALYTICS_PUSH_VIEWS_DATA = 'https://connectedsearch.simpplr.com/aws_analytics/views_data?rat=';
	public static final String AWS_ANALYTICS_PUSH_BOOKMARK_DATA = 'https://connectedsearch.simpplr.com/aws_analytics/bookmark_data?rat=';
	public static final String AWS_ANALYTICS_CONTENT_FEED_DATA = 'https://connectedsearch.simpplr.com/aws_analytics/content_feed_data?rat=';
	public static final String AWS_ANALYTICS_CONTENT_SHARE_DATA = 'https://connectedsearch.simpplr.com/aws_analytics/content_share_data?rat=';
	public static final String AWS_ANALYTICS_CONTENT_USEFULL_DATA = 'https://connectedsearch.simpplr.com/aws_analytics/content_usefull_data?rat=';
	public static final String AWS_ANALYTICS_PEOPLE_FOLLOWERS_DATA = 'https://connectedsearch.simpplr.com/aws_analytics/people_followers_data?rat=';
	public static final String AWS_ANALYTICS_SEARCH_SELECT_DATA = 'https://connectedsearch.simpplr.com/aws_analytics/search_select_data?rat=';
	public static final String AWS_ANALYTICS_CONTENT_LIKE_DATA = 'https://connectedsearch.simpplr.com/aws_analytics/content_like_data?rat=';
	public static final String AWS_ANALYTICS_SITE_MEMBERS_DATA = 'https://connectedsearch.simpplr.com/aws_analytics/site_members_data?rat=';
    public static Map<String, List<String>> mapOfFileTypeToExtension {
        get{
            if (mapOfFileTypeToExtension == null) {
                Map<String, List<String>> mapOfTypeWithExtension = new Map<String, List<String>>();
                mapOfTypeWithExtension.put('pdf', new List<String>{'pdf'});
                mapOfTypeWithExtension.put('microsoft_office_excel', new List<String>{'xls', 'xlsx', 'xls_x'});
                mapOfTypeWithExtension.put('microsoft_office_document', new List<String>{'doc', 'docx', 'doc_x'});
                mapOfTypeWithExtension.put('microsoft_powerpoint', new List<String>{'ppt', 'pptx', 'ppt_x'});
                mapOfTypeWithExtension.put('text', new List<String>{'txt'});
                mapOfTypeWithExtension.put('png', new List<String>{'png'});
                mapOfTypeWithExtension.put('jpg', new List<String>{'jpg'});
                mapOfTypeWithExtension.put('jpeg', new List<String>{'jpg'});
                mapOfTypeWithExtension.put('rtf', new List<String>{'rtf'});
                mapOfTypeWithExtension.put('zip', new List<String>{'zip'});
                mapOfTypeWithExtension.put('csv', new List<String>{'csv'});
                return mapOfTypeWithExtension;
            } else {
                return mapOfFileTypeToExtension;
            }
        
        }
    }
}