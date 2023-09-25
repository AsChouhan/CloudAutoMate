public with sharing class PeopleListWrapper implements Comparable{

	
	public String id;// for backward compatibilty , to be removed later on
	public String peopleId;
	public String userId;// for backward compatibilty , to be removed later on
	public String sfUserId;
	public String nickname;
	public string url;
	public String name {get;set;}
	public String segmentName {get;set;}
	public String segmentId {get;set;}
	public string img;
	public String department{get;set;}
	public String departmentId;
	public String title;
	public String location;
	public String locationId;
	public String email{get;set;}
	public String phone;
	public String mobile;
	public String phoneExtension;
	public String about;
	public String birthday ;
	public String workAnniversary ;
	public String hireDate;
	public Boolean isFollowing;
	public Boolean isActive;
	public Boolean isFavorited ;
	public Boolean canFollow;
	public String city{get;set;}
	public String state{get;set;}
	public String country{get;set;}
	public String division{get;set;}
	public String companyName{get;set;}
	//Below attributes are not initilised by the converters below but are initialised in respective modules locaaly as required
	public Boolean endorsedForTopic;
	public Integer endorsementsForTopicCount;
	public Integer relevancyScore;
	public String orgChartUrl;
	public Boolean canMakeManager;
	public Boolean canMakeContentManager;
	public Boolean canMakeNotManager;
	public Boolean canMakeNotContentManager;
	public Boolean canMakeOwner;
	public Boolean canSPTransferOwnership;
	public Boolean canRemove;
	public Boolean isOwner;
	public Boolean isManager;
	public Boolean isContentManager;
	public Boolean hasRead;
	public Boolean hasConnectedGoogleDriveAccount;
	public Boolean hasConnectedDropboxAccount;
	public Boolean hasConnectedSharePointAccount;
	public Boolean hasConnectedOneDriveAccount;
	public Boolean hasConnectedMicrosoftTeamsAccount;
	public Boolean hasConnectedSlackAccount;
	public Boolean hasConnectedBoxAccount;
	public String firstName;
	public String lastName;
	public String street;
	public String mediumPhotoUrl;
	
	public String videoCallUsername;
	public String videoCallProvider;
	public String microsoftTeamsUserName;
	public String microsoftTeamsUserId;
	public String microsoftTenantId;
	public String slackUserName;
	public String slackUserId;
	public String slackTenantId;
	    
	public Boolean isProtectedAuthor;
	
	public Boolean isFollower;
	public Boolean isMember;
	public Boolean isAppManager;

	public Request request;
	public PeopleListWrapper user;

	public String language;

	//TimeZone related info
	public String timezoneName;
	public String timezoneIso;
	public Integer timezoneOffset;
	
	public class PaginationWrapper{
		public String nextPageToken;
		public Integer totalRecords;
		public String csvUrl;
		public Boolean isCsvDownloadable;
    	public List<PeopleListWrapper> listOfItems = new List<PeopleListWrapper>();
		public Integer readCount;
		public Decimal readPercent;
		public Integer totalCount;
		public Decimal readBenchmarkPercent;
		public Decimal averageReadPercent;
	}
	
	public class PeopleTileWrapper{
		public String nextPageToken;
		public Integer total;
    	public List<PeopleListWrapper> listOfItems = new List<PeopleListWrapper>();
	}
	
	public class AddPeopleTileWrapper{
		public String id;
	}

	public class Request {
		public String id;
	    public String requestedBy;
	    public String requestedByPeopleId;
	    public String requestedOn;
	    public String status;
	    public String actionOn;
	    public String actionBy;
	    public String actionByPeopleId;
	}
	
	public static  List<String> getPeopleFieldList(String loggedInPeopleId) {
    	return New List<String>{
    		'Id',
			'User__c',
			'First_Name__c',
			'Last_Name__c',
			'user__r.SmallPhotoURL',
			'user__r.FullPhotoURL',
			'Department__c',
			'Title__c',
			'City__c',
			'Division__c',
            'Company_Name__c',
            'Segment__c',
			'Segment__r.Name__c',
			'About__c',
			'Community_Nickname__c',
			'Country__c',
			'State__c',
			'Email__c',
			'Phone__c',
			'mobile_phone__c',
			'extension__c',
			'Birth_Date__c',
			'Joining_Date__c',
			'User__r.isactive',
			'Zoom_Id__c',
			'Skype_Id__c',
            'Microsoft_Teams_User_Id__c',
			'Microsoft_Teams_User_Name__c',
			'Microsoft_Tenant_Id__c',
			'Slack_User_Id__c',
			'Slack_User_Name__c',
			'Slack_Tenant_Id__c',
			'Is_Protected_Author__c',
			'User__r.LanguageLocaleKey',
			'User__r.TimeZoneSidKey',
			'(Select Id from Bookmark_Receiver_People__r where People__c=:loggedInPeopleId And Type__c=\'People\' And Is_Deleted__c=false )',
			'(Select connected__c, name from People_Integrations__r)'       
		};
    }
	
	public static List<PeopleListWrapper> peopleListToWrapper(List<People__c> peopleList){
		List<PeopleListWrapper> peopleWrapperList = new List<PeopleListWrapper>();
		for(People__c peopleObj: peopleList){
			peopleWrapperList.add(peopleToWrapper(peopleObj));
		}
		return peopleWrapperList;
	}
	
	public static PeopleListWrapper peopleToWrapper(People__c peopleObjArg) {
		PeopleListWrapper  peopleWrapObj = new PeopleListWrapper ();

		peopleWrapObj.id = peopleObjArg.id;
		peopleWrapObj.peopleId = peopleObjArg.id;
		peopleWrapObj.sfUserId = peopleObjArg.User__c;
		peopleWrapObj.nickname = peopleObjArg.Community_Nickname__c;
		peopleWrapObj.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleObjArg.id;
		String name = Utility.buildName(peopleObjArg.First_Name__c,peopleObjArg.Last_Name__c);
		if(String.isNotBlank(name)){
			peopleWrapObj.name = name;
		}

		peopleWrapObj.hasConnectedGoogleDriveAccount = false;
		peopleWrapObj.hasConnectedDropboxAccount = false;
		peopleWrapObj.hasConnectedSharePointAccount = false;
		peopleWrapObj.hasConnectedOneDriveAccount = false;
		peopleWrapObj.hasConnectedMicrosoftTeamsAccount = false;
		peopleWrapObj.hasConnectedBoxAccount = false;

		if(peopleObjArg.Preferences_People__r != null && !peopleObjArg.Preferences_People__r.isEmpty()){
			People_Preference__c ppf = peopleObjArg.Preferences_People__r.get(0);
			if(SimpplrContext.IsBoxIntegrationEnabled) {
				peopleWrapObj.hasConnectedBoxAccount = String.isNotBlank(ppf.Box_Access_Token__c);
			}
		}
		
		if(peopleObjArg.People_Integrations__r != null && !peopleObjArg.People_Integrations__r.isEmpty()) {
			for(People_Integration__c pplInteg: peopleObjArg.People_Integrations__r) {
				if(pplInteg.name.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING)) {
					peopleWrapObj.hasConnectedGoogleDriveAccount = pplInteg.connected__c;		
				} else if(pplInteg.name.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING)) {
					peopleWrapObj.hasConnectedDropboxAccount = pplInteg.connected__c;		
				} else if(pplInteg.name.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING)) {
					peopleWrapObj.hasConnectedSharePointAccount = pplInteg.connected__c;		
				} else if(pplInteg.name.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING)) {
					peopleWrapObj.hasConnectedOneDriveAccount = pplInteg.connected__c;		
				} else if(pplInteg.name.equalsIgnoreCase(IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS)) {
					peopleWrapObj.hasConnectedMicrosoftTeamsAccount = pplInteg.connected__c;		
				} else if (pplInteg.name.equalsIgnoreCase(IntegrationConstants.INTEGRATION_TYPE_SLACK)) {
					peopleWrapObj.hasConnectedSlackAccount = pplInteg.connected__c;
				} 
			}
		}

		if (SimpplrContext.isPPVideoDisplay) {
			peopleWrapObj.videoCallProvider = SimpplrContext.PPVideoProvider;
		
			if(ServiceConstants.VIDEO_PROVIDER_ZOOM.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
				peopleWrapObj.videoCallUsername = peopleObjArg.Zoom_Id__c;
			} else if(ServiceConstants.VIDEO_PROVIDER_SKYPE.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
				peopleWrapObj.videoCallUsername = peopleObjArg.Skype_Id__c;
			}
		}
        
		peopleWrapObj.microsoftTeamsUserId = peopleObjArg.Microsoft_Teams_User_Id__c;
		peopleWrapObj.microsoftTeamsUserName = peopleObjArg.Microsoft_Teams_User_Name__c;
		peopleWrapObj.microsoftTenantId = peopleObjArg.Microsoft_Tenant_Id__c;
		peopleWrapObj.slackUserName = peopleObjArg.Slack_User_Name__c;
		peopleWrapObj.slackUserId = peopleObjArg.Slack_User_Id__c;
		peopleWrapObj.slackTenantId = peopleObjArg.Slack_Tenant_Id__c;
		peopleWrapObj.img = Utility.getProfilePhotoURL(peopleObjArg.user__r.FullPhotoUrl); 
		peopleWrapObj.department = SimpplrContext.isPPDepartmentDisplay ? peopleObjArg.Department__c : null;
		peopleWrapObj.departmentId = String.isNotBlank(peopleObjArg.Department__c) ? peopleObjArg.Department__c.toLowerCase() : null;
		peopleWrapObj.title = SimpplrContext.isPPTitleDisplay ? peopleObjArg.Title__c : null;
		peopleWrapObj.location = Utility.buildLocation(peopleObjArg.City__c, peopleObjArg.State__c, peopleObjArg.Country__c);
		peopleWrapObj.locationId = peopleObjArg.City__c + ' @@ ' + peopleObjArg.State__c + ' @@ ' + peopleObjArg.Country__c;
		peopleWrapObj.email = peopleObjArg.Email__c;
		peopleWrapObj.phone = simpplrcontext.isPPPhoneDisplay ? peopleObjArg.Phone__c : null;
		peopleWrapObj.mobile = SimpplrContext.isPPMobilePhoneDisplay ? peopleObjArg.mobile_phone__c : null;
		peopleWrapObj.phoneExtension = SimpplrContext.isPPExtensionDisplay ? peopleObjArg.extension__c : null;
		peopleWrapObj.about = SimpplrContext.isPPAboutMeDisplay ? peopleObjArg.About__c : null;
		peopleWrapObj.birthday = SimpplrContext.isPPBirthDateDisplay ? Utility.dateToDisplayString(peopleObjArg.Birth_Date__c,'MM-dd') : null;
		if(SimpplrContext.isPPJoiningDateDisplay) {
			peopleWrapObj.hireDate = Utility.dateToDisplayString(peopleObjArg.Joining_Date__c,'yyyy-MM-dd');
		}
		peopleWrapObj.companyName = SimpplrContext.isPPCompanyNameDisplay ? peopleObjArg.Company_Name__c : null;
		peopleWrapObj.segmentName = SimpplrContext.isSegmentsEnabled ? peopleObjArg.Segment__r.Name__c : null;
		peopleWrapObj.segmentId = SimpplrContext.isSegmentsEnabled ? peopleObjArg.Segment__c : null;
		peopleWrapObj.division = SimpplrContext.isPPDivisionDisplay ? peopleObjArg.Division__c : null;
		peopleWrapObj.city = SimpplrContext.isPPCityDisplay ? peopleObjArg.City__c : null;
		peopleWrapObj.state = SimpplrContext.isPPStateDisplay ? peopleObjArg.State__c : null;
		peopleWrapObj.country = SimpplrContext.isPPCountryDisplay ? peopleObjArg.Country__c : null;
		
		if (UserContext.usersIFollowIdSet.contains(peopleObjArg.User__c)) {
    		peopleWrapObj.isFollowing = true;
    		
    	} else {
    		peopleWrapObj.isFollowing = false;
    	}
    	
		peopleWrapObj.isActive = peopleObjArg.User__r.isactive;

    	if (!peopleObjArg.Bookmark_Receiver_People__r.isEmpty()) {
    		peopleWrapObj.isFavorited = true;
    		
    	} else {
    		peopleWrapObj.isFavorited = false;
    	}
    	
		
		if (UserContext.getCurrentUserInfo.Id == peopleObjArg.Id) {
			peopleWrapObj.canFollow = false;
			
		} else {
			peopleWrapObj.canFollow = peopleObjArg.User__r.isactive;
			
		} 
		peopleWrapObj.isProtectedAuthor = peopleObjArg.Is_Protected_Author__c;        
		peopleWrapObj.language = Utility.getSimpplrLanguageLocaleKey(peopleObjArg.User__r.languagelocalekey).replace('_', '-');

		TimeZone tz = Timezone.getTimeZone(peopleObjArg.User__r.TimeZoneSidKey);
		peopleWrapObj.timezoneName = Utility.timezoneIdToDisplayLabel(peopleObjArg.User__r.TimeZoneSidKey);
		peopleWrapObj.timezoneIso = tz.getID();
		peopleWrapObj.timezoneOffset = tz.getOffset(system.today());

		return peopleWrapObj;
	}
	
	public Integer compareTo (Object compareTo) {
        PeopleListWrapper peopleListWrapperObj = (PeopleListWrapper) compareTo;
        
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