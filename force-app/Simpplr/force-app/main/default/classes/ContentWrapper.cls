public with sharing class ContentWrapper implements Comparable{
    public String id;
    public String siteId;
	public String contentId;
	public String type;
	public String contentSubType;
	public Boolean isTypeActive;
	public String img;
	public String imgLandscape;
	public String imgOriginal;
	public String imgLayout;
	public String imgCaption;
	public String language;
	public String title;
	public String body;
	public TipTapBodyWrapper bodyJson;
	public String editUrl;
	public String url;
	public boolean isPromoted;
	public String summary;
	public String excerpt;
	public boolean isPublished;
	public boolean shouldUseNewEditor;
	public Boolean isFavorited;
	public Boolean isLiked;
	public Boolean isInHomeCarousel;
	public Boolean isInSiteCarousel;
	public Boolean isMustRead;
	public Boolean isDeleted;
	public Boolean isFeedEnabled;
	public Boolean isMaximumWidth;
	public Boolean hasRead;
	public Boolean isContentRead;
	public Boolean hasSeen;
	public Boolean hasRated;
	public Integer likeCount;
	public Integer readCount;
	public Integer postCount;
	public Integer questionCount;
	public String onboardingStatus;
	public String readAt;
	public String favoriteContext;
	public String outlookWebUrl;
	public String icsDownloadUrl;
	public String googleCalendarWebUrl;
	public String office365WebUrl;
	public String firstPublishedAt;
	public String publishAt;	//2015-08-17T0716:37.000Z
	public String createdAt;   //2015-08-17T07:16:37.000Z
	public String modifiedAt;	//2015-08-17T07:16:37.000Z
	public String publishTo;
	public String promoteAt;
	public String unpublishedAt;
    public String submittedAt;
	public String promoteTo;
	public String newsletterLastSentAt; //2015-08-17T07:16:37.000Z
	public String timezoneIso;
	public String timezoneName;
	public Integer timezoneOffset;
	public String startsAt;
	public String endsAt;
	public Boolean isAllDay;
	public String location;
	public String mapUrl;
	public Boolean hasDirections;
	public List<String> directions;
	public Boolean hasRsvp;
	public RsvpWrapper rsvp;
    public List<PeopleListWrapper> listOfOrganizers;
    public Integer recentViewCount;
    public Integer imageCount;
    public Integer videoCount;
	public Boolean isMultiDay;
	public String status;
	public Boolean canPost;
	public boolean canEdit;
	public boolean canDelete;
	public boolean canModerate;
	public boolean canPublishUnpublish;
	public boolean canSendUpdateNotification;
	public boolean canMakeMustRead;
	public boolean canManageOnboardingContent;
	public Boolean isOpenToSubmissions;
	public Boolean isOpenToNotification;
	public CategoryWrapper category;
	public SiteLiteWrapper site;
	public PeopleListWrapper authoredBy;
	public PeopleListWrapper editedBy;
	public List<TopicWrapper> listOfTopics;
	public List<FileContentWrapper> listOfFiles;
	public List<FileContentWrapper> listOfInlineImages;
	public List<FileContentWrapper> listOfInlineVideos;
	public FileContentWrapper imgOriginalFile;
	public FileContentWrapper imgFile;
	public FileContentWrapper imgLandscapeFile;
	public Double relevancyScore;
	public ContentUsefulWrapper usefulContent;
	public Boolean isContentTypeActive;
	public Integer order;
	public String coverImageMediaId;
	public List<MediaWrapper> listOfAlbumMedia;
	public List<String> listOfContentTopicIds;
	public String contentBodyUrl;
	public List<FileListingWrapper> listOfAlbumImagesAndVideos;
	public List<FileListingWrapper> listOfMedia;
	public List<AlbumImagesWrapper> listOfTopAlbumImages;
	public Boolean matchedOnTopic;
	public Boolean matchedOnExpertise;
	public String itemType;
	public Long lastModifiedDateTimeStamp;
	public MustReadDetails mustReadDetails;
	public List<SegmentWrapper> addedToSegmentCarouselList;
	public String expiresAt;
	public String lastValidatedAt;
	public String lastDismissedAt;
	public String lastMovedAt;
	public Boolean isLatest;
	public Boolean isScheduled;
	public Decimal versionId;
	public RejectionDetailWrapper rejectionDetails; 
	public List<SuggestedTopicsWrapper> listOfSuggestedTopics;
	public Boolean isProtectedAuthor;
	public Boolean isQuestionAnswerEnabled;
	public String onboardingAddedDate;
	public Integer readTime;
	
	public class RejectionDetailWrapper {
		public String message;
		public PeopleListWrapper rejectedBy;
		public String rejectedAt;
	}

	public ContentWrapper (){
		authoredBy = new PeopleListWrapper();
		editedBy = new PeopleListWrapper();
		usefulContent = new ContentUsefulWrapper();
        listOfFiles = new List<FileContentWrapper>();
        listOfInlineImages = new List<FileContentWrapper>();
		listOfTopAlbumImages = new List<AlbumImagesWrapper>();
		listOfInlineVideos = new list<FileContentWrapper>();
	}

	public class MustReadDetails{
		public String createdAt;
		public String removedAt;
		public String audience;
		public Integer audienceCount;
		public String message;
		public Integer readCount;
		public Integer unreadMustReadsCount;
		public String duration;
		public PeopleListWrapper createdBy;
		public String usertype;
	}
	public class SegmentWrapper{
		public String segmentId;
		public String segmentName;
	}
	public class PaginationWrapper {
        public String nextPageToken;
        public Integer totalRecords;
        Public List<ContentWrapper> listOfItems = new List<ContentWrapper>();
        public Map<String, Boolean> listOfDays;
        public List<PopularTopicsWrapper> popularTopics =  new List<PopularTopicsWrapper>();
    }
    
	public class SuggestedTopicsWrapper{
		public String id;
		public String name;
	}

    public class PopularTopicsWrapper{
		public Id id;
		public String name;
		public Integer pageCount;
	}
	
	public class ContentUsefulWrapper{
		public Boolean canViewHistory;
		public Boolean hasUserRated;
		public Boolean hasUserRatedUseful;
	}
	
	public class AlbumImagesWrapper{
		public String albumMediaId;
		public String thumbnailImg;
		public String img;
		public Boolean isVideo;
	}
	
	public class MediaWrapper{
		public String id;
		public String description;
	}
	public class RsvpWrapper{
		public String respondedWith;
		public Integer attendingCount;
		public Integer capacityCount;
		public String dueAtDate;
		public Boolean hasMaybeOption;
		public String noteLabel;
		public String noteValue;
		public Boolean canDownloadReport;
		public String reportUrl;
		public Boolean isExpired;
		public Boolean isRemovedFromAttendeeList;
		public String removedFromAttendeeListMessage;
	}

    public class ContentOrderWrapper {
        public string siteId;
        public string contentId;
        public List<String> contentIdsArray;
    }

	public class ContentSiteFeedWrapper {
		public string contentId;
		public string siteId;
		public string orgId;
        public string title;
        public string summary;
        public string imgUrl;
		public string authorName;
    }
    
	public List<TopicAssignment> getTopicList(List<String> contentIdSet){
		List<TopicAssignment> topicList = new List<TopicAssignment>();
		if(contentIdSet.size()>0){
			String queryToFetchTopic = 'SELECT Id,Topic.Id,Topic.name,EntityId FROM TopicAssignment WHERE EntityId IN:contentIdSet';
			if(SimpplrContext.isCommunitiesEnabled){
	    		queryToFetchTopic = queryToFetchTopic+' AND NetworkId = null';
	    	}
			topicList = Database.query(queryToFetchTopic);
		}
		return topicList;
	}
	
	
	public Integer compareTo(Object compareTo){
        ContentWrapper wrapperObj = (ContentWrapper) compareTo;
        if(relevancyScore==null || wrapperObj.relevancyScore==null){
        	return 0;
        }
        if (relevancyScore == wrapperObj.relevancyScore) return 0;
        if (relevancyScore > wrapperObj.relevancyScore) return -1;
        return 1;
    }
    
    public static ContentWrapper parse(String json){
		return (ContentWrapper) System.JSON.deserialize(json, ContentWrapper.class);
	}
}