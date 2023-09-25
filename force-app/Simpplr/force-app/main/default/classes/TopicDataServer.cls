/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class TopicDataServer extends DataServer{
	public transient final String STR_ERROR_DUPLICATE_FLASH { get { return labelMap.get('manage_topics.duplicate_error_flash');}}
	private final String ACTION_VALUE_SEARCH = 'search';
    private final String ACTION_VALUE_GET = 'get';
	private final String ACTION_VALUE_MERGE = 'mergeTopics';
	private final String ACTION_VALUE_DELETE = 'deleteTopic';
	
    private final String REQUEST_PARAM_DATA = 'data';
    private final String REQUEST_PARAM_QUERY = 'term';
    private final String REQUEST_PARAM_SAVE = 'save';
    private final String REQUEST_PARAM_FROM_TOPIC_ID = 'fromTopicId';
    private final String REQUEST_PARAM_TO_TOPIC_ID = 'toTopicId';
    private final String REQUEST_PARAM_TOPIC_ID = 'topicId';
    
    private final String TOPIC_MERGE_ERROR = 'Its not possible to perform this action';
    private final String TOPIC_DELETE_ERROR = 'Its not possible to perform this action';
    public transient final String STR_ERROR_TOPIC_SPACING_N_CAPITALIZATION_ALLOWED_FLASH = 'manage_topics.spacing_and_capitilization_error_flash';
    
    public TopicDataServer() {

    }
	
	public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
    public override void handleRequest(){
    	try{
    		logger.logDebug('TopicDataServer----entered handleRequest----');
    		
    		String action = readParam(REQUEST_PARAM_ACTION);
        	
            if(String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
            }
            
            if(ACTION_VALUE_SEARCH.equalsIgnoreCase(action)) {
                response = searchTopic(readParam(REQUEST_PARAM_DATA));
                
            }else if(ACTION_VALUE_GET.equalsIgnoreCase(action)) {
                response = get(readParam('topicId'));
                
            }else if(ACTION_VALUE_MERGE.equalsIgnoreCase(action)) {
                response = mergeTopics(readParam(REQUEST_PARAM_DATA));
                
            }else if(ACTION_VALUE_DELETE.equalsIgnoreCase(action)) {
                response = deleteTopic(readParam(REQUEST_PARAM_DATA));
                
            }else if(REQUEST_PARAM_SAVE.equalsIgnoreCase(action)){
                response = save(readParam(REQUEST_PARAM_DATA));
                
            } else{
                throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            }

    	}catch(Exception ex){
            logger.logError(ex);
            
            String errorMessage = ex.getMessage();
            Set<String> ignoredMessages = new Set<String> {'INVALID_REQUEST_DATA'};
        	if(ignoredMessages.contains(errorMessage)) {
            	response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        	}else if(errorMessage.contains('DUPLICATE_VALUE')){
        		response = buildResponseWrapper(RESPONSE_STATUS_ERROR, STR_ERROR_DUPLICATE_FLASH, null);
        	}else {
        		response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        	}
        }
        
    }
    @TestVisible private ResponseWrapper save(String data){
    	ResponseWrapper resultWrapper;
    	logger.logDebug('TopicDataServer-------save-----' + data);
    	if(String.isBlank(data)){
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        }
    	Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data,Type.forName('Map<String,String>'));
    
    	if(String.isBlank(requestDataMap.get('id'))){
    		resultWrapper = createNewTopic(requestDataMap);
    	} else {
    		resultWrapper = updateTopic(requestDataMap);
    	}
    	return resultWrapper;
    }
    
   @TestVisible  private ResponseWrapper createNewTopic(Map<String,String> requestDataMap){
    	logger.logDebug('TopicDataServer-------createNewTopic-----' + requestDataMap);
    	ResponseWrapper resultWrapper = New ResponseWrapper();
        if(requestDataMap == null || requestDataMap.isEmpty()){
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        }
        if(!UserContext.canCreateTopics) {
        	throw New SimpplrException(ExceptionCode.NO_CREATE_TOPIC_PERMISSION.name());
        }
        
        if(String.isBlank(requestDataMap.get('name'))){
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        }
        String topicName = Utility.removeAllHashSymbolFromStart(requestDataMap.get('name'));
        List<Topic> listOfDBTopics = new List<Topic>();
        String BASE_QUERY= 'select id, name from Topic where name=: topicName';
        if(SimpplrContext.isCommunitiesEnabled){
    		BASE_QUERY = BASE_QUERY+' AND NetworkId = null';
    	}
    	listOfDBTopics = Database.query(BASE_QUERY);
         Topic newTopicRecord;
        if(listOfDBTopics.isEmpty()) {
	        newTopicRecord = New Topic(Name = topicName); 
            
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
            sObject obj = SIMPESAPI.accessController().insertAsUser(newTopicRecord, new List<Schema.SObjectField>{
                Topic.name
            });
            newTopicRecord = (Topic) obj;
            
        } else {
        	newTopicRecord = listOfDBTopics[0];
            throw new SimpplrException('DUPLICATE_VALUE' + listOfDBTopics[0].name);
        }
        TopicWrapper wrapperObj = New TopicWrapper();
        wrapperObj.topicid = newTopicRecord.id;
        wrapperObj.id = newTopicRecord.id;
        wrapperObj.name = newTopicRecord.name;
        wrapperObj.url =  PageContext.getPageURL(Pages.app) + '?u=/topic/' + wrapperObj.id;
        wrapperObj.talkingAboutCount = 1;
        wrapperObj.authoredBy.id = UserContext.id;
        wrapperObj.authoredBy.name = UserContext.peopleName;
        wrapperObj.canEdit = UserContext.isUserAppModerator;
        wrapperObj.canDelete = UserContext.isUserAppModerator; 
        resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Topic has been saved!', wrapperObj);
        
        return resultWrapper;   
    }

    @TestVisible private ResponseWrapper updateTopic(Map<String,String> requestDataMap){
    	logger.logDebug('TopicDataServer-------updateTopic-----' + requestDataMap);
        ResponseWrapper resultWrapper = New ResponseWrapper();
        String errorMessage = '';
        if(requestDataMap == null || requestDataMap.isEmpty()){
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        } 
        String topicId = requestDataMap.get('id');
        String topicName = requestDataMap.get('name');
        if(String.isBlank(topicId) || String.isBlank(topicName)){
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        }
        Topic newTopicRecord = New Topic();
        newTopicRecord.Id = topicId;
        newTopicRecord.Name = topicName;
        try{
            Database.SaveResult saveResult = Database.update(newTopicRecord);   
            TopicWrapper wrapperObj = New TopicWrapper();
            wrapperObj.id = topicId;
            wrapperObj.name = topicName;
            wrapperObj.authoredBy.id = UserContext.id;
            wrapperObj.authoredBy.name = UserContext.peopleName;
            wrapperObj.canEdit = UserContext.isUserAppModerator;
            resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Topic has been saved!', wrapperObj);

        }catch(Exception ex){
        	logger.logDebug('TopicDataServer.updateTopic()----Exception occured----' + ex); 
        	if(ex.getMessage().containsIgnoreCase('DUPLICATE_VALUE')) {
                resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, STR_ERROR_DUPLICATE_FLASH, null);
        	}
        	else {
                errorMessage = LocaleContext.getLabel(UserContext.languageLocaleKey, STR_ERROR_TOPIC_SPACING_N_CAPITALIZATION_ALLOWED_FLASH);
			    resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, errorMessage, null);
        	}
        }
        return resultWrapper;
    }

    @TestVisible
    private ResponseWrapper get(String topicId){
        logger.logDebug('TopicDataServer.get()-------topicId-----' + topicId);
        if(String.isBlank(topicId)){
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        }

        TopicDao topicDaoObj = new TopicDao();
    	List<Topic> topicList = topicDaoObj.getTopicsById(new List<String>{topicId});
        
        if(topicList == null || topicList.isEmpty()){
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        }
        
        Topic topicObj = topicList[0];
        TopicWrapper wrapperObj = new TopicWrapper();
        wrapperObj.topicid = topicObj.id;
        wrapperObj.id = topicObj.id;
        wrapperObj.name = topicObj.name;
        wrapperObj.url = PageContext.getPageURL(Pages.app) + '?u=/topic/' + topicObj.id;
        wrapperObj.isFollowing = false;

        if(UserContext.topicsIFollowIdSet.contains(topicObj.id)) {
            wrapperObj.isFollowing = true;
        }

        ResponseWrapper responseWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, wrapperObj);
        
        return responseWrapper;
    }

    @TestVisible private ResponseWrapper searchTopic(String data){
    		ResponseWrapper resultWrapper = new ResponseWrapper();
        ManageContentRequestWrapper requestObj = (ManageContentRequestWrapper)JSON.deserialize(data, ManageContentRequestWrapper.class);
        String sortBy = 'Name';
        String order = 'ASC';
        String searchText = String.isBlank(requestObj.term) ? '':requestObj.term;
        Integer nextPageToken = String.isNotBlank(requestObj.nextPageToken)?Integer.valueOf(requestObj.nextPageToken):0;
        Integer recordLimit;
        if(requestObj.size != null && requestObj.size > 0) {
        	recordLimit = Integer.valueOf(requestObj.size) + 1;
        }
        
        if(requestObj.sortBy != null && requestObj.sortBy.equalsIgnoreCase('talkingAbout')){
            sortBy = 'TalkingAbout';
            order = 'DESC';
        }

        List<Topic> listOfTopic = new List<Topic>();
        List<String> topicIdList = new List<String>();
        List<String> userIdList = new List<String>();
        List<TopicWrapper> topicWrapperList = new List<TopicWrapper>();
        Map<String,Object> result = New Map<String,Object>();
        TopicDao topicDaoObj = new TopicDao();
        if(SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(requestObj.term)) {
            ExternalSearchService externalSearchServiceObj = new ExternalSearchService();
            ExternalSearchWrapper.TopContentsWrapper externalSearchResponse = new ExternalSearchWrapper.TopContentsWrapper();
            externalSearchResponse = externalSearchServiceObj.searchTopic(requestObj);
            if (externalSearchResponse.listOfItems != null && externalSearchResponse.listOfItems.size() > 0){
                for (ExternalSearchWrapper.ItemWrapper itemWrapperObj : externalSearchResponse.listOfItems){
                    Object item = itemWrapperObj.item;
                    ExternalSearchWrapper.TopicWrapper tp = (ExternalSearchWrapper.TopicWrapper)item;
                    topicIdList.add(tp.id);	
                }
                List<Topic> tempTopicList = topicDaoObj.getTopicsWithCriteriaForManagePage(searchText,sortBy,order,recordLimit,nextPageToken,topicIdList);
                Map<Id, Topic> tempTopicMap = new Map<Id, Topic>(tempTopicList);
                for(String topicId : topicIdList) {
                    if(tempTopicMap.containsKey(topicId)) {
                        listOfTopic.add(tempTopicMap.get(topicId));
                    }
                }
                tempTopicList.clear();
                tempTopicMap.clear();
            }
            if (!listOfTopic.isEmpty()){
                for (Topic tp : listOfTopic){
                        userIdList.add(tp.CreatedBy.Id);	
                    }
            }
            Map<String,People__c> userIdToPeopleMap = Utility.userIdToPeopleMap(userIdList);
            topicWrapperList = toManageTopicWrapper(listOfTopic,userIdToPeopleMap);
            result.put('nextPageToken', externalSearchResponse.nextPageToken);
        }else{
            listOfTopic = topicDaoObj.getTopicsWithCriteriaForManagePage(searchText,sortBy,order,recordLimit,nextPageToken,null);
            if (!listOfTopic.isEmpty()){
            for (Topic tp : listOfTopic){
                    userIdList.add(tp.CreatedBy.Id);	
                }
            }
            Map<String,People__c> userIdToPeopleMap = Utility.userIdToPeopleMap(userIdList);
            topicWrapperList = toManageTopicWrapper(listOfTopic,userIdToPeopleMap);
                
    
            if (recordLimit != null && topicWrapperList.size() == recordLimit && nextPageToken < 2000) {
                topicWrapperList.remove(recordLimit - 1);
                result.put('nextPageToken', nextPageToken + requestObj.size);
            }
        }    
        
        result.put('listOfItems',topicWrapperList);
        resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Records have been retirived!', result);
        return resultWrapper;
    }
	
	// Only users with the 'Delete Topics' or 'Modify All Data' permission can merge topics.
	@TestVisible private ResponseWrapper mergeTopics(String data) {
		ResponseWrapper localResult = new ResponseWrapper();
    	
		try {
			if(data == null || String.isBlank(data)){
	            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
	        }
            RecursionCheck.stopRecursion();
                
		    Map<String,Object> requestData = (Map<String,Object>)JSON.deserializeUntyped(data);
		    String fromTopicId = String.valueOf(requestData.get(REQUEST_PARAM_FROM_TOPIC_ID));
		    String toTopicId = String.valueOf(requestData.get(REQUEST_PARAM_TO_TOPIC_ID));
			List<String> oldTopicList = new List<String> {fromTopicId};
            ConnectApi.Topic topicObj = ConnectApi.Topics.mergeTopics(null, toTopicId, oldTopicList);
            List<External_Search_Data_Trail__c> listToInsert = new List<External_Search_Data_Trail__c>();
            if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
                External_Search_Data_Trail__c obj = new External_Search_Data_Trail__c();
                obj.Topic__c = fromTopicId;
                obj.Type__c = 'Merge_Topic';
                obj.Merge_To__c = toTopicId;
                obj.Merge_From__c =  fromTopicId;     
                listToInsert.add(obj);

                List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
		
                if( !listToInsert.isEmpty() ) {
                    fieldList.add(External_Search_Data_Trail__c.Topic__c);
                    fieldList.add(External_Search_Data_Trail__c.Type__c);
                    fieldList.add(External_Search_Data_Trail__c.Merge_To__c);
                    fieldList.add(External_Search_Data_Trail__c.Merge_From__c);

                    SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                    SIMPESAPI.accessController().insertAsUser(listToInsert, fieldList);
                }
            }         
            
			localResult.status = RESPONSE_STATUS_SUCCESS;
	        localResult.message = '';
		}catch(Exception ex){
        	logger.logDebug('TopicDataserver.mergeTopics() Exception while merging Topics : ' + ex);
        	
        	localResult.status = RESPONSE_STATUS_ERROR;
	        localResult.message = null;
        }
        
		return localResult;
	}
	
	// Only users with the 'Delete Topics' or 'Modify All Data' permission can delete topics.
	@TestVisible private ResponseWrapper deleteTopic(String data) {
		ResponseWrapper localResult = new ResponseWrapper();
    	
		try {
			if(data == null || String.isBlank(data)){
	            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
	        }
		    
		    Map<String,Object> requestData = (Map<String,Object>)JSON.deserializeUntyped(data);
		    String topicId = String.valueOf(requestData.get(REQUEST_PARAM_TOPIC_ID));
			
			if(String.isBlank(topicId)){
	            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
	        }
	        
			TopicDao topicDaoObj = new TopicDao();
			if(topicDaoObj.getTopicsById(new List<String>{topicId}).size() > 0){
				ConnectApi.Topics.deleteTopic(null, topicId);
			}
			
			localResult.status = RESPONSE_STATUS_SUCCESS;
	        localResult.message = '';
		}catch(Exception ex){
        	logger.logDebug('Exception while deleting Topic : ' + ex);
        	
        	localResult.status = RESPONSE_STATUS_ERROR;
	        localResult.message = TOPIC_DELETE_ERROR;
        }
        
		return localResult;
	}
	
    @TestVisible  private List<TopicWrapper> toManageTopicWrapper(List<Topic> listOfTopic, Map<String,People__c> userIdToPepleMap){
        List<TopicWrapper> wrapperList = new List<TopicWrapper>();
        TopicWrapper topicWrapperItem ;
        if(listOfTopic != null && listOfTopic.size() > 0){
            for(Topic topicItem :listOfTopic){
                topicWrapperItem = new TopicWrapper();
                topicWrapperItem.id = topicItem.Id;
                topicWrapperItem.url = PageContext.getPageURL(Pages.app) + '?u=/topic/' + topicItem.Id;
                topicWrapperItem.feedUrl = PageContext.getPageURL(Pages.app) + '?u=/topic/' + topicItem.Id;
                topicWrapperItem.name = topicItem.Name;
                topicWrapperItem.talkingAboutCount = topicItem.talkingAbout;
                topicWrapperItem.canEdit = UserContext.isUserAppModerator;
                topicWrapperItem.canDelete = UserContext.isUserAppModerator; 
                if (userIdToPepleMap != NULL && userIdToPepleMap.get(topicItem.CreatedBy.Id) != NULL) {
                	topicWrapperItem.authoredBy.id = userIdToPepleMap.get(topicItem.CreatedBy.Id).id;
                	topicWrapperItem.authoredBy.peopleId = userIdToPepleMap.get(topicItem.CreatedBy.Id).id;
                	topicWrapperItem.authoredBy.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + topicWrapperItem.authoredBy.peopleId;
                } 
                topicWrapperItem.authoredBy.name = userIdToPepleMap.get(topicItem.CreatedBy.Id) != null ? userIdToPepleMap.get(topicItem.CreatedBy.Id).Full_Name__c : topicItem.CreatedBy.Name;
                if(UserContext.topicsIFollowIdSet.contains(topicItem.Id)) {
    				topicWrapperItem.isFollowing = true;
		    	} else {
		    		topicWrapperItem.isFollowing = false;
		    	}
                wrapperList.add(topicWrapperItem);
            }
        }
        return wrapperList;
    }
    
}