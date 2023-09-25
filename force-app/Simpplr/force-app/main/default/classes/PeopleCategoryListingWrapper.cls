public with sharing class PeopleCategoryListingWrapper {
		
	public String id {get;set;}
	public String name {get;set;}
	public Boolean isDeleted {get;set;}
	public Integer userCount {get;set;}
	
	public class PaginationWrapper{
		public String nextPageToken;
    	public List<PeopleCategoryListingWrapper> listOfItems = new List<PeopleCategoryListingWrapper>();
	}
	
	public class PeopleCategory{
		public String term {get;set;}
		public String size {get;set;}
		public String sortBy {get;set;}
		public Integer offset {get;set;}
		public String nextPageToken {get;set;}		
	}
    
}