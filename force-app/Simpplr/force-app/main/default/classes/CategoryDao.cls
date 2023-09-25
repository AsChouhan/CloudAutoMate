public with sharing class CategoryDao {
	

    public CategoryDao() {

    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public Map<Id,Pages_Category__c> getCategoryMap4Site(String siteId){
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1', siteId);
        String pageCtgryQuery = 'SELECT Name__c,Order__c,Site__c,Site__r.name,CreatedDate,CreatedById,CreatedBy.Name FROM Pages_Category__c WHERE Site__c =:soqlParam1 AND Is_Deleted__c = false';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        return New Map<Id,Pages_Category__c>((List<Pages_Category__c>)SIMPESAPI.accessController().queryAsUser(pageCtgryQuery, soqlParamMap));
    }

    /**
     * @description create duplicatePageCategory
     * @param originalSiteId - containing site id of original site
     * @param duplicateSiteId - containg site id of duplicate site
     */
    public void duplicatePageCategory(String originalSiteId, String duplicateSiteId){
        Map<Id, Pages_Category__c> categoryMap = getCategoryMap4Site(originalSiteId);
        List<Pages_Category__c> pageCatList = new List<Pages_Category__c>();
        for(Pages_Category__c catObj : categoryMap.values()) {
            if('Uncategorized'.equalsIgnoreCase(catObj.Name__c)) {
                continue;
            }
            Pages_Category__c dupCatObj = new Pages_Category__c();
            dupCatObj.Name__c = catObj.Name__c;
            dupCatObj.Site__c = duplicateSiteId;
            dupCatObj.Order__c = catObj.Order__c;
            pageCatList.add(dupCatObj);
        }
        if(pageCatList.size() > 0) {
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().insertAsUser(pageCatList, new List<Schema.SObjectField>{Pages_Category__c.Name__c,
                                                                                                    Pages_Category__c.Site__c,
                                                                                                    Pages_Category__c.Order__c});
        }
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public Map<Id,Site_Category__c> getSiteCategoriesMap(){
        String query = 'SELECT Name__c, Order__c, CreatedDate, CreatedById, CreatedBy.Name ' +
            ' FROM Site_Category__c WHERE Is_Deleted__c = false';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        return New Map<Id,Site_Category__c>((List<Site_Category__c>)SIMPESAPI.accessController().queryAsUser(query, null));
    }
    
    public void updateSiteCategoryPosition(List<Site_Category__c> updatedCategoriesList) {
    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id,Site_Category__c>(updatedCategoriesList),new List<Schema.SObjectField>{
	    													Site_Category__c.Order__c
    													});
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public boolean removePageCategories(List<String> recordIds){
        try{
            List<Pages_Category__c> updatedCategoriesList = new List<Pages_Category__c>();

            for(String categoryId : recordIds) {
			    Pages_Category__c pageCatObj = new Pages_Category__c(Id= categoryId, Is_Deleted__c = true);
                updatedCategoriesList.add(pageCatObj);
            }
            
			//update simContent;
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    		SIMPESAPI.accessController().updateAsUser(new Map<Id,Pages_Category__c>(updatedCategoriesList),new List<Schema.SObjectField>{Pages_Category__c.Is_Deleted__c});

			return true; 
		}
        catch(Exception e) {
			return false;
		}
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public List<Pages_Category__c> getCategoryListFromCriteria(String siteId, String searchText, String orderByField, String order, Integer recordLimit, Integer offsetVal, Set<Id> siteIdSet, Boolean isAppModerator){
    	List<String> fieldList = New List<String>{
            'Name__c',
            'Order__c',
            'Site__c', 
            'Site__r.name', 
            'CreatedDate',
            'CreatedById',
            'CreatedBy.Name'
        };
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        String conditionString = '';
        conditionString += ' Site__c != null';
        conditionString += ' And Site__r.Is_Active__c = true';
        conditionString += ' And Site__r.Show_In_Simpplr__c = true';
        
        if(String.isNotBlank(searchText)){
            searchText = '%' + searchText + '%';
            soqlParamMap.put('soqlParam1', searchText);
            conditionString+=' AND Name__c like:soqlParam1';
        }
        if(String.isNotBlank(siteId)){
            soqlParamMap.put('soqlParam2', siteId);
            conditionString+=' AND Site__c =:soqlParam2';
        } else if(!isAppModerator){
        	siteIdSet = (siteIdSet == null || siteIdSet.size() == 0) ? New Set<Id>() :siteIdSet;
            soqlParamMap.put('soqlParam3', siteIdSet);
            conditionString += ' AND site__c IN:soqlParam3';
        }
        conditionString += ' AND Is_Deleted__c = false';
        conditionString = !conditionString.equals('')?' WHERE'+conditionString : '';
        String subConditionString = '';
        if(String.isBlank(order)){
            order = 'DESC';
        }
        if(String.isNotBlank(orderByField)){
            subConditionString+=' ORDER BY '+orderByField+' '+order;
        }
        if(recordLimit != null && recordLimit > 0){
            soqlParamMap.put('soqlParam4', recordLimit);
            subConditionString+=' LIMIT :soqlParam4';
        }
        if(offsetVal != null && offsetVal > 0){
            soqlParamMap.put('soqlParam5', offsetVal);
            subConditionString+=' OFFSET :soqlParam5';
        }
        
        //  not needed.. '+PageContext.namespacePrefix+' 
        String query = 'SELECT '+String.join(fieldList,',')+' FROM Pages_Category__c'+conditionString+subConditionString;
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        return (List<Pages_Category__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
    }

    public List<Pages_Category__c> getCategoryListFromIds(List<String> catIdsToFilterFrom, String orderByField, String order) {
    	List<String> fieldList = New List<String>{
            'Name__c',
            'Order__c',
            'Site__c', 
            'Site__r.name', 
            'CreatedDate',
            'CreatedById',
            'CreatedBy.Name'
        };
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        String conditionString = '';
        conditionString += ' Site__c != null';
        conditionString += ' AND Site__r.Is_Active__c = true';
        conditionString += ' AND Site__r.Show_In_Simpplr__c = true';
        conditionString += ' AND Is_Deleted__c = false';

        soqlParamMap.put('soqlParam1', catIdsToFilterFrom);
        conditionString += ' AND Id = :soqlParam1';

        conditionString = !conditionString.equals('')?' WHERE'+conditionString : '';

        String orderString = '';
        if(String.isBlank(order)){
            order = 'DESC';
        }
        if(String.isNotBlank(orderByField)){
            orderString+=' ORDER BY '+orderByField+' '+order;
        }
       
        String query = 'SELECT ' + String.join(fieldList,',') + ' FROM Pages_Category__c' + conditionString + orderString;
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        return (List<Pages_Category__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public SiteListingWrapper getUncategorizedSiteCategory() {
		SiteListingWrapper siteObjWrapper = new SiteListingWrapper();
		
		String categoryName = ServiceConstants.UNCATEGORIZED_CATEGORY_STR;
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1', categoryName);
        String query = 'Select Id, Name__c from Site_Category__c where Name__c = :soqlParam1 and Is_Deleted__c = false';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    	List<Site_Category__c> siteCategoryList = (List<Site_Category__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
    	
    	if( ! siteCategoryList.isEmpty() ) {
    		siteObjWrapper.category.id = siteCategoryList[0].Id;
    		siteObjWrapper.category.name = siteCategoryList[0].Name__c;
    		siteObjWrapper.category.url = PageContext.getPageURL(Pages.app)+'?u=/sites/category?category=' + siteCategoryList[0].Id;
    	}
    	
		return siteObjWrapper;
    }

    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<Site_Category__c> getCategoriesWithId (List<String> categoryIds) {
		String queryString = 'SELECT name, Name__c,Order__c, access__c, LastModifiedDate, ' + 
            '(SELECT id, name, site_type__c, Chatter_Group_Id__c  ' + 
            ' from Simpplr_Sites_Site_Category__r where is_Deleted__c=false ' + 
            ' AND Is_Active__c=true and Show_In_Simpplr__c = true )' + 
            ' FROM Site_Category__c Where id IN :soqlParam1';
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1', categoryIds);
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
        return (List<Site_Category__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<Site_Category__c> getCategoriesWithSiteCount (String searchTerm, String sortBy, Integer recordLimit, Integer offsetVal) {
		Set<Id> setOfCollabGroupIds = new Set<Id>();
		String BASE_QUERY = 'select Id from CollaborationGroup where IsArchived = false';
		
		if(SimpplrContext.isCommunitiesEnabled){
	    		BASE_QUERY = BASE_QUERY+' AND NetworkId = null';
	    }
		Map<Id, CollaborationGroup> mapOfChatterGroups = new Map<Id, CollaborationGroup>((List<CollaborationGroup>)Database.query(BASE_QUERY));
		
		setOfCollabGroupIds = mapOfChatterGroups.keySet();

        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1', setOfCollabGroupIds);
        String queryString = 'SELECT name, Name__c,Order__c, access__c, LastModifiedDate, ' + 
                '(SELECT id, name, site_type__c, Chatter_Group_Id__c  ' + 
                ' from Simpplr_Sites_Site_Category__r where is_Deleted__c=false ' + 
                ' AND Is_Active__c=true and Show_In_Simpplr__c = true and ' + 
                ' Chatter_Group_id__c IN :soqlParam1 ORDER BY Name ASC) ' + 
                ' FROM Site_Category__c';
		
		String conditionString = '';
		String subConditionString = '';
		conditionString += ' Is_Deleted__c = false'	;
		
		if (String.isBlank(sortBy) || sortBy.equalsIgnoreCase('alphabetical')) {
			subConditionString += ' ORDER BY Name__c ASC';
		}else if (sortBy.equalsIgnoreCase('latest')){
			subConditionString += ' ORDER BY lastModifiedDate DESC, Name__c ASC';
		}else if(sortBy.equalsIgnoreCase('natural')){
			subConditionString += ' ORDER BY Order__c, Name__c ASC';
		}
		
		
		if(recordLimit != null && recordLimit > 0) {
            soqlParamMap.put('soqlParam2', recordLimit);
            subConditionString +=' LIMIT :soqlParam2';
        }
        if(offsetVal != null && offsetVal > 0) {
            soqlParamMap.put('soqlParam3', offsetVal);
            subConditionString +=' OFFSET :soqlParam3';
        }
		
		if(String.isNotBlank(searchTerm)) {
			searchTerm = '%' + searchTerm + '%';
            soqlParamMap.put('soqlParam4', searchTerm);
			conditionString += ' AND Name__c like :soqlParam4';
		}
		conditionString = !conditionString.equals('')?' WHERE'+conditionString : '';
		queryString += conditionString + subConditionString;
        
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
        return (List<Site_Category__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);
	}
	
	public Site_Category__c getCategoryWithSiteCountById(String categoryId){
		String queryString = 'SELECT name, Name__c, access__c, (SELECT id from Simpplr_Sites_Site_Category__r where is_Deleted__c=false AND Is_Active__c=true) FROM Site_Category__c WHERE id = \'' + categoryId + '\'';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        return ((List<Site_Category__c>)SIMPESAPI.accessController().queryAsUser(queryString, null))[0];
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public Site_Category__c addSiteCategory(String categoryName){
		Site_Category__c categoryObj= new Site_Category__c();
		categoryObj.Name=categoryName;
		categoryObj.Name__c=categoryName;
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		categoryObj = (Site_Category__c)SIMPESAPI.accessController().insertAsUser(categoryObj,new List<Schema.SObjectField>{Site_Category__c.Name,Site_Category__c.Name__c});
		
		return categoryObj;
	}
	
	public ManageApplicationWrapper.ManageSitesCategoryWrapper saveSiteCategory(ManageApplicationWrapper.ManageSitesCategoryWrapper siteCategoryWrapperObj){
		Site_Category__c categoryObj = new Site_Category__c();
		
		categoryObj.Name = siteCategoryWrapperObj.name;
		categoryObj.Name__c = siteCategoryWrapperObj.name;
		categoryObj.access__c = siteCategoryWrapperObj.access;
		categoryObj.id = siteCategoryWrapperObj.id;
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Schema.SObjectField> sobjectFieldList =  new List<Schema.SObjectField>{
																					Site_Category__c.Name,
																					Site_Category__c.Name__c,
																					Site_Category__c.access__c};
		
		if(String.isBlank(categoryObj.id)){
			categoryObj = (Site_Category__c)SIMPESAPI.accessController().insertAsUser(categoryObj, sobjectFieldList);
		} else {
			categoryObj = (Site_Category__c)SIMPESAPI.accessController().updateAsUser(categoryObj, sobjectFieldList);
		}
		
		siteCategoryWrapperObj.id = categoryObj.Id;
		siteCategoryWrapperObj.categoryId = categoryObj.Id;
		
		return siteCategoryWrapperObj;
	}
	
	public Integer checkDuplicateSiteCategoryName(String categoryName, String categoryId){
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1', categoryName);
        soqlParamMap.put('soqlParam2', categoryId);
        String query = 'Select Id, Name__c from Site_Category__c where Name__c =:soqlParam1 and Id != :soqlParam2 AND Is_Deleted__c = false';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<Site_Category__c> listOFCategories = (List<Site_Category__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
	
		if(listOFCategories.size()>0){
			return 1;
		}
		else {
			return 2;
		}
	}

	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public Boolean deleteCategory(Set<String> setOfCategoryIds){
		Boolean returnValue = false; 
		List<Site_Category__c> listOfSiteCatgories= new List<Site_Category__c>();
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1', setOfCategoryIds);
        String query = 'SELECT ID, Is_Deleted__c  from Site_Category__c WHERE id =:soqlParam1';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        listOfSiteCatgories = (List<Site_Category__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		if(!listOfSiteCatgories.isEmpty()) {
            for(Site_Category__c listOfSiteCatgoriesObj : listOfSiteCatgories) {
            	listOfSiteCatgoriesObj.Is_Deleted__c = true;
            }
            
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(new Map<Id,Site_Category__c>(listOfSiteCatgories),new List<Schema.SObjectField>{
	    													Site_Category__c.Is_Deleted__c
    													});
    		
    		removeCategoryFromInactiveSites(setOfCategoryIds);
    		returnValue = true;
        }
        return returnValue;
	}
	//select name, (select id from Simpplr_Sites_Site_Category__r) from site_category__c where is_deleted__c = false
	
	private Boolean removeCategoryFromInactiveSites(Set<String> setOfCategoryIds) {
		List<Simpplr_Site__c> listOfSites= [SELECT ID, Site_Category__c from Simpplr_Site__c WHERE Site_Category__c =: setOfCategoryIds AND Is_Active__c = false WITH SECURITY_ENFORCED];
		if(!listOfSites.isEmpty()) {
            for(Simpplr_Site__c siteObj : listOfSites) {
            	siteObj.Site_Category__c = null;
            }
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
            SIMPESAPI.accessController().updateAsUser(new Map<Id,Simpplr_Site__c>(listOfSites),new List<Schema.SObjectField>{
	    													Simpplr_Site__c.Site_Category__c
    													});
        }
		
		return true;
	}
	
	public void updateCategoryPosition(List<Pages_Category__c> updatedCategoriesList) {
    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id,Pages_Category__c>(updatedCategoriesList),new List<Schema.SObjectField>{
	    													Pages_Category__c.Order__c
    													});
    	
    }

    public Pages_Category__c getCategoryWithId(String pageCategoryId) {
        Pages_Category__c pageCategoryObj = null;
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1', pageCategoryId);
        String pageCtgryQuery = 'SELECT Id, Name__c, Site__c, OwnerId, Is_Deleted__c, Order__c, CreatedById, CreatedDate FROM Pages_Category__c where Id =:soqlParam1 AND Is_Deleted__c = false LIMIT 1';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<Pages_Category__c> pageCategoryList = (List<Pages_Category__c>)SIMPESAPI.accessController().queryAsUser(pageCtgryQuery, soqlParamMap);
        if(!pageCategoryList.isEmpty()){
            pageCategoryObj = pageCategoryList[0];
        }
        return pageCategoryObj;
    }
}