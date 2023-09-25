public with sharing class KnowledgeCategoriesCtrl {
	public String defaultParamString {get;set;}
	@TestVisible private String DATA_CATEGORY_OBJECT = ServiceConstants.DEFAULT_DATA_CATEGORY + '__DataCategorySelection';
	public String knowledgeHomeURL {get {
        String linkUrl = PageContext.getPageURL(Pages.KnowledgeCategories);
		return linkUrl;
	}set;}
	
 	public String resourcePath {
		get {
			String packageName = String.isNotBlank(SimpplrContext.packageName) ? (SimpplrContext.packageName + '__') : '';
			return SimpplrContext.salesforceBaseUrl + '/resource/'+ packageName;
		}
	}
	
	public String getPageTitle() {
    	return  'Knowledge Categories';
	}   
	
	 public static String pageName {get{
    	if(String.isEmpty(pageName)){
    		pageName = PageContext.namespacePrefix + 'KnowledgeCategories';
    	}
    	return pageName;
    }set;}
    
    public PageReference handleRequest () {
		try {
			DefaultParameters defaultParametersObj = new DefaultParameters ();
			Map<String, String> args = new Map<String, String>();
            args.put('categoryGroup', 'AllKnowledgeArticles');
            
            String linkUrl = PageContext.getPageURL(Pages.KnowledgeArticles, args);
    		DefaultParametersObj.redirectURL = linkUrl;
    		String searchTerm = SIMPESAPI.encoder().SFDC_JSENCODE(ApexPages.currentPage().getParameters().get('searchTerm'));
    		if(String.isNotBlank(searchTerm)) {
            	DefaultParametersObj.term = searchTerm;
            	DefaultParametersObj.categoryGroup = 'AllKnowledgeArticles';
    		}
			defaultParamString = Json.serialize(DefaultParametersObj);	
	        
		} catch (Exception e) {
		
		}
		
		return null;
    }
    
    public class DefaultParameters {
		public String redirectURL {get;set;}
		public String term{get;set;}
		public String categoryGroup{get;set;}
	}
}