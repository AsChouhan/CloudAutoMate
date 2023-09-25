public with sharing class MSAPIDriveItem {
    String baseUrl = 'https://graph.microsoft.com/v1.0/drives/';
    String baseUrlBeta = 'https://graph.microsoft.com/beta/drives/';
    String driveId;
    String itemId;
	MSAPIClient client;
	
	public MSAPIDriveItem(MSAPIClient clientObj) {
		this.client = clientObj;
	}
	
	// Getter and Setter  Methods
	public MSAPIClient getClient() { return this.client; }
	public MSAPIDriveItem setClient(MSAPIClient clientObj) {
		this.client = clientObj;
		return this;
	}
	
	// Create folder
	public class CreateFolder extends SCoreClient.AbstractClientRequest {
  		public CreateFolder(MSAPIDriveItem driveItemObj, String driveId, String parentItemId, 
  				MSAPIModelDriveItem.CreateFolderArg folderObj) {
			super(driveItemObj.getClient(), 
					driveItemObj.baseUrl + driveId + 
						(String.isBlank(parentItemId) ? 
							'/root' : 
							(parentItemId.startswith('/root') ? 
								parentItemId.replaceAll('%3A',':') + ':' : 
								'/items/'+parentItemId)) + 
						'/children',
				  	'POST', 
				  	folderObj, 
				  	new SCoreJsonDeserializer(MSAPIModelDriveItem.class, EFSConstants.MSAPItoApexKeywordsMap));
		}
	}

	// Get driveitem
	public class GetItem extends SCoreClient.AbstractClientRequest { 
  		public GetItem (MSAPIDriveItem driveItemObj, String driveId, String itemId) {
			super(driveItemObj.getClient(), 
					driveItemObj.baseUrl + driveId + (itemId == 'root' ? '/root' : '/items/' + itemId), 
				  	'GET', 
				  	null, 
				  	new SCoreJsonDeserializer(MSAPIModelDriveItem.class, EFSConstants.MSAPItoApexKeywordsMap));
		}
	}
		
	// List driveItem children 
	public class ListChildren extends SCoreClient.AbstractClientRequest {
  		public ListChildren (MSAPIDriveItem driveItemObj, String driveId, String itemId) {
			super(driveItemObj.getClient(), 
					driveItemObj.baseUrl + driveId +'/items/' + itemId + '/children', 
				  	'GET', 
				  	null,  
				  	new SCoreJsonDeserializer(MSAPIModelDriveItem.MSAPIModelDriveItemList.class, EFSConstants.MSAPItoApexKeywordsMap));
		}
	}
	
	// List driveItem children 
	public class Move extends SCoreClient.AbstractClientRequest {
  		public Move (MSAPIDriveItem driveItemObj, String driveId, String itemId, 
  				MSAPIModelDriveItem.MoveItemArg itemArg) {
			super(driveItemObj.getClient(), 
					driveItemObj.baseUrl + driveId + '/items/' + itemId, 
				  	REQUEST_METHOD_PATCH, 
				  	itemArg,  
				  	new SCoreJsonDeserializer(MSAPIModelDriveItem.MSAPIModelDriveItemList.class, null));
		}
	}
	
	// download driveitem /file content 
	public class DownloadDriveItem extends SCoreClient.AbstractClientRequest {
  		public DownloadDriveItem(MSAPIDriveItem driveItemObj) {
			super(driveItemObj.getClient(), 
					driveItemObj.baseUrl + driveItemObj.driveId + '/items/' + 
  					driveItemObj.itemId +'/content', 
				  	'GET', 
				  	null, 
				  	new SCoreJsonDeserializer(MSAPIModelDriveItem.class, EFSConstants.MSAPItoApexKeywordsMap));
		}
	}
	
	// Uploading a file
	public class UploadFile extends SCoreClient.AbstractClientRequest {
  		public UploadFile(MSAPIDriveItem driveItemObj, String parentId, String fileName) {
			super(driveItemObj.getClient(), 
					driveItemObj.baseUrl + driveItemObj.driveId + '/items/' + 
  					parentId +':/'+ fileName +':/content', 
				  	'PUT', 
				  	null, 
				  	new SCoreJsonDeserializer(MSAPIModelDriveItem.class, null));
		}
		
	}
	
	// List driveitem versions 
	public class GetDriveItemVersions extends SCoreClient.AbstractClientRequest {
  		public GetDriveItemVersions(MSAPIDriveItem driveItemObj, String driveId, String itemId) {
			super(driveItemObj.getClient(), 
					driveItemObj.baseUrl + driveId + '/items/' + itemId +'/versions', 
				  	'GET', 
				  	null, 
				  	new SCoreJsonDeserializer(MSAPIModelDriveItemVersionContainer.class, EFSConstants.MSAPItoApexKeywordsMap));
		}
	}
	
	// Get driveitem version 
	public class GetVersion extends SCoreClient.AbstractClientRequest {
  		public GetVersion(MSAPIDriveItem driveItemObj, String versionId) {
			super(driveItemObj.getClient(), 
					driveItemObj.baseUrl + driveItemObj.driveId + '/items/' + 
  					driveItemObj.itemId +'/versions/' + versionId, 
				  	'GET', 
				  	null, 
				  	new SCoreJsonDeserializer(MSAPIModelDriveItemVersionContainer.MSIAPIModelDriveItemVersion.class, EFSConstants.MSAPItoApexKeywordsMap));
		}
	}
	
	public class DeleteDriveItem extends SCoreClient.AbstractClientRequest {
  		public DeleteDriveItem(MSAPIDriveItem driveItemObj, String driveId, String itemId) {
			super(driveItemObj.getClient(), 
					driveItemObj.baseUrl + driveId + '/items/' + itemId, 
				  	'DELETE', 
				  	null, 
				  	new SCoreJsonDeserializer(null, null));
		}
		
		public Object executePatch() {
		    HttpRequest req = this.buildHttpRequest(); 
		    req.setBody('');
		    req.setHeader('X-HTTP-Method-Override','PATCH');
		    
		    logger.logDebug('HTTP Request' + req + ' containing body [' + req.getbody() + ']');
		    
		    HttpResponse httpResponse = new Http().send(req);
		    Integer statusCode = httpResponse.getStatusCode();
		    String status = httpResponse.getStatus();
		    logger.logDebug('HTTP Response' + status + '[' + httpResponse.getBody() + ']');
		    if (statusCode >= SCoreAppException.ERROR_HTTP_BAD_REQUEST) 
		    {
		        throw new SCoreAppException(statusCode, status);
		    }
		    
			return (MSAPIModelDriveItem)this.parse(httpResponse);
		}
		
	}
	
	public class SearchDriveItem extends SCoreClient.AbstractClientRequest {
  		public SearchDriveItem(MSAPIDriveItem driveItemObj, String searchTerm) {
			super(driveItemObj.getClient(), 
					driveItemObj.baseUrl + driveItemObj.driveId + '/items/' +
						'/root/search/(q={'+ searchTerm +'})', 
				  	'GET', 
				  	null, 
				  	new SCoreJsonDeserializer(MSAPIModelDriveItemVersionContainer.MSIAPIModelDriveItemVersion.class, EFSConstants.MSAPItoApexKeywordsMap));
		}
	}
	
	//Update driveItem 
	public class UpdateDriveItem extends SCoreClient.AbstractClientRequest {
  		public UpdateDriveItem (MSAPIDriveItem driveItemObj, String driveId, String itemId, 
  				MSAPIModelDriveItem.UpdateItemArg itemArg) {
			super(driveItemObj.getClient(), 
					driveItemObj.baseUrl + driveId +
						(String.isBlank(itemId) ? 
							'/root' : 
							(itemId.startswith('/root') ? 
								itemId.replaceAll('%3A',':') : 
								'/items/'+itemId)),
				  	REQUEST_METHOD_PATCH, 
				  	itemArg,  
				  	new SCoreJsonDeserializer(MSAPIModelDriveItem.class, null));
		}
	}
	
	// Restore Folder
	public class RestoreVersion extends SCoreClient.AbstractClientRequest {
  		public RestoreVersion(MSAPIDriveItem driveItemObj, String driveId, String itemId, 
  				String versionId,
  				MSAPIModelDriveItem.CreateFolderArg folderObj) {
			super(driveItemObj.getClient(), 
					driveItemObj.baseUrl + driveId + 
						(String.isBlank(itemId) ? 
							'/root' : 
							(itemId.startswith('/root') ? 
								itemId.replaceAll('%3A',':') + ':' : 
								'/items/'+itemId)) + 
  						'/versions/' + versionId + '/restoreVersion', 
				  	'POST', 
				  	null, 
				  	new SCoreJsonDeserializer(null, null));
		}
	}
	
	//Update driveItem 
	public class GetPreview extends SCoreClient.AbstractClientRequest {
  		public GetPreview (MSAPIDriveItem driveItemObj, String driveId, String itemId) {
			super(driveItemObj.getClient(), 
					driveItemObj.baseUrlBeta + driveId + '/items/' + itemId + '/preview', 
				  	'POST', 
				  	null,  
				  	new SCoreJsonDeserializer(MSAPIModelDriveItem.Preview.class, null));
		}
	}
}