public with sharing class CampaignWrapper {
    public String campaignId;
	public set<string> socialCampIdSet = new set<String>();
    public String defaultDescription;
    public String url;
    public String createdAt; 
    public PeopleListWrapper createdBy;
    public Boolean isActive;
    public NetworksWrapper networks;
    public OembedWrapper oembed;
	public String recipient;
    public SegmentWrapper segment;
	public String segmentId;
    public AudienceWrapper audience;
    public Boolean isInHomeCarousel;
    
    public CampaignWrapper(){
		createdBy = new PeopleListWrapper();
		networks =  new NetworksWrapper();
    }
    
    public class NetworksWrapper {
    		public NetworkWrapper twitter;
    		public NetworkWrapper facebook;
    		public NetworkWrapper linkedin;
    }
    
    public class NetworkWrapper {
    		public Boolean isEnabled;
    		public Boolean hasShared;
    		public Integer shareCount;
    		public Integer likeCount; 
        public Integer reshareCount;
    }
    
    public class OembedWrapper {
    		public String type;
    		public String version;
    		public String title;
    		public String author_name;
    		public String author_url;
    		public String provider_name;
    		public String provider_url;
    		public String cache_age;
    		public String thumbnail_url;
    		public String thumbnail_width;
    		public String thumbnail_height;
    		public String description;
    		public String url;
    		public String html;
    		public String width;
    		public String height;
    }
    
    public class CampaignShareHistoryWrapper {
    		public PeopleLiteWrapper user;
    		public NetworksWrapper networksSharedTo;
    		
    		public CampaignShareHistoryWrapper() {
    			user = new PeopleLiteWrapper();
    			networksSharedTo = new NetworksWrapper();
    		}
    }
    
		public class CampaignReportWrapper{
			public String username{get;set;}
			public String email{get;set;}
			public String department{get;set;}
			public String city{get;set;}
			public String state{get;set;}
			public String country{get;set;}
			public String time_shared{get;set;}
			public String what_service_campaign_shared_to{get;set;}
			public Integer reshares{get;set;}
			public Integer likes{get;set;}
			public Datetime createdDate{get;set;}
			public String localizedTimeShared{get{
				return LocaleContext.getLocalisedDateAsMMMDDYYYY(createdDate, UserContext.languageLocaleKey, UserContext.timeZoneSIDKey)
							+ ' '
							+ LocaleContext.getLocalisedDateAs12HourFormatTime(createdDate, UserContext.languageLocaleKey, UserContext.timeZoneSIDKey);
			}set;}
	
			public CampaignReportWrapper(String username, String email, String department, String city, String state, String country, String time_shared, String what_service_campaign_shared_to, Integer reshares, Integer likes, Datetime createdDate){
				this.username = username;
				this.email = email;
				this.department = department;
				this.city = city;
				this.state = state;
				this.country = country;
				this.time_shared = time_shared;
				this.what_service_campaign_shared_to = what_service_campaign_shared_to;
				this.reshares = reshares;
				this.likes = likes;
				this.createdDate = createdDate;
			}
		}
}