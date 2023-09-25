/* 
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class SimpplrContext {

	public static final String DATE_TIME_FORMAT = 'MMM dd, yyyy hh:mm a';
	public static Boolean appConfigQueried;
	public static Boolean appFeatureQueried;

    private SimpplrContext() {
    } 
	
	public static String carouselLayout{
    	get{
	    	if(carouselLayout == null){
	    		if(appConfig != null){
	    			carouselLayout = appConfig.Carousel_Layout__c;
	    		}
	    	}
	    	return carouselLayout;
    	}private set;
    }
	public static Boolean carouselGovernance{
    	get{
	    	if(carouselGovernance == null){
				carouselGovernance = false;
	    		if(appConfig != null && aiPersonalizedCarouselFeatureEnabled){
					carouselGovernance = appConfig.Carousel_Governance__c;
	    		}
	    	}
	    	return carouselGovernance;
    	}private set;
    }
	
	public static Boolean enableEmail{  
		get {
	    	if(enableEmail == null){
	    		enableEmail = false;
	    		if(appConfig != null){
	      			enableEmail = appConfig.Simpplr_Emails_Allowed__c;
	     		}
	    	}
	    	return enableEmail;
	     }private set;
	}
	
	public static Boolean enableTopStoriesEmails{  
		get {
	    	if(enableTopStoriesEmails == null){
	    		enableTopStoriesEmails = false;
	    		if(appConfig != null){
	      			enableTopStoriesEmails = appConfig.Simpplr_Top_Stories_Emails_Allowed__c;
	     		}
	    	}
	    	return enableTopStoriesEmails;
	     }private set;
	} 
	
	public static String chatterEmails {  // TO Do : Confirm with Ajay for this default value thing.
		get {
	    	if (chatterEmails == null) {
	    		if (appConfig != null) {
	    			if (String.isBlank(appConfig.GoLive_Chatter_Email_Setup__c)) {
						Schema.DescribeFieldResult F = App_Config__c.GoLive_Chatter_Email_Setup__c.getDescribe();
						List <Schema.PicklistEntry> pickVals = F.getPicklistValues();        
						for (Schema.PicklistEntry pv: pickVals) {
						    if (pv.isDefaultValue()) {
						        chatterEmails = pv.getValue();
						        break;
						    }    
						}
	    			} else {
	      				chatterEmails = appConfig.GoLive_Chatter_Email_Setup__c;
	    			}	
	     		}
	    	}
	    	return chatterEmails;
	     }private set;
	}
	public static List<String> chatterEmailOffForProfiles{  
		get {
	    	if (chatterEmailOffForProfiles == null){
	    		if (appConfig != null){
	    			if (!String.isBlank( appConfig.Chatter_Email_Off_Profiles__c)){
		    			chatterEmailOffForProfiles = appConfig.Chatter_Email_Off_Profiles__c.split(',');
	    			}	
	     		}
	    	}
	    	return chatterEmailOffForProfiles;
	     }private set;
	}
	
	public static Boolean DeeplinkingEnabled{
		get {
	    	if(DeeplinkingEnabled == null){
	    		DeeplinkingEnabled = false;
	    		if(appConfig != null){
	      			DeeplinkingEnabled = appConfig.Mobile_App_Deeplinking_Enabled__c;
	     		}
	    	}
	    	return DeeplinkingEnabled;
	     }private set;
	}
	
	public static String DeeplinkingRedirectURL{
		get {
	    	if(String.isBlank(DeeplinkingRedirectURL)){
	    		if(appConfig != null){
	      			DeeplinkingRedirectURL = appConfig.Mobile_App_Deeplinking_Redirect_URL__c;
	     		}
	    	}
	    	return DeeplinkingRedirectURL;
	     }private set;
	}
	@TestVisible
	public static String PPUserCustomFields{
		get {
	    	if(String.isBlank(PPUserCustomFields)){
	    		if(appConfig != null){
	      			PPUserCustomFields = appConfig.PP_User_Custom_Fields__c;
	     		}
	    	}
	    	return PPUserCustomFields;
	     }private set;
	}
	
	public static String PushNotificationServiceUrl{
		get {
	    	if(String.isBlank(PushNotificationServiceUrl)){
	    		if(appConfig != null){
	      			PushNotificationServiceUrl = appConfig.Push_Notification_Service_URL__c;
	     		}
	    	}
	    	return PushNotificationServiceUrl;
	     }private set;
	}
	
	public static String AppDownloadInfoURL{  
		get {
	    	if(AppDownloadInfoURL == null){
	    		if(appConfig != null){
	      			AppDownloadInfoURL = appConfig.App_Download_Info_URL__c;
	     		}
	    	}
	    	return AppDownloadInfoURL;
	     }private set;
	}
	  
	public static String StartOfWeek{
	  get {
	    if(StartOfWeek == null){
	     if(appConfig != null){
	      StartOfWeek = appConfig.Start_Of_Week__c;
	     }
	    }
	    return StartOfWeek;
	   }private set;
	  }
	  
	public static String SiteDashboardMode{
	  get {
	    if(SiteDashboardMode == null){
	     if(appConfig != null){
	      SiteDashboardMode = appConfig.Site_Dashboard_Mode__c;
	     }
	    }
	    return SiteDashboardMode;
	   }private set;
	  }
	public static Boolean isAuditTrailEnabled{
		get {
	    if(isAuditTrailEnabled == null){
	    	isAuditTrailEnabled = false;
		    if(appConfig != null){
		    	isAuditTrailEnabled = appConfig.Audit_Trail_Enabled__c;
		    }
	    }
	    return isAuditTrailEnabled;
	   }private set;
	}
	public static Boolean allowFileShareWithPublicLink{
		get {
	    if(allowFileShareWithPublicLink == null){
	    	allowFileShareWithPublicLink = false;
		    if(appConfig != null){
		    	allowFileShareWithPublicLink = appConfig.Allow_File_Share_With_Public_Link__c;
		    }
	    }
	    return allowFileShareWithPublicLink;
	   }private set;
	}
	@TestVisible
	public static Boolean isSimpplrSetupComplete{
	  get {
	    if(isSimpplrSetupComplete == null){
	    	isSimpplrSetupComplete = false;
		    if(appConfig != null){
		    	isSimpplrSetupComplete = appConfig.Simpplr_Setup_Complete__c;
		    }
	    }
	    return isSimpplrSetupComplete;
	   }private set;
  	}
		@TestVisible
  	public static Boolean isMaintenanceInProgress{
	  get {
	    if(isMaintenanceInProgress == null){
	    	isMaintenanceInProgress = true;
		    if(appConfig != null){
		    	isMaintenanceInProgress = appConfig.Maintenance_In_Progress__c;
		    }
	    }
	    return isMaintenanceInProgress;
	   }private set;
  	}
  	
	public static String SSOProvider{
	  get {
	    if(SSOProvider == null){
	     if(appConfig != null){
	      SSOProvider = appConfig.SSO_Provider__c;
	     }
	    }
	    return SSOProvider;
	   }private set;
	  }
	public static Integer SEDWeeklyDigestSize{
	  get {
	    if(SEDWeeklyDigestSize == null){
	     if(appConfig != null){
	      SEDWeeklyDigestSize = appConfig.SED_Weekly_Digest_Size__c.intValue();
	     }
	    }
	    return SEDWeeklyDigestSize;
	   }private set;
	  }
	public static String SEDFromEmail{
	  get {
	    if(SEDFromEmail == null){
	     if(appConfig != null){
	      SEDFromEmail = appConfig.SED_From_Email__c;
	     }
	    }
	    return SEDFromEmail;
	   }private set;
	  }
	public static Integer SEDDailyDigestSize{ 
	  get {
	    if(SEDDailyDigestSize == null){
	     if(appConfig != null){
	      SEDDailyDigestSize = appConfig.SED_Daily_Digest_Size__c.intValue();
	     }
	    }
	    return SEDDailyDigestSize;
	   }private set;
	  }
	public static String SALogo{
	  get {
	    if(SALogo == null){
	     if(appConfig != null){
	      	SALogo = appConfig.Branding_Logo__c;
	     }
	    }
	    return SALogo;
	   }private set;
	  }
	  
	  public Static String resourcePath {
		get {
			if(resourcePath == null){
				String packageName = String.isNotBlank(SimpplrContext.packageName) ? (SimpplrContext.packageName + '__') : '';
				resourcePath = SimpplrContext.salesforceBaseUrl + '/resource/'+ packageName;
			}
			return resourcePath; 
		} private set;
	}
	  
	 public static String defaultFontCSS {
	 	get {
	 	if(defaultFontCSS == null) {
    		if(String.isNotBlank(SimpplrContext.PackageName)) {
	    		defaultFontCSS = SimpplrContext.resourcePath + 'font_min_css';
	    	} else {
	    		defaultFontCSS = SimpplrContext.resourcePath + 'font_min_css_dev';
	    	}
	 	}
	 	return defaultFontCSS;
	 	} private set;
	 }
	 
	 public static String SABrandingJSON{
	  get {
	    if(SABrandingJSON == null){
			if(appConfig != null){
				SABrandingJSON = appConfig.Branding_JSON__c;
			} 
			if(String.isBLank(SABrandingJSON) ) {
				SABrandingJSON = Utility.getDefaultBrandingValues();
			}
			if(!(SABrandingJSON.containsIgnoreCase('"general_primaryColor"')) ){
				String brandingJsonString = SABrandingJSON.SubString(0, 1) + '"general_primaryColor":"' + ServiceConstants.DEFAULT_BRANDING.get('general_primaryColor')+ '"';
				if(SABrandingJSON.subString(1).length()>1){
					brandingJsonString +=',';
				}
				brandingJsonString += SABrandingJSON.subString(1);
				SABrandingJSON = brandingJsonString;
			}
			if( !(SABrandingJSON.containsIgnoreCase('"general_primaryDarkModeColor"'))){   
				String brandingJsonString = SABrandingJSON.SubString(0, 1) + '"general_primaryDarkModeColor":"' + ServiceConstants.DEFAULT_BRANDING.get('general_primaryDarkModeColor')+ '"';
				if(SABrandingJSON.subString(1).length()>1){
					brandingJsonString +=',';
				}
				brandingJsonString += SABrandingJSON.subString(1);
				SABrandingJSON = brandingJsonString;
			}
			// CONT-10737
			// if( !(SABrandingJSON.containsIgnoreCase('"general_backgroundColor"'))){   
			// 	String brandingJsonString = SABrandingJSON.SubString(0, 1) + '"general_backgroundColor":"' + ServiceConstants.DEFAULT_BRANDING.get('general_backgroundColor')+ '"';
			// 	if(SABrandingJSON.subString(1).length()>1){
			// 		brandingJsonString +=',';
			// 	}
			// 	brandingJsonString += SABrandingJSON.subString(1);
			// 	SABrandingJSON = brandingJsonString;
			// }

			// if( !(SABrandingJSON.containsIgnoreCase('"background_backgroundColor"'))){   
			// 	String brandingJsonString = SABrandingJSON.SubString(0, 1) + '"background_backgroundColor":"' + ServiceConstants.DEFAULT_BRANDING.get('background_backgroundColor')+ '"';
			// 	if(SABrandingJSON.subString(1).length()>1){
			// 		brandingJsonString +=',';
			// 	}
			// 	brandingJsonString += SABrandingJSON.subString(1);
			// 	SABrandingJSON = brandingJsonString;
			// }
			
			if( !(SABrandingJSON.containsIgnoreCase('"color_primaryDarkModeColor"'))){
				String brandingJsonString = SABrandingJSON.SubString(0, 1) + '"color_primaryDarkModeColor":"' + ServiceConstants.DEFAULT_BRANDING.get('color_primaryDarkModeColor')+ '"';
				if(SABrandingJSON.subString(1).length()>1){
					brandingJsonString +=',';
				}
				brandingJsonString += SABrandingJSON.subString(1);
				SABrandingJSON = brandingJsonString;
			}

			if( !(SABrandingJSON.containsIgnoreCase('"general_brandingAnchorPrimarycolor"'))){
				String brandingJsonString = SABrandingJSON.SubString(0, 1) + '"general_brandingAnchorPrimaryColor":"' + ServiceConstants.DEFAULT_BRANDING.get('general_brandingAnchorPrimaryColor')+ '"';
				if(SABrandingJSON.subString(1).length()>1){
					brandingJsonString +=',';
				}
				brandingJsonString += SABrandingJSON.subString(1);
				SABrandingJSON = brandingJsonString;
			}
			if( !(SABrandingJSON.containsIgnoreCase('"color_brandingAnchorDarkModeColor"'))){
				String brandingJsonString = SABrandingJSON.SubString(0, 1) + '"color_brandingAnchorDarkModeColor":"' + ServiceConstants.DEFAULT_BRANDING.get('color_brandingAnchorDarkModeColor')+ '"';
				if(SABrandingJSON.subString(1).length()>1){
					brandingJsonString +=',';
				}
				brandingJsonString += SABrandingJSON.subString(1);
				SABrandingJSON = brandingJsonString;
			}
	    }
		
	     return SABrandingJSON;
	    } private set; 
	  }
	  
	@TestVisible
	public static String packageName{
	  get {
	    if(packageName == null){	    	
			packageName = SimpplrContext.class.getName().substringBefore('SimpplrContext').substringBefore('.').toLowerCase();
	    }
	    return packageName;
	   }private set;
	  }
	 
	@TestVisible
	public static Boolean isPPTimezoneEditable{
	  get {
	    if(isPPTimezoneEditable == null){
	    	isPPTimezoneEditable = false;
	     if(appConfig != null){
	      isPPTimezoneEditable = appConfig.PP_Timezone_Editable__c;
	     }
	    }
	    return isPPTimezoneEditable;
	   }private set;
	  }
	public static Boolean isPPLanguageEditable{
	  get {
	    if(isPPLanguageEditable == null){
	    	isPPLanguageEditable = false;
	     if(appConfig != null){
	      isPPLanguageEditable = appConfig.PP_Language_Editable__c;
	     }
	    }
	    return isPPLanguageEditable;
	   }private set;
	  }
	public static Boolean isPPLanguageDisplay{
	  get {
	    if(isPPLanguageDisplay == null){
	    	isPPLanguageDisplay = false;
	     if(appConfig != null){
	      isPPLanguageDisplay = appConfig.PP_Language_Display__c;
	     }
	    }
	    return isPPLanguageDisplay;
	   }private set;
	  }
	@TestVisible
	public static Boolean isPPTimezoneDisplay{
	  get {
	    if(isPPTimezoneDisplay == null){
	    	isPPTimezoneDisplay = false;
	     if(appConfig != null){
	      isPPTimezoneDisplay = appConfig.PP_Timezone_Display__c;
	     }
	    }
	    return isPPTimezoneDisplay;
	   }private set;
	  }
	 
	public static Boolean isPPVideoEditable{
	  get {
	    if(isPPVideoEditable == null){
	    	isPPVideoEditable = false;
	     if(appConfig != null){
	      isPPVideoEditable = appConfig.PP_Video_Editable__c;
	     }
	    }
	    return isPPVideoEditable;
	   }private set;
	  }
	public static Boolean isPPVideoDisplay{
	  get {
	    if(isPPVideoDisplay == null){
	    	isPPVideoDisplay = false;
	     if(appConfig != null){
	      isPPVideoDisplay = appConfig.PP_Video_Display__c;
	     }
	    }
	    return isPPVideoDisplay;
	   }private set;
	  }
	@TestVisible
	public static String PPVideoProvider{
	  get {
	    if(PPVideoProvider == null){
	     if(appConfig != null){
	      PPVideoProvider = appConfig.PP_Video_Provider__c;
	     }
	    }
	    return PPVideoProvider;
	   }private set;
	  }
	public static Boolean isPPTitleEditable{
	  get {
	    if(isPPTitleEditable == null){
	    	isPPTitleEditable = false;
	     if(appConfig != null){
	      isPPTitleEditable = appConfig.PP_Title_Editable__c;
	     }
	    }
	    return isPPTitleEditable;
	   }private set;
	  }
	public static Boolean isPPTitleDisplay{
	  get {
	    if(isPPTitleDisplay == null){
	    	isPPTitleDisplay = false;
	     if(appConfig != null){
	      isPPTitleDisplay = appConfig.PP_Title_Display__c;
	     }
	    }
	    return isPPTitleDisplay;
	   }private set;
	  }
	public static Boolean isPPStateEditable{
	  get {
	    if(isPPStateEditable == null){
	    	isPPStateEditable = false;
	     if(appConfig != null){
	      isPPStateEditable = appConfig.PP_State_Editable__c;
	     }
	    }
	    return isPPStateEditable;
	   }private set;
	  }
	public static Boolean isPPStateDisplay{
	  get {
	    if(isPPStateDisplay == null){
	    	isPPStateDisplay = false;
	     if(appConfig != null){
	      isPPStateDisplay = appConfig.PP_State_Display__c;
	     }
	    }
	    return isPPStateDisplay;
	   }private set;
	  }
	  
	public static Boolean isLocationTileEnabled{
	  get {
	    if(isLocationTileEnabled == null){
	    	isLocationTileEnabled = false;
	     if(appConfig != null){
	      isLocationTileEnabled = appConfig.PP_City_Display__c || appConfig.PP_Country_Display__c || appConfig.PP_State_Display__c ;
	     }
	    }
	    return isLocationTileEnabled;
	   }private set;
	  }
	public static Boolean isPPPhoneEditable{
	  get {
	    if(isPPPhoneEditable == null){
	    	isPPPhoneEditable = false;
	     if(appConfig != null){
	      isPPPhoneEditable = appConfig.PP_Phone_Editable__c;
	     }
	    }
	    return isPPPhoneEditable;
	   }private set;
	  }
	public static Boolean isPPPhoneDisplay{
	  get {
	    if(isPPPhoneDisplay == null){
	    	isPPPhoneDisplay = false;
	     if(appConfig != null){
	      isPPPhoneDisplay = appConfig.PP_Phone_Display__c;
	     }
	    }
	    return isPPPhoneDisplay;
	   }private set;
	  }
	public static Boolean isPPMobilePhoneEditable{
	  get {
	    if(isPPMobilePhoneEditable == null){
	    	isPPMobilePhoneEditable = false;
	     if(appConfig != null){
	      isPPMobilePhoneEditable = appConfig.PP_MobilePhone_Editable__c;
	     }
	    }
	    return isPPMobilePhoneEditable;
	   }private set;
	  }
	  
	public static Boolean isPPCompanyNameEditable{
	  get {
	    if(isPPCompanyNameEditable == null){
	    	isPPCompanyNameEditable = false;
	     if(appConfig != null){
	      isPPCompanyNameEditable = appConfig.PP_Company_Name_Editable__c;
	     }
	    }
	    return isPPCompanyNameEditable;
	   }private set;
	  }
	  
	public static Boolean isPPDivisionEditable{
	  get {
	    if(isPPDivisionEditable == null){
	    	isPPDivisionEditable = false;
	     if(appConfig != null){
	      isPPDivisionEditable = appConfig.PP_Division_Editable__c;
	     }
	    }
	    return isPPDivisionEditable;
	   }private set;
	  }
	  
	  public static Boolean isPPCompanyNameDisplay{
	  get {
	    if(isPPCompanyNameDisplay == null){
	    	isPPCompanyNameDisplay = false;
	     if(appConfig != null){
	      isPPCompanyNameDisplay = appConfig.PP_Company_Name_Display__c;
	     }
	    }
	    return isPPCompanyNameDisplay;
	   }private set;
	  }
	  
	public static Boolean isPPDivisionDisplay{
	  get {
	    if(isPPDivisionDisplay == null){
	    	isPPDivisionDisplay = false;
	     if(appConfig != null){
	      isPPDivisionDisplay = appConfig.PP_Division_Display__c;
	     }
	    }
	    return isPPDivisionDisplay;
	   }private set;
	  }
	public static Boolean isPPMobilePhoneDisplay{
	  get {
	    if(isPPMobilePhoneDisplay == null){
	    	isPPMobilePhoneDisplay = false;
	     if(appConfig != null){
	      isPPMobilePhoneDisplay = appConfig.PP_MobilePhone_Display__c;
	     }
	    }
	    return isPPMobilePhoneDisplay;
	   }private set;
	  }
	@TestVisible
	public static Boolean isPPManagerEditable{
	  get {
	    if(isPPManagerEditable == null){
	    	isPPManagerEditable = false;
	     if(appConfig != null){
	      isPPManagerEditable = appConfig.PP_Manager_Editable__c;
	     }
	    }
	    return isPPManagerEditable;
	   }private set;
	  }
	public static Boolean isPPManagerDisplay{
	  get {
	    if(isPPManagerDisplay == null){
	    	isPPManagerDisplay = false;
	     if(appConfig != null){
	      isPPManagerDisplay = appConfig.PP_Manager_Display__c;
	     }
	    }
	    return isPPManagerDisplay;
	   }private set;
	  }
	public static Boolean isPPLastNameEditable{
	  get {
	    if(isPPLastNameEditable == null){
	    	isPPLastNameEditable = false;
	     if(appConfig != null){
	      isPPLastNameEditable = appConfig.PP_LastName_Editable__c;
	     }
	    }
	    return isPPLastNameEditable;
	   }private set;
	  }
	public static Boolean isPPLastNameDisplay{
	  get {
	    if(isPPLastNameDisplay == null){
	    	isPPLastNameDisplay = false;
	     if(appConfig != null){
	      isPPLastNameDisplay = appConfig.PP_LastName_Display__c;
	     }
	    }
	    return isPPLastNameDisplay;
	   }private set;
	  }
	public static Boolean isPPFirstNameEditable{
	  get {
	    if(isPPFirstNameEditable == null){
	    	isPPFirstNameEditable = false;
	     if(appConfig != null){
	      isPPFirstNameEditable = appConfig.PP_FirstName_Editable__c;
	     }
	    }
	    return isPPFirstNameEditable;
	   }private set;
	  }
	public static Boolean isPPFirstNameDisplay{
	  get {
	    if(isPPFirstNameDisplay == null){
	    	isPPFirstNameDisplay = false;
	     if(appConfig != null){
	      isPPFirstNameDisplay = appConfig.PP_FirstName_Display__c;
	     }
	    }
	    return isPPFirstNameDisplay;
	   }private set;
	  }
	public static Boolean isPPExtensionEditable{
	  get {
	    if(isPPExtensionEditable == null){
	    	isPPExtensionEditable = false;
	     if(appConfig != null){
	      isPPExtensionEditable = appConfig.PP_Extension_Editable__c;
	     }
	    }
	    return isPPExtensionEditable;
	   }private set;
	  }
	public static Boolean isPPExtensionDisplay{
	  get {
	    if(isPPExtensionDisplay == null){
	    	isPPExtensionDisplay = false;
	     if(appConfig != null){
	      isPPExtensionDisplay = appConfig.PP_Extension_Display__c;
	     }
	    }
	    return isPPExtensionDisplay;
	   }private set;
	  }
	public static Boolean isPPDepartmentEditable{
	  get {
	    if(isPPDepartmentEditable == null){
	    	isPPDepartmentEditable = false;
	     if(appConfig != null){
	      isPPDepartmentEditable = appConfig.PP_Department_Editable__c;
	     }
	    }
	    return isPPDepartmentEditable;
	   }private set;
	  }
	public static Boolean isPPDepartmentDisplay{
	  get {
	    if(isPPDepartmentDisplay == null){
	    	isPPDepartmentDisplay = false;
	     if(appConfig != null){
	      isPPDepartmentDisplay = appConfig.PP_Department_Display__c;
	     }
	    }
	    return isPPDepartmentDisplay;
	   }private set;
	  }
	public static Boolean isPPCountryEditable{
	  get {
	    if(isPPCountryEditable == null){
	    	isPPCountryEditable = false;
	     if(appConfig != null){
	      isPPCountryEditable = appConfig.PP_Country_Editable__c;
	     }
	    }
	    return isPPCountryEditable;
	   }private set;
	  }
	public static Boolean isPPCountryDisplay{
	  get {
	    if(isPPCountryDisplay == null){
	    	isPPCountryDisplay = false;
	     if(appConfig != null){
	      isPPCountryDisplay = appConfig.PP_Country_Display__c;
	     }
	    }
	    return isPPCountryDisplay;
	  }private set;
	}
	@TestVisible
	public static Boolean isPPCityEditable{
	  get {
	    if(isPPCityEditable == null){
	    	isPPCityEditable = false;
	     if(appConfig != null){
	      isPPCityEditable = appConfig.PP_City_Editable__c;
	     }
	    }
	    return isPPCityEditable;
	   }private set;
	}
	@TestVisible
	public static Boolean isPPCityDisplay{
	  get {
	    if(isPPCityDisplay == null){
	    	isPPCityDisplay = false;
	     if(appConfig != null){
	      isPPCityDisplay = appConfig.PP_City_Display__c;
	     }
	    }
	    return isPPCityDisplay;
	   }private set;
	  }
	 public static Boolean isPPStreetEditable{
	  get {
	    if(isPPStreetEditable == null){
	    	isPPStreetEditable = false;
	     if(appConfig != null){
	      isPPStreetEditable = appConfig.PP_Street_Editable__c;
	     }
	    }
	    return isPPStreetEditable;
	   }private set;
	  }
	public static Boolean isPPStreetDisplay{
	  get {
	    if(isPPStreetDisplay == null){
	    	isPPStreetDisplay = false;
	     if(appConfig != null){
	      isPPStreetDisplay = appConfig.PP_Street_Display__c;
	     }
	    }
	    return isPPStreetDisplay;
	   }private set;
	  }
	public static Boolean isPPCategoryEditable{
	  get {
	    if(isPPCategoryEditable == null){
	    	isPPCategoryEditable = false;
	     if(appConfig != null){
	      isPPCategoryEditable = appConfig.PP_Category_Editable__c;
	     }
	    }
	    return isPPCategoryEditable;
	   }private set;
	  }
	public static Boolean isPPCategoryDisplay{
	  get {
	    if(isPPCategoryDisplay == null){
	    	isPPCategoryDisplay = false;
	     if(appConfig != null){
	      isPPCategoryDisplay = appConfig.PP_Category_Display__c;
	     }
	    }
	    return isPPCategoryDisplay;
	   }private set;
	  }
	public static Boolean isPPAboutMeEditable{
	  get {
	    if(isPPAboutMeEditable == null){
	    	isPPAboutMeEditable = false;
	     if(appConfig != null){
	      isPPAboutMeEditable = appConfig.PP_About_Me_Editable__c;
	     }
	    }
	    return isPPAboutMeEditable;
	   }private set;
	  }
	public static Boolean isPPAboutMeDisplay{
	  get {
	    if(isPPAboutMeDisplay == null){
	    	isPPAboutMeDisplay = false;
	     if(appConfig != null){
	      isPPAboutMeDisplay = appConfig.PP_About_Me_Display__c;
	     }
	    }
	    return isPPAboutMeDisplay;
	   }private set;
	  }
	public static String PDSWorkdayUsername{
	  get {
	    if(PDSWorkdayUsername == null){
	     if(appConfig != null){
	      PDSWorkdayUsername = appConfig.PDS_Workday_Username__c;
	     }
	    }
	    return PDSWorkdayUsername;
	   }private set;
	  }
	public static String PDSWorkdayPassword{
	  get {
	    if(PDSWorkdayPassword == null){
	     if(appConfig != null){
	      PDSWorkdayPassword = appConfig.PDS_Workday_Password__c;
	     }
	    }
	    return PDSWorkdayPassword;
	   }private set;
	  }
	public static String PDSWorkdayEndpoint{
	  get {
	    if(PDSWorkdayEndpoint == null){
	     if(appConfig != null){
	      PDSWorkdayEndpoint = appConfig.PDS_Workday_Endpoint__c;
	     }
	    }
	    return PDSWorkdayEndpoint;
	   }private set;
	  }
	public static Boolean isPDSTitle{
	  get {
	    if(isPDSTitle == null){
	    	isPDSTitle = false;
	     if(appConfig != null){
	      isPDSTitle = appConfig.PDS_Title__c;
	     }
	    }
	    return isPDSTitle;
	   }private set;
	  }
	public static Boolean isPDSStreet{
	  get {
	    if(isPDSStreet == null){
	    	isPDSStreet = false;
	     if(appConfig != null){
	      isPDSStreet = appConfig.PDS_Street__c;
	     }
	    }
	    return isPDSStreet;
	   }private set;
	  }
	public static Boolean isPPBirthDateEditable{
	  get {
	    if(isPPBirthDateEditable == null){
	    	isPPBirthDateEditable = false;
	     if(appConfig != null){
	      isPPBirthDateEditable = appConfig.PP_BirthDate_Editable__c;
	     }
	    }
	    return isPPBirthDateEditable;
	   }private set;
	  }   
	public static Boolean isPPBirthDateDisplay{
	  get {
	    if(isPPBirthDateDisplay == null){
	    	isPPBirthDateDisplay = false;
	     if(appConfig != null){
	      isPPBirthDateDisplay = appConfig.PP_BirthDate_Display__c;
	     }
	    }
	    return isPPBirthDateDisplay;
	   }private set;
	  }
    public static Boolean isPPJoiningDateEditable{
	  get {
	    if(isPPJoiningDateEditable == null){
	    	isPPJoiningDateEditable = false;
	     if(appConfig != null){
	      isPPJoiningDateEditable = appConfig.PP_JoiningDate_Editable__c;
	     }
	    }
	    return isPPJoiningDateEditable;
	   }private set;
	  }
    public static Boolean isPPJoiningDateDisplay{
	  get {
	    if(isPPJoiningDateDisplay == null){
	    	isPPJoiningDateDisplay = false;
	     if(appConfig != null){
	      isPPJoiningDateDisplay = true; // appConfig.PP_JoiningDate_Display__c;
	     }
	    }
	    return isPPJoiningDateDisplay;
	   }private set;
	}        
	public static Boolean isPDSState{
	  get {
	    if(isPDSState == null){
	    	isPDSState = false;
	     if(appConfig != null){
	      isPDSState = appConfig.PDS_State__c;
	     }
	    }
	    return isPDSState;
	   }private set;
	  }
	@TestVisible
	public static String PDSSourceApplication{
	  get {
	    if(PDSSourceApplication == null){
	     if(appConfig != null){
	      PDSSourceApplication = appConfig.PDS_Source_Application__c;
	     }
	    }
	    return PDSSourceApplication;
	   }private set;
	  }
	public static Boolean isPDSRole{
	  get {
	    if(isPDSRole == null){
	    	isPDSRole = false;
	     if(appConfig != null){
	      isPDSRole = appConfig.PDS_Role__c;
	     }
	    }
	    return isPDSRole;
	   }private set;
	  }
	public static Boolean isPDSPostalCode{
	  get {
	    if(isPDSPostalCode == null){
	    	isPDSPostalCode = false;
	     if(appConfig != null){
	      isPDSPostalCode = appConfig.PDS_Postal_Code__c;
	     }
	    }
	    return isPDSPostalCode;
	   }private set;
	  }
	public static Boolean isPDSPhone{
	  get {
	    if(isPDSPhone == null){
	    	isPDSPhone = false;
	     if(appConfig != null){
	      isPDSPhone = appConfig.PDS_Phone__c;
	     }
	    }
	    return isPDSPhone;
	   }private set;
	  }
	public static Boolean isPDSMobilePhone{
	  get {
	    if(isPDSMobilePhone == null){
	    	isPDSMobilePhone = false;
	     if(appConfig != null){
	      isPDSMobilePhone = appConfig.PDS_Mobile_Phone__c;
	     }
	    }
	    return isPDSMobilePhone;
	   }private set;
	  }
	public static Boolean isPDSMiddleName{
	  get {
	    if(isPDSMiddleName == null){
	    	isPDSMiddleName = false;
	     if(appConfig != null){
	      isPDSMiddleName = appConfig.PDS_Middle_Name__c;
	     }
	    }
	    return isPDSMiddleName;
	   }private set;
	  }
	public static Integer PDSMaxSyncAttempts{
	  get {
	    if(PDSMaxSyncAttempts == null){
	     if(appConfig != null){
	      PDSMaxSyncAttempts = appConfig.PDS_Max_Sync_Attempts__c.intValue();
	     }
	    }
	    return PDSMaxSyncAttempts;
	   }private set;
	  }
	public static Boolean isPDSManagerId{
	  get {
	    if(isPDSManagerId == null){
	    	isPDSManagerId = false;
	     if(appConfig != null){
	      isPDSManagerId = appConfig.PDS_Manager_Id__c;
	     }
	    }
	    return isPDSManagerId;
	   }private set;
	  }
	public static Boolean isPDSLastName{
	  get {
	    if(isPDSLastName == null){
	    	isPDSLastName = false;
	     if(appConfig != null){
	      isPDSLastName = appConfig.PDS_Last_Name__c;
	     }
	    }
	    return isPDSLastName;
	   }private set;
	  }
	@TestVisible
	public static Boolean isPDSJoiningDate{
	  get {
	    if(isPDSJoiningDate == null){
	    	isPDSJoiningDate = false;
	     if(appConfig != null){
	      isPDSJoiningDate = appConfig.PDS_Joining_Date__c;
	     }
	    }
	    return isPDSJoiningDate;
	   }private set;
	  }
	public static Boolean isPDSFirstName{
	  get {
	    if(isPDSFirstName == null){
	    	isPDSFirstName = false;
	     if(appConfig != null){
	      isPDSFirstName = appConfig.PDS_First_Name__c;
	     }
	    }
	    return isPDSFirstName;
	   }private set;
	  }
	public static Boolean isPDSFax{
	  get {
	    if(isPDSFax == null){
	    	isPDSFax = false;
	     if(appConfig != null){
	      isPDSFax = appConfig.PDS_Fax__c;
	     }
	    }
	    return isPDSFax;
	   }private set;
	  }
	public static Boolean isPDSExtension{
	  get {
	    if(isPDSExtension == null){
	    	isPDSExtension = false;
	     if(appConfig != null){
	      isPDSExtension = appConfig.PDS_Extension__c;
	     }
	    }
	    return isPDSExtension;
	   }private set;
	  }
	public static Boolean isPDSEnableFormatting{
	  get {
	    if(isPDSEnableFormatting == null){
	    	isPDSEnableFormatting = false;
	     if(appConfig != null){
	      isPDSEnableFormatting = appConfig.PDS_Enable_Formatting__c;
	     }
	    }
	    return isPDSEnableFormatting;
	   }private set;
	  }
	public static Boolean isPDSEmployeeNumber{
	  get {
	    if(isPDSEmployeeNumber == null){
	    	isPDSEmployeeNumber = false;
	     if(appConfig != null){
	      isPDSEmployeeNumber = appConfig.PDS_Employee_Number__c;
	     }
	    }
	    return isPDSEmployeeNumber;
	   }private set;
	  }
	public static Boolean isPDSEmail{
	  get {
	    if(isPDSEmail == null){
	    	isPDSEmail = false;
	     if(appConfig != null){
	      isPDSEmail = appConfig.PDS_Email__c;
	     }
	    }
	    return isPDSEmail;
	   }private set;
	  }
	public static Boolean isPDSDivision{
	  get {
	    if(isPDSDivision == null){
	    	isPDSDivision = false;
	     if(appConfig != null){
	      isPDSDivision = appConfig.PDS_Division__c;
	     }
	    }
	    return isPDSDivision;
	   }private set;
	  }
	public static Boolean isPDSDepartment{
	  get {
	    if(isPDSDepartment == null){
	    	isPDSDepartment = false;
	     if(appConfig != null){
	      isPDSDepartment = appConfig.PDS_Department__c;
	     }
	    }
	    return isPDSDepartment;
	   }private set;
	  }
	public static Boolean isPDSCountry{
	  get {
	    if(isPDSCountry == null){
	    	isPDSCountry = false;
	     if(appConfig != null){
	      isPDSCountry = appConfig.PDS_Country__c;
	     }
	    }
	    return isPDSCountry;
	   }private set;
	  }
	public static Boolean isPDSCompanyName{
	  get {
	    if(isPDSCompanyName == null){
	    	isPDSCompanyName = false;
	     if(appConfig != null){
	      isPDSCompanyName = appConfig.PDS_Company_Name__c;
	     }
	    }
	    return isPDSCompanyName;
	   }private set;
	  }
	public static Boolean isPDSCommunityNickname{
	  get {
	    if(isPDSCommunityNickname == null){
	    	isPDSCommunityNickname = false;
	     if(appConfig != null){
	      isPDSCommunityNickname = appConfig.PDS_Community_Nickname__c;
	     }
	    }
	    return isPDSCommunityNickname;
	   }private set;
	  }
	  @TestVisible
	  public static Boolean isPDSCity{
	  get {
	    if(isPDSCity == null){
	    	isPDSCity = false;
	     if(appConfig != null){
	      isPDSCity = appConfig.PDS_City__c;
	     }
	    }
	    return isPDSCity;
	   }private set;
	  }
	public static Boolean isPDSBirthDate{
	  get {
	    if(isPDSBirthDate == null){
	    	isPDSBirthDate = false;
	     if(appConfig != null){
	      isPDSBirthDate = appConfig.PDS_Birth_Date__c;
	     }
	    }
	    return isPDSBirthDate;
	   }private set;
	  }
	@TestVisible
	public static Boolean isPDSAboutMe{
	  get {
	    if(isPDSAboutMe == null){
	    	isPDSAboutMe = false;
	     if(appConfig != null){
	      isPDSAboutMe = appConfig.PDS_About_Me__c;
	     }
	    }
	    return isPDSAboutMe;
	   }private set;
	  }
	public static String OneLoginLink{
	  get {
	    if(OneLoginLink == null){
	     if(appConfig != null){
	      OneLoginLink = appConfig.OneLogin_Link__c;
	     }
	    }
	    return OneLoginLink;
	   }private set;
	  }
	public static String OneLoginEmbeddingToken{
	  get {
	    if(OneLoginEmbeddingToken == null){
	     if(appConfig != null){
	      OneLoginEmbeddingToken = appConfig.OneLogin_Embedding_Token__c;
	     }
	    }
	    return OneLoginEmbeddingToken;
	   }private set;
	  }
	  
	public static String OneLoginAPIToken{
	  get {
	    if(OneLoginAPIToken == null){
	     if(appConfig != null){
	      OneLoginAPIToken = appConfig.OneLogin_API_Token__c;
	     }
	    }
	    return OneLoginAPIToken;
	   }private set;
	  }
	 
	public static boolean isOneLoginEnabled {
	  	get {
		  	if(isOneLoginEnabled == null) {
		  		isOneLoginEnabled = false;
		  		if(appConfig != null){
			      isOneLoginEnabled = appConfig.OneLogin_Enabled__c != null ? appConfig.OneLogin_Enabled__c : false;
			    }
		  	}
		  	return isOneLoginEnabled;
	  	} private set;
	}
	
	public static String OktaPeopleNameFormat{
	  get {
	    if(OktaPeopleNameFormat == null){
	     if(appConfig != null){
	      OktaPeopleNameFormat = appConfig.Okta_People_Name_Format__c;
	     }
	    }
	    return OktaPeopleNameFormat;
	   }private set;
	  }
	public static String OktaLink{
	  get {
	    if(OktaLink == null){
	     if(appConfig != null){
	      OktaLink = appConfig.Okta_Link__c;
	     }
	    }
	    return OktaLink;
	   }private set;
	  }
	public static String OktaAPIToken{
	  get {
	    if(OktaAPIToken == null){
	     if(appConfig != null){
	      OktaAPIToken = appConfig.Okta_API_Token__c;
	     }
	    }
	    return OktaAPIToken;
	   }private set;
	  }
	
	public static boolean isOktaEnabled {
	  	get {
		  	if(isOktaEnabled == null) {
		  		isOktaEnabled = false;
		  		if(appConfig != null){
			      isOktaEnabled = appConfig.Okta_Enabled__c != null ? appConfig.Okta_Enabled__c : false;
			    }
		  	}
		  	return isOktaEnabled;
	  	} private set;
	  }  
	public static String CustomSSOJSON {
		get {
			if(CustomSSOJSON == null){
		     if(appConfig != null){
		      CustomSSOJSON = appConfig.SSO_Custom_JSON__c;
		     }
		    }
	    return CustomSSOJSON;
		} private set;
	}
	public static String LogoutCustomPageURL{
	  get {
	    if(LogoutCustomPageURL == null){
	     if(appConfig != null){
	      LogoutCustomPageURL = appConfig.Logout_Custom_Page_URL__c;
	     }
	    }
	    return LogoutCustomPageURL;
	   }private set;
	  }
	@TestVisible  public static String BrandingCSSClass{
	  get {
	    if(BrandingCSSClass == null){
	     if(appConfig != null){
	      BrandingCSSClass = appConfig.Branding_CSS_Class__c;
	     }
	    }
	    return BrandingCSSClass;
	   }private set;
	  }
	public static Boolean isLogoutCustomPageEnabled{
	  get {
	    if(isLogoutCustomPageEnabled == null){
	    	isLogoutCustomPageEnabled = false;
	     if(appConfig != null){
	      isLogoutCustomPageEnabled = appConfig.Logout_Custom_Page_Enabled__c;
	     }
	    }
	    return isLogoutCustomPageEnabled;
	   }private set;
	  }

	public static String Id{
	  get {
	    if(Id == null){
	     if(appConfig != null){
	      Id = appConfig.Id;
	     }
	    }
	    return Id;
	   }private set;
	  }
	public static String GATrackingCode{
	  get {
	    if(GATrackingCode == null){
	     if(appConfig != null){
	      GATrackingCode = appConfig.GA_Tracking_Code__c;
	     }
	    }
	    return GATrackingCode;
	   }private set;
	  }

	  public static String GATrackingCode4{
		get {
		  if(GATrackingCode4 == null){
		   if(appConfig != null){
			GATrackingCode4 = appConfig.GA_Tracking_Code4__c;
		   }
		  }
		  return GATrackingCode4;
		 }private set;
		}
	public static Boolean isGAEnhancedLinkAttribution{
	  get {
	    if(isGAEnhancedLinkAttribution == null){
	    	isGAEnhancedLinkAttribution = false;
	     if(appConfig != null){
	      isGAEnhancedLinkAttribution = appConfig.GA_Enhanced_Link_Attribution__c;
	     }
	    }
	    return isGAEnhancedLinkAttribution;
	   }private set;
	  }
	@TestVisible
	public static Boolean isGAEnabled{
	  get {
	    if(isGAEnabled == null){
	    	isGAEnabled = false;
	     if(appConfig != null){
	      isGAEnabled = appConfig.GA_Enabled__c;
	     }
	    }
	    return isGAEnabled;
	   }private set;
	  }
	@TestVisible
	public static Boolean enableGoogleAnalytics4{
		get {
		  	if(enableGoogleAnalytics4 == null){
				enableGoogleAnalytics4 = false;
		   		
				if(appConfig != null){
					enableGoogleAnalytics4 = appConfig.Enable_Google_Analytics4__c;
		   		}
			}
		  	return enableGoogleAnalytics4;
		}private set;
	} 
	
	public static Boolean enableGoogleAnalytics3{
		get {
			if(enableGoogleAnalytics3 == null){
				enableGoogleAnalytics3 = false;
				
		   		if(appConfig != null){
					enableGoogleAnalytics3 = appConfig.Enable_Google_Analytics3__c;
		   		}
		  	}
			return enableGoogleAnalytics3;
		}private set;
	}  
	public static Boolean isGADemographyInterests{
	  get {
	    if(isGADemographyInterests == null){
	    	isGADemographyInterests = false;
	     if(appConfig != null){
	      isGADemographyInterests = appConfig.GA_Demography_Interests__c;
	     }
	    }
	    return isGADemographyInterests;
	   }private set;
	  }
	  
	public static Boolean isOnlyInfluencersAllowedToCreateBlog {
		get {
		    if(isOnlyInfluencersAllowedToCreateBlog == null){
		    	isOnlyInfluencersAllowedToCreateBlog = false;
		     if(appConfig != null){
		      isOnlyInfluencersAllowedToCreateBlog = appConfig.Allow_Only_Influencers_To_Create_Blog__c;
		     }
		    }
		    return isOnlyInfluencersAllowedToCreateBlog;
		}private set;
  	}

	public static String FileStorageSource{
	  get {
	    if(FileStorageSource == null){
	     if(appConfig != null){
	      FileStorageSource = appConfig.File_Storage_Source__c;
	     }
	    }
	    return FileStorageSource;
	   }private set;
	  }
	public static String FileStorageSettingLevel{
	  get {
	    if(FileStorageSettingLevel == null){
	     if(appConfig != null){
	      FileStorageSettingLevel = appConfig.File_Storage_Setting_Level__c;
	     }
	    }
	    return FileStorageSettingLevel;
	   }private set;
	  }
	public static Boolean isFeedEnabled{
	  get {
	    if(isFeedEnabled == null){
	    	isFeedEnabled = false;
	     if(appConfig != null){
	      isFeedEnabled = appConfig.Feed_Enabled__c;
	     }
	    }
	    return isFeedEnabled;
	   }private set;
	  }

	public static String feedMode {
		get {
			if(feedMode == null){
				if(appConfig != null){
					feedMode = appConfig.Feed_Mode__c;
				}
			}
			return feedMode;		
		}private set;
	}	
		
	public static String FaviconsFolder{
		get {
			if(FaviconsFolder == null){
				if(appConfig != null){
					FaviconsFolder = appConfig.Favicons_Folder__c;
				}
			}
			if(String.isBlank(FaviconsFolder)) {
				FaviconsFolder = ServiceConstants.DEFAULT_BRANDING.get('logo_faviconPath');
			}
			if(FaviconsFolder.endsWith('/')) {
				FaviconsFolder = FaviconsFolder.removeEnd('/');				
			}
			return FaviconsFolder;
		}private set;
	}

	public static Boolean EmbedlyEnabled{
	  get {
	    if(EmbedlyEnabled == null){
	     if(appConfig != null){
	      EmbedlyEnabled = appConfig.Embedly_Enabled__c && String.isNotBlank(appConfig.Embedly_API_Key__c);
	     }
	    }
	    if(EmbedlyEnabled == null){
	    	EmbedlyEnabled = false;
	    }
	    return EmbedlyEnabled;
	   }private set;
	  }
	
	public static String EmbedlyAPIKey{
	  get {
	    if(EmbedlyAPIKey == null){
	     if(appConfig != null){
	      EmbedlyAPIKey = appConfig.Embedly_API_Key__c;
	     }
	    }
	    return EmbedlyAPIKey;
	   }private set;
	  }
	    
	  
	public static Boolean isUIStackTraceEnabled{
	  get {
	    if(isUIStackTraceEnabled == null){
	    	isUIStackTraceEnabled = false;
	     if(appConfig != null){
	      isUIStackTraceEnabled = appConfig.EH_UI_Stack_Trace_Enabled__c;
	     }
	    }
	    return isUIStackTraceEnabled;
	   }private set;
	  }
	
	public static Boolean isDebugEnabled{
	  get {
	    if(isDebugEnabled == null){
			isDebugEnabled = false;
			if(appConfig != null){
	    		isDebugEnabled = appConfig.EH_Debug_Enabled__c && SimpplrContext.loggingLevel>0;
				if(Test.isRunningTest()){
					isDebugEnabled = true;
				}
			}
	    }
	    return isDebugEnabled;
	   }private set;
	  }
	 public static Boolean isJSDebugEnabled{
	  get {
	    if(isJSDebugEnabled == null){
	    	isJSDebugEnabled = false;
	     if(appConfig != null){
	      isJSDebugEnabled = SimpplrContext.loggingLevel>0 && appConfig.EH_JS_Debug_Enabled__c;
	     } else {
	     	isJSDebugEnabled = true;
	     }
	    }
	    return isJSDebugEnabled;
	   }private set;
	  } 
	  
	  
	public static Boolean isPeopleCategoryEnable{
		get {
		    if(isPeopleCategoryEnable == null){
		    	isPeopleCategoryEnable = false;
			     if(appConfig != null){
			     	isPeopleCategoryEnable = appConfig.People_Category_Enabled__c;
			     }
			     if(isPeopleCategoryEnable==null){
			     	isPeopleCategoryEnable = false;
			     }
		    }
	   		return isPeopleCategoryEnable;
		}private set;
	}
	public static String peopleCategorySingular{
		get {
		    if(peopleCategorySingular == null){
			     if(appConfig != null){
			     	peopleCategorySingular = appConfig.People_Catgeory_Singular__c;
			     }
		    }
	   		return peopleCategorySingular;
		}private set;
	}
	public static String peopleCategoryPlural{
		get {
		    if(peopleCategoryPlural == null){
			     if(appConfig != null){
			     	peopleCategoryPlural = appConfig.People_Catgeory_Plural__c;
			     }
		    }
	   		return peopleCategoryPlural;
		}private set;
	}
	public static Boolean isSMSEnabled{
		get {
		    if(isSMSEnabled == null){
			     if(appConfig != null){
					isSMSEnabled = appConfig.SMS_Enabled__c;
			     }
		    }
	   		return isSMSEnabled;
		}private set;
	}
	public static Integer simpplrDefaultPageSize{
	  get {
	    if(simpplrDefaultPageSize == null){
		     if(appConfig != null){
		      simpplrDefaultPageSize = appConfig.Default_Page_Size__c.intValue();
		     } else {
		    	simpplrDefaultPageSize = 16;
		     }
	    } 
	    return simpplrDefaultPageSize;
	   }private set;
	  }
	  
	  
	  
	  public static Integer simpplrFeedRefreshInterval{
	  get {
	    if(simpplrFeedRefreshInterval == null){
	     if(appConfig != null){
	      simpplrFeedRefreshInterval = appConfig.Feed_Refresh_Interval__c.intValue();
	     }
	    } else {
	    	simpplrFeedRefreshInterval = 120;
	    }
	    return simpplrFeedRefreshInterval;
	   }private set;
	  }
	  
	  public static Boolean isFeedRichTextEnabled{
    	get{
	    	if(isFeedRichTextEnabled == null){
	    		isFeedRichTextEnabled = false;
	    		if(appConfig != null){
	    			isFeedRichTextEnabled = appConfig.Feed_Rich_Text_Enabled__c;
	    		}
	    	}
	    	return isFeedRichTextEnabled;
    	}private set;
	  }
	  @TestVisible
	  public static Boolean isEmployeeAdvocacyEnabled{
    	get{
	    	if(isEmployeeAdvocacyEnabled == null){
	    		isEmployeeAdvocacyEnabled = false;
	    		if(appConfig != null && isFeatureEnabled('Employee_Advocacy')){
	    			isEmployeeAdvocacyEnabled = appConfig.Employee_Advocacy_Enabled__c;
	    		}
	    	}
	    	return isEmployeeAdvocacyEnabled;
    	}private set;
	  }
	  @TestVisible
	  public static Boolean isExternalSearchEnabled{
    	get{
	    	if(isExternalSearchEnabled == null){
	    		isExternalSearchEnabled = false;
	    		if(appConfig != null){
	    			isExternalSearchEnabled = appConfig.External_Search_Enabled__c;
	    		}
	    	}
	    	return isExternalSearchEnabled;
    	}private set;
	  }

	  public static Boolean isFlowExternalSearchEnabled{
    	get{
	    	if(isFlowExternalSearchEnabled == null){
	    		isFlowExternalSearchEnabled = false;
	    		if(appConfig != null){
	    			isFlowExternalSearchEnabled = appConfig.Flow_External_Search_Enabled__c;
	    		}
	    	}
	    	return isFlowExternalSearchEnabled;
    	}private set;
	  }

	public static Boolean isExternalSearchActiveEnabled{
		get{
			if(isExternalSearchActiveEnabled == null){
				isExternalSearchActiveEnabled = false;
				if(appConfig != null){
					isExternalSearchActiveEnabled = appConfig.External_Search_Active__c;
				}
			}
			return isExternalSearchActiveEnabled;
		}private set;
	}

	  @TestVisible
	  public static Boolean isEnterpriseSearchEnabled{
    	get{
	    	if(isEnterpriseSearchEnabled == null){
	    		isEnterpriseSearchEnabled = false;
	    		if(appConfig != null){
	    			isEnterpriseSearchEnabled = appConfig.Enterprise_Search_Enabled__c;
	    		}
	    	}
	    	return isEnterpriseSearchEnabled;
    	}private set;
	  }

	  @TestVisible
	  public static String enterpriseSearchProvider{
    	get{
	    	if(enterpriseSearchProvider == null){
	    		if(appConfig != null){
	    			enterpriseSearchProvider = appConfig.Enterprise_Search_Provider__c;
	    		}
	    	}
	    	return enterpriseSearchProvider;
    	}private set;
	  }

	  @TestVisible
	  public static String enterpriseSearchUrl{
    	get{
	    	if(enterpriseSearchUrl == null){
	    		if(appConfig != null){
	    			enterpriseSearchUrl = appConfig.Enterprise_Search_Url__c;
	    		}
	    	}
	    	return enterpriseSearchUrl;
    	}private set;
	  }
	  
	  public static String getAWSAccessToken{
		get {
		    if(getAWSAccessToken == null){
			     if(appConfig != null){
			     	getAWSAccessToken = appConfig.AWS_Access_Token__c;
			     }
		    }
	   		return getAWSAccessToken;
		}private set;
	  }
	  
	 public static Boolean isExternalAnalyticsEnabled{
    	get{
	    	return true;
    	}private set;
	  }
	  @TestVisible
	  public static Boolean isNativeVideo{
    	get{
	    	if(isNativeVideo == null){
	    		isNativeVideo = false;
	    		if(Integrations != null){
	    			isNativeVideo = isFeatureEnabled('Native_Video') && Integrations.containskey(ServiceConstants.VIDEO_PROVIDER_NATIVE);
	    		}
	    	}
	    	return isNativeVideo;
    	}private set;
	  }
	  
	 public static String getExternalSearchBaseUrl{
		get {
		    if(getExternalSearchBaseUrl == null){
			     if(appConfig != null){
			     	getExternalSearchBaseUrl = appConfig.External_Search_Base_URL__c;
			     }
		    }
	   		return getExternalSearchBaseUrl;
		}private set;
	 }

	 @TestVisible
	  public static Boolean isExternalSearchAppConnected{
    	get{
	    	if(isExternalSearchAppConnected == null){
	    		isExternalSearchAppConnected = false;
	    		if(appConfig != null){
	    			isExternalSearchAppConnected = appConfig.External_search_app_connected__c;
	    		}
	    	}
	    	return isExternalSearchAppConnected;
    	}private set;
      }
	  
	  public static Set<String> connectedStorages {
	  	get{
		  	if(connectedStorages == null){
		  		connectedStorages = new Set<String>();
		  		if(integrations !=null && !integrations.isEmpty()){
			  		for(String name : integrations.keySet()){
			  			if((name.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING) || 
			  				name.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING) ||
			  				name.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING) ||
			  				name.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING) 
			  				) &&
			  				(integrations.get(name).Integration_Enabled__c && integrations.get(name).Connected__c)){
			  				connectedStorages.add(name);
			  			}
			  		}
		  		}
		  	}
		  	return connectedStorages;
	  	}private set;
	  }

    /**
    * @author Ashish Chaudhary
    * @date 28/09/2021
    * @description This property tells is sharepoint is connect or not using App_Integration__c
    * @return Boolean true is user is connected to sharepoint
    */
    @TestVisible
    public static Boolean isSharepointConnected{
        get{
            if(isSharepointConnected == null){
                isSharepointConnected = false;
                if(Integrations!=null && Integrations.containsKey(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING) && Integrations.get(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING).Integration_Enabled__c && Integrations.get(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING).connected__c){
                    isSharepointConnected = true;
                }
            }
            return isSharepointConnected;
        } private set;
    }

    /**
    * @author Ashish Chaudhary
    * @date 28/09/2021
    * @description This property tells is sharepoint is upgraded or not using App_Config__c
    * @return Boolean true is user is sharepoint upgraded to multi instance
    */
    @TestVisible
    public static Boolean isSharepointUpgraded{
        get{
            if(isSharepointUpgraded == null){
                isSharepointUpgraded = false;
                if(appConfig != null && 
                    (appConfig.SP_Upgrade_Status__c == ServiceConstants.SP_UPGRADE_STATUS_NOT_REQUIRED || 
                    appConfig.SP_Upgrade_Status__c == ServiceConstants.SP_UPGRADE_STATUS_COMPLETED)) {
                    isSharepointUpgraded = true;
                }
            }
            return isSharepointUpgraded;
        } private set;
    }

	/**
    * @description This property tells is ai Content Moderation Enabled is enabled from manage app priviledges
    * @return Boolean
    */
    @TestVisible
    public static Boolean aiContentModerationEnabled{
        get{
            if(aiContentModerationEnabled == null){
                aiContentModerationEnabled = false;
                if(appConfig != null && appConfig.Content_Moderation_Enabled__c != null && appConfig.Content_Moderation_Enabled__c && SimpplrContext.aiContentModerationFeatureEnabled) {
                    aiContentModerationEnabled = true;
                }
            }
            return aiContentModerationEnabled;
        } private set;
    }

	/**
    * @description This property tells if Onboarding is Enabled from manage app priviledges
    * @return Boolean
    */
    @TestVisible
    public static Boolean isOnboardingEnabled{
        get{
            if(isOnboardingEnabled == null){
                isOnboardingEnabled = false;
                if(appConfig != null && appConfig.Is_Onboarding_Disabled__c != null && !appConfig.Is_Onboarding_Disabled__c) {
                    isOnboardingEnabled = true;
                }
            }
            return isOnboardingEnabled;
        } private set;
    }

	@TestVisible
    public static Boolean isOnboardingContentExist{
        get{
            if(isOnboardingContentExist == null){
                isOnboardingContentExist = false;
                if(appConfig != null && appConfig.Is_Onboarding_Content_Exist__c != null && appConfig.Is_Onboarding_Content_Exist__c) {
                    isOnboardingContentExist = true;
                }
            }
            return isOnboardingContentExist;
        } private set;
    }

	  @TestVisible
	  public static Boolean isGdriveConnected{
	  	get{
	  		if(isGdriveConnected == null){
	  			isGdriveConnected = false;
	  			if(integrations!=null && integrations.containsKey(ServiceConstants.STORAGE_TYPE_GDRIVE_STRING) && integrations.get(ServiceConstants.STORAGE_TYPE_GDRIVE_STRING).Integration_Enabled__c && integrations.get(ServiceConstants.STORAGE_TYPE_GDRIVE_STRING).connected__c){
	  				isGdriveConnected = true;
	  			}
	  		}
	  		return isGdriveConnected;
	  	}private set;
	  }

	  public static Boolean isServiceNowConnected{
	  	get{
	  		if(isServiceNowConnected == null){
	  			isServiceNowConnected = false;
	  			if(isFeatureEnabled('ServiceNow') && integrations!=null && integrations.containsKey(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) && integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Integration_Enabled__c && integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).connected__c){
	  				isServiceNowConnected = true;
	  			}
	  		}
	  		return isServiceNowConnected;
	  	}private set;
	  }

	  public static String serviceNowUserName{
	  	get{
	  		if(serviceNowUserName == null){
	  			serviceNowUserName = '';
	  			if(isFeatureEnabled('ServiceNow') && integrations!=null && integrations.containsKey(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) && integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Integration_Enabled__c && integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).connected__c){
	  				serviceNowUserName = integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).User_Name__c;
	  			}
	  		}
	  		return serviceNowUserName;
	  	}private set;
	  }
	  
	  public static Boolean isDropboxConnected{
	  	get{
	  		if(isDropboxConnected == null){
	  			isDropboxConnected = false;
	  			if(integrations!=null && integrations.containsKey(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING) && integrations.get(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING).Integration_Enabled__c && integrations.get(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING).connected__c){
	  				isDropboxConnected = true;
	  			}
	  		}
	  		return isDropboxConnected;
	  	}private set;
	  }
	  
	  public static Boolean isExternalSearchFileEnabled{
    	get{
	    	if(isExternalSearchFileEnabled == null){
	    		isExternalSearchFileEnabled = false;
	    		if(appConfig != null){
	    			isExternalSearchFileEnabled = appConfig.External_search_file_connected__c;
	    		}
	    	}
	    	return isExternalSearchFileEnabled;
    	}private set;
	  }
	  	
	  public static Integer simpplrFeedPageSize{
	  get {
	    if(simpplrFeedPageSize == null){
	     if(appConfig != null){
	      simpplrFeedPageSize = appConfig.Feed_Page_Size__c.intValue();
	     } else {
	     	simpplrFeedPageSize = 20;
	     }
	    }
	    return simpplrFeedPageSize;
	   }private set;
	  }
	  
	  
	  public static Integer simpplrNotificationRefreshInterval{
	  get {
	    if(simpplrNotificationRefreshInterval == null){
	     if(appConfig != null){
	      simpplrNotificationRefreshInterval = appConfig.Notification_Refresh_Interval__c.intValue();
	     }
	    } else {
	    	simpplrNotificationRefreshInterval = 60;
	    }
	    return simpplrNotificationRefreshInterval;
	   }private set;
	  }

	  /**
	   * @description - returns alert refresh interval
	   * @return - Integer
	   */
	  public static Integer simpplrAlertRefreshInterval{
		get {
		  if(simpplrAlertRefreshInterval == null){
		   if(appConfig != null && appConfig.Alert_Refresh_Interval__c != null) {
			simpplrAlertRefreshInterval = appConfig.Alert_Refresh_Interval__c.intValue();
		   } else {
			simpplrAlertRefreshInterval = ServiceConstants.ALERT_REFRESH_INTERVAL;
		  }
		  }
		  return simpplrAlertRefreshInterval;
		 } private set;
		}	  
	  
	public static String DataKey{
	  get {
	    if(DataKey == null){
	     if(appConfig != null){
	      DataKey = appConfig.Data_Key__c;
	     }
	    }
	    return DataKey;
	   }private set;
	  }
	@TestVisible public static Boolean isCommunitiesEnabled{ 
	  get {
	    if(isCommunitiesEnabled == null){
	    	isCommunitiesEnabled = false;
	     if(appConfig != null){
	      isCommunitiesEnabled = appConfig.Communities_Enabled__c;
	     } else {
	     	isCommunitiesEnabled = false;
	     }
	    }
	    return isCommunitiesEnabled;
	   }private set;
	  }
	@testVisible public static Boolean IsBoxIntegrationEnabled {
		get {
			if(IsBoxIntegrationEnabled == null) {
				IsBoxIntegrationEnabled = false;
				if(appConfig != null){
					if(appConfig.Box_Integration_Enabled__c == true && String.isNotBlank(appConfig.Box_User_Id__c)){
						IsBoxIntegrationEnabled = true;
					}
				}
			}
			return IsBoxIntegrationEnabled;
		}private set;
	}
	@testVisible public static String BoxUsername{
	  get {
	    if(BoxUsername == null){
	     if(appConfig != null){
	      BoxUsername = appConfig.Box_Username__c;
	     }
	    }
	    return BoxUsername;
	   }private set;
	  }

	public static String globalSearchProvider{
	  get {
	    if(globalSearchProvider == null){
	     if(appConfig != null){
	      globalSearchProvider = String.isBlank(appConfig.Global_Search_Provider__c) ? 'Elastic' : appConfig.Global_Search_Provider__c;
	     }
	    }
	    return globalSearchProvider;
	   }private set;
	  }

	public static String BoxUserId{
	  get {
	    if(BoxUserId == null){
	     if(appConfig != null){
	      BoxUserId = appConfig.Box_User_Id__c;
	     }
	    }
	    return BoxUserId;
	   }private set;
	  }
	public static String BoxRefreshToken{
	  get {
	    if(BoxRefreshToken == null){
	     if(appConfig != null){
	      BoxRefreshToken = appConfig.Box_Refresh_Token__c;
	     }
	    }
	    return BoxRefreshToken;
	   }private set;
	  }
	public static Datetime BoxRefreshTokenExpiresAt{
	  get {
	    if(BoxRefreshTokenExpiresAt == null){
	     if(appConfig != null){
	      BoxRefreshTokenExpiresAt = appConfig.Box_Refresh_Token_Expires_At__c;
	     }
	    }
	    return BoxRefreshTokenExpiresAt;
	   }private set;
	  }
	public static String BoxEnterpriseId{
	  get {
	    if(BoxEnterpriseId == null){
	     if(appConfig != null){
	      BoxEnterpriseId = appConfig.Box_Enterprise_Id__c;
	     }
	    }
	    return BoxEnterpriseId;
	   }private set;
	  }
	public static String BoxClientSecret{
	  get {
	    if(BoxClientSecret == null){
	     if(appConfig != null){
	      BoxClientSecret = appConfig.Box_Client_Secret__c;
	     }
	    }
	    return BoxClientSecret;
	   }private set;
	  }
	public static String BoxClientId{
	  get {
	    if(BoxClientId == null){
	     if(appConfig != null){
	      BoxClientId = appConfig.Box_Client_Id__c;
	     }
	    }
	    return BoxClientId;
	   }private set;
	  }
	public static String BoxAllCompanyGroupId{
	  get {
	    if(BoxAllCompanyGroupId == null){
	     if(appConfig != null){
	      BoxAllCompanyGroupId = appConfig.Box_All_Company_Group_Id__c;
	     }
	    }
	    return BoxAllCompanyGroupId;
	   }private set;
	  }
	  
	public static String BoxAccessToken{
	  get {
	    if(BoxAccessToken == null){
	     if(appConfig != null){
	      BoxAccessToken = appConfig.Box_Access_Token__c;
	     }
	    }
	    return BoxAccessToken;
	   }private set;
	  }
	public static Datetime BoxAccessTokenExpiresAt{
	  get {
	    if(BoxAccessTokenExpiresAt == null){
	     if(appConfig != null){
	      BoxAccessTokenExpiresAt = appConfig.Box_Access_Token_Expires_At__c;
	     }
	    }
	    return BoxAccessTokenExpiresAt;
	   }private set;
	  }

	/**
	* @description flag return Managed Permission of box - value can be(box/simpplr/null)
	*/
	@testVisible 
	public static String boxManagedPermission {
		get {
			if(boxManagedPermission == null) {
				if(appConfig != null) {
					boxManagedPermission = appConfig.Box_Managed_Permissions__c;
				}
			}
			return boxManagedPermission;
		} private set;
	}

	/**
	* @description flag return access Permission of box - value can be(true/false) true for showOpenInBox , false for donotOpenInBox
	*/
	@testVisible 
	public static Boolean showOpenInBox {
		get {
			if(showOpenInBox == null) {
				showOpenInBox = false;
				if(appConfig != null){
					if(appConfig.Box_Access_Permissions__c == true){
						showOpenInBox = true;
					}
				}
			}
			return showOpenInBox;
		}private set;
	}

	/**
	* @description give the datetime when box is connected at manage app screen
	*/
	public static Datetime boxConnectedAt{
		get {
			if(boxConnectedAt == null){
				if(appConfig != null){
					boxConnectedAt = appConfig.Box_Connected_DateTime__c;
				}
			}
			return boxConnectedAt;
		}private set;
	}

	public static String applicationName{
	  get {
	    if(applicationName == null){
	     if(appConfig != null){
	      applicationName = appConfig.App_Name__c;
	     }
	    }
	    return applicationName;
	   }private set;
	  }
	@TestVisible
	public static String AppDashboardMode{
	  get {
	    if(AppDashboardMode == null){
	     if(appConfig != null){
	      AppDashboardMode = appConfig.App_Dashboard_Mode__c;
	     }
	    }
		system.debug('??????>>>> SC >>>>AppDashboardMode>> 2211 ' + AppDashboardMode );
	    return AppDashboardMode;
	   } private set;
	  }
	public static String AllowedFeatures{ 
	  get {
	    if(AllowedFeatures == null){
	    	AllowedFeatures = '';
	     if(appConfig != null){
	      AllowedFeatures = String.isBlank(appConfig.Allowed_Features__c)?'':appConfig.Allowed_Features__c;
	     }
	    }
	    return AllowedFeatures;
	   }private set;
	  }
	  
	public static Boolean isPublicContributionAllowed{
	  get {
	    if(isPublicContributionAllowed == null){
	    	isPublicContributionAllowed = false;
	     if(appConfig != null){
	     	isPublicContributionAllowed = appConfig.Allow_Public_Contribution__c;
	     }
	    }
	    return isPublicContributionAllowed;
	   }private set;
	  }
	public static Boolean isFollowAllowed{
	  get {
	    if(isFollowAllowed == null){
	    	isFollowAllowed = false;
	     if(appConfig != null){
	      isFollowAllowed = appConfig.Allow_Follow__c;
	     }
	    }
	    return isFollowAllowed;
	   }private set;
	  }
	public static Boolean isCommentsAllowed{
	  get {
	    if(isCommentsAllowed == null){
	    	isCommentsAllowed = false;
	     if(appConfig != null){
	      isCommentsAllowed = appConfig.Allow_Comments__c;
	     }
	    }
	    return isCommentsAllowed;
	   }private set;
	  }
	public static Boolean isATUserEnabled{
	  get {
	    if(isATUserEnabled == null){
	    	isATUserEnabled = true;
	     if(appConfig != null){
	      isATUserEnabled = appConfig.AT_User_Enabled__c;
	     }
	    }
	    return isATUserEnabled;
	   }private set;
	  }
	  
	public static String ATUserTriggerType{
	  get {
	    if(ATUserTriggerType == null){
	     if(appConfig != null){
	      ATUserTriggerType = appConfig.AT_User_Trigger_Type__c;
	     }
	    }
	    return ATUserTriggerType;
	   }private set;
	  }  
	  
	public static Boolean isATSimpplrSiteEnabled{
	  get {
	    if(isATSimpplrSiteEnabled == null){
	    	isATSimpplrSiteEnabled = true;
	     if(appConfig != null){
	      isATSimpplrSiteEnabled = appConfig.AT_Simpplr_Site_Enabled__c;
	     }
	    }
	    return isATSimpplrSiteEnabled;
	   }private set;
	  }
	public static Boolean isATPeopleEnabled{
	  get {
	    if(isATSimpplrSiteEnabled == null){
	    	isATPeopleEnabled = true;
	     if(appConfig != null){
	      isATSimpplrSiteEnabled = appConfig.AT_People_Enabled__c || (appConfig.AT_People_Enabled__c == null);
	     }
	    }
	    return isATSimpplrSiteEnabled;
	   }private set;
	  }
	public static Boolean isATSimpplrContentEnabled{
	  get {
	    if(isATSimpplrContentEnabled == null){
	    	isATSimpplrContentEnabled = true;
	     if(appConfig != null){
	      isATSimpplrContentEnabled = appConfig.AT_Simpplr_Content_Enabled__c;
	     }
	    }
	    return isATSimpplrContentEnabled;
	   }private set;
	  }

	public static Boolean isATFeedItemEnabled{
	  get {
	    if(isATFeedItemEnabled == null){
	    	isATFeedItemEnabled = true;
	     if(appConfig != null){
	      isATFeedItemEnabled = appConfig.AT_Feed_ItemEnabled__c;
	     }
	    }
	    return isATFeedItemEnabled;
	   }private set;
	  }
	  
	  public static Boolean isGoToSalesforceEnabled{get {
	    if(isGoToSalesforceEnabled == null){
	    	isGoToSalesforceEnabled = false;
	     if(appConfig != null){
	      isGoToSalesforceEnabled = appConfig.Go_To_Salesforce_Enabled__c;
	     }
	    }
	    return isGoToSalesforceEnabled;
	   }private set;
	  }
	  
	  public static Boolean isOrgChartEnabled{get {
	  	if (isOrgChartEnabled == null) {
	    	isOrgChartEnabled = false; 
	    	
	     	if (appConfig != null && isFeatureEnabled('Org_Chart')) {
	      		isOrgChartEnabled = appConfig.Org_Chart_Enabled__c;
	     	}
	     	
	    }
	    
	    return isOrgChartEnabled;
	   }private set;
	  }
	  
	public static Boolean isATFeedCommentEnabled{
	  get {
	    if(isATFeedCommentEnabled == null){
	    	isATFeedCommentEnabled = true;
	     if(appConfig != null){
	      isATFeedCommentEnabled = appConfig.AT_FeedComment_Enabled__c;
	     }
	    }
	    return isATFeedCommentEnabled;
	   }private set;
	  }
	public static Boolean isATContentVersionEnabled{
	  get {
	    if(isATContentVersionEnabled == null){
	    	isATContentVersionEnabled = true;
	     if(appConfig != null){
	      isATContentVersionEnabled = appConfig.AT_ContentVersion_Enabled__c;
	     }
	    }
	    return isATContentVersionEnabled;
	   }private set;
	  }
	  
	public static Boolean isATContentDocumentEnabled{
	  get {
	    if(isATContentDocumentEnabled == null){
	    	isATContentDocumentEnabled = true;
	     if(appConfig != null){
	      isATContentDocumentEnabled = appConfig.AT_ContentDocument_Enabled__c;
	     }
	    }
	    return isATContentDocumentEnabled;
	   }private set;
	  }
	
	public static Boolean isATContentDocumentLinkEnabled{
	  get {
	    if(isATContentDocumentLinkEnabled == null){
	    	isATContentDocumentLinkEnabled = true;
	     if(appConfig != null){
	      isATContentDocumentLinkEnabled = appConfig.AT_ContentDocumentLink_Enabled__c;
	     }
	    }
	    return isATContentDocumentLinkEnabled;
	   }private set;
	  }
	    
	public static Boolean isATCollaborationGroupEnabled{
	  get {
	    if(isATCollaborationGroupEnabled == null){
	    	isATCollaborationGroupEnabled = true;
	     if(appConfig != null){
	      isATCollaborationGroupEnabled = appConfig.AT_CollaborationGroup_Enabled__c;
	     }
	    }
	    return isATCollaborationGroupEnabled;
	   }private set;
	}
	public static Boolean isATCollaborationGroupMemberEnabled{
	  get {
	    if(isATCollaborationGroupMemberEnabled == null){
	    	isATCollaborationGroupMemberEnabled = true;
	     if(appConfig != null){
	      isATCollaborationGroupMemberEnabled = appConfig.AT_CollaborationGroupMember_Enabled__c;
	     }
	    }
	    return isATCollaborationGroupMemberEnabled;
	  }private set;
	}
	
	
    public static String feedbackToEmails{
	  get {
	    if(feedbackToEmails == null){
	     if(appConfig != null){
	      feedbackToEmails = appConfig.Feedback_To_Emails__c;
	     }
	    }
	    return feedbackToEmails;
	  }private set;
	}
	
	public static String packageVersion{
	  get {
	    if(packageVersion == null){
	     if(appConfig != null){
	      packageVersion = appConfig.Package_Version__c;
	     }
	    }
	    return packageVersion;
	  }private set;
	}
	
	public static Integer loginTimeout{
		get {
			if(loginTimeout == null) {
				if(appConfig != null && appConfig.Login_Timeout__c !=null) {
					loginTimeout = appConfig.Login_Timeout__c.intValue();
					
				}
			}
			return loginTimeout;
		}private set;
	}
	
    public static Boolean feedbackShareWithSimpplr{
	  get {
	    if(feedbackShareWithSimpplr == null){
	    	feedbackShareWithSimpplr = true;
	     if(appConfig != null){
	      feedbackShareWithSimpplr = appConfig.Feedback_Share_with_Simpplr__c;
	     }
	    }
	    return feedbackShareWithSimpplr;
	  }private set;
	}
    
    public static Organization simpplrOrg{get{
    	if(simpplrOrg == null){
    		simpplrOrg = [SELECT Id, InstanceName, IsSandbox, Name
                					FROM Organization LIMIT 1];
    	}
    	return simpplrOrg;
    }private set;}

	public static string simpplrOrgId {get{
    	if(simpplrOrgId == null){
    		simpplrOrgId = simpplrOrg.Id;
    	}
    	return simpplrOrgId;
    }private set;}   
    
    public static Boolean isSandbox{get{
    	if(isSandbox == null){
    		isSandbox = simpplrOrg.isSandbox;
    	}
    	return isSandbox;
    }private set;}

	public static Boolean isTestOrg{get{
    	if(isTestOrg == null){
			isTestOrg = false;
			if(appConfig != null) {
    			isTestOrg = appConfig.is_test__c;
			}
    	}
    	return isTestOrg;
    }private set;}

    public static String instance {
        public get {
            if (instance == null) {
                instance = simpplrOrg.InstanceName;    
                instance = instance.toLowerCase();      					
            } 
            return instance;
        } private set; 
	}

	public static String salesforceHost{
		get{
			return 'https://' + instance + '.salesforce.com';
		}private set;
	}

	public static String salesforceBaseUrl { 
		get {
			if(salesforceBaseUrl == null){
				salesforceBaseUrl = Url.getSalesforceBaseUrl().toExternalForm(); 
			}
			return salesforceBaseUrl;
		}private set;
	}

	public static String salesforceOrgDomainUrl { 
		get {
			if(salesforceOrgDomainUrl == null){
				salesforceOrgDomainUrl = Url.getOrgDomainUrl().toExternalForm(); 
			}
			return salesforceOrgDomainUrl;
		}private set;
	}
  
	public static Boolean isEnhancedDomainEnabled {
		get {
			if(isEnhancedDomainEnabled == null){
				isEnhancedDomainEnabled = SimpplrContext.salesforceBaseUrl.endsWith('.vf.force.com');
			}
			return isEnhancedDomainEnabled;
		}private set;
	}	

	public static String fileDownloadBaseURL { 
		get {
			if(fileDownloadBaseURL == null){
				fileDownloadBaseURL = 'https://' + DomainCreator.getContentHostname();
			}
			return fileDownloadBaseURL;
		}private set;
	}
	
	public static Datetime adoptionEmailNextRunDate{
		get {
			if(adoptionEmailNextRunDate == null){
	     		if(appConfig != null){
	      			adoptionEmailNextRunDate = appConfig.Adoption_Email_Next_Run_Date__c;
	     		}
    		}
	   return adoptionEmailNextRunDate;
	   }private set;
	}		
	
    public static App_Config__c appConfig { get { 

	    	if (appConfig==null && appConfigQueried == null) {
	    		appConfigQueried = true;
				List<App_Config__c> appConfigList = new List<App_Config__c>();
				String platformCacheAppConfigStr = 'Local.Cache.appConfig';
				system.debug('Local.Cache.appConfig' + platformCacheAppConfigStr);

				if (!String.isblank(namespacePrefix)) {
					platformCacheAppConfigStr = 'Simpplr.Cache.appConfig';
				}

				if (isPlatformCachingFeatureEnabled  && 
						Cache.Org.contains(platformCacheAppConfigStr)) {  
					appConfigList = (List<App_Config__c>)Cache.Org.get(platformCacheAppConfigStr);
					system.debug('>>>simpplrContext>>>>>appConfigList 2555' +  JSON.serializePretty(appConfigList[0]));


		
				}  else {
					String appConfigQuery = 'Select Allow_Site_Add__c,Show_Logo_On_Mobile__c,App_Home_Dashboard_Tile_Ids__c, Login_Timeout__c, Package_Version__c, Go_To_Salesforce_Enabled__c,Knowledge_Article_Detail_Field__c, Knowledge_Article_Type__c,'
							+ ' Knowledge_Article_Custom_Fields__c, SystemModstamp, Mobile_Promotion_Enabled__c, Mobile_App_Additional_Security_Enabled__c, Android_App_Link__c, Login_From_Generic_App_Allowed__c, '
							+ ' Start_Of_Week__c, Site_Dashboard_Mode__c, Simpplr_Setup_Complete__c, Maintenance_In_Progress__c, Maintenance_Batches_Pending_Count__c, Maintenance_Reason__c, Simpplr_Emails_Allowed__c, Simpplr_Top_Stories_Emails_Allowed__c, Search_People_Allowed_Field__c,'
							+ ' Search_Content_Allowed_Field__c, SSO_Provider__c, SSO_Custom_JSON__c, SED_Weekly_Digest_Size__c, SED_From_Email__c,'
							+ ' SED_Daily_Digest_Size__c, People_Catgeory_Singular__c, People_Catgeory_Plural__c, People_Category_Enabled__c,PP_JoiningDate_Display__c,'
							+ ' Package_Name__c, PP_User_Custom_Fields__c, PP_Timezone_Editable__c, PP_Timezone_Display__c, PP_Title_Editable__c, PP_Title_Display__c,'
							+ ' PP_Video_Display__c, PP_Video_Editable__c, PP_Video_Provider__c, PP_Language_Editable__c, PP_Language_Display__c,'
							+ ' PP_State_Editable__c,PP_State_Display__c,PP_Street_Display__c,PP_Street_Editable__c, PP_Phone_Editable__c, PP_Phone_Display__c, PP_MobilePhone_Editable__c,'
							+ ' PP_MobilePhone_Display__c, PP_Manager_Editable__c, PP_Manager_Display__c, PP_LastName_Editable__c, PP_LastName_Display__c, PP_Division_Display__c, PP_Division_Editable__c,'
							+ ' PP_FirstName_Editable__c, PP_FirstName_Display__c, PP_Extension_Editable__c, PP_Extension_Display__c, PP_Department_Editable__c, PP_Company_Name_Display__c, PP_Company_Name_Editable__c,'
							+ ' PP_Department_Display__c, PP_Country_Editable__c, PP_Country_Display__c, PP_City_Editable__c, PP_City_Display__c, PP_Category_Editable__c,'
							+ ' PP_Category_Display__c, PP_About_Me_Editable__c, PP_About_Me_Display__c, PDS_First_Pull_Sync_All_Fields__c, PDS_Workday_Username__c, PDS_Workday_Password__c, PDS_Workday_Endpoint__c,'
							+ ' PDS_Workday_Enabled__c, PDS_Title__c, PDS_Street__c, PDS_State__c, PDS_Source_Application__c, PDS_Role__c, PDS_Postal_Code__c, PDS_Phone__c,'
							+ ' PDS_Mobile_Phone__c, PDS_Middle_Name__c, PDS_Max_Sync_Attempts__c, PDS_Manager_Id__c, PDS_Last_Name__c, PDS_Joining_Date__c, PDS_First_Name__c,' 
							+ ' PDS_Fax__c, PDS_Extension__c, PDS_Enable_Formatting__c, PDS_Employee_Number__c, PDS_Email__c, PDS_Division__c, PDS_Department__c,'
							+ ' PDS_Country__c, PDS_Company_Name__c, PDS_Community_Nickname__c, PDS_City__c, PDS_Birth_Date__c, PDS_About_Me__c,'
							+ ' PDS_Joining_Date_Key__c, PDS_Birth_Date_Key__c, OneLogin_Link__c,'
							+ ' OneLogin_Enabled__c, OneLogin_Embedding_Token__c, OneLogin_API_Token__c, Okta_People_Name_Format__c, Okta_Link__c, Okta_Enabled__c,'
							+ ' Okta_API_Token__c, Notification_Refresh_Interval__c, Name, Logout_Custom_Page_URL__c, Logout_Custom_Page_Enabled__c,'
							+ ' Id, GoLive_Chatter_Email_Setup__c, NPS_Survey_Enabled__c,NPS_Survey_Days_To_End__c,'
							+ ' GA_Tracking_Code__c, GA_Tracking_Code4__c, GA_Enhanced_Link_Attribution__c, GA_Enabled__c,'  
							+ ' Enable_Google_Analytics4__c,Enable_Google_Analytics3__c, GA_Demography_Interests__c,'
							+ ' File_Storage_Source__c, File_Storage_Setting_Level__c, Feedback_To_Emails__c, Feedback_Share_with_Simpplr__c,'						
							+ ' Feed_Refresh_Interval__c, Feed_Rich_Text_Enabled__c, Feed_Page_Size__c, Feed_Placeholder__c,'
							+ ' Feed_Enabled__c, Feed_Mode__c, Favicons_Folder__c, Embedly_Enabled__c, Embedly_API_Key__c, EH_Auto_Flush_Enabled__c,'
							+ ' EH_UI_Stack_Trace_Enabled__c, EH_Debug_Enabled__c, EH_JS_Debug_Enabled__c, Default_Page_Size__c, Data_Key__c, CreatedDate,'
							+ ' CreatedById, Communities_Enabled__c, Chatter_Email_Off_Profiles__c, Carousel_Speed__c,External_Analytics_Enabled__c,'
							+ ' Branding_Logo__c, Branding_JSON__c, Branding_CSS__c, Branding_CSS_Class__c, Box_View_Api_Key__c, Box_Username__c, Box_User_Id__c,'
							+ ' Box_Refresh_Token__c, Box_Refresh_Token_Expires_At__c, Box_Integration_Enabled__c, Box_Enterprise_Id__c, Box_Client_Secret__c, External_Analytics_URL__c,'
							+ ' Box_Client_Id__c, Box_All_Company_Group_Id__c, Box_Access_Token__c, Box_Access_Token_Expires_At__c,'
							+ ' Carousel_Layout__c, App_Name__c, App_Download_Info_URL__c, App_Dashboard_Mode__c, App_Integrations_Enabled__c,'
							+ ' Allowed_Features__c, Allow_Public_Contribution__c, Allow_Follow__c, Allow_Comments__c, AT_User_Trigger_Type__c, AT_User_Enabled__c,'
							+ ' AT_Simpplr_Social_Analytics_Enabled__c, AT_Simpplr_Site_Enabled__c, AT_People_Enabled__c, AT_Simpplr_Content_Enabled__c, Microsoft_Teams_Integration_Enabled__c,'
							+ ' AT_Feed_ItemEnabled__c, AT_FeedComment_Enabled__c, AT_ContentVersion_Enabled__c, AT_ContentDocument_Enabled__c, AT_ContentDocumentLink_Enabled__c, AT_CollaborationGroup_Enabled__c,'
							+ ' AT_CollaborationGroupMember_Enabled__c, AT_Share_Enabled__c, AT_Like_Enabled__c, AT_Bookmark_Enabled__c, AT_Folder_Enabled__c,'
							+ ' AT_File_Enabled__c, Mobile_App_Bundle_ID_Android__c, Mobile_App_Bundle_ID_iOS__c, Mobile_App_Deeplinking_Enabled__c, Mobile_App_Deeplinking_Redirect_URL__c,External_search_app_connected__c,'
							+ ' Simpplr_Mobile_Notification_Allowed__c, Simpplr_Desktop_Notification_Allowed__c, Push_Notification_Service_URL__c, Mute_Content_Post_In_SiteFeed_Enabled__c,External_search_file_connected__c,'
							+ ' Layout__c, Analytics_Data_Collection_Enabled__c, PP_BirthDate_Editable__c, PP_BirthDate_Display__c, PP_JoiningDate_Editable__c,External_Search_Provider__c,'
							+ ' Feed_Show_Track_Change_Posts__c, Show_Hidden_Folders__c, Allow_Only_Influencers_To_Create_Blog__c, Audit_Trail_Enabled__c, Branding_Document_IDs_JSON__c,External_Search_Enabled__c,'
							+ ' Use_ConnectAPI_for_Feed_Update_Check__c, Is_Test__c, CDN_Enabled__c,CDN_Path__c, Allow_File_Upload_Site_Managers__c, '
							+ ' Calendar_App_Enabled__c, Calendar_Office365_Enabled__c, Calendar_Google_Enabled__c, Calendar_Outlook_Web_Enabled__c,Employee_Advocacy_Enabled__c, Content_History_Enabled__c,'
							+ ' Custom_Links_JSON__c,Org_Chart_Enabled__c, Lightning_UX_Tab_Open_Setting__c, Auto_Convert_ChatterGroup_To_Site__c, Vbrick_Enabled__c, Vbrick_Base_Url__c, Social_Tiles_Enabled__c,External_Search_Active__c,'
							+ ' Segment_Column_Name__c, Segment_Enabled__c, Segment_Apps_Links_Enabled__c, Segment_Branding_Enabled__c, AD_Integration_Enabled__c, AWS_Access_Token__c,Home_Carousel_Enabled__c, Site_Carousel_Enabled__c,'
							+ ' External_Search_Base_URL__c,Flow_External_Search_Enabled__c, Auto_provisioning_Process_Enabled__c, Allow_File_Upload__c, Expertise_Controlled_By__c, Expertise_Create_Controlled_By__c,'
							+ ' Allow_File_Share_With_Public_Link__c, Adoption_Email_Next_Run_Date__c, Social_Campaign_Policy_URL__c, Last_Major_Upgrade_DateTime__c, UUID__c, '
							+ ' App_Languages_Enabled__c, App_Default_Language__c, Auto_Free_Simpplr_License_Enabled__c, Content_Governance_Enabled__c, Validation_Period__c, Iframe_Security_Enable__c, Native_App_Enabled__c, '
							+ ' Enterprise_Search_Enabled__c, Enterprise_Search_Provider__c, Enterprise_Search_Url__c, Automated_Translation_Enabled__c, Demo_Analytics_Enabled__c, SMS_Enabled__c, PDS_User_Division_Key__c, Calendar_Office365_URL__c, '
							+ ' PDS_UKG_Pro_Enabled__c, PDS_UKG_Pro_Username__c, PDS_UKG_Pro_Password__c, PDS_UKG_Pro_Endpoint__c, PDS_UKG_Pro_API_Key__c, Branded_App_Distribution_Enabled__c, SP_Upgrade_Status__c, Alert_Refresh_Interval__c, '
							+ ' Box_Managed_Permissions__c, Box_Access_Permissions__c, Notification_Archival_Duration_In_Months__c, Allow_Leadercast__c, Site_Level_Onboarding__c, Box_Connected_DateTime__c, Content_Moderation_Enabled__c, Email_Open_Tracker_URL__c, '
							+ ' Question_Answer_Enabled__c, Flow_External_Sync_Enabled__c, HTML_tile_enabled__c, Is_Onboarding_Disabled__c, Is_Onboarding_Content_Exist__c, Carousel_Governance__c, Has_Initiatives__c, Global_Search_Provider__c, '
							+ ' Is_My_Teams_Analytics_Enabled__c, Is_My_Teams_Listener_Suite_Enabled__c, Google_Multi_Domain_Upgrade_Status__c, '
							+ ' debug_enabled_for_users__c, Debugging_Turn_Off_Time__c '
							+ ' From App_Config__c Limit 1';

					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					appConfigList = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
					//system.debug('>>>simpplrContext>>>>>appConfigList 2615' +  JSON.serializePretty(appConfigList[0]));

					
					if (isPlatformCachingFeatureEnabled) {
						Cache.Org.put(platformCacheAppConfigStr, appConfigList);
					}
					
				}	
						
                if(appConfigList != null && appConfigList.size() > 0){
                   appConfig = appConfigList.get(0);
                }
	    	}
	    	return appConfig;
         } private set;
	}

    /*** Flag to identify if a user can manage onboarding on all sites */
	public static Boolean allSiteOnboardingEnabled {
		get {
			if(allSiteOnboardingEnabled == null) {
                allSiteOnboardingEnabled = false;
				if(appConfig != null) {
					allSiteOnboardingEnabled = ServiceConstants.CONTENT_ONBOARDING_ALL_SITES.equals(appConfig.Site_Level_Onboarding__c) ? true : false;
				}
			}
			return allSiteOnboardingEnabled;
		} private set;
	}
	
    public static Boolean isGoogleCalendarEnabled {
		get {
			if(isGoogleCalendarEnabled == null){
				isGoogleCalendarEnabled = false;
				if(appConfig != null){
					isGoogleCalendarEnabled = appConfig.Calendar_Google_Enabled__c;
				}
			}
			return isGoogleCalendarEnabled;
		} set;
	}
	
	public static String pdsJoiningDateKey{
		get{
			if(String.isBlank(pdsJoiningDateKey)){
				if(appConfig != null){
					pdsJoiningDateKey = appConfig.PDS_Joining_Date_Key__c;
				}
			}
			return pdsJoiningDateKey;
		}private set;
	}

	public static String pdsBirthDateKey{
		get{
			if(String.isBlank(pdsBirthDateKey)){
				if(appConfig != null){
					pdsBirthDateKey = appConfig.PDS_Birth_Date_Key__c;
				}
			}
			return pdsBirthDateKey;
		}private set;
	}

	public static String pdsDivisionKey{
		get{
			if(String.isBlank(pdsDivisionKey)){
				if(appConfig != null){
					pdsDivisionKey = appConfig.PDS_User_Division_Key__c;
				}
			}
			return pdsDivisionKey;
		}private set;
	}

	@TestVisible public static String cdnPath{
		get {
			if(cdnPath == null){
				if(appConfig != null){
					cdnPath = appConfig.CDN_Path__c;
				}
			}
			return cdnPath;
		}private set;
	}

	public static Boolean mobilePromotionEnabled {
		get {
			if(mobilePromotionEnabled == null){
				mobilePromotionEnabled = false;
				if(appConfig != null){
					mobilePromotionEnabled = appConfig.Mobile_Promotion_Enabled__c;
				}
			}
			return mobilePromotionEnabled && SimpplrContext.nativeAppEnabled;
		} set;
	}

	public static Boolean brandedAppDistributionEnabled {
		get {
			if(brandedAppDistributionEnabled == null){
				brandedAppDistributionEnabled = false;
				if(appConfig != null){
					brandedAppDistributionEnabled = appConfig.Branded_App_Distribution_Enabled__c;
				}
			}
			return brandedAppDistributionEnabled;
		} set;
	}

	public static Boolean nativeAppEnabled {
		get {
			if(nativeAppEnabled == null){
				nativeAppEnabled = false;
				if(appConfig != null){
					nativeAppEnabled = appConfig.Native_App_Enabled__c;
				}
			}
			return nativeAppEnabled;
		} set;
	}	
	
	/**
	 * @description this tells whether login from generic app feature enabled or not
	 * @return Boolean
	 */
	public static Boolean loginFromGenericAppAllowed {
		get {
			if(loginFromGenericAppAllowed == null){
				loginFromGenericAppAllowed = true;
				if(appConfig != null){
					loginFromGenericAppAllowed = appConfig.Login_From_Generic_App_Allowed__c;
				}
			}
			return loginFromGenericAppAllowed;
		} set;
	}

	/**
	 * @description returns which option is selected for leadercast settings
	 * @return String
	 */
	public static String leadercastEnabledFor {
		get {
			if(String.isblank(leadercastEnabledFor)){
				leadercastEnabledFor = '';
				if(appConfig != null && appConfig.Allow_Leadercast__c != null) {
					leadercastEnabledFor = appConfig.Allow_Leadercast__c;
				}
			}
			return leadercastEnabledFor;	
		} private set;
	}

	/**
	 * @description returns Email Open Tracker URL
	 * @return String
	 */
	public static String emailOpenTrackerURL {
		get {
			if(String.isblank(emailOpenTrackerURL)){
				emailOpenTrackerURL = SimpplrContext.simpplrAPIEndpoint + '/ai/email-logo?td=';
			}
			return emailOpenTrackerURL;	
		} private set;
	}

	public static String androidAppLink {
		get {
			if(androidAppLink == null){
				if(appConfig != null){
					androidAppLink = appConfig.Android_App_Link__c;
				}
			}
			return androidAppLink;
		} set;
	}

	public static String contentValidationPeriod{
		get{
			if(isContentGovernanceEnabled && String.isBlank(contentValidationPeriod)){
				if(appConfig != null){
					contentValidationPeriod = appConfig.Validation_Period__c;
				}
			}
			return contentValidationPeriod;
		}private set;
	}
	public static Integer validationPeriodMonth {
		get{
			if(validationPeriodMonth == null){
				if(String.isNotBlank(contentValidationPeriod)){	
					validationPeriodMonth = Integer.valueOf(contentValidationPeriod.replace('P', '').replace('M', ''));
				}
			}
			return validationPeriodMonth;
		}private set;
	}

 @TestVisible	public static Boolean isContentGovernanceEnabled{
		get{
			if(isContentGovernanceEnabled == null){
				isContentGovernanceEnabled = false;
				if(appConfig != null){
					isContentGovernanceEnabled = appConfig.Content_Governance_Enabled__c && isFeatureEnabled('Content_Governance');
				}
			}
			return isContentGovernanceEnabled;
		}private set;
	}

	public static String mobileAppsEnabled {
		get{
			if(mobileAppsEnabled == null) {				
				Integer featureIntegerValue = getFeatureIntegerValue('Mobile_Apps_Enabled');
				if(featureIntegerValue == 0) {
					mobileAppsEnabled = 'none';
					
				} else if(featureIntegerValue == 1) {
					mobileAppsEnabled = 'branded';

				} else if(featureIntegerValue == null || featureIntegerValue == 2) {
					mobileAppsEnabled = 'native_only';

				} 								
			}
			return mobileAppsEnabled;

		}private set;
	}
    
    public static String segmentColumnName{
		get{
			if(String.isBlank(segmentColumnName)){
				if(appConfig != null){
					segmentColumnName = appConfig.Segment_Column_Name__c;
				}
			}
			return segmentColumnName;
		}private set;
    }
    
    public static String allowFileUpload{
		get{
			if(String.isBlank(allowFileUpload)){
				if(appConfig != null){
					allowFileUpload = appConfig.Allow_File_Upload__c;
				}
			}
			return allowFileUpload;
		}private set;
    }
    @testVisible
    public static String maintenanceReason{ 
		get{
			if(String.isBlank(maintenanceReason)){
				if(appConfig != null){
					maintenanceReason = appConfig.Maintenance_Reason__c;
				} else {
					maintenanceReason = 'initialSetup';
				}
			}
			return maintenanceReason;
		}private set;
    }
    
    public static String namespacePrefix {
    		get {
    			if(namespacePrefix == null) {
    				namespacePrefix = String.isNotBlank(SimpplrContext.packageName) ? (SimpplrContext.packageName + '__') : '';
    			}
    			return namespacePrefix;
    		}private set;
    }
    @TestVisible
    public static Boolean isSegmentsEnabled{
		get{
		    	if(isSegmentsEnabled == null) {
		    		isSegmentsEnabled = false;
		    		if(appConfig != null && isFeatureEnabled('Segments')) {
		    			isSegmentsEnabled = appConfig.Segment_Enabled__c;
		    		}
			}
		    	return isSegmentsEnabled;
		}private set;
    }

	  @TestVisible
    public static Boolean isIframeSecurityEnabled{
		get{
		    	if(isIframeSecurityEnabled == null) {
		    		isIframeSecurityEnabled = false;
		    		if(appConfig != null){
		    			isIframeSecurityEnabled = appConfig.Iframe_Security_Enable__c;
		    		}
			}
		    	return isIframeSecurityEnabled;
		}private set;
    }
    
   @TestVisible public static Boolean isSegmentBrandingEnabled{
		get{
		    	if(isSegmentBrandingEnabled == null) {
		    		isSegmentBrandingEnabled = false;
		    		if(appConfig != null && isSegmentsEnabled){
		    			isSegmentBrandingEnabled = appConfig.Segment_Branding_Enabled__c;
		    		}
			}
		    	return isSegmentBrandingEnabled;
		}private set;
    }    
   	
	@TestVisible public static Boolean isSegmentAppsNLinksEnabled{
		get{
			if(isSegmentAppsNLinksEnabled == null) {
				isSegmentAppsNLinksEnabled = false;
				if(appConfig != null && isSegmentsEnabled){
					isSegmentAppsNLinksEnabled = appConfig.Segment_Apps_Links_Enabled__c;
				}
			}
			return isSegmentAppsNLinksEnabled;
		}private set;
	}

    public static Boolean showHiddenFolders{
    	get{
	    	if(showHiddenFolders == null){
	    		if(appConfig != null){
	    			showHiddenFolders = appConfig.Show_Hidden_Folders__c;
	    		}
	    	}
	    	return showHiddenFolders;
    	}private set;
    }
    @TestVisible
    public static Boolean adIntegrationEnabled{
    	get{
	    	if(adIntegrationEnabled == null){
	    		if(appConfig != null){
	    			adIntegrationEnabled = appConfig.AD_Integration_Enabled__c;
	    		}
	    	}
	    	return adIntegrationEnabled;
    	}private set;
    }
    
    public static Boolean autoConvertChatterGroupToSite{
    	get{
	    	if(autoConvertChatterGroupToSite == null){
	    		autoConvertChatterGroupToSite = false;
	    		if(appConfig != null){
	    			autoConvertChatterGroupToSite = appConfig.Auto_Convert_ChatterGroup_To_Site__c;
	    		}
	    	}
	    	return autoConvertChatterGroupToSite;
    	}private set;
    }
    
    public static String appLightningSetting{
    		get{
    			if(appLightningSetting == null){
    				if(appConfig != null){
    					appLightningSetting = appConfig.Lightning_UX_Tab_Open_Setting__c;
    				}
    			}
    			return appLightningSetting;
    		}private set;
    }
    
    public static Boolean showTrackChangesFeedPosts{
    	get{
	    	if(showTrackChangesFeedPosts == null){
	    		if(appConfig != null){
	    			showTrackChangesFeedPosts = appConfig.Feed_Show_Track_Change_Posts__c;
	    		}
	    	}
	    	return showTrackChangesFeedPosts;
    	}private set;
    }
    
    public static String tileLayout{
    	get{
	    	if(tileLayout == null){
	    		if(appConfig != null){
	    			tileLayout = appConfig.Layout__c;
	    		}
	    	}
	    	return tileLayout;
    	}private set;
    }

		public static Set<String> appLanguageEnabledSet {
				get {
	    		if(appLanguageEnabledSet == null) {
	    			appLanguageEnabledSet = new Set<String>();
	    			if(appConfig != null && String.isNotBlank(appConfig.App_Languages_Enabled__c)){
	    				appLanguageEnabledSet = new Set<String>(appConfig.App_Languages_Enabled__c.split(';'));
	    			} else {
							appLanguageEnabledSet.add('en_US');
						}
	    		}
	    		return appLanguageEnabledSet;
	    	}
				private set;
		} 

		public static String appDefaultLanguage {
    	get{
	    	if(appDefaultLanguage == null){
	    		if(appConfig != null){
	    			appDefaultLanguage = appConfig.App_Default_Language__c;
	    		}
					if(appDefaultLanguage == null) {
						appDefaultLanguage = 'en_US';
					}
	    	}
	    	return appDefaultLanguage;
    	}private set;
    }
    
    public static Set<String> appIntegrationEnabledSet {
	    	get {
	    		if(appIntegrationEnabledSet == null) {
	    			appIntegrationEnabledSet = new Set<String>();
	    			if(appConfig != null && isEmployeeAdvocacyEnabled && String.isNotBlank(appConfig.App_Integrations_Enabled__c)){
	    				appIntegrationEnabledSet = new Set<String>(appConfig.App_Integrations_Enabled__c.split(';'));
	    			}
	    		}
	    		return appIntegrationEnabledSet;
	    	}private set;
    }
    public static List<String> KnowledgeArticleCustomFields {
    	get {
    		if(KnowledgeArticleCustomFields == null) {
    			KnowledgeArticleCustomFields = new List<String>();
				if(appConfig != null && String.isNotBlank(appConfig.Knowledge_Article_Custom_Fields__c)){
					KnowledgeArticleCustomFields = appConfig.Knowledge_Article_Custom_Fields__c.split(',');
				}
    		}
    		return KnowledgeArticleCustomFields;
    	}private set;
    }
    
    public static String KnowledgeArticleType{
    	get {
    		if(KnowledgeArticleType == null){
    			KnowledgeArticleType = '';
	    		if(appConfig != null){
	    			KnowledgeArticleType = appConfig.Knowledge_Article_Type__c;
	    		}
    		}
    		return KnowledgeArticleType;
    	}private set;
    }
    
    public static String KnowledgeArticleDetailField {
    	get {
    		if(KnowledgeArticleDetailField == null){
    			KnowledgeArticleDetailField = '';
	    		if(appConfig != null){
	    			KnowledgeArticleDetailField = appConfig.Knowledge_Article_Detail_Field__c;
	    		}
    		}
    		return KnowledgeArticleDetailField;
    	} private set;
    }
    
	public static String SlackClientId{
    	get{
	    	if(SlackClientId == null){
					if(Integrations != null && Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SLACK) != null ){
	    			SlackClientId = Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SLACK).Client_Id__c;
	    		}
	    	}
	    	return SlackClientId;
    	}private set;
	}
	
	public static String SlackClientSecret{
    	get{
	    	if(SlackClientSecret == null){
	    		if(Integrations != null && Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SLACK) != null){
	    			SlackClientSecret = Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SLACK).Client_Secret__c;
	    		}
	    	}
	    	return SlackClientSecret;
    	}private set;
	}

	@TestVisible
	public static Boolean slackIntegrationEnabled{
    	get{
	    	if(slackIntegrationEnabled == null){
					slackIntegrationEnabled = false;
	    		if(Integrations != null && Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SLACK)!=null ){
	    			slackIntegrationEnabled = Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SLACK).Integration_Enabled__c;
	    		}
	    	}
	    	return slackIntegrationEnabled;
    	}private set;
	}
	
	public static String serviceNowClientId{
    	get{
	    	if(serviceNowClientId == null){
					if(Integrations != null && Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) != null ){
	    			serviceNowClientId = Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Client_Id__c;
	    		}
	    	}
	    	return serviceNowClientId;
    	}private set;
	}	

	public static String simpplrIntegrationServiceEndpoint {
		get{
			if(simpplrIntegrationServiceEndpoint == null){
				if(isTestOrg) {
					simpplrIntegrationServiceEndpoint = 'https://staging.api.simpplr.com/api-proxy/simpplr-integration-service';									
				} else {
					simpplrIntegrationServiceEndpoint = 'https://api.simpplr.com/api-proxy/simpplr-integration-service';
				}
				
			}
		return simpplrIntegrationServiceEndpoint;	
		}private set;
	}

	public static String newsletterIntegrationServiceEndpoint {
		get{
			if(newsletterIntegrationServiceEndpoint == null) {
				if (String.isBlank(SimpplrContext.packageName)) {
					newsletterIntegrationServiceEndpoint = 'https://dev.newsletter.api.simpplr.com/';
					
				} else if(SimpplrContext.isTestOrg || SimpplrContext.isSandbox) {
					newsletterIntegrationServiceEndpoint = 'https://staging.newsletter.api.simpplr.com/';

				} else {
					newsletterIntegrationServiceEndpoint = 'https://newsletter.api.simpplr.com/';
				}
			}
			return newsletterIntegrationServiceEndpoint;
		}private set;	
	}
	
	public static String serviceNowClientSecret{
    	get{
	    	if(serviceNowClientSecret == null){
	    		if(Integrations != null && Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) != null){
	    			serviceNowClientSecret = Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Client_Secret__c;
	    		}
	    	}
	    	return serviceNowClientSecret;
    	}private set;
	}

	public static String serviceNowCustomKBName{
    	get{
	    	if(serviceNowCustomKBName == null){
				serviceNowCustomKBName = ''; // At Initial connection 
	    		if(Integrations != null && Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) != null){
	    			String dataJSON = Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Data__c;
					if(String.isNotBlank(dataJSON)){
						Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(dataJSON);
						serviceNowCustomKBName = dataMap.get('customKBName') != null? String.valueOf(dataMap.get('customKBName')) : '';
					}
	    		}
	    	}
	    	return serviceNowCustomKBName;
    	}private set;
	}

	public static String serviceNowCustomKnowledgebaseUrl{
    	get{
	    	if(serviceNowCustomKnowledgebaseUrl == null){
				serviceNowCustomKnowledgebaseUrl = ''; // At Initial connection 
	    		if(Integrations != null && Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) != null){
	    			String dataJSON = Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Data__c;
					if(String.isNotBlank(dataJSON)){
						Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(dataJSON);
						serviceNowCustomKnowledgebaseUrl = dataMap.get('customSNKnowledgebaseUrl') != null? String.valueOf(dataMap.get('customSNKnowledgebaseUrl')) : '';
					}
	    		}
	    	}
	    	return serviceNowCustomKnowledgebaseUrl;
    	}private set;
	}

	public static String customServiceNowTicketsUrl{
    	get{
	    	if(customServiceNowTicketsUrl == null){
				customServiceNowTicketsUrl = ''; // At Initial connection 
	    		if(Integrations != null && Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) != null){
	    			String dataJSON = Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Data__c;
					if(String.isNotBlank(dataJSON)){
						Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(dataJSON);
						customServiceNowTicketsUrl = dataMap.get('customServiceNowTicketsUrl') != null? String.valueOf(dataMap.get('customServiceNowTicketsUrl')) : '';
					}
	    		}
	    	}
	    	return customServiceNowTicketsUrl;
    	}private set;
	}

	public static String serviceNowCustomTicketingName{
    	get{
	    	if(serviceNowCustomTicketingName == null){
	    		serviceNowCustomTicketingName = ''; // At Initial connection 
				if(Integrations != null && Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) != null){
	    			String dataJSON = Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Data__c;
					if(String.isNotBlank(dataJSON)){
						Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(dataJSON);
						serviceNowCustomTicketingName = dataMap.get('CustomTicketingName') != null? String.valueOf(dataMap.get('CustomTicketingName')) : '';
					}
	    		}
	    	}
	    	return serviceNowCustomTicketingName;
    	}private set;
	}

	public static Boolean isServiceNowTicketEnabled{
    	get{
	    	if(isServiceNowTicketEnabled == null){
	    		isServiceNowTicketEnabled = true; // At Initial connection 
				if(Integrations != null && Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) != null){
	    			String dataJSON = Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Data__c;
					if(String.isNotBlank(dataJSON)){
						Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(dataJSON);
						isServiceNowTicketEnabled = dataMap.get('snTicketEnabled') != null ? 'true'.equalsIgnoreCase((String) dataMap.get('snTicketEnabled')) : true;
					}
	    		}
	    	}
	    	return isServiceNowTicketEnabled;
    	}private set;
	}

	public static Boolean isServiceNowKnowledgebaseEnabled{
    	get{
	    	if(isServiceNowKnowledgebaseEnabled == null){
				isServiceNowKnowledgebaseEnabled = true; // At Initial connection 
	    		if(Integrations != null && Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) != null){
	    			String dataJSON = Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Data__c;
					if(String.isNotBlank(dataJSON)){
						Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(dataJSON);
						isServiceNowKnowledgebaseEnabled = dataMap.get('snKnowledgebaseEnabled') != null ? 'true'.equalsIgnoreCase((String) dataMap.get('snKnowledgebaseEnabled')) : true;
					}
	    		}
	    	}
	    	return isServiceNowKnowledgebaseEnabled;
    	}private set;
	}

	public static Boolean isServiceNowTicketCreationEnabled{
    	get{
	    	if(isServiceNowTicketCreationEnabled == null){
				isServiceNowTicketCreationEnabled = true; //Initially Enabled
	    		if(Integrations != null && Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) != null){
	    			String dataJSON = Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Data__c;
					if(String.isNotBlank(dataJSON)){
						Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(dataJSON);
						isServiceNowTicketCreationEnabled = dataMap.get('snTicketCreationEnabled') != null ? 'true'.equalsIgnoreCase((String) dataMap.get('snTicketCreationEnabled')) : true;
					}
	    		}
	    	}
	    	return isServiceNowTicketCreationEnabled;
    	}private set;
	}

	@TestVisible
	public static Boolean serviceNowIntegrationEnabled{
    	get{
	    	if(serviceNowIntegrationEnabled == null){
					serviceNowIntegrationEnabled = false;
	    		if(Integrations != null && Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW)!=null ){
	    			serviceNowIntegrationEnabled = Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Integration_Enabled__c;
	    		}
	    	}
	    	return serviceNowIntegrationEnabled;
    	}private set;
	}

	@TestVisible
	public static String serviceNowInstanceUrl{
    	get{
	    	if(serviceNowInstanceUrl == null){
				if(Integrations != null && Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW)!=null ){
	    			serviceNowInstanceUrl = Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Endpoint_Url__c;
	    		}
	    	}
	    	return serviceNowInstanceUrl;
    	}private set;
	}

	@TestVisible
	public static String ServiceNowKnowledgeBasesJSON{
    	get{
	    	if(ServiceNowKnowledgeBasesJSON == null){
				if(Integrations != null && Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW)!=null ){
	    			ServiceNowKnowledgeBasesJSON = Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Extra_Url_Parameters__c;
	    		}
	    	}
	    	return ServiceNowKnowledgeBasesJSON;
    	}private set;
	}

	public static Boolean slackAppInstalled{
		get{
			if(slackAppInstalled == null){
				slackAppInstalled = false;
				if(Integrations!= null && integrations.get(IntegrationConstants.INTEGRATION_TYPE_SLACK) != null){
					slackAppInstalled = integrations.get(IntegrationConstants.INTEGRATION_TYPE_SLACK).App_Installed__c;
				}
			}
			return slackAppInstalled;
		}private set;
	}
	@TestVisible
	public static Boolean microsoftTeamsIntegrationEnabled{
    	get{
	    	if(microsoftTeamsIntegrationEnabled == null && isFeatureMicrosoftTeamsEnabled == true) {
				microsoftTeamsIntegrationEnabled = false;
	    		if (Integrations != null && Integrations.get(IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS)!=null ) {
	    			microsoftTeamsIntegrationEnabled = Integrations.get(IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS).Integration_Enabled__c;
                }
	    	} else if(microsoftTeamsIntegrationEnabled == null) {
				microsoftTeamsIntegrationEnabled = false;
	    		if(appConfig != null){
	    			microsoftTeamsIntegrationEnabled = appConfig.Microsoft_Teams_Integration_Enabled__c;
	    		}
	    	}
	    	return microsoftTeamsIntegrationEnabled;
    	}private set;
	}
	public static Boolean workdayIntegrationEnabled{
    	get{
	    	if(workdayIntegrationEnabled == null){
				workdayIntegrationEnabled = false;
	    		if(appConfig != null){
	    			workdayIntegrationEnabled = appConfig.PDS_Workday_Enabled__c;
	    		}
	    	}
	    	return workdayIntegrationEnabled;
    	}private set;
	}	
	
	public static Integer CarouselSpeed{ 
		get {
			if(CarouselSpeed == null){
				CarouselSpeed = 10000;
				if(appConfig != null){
					if(appConfig.Carousel_Speed__c != null && appConfig.Carousel_Speed__c != 0) {
						CarouselSpeed = appConfig.Carousel_Speed__c.intValue();
					}
				}
			} 
			return CarouselSpeed;
		}private set;
	}
	
	 public static String feedPlaceholder{
    	get{
	    	if(feedPlaceholder == null){
	    		if(appConfig != null){
	    			feedPlaceholder = appConfig.Feed_Placeholder__c;
	    		}
	    	}
	    	return feedPlaceholder;
    	}private set;
	}

	@TestVisible
	public static Boolean SimpplrMobileNotificationAllowed{
    	get{
	    	if(SimpplrMobileNotificationAllowed == null){
	    		SimpplrMobileNotificationAllowed = false;
	    		if(appConfig != null){
	    			SimpplrMobileNotificationAllowed = appConfig.Simpplr_Mobile_Notification_Allowed__c;
	    		}
	    	}
	    	return SimpplrMobileNotificationAllowed;
    	}private set;
	}
	public static Boolean SimpplrDesktopNotificationAllowed{
    	get{
	    	if(SimpplrDesktopNotificationAllowed == null){
	    		if(appConfig != null){
	    			SimpplrDesktopNotificationAllowed = appConfig.Simpplr_Desktop_Notification_Allowed__c;
	    		}
	    	}
	    	return SimpplrDesktopNotificationAllowed;
    	}private set;
	}
	
	@TestVisible public static Boolean isNPSSurveyEnabled{
		get{
			if(isNPSSurveyEnabled == null){
				isNPSSurveyEnabled = false;
				/*
				if(appConfig != null){
					isNPSSurveyEnabled = appConfig.NPS_Survey_Enabled__c;
				}
				*/
			}
			return isNPSSurveyEnabled;
		}private set;
	}
	public static Integer npsSurveyDaysToEnd{ 
		get{
			if(npsSurveyDaysToEnd == null){
				if(appConfig != null && appConfig.NPS_Survey_Days_To_End__c !=null){
					npsSurveyDaysToEnd = Integer.valueOf(appConfig.NPS_Survey_Days_To_End__c);
				}else {
					npsSurveyDaysToEnd = 45;
				}
			}
			return npsSurveyDaysToEnd;
		}private set;
	}
	public static Boolean isLaunchpadConfigured{
		get{
			if(isLaunchpadConfigured == null){
				isLaunchpadConfigured = false;
				if(String.isNotBlank(SSOProvider) && !'None'.equalsIgnoreCase(SSOProvider)) {
					isLaunchpadConfigured = true;
				} else {
					isLaunchpadConfigured = false;
				}
			}
			return isLaunchpadConfigured;
		}private set;
	}


	public static Boolean isMuteContentPostInSiteFeedEnabled{
		get{
			if(isMuteContentPostInSiteFeedEnabled == null) {
				isMuteContentPostInSiteFeedEnabled = false;
				if (appConfig != null) {
	    			isMuteContentPostInSiteFeedEnabled = appConfig.Mute_Content_Post_In_SiteFeed_Enabled__c;
	    		}
			}
			return isMuteContentPostInSiteFeedEnabled;
		}private set;
	}
    public static Map<String,Schema.SObjectType> globalDescribe{
    	get{ 	        
	        return null;
	    }private set;
	}
	@TestVisible
	public static Boolean isDemoAnalyticsEnabled{
		get{ 
			if(isDemoAnalyticsEnabled == null){
				isDemoAnalyticsEnabled = false;
	    			if (appConfig != null) {
	    				isDemoAnalyticsEnabled = appConfig.Demo_Analytics_Enabled__c;
	    			}
			}
			return isDemoAnalyticsEnabled;
		}private set;
	}

	@testVisible
	public static Boolean isAnalyticsDataCollectionEnabled{
		get{ 
			
			return true;
		}private set;
	}
    
	public static void voidIntegrationsMap(){
		SimpplrContext.Integrations = null;
	}

    public static Map<String, App_Integration__c> Integrations {
    	get {
    		if(Integrations == null) {
    			Integrations = new Map<String, App_Integration__c>();
				List<App_integration__c> appIntegList = new List<App_integration__c>();
				String platformCacheAppIntegStr = 'Local.Cache.appIntegrations';

				if (!String.isblank(namespacePrefix)) {
					platformCacheAppIntegStr = 'Simpplr.Cache.appIntegrations';
				}

				if (isPlatformCachingFeatureEnabled && Cache.Org.contains(platformCacheAppIntegStr) && !Test.isRunningTest()) { 
					appIntegList = (List<App_integration__c>)Cache.Org.get(platformCacheAppIntegStr);
		
				}  else {					
					String appIntQuery = 'SELECT Id, Name,'
							+ ' Scope__c, Scope_Required__c, User_Name__c, User_Email__c,'
							+ ' Extra_Url_Parameters__c, Client_Secret__c, Client_Id__c,'
							+ ' DB_User_Client_Id__c, DB_User_Client_Secret__c,'
							+ ' App_Access_Token__c, App_Refresh_Token__c, User_Principal_Name__c, '
							+ ' Token_Type__c, Redirect_Uri__c, App_Installed__c,'
							+ ' Access_Token_Requested_Datetime__c, Refresh_Token_Requested_Datetime__c,'
							+ ' Access_Token_Expiration_Datetime__c, Refresh_Token_Expiration_Datetime__c,'
							+ ' Access_Token_Expiry__c,  External_Id__c, Integration_Enabled__c, Connected__c,'
							+ ' Is_Deleted__c ,All_Company_Group_Id__c, Batch_Processing__c,'
							+ ' Root_Folder_Id__c, Enterprise_Id__c, Endpoint_Url__c, Data__c,'
							+ ' Is_My_Drive_Enabled__c, Simpplr_Managed_Permission__c,'
							+ ' Active_Directory_Groups_Enabled__c, Auto_Audience_creation__c, '
							+ ' Is_Shared_Drive_Enabled__c, Show_Open_In_Google_Drive__c,Show_Atlassian_VPN_Message__c,'
							+ ' Owner.UserName, Owner.IsActive, CreatedDate, Connected_DateTime__c, Whitelist_Domain__c, Alerts_For_App_Enabled__c, Is_Slack_Upgraded__c '
							+ ' FROM App_Integration__c'
							+ ' WHERE Is_Deleted__c = false'
							+ ' AND Org_Id__c = :soqlParam1';
					
					Map<String, Object> sqlParamMap = new Map<String, Object>();
					sqlParamMap.put('soqlParam1', simpplrOrgId);

					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					appIntegList = (List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, sqlParamMap);
					
					if (isplatformCachingFeatureEnabled && !appIntegList.isEmpty()) {
						Cache.Org.put(platformCacheAppIntegStr, appIntegList);
					}

				}

				for (App_Integration__c integObj : appIntegList) {
					Integrations.put(integObj.Name, integObj);					   			
				}
    		}
			return Integrations;
    	}private set;
    }

	// public static List<AppInitWrapper.PartnerIntegrations> partnerIntegrations {
	// 	get {
	// 		partnerIntegrations = new List<AppInitWrapper.PartnerIntegrations>();
	// 		if(SimpplrContext.Integrations != null) {
	// 			for(App_Integration__c obj : SimpplrContext.Integrations.values()){
	// 				if(obj.Partner_Integration_Name__c != null && IntegrationConstants.PARTNER_INTEGRATIONS.contains(obj.Partner_Integration_Name__c) && obj.Integration_Enabled__c && obj.Connected__c && !obj.Is_Deleted__c) {
	// 					AppInitWrapper.PartnerIntegrations partnerIntegration = new AppInitWrapper.PartnerIntegrations();
	// 					partnerIntegration.name = obj.Name;
	// 					partnerIntegration.label = obj.Custom_App_Name__c;
	// 					partnerIntegrations.add(partnerIntegration);
	// 				}
	// 			}
	// 		}
	// 		return partnerIntegrations;
	// 	}private set;
	// }

	/**
	 * @description this is used to get the flag to showing file in sharepoint
	 * @return Boolean flag is user is allowed to open file in sharepoint
	 */
	public static Boolean showOpenInSharePoint {
		get {
			if(showOpenInSharePoint == null){
				showOpenInSharePoint = true;
				if(Integrations!= null && integrations.get(IntegrationConstants.INTEGRATION_TYPE_SHAREPOINT) != null && String.isNotBlank(integrations.get(IntegrationConstants.INTEGRATION_TYPE_SHAREPOINT).Data__c)){
					Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(integrations.get(IntegrationConstants.INTEGRATION_TYPE_SHAREPOINT).Data__c);
					showOpenInSharePoint = requestDataMap.get('showOpenInSharePoint') != null ? Boolean.valueOf(requestDataMap.get('showOpenInSharePoint')) : false;
				}
			}
			return showOpenInSharePoint;
		} private set;
	}

    public static Boolean myDriveEnabled{
		get{
			if(myDriveEnabled == null){
				myDriveEnabled = false;
				if(Integrations!= null && integrations.get(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE) != null){
					myDriveEnabled = integrations.get(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE).Is_My_Drive_Enabled__c;
				}
			}
			return myDriveEnabled;
		}private set;
    }
    
	@TestVisible
    public static Boolean googleManagedPermission {
		get {

			if (googleManagedPermission == null){
				
				if(Integrations!= null && integrations.get(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE) != null){
					googleManagedPermission = !integrations.get(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE).Simpplr_Managed_Permission__c;
				}
			}
			return googleManagedPermission;
		}private set;
	}

	public static Boolean sharedDriveEnabled{
		get{
			if(sharedDriveEnabled == null){
				sharedDriveEnabled = false;
				if(Integrations!= null && integrations.get(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE) != null){
					sharedDriveEnabled = integrations.get(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE).Is_Shared_Drive_Enabled__c;
				}
			}
			return sharedDriveEnabled;
		}private set;
    }

	public static Boolean showOpenInGoogleDrive{
		get{
			if(showOpenInGoogleDrive == null){
				showOpenInGoogleDrive = false;
				if(Integrations!= null && integrations.get(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE) != null){
					showOpenInGoogleDrive = integrations.get(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE).Show_Open_In_Google_Drive__c;
				}
			}
			return showOpenInGoogleDrive;
		}private set;
    }
    
	public static Map<String,String> brandingDocNameToIdMap{  
		get {
	    	if(brandingDocNameToIdMap == null){
	    		if(appConfig != null) {
	    			if(String.isNotBlank(appConfig.Branding_Document_IDs_JSON__c)){
		      			brandingDocNameToIdMap = (Map<String,String>)JSON.deserialize(appConfig.Branding_Document_IDs_JSON__c, Map<String,String>.class);
	    			} else {
	    				PostInstallHelper helperObj = new PostInstallHelper();
	    				String brandingDocIdJson = helperObj.getBrandingDocIdJson(); 
	    				brandingDocNameToIdMap = (Map<String,String>)JSON.deserialize(brandingDocIdJson, Map<String,String>.class);
	    			}
	     		}
	    	}
	    	return brandingDocNameToIdMap;
	     }private set;
	}

	public static Boolean isContentHistoryEnabled{  
		get {
	    	if(isContentHistoryEnabled == null){
	    		isContentHistoryEnabled = false;
	    		if(appConfig != null){
	      			isContentHistoryEnabled = appConfig.Content_History_Enabled__c;
	     		}
	    	}
	    	return isContentHistoryEnabled;
	     }private set;
	}
	
	public static String customLinksJSON{  
		get {
	    	if(customLinksJSON == null){
	    		if(appConfig != null){
	      			customLinksJSON = appConfig.Custom_Links_JSON__c;
	     		}
	    	}
	    	return customLinksJSON;
	     }private set;
	}
	
	public static Boolean isExpertiseAppManagerControlled{
  		get {
    		if(isExpertiseAppManagerControlled == null){
    			isExpertiseAppManagerControlled = false;
     			if(appConfig != null){
      				isExpertiseAppManagerControlled = 'manager'.equalsIgnoreCase(appConfig.Expertise_Controlled_By__c)?
      						true : false;
     			}
    		}
    		return isExpertiseAppManagerControlled;
   		}private set;
	}
	  
	public static Boolean isExpertiseCreateAppManagerControlled{
		get {
		  if(isExpertiseCreateAppManagerControlled == null){
			isExpertiseCreateAppManagerControlled = false;
			   if(appConfig != null){
				isExpertiseCreateAppManagerControlled = 'manager'.equalsIgnoreCase(appConfig.Expertise_Create_Controlled_By__c)?
							true : false;
			   }
		  }
		  return isExpertiseCreateAppManagerControlled;
		 }private set;
	}

	@testVisible
	public static Boolean isFeatureEnabled(String feature) {
		Boolean isFeatureEnabled= 'Full_External_Search'.equalsIgnoreCase(feature) && !Test.isRunningTest() ? false : true;
		try {
			if(String.isNotBlank(packageName)) {
				isFeatureEnabled = System.FeatureManagement.checkPackageBooleanValue(namespacePrefix + feature);
			}
		} catch (Exception ex) {		
			isFeatureEnabled=true;
		}		
		return isFeatureEnabled;
	}
	
	@TestVisible
    public static Boolean isFeatureContentOnboardingEnabled {
		get {
			return true;
		}private set;
	}

	@TestVisible
    public static Boolean isFeatureMicrosoftTeamsEnabled {
		get {
			return true;
		}private set;
	}

	public static Boolean isKitaPSARChangesEnabled  {
		get {
			if(isKitaPSARChangesEnabled  == null){
				isKitaPSARChangesEnabled  = ('1' == futureFeaturesSet2Enabled.mid(7,1)  ? true : false);
			}
			return isKitaPSARChangesEnabled ;
		}private set;
	}
	
	
	@TestVisible
    public static Boolean isFeatureMicrosoftTeamsEnabledPhase2 {
		get {
			return true;
		}private set;
	}

	@TestVisible
    public static Boolean isSlackPhase2FeatureEnabled {
		get {
			if(isSlackPhase2FeatureEnabled == null) {
				isSlackPhase2FeatureEnabled = ('1' == futureFeaturesSet2Enabled.mid(2,1) ? true : false);
			}
			return isSlackPhase2FeatureEnabled;
		}private set;
	}
	
	@TestVisible
	public static Boolean isQuestionAnswerFeatureEnabled {
		get {
			return true;
		}private set;
	}
	
	@TestVisible
	public static Boolean questionChangesForKITA {
		get {
			return true;
		}private set;
	}
	
	public static Boolean isQuestionAnswerEnabled {
		get {
			isQuestionAnswerEnabled = false;
			if(appConfig != null) {
				isQuestionAnswerEnabled = isQuestionAnswerFeatureEnabled && appConfig.Question_Answer_Enabled__c;
			}
			return isQuestionAnswerEnabled;
		}private set;
	}

	@TestVisible
	public static Boolean isPageTemplateEnabled {
		get {
			if(isPageTemplateEnabled == null){
				isPageTemplateEnabled = ('1' == futureFeaturesEnabled.mid(2,1)  ? true : false);
			}
			return isPageTemplateEnabled;
		}private set;
	}

	@TestVisible
	public static Boolean isExternalDataSyncEnabled {
		get {
			if(isExternalDataSyncEnabled == null){
				isExternalDataSyncEnabled = ('1' == futureFeaturesSet2Enabled.mid(3,1) ? true : false);
			}
			return isExternalDataSyncEnabled;
		}private set;
	}

	@TestVisible
	public static Boolean isFlowExternalSyncEnabled{
		get{
			if(isFlowExternalSyncEnabled == null){
				isFlowExternalSyncEnabled = false;
				if(appConfig != null){
					isFlowExternalSyncEnabled = appConfig.Flow_External_Sync_Enabled__c;
				}
			}
			return isFlowExternalSyncEnabled;
		}private set;
	}
	public static Boolean isAdsiIntegrationEnabled {
		get {
			if(isAdsiIntegrationEnabled == null){
				isAdsiIntegrationEnabled = false;
				if(Integrations!= null && integrations.get(IntegrationConstants.INTEGRATION_TYPE_ADSI) != null){
					isAdsiIntegrationEnabled = integrations.get(IntegrationConstants.INTEGRATION_TYPE_ADSI).Connected__c;
				}
			}
			return isAdsiIntegrationEnabled;		
		}private set;
	}	

	@TestVisible
	public static Boolean isActiveDirectoryEnabled {
		get {
			if(isActiveDirectoryEnabled == null){
				isActiveDirectoryEnabled = false;
				if(Integrations!= null && integrations.get(IntegrationConstants.INTEGRATION_TYPE_ACTIVE_DIRECTORY) != null){
					isActiveDirectoryEnabled = integrations.get(IntegrationConstants.INTEGRATION_TYPE_ACTIVE_DIRECTORY).Connected__c;
				}
			}
			return isActiveDirectoryEnabled;		
		}private set;
	}

	@TestVisible
	public static Boolean isActiveDirectoryGroupsEnabled {
		get {
			if(isActiveDirectoryGroupsEnabled == null){
				isActiveDirectoryGroupsEnabled = false;
				if(Integrations!= null && integrations.get(IntegrationConstants.INTEGRATION_TYPE_ACTIVE_DIRECTORY) != null){
					isActiveDirectoryGroupsEnabled = integrations.get(IntegrationConstants.INTEGRATION_TYPE_ACTIVE_DIRECTORY).Active_Directory_Groups_Enabled__c;
				}
			}
			return isActiveDirectoryGroupsEnabled;		
		}private set;
	}
	
	@TestVisible
	public static Boolean autoCreateActiveDirectoryAudience {
		get {
			if(autoCreateActiveDirectoryAudience == null){
				autoCreateActiveDirectoryAudience = false;
				if(Integrations!= null && integrations.get(IntegrationConstants.INTEGRATION_TYPE_ACTIVE_DIRECTORY) != null){
					autoCreateActiveDirectoryAudience = integrations.get(IntegrationConstants.INTEGRATION_TYPE_ACTIVE_DIRECTORY).Auto_Audience_creation__C;
				}
			}
			return autoCreateActiveDirectoryAudience;		
		}private set;
	}	

	/**
	 * @description isJwtAuthEnabled - defines if Analytics Jwt Auth is enabled or not
	 * @return Boolean - if Analytics Jwt Auth is enabled or not
	 */
	public static Boolean isJwtAuthEnabled {
		get {
			if(isJwtAuthEnabled == null){
				isJwtAuthEnabled = true;
			}
			return isJwtAuthEnabled;
		}private set;
	}

	/**
	 * @description isSiteAndLaunchpadAnalyticsEnabled - defines if Site User Engagement and Launchpad Analytics enabled or not
	 * @return Boolean - if Site User Engagement and Launchpad Analytics is enabled or not
	 */
	public static Boolean isSiteAndLaunchpadAnalyticsEnabled {
		get {
			if(isSiteAndLaunchpadAnalyticsEnabled == null){
				isSiteAndLaunchpadAnalyticsEnabled = true;
			}
			return isSiteAndLaunchpadAnalyticsEnabled;
		}private set;
	}

	/**
	 * @description isAudienceCSVEnabled - if it is true UI will show CSV upload option inside Audience modal
	 * @return Boolean
	 */
	public static Boolean isAudienceCSVEnabled {
		get {
			return true;
		}private set;
	}

	public static Boolean isOutlookCalendarFeatureEnabled {
		get {
			return true;
		}private set;
	}

	public static Boolean isAdditional20FieldsFeatureEnabled {
		get {
			return true;
		}private set;
	}

	public static Boolean isInitiativesAndCampaignsEnabled {
		get {
			if(isInitiativesAndCampaignsEnabled == null){
				isInitiativesAndCampaignsEnabled = ('1' == futureFeaturesEnabled.mid(4,1)  ? true : false);
			}
			return isInitiativesAndCampaignsEnabled;
		}private set;
	}

	public static Integer getFeatureIntegerValue(String feature) {
		Integer featureIntegerValue;
		try {
			if(String.isNotBlank(packageName)) {
				featureIntegerValue = System.FeatureManagement.checkPackageIntegerValue(namespacePrefix + feature);
			}
		} catch (Exception ex) {
			featureIntegerValue = null;
		}
		return featureIntegerValue;
	}

	public static String serviceNowEndpoint {get;set;}
	
	public static String simpplrAPIEndpoint {
		get{
			if(simpplrAPIEndpoint == null) {
				if (String.isBlank(SimpplrContext.packageName)) {
					simpplrAPIEndpoint = 'https://development.api.simpplr.com';
					
				} else if(SimpplrContext.isTestOrg || SimpplrContext.isSandbox) {
					simpplrAPIEndpoint = 'https://staging.api.simpplr.com';

				} else {
					simpplrAPIEndpoint = 'https://api.simpplr.com';
				}
			}
			return simpplrAPIEndpoint;
		}private set;	
	}

//AWS-Linked
	// public static String linkedinServiceEndpoints {
	// 	get{
	// 		if(linkedinServiceEndpoints == null) {
	// 			if (String.isBlank(SimpplrContext.packageName)) {
	// 				linkedinServiceEndpoints = ServiceConstants.ZEUS_MICROSERVICE_DEV_URL.replace('zeus.','') ; //'https://api.dev.simpplr.xyz';
					
	// 			} else if(SimpplrContext.isTestOrg) {
	// 				linkedinServiceEndpoints = ServiceConstants.ZEUS_MICROSERVICE_TEST_URL; //'https://api.test.simpplr.xyz';
				
	// 			} else if(SimpplrContext.isSandbox) {
	// 				linkedinServiceEndpoints = ServiceConstants.ZEUS_MICROSERVICE_QA_URL;  //'https://api.qa.simpplr.xyz';

	// 			} else {
	// 				linkedinServiceEndpoints = ServiceConstants.ZEUS_MICROSERVICE_PROD_URL; //'https://api.app.simpplr.com';
	// 			}
	// 		}
	// 		return linkedinServiceEndpoints;
	// 	}private set;	
	// }
	//AWS-Linked

	public static String simpplrAPIEndpointMFE {
		get{
			if(simpplrAPIEndpointMFE == null) {
				if (String.isBlank(SimpplrContext.packageName)) {
					simpplrAPIEndpointMFE = ServiceConstants.Simpplr_MFE_DEV_URL;
					
				} else if(SimpplrContext.isTestOrg || SimpplrContext.isSandbox) {
					simpplrAPIEndpointMFE = ServiceConstants.Simpplr_MFE_QA_URL;
					
				} else {
					simpplrAPIEndpointMFE = ServiceConstants.Simpplr_MFE_PROD_URL;
				}
			}
			return simpplrAPIEndpointMFE;
		}private set;
	}
	
	public static String zeusMicroserviceUrl {
		get {
			if(zeusMicroserviceUrl == null) {
				if(String.isBlank(SimpplrContext.packageName)) {
					zeusMicroserviceUrl = ServiceConstants.ZEUS_MICROSERVICE_DEV_URL;
				} else if(SimpplrContext.isTestOrg || SimpplrContext.isSandbox) {
					zeusMicroserviceUrl = ServiceConstants.ZEUS_MICROSERVICE_QA_URL;
				} else {
					zeusMicroserviceUrl = ServiceConstants.ZEUS_MICROSERVICE_PROD_URL;
				}
			}
			return zeusMicroserviceUrl;
		}private set;
	}

	public static String zeusRedirectUrl {
		get {
			if(zeusRedirectUrl == null) {
				if(String.isBlank(SimpplrContext.packageName)) {
					zeusRedirectUrl = ServiceConstants.ZEUS_MICROSERVICE_DEV_URL.replace('api',simpplrOrgId);
				} else if(SimpplrContext.isTestOrg || SimpplrContext.isSandbox) {
					zeusRedirectUrl = ServiceConstants.ZEUS_MICROSERVICE_QA_URL.replace('api',simpplrOrgId);
				} else {
					zeusRedirectUrl = ServiceConstants.ZEUS_MICROSERVICE_PROD_URL.replace('api',simpplrOrgId);
				}
			}
			return zeusRedirectUrl;
		}private set;
	}
	public static String zeusClientId {
		get {
			if(zeusClientId == null) {
				if(String.isBlank(SimpplrContext.packageName)) {
					zeusClientId = IntegrationConstants.ZEUS_IDENTITY_CLIENT_ID_DEV;
				} else if(SimpplrContext.isTestOrg || SimpplrContext.isSandbox) {
					zeusClientId = IntegrationConstants.ZEUS_IDENTITY_CLIENT_ID_QA;
				} else {
					zeusClientId = IntegrationConstants.ZEUS_IDENTITY_CLIENT_ID_PROD;
				}
			}
			return zeusClientId;
		}private set;
	}
	public static String zeusClientSecret {
		get {
			if(zeusClientSecret == null) {
				if(String.isBlank(SimpplrContext.packageName)) {
					zeusClientSecret = IntegrationConstants.ZEUS_IDENTITY_CLIENT_SECRET_DEV;
				} else if(SimpplrContext.isTestOrg || SimpplrContext.isSandbox) {
					zeusClientSecret = IntegrationConstants.ZEUS_IDENTITY_CLIENT_SECRET_QA;
				} else {
					zeusClientSecret = IntegrationConstants.ZEUS_IDENTITY_CLIENT_SECRET_PROD;
				}
			}
			return zeusClientSecret;
		}private set;
	}

	public static String sisenseAnalyticsUrl {
		get {
			if(sisenseAnalyticsUrl == null) {
				if(String.isBlank(SimpplrContext.packageName)) {
					sisenseAnalyticsUrl = ServiceConstants.SISENSE_ANALYTICS_DEV_URL;
				} else if(SimpplrContext.isTestOrg || SimpplrContext.isSandbox) {
					sisenseAnalyticsUrl = ServiceConstants.SISENSE_ANALYTICS_QA_URL;
				} else {
					sisenseAnalyticsUrl = ServiceConstants.SISENSE_ANALYTICS_PROD_URL;
				}
			}
			return sisenseAnalyticsUrl;
		}private set;
	}

	public static String listenerSuiteURL {
		get{
			if(listenerSuiteURL == null) {
				if (String.isBlank(SimpplrContext.packageName)) {
					listenerSuiteURL = 'https://api.listenersuite-dev.simpplr.xyz';
					
				} else if(SimpplrContext.isTestOrg || SimpplrContext.isSandbox) {
					listenerSuiteURL = 'https://api.listenersuite-staging.simpplr.xyz';
				
				} else {
					listenerSuiteURL = 'https://api.listenersuite-production.simpplr.xyz';
				}
			}
			return listenerSuiteURL;
		}private set;	
	}

	public static String listenerSuiteAPIKey {
		get{
			if(listenerSuiteAPIKey == null) {
				if (String.isBlank(SimpplrContext.packageName)) {
					listenerSuiteAPIKey = 'HPqpVOBmvy6oTl5RbWIvl1E8Y202gLey69kAKEmG';
					
				} else if(SimpplrContext.isTestOrg || SimpplrContext.isSandbox) {
					listenerSuiteAPIKey = 'N9xyvIXvNC8hlr9YlEdE06H0HES6Scmm8x1Wg207';
				
				} else {
					listenerSuiteAPIKey = 'O3KpKvGeHEaEJvhSJReN6aPDbywvmC228tq5YXo7';
				}
			}
			return listenerSuiteAPIKey;
		}private set;	
	}

	public static String simpplrPageRedirectUrl {
		get{
			if(simpplrPageRedirectUrl == null) {
				if (String.isBlank(SimpplrContext.packageName)) {
					simpplrPageRedirectUrl = 'https://development.simpplr.link';
					
				} else if(SimpplrContext.isTestOrg || SimpplrContext.isSandbox) {
					simpplrPageRedirectUrl = 'https://staging.simpplr.link';

				} else {
					simpplrPageRedirectUrl = 'https://simpplr.link';
				}
			}
			return simpplrPageRedirectUrl;
		}private set;	
	}

	@TestVisible
	public static Boolean atlassianIntegrationEnabled{
    	get{
	    	if(atlassianIntegrationEnabled == null){
				atlassianIntegrationEnabled = false;
	    		if(Integrations != null && Integrations.get(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN)!=null ){
	    			atlassianIntegrationEnabled = Integrations.get(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN).Integration_Enabled__c;
	    		}
	    	}
	    	return atlassianIntegrationEnabled;
    	}private set;
	}

	public static Boolean isAtlassianConnected{
		get{
			if(isAtlassianConnected == null){
				isAtlassianConnected = false;
				if(integrations!=null && integrations.containsKey(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN) && integrations.get(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN).Integration_Enabled__c && integrations.get(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN).connected__c){
					isAtlassianConnected = true;
				}
			}
			return isAtlassianConnected;
		}private set;
	}

	public static String atlassianClientId{
    	get{
	    	if(atlassianClientId == null){
					if(Integrations != null && Integrations.get(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN) != null ){
						atlassianClientId = Integrations.get(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN).Client_Id__c;
	    		}
	    	}
	    	return atlassianClientId;
    	}private set;
	}

	public static String atlassianClientSecret{
    	get{
	    	if(atlassianClientSecret == null){
					if(Integrations != null && Integrations.get(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN) != null ){
						atlassianClientSecret = Integrations.get(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN).Client_Secret__c;
	    		}
	    	}
	    	return atlassianClientSecret;
    	}private set;
	}

	public static String atlassianUserEmail{
		get{
			if(atlassianUserEmail == null){
				atlassianUserEmail = '';
				if(integrations!=null && integrations.containsKey(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN) && integrations.get(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN).Integration_Enabled__c && integrations.get(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN).connected__c){
					atlassianUserEmail = integrations.get(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN).User_Email__c;
				}
			}
			return atlassianUserEmail;
		}private set;
	}

	@TestVisible
	public static String atlassianInstanceUrl{
    	get{
	    	if(atlassianInstanceUrl == null){
				if(Integrations != null && Integrations.get(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN)!=null ){
	    			atlassianInstanceUrl = Integrations.get(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN).Endpoint_Url__c;
	    		}
	    	}
	    	return atlassianInstanceUrl;
    	}private set;
	}

	public static Boolean confluenceEnabled{
    	get{
	    	if(confluenceEnabled == null){
				confluenceEnabled = Integrations!=null && Integrations.containsKey(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN) && Integrations.get(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN).Integration_Enabled__c && Integrations.get(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN).connected__c;
			}
	    	return confluenceEnabled;
    	}private set;
	}

	public static Boolean confluenceKnowledgeSpacesSelected{
    	get{
	    	if(confluenceKnowledgeSpacesSelected == null){
				confluenceKnowledgeSpacesSelected = true;
				if(confluenceEnabled) {				
	    			String dataJSON = Integrations.get(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN).Data__c;
					if(String.isNotBlank(dataJSON)){
						Map<String, Object> dataMap = (Map<String, Object>)JSON.deserializeUntyped(dataJSON);
						
						confluenceKnowledgeSpacesSelected = Boolean.valueOf((String) dataMap.get('confluenceSpaceDefault'));
					}
				}	
	    	}
	    	return confluenceKnowledgeSpacesSelected;
    	}private set;
	}

	public static String confluenceCustomKBName{
    	get{
	    	if(confluenceCustomKBName == null){
	    		if(confluenceEnabled){
	    			String dataJSON = Integrations.get(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN).Data__c;
					if(String.isNotBlank(dataJSON)){
						Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(dataJSON);
						confluenceCustomKBName = dataMap.get('customKBName') != null  ? String.valueOf(dataMap.get('customKBName')) : '';
					}
	    		}
	    	}
	    	return confluenceCustomKBName;
    	}private set;
	}

	@TestVisible
	public static String confluenceKnowledgeBasesJSON{
    	get{
	    	if(confluenceKnowledgeBasesJSON == null){
				if(Integrations != null && Integrations.get(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN)!=null){
					String dataJSON = Integrations.get(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN).Data__c;
					if(String.isNotBlank(dataJSON)){
						Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(dataJSON);
						confluenceKnowledgeBasesJSON = dataMap.get('confluenceKBWrapperList') != null  ? String.valueOf(dataMap.get('confluenceKBWrapperList')) : '';
					}
	    			
	    		}
	    	}
	    	return confluenceKnowledgeBasesJSON;
    	}private set;
	}

	public static Boolean showAtlassianVPNMessage{
		get{
			if(showAtlassianVPNMessage == null){
				showAtlassianVPNMessage = false;
				if(integrations!=null && integrations.containsKey(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN) && integrations.get(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN).Show_Atlassian_VPN_Message__c){
					showAtlassianVPNMessage = true;
				}
			}
			return showAtlassianVPNMessage;
		}private set;
	}

	public static Boolean ukgProIntegrationEnabled{
    	get{
	    	if(ukgProIntegrationEnabled == null){
				ukgProIntegrationEnabled = false;
	    		if(appConfig != null){
	    			ukgProIntegrationEnabled = appConfig.PDS_UKG_Pro_Enabled__c;
	    		}
	    	}
	    	return ukgProIntegrationEnabled;
    	}private set;
	}

	public static App_Feature__c appFeature { get { 
		if(appFeature==null && appFeature == null) {
			appFeatureQueried = true;
			String appFeatureQuery = 'Select AI_Topic_Suggestion_Enabled__c, AI_Related_Content_Enabled__c, Newsletter_V2_Enabled__c From App_Feature__c';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<App_Feature__c> appFeatureList = (List<App_Feature__c>)SIMPESAPI.accessController().queryAsUser(appFeatureQuery, null);						
			if(appFeatureList != null && appFeatureList.size() > 0){
				appFeature = appFeatureList.get(0);
			}
		}
		return appFeature;
	} private set;}	

    public static Boolean skipContentDocTrigger = false; 

	/*	100,000,000
		|||.|||.|||____		8. Not Used
		|||.|||.||_____		7. Not Used
		|||.|||.|______		6. Not Used
		|||.|||________		5. Personalized Carousel
		|||.||_________		4. Content Moderation
		|||.|__________		3. Page Recommendation
		|||____________		2. Related Content	
		||_____________		1. Topic Suggestion
		|______________		Always 1
	*/
	@TestVisible
	public static String aiFeaturesEnabled {
		get{
			if(aiFeaturesEnabled == null){
				Integer featureValue = getFeatureIntegerValue('AI_Features_Enabled');
				aiFeaturesEnabled = featureValue != null ? String.valueOf(featureValue) : '111111000';
			}
			return aiFeaturesEnabled;
		}private set;
    }

	/*	100,000,000
		|||.|||.|||____		8. Not Used
		|||.|||.||_____		7. Not Used
		|||.|||.|______		6. Not Used
		|||.|||________		5. Location Normalization
		|||.||_________		4. Recognition Enabled
		|||.|__________		3. listener suite Enabled
		|||____________		2. Newsletter+ Enabled
		||_____________		1. Not Used
		|______________		Always 1
	*/
	public static String coreFeaturesEnabled {
		get{
			if(coreFeaturesEnabled == null){
				Integer featureValue = getFeatureIntegerValue('Core_Features_Enabled');
				coreFeaturesEnabled = featureValue != null ? String.valueOf(featureValue) : '111100000';
			}
			return coreFeaturesEnabled;
		}private set;
    }

	/*	100,000,000
		|||.|||.|||____		8. 
		|||.|||.||_____		7. Zeus File Service Authentication
		|||.|||.|______		6. My Teams Analytics Dashboard Enabled
		|||.|||________		5. Perception Analytics Dashboard Enabled
		|||.||_________		4. Initiatives and Campaingns and CDC
		|||.|__________		3. Image Lazy load
		|||____________		2. Page Template
		||_____________		1. TipTap Editor Enabled
		|______________		Always 1
	*/
	public static String futureFeaturesEnabled {
		get{
			if(futureFeaturesEnabled == null){
				Integer featureValue = getFeatureIntegerValue('Future_Features_Enabled');
				futureFeaturesEnabled = featureValue != null ? String.valueOf(featureValue) : '111111101';
			}
			return futureFeaturesEnabled;
		}private set;
    }

	/*	100,000,000
		|||.|||.|||____		8. 
		|||.|||.||_____		7. Kita PSAR changes
		|||.|||.|______		6. Manage Video
		|||.|||________		5. mobile app feature
		|||.||_________		4. 
		|||.|__________		3. Salesforce CDC
		|||____________		2. Slack 2.0
		||_____________		1. 
		|______________		Always 1
	*/
	public static String futureFeaturesSet2Enabled {
		get{
			if (futureFeaturesSet2Enabled == null) {
				Integer featureValue = getFeatureIntegerValue('Future_Features_Set2_Enabled');
				futureFeaturesSet2Enabled = featureValue != null ? String.valueOf(featureValue) : '111110011';
			}

			return futureFeaturesSet2Enabled;
		}private set;
    }

	public static Boolean isActionPollerNotificationEnabled{
    	get{
	    	if(isActionPollerNotificationEnabled == null){
				isActionPollerNotificationEnabled = isFeatureEnabled('Action_Poller_Notification_Enabled');
	    	}
	    	return isActionPollerNotificationEnabled;
    	}private set;
	}
	
	public static Boolean isApexRestEnabled{
    	get{
	    	if(isApexRestEnabled == null){
				isApexRestEnabled = isFeatureEnabled('Apex_Rest_Enabled');
	    	}
	    	return isApexRestEnabled;
    	}private set;
	}

	public static Boolean isNewEditorEnabled {
		get {

			if(isNewEditorEnabled == null){
				isNewEditorEnabled = ('1' == futureFeaturesEnabled.mid(1,1) ? true : false);
			}
			return isNewEditorEnabled;
		}private set;
	}
	@TestVisible
	public static Boolean isFileServiceAuthEnabled {
		get {
			if(isFileServiceAuthEnabled == null){
				isFileServiceAuthEnabled = ('1' == futureFeaturesEnabled.mid(7,1) ? true : false);
			}
			return isFileServiceAuthEnabled;
		}private set;
	}

	public static Boolean isImageLazyLoadEnabled {
		get {
			if(isImageLazyLoadEnabled == null){
				isImageLazyLoadEnabled = ('1' == futureFeaturesEnabled.mid(3,1) ? true : false);
			}
			return isImageLazyLoadEnabled;
		}private set;
	}

	public static Boolean isMyTeamsAnalyticsEnabled {
		get {
			if(isMyTeamsAnalyticsEnabled == null){
				isMyTeamsAnalyticsEnabled = ('1' == futureFeaturesEnabled.mid(6,1) ? true : false);
			}
			return isMyTeamsAnalyticsEnabled;
		}private set;
	}

	public static Boolean isMyTeamsAnalyticsSettingEnabled {
		get {
			if(isMyTeamsAnalyticsSettingEnabled == null) {
                isMyTeamsAnalyticsSettingEnabled = true;
				if(appConfig != null) {
					isMyTeamsAnalyticsSettingEnabled = appConfig.Is_My_Teams_Analytics_Enabled__c;
				}
			}
			return isMyTeamsAnalyticsSettingEnabled;
		} private set;
	}

	public static Boolean isListenerSuiteForMyTeamsEnabled {
		get {
			if(isListenerSuiteForMyTeamsEnabled == null) {
                isListenerSuiteForMyTeamsEnabled = true;
				
				if(appConfig != null) {
					isListenerSuiteForMyTeamsEnabled = appConfig.Is_My_Teams_Listener_Suite_Enabled__c;
				}
			}
			return isListenerSuiteForMyTeamsEnabled;
		} private set;
	}

	public static Boolean isPerceptionAnalyticsEnabled {
		get {
			if(isPerceptionAnalyticsEnabled == null){
				isPerceptionAnalyticsEnabled = ('1' == futureFeaturesEnabled.mid(5,1) ? true : false);
			}
			return isPerceptionAnalyticsEnabled;
		}private set;
	}

	@TestVisible public static Boolean isPlatformCachingFeatureEnabled {
		get {			
			return true;
		}private set;
	}

	@TestVisible public static Boolean isPhoneNoAndMobileTokenRemovableFeatureEnabled {
		get {
			return true;
		}private set;
	}

	@TestVisible public static Boolean isMobileAppPopupFeatureEnabled {
		get {
			if(isMobileAppPopupFeatureEnabled == null){
				isMobileAppPopupFeatureEnabled = ('1' == futureFeaturesSet2Enabled.mid(5,1)  ? true : false);
			}
			return isMobileAppPopupFeatureEnabled;
		}private set;
	}
	
	@TestVisible public static Boolean isVideosManagementFeatureEnabled {
		get {
			if(isVideosManagementFeatureEnabled == null){
				isVideosManagementFeatureEnabled = ('1' == futureFeaturesSet2Enabled.mid(6,1)  ? true : false);
			}
			return isVideosManagementFeatureEnabled;
		}private set;
	}
	

	@TestVisible public static Boolean newsletterPlusEnabled {
		get {
			newsletterPlusEnabled = false;
			if(appFeature != null){
				newsletterPlusEnabled = (('1' == coreFeaturesEnabled.mid(2,1) && appFeature.Newsletter_V2_Enabled__c) ? true : false);
			}
			return newsletterPlusEnabled;
		}private set;
	}

	/**
	 * @description check whether listenerSuite is Enabled or not
	 * @return Boolean - true, if listenerSuite is enabled 
	 */
	@TestVisible public static Boolean listenerSuiteEnabled {
		get {
			if(listenerSuiteEnabled == null){
				listenerSuiteEnabled = ('1' == coreFeaturesEnabled.mid(3,1)  ? true : false);
			}
			return listenerSuiteEnabled;
		}private set;
	}

	/**
	 * @description check whether recognition is Enabled or not
	 * @return Boolean - true, if recognition is enabled 
	 */
	@TestVisible public static Boolean recognitionEnabled {
		get {
			if(recognitionEnabled == null){
				recognitionEnabled = ('1' == coreFeaturesEnabled.mid(4,1)  ? true : false);
			}
			return recognitionEnabled;
		}private set;
	}
	@TestVisible public static Boolean locationNormalizationEnabled {
		get {
			if(locationNormalizationEnabled == null){
				locationNormalizationEnabled = ('1' == coreFeaturesEnabled.mid(5,1)  ? true : false);
			}
			return locationNormalizationEnabled;
		}private set;
	}
    @TestVisible
	public static Boolean aiTopicSuggestionEnabled {
		get {
			aiTopicSuggestionEnabled = false;
			if(aiFeaturesEnabled != null){
				aiTopicSuggestionEnabled = ('0' == aiFeaturesEnabled.mid(1,1) ? false : true);
	     		
    		}
	   return aiTopicSuggestionEnabled;
	   }private set;
	}
    @TestVisible
	public static String aiTopicSuggestionVersion {
		get {
			if(aiTopicSuggestionVersion == null){
				aiTopicSuggestionVersion = ServiceConstants.TOPIC_SUGGESTION_API_VERSION;
	     		
    		}
	   return aiTopicSuggestionVersion;
	   }private set;
	}
    @TestVisible
	public static Boolean aiRelatedContentEnabled {
		get {
			aiRelatedContentEnabled = false;
			if(aiFeaturesEnabled != null){
				aiRelatedContentEnabled = ('0' == aiFeaturesEnabled.mid(2,1) ? false : true);
	     		
    		}
	   return aiRelatedContentEnabled;
	   }private set;
	}
    @TestVisible
	public static String aiRelatedContentVersion {
		get {
			if(aiRelatedContentVersion == null){
				aiRelatedContentVersion = ServiceConstants.RELATED_CONTENT_API_VERSION;
	     		
    		}
	   return aiRelatedContentVersion;
	   }private set;
	}

	/**
	 * @description aiContentRecommendationEnabled - defines if Content Recommendation is enabled or not
	 * @return Boolean - if Content Recommendation is enabled or not
	 */
    @TestVisible
	public static Boolean aiContentRecommendationEnabled {
		get {
			aiContentRecommendationEnabled = false;
			if(aiFeaturesEnabled != null){
				aiContentRecommendationEnabled = ('0' == aiFeaturesEnabled.mid(3,1) ? false : true);
	     		
    		}
	   return aiContentRecommendationEnabled;
	   }private set;
	}

	/**
	 * @description aiContentRecommendationVersion - Content Recommendation Version
	 * @return String - version
	 */
    @TestVisible
	public static String aiContentRecommendationVersion {
		get {
			if(aiContentRecommendationVersion == null){
				aiContentRecommendationVersion = ServiceConstants.PAGE_RECOMMENDATION_API_VERSION;
	     		
    		}
	   return aiContentRecommendationVersion;
	   }private set;
	}

	/**
	 * @description isAIContentModerationFeatureEnabled - defines if Content Moderation Feature is enabled or not
	 * @return Boolean - if Content ModerationFeature is enabled or not
	 */
    @TestVisible
	public static Boolean aiContentModerationFeatureEnabled {
		get {
			aiContentModerationFeatureEnabled = false;
			if(aiFeaturesEnabled != null){
				aiContentModerationFeatureEnabled = ('0' == aiFeaturesEnabled.mid(4,1) ? false : true);
	     		
    		}
	   return aiContentModerationFeatureEnabled;
	   }private set;
	}

	/**
	 * @description aiContentModerationVersion - Content Moderation Version
	 * @return String - version
	 */
    @TestVisible
	public static String aiContentModerationVersion {
		get {
			if(aiContentModerationVersion == null){
				aiContentModerationVersion = ServiceConstants.CONTENT_MODERATION_API_VERSION;
	     		
    		}
	   return aiContentModerationVersion;
	   }private set;
	}

	/**
	 * @description isAIPersonalizedCarouselFeatureEnabled - defines if Personalized Carousel Feature is enabled or not
	 * @return Boolean - if Personalized Carousel Feature is enabled or not
	 */
    @TestVisible
	public static Boolean aiPersonalizedCarouselFeatureEnabled {
		get {
			aiPersonalizedCarouselFeatureEnabled = false;
			if(aiFeaturesEnabled != null){
				aiPersonalizedCarouselFeatureEnabled = ('0' == aiFeaturesEnabled.mid(5,1) ? false : true);
	     		
    		}
	   return aiPersonalizedCarouselFeatureEnabled;
	   }private set;
	}

	/**
	 * @description aiPersonalizedCarouselVersion - Personalized Carousel Version
	 * @return String - version
	 */
    @TestVisible
	public static String aiPersonalizedCarouselVersion {
		get {
			if(aiPersonalizedCarouselVersion == null){
				aiPersonalizedCarouselVersion = ServiceConstants.PERSONALIZED_CAROUSEL_API_VERSION;
	     		
    		}
	   return aiPersonalizedCarouselVersion;
	   }private set;
	}

	/**
	* @description This is flag that distinguish execute context REST or normal context
	* @return Boolean return flag that indecates rest context or not
	**/
    @TestVisible
	public static Boolean isRESTServiceContext{
		get {
			if(isRESTServiceContext == null){
				isRESTServiceContext = false;
			}
			return isRESTServiceContext;
	   }set;
	}

	/**
	* @description retrieve user agent from header, avoid using this in future, instead USE DataServer.readHeader
	* @return String returns user agent
	**/
    @TestVisible
	public static String userAgent{
		get {
			if(userAgent == null){
				// map is case sensitive, this is done to support existing code
				userAgent = SimpplrContext.headers.get('User-Agent') != null ? SimpplrContext.headers.get('User-Agent') : SimpplrContext.headers.get('USER-AGENT');
			}
			return userAgent;
	   }set;
	}

	/**
	* @description replace for ApexPages.currentPage().getHeaders()
	* @return Map<String, String> map of headers
	**/
	public static Map<String, String> headers{
		get {
			if(headers == null){
				headers = new Map<String, String>();
				//When isRESTServiceContext = true - headers are set from RestWebServiceHandler
				//current page does not exists in API context
				if(SimpplrContext.isRESTServiceContext != true 
					&& ApexPages.currentPage() != null 
					&& ApexPages.currentPage().getHeaders() != null){
						headers = ApexPages.currentPage().getHeaders();
				}
			}
			return headers;
	   }set;
	}

	/**
	* @description replacement for ApexPages.currentPage().getUrl()
	* @return String returns requestURI with params
	**/
	public static String requestURI{
		get {
			if(requestURI == null){
				//When isRESTServiceContext = true - requestURI is set from RestWebServiceHandler
				//current page does not exists in API context
				if(ApexPages.currentPage() != null && SimpplrContext.isRESTServiceContext != true){
					requestURI = ApexPages.currentPage().getUrl();
				}
			}
			return requestURI;
	   }set;
	}

	/**
	 * @description isLinkedinConnected - checks whether admin linkedin integration is enabled or not
	 * @return Boolean - if admin linkedin is enabled or not
	 */
	public static Boolean isLinkedinConnected{
		get{
			if(isLinkedinConnected == null){
				isLinkedinConnected = false;
				if(integrations!=null && integrations.containsKey(IntegrationConstants.INTEGRATION_TYPE_LINKEDIN) && integrations.get(IntegrationConstants.INTEGRATION_TYPE_LINKEDIN).Integration_Enabled__c && integrations.get(IntegrationConstants.INTEGRATION_TYPE_LINKEDIN).connected__c){
					isLinkedinConnected = true;
				}
			}
			return isLinkedinConnected;
		}private set;
	}

	/**
	 * @description isTwitterConnected - checks whether admin twitter integration is enabled or not
	 * @return Boolean - if admin linkedin is enabled or not
	 */
	public static Boolean isTwitterConnected{
		get{
			if(isTwitterConnected == null){
				isTwitterConnected = false;
				if(integrations!=null && integrations.containsKey(IntegrationConstants.INTEGRATION_TYPE_TWITTER) && integrations.get(IntegrationConstants.INTEGRATION_TYPE_TWITTER).Integration_Enabled__c && integrations.get(IntegrationConstants.INTEGRATION_TYPE_TWITTER).connected__c){
					isTwitterConnected = true;
				}
			}
			return isTwitterConnected;
		}private set;
	}

	public static String environmentStageName {
		get{
			if(environmentStageName == null) {
				if (String.isBlank(SimpplrContext.packageName)) {
					environmentStageName = 'Development';
					
				} else if(SimpplrContext.isTestOrg || SimpplrContext.isSandbox) {
					environmentStageName = 'Staging';

				} else {
					environmentStageName = 'Production';
				}
			}
			return environmentStageName;
		}private set;	
	}

	public static String getEnvironmentInfo {
		get{
			if(getEnvironmentInfo == null) {
				if (String.isBlank(SimpplrContext.packageName)) {
					getEnvironmentInfo = 'DEV';
					
				} else if(SimpplrContext.isTestOrg || SimpplrContext.isSandbox) {
					getEnvironmentInfo = 'QA';

				} else {
					getEnvironmentInfo = 'PROD';
				}
			}
			return getEnvironmentInfo;
		}private set;	
	}

	@TestVisible
	public static Boolean isContentModerationEnabled{
    	get{
	    	if(isContentModerationEnabled == null){
	    		if(appConfig != null){
	    			isContentModerationEnabled = appConfig.Content_Moderation_Enabled__c;
	    		}
	    	}
	    	return isContentModerationEnabled;
    	}private set;
	}

	/**
	 * @description return corresponding Zeus UUID for salesforce Org
	 * @return String
	 */
	@TestVisible
	public static String uuid{
		get {
		  	if(uuid == null){
				if(appConfig != null){
					uuid = appConfig.UUID__c;
		   		}
		  	}
		  	return uuid;
		}private set;
	}	

	/**
	 * @description hasInitiatives - checks whether the org has any initiatives created or not
	 * @return Boolean - if org has initiatives true else false
	 */
	public static Boolean hasInitiatives{
		get{
			if(hasInitiatives == null){
				if(appConfig != null){
					hasInitiatives = appConfig.Has_Initiatives__c;
		   		}
			}
			return hasInitiatives;
		}private set;
	}

	/**
	 * @description googleMultiDomainUpgradeStatus - checks status of google multi domain upgrade
	 * @return String - notStartedYet/inProgress/completed
	 */
	public static String googleMultiDomainUpgradeStatus{
		get{
			if(googleMultiDomainUpgradeStatus == null){
				if(appConfig != null){
					if(isGoogleMultiDomainEnabled){
						googleMultiDomainUpgradeStatus = String.isNotBlank(appConfig.Google_Multi_Domain_Upgrade_Status__c) ? appConfig.Google_Multi_Domain_Upgrade_Status__c : ServiceConstants.UPGRADE_STATUS_NOT_STARTED_YET;
					}
					else{
						googleMultiDomainUpgradeStatus = ServiceConstants.SINGLE_DOMAIN;
					}
		   		}
			}
			return googleMultiDomainUpgradeStatus;
		}private set;
	}

	/**
	 * @description isGoogleMultiDomainUpgraded - checks whther status of Google_Multi_Domain_Upgrade_Status__c is completed
	 * @return Boolean - true if status is completed
	 */
	@TestVisible
	public static Boolean isGoogleMultiDomainUpgraded{
		get{
			if(isGoogleMultiDomainUpgraded == null){
				if(appConfig != null){
					if(String.isNotBlank(appConfig.Google_Multi_Domain_Upgrade_Status__c) && isGoogleMultiDomainEnabled){
						isGoogleMultiDomainUpgraded = (appConfig.Google_Multi_Domain_Upgrade_Status__c.equalsIgnoreCase(ServiceConstants.UPGRADE_STATUS_COMPLETED) || appConfig.Google_Multi_Domain_Upgrade_Status__c.equalsIgnoreCase(ServiceConstants.UPGRADE_STATUS_NOT_REQUIRED))? true : false;
					}
					else{
						isGoogleMultiDomainUpgraded = false;
					}
		   		}
			}
			return isGoogleMultiDomainUpgraded;
		}private set;
	}

	public static Boolean isGoogleMultiDomainEnabled{
    	get{
	    	return true;
    	}private set;
	}

	public static String harnessAPIKey {
		get{
			if(harnessAPIKey == null) {
				if (String.isBlank(SimpplrContext.packageName)) {
					harnessAPIKey = '02c21b72-6176-4914-91d0-cabe2cc60155';
					
				} else if(SimpplrContext.isTestOrg || SimpplrContext.isSandbox) {
					harnessAPIKey = 'ec6523fe-fdf8-465c-a6df-2cc94af11e8b';
				
				} else {
					harnessAPIKey = '2f7c75f0-040d-48f9-8d59-4ded17b7cba6';
				}
			}
			return harnessAPIKey;
		}private set;	
	}
	/**
	 * @description isSlackUpgraded - checks if slack is upgraded
	 * @return Boolean - true if upgraded
	 */
	@TestVisible
	public static Boolean isSlackUpgraded {
		get {
			if(isSlackUpgraded == null) {
				isSlackUpgraded = false;
				if(Integrations != null && integrations.get(IntegrationConstants.INTEGRATION_TYPE_SLACK) != null) {
					isSlackUpgraded = integrations.get(IntegrationConstants.INTEGRATION_TYPE_SLACK).Is_Slack_Upgraded__c;
				}
			}
			return isSlackUpgraded;
		} private set;
	}
	
	public static String targetEnvironemnt{
        get{
            return null;
        }private set;
    }

	/*
    NONE - 0	No logging.
    ERROR- 1	Error and exception logging.
    WARN-  2 	Warning logging.
    INFO-  3	Informational logging.
    DEBUG- 4 	User-specified debug logging.
    */
	public static Integer loggingLevel {
		get{
			return 4;
			// if(loggingLevel == null){
			// 	Integer featureValue = getFeatureIntegerValue('Logging_Level');
			// 	loggingLevel = featureValue != null ? featureValue : 0;
			// 	if(Test.isRunningTest()){
			// 		loggingLevel = 4;
			// 	}
			// }
			// return loggingLevel;
		}private set;
    }

	public static String debugEnabledforUsers {
		get {
    		if(debugEnabledforUsers == null){
    			debugEnabledforUsers = '';
	    		if(appConfig != null){
	    			debugEnabledforUsers = appConfig.debug_enabled_for_users__c!=null? appConfig.debug_enabled_for_users__c : '';
					if(Test.isRunningTest()){
						debugEnabledforUsers = UserInfo.getUserId();
					}
	    		}
    		}
    		return debugEnabledforUsers;
    	} private set;
    }

	public static DateTime debugTurnOffTime {
		get {
			if(debugTurnOffTime == null){
				if(appConfig != null){
					debugTurnOffTime = appConfig.Debugging_Turn_Off_Time__c!=null? appConfig.Debugging_Turn_Off_Time__c : System.now().addDays(-1);
			 	}
				if(Test.isRunningTest()){
					debugTurnOffTime = System.now().addDays(1);
				}
			}
			return debugTurnOffTime;
		}private set;
    }
}