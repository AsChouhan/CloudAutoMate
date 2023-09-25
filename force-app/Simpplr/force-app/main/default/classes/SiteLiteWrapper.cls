/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class SiteLiteWrapper {
	// Unique Identifiers
    public String siteId;
    public String chatterGroupId;
	
	// Identifiers
	public String name;
	public String title;
	public String url;

	// Type
	public String access;
	public Boolean isPublic;
	public Boolean isPrivate;
	public Boolean isListed;
	public Boolean isChatterGroupOnly;
	public Boolean isFeatured;
	public Boolean isBroadcast;

	// Current User Type
	public Boolean isMember;
	public Boolean isFollower;
	public Boolean isManager;
	public Boolean isContentManager;
	public Boolean isOwner;
	public Boolean canUploadAllFileTypes;

	// Site Other Info
	public String img;
	public String imgThumbnail;
	public String imgContentDocumentId;
	public Boolean isActive;
	public Boolean isActivated;
	public String jsonDataString;
	public Integer memberCount;
	public Integer followerCount; 
	public Boolean hasCampaigns;
	public Boolean isContentUnfurlEnabled;

}