public with sharing class GDAPIModelPermission extends GDAPIModelAbstract {
	// Instance Variables
	private String id;							//The ID of this permission. This is a unique identifier for the grantee, and is published in User resources as permissionId.
	private String type;						//The type of the grantee. Valid values are:user group domain anyone(writable)
	private String emailAddress;				//The email address of the user or group to which this permission refers.(writable)
	private String domain;						//The domain to which this permission refers.(writable)
	private String role;						//The role granted by this permission. While new values may be supported in the future, the following are currently allowed:organizer owner writer commenter reader(writable)
	private Boolean allowFileDiscovery;			//Whether the permission allows the file to be discovered through search. This is only applicable for permissions of type domain or anyone.(writable)
	private String displayName;					//A displayable name for users, groups or domains.
	private String photoLink;					//A link to the user's profile photo, if available.
	private Datetime expirationTime;			//The time at which this permission will expire (RFC 3339 date-time). Expiration times have the following restrictions:They can only be set on user and group permissions The time must be in the future The time cannot be more than a year in the future(writable)
	private List<TeamDrivePermissionDetail> teamDrivePermissionDetails;	//Details of whether the Permissions on this Team Drive item are inherited or directly on this item. This is an output-only field which is present only for Team Drive items.

	// Getter and Setter Methods
	public String getId() { return this.id; }
	public String getType() { return this.type; }
	public void setType(String typ) {
		this.type = typ;
	}
	public String getEmailAddress() { return this.emailAddress; }
	public void setEmailAddress(String emailAddress) {
		this.emailAddress = emailAddress;
	}
	public String getDomain() { return this.domain; }
	public void setDomain(String domain) {
		this.domain = domain;
	}
	public String getRole() { return this.role; }
	public void setRole(String role) {
		this.role = role;
	}
	public Boolean getAllowFileDiscovery() { return this.allowFileDiscovery; }
	public void setAllowFileDiscovery(Boolean allowDiscovery) {
		this.allowFileDiscovery = allowDiscovery;
	}
	public String getDisplayName() { return this.displayName; }
	public String getPhotoLink() { return this.photoLink; }
	public Datetime getExpirationTime() { return this.expirationTime; }
	public void setExpirationTime(Datetime expirationTime) {
		this.expirationTime = expirationTime;
	}
	public List<TeamDrivePermissionDetail> getTeamDrivePermissionDetails() { return this.teamDrivePermissionDetails; }
	public void setTeamDrivePermissionDetails(List<TeamDrivePermissionDetail> tdPermissionDetails) {
		this.teamDrivePermissionDetails = tdPermissionDetails;
	}
	
	// Construtor
	public GDAPIModelPermission() {
		super('drive#permission');			//Identifies what kind of resource this is. Value: the fixed String "drive#permission".
	}
	
	// Inner Class
	public class TeamDrivePermissionDetail extends SCoreAbstractJsonSerializable {
		private String teamDrivePermissionType;		//The Team Drive permission type for this user. While new values may be added in future, the following are currently possible:file member
		private String role;						//The primary role for this user. While new values may be added in the future, the following are currently possible:organizer writer commenter reader
		private String inheritedFrom;				//The ID of the item from which this permission is inherited. This is an output-only field and is only populated for members of the Team Drive.
		private Boolean inherited;					//Whether this permission is inherited. This field is always populated. This is an output-only field.
	}
}