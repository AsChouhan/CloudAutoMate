public with sharing class NotificationListingWrapper {
	public String id;
	public String stamp;
	public String createdAt;
	public String state;
	public Boolean isActionable;
	public Boolean isSeen;
	public Boolean isRead;
	public UserWrapper actionedBy;
	public String url;
	public String text;
    public UserWrapper user;
    public List<UserWrapper> listOfUser;
	public String sentToId;
	public String privateSiteRequestId;
	public String androidToken;
	public String type;
	public String subType;
	public String siteId;
	public String contentId;
	public String peopleId;
	public String fileId;
	public String newsletterId;
	public String feedId;
	public String feedCommentId;
	public String questionId;
	public String answerId;
	public Boolean isClickable;
	public Integer badge;
	public String sound;
	public String contentType;
	public Boolean isMustRead;
	public String category;
	public String campaignId;
	public String imgContent;
	public String imgSite;
	public String objectId;
	
    public class PaginationWrapper {
		public Integer nextPageToken;
    		public List<NotificationListingWrapper> listOfItems = new List<NotificationListingWrapper>();
    		public CountWrapper newCounts;
		public CountWrapper totalCounts;
		public String viewAllLink;	
	}
	
	public class CountWrapper {
		public Integer activity;
		public Integer actionable;
	}
	
	public class UserWrapper {
		public String id;
		public String name;
		public String img;
		public String url;
		public String profileImg;//mediumPhotoUrl used by mobile
	}

}