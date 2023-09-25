public with sharing class AppInitWrapper {
    public UserConfig currentUser;
    public AppSettings settings;    

    public class UserConfig {
        public String sfUserId;
        public String peopleId;
        public String nickname;
        public String firstName;
        public String name;
        public String email;
        public String img;
        public String language; 
        public String locationId;
        public String location;
        public String department;
        public String departmentId;
        public String company;
        public String division;
        public String phone;
        public String mobile;
        public String birthday;
        public String coverImageUrl;
        public String country;
        public String city;
        public String state;
        public String url;
        public String about;
        public String mobileLandingPage;
        public String segmentId;
        public String segmentName;
        public String subSegment;
        public String timezone;
        public String timezoneIso;
        public String timezoneName;
        public String feedSort;
        public String feedFilter;
        public String lastLoginAt;
        public String sessionId;
        public String hireDate;
        public String microsoftTeamsUserId;
        public String microsoftTeamsUserName;
        public String microsoftTeamsConnectedAs;
        public String microsoftTenantId;
        public String slackConnectedAs;
        public String slackUserId;

        public Integer timezoneOffset;

        public Boolean isNewHire;
        public Boolean isOnboardingDisabledOnFeed;
        public Boolean isNewUser;
        public Boolean hasConnectedBoxAccount;
        public Boolean hasConnectedLinkedInAccount;
        public Boolean hasConnectedTwitterAccount;
        public Boolean hasConnectedDropboxAccount;
        public Boolean hasConnectedGoogleDriveAccount;
        public Boolean hasConnectedSharePointAccount;
        public Boolean hasConnectedGoogleCalendarAccount;
        public Boolean hasConnectedOutlookCalendarAccount;
        public Boolean hasConnectedOneDriveAccount;
        public Boolean hasConnectedSlackAccount;
        public Boolean hasConnectedMicrosoftTeamsAccount;
        public Boolean hasConnectedServiceNowAccount;
        public Boolean hasConnectedAtlassianAccount; 
        public Boolean hasLoggedInToMobileApp;
        public Boolean emailProductResearch;
        public Boolean browserNotificationAllowed;
        public Boolean hasDismissedWebPushPromptFromNotiPanel;
        public String spInstanceId;

        public UserPermissions permissions;

        //Deprecated
        public List<String> dismissedFlags;
        public List<String> dismissedOnboardingFlags;
        public List<DismissibleFlashWrapper> dismissibleFlashes;
        public Boolean showConnectAccountsPrompt;
        public Set<String> newIntegrations;
    }

    public class UserPermissions {

        public Boolean canCreateSite;
        public Boolean canAccessAllPrivateSites;
        public Boolean canCreateTopics;
        public Boolean canAccessAnalytics;
        public Boolean canCreateBlogPost;
        public Boolean isSegmentManager;
        public Boolean isSiteManager;
        public Boolean isSiteOwner;
        public Boolean isContentManager;
        public Boolean isSystemAdmin;
        public Boolean isAppManager;
        public Boolean isCampaignManager;
        public Boolean isInitiativesAndCampaignsManager;
        public Boolean canManageOrgOnboarding;
        public Boolean canSendAlerts;
        public Boolean canSendAlertsToAll;
        public Boolean canSendNewsletter;
        public Boolean canSendNewsletterToAll;
        public Boolean isUnlistedAdmin;
        public Boolean canManageHomeDashboard;
        public Boolean canManageCampaigns;
        public Boolean canManageInternalUsers;
        public Boolean isProtectedAuthorAllowlisted;
        public Boolean canManageSiteOnboarding;
        public Boolean canAccessLeadercast;
        public Boolean canManageSentimentCheck;
        public Boolean canManageSurveys;
        public Boolean isContentModerator;
        public Boolean canManageRecognition;
        public Boolean isPeopleManager;
    }

    public class AppSettings {
        public Boolean isCampaignManagerFeatureEnabled;
        public Boolean isHtmlTileEnabled;
        public Boolean isSegmentsEnabled;  
        public Boolean isHomeCarouselEnabled;
        public Boolean isSiteCarouselEnabled;
        public Boolean isOrgChartEnabled;
        public Boolean isAppsAndLinksSegmented;
        public Boolean isBrandingSegmented;
        public Boolean isSocialTilesEnabled;
        public Boolean isMaintenanceModeEnabled;
        public Boolean isPublicFilesLinkEnabled;
        public Boolean isExternalSearchIndexing;
        public Boolean isFeedbackEnabled;
        public Boolean haveToMentionGroup;
        public Boolean isMobilePromotionEnabled;
        public Boolean isNativeAppEnabled;
        public Boolean contentSubmissionsEnabled;
        public Boolean peopleCustomFieldEnabled;
        public Boolean isSiteAppManagerControlled;        
        public Boolean feedOnContentEnabled;
        public Boolean goToSalesforceEnabled;
        public Boolean launchpadEnabled;
        public Boolean isJsDebugEnabled;
        public Boolean isUnlistedSitesEnabled;
        public Boolean showLogoOnMobile;
        public Boolean isAutomatedTranslationEnabled;
        public Boolean isExpertiseAppManagerControlled;
        public Boolean isExpertiseCreateAppManagerControlled;
        public Boolean usageTrackingEnabled;
        public Boolean isHomeAppManagerControlled;
        public Boolean brandingNeedsRefresh;   
        public Boolean feedRichTextEnabled; 
        public Boolean isIframeSecurityEnabled;  
        public Boolean isSimpplrEmailEnabled;
        public Boolean isTopStoriesEmailEnabled;
        public Boolean isSmsNotificationsEnabled;
        public Boolean isTestOrg;
        public Boolean isSandbox;
        public Boolean isAlertsForTeamsEnabled;
        public Boolean isNewEditorEnabled;
        public Boolean hasInitiatives;
        public Boolean isMyTeamsAnalyticsEnabled;
        public Boolean isMyTeamsAnalyticsSettingEnabled;
        public Boolean isListenerSuiteForMyTeamsEnabled;
        public Boolean isPerceptionAnalyticsEnabled;
        public Boolean isActionPollerNotificationEnabled;
        
        public String mobileAppsEnabled;        
        public String packageInfo;
        public String logoUrl;
        public String organizationId;
        public String organizationName;
        public String brandingPrimaryColor;
        public String brandingPrimaryDarkModeColor;
        public String brandingLightModeLinkColor;              //CONT-10737
        public String brandingDarkModeLinkColor;              //CONT-10737
        public String brandingAnchorPrimaryColor;              //CONT-10737



        public String launchpadProvider;
        public String segmentField;
        public String segmentColumnName;
        public String socialCampaignsPolicyUrl;                
        public String maintenanceModeReason; 
        public String appUrl;
        public String allowFileUpload;
        public String jsPath;
        public String framebusterOption;
        public String simpplrVersion;
        public String peopleCustomFieldSingular;
        public String peopleCustomFieldPlural;
        public String feedMode;
        public String imgPath;
        public String defaultFontCss;
        public String socialCampaignsFacebookAppId;
        public String simpplrGaCode;
        public String simpplrMixpanelProjectToken;
        public String feedPlaceholder;
        public String vbrickBaseUrl;
        public String validationPeriod;
        public String appName;
        public String baseUrl;
        public String contentUrl;
        public String homeDashboardLayout;
        public String recognitionModuleUrl;
        public String microserviceUrl;
        public String zeusMicroserviceUrl;
        public String qnaMicroserviceUrl;
        public String sisenseAnalyticsUrl;
        public String globalSearchUrl;
        public String globalSearchBaseUrl;

        public Integer listingLoadSize;
        public Integer commentStagger;
        public Integer feedRefreshInterval;
        public Integer notificationRefreshInterval;
        public Integer alertRefreshInterval;
        public Integer carouselSpeed;
        public Integer loginTimeout;

        public List<String> addOns;
        public List<String> availableContentTypes;
        public List<String> languages;
        public String globalSearchProvider;
        public List<String> addToCalendar;                
        public List<FilterAttributeWrapper> fileProviders;

        public List<AudienceField> availableAudienceFieldTypes;

        public LinkSettings links;
        public IntegrationSettings integrations;
        public Boolean isEnhancedDomainEnabled; 
        public Boolean isMobileNotificationsEnabled;
        public Boolean isActiveDirectoryGroupsEnabled;
        public Boolean isBrandedAppDistributionEnabled;
        public Boolean isAndroidAppLinkAvailable;
        public Boolean isAudienceCSVEnabled;
        public Boolean isOutlookCalendarFeatureEnabled;
        public Boolean isAdditional20FieldsFeatureEnabled;
        public Boolean isQuestionAnswerEnabled;
        public Boolean isQuestionEnabledForContent;
        public Boolean isImageLazyLoadEnabled; 
        public Boolean isPhoneNoAndMobileTokenRemovableFeatureEnabled; 
        public Boolean isMobileAppPopupFeatureEnabled; 

        //AI API Enabled/Disabled
        public Boolean isAITopicSuggestionEnabled;
        public Boolean isAIRelatedContentEnabled;
        public Boolean isAIContentRecommendationEnabled;
        public Boolean isAIContentModerationFeatureEnabled;
        public Boolean isAIPersonalizedCarouselFeatureEnabled;

        public Boolean isInitiativesAndCampaignsEnabled;
        public Boolean isAIContentModerationEnabled;

        // Videos Management 
        public Boolean isVideosManagementFeatureEnabled;

        //AI API versions
        public String aiTopicSuggestionVersion;
        public String aiRelatedContentVersion;
        public String aiContentRecommendationVersion;
        public String aiContentModerationVersion;
        public String aiPersonalizedCarouselVersion;

        //Analytics
        public Boolean isJwtAuthEnabled;
        public String externalAnalyticsJwtEndpoint;
        public Boolean isSiteAndLaunchpadAnalyticsEnabled;
        public String analyticsColorScheme;

        public Boolean isOnboardingEnabled;
        public Boolean isOnboardingContentExist;
        public Boolean isSlackUpgraded;


        //Deprecated
        public String popularContentUrl;
        public String popularSiteId;
        public String popularSiteDashboardLayout;
        public Boolean popularSiteHasCarousel;
        public Boolean popularSiteHasTiles;
    }

    public class AudienceField {
        public String name;
        public String label;
    }

    public class IntegrationSettings {
        public Boolean embedly;
        public Boolean crm;
        public Boolean box;
        public Boolean googledrive;
        public Boolean dropbox;
        public Boolean onedrive;
        public Boolean servicenow;
        public Boolean sharepoint;
        public Boolean googleCalendar;
        public Boolean outlookCalendar;
        public Boolean isSharePointFullSearchEnabled;
        public Boolean slack;
        public Boolean microsoftTeams;
        public Boolean okta;
        public Boolean onelogin;
        public Boolean workday;
        public Boolean activeDirectory;
        public Boolean google;
        public Boolean ukgPro;

        public Boolean atlassian;
        public Boolean confluence;
        
        public String servicenowKnowledgebaseName;
        public String servicenowTicketingSystem;
        public Boolean isServiceNowTicketEnabled;
		public Boolean isServiceNowKnowledgebaseEnabled;
        public Boolean isServiceNowTicketCreationEnabled;

        public String confluenceKnowledgebaseName;

        public GoogleAnalyticsSettings googleAnalytics;
        public GoogleAnalyticsSettings4 googleAnalytics4;
        public Boolean isGa4IntegrationFlagEnabled; // will hold the value of 'ga4_integration' harness flag status
        public Map<String, AppInitWrapper.EnterpriseSearchSettings> enterpriseSearch;
        public Set<String> campaignSocialNetworks;
        public Boolean isMyDriveEnabled;
        public Boolean isSharedDriveEnabled;
        public Boolean showOpenInGoogleDrive;
        public Boolean showOpenInSharePoint;
        public Boolean googleManagedPermission;
        public Boolean isAtlassianVPNWarningVisible;
        public String boxManagedPermission;
        public Boolean showOpenInBox;
        public Boolean isActiveDirectoryGroupsEnabled;
        public String googleMultiDomainUpgradeStatus;
    }

    public class EnterpriseSearchSettings {
        public Boolean isEnabled;
        public String provider;
        public String url;
    }

    public class GoogleAnalyticsSettings {
        public String trackingCode;
        public Boolean isDemographyInterests;
        public Boolean isEnhancedLinkAttribution;
        public Boolean googleAnalytics;
    }
    public class LinkSettings {        
        public String appsDownload;
        public String connectBoxAccount;
        public String connectGdriveAccount;
        public String connectDropboxAccount;
        public String connectOnedriveAccount;
        public String connectSharepointAccount;
        public String connectServicenowAccount;
        public String connectAtlassianAccount;
        public String generateExternalLink;
        public String knowledge;
        public String logout;
        public String mySettingsExternalApps;
        public String mySettingsNotificationsMobile;
        public String manageApp;
        public String manageAppDefaults;
        public String manageAppPeople;
        public String manageAppPeopleProfileFields;
        public String manageAppIntegrations;
        public String manageAppResets;
        public String manageSiteExternalApps;
        public String profileSettings;
        public String salesforce;
        public String serviceNowInstanceUrl;
        public String atlassianInstanceUrl;
        public String legacyAnalytics;
        public String pageRedirectUrl;

    }

    /**
     * @description wrapper class for dismissibleFlash Obj
     */
    public class DismissibleFlashWrapper {
		public String name;
		public String type;
	}

    public class DeferredAppConfig {
        public DeferredUserConfig currentUser;
        public DeferredAppSettings settings;  
    }
    
    public class DeferredAppSettings {
        public String popularContentUrl;
        public String popularSiteDashboardLayout;
        public Boolean popularSiteHasCarousel;
        public Boolean popularSiteHasTiles;
        public String popularSiteId;
        
    }
    
    public class DeferredUserConfig {
        public Boolean showConnectAccountsPrompt;
        public Set<String> newIntegrations;
        public List<String> dismissedOnboardingFlags;
        public List<String> dismissedFlags;
        public List<DismissibleFlashWrapper> dismissibleFlashes;
        
    }

    public class GoogleAnalyticsSettings4 {
        public String trackingCode4;
        public Boolean isEnableGoogleAnalytics4;
    }
    
}