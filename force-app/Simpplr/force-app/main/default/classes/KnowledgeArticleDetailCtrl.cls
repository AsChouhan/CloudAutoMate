public with sharing class KnowledgeArticleDetailCtrl {
    @TestVisible private String KNOWLEDGE_ARTICLE_OBJECT = ServiceConstants.DEFAULT_DATA_CATEGORY + '__ka';
    @TestVisible private String KNOWLEDGE_ARTICLE_VERSION_OBJECT = ServiceConstants.DEFAULT_DATA_CATEGORY + '__kav';
    @TestVisible private String KnowledgeArticleType;
    @TestVisible private final String ARTICLE_DESCRIPTION_CUSTOM_FIELD = ServiceConstants.ARTICLE_BODY_CUSTOM_FIELD;
    @TestVisible private final String KNOWLEDGE_PUBLISH_STATUS = ServiceConstants.PUBLISH_STATUS;
    @TestVisible private final String KNOWLEDGE_LANGAUGE = ServiceConstants.LANGUAGE;
    
    public String knowledgeHomeURL {get {
        String linkUrl = PageContext.getPageURL(Pages.KnowledgeCategories);
		return linkUrl;
	}set;}
	
	public String defaultParamString {get;set;}
	public KnowledgeWrapper.articleDetailWrapper knowledgeArticleObj {get;set;}
	
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
    public static Map<String, String> mapOfChildAndParentCategory {get {
    	if(mapOfChildAndParentCategory == null) {
    		mapOfChildAndParentCategory = new Map<String, String>();
    		for(String parentCategory : mapOfDataCategories.keySet()) {
    			for(String childCategory:mapOfDataCategories.get(parentCategory).mapofSubCategories.keySet()) {
    				mapOfChildAndParentCategory.put(childCategory, mapOfDataCategories.get(parentCategory).name);
    			}
    		}
    	}
    	return mapOfChildAndParentCategory;	
    } set;
	}
	
	public static Map<String, String> mapOfCategoryNameAndLabel {get {
		if(mapOfCategoryNameAndLabel == null) {
			mapOfCategoryNameAndLabel = new Map<String, String>();
			for(String parentCategoryName : mapOfDataCategories.keySet()) {
				KnowledgeWrapper.DataCategoryWrapper parentDetails = mapOfDataCategories.get(parentCategoryName);
				mapOfCategoryNameAndLabel.put(parentDetails.name, parentDetails.label);
    			for(String childCategoryName:parentDetails.mapofSubCategories.keySet()) {
    				KnowledgeWrapper.DataCategoryWrapper childDetails = parentDetails.mapofSubCategories.get(childCategoryName);
    				mapOfCategoryNameAndLabel.put(childDetails.name, childDetails.label);
    			}
    		}
		}
		return mapOfCategoryNameAndLabel;
	} set;
	} 
	
	public String getPageTitle() {
    	return  'Knowledge Articles';
	}   
	
	 public static String pageName {get{
    	if(String.isEmpty(pageName)){
    		pageName = PageContext.namespacePrefix + 'KnowledgeArticleDetail';
    	}
    	return pageName;
    }set;}
	
	public void handleRequest () {
		try {
			String KnowledgeArticleType = SimpplrContext.KnowledgeArticleType;
	        
	        if (KnowledgeArticleType != null) {  
		        KNOWLEDGE_ARTICLE_OBJECT = KnowledgeArticleType + '__ka'; 
		        KNOWLEDGE_ARTICLE_VERSION_OBJECT = KnowledgeArticleType + '__kav';
       		}
       		
			String articleId = SIMPESAPI.encoder().SFDC_JSENCODE(ApexPages.currentPage().getParameters().get('articleId'));
			if (articleId != null) {
				List<KnowledgeWrapper.articleDetailWrapper> listOfArticleDetail = new List<KnowledgeWrapper.articleDetailWrapper>();
				listOfArticleDetail = getArticleDetail(articleId);
				if (!listOfArticleDetail.isEmpty()) {
					knowledgeArticleObj = new KnowledgeWrapper.articleDetailWrapper();
					knowledgeArticleObj = listOfArticleDetail[0];
				}
			
			}
			
		} catch (Exception e) {
		}
	}
	
	@TestVisible  
    private List<KnowledgeWrapper.articleDetailWrapper> getArticleDetail(String articleId) { 
    	
    	List<KnowledgeWrapper.articleDetailWrapper> ArticleDetailList = new List<KnowledgeWrapper.articleDetailWrapper>();
    	String queryArticle = 'Select Id, Title, LastModifiedDate, createdbyId, CreatedDate, Summary,'+
    			getKnowledgeArticleDetailCustomFields() +
    			' PublishStatus, Language,'+ simpplrContext.KnowledgeArticleDetailField +
    			',(Select Id, ParentId, DataCategoryGroupName, DataCategoryName From DataCategorySelections)  From '+
                 KNOWLEDGE_ARTICLE_VERSION_OBJECT+' Where Language =\''+KNOWLEDGE_LANGAUGE+'\''+
                 ' AND PublishStatus =\''+KNOWLEDGE_PUBLISH_STATUS + '\''+' AND KnowledgeArticleId = :articleId';
                 
        List<SObject> listOfGroupWithArticle = Database.query(queryArticle);  
    	Map<Id, Id> artcleCreatedByIdMap = new Map<Id, Id>();
        Map<Id, User> userMap = new Map<Id, User>();
        Set<Id> setOfCreatedById = new Set<Id>();
        Map <Id, List<SObject>> mapOfIdWithListOfCategoriesArticle = new   Map <Id, List<SObject>>();
        
        for (SObject obj : listOfGroupWithArticle) {
    		artcleCreatedByIdMap.put(obj.Id, (String)obj.get('createdbyId'));
    		setOfCreatedById.add((String)obj.get('createdbyId'));
    		mapOfIdWithListOfCategoriesArticle.put(obj.Id, obj.getSObjects('DataCategorySelections'));	
        }
      
        for (User uObj : [SELECT Id, Name, smallphotourl, (select id, full_name__c from Parent_User__r) FROM User WHERE Id IN:setOfCreatedById WITH SECURITY_ENFORCED]) {
    		userMap.put(uObj.Id, uObj);	
        }
        Map<String,Schema.SObjectField> mapofKnowledgeFields = new Map<String, Schema.SObjectField>(); 
    	if(!SimpplrContext.KnowledgeArticleCustomFields.isEmpty()) {
    		Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();  
			Schema.sObjectType sObjType = globalDescription.get(KNOWLEDGE_ARTICLE_VERSION_OBJECT);
    		mapofKnowledgeFields = sObjType.getDescribe().fields.getMap();
    	}
    	
    	for (SObject obj : listOfGroupWithArticle) {
			KnowledgeWrapper.ArticleDetailWrapper wObj = new KnowledgeWrapper.ArticleDetailWrapper();
			wObj.owner = new KnowledgeWrapper.OwnerWrapper();
    		wObj.title = (String)obj.get('Title');
    		wObj.summary = (String)obj.get('Summary');
    	    wObj.description = (String)obj.get(SimpplrContext.KnowledgeArticleDetailField);
    	    if(String.isNotBlank(wObj.description)) {
    	    	wObj.description = replaceSmartLink(wObj.description);
    	    }
			wObj.createdDate = dateToDisplayString((DateTime)obj.get('CreatedDate'),'MMM d, yyyy');
			
			wObj.lastModifiedDate = dateToDisplayString((DateTime)obj.get('LastModifiedDate'),'MMM d, yyyy');
    		wObj.owner.id = (String)obj.get('CreatedById');
    		
            String linkUrl = PageContext.getPageURL(Pages.app) + '?u=/people/' + wObj.owner.id;
        	wObj.owner.URL = linkUrl;
            	
            wObj.owner.name = userMap.get(artcleCreatedByIdMap.get(obj.id)).parent_user__r.size() > 0 ? userMap.get(artcleCreatedByIdMap.get(obj.id)).parent_user__r[0].full_name__c : userMap.get(artcleCreatedByIdMap.get(obj.id)).Name;
            String str = userMap.get(artcleCreatedByIdMap.get(obj.id)).smallphotourl;
            
            if (Str.endsWith('/005/T')) {
         		wObj.owner.profileImage = null;		
            
            } else {
            	wObj.owner.profileImage = str;
            }
            
            wObj.listOfVirtualTopics = new List<KnowledgeWrapper.VirtualTopicWrapper>();
	    	for (String currentArtcileId : mapOfIdWithListOfCategoriesArticle.keySet()) {
	    		List<SObject> listOfCategory = mapOfIdWithListOfCategoriesArticle.get(currentArtcileId);
	    		
	    		if (listOfCategory != null && !listOfCategory.isEmpty()) {
	    			
	    			for (SObject dataCategoryObj : listOfCategory) {
	    				String childCategoryName = (String)dataCategoryObj.get('DataCategoryName');
	    				String parentCategoryName = mapOfChildAndParentCategory.get(childCategoryName);
	    				KnowledgeWrapper.VirtualTopicWrapper virtaulTopicObj = new KnowledgeWrapper.VirtualTopicWrapper();
	    				
	    				Map<String, String> mapOfArguments = new Map<String, String>();
    			
	    				if (parentCategoryName != null ) {
	    					virtaulTopicObj.name = mapOfCategoryNameAndLabel.get(parentCategoryName) + ' > ' + mapOfCategoryNameAndLabel.get(childCategoryName);
				            mapOfArguments.put('categoryGroup', parentCategoryName);
	    					mapOfArguments.put('subCategory', childCategoryName);
	    				} else if(mapOfCategoryNameAndLabel.containsKey(childCategoryName)) {
	    					virtaulTopicObj.name = mapOfCategoryNameAndLabel.get(childCategoryName);
	    					mapOfArguments.put('categoryGroup', childCategoryName);
	    				} 
	    				if(mapOfArguments.size() > 0) {
		    				String knowledgeArticlesLink = PageContext.getPageURL(Pages.KnowledgeArticles, mapOfArguments);
			    			virtaulTopicObj.URL = knowledgeArticlesLink;
		    				wObj.listOfVirtualTopics.add(virtaulTopicObj);
	    				}
	    			}
	    			
	    		}
	    		
	    	}
	    	if(!SimpplrContext.KnowledgeArticleCustomFields.isEmpty()) {
	    		for(String fieldName:SimpplrContext.KnowledgeArticleCustomFields) {
	    			KnowledgeWrapper.CustomField customField = new KnowledgeWrapper.CustomField();
	    			customField.value =  (String)obj.get(fieldName);
	    			customField.label = mapofKnowledgeFields.get(fieldName).getDescribe().getLabel();
	    			wObj.listOfCustomFields.add(customField);
	    		}
	    	} 
            ArticleDetailList.add(wObj);
    	}
    	return ArticleDetailList; 
    }
    @TestVisible 
    private String getKnowledgeArticleDetailCustomFields() {
    	String customFields = '';
    	if(SimpplrContext.KnowledgeArticleCustomFields != null && !SimpplrContext.KnowledgeArticleCustomFields.isEmpty()) {
    		for(String fieldName : SimpplrContext.KnowledgeArticleCustomFields) {
    			customFields += fieldName + ', '; 
    		}
    	}
    	return customFields;
    }
    @TestVisible 
    private String replaceSmartLink(String description) {
		String regexFormat = '(?<=href=(\"|\'))[^\"\']+(?=(\"|\'))';
		Pattern myPattern = Pattern.Compile(regexFormat); 
		Matcher myMatch = myPattern.matcher(description);
		Map<String, String> mapURL= new Map<String, String>();
		while (myMatch.find()) {
			String articleLink = '/' + SimpplrContext.KnowledgeArticleType + '/';	
			if(String.isNotBlank(myMatch.group(0)) && myMatch.group(0).startsWith('/articles') && myMatch.group(0).containsIgnoreCase(articleLink) && myMatch.group(0).containsIgnoreCase('?articleId=')) {
				String urlName = myMatch.group(0).substringBetween(articleLink, '?articleId=');
				if(String.isNotBlank(urlName)) {
		    		mapURL.put(myMatch.group(0), urlName);
				}
			}
		}
		if(mapURL.size() > 0) {
			List<String> listOfURLs = mapURL.values();
			String queryLinkedArticles = 'Select Id, urlName From '+
						                 KNOWLEDGE_ARTICLE_VERSION_OBJECT+' Where Language =\''+KNOWLEDGE_LANGAUGE+'\''+
						                 ' AND PublishStatus =\''+KNOWLEDGE_PUBLISH_STATUS + '\''+' AND urlName =: listOfURLs';
                 
        	List<SObject> listOfGroupWithArticle = Database.query(queryLinkedArticles);
        	Map<String, String> mapOfURLNameAndArticleId = new Map<String, String>();  
        	for (SObject obj : listOfGroupWithArticle) {
        		mapOfURLNameAndArticleId.put((String)obj.get('urlName'), obj.id);
        	}    
			for (String fieldName : mapURL.keySet()){
				if(mapOfURLNameAndArticleId.containsKey(mapURL.get(fieldName))) {
			    	String strReplace = '/apex/knowledgearticledetail?articleId=' + mapOfURLNameAndArticleId.get(mapURL.get(fieldName));
			    	String strSearch = fieldName;
			    	description = description.replace(strSearch,strReplace);
				}
			}
		}		
		return description;
    }
    @TestVisible 
    private String dateToDisplayString(Object value,String format){
        String result = '';
        if(value != null){
          DateTime dateTimeValue;
          if(value instanceof Datetime){
            dateTimeValue = (Datetime)value;
          }else if(value instanceof Date){
            Date dateValue = (Date)value;
            dateTimeValue = Datetime.newInstance(dateValue.year(), dateValue.month(),dateValue.day());
          }
          result = dateTimeValue.format(format);  
        }
        return result;
    }
}