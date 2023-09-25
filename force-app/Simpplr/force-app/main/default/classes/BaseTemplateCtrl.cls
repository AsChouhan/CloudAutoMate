public with sharing class BaseTemplateCtrl extends BaseCtrl {
	public boolean useCustomFont {get; set;}
	public String IEFaviconURL {get;set;}
	public Boolean showLogoOnMobile {get;set;}
	public String languageLocale {get {
		return UserContext.languageLocaleKey.replace('_', '-');
	}set;}
	public Integer timeZoneOffset { get {
		TimeZone tz = UserInfo.getTimeZone();
		Integer offset = tz.getOffset(system.today());
		return offset;
	} set; }

	String alert;
	String notification;	

	public PageReference getNotificationsAndAlerts() {
		AlertDataServer alertDS = new AlertDataServer();
		NotificationDataServer notificationDS = new NotificationDataServer();
		alert = JSON.serializePretty(alertDS.getActiveAlert(),true);
		JSONGenerator jsonGen = JSON.createGenerator(true);
		jsonGen.writeStartObject();
		jsonGen.writeStringField('since',String.valueOf(datetime.now().addSeconds(-60).getTime()));
		jsonGen.writeBooleanField('includeActioned',false);
		jsonGen.writeNumberField('size',20);
		jsonGen.writeEndObject();
		String jsonData = jsonGen.getAsString();
		notification = JSON.serializePretty(notificationDS.getNotifications('search', jsonData),true);
        return null;
	}

    public String getAlert() {
		return alert;
    }
    public String getNotification() {
		return notification;
    }

	/**
	* @description fetch new token based on session and create/update cookie
	* @return String token
	**/
	public String csrfToken { 
		get {
			if(String.isBlank(csrfToken)){
				csrfToken = AccessManager.getCsrfToken();
				AccessManager.manageCookieCsrf(csrfToken);
			}
			return csrfToken;
		} private set; 
	}

    public static Boolean isKitaPSARChangesEnabled {
		get {
			return SimpplrContext.isKitaPSARChangesEnabled;
		}private set;
	}

	public static Boolean isActionPollerNotificationEnabled {
		get {
			return SimpplrContext.isActionPollerNotificationEnabled;
		}private set;
	}

	public static Boolean isApexRestEnabled {
		get {
			return SimpplrContext.isApexRestEnabled;
		}private set;
	}

	public String minifiedJsPath {get {
		return cdnPath + '/js/';		
	} set;}

	public String minifiedJsExtension {get {
		return '.js';
	} set;}

	
	public String minifiedCssPath {get {		
		return cdnPath + '/css/';		
	} set;}			
	
	public Boolean isMaintenanceModeEnabled { get {
		return SimpplrContext.isMaintenanceInProgress;
	} set;}
	
	public Boolean showMaintenanceInterstitialDiv { get {
		showMaintenanceInterstitialDiv = SimpplrContext.isMaintenanceInProgress;
		if(showMaintenanceInterstitialDiv && PageContext.currentPageName.containsIgnoreCase('PostInstallSetup')) {
			if( SimpplrContext.appConfig == null || 'migration'.equalsIgnoreCase(SimpplrContext.appConfig.Maintenance_Reason__c)){
				showMaintenanceInterstitialDiv = false;
			}
		}
		return showMaintenanceInterstitialDiv;
	} set;}

	public String packageVersion { get { 
		return ServiceConstants.PACKAGE_VERSION;
	} set;}

	public String appCSSURL { get {
		appCSSURL = cdnPath + '/css/app.min.css';		
		return appCSSURL;
	} set; }
	
	public String fontCSSURL { get {
		if(useCustomFont) {
			fontCSSURL = PageContext.getPageURL(Pages.BrandingCSS) + '?target=UtilityDataServer&action=getCustomFontCSS&v=' + packageVersion;
		} else {
			fontCSSURL = cdnPath + '/css/font.min.css';
		}
		return fontCSSURL;
	} set; }
	
	public Boolean isJSDebugEnabled { get {
		return SimpplrContext.isJSDebugEnabled;
	} set; }
    
	public Boolean showOnlyLogoInHeader { get { 
		return SimpplrContext.isSimpplrSetupComplete==false || String.isEmpty(UserContext.peopleId);
	} set; }
	
	public String appName { get {
		return String.isBlank(SimpplrContext.applicationName) ? '' : SimpplrContext.applicationName.escapeJava().replace('/', '\\/');
	} set; }

	public String packageName { get {
		return String.isNotBlank(SimpplrContext.packageName) ? (SimpplrContext.packageName + '__') : '';
	} set; }

  	public String faviconsPath { get {   
		String faviconsFolderPath; 
		if(SimpplrContext.isSegmentsEnabled && SimpplrContext.isSegmentBrandingEnabled) {
			faviconsFolderPath = UserContext.getCurrentUserInfo.Segment__r.Favicons_Folder__c;
		} else {
			faviconsFolderPath = SimpplrContext.FaviconsFolder;
		}
		if(String.isBlank(faviconsFolderPath)) {
			faviconsFolderPath = ServiceConstants.DEFAULT_BRANDING.get('logo_faviconPath');
		
		} else if(!faviconsFolderPath.startsWith('http')) {
			faviconsFolderPath = simpplrBaseURL + faviconsFolderPath;

		}
		return faviconsFolderPath;
	} set; }
    
	
    public String getPageTitle() {
    	return  SimpplrContext.applicationName;
    }
    
    public String getCSSClasses() {
     	String cssJson = (SimpplrContext.isSegmentsEnabled && SimpplrContext.isSegmentBrandingEnabled) ? UserContext.getSegmentCSSClasses : SimpplrContext.BrandingCSSClass;
		String cssClass = ' ';
     	if(String.isNotBlank(cssJson)) {
     		List<String> cssClassList = (List<String>)JSON.deserialize(cssJson,List<String>.class);
			for(String className : cssClassList) {
				cssClass = cssClass + className+ ' ';
			}
     	} 
    	return cssClass;
    }
    
    public String getDashboardHasFeedCSSClasses() {
    	String dashboardHasFeedCSSClasses = '';
    	
    	String homeDashboardLayout = SimpplrContext.tileLayout;
    	if(ServiceConstants.DASHBOARD_OWNER_USER.equalsIgnoreCase(SimpplrContext.AppDashboardMode)) {
    		homeDashboardLayout = UserContext.tileLayout;
    		
    	} else if(SimpplrContext.isSegmentsEnabled) {
    		homeDashboardLayout = UserContext.segmentTileLayout;
    		
    	}
    	
    	if(SimpplrContext.isFeedEnabled && ServiceConstants.FEED_ON_DASHBOARD_LAYOUT_SET.contains(homeDashboardLayout)) {
    		dashboardHasFeedCSSClasses = 'home-dashboard-has-feed';
    	}
    	
    	if(SimpplrContext.isFeedEnabled && String.isNotBlank(SiteContext.siteId) && ServiceConstants.FEED_ON_DASHBOARD_LAYOUT_SET.contains(SiteContext.tileLayout)){
    		dashboardHasFeedCSSClasses += ' site-dashboard-has-feed';
    	}
    	
    	return dashboardHasFeedCSSClasses;
    }
    
    /*
    *
    */
    public String getLogoUrl() {
		return SimpplrContext.isSegmentBrandingEnabled ? UserContext.getCurrentUserInfo.Segment__r.Branding_Logo__c : SimpplrContext.SALogo;
    }
    
    public String getPageUrl() {
    	return  ApexPages.currentPage().getUrl();
    }  
    
    public override String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
    public PageReference init(){
		PageReference returnPage = null; 
		showLogoOnMobile = false;
		useCustomFont = false;
		try {
			if (UserContext.hasSimpplrUserPermissionSetAssigned == false){
				throw new SimpplrException(ExceptionCode.PERMISSION_SET_EXCEPTION.name());
			
			} 

			if (SimpplrContext.isSimpplrSetupComplete == true && SimpplrContext.isMaintenanceInProgress == false) {
				
				if (String.isBlank(UserContext.peopleId)) {
					
					if (PageContext.currentPageName.containsIgnoreCase('ErrorPage')) {
					} else if (PageContext.currentPageName.containsIgnoreCase('PostInstallSetup')) {
					} else {
						PeopleDao daoObj = new peopleDao();
						daoObj.autoCreatePeopleOnFirstLogin();
						returnPage = Page.app;
						returnPage.setRedirect(true);
						return returnPage;
					}

				} else {
					startPeopleOnboarding();
				}
				showLogoOnMobile = SimpplrContext.appConfig.Show_Logo_On_Mobile__c;
				setFirstLoginTimeIfRequired();
				setBrandingParams();
			}
			
		} catch (Exception e) {
			returnPage = handleAndTranslateException(returnPage, e);
	    }
        return returnPage;
    }    
    public void startPeopleOnboarding() {
		if(String.isEmpty(UserContext.uuid) && !String.isEmpty(SimpplrContext.uuid)){
			logger.logDebug('--onboarding people--');
			String peopleOnboardingEndpoint = SimpplrContext.simpplrAPIEndpoint + '/people-onboarding';
			Map<String, Object> request = Utility.getPeopleOnboardingRequestBody();
			HttpResponse respPeopleOnboard = Utility.getResponseFromAWS(peopleOnboardingEndpoint, request);
			if(respPeopleOnboard.getStatusCode() == 200) {
				Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(respPeopleOnboard.getBody());
				if (results.containsKey('peopleUuid')) {
					Map<String, Object> soqlParamMap = new Map<String, Object>();
					soqlParamMap.put('soqlParam1', UserContext.peopleId); 
					String peopleQuery = 'SELECT Id, UUID__c FROM People__c where id =:soqlParam1';
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					List<People__c> peopleObjectList = (List<People__c>)SIMPESAPI.accessController().queryAsUser(peopleQuery, soqlParamMap);
					if(!peopleObjectList.isEmpty()){
						peopleObjectList[0].UUID__c = (String)results.get('peopleUuid');
						SIMPESAPI.accessController().updateAsUser(new Map<Id, People__c>(peopleObjectList),new List<Schema.SObjectField>{People__c.UUID__c});
					}
				}
			}

		}
	}
    private void setBrandingParams() {
    		Map<String,Object> brandingMap = new Map<String,Object>();
    		if(SimpplrContext.isSegmentBrandingEnabled) {
    			if(String.isNotBlank(UserContext.segmentId) && String.isNotBlank(UserContext.getCurrentUserInfo.Segment__r.Branding_JSON__c)) {
					brandingMap = (Map<String,Object>)JSON.deserializeUntyped(UserContext.getCurrentUserInfo.Segment__r.Branding_JSON__c);
    			}    			
    		} else {
		    	brandingMap = (Map<String,Object>)JSON.deserializeUntyped(SimpplrContext.SABrandingJSON);
    		}
			if(SimpplrContext.brandingDocNameToIdMap != null || SimpplrContext.brandingDocNameToIdMap.isEmpty()) {
				IEFaviconURL = Utility.getFileDownloadBaseURL() + '/servlet/servlet.ImageServer?id='+SimpplrContext.brandingDocNameToIdMap.get('Favicon')+'&oid='+UserInfo.getOrganizationId() + '&lastMod=' + Datetime.now().getTime();
			}
	    	String fontUsed = String.valueOf(brandingMap.get('font_font'));
	    	if('custom'.equalsIgnoreCase(fontUsed)) {
	    		useCustomFont = true;
	    	}
    }
	
	public void setFirstLoginTimeIfRequired() {
		if(PageContext.currentPageName.containsIgnoreCase('PostInstallSetup') == false &&
		   UserContext.getCurrentUserInfo != null && UserContext.getCurrentUserInfo.First_Login_DateTime__c == null) {
			PeopleDao daoObj = new peopleDao();
			daoObj.updateFirstLoginDateTime();
		}
	}

	public String cdnPath {
		get {
			if(String.isBlank(cdnPath)){
				String basePath = 'https://static.simpplr.com/simpplr/';
				if(String.isBlank(SimpplrContext.packageName)) {
					cdnPath = basePath + 'unmanaged/';
				}
				cdnPath = String.isBlank(SimpplrContext.cdnPath) ? 
							basePath + ServiceConstants.RELEASE_VERSION : SimpplrContext.cdnPath;
			}
			return cdnPath;
		} private set; 
	}

	public String brandingCSS { get {
        String brandingCssString = '';
        if(SimpplrContext.isSegmentsEnabled && SimpplrContext.isSegmentBrandingEnabled && String.isNotBlank(UserContext.segmentId)) {
            brandingCssString = UserContext.getCurrentUserInfo.Segment__r.Branding_CSS__c;
            
        } else if(SimpplrContext.appConfig != null) {
            brandingCssString = SimpplrContext.appConfig.Branding_CSS__c;
        }
        return brandingCssString;
    } set; }

	//To be deleted after Kita
	public String brandingCSSURL {get;set;}
	
}