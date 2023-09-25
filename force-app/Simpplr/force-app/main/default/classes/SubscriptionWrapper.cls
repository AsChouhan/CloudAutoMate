public with sharing class SubscriptionWrapper {
	public String subscriptionId;
	public String recipient;
	public SegmentWrapper segment;
	public AudienceWrapper audience;
	public String createdAt;
	public PeopleLiteWrapper createdBy;
	public String modifiedAt;
	public PeopleLiteWrapper modifiedBy;
	public SubscriptionAction action;
	public Boolean isLocked;
	public String membershipType;

	public class SubscriptionAction {
		public String actionType;
		public String itemType;
		public List<SubscriptionSiteItem> listOfSites;
		public List<SubscriptionPeopleItem> listOfPeople;
	}
	
	public class SubscriptionSiteItem {
		public String subscriptionEntityId;
		public String status;
		public SiteLiteWrapper item;
		public PeopleLiteWrapper actionedBy;
	}
	
	public class SubscriptionPeopleItem {
		public String subscriptionEntityId;
		public PeopleLiteWrapper item;
	}
	
	public class PaginationWrapper {
		public List<SubscriptionWrapper> listOfItems = new List<SubscriptionWrapper>();
    	public String nextPageToken;
	}
}