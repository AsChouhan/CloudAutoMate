public with sharing class AIWrapper {
    
    public class ContentWrapper {
        public String id;
        public String title;
        public String text_intro;
        public String site_id;
		public String site_type;
        public String type;
        public String publishStartDate;
        public String expires_at;
        public String page_category;
        public List<String> topic_list;
    }

    public class CommentsToxicityWrapper {
        public String version;
        public Boolean isToxic;
        public List<String> reasons;
    }

    public class ModerationDataWrapper {
        public String chatterCommentId;
        public ModerationMetaDataWrapper moderationMetadata;
        public List<ModerationRepliesWrapper> replies;
    }

    public class ModerationRepliesWrapper {
        public String chatterReplyId;
        public ModerationMetaDataWrapper moderationMetadata;
    }

    public class ModerationMetaDataWrapper {
        public String moderationStatus;
    }

    public class TopicWrapper {
        public List<TopicsTagWrapper> listOfTopics;
    }

    public class TopicsTagWrapper {
        public String tagId;
        public String tagName;
    }

    public class ModerationQueueWrapper {
        public Integer total;
        public List<ModerationQueueItem> listOfItems; 
        public String nextPageToken;
        public String updatesToken;
        public String type;
        public String sortBy;
    }

    public class ModerationQueueItem {
        public PeopleLiteWrapper authoredBy;
        public String body;
        public String createdAt;
        public String timeStamp;
        public String id;
        public List<MentionWrapper> listOfMentions;
        public String postType;
        public String url;
        public String contentId;
        public String contentTitle;
		public SiteListingWrapper site;
        public String publishAt;
        public List<Object> reportReason;
        public String reportedBy;
        public String reporterId;
        public String reportedOn;
        public String type;
        public ContentLiteWrapper content;
        public PeopleLiteWrapper reporterDetails;
        public PeopleLiteWrapper user;
        public PeopleLiteWrapper moderator;
        public String moderatedOn;
        public String moderationStatus;
        public String moderationId;
        public String parentCommentId;
        public String lastUpdatedOn;
    }

    public class ContentLiteWrapper{
		public string id;
		public string type;
		public string url;
		public string title;
		public string publishAt;
		public string img;
		public string imgLandscape;
	}

    public class HistoryFiltersWrapper{
        public List<SiteWrapper> sitesList;
        public List<UserWrapper> usersList;
        public List<ModeratorWrapper> moderatorsList;
    }

    public class FiltersDataWrapper{
        public List<SiteWrapper> sitesList;
        public List<ReporterWrapper> reportersList;
    }

    public class SiteWrapper{
        public String siteId;
        public String siteName;
    }

    public class ReporterWrapper{
        public String reporterId;
        public String reporterName;
    }

    public class UserWrapper{
        public String userId;
        public String userName;
    }

    public class ModeratorWrapper{
        public String moderatorId;
        public String moderatorName;
    }

    public class AnalyticsTopicSuggestion{
        public String id;
        public String content_id;
        public List<String> suggested_topics;
        public List<String> content_topics;
        public Date record_date;
        public String org_id_content_id;
        public String record_id;
        public String people_id;
        }

}