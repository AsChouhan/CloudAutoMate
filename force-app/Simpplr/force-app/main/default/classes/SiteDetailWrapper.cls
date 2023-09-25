public with sharing class SiteDetailWrapper {

    public String name;
	public String description;
	public string access;
	public String titleImageCaption;
	public Boolean isNew;
	public String id ;
	public String siteId ;
	public String title ;
	public String img ;
	public String imgThumbnail;
	public String fullPhotoUrl;
	public String siteImg ;
	public String coverImage ;
	public String url ;
	public String editUrl ;
	public Boolean canEdit;
	public Boolean canMention;
	public Boolean canActivateDeactivate;
	public Boolean isPrivate;
	public Boolean isListed;
	public Boolean hasContent;
	//public Boolean hasNews;
	public Boolean hasEvents;
	public Boolean hasPages;
	public Boolean hasAlbums;
	public Boolean isMembershipAutoApproved;
	public String information;
	public String about;
	public String chatterGroupId;
	public Boolean canCreatePage;
	public Boolean canCreateEvent;
	public Boolean canCreateAlbum;
	public Boolean isContentFeedEnabled;
	public Boolean isContentUnfurlEnabled;
	public Integer members;
	public Integer memberCount;
    public Integer followerCount;
	public Boolean isMember;
	public Boolean isFollower;
	public Boolean isActive;
	public Boolean isMandatory;
	public Boolean isFavorited;
	public Boolean isFeatured;
	public Boolean isOwner;
	public Boolean isManager;
	public Boolean isAccessRequested;
	public Boolean isContentManager;
	public Boolean isBroadcast;
	public Boolean isContentSubmissionsEnabled;
	public Boolean isQuestionAnswerEnabled;
	public SiteDetailWrapper.Category category ;
	public SiteDetailWrapper.FileWrapper imgFile;
	public String feedPlaceholder;
	public String feedContentPlaceholder;
	public ManagerWrapper owner;
	public List<ManagerWrapper> managerList;
	public List<ManagerWrapper> memberList;
	public List<ManagerWrapper> followerList;
	public String imgTHUMB240BY180URL;
	public String imgTHUMB720BY480URL;
	public String imgFullURL;
	public Slack slack;
	public Boolean teams;
	public List<SegmentWrapper> listOfFeaturedSegments;
	public List<SegmentWrapper> listOfMandatorySegments;
	public AnalyticsWrapper analytics;
	
	public String dashboardLayout;
	public Boolean hasDashboard;
	public String landingPage;
	public String storageProvider;
	public String dropboxRootPermission;
	public Boolean isInMandatorySubscription;
	public String createdAt;
	public Integer managerCount;
	public Integer peopleCount;
	public Boolean canUploadAllFileTypes;
	public String ownerId;
	public Boolean canAccessLeadercast;
	public MsTeams msTeams;
	public Boolean hasCampaigns;

    /**
     * @description constructor
     */
	public SiteDetailWrapper(){
	}
	
	public class AnalyticsWrapper {
		public Integer totalPageCount;
		public Integer totalEventCount;
		public Integer totalAlbumCount;
		public String csvUrl;
		public AnalyticsWrapper() {
			totalPageCount = 0;
			totalEventCount = 0;
			totalAlbumCount = 0;
		}
	}
	public class ManagerWrapper{
    	public String peopleId;
    	public String sfuserId;
    	public String firstName;
    	public String lastName;
    	public String name;
    	public String profileImg;
    	public String title;
    	public String department;
    	public String email;
    	public String address;
    	public String mobilePhone;
    	public String phone;
    	public String extension;
    	public String street;
    	public String city;
    	public String state;
    	public String country;
		public Boolean isActive;
    }
    
	public class FileWrapper {
	    public Boolean isAccessible ;
	    public Integer size {set;get;}
	    public Boolean isDownloadableOniOS;
	    public Boolean isLiked ;
	    public Boolean canUnlink;
	    public Boolean isDir;
	    public PermissionsWrapper permissions;
	    public Boolean canCreateNewVersion;
	    public Boolean canCreatePublicShareLink;
	    public String boxUrl;
	    public String publicUrl;
	    public String downloadUrl;
	    public Boolean canChangeName;
	    public String gdriveUrl;
	    public List<String> sites;
	    public String url;
	    public String context;
	    public String pathOnClient;
	    public String provider;
	    public Boolean isImage;
	    public Boolean canSetPermissions;
	    public String fileUrl;
	    public OwnerWrapper owner;
	    public Boolean isSystemDir;
	    public String location;
	    public String thumbnailImg;
	    public String title;
	    public String directoryName;
	    public String type;
	    public String id;
	    public String createdAt;
	    public String modifiedAt;
	    public Boolean canDelete;
	    public Boolean isFavorited;
    }
    
    public class OwnerWrapper {
    	public Boolean canFollow;
		public String mobile;
		public String img;
		public PermissionsWrapper permissions;
		public String peopleId;
		public String name;
		public String about;
		public String nickname;
		public String phone;
		public String url;
		public Boolean isActive;
		public Boolean hasRead;
		public Boolean hasConnectedBoxAccount;
		public String phoneExtension;
		public String department;
		public String location;
		public String title;
		public String id;
		public String email;
		public String birthday;
		public Boolean isFavorited;
		public String hireDate;
    }
    
    public class PermissionsWrapper {
    	public Boolean canArrangeFeaturedSites;
        public Boolean canSendAlerts;
        public Boolean isUnlistedAdmin;
        public Boolean canSendNewsletter;
        public Boolean canAccessAnalytics;
        public Boolean canCreateSite;
        public Boolean canSendNewsletterToAll;
        public Boolean canAccessAllPrivateSites;
        public Boolean isAppManager;
        public Boolean canSendAlertsToAll;
        public Boolean isSiteManager;
    }
    
    public class Category {
		public String id;
		public String name;
		public String url;
	}
	
	public class Slack {
		public String id;
		public String name;
		public String url;
	}

	public class MsTeams {
		public String id;
		public String name;
		public String webUrl;
	}

	public class MembershipRequestsWrapper {
		public Boolean isMembershipAutoApproved;
	}
}