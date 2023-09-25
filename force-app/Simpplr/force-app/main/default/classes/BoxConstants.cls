public with sharing class BoxConstants {
	
	//-------------------------Labels For Box.com integration -----------------------------------
 	public static final String BOX_FOLDER_NOT_SELECTED_ERROR = 'Please select a folder';
 	public static final String BOX_FOLDER_BLANK_ERROR = 'Folder name can not be blank !';
 	public static final String BOX_FOLDER_CHANGE_NAME_SUCCESS = 'Folder renamed successfully!';
 	public static final String BOX_FOLDER_NAME_SIMILAR = 'New name is similar to previous name';
 	public static final String BOX_FOLDER_VALID_NAME_ERROR = 'Please enter a valid Folder name';
 	public static final String BOX_ALL_COMPANY_GROUP_TYPE = 'BOX_ALL_COMPANY_GROUP_ID';
 	public static final String BOX_ADMIN_GROUP_TYPE = 'BOX_ADMIN_GROUP_ID';
 	public static final String BOX_MEMBER_GROUP_TYPE = 'BOX_MEMBER_GROUP_ID';
 	public static final String BOX_MEMBERSHIP_INFO = 'BOX_MEMBERSHIP_INFO';
 	public static final String BOX_HOST = 'https://api.box.com/2.0';
 	public static final String BOX_GROUP_REQUEST_URL = 'groups';
 	public static final String BOX_GROUP_MEMBER_REQUEST_URL = 'group_memberships';
 	public static final String BOX_GROUP_FOLDER_REQUEST_URL = 'folders';
 	public static final String BOX_SEARCH_REQUEST_URL = 'search';
 	public static final String BOX_GROUP_COLLABORATION_REQUEST_URL = 'collaborations';
 	public static final String BOX_GROUP_DESCRIPTION = 'This Group is created by simpplr. Please do not delete or change any setting of this group. This may change application behaviour';
 	public static final String BOX_READ_ONLY_PERMISSION='viewer';
 	public static final String BOX_READ_WRITE_PERMISSION='editor';
 	//-------------------------A Set For Box.com status code-----------------------------------------
 	public static final set<Integer> BOX_ERROR_CODE_SET = new  set<Integer>{
 																		400,401,403,404,405,409,412,429,500,503
 																	};
	public static final set<Integer> BOX_SUCCESS_CODE_SET = new  set<Integer>{
 																		200,201,204
 																	}; 
	public static final String BOX_EMPTY_SUCCESS_RESPONSE = 'SUCCESS WITH NO RESPONSE'; 	
	public static final String BOX_CURRENT_USER_IS_NOT_CONNECTED = 'Current logged in user is not connected with box service';																																	
 	
 	public static final String BOX_FOLDER_TYPE_LABEL = 'Box';
 	public static final String BOX_ADMIN_SETUP_NOT_DONE = 'Admin setup is not yet done, Please contact your App Manager';
 	public static final String BOX_API_EXCEPTION = 'Unable to connect to your box account, Please contact your App Manager';
 	public static final String BOX_NOT_CONNECTED = 'You are not connected to Box account, Box content will not be accessible';
 	public static final String BOX_NOT_CONNECTED_DOWNLOAD_ERROR = 'Could not download File - please connect your Box account';
 	public static final String BOX_FOLDER_LINK_SUCCESS = 'Folder linked successfully';
 	public static final String BOX_FOLDER_UNLINK_SUCCESS = 'Folder unlinked successfully';
 	public static final String BOX_FOLDER_ALREADY_LINKED = 'Folder is already linked';
 	public static final String BOX_FOLDER_ALREADY_UNLINKED = 'Folder is already unlinked';
 	public static final String BOX_UNAUTHORIZED_USER = 'You are not authorized to access this resource';
 	public static final String BOX_FILE_SHARE_MESSAGE = 'has shared the document {0} from box';
 	public static final String BOX_FOLDER_UNLINK_ALL_FOLDERS_FOR_USER = 'Folders linked by you across all sites will be unlinked. Are you sure you want to continue?';
 	public static final String BOX_ROOT_FOLDER_NAME = 'Box Files';
 	public static final String BOX_NON_ENTERPRISE_ACCOUNT = 'Non enterprise accounts are currently not supported';
 	public static final String BOX_NON_OFFICIAL_BOX_ACCOUNT = 'It seems you are not using official account, please contact your App Manager for more details';
 	public static final String BOX_ADMIN_NOT_CONNECTED = 'Service User has not connected yet, please contact your App Manager for more details';
 	public static final String BOX_SERVICE_USER_FROM_DIFFERENT_ENTERPRISE = 'New service account does not belong to same enterprise';
 	public static final String BOX_FOLDER_TRASHED_ERROR = 'Folder is no longer available';
 	public static final String BOX_SERVICE_ACCOUNT_DISCONNECTED_ERROR = 'The service account for your box admin has disconnected, Please contact your App Manager';
 	public static final String BOX_SERVICE_ACCOUNT_PERMISSION_ERROR = 'Service account used does not has required permissions to create group in Box';
 	public static final String BOX_PERMISSION_ERROR = 'You do not have required permissions to complete this operation';
 	
 	public static final String UNEXPECTED_ERROR = 'Some unexpected error occurred !!';
 	
    public static final String BOX_OAUTH_END_POINT_URL = 'https://www.box.com/api/oauth2/token';
    public static final String INT_POST = 'POST';
 	public static final String INT_GET = 'GET';
 	public static final String INT_DELETE = 'DELETE';
 	public static final String INT_PUT = 'PUT';
    
    
}