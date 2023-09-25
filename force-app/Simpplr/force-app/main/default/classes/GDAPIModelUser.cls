/*
 * An object that represents the meta data for a user of Google Drive.
 */
public with sharing class GDAPIModelUser extends GDAPIModelAbstract {
	public static final String KIND_DRIVE_USER = 'drive#user';
	
	//Instance variables
	private String displayName;								//A plain text displayable name for this user
	private String photoLink;								//A link to the user's profile photo, if available
	private Boolean me;										//Whether this user is the requesting user
	private String permissionId;							//The user's ID as visible in Permission resources
	private String emailAddress;							//The email address of the user. This may not be present in certain contexts if the user has not made their email address visible to the requester
	
	// Constructor
	public GDAPIModelUser() {
		super(KIND_DRIVE_USER);
	}
	
	// Getter & Setter Methods
	public String getDisplayName() {
		return displayName;
	}
	public GDAPIModelUser setDisplayName(String dispName) {
		this.displayName = dispName;
		return this;
	}
	public String getPhotoLink() {
		return photoLink;
	}
	public GDAPIModelUser setPhotoLink(String picUrl) {
		this.photoLink = picUrl;
		return this;
	}
	public Boolean getMe() {
		return me;
	}
	public GDAPIModelUser setMe(Boolean meFlag) {
		this.me = meFlag;
		return this;
	}
	public String getPermissionId() {
		return permissionId;
	}
	public GDAPIModelUser setPermissionId(String permId) {
		this.permissionId = permId;
		return this;
	}
	public String getEmailAddress() {
		return emailAddress;
	}
	public GDAPIModelUser setEmailAddress(String email) {
		this.emailAddress = email;
		return this;
	}
}