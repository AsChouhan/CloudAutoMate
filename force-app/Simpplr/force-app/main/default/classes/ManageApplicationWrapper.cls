public with sharing class ManageApplicationWrapper {
    
    /** Modified By AJAY */
    public class GeneralSetupWrapper{
    	
    	public String applicationName;
		public String applicationPageTitle;
		
		public String loginTimeoutSeconds;
		public String postLogoutUrl;
		
		public List<CheckboxItem> feature;
		public List<CheckboxItem> languages;
		public List<String> feedbackRecipients;
		public boolean shareFeedback;
		public String automatedTranslationEnabled;
		// feature variables
		public Boolean newsFeatureEnabled;
		public Boolean pagesFeatureEnabled;
		public Boolean eventsFeatureEnabled;
		public Boolean fileFeatureEnabled;
		public Boolean albumsFeatureEnabled;
		public Boolean blogsFeatureEnabled;
		public String mobileAppAdditionalSecurityEnabled;
		public String mobilePromotionEnabled;
		public String brandedAppDistributionEnabled;
		public Boolean nativeAppEnabled;
		public Boolean brandedAppEnabled;
		public String blogPostSetup;
		
		// Add to calendar fields
		public boolean calendarAppEnabled;
		public boolean calendarOffice365Enabled;
		public boolean calendarGoogleEnabled;
		public boolean calendarOutlookEnabled;

		public String calendarOffice365URL;
		
		public boolean enablePushNotificationDesktop;
		public boolean enablePushNotificationMobile;
		
		public boolean termsOfService;
		public String termsOfServiceTextLabel;
		public String termsOfServiceTextLink;
		public boolean privacyPolicy;
		public String privacyPolicyTextLabel;
		public String privacyPolicyTextLink;
		public boolean copyrightText;
		public String copyrightTextCopy;
		public String socialCampaignEnabled;
		public String socialCampaignPolicyURL;
		public boolean enableSMSNotifications;

		public String questionAnswerEnabled;
		
		public GeneralSetupWrapper(){
			feature = new List<CheckboxItem>();
			feedbackRecipients = new List<String>();
			newsFeatureEnabled = false ;
			pagesFeatureEnabled = false ;
			eventsFeatureEnabled = false ;
			fileFeatureEnabled = false ;
			albumsFeatureEnabled = false ;
			blogsFeatureEnabled = false ;
		}
    }
    
    /** Modified By AJAY */
    public class CheckboxItem implements Comparable{
    	public String label{get;set;}
    	public String name{get;set;}
    	public Boolean onOff{get;set;}
    	public String isHtml{get;set;}
    	public String isEditable{get;set;}
    	public String itemOrder{get;set;}
		public String source{get;set;}
    	
    	public CheckboxItem(){
    		this.onOff = false; 
    	}
    	public CheckboxItem(String name){
    		this.name = name;
    	}
    	public CheckboxItem(String name, Boolean onOff){
    		this(name);
    		this.onOff = onOff;
    	}
    	public CheckboxItem(String name, Boolean onOff, String itemOrder){
    		this(name, onOff);
    		this.itemOrder = itemOrder;
    	}
    	public CheckboxItem(String label,String name, Boolean onOff, String itemOrder){
    		this(name, onOff,itemOrder);
    		this.label = label;
    	}
    	
    	public CheckboxItem(String label,String name, Boolean onOff, String isHtml, String itemOrder){
    		this(label, name, onOff,itemOrder);
    		this.isHtml = isHtml;
    	}
    	
    	public CheckboxItem(String label,String name, Boolean onOff, String isHtml, String isEditable, String itemOrder){
    		this(label, name, onOff, isHtml, itemOrder);
    		this.isEditable = isEditable;
    	}
    	
    	public Integer compareTo(Object compareTo) {
	        CheckboxItem obj = (CheckboxItem) compareTo;
	        Integer odr = Integer.valueOf(itemOrder);
	        if(odr==null || obj.itemOrder==null){
	        	return 0;
	        }
	        if (odr == Integer.valueOf(obj.itemOrder)) return 0;
	        if (odr < Integer.valueOf(obj.itemOrder)) return -1;
	        return 1;
	    }
    }
    
    /** Modified By AJAY */
    public class CheckboxLink implements Comparable{
    	public String id{get;set;}
    	public String name{get;set;}
    	public Boolean onOff{get;set;}
    	public String url{get;set;}
    	public String itemOrder{get;set;}
    	
    	public CheckboxLink(){
    		this.onOff = false; 
    	}
    	public CheckboxLink(String name){
    		this.name = name;
    	}
    	public CheckboxLink(String name, Boolean onOff){
    		this(name);
    		this.onOff = onOff;
    	}
    	public CheckboxLink(String name, Boolean onOff, String url){
    		this(name);
    		this.onOff = onOff;
    		this.url = url;
    	}
    	
    	public CheckboxLink(String name, Boolean onOff, String url, String itemOrder){
    		this(name, onOff, url);
    		this.itemOrder = itemOrder;
    	}
    	
    	public Integer compareTo(Object compareTo) {
	        CheckboxLink obj = (CheckboxLink) compareTo;
	        Integer odr = Integer.valueOf(itemOrder);
	        if(odr==null || obj.itemOrder==null){
	        	return 0;
	        }
	        if (odr == Integer.valueOf(obj.itemOrder)) return 0;
	        if (odr < Integer.valueOf(obj.itemOrder)) return -1;
	        return 1;
	    }
    }
    
    public class GovernanceSetupWrapper {
	    public String feedEnabled;
		public String feedMode;
	    public Boolean showTrackChangesFeedPosts;
	    public String autoConvertChatterGroupToSite;
		public String feedVisibility;
		public String siteFeedVisibility;
		public String homeDashboardSetup;
		public String siteDashboardSetup;
		public String htmlTileEnabled;
		public Boolean multipleLanguagesEnabled;
		public String feedPlaceholderToggle;
		public String customFeedPlaceholderText;
		public Boolean contentSubmissions;
		public Boolean contentComments;
		public Boolean homeCarouselEnabled;
		public Boolean siteCarouselEnabled;
		public String filePermission;
		public String expertiseControlledByManager;
		public String expertiseCreateControlledByManager;
		public Boolean allowFileShareWithPublicLink;

		public String autoGovernanceEnabled;
		public String autoGovValidationPeriod;
		public String siteFilePermission;
		public List<SiteLiteWrapper> sitesToUploadFiles;
    }

    public class AnalyticsEmbedsIntegrationsWrapper{
        public Boolean googleAnalytics;
		public String analyticsTrackingId;	
		public String analyticsTrackingId4;
		public Boolean analyticsEnhancedLinkAttribution;
		public Boolean analyticsDemographicsInterestsReports; 
        public Boolean vbrick;
        public String vbrickBaseURL; 
		public Boolean enableGoogleAnalytics4;
		//public Boolean enableGoogleAnalytics3;
		public Boolean enableGoogleAnalytics;
	}
	
	public class CalendarIntegrationsWrapper{
		public Boolean googleCalendar;
		public String googleCalendarConnectedAs; 
		public Boolean isGoogleCalendarAccountReconnectRequired;
		public Boolean googleCalendarDomainExists;
		public String googleMultiDomainUpgradeStatus;
		public Boolean outlookCalendar;
		public List<String> outlookCalendarDomainWhitelist;
	}

	public class CampaignsIntegrationsWrapper{
		public Boolean employeeAdvocacy;
		public Boolean facebookEnabled;
		public Boolean linkedInEnabled;    
		public Boolean twitterEnabled;
	}

	public class PeopleIntegrationsWrapper{
		public Boolean adIntegrationEnabled;
		public Boolean activeDirectoryIntegrationEnabled;
		public String adClientId;
		public String adClientSecret;
		public String adConnectedAs;
		public String activeDirectoryConnectedAs;
		public Boolean isActiveDirectoryGroupsEnabled;
		public Boolean autoCreateActiveDirectoryAudience;
		public Integer selectedActiveDirectoryGroupCount;
		public String adRedirectURL;
		public Boolean workday;
		public String workdayUsername;
		public String workdayPassword;
		public String workdayPasswordConfirm;
		public String workdayEndpointUrl;
		public Boolean googleIntegrationEnabled;
		public String googleConnectedAs;
		public String googleRedirectURL;
		public Boolean workdayPasswordSaved;
		public Boolean ukgPro;
		public Boolean ukgProPasswordSaved;
		public String ukgProUsername;
		public String ukgProPassword;
		public String ukgProBaseUrl;
		public String ukgProApiKey;
		public Boolean ukgProApiKeySaved;
		public Boolean isGooglePeopleDataAccountReconnectRequired;
		public List<ActiveDirectoryModel.ADGroup> listOfActiveDirectoryGroupsSelected;
		public List<ActiveDirectoryModel.ADGroup> listOfActiveDirectoryGroupsRemoved;
		public ActiveDirectorySyncInfoWrapper activeDirectorySyncInfo;
	}

	public class ActiveDirectorySyncInfoWrapper {
		public String lastRunAt;
		public String nextRunAt;
		public Boolean isInProgress;
		public Boolean isSuccessful;
	}
 
    public class SearchIntegrationsWrapper {
 		public Boolean isExternalSearchConnected;
		public String externalSearchProvider;
		public String externalSearchClientSecret;
		public Boolean hasModifyAllDataPermission;
		public Boolean hasSmartSearchPermission;
		public String smartSearchStatus;
		public Boolean isExternalSearchEnabled;
		public Boolean isExternalSearchIndexing;
		public Boolean isEnterpriseSearchEnabled;
		public String enterpriseSearchProvider;
		public String enterpriseSearchUrl;

    }

	public class EnterpriseSearchIntegration {
	   public Boolean isEnabled;
	   public String provider;
	   public String url;

   }

	public class SingleSignOnIntegrationsWrapper{
		public Boolean okta;
        public Boolean onelogin;
        public String oktaLink;
        public String oktaApiToken;
        public String oktaUserNameFormat;
        public String oneLoginApiKey;
        public String oneLoginEmbeddingCode;
		public String oneLoginEmbeddingUrl;
		public Boolean google;
		public Boolean oktaApiTokenSaved;
		public Boolean oneLoginApiKeySaved;
	}

    public class PrivilegesSetupWrapper {
		public List<PeopleWrapper> protectedAuthorAllowlisted;
		public List<PeopleWrapper> protectedAuthor;
    	public List<PeopleWrapper> influencers;
    	public List<PeopleWrapper> newsletterControlPeople;
    	public List<PeopleWrapper> analyticsAccess;
    	public List<PeopleWrapper> canAccessAlertsPeople;
    	public List<SiteLiteWrapper> newsletterControlSite;
    	public List<SiteLiteWrapper> mustReadsControlSite;
    	public List<SiteLiteWrapper> alertsControlSite;
    	public List<PeopleWrapper> canControlHomeDashboard;
    	public List<PeopleWrapper> canManageSocialCampaign;
    	public Set<PeopleWrapper> unlistedSitesManagingPeopleIdSet;
    	public Set<PeopleWrapper> appManagingPeopleIdSet;
    	public Set<PeopleWrapper> campaignManagingPeopleIdSet;
    	public Set<PeopleWrapper> addSitesUserSet;
    	public Boolean canControlDashboard;
    	public Boolean isEmployeeAdvocacyEnabled;
    	public Boolean isHomeManagementEnabled;
    	public String addSitesPermission;
        public List<SiteLiteWrapper> onboardingSiteList;
		public List<PeopleWrapper> onboardingPeopleList;
		public String onboardingSitePermission;
		public String leadercastPermission;
		public List<PeopleWrapper> leadercastControlPeople;
    	public List<SiteLiteWrapper> leadercastControlSites;
		public List<PeopleWrapper> initiativesAndCampaignsManagers;
        /*** @description flag to send ai content moderation priviledge enabled or not */
        public Boolean isAIContentModerationEnabled;
        /*** @description store people ai content moderation priviledge */
        public List<PeopleWrapper> contentModeratorPeopleList;
		/*** @description flag to store onboarding enabled or not */
		public Boolean isOnboardingEnabled;
		public Boolean isMyTeamsAnalyticsSettingEnabled;

    	
    	public PrivilegesSetupWrapper(){
			protectedAuthorAllowlisted = new List<PeopleWrapper>();
			protectedAuthor = new List<PeopleWrapper>();
    		influencers = new List<PeopleWrapper>();
    		newsletterControlPeople = new List<PeopleWrapper>();
    		analyticsAccess = new List<PeopleWrapper>();
    		canAccessAlertsPeople = new List<PeopleWrapper>();
    		newsletterControlSite = new List<SiteLiteWrapper>();
    		mustReadsControlSite = new List<SiteLiteWrapper>();
    		alertsControlSite = new List<SiteLiteWrapper>();
    		canControlHomeDashboard = new List<PeopleWrapper>();
    		canManageSocialCampaign = new List<PeopleWrapper>();
    		unlistedSitesManagingPeopleIdSet = new Set<PeopleWrapper>();
    		appManagingPeopleIdSet = new Set<PeopleWrapper>();
    		campaignManagingPeopleIdSet = new Set<PeopleWrapper>();
    		addSitesUserSet = new Set<PeopleWrapper>();

    		
    		canControlDashboard = false;
    		isEmployeeAdvocacyEnabled = false;
    		isHomeManagementEnabled = false;
			onboardingSiteList = new List<SiteLiteWrapper>();
    		onboardingPeopleList = new List<PeopleWrapper>();
			initiativesAndCampaignsManagers = new List<PeopleWrapper>();
			isAIContentModerationEnabled = false;
			contentModeratorPeopleList = new List<PeopleWrapper>();
			isMyTeamsAnalyticsSettingEnabled = true;
    	}
    }


    
    public class PrivilegesSetsWrapper {
		public Set<String> protectedAuthorAllowlisted {get;set;}
		public Set<String> protectedAuthor {get;set;}
    	public Set<String> leadership {get;set;}
    	public Set<String> influencers {get;set;}
    	public Set<String> newsletterControlPeople {get;set;}
    	public Set<String> analyticsAccess {get;set;}
    	public Set<String> newsletterControlSite {get;set;}
		public Set<String> mustReadsControlSite {get;set;}
    	public Set<String> canAccessAlertsPeople {get;set;}
    	public Set<String> alertsControlSite {get;set;}
    	public Set<String> canControlHomeDashboard {get;set;}
    	public Set<String> canManageSocialCampaign {get;set;}
    	public Set<String> unlistedSitesManagingPeopleIdSet {get;set;}
    	public Set<String> appManagingPeopleIdSet {get;set;}
    	public Set<String> campaignManagingPeopleIdSet {get;set;}
    	public Set<String> addSitesUserSet {get;set;}
    	public String addSitesPermission {set;get;}
		public Set<String> initiativesAndCampaignsManagers {get; set;}

		/**
		 * @description - key to send leadercastPermission type to UI
		 */
		public String leadercastPermission {set;get;}

		/**
		 * @description - key to send set of people records that have leadercast permission access
		 */
		public Set<String> leadercastControlPeople {set;get;}

		/**
		 * @description - key to send set of sites whose managers will have leadercast permissions
		 */
		public Set<String> leadercastControlSites {set;get;}
    	
        /*** @description store org level onboarding priviledge */
        public Set<String> onboardingPeopleList {set;get;}
        /*** @description store site level onboarding priviledge */
        public Set<String> onboardingSiteList {set;get;}
        /*** @description store site level onboarding permission setting */
    	public String onboardingSitePermission {set;get;}
        /*** @description flag to send ai content moderation priviledge enabled or not */
        public Boolean isAIContentModerationEnabled {set;get;}
        /*** @description store people ai content moderation priviledge */
        public Set<String> contentModeratorPeopleList {set;get;}
		/*** @description flag to store onboarding enabled or not */
        public Boolean isOnboardingEnabled {set;get;}
		
        public Boolean isMyTeamsAnalyticsSettingEnabled {set;get;}
    	
    	public PrivilegesSetsWrapper () {
			protectedAuthorAllowlisted = new Set<String>();
			protectedAuthor = new Set<String>();
    		leadership = new Set<String>();
    		influencers = new Set<String>();
    		newsletterControlPeople = new Set<String>();
    		analyticsAccess = new Set<String>();
    		newsletterControlSite = new Set<String>();
			mustReadsControlSite = new Set<String>();
    		canAccessAlertsPeople = new Set<String>(); 
    		alertsControlSite = new Set<String>();
    		canManageSocialCampaign = new Set<String>();
    		unlistedSitesManagingPeopleIdSet = new Set<String>();
    		appManagingPeopleIdSet = new Set<String>();
    		campaignManagingPeopleIdSet = new Set<String>();
    		addSitesUserSet = new Set<String>();
    		addSitesPermission = '';
			leadercastPermission = '';
			leadercastControlPeople = new Set<String>();
			leadercastControlSites = new Set<String>();
			initiativesAndCampaignsManagers = new Set<String>();		
    	}
    	
    }
    
     /** Modified By AJAY */
	public class NavigationSetupWrapper {
    	public List<CheckboxItem> features;
    	public String appLightningSetting;
    	public Boolean goToSalesforceEnabled;
    	public Boolean isOrgChartEnabled;
    	
		public NavigationSetupWrapper(){
			features = new List<CheckboxItem>();
		}
		
    }
    
    // App setup -> People
    public class GeneralPeopleWrapper {
    	public Boolean peopleCategoryEnabled;
    	public String peopleCategorySingular;
    	public String peopleCategoryPlural;
    	public Integer locationsCount;
    	public Integer departmentsCount;
    	public Integer employeesCount;
    	public Boolean autoProvisioningProcessEnabled;
		public Boolean autoFreeSimpplrLicenseEnabled;
		public Boolean peopleCategoryUsedForAudience;
    }
    
    // AppConfigEmail
    public class AppConfigEmailWrapper {
    	public Boolean enableEmail;
    	public Boolean enableTopStoriesEmails;
    	public Boolean enableDeepLinking;
    	public String emailSender;
    	public Set<String> usersWhoControlNewsletter;
    	public String chatterEmails;
    	public Set<String> profilesNotReceiveEmails;
		public Set<Pair> availableProfiles;
		public Map<String, String> availableSenders;
    	
    	// Constructor 
    	public AppConfigEmailWrapper(){
    		profilesNotReceiveEmails = new Set<String>();
    		usersWhoControlNewsletter = new Set<String>();
    	}
    }
    
	public class UserSyncingPeopleWrapper {
        
        public String syncSource;
        public String uniqueIdentifier;
        public String queryFilter;
        public Boolean enableFormatting;
        public String maxSyncAttempts;
        public LastSyncInfoWrapper lastSyncInfo;
        public Boolean firstName;
        public Boolean middleName;
        public Boolean lastName;
        public Boolean userTitle;
        public Boolean birthDate;
        public Boolean userEmail;
        public Boolean communityNickname;
        public Boolean aboutMe;
        public Boolean employeeNumber;
        public Boolean manager;
        public Boolean department;
        public Boolean userDivision;
        public Boolean companyName;
        public Boolean joiningDate;
        public Boolean userRole;
        public Boolean street;
        public Boolean postalCode;
        public Boolean city;
        public Boolean state;
        public Boolean country;
        public Boolean phone;
        public Boolean extension;
        public Boolean mobilePhone;
        public Boolean fax;
        public Boolean photo;
        public Boolean federationId;
        public Boolean locale;
        public Boolean language;
        public Boolean timeZone;
        public String joiningDateKey;
        public String birthDateKey;
        public String companyNameKey;
        public String userDivisionKey;
        public Boolean csvSaved;
		public String ukgProDepartmentKey;
		public String ukgProBirthDateKey;
		public String ukgProUserDivisionKey;
		public String streetKey;
		public String cityKey;
		public String stateKey;
		public String countryKey;
		public String postalCodeKey;
		public String streetNameKey;
		public String cityNameKey;
		public String stateNameKey;
		public String countryNameKey;
		public String postalCodeNameKey;
        public List<CustomProfileField> additionalFields;       
    }
	
	public class LastSyncInfoWrapper {
		public String lastRunAt;
		public String status;
	}

    public class ProfileFieldsWrapper {
    	public Boolean firstName;
    	public Boolean editableFirstName;
    	public Boolean lastName;
    	public Boolean editableLastName;
    	public Boolean userTitle;
    	public Boolean editableUserTitle;
		public Boolean language;
    	public Boolean editableLanguage;
    	public Boolean aboutMe;
    	public Boolean editableAboutMe;
    	public Boolean department;
    	public Boolean editableDepartment;
    	public Boolean state;
    	public Boolean editableState;
    	public Boolean country;
    	public Boolean editableCountry;
    	public Boolean phone;
    	public Boolean editablePhone;
    	public Boolean extension;
    	public Boolean editableExtension;
    	public Boolean mobilePhone;
    	public Boolean editableMobilePhone;
    	public Boolean userCategory;
		public Boolean editableUserCategory;
		public Boolean city;
		public Boolean editableCity;
		public Boolean street;
		public Boolean editableStreet;
		public Boolean manager;
		public Boolean editableManager;
		public Boolean timezone;
		public Boolean editableTimezone;
		public Boolean birthDate;
		public Boolean editableBirthDate;
		public Boolean joiningDate;
		public Boolean editableJoiningDate;
		public Boolean companyName;
		public Boolean editableCompanyName;
		public Boolean division;
		public Boolean divisionSynced;
		public Boolean editableDivision;
		
		public Boolean video;
		public Boolean editableVideo;
		public String videoProvider;

		public map<String, String> availableFields;
		
		
		public List<CustomProfileField> customFields {get; set;}

		Public Boolean lastNameSynced;
        Public Boolean firstNameSynced;
        Public Boolean userTitleSynced;
        Public Boolean aboutMeSynced;
        Public Boolean departmentSynced;
        Public Boolean stateSynced;
        Public Boolean countrySynced;
        Public Boolean phoneSynced;
        Public Boolean extensionSynced;
        Public Boolean mobilePhoneSynced;
        Public Boolean userCategorySynced;
        Public Boolean citySynced;
        Public Boolean streetSynced;
        Public Boolean managerSynced;
        Public Boolean timezoneSynced;
        Public Boolean birthDateSynced;
        Public Boolean hireDateSynced;
        Public Boolean joiningDateSynced;
        Public Boolean companyNameSynced;
        Public Boolean dvisionSynced;
        Public Boolean videoSynced;
        Public Boolean languageSynced;

    }

	public class MessagingIntegrationWrapper {
		public Boolean slackIntegrationEnabled;
		public Boolean slackConnected;
    	public String slackClientId;
    	public String slackClientSecret;
		public Boolean slackLinkUnfurlEnabled;//not in use any more
		public Boolean slackAppInstalled;
		public Boolean isAddToSlackButtonEnabled;
		public Boolean isSlackUnfurlAppInstalled;
		public String slackUninstallUrl;
		public String addToSlackUrl;
		public Boolean slackCustomNameIconEnabled;
		public String slackAppName;
		public String slackAppIconConfig;
    	
		/* Fields for Microsoft Teams Access */
		public Boolean microsoftTeams;
        public Boolean microsoftTeamsIntegrationEnabled;
		public Boolean microsoftTeamsConnected;
		public String microsoftTeamsClientId;
    	public String microsoftTeamsClientSecret;
		public Boolean microsoftTeamsInstalled;
		public Boolean isAddToMicrosoftTeamsButtonEnabled;
		public String microsoftTeamsUninstallUrl;
		public String addToMicrosoftTeamsUrl;
		public Boolean isAlertsForTeamsEnabled;
		public String msTeamsConnectedAs;
		public String msTeamsDomainID;
	}

	public class SupportIntegrationWrapper {
		public ServiceNowWrapper.SNWrapper serviceNow;
		public AtlassianWrapper atlassian;		
	}
    
    public class FilesIntegrationWrapper {
    	// EFS Flags    	
    	public Boolean boxStorage;
    	public Boolean gdriveEnabled;
    	public Boolean dropboxEnabled;		
		public Boolean spIntegrationEnabled;
    	public Boolean odIntegrationEnabled;
    			
    	// Box
		public String boxClientId;
		public String boxClientSecret;
		public String boxConnectedAs;
		public String boxManagedPermission;
		public Boolean showOpenInBox;
		public Boolean isBoxAccountReconnectRequired;

		// Google Drive
		public String gdriveClientId;
		public String gdriveClientSecret;
		public String gdriveConnectedAs;	
		public Boolean isGoogleDriveAccountReconnectRequired;
		public Boolean googleDriveDomainExists;
		public String googleMultiDomainUpgradeStatus;
		
		// Dropbox
		public String dbUserClientId;
		public String dbUserClientSecret;
		public String dbAdminClientId;
		public String dbAdminClientSecret;
		public String dbConnectedAs;
		
		// One Drive
		public String odDomain;
    	public String odClientId;
    	public String odClientSecret;
		public Boolean odConnected;
    	
		// Sharepoint
		public String spDomain;
    	public String spClientId;
    	public String spClientSecret;
		public Boolean spConnected;
		public String spConnectedAs;
        public Boolean spFullSearchEnabled;
		public Boolean showOpenInSharePoint;
		public String spUpgradeStatus;
		public List<String> sharepointDomainWhitelist;
        
        //Google Shared/My Drive 
        public String googleDriveConnectedAs; 
        public Boolean myDriveEnabled;
        public Boolean googleManagedPermission;
        public Boolean googleDriveEnabled;
        public Boolean sharedDriveEnabled;
        public Boolean showOpenInGoogleDrive;
	}

	public class DomainsIntegrationReqWrapper {
		public String type;

		// Google Multi-Domain
		public List<Map<String, String>> googleDriveDomainList;
		public List<Map<String, String>> googleCalendarDomainList;
	}

	public class DomainsIntegrationResWrapper {
		// Google Multi-Domain
		public Map<String, List<Map<String, String>>> googleDomainList;
	}

	public class GoogleManualUpgradeFlowReqWrapper {
		public Boolean retainGoogleGroups;
	}
    
    public class TroubleshootingWrapper {
    	public Boolean collaborationGroup;
    	public Boolean collaborationGroupMember;
    	public Boolean contentVersion;
    	public Boolean contentDocument;
    	public Boolean feedItem;
    	public Boolean feedComment;
    	public Boolean simpplrContent;
    	public Boolean simpplrSite;
    	public Boolean user;
    	public Boolean debugEnabled;
    	public Boolean jsDebugEnabled;
		public Boolean errorStack;
		public Boolean updateSimpplrDomain;
		public String currentSimpplrDomain;
    }

    /**
     * @description wrapper class for MobileApp setup of manage application
     */
    public class MobileAppWrapper {
		public Boolean nativeAppEnabled;
		public Boolean brandedAppEnabled;
		public String mobilePromotionEnabled;
		public String brandedAppDistributionEnabled;
        public String mobileAppAdditionalSecurityEnabled;
    }
	
	public class ManageSitesCategoryWrapper implements Comparable{
		public String id {get;set;}
		public String categoryId;
    	public String name {get;set;}
		public Integer siteCount {get;set;}
    	public String access;
    	public Boolean isUncategorized;
		public String url;
		public String sortBy;
		public Datetime modifiedAtDateTime;
		public Integer order;
		public List<SiteLiteWrapper> listOfSites;
    	public FileContentWrapper img;

		public Integer compareTo(Object compareTo) {
	        ManageSitesCategoryWrapper categoryData = (ManageSitesCategoryWrapper) compareTo;
	        if(sortBy != null && categoryData.sortBy != null) {
				if ('latest'.equalsIgnoreCase(categoryData.sortBy)) {
					if(modifiedAtDateTime!=null && categoryData.modifiedAtDateTime!=null){
						if (modifiedAtDateTime < categoryData.modifiedAtDateTime) return 1;
						if (modifiedAtDateTime > categoryData.modifiedAtDateTime) return -1;
					}
				} else if('natural'.equalsIgnoreCase(categoryData.sortBy)) {
					if(order!=null && categoryData.order!=null){
						if (order > categoryData.order) return 1;
						if (order < categoryData.order) return -1;
					}
				}
				if('alphabetical'.equalsIgnoreCase(categoryData.sortBy) || String.isBlank(categoryData.sortBy)) {
					return name.toLowerCase().compareTo(categoryData.name.toLowerCase());
				}
            }
	        return 0;      
	    }
	}
	
    public with sharing class PaginationWrapper {
		public String nextPageToken;
    	public List<ManageSitesCategoryWrapper> listOfItems = new List<ManageSitesCategoryWrapper>();
	}
	public class CategoryEditWrapper {
		public String categoryName {get;set;}
		public String newCategoryName {get;set;}
	}
	
	public class DefaultFeedSettingsWrapper {
		public String feedSetting;
		public String feedFilter;
		public Boolean isProcessing;
		public String appDefaultLastModifiedDate;
		public String appDefaultLastModifiedByURL;
		public String appDefaultLastModifiedByName;
		public String isApplyToAllUsers;
		 
    }

    public class SummariesAndDigestWrapper {
        public Boolean isProcessing;
		public String isApplyToAllUsers;
        public String digestFrequency;
        public String topStoriesFrequency;
        public String siteAnalyticsFrequency;
		public String emailOnboardingFrequency;
        public String modifiedAt; 
        public UserWrapper modifiedBy; 
    }

    public class UserWrapper {
        public String peopleId; 
        public String name; 
        public String url; 
    }

	public class EmailNotificationWrapper {
		public Boolean isProcessing;
		public String isApplyToAllUsers;
        
		public String allowSimpplrEmails;
		public String emailNotificationFrequency;

		//Org
		public Boolean emailContentMarkedAsMustRead;
		public Boolean emailAlerts;
		public Boolean emailUpdatesContentSitesFollow;

		//Profile and Expertise
		public Boolean emailFollowsMe;
		public Boolean emailEndorseExpertise;

		//Feed
		public Boolean emailCommentsPostMade;
		public Boolean emailCommentsAfterMe;
		public Boolean emailCommentsPostLike;
		public Boolean emailLikesPostOrCommentMade;
		public Boolean emailSharesPostMade;
		public Boolean emailPostsToMe;

		//Sites
		public Boolean emailPrivateSiteMembershipResponse;

		//Content
		public Boolean emailKnowledgeReview;
		public Boolean emailKnowledgeExpired;
		public Boolean emailCommentsContentPublished;
		public Boolean emailLikesSharesContentPublished;
		public Boolean emailContentSubmissionResponse;
		public Boolean emailForContentUseful;

		//Event
		public Boolean emailEventInviteMore;
		public Boolean emailUpdatesEventIRsvpYes;
		public Boolean emailUpdatesEventIAuthorOrganize;

		//Site-management 
		public Boolean emailPrivateSiteMembershipRequest;	
		public Boolean emailContentSubmittedForModeration;
		public Boolean emailSubscriptionRequest;

		//App-management 
		public Boolean emailSubscriptionModeration;
		public Boolean emailSiteActionableForAppMgr;
		public Boolean emailContentPromotionMessageForAppMgr;
		public Boolean emailForContentUsefulAppMgr; 

		public String modifiedAt; 
		public UserWrapper modifiedBy; 

		//Question Answer
		public Boolean emailQnANewQuestion;
		public Boolean emailQnAQuestionMention;
		public Boolean emailQnAAnswerMention;
		public Boolean emailQnAVote;
		public Boolean emailQnAAnswerApproval;
		public Boolean emailQnANewAnswer;
		public Boolean emailQnANewApprovedAnswer;
		public Boolean emailQnADuplicateQuestion;
		public Boolean emailForContentQuestion;
		public Boolean emailForContentAnswer;

		//Campaign & Initiative
		public Boolean emailCnIEndCampaign;
		public Boolean emailCnINewCampaign;
		public Boolean emailCnIInitiativeEnd;
		public Boolean emailCnIInitiativeStart;
	}
	
	public class LicensingPeopleWrapper {
		public boolean autoProvisioningProcessEnabled;
		public boolean autoFreeSimpplrLicenseEnabled;
	}
	
	public class SMSNotificationWrapper {
		public Boolean isProcessing;
		public boolean smsAlerts;	
		public boolean smsContentMarkedAsMustRead;
		public boolean smsContentPromotionMessage;
        public String isApplyToAllUsers;
        public String modifiedAt; 
        public UserWrapper modifiedBy;
	}

	public class MobileAppNotificationWrapper {
		public Boolean isProcessing;
		public String isApplyToAllUsers;

		// Org
		public Boolean mobileAppContentMarkedAsMustRead;
		public Boolean mobileAppAlerts;
		public Boolean mobileAppUpdatesContentSitesFollow;
		
		// Profile and Expertise
		public Boolean mobileAppFollowsMe;
		public Boolean mobileAppEndorseExpertise;               // -----------  (New) 

		// Feed
		public Boolean mobileAppCommentsPostMade;
		public Boolean mobileAppReplyAfterMe;                   // -----------  (New) 
		public Boolean mobileAppReplyOnLikedPost;               // -----------  (New) 
		public Boolean mobileAppLikesPostOrCommentMade;
		public Boolean mobileAppSharesMyPost;                   // -----------  (New) 
		public Boolean mobileAppPostsToMe;

		//Site
		public Boolean mobileAppPrivateSiteMembershipResponse;  // -----------  (New)

		// Content
		public Boolean mobileAppCommentsContentPublished;
		public Boolean mobileAppLikesOrSharesContentPublished;
		public Boolean mobileAppContentApprovalRejection;       // -----------  (New) 

		// Events
		public Boolean mobileAppEventInviteMore; 

		// Site-Manager
		public Boolean mobileAppPrivateSiteMembershipRequest;
		public Boolean mobileAppContentSubmittedForModeration;
		
		// Question Answer
		public Boolean mobileQnAQuestionMention;
		public Boolean mobileQnAAnswerMention;
		public Boolean mobileQnAVote;
		public Boolean mobileQnAAnswerApproval;
		public Boolean mobileQnANewAnswer;
		public Boolean mobileQnANewApprovedAnswer;
		public Boolean mobileQnADuplicateQuestion;
		public Boolean mobileQnANewQuestion;
		public Boolean mobileAppContentQuestion;
		public Boolean mobileAppContentAnswer;

		//survey
		public Boolean mobileSurveys;
		
        public String modifiedAt; 
        public UserWrapper modifiedBy;
	}

	public class BrowserNotificationWrapper {
		public Boolean isProcessing;
		public String isApplyToAllUsers;

		// Org
		public Boolean browserMustRead;
		public Boolean browserAlerts;
		public Boolean browserUpdatesContentSitesFollow;
		
		// Profile and Expertise
		public Boolean browserFollowsMe;
		public Boolean browserEndorseExpertise;
		
		// Feed
		public Boolean browserReplyOnMyPost;
		public Boolean browserReplyAfterMe;
		public Boolean browserReplyOnLikedPost;
		public Boolean browserLikesMyPostOrReply;
		public Boolean browserSharesMyPost;
		public Boolean browserPostsToMe;

		//Site
		public Boolean browserPrivateSiteMembershipResponse;
		
		// Content
		public Boolean browserContentValidationRequired;
		public Boolean browserContentValidationExpired;
		public Boolean browserContentCommentsOnPublished;
		public Boolean browserContentLikesSharesOnPublished;
		public Boolean browserContentApprovalRejection;
		public Boolean browserContentFeedback;
		

		// Events
		public Boolean browserEventInvite;
		public Boolean browserEventUpdatesAttending;
		public Boolean browserEventUpdatesAuthoredOrganized;

		// Site-Manager
		public Boolean browserPrivateSiteMembershipRequest;	
		public Boolean browserContentSubmittedForModeration;
		public Boolean browserSubscriptionRequest;

        public String modifiedAt; 
        public UserWrapper modifiedBy;
        
        // Question Answer
        public Boolean browserQnANewQuestion;
        public Boolean browserQnAQuestionMention;
        public Boolean browserQnAAnswerMention;
        public Boolean browserQnAVote;
        public Boolean browserQnAAnswerApproval;
        public Boolean browserQnANewAnswer;
        public Boolean browserQnANewApprovedAnswer;
        public Boolean browserQnADuplicateQuestion;
		public Boolean browserContentQuestion;
		public Boolean browserContentAnswer;

		//Campaign & Initiative
		public Boolean browserCnIEndCampaign;
		public Boolean browserCnINewCampaign;
		public Boolean browserCnIInitiativeEnd;
		public Boolean browserCnIInitiativeStart;
	}

	public class UserProvisioningWrapper{
        public String provisioningSource;
        public String queryFilter;
        public String createNewUser;
        public Boolean profile;
        public Set<Pair> availableProfiles;
        public String profileType;
        public Boolean username;
        public String usernameSuffix;
        public Boolean firstName;
        public Boolean lastName;
        public Boolean userTitle;
        public Boolean birthDate;
        public String birthDateField;
        public Boolean joiningDate;
        public String joiningDateField;
        public Boolean companyName;
        public String companyNameField;
        public Boolean department;
        public Boolean manager;
        public Boolean employeeNumber;
        public Boolean federationId;
        public Boolean phone;
        public Boolean mobilePhone;
        public Boolean userEmail;
        public Boolean fax;
        public Boolean street;
        public Boolean city;
        public Boolean country;
        public Boolean state;
        public Boolean postalCode;
        public Boolean timezone;
        public String timezoneIso;
        public String timezoneName;
        public String deactiveUsers;
        public Boolean locale;
        public String localeType;
        public Boolean language;
        public String languageType;
        public Boolean phoneExtension;
        public String sendEmails;
        public Set<Pair> availableLocale;
        public Boolean about;
        public Boolean division;
        public Boolean csvSaved;
        public String managerUniqueIdentifier;
        public String userDeprovisioningIdentifier;
		public String uniqueIdentifier;
		public String streetKey;
		public String cityKey;
		public String stateKey;
		public String countryKey;
		public String postalCodeKey;
		public String streetNameKey;
		public String cityNameKey;
		public String stateNameKey;
		public String countryNameKey;
		public String postalCodeNameKey;
    }

	public class UKGUserFieldConfig{
		public List<String> employeeFieldList;
		public List<FieldList> employeeUserDefinedFieldList;
		public List<FieldList> companyUserDefinedFieldList;
		public List<FieldList> internationalUserDefinedFieldList;
		public Boolean showEmployeeUserDefinedFieldName;
		public Boolean showCompanyUserDefinedFieldName;
		public Boolean showInternationalUserDefinedFieldName;
	}
	public class FieldList {
		public String id;
		public String name;
	}

	/**
	 * @description wrapper class for ListenerSuite Obj
	 */
	public class ListenerSuiteSetupWrapper {
		/**
		 * @description - key to send people wrapper who can control ListenerSuite type
		 */
		public List<PeopleWrapper> sentimentCheckControlPeople;
		/**
		 * @description - key to send site wrapper for which ListenerSuite is enabled
		 */
		public List<SiteLiteWrapper> sentimentCheckControlSites;
		public ListenerSuiteSetupWrapper(){
			sentimentCheckControlPeople = new List<PeopleWrapper>();			
			sentimentCheckControlSites = new List<SiteLiteWrapper>();
		}
		/**
		 * @description - key to send people wrapper who can manage Survey
		 */
		public List<PeopleWrapper> surveysControlPeople;
		public Boolean isListenerSuiteForMyTeamsEnabled;
	}

	/**
	 * @description wrapper class for Recognition Obj
	 */
	public class RecognitionSetupWrapper {
		/**
		 * @description - key to send people ids who can control Recognition type
		 */
		public List<String> recognitionManagersIds;

		/**
		 * @description - responsew key to send people wrapper who can control Recognition type
		 */
		public List<PeopleLiteWrapper.PeopleMinWrapper> recognitionManagers;
	}
	
}