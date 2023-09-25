/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/ 
public with sharing class CategoryDataServer extends DataServer{
	public transient final String STR_ERROR_DELETE_UNCATEGORIES { get { return labelMap.get('manage_page_categories.delete.uncategorized_error_flash');}}
	public transient final String STR_ERROR_DELETE_NOT_EMPTY { get { return labelMap.get('manage_page_categories.delete.not_empty_error_flash');}}
	public transient final String STR_ERROR_EDIT_UNCATEGORIES  { get { return labelMap.get('manage_page_categories.edit.uncategorized_error_flash');}}
	public transient final String STR_ERROR_EDIT_DUPLICATE { get { return labelMap.get('manage_page_categories.add.duplicate_error_flash');}}
	
	private PageDao pageDaoObj;
	@testVisible private final String ACTION_VALUE_SEARCH = 'search';
	@testVisible private final String ACTION_VALUE_DELETE = 'delete';
	@testVisible private final String ACTION_VALUE_EDIT = 'edit';
	@testVisible private final String ACTION_VALUE_CREATE = 'create';
	@testVisible private final String REQUEST_PARAM_DATA = 'data';
	@testVisible private final String ACTION_SEARCH_CATEGORY_WITH_SITE_COUNT='searchSiteCategory';
	@testVisible private final String ACTION_GET_SITE_CATEGORY = 'getSiteCategory';
	@testVisible private final String ACTION_CREATE_SITE_CATEGORY='saveSiteCategory';
	@testVisible private final String ACTION_DELETE_SITE_CATEGORY='deleteSiteCategory';
	@testVisible private final String ACTION_VALUE_UPDATE_SITE_CATEGORY_POSITION='updateSiteCategoryPosition';
	@testVisible private final String ACTION_VALUE_UPDATE_CATEGORY_POSITION = 'updateCategoryPosition';
	@testVisible private final String ALL_CATEGORY_STR = 'all';
	@testVisible private final String DUPLICATE_CATEGORY_STR = 'A category with this name already exists';
	
	private static String loggedInUserId = UserContext.id;

    public CategoryDataServer() {
		pageDaoObj = new PageDao();
    }
	
	public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
    public override void handleRequest(){
    	try{
    		logger.logDebug('CategoryDataServer----entered handleRequest----');
	    	
    		String action = readParam(REQUEST_PARAM_ACTION);
        	
            if(String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
            }
            if(ACTION_VALUE_SEARCH.equalsIgnoreCase(action)) {
                response = searchPageCategory(readParam(REQUEST_PARAM_DATA));
            }else if(ACTION_VALUE_DELETE.equalsIgnoreCase(action)) {
                response = deletePageCategoryRecord(readParam(REQUEST_PARAM_DATA));
            }else if(ACTION_VALUE_EDIT.equalsIgnoreCase(action)) {
                response = editPageCategoryRecord(readParam(REQUEST_PARAM_DATA));
            }else if(ACTION_VALUE_CREATE.equalsIgnoreCase(action)) {
                response = createPageCategoryRecord(readParam(REQUEST_PARAM_DATA));
            } else if (ACTION_SEARCH_CATEGORY_WITH_SITE_COUNT.equalsIgnoreCase(action)){
            	response = searchSiteCategory(readParam(REQUEST_PARAM_DATA));
            } else if (ACTION_CREATE_SITE_CATEGORY.equalsIgnoreCase(action)){
            	response = saveSiteCategory(readParam(REQUEST_PARAM_DATA));
            } else if (ACTION_DELETE_SITE_CATEGORY.equalsIgnoreCase(action)){
            	response = deleteSiteCategory(readParam(REQUEST_PARAM_DATA));
            } else if (ACTION_VALUE_UPDATE_SITE_CATEGORY_POSITION.equalsIgnoreCase(action)){
            	response = updateSiteCategoryPosition(readParam(REQUEST_PARAM_DATA));
            } else if(ACTION_VALUE_UPDATE_CATEGORY_POSITION.equalsIgnoreCase(action)) {
            	response = updateCategoryPosition(readParam(REQUEST_PARAM_DATA));
            } else if(ACTION_GET_SITE_CATEGORY.equalsIgnoreCase(action)){
            	response = getSiteCategory(readParam(REQUEST_PARAM_DATA));
            }else {
                throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            }

    	}catch(Exception ex){
            logger.logError('Either no page access or action parameter returning wrong data',ex);  
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        
    }
    
	@TestVisible 
    private ResponseWrapper searchPageCategory(String data){
    	logger.logDebug('CategoryDataServer.searchPageCategory()----data----'+data);
    	ResponseWrapper resultWrapper = New ResponseWrapper();
		try{
			if(data == null || String.isBlank(data)){
				throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
			}
			ManageContentRequestWrapper requestObj = (ManageContentRequestWrapper)JSON.deserialize(data, ManageContentRequestWrapper.class);
			String orderBy = 'CreatedDate';
			String order = String.isBlank(requestObj.sortBy)? 'ASC': requestObj.sortBy.equalsIgnoreCase('createdNewest')? 'DESC' : 'ASC';
			String searchText = String.isBlank(requestObj.term) ? '':requestObj.term;
			String siteId = String.isBlank(requestObj.siteId) ? '':requestObj.siteId;
			Integer recordLimit = requestObj.size == null? SimpplrContext.simpplrDefaultPageSize : requestObj.size;
			Integer nextPageToken = String.isNotBlank(requestObj.nextPageToken)?Integer.valueOf(requestObj.nextPageToken):0;
			Set<Id> siteIManageIdList = UserContext.sitesIManageIdSet;
			Boolean isUserAppModerator = UserContext.isUserAppModerator;
			
			CategoryDao categoryDaoObj = new CategoryDao();
			List<Pages_Category__c> categoryObjList = New List<Pages_Category__c>();
			if(SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(searchText)) {
				List<String> categoryIds = getCategoriesFromAWS(searchText, siteId, recordLimit, nextPageToken);
				categoryObjList = categoryDaoObj.getCategoryListFromIds(categoryIds, orderBy, order);
			} else {
				categoryObjList = categoryDaoObj.getCategoryListFromCriteria(siteId, searchText, orderBy ,order, recordLimit+1, nextPageToken, siteIManageIdList, isUserAppModerator);
			}

			Map<String,Integer> pageCountMap = pageDaoObj.getContentGroupByCategory();
			Map<String,Integer> publishedPageCountMap = pageDaoObj.getPublishedContentGroupByCategory();
			List<String> userIdList = new List<String>();
			if (!categoryObjList.isEmpty()){
				for (Pages_Category__c tp : categoryObjList){
					userIdList.add(tp.CreatedBy.Id);	
				}
			}
			Map<String,People__c> userIdToPeopleMap = Utility.userIdToPeopleMap(userIdList);
			List<CategoryListWrapper> categoryWrapperList = convertCategoryListTowrapperList(categoryObjList, pageCountMap, publishedPageCountMap, userIdToPeopleMap);
			
			if (categoryWrapperList.size() == (recordLimit + 1) && nextPageToken < 2000) {
				categoryWrapperList.remove((categoryWrapperList.size()-1));
				nextPageToken = nextPageToken + recordLimit;
			} else {
				nextPageToken = null;
			}
			
			Map<String,Object> result = New Map<String,Object>();
			result.put('listOfItems',categoryWrapperList);
			result.put('nextPageToken',nextPageToken);
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Records have been retirived!', result);
			logger.logDebug('CategoryDataServer.searchPageCategory()----resultWrapper----'+resultWrapper);
        } catch(exception e){
      		logger.logError('CategoryDataServer.searchPageCategory()------could not retrieve data----',e);
  			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return resultWrapper;
	}
	
	private List<String> getCategoriesFromAWS(String searchText, String siteId, Integer recordLimit, Integer nextPageToken) {
		String SearchForType = 'Pages_Category';
		List<String> categoryIds = new List<String>();

		Criteria.ExternalSearchReq pageCategoryCriteria = new Criteria.ExternalSearchReq();

		pageCategoryCriteria.term = searchText;
		pageCategoryCriteria.size = recordLimit;
		pageCategoryCriteria.siteId = siteId;
		pageCategoryCriteria.nextPageToken = String.valueOf(nextPageToken);
		pageCategoryCriteria.isCorrectionEnabled = true; // ToDo - DS0001 - Why  ?

		ExternalSearchService externalServiceObj = new ExternalSearchService();
		ExternalSearchWrapper.TopContentsWrapper returnWrapper = externalServiceObj.searchPageCategories(pageCategoryCriteria, searchForType);

		for(ExternalSearchWrapper.ItemWrapper itemWrapperObj : returnWrapper.listOfItems) {

			Object item = itemWrapperObj.item;
			CategoryListWrapper clWrapper = (CategoryListWrapper)item;

			categoryIds.add(clWrapper.id);
		}

		return categoryIds;
	}
    
    @TestVisible 
    private ResponseWrapper getSiteCategory(String data){
    	logger.logDebug('CategoryDataServer.getSiteCategory()----data----'+data);
    	ResponseWrapper resultWrapper = New ResponseWrapper();
		try{
			if(data == null || String.isBlank(data)){
				throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
			}
			Map<String, String> requestObjMap = (Map<String, String>)JSON.deserialize(data, Map<String, String>.class);
			String categoryId = requestObjMap.get('categoryId');

			Site_Category__c siteCategoryObj = new CategoryDao().getCategoryWithSiteCountById(categoryId);
			
			ManageApplicationWrapper.ManageSitesCategoryWrapper resultObj = new ManageApplicationWrapper.ManageSitesCategoryWrapper();
			resultObj.id = siteCategoryObj.Id;
			resultObj.categoryId = siteCategoryObj.Id;
			resultObj.name = siteCategoryObj.name__c;
			resultObj.siteCount = siteCategoryObj.Simpplr_Sites_Site_Category__r.size();
			resultObj.access = siteCategoryObj.access__c;
			resultObj.url = PageContext.getPageURL(Pages.app)+'?u=/sites/category&category='+ siteCategoryObj.Id;
			
			resultObj.isUncategorized = false;
			if(ServiceConstants.UNCATEGORIZED_CATEGORY_STR.equalsIgnoreCase(resultObj.name)) {
				resultObj.isUncategorized = true;
			}
			
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Record has been retrieved!', resultObj);
			logger.logDebug('CategoryDataServer.getSiteCategory()----resultWrapper----'+resultWrapper);
        } catch(exception e){
      		logger.logError('CategoryDataServer.getSiteCategory()-----could not retrieve data----',e);
  			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
        return resultWrapper;
    }
        
	@TestVisible 
    private ResponseWrapper deletePageCategoryRecord(String data){
    	logger.logDebug('CategoryDataServer.deletePageCategoryRecord()----data----'+data);
    	ResponseWrapper resultWrapper = New ResponseWrapper();
		try {
			if(data == null || String.isBlank(data)){
				throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
			}
			
			List<String> categoriesList = (List<String>)JSON.deserialize(data, List<String>.class);
			logger.logDebug('CategoryDataServer.deletePageCategoryRecord()----categoriesList----' + categoriesList);

			if(categoriesList.isEmpty()) {
				throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
			}
			
			String uncategorizedCategoryName = ServiceConstants.CATEGORY_UNCATEGORIZED;
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', categoriesList);
			soqlParamMap.put('soqlParam2', uncategorizedCategoryName);
			String pageCtgryQuery = 'Select Site__c, Name__c FROM Pages_Category__c WHERE Id = :soqlParam1 AND Name__c = :soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Pages_Category__c> oldRecordsList = (List<Pages_Category__c>)SIMPESAPI.accessController().queryAsUser(pageCtgryQuery, soqlParamMap);
			if( !oldRecordsList.isEmpty() && uncategorizedCategoryName.equalsIgnoreCase(oldRecordsList.get(0).Name__c) ) {
				resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, STR_ERROR_DELETE_UNCATEGORIES, null);
			}
			else {
				Integer associatedPageCount = getAssociatedPagesCount(categoriesList);
				if(associatedPageCount > 0) {
					resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, STR_ERROR_DELETE_NOT_EMPTY, null);
				}
				else {
					CategoryDao catDaoObj = new CategoryDao();
					catDaoObj.removePageCategories(categoriesList);
					resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Content has beed deleted!', null);
				}
			}
			logger.logDebug('CategoryDataServer.deletePageCategoryRecord()----resultWrapper----'+resultWrapper);
		} catch(exception e){
      		logger.logError('CategoryDataServer.deletePageCategoryRecord()-----could not retrieve data----',e);
  			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return resultWrapper;
    }

	@TestVisible 
    private ResponseWrapper editPageCategoryRecord(String data){
    	logger.logDebug('CategoryDataServer.editPageCategoryRecord()----data----'+data);
    	ResponseWrapper resultWrapper = New ResponseWrapper();
        if(data == null || String.isBlank(data)){
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        }
        Map<String,String> requestMap = (Map<String,String>)JSON.deserialize(data, Type.forName('Map<String,String>'));
        
        
        if(!requestMap.containsKey('id') || !requestMap.containsKey('name') ){
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        }
        String recordId = requestMap.get('id');
        String recordName = requestMap.get('name').trim();
        String siteId = requestMap.get('siteId');
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', recordId);
		String pageCtgryQuery = 'Select Site__c, Name__c FROM Pages_Category__c WHERE Id = :soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Pages_Category__c> oldRecordsList = (List<Pages_Category__c>)SIMPESAPI.accessController().queryAsUser(pageCtgryQuery, soqlParamMap);
        
        if( !oldRecordsList.isEmpty() && (ServiceConstants.CATEGORY_UNCATEGORIZED).equalsIgnoreCase(oldRecordsList.get(0).Name__c) ){
            resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, STR_ERROR_EDIT_UNCATEGORIES, null);
        }
        else {
			soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', oldRecordsList.get(0).site__c);
			soqlParamMap.put('soqlParam2', recordId);
			soqlParamMap.put('soqlParam3', recordName);
			pageCtgryQuery = 'Select Site__c,Site__r.Name FROM Pages_Category__c WHERE site__c =:soqlParam1 AND Id!= :soqlParam2 AND Name__c =:soqlParam3 AND Is_Deleted__c = false';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Pages_Category__c> recordsForSameNameList = (List<Pages_Category__c>)SIMPESAPI.accessController().queryAsUser(pageCtgryQuery, soqlParamMap);
	        if(recordsForSameNameList.size() > 0){
	            resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, STR_ERROR_EDIT_DUPLICATE, null);
	        }
	        else {
				List<String> listOfPagesCategoriesIds = new List<String>();
				listOfPagesCategoriesIds.add(recordId);
				Criteria.Pages pagesCriteriaObjArg = new Criteria.Pages();
				pagesCriteriaObjArg.siteId = siteId;
				List<AggregateResult> groupedResults = pageDaoObj.getContentCountsPerCategory(pagesCriteriaObjArg, listOfPagesCategoriesIds);
		        Pages_Category__c record = New Pages_Category__c();
		        record.Id = recordId;
				record.Name__c = recordName;
				Integer pageCount = 0;
				Boolean canDelete = true;
				String createdAt;
				
        		logger.logDebug('CategoryDataServer.editPageCategoryRecord()----updating recording----');
		        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(record,new List<Schema.SObjectField>{Pages_Category__c.Name__c});
				logger.logDebug('CategoryDataServer.editPageCategoryRecord()----records updated----');
				CategoryDao daoObj = new CategoryDao();
				Pages_Category__c pageCategoryObj = daoObj.getCategoryWithId(recordId);
				createdAt = pageCategoryObj.createdDate != null ? Utility.dateToDisplayString(pageCategoryObj.createdDate, ServiceConstants.DATETIME_FORMAT) : null;
		        Map<Object,Object> resultMap = New Map<Object,Object>();
		        resultMap.put('id',record.id);
				resultMap.put('name',record.Name__c);
				if(groupedResults != null && groupedResults.size() > 0){
					for(AggregateResult ar : groupedResults){
						pageCount = (Integer) ar.get('expr0');
						canDelete = pageCount == 0 ? true : false; 
					}
				}
				
				resultMap.put('pageCount',pageCount);
				resultMap.put('canEdit',true);
				resultMap.put('canDelete',canDelete);
				resultMap.put('createdAt',createdAt);
		        resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Content has beed updated!', resultMap);
	        }
        }
		logger.logDebug('CategoryDataServer.editPageCategoryRecord()----resultWrapper----'+resultWrapper);
        return resultWrapper;
    }

	@TestVisible 
    private ResponseWrapper createPageCategoryRecord(String data){
    	logger.logDebug('CategoryDataServer.createPageCategoryRecord()----data----'+data);
    	ResponseWrapper resultWrapper = New ResponseWrapper();
    	try {
	        if(data == null || String.isBlank(data)){
	            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
	        }
	        List<String> userIdList = new List<String>();
	        Map<String,String> requestMap = (Map<String,String>)JSON.deserialize(data, Type.forName('Map<String,String>'));
	        if(!requestMap.containsKey('siteId') || !requestMap.containsKey('name') ){
	            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
	        }
	        String siteId = requestMap.get('siteId');
	        
	        Map<Id,Simpplr_Site__c> allSimpplrGroupIdAndSiteMap = New Map<Id,Simpplr_Site__c>();
			for(Simpplr_Site__c site : Utility.getAllSimpplrSiteMap().values()){
				allSimpplrGroupIdAndSiteMap.put(site.chatter_Group_Id__c, site);
			}
		
	        if(allSimpplrGroupIdAndSiteMap != NULL && allSimpplrGroupIdAndSiteMap.get(siteId) != NULL){
	        	siteId = allSimpplrGroupIdAndSiteMap.get(siteId).Id;
	        }
	        String recordName = requestMap.get('name').trim();
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', siteId);
			soqlParamMap.put('soqlParam2', recordName);
			String pageCtgryQuery = 'Select Site__c,Site__r.Name FROM Pages_Category__c WHERE site__c =:soqlParam1 AND Name__c =:soqlParam2 AND Is_Deleted__c = false';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Pages_Category__c> recordsForSameNameList = (List<Pages_Category__c>)SIMPESAPI.accessController().queryAsUser(pageCtgryQuery, soqlParamMap);
	        if(recordsForSameNameList.size() > 0 ){
	            resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, STR_ERROR_EDIT_DUPLICATE, null);
	        }
	        else {
		        Pages_Category__c record = New Pages_Category__c();
		        record.site__c = siteId;
		        record.Name__c = recordName;
		        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		        SIMPSFDCAccessControlResults.InsertResults result = SIMPESAPI.accessController().insertAsUser(New List<Pages_Category__c>{record},new List<Schema.SObjectField>{Pages_Category__c.site__c,Pages_Category__c.Name__c});
		        List<Pages_Category__c> listOfNewCategoriesTemp = result.getInsertedObjects();
				soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', listOfNewCategoriesTemp);
				pageCtgryQuery = 'SELECT Id,Name__c,Site__c,Site__r.Id,CreatedById,CreatedDate,CreatedBy.Name,Site__r.name FROM Pages_Category__c WHERE ID IN :soqlParam1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<Pages_Category__c> listOfNewCategories = (List<Pages_Category__c>)SIMPESAPI.accessController().queryAsUser(pageCtgryQuery, soqlParamMap);
		        
		        if (!listOfNewCategories.isEmpty()){
					for (Pages_Category__c tp : listOfNewCategories){
						userIdList.add(tp.CreatedById);	
					}
				}
				userIdList.add(loggedInUserId);
				Map<String,People__c> userIdToPeopleMap = Utility.userIdToPeopleMap(userIdList);
			
		        List<CategoryListWrapper> categoryWrapperList = convertCategoryListTowrapperList(listOfNewCategories, null, null, userIdToPeopleMap);
	        
		        resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Category record has been created!', categoryWrapperList.get(0));
	        }
	    }
	    catch(Exception ex) {
	    	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
	    }
        
        logger.logDebug('CategoryDataServer.createPageCategoryRecord()----resultWrapper----'+resultWrapper);
        return resultWrapper;
    }

	@TestVisible 
	private ResponseWrapper searchSiteCategory(String requestData){
		logger.logDebug('CategoryDataServer.searchSiteCategory()----requestData----'+requestData);
        ResponseWrapper responseWrapperObj = null;
        
        Integer recordLimit = SimpplrContext.simpplrDefaultPageSize;
        Integer nextPageToken = 0;
        
        try {
	        String searchTerm = null;
		    String sortBy = '';
		    Boolean includeSites = false;
			Boolean showOnlyContainingSites = false;
	        
        	if(String.isNotBlank(requestData)) {
	        	Map<String,String> requestMap = (Map<String,String>)JSON.deserialize(requestData, Type.forName('Map<String,String>'));
		        
		        if(requestMap != NULL && requestMap.get('term') != NULL) {
		            searchTerm = requestMap.get('term');
		        }
				if(requestMap != NULL && requestMap.get('sortBy') != NULL) {
		            sortBy = requestMap.get('sortBy');
				}
				if(requestMap != NULL && requestMap.get('includeSites') != NULL) {
					includeSites = Boolean.valueOf(requestMap.get('includeSites'));
		        }
				if(requestMap != NULL && requestMap.get('showOnlyContainingSites') != NULL) {
					showOnlyContainingSites = Boolean.valueOf(requestMap.get('showOnlyContainingSites'));
		        }
		        if(requestMap != NULL && requestMap.get('size') != NULL) {
		        	recordLimit = requestMap.get('size') == null ? recordLimit : Integer.valueOf(requestMap.get('size'));
		        }
		        if(requestMap != NULL && requestMap.get('nextPageToken') != NULL && !('nextPageToken'.equalsIgnoreCase(requestMap.get('nextPageToken')))) {
        			nextPageToken = String.isNotBlank(requestMap.get('nextPageToken')) ? Integer.valueOf(requestMap.get('nextPageToken')) : nextPageToken;
		        }
        	}
	        
			ManageApplicationWrapper.PaginationWrapper itemsList = new ManageApplicationWrapper.PaginationWrapper();
			if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
				if(String.isNotBlank(searchTerm)) {
					logger.logDebug('--------enter in external search');
					Criteria.ExternalSearchReq siteCategoryCriteriaObj = (Criteria.ExternalSearchReq)JSON.deserialize(requestData, Criteria.ExternalSearchReq.class);
					String SearchForType = 'Site_Category';
					ExternalSearchService externalSearchService = new ExternalSearchService();
					ExternalSearchWrapper.TopContentsWrapper returnWrapper = externalSearchService.searchSiteCategory(siteCategoryCriteriaObj, SearchForType);
					List<String> categoryIds = new List<String>();
					if(returnWrapper.listOfItems != null && returnWrapper.listOfItems.size() > 0) {
						for(ExternalSearchWrapper.ItemWrapper itemWrapperObj : returnWrapper.listOfItems) {
							Object item = itemWrapperObj.item;
							ManageApplicationWrapper.ManageSitesCategoryWrapper wrapperObj = (ManageApplicationWrapper.ManageSitesCategoryWrapper)item;
							categoryIds.add(wrapperObj.id);	
						}
						itemsList.listOfItems = convertToCategorySitesWrapper(new CategoryDao().getCategoriesWithId(categoryIds), sortBy, includeSites, true, showOnlyContainingSites);						
						itemsList.nextPageToken = returnWrapper.nextPageToken;
					}
				} else {
					String query = 'SELECT name, Name__c, Order__c, access__c, LastModifiedDate, ' +
					' (SELECT id, name, site_type__c, Chatter_Group_Id__c from Simpplr_Sites_Site_Category__r where is_Deleted__c=false AND Is_Active__c=true and Show_In_Simpplr__c = true) ' +
					' FROM Site_Category__c WHERE is_Deleted__c=false';
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
					List<Site_Category__c> siteCategoryList = (List<Site_Category__c>)SIMPESAPI.accessController().queryAsUser(query, null);
                    itemsList.listOfItems = returnSpecifiedPaginationList(convertToCategorySitesWrapper(siteCategoryList, sortBy, includeSites, true, showOnlyContainingSites), recordLimit + 1, nextPageToken);
					if (itemsList.listOfItems.size() == (recordLimit + 1) && nextPageToken < 2000) {
						itemsList.listOfItems.remove((itemsList.listOfItems.size()-1));
						itemsList.nextPageToken = String.valueOf(nextPageToken + recordLimit);
					} else {
						itemsList.nextPageToken = null;
					}
				}
			} else {
				itemsList.listOfItems = convertToCategorySitesWrapper(new CategoryDao().getCategoriesWithSiteCount(searchTerm, sortBy, (recordLimit + 1), nextPageToken), sortBy, includeSites, false, showOnlyContainingSites);
				if (itemsList.listOfItems.size() == (recordLimit + 1) && nextPageToken < 2000) {
					itemsList.listOfItems.remove((itemsList.listOfItems.size()-1));
					itemsList.nextPageToken = String.valueOf(nextPageToken + recordLimit);
				} else {
					itemsList.nextPageToken = null;
				}
			}
				
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, itemsList);
        }
        catch(Exception e) {
        	logger.logError('CategoryDataServer.searchSiteCategory()----Could not search site category',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('CategoryDataServer.searchSiteCategory()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }

	@testVisible 
    private List<ManageApplicationWrapper.ManageSitesCategoryWrapper> returnSpecifiedPaginationList(List<ManageApplicationWrapper.ManageSitesCategoryWrapper> fullList, Integer size, 
            Integer nextPageToken) {

		List<ManageApplicationWrapper.ManageSitesCategoryWrapper> listToBeReturned = new List<ManageApplicationWrapper.ManageSitesCategoryWrapper>();
		if(fullList.size() > 0) {		
			Integer filesCount = fullList.size();
			Integer startIndex = nextPageToken == null ? 0 : nextPageToken;
			Integer endIndex = (startIndex + size) >= filesCount ? filesCount : startIndex + size;
			
			for (integer i = startIndex; i < endIndex ; i++) {
				listToBeReturned.add(fullList.get(i));
			}
		}
    	return listToBeReturned;
	}
    
    @TestVisible 
    private ResponseWrapper deleteSiteCategory(String requestData){
    	logger.logDebug('CategoryDataServer.deleteSiteCategory()----requestData----'+requestData);
       	ResponseWrapper responseWrapperObj = null;
        try{
        	Set<String> setOfCategoryIds = (Set<String>)Json.deserialize(requestData,Set<String>.class);
        	
        	List<String> notDeletedCategoryIds = categoryIdsHavingSites(setOfCategoryIds);
        	
        	// remove the categories that are having some active sites
        	setOfCategoryIds.removeAll(notDeletedCategoryIds);
        	
        	Boolean deleteFlag = new CategoryDao().deleteCategory(setOfCategoryIds);
        	
        	if(deleteFlag) {
            	if(notDeletedCategoryIds.size() == 0) {
            		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
            	} else if(notDeletedCategoryIds.size() == 1) {
        			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
            	} else {
	        		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
	        	}
        	} else {
    			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        	}
        }catch(Exception e){
        	logger.logError('CategoryDataServer.deleteSiteCategory()----Could not delete site category',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('CategoryDataServer.deleteSiteCategory()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
    
    @TestVisible 
    private List<String> categoryIdsHavingSites(Set<String> setOfCategoryIds) {
    	List<String> notDeletedCategoryIds = new List<String>();
    	List<Simpplr_Site__c> sitesList = [select Id, Site_Category__c from Simpplr_Site__c 
    										where Site_Category__c = :setOfCategoryIds and Is_Active__c = true AND Is_Deleted__c = false WITH SECURITY_ENFORCED];
    	
    	for(Simpplr_Site__c siteObj : sitesList) {
    		notDeletedCategoryIds.add(siteObj.Site_Category__c);
    	}
    	return notDeletedCategoryIds;
    }
    
    @TestVisible 
    private ResponseWrapper saveSiteCategory(String requestData){
    	logger.logDebug('CategoryDataServer.saveSiteCategory()----requestData----'+requestData);
    	if(!UserContext.isUserAppModerator){
    		throw new SimpplrException(ServiceConstants.ERROR_403);
    	}
       	ResponseWrapper responseWrapperObj = null;
        try{
        	ManageApplicationWrapper.ManageSitesCategoryWrapper siteCategoryWrapperObj = (ManageApplicationWrapper.ManageSitesCategoryWrapper)Json.deserialize(requestData, ManageApplicationWrapper.ManageSitesCategoryWrapper.class);
        	String categoryName = siteCategoryWrapperObj.name.replace('"','').trim();
        	siteCategoryWrapperObj.name = categoryName;
        	Boolean allowOperation = false;
        	
        	Integer addCategoryResponseCode = new CategoryDao().checkDuplicateSiteCategoryName(categoryName, siteCategoryWrapperObj.id);
        	if(addCategoryResponseCode == 1){
        		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, DUPLICATE_CATEGORY_STR, null);
        	} else if(addCategoryResponseCode == 2){
        		allowOperation = true;
        	}
        	
        	// Check if it's not a duplicate category then let the operation to be done.
        	if(allowOperation){
        		ManageApplicationWrapper.ManageSitesCategoryWrapper siteCatWrapObj = new CategoryDao().saveSiteCategory(siteCategoryWrapperObj);
        		siteCatWrapObj.siteCount = (siteCategoryWrapperObj.siteCount != null) ? siteCategoryWrapperObj.siteCount : 0;
        		siteCatWrapObj.categoryId = siteCatWrapObj.Id;
        		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, siteCatWrapObj);
        	}
        }catch(Exception e){
        	logger.logError('CategoryDataServer.saveSiteCategory()----Could not save site category',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('CategoryDataServer.saveSiteCategory()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
    
    @TestVisible 
    private List<CategoryListWrapper> convertCategoryListTowrapperList(List<Pages_Category__c> recordsList, Map<String,Integer> pageCountMap, Map<String,Integer> publishedPageCountMap, Map<String,People__c> userIdToPepleMap){
    	List<CategoryListWrapper> result = New List<CategoryListWrapper>();
    	CategoryListWrapper wrapperObj;
		
    	if(recordsList != null && recordsList.size() > 0){
            for(Pages_Category__c contentRecord : recordsList){
            	wrapperObj  = New CategoryListWrapper();
            	
            	
            	wrapperObj.id = contentRecord.Id;
            	wrapperObj.name = contentRecord.Name__c;
            	
            	wrapperObj.pageCount = 0;
            	if(pageCountMap != null) {
            		wrapperObj.pageCount = pageCountMap.containsKey(contentRecord.Id) ? pageCountMap.get(contentRecord.Id) : 0;
            	}
            	if(publishedPageCountMap != null) {
            		wrapperObj.publishedPageCount = publishedPageCountMap.containsKey(contentRecord.Id) ? publishedPageCountMap.get(contentRecord.Id) : 0;
            	}
            	wrapperObj.createdAt = contentRecord.createdDate == null ? '':Utility.dateToDisplayString(contentRecord.createdDate,ServiceConstants.DATETIME_FORMAT); 
            	
				if(ServiceConstants.UNCATEGORIZED_CATEGORY_STR.equalsIgnoreCase(contentRecord.Name__c)){
					wrapperObj.canEdit = false;
            		wrapperObj.canDelete = false;
				}else{
					wrapperObj.canEdit = true;
            		wrapperObj.canDelete = wrapperObj.pageCount == 0?true:false;
				}
                
                if (userIdToPepleMap != NULL && userIdToPepleMap.get(contentRecord.CreatedById) != NULL){
                	
                	wrapperObj.authoredBy.id = userIdToPepleMap.get(contentRecord.CreatedById).id;
                	wrapperObj.authoredBy.peopleId = userIdToPepleMap.get(contentRecord.CreatedById).id;
                	wrapperObj.authoredBy.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + wrapperObj.authoredBy.peopleId;
                } 
                wrapperObj.authoredBy.name = userIdToPepleMap.get(contentRecord.CreatedById) != null ? userIdToPepleMap.get(contentRecord.CreatedById).Full_Name__c : contentRecord.CreatedBy.Name;
                
                wrapperObj.site.siteid = contentRecord.Site__c;
                wrapperObj.site.name = contentRecord.Site__r.name;
                wrapperObj.site.url = '/apex/sitedashboard?siteId='+wrapperObj.site.siteid;
                wrapperObj.url = PageContext.getPageURL(Pages.app) + '?u=/manage/sites/' + contentRecord.Site__c + '/content&type=page&category='+contentRecord.id;
                result.add(wrapperObj);
            }
        }
    	return result;
    }
    
    @TestVisible 
    private List<ManageApplicationWrapper.ManageSitesCategoryWrapper> convertToCategorySitesWrapper (List<Site_category__c> listCatObj, String sortBy, Boolean includeSites, Boolean sortList, Boolean showOnlyContainingSites){
		List<ManageApplicationWrapper.ManageSitesCategoryWrapper> listResult = new List<ManageApplicationWrapper.ManageSitesCategoryWrapper>();		
		Map<string, List<SiteLiteWrapper>> categorySiteLiteCombinedMap = new Map<string, List<SiteLiteWrapper>>();
        Map<Id, CollaborationGroup> mapOfAllCollaborationGrp = new SiteDao().getMapOfIdWithCollaborationGroup(UserContext.id);
		
        for (Site_Category__c siteCatObj: listCatObj) {
            ManageApplicationWrapper.ManageSitesCategoryWrapper temp = new ManageApplicationWrapper.ManageSitesCategoryWrapper();
            temp.id = siteCatObj.Id;
            temp.categoryId = siteCatObj.Id;
            temp.name = siteCatObj.name__c;
            temp.sortBy = sortBy;
            temp.modifiedAtDateTime = siteCatObj.LastModifiedDate;
            temp.order = (Integer)siteCatObj.Order__c;
            temp.siteCount = siteCatObj.Simpplr_Sites_Site_Category__r.size();
            temp.access = siteCatObj.access__c;
            temp.isUncategorized = ServiceConstants.UNCATEGORIZED_CATEGORY_STR.equalsIgnoreCase(temp.name);							
            
            if (includeSites) {

                if (!siteCatObj.Simpplr_Sites_Site_Category__r.isEmpty()) {
                    temp.listOfSites = new List<SiteLiteWrapper>();

                    for (Simpplr_Site__c simpSiteObj: siteCatObj.Simpplr_Sites_Site_Category__r) {
                        Boolean isMember = UserContext.sitesIFollowIdSet.contains(simpSiteObj.id);
                    
                        if (temp.listOfSites.size() < 21) {
                            SiteLiteWrapper siteWrapObj= new SiteLiteWrapper();
                            siteWrapObj.siteId = simpSiteObj.id;
                            siteWrapObj.name = simpSiteObj.name;
                            siteWrapObj.access = simpSiteObj.site_type__c;
                            siteWrapObj.isMember = isMember;
							temp.listOfSites.add(siteWrapObj);
                        }

                    }

                }

            } else {
                temp.listOfSites = new List<SiteLiteWrapper>();
            }
			if (!(includeSites && showOnlyContainingSites && (temp.listOfSites == null || temp.listOfSites.size() == 0))) {
            	listResult.add(temp);
			}
        }
		if(sortList) {
			listResult.sort();
		}
        
    	return listResult;
	}

    
    
    @TestVisible 
    private ResponseWrapper updateCategoryPosition (String requestData){
    	logger.logDebug('CategoryDataServer.updateCategoryPosition()----requestData----'+requestData);
        ResponseWrapper responseWrapperObj = null;
        try{
        	if( !(UserContext.sitesIManageIdSet.contains(SiteContext.siteId) || (UserContext.isUserAppModerator && SiteContext.isPrivateSite==false) || UserContext.hasModifyAllDataPermission) ){
        		throw new SimpplrException(ServiceConstants.ERROR_403);
        	}
        	CategoryOrder categoryOrderObj = (CategoryOrder)JSON.deserialize(requestData, CategoryOrder.class);
        	Map<Id, Pages_Category__c> categoryMap = new CategoryDao().getCategoryMap4Site(categoryOrderObj.siteId);
        	
        	List<Pages_Category__c> updatedCategoriesList = updateCategoryOrder(categoryMap, categoryOrderObj.categoryIds);
        	new CategoryDao().updateCategoryPosition(updatedCategoriesList);
        	
        	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
        }catch(Exception e){
        	logger.logError('CategoryDataServer.createSiteCategory()----Could not update category position',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('CategoryDataServer.updateCategoryPosition()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
    
    
    @TestVisible 
    private List<Pages_Category__c> updateCategoryOrder(Map<Id, Pages_Category__c> categoryMap, List<String> categoryIdsList) {
    	List<Pages_Category__c> returnList = new List<Pages_Category__c>();
    	
    	List<Integer> catOrderList = new List<Integer>();
    	Integer counter = 0;
    	for(String catId : categoryIdsList) {
    		Pages_Category__c catObjTemp = categoryMap.remove(catId);
    		
    		if(catObjTemp != null) {
    			catObjTemp.Order__c = counter++;
    			returnList.add(catObjTemp);
    		}
    	}
    	
    	for(Pages_Category__c catObj : categoryMap.values()) {
    		catObj.Order__c = counter++;
    		returnList.add(catObj);
    	}
    	
    	return returnList;
    }
    
    @TestVisible 
    private ResponseWrapper updateSiteCategoryPosition (String requestData){
    	logger.logDebug('CategoryDataServer.updateSiteCategoryPosition()----requestData----'+requestData);
        ResponseWrapper responseWrapperObj = null;
        try{
        	if( !(UserContext.isUserAppModerator || UserContext.hasModifyAllDataPermission) ){
        		throw new SimpplrException(ServiceConstants.ERROR_403);
        	}
        	CategoryOrder categoryOrderObj = (CategoryOrder)JSON.deserialize(requestData, CategoryOrder.class);
        	Map<Id, Site_Category__c> categoryMap = new CategoryDao().getSiteCategoriesMap();
        	
        	List<Site_Category__c> updatedCategoriesList = updateSiteCategoryOrder(categoryMap, categoryOrderObj.categoryIds);
        	new CategoryDao().updateSiteCategoryPosition(updatedCategoriesList);
        	
        	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
        }catch(Exception e){
        	logger.logError('CategoryDataServer.updateSiteCategoryPosition()----Could not update category position',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('CategoryDataServer.updateSiteCategoryPosition()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
    
    @TestVisible 
    private List<Site_Category__c> updateSiteCategoryOrder(Map<Id, Site_Category__c> categoryMap, List<String> categoryIdsList) {
    	List<Site_Category__c> returnList = new List<Site_Category__c>();
    	
    	List<Integer> catOrderList = new List<Integer>();
    	Integer counter = 0;
    	for(String catId : categoryIdsList) {
    		Site_Category__c catObjTemp = categoryMap.remove(catId);
    		
    		if(catObjTemp != null) {
    			catObjTemp.Order__c = counter++;
    			returnList.add(catObjTemp);
    		}
    	}
    	
    	for(Site_Category__c catObj : categoryMap.values()) {
    		catObj.Order__c = counter++;
    		returnList.add(catObj);
    	}
    	
    	return returnList;
    }
    
    /*
    *  This method return number of Page-records associated with the category.
    *  
    */
    private Integer getAssociatedPagesCount(List<String> categoryIds) {
    	List<Simpplr_Content__c> pagesList = [select Id From Simpplr_Content__c where Type__c = :ServiceConstants.TYPE_PAGE AND Is_Deleted__c = false and Pages_Category__c = :categoryIds WITH SECURITY_ENFORCED];
    	return pagesList.size();
    }
    
    public class CategoryOrder {
    	String siteId {get; set;}
    	List<String> categoryIds {get; set;}
    }
    
}