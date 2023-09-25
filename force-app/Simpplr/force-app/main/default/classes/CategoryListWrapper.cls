public class CategoryListWrapper{
	public String id{get;set;}	//4
	public String url{get;set;}
	public String name{get;set;}
	public Integer pageCount{get;set;}
	public Integer publishedPageCount{get;set;}
	public String createdAt{get;set;}
	public boolean canEdit{get;set;}
	public boolean canDelete{get;set;}
	public PeopleLiteWrapper authoredBy{get;set;}
	public SiteLiteWrapper site{get;set;}
	public static CategoryListWrapper parse(String json){
		return (CategoryListWrapper) System.JSON.deserialize(json, CategoryListWrapper.class);
	}

	public CategoryListWrapper(){
		authoredBy = New PeopleLiteWrapper();
		site = New SiteLiteWrapper();
	}
}