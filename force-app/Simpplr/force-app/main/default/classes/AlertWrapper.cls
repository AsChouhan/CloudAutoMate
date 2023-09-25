public with sharing class AlertWrapper {
	public String alertId;
	public PeopleLiteWrapper authoredBy;
	public String recipient;
	public Integer recipientCount;
	public Integer seenCount;
	public Boolean canDelete;
	public String status;
	public String message;
	public Boolean isDismissible;
	public String url;
	public String displayFrom;
	public String displayTo;
	public String duration;
	public String createdAt;
	public String modifiedAt;
	public Boolean isScheduled;
	public Boolean hasUrl;
	public AlertWrapper itemData;
	public String membersType;

	public String siteId;
	public SearchRecordWrapper site;
	public String segmentId;
	public AudienceWrapper.SegmentLiteWrapper segment;
	public String audienceId;
	public AudienceWrapper audience;
	public String durationStart;
	public ExternalAppsForAlert externalDistribution;
	
	public class AlertListingWrapper {
		public List<AlertWrapper> listOfItems;
		public List<SiteLiteWrapper> filterOptions;
	}

	public class ExternalAppsForAlert {
		public boolean isMsTeamsSelected;
		public String msTeamsChannelId;
		public String msTeamsTeamId;
		public boolean isMSTeamsPostAlertAsDM;
		public boolean isMSTeamsPostAlertAsChannel;
		public String msTeamsConnectedUserId;
		public String msTeamsTeamName;
		public String msTeamsChannelName;
	}
    
}