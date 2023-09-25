public with sharing class GlobalSearchWrapper {
    public String nextPageToken {get;set;}
	public Object totalRecords {get;set;}
	public List<ItemWrapper> listOfItems {get;set;}
	
	public GlobalSearchWrapper() {
		this.listOfItems = new List<ItemWrapper>();
		this.totalRecords = 0;
		this.nextPageToken = null;
	}
    
    public class ItemWrapper {
		public Double relevancyScore;
		public Boolean matchedOnTopic;
		public Boolean matchedOnExpertise;
		public String itemType;
		public Object item;
	}
	
}