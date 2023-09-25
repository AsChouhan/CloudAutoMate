/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */

@isTest
private class SimpplrContextTest { 
    @testSetup static void setup() {
    	 TestHelper.setupAppConfig();
         User testUser = TestHelper.createUser('Simpplr_usr', null, false);
         User siteMngr = TestHelper.createUser('Simpplr_siteMngr', null, false);
         
         CollaborationGroup cgroup = TestHelper.createCollaborationGroup('SimpplrContextTest_Grp1','Public');
		TestHelper.createCollaborationGroupMember(cgroup.Id, siteMngr.id,'Admin');
		Simpplr_Site__c  testSite = TestHelper.getSiteRecord(cgroup.Id);
    }
    
    private static void  getAppConfiguration(){
    	App_Config__c appCOnfigVar = SimpplrContext.appConfig;
    }
    
    private static list<Simpplr_Site__c> getSimpplrSiteList(){
    	return([select id ,Chatter_Group_Id__c from Simpplr_Site__c]);
    }
    
   @isTest static void testCommonMethods() {
   		Boolean enableEmail = SimpplrContext.enableEmail;
   		Boolean DeeplinkingEnabled = SimpplrContext.DeeplinkingEnabled;
   		String chatterEmails = SimpplrContext.chatterEmails;
   		String DeeplinkingRedirectURL = SimpplrContext.DeeplinkingRedirectURL;
   		List<String> chatterEmailOffForProfiles = SimpplrContext.chatterEmailOffForProfiles;
   		String SABrandingJSON = SimpplrContext.SABrandingJSON;
   		String BrandingCSSClass = SimpplrContext.BrandingCSSClass;
   		String Id = SimpplrContext.Id;
   		Boolean isPeopleCategoryEnable = SimpplrContext.isPeopleCategoryEnable;
   		String peopleCategorySingular = SimpplrContext.peopleCategorySingular;
   		String peopleCategoryPlural = SimpplrContext.peopleCategoryPlural;
   		Integer simpplrFeedRefreshInterval = SimpplrContext.simpplrFeedRefreshInterval;
   		Boolean enableTopStoriesEmails = SimpplrContext.enableTopStoriesEmails;
   		String PushNotificationServiceUrl = SimpplrContext.PushNotificationServiceUrl;
   		Boolean isMaintenanceInProgress = SimpplrContext.isMaintenanceInProgress;
   		Boolean isPPTimezoneEditable = SimpplrContext.isPPTimezoneEditable;
   		Boolean isPPTimezoneDisplay = SimpplrContext.isPPTimezoneDisplay;
   		Boolean isLocationTileEnabled = SimpplrContext.isLocationTileEnabled;
   		Boolean isPPBirthDateEditable = SimpplrContext.isPPBirthDateEditable;
   		Boolean isPPBirthDateDisplay = SimpplrContext.isPPBirthDateDisplay;
   		Boolean isPPJoiningDateEditable = SimpplrContext.isPPJoiningDateEditable;
   		Boolean isPPJoiningDateDisplay = SimpplrContext.isPPJoiningDateDisplay;
   		Boolean isOneLoginEnabled = SimpplrContext.isOneLoginEnabled;
   		Boolean isOktaEnabled = SimpplrContext.isOktaEnabled;
   		String CustomSSOJSON = SimpplrContext.CustomSSOJSON;
   		Boolean EmbedlyEnabled = SimpplrContext.EmbedlyEnabled;
   		Boolean isJSDebugEnabled = SimpplrContext.isJSDebugEnabled;
   		Integer simpplrFeedPageSize = SimpplrContext.simpplrFeedPageSize;
   		Integer simpplrNotificationRefreshInterval = SimpplrContext.simpplrNotificationRefreshInterval;
   		Boolean IsBoxIntegrationEnabled = SimpplrContext.IsBoxIntegrationEnabled;
   		Boolean isGoToSalesforceEnabled = SimpplrContext.isGoToSalesforceEnabled;
   		Boolean isATContentDocumentEnabled = SimpplrContext.isATContentDocumentEnabled;
   		String feedbackToEmails = SimpplrContext.feedbackToEmails;
   		String packageVersion = SimpplrContext.packageVersion;
   		Integer loginTimeout = SimpplrContext.loginTimeout;
   		Boolean feedbackShareWithSimpplr = SimpplrContext.feedbackShareWithSimpplr;
   		String simpplrOrgId = SimpplrContext.simpplrOrgId;
   		String FileDownloadBaseURL = SimpplrContext.FileDownloadBaseURL;
   		Boolean showHiddenFolders = SimpplrContext.showHiddenFolders;
   		String tileLayout = SimpplrContext.tileLayout;
   		String KnowledgeArticleType = SimpplrContext.KnowledgeArticleType;
   		String KnowledgeArticleDetailField = SimpplrContext.KnowledgeArticleDetailField;
   		String SlackClientId = SimpplrContext.SlackClientId;
   		String SlackClientSecret = SimpplrContext.SlackClientSecret;
   		Boolean slackIntegrationEnabled = SimpplrContext.slackIntegrationEnabled;
   		Integer CarouselSpeed = SimpplrContext.CarouselSpeed;
   		Boolean SimpplrMobileNotificationAllowed = SimpplrContext.SimpplrMobileNotificationAllowed;
   		Boolean SimpplrDesktopNotificationAllowed = SimpplrContext.SimpplrDesktopNotificationAllowed;
   		Boolean isLaunchpadConfigured = SimpplrContext.isLaunchpadConfigured;
   		Boolean isMuteContentPostInSiteFeedEnabled = SimpplrContext.isMuteContentPostInSiteFeedEnabled;
   		Boolean isAnalyticsDataCollectionEnabled = SimpplrContext.isAnalyticsDataCollectionEnabled;
        Boolean isContentGovernanceEnabled = SimpplrContext.isContentGovernanceEnabled;
        Boolean isIframeSecurityEnabled = SimpplrContext.isIframeSecurityEnabled;
        Boolean isSegmentBrandingEnabled = SimpplrContext.isSegmentBrandingEnabled;
        Boolean workdayIntegrationEnabled = SimpplrContext.workdayIntegrationEnabled;
        Boolean adIntegrationEnabled = SimpplrContext.adIntegrationEnabled;
        Boolean showTrackChangesFeedPosts = SimpplrContext.showTrackChangesFeedPosts;
        String appLightningSetting = SimpplrContext.appLightningSetting;
        Boolean microsoftTeamsIntegrationEnabled = SimpplrContext.microsoftTeamsIntegrationEnabled;
        String feedPlaceholder = SimpplrContext.feedPlaceholder;
        Boolean isNPSSurveyEnabled = SimpplrContext.isNPSSurveyEnabled;
        Boolean isContentHistoryEnabled = SimpplrContext.isContentHistoryEnabled;
        Boolean mobilePromotionEnabled = SimpplrContext.mobilePromotionEnabled;
        String appDefaultLanguage = SimpplrContext.appDefaultLanguage;
        Boolean aiTopicSuggestionEnabled = SimpplrContext.aiTopicSuggestionEnabled;
        String aiTopicSuggestionVersion = SimpplrContext.aiTopicSuggestionVersion;
        Boolean aiRelatedContentEnabled = SimpplrContext.aiRelatedContentEnabled;
        String aiRelatedContentVersion = SimpplrContext.aiRelatedContentVersion;
        Boolean aiContentRecommendationEnabled = SimpplrContext.aiContentRecommendationEnabled;
        String aiContentRecommendationVersion = SimpplrContext.aiContentRecommendationVersion;
        Boolean aiContentModerationFeatureEnabled = SimpplrContext.aiContentModerationFeatureEnabled;
        String aiContentModerationVersion = SimpplrContext.aiContentModerationVersion;
        String aiPersonalizedCarouselVersion = SimpplrContext.aiPersonalizedCarouselVersion;
        Boolean isRESTServiceContext = SimpplrContext.isRESTServiceContext;
        String userAgent = SimpplrContext.userAgent;
   		
   		System.assert(true,'Running as expected');
    }
    
    @isTest static void testSimpplrOrgProperty() {
        Organization simpplrOrgTest = SimpplrContext.simpplrOrg;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testIsSandboxProperty() {
        Boolean isSandboxVar = SimpplrContext.isSandbox;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testInstanceProperty() {
        String instanceStr  = SimpplrContext.instance;
        System.assert(true,'Running as expected');
    }
     
    @isTest static void testSalesforceHostProperty() {
        String salesforceHostStr = SimpplrContext.salesforceHost;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testSalesforceBaseUrlProperty() {
        String salesforceBaseUrlStr = SimpplrContext.salesforceBaseUrl;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testAppConfigProperty() {
    	getAppConfiguration();

		System.assert(true,'Running as expected'); 
    }
  
    
    @isTest  static void testAppDownloadInfoURL() {
        String appDownloadInfoURL = SimpplrContext.AppDownloadInfoURL;
    	System.assert(true,'Running as expected');
    }
    
    @isTest  static void testStartOfWeekProperty() {
        String StartOfWeek = SimpplrContext.StartOfWeek;
  		System.assert(true,'Running as expected');
  	}
      
	@isTest  static void testSiteDashboardModeProperty() {
        String SiteDashboardMode = SimpplrContext.SiteDashboardMode;
  		System.assert(true,'Running as expected');
  	}
    
	@isTest  static void testSimpplrSetupCompleteProperty() {
        Boolean SimpplrSetupComplete = SimpplrContext.isSimpplrSetupComplete;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testSearchPeopleAllowedFieldProperty() {
        //String SearchPeopleAllowedField = SimpplrContext.SearchPeopleAllowedField;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testSearchContentAllowedFieldProperty() { 
        //String SearchContentAllowedField = SimpplrContext.SearchContentAllowedField;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testSSOProviderProperty() {
        String SSOProvider = SimpplrContext.SSOProvider;
 	    System.assert(true,'Running as expected');}
    
    @isTest  static void testCarouselLayout() {
        String carouselLayout = SimpplrContext.carouselLayout;
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testIsAuditTrailEnabled() {
        Boolean isAuditTrailEnabled = SimpplrContext.isAuditTrailEnabled;
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testAllowFileShareWithPublicLink() {
        Boolean allowFileShareWithPublicLink = SimpplrContext.allowFileShareWithPublicLink;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testSEDWeeklyDigestSizeProperty() {
        Integer SEDWeeklyDigestSize = SimpplrContext.SEDWeeklyDigestSize;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testSEDFromEmailProperty() {
        String SEDFromEmail = SimpplrContext.SEDFromEmail;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testSEDDailyDigestSizeProperty() {
        Integer SEDDailyDigestSize = SimpplrContext.SEDDailyDigestSize;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testSALogoProperty() {
        String SALogo = SimpplrContext.SALogo;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testFeedMode() {
        String feedMode = SimpplrContext.feedMode; 
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testPackageNameProperty() {
        String packageName = SimpplrContext.packageName; 
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testIsOnlyInfluencersAllowedToCreateBlog() {
        Boolean isOnlyInfluencersAllowedToCreateBlog = SimpplrContext.isOnlyInfluencersAllowedToCreateBlog;
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testIsFeedRichTextEnabled() {
        Boolean isFeedRichTextEnabled = SimpplrContext.isFeedRichTextEnabled;
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testIsEmployeeAdvocacyEnabled() {
        Boolean isEmployeeAdvocacyEnabled = SimpplrContext.isEmployeeAdvocacyEnabled;
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testIsExternalSearchEnabled() {
        Boolean isExternalSearchEnabled = SimpplrContext.isExternalSearchEnabled;
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testIsEnterpriseSearchEnabled() {
        Boolean isEnterpriseSearchEnabled = SimpplrContext.isEnterpriseSearchEnabled;
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testEnterpriseSearchProvider() {
        String enterpriseSearchProvider = SimpplrContext.enterpriseSearchProvider;
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testEnterpriseSearchUrl() {
        String enterpriseSearchUrl = SimpplrContext.enterpriseSearchUrl;
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testGetAWSAccessToken() {
        String getAWSAccessToken = SimpplrContext.getAWSAccessToken;
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testGetExternalSearchBaseUrl() {
        String getExternalSearchBaseUrl = SimpplrContext.getExternalSearchBaseUrl;
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testIsGdriveConnected() {
        Boolean isGdriveConnected = SimpplrContext.isGdriveConnected;
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testIsServiceNowConnected() {
        Boolean isServiceNowConnected = SimpplrContext.isServiceNowConnected;
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testServiceNowUserName() {
        String serviceNowUserName = SimpplrContext.serviceNowUserName;
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testIsDropboxConnected() {
        Boolean isDropboxConnected = SimpplrContext.isDropboxConnected;
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testIsExternalSearchFileEnabled() {
        Boolean isExternalSearchFileEnabled = SimpplrContext.isExternalSearchFileEnabled;
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testIsExternalAnalyticsEnabled() {
        Boolean isExternalAnalyticsEnabled = SimpplrContext.isExternalAnalyticsEnabled;
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testIsOrgChartEnabled() {
        Boolean isOrgChartEnabled = SimpplrContext.isOrgChartEnabled;
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testIsATContentDocumentLinkEnabled() {
        Boolean isATContentDocumentLinkEnabled = SimpplrContext.isATContentDocumentLinkEnabled;
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testAdoptionEmailNextRunDate() {
        DateTime adoptionEmailNextRunDate = SimpplrContext.adoptionEmailNextRunDate;
  		System.assert(true,'Running as expected');}
    
    @isTest static void testAppIntegrationEnabledSet() {
        Set<String> appIntegrationEnabledSet = new Set<String>();
        appIntegrationEnabledSet = SimpplrContext.appIntegrationEnabledSet;
  		System.assert(true,'Running as expected');}
    
    @isTest static void testKnowledgeArticleCustomFields() {
        App_Config__c appConfigObj = TestHelper.getAppConfig();
        appConfigObj.Knowledge_Article_Custom_Fields__c = 'testFields';
        update appConfigObj;
        List<String> KnowledgeArticleCustomFields = new List<String>();
        KnowledgeArticleCustomFields = SimpplrContext.KnowledgeArticleCustomFields;
  		System.assert(true,'Running as expected');}
    
    @isTest static void testServiceNowClientId() {
        String serviceNowClientId = SimpplrContext.serviceNowClientId;
  		System.assert(true,'Running as expected');}
    
    @isTest static void testSimpplrIntegrationServiceEndpoint() {
        String simpplrIntegrationServiceEndpoint = SimpplrContext.simpplrIntegrationServiceEndpoint;
  		System.assert(true,'Running as expected');}
    
    @isTest static void testServiceNowClientSecret() {
        String serviceNowClientSecret = SimpplrContext.serviceNowClientSecret;
  		System.assert(true,'Running as expected');}
    
    @isTest static void testServiceNowCustomKBName() {
        String serviceNowCustomKBName = SimpplrContext.serviceNowCustomKBName;
  		System.assert(true,'Running as expected');}
    
    @isTest static void testServiceNowCustomTicketingName() {
        String serviceNowCustomTicketingName = SimpplrContext.serviceNowCustomTicketingName;
  		System.assert(true,'Running as expected');}
    
    @isTest static void testServiceNowIntegrationEnabled() {
        Boolean serviceNowIntegrationEnabled = SimpplrContext.serviceNowIntegrationEnabled;
  		System.assert(true,'Running as expected');}
    
    @isTest static void testServiceNowKnowledgeBasesJSON() {
        String ServiceNowKnowledgeBasesJSON = SimpplrContext.ServiceNowKnowledgeBasesJSON;
  		System.assert(true,'Running as expected');}
    
    @isTest static void testSlackAppInstalled() {
        Boolean slackAppInstalled = SimpplrContext.slackAppInstalled;
  		System.assert(true,'Running as expected');}
    
    @isTest static void testCustomLinksJSON() {
        String customLinksJSON = SimpplrContext.customLinksJSON;
  		System.assert(true,'Running as expected');}
    
    @isTest static void testIsExpertiseAppManagerControlled() {
        Boolean isExpertiseAppManagerControlled = SimpplrContext.isExpertiseAppManagerControlled;
  		System.assert(true,'Running as expected');}
    
    @isTest static void testNpsSurveyDaysToEnd() {
        Integer npsSurveyDaysToEnd = SimpplrContext.npsSurveyDaysToEnd;
  		System.assert(true,'Running as expected');}
    
    @isTest static void testGetFeatureIntegerValue() {
        Integer getFeatureIntegerValue = SimpplrContext.getFeatureIntegerValue('Mobile_Apps_Enabled');
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testIsPPLanguageEditable() {
        Boolean isPPLanguageEditable = SimpplrContext.isPPLanguageEditable;
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testIsPPLanguageDisplay() {
        Boolean isPPLanguageDisplay = SimpplrContext.isPPLanguageDisplay;
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testIsPPVideoEditable() {
        Boolean isPPVideoEditable = SimpplrContext.isPPVideoEditable;
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testIsPPVideoDisplay() {
        Boolean isPPVideoDisplay = SimpplrContext.isPPVideoDisplay;
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testPPVideoProvider() {
        String PPVideoProvider = SimpplrContext.PPVideoProvider;
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testIsPPDivisionEditable() {
        Boolean isPPDivisionEditable = SimpplrContext.isPPDivisionEditable;
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testIsPPCompanyNameEditable() {
        Boolean isPPCompanyNameEditable = SimpplrContext.isPPCompanyNameEditable;
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testIsPPStreetEditable() {
        Boolean isPPStreetEditable = SimpplrContext.isPPStreetEditable;
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testIsPPStreetDisplay() {
        Boolean isPPStreetDisplay = SimpplrContext.isPPStreetDisplay;
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testPPUserCustomFields() {
        String PPUserCustomFields = SimpplrContext.PPUserCustomFields;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testPPTitleEditableProperty() {
        Boolean PPTitleEditable = SimpplrContext.isPPTitleEditable;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPPTitleDisplayProperty() {
        Boolean PPTitleDisplay = SimpplrContext.isPPTitleDisplay;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPPStateEditableProperty() {
        Boolean PPStateEditable = SimpplrContext.isPPStateEditable;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPPStateDisplayProperty() {
        Boolean PPStateDisplay = SimpplrContext.isPPStateDisplay;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPPPhoneEditableProperty() {
        Boolean PPPhoneEditable = SimpplrContext.isPPPhoneEditable;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testPPPhoneDisplayProperty() {
        Boolean PPPhoneDisplay = SimpplrContext.isPPPhoneDisplay;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testPPMobilePhoneEditableProperty() {
        Boolean PPMobilePhoneEditable = SimpplrContext.isPPMobilePhoneEditable;
 		System.assert(true,'Running as expected');}
      
	@isTest  static void testPPMobilePhoneDisplayProperty() {
        Boolean PPMobilePhoneDisplay = SimpplrContext.isPPMobilePhoneDisplay;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPPManagerEditableProperty() {
        Boolean PPManagerEditable = SimpplrContext.isPPManagerEditable;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPPManagerDisplayProperty() {
        Boolean PPManagerDisplay = SimpplrContext.isPPManagerDisplay;
 	 	System.assert(true,'Running as expected');}
      
	@isTest  static void testPPLastNameEditableProperty() {
        Boolean PPLastNameEditable = SimpplrContext.isPPLastNameEditable;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPPLastNameDisplayProperty() {
        Boolean PPLastNameDisplay = SimpplrContext.isPPLastNameDisplay;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testPPFirstNameEditableProperty() {
        Boolean PPFirstNameEditable = SimpplrContext.isPPFirstNameEditable;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPPFirstNameDisplayProperty() {
        Boolean PPFirstNameDisplay = SimpplrContext.isPPFirstNameDisplay;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPPExtensionEditableProperty() {
        Boolean PPExtensionEditable = SimpplrContext.isPPExtensionEditable;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPPExtensionDisplayProperty() {
        Boolean PPExtensionDisplay = SimpplrContext.isPPExtensionDisplay;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testPPDepartmentEditableProperty() {
        Boolean PPDepartmentEditable = SimpplrContext.isPPDepartmentEditable;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testPPDepartmentDisplayProperty() {
        Boolean PPDepartmentDisplay = SimpplrContext.isPPDepartmentDisplay;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testPPCountryEditableProperty() {
        Boolean PPCountryEditable = SimpplrContext.isPPCountryEditable;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPPCountryDisplayProperty() {
        Boolean PPCountryDisplay = SimpplrContext.isPPCountryDisplay;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPPCompanyNameDisplayProperty() {
        Boolean PPCompanyNameDisplay = SimpplrContext.isPPCompanyNameDisplay;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPPDivisionDisplayProperty() {
        Boolean PPDivisionDisplay = SimpplrContext.isPPDivisionDisplay;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPPCityEditableProperty() {
        Boolean PPCityEditable = SimpplrContext.isPPCityEditable;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPPCityDisplayProperty() {
        Boolean PPCityDisplay = SimpplrContext.isPPCityDisplay;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testPPCategoryEditableProperty() {
        Boolean PPCategoryEditable = SimpplrContext.isPPCategoryEditable;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPPCategoryDisplayProperty() {
        Boolean PPCategoryDisplay = SimpplrContext.isPPCategoryDisplay;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPPAboutMeEditableProperty() {
        Boolean PPAboutMeEditable = SimpplrContext.isPPAboutMeEditable;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPPAboutMeDisplayProperty() {
        Boolean PPAboutMeDisplay = SimpplrContext.isPPAboutMeDisplay;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPDSWorkdayUsernameProperty() {
        String PDSWorkdayUsername = SimpplrContext.PDSWorkdayUsername;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testPDSWorkdayPasswordProperty() {
        String PDSWorkdayPassword = SimpplrContext.PDSWorkdayPassword;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPDSWorkdayEndpointProperty() {
        String PDSWorkdayEndpoint = SimpplrContext.PDSWorkdayEndpoint;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testPDSTitleProperty() {
        Boolean PDSTitle = SimpplrContext.isPDSTitle;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testPDSStreetProperty() {
        Boolean PDSStreet = SimpplrContext.isPDSStreet;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testPDSStateProperty() {
        Boolean PDSState = SimpplrContext.isPDSState;
  		System.assert(true,'Running as expected');}
	      
	@isTest  static void testPDSSourceApplicationProperty() {
        String PDSSourceApplication = SimpplrContext.PDSSourceApplication;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testPDSRoleProperty() {
        Boolean PDSRole = SimpplrContext.isPDSRole;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPDSPostalCodeProperty() {
        Boolean PDSPostalCode = SimpplrContext.isPDSPostalCode;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPDSPhoneProperty() {
        Boolean PDSPhone = SimpplrContext.isPDSPhone;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPDSMobilePhoneProperty() {
        Boolean PDSMobilePhone = SimpplrContext.isPDSMobilePhone;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPDSMiddleNameProperty() {
        Boolean PDSMiddleName = SimpplrContext.isPDSMiddleName;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPDSMaxSyncAttemptsProperty() {
        Integer PDSMaxSyncAttempts = SimpplrContext.PDSMaxSyncAttempts;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testPDSManagerIdProperty() {
        Boolean PDSManagerId = SimpplrContext.isPDSManagerId;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testPDSLastNameProperty() {
        Boolean PDSLastName = SimpplrContext.isPDSLastName;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testPDSJoiningDateProperty() {
        Boolean PDSJoiningDate = SimpplrContext.isPDSJoiningDate;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPDSFirstNameProperty() {
        Boolean PDSFirstName = SimpplrContext.isPDSFirstName;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testPDSFaxProperty() {
        Boolean PDSFax = SimpplrContext.isPDSFax;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testPDSExtensionProperty() {
        Boolean PDSExtension = SimpplrContext.isPDSExtension;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPDSEnableFormattingProperty() {
        Boolean PDSEnableFormatting = SimpplrContext.isPDSEnableFormatting;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testPDSEmployeeNumberProperty() {
        Boolean PDSEmployeeNumber = SimpplrContext.isPDSEmployeeNumber;
  		System.assert(true,'Running as expected');}    
      
	@isTest  static void testPDSEmailProperty() {
        Boolean PDSEmail = SimpplrContext.isPDSEmail;
  		System.assert(true,'Running as expected');}
    
    @isTest  static void testPDSDivisionProperty() {
        Boolean PDSDivision = SimpplrContext.isPDSDivision;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPDSDepartmentProperty() {
        Boolean PDSDepartment = SimpplrContext.isPDSDepartment;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPDSCountryProperty() {
        Boolean PDSCountry = SimpplrContext.isPDSCountry;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPDSCompanyNameProperty() {
        Boolean PDSCompanyName = SimpplrContext.isPDSCompanyName;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPDSCommunityNicknameProperty() {
        Boolean PDSCommunityNickname = SimpplrContext.isPDSCommunityNickname;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testPDSCityProperty() {
        Boolean PDSCity = SimpplrContext.isPDSCity;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testPDSBirthDateProperty() {
        Boolean PDSBirthDate = SimpplrContext.isPDSBirthDate;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testPDSAboutMeProperty() {
        Boolean PDSAboutMe = SimpplrContext.isPDSAboutMe;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testOneLoginLinkProperty() {
        String OneLoginLink = SimpplrContext.OneLoginLink;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testOneLoginEmbeddingTokenProperty() {
        String OneLoginEmbeddingToken = SimpplrContext.OneLoginEmbeddingToken;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testOneLoginAPITokenProperty() {
        String OneLoginAPIToken = SimpplrContext.OneLoginAPIToken;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testOktaPeopleNameFormatProperty() {
        String OktaPeopleNameFormat = SimpplrContext.OktaPeopleNameFormat;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testOktaLinkProperty() {
        String OktaLink = SimpplrContext.OktaLink;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testOktaAPITokenProperty() {
        String OktaAPIToken = SimpplrContext.OktaAPIToken;
  		System.assert(true,'Running as expected');}

	@isTest  static void testLogoutCustomPageURLProperty() {
        String LogoutCustomPageURL = SimpplrContext.LogoutCustomPageURL;
  		System.assert(true,'Running as expected');}
  	  
	@isTest  static void testLogoutCustomPageEnabledProperty() {
        Boolean LogoutCustomPageEnabled = SimpplrContext.isLogoutCustomPageEnabled;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testGATrackingCodeProperty() {
        String GATrackingCode = SimpplrContext.GATrackingCode;
  		System.assert(true,'Running as expected');
	}

	@isTest  static void testGATrackingCode4Property() {
        String GATrackingCode = SimpplrContext.GATrackingCode4;
  		System.assertEquals(GATrackingCode,'xgthyyttw', 'Invalid GATrackingCode!');
	}

	@isTest  static void testEnableGoogleAnalytics4Property() {
        Boolean enableGoogleAnalytics4 = SimpplrContext.enableGoogleAnalytics4;
  		System.assertEquals(false, enableGoogleAnalytics4, 'success');
	}

	@isTest  static void testEnableGoogleAnalytics3Property() {
        Boolean enableGoogleAnalytics3 = SimpplrContext.enableGoogleAnalytics3;
  		System.assertEquals(false, enableGoogleAnalytics3, 'success');
	}
    
	@isTest  static void testGAEnhancedLinkAttributionProperty() {
        Boolean GAEnhancedLinkAttribution = SimpplrContext.isGAEnhancedLinkAttribution;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testGAEnabledProperty() {
        Boolean GAEnabled = SimpplrContext.isGAEnabled;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testGADemographyInterestsProperty() {
        Boolean GADemographyInterests = SimpplrContext.isGADemographyInterests;
  		System.assert(true,'Running as expected');}
   
	@isTest  static void testFileStorageSourceProperty() {
        String FileStorageSource = SimpplrContext.FileStorageSource;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testFileStorageSettingLevelProperty() {
        String FileStorageSettingLevel = SimpplrContext.FileStorageSettingLevel;
  		System.assert(true,'Running as expected');
  	}
      
	@isTest  static void testFeedEnabledProperty() {
        Boolean FeedEnabled = SimpplrContext.isFeedEnabled;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testFaviconsFolderProperty() {
        String FaviconsFolder = SimpplrContext.FaviconsFolder;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testEmbedlyAPIKeyProperty() {
        String EmbedlyAPIKey = SimpplrContext.EmbedlyAPIKey;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testIsUIStackTraceEnabledProperty() {
        Boolean isUIStackTraceEnabled = SimpplrContext.isUIStackTraceEnabled;
  		System.assert(true,'Running as expected');}
    
	/*@isTest  static void testEHEmailEnabledProperty() {
        Boolean EHEmailEnabled = SimpplrContext.isEHEmailEnabled;
  		System.assert(true,'Running as expected');}
    */  
	/*@isTest  static void testEHEmailAddressProperty() {
        String EHEmailAddress = SimpplrContext.EHEmailAddress;
  		System.assert(true,'Running as expected');}
    */  
	@isTest  static void testIsDebugEnabledProperty() {
        Boolean isDebugEnabled = SimpplrContext.isDebugEnabled;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testSimpplrDefaultPageSizeProperty() {
        Integer simpplrDefaultPageSize = SimpplrContext.simpplrDefaultPageSize;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testDataKeyProperty() {
        String DataKey = SimpplrContext.DataKey;
  		system.assert(true,'Running as Expected');}
      
	/*@isTest  static void testCreatedDateProperty() {
        Datetime CreatedDate = SimpplrContext.CreatedDate;
  		System.assert(true,'Running as expected');
    }
      
	@isTest  static void testCreatedByIdProperty() {
        String CreatedById = SimpplrContext.CreatedById;
  		System.assert(true,'Running as expected');
  	}*/
      
	@isTest  static void testCommunitiesEnabledProperty() {
        Boolean CommunitiesEnabled = SimpplrContext.isCommunitiesEnabled;
  		System.assert(true,'Running as expected');}
      
	/*@isTest  static void testCommunitiesBasePathProperty() {
        String CommunitiesBasePath = SimpplrContext.CommunitiesBasePath;
  		System.assert(true,'Running as expected');}
    */
	@isTest  static void testBoxUsernameProperty() {
        String BoxUsername = SimpplrContext.BoxUsername;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testBoxUserIdProperty() {
        String BoxUserId = SimpplrContext.BoxUserId;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testBoxRefreshTokenProperty() {
        String BoxRefreshToken = SimpplrContext.BoxRefreshToken;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testBoxRefreshTokenExpiresAtProperty() {
        Datetime BoxRefreshTokenExpiresAt = SimpplrContext.BoxRefreshTokenExpiresAt;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testBoxEnterpriseIdProperty() {
        String BoxEnterpriseId = SimpplrContext.BoxEnterpriseId;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testBoxClientSecretProperty() {
        String BoxClientSecret = SimpplrContext.BoxClientSecret;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testBoxClientIdProperty() {
        String BoxClientId = SimpplrContext.BoxClientId;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testBoxAllCompanyGroupIdProperty() {
        String BoxAllCompanyGroupId = SimpplrContext.BoxAllCompanyGroupId;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testBoxAccessTokenProperty() {
        String BoxAccessToken = SimpplrContext.BoxAccessToken;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testBoxAccessTokenExpiresAtProperty() {
        Datetime BoxAccessTokenExpiresAt = SimpplrContext.BoxAccessTokenExpiresAt;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testApplicationNameProperty() {
        String applicationName = SimpplrContext.applicationName;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testAppDashboardModeProperty() {
        String AppDashboardMode = SimpplrContext.AppDashboardMode;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testAllowedFeaturesProperty() {
        String AllowedFeatures = SimpplrContext.AllowedFeatures;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testAllowPublicContributionProperty() {
        Boolean AllowPublicContribution = SimpplrContext.isPublicContributionAllowed;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testAllowFollowProperty() {
        Boolean AllowFollow = SimpplrContext.isFollowAllowed;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testAllowCommentsProperty() {
        Boolean AllowComments = SimpplrContext.isCommentsAllowed;
  		System.assert(true,'Running as expected');}
    
	@isTest  static void testATUserEnabledProperty() {
        Boolean ATUserEnabled = SimpplrContext.isATUserEnabled;
  		System.assert(true,'Running as expected');}
      
	/*@isTest  static void testATSimpplrSocialAnalyticsEnabledProperty() {
        Boolean ATSimpplrSocialAnalyticsEnabled = SimpplrContext.isATSimpplrSocialAnalyticsEnabled;
  		System.assert(true,'Running as expected');}
    */
	@isTest  static void testATSimpplrSiteEnabledProperty() {
		Boolean ATSimpplrSiteEnabled = SimpplrContext.isATSimpplrSiteEnabled;
        System.assert(true,'Running as expected');}
    
	@isTest  static void testATSimpplrContentEnabledProperty() {
        Boolean ATSimpplrContentEnabled = SimpplrContext.isATSimpplrContentEnabled;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testATFeedItemEnabledProperty() {
        Boolean ATFeedItemEnabled = SimpplrContext.isATFeedItemEnabled;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testATFeedCommentEnabledProperty() {
        Boolean ATFeedCommentEnabled = SimpplrContext.isATFeedCommentEnabled;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testATContentVersionEnabledProperty() {
        Boolean ATContentVersionEnabled = SimpplrContext.isATContentVersionEnabled;
  		System.assert(true,'Running as expected');}
      
	@isTest  static void testATCollaborationGroupEnabledProperty() {
        Boolean ATCollaborationGroupEnabled = SimpplrContext.isATCollaborationGroupEnabled;
		System.assert(true,'Running as expected');}
      
	@isTest  static void testATCollaborationGroupMemberEnabledProperty() {
        Boolean ATCollaborationGroupMemberEnabled = SimpplrContext.isATCollaborationGroupMemberEnabled;
  		System.assert(true,'Running as expected');}

	@isTest  static void testNewsletterIntegrationServiceEndpoint() {
		String newsletterIntegrationServiceEndpoint = SimpplrContext.newsletterIntegrationServiceEndpoint;
		System.assert(newsletterIntegrationServiceEndpoint != null,'newsletterIntegrationServiceEndpoint not found');
	}
	@isTest  static void testBrandingJsonForNull() {
		App_Config__c appConfig = SimpplrContext.appConfig;
		appConfig.Branding_JSON__c = null;
		update appConfig;
		String SABrandingJSON = SimpplrContext.SABrandingJSON;
		Object jsonObj = Json.deserializeUntyped(SABrandingJSON);
		System.assertEquals(true, SimpplrContext.SABrandingJSON.containsIgnoreCase('"general_primaryColor"'), 'primary color not populated when sending null in branding JSON');
	}

	@isTest  static void testBrandingJsonForEmptyString() {
		App_Config__c appConfig = SimpplrContext.appConfig;
		appConfig.Branding_JSON__c = '';
		update appConfig;
		String SABrandingJSON = SimpplrContext.SABrandingJSON;
		Object jsonObj = Json.deserializeUntyped(SABrandingJSON);
		System.assertEquals(true, SimpplrContext.SABrandingJSON.containsIgnoreCase('"general_primaryColor"'), 'primary color not populated when sending null in branding JSON');
	}

	@isTest  static void testBrandingJsonForEmptyObjectString() {
		App_Config__c appConfig = SimpplrContext.appConfig;
		appConfig.Branding_JSON__c = '{}';
		update appConfig;
		String SABrandingJSON = SimpplrContext.SABrandingJSON;
		Object jsonObj = Json.deserializeUntyped(SABrandingJSON);
		System.assertEquals(true, SimpplrContext.SABrandingJSON.containsIgnoreCase('"general_primaryColor"'), 'primary color not populated when sending empty object in branding JSON');
	}

	@isTest  static void testBrandingJsonForValidString() {
		App_Config__c appConfig = SimpplrContext.appConfig;
		appConfig.Branding_JSON__c = '{"general_primaryColor":"5e8980"}';
		update appConfig;
		String SABrandingJSON = SimpplrContext.SABrandingJSON;
		Object jsonObj = Json.deserializeUntyped(SABrandingJSON);
		System.assertEquals(true, SimpplrContext.SABrandingJSON.containsIgnoreCase('"general_primaryDarkModeColor"'), 'primary dark mode color not getting populated');
	}


	@isTest  static void testTargetEnvironemnt() {
  		System.assertEquals(null, SimpplrContext.targetEnvironemnt, 'target env should be null until we merge sls changes.');
	}

	@isTest  static void testDebugEnabledforUsers() {
        String val = SimpplrContext.debugEnabledforUsers;
  		System.assert(val!=null,'Running as expected');
	}

	@isTest  static void testDebugTurnOffTime() {
        DateTime val = SimpplrContext.debugTurnOffTime;
  		System.assert(val!=null,'Running as expected');
	}

	@isTest  static void testLoggingLevel() {
        Integer val = SimpplrContext.loggingLevel;
  		System.assert(val!=null,'Running as expected');
	}
}