public with sharing class SiteListingWrapper implements Comparable {
    public String id {get;set;}
	public String img {get;set;}
	public String url;
	public String aboutUrl; 
	public String title {get;set;}
	public String name;
	public String description;
	public Integer members; // deprecated in favour of memberCount (to be removed)
	public Integer memberCount;
	public Boolean isMember;
	public Boolean isFavorited;
	public Boolean isFeatured;
	public Boolean isPrivate {get;set;}
	public Boolean isPublic {get;set;}
	public Boolean isOwner;
	public Boolean isManager;
	public Boolean isAccessRequested;
	public Boolean isMandatory;
	public Boolean canEdit;
	public Boolean isListed;
	public Boolean canActivateDeactivate;
	public String informationTitle;
	public String chatterGroupId;
	public String photoColor;
	public String ownerId;
	public String currentUserSubscriptionId;
	public String editUrl;
	public CategoryWrapper category;
	public Boolean isActivated {get;set;}
	public Integer relevancyScore {get;set;}
	public Boolean canAccess {get;set;}
	public String access{get;set;}
	public Slack slack {get;set;}
	public Boolean teams {get;set;}
	public String jsonDataString {get;set;}
	public String imgThumbnail {get;set;}
	public Boolean matchedOnTopic;
	public Boolean matchedOnExpertise;
	public String itemType;
	public Boolean isInMandatorySubscription;
	// Adding temporarily for mobile issue MAR: 6437
	public String siteId;
	public Boolean isShowInSimpplrEnabled;
	public Boolean isPageEnabled;
	
	public Boolean isFileEnabled;
	public Boolean isFeedEnabled;
	public Boolean isEventEnabled;
	public Boolean isDeleted;
	public Boolean isBroadcast;
	public Boolean isAlbumEnabled;
	public Boolean isAboutEnabled;
	public Boolean isQuestionAnswerEnabled;
	public String categoryName;
	public String categoryId;
	public FileListingWrapper imgFile;
	
	public class Slack{
		public String url;
		public String name;
		
	}
	public SiteListingWrapper (){
		category= new CategoryWrapper();
	}
	public SiteListingWrapper (String id, String name){
		this.id = id;
		this.title = name;
		category= new CategoryWrapper();
	}
	public class PaginationWrapper {
        public String nextPageToken;
        public Integer totalRecords;
        Public List<SiteListingWrapper> listOfItems = new List<SiteListingWrapper>();
    }
    public class CategoryWrapper {
		public String id {get;set;}
		public String name {get;set;}
		public String url {get;set;}
	}
	public List<SiteListingWrapper> convertToWrapper (List<Simpplr_Site__c> listOfSimpplrSites) {
		List<SiteListingWrapper> listToBeReturned= new List<SiteListingWrapper>();
		
		List<Id> listOfCollGroupId = new List<Id> ();
		
		if (!listOfSimpplrSites.isEmpty()) {
			
			for (Simpplr_Site__c simpplrSiteObj : listOfSimpplrSites) {
				listOfCollGroupId.add(simpplrSiteObj.Chatter_Group_Id__c);
			}
			
		}
		Map<Id, CollaborationGroup> mapOfIdWithCollaborationGrpForLoggedInUser;
		SiteDao siteDaoObj = new SiteDao();
    	mapOfIdWithCollaborationGrpForLoggedInUser = siteDaoObj.getMapOfIdWithCollaborationGroup(listOfCollGroupId,
    				UserContext.id);
    	for (Simpplr_Site__c siteObj :listOfSimpplrSites) {
    		if(mapOfIdWithCollaborationGrpForLoggedInUser.containsKey(siteObj.Chatter_Group_Id__c)) {
				SiteListingWrapper siteWrapObj = new SiteListingWrapper();
				siteWrapObj = ObjectToWrapperAdapter.generateSiteWrapFromSiteAndCollGrp(siteObj,
						mapOfIdWithCollaborationGrpForLoggedInUser.get(siteObj.Chatter_Group_Id__c));
				listToBeReturned.add(siteWrapObj);
    		}
		}
		return listToBeReturned;
	}
	public Integer compareTo(Object compareTo) 
    {
        SiteListingWrapper siteListWrapperObj = (SiteListingWrapper) compareTo;
        if(relevancyScore==null || siteListWrapperObj.relevancyScore==null){
        	return 0;
        }
        if (relevancyScore < siteListWrapperObj.relevancyScore) return 1;
        if (relevancyScore > siteListWrapperObj.relevancyScore) return -1;
        
        if(memberCount==null || siteListWrapperObj.memberCount==null){
        	return 0;
        }
        if (memberCount < siteListWrapperObj.memberCount) return 1;
        if (memberCount > siteListWrapperObj.memberCount) return -1;
        
        if(title==null || siteListWrapperObj.title==null){
        	return 0;
        }
        if (title < siteListWrapperObj.title) return 1;
        if (title > siteListWrapperObj.title) return -1;
        
        return 0;      
    }
}