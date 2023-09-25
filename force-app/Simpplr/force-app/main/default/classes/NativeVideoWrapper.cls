public with sharing class NativeVideoWrapper {

    public class VideoCategoryWrapper {
        public String siteId;
        public String directory;
        public Video mediaParams;
        public UploadResponse uploadVideoResponse;
    }

    public class Video {
        public String id;
        public String name;
        public String description;
    }

    public class UploadResponse{
        public String fileName ;
        public String fileSize ;
        public String uploadedFileSize ;
        public String userId;
        
    }

    public class peopleWrapper{
        public String peopleId;
        public String firstName; 
        public String lastName;
        public String name;
        public String email;
        public String country;
        public String city;
        public String state;
        public String zip;
        public Boolean isAppManager;
        public String url;
    }
    public class VideoMoveWrapper{
        
        public string oldSiteId ;
        public String newSiteId ;
        public String entryId ;
        public Long size ;
    }
    public class VideoReferencesWrapper{
        public List<ReferenceItemWrapper> results;
        public String nextPageToken;
    }
    public class ReferenceItemWrapper{
        public ReferenceContentWrapper content;
        public ReferenceFeedWrapper feedPost;
        public ReferenceTileWrapper tile;
        public String id;
        public String peopleId;
        public Boolean isContent;
        public Boolean isSiteFeedPost;
        public Boolean isHomeFeedPost;
        public Boolean isBlog;
        public String videoUploadDate;
        public Boolean isHomeTile;
        public Boolean isSiteTile;
    }
    public class ReferenceFeedWrapper{
        public string url ;
        public string id ;
        public Boolean isHomeFeed ;
        public Boolean isSiteFeed ;
        public PeopleLiteWrapper authoredBy;
        public SiteLiteWrapper site;
    }
    public class ReferenceContentWrapper{
        public String id ;
        public String url;
        public String contentId;
        public String title ;
        public String type ;
        public String img;
        public String imgLandscape;
        public String imgOriginal;
        public String imgLayout;
        public String imgCaption;
        public String language;
        public String timezoneIso;
        public String timezoneName;
        public Integer timezoneOffset;
        public String startsAt;
        public String endsAt;
        public Boolean isAllDay;
	    public SiteLiteWrapper site;
        public PeopleLiteWrapper authoredBy;
    }

    /**
     * @description wrapper for Tile
     */
    public class ReferenceTileWrapper{
        public string url ;
        public string id ;
        public SiteLiteWrapper site;
    }

    /**
     * @description VideoSearchFilter attributes
     */
    public class VideoSearchFilter {
		public String site; 
        public String term;
        public String owner;
        public Integer size;
        public Integer nextPageToken;
	}

    /**
     * @description VideoResultWrapper attributes
     */
    public class VideoResultWrapper {
		public Object nextPageToken;
		public Object totalRecords;
		public List<FileListingWrapper> listOfItems;
	}
}