public with sharing class EFSConstants { 	
	public static final String SHAREPOINT_FULL_SEARCH_CLIENT_ID = '72e22fb7-3ef7-4233-9171-54caef8a5e19';
	
	public static final String SHAREPOINT_ONEDRIVE_CLIENT_ID = '4c0b387a-9697-476e-996c-1e93560b32fa';
	public static final String SHAREPOINT_ONEDRIVE_CLIENT_SECRET = 'pkNupspKm2ucmus9zameikPeNIlpN3rBM4hqo/ShI8o=';
	public static final String BOX_CLIENT_ID = 'adnbssmrpihybholqr6q38fhtt6y1npm';
	public static final String BOX_CLIENT_SECRET = '8wTIucraMhUHgkEaZXmQMsdOlIPZLw9F';
    public static final String DROPBOX_ADMIN_CLIENT_ID = '8g0dhbfyzsyl16j';
	public static final String DROPBOX_ADMIN_CLIENT_SECRET = '2kgru84ub30q29y';
	public static final String DROPBOX_USER_CLIENT_ID = '7xhz9hzs25f2mre';
	public static final String DROPBOX_USER_CLIENT_SECRET = 'nawxgrh5pqy985i';
    public static final String GOOGLEDRIVE_CLIENT_ID = '305062543529-g8bt3b2kfs63mrfb0360ehrqgmtqdgee.apps.googleusercontent.com';
	public static final String GOOGLEDRIVE_CLIENT_SECRET = 'OeFOIw12JqtltnS7n0g8Qzt4';

	public static final String GOOGLE_SEARCH = SimpplrContext.simpplrAPIEndpoint + '/gsuite/search?action=search';

    public static final Set<String> integrationStates = new Set<String> {
    	'box', 'gdrive', 'dropbox', 'sharepoint', 'onedrive', 
    	'boxadmin', 'gdriveadmin', 'dropboxadmin', 'sharepointadmin', 'onedriveadmin'
    };

    public static final Set<String> storageTypes = new Set<String> { 'box', 'googledrive', 'gdrive', 'dropbox', 'sharepoint', 'onedrive' };
    public static final Set<String> simpplrManagedStorages = new Set<String> { 'box', 'gdrive', 'dropbox' };
    public static final Set<String> clientManagedStorages = new Set<String> { 'sharepoint', 'onedrive' };
    
    public static final String DROPBOX_NOT_CONNECTED_DOWNLOAD_ERROR = 'Could not download File - please connect' + 
    															  'your Dropbox account';
    public static final String GDRIVE_ADMIN_SCOPE = ' https://www.googleapis.com/auth/admin.directory.group';
    public static final String GDRIVE_EXTRAURL = '';
    public static final Map<String,String> EFS_STORAGE_TYPE_MAP = new Map<String,String>{'box'=>'Box','gdrive'=>'Google Drive','dropbox' => 'Dropbox'};
    public static final Map<String,String> EFS_SYSTEM_FOLDERS_MAP = new Map<String,String>{
    														'box'=>'Box Files',
    														'gdrive'=>'Google Drive Files',
    														'dropbox' => 'Dropbox Files',
    														'sharepoint' => 'SharePoint Files',
    														'onedrive' => 'OneDrive Files'};
    														            
    public static final String ACCESS_EXPIRED_MESSAGE = 'Your Access Expired. Please reconnect.';
    
	public static final Set<String> GDRIVE_DOWNLOADABLE_TYPES = new Set<String> {
		'VND.GOOGLE-APPS.DOCUMENT',
		'VND.GOOGLE-APPS.DRAWING',
		'VND.GOOGLE-APPS.PRESENTATION',
		'VND.GOOGLE-APPS.SPREADSHEET'
	};
	
	public static final Map<String, String> DPtoApexKeywordsMap = new Map<String, String> {
		'.tag' => 'tag',
		'group' => 'grp',
		'list' => 'listItem'
	};
	
	public static final Map<String, String> MSAPItoApexKeywordsMap = new Map<String, String> {
		'@microsoft.graph.downloadUrl' => 'downloadUrl',
		'@odata.type' => 'type'
	};

	public static final Map<String, String> SearchTypetoProviderMap = new Map<String, String> {
		'GoogleDriveFile' => 'googledrive',
		'DropboxFile' => 'dropbox',
		'SharePointFile' => 'sharepoint',
		'OneDriveFile' => 'onedrive'
	};
		
	public static final String userCancelledAuthMsg = 'The user chose not to give your app access to their Dropbox account.';
	
	public static String getConnectErrorMessage(String storStr) {
		return 'You must first connect your ' + storageCamelCaseMap.get(storStr) + ' account';
	}
	
	public static final Map<String, String> storageCamelCaseMap = new Map<String, String> {
		'gdrive' => 'Google Drive',
		'dropbox' => 'Dropbox',
		'box' => 'Box',
		'sharepoint' => 'SharePoint',
        'onedrive' => 'OneDrive',
        'googledrive' => 'Google Drive'
    };

    public static final String GOOGLE_API_ADD_GROUP_MEMBER = SimpplrContext.simpplrAPIEndpoint + '/gsuite/group-manager?action=addMemberToGroup';

}