public class JSONFeedElementWrapper {
	
	public String id;
	public Body body;
	public Boolean canShare;
	public Capabilities_Y capabilities;
	public String createdDate;
	public String feedElementType;
	public Header header;
	public OriginalFeedItemActor originalFeedItemActor;
	public OriginalFeedItem originalFeedItem;
	public User parent;
	public String type;
	public String url;
	public Actor actor;
	
	public class OriginalFeedItem{
		public string id;
		public string url;
	}
	
	public class Actor{
		public string id;
		public string displayName;
		public Photo Photo;
	}
	public class Capabilities_Y {
		public ChatterLikes chatterLikes;
		public Comments comments;
		public Content content;
        public Poll poll;
        public Link link;
        public Topics topics;
		public Files files;
	}
	
	public class Topics {
	    public boolean canAssignTopics;
	    public List<TopicItem> items;
	}
	
	public class TopicItem {
	    public String createdDate;
	    public String id;
	    public String name;
	}
	
	public class Choices {
		public String id;
		public Integer position;
		public String text;
		public Integer voteCount;
		public Decimal voteCountRatio;
	}
    public class Poll {
		public List<Choices> choices;
		public Integer totalVoteCount;
	}
    public class Link {
		public String url;
		public String urlName;
	}
	public class User {
		public String displayName;
		public String firstName;
		public String id;
		public String lastName;
		public String name;
		public String type;
		public Photo photo;
	}
	public class Photo {
		public String photoVersionId;
		public String standardEmailPhotoUrl;
	}

	public class MessageSegments_Y {
		public String text;
		public String type;
		public String name;
		public Record record;
        public String tag;
        public String url;
         public String htmlTag;
	}
	public class MessageSegments {
		public String text;
		public String type;
		public String name;
		public Record record;
        public String tag;
        public String url;
        public String htmlTag;
		public String markupType;
		public String altText;
	}
	public class MessageSegments_Z {
        public Reference reference;
		public String text;
		public String type;
        public String tag;
        public String url;
        public String id;
	}
	public class Reference {
		public String id;
		public String url;
	}
	public class LikesMessage {
		public List<MessageSegments_Z> messageSegments;
		public String text;
	}
    public class Header {
		public List<MessageSegments_Z> messageSegments;
		public String text;
		public String id;
	}

	public class Pages {
		public List<Items> items;
		public Integer total;
	}

	public class Page_Z {
		public List<Items_Z> items;
		public Integer total;
	}

	public class Capabilities {
		public Content content;
	}
	
	public class Items_Z {
		public Body_Z body;
		public Capabilities capabilities;
		public String createdDate;
		public String id;
        public String name;
		public Likes likes;
		public String type;
		public String url;
		public User user;
	}

	public class Content {
		public String downloadUrl;
		public String fileExtension;
		public String fileSize;
		public String fileType;
		public String id;
		public String versionId;
		public String title;
	}
	
	public class Files {
		public List<Content> items;
	}	

	public class Items {
		public String id;
		public String url;
	}

	public class Comments {
		public Page_Z page;
	}

	public class Body {
		public List<MessageSegments> messageSegments;
		public String text;
	}

	public class Likes {
		public Integer total;
	}

	public class Record {
		public String displayName;
		public String firstName;
		public String id;
		public String lastName;
		public String name;
		public String type;
		public String url;
		public string additionalLabel;
	}

	public class OriginalFeedItemActor {
		public String firstName;
		public String displayName;
		public String id;
		public String lastName;
		public String name;
		public String title;
		public String type;
	}
	public class ChatterLikes {
		public LikesMessage likesMessage;
		public Pages page;
	}

	public class Body_Z {
		public List<MessageSegments_Y> messageSegments;
		public String text;
	}
	
	public static JSONFeedElementWrapper parse(String json) {
		return (JSONFeedElementWrapper) System.JSON.deserialize(json, JSONFeedElementWrapper.class);
	}
}