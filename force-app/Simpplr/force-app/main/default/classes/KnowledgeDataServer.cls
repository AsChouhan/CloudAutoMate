/**
* Class [KnowledgeDataServer] 
* Purpose:  [Fatching Data Category]
*
*/
public with sharing class KnowledgeDataServer extends DataServer {   
	
    @TestVisible private String DATA_CATEGORY_OBJECT = ServiceConstants.DEFAULT_DATA_CATEGORY + '__DataCategorySelection';
    @TestVisible private String KNOWLEDGE_ARTICLE_OBJECT = ServiceConstants.DEFAULT_DATA_CATEGORY + '__ka';
    @TestVisible private String KNOWLEDGE_ARTICLE_VERSION_OBJECT = ServiceConstants.DEFAULT_DATA_CATEGORY + '__kav';
    @TestVisible private string KnowledgeArticleType;
    @TestVisible private final String ARTICLE_DESCRIPTION_CUSTOM_FIELD = ServiceConstants.ARTICLE_BODY_CUSTOM_FIELD;
    @TestVisible private final String KNOWLEDGE_PUBLISH_STATUS = ServiceConstants.PUBLISH_STATUS;
    @TestVisible private final String KNOWLEDGE_LANGAUGE = ServiceConstants.LANGUAGE;
    @TestVisible private final String ACTION_SEARCH = 'search'; 
    @TestVisible private final String GET_ARTICLE_VERSION_OF_CATEGORY_GROUP = 'getAllArticles';
    @TestVisible private final String REQUEST_PARAM_CATEGORY_GROUP = 'categoryGroup';
    @TestVisible private final String REQUEST_PARAM_SUBCATEGORY_GROUP = 'subcategory';
	private final String REQUEST_PARAM_DATA = 'data';
    
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
     /** 
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */

    public override void handleRequest () { 
        try {
            String action = readParam(REQUEST_PARAM_ACTION); 
			String dataJSON = readParam(REQUEST_PARAM_DATA);
			Map<String,String> requestMap = (Map<String, String>)JSON.deserialize(dataJSON, Map<String,String>.class);   
            String categoryGroupName = requestMap.get(REQUEST_PARAM_CATEGORY_GROUP);  
            String subCategoryGroupName = requestMap.get(REQUEST_PARAM_SUBCATEGORY_GROUP);
            String searchTerm = requestMap.get('term'); 
            String pageSize = requestMap.get('size');
           	String nextPageToken = requestMap.get('nextPageToken');
           	
           	if (searchTerm != null) {
           		searchTerm = String.escapeSingleQuotes(searchTerm);
           	}
           	
            KnowledgeArticleType = SimpplrContext.KnowledgeArticleType;
	        
	        if (KnowledgeArticleType != null) {  
		        KNOWLEDGE_ARTICLE_OBJECT = KnowledgeArticleType + '__ka'; 
		        KNOWLEDGE_ARTICLE_VERSION_OBJECT = KnowledgeArticleType + '__kav';
		        DATA_CATEGORY_OBJECT = KnowledgeArticleType + '__DataCategorySelection';
       		}
       		if(ACTION_SEARCH.equalsIgnoreCase(action)) {
				if(String.isBlank(categoryGroupName)) {
       				response = getCategoriesWithCount(Integer.valueOf(pageSize), nextPageToken, searchTerm);
       			
        		} else {
                	response = getAllArticles(categoryGroupName, subCategoryGroupName,
                		Integer.valueOf(pageSize), nextPageToken, searchTerm);  
				}
            } 
            
         } catch (Exception ex) {
         	logger.logError('Exception occured ---- KnowledgeDataServer.handleRequest()', ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
         }
         
    }
    
    @TestVisible  
    private ResponseWrapper getCategoriesWithCount (Integer paginationSize, String nextPageToken,
    		String searchString) { 
		ResponseWrapper responseWrapperObj;
		try {
			List<String> listOfKnowledgeCategory = new List<String>();
			for(String categoryName : mapOfDataCategories.keySet()) {
				listOfKnowledgeCategory.add(categoryName + '__c');
			}
			
			String dataCategoryGroup = KnowledgeArticleType + '__c';
			String articleQuery = 'Select Id, KnowledgeArticleId, Title, Summary, LastModifiedDate, CreatedDate, createdbyId,'+
					' (Select DataCategoryGroupName, DataCategoryName From DataCategorySelections) From ' + 
					KNOWLEDGE_ARTICLE_VERSION_OBJECT+' WHERE Language =\''+KNOWLEDGE_LANGAUGE+'\'' +
					' AND PublishStatus =\''+KNOWLEDGE_PUBLISH_STATUS + '\''+
					' WITH DATA CATEGORY ' + dataCategoryGroup + ' BELOW ( ' + Utility.convertToCommaSeparatedString(listOfKnowledgeCategory) + ') '+
					' ORDER BY LastModifiedDate Desc limit 50000';
			
			List<SObject> listOfKnowledgeArticles = Database.query(articleQuery);
			Map<String, Set<String>> mapOfCategoryWithArticleIds = new Map<String, Set<String>>(); 
			Map<String, List<KnowledgeWrapper.ArticleWrapper>> mapOfCategoryAndListOfTopArticles = new Map<String, List<KnowledgeWrapper.ArticleWrapper>>();
			
			for (SObject articleObj : listOfKnowledgeArticles ) {
				KnowledgeWrapper.ArticleWrapper articleWrapObj = new KnowledgeWrapper.ArticleWrapper();
				articleWrapObj.id = (String)articleObj.get('KnowledgeArticleId');
				articleWrapObj.title = (String)articleObj.get('Title');
				articleWrapObj.summary = (String)articleObj.get('Summary');
				
				DateTime DateTimeValue = (DateTime)articleObj.get('CreatedDate');
				articleWrapObj.createdDate = DateTimeValue.format(ServiceConstants.DATETIME_FORMAT);
				
				DateTimeValue = (DateTime)articleObj.get('LastModifiedDate');
				articleWrapObj.lastModifiedDate = DateTimeValue.format(ServiceConstants.DATETIME_FORMAT);
				
				
				articleWrapObj.redirectURL = PageContext.getPageURL(Pages.KnowledgeArticleDetail, new Map<String, String>{'articleId'=> articleWrapObj.Id});
				
				List<KnowledgeWrapper.ArticleWrapper> listOfArticles;
				Set<String> setOfArticleIds;
				for (SObject articleCategoryObj : articleObj.getSObjects('DataCategorySelections')) {
					
					String categoryName = (String)articleCategoryObj.get('DataCategoryName');
					String parentCategoryName = mapOfChildAndParentCategory.get(categoryName);
					String key;
					if(parentCategoryName != null) {
						key = parentCategoryName;
					} else if(mapOfCategoryNameAndLabel.containsKey(categoryName)) {
						key = categoryName;
					}
					if(String.isNotBlank(key)) {
						if (mapOfCategoryWithArticleIds.containsKey(key)) {
							setOfArticleIds = mapOfCategoryWithArticleIds.get(key);
							listOfArticles = mapOfCategoryAndListOfTopArticles.get(key);
						} else {
							setOfArticleIds = new Set<String>();
							listOfArticles = new List<KnowledgeWrapper.ArticleWrapper>();
						}
						if(!setOfArticleIds.contains(articleWrapObj.id)) {
							setOfArticleIds.add(articleWrapObj.id);
							mapOfCategoryWithArticleIds.put(key, setOfArticleIds);
							if(listOfArticles.size() <3) {
								listOfArticles.add(articleWrapObj);
								mapOfCategoryAndListOfTopArticles.put(key, listOfArticles);
							}
						}
					}
				}
				
			}	
					
			List<KnowledgeWrapper.CategoryWrapper> listOfKnowledgeCategoryWrapper = new List<KnowledgeWrapper.CategoryWrapper>();
			
			if (!mapOfCategoryWithArticleIds.isEmpty()) {
				
				for (String categoryName : mapOfCategoryWithArticleIds.keySet()) {
					KnowledgeWrapper.CategoryWrapper categrogyWrapObj = new KnowledgeWrapper.CategoryWrapper();
						categrogyWrapObj.id = categoryName;
					categrogyWrapObj.label = mapOfCategoryNameAndLabel.get(categoryName);
					categrogyWrapObj.redirectURL = PageContext.getPageURL(Pages.KnowledgeArticles, new Map<String, String>{'categoryGroup'=> categoryName});
					categrogyWrapObj.totalArticle = mapOfCategoryWithArticleIds.get(categoryName).size();
					categrogyWrapObj.topArticles = mapOfCategoryAndListOfTopArticles.get(categoryName);
					listOfKnowledgeCategoryWrapper.add(categrogyWrapObj);
				}
				listOfKnowledgeCategoryWrapper.sort();
				
			}
			
			KnowledgeWrapper.CategoryPaginationWrapper paginatorObj = new KnowledgeWrapper.CategoryPaginationWrapper();
			paginatorObj.listOfItems.addAll(listOfKnowledgeCategoryWrapper);
			Integer offSet = 0;
			
			if (String.isNotBlank(nextPageToken)) {
				offSet = Integer.valueOf(nextPageToken);
			}
			
			if (paginatorObj.listOfItems.size() > paginationSize) {
				paginatorObj.nextPageToken = String.valueOf(offset + paginationSize);
				
			} else {
				paginatorObj.nextPageToken = null;
			}
			
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'All category!', paginatorObj);
		} catch(exception e){
			logger.logError('Exception occured ---- nowledgeDataServer.getCategoriesWithCount()', e);
  			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		 
		return responseWrapperObj;
    }
    
    
    @TestVisible  
    private ResponseWrapper getAllArticles (String categoryGroupArg, String subCategoryArg, 
    	Integer paginationSize, String nextPageToken, String searchString) {
		ResponseWrapper responseWrapperObj;
		try { 
			String knowledgeArticleType = SimpplrContext.KnowledgeArticleType;
			List<KnowledgeWrapper.ArticleWrapper> listOfArticleWrapper = new List<KnowledgeWrapper.ArticleWrapper>();
			String articleQuery = '';
			
			if (subCategoryArg != null &&  subCategoryArg.equalsIgnoreCase('allArticlesOfCategory')) {
				subCategoryArg = null;
			}
			
			Set<Id> setOfFilterdArticleId = new set<Id>();
			Set<String> searchTokens = new Set<String>();
			if (String.isNotBlank(searchString)) {
				searchTokens = Utility.getSearchTokens(String.escapeSingleQuotes(searchString));
				String articleSOSLStr = Utility.generateStringForSOSLQuery(searchTokens);
				articleSOSLStr = 'FIND {' + articleSOSLStr + '} IN ALL FIELDS RETURNING '+KNOWLEDGE_ARTICLE_VERSION_OBJECT+
						'(Id WHERE Language =\''+KNOWLEDGE_LANGAUGE+'\'' +
						' AND PublishStatus =\''+KNOWLEDGE_PUBLISH_STATUS + '\''+ ' ORDER BY LastModifiedDate Desc )'+
						' limit 2000';
					
				List<List<SObject>> listOfSearchObjects = Search.query(articleSOSLStr);
				if (!listOfSearchObjects.isEmpty()) {
					if (!listOfSearchObjects[0].isEmpty()) {
						
						for (SObject articleObj :listOfSearchObjects[0]) {
							setOfFilterdArticleId.add(articleObj.Id);
						}
					}
				}
			} 
			
			
			articleQuery = 'Select Id, KnowledgeArticleId, CreatedById, Summary, Title, LastModifiedDate, CreatedDate,'+
					' createdBy.name, createdBy.smallPhotoURL ,'+
					' (Select DataCategoryGroupName, DataCategoryName From DataCategorySelections) From ' + 
					KNOWLEDGE_ARTICLE_VERSION_OBJECT+' WHERE Language =\''+KNOWLEDGE_LANGAUGE+'\'' +
					' AND PublishStatus =\''+KNOWLEDGE_PUBLISH_STATUS + '\'';
						
			if (searchTokens.size() > 0) {
				articleQuery += ' And (Id IN:setOfFilterdArticleId ';
				for(String searchToken: searchTokens){
					articleQuery += ' OR Title LIKE \'%' + searchToken + '%\'  OR Summary LIKE \'%' + searchToken + '%\'';
				}
				articleQuery += ') ';
			} else if(String.isNotBlank(subCategoryArg) && !'allArticlesOfCategory'.equalsIgnoreCase(subCategoryArg)) {
				articleQuery += ' WITH DATA CATEGORY ' + knowledgeArticleType + '__c below ' + String.escapeSingleQuotes(subCategoryArg) + '__c ';
				
			} else if(String.isNotBlank(categoryGroupArg) && !'AllKnowledgeArticles'.equalsIgnoreCase(categoryGroupArg)) {
				articleQuery += ' WITH DATA CATEGORY ' + knowledgeArticleType + '__c below ' + String.escapeSingleQuotes(categoryGroupArg) + '__c ';
				
			}
			articleQuery += ' ORDER BY LastModifiedDate Desc  limit 50000';
			List<SObject> listOfKnowledgeArticles = Database.query(articleQuery);
			Double score = 2.0;
			for (SObject articleObj : listOfKnowledgeArticles ) {
					
				KnowledgeWrapper.ArticleWrapper articleWrapObj = new KnowledgeWrapper.ArticleWrapper();
				score = score - 0.001;
				articleWrapObj.relevancyScore = score;
				articleWrapObj.title = (String)articleObj.get('Title');
				articleWrapObj.summary = (String)articleObj.get('Summary');
				articleWrapObj.id = (String)articleObj.get('KnowledgeArticleId');
				articleWrapObj.authorId = (String)articleObj.get('createdById');
				articleWrapObj.authorName = (String)articleObj.getSobject('createdBy').get('Name');
				String authorImageURL = (String)articleObj.getSobject('createdBy').get('smallPhotoURL');
				
				if (authorImageURL.endsWith('/005/T')) {
					articleWrapObj.authorImage = null;			
					articleWrapObj.authorNamesFirstLetter = articleWrapObj.authorName.substring(0, 1);
					
				} else {
					articleWrapObj.authorImage = authorImageURL;
				}
				
				articleWrapObj.subcategory = subCategoryArg;
				articleWrapObj.category = categoryGroupArg;
				
				Map<String, String> args = new Map<String, String>();
				args.put('profileId', articleWrapObj.authorId);
				String linkUrl = PageContext.getPageURL(Pages.app) + '?u=/people/' + articleWrapObj.authorId;
				articleWrapObj.authorURL = linkUrl;
				
				Map<String, String> articalDetailArgs = new Map<String, String>();
				articalDetailArgs.put('articleId', articleWrapObj.Id);
				String articleDetailUrl = PageContext.getPageURL(Pages.KnowledgeArticleDetail, articalDetailArgs);
				articleWrapObj.redirectURL = articleDetailUrl;
				
				
				DateTime DateTimeValue = (DateTime)articleObj.get('CreatedDate');
				articleWrapObj.createdDate = DateTimeValue.format(ServiceConstants.DATETIME_FORMAT);
				
				DateTimeValue = (DateTime)articleObj.get('LastModifiedDate');
				articleWrapObj.lastModifiedDate = DateTimeValue.format(ServiceConstants.DATETIME_FORMAT);
				List<SObject> listOfCategory = articleObj.getSObjects('DataCategorySelections');

				articleWrapObj.listOfVirtualTopics = new List<KnowledgeWrapper.VirtualTopicWrapper>();
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
							articleWrapObj.listOfVirtualTopics.add(virtaulTopicObj);
						}
					}
					
				}
				if(searchTokens.size() > 0) {
					articleWrapObj.relevancyScore += calcualteArticleScore(articleWrapObj, searchTokens); 
				}
				listOfArticleWrapper.add(articleWrapObj);
			}
			if (String.isNotBlank(searchString)) {
				listOfArticleWrapper.sort();
			}    
			
			KnowledgeWrapper.ArticlePaginationWrapper paginatorObj = new KnowledgeWrapper.ArticlePaginationWrapper();
			Integer offSet = 0;
			
			if (String.isNotBlank(nextPageToken)) {
				offSet = Integer.valueOf(nextPageToken);
			}
			
			paginatorObj.listOfItems = new List<KnowledgeWrapper.ArticleWrapper>();
			
			if (listOfArticleWrapper.size() > (offSet + paginationSize)) {
				paginatorObj.nextPageToken = String.valueOf(offset + paginationSize);
				Integer counter = offSet;
				
				for (; counter < (offSet + paginationSize) ;  counter++) {
					paginatorObj.listOfItems.add(listOfArticleWrapper[counter]);
				}
				
				
			} else {
				paginatorObj.nextPageToken = null; 
				Integer counter = offSet;
				
				for (; counter < listOfArticleWrapper.size() ;  counter++) {
					paginatorObj.listOfItems.add(listOfArticleWrapper[counter]);
				}
				
			}
			
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'All Articles returned!', paginatorObj);
		
		} catch(exception e){
			logger.logError('Exception occured ---- KnowledgeDataServer.getAllArticles()', e);
  			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}

        return responseWrapperObj;
    }
    @TestVisible 
    private Integer calcualteArticleScore(KnowledgeWrapper.ArticleWrapper articleWrapperObj, Set<String> searchTokens) {
    	Integer score=0;
		
    	Integer TITLE_WEIGHT_EXACT_MATCH=1000;
    	Integer TITLE_WEIGHT_STARTS_WITH=10;
    	Integer TITLE_WEIGHT_CONTAINS_IT=10;
    	
    	Integer SUMMARY_WEIGHT_EXACT_MATCH=1000;
    	Integer SUMMARY_WEIGHT_STARTS_WITH=1;
    	Integer SUMMARY_WEIGHT_CONTAINS_IT=1;
    	
    	Integer TOPIC_WEIGHT_EXACT_MATCH=100;
    	Integer TOPIC_WEIGHT_STARTS_WITH=1;
    	Integer TOPIC_WEIGHT_CONTAINS_IT=1;
    	
    	Integer MULTIPLICATION_FACTOR_TITLE_EXACT_MATCH=3;
    	Integer MULTIPLICATION_FACTOR_TITLE_STARTS_WITH=2;
    	Integer MULTIPLICATION_FACTOR_TITLE_CONTAINS_IT=1;
    	
    	Integer MULTIPLICATION_FACTOR_OTHERS_EXACT_MATCH=3;
    	Integer MULTIPLICATION_FACTOR_OTHERS_STARTS_WITH=2;
    	Integer MULTIPLICATION_FACTOR_OTHERS_CONTAINS_IT=1;
    	
    	for(String searchToken: searchTokens){
    		if(String.isNotBlank(articleWrapperObj.title)){
    			if(articleWrapperObj.title.equalsIgnoreCase(searchToken)){
    				score= score+(TITLE_WEIGHT_EXACT_MATCH*MULTIPLICATION_FACTOR_TITLE_EXACT_MATCH);
    			} else if(articleWrapperObj.title.startsWithIgnoreCase(searchToken)){
    				score= score+(TITLE_WEIGHT_STARTS_WITH*MULTIPLICATION_FACTOR_TITLE_STARTS_WITH);
    			} else if(articleWrapperObj.title.containsIgnoreCase(searchToken)) {
    				score= score+(TITLE_WEIGHT_CONTAINS_IT*MULTIPLICATION_FACTOR_TITLE_CONTAINS_IT);
    			}
			}
			
			if(String.isNotBlank(articleWrapperObj.summary)){
    			if(articleWrapperObj.summary.equalsIgnoreCase(searchToken)){
    				score= score+(SUMMARY_WEIGHT_EXACT_MATCH*MULTIPLICATION_FACTOR_OTHERS_EXACT_MATCH);
    			} else if(articleWrapperObj.summary.startsWithIgnoreCase(searchToken)){
    				score= score+(SUMMARY_WEIGHT_STARTS_WITH*MULTIPLICATION_FACTOR_OTHERS_STARTS_WITH);
    			} else if(articleWrapperObj.summary.containsIgnoreCase(searchToken)) {
    				score= score+(SUMMARY_WEIGHT_CONTAINS_IT*MULTIPLICATION_FACTOR_OTHERS_CONTAINS_IT);
    			}
			}
			for(KnowledgeWrapper.VirtualTopicWrapper topicObj: articleWrapperObj.listOfVirtualTopics) {
				if(String.isNotBlank(topicObj.name)) {
					if(topicObj.name.equalsIgnoreCase(searchToken)){
    					score= score+(TOPIC_WEIGHT_EXACT_MATCH*MULTIPLICATION_FACTOR_OTHERS_EXACT_MATCH);
	    			} else if(topicObj.name.startsWithIgnoreCase(searchToken)){
	    				score= score+(TOPIC_WEIGHT_STARTS_WITH*MULTIPLICATION_FACTOR_OTHERS_STARTS_WITH);
	    			} else if(topicObj.name.containsIgnoreCase(searchToken)) {
	    				score= score+(TOPIC_WEIGHT_CONTAINS_IT*MULTIPLICATION_FACTOR_OTHERS_CONTAINS_IT);
	    			}
				}
			}
    	}
		return score;
    } 
}