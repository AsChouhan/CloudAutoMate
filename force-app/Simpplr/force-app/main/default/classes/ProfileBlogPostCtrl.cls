public with sharing class ProfileBlogPostCtrl extends BaseCtrl {
    
    public ProfileBlogPostCtrl() {
        
    }
    
    public String getPageTitle() {
    	return  'Profile Blog Post' + AppPageTitle;
    }
    
    public override String getPageFeature() {
        return AccessManager.FEATURE_BLOG;
    }
    
    public String pageName {get{
    	if(String.isEmpty(pageName)){
    		pageName = PageContext.namespacePrefix + 'Site Content';
    	}
    	return pageName;
    }set;}
    
    public PageReference init(){
    	logger.logDebug('init()---start--request params-- ' + ApexPages.currentPage().getParameters());
        PageReference returnPage = null;
        try{
	        logger.logDebug('init()---checking page access--when page-- '+ pageName +' and page feature is- ' + getPageFeature());
	        if(!AccessManager.hasPageAccess(getPageFeature())) {
	        	logger.logDebug('init()---page access denied--when page-- '+ pageName +' and page feature is- ' + getPageFeature());
		        throw new SimpplrException(ServiceConstants.ERROR_404);
	    	}
	    	
	    	logger.logDebug('init()---start loading page metadata--');
	    	logger.logDebug('init()---end loading page metadata--');
        }catch(Exception e){
        	returnPage = handleAndTranslateException(returnPage, e);
        }
        logger.logDebug('init()---page successfully loaded--');
        
	    return returnPage;
    }
}