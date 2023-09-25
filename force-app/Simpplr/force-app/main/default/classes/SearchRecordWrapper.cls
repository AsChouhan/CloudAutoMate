public with sharing class SearchRecordWrapper {
    public String id;
	public String siteId;
	public String name;
	public String title;
	public String img;
	public String imgThumbnail;
	public String siteImg;
	public String url;
	public Boolean isPrivate;
	public Boolean isListed;
	public Boolean hasContent;
	public Boolean hasNews;
	public Boolean hasEvents;
	public Boolean hasPages;
	public Boolean hasAlbums;
	public String information;
	public String about;
	public String chatterGroupId ;
	public Boolean canCreateNews;
	public Boolean canCreatePage;
	public Boolean canCreateEvent;
	public Boolean canCreateAlbum;
	public String description;
	public Integer members;
	public Boolean isMember;
	public Boolean isActivated;
	public Boolean isMandatory;
	public Boolean isFavorited;
	public Boolean isFeatured;
	public Boolean isOwner;
	public Boolean isManager;
	public Boolean isAccessRequested;
	public Boolean isBroadcast;
	public Category category ;
	
	public class Category{
		public String id;
		public String name;
		public String url;
	}
}