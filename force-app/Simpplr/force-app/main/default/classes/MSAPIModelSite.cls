public with sharing class MSAPIModelSite extends MSAPIModelAbstract{
	public DateTime createdDateTime;
	public String description; 
	public String id;
	public String lastModifiedDateTime;
	public String name;
	public String webUrl;
	public String displayName;
	public List<ChildItem> drives;
	public List<ChildItem> sites;
	public SiteItemList listItem;
	
	public class SiteItemList {
		public String template;
		public boolean hidden;
	}
	
	public class MSSiteListing {
		public List<MSAPIModelSite> value;
	}
	
	public class UIResponse implements Comparable{
		public String id;
		public String name;
		public String type;
		public String webUrl;
		public Criteria.OwnerWrapper owner;

		/**
		 * @description interface method used to sort the object
		 * @param object to compare with name
		 * @return Integer value based on the compare result
		 */
		public Integer compareTo(Object objToCompare) {
			UIResponse response = (UIResponse)objToCompare;

			if (this.name == response.name){
				return 0;
			}
			else if (this.name > response.name){
				return 1;
			}
			return -1;
		}
	}
	
	public class ChildItem{
		public String id;
		public String name;
		public String webUrl;
		public MSAPIModelUser.IdentitySet createdBy;
		public MSAPIModelUser.IdentitySet owner;
	}

	public class SearchRequestBody extends SCoreAbstractJsonSerializable {
		public List<SearchQueryRequest> requests;
	}
	
	public class SearchQueryRequest {
		public List<String> entityTypes;
		public SearchQuery query;
		public Integer offset;
		public Integer size;
	}
	public class SearchQuery {
		public String queryString;
	}
	public class SearchResult {
		public List<SearchResultItem> value;
	}

	public class SearchResultItem{
		public List<HitsContainers> hitsContainers;
	}
	public class Resource {
		public String id;
		public String name;
		public String displayName;
		public string type;
		public String description;
		public String webUrl;
		public String lastModifiedDateTime;
		public String createdDateTime;
	}
	public class Hits {
		public String hitId;
		public Integer rank;
		public String summary;
		public Resource resource;
		
	}
	public class HitsContainers {
		public Integer total;
		public Boolean moreResultsAvailable;
		public List<Hits> hits;
	}
}