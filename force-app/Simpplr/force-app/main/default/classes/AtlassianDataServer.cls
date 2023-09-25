public with sharing class AtlassianDataServer extends DataServer {
	
    private final String ACTION_VALUE_GET_CONFLUENCE_SPACES = 'getConfluenceSpaces';
	private final String ACTION_VALUE_GET_CONFLUENCE_SEARCH = 'searchConfluence';
	private final String ACTION_VALUE_GET_CONFLUENCE_USERS = 'getConfluenceUsers';
	private final String ACTION_VALUE_UPDATE_INTEGRATION_INFO = 'updateIntegrationInfo';
    
    private final String REQUEST_PARAM_DATA = 'data';

	public final String CONFLUENCE = 'Confluence';
    
    public override void handleRequest () {
		logger.logDebug('AtlassianDataServer.handleRequest()----entered handleRequest----');
		
		try {
			String action = readParam(REQUEST_PARAM_ACTION);
			String requestData = readParam(REQUEST_PARAM_DATA);
			if(ACTION_VALUE_GET_CONFLUENCE_SPACES.equalsIgnoreCase(action)){
	            response = getConfluenceSpaces(requestData);		    
		        
			} else if(ACTION_VALUE_GET_CONFLUENCE_SEARCH.equalsIgnoreCase(action)){
	            response = searchConfluence(requestData);		    
		        
			} else if(ACTION_VALUE_GET_CONFLUENCE_USERS.equalsIgnoreCase(action)){
				response = getConfluenceUsers(requestData);	

			} else if(ACTION_VALUE_UPDATE_INTEGRATION_INFO.equalsIgnoreCase(action)){
				response = updateIntegrationInfo(requestData);	

			} else {
				response = null;

			}
			
		} catch (Exception ex) {
            logger.logError('AtlassianDataServer.handleRequest()---Exception occured----', ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        
	}
	
    @TestVisible
	private ResponseWrapper getConfluenceSpaces(String requestData) {
		logger.logDebug('AtlassianDataServer.getConfluenceSpaces() ');
		PaginationWrapper paginationWrapperObj = new PaginationWrapper();
		ResponseWrapper responseWrapperObj = null;

		try {
			Map<String,Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(requestData);
			String nextPageToken = requestMap.containsKey('nextPageToken') ? (String)requestMap.get('nextPageToken') : null;
			Integer recordLimit = requestMap.containsKey('size') ? (Integer)requestMap.get('size') : SimpplrContext.simpplrDefaultPageSize;
			AtlassianService service = new AtlassianService();
			AtlassianWrapper.ConfluenceSpacesWrapper confluenceSpacesWrapperObj = service.getConfluenceSpaces(recordLimit, nextPageToken, requestMap);
			List<AtlassianWrapper.KnowledgeBaseWrapper> listOfConfluenceSpaces = confluenceSpacesWrapperObj.results;
			if(listOfConfluenceSpaces !=null){
				paginationWrapperObj.listOfItems.addAll(listOfConfluenceSpaces);
	   		}
	        paginationWrapperObj.nextPageToken = confluenceSpacesWrapperObj.nextPageToken!=null?confluenceSpacesWrapperObj.nextPageToken:null;
    		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, paginationWrapperObj);
		} catch (Exception ex) {
			logger.logError('AtlassianDataServer.getConfluenceSpaces()---Exception occured----', ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		
		return responseWrapperObj;
	}

    @TestVisible
	private ResponseWrapper searchConfluence(String requestData) {
		logger.logDebug('AtlassianDataServer.searchConfluence() ');
		PaginationWrapper paginationWrapperObj = new PaginationWrapper();
		ResponseWrapper responseWrapperObj = null;

		try {

			Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(requestData);
			String nextPageToken = requestMap.containsKey('nextPageToken') ? (String) requestMap.get('nextPageToken') : null;
			Integer recordLimit = 16;
			AtlassianService service = new AtlassianService();
			AtlassianWrapper.SearchWrapper confluenceSearchWrapper = service.searchConfluence(recordLimit, nextPageToken, requestMap);
			List<AtlassianWrapper.KBItemSearchWrapper> confluenceSearchItemWrapperList = confluenceSearchWrapper.results;
			if(confluenceSearchItemWrapperList != null){
				paginationWrapperObj.listOfItems.addAll(confluenceSearchItemWrapperList);
	   		}

			paginationWrapperObj.totalRecords = confluenceSearchWrapper.totalRecords;
			paginationWrapperObj.term = requestMap.containsKey('term') ? (String) requestMap.get('term') : null;   
	        paginationWrapperObj.nextPageToken = confluenceSearchWrapper.nextPageToken != null ? confluenceSearchWrapper.nextPageToken : null;
    		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, paginationWrapperObj);
		} catch (Exception ex) {
			logger.logError('AtlassianDataServer.searchConfluence()---Exception occured----', ex);
			if (ex.getMessage().containsIgnoreCase(ServiceConstants.CONFLUENCE_REFRESH_TOKEN_EXPIRED)) {
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, ServiceConstants.CONFLUENCE_REFRESH_TOKEN_EXPIRED, null);
			} else{
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
			}	
		}
		
		return responseWrapperObj;
	}	

    @TestVisible
	private ResponseWrapper getConfluenceUsers(String requestData) {
		logger.logDebug('AtlassianDataServer.getConfluenceUsers() ');
		PaginationWrapper paginationWrapperObj = new PaginationWrapper();
		ResponseWrapper responseWrapperObj = null;

		try {

			Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(requestData);
			String nextPageToken = requestMap.containsKey('nextPageToken') ? (String) requestMap.get('nextPageToken') : null;
			Integer recordLimit = requestMap.containsKey('size') ? (Integer)requestMap.get('size') : SimpplrContext.simpplrDefaultPageSize;
			AtlassianService service = new AtlassianService();
			AtlassianWrapper.ContributorWrapper contributorWrapper = service.getConfluenceUsers(recordLimit, nextPageToken, requestMap);
			List<AtlassianWrapper.ContributorItemWrapper> contributorItemWrapperList = contributorWrapper.results;
			if(contributorItemWrapperList != null){
				paginationWrapperObj.listOfItems.addAll(contributorItemWrapperList);
	   		}
	        paginationWrapperObj.nextPageToken = contributorWrapper.nextPageToken != null ? contributorWrapper.nextPageToken : null;
    		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, paginationWrapperObj);
		} catch (Exception ex) {

			logger.logError('AtlassianDataServer.getConfluenceUsers()---Exception occured----', ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		
		return responseWrapperObj;
	}

    @TestVisible
	private ResponseWrapper updateIntegrationInfo( String requestData ) {
		logger.logDebug('AtlassianDataServer.updateIntegrationInfo() '+requestData);
		ResponseWrapper responseWrapperObj = null;
        List<ConnectedUsersWrapper> dataList = (List<ConnectedUsersWrapper>)JSON.deserialize(requestData, List<ConnectedUsersWrapper>.class);
        try{
			if(dataList.size() > 0){
				Map<String, ConnectedUsersWrapper> accountIdToUserInfo = new Map<String, ConnectedUsersWrapper>();
				List<sObject> lstIntegrationRecords = new List<sObject>();
				List<People_Integration__c> peopleIntegrationDeleteRecordsList = new List<People_Integration__c>();
				Set<Id> dismissedPeopleIdSet = new Set<Id>();
				Boolean isAdminDisconnected = false;
				for(ConnectedUsersWrapper userInfo:dataList){
					accountIdToUserInfo.put(userInfo.accountId, userInfo);
				}
		
				for(App_Integration__c record :[SELECT id, name, External_id__c, Integration_Enabled__c, Is_Deleted__c, Extra_Url_Parameters__c, Endpoint_Url__c, User_email__c, User_name__c FROM App_Integration__c WHERE External_id__c IN :accountIdToUserInfo.keySet() WITH SECURITY_ENFORCED ]){
					if(accountIdToUserInfo.get(record.External_id__c).isNotValidConnection != null &&
					   accountIdToUserInfo.get(record.External_id__c).isNotValidConnection) {
						isAdminDisconnected = true;
						deleteAtlassianPeopleIntegrations();
					} else {
						if(accountIdToUserInfo.get(record.External_id__c).isUpdate){
							record.User_name__c = accountIdToUserInfo.get(record.External_id__c).userName;
							record.User_email__c = accountIdToUserInfo.get(record.External_id__c).userEmail;
						} else {
			
							record.User_name__c = null;
							record.User_email__c = null;
							record.External_id__c = null;
							record.Integration_Enabled__c = false;
							record.Is_Deleted__c = true;
							record.Extra_Url_Parameters__c = null;
							record.Endpoint_Url__c = null;
							record.Refresh_Token_Expiration_Datetime__c = Datetime.now();
							
						}
						lstIntegrationRecords.add(record);
					}
				}

				if(isAdminDisconnected == true) {
					responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
					return responseWrapperObj;
				}

				for(People_Integration__c record :[SELECT id, name, External_id__c, Is_Deleted__c, User_email__c, User_name__c, People__c  FROM People_Integration__c WHERE External_id__c IN :accountIdToUserInfo.keySet() WITH SECURITY_ENFORCED]){

					if(accountIdToUserInfo.get(record.External_id__c).isNotValidConnection != null &&
					   accountIdToUserInfo.get(record.External_id__c).isNotValidConnection) {
						dismissedPeopleIdSet.add(record.People__c);
						peopleIntegrationDeleteRecordsList.add(record);
					} else {
						if(accountIdToUserInfo.get(record.External_id__c).isUpdate){
							record.User_name__c = accountIdToUserInfo.get(record.External_id__c).userName;
							record.User_email__c = accountIdToUserInfo.get(record.External_id__c).userEmail;
						} else {
			
							record.User_name__c = null;
							record.User_email__c = null;
							record.External_id__c = null;
							record.Is_Deleted__c = true;
						}
						lstIntegrationRecords.add(record);
					}

				}		

				if(lstIntegrationRecords.size() > 0){
					update lstIntegrationRecords;
				}
				if(peopleIntegrationDeleteRecordsList.size() > 0){
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().deleteAsUser(peopleIntegrationDeleteRecordsList);
				}
				if(dismissedPeopleIdSet.size() > 0) {
					HelpDao helpDaoObj = new HelpDao();
					helpDaoObj.insertHelptextViewRecords(dismissedPeopleIdSet, ServiceConstants.HELP_TEXT_ATLASSIAN_DISMISSED_TASK, 
														ServiceConstants.DISMISSIBLE_FLASHES_TASK_TYPE_MAP.get('ERROR'));
					// calling method to save email logs and send email
					NotificationDispatcher.userIntegrationTokenExpireSendEmailSaveLogs(dismissedPeopleIdSet,CONFLUENCE);
				}		
			}
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
		} catch (Exception ex) {
			logger.logError('AtlassianDataServer.updateIntegrationInfo()---Exception occured----', ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return responseWrapperObj;
    }

    private void deleteAtlassianPeopleIntegrations() {
		Database.executeBatch(new BatchDeleteIntegrationRecords(new List<String>{IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN}, 'deleteAtlassianDisconnectedRecords'));
	}
	
	private class ConnectedUsersWrapper{
        String accountId;
        String userName;
        String userEmail;
        Boolean isUpdate;
		Boolean isNotValidConnection;
    }

	public class PaginationWrapper{
		public String term;
		public String nextPageToken;
		public Integer totalRecords;
    	public List<Object> listOfItems = new List<Object>();
	}


}