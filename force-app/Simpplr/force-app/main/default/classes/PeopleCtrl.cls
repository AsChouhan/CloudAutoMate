/**
* Class PeopleCtrl 
* Purpose:  Default Page controller for People page to check page access, provide page metadata 
*
*/
public with sharing class PeopleCtrl extends BaseCtrl {
	
	public String filterWrapper{get; set;}
    
   /**
   * 
   * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
   * Parameters:
   *      parameter_name -- [Explanation of the purpose of this parameter to the method.
   *      
   * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
   */
    public PeopleCtrl() {
        
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
    		pageName = PageContext.namespacePrefix + 'People';
    	}
    	return pageName;
    }set;}

	/*
    *
    */
    public String getPageTitle() {
    	return  'People' + AppPageTitle;
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
    	return AccessManager.FEATURE_SIMPPLR;
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
	        logger.logDebug('init()---checking page access--when page-- '+ pageName +' and page feature is- ' + getPageFeature());
	        if(!AccessManager.hasPageAccess(getPageFeature())) {
	        	logger.logDebug('init()---page access denied--when page-- '+ pageName +' and page feature is- ' + getPageFeature());
		        throw new SimpplrException(ServiceConstants.ERROR_404);
	    	}
        }catch(Exception e){
        	returnPage = handleAndTranslateException(returnPage, e);
        }
        logger.logDebug('init()---page successfully loaded--');
        
	    return returnPage;
    }
    
}