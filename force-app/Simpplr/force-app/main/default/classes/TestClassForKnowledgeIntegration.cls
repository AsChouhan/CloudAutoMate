@isTest
private class TestClassForKnowledgeIntegration {
    @testSetup static void setup() {
    	TestHelper.setupAppConfig();
    }
    
    @isTest static void testmethods() {
    	App_config__c appConfig = KnowledgeArticleDetailCtrl.appConfig;
    	appConfig = KnowledgeDataServer.appConfig;
    	appConfig = KnowledgeArticlesCtrl.appConfig;
    	
		PageReference pageRef = Page.KnowledgeArticleDetail;
        Test.setCurrentPage(pageRef);
    	
    	Map<String, KnowledgeWrapper.DataCategoryWrapper> mapOfCategories = KnowledgeArticleDetailCtrl.mapOfDataCategories;
    	mapOfCategories = KnowledgeDataServer.mapOfDataCategories;
    	mapOfCategories = KnowledgeArticlesCtrl.mapOfDataCategories;
    	
    	Map<String, String>  stringMap = KnowledgeArticleDetailCtrl.mapOfChildAndParentCategory;
    	stringMap = KnowledgeDataServer.mapOfChildAndParentCategory;
    	
    	stringMap = KnowledgeArticleDetailCtrl.mapOfCategoryNameAndLabel;
    	stringMap = KnowledgeDataServer.mapOfCategoryNameAndLabel;
    	
    	String strVal = KnowledgeArticleDetailCtrl.pageName;
    	strVal = KnowledgeArticlesCtrl.pageName;
    	
    	KnowledgeArticleDetailCtrl ctrlObj = new KnowledgeArticleDetailCtrl();
    	strVal = ctrlObj.knowledgeHomeURL;
    	strVal = ctrlObj.defaultParamString;
    	strVal = ctrlObj.resourcePath;
    	strVal = ctrlObj.getPageTitle();
    	ctrlObj.handleRequest();
    	ctrlObj.getKnowledgeArticleDetailCustomFields();
    	strVal = ctrlObj.replaceSmartLink('<a href="https://Www.simpplr.com?articleId=dummyId">linkName</a>');
    	strVal = ctrlObj.dateToDisplayString(DateTime.now(), 'YYYY');
    	strVal = ctrlObj.dateToDisplayString(Date.Today(), 'YYYY');
    	
    	KnowledgeArticlesCtrl knowledgeArticlesCtrlObj = new KnowledgeArticlesCtrl();
    	strVal = knowledgeArticlesCtrlObj.knowledgeHomeURL;
    	strVal = knowledgeArticlesCtrlObj.defaultParamString;
    	strVal = knowledgeArticlesCtrlObj.resourcePath;
    	knowledgeArticlesCtrlObj.handleRequest();
    	knowledgeArticlesCtrlObj.getfilterWrapperList('Human Resource', 'Policy');
    	
    	KnowledgeWrapper.ArticleWrapper wrapperObj = new KnowledgeWrapper.ArticleWrapper();
    	wrapperObj.title = 'Dummy';
    	wrapperObj.summary = 'Dummy';
    	KnowledgeWrapper.VirtualTopicWrapper topicObj = new KnowledgeWrapper.VirtualTopicWrapper(); 
    	topicObj.Name = 'Dummy';
    	wrapperObj.listOfVirtualTopics = new List<KnowledgeWrapper.VirtualTopicWrapper>{topicObj};
    	
		pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target', 'KnowledgeDataServer');
        Test.setCurrentPage(pageRef);
    	KnowledgeDataServer dataServerObj = new KnowledgeDataServer();
    	dataServerObj.calcualteArticleScore(wrapperObj, new Set<String>{'Dummy','ADummy','"Dummy"'});
    	
    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testHandleRequest() {
        Test.startTest();
        App_Config__c appConfig = TestHelper.getAppConfig();
        appConfig.Knowledge_Article_Type__c = 'TestKnowledgeArticle';
        update appConfig;
        KnowledgeDataServer dataServerObj = new KnowledgeDataServer();
        
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','KnowledgeDataServer');
        Test.setCurrentPage(pgRef);
        
        pgRef.getParameters().put('nextPageToken','10');
        pgRef.getParameters().put('pageSize','16');
        pgRef.getParameters().put('searchString','test');
        pgRef.getParameters().put('categoryGroup','testCategory');
        pgRef.getParameters().put('subCategory','allArticlesOfCategory');
        
        pgRef.getParameters().put('action','getCategoriesWithCount');
        dataServerObj.handleRequest();
        
        pgRef.getParameters().put('action','getAllArticles');
        dataServerObj.handleRequest();
        
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testGetAllArticles() {
        Test.startTest();
        
        KnowledgeDataServer dataServerObj = new KnowledgeDataServer();
        dataServerObj.getAllArticles('testCategory', 'allArticlesOfCategory', 16, '10', 'test');
        
        System.assert(true,'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testGetCategoriesWithCount() {
        Test.startTest();
                
        Map<String, KnowledgeWrapper.DataCategoryWrapper> dataCategoryWrapperMap = new Map<String, KnowledgeWrapper.DataCategoryWrapper>();
        KnowledgeWrapper.DataCategoryWrapper dataCategoryWrapperObj = new KnowledgeWrapper.DataCategoryWrapper();
        dataCategoryWrapperObj.label = 'testLabel';
        dataCategoryWrapperObj.name = 'test';
        
        Map<String, KnowledgeWrapper.DataCategoryWrapper> subCategoryMap = new Map<String, KnowledgeWrapper.DataCategoryWrapper>();
        KnowledgeWrapper.DataCategoryWrapper subCategoryWrapperObj = new KnowledgeWrapper.DataCategoryWrapper();
        subCategoryWrapperObj.label = 'testsubCategory';
        subCategoryWrapperObj.name = 'subCategory';
        subCategoryMap.put('subCategoryMap',subCategoryWrapperObj);
        dataCategoryWrapperObj.mapofSubCategories = subCategoryMap;
        
        dataCategoryWrapperMap.put('map',dataCategoryWrapperObj);
        
        App_Config__c appConfig = TestHelper.getAppConfig();
        appConfig.Knowledge_Article_Data_Categories__c = Json.serialize(dataCategoryWrapperMap);
        update appConfig;
        Map<String, KnowledgeWrapper.DataCategoryWrapper> mapOfCategories = KnowledgeDataServer.mapOfDataCategories;
        
        Map<String, String>  stringMap = KnowledgeDataServer.mapOfChildAndParentCategory;
        stringMap = KnowledgeDataServer.mapOfCategoryNameAndLabel;
        
        KnowledgeDataServer dataServerObj = new KnowledgeDataServer();
        dataServerObj.getCategoriesWithCount(16, '10', 'test');
        
        System.assert(true,'Running as Expected');
        Test.stopTest();
    }
    
}