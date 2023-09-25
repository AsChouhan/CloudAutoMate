public with sharing class NotificationWrapper {
	public String nextPageToken;
	public Counts newCounts;
	public Counts totalCounts;
	public List<Notification> listOfNotification = new List<Notification>();


public class User {
		public String id;
		public String name;
		public String img;
		public String url;
	}
	
	public class Counts {
		public Integer activity;
		public Integer actionable;
	}

	public class Notification {
		public String id;
		public String createdAt;
		public String state;
		public Boolean isActionable;
		public String actionedBy;
		public String url;
		public String text;
		public User user;
	}
	
	public class FilterWrapper {
		public String id;
		public String name;
	}
	public class FilterListWrapper {
		public List<filterWrapper> sites = new List<filterWrapper>();
	}
    
    public class NotificationDispatcher {
    	public Set<People__c> toUserList;
		public String subject;
		public String body;
		public People__c fromUser;
		public string Action;
		public People__c ActionBy;
		public String actionComment;
		public Datetime actionOnDate;
		public String GUID;
		public String objectId;
		public String objectType;
		public String parentNotification;
		public People__c sentBy;
		public Simpplr_Site__c site;
		public String submitterComment;
		public String type;
	}
	
	public class SendInBlueWrapper {
		public ContactWrapper contact;
		public RecipientWrapper recipient;
		public WelcomeEmailParamsWrapper emailParams;		
	}

	public class WelcomeEmailParamsWrapper {
		public String appName;
		public String settingLink;
	}

	public class RecipientWrapper {
		public String name;
		public String email;
	}

	public class ContactWrapper {
		public String Email;
		public String FIRSTNAME;
		public String LASTNAME;
		public String ORG_ID;
		public String ORG_NAME;
		public String JOB_TITLE;
		public Boolean APP_MANAGER;
		public Boolean SITE_MANAGER;
		public Boolean CONTENT_AUTHOR;
		public Integer NUM_DAYS_OF_LOGIN_LAST_NINETY_DAYS;
		public Boolean ALERT_CONTROL;
		public Boolean ANALYTICS_CONTROL;
		public Boolean HOME_MANAGEMENT_CONTROL;
		public Boolean NEWSLETTER_CONTROL;
		public Boolean SOCIAL_CAMPAIGN_CONTROL;
    }
    
    public class GroupedNotification {
		public String parentObjectId;
		public String objectId;
		public String objectType;
		public String contentId;
		public String siteId;
        public String sentBy;
        public String snippet;
        public String status;
        public String subType;
        public String type;
        public String category;
        public String rAB1;
        public String rAB2;
        public String rAB3;
        public DateTime rAB1DateTime;
        public DateTime rAB2DateTime;
        public DateTime rAB3DateTime;
        public DateTime createdDateTime;
        public Integer total; 
    }
}