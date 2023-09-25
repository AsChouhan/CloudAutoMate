/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class PeopleWrapper implements Comparable {
	
	public String id {get;set;}
	public String peopleId {get;set;} 
	public String userId {get;set;}
	public String sfUserId {get;set;}
	public String encryptedUserId; 
	public String segmentId;
	public PeopleLiteWrapper manager;
	public String showInSimpplr;
	public String name {get;set;}
	public String firstName {get;set;}
	public String lastName {get;set;}	
	public String nickname {get;set;}
	public string url {get; set;}
	public String img {get;set;}
	public String department {get;set;}
	public String title {get;set;}
	public String location {get;set;}
	public String language;
	public UserCategory userCategory {get;set;}
	
	public String email {get;set;}
	public String phone {get;set;}
	public String mobile {get;set;}
	public String phoneExtension {get;set;}
	public String videoCallUsername {get;set;}
	public String videoCallProvider {get;set;}
	public String microsoftTeamsUserName {get;set;}
	public String microsoftTeamsUserId {get;set;}
	public String microsoftTenantId {get;set;}
	public String slackUserName {get;set;}
	public String slackUserId {get;set;}
	public String slackTenantId {get;set;}
	public String about {get;set;}
	public String birthday {get;set;}
	public String hireDate {get;set;}
	public String workAnniversary {get;set;}
	public Boolean isFollowing {get;set;}
	public Boolean isFavorited {get;set;}
	public Boolean isActive {get;set;}
	public Boolean canFollow {get;set;}
	
	public String company {get;set;}
	public String division {get;set;}
	public String city {get;set;}
	public String state {get;set;}
	public String country {get;set;}
	public String streetAddress {get;set;}
	
	public Boolean hasConnectedBoxAccount {get;set;}
	public Boolean hasConnectedGoogleDriveAccount {get;set;}
	public Boolean hasConnectedDropboxAccount {get;set;}
	public Boolean hasConnectedTwitterAccount {get;set;}
	public Boolean hasConnectedFacebookAccount {get;set;}
	public Boolean hasConnectedLinkedInAccount {get;set;}
	public Boolean hasConnectedOneDriveAccount {get;set;}
	public Boolean hasConnectedSharePointAccount {get;set;}
	public Boolean hasConnectedSlackAccount{get;set;}
	public Boolean hasConnectedGoogleCalendarAccount;
	public Boolean hasConnectedOutlookCalendarAccount;
	public Boolean hasConnectedMicrosoftTeamsAccount{get;set;}
	
	public PermissionWrapper permissions {get;set;}
	
	public String timezoneName {get;set;}
	public String timezoneIso {get;set;}
	public Integer timezoneOffset {get;set;}
	
	public String profileImageUrl {get;set;}
	public FileDetailWrapper coverImageFile{get; set;}
	public String coverImageUrl {get;set;}

	public List<UserCustomFieldsWrapper> listOfCustomFields{get; set;}
	public List<UserCustomFieldsWrapper> profileFields;
	public List<TopicWrapper> expertise;
	public String mediumPhotoUrl;
	public Boolean isBlogEnabled;
	public Boolean hasBlogs;
	public Boolean isAppManager;
	public Boolean isSystemAdmin;
	public Boolean isUnlistedAdmin;
	public Boolean canCreateTopics;
	public String extension;
	public String aboutMe;
	public Boolean canFavorite;
	public String timeZone;
	public String address;
	
	public String feedSort;
	
	// ------------ remove below properties ------------ // -- not required in Summer18 -- user.get
	public String mobilePhone {get;set;}
	public String smallPhotoUrl {get;set;}
	public Integer score {get;set;}
	public string role {get; set;} // used for site about page only (role stamp)
	public String jsonDataString {get; set;} // one usage Manage application dao
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public  Integer compareTo(Object compareTo) {
		PeopleWrapper compareToWrapper = (PeopleWrapper)compareTo;
		if(score!=null && compareToWrapper.score!=null){
			if(score > compareToWrapper.score){
	        	return -1;
	        }
	        else if(score<compareToWrapper.score){
	        	return 1;
	        }
		}
    	if(name==null || compareToWrapper.name==null){
    		return 0;
    	}
    	if (name == compareToWrapper.name) return 0;
        if (name > compareToWrapper.name) return 1;
        return -1;
	}
	
	public class UserCategory{
		public String id{get;set;}
		public String name{get;set;}
	}
	
	public class EndorsementWrapper {
		public String topicId; // TODO  - remove it
		public String expertiseId;
		public String sfUserId;
		public String endorsedById;
	}
	
	public class EndorsementsWrapper {
		public Topic topic; // This attribute should be removed (topic).. now left due just to avoid compilation error as used in many places.. shold not be required once all task are complete
		public Expertise expertise;
		public Integer count;
		public Boolean isEndorsed;

		public EndorsementsWrapper(){
			expertise = new Expertise();
			isEndorsed = false;
		}
	}

	public class Expertise {
		public String id;
		public String name;
		public String alphanumericName;
		public String url;
	}
	
	public class Topic {
		public String id;
		public String name;
		public String url;
	}
	
	
	public String currentPageUrl;
	public List<JsonKnowledgeableAboutTopics> knowledgeableAboutTopics;
	public String nextPageUrl;
	public String previousPageUrl;
	
	public class JsonKnowledgeableAboutTopics {
		public Boolean isEndorsedByMe;
		public String knowledgeableId;
		public Integer numEndorsements;
		public List<String> reasons;
		public JsonTopic topic;
	}
	public class JsonTopic {
		public String createdDate;
		public String description;
		public String id;
		public String name;
		public Integer talkingAbout;
		public String url;
	}
	
	public Boolean isEndorsed(List<string> reasonList) {
		if(reasonList != null) {
			for(String aString:reasonList) {
				if(aString.equalsIgnoreCase('Endorsed')) {
					return true;
				}
			}
		}
		return false;
	}
	public static PeopleWrapper parse(String json) {
		return (PeopleWrapper) System.JSON.deserialize(json, PeopleWrapper.class);
	}
	
	
	
	
	
	//for wrapping endorsement object from connect API start
	public List<JsonTopicEndorsement> topicEndorsements;

	public class JsonTopicEndorsementList{
		public String currentPageUrl;
		public String nextPageUrl;
		public String previousPageUrl;
		public List<JsonTopicEndorsement> topicEndorsements;
	}

	public class JsonTopicEndorsement {
		public JsonUserSummary endorsee;
		public String endorsementId;
		public JsonUserSummary endorser;
		public JsonTopic topic;
		public String url;
	}
	public class JsonUserSummary {
		public String additionalLabel;
		public String companyName;
		public String firstName;
		public String id;	
		public Boolean isActive;
		public Boolean isInThisCommunity;
		public String lastName;
		public JsonReference mySubscription;
		public String name;	
		public String recordViewUrl;
		public String title;
		public String url;
		public String userType;
	}

	public class JsonReference {
		public String id;
		public String url;
	}
	
	public class CompanyStats {
		public Integer people;
		public Integer departments;
		public Integer locations;
	}
	
	public class InstallStats {
		public Integer activeLicenseCount;
		public Integer totalLicenseCount;
	}
	
	public class PeopleTileData {
		public List<PeopleTilesOrder> listOfItems = new List<PeopleTilesOrder>();
		public List<String> disabledTiles = new List<String>();
	}
	
	public class PeopleTilesOrder{
		public String id;
		public String type;
		public String name;
		public Integer order;
		public Integer column;
	}
	
	public class DisabledPeopleTiles{
		public String type;
	}
	
	public class UserLocation{
		public String id;
		public String name;
	}
	public class Locations{
		public Set<FilterAttributeWrapper> listOfItems;
	}
	
	public class Departments{
		public List<FilterAttributeWrapper> listOfItems;
	}
	
	public class CustomField{
		public Set<FilterAttributeWrapper> listOfItems;
	}
	
	public static PeopleWrapper parseTopicEndorsementCollection(String json){
		return (PeopleWrapper) System.JSON.deserialize(json, PeopleWrapper.class);
	}

	public static JsonTopicEndorsementList parseTopicEndorsementList(String json){
		return (JsonTopicEndorsementList) System.JSON.deserialize(json, JsonTopicEndorsementList.class);
	}

	public static JsonTopicEndorsement parseTopicEndorsement(String json){
		return (JsonTopicEndorsement) System.JSON.deserialize(json, JsonTopicEndorsement.class);
	}
	// Warpping Endorsement object end
	
	public class FollowStats {
		public String peopleId;
		public Integer userFollowersCount;
		public Integer userFollowingCount;
		public Integer siteFollowingCount;
		public Integer siteManagingCount;
		public Integer siteMemberCount;
	}
	
	public class peopleStatsWrapper {
		public Integer ownerAndManagerCount;
		public Integer memberCount;
		public Integer followerCount;
		public Integer requestCount;
		public Boolean isMember;
		public Boolean isFollower;
		public Boolean isOwner;
		public Boolean isManager;
		public Boolean isContentManager;
	}

	public class UserCustomFieldsWrapper {
		public String id;
		public String label;
		public Boolean isHtml;
		public String value;
		public List<String> selectedValues;
		public Integer index;
		public Integer maxLength;
		public String columnName;

	    public String isEditable;
		public String fieldType;
		public String fieldName;
		public Boolean booleanFieldValue;
		public Boolean isRequired;
		public Integer integerFieldValue;
		public String stringFieldValue;
		public String multiPickListFieldKeys;
		public List<String> listOfMultiPickListFieldKeys;
		public transient List<String> listOfMultiPickListFieldValues;
		public transient List<Schema.PicklistEntry> picklistEntryList;
	}
	
	public class PermissionWrapper {
		public Boolean isAppManager;
	    public Boolean isSiteManager;
	    public Boolean isUnlistedAdmin;
	    public Boolean isSegmentManager;
	    public Boolean canCreateSite;
	    public Boolean canCreateBlogPost;
	    public Boolean canAccessAllPrivateSites;
	    public Boolean canManageHomeDashboard;
	    public Boolean canAccessAnalytics;
	    public Boolean canSendNewsletter;
	    public Boolean canSendNewsletterToAll;
	    public Boolean canSendAlerts;
	    public Boolean canSendAlertsToAll;
	    public Boolean canManageCampaigns;
	}
	
	
	public class AppManagerWrapper {
        public String id;
        public String name; 
        public String email; 
    }

	public class UserIdWrapper {
		public List<String> userIds;
	}
}