/**
* @Class PageListingWrapper 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class PageListingWrapper implements Comparable {
	
	public String id; 
	public String img;
	public String url;
	public String title;
	public String type;
	public String excerpt;
	public String summary;
	public Boolean isPromoted;
	public String createdAt;
	public String publishAt;
	public String modifiedAt;
	public PageListingWrapper.ArticleCategory category = new PageListingWrapper.ArticleCategory();
	public PeopleLiteWrapper authoredBy  = new PeopleLiteWrapper();
	public SiteLiteWrapper site = new SiteLiteWrapper();
	public Boolean isLiked;
	public Integer likes;
	public Boolean isBookmarked;
	public Boolean isFavorited;
	public Integer comments;
	public Boolean canEdit;
	public String siteId;
	public Double relevancyScore;
	public String imgThumbnail;
	public Boolean isMustRead;
	public Boolean hasRead;
	public FileContentWrapper imgLandscapeFile;
	public String imgLandscape;
	public FileContentWrapper imgFile;
	
	public PageListingWrapper(){
	 	
	}
	
	public PageListingWrapper(PageListingWrapper obj){
		this.relevancyScore=obj.relevancyScore;
	}
	
	public Integer compareTo(Object compareTo) 
    {
        PageListingWrapper pageListWrapperObj = (PageListingWrapper) compareTo;
        if(relevancyScore==null || pageListWrapperObj.relevancyScore==null){
        	return 0;
        }
        if (relevancyScore == pageListWrapperObj.relevancyScore) return 0;
        if (relevancyScore > pageListWrapperObj.relevancyScore) return -1;
        return 1;    
    }
    
    public with sharing class ArticleCategory {
	
		public String id;
		public String name;
		public String url;
	}
	
	public class CategoryWrapper {
    	public String id;
		public String url;
		public String name;
    	public Integer pageCount;
		//public List<PageListingWrapper> recentPages = new List<PageListingWrapper>();
		public List<PageListingWrapper> topPages = new List<PageListingWrapper>();
    }
    
	public class PaginationWrapper {
		public Integer nextPageToken;
		public Integer totalRecords;
    	public List<PageListingWrapper> listOfItems  = new List<PageListingWrapper>();
    	public List<PopularTopicsWrapper> popularTopics =  new List<PopularTopicsWrapper>();
	}
	
	public class IndexPaginationWrapper {
		public String nextPageToken;
		public Boolean canSort;
		public List<CategoryWrapper> listOfItems   = new List<CategoryWrapper>();
	}
	
	public class PageFilterWrapper{
    	public Boolean canCreate{get;set;}
    	public Boolean canSort{get;set;}
		public Set<PageFilterAttributeWrapper> categories{get;set;}
		
		public PageFilterWrapper(){
			canCreate = false;
			canSort = false;
			this.categories = new Set<PageFilterAttributeWrapper>();
		}
	}
	
	public class PageFilterAttributeWrapper{
		public String id{get;set;}
		public String name{get;set;}
		public Boolean hasPages{get;set;}
	}
	public class PopularTopicsWrapper{
		public Id id{get;set;}
		public String name{get;set;}
		public Integer pageCount{get;set;}
	}
}