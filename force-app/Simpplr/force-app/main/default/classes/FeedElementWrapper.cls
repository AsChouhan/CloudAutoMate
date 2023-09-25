/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class FeedElementWrapper {
	public String groupingId;
	public String id;
	public String createdAt;
	public PeopleLiteWrapper authoredBy;
	public PeopleLiteWrapper addressedTo; 
	public SiteLiteWrapper site;
	public FeedSiteWrapper createdSite;
	public String body; 
	public String bodyJson;
	public String postType;
	public List<PeopleLiteWrapper.PeopleMinWrapper> recognitionAwardedTo;
	public PeopleLiteWrapper.PeopleMinWrapper recognitionAwardedBy;
	public String recognitionAwardId;
	public String subType;
	public String objectId;
	public List<TopicWrapper> listOfTopics;
	public List<String> listOfLinks;
	public Boolean isLiked;
	public Integer likeCount;
	public Integer commentCount;
	public RecentCommentsContainerWrapper recentComments;
	public List<FeedElementWrapper> listOfPost; 
	public Boolean canEdit;
	public Boolean canFavorite;
	public Boolean canChangeTopics;
	public Boolean canDelete;
	public String feedElementType;
	public Boolean isBookmarked;
	public Boolean isFavorited;
	public Boolean canShare;
	public String likeId;
	public LinkWrapper link;
	public CampaignWrapper campaign;
	public List<FileWrapper> listOfFiles;
	public PollWrapper poll; 
	public ChangeContainerWrapper changes;
	public String url;
	public List<MentionWrapper> listOfMentions;
	public OriginalPostWrapper originalPost; 
	public postedOnWrapper postedOn;
	public Boolean isFileNewVersion;
	public Boolean includeInFeedOnPage;
	public Boolean isClosed;
	public Boolean canUploadAllFileTypes;
	public Boolean canAccessLeadercast;
	public ModerationResult moderationResult;
	public String questionId;
	/**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
	
	public class CreatedSiteWrapper {
		public String id;
		public String name;
		public String url;
		public Boolean isPrivate;
		public Boolean isListed;
		public Boolean isActivated;
	} 
	
	public class OriginalPostWrapper {
		public String id;
		public String url;
		public PeopleLiteWrapper authoredBy;
	}
	
	public class postedOnWrapper {
		public String id;
		public String name;
		public String url;
		public String title;
		public String type;
		public String siteId;
		public Integer postCount;
		public Integer questionCount;
		public Boolean isQuestionAnswerEnabled;
		public String description;
		public String imageUrl;
		public VideoWrapper video;
		public String promoted;
		public String createdAt;
		public PeopleLiteWrapper authoredBy;
		public SiteLiteWrapper site;
		public CategoryWrapper category;
		public List<AlbumImagesWrapper> listOfTopAlbumImages;
		public Boolean isPromoted;
		public Boolean isAvailable;
		public Boolean isMustRead;
		public Boolean hasRead;
		public String albumMediaId;
		public String downloadUrl;
		public Integer videoCount;
		public String publishAt;
		public String modifiedAt;
		public Boolean isOpenToSubmissions;
		public Integer imageCount;
		public Boolean isPublished;	
		public String startsAt; 
		public String endsAt;
		public String timezoneIso;
		public String timezoneName;
		public Integer timezoneOffset;
		public Boolean isAllDay;
		public Boolean isMultiDay;
		public String imgTHUMB720BY480URL;
		public String contentType;
		public Boolean isFromPromoteModal; 
		public Boolean hidePost; 
	}

	/**
	 * @description wrapper for Album items
	 */
	public class AlbumImagesWrapper{
		public String albumMediaId;
		public String thumbnailImg;
		public String img;
		public Boolean isVideo;
		public String provider;
		public string videoId;
		public Decimal status;
	}

	/**
	 * @description wrapper for video items
	 */
	public class VideoWrapper {
		public String id;
		public String provider;
	}

	/**
	 * @description wrapper for Category items
	 */
	public class CategoryWrapper {
		public String id;
		public String name;
		public String url;
	}
    
	/**
	 * @description wrapper for Moderation info
	 */
	public class ModerationResult {
		public Boolean isToxic;
		public List<String> categories;
		public String moderationStatus;
	}

	/**
	 * @description wrapper for recognition info
	 */
	public class RecognitionInfo {
		public String awardedTo;
		public String awardedBy;
		public String awardId;
		public String awardName;
		public String feedElementId;
		public String subType;
		public String objectId;
	}

	/**
	 * @description wrapper for recognition info
	 */
	public class RecognitionResponseInfo {
		public List<PeopleLiteWrapper.PeopleMinWrapper> recognitionAwardedTo;
		public PeopleLiteWrapper.PeopleMinWrapper recognitionAwardedBy;
		public String recognitionAwardId;
		public String recognitionAwardName;
		public String feedElementId;
		public String subType;
		public String objectId;
	}
}