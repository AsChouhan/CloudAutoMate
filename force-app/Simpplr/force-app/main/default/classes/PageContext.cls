/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class PageContext {
	
	@TestVisible
	public static String currentPageURL{
		get{
			if(currentPageURL == null){
				currentPageURL = ApexPages.currentPage().getUrl();
				currentPageURL = currentPageURL.substring(0,currentPageURL.lastIndexOf('?')>0?currentPageURL.lastIndexOf('?'):currentPageURL.length());
				currentPageURL = currentPageURL.substring(0,currentPageURL.lastIndexOf('#')>0?currentPageURL.lastIndexOf('#'):currentPageURL.length());
			}
			return currentPageURL;
		} private set;
	}
    @TestVisible
    public static String namespacePrefix{
    	get{
	    	if(namespacePrefix == null){
	    		namespacePrefix = '';
	    		if(!String.isEmpty(SimpplrContext.packageName)){
    				namespacePrefix = SimpplrContext.packageName+'__';
	    		}
	    	}
	    	return namespacePrefix;
    	} private set;
    }
    
    @TestVisible
    public static String currentPageName{
    	get{
	    	if(currentPageName == null){
	    		currentPageName = '';
	    		String currentUrl = '';
	    		if(ApexPages.currentPage()!=null && !String.isBlank(ApexPages.currentPage().getUrl()) ){
		    		currentUrl = ApexPages.currentPage().getUrl().toLowercase();
		    		if(!String.isBlank(currentUrl) && currentUrl.startsWith('/apex')){
		    			String namespacePrefixStr = (String.isBlank(SimpplrContext.packageName)?'':SimpplrContext.packageName+'__').toLowercase();
		    			currentPageName =  currentUrl.substring(currentUrl.lastIndexOf('/'+ namespacePrefixStr)+namespacePrefixStr.length()+1);
		    			if(currentPageName.lastIndexOf('?')>0){
		                	currentPageName = currentPageName.substring(0,currentPageName.lastIndexOf('?'));
		            	}
		    		}
	    		}
	    	}
	    	return currentPageName;
    	}set;
    }
    
    public static String getPageURL(String pageName){
    		return SimpplrContext.salesforceBaseUrl  + '/apex/' + pageName;
    }
    
    public static String getPageURL(String pageName, Map<String,String>args){
    	
	    	String returnUrl = getPageURL(pageName);
	    	if(args != null) {
	    		returnUrl += '?';
		    	for(String key: args.keyset()){
		    		returnUrl += '' + key + '=' + args.get(key) + '&';
		    	}
	    	}
	    	return returnUrl.removeEnd('&');
    }
    
    // DONE
    public static Boolean allowCommentOnContent(){
    	Boolean allowCommentOnContent = false;
    	
    	if(String.isNotBlank(SiteContext.siteId)) {
    		allowCommentOnContent = SimpplrContext.isFeedEnabled && SimpplrContext.isCommentsAllowed && SiteContext.isCommentsAllowed;
    	}
    	return allowCommentOnContent;
    }

	
    
    public static final Map<String, String> pageUrlMap = new Map<String, String>{};
    																					
}