public with sharing class CarouselWrapper {
	public Integer order;
	public Integer originalOrder;
    public String carouselItemId;
    public String itemType;
    public Object item;	
	public Integer totalViews;
	public Integer viewedBy;
	public String addedAt;
	public String source;
	public List<AnalyticsWrapper.ViewsOverTime> viewsOverTime = new List<AnalyticsWrapper.ViewsOverTime>();
    
    public class OembedModel {
    	public String type;				
    	public String version;
    	public String title;			
	    public String author_name;		
	    public String author_url;		
	    public String provider_name;
	    public String provider_url;
	    public Integer cache_age;
	    public String thumbnail_url;
	    public String thumbnail_width;
	    public String thumbnail_height;	
	    public String description;		
	    public String url;				
	    public String html;			
	    public Integer width;			
	    public Integer height;			
    }
}