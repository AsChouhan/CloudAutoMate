public with sharing class NewsletterListingWrapper {
    public String newsletterId {get;set;}
	public String img {get;set;}
	public String url;
	public PeopleLiteWrapper authoredBy;
	public String recipient;
	public Integer recipientCount;
	public Boolean canDelete;
	public String status;
	public String introduction;
	public String subject;
	public Integer clickThroughs;
	public Boolean isScheduled;
	public String sentAt;	//2015-08-17 
	public String sendAt;	//2015-08-17
	public String createdAt ;	//2015-08-17T07:16:37.000Z
	public String modifiedAt ;  //2015-08-17T07:16:37.000Z
	public List<ContentListWrapper> listOfItems = new List<ContentListWrapper>();
	public Boolean canEdit;
	public Boolean isDeleted;
	public Integer totalClickCount ;
	public Integer uniqueClickCount;
	public Integer openCount ;
	public String introductionInlined;
	public String fromAddress;
	public String fromAddressId;
	public String bannerUrl;
	public String name;

	public String membersType;
	
	public String siteId;
	public SiteLiteWrapper site;
	public String segmentId;
	public AudienceWrapper.SegmentLiteWrapper segment;
	public String audienceId;
	public AudienceWrapper audience;
	
	public NewsletterListingWrapper (){
		site = new SiteLiteWrapper();
		authoredBy = new PeopleLiteWrapper();
	}

	public class ContentListWrapper{
		public ContentWrapper content;
		public String type;
		public String text;
		public Boolean isShowcase;
		public String heading;
		public Integer index;
		public String id;
	}
	
	public class PaginationWrapper {
        public String nextPageToken;
        public Integer totalRecords;
        Public List<NewsletterListingWrapper> listOfItems = new List<NewsletterListingWrapper>();
    }
   
}