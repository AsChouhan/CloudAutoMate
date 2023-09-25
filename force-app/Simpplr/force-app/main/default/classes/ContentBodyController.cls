public with sharing class ContentBodyController {
	

	public boolean useCustomFont {get; set;}
	public String contentBody {get; set;}
	public String resourcePath {
		get {
			String packageName = String.isNotBlank(SimpplrContext.packageName) ? (SimpplrContext.packageName + '__') : '';
			return SimpplrContext.salesforceBaseUrl + '/resource/'+ packageName;
		} set;
	}
	
	public String fontCSSURL { get {
		if(useCustomFont) {
			fontCSSURL = PageContext.getPageURL(Pages.BrandingCSS) + '?action=getCustomFontCSS&v=' + packageVersion;
		} else {
			fontCSSURL = resourcePath +  + 'font_min_css' + (String.isNotBlank(SimpplrContext.packageName) ? '' : '_dev') + '?v=' + packageVersion;
		}
		return fontCSSURL;
	} set; }
	
	public String brandingCSSURL { get {
		if(useCustomFont) {
			brandingCSSURL = PageContext.getPageURL(Pages.BrandingCSS) + '?action=getBrandingCSS&v=' + packageVersion;
		} else {
			brandingCSSURL = PageContext.getPageURL(Pages.BrandingCSS) + '?action=getBrandingCSS&v=' + packageVersion;
		}
		return brandingCSSURL;
	} set; }
	
	public String packageName { get {
		return String.isNotBlank(SimpplrContext.packageName) ? (SimpplrContext.packageName + '__') : '';
	} set; }
	
	public String packageVersion { get { 
		return ServiceConstants.PACKAGE_VERSION;
	} set;}

	public String salesforceBaseUrl { 
        get {
            
                return Url.getSalesforceBaseUrl().toExternalForm(); 
        }
    }
	
	
	public PageReference init(){
    	PageReference returnPage = null;
    	logger.logDebug('init()---start--request params-- ' + ApexPages.currentPage().getParameters());
    	useCustomFont = false;
    	try{
    		if(UserContext.hasSimpplrUserPermissionSetAssigned){
    			
    		} else {
    			throw new SimpplrException(ExceptionCode.PERMISSION_SET_EXCEPTION.name());
    		}
    		
    		if(SimpplrContext.isSimpplrSetupComplete == false){
    			// ignore error and postinstall setup pages otherwise throw error.
    			if(PageContext.currentPageName.containsIgnoreCase('ErrorPage')){
    			} else if(PageContext.currentPageName.containsIgnoreCase('PostInstallSetup')){
    			} else{
	    			logger.logDebug('init()---Missing system configuration for user = ' + UserContext.id);
			        throw new SimpplrException(ExceptionCode.MISSING_SYSTEM_CONFIGURATION.name());
    			}
    		} else if(SimpplrContext.isMaintenanceInProgress) {
    			if(PageContext.currentPageName.containsIgnoreCase('ErrorPage')){
    			} else if(PageContext.currentPageName.containsIgnoreCase('PostInstallSetup')){
    			} else{
			        throw new SimpplrException(ServiceConstants.MIGRATION_ERROR);
    			}
    		}
    		if(String.isEmpty(UserContext.peopleId)) {
    			if(PageContext.currentPageName.containsIgnoreCase('ErrorPage')){
    			} else if(PageContext.currentPageName.containsIgnoreCase('PostInstallSetup')){
    			} else{
	    			logger.logDebug('init()---page access denied--User setup incorrect--userId-- ' + UserContext.id);
	        		throw new SimpplrException(ExceptionCode.INCORRECT_USER_SETUP.name());
    			}
	    	}
	    	if(SimpplrContext.isSimpplrSetupComplete == true && String.isNotEmpty(UserContext.peopleId)) {
	    		Map<String,Object> brandingMap = (Map<String,Object>)JSON.deserializeUntyped(SimpplrContext.SABrandingJSON);
	    		String fontUsed = String.valueOf(brandingMap.get('font_font'));
	    		if('custom'.equalsIgnoreCase(fontUsed)) {
	    			useCustomFont = true;
	    		}
	    		
	    	}
			String contentId = ApexPages.currentPage().getParameters().get('contentId');
			contentBody = getContentBody(contentId);
	    	
		}catch(Exception e){
			logger.logDebug('Exception occured-----' + e);
	    }
    	return returnPage;
    }
    
    public String getContentBody(String contentId){
    	String contentBody = '';
    	Simpplr_Content__c contentRecord = [select Text_Intro__c, Text_Main__c, Text_Main_Continued__c from Simpplr_Content__c where id=:contentId WITH SECURITY_ENFORCED limit 1 ];
    	contentBody = (String.isNotBlank(contentRecord.Text_Intro__c) ? contentRecord.Text_Intro__c : '') +
                                      (String.isNotBlank(contentRecord.Text_Main__c) ? contentRecord.Text_Main__c : '') +
                                      (String.isNotBlank(contentRecord.Text_Main_Continued__c) ? contentRecord.Text_Main_Continued__c : '');
    	return Utility.getSanitizedHTMLfromLambda(contentBody);
    }
}