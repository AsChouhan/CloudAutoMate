public with sharing class KnowledgeWrapper{
    
     public class ArticleDetailWrapper{
     	public String title{get;set;}
     	public String summary{get;set;}
     	public String description{get;set;}	
     	public String createdDate{get;set;}	
     	public String lastModifiedDate{get;set;}
     	public OwnerWrapper owner{get;set;}
     	public List<VirtualTopicWrapper> listOfVirtualTopics {get;set;} 
     	public List<CustomField> listOfCustomFields {get;set;}
     	
     	public ArticleDetailWrapper() {
     		listOfVirtualTopics = new List<VirtualTopicWrapper>();
     		listOfCustomFields =  new List<CustomField>();
     	}
     }
     
     public class CustomField {
     	public String label {get;set;}
     	public String value {get;set;}
     }
     
     public class VirtualTopicWrapper {
     	public String name {get;set;}
     	public String url {get;set;}
     }
     
     public class OwnerWrapper{
     	public String id{get;set;} 
     	public String name{get;set;}
     	public String profileImage{get;set;}
     	public String url {get;set;}
    }
 
    /*******************************************************************************/
    public class CategoryWrapper implements Comparable {  
    	public String id {get;set;}
    	public String label {get;set;}
    	public String name {get;set;}
        public Integer totalArticle {get;set;} 
        public String redirectURL {get;set;}
        public List<ArticleWrapper> topArticles = new List<ArticleWrapper>();
        public Integer compareTo(Object compareTo) {
        	CategoryWrapper categoryWrapperObj = (CategoryWrapper) compareTo;
        	if (label > categoryWrapperObj.label) return 1;
            if (label < categoryWrapperObj.label) return -1;
        	return 0;
        }
    } 
    
    public class CategoryPaginationWrapper { 
    	public String nextPageToken{get;set;}
    	public List<CategoryWrapper> listOfItems{get;set;}
    	public CategoryPaginationWrapper() {
    		listOfItems = new List<CategoryWrapper>();
    	}
    	
    }
    
     public class ArticleWrapper implements Comparable { 
        public String title {get;set;}
        public String summary {get;set;}
        public String id {get;set;}
        public string subcategory {get;set;} 
        public string category {get;set;} 
        public string sortBy {get;set;}
        public string createdDate {get;set;}
        public string lastModifiedDate {get;set;}
        public String authorId {get;set;}
        public String authorName {get;set;}
        public String authorImage {get;set;}
        public String authorURL {get;set;}
        public String authorNamesFirstLetter {get;set;}
        public String redirectURL {get;set;}
        public List<VirtualTopicWrapper> listOfVirtualTopics {get;set;} 
        public Double relevancyScore {get;set;}
        
        public Integer compareTo(Object compareTo) {
        	ArticleWrapper articleWrapperObj = (ArticleWrapper) compareTo;
        	if (relevancyScore < articleWrapperObj.relevancyScore) return 1;
            if (relevancyScore > articleWrapperObj.relevancyScore) return -1;
            return 0;
        }
     }
     
      public class ArticlePaginationWrapper { 
    	public String nextPageToken{get;set;} 
    	public List<ArticleWrapper> listOfItems{get;set;}
    	
    	public ArticlePaginationWrapper () {
    		listOfItems = new List<ArticleWrapper>();
    	}
    	
    }
    
    public class DataCategoryWrapper {
		public String label{get;set;}
		public String name{get;set;}
		public Map<String, DataCategoryWrapper> mapofSubCategories{get;set;}
	}	
    
}