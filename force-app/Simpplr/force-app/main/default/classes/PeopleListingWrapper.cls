/**
* @Class PeopleListingWrapper
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class PeopleListingWrapper implements Comparable {
	public String id;
	public String peopleId;
	public String managerId;
	public String name;
	public string designation;
	public string city;
	public string img;
	public String state;
	public String country;
	public String location;
	public string url;
	public String title;
	public String department;
	public String smallPhotoUrl;
	public String currentUserSubscriptionId;
	public String photoColor;
	public Boolean isActive;
	public Integer score;
	public String email;
	public String phone;
	public String mobile;
	public String phoneExtension;
	public Boolean isFollowing;
	public Boolean canFollow;
	public Boolean canMakeManager;
	public Boolean canMakeNotManager;
	public Boolean canMakeOwner;
	public Boolean canRemove;
	public String userId;
	public String sfUserId;
	public Boolean isOwner;
	public Boolean isManager;
	public Boolean hasRead;
	public Boolean endorsedForTopic;
	public Integer endorsementsForTopicCount;
	public Integer relevancyScore{get;set;}
	public String orgChartUrl {get;set;}
	public Boolean isFavorited {get;set;}
	public Boolean canFavorite {get;set;}
	public String birthday {get;set;}
	public String workAnniversary {get;set;}
	public String hireDate { get; set; }	
	public Boolean matchedOnTopic;
	public Boolean matchedOnExpertise;
	public String itemType;
	public String slackUserId;
	public String slackUserName;
	public String slackTenantId;
	
	public class PaginationWrapper{
		public String nextPageToken;
		public Integer totalRecords;
		public String csvUrl;
    	public List<PeopleListingWrapper> listOfItems = new List<PeopleListingWrapper>();
	}
	
	public class PeopleTileWrapper{
		public String nextPageToken;
		public Integer total;
    	public List<PeopleListingWrapper> listOfItems = new List<PeopleListingWrapper>();
	}
	
	public class AddPeopleTileWrapper{
		public String id;
	}
	
	public Integer compareTo (Object compareTo) {
        PeopleListingWrapper peopleListWrapperObj = (PeopleListingWrapper) compareTo;
        
        if (relevancyScore==null || peopleListWrapperObj.relevancyScore==null) {
        	return 0;
        }
        
        if (relevancyScore < peopleListWrapperObj.relevancyScore) return 1;
        
        if (relevancyScore > peopleListWrapperObj.relevancyScore) return -1;
        
        if (name == null || peopleListWrapperObj.name == null) {
        	return 0;
        }
        
        if (name > peopleListWrapperObj.name) return 1;
        
        if (name < peopleListWrapperObj.name) return -1;
        
        return 0;      
    }
}