/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class RecentCommentsWrapper {
	
	public String id;
	public String createdAt;
	public Boolean canEdit;
	public Boolean canDelete;
	public PeopleLiteWrapper authoredBy;
	public String body;
	public String bodyJson;
	public Boolean isLiked;
	public Integer likeCount;
	public String likeId;
	public List<FileWrapper> listOfFiles;
	public List<MentionWrapper> listOfMentions; 
	public List<String> listOfLinks;
	public List<TopicWrapper> listOfTopics;
	public LinkWrapper link;
	public String postType;
	public CampaignWrapper campaign;
	public Boolean canShare;
	public ModerationResult moderationResult;
	
	public RecentCommentsWrapper(){
		authoredBy = new PeopleLiteWrapper();
		listOfFiles = new List<FileWrapper>();
	}
	
	/**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
	public class FileWrapper {
		public String id;
		public String fileId;
		public String thumbnail;
		public String name;
		public String size;
		public String downloadURL; 
		public Boolean isAccessible; 
		public String url;
		public String fileType;
		public String type;
    	public String fileExtension; 
		public String spInstanceId;
		public Boolean isDownloadableOniOS {get; set;}
		public Boolean isImage;
		public Boolean isVideo;
		public String title;
		public String context;
		public String provider;
        public String rootDirectory;
        public Integer videoStatus;
	}

	/**
	 * @description wrapper for Moderation info
	 */
	public class ModerationResult {
		public Boolean isToxic;
		public List<String> categories;
		public String moderationStatus;
	}
	
}