public with sharing class MSAPIDrive {
    MSAPIClient client;
		
	public MSAPIDrive(MSAPIClient msc) {
		this.client = msc;
	}
	
	// Getter and Setter  Methods
	public MSAPIClient getClient() { return this.client; }
	public MSAPIDrive setClient(MSAPIClient msc) {
		this.client = msc;
		return this;
	} 
	
	// Get Current User Drive detail(Get current user's OneDrive)
	public class CurrentUserDriveDetail extends SCoreClient.AbstractClientRequest {
  		public CurrentUserDriveDetail(MSAPIDrive drive) {
			super(drive.getClient(), 
				  'https://graph.microsoft.com/v1.0/me/drive', 
				  'GET', 
				  null, 
				  new SCoreJsonDeserializer(MSAPIModelDrive.class, null));
		}
	}
	
	//Get a user's OneDrive
	
	public class UserDriveDetail extends SCoreClient.AbstractClientRequest {
  		public UserDriveDetail(MSAPIDrive drive, String userId) {
			super(drive.getClient(), 
				  'https://graph.microsoft.com/v1.0/users/'+userId+'/drive', 
				  'GET', 
				  null, 
				  new SCoreJsonDeserializer(MSAPIModelDrive.class, null));
		}
	}
	
	//Get the document library for a site
	
	public class SiteDriveDetail extends SCoreClient.AbstractClientRequest {
  		public SiteDriveDetail(MSAPIDrive drive, String siteId) {
			super(drive.getClient(), 
				  'https://graph.microsoft.com/v1.0/sites/'+siteId+'/drive', 
				  'GET', 
				  null, 
				  new SCoreJsonDeserializer(MSAPIModelDrive.class, null));
		}
	}
	
	
	// Get Drive detail by drive id
	public class DriveDetail extends SCoreClient.AbstractClientRequest {
  		public DriveDetail(MSAPIDrive drive, String driveId) {
			super(drive.getClient(), 
				  'https://graph.microsoft.com/v1.0/drives/'+driveId, 
				  'GET', 
				  null, 
				  new SCoreJsonDeserializer(MSAPIModelDrive.class, null));
		}
	}
	
	// List a site's drives
	public class SiteDriveListing extends SCoreClient.AbstractClientRequest {
  		public SiteDriveListing(MSAPIDrive drive, String siteId) {
			super(drive.getClient(), 
				  'https://graph.microsoft.com/v1.0/sites/'+siteId+'/drives', 
				  'GET', 
				  null, 
				  new SCoreJsonDeserializer(MSAPIModelDrive.MSSiteDriveListing.class, EFSConstants.MSAPItoApexKeywordsMap));
		}
	}
	
	// List a user's drives
	public class UserDriveListing extends SCoreClient.AbstractClientRequest {
  		public UserDriveListing(MSAPIDrive drive, String userId) {
			super(drive.getClient(), 
				  'https://graph.microsoft.com/v1.0/users/'+userid+'/drives', 
				  'GET', 
				  null, 
				  new SCoreJsonDeserializer(MSAPIModelDrive.MSSiteDriveListing.class, EFSConstants.MSAPItoApexKeywordsMap));
		}
	}
	
	// List the current user's drives
	public class CurrentUserDriveListing extends SCoreClient.AbstractClientRequest {
  		public CurrentUserDriveListing(MSAPIDrive drive) {
			super(drive.getClient(), 
				  'https://graph.microsoft.com/v1.0/me/drives', 
				  'GET', 
				  null, 
				  new SCoreJsonDeserializer(MSAPIModelDrive.MSSiteDriveListing.class, EFSConstants.MSAPItoApexKeywordsMap));
		}
	}
	
	//List children of a driveItem
	public class DriveItemChildrenListing extends SCoreClient.AbstractClientRequest {
  		public DriveItemChildrenListing(MSAPIDrive drive, String driveId, String itemId, String sortBy) {
			super(drive.getClient(),
				  'https://graph.microsoft.com/v1.0/drives/' + driveId + 
				  	 + (String.isBlank(itemId) ? '/root' : (itemId.startswith('/root') ? itemId.replaceAll('%3A',':') : '/items/'+itemId)) + 
				  	'?$expand=children,permissions,versions'+getOrderByString(sortBy)
				  	,
				  'GET', 
				  null, 
				  new SCoreJsonDeserializer(MSAPIModelDriveItem.class, new Map<String, String>{'children@odata.nextLink'=> 'childrenNextLink'}));
		}

		public DriveItemChildrenListing(MSAPIDrive drive, String url, String sortBy) {
			super(drive.getClient(), 
				  url,
				  'GET', 
				  null, 
				  new SCoreJsonDeserializer(MSAPIModelDriveItem.class, new Map<String, String>{'@odata.nextLink'=> 'childrenNextLink'}));
		}
	}
	
	private static String getOrderByString(String sortBy){
		String orderBy = '';
		if(String.isNotBlank(sortBy)){
			if('createdOldest'.equalsIgnoreCase(sortBy)){
				orderBy += '&$orderby=createdDateTime';
			} else if('createdNewest'.equalsIgnoreCase(sortBy)){
				orderBy += '&$orderby=createdDateTime%20desc';
			} else if('modifiedOldest'.equalsIgnoreCase(sortBy)){
				orderBy += '&$orderby=lastModifiedDateTime';
			} else if('modifiedNewest'.equalsIgnoreCase(sortBy)){
				orderBy += '&$orderby=lastModifiedDateTime%20desc';
			} 
		}
		return orderBy;
	}
	
	//Current User Drives
	public class MyDrives extends SCoreClient.AbstractClientRequest {
  		public MyDrives(MSAPIDrive drive, String itemId) {
			super(drive.getClient(), 
				  'https://graph.microsoft.com/v1.0/me/drive' + ('me'.equalsIgnoreCase(itemId) ? '/root/children' : '/sharedWithMe'), 
				  'GET', 
				  null, 
				  new SCoreJsonDeserializer(MSAPIModelDrive.ItemListing.class, EFSConstants.MSAPItoApexKeywordsMap));
		}
	}

	//Searching the current user drive
	public class MyDriveSearch extends SCoreClient.AbstractClientRequest {
  		public MyDriveSearch(MSAPIDrive drive, String term) {
			super(drive.getClient(), 
				  'https://graph.microsoft.com/v1.0/me/drive/search(q=\'' + EncodingUtil.urlEncode(term,'UTF-8') + '\')', 
				  'GET', 
				  null, 
				  new SCoreJsonDeserializer(MSAPIModelDrive.ItemListing.class, EFSConstants.MSAPItoApexKeywordsMap));
		}
	}

	
	//List items shared with the signed-in user
	public class CurrentUserSharedDriveListing extends SCoreClient.AbstractClientRequest {
  		public CurrentUserSharedDriveListing(MSAPIDrive drive, String driveId, String itemId) {
			super(drive.getClient(), 
				  'https://graph.microsoft.com/v1.0/me/drive/sharedWithMe', 
				  'GET', 
				  null, 
				  new SCoreJsonDeserializer(MSAPIModelDriveItem.class, EFSConstants.MSAPItoApexKeywordsMap));
		}
	}
	
	//MS File Search batch request
	public class SearchMSFiles extends SCoreClient.AbstractClientRequest{
		public SearchMSFiles(MSAPIDrive drive, String searchTerm, Set<String> driveIdSet) {
			super(drive.getClient(),
			'https://graph.microsoft.com/v1.0/$batch', 
				  'POST', 
				  getSearchRequestJSONBody(searchTerm, driveIdSet), 
				  new SCoreJsonDeserializer(MSAPIModelDriveItem.SearchResult.class, EFSConstants.MSAPItoApexKeywordsMap)); 
		}
	}
	
	private static MSAPIModelDrive.BatchRequestList getSearchRequestJSONBody(String searchTerm, Set<String> driveIdSet){
		String searchRequestJSONBody = '';
		MSAPIModelDrive.BatchRequestList requListObj = new MSAPIModelDrive.BatchRequestList();
		requListObj.requests = new List<MSAPIModelDrive.BatchRequest>();
		Integer i=1 ;
		for(String driveId: driveIdSet){
			MSAPIModelDrive.BatchRequest brObj = new MSAPIModelDrive.BatchRequest();
			brObj.id= i+'';
			brObj.method='GET';
			brObj.url = '/drives/'+driveId+'/root/search(q='+'\''+ EncodingUtil.urlEncode(searchTerm,'UTF-8') +'\''+')';
			requListObj.requests.add(brObj);
			i++;
		}
		
		return requListObj;
	}
}