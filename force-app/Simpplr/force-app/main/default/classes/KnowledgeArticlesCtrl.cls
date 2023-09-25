public with sharing class KnowledgeArticlesCtrl {
	
	@TestVisible private String DATA_CATEGORY_OBJECT = ServiceConstants.DEFAULT_DATA_CATEGORY + '__DataCategorySelection';
	public String defaultParamString {get;set;}
	public String viewParamString {get;set;}
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
	public static App_Config__c appConfig { get {
	    	if(appConfig==null) {
				String appConfigQuery = 'select Knowledge_Article_Data_Categories__c  from App_config__c Limit 1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<App_Config__c> appConfigList = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
		
				if(appConfigList.size() > 0) {
					appConfig = appConfigList[0];
				}
	    	}
	    	return appConfig;
    	} set;
    }
    
    public static Map<String, KnowledgeWrapper.DataCategoryWrapper> mapOfDataCategories {get {
    		if(mapOfDataCategories == null) {
    			mapOfDataCategories = new Map<String, KnowledgeWrapper.DataCategoryWrapper>();
    			if(appConfig != null && String.isNotBlank(appConfig.Knowledge_Article_Data_Categories__c)) {
    				mapOfDataCategories = (Map<String, KnowledgeWrapper.DataCategoryWrapper>)JSON.deserialize(appConfig.Knowledge_Article_Data_Categories__c, Map<String, KnowledgeWrapper.DataCategoryWrapper>.class);
    			}
    		}
    		return mapOfDataCategories;
    	} set;
    }
	public String getPageTitle() {
    	return  'Knowledge Articles';
	}   
	
	 public static String pageName {get{
    	if(String.isEmpty(pageName)){
    		pageName = PageContext.namespacePrefix + 'KnowledgeArticles';
    	}
    	return pageName;
    }set;}
	
	public PageReference handleRequest () {
		PageReference returnPageRef = null;
		try {
			String categoryGroup = SIMPESAPI.encoder().SFDC_JSENCODE(ApexPages.currentPage().getParameters().get('categoryGroup'));
			String subcategory = SIMPESAPI.encoder().SFDC_JSENCODE(ApexPages.currentPage().getParameters().get('subcategory'));
			DefaultParameters DefaultParametersObj = new DefaultParameters ();
			DATA_CATEGORY_OBJECT = SimpplrContext.KnowledgeArticleType + '__DataCategorySelection';
			
			if (categoryGroup!= null) {
				DefaultParametersObj.categoryGroup =  categoryGroup;
			}
			
			if (subcategory != null) {
				DefaultParametersObj.subcategory =  subcategory;
			}
			
			DefaultParametersObj.isSecondPage = true;
			defaultParamString = Json.serialize(DefaultParametersObj);
        	
        	ViewParamWrapper viewParamWrapObj = getfilterWrapperList(categoryGroup, categoryGroup); 
			viewParamString = Json.serialize(viewParamWrapObj);
		} catch (Exception e) {
			logger.logError('KnowledgeArticleCtrl.handleRequest()------ exception occured ', e);
		}
		
		return returnPageRef;
	}
	@TestVisible
	private ViewParamWrapper getfilterWrapperList(String categoryName, String subCategoryName){
		ViewParamWrapper viewParams = new ViewParamWrapper();
		viewParams.categories = new List<Category>();
		viewParams.subcategories = new List<Subcategory>();
		
		for(String parentCategoryName : mapOfDataCategories.keySet()) {
			KnowledgeWrapper.DataCategoryWrapper parentCategory = mapOfDataCategories.get(parentCategoryName);
            Category categoryObj = new Category();
            categoryObj.name = 'All Categories';
            categoryObj.value = 'AllKnowledgeArticles';
			categoryObj.url = PageContext.getPageURL(KnowledgeCategoriesCtrl.pageName);
			viewParams.categories.add(categoryObj);
            
            categoryObj = new Category();
			categoryObj.name = parentCategory.label;
			categoryObj.value = parentCategory.name;
			categoryObj.url = PageContext.getPageURL(KnowledgeArticlesCtrl.pageName, new Map<String, String>{'categoryGroup'=> parentCategory.name});
			viewParams.categories.add(categoryObj);
			if(categoryObj.value.equalsIgnoreCase(subCategoryName) || 'AllKnowledgeArticles'.equalsIgnoreCase(categoryName)) {
	            for(String childCategoryName : parentCategory.mapofSubCategories.keySet()) {
	            	KnowledgeWrapper.DataCategoryWrapper childCategory = parentCategory.mapofSubCategories.get(childCategoryName);
					Subcategory subCatObj = new Subcategory();
					subCatObj.name = childCategory.label;
					subCatObj.value = childCategory.name;
					viewParams.subcategories.add(subCatObj);
	            }
			}
		}
		viewParams.categories.sort();
		viewParams.subcategories.sort();
		return viewParams;
	}
	private static List<DataCategory> getAllCategories(List<DataCategory> listOfParentCategories){
		if(listOfParentCategories.isEmpty()){
			return new DataCategory[]{};
		} else {
			List<DataCategory> categoriesClone = listOfParentCategories.clone();
			DataCategory category = categoriesClone[0];
			List<DataCategory> allCategories = new List<DataCategory>();
			categoriesClone.remove(0);
			categoriesClone.addAll(category.getChildCategories());
			return categoriesClone;
		}
	}
	
	public class DefaultParameters {
		public String categoryGroup {get;set;}
		public String subcategory {get;set;}
		public Boolean isFirstPage {get;set;}
		public Boolean isSecondPage {get;set;}
	}
	
	public class ViewParamWrapper {
		public List<Subcategory> subcategories {get;set;}
		public List<Category> categories {get;set;}
	}
	
	public class Subcategory  implements Comparable {
		public String name {get;set;}
		public String value {get;set;}
		public Integer compareTo(Object compareTo) {
			Subcategory subcategoryObj = (Subcategory) compareTo;
			if(name == null || subcategoryObj.name == null) {
				return 0;
			}
			if(name > subcategoryObj.name) return 1;
			if(name < subcategoryObj.name) return -1;
			return 0;
		} 
		
	}
	
	public class Category  implements Comparable{
		public String name {get;set;}
		public String value {get;set;}
		public String url {get;set;}
		
		public Integer compareTo(Object compareTo) {
			Category categoryObj = (Category) compareTo;
			if(name == null || categoryObj.name == null) {
				return 0;
			}
			if(name > categoryObj.name) return 1;
			if(name < categoryObj.name) return -1;
			return 0;
		} 
	}
}