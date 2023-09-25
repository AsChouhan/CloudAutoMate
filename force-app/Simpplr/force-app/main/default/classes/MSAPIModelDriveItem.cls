public with sharing class MSAPIModelDriveItem {
	public String id;
	public String name; 
	public String description;
	public File file;
	public Long size;
	public Folder folder;
	public SharePointIds sharepointIds;
	public String webDavUrl;
	public MSAPIModelUser.IdentitySet createdBy;
	public MSAPIModelUser.IdentitySet lastModifiedBy;
	public List<MSAPIModelDriveItem> children;
	public List<MSAPIModelDriveItem> value;
	public String childrenNextLink;
	public ThumbnailSet thumbnails;
	public List<MSAPIModelPermission> permissions;
	public String createdDateTime; 
	public Datetime lastModifiedDateTime; 
	public ItemReference parentReference; 
	public String webUrl; 
	public List<Version> versions;
	public String downloadUrl; 
	public MSAPIModelDriveItem remoteItem;
	
	//private ODataWrapper audio;
	//private ODataWrapper content;
	//private String cTag;
	//private ODataWrapper deleted;
	//private ODataWrapper fileSystemInfo;
	//private Image image;
	
	//private ODataWrapper location;//to bedel
	//private ODataWrapper malware;//
	//private ODataWrapper packageName;//
	//private ODataWrapper photo;//
	//private ODataWrapper remoteItem;
	//private ODataWrapper root;
	//private ODataWrapper searchResult;
	//private ODataWrapper shared;
	//private ODataWrapper specialFolder;
	//private ODataWrapper video;
	//private List<ODataWrapper> activities;
	//private ODataWrapper createdBy; 
	//private String eTag; 
	//private ODataWrapper lastModifiedBy; 

	
	public class CreateFolderArg extends SCoreAbstractJsonSerializable {
		public String name;
		public Folder folder;
	}
	
	public class MoveItemArg extends SCoreAbstractJsonSerializable {
		public ItemReference parentReference;
		public String name;
	}
	
	public class UpdateItemArg extends SCoreAbstractJsonSerializable {
		public String name;
	}
	
	public class File{
		public String mimeType;
	}
	
	public class Folder {
		public Integer childCount;
	}
	
	public class ItemReference {
		public String id;
		public String driveId;
		public String driveType;
		public String name;
		public String path;
		public String shareId;
		public SharePointIds sharepointIds;
	}
	
	public class SharePointIds{
		public String listId;
		public String listItemId;
		public String listItemUniqueId;
		public String siteId;
		public String siteUrl;
		public String webId;
	}
	
	public class ThumbnailSet {
		public String id;
		public Thumbnail large;
		public Thumbnail medium;
		public Thumbnail small;
		public Thumbnail source;
	}	
	
	
	public class Thumbnail {
		public String url;
		public String sourceItemId;
	}
	
	public class Version{
		public String id;
	}
	
	public class Preview {
		public String getUrl;
		public String postParameters;
		public String postUrl; 
	}
	
	public class SearchResult{
		public List<SearchResultItem> responses;
	}

	public class FullSearchResult{
		public List<MSAPIModelDriveItem> result; 
		public Integer totalItem;
		public String nextPageToken;
	}

	public class AWSSearchResult{
		public List<MSAPIModelDriveItem> result; 
		public String totalItem;
		public String nextPageToken;
	}
	
	public class SearchResultItem{
		public String id;
		public Integer status;
		public SearchBody body;
	}
	
	public class SearchBody {
		public List<MSAPIModelDriveItem> value; 
	}
	
	public class UIOnedriveLinkingResponse{
		public string id;
		public string driveId;
		public string name;
		public Criteria.OwnerWrapper owner;
		public string path;
		public String webUrl;
	}
}