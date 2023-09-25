public with sharing class Criteria {
	
	public class Blog {
		public String siteId;
		public String topicId;
		public String nextPageToken; 
		public Integer size;
		public String sortBy; 
		public String filter;
		public String term;
		public String eventDate;
		public String category;
		public String userId;
		public String peopleId;
		public String profileId;
		public Boolean groupCategories;
		public String provider;
		public String pageName; 
		public Integer offset;
		public String publishStartDate;
		public String authoredBy;
		public Boolean isGlobalSearchReq {get{
			if(isGlobalSearchReq==null){ isGlobalSearchReq = false;}
			return isGlobalSearchReq;
		}set;}
		public Set<String> contentIdSet= new Set<String>();
	}
	
	public class Pages {
		public String siteId;
		public String topicId;
		public String nextPageToken; 
		public Integer size;
		public String sortBy; 
		public String filter;
		public String term;
		public String eventDate;
		public String category;
		public String userId;
		public String profileId;
		public Boolean groupCategories;
		public String provider;
		public String pageName; 
		public Integer offset;
		public String publishStartDate; 
		public String authoredBy;
		public Boolean isGlobalSearchReq {get{
			if(isGlobalSearchReq==null){ isGlobalSearchReq = false;}
			return isGlobalSearchReq;
		}set;}
		public List<Id> topics;
        public Set<String> contentIdSet= new Set<String>();
        public String publishStartDateSpan; 
        public String contentSubType; 
	}
	
	public class Event {
		public String siteId;
		public String topicId;
		public String nextPageToken; 
		public Integer size;
		public String sortBy; 
		public String filter;
		public String period;
		public String source;
		public Boolean isPromoted;
		public String term;
		public String eventDate;
		public String category;
		public String userId;
		public String calendarId;
		public String profileId;
		public Boolean groupCategories;
		public String provider;
		public String pageName; 
		public Integer offset;
		public String publishStartDate; 
		public String authoredBy;
		public Boolean isGlobalSearchReq {get{
			if(isGlobalSearchReq==null){ isGlobalSearchReq = false;}
			return isGlobalSearchReq;
		}set;}
        public Set<String> contentIdSet= new Set<String>();
        public String publishStartDateSpan; 
	}
	
	public class Album {
		public String siteId;
		public String topicId;
		public String nextPageToken; 
		public Integer size;
		public String sortBy; 
		public String filter;
		public String term;
		public String eventDate;
		public String category;
		public String userId;
		public String profileId;
		public Boolean groupCategories;
		public String provider;
		public String pageName; 
		public Integer offset;
		public String publishStartDate; 
		public String authoredBy;
		public Boolean isGlobalSearchReq {get{
			if(isGlobalSearchReq==null){ isGlobalSearchReq = false;}
			return isGlobalSearchReq;
		}set;}
		
		public String action;
		public String videoUrl;
		public String id;
		public String videoProvider;
		public String fileIdToRemove;
		public String fileDescription;
		public String fileIdToProcess;
		public String photoUrl;
		public String fileContentDocId;
		public String fileContentVersionId;
		public String thumbsnailUrl;
		public String videoId;
		public Set<String> contentIdSet= new Set<String>();
		public String videoTitle;
        public String videoThumbsnailImg;
        public String publishStartDateSpan; 
	}
	
	public class Site {
		public String siteId;
		public String segmentId;
		public String origin;
		public String cid;
		public String topicId;
		public String nextPageToken; 
		public Boolean isCorrectionEnabled;
		public Integer size;
		public String term;
		public Boolean canSubmitQuestion;
		public String filter;
		public String category;
		public String userId;
		public String sortBy; 
		public Boolean canAccess;
		public Boolean canManage;
		public Boolean isManager;
		public Boolean includeDeactivated;
		public String profileId;
		public String peopleId;
		public String sfUserId;
		public Boolean groupCategories;
		public String pageName; 
		public Integer offset;
		public Boolean isFullModel;
		public Boolean isPrivate;
		public Boolean isGlobalSearchReq {get{
			if(isGlobalSearchReq==null){ isGlobalSearchReq = false;}
			return isGlobalSearchReq;
		}set;}
        public Set<Id> setOfIdToExclude;
		public Set<Id> setOfCollGroupId;
		
	}
	
	public class ChatterGroup {
		public String chatterGroupId;
		public String name;
		public String url;
		public String nextPageToken; 
		public Integer size;
		public String term;
		public String filter;
		public String access;
		public String memberCount;
		public String sortBy; 
		public Integer offset;
	}
	
	public class People { 
		public String audienceId;
		public String segmentId;
		public String limitToSubsegment;
		public String subscriptionId;
		public String siteId;
		public Boolean isPrivate;
		public String expertiseId;
		public String nextPageToken;
		public String chatterGroupId;
		public Integer size;
		public String sortBy;
		public String filter;
		public String type;
		public String term;
		public Boolean isCorrectionEnabled;
		public String category; 
		public String invitableToEventId ;
		public String sfUserId;
		public String department;
		public String location;
		public String userCategory;
		public Integer offset;
		public String name_term;
		public String title_term;
		public String telephone_term;
		public String phone_term;
		public String city_term;
		public String state_term;
		public String country_term;
		public String contentId;
		public String origin;
		public String includeMemberTypeForSite;
		public Boolean isFullModel;
		public String expertise_term;
		public ExpertiseWrapper expertise;
		public Boolean includeTotal;
		public Boolean isGlobalSearchReq {get{
			if(isGlobalSearchReq==null){ isGlobalSearchReq = false;}
			return isGlobalSearchReq;
		}set;}
        public String Custom_Field_1;
        public String Custom_Field_2;
        public String Custom_Field_3;
        public String Custom_Field_4;
        public String Custom_Field_5;
        public String Custom_Field_6;
        public String Custom_Field_7;
        public String Custom_Field_8;
        public String Custom_Field_9;
        public String Custom_Field_10;
        public String Custom_Field_11;
        public String Custom_Field_12;
        public String Custom_Field_13;
        public String Custom_Field_14;
        public String Custom_Field_15;
        public String Custom_Field_16;
        public String Custom_Field_17;
        public String Custom_Field_18;
        public String Custom_Field_19;
        public String Custom_Field_20;
        public String Custom_Field_21;
        public String Custom_Field_22;
        public String Custom_Field_23;
        public String Custom_Field_24;
        public String Custom_Field_25;								
		public String filterDays;
	}
	
	public class File {
		public String id;
		public String name;
		public Boolean isCorrectionEnabled;
		public Boolean fullText;
		public String fileId;
		public String fileType;
		public String publishStartDate;
		public String site;
		public String permissions;
		public String currentDirectory;			// Source Folder
		public String currentRootDirectory;	// Source Drive
		public String action;
		public String siteId;
		public String type;
		public String topicId;
		public String view;
		public String nextPageToken;
		public String nextPageUrl;
		public Integer size;
		public String sortBy;
		public String filter;
		public String owner;
		public String term;
		public String eventDate;
		public String category;
		public String userId;
		public Boolean groupCategories;
		public String provider;
		public String pageName;
		public Integer offset;
		public String albumId;
		public String fileStorageSource;
		public Boolean isMediaManager;
		public String directory;							// Destination Folder
		public String rootDirectory;						// Destination Drive
		public String parentDirectory;	// Added for handle multi parent in google drive
		public Boolean isPaginationEnabled;
		public String context;
		public Boolean hideProviderSystemDirs;
		public String origin;
		public String driveType;
		public String spInstanceId;
		public String externalUrl;
		public Boolean isGlobalSearchReq {get{
			if(isGlobalSearchReq==null){ isGlobalSearchReq = false;}
			return isGlobalSearchReq;
		}set;}
		public String versionHistoryId;
	}
	
	public class Notification {
		public Boolean includeActioned;
		public String siteId;
		public Integer nextPageToken;
		public Integer size;
		public String sortBy;
		public String filter;
		public String since;
		public Integer offset;
		public String peopleId;
		public String origin;
		public Boolean markAsSeen;
		public Boolean includeFeedNotification;
		public String languageLocaleKey;
	}
	
	/**
     * @description NotificationList helps in accepting notificationListJson 
     * @return null
     */
    public class NotificationList {
		public String notificationsListJson; 
	}
	
	public class Feed {
		public String nextPageToken {get; set;}
		public String postId;
		public Integer size;
		public String communityId;
		public String feedElementId;
		public Boolean setBookmark; 
		public String action;
		public String likeId;
		public String commentId;
		public String textBody;
		public String subjectId;
		public String feedElementType;
		public List<String> listOfTopic;
		public String urlArg;
		public String urlName;
		public List<String> listOfPollChoice;
		public String contentDocumentId;
		public String fileId;
		public String versionNumber;
		public String siteId;
		public String myChoiceId;
		public String commentText;
		public String originalFeedElementId;
		public String userId;
		public String sfUserId;
		public String peopleId;
		public String term;
		public String locationURL;
		public String filterValue;
		public List<String> listOfAttachedFileId;
		public ModerationResult moderationResult;
		public FeedElementWrapper.RecognitionInfo recognitionBody;
		public String bodyJson;
		public List<ExternalFileWrapper> externalFiles;
		public String creatorUserId;
	}
	
	public class Topic {
		public String siteId;
		public String topicId;
		public String nextPageToken;  
		public Integer size;
		public String sortBy;
		public String filter;
		public String term;
		public String eventDate;
		public String category;
		public String userId;
		public String provider;
		public String pageName; 
		public Integer offset;
		public Boolean isGlobalSearchReq {get{
			if(isGlobalSearchReq==null){ isGlobalSearchReq = false;}
			return isGlobalSearchReq;
		}set;}
	}
	
	public class Box {
		public String name;
	}
	
	public class Folder {
		public String name;
		public String path{set;get;}
		public String webUrl;
		public String permissions;
		public String directory;
		public String currentDirectory;
		public String rootDirectory;
		public String siteId;
		public String sharepointSiteId;
		public String storage{set;get;}
        public OwnerWrapper owner;
        public String type; 
        public String term;
        public String nextPageToken;
        public Integer size; 
	}
	
	public class SearchStats {
		public String url;
		public String term;
		public String siteId;
		public Integer totalResultCount;
		public long totalTimeTaken;
		public List<String> sections;
	}
	
	public class SearchResultsSelectStats{
		public String section;
		public String term;
		public Integer position;
		public Integer pagePosition;
		public String itemtype;
		public String itemId;
		public String context;
		public Double score;
		public Boolean isExternal;
		public String siteId;
		public String subsection;
	}
	
	public class SearchResponseStats {
		public String name;
		public String status;
		public Integer resultCount;
		public long timeTaken;
	}
	
	public class FileDeleteParams {
		public List<String> fileId;
		public String rootDirectory;
		public String provider;
		public String fileSiteId; 
	} 
	
	public class FolderDeleteParams {
		public List<String> folderId;
		public String provider;
		public String siteId;
		public String rootDirectory;
	} 
	
	public class FeedbackParams {
		public String feedbackMsg;
		public String pageUrl;
        public String pageTitle;
        public String helpTopics;
        public Boolean emailProductResearch;
	}
	
	public class Segment {
		public Boolean isFullModel;
		public Boolean includeUnassigned;
	}
	
	public class Subscription {
		public String segmentId;
		public Boolean excludeSegments;
		public String siteId;
		public Integer size;
		public Integer nextPageToken;
		public Integer offset;
	}
	
	// File Move Wrapper
	public class FileMove{
		public List<File> fileArray;
		public String siteId;
		public String source;
		public String destination;
		public String provider;
		public String sourceRoot;
		public String destinationRoot;
	}
	
	public class OwnerWrapper {
		public String id;
		public String name;
		public String URL;
	}

	public class ContentMove {
		public List<String> contentIdList;
		public String siteId;
		public String categoryId; 
	}

	public class ContentSearchFilter {
		public Integer offset;
		public Integer recordLimit;
		public String siteId;
		public String contentType;
		public String excludeType;
		public String searchText;
		public String sortBy;
		public DateTime publishStartDateTime;
		public String author;
		public DateTime maxAllowedEventEndDateTime;
		public Boolean isAllContent;
		public Boolean futureEventsOnly;
	}

	public class Audience {
		public String nextPageToken;
		public Integer offset;
		public Integer size;
		public String segmentId;
		public String term;
	}

	public class AudienceDeleteParams {
		public String audienceId;
		public Boolean fromEditModal;
	}

    public class ExternalSearchReq {
        public Boolean isCorrectionEnabled;
		public Boolean isPrivate;
        public String section;
		public String siteId; 
		public String site; 
        public Integer size;
        public String term;
        public String nextPageToken;
		public String type;
        public String contentType; 
		public String contentSubType; 
		public Boolean includeAllContents;
		public Boolean canSubmitQuestion;
		public Set<Id> targetGroupIds;
		public List<String> listOfAllowedFeatures;
        public String author;
        public List<TopicWrapper> topic;
        public String publishStartDate; 
        public String department;
        public String location; 
		public ExpertiseWrapper expertise;
		public String userCategory;
        public String owner;
        public String fileType;
        public String chatterGroupId;
        public String eventOccurrence; 
        public String pageCategory; 
		public String filter;
		public String requestType; 
		public String sortBy;
		public Boolean canManage;
		public String order;
		public String custom_field_1;
        public String custom_field_2;
        public String custom_field_3;
        public String custom_field_4;
        public String custom_field_5;
		public String custom_field_6;
        public String custom_field_7;
        public String custom_field_8;
        public String custom_field_9;
        public String custom_field_10;
		public String custom_field_11;
        public String custom_field_12;
        public String custom_field_13;
        public String custom_field_14;
        public String custom_field_15;
		public String custom_field_16;
        public String custom_field_17;
        public String custom_field_18;
        public String custom_field_19;
        public String custom_field_20;
		public String custom_field_21;
        public String custom_field_22;
        public String custom_field_23;
        public String custom_field_24;
        public String custom_field_25;						
		public String status;
		public String authorId;
		public  Boolean canSendAlert;
		public String authoredBy;
		public String source;
		public List<String> contentContributed;
		public List<String> favouriteIds;
		public String recipient;
		public Set<Id> siteSet;
		public String provider;
		public List<String> ContentIds;
		public String ppl_segment_id;
		public String duration;
		public String fieldName;
		public String tileDashboard;
		public String topicId;
		public String category;
		public String contentId;
		public String collaborationId;
		public String audienceType;
	}

	public class Question {
		public String siteId; 
		public String site; 
        public Integer size;
        public String term;
		public Integer nextPageToken;
		public String sortBy; 
		public String filter;
		public Integer Offset;
		public String section;
	}
	
	public class RemoveAntendee{
        public String contentId;
        public List<String> peopleIds;
        public String note;
 
    }
	
    public class ContentTemplateSearchWrapper {
        public String nextPageToken;
        public Integer size;
        public String siteId;
        public String type;
        public String term;
        public String sortBy;
    }

	public class ModerationResult {
		public Boolean isToxic;
		public List<String> categories;
	}

	public class ExternalFileWrapper{	
		public String title;
		public String context;
		public String fileId;
		public Integer size;
		public String type;
		public String url;
		public String id;
		
		
	}
	
}