/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class ExpertiseDataServer extends DataServer{
    public transient final String STR_ERROR_DUPLICATE_EXPERTISE { get { return labelMap.get('expertise.add.duplicate.error_flash');}}
    public transient final String STR_ERROR_CREATE_EXPERTISE_PERMISSION { get { return labelMap.get('expertise.create.permission.access_error');}}
    public transient final String STR_ERROR_DELETE_EXPERTISE_PERMISSION { get { return labelMap.get('expertise.delete.permission.access_error');}}

	private final String ACTION_VALUE_SEARCH = 'search';
	private final String ACTION_VALUE_MERGE = 'mergeExpertises';
	private final String ACTION_VALUE_DELETE = 'deleteExpertise';
    private final String ACTION_VALUE_SAVE = 'save';
	
    private final String REQUEST_PARAM_DATA = 'data';
    private final String REQUEST_PARAM_QUERY = 'term';
    private final String REQUEST_PARAM_FROM_EXPERTISE_ID = 'fromExpertiseId';
    private final String REQUEST_PARAM_TO_EXPERTISE_ID = 'toExpertiseId';
    private final String REQUEST_PARAM_EXPERTISE_ID = 'expertiseId';
    
    private final String EXPERTISE_MERGE_ERROR = 'Its not possible to perform this action';
    private final String EXPERTISE_DELETE_ERROR = 'Its not possible to perform this action';
    
    public ExpertiseDataServer() {

    }
	
	public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
    public override void handleRequest(){
    	try{
    		logger.logDebug('ExpertiseDataServer----entered handleRequest----');
    		
    		String action = readParam(REQUEST_PARAM_ACTION);
        	
            if(String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
            }
            
            if(ACTION_VALUE_SEARCH.equalsIgnoreCase(action)) {
                response = searchExpertise(readParam(REQUEST_PARAM_DATA));
                
            //} else if(ACTION_VALUE_GET.equalsIgnoreCase(action)) {
            //    response = get(readParam('expertiseId'));
                
            } else if(ACTION_VALUE_MERGE.equalsIgnoreCase(action)) {
                response = mergeExpertises(readParam(REQUEST_PARAM_DATA));
                
            } else if(ACTION_VALUE_DELETE.equalsIgnoreCase(action)) {
                response = deleteExpertise(readParam(REQUEST_PARAM_DATA));
                
            } else if(ACTION_VALUE_SAVE.equalsIgnoreCase(action)) {
                response = saveExpertise(readParam(REQUEST_PARAM_DATA));
                
            } else {
                throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            }

    	}catch(Exception ex){
            logger.logError(ex);
        	response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        
    }

    @TestVisible 
    private ResponseWrapper saveExpertise(String data) {
    	ResponseWrapper resultWrapper;
    	logger.logDebug('ExpertiseDataServer-------saveExpertise-----' + data);
    	if(String.isBlank(data)){
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        }
        if( SimpplrContext.isExpertiseAppManagerControlled && !(UserContext.isUserAppModerator) ) {
            throw New SimpplrException(STR_ERROR_CREATE_EXPERTISE_PERMISSION);
        }

        Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data,Type.forName('Map<String,String>'));
    	try {
        
            if(String.isBlank(requestDataMap.get('id'))){
                resultWrapper = createNewExpertise(requestDataMap);
            } else {
                resultWrapper = updateExpertise(requestDataMap);
            }
        }
        catch(Exception ex) {
            logger.logDebug('ExpertiseDataServer.saveExpertise() --------------- EXCEPTION :: ' + ex.getMessage());
            String expertiseName = ex.getMessage().replace('DUPLICATE_VALUE', '');
            if(ex.getMessage().containsIgnoreCase('DUPLICATE_VALUE')) {
                resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, STR_ERROR_DUPLICATE_EXPERTISE.replace('{{expertiseName}}', expertiseName), null);
            }
            else {
                throw new SimpplrException(ex.getMessage());
            }
        }
        
    	return resultWrapper;
    }
    
    @TestVisible 
    private ResponseWrapper createNewExpertise(Map<String,String> requestDataMap){
    	logger.logDebug('ExpertiseDataServer-------createNewExpertise-----' + requestDataMap);
    	ResponseWrapper resultWrapper = New ResponseWrapper();
        if(requestDataMap == null || requestDataMap.isEmpty()){
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        }

        if( SimpplrContext.isExpertiseCreateAppManagerControlled && !(UserContext.isUserAppModerator) ) {
        	throw New SimpplrException(STR_ERROR_CREATE_EXPERTISE_PERMISSION);
        }
        
        if(String.isBlank(requestDataMap.get('name'))){
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        }
        
        String expertiseName = requestDataMap.get('name');
        
        String alphanumericName = expertiseName.replaceAll('[^\\p{L}\\p{M}\\p{N}]', '');
        alphanumericName = alphanumericName.toLowerCase();

        List<Expertise__c> listOfDBExpertises = new List<Expertise__c>();
        String BASE_QUERY= 'select Id, Name__c, Display_Name__c, User_Count__c from Expertise__c where Name__c = :alphanumericName';
    	listOfDBExpertises = Database.query(BASE_QUERY);
              
        if(listOfDBExpertises.isEmpty()) {
            Expertise__c newExpertiseRecord = new Expertise__c();
            newExpertiseRecord.Name__c = alphanumericName;
		    newExpertiseRecord.Display_Name__c = expertiseName;

            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    	    newExpertiseRecord = (Expertise__c)SIMPESAPI.accessController().insertAsUser(newExpertiseRecord, new List<Schema.SObjectField>{
                                                                            Expertise__c.Name__c,
																			Expertise__c.Display_Name__c});
                                                                            ExpertiseWrapper wrapperObj = new ExpertiseWrapper();
            wrapperObj.expertiseid = newExpertiseRecord.id;
            wrapperObj.id = newExpertiseRecord.id;
            wrapperObj.name = newExpertiseRecord.Display_Name__c;

            wrapperObj.canEdit = true;
            wrapperObj.canDelete = true; 
            
            wrapperObj.users = (newExpertiseRecord.User_Count__c != null) ? (Integer)newExpertiseRecord.User_Count__c : 0;
            
            resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Expertise has been saved!', wrapperObj);
        } else {
        	throw new SimpplrException('DUPLICATE_VALUE' + listOfDBExpertises[0].Display_Name__c);
        }   
        
        return resultWrapper;   
    }

    @TestVisible 
    private ResponseWrapper updateExpertise(Map<String,String> requestDataMap){
    	logger.logDebug('ExpertiseDataServer-------updateExpertise-----' + requestDataMap);
        ResponseWrapper resultWrapper = New ResponseWrapper();
        String errorMessage = '';
        if(requestDataMap == null || requestDataMap.isEmpty()){
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        } 
        String expertiseId = requestDataMap.get('id');
        String expertiseName = requestDataMap.get('name');
        if(String.isBlank(expertiseId) || String.isBlank(expertiseName)){
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        }
        Expertise__c newExpertiseRecord = new Expertise__c();
        newExpertiseRecord.Id = expertiseId;
        String alphanumericName = expertiseName.replaceAll('[^\\p{L}\\p{M}\\p{N}]', '');
        alphanumericName = alphanumericName.toLowerCase();

        List<Expertise__c> listOfDBExpertises = new List<Expertise__c>();
        String BASE_QUERY= 'SELECT Id, Name__c, Display_Name__c, User_Count__c FROM Expertise__c WHERE Name__c = :alphanumericName AND Id != :expertiseId';
        listOfDBExpertises = Database.query(BASE_QUERY);

        if(listOfDBExpertises.isEmpty()) {
            ExpertiseDao expertiseDaoObj = new ExpertiseDao();
            Expertise__c listOfExpertise = expertiseDaoObj.getExpertiseById(expertiseId);
	        newExpertiseRecord.Name__c = alphanumericName;
            newExpertiseRecord.Display_Name__c = expertiseName;

            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(newExpertiseRecord, new List<Schema.SObjectField>{
                                                                                        Expertise__c.Name__c,
                                                                                        Expertise__c.Display_Name__c});

            
            Map<Object,Object> result = New Map<Object,Object>();
            result.put('id',newExpertiseRecord.Id);
            result.put('name',newExpertiseRecord.Display_Name__c);
            result.put('canEdit',true);
            result.put('canDelete',true);
            result.put('users',listOfExpertise.User_Count__c);
            resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Expertise has been saved!', result);
        } else {
        	throw new SimpplrException('DUPLICATE_VALUE' + listOfDBExpertises[0].Display_Name__c);
        }

        return resultWrapper;
    }

    @TestVisible 
    private ResponseWrapper searchExpertise(String data){
        ResponseWrapper resultWrapper = new ResponseWrapper();
        ManageContentRequestWrapper requestObj = (ManageContentRequestWrapper)JSON.deserialize(data, ManageContentRequestWrapper.class);
        String sortBy = 'User_Count__c';
        String order = (String.isBlank(requestObj.order) || 'desc'.equalsIgnorecase(requestObj.order)) ? 'DESC' : 'ASC';

        String regExp = '[^0-9a-zA-Z ]';
        if(String.isNotBlank(requestObj.term)) {
            requestObj.term = (requestObj.term).replaceAll(regExp, '');
        }
        
        String searchText = String.isBlank(requestObj.term) ? '':requestObj.term;
        Integer nextPageToken = String.isNotBlank(requestObj.nextPageToken)?Integer.valueOf(requestObj.nextPageToken):0;
        Integer recordLimit;
        if(requestObj.size != null && requestObj.size > 0) {
            recordLimit = Integer.valueOf(requestObj.size) + 1;
        }

        List<Expertise__c> listOfExpertise = new List<Expertise__c>();
        List<String> userIdList = new List<String>();
        Map<String,Object> result = New Map<String,Object>();
        List<ExpertiseWrapper> expertiseWrapperList = new List<ExpertiseWrapper>();
        if(SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(requestObj.term)) {
            ExternalSearchService externalSearchServiceObj = new ExternalSearchService();
            ExternalSearchWrapper.TopContentsWrapper externalSearchResponse = new ExternalSearchWrapper.TopContentsWrapper();
            externalSearchResponse = externalSearchServiceObj.searchExpertise(requestObj);

            expertiseWrapperList = convertToExpertiseWrapper(externalSearchResponse.listOfItems);
            result.put('nextPageToken', externalSearchResponse.nextPageToken);

        } else {
            ExpertiseDao expertiseDaoObj = new ExpertiseDao();
            listOfExpertise = expertiseDaoObj.getExpertiseWithCriteria(searchText,sortBy,order,recordLimit,nextPageToken);

            expertiseWrapperList = toManageExpertiseWrapper(listOfExpertise);
            
            if (recordLimit != null && expertiseWrapperList.size() == recordLimit && nextPageToken < 2000) {
                expertiseWrapperList.remove(recordLimit - 1);
                result.put('nextPageToken', nextPageToken + requestObj.size);
            }
        }

        
        result.put('listOfItems', expertiseWrapperList);
        resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Records have been retirived!', result);
        return resultWrapper;
    }
	
    @TestVisible 
    private ResponseWrapper mergeExpertises(String data) {
		ResponseWrapper localResult = new ResponseWrapper();
    	
		try {
			if(data == null || String.isBlank(data)){
	            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
            }
            if( SimpplrContext.isExpertiseAppManagerControlled && !(UserContext.isUserAppModerator) ) {
                throw New SimpplrException(STR_ERROR_CREATE_EXPERTISE_PERMISSION);
            }
		         
		    Map<String,Object> requestData = (Map<String,Object>)JSON.deserializeUntyped(data);
		    String fromExpertiseId = String.valueOf(requestData.get(REQUEST_PARAM_FROM_EXPERTISE_ID));
		    String toExpertiseId = String.valueOf(requestData.get(REQUEST_PARAM_TO_EXPERTISE_ID));
            
            ExpertiseDao expDaoObj = new ExpertiseDao();
            expDaoObj.mergeExpertises(fromExpertiseId, toExpertiseId);
            
            localResult.status = RESPONSE_STATUS_SUCCESS;
	        localResult.message = '';
		}catch(Exception ex){
        	logger.logDebug('ExpertiseDataServer.mergeExpertises() Exception while merging Expertises : ' + ex);
        	
        	localResult.status = RESPONSE_STATUS_ERROR;
	        localResult.message = null;
        }
        
		return localResult;
	}
	
    @TestVisible 
    private ResponseWrapper deleteExpertise(String data) {
		ResponseWrapper localResult = new ResponseWrapper();
    	
		try {
			if(data == null || String.isBlank(data)) {
	            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
	        }

            if(!UserContext.isUserAppModerator) {
                throw New SimpplrException(STR_ERROR_DELETE_EXPERTISE_PERMISSION);
            }
		
            ManageContentRequestWrapper.deleteExpertise wrapperObj = (ManageContentRequestWrapper.deleteExpertise)JSON.deserialize(data, ManageContentRequestWrapper.deleteExpertise.class);
            List<String> epertiseIdList = wrapperObj.expertiseId;
            if(epertiseIdList.isEmpty()) {
                throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
	        }
			ExpertiseDao expertiseDaoObj = new ExpertiseDao();
            expertiseDaoObj.deleteExpertise(epertiseIdList);
			
			localResult.status = RESPONSE_STATUS_SUCCESS;
	        localResult.message = '';
		} catch(Exception ex) {
        	logger.logError('Exception while deleting Expertise : ' + ex);
        	
        	localResult.status = RESPONSE_STATUS_ERROR;
	        localResult.message = EXPERTISE_DELETE_ERROR;
        }
        
		return localResult;
	}
	
    @TestVisible  
    private List<ExpertiseWrapper> toManageExpertiseWrapper(List<Expertise__c> listOfExpertise){
        List<ExpertiseWrapper> wrapperList = new List<ExpertiseWrapper>();
        ExpertiseWrapper expertiseWrapperItem ;
        if(listOfExpertise != null && listOfExpertise.size() > 0){
            for(Expertise__c expertiseItem :listOfExpertise){
                expertiseWrapperItem = new ExpertiseWrapper();
                expertiseWrapperItem.id = expertiseItem.Id;
                expertiseWrapperItem.name = expertiseItem.Display_Name__c;
                expertiseWrapperItem.url = PageContext.getPageURL(Pages.app) + '?u=/expertise/' + expertiseItem.Id;
                
                expertiseWrapperItem.canEdit = UserContext.isUserAppModerator || !SimpplrContext.isExpertiseAppManagerControlled;
                expertiseWrapperItem.canDelete = UserContext.isUserAppModerator || !SimpplrContext.isExpertiseAppManagerControlled;
                
                expertiseWrapperItem.users = (Integer)expertiseItem.User_Count__c;
                
                wrapperList.add(expertiseWrapperItem);
            }
        }

        return wrapperList;
    }
    
    private List<ExpertiseWrapper> convertToExpertiseWrapper(List<ExternalSearchWrapper.ItemWrapper> listOfItems){
        List<ExpertiseWrapper> wrapperList = new List<ExpertiseWrapper>();
        ExpertiseWrapper expertiseWrapperItem ;
        
        for(ExternalSearchWrapper.ItemWrapper itemWrapperObj : listOfItems){
            Object item = itemWrapperObj.item;
            ExternalSearchWrapper.ExpertiseWrapper expertiseObj = (ExternalSearchWrapper.ExpertiseWrapper)item;
            
            expertiseWrapperItem = new ExpertiseWrapper();
            expertiseWrapperItem.id = expertiseObj.Id;
            expertiseWrapperItem.name = expertiseObj.name;
            expertiseWrapperItem.url = PageContext.getPageURL(Pages.app) + '?u=/expertise/' + expertiseObj.Id;
            
            expertiseWrapperItem.canEdit = UserContext.isUserAppModerator || !SimpplrContext.isExpertiseAppManagerControlled;
            expertiseWrapperItem.canDelete = UserContext.isUserAppModerator || !SimpplrContext.isExpertiseAppManagerControlled;
            
            expertiseWrapperItem.users = expertiseObj.count;
            
            wrapperList.add(expertiseWrapperItem);
        }
        

        return wrapperList;
    }

}