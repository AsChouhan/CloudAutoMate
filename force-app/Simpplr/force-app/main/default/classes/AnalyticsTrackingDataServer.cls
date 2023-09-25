/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class AnalyticsTrackingDataServer extends DataServer{ 
	private final String REQUEST_PARAM_DATA = 'data';
	private final String ACTION_CREATE_ANALYTICS_FILE_UPLOAD_RECORD = 'createAnalyticsFileUploadRecord';
    public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
    public override void handleRequest() {
        try {        	
			logger.logDebug('AnalyticsTrackingDataServer----entered handleRequest----');
			String action = readParam(REQUEST_PARAM_ACTION);
			String requestData = readParam(REQUEST_PARAM_DATA);
			ResponseWrapper response = new ResponseWrapper();
			if (string.isBlank(action)){
	        // Condition for calling Mount and Move batch for the user
	        if (SimpplrContext.integrations.containsKey(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING) &&
	        		SimpplrContext.integrations.get(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING).Integration_Enabled__c &&
	           		SimpplrContext.integrations.get(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING).Connected__c &&
			   		UserContext.integrations.containsKey(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING) &&
	           		UserContext.integrations.get(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING).Batch_Flag__c &&
	           		UserContext.integrations.get(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING).Connected__c) {
	           	Database.executeBatch(new BatchEFSUserSync('MOUNT', null, ServiceConstants.STORAGE_TYPE_DROPBOX_STRING), 40);
            }
        	
            Map<String, String> mapOfParams = (Map<String, String>) JSON.deserialize(requestData, Map<String, String>.class);
	        new AnalyticsDao().pushViewData(mapOfParams);
	        String pageName = mapOfParams.get('pageName');
			PeopleDao daoObj = new PeopleDao();	

			if(UserContext.getCurrentUserInfo != null && UserContext.getCurrentUserInfo.OwnerId != UserContext.userId) {
				logger.logDebug('AnalyticsTrackingDataServer----updatePeopleOwnerId----');
				daoObj.updatePeopleOwnerIdToCurrentUserId();
				daoObj.updatePeoplePrefOwnerIdToCurrentUserId();
				daoObj.updatePeopleIntegrationOwnerIdToCurrentUserId();
			}
	        if (String.isNotBlank(pageName) && pageName.containsIgnoreCase('HomeMyDashboard')) {
				daoObj.renewExternalPhotoURL();
				daoObj.syncGroupMembership();
				daoObj.sendMobilePromotionInAppNotification();
			}
			response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);			
		} else if(ACTION_CREATE_ANALYTICS_FILE_UPLOAD_RECORD.equalsIgnoreCase(action)) {
			response = createAnalyticsFileUploadRecord(requestData);    	       

		} 
		
		
	 } catch (Exception ex) {
        	response = buildResponseWrapper(RESPONSE_STATUS_ERROR, 
					MessageHelper.translateSFMessageToErrorCode(ex), null);
		}

	}
	private ResponseWrapper createAnalyticsFileUploadRecord(String requestData){  
        ResponseWrapper localResult = null;
        try {
			Map<String, String> mapOfParams = (Map<String, String>) JSON.deserialize(requestData, Map<String, String>.class);
	        new AnalyticsDao().pushAnalyticsFileData(mapOfParams);
	       
			localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
        } catch(Exception e) {
        	logger.logError(e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult; 
	}

}