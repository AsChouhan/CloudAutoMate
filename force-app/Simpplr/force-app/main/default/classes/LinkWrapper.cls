/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class LinkWrapper {
	
	public String id {get;set;}
	public String title {get;set;}
	public String url {get;set;}
	public String description {get;set;}
	public String imageUrl {get;set;}
	public VideoWrapper video {get;set;}
	public String promoted {get;set;}
	public String createdAt {get;set;}
	public PeopleLiteWrapper authoredBy{get;set;}
	public SiteLiteWrapper site{get;set;}
	public CategoryWrapper category {get;set;}
	public List<AlbumImagesWrapper> listOfTopAlbumImages;
	public Boolean isPromoted {get;set;}
	public Boolean isAvailable {get;set;}
	public Boolean isMustRead {get;set;}
	public Boolean hasRead {get;set;}
	public String albumMediaId {get;set;}
	public String downloadUrl {get;set;}
	public String type {get;set;}
	public Integer videoCount {get;set;}
	public Boolean isOpenToSubmissions {get;set;}
	public Integer imageCount  {get;set;}
	public Boolean isPublished {get;set;}	
	public Boolean isDeleted;
	public String startsAt; 
	public String endsAt;
	public String timezoneName;
	public String timezoneIso;
	public Integer timezoneOffset;
	public Boolean isAllDay;
	public Boolean isMultiDay;
	public String imgTHUMB720BY480URL {get;set;}
	public String contentType {get;set;}
	public Boolean isFromPromoteModal {get;set;}
	
	public LinkWrapper(){
	}
	
	/**
	 * @description wrapper for video items
	 */
	public class VideoWrapper {
		/**
		 * @description id value for video
		 */
		public String id {get;set;}
		/**
		 * @description provider value for video
		 */
		public String provider {get;set;}
		/**
		 * @description videoStatus value for video
		 */
		public Decimal videoStatus {get;set;}
		/**
		 * @description thumbnailImg value for video
		 */
		public String thumbnailImg {get;set;}
	}
	
	/**
	 * @description wrapper for Category items
	 */
	public class CategoryWrapper {
		/**
		 * @description id value for category
		 */
		public String id {get;set;}
		/**
		 * @description name value for category
		 */
		public String name {get;set;}
		/**
		 * @description url value for category
		 */
		public String url {get;set;}
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
}