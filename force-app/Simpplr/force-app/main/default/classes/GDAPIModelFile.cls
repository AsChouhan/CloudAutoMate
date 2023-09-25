public with sharing class GDAPIModelFile extends GDAPIModelAbstract {
	public static final String KIND_DRIVE_FILE = 'drive#file';
	
	// Instance Variables
	private String id;										//The ID of the file.(writable)
	private String name;									//The name of the file. This is not necessarily unique within a folder. Note that for immutable items such as the top level folders of Team Drives, My Drive root folder, and Application Data folder the name is constant.(writable)
//	public String folderId { get; set; }					// Custom field added for Simpplr
//	public String folderName { get; set; }					// Custom field added for Simpplr
	private String mimeType;								//The MIME type of the file.Drive will attempt to automatically detect an appropriate value from uploaded content if no value is provided. The value cannot be changed unless a new revision is uploaded. If a file is created with a Google Doc MIME type, the uploaded content will be imported if possible. The supported import formats are published in the About resource.(writable)
	private String description;								//A short description of the file.(writable)
	private Boolean starred;								//Whether the user has starred the file.(writable)
	private Boolean trashed;								//Whether the file has been trashed, either explicitly or from a trashed parent folder. Only the owner may trash a file, and other users cannot see files in the owner's trash.(writable)
	private Boolean explicitlyTrashed;						//Whether the file has been explicitly trashed, as opposed to recursively trashed from a parent folder

	private List<String> parents;							//The IDs of the parent folders which contain the file.If not specified as part of a create request, the file will be placed directly in the My Drive folder. Update requests must use the addParents and removeParents parameters to modify the values.(writable)

	private Map<String, String> properties;					//A collection of arbitrary key-value pairs which are visible to all apps. Entries with null values are cleared in update and copy requests.(writable)
	private Map<String, String> appProperties;				//A collection of arbitrary key-value pairs which are private to the requesting app. Entries with null values are cleared in update and copy requests.(writable)

	private List<String> spaces;							//The list of spaces which contain the file. The currently supported values are 'drive', 'appDataFolder' and 'photos'.
	private Integer version;								//A monotonically increasing version number for the file. This reflects every change made to the file on the server, even those not visible to the user
	private String webContentLink;							//A link for downloading the content of the file in a browser. This is only available for files with binary content in Drive
	private String webViewLink;								//A link for opening the file in a relevant Google editor or viewer in a browser
	private String iconLink;								//A static, unauthenticated link to the file's icon
	private String thumbnailLink;							//A short-lived link to the file's thumbnail, if available. Typically lasts on the order of hours. Only populated when the requesting app can access the file's content
	private Boolean viewedByMe;								//Whether the file has been viewed by this user
	private Datetime viewedByMeTime;						//The last time the file was viewed by the user (RFC 3339 date-time).(writable)
	private Datetime createdTime;							//The time at which the file was created (RFC 3339 date-time).(writable)
	private Datetime modifiedTime;							//The last time the file was modified by anyone (RFC 3339 date-time).Note that setting modifiedTime will also update modifiedByMeTime for the user.(writable)
	private Datetime modifiedByMeTime;						//The last time the file was modified by the user (RFC 3339 date-time)
	private Datetime sharedWithMeTime;						//The time at which the file was shared with the user, if applicable (RFC 3339 date-time)
	
	private GDAPIModelUser sharingUser;						//The user who shared the file with the requesting user, if applicable
	private GDAPIModelUser[] owners;						//The owners of the file. Currently, only certain legacy files may have more than one owner. Not populated for Team Drive files
	private GDAPIModelUser lastModifyingUser;				//The last user to modify the file

	private Boolean shared;									//Whether the file has been shared. Not populated for Team Drive files
	private Boolean ownedByMe;								//Whether the user owns the file. Not populated for Team Drive files
	private Boolean viewersCanCopyContent;					//Whether users with only reader or commenter permission can copy the file's content. This affects copy, download, and print operations.(writable)
	private Boolean writersCanShare;						//Whether users with only writer permission can modify the file's permissions. Not populated for Team Drive files.(writable)

	private List<GDAPIModelPermission> permissions;			//The full list of permissions for the file. This is only available if the requesting user can share the file. Not populated for Team Drive files

	private String folderColorRgb;							//The color for a folder as an RGB hex string. The supported colors are published in the folderColorPalette field of the About resource.If an unsupported color is specified, the closest color in the palette will be used instead.(writable)
	private String originalFilename;						//The original filename of the uploaded content if available, or else the original value of the name field. This is only available for files with binary content in Drive.(writable)
	private String fullFileExtension;						//The full file extension extracted from the name field. May contain multiple concatenated extensions, such as "tar.gz". This is only available for files with binary content in Drive.This is automatically updated when the name field changes, however it is not cleared if the new name does not contain a valid extension
	private String fileExtension;							//The final component of fullFileExtension. This is only available for files with binary content in Drive
	private String md5Checksum;								//The MD5 checksum for the content of the file. This is only applicable to files with binary content in Drive
	private Long size;									//The size of the file's content in bytes. This is only applicable to files with binary content in Drive
	private Integer quotaBytesUsed;							//The number of storage quota bytes used by the file. This includes the head revision as well as previous revisions with keepForeverenabled
	private String headRevisionId;							//The ID of the file's head revision. This is currently only available for files with binary content in Drive

	private ContentHintsModel contentHints;					//Additional information about the content of the file. These fields are never populated in responses										

	private ImageMediaMetadataModel imageMediaMetadata;		//Additional metadata about image media, if available

	private VideoMediaMetadataModel videoMediaMetadata;		//Additional metadata about video media. This may not be available immediately upon upload

	public Capabilities capabilities;						//Capabilities the current user has on the file. Each capability corresponds to a fine-grained action that a user may take
	
	private Boolean isAppAuthorized;						//Whether the file was created or opened by the requesting app
	private Boolean hasThumbnail;							//Whether this file has a thumbnail
	private Integer thumbnailVersion;						//The thumbnail version for use in thumbnail cache invalidation
	private Boolean modifiedByMe;							//Whether the file has been modified by this user

	private GDAPIModelUser trashingUser;					//If the file has been explicitly trashed, the user who trashed it. Only populated for Team Drive files

	private Datetime trashedTime;							//The time that the item was trashed (RFC 3339 date-time). Only populated for Team Drive files
	private String teamDriveId;								//ID of the Team Drive the file resides in

	private Boolean hasAugmentedPermissions;				//Whether any users are granted file access directly on this file. This field is only populated for Team Drive files
	
	public String eTag;
	
	// Getter & Setter Method
	public String getId() { return this.id; }
	public void setId(String id) {
		this.id = id;
	}	
	public String getName() { return this.name; }
	public void setName(String nam) {
		this.name = nam;
	}
	public Long getSize(){return this.size;}
	public void setSize(Long size){
		this.size = size;
	}
	public String getMimeType() { return this.mimeType; }
	public void setMimeType(String mime) {
		this.mimeType = mime;
	}
	public String getDescription() { return this.description; }
	public void setDescription(String descr) {
		this.description = descr;
	}
	public String getWebContentLink() { return this.webContentLink; } 
	public String getThumbnailLink() { return this.thumbnailLink; } 
	public String getWebViewLink() {return this.webViewLink;}
	public List<GDAPIModelUser> getOwners() { return this.owners; }
	public void setOwners(List<GDAPIModelUser> users) { 
		this.owners = users;
	}
	public Boolean getStarred() { return this.starred; }
	public void setStarred(Boolean starred) {
		this.starred = starred;
	}
	public Boolean getTrashed() { return this.trashed; }
	public void setTrashed(Boolean trashed) {
		this.trashed = trashed;
	}
	public Boolean getExplicitlyTrashed() { return this.explicitlyTrashed; }
	public List<String> getParents() { return this.parents; }
	public void setParents(List<String> folders) {
		this.parents = folders;
	}
	public Integer getVersion() { return this.version; }
	public void setVersion(Integer ver) { this.version = ver; }
	public List<GDAPIModelPermission> getPermissions() { return this.permissions; }
	public Map<String, String> getProperties() { return this.properties; }
	public void setproperties(Map<String, String> prop) {
		this.properties = prop;
	} 
	public Map<String, String> getAppProperties() { return this.appProperties; }
	public void setAppProperties(Map<String, String> appProp) {
		this.AppProperties = appProp;
	} 
	public Datetime getModifiedTime() { return this.modifiedTime; }
	
	public Capabilities getCapabilities() { return this.capabilities;} 
	// Inner Classes
	public class ContentHintsModel extends SCoreAbstractJsonSerializable {
		private ThumbNailModel thumbNail;					//A thumbnail for the file. This will only be used if Drive cannot generate a standard thumbnail
		private String indexableText;						//Text to be indexed for the file to improve fullText queries. This is limited to 128KB in length and may contain HTML elements.(writable)
	} 

	public class ThumbNailModel  extends SCoreAbstractJsonSerializable {
		private Blob image;									//The thumbnail data encoded with URL-safe Base64 (RFC 4648 section 5).(writable)
		private String mimeType;							//The MIME type of the thumbnail.(writable)
	}
		
	public class ImageMediaMetadataModel extends SCoreAbstractJsonSerializable {
		private Integer width;								//The width of the image in pixels
		private Integer height;								//The height of the image in pixels
		private Integer rotation;							//The rotation in clockwise degrees from the image's original orientation
		private LocationModel location;						//Geographic location information stored in the image
		
		private Datetime takentime;							//The date and time the photo was taken (EXIF DateTime)
		private String cameraMake;							//The make of the camera used to create the photo
		private String cameraModel;							//The model of the camera used to create the photo
		private Double exposureTime;						//The length of the exposure, in seconds
		private Double aperture;							//The aperture used to create the photo (f-number)
		private Boolean flashUsed;							//Whether a flash was used to create the photo
		private Double focalLength;							//The focal length used to create the photo, in millimeters
		private Integer isoSpeed;							//The ISO speed used to create the photo
		private String meteringMode;						//The metering mode used to create the photo
		private String sensor;								//The type of sensor used to create the photo
		private String exposureMode;						//The exposure mode used to create the photo
		private String colorSpace;							//The color space of the photo
		private String whiteBalance;						//The white balance mode used to create the photo
		private Double exposureBias;						//The exposure bias of the photo (APEX value)
		private Double maxApertureValue;					//The smallest f-number of the lens at the focal length used to create the photo (APEX value)
		private Integer subjectDistance;					//The distance to the subject of the photo, in meters
		private String lens;								//The lens used to create the photo
	}
	
	public class LocationModel extends SCoreAbstractJsonSerializable {
		private Double latitude;							//The latitude stored in the image
		private Double longitude;							//The longitude stored in the image
		private Double altitude;							//The altitude stored in the image
		
		public Double getLatitude() {
			return latitude;
		}
		public LocationModel setLatitude(Double lat) {
			this.latitude = lat;
			return this;
		}
		public Double getLongitude() {
			return longitude;
		}
		public LocationModel setLongitude(Double lon) {
			this.longitude = lon;
			return this;
		}
		public Double getAltitude() {
			return altitude;
		}
		public LocationModel setAltitude(Double alt) {
			this.altitude = alt;
			return this;
		}
	}
	
	public class VideoMediaMetadataModel extends SCoreAbstractJsonSerializable {
		private Integer width;								//The width of the video in pixels.	
		private Integer height;								//The height of the video in pixels.	
		private Long durationMillis;						//The duration of the video in milliseconds.
		
		public Integer getWidth() {
			return width;
		}
		public VideoMediaMetadataModel setWidth(Integer width) {
			this.width = width;
			return this;
		}
		public Integer getHeight() {
			return height;
		}
		public VideoMediaMetadataModel setHeight(Integer height) {
			this.height = height;
			return this;
		}
		public Long getDurationMillis() {
			return durationMillis;
		}
		public VideoMediaMetadataModel setDurationMillis(Long durationMillis) {
			this.durationMillis = durationMillis;
			return this;
		}
	}
	
	public class Capabilities extends SCoreAbstractJsonSerializable {
		private Boolean canEdit;							//Whether the user can edit the file's content.()
		private Boolean canComment;							//Whether the user can comment on the file.()
		private Boolean canShare;							//Whether the user can modify the file's permissions and sharing settings.()
		private Boolean canCopy;							//Whether the user can copy the file. For a Team Drive item, whether non-folder descendants of this item, or this item itself if it is not a folder, can be copied.()
		private Boolean canReadRevisions;					//Whether the user has read access to the Revisions resource of the file. For a Team Drive item, whether revisions of non-folder descendants of this item, or this item itself if it is not a folder, can be read.()
		private Boolean canAddChildren;						//Whether the user can add children to this folder. This is always false when the item is not a folder.()
		private Boolean canDelete;							//Whether the file can be deleted by the user.()
		private Boolean canDownload;						//Whether the file can be downloaded by the user.()
		private Boolean canListChildren;					//Whether the user can list the children of this folder. This is always false when the item is not a folder.()
		private Boolean canMoveTeamDriveItem;				//Whether the user can move this Team Drive item by changing its parent. Note that a request to change the parent for this item may still fail depending on the new parent that is being added. Only populated for Team Drive files.()
		private Boolean canMoveItemIntoTeamDrive;			//Whether the current user can move this item into a Team Drive. If the item is in a Team Drive, this field is equivalent to canMoveTeamDriveItem.()
		private Boolean canReadTeamDrive;					//Whether the user has read access to the Team Drive to which this file beLongs. Only populated for Team Drive files.()
		private Boolean canRemoveChildren;					//Whether the user can remove children from this folder. This is always false when the item is not a folder.()
		private Boolean canRename;							//Whether the file can be renamed by the user.()
		private Boolean canTrash;							//Whether the file can be trashed by the user.()
		private Boolean canUntrash;							//Whether the file can be restored from the trash by the current user.()
		
		public Boolean getCanEdit() { return this.canEdit; }
		public void setCanEdit(Boolean canEdit){
			this.canEdit = canEdit;
		}
		
		public Boolean getCanDelete() { return this.canDelete; }
		public void setCanDelete(Boolean canDelete){
			this.canDelete = canDelete;
		}
		
		public Boolean getCanRename() { return this.canRename; }
		public void setCanRename(Boolean canRename){
			this.canRename = canRename;
		}	
		
		public Boolean getCanTrash() { return this.canTrash; }
		public void setCanTrash	(Boolean canTrash){
			this.canTrash = canTrash;
		}	
		
		public Boolean getCanShare() { return this.canShare; }
		public void setCanShare(Boolean canShare){
			this.canShare = canShare;
		}
		
		public Boolean getCanAddChildren() { return this.canAddChildren; }
		public void setCanAddChildren(Boolean canAddChildren){
			this.canAddChildren = canAddChildren;
		}
		
		public Boolean getCanDownload() { return this.canDownload; }
		public void setCanDownload(Boolean canDownload){
			this.canDownload = canDownload;
		}
	}
	
	// Constructor
	public GDAPIModelFile() {
		super(KIND_DRIVE_FILE);		
	}
}