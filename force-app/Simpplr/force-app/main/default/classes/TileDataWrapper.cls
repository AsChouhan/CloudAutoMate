/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class TileDataWrapper {
	
	/**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
	public class TileOrderData {
		public String layout;
		public Boolean canManage;
		public Boolean isManagerControlled;
		public Boolean isDefaultConfigured;
		public String modifiedAt;
		public PeopleDetail modifiedBy = new PeopleDetail();
		public Boolean isProcessing;
		public List<TilesOrder> listOfItems = new List<TilesOrder>();
		public FileContentWrapper banner;
	}
	
	/**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
	public class PeopleDetail{
		public String id;
		public String name;
		public String url;
		public String img;
	}
	public class TilesOrder {
		public String id;
		public String type;
		public String title;
		public boolean adminControlled;
		public Integer order;
		public Integer mobileDashboardIndex;
		public String column;
		public String variant;
		public Boolean isNewlyPushed;
		public String description;
	}
	
	public class TileData{
		public String id;
		public String contentId;
		public String siteId;
		public String chatterGroupId;
		public String userId;
		public String name;
		public String department;
		public String location;
		public Boolean isFollowing;
		public Boolean canFollow;
		public String sfUserId;
		public Boolean isMember;
		public Boolean isOwner;
		public Boolean isManager;
		public Boolean isContentManager;
		public String startsAt;
		public String endsAt;
		public String timezoneName;
		public String timezoneIso;
		public Integer timezoneOffset;
		public Boolean isMultiDay;
		public Boolean isAllDay;
		public String createdAt;
		public String publishAt;
		public String modifiedAt;
		public Boolean isPrivate;
		public Boolean isPublic;
		public Boolean isListed;
		public Boolean isPromoted;
		public String provider;
		public String image1x1URL;
		public Integer imageCount;
		public Integer videoCount;
		public String type;
		public String fileExtension;
		public List<String> listOfImages1x1 = new List<String>();
		public List<String> listOfImages16x9 = new List<String>();
		public List<AlbumImagesWrapper> listOfTopAlbumImages = new List<AlbumImagesWrapper>();
		public Integer attending;
		public Integer pageCount;
		public Integer siteCount;
		public Category category;
		public RsvpWrapper rsvp;
		
		public String img;
		public String imgLandscape;
		public Integer memberCount;
		public String birthday;
		public String hireDate;
		public String thumbnail;
		public Integer size;
		public String status;
		public String downloadUrl;
		public Boolean canDownload; // for google drive tile (recent/starred)
		public Boolean isAccessible;
		
		public String role;
		public SiteLiteWrapper site;
		public PeopleListWrapper authoredBy;
		
		public String label;
		public String iconImg;
		public String peopleId; 
		public Boolean isFavorited; 
		public Boolean isActive;
		public Boolean isMustRead; 
		public boolean canMakeMustRead;
		public Boolean hasRead;
		public String fileId;
		public String rootDirectory;

		public String campaignId;
		public String defaultDescription;
		public PeopleListWrapper createdBy;
		public CampaignWrapper.NetworksWrapper networks;

		public String url;
		public String text;
		public FileListingWrapper imageFile;
		public FileListingWrapper videoFile;
		public OembedModel oembed;
		public String title;
		public String description;
		public String variant;
		public Boolean showInfo;
		public List<TileData> links;
		public String excerpt;
		public String summary;
		public String spInstanceId;
		public Boolean isMandatory;
		public Boolean isInMandatorySubscription;
		public Boolean isFeatured;
		public String contentDocumentid;
		public String imgUrl;
		public String imgLandscapeUrl;
	}
	
	public class AddTile{
		public String title;
		public Boolean saveToLibrary;
		public String description;
		public Boolean pushToAllHomeDashboards ;
		public String type;
		public String variant;
		public Options options;
		public List<String> items;
	}
	
	/**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
	public class LatestHiresData {
		public Options options = new Options();
		public List<TileData> listOfItems = new List<TileData>();
		public String id;
	}
	
	public class AlbumImagesWrapper{
		public String albumMediaId;
		public String thumbnailImg;
		public String img;
		public String contentDocumentId;
		public String imgUrl;
	}

	public class GoogleCalendarData {
		public Options options = new Options();
		public List<Object> listOfItems = new List<Object>();
		public String nextPageToken;
		public String id;

	}

	public class OutlookCalendarData {
		public Options options = new Options();
		public String id;
	}
	
	/**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
	public class TrendingTopics {
		public String id;
		public String name;
		public String url;
	}
	
	/**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
	public class ContentData {
		public Options options = new Options();
		public List<TileData> listOfItems = new List<TileData>();
		public String id;
	}
	
	public class CampaignData {
		public Options options = new Options();
		public List<TileData> listOfItems = new List<TileData>();
		public String id;
	}
	
	public class ContentTabData {
		public List<TileData> listOfItems = new List<TileData>();
		public String section;
	}
	
	public class LatestPopularContentTileData {
		public String id;
		public Options options = new Options();
		public List<ContentTabData> listOfItems = new List<ContentTabData>();
	}
	
	public class LatestPopularCampaignTileData {
		public String id;
		public Options options = new Options();
		public List<CampaignTabData> listOfItems = new List<CampaignTabData>();
	}
	
	public class CampaignTabData {
		public List<TileData> listOfItems = new List<TileData>();
		public String section;
	}		
	
	public class CategoriesData {
		public Options options = new Options();
		public List<TileData> listOfItems = new List<TileData>();
		public String id;
	}
	
	
	/**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
	public class RecentActivities {
		public String recentActivitiesURL;
		public String recentActivitiesText;
		public String recentActivitiesId;
	}
	
	
	/**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
	public class MySitesData {
		public Options options = new Options();
		public List<TileData> listOfItems = new List<TileData>();
		public String id;
	}
	
	public class HelpLink4Widget {
		public String title;
    	public String url;
	}
	
	/**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
	public class MyHelpLinkData {
		public List<TileData> listOfItems = new List<TileData>();
		public Options options = new Options();
		public String id;
	}
	
	
	/**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
	public class FileData {
		public String id;
		public Options options = new Options();
		public List<TileData> listOfItems = new List<TileData>();
	}
	
	public class FileDataGoogleDrive {
		public String id;
		public Options options = new Options();
		public List<TileDataSection> listOfItems = new List<TileDataSection>();
	}
	
	public class TileDataSection {
		public String section;
		public List<TileData> listOfItems = new List<TileData>();
	}
	
	/**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
	public class PeopleData {
		public Integer total;
		public Options options = new Options();
		public String siteId;
		public String id;
		public List<TileData> listOfItems = new List<TileData>();
	}
	
	/**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
	/*public class Apps {
		public String url;
		public String label;
		public String iconImg;
	}*/
	
	/**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
	public class ListOfAnswers {
		public String id;
		public String title;
		public Integer voteCount;
		public Integer percentage;
	}
	
	
	/**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
	public class AppData {
		public List<TileData> listOfItems = new List<TileData>();
		public String id;
		public Options options = new Options();
	}
	
	/**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
	public class RSS {
		public string title;
		public string url;
		public Integer size;
		public string excerpt;
		public string postedAt;
             
	}
	
	/**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
	public class RSSData {
		public List<RSS> listOfItems = new List<RSS>();
	}
	
	/**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
	
	public class TileDataSettings {
		public String spInstanceId;
		public Integer size{get;set;}
		public String layout{get;set;}
		public String type{get;set;}
		public String code{get;set;}
		public Integer height{get;set;}
		public Boolean posts{get;set;}
		public Boolean faces{get;set;}
		public Boolean cover{get;set;}
		public String stopDateTime{get;set;}//stores GMT Date
		public String stopDate;
		public String stopTime;
		public Boolean siteFollowers;
		public Boolean siteMembers;
		public String message;
		public Integer counter;
		public String endTitle{get;set;}
		public List<TileData> listOfItems{get;set;}
		public String value{get;set;}
		public String id{get;set;}
		public Set<Id> idSet{get;set;}
		public String siteId{get;set;}
		public String siteFilter{get;set;}
		public String pageCategoryId{get;set;}
		public String url{get;set;}
		public OembedModel oembed;
		public FileListingWrapper imageFile;
		public FileListingWrapper videoFile;
		public String title{get;set;}
		public String description;
		public String hireDaysThreshold;
		public String celebrationsPeople;
		public String celebrationsDays;
		public Boolean showInfo;
		public Map<String, String> calendar;
		public Map<String, String> outlookCalendar;
		public String addedAt;
	}
	
	public class WidgetOptions{
        public Options options;
        public String id;
	}
	
	public class FacebookWidgetOptions{
        public FacebookWidget options;
	}
	
	public class FacebookWidget {
		public Integer height;
		public String code;
		public String url;
		public Boolean showPosts;
		public Boolean showFaces;
		public Boolean showCover;
	}
	
	public class PageCategory {
		public String id;
		public String name;
		public String url;
	}
	
	public class HTMLWidgetOptions{
        public HTMLWidget options;
	}
	
	public class HTMLWidget {
		public Integer height;
		public String code;
	}
	
	public class Options{
		public String type;
		public String text;
		public String thresholdDays;
		public Integer size;
		public Integer height;
		public Boolean showPosts;
		public Boolean showFaces;
		public Boolean showCover;
		public String code;
		public String html;
		public List<TileData> links;
		public List<TileData> files ;
		public String stopAt;
		public String endMessage;
		public String widgetId;
		public Boolean showImages;
		public Integer totalNotShown;
		public String siteFilter;
		public String siteId;
		public String siteName;
		public String pageCategoryId;
		public String pageCategoryName;
		public String layout;
		public String url;
		public FileListingWrapper imageFile;
		public FileListingWrapper videoFile;
		public OembedModel oembed;
		public String title;
		public String description;
		public Boolean showInfo;
		public String hireDaysThreshold;
		public String celebrationsPeople;
		public String celebrationsDays;
		public Map<String, String> calendar;
		public Map<String, String> outlookCalendar;
		public MembershipType membershipType;
		public String addedAt;
	}
	
	public class MembershipType{
		public Boolean siteMembers;
		public Boolean siteFollowers;
	}
	public class Category{
		public String id{get;set;}
		public String categoryId{get;set;}
		public String name{get;set;}
		public String url{get;set;}
	}
	
	public class onboardingTileData{
		public Options options = new Options();
		public List<Object> listOfItems = new List<Object>();
		public String id;
	}
}