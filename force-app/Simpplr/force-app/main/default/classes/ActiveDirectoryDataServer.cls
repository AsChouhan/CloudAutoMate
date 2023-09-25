public with sharing class ActiveDirectoryDataServer extends DataServer {
    private final String ACTION_VALUE_SEARCH = 'search'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_VALUE_GROUP_SEARCH = 'groupSearch'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_VALUE_GET_GROUPS = 'getActiveDirectoryGroups'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_VALUE_GET_GROUP_MEMBERS = 'getActiveDirectoryGroupMembers'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_VALUE_INITIATE_AD_GROUP_MEM_SYNC = 'initiateADGroupMemSync'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_VALUE_GET_SELECTED_GROUP_TYPES = 'getSelectedGroupTypes'; // NOPMD - correct naming convension, suppressed codacy error

    private final String REQUEST_PARAM_DATA = 'data';

    public ActiveDirectoryDataServer() {
		featureFlagList = new List<String> {
			'ad_groups_v2'
		};
	}
    public override void handleRequest () {
		logger.logDebug('ActiveDirectoryDataServer.handleRequest()----entered handleRequest----');
		
		try {
			String action = readParam(REQUEST_PARAM_ACTION);
			String requestData = readParam(REQUEST_PARAM_DATA);
			
			if (ACTION_VALUE_GROUP_SEARCH.equalsIgnoreCase(action)){
	            response = groupSearch(requestData);
		        
			} else if (ACTION_VALUE_GET_GROUPS.equalsIgnoreCase(action)){
                response = getActiveDirectoryGroups(requestData);

            } else if (ACTION_VALUE_GET_GROUP_MEMBERS.equalsIgnoreCase(action)){
                response = getActiveDirectoryGroupMembers(requestData);

            } else if(ACTION_VALUE_INITIATE_AD_GROUP_MEM_SYNC.equalsIgnoreCase(action)) {
                response = initiateADGroupMemSync(requestData);

            } else if(ACTION_VALUE_GET_SELECTED_GROUP_TYPES.equalsIgnoreCase(action)) {
                response = getSelectedGroupTypes();
            } else { 
				response = null;

			}
			
		} catch (Exception ex) {
            logger.logError('ActiveDirectoryDataServer.handleRequest()---Exception occured----', ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        
    }
    
    private ResponseWrapper groupSearch(String requestData) {
		logger.logDebug('ActiveDirectoryDataServer.groupSearch()----- requestData: ' + requestData);
        ResponseWrapper responseWrapperObj = null;
        try {
            Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestData, 
                    Map<String, String>.class);
            logger.logDebug('ActiveDirectoryDataServer.groupSearch()----requestMap----' + requestMap);
            Boolean selectedAdGroups = requestMap.containsKey('selected') ?
                                        Boolean.valueOf(requestMap.get('selected')) : false;
            String  term = requestMap.get('term');
            ActiveDirectoryService aDService = new ActiveDirectoryService();
            List<ActiveDirectoryModel.ADGroup> listOfAdGrpWrap = new List<ActiveDirectoryModel.ADGroup>();

            if (selectedAdGroups) {
                listOfAdGrpWrap = aDService.searchSelectedGroups(term);
                
            } else {
                // All AD groups will be returned using REST API calling  
                // aDService.getAllGroups(); 
            }

            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, listOfAdGrpWrap);
            
		} catch (Exception ex) {
			logger.logError('AudienceDataServer.groupSearch()---Exception occured----', ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		 
		return responseWrapperObj;
	}

    /**
     * @description this method handle all the ad group listing, filteing and searching
     * @return ResponseWrapper - response wrapper
     * @param requestData - string type request data
     */
    private ResponseWrapper getActiveDirectoryGroups(String requestData) {
		logger.logDebug('ActiveDirectoryDataServer.getActiveDirectoryGroups()----- requestData: ' + requestData);
        ResponseWrapper responseWrapperObj = null;
        try {
            ActiveDirectoryService aDService = new ActiveDirectoryService();
            ActiveDirectoryService.ResultWrapper responseFromAD = aDService.getActiveDirectoryGroups(requestData, FeatureFlagManager.isFeatureEnabled('ad_groups_v2'));
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, responseFromAD);
            
		} catch (Exception ex) {
			logger.logError('AudienceDataServer.getActiveDirectoryGroups()---Exception occured----', ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		 
		return responseWrapperObj;
	}

    /**
     * @description this method handle all the ad group members listing
     * @return ResponseWrapper - response wrapper
     * @param requestData - string type request data
     */
    private ResponseWrapper getActiveDirectoryGroupMembers(String requestData) {
		logger.logDebug('ActiveDirectoryDataServer.getActiveDirectoryGroupMembers()----- requestData: ' + requestData);
        ResponseWrapper responseWrapperObj = null;
        try {
            ActiveDirectoryService aDService = new ActiveDirectoryService();
            ActiveDirectoryService.ResultWrapper responseFromAD = aDService.getActiveDirectoryGroupMembers(requestData);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, responseFromAD);
            
		} catch (Exception ex) {
			logger.logError('AudienceDataServer.getActiveDirectoryGroupMembers()---Exception occured----', ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		 
		return responseWrapperObj;
	}

    /**
     * @description action to return which AD Group Types are selected
     * @param requestData
     * @return `ResponseWrapper`
     */
    private ResponseWrapper getSelectedGroupTypes() {
        logger.logDebug('ActiveDirectoryDataServer.getSelectedGroupTypes()----- ');
        ResponseWrapper responseWrapperObj = null;
        try {
            ActiveDirectoryHelper adHelperObj = new ActiveDirectoryHelper();
            ActiveDirectoryModel.SelectedGroupTypes selectedGroupTypesWrapperObj =  adHelperObj.getSelectedGroupTypesWrapper(FeatureFlagManager.isFeatureEnabled('ad_groups_v2'));
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, selectedGroupTypesWrapperObj);
        } catch (Exception ex) {
			logger.logError('ActiveDirectoryDataServer.getSelectedGroupTypes()---Exception occured----', ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);            
        }

        return responseWrapperObj;
    }

    private ResponseWrapper initiateADGroupMemSync(String requestData) {
		logger.logDebug('ActiveDirectoryDataServer.initiateADGroupMemSync()----- requestData: ' + requestData);
        ResponseWrapper responseWrapperObj = null;        
        try {
            Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(requestData);
            logger.logDebug('ActiveDirectoryDataServer.initiateADGroupMemSync()----requestMap----' + requestMap);    
            String jobType = (String)requestMap.get('jobType');
            if(String.isBlank(jobType)) {
                throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
            }
            else if(jobType.endsWithIgnoreCase('intiateADGroupSyncJob')) {
                ActiveDirectoryService.intiateADGroupSyncJob();
            } else if(jobType.equalsIgnoreCase('initiateAudienceMemSync')) {
                List<Object> adGroupIdsDeletedFromPortal = (List<Object>)requestMap.get('adGroupIdsDeletedFromPortal');
                if(adGroupIdsDeletedFromPortal.isEmpty()) {
                    ActiveDirectoryService.initiateAudienceMemSync();
                } else {
                    ActiveDirectoryHelper adHelperObj = new ActiveDirectoryHelper();
                    adHelperObj.syncGroupsDeletedFromADPortal(adGroupIdsDeletedFromPortal);
                }
            }        
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
        } catch (Exception ex) {
			logger.logError('AudienceDataServer.initiateADGroupMemSync()---Exception occured----', ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);            
        }

        return responseWrapperObj;
    }    

}