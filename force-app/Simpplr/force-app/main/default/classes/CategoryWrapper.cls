public class CategoryWrapper{
	public String id{get;set;}
	public String categoryId{get;set;}
	public String url{get;set;}
	public String name{get;set;}
	public Integer pageCount{get;set;}
	public Integer publishedPageCount{get;set;}
	public String createdAt{get;set;}
	public boolean canEdit{get;set;}
	public boolean canDelete{get;set;}
	public PeopleLiteWrapper authoredBy{get;set;}
	public SiteLiteWrapper site{get;set;}
	public static CategoryWrapper parse(String json){
		return (CategoryWrapper) System.JSON.deserialize(json, CategoryWrapper.class);
	}

	public CategoryWrapper(){
		authoredBy = New PeopleLiteWrapper();
		site = New SiteLiteWrapper();
	}
}