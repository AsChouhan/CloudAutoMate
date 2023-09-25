public with sharing class AnalyticsCtrl extends BaseCtrl {
	
	public String accessLevel{get;set;}
	public String siteId{get;set;}
	public String hiddenContentFilters{get;set;}
	
    public AnalyticsCtrl() {
        
    }
    
   /**
   * 
   * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
   * Parameters:
   *      parameter_name -- [Explanation of the purpose of this parameter to the method.
   *      
   * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
   */    
    public static String pageName {get{
    	if(String.isEmpty(pageName)){
    		pageName = PageContext.namespacePrefix + 'Analytics';
    	}
    	return pageName;
    }set;}
    
    public String currentSiteId{
		get{ 
			if(String.isBlank(SiteContext.siteId)){
				return null;
			} else{
				return SiteContext.siteId;
			}
		}
	}
    
   /**
   * 
   * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
   * Parameters:
   *      parameter_name -- [Explanation of the purpose of this parameter to the method.
   *      
   * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
   */
    public override String getPageFeature() {
    	return AccessManager.FEATURE_ANALYTICS;
    }
    
    /*
    *
    */
    public String getPageTitle() {
    	return  'Analytics' + AppPageTitle;
    }
    
    /**
     * 
     */
    private Boolean isPageFeatureEnabled(){
		Boolean isPageFeatureEnabled = false;
		if(SimpplrContext.AllowedFeatures.containsIgnoreCase(AccessManager.FEATURE_PAGE)) {
			isPageFeatureEnabled = String.isBlank(SiteContext.siteId) ? true : SiteContext.hasPages;
		}
		return isPageFeatureEnabled;
    }
    
    /**
     * 
     */
    private Boolean isEventFeatureEnabled() {
		Boolean isEventFeatureEnabled = false;
		if(SimpplrContext.AllowedFeatures.containsIgnoreCase(AccessManager.FEATURE_Event)) {
			isEventFeatureEnabled = String.isBlank(SiteContext.siteId) ? true : SiteContext.hasEvents;
		}
		return isEventFeatureEnabled;
    }
    
    /**
     * 
     */
    private Boolean isAlbumFeatureEnabled(){
		Boolean isAlbumFeatureEnabled = false;
		if(SimpplrContext.AllowedFeatures.containsIgnoreCase(AccessManager.FEATURE_Album)) {
			isAlbumFeatureEnabled = String.isBlank(SiteContext.siteId) ? true : SiteContext.hasAlbums;
		}
		return isAlbumFeatureEnabled;
    }
    
    /**
     * 
     */
    private Boolean isBlogFeatureEnabled() {
    	Boolean isBlogFeatureEnabled = false;
    	if(SimpplrContext.AllowedFeatures.containsIgnoreCase(AccessManager.FEATURE_BLOG)){
			isBlogFeatureEnabled = true;
    	}
    	return isBlogFeatureEnabled;
    }
    
   /**
   * 
   * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
   * Parameters:
   *      parameter_name -- [Explanation of the purpose of this parameter to the method.
   *      
   * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
   */
    public PageReference init() {
    	logger.logDebug('init()---start--request params-- ' + ApexPages.currentPage().getParameters());
        PageReference returnPage = null;
        
    	try{
    		String ultralinks = readParam('ultralinks');
    		if(SimpplrContext.isExternalAnalyticsEnabled || ('1'.equalsIgnoreCase(ultralinks) ==false)) {
    			returnPage = Page.app;
		    	returnPage.getParameters().put('u', '/analytics');
				return returnPage;  
    		}
	        if(!AccessManager.hasPageAccess(getPageFeature())) {
	        	logger.logDebug('init()---page access denied--when page-- '+ pageName +' and page feature is- ' + getPageFeature());
		        throw new SimpplrException(ServiceConstants.ERROR_403);
	    	}else if(String.isNotBlank(currentSiteId) && !AccessManager.hasUserSiteAccessForAnalytics(currentSiteId)) {
	    		String pageUrl = PageContext.getPageURL(Pages.Analytics);
	    		
    			if(UserContext.sitesIManageIdSet.size()==1){
    				Map<String,String> args = new Map<String,String>();
    				args.put('siteId',new List<Id>(UserContext.sitesIManageIdSet)[0]);
    				pageUrl = PageContext.getPageURL(Pages.Analytics,args);
    			}
    			PageReference pageRef = new PageReference(pageUrl);
				pageRef.setRedirect(true);
    			return pageRef;
	    	}
	    	logger.logDebug('init()---start loading page metadata--');
	    	
	    	// set default value as site. 
	    	siteId = SiteContext.siteId;
	    	accessLevel = 'site'; 
	    	
	    	if(UserContext.isUserAppModerator || UserContext.hasModifyAllDataPermission || UserContext.canAccessAnalytics){
	    		accessLevel = 'full';
	    	}
	    	
	    	hiddenContentFilters = buildVIewParam();
	    	
	    	logger.logDebug('init()---end loading page metadata--');
    	}catch(Exception e){
	    	returnPage = handleAndTranslateException(returnPage, e);
	    }
	    logger.logDebug('init()---page successfully loaded--');
	    return returnPage;
    }
    
    @TestVisible 
    private String buildVIewParam(){
    	List<String> hiddenFilters = new List<String>();
	     
    	if(isPageFeatureEnabled()==false){
    		hiddenFilters.add('pages');
    	}
    	if(isEventFeatureEnabled()==false){
    		hiddenFilters.add('events');
    	}
    	if(isAlbumFeatureEnabled()==false){
    		hiddenFilters.add('albums');
    	}
    	if(isBlogFeatureEnabled()==false){
    		hiddenFilters.add('blog_posts');
    	}
    	
    	return JSON.serialize(hiddenFilters);
    }
	
}