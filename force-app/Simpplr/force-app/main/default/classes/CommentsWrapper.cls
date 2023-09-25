/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class CommentsWrapper {
	
	public String id;
	public String createdAt;
	public Boolean canEdit;
	public Boolean canDelete;
	public PeopleLiteWrapper authoredBy;
	public String body;
	public Boolean isLiked;
	public Integer likeCount;
	public String likeId;
	public List<FileWrapper> listOfFiles;
	public List<MentionWrapper> listOfMentions;
	public List<String> listOfLinks;
	
	public CommentsWrapper(){
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
		public String thumbnail;
		public String name;
		public String size;
		public String downloadURL; 
		public Boolean isAccessible; 
		public String url;
		public Boolean isDownloadableOniOS {get; set;}
		public String fileType;
		public String type;
    	public String fileExtension;
		public Boolean isImage;
		public String title;
		public String context;
		public String provider;
	}
}