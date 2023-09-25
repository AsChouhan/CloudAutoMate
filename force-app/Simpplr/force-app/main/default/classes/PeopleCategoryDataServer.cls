public with sharing class PeopleCategoryDataServer extends DataServer {
	
	private final String ACTION_VALUE_SEARCH = 'search';
	private final String ACTION_VALUE_DELETE = 'delete';
	private final String ACTION_VALUE_RENAME = 'rename';
	private final String ACTION_VALUE_CREATE = 'create';
	private final String REQUEST_PARAM_DATA = 'data';
	// used in test method for covering else part of Full_external_search even if test method gives feature enabled value as true
	@testVisible private static Boolean checkFullExternalSearch = true;
	
	public PeopleCategoryDataServer() {
    }
	
	public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
	 public override void handleRequest(){
    	try{
    		logger.logDebug('PeopleCategoryDataServer----entered handleRequest----');

    		String action = readParam(REQUEST_PARAM_ACTION);
        	
            if(String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
            }
            if(ACTION_VALUE_SEARCH.equalsIgnoreCase(action)) {
            	String requestData = readParam(REQUEST_PARAM_DATA);
        		response = search(requestData);
            }else if(ACTION_VALUE_DELETE.equalsIgnoreCase(action)) {
                response = deleteRecord(readParam(REQUEST_PARAM_DATA));
            }else if(ACTION_VALUE_RENAME.equalsIgnoreCase(action)) {
                response = renameRecord(readParam(REQUEST_PARAM_DATA));
            }else if(ACTION_VALUE_CREATE.equalsIgnoreCase(action)) {
                response = createRecord(readParam(REQUEST_PARAM_DATA));
            } else{
                throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            }

    	}catch(Exception ex){
            logger.logError('Either no page access or action parameter returning wrong data',ex);  
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        
    }
    
    private ResponseWrapper search(String requestData){
    	logger.logDebug('PeopleCategoryDataServer.search()----requestData----'+requestData);
    	ResponseWrapper responseToReturn = New ResponseWrapper();
    	List<PeopleCategoryListingWrapper> listOfPeopleCategoryWrapper = new List<PeopleCategoryListingWrapper>();
		try {
			Integer uncategorizedPeopleCount = 0;
			PeopleCategoryListingWrapper.PeopleCategory peopleCategoryCriteriaObjArg = (PeopleCategoryListingWrapper.PeopleCategory)JSON.deserialize(requestData, PeopleCategoryListingWrapper.PeopleCategory.class);
			if (peopleCategoryCriteriaObjArg.nextPageToken == null) {
				peopleCategoryCriteriaObjArg.offset = 0; 
				uncategorizedPeopleCount = new PeopleDao().getUncategorizedPeopleCount();
			} else {
				peopleCategoryCriteriaObjArg.offset = Integer.valueOf(peopleCategoryCriteriaObjArg.nextPageToken);
			}
			if(checkFullExternalSearch && SimpplrContext.isFeatureEnabled('Full_External_Search')) {
				Criteria.ExternalSearchReq contentCriteria = (Criteria.ExternalSearchReq)JSON.deserialize(requestData, Criteria.ExternalSearchReq.class);
				listOfPeopleCategoryWrapper = new ExternalSearchService().getPeopleCategory(contentCriteria);
			} else {
				listOfPeopleCategoryWrapper = PeopleCategoryProvider.getPeopleCategory(peopleCategoryCriteriaObjArg);
			}
			PeopleCategoryListingWrapper.PaginationWrapper paginationObj = new PeopleCategoryListingWrapper.PaginationWrapper();
        	paginationObj.listOfItems.addAll(listOfPeopleCategoryWrapper);
        	
        	if (paginationObj.listOfItems.size() == (SimpplrContext.simpplrDefaultPageSize + 1) &&
	        		peopleCategoryCriteriaObjArg.offset < 2000) {
	        	paginationObj.listOfItems.remove((paginationObj.listOfItems.size()-1));
	        	paginationObj.nextPageToken = String.valueOf(peopleCategoryCriteriaObjArg.offset + SimpplrContext.simpplrDefaultPageSize);
	        } else {
	        	paginationObj.nextPageToken = null;
	        }
			if(uncategorizedPeopleCount > 0) {
				listOfPeopleCategoryWrapper = new List<PeopleCategoryListingWrapper>();
				PeopleCategoryListingWrapper PeopleCategoryObj = new PeopleCategoryListingWrapper();
    			PeopleCategoryObj.id = 'uncategorized';
    			PeopleCategoryObj.name = 'Uncategorized';
				PeopleCategoryObj.userCount = uncategorizedPeopleCount;
				listOfPeopleCategoryWrapper.add(PeopleCategoryObj);
				listOfPeopleCategoryWrapper.addAll(paginationObj.listOfItems);
				paginationObj.listOfItems = listOfPeopleCategoryWrapper;
			}
	        
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, paginationObj);
         	logger.logDebug('PeopleCategoryDataServer.search()----responseToReturn----'+responseToReturn);
		} catch(Exception e) {
        	logger.logError('PeopleCategoryDataServer----Could not fetch people categories',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
    	return responseToReturn;
    }
    
    private ResponseWrapper deleteRecord(String requestData){
    	logger.logDebug('PeopleCategoryDataServer.deleteRecord()----requestData----'+requestData);
    	ResponseWrapper responseWrapperObj = New ResponseWrapper();
    	try{
        	PeopleCategoryListingWrapper peopleCategoryObj= new PeopleCategoryListingWrapper();
        	List<String> listOfPeopleCategoryIds = (List<String>)JSON.deserialize(requestData, List<String>.class);
        	PeopleCategoryDao peoplecategoryDaoObj = new PeopleCategoryDao();
        	peoplecategoryDaoObj.deletePeopleCategory(listOfPeopleCategoryIds);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, peopleCategoryObj);
        }catch(Exception e){
        	logger.logError('PeopleCategoryDataServer----Could not delete records',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
    	return responseWrapperObj;
    }
    
    private ResponseWrapper renameRecord(String requestData){
    	logger.logDebug('PeopleCategoryDataServer.renameRecord()----requestData----'+requestData);
    	ResponseWrapper responseWrapperObj = New ResponseWrapper();
    	try{
        	PeopleCategoryListingWrapper peopleCategoryObj= new PeopleCategoryListingWrapper();
        	PeopleCategoryListingWrapper params= (PeopleCategoryListingWrapper)Json.deserialize(requestData,PeopleCategoryListingWrapper.class);
        	PeopleCategoryDao peoplecategoryDaoObj = new PeopleCategoryDao();
        	peoplecategoryDaoObj.renamePeopleCategory(params);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, peopleCategoryObj);
        }catch(Exception e){
        	logger.logError('PeopleCategoryDataServer----Could not rename records',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
    	return responseWrapperObj;
    }
    
    private ResponseWrapper createRecord(String requestData){
    	logger.logDebug('PeopleCategoryDataServer.createRecord()----requestData----'+requestData);
    	ResponseWrapper responseWrapperObj = New ResponseWrapper();
    	try{
        	PeopleCategoryListingWrapper peopleCategoryObj= new PeopleCategoryListingWrapper();
        	PeopleCategoryListingWrapper listOfPeopleCategoryObj= new PeopleCategoryListingWrapper();
        	peopleCategoryObj.name = requestData.replace('"','');
        	PeopleCategoryDao peoplecategoryDaoObj = new PeopleCategoryDao();
        	People_Category__c categoryObj = peoplecategoryDaoObj.savePeopleCategory(peopleCategoryObj);
			peopleCategoryObj.id = categoryObj.id;
			peopleCategoryObj.userCount = 0;
			
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, peopleCategoryObj);
        }catch(Exception e){
        	logger.logError('PeopleCategoryDataServer----Could not create records',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
    	return responseWrapperObj;
    }
}