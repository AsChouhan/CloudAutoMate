public with sharing class SiteListWrapper {
	
    public String id;
    public String siteId;
    public String chatterGroupId;
    public String title;
    public String name;
    public String description;
    public String information;
    public String informationTitle;
    public Integer memberCount;
    public Integer followerCount;
    public Integer peopleCount;
    public String url;
    public String aboutUrl;
    public String editUrl;
    public String img;
    public String imgThumbnail;
    public SiteListWrapper.FileWrapper imgFile;
    public Category category;
    public Slack slack;
    public Boolean teams;
    public Boolean isMember;
    public Boolean isFollower;
    public Boolean isContentManager;
    public Boolean isAccessRequested;
    public Boolean isOwner;
    public Boolean isManager;
    public Boolean isActive;
    public Boolean isFavorited;
    public Boolean isFeatured;
    public Boolean isMandatory;
    public Boolean isBroadcast;
    public Boolean hasPages;
    public Boolean hasEvents;
    public Boolean hasAlbums;
    public Boolean hasContent;
    public Boolean canCreatePage;
    public Boolean canCreateEvent;
    public Boolean canCreateAlbum;
    public String access;
    public Boolean isPublic;
    public Boolean isPrivate;
    public Boolean isListed;
    public Boolean canEdit;
    public Boolean canActivateDeactivate;
	public Boolean isInMandatorySubscription;
    public Boolean isRestrictedCategory;
    public Boolean isMembershipAutoApproved;
    public Boolean canUploadAllFileTypes;
    public Boolean canAccessLeadercast;
    public Boolean isQuestionAnswerEnabled;
    
    public class Category{
    	public String id;
    	public String categoryId;
    	public String name;
    	public String url;
    }
    
    public class Slack{
    	public String name;
    	public String url;
    }
    
    public class PaginationWrapper {
        public String nextPageToken;
        public Integer totalRecords;
        Public List<SiteListWrapper> listOfItems = new List<SiteListWrapper>();
    }
    
    public class FileWrapper {
	    public String id;
	    public String url;
	    public String fileUrl;
	    public String downloadUrl;
	    public String thumbnailImg;
    }
    
}