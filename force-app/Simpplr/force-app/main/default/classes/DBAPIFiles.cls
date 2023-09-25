public with sharing class DBAPIFiles {
	public String mainEndpoint = 'https://api.dropboxapi.com/2/files/';
	
	DBAPIClient client;
	
	public DBAPIFiles(DBAPIClient dbc) {
		this.client = dbc;
	}
	
	// Getter and Setter Methods
	public DBAPIClient getClient() { return this.client; }
	public DBAPIFiles setClient(DBAPIClient gdc) {
		this.client = gdc;
		return this;
	}
	
	// Create Request - Method
	public CreateRequest getCreateRequest(String folder_name, Boolean renameFlag) {
  		DBAPIModelFiles.CreateFolderArg content = new DBAPIModelFiles.CreateFolderArg();
  		content.path = folder_name;
  		content.autorename = renameFlag;
  		
		return new CreateRequest(this, content);
	}
	
  	public class CreateRequest extends SCoreClient.AbstractClientRequest {
  		public CreateRequest(DBAPIFiles fil, DBAPIModelFiles.CreateFolderArg args) {
			super(fil.getClient(), fil.mainEndpoint + 'create_folder_v2', 'POST', args, new SCoreJsonDeserializer(DBAPIModelFiles.CreateFolderResult.class));
		}
	}

	// Delete Request - Method
	public DeleteRequest getDeleteRequest(String fpath) {  		
		return new DeleteRequest(this, fpath);
	}
	
  	public class DeleteRequest extends SCoreClient.AbstractClientRequest {
  		public DeleteRequest(DBAPIFiles fil, String path) {
			super(fil.getClient(), 
				  fil.mainEndpoint + 'delete_v2', 
				  'POST', 
				  new DBAPIModelFiles.OnlyPathArg(path), 
				  new SCoreJsonDeserializer(DBAPIModelFiles.DeleteResult.class, EFSConstants.DPtoApexKeywordsMap));
		}
  	}
	
	/*// Get Link Request - Method
	public TemporaryLinkRequest getTemporaryLinkRequest(String path) {
		return new TemporaryLinkRequest(this, path);
	}
	
  	public class TemporaryLinkRequest extends SCoreClient.AbstractClientRequest {
  		public TemporaryLinkRequest(DBAPIFiles fil, String path) {
			super(fil.getClient(), 
				  fil.mainEndpoint + 'get_temporary_link', 
				  'POST', 
				  new DBAPIModelFiles.OnlyPathArg(path), 
				  new SCoreJsonDeserializer(DBAPIModelFiles.GetTemporaryLinkResult.class, EFSConstants.DPtoApexKeywordsMap));
		}
	} */
	
	// List Request - Method
	public ListRequest getListRequest(DBAPIModelFiles.ListFolderArg content) {
		return new ListRequest(this, 'list_folder', content);
	}

	// List (continue) Request - Method
	public ListRequest getListRequest(String cursor) {
  		DBAPIModelGroup.DynamicContent content = new DBAPIModelGroup.DynamicContent();
  		content.tag_flag = false;
  		content.id_field = 'cursor';
  		content.id_value = cursor;
  		
		return new ListRequest(this, 'list_folder/continue', content);
	}
	
	// Get Revisions Request - Method
	public ListRequest getRevisionsRequest(String path, Integer revCount) {
		return new ListRequest(this, 'list_revisions', new DBAPIModelFiles.GetRevisionsArg(path, revCount));
	}	
	
  	public class ListRequest extends SCoreClient.AbstractClientRequest {
  		public ListRequest(DBAPIFiles fil, String url, DBAPIModelGroup.DynamicContent content) {
			super(fil.getClient(), 
				  fil.mainEndpoint + url, 
				  'POST', 
				  content, 
				  new SCoreJsonDeserializer(DBAPIModelFiles.ListResult.class, EFSConstants.DPtoApexKeywordsMap));
		}
		
  		public ListRequest(DBAPIFiles fil, String url, DBAPIModelFiles.ListFolderArg content) {
			super(fil.getClient(), 
				  fil.mainEndpoint + url, 
				  'POST', 
				  content, 
				  new SCoreJsonDeserializer(DBAPIModelFiles.ListResult.class, EFSConstants.DPtoApexKeywordsMap));
		}
		
  		public ListRequest(DBAPIFiles fil, String url, DBAPIModelFiles.GetRevisionsArg content) {
			super(fil.getClient(), 
				  fil.mainEndpoint + url, 
				  'POST', 
				  content, 
				  new SCoreJsonDeserializer(DBAPIModelFiles.ListRevisionResult.class, EFSConstants.DPtoApexKeywordsMap));
		}
	}
	
	// Get Metadata Request - Method
	public GetMetadataRequest getMetadataRequest(String path, Boolean mediaFlag) {
		DBAPIModelFiles.GetMetadataArg mArgs = new DBAPIModelFiles.GetMetadataArg();
		mArgs.path = path;
		mArgs.include_media_info = mediaFlag;
		
		return new GetMetadataRequest(this, mArgs);
	}
	
	public class GetMetadataRequest extends SCoreClient.AbstractClientRequest {
  		public GetMetadataRequest(DBAPIFiles fil, DBAPIModelFiles.GetMetadataArg content) {
			super(fil.getClient(), 
				  fil.mainEndpoint + 'get_metadata', 
				  'POST', 
				  content, 
				  new SCoreJsonDeserializer(DBAPIModelFiles.Metadata.class, EFSConstants.DPtoApexKeywordsMap));
		}
	}
	
	// Move Request - Method
	public MoveRequest getMoveRequest(String fpath, String tpath) {
  		DBAPIModelFiles.MoveArg content = new DBAPIModelFiles.MoveArg();
  		content.from_path = fpath;
  		content.to_path = tpath;
  		
		return new MoveRequest(this, content);
	}
	
  	public class MoveRequest extends SCoreClient.AbstractClientRequest {
  		public MoveRequest(DBAPIFiles fil, DBAPIModelFiles.MoveArg args) {
			super(fil.getClient(), 
				  fil.mainEndpoint + 'move_v2', 
				  'POST', 
				  args, 
				  new SCoreJsonDeserializer(DBAPIModelFiles.MoveResult.class, EFSConstants.DPtoApexKeywordsMap));
		}
	}
	
	public class SearchRequest extends SCoreClient.AbstractClientRequest {
  		public SearchRequest(DBAPIFiles fil, DBAPIModelFiles.SearchRequestParams args) {
			super(fil.getClient(), 
				  fil.mainEndpoint + 'search_v2', 
				  'GET',
				  args, 
				  new SCoreJsonDeserializer(DBAPIModelFiles.SearchResult.class, EFSConstants.DPtoApexKeywordsMap));
		}
	}

	public class SearchContinueRequest extends SCoreClient.AbstractClientRequest {
		public SearchContinueRequest(DBAPIFiles fil, DBAPIModelFiles.SearchRequestParams args) {
		  super(fil.getClient(), 
				fil.mainEndpoint + 'search/continue_v2', 
				'GET',
				args, 
				new SCoreJsonDeserializer(DBAPIModelFiles.SearchResult.class, EFSConstants.DPtoApexKeywordsMap));
	  }
  }
}