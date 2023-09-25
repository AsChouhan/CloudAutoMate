public with sharing class MSAPISite {
	
	MSAPIClient client;
	
	public MSAPISite(MSAPIClient msc) {
		this.client = msc;
	}
	
	// Getter and Setter  Methods
	public MSAPIClient getClient() { return this.client; }
	public MSAPISite setClient(MSAPIClient msc) {
		this.client = msc;
		return this;
	}
	
	// Get Site listing
	public class SitesSearchList extends SCoreClient.AbstractClientRequest {
  		public SitesSearchList(MSAPISite site) {
			super(site.getClient(), 
				  'https://graph.microsoft.com/v1.0/sites?search=', 
				  'GET', 
				  null, 
				  new SCoreJsonDeserializer(MSAPIModelSite.MSSiteListing.class, EFSConstants.DPtoApexKeywordsMap));
		}
	}

	// Search for Sharepoint sites and document libraries
	public class Search extends SCoreClient.AbstractClientRequest {
		public Search(MSAPISite site, String webUrl, String term) {
		  super(site.getClient(), 
				'https://graph.microsoft.com/v1.0/search/query', 
				'POST', 
				getSearchRequestBody(term, webUrl), 
				new SCoreJsonDeserializer(MSAPIModelSite.SearchResult.class, EFSConstants.MSAPItoApexKeywordsMap));
	  }
  	}

	
	private static MSAPIModelSite.SearchRequestBody getSearchRequestBody(String searchTerm,  String path){
		MSAPIModelSite.SearchQueryRequest request = new MSAPIModelSite.SearchQueryRequest();
		request.query = new MSAPIModelSite.SearchQuery();
		request.query.queryString = '"'+searchTerm +'"';
		request.entityTypes = new List<String>{'site'};
		request.size = 500;
		if(String.isNotBlank(path)){
			request.entityTypes.add('drive');
			request.query.queryString = request.query.queryString +' path: \"'+path+'\"';
		} 
		List<MSAPIModelSite.SearchQueryRequest> requestList = new List<MSAPIModelSite.SearchQueryRequest>();
		requestList.add(request);
		MSAPIModelSite.SearchRequestBody reqBody = new MSAPIModelSite.SearchRequestBody();
		reqBody.requests = requestList;
		return reqBody;
	}
	
	// Get Site detail
	public class SiteDetail extends SCoreClient.AbstractClientRequest {
  		public SiteDetail(MSAPISite site, String msSiteId) {
			super(site.getClient(), 
				  'https://graph.microsoft.com/v1.0/sites/'+msSiteId, 
				  'GET', 
				  null, 
				  new SCoreJsonDeserializer(MSAPIModelSite.class, EFSConstants.DPtoApexKeywordsMap));
		}
	}
	
	////Not in use anymore
	// Get subsites list
	public class ListSubsitesAndDrives extends SCoreClient.AbstractClientRequest {
  		public ListSubsitesAndDrives(MSAPISite site, String msSiteId) {
			super(site.getClient(), 
				  'https://graph.microsoft.com/v1.0/sites/'+msSiteId+'?$expand=sites,drives', 
				  'GET', 
				  null, 
				  new SCoreJsonDeserializer(MSAPIModelSite.class, EFSConstants.DPtoApexKeywordsMap));
		}
	}
	
	// Get list
	public class ListItem extends SCoreClient.AbstractClientRequest {
  		public ListItem(MSAPISite site, String msSiteId) {
			super(site.getClient(), 
				  'https://graph.microsoft.com/v1.0/sites/'+msSiteId+'/lists', 
				  'GET', 
				  null, 
				  new SCoreJsonDeserializer(MSAPIModelSite.MSSiteListing.class, EFSConstants.DPtoApexKeywordsMap));
		}
	}
}