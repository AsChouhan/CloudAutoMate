public with sharing class FlagDataServer extends DataServer{
    
    private final String REQUEST_PARAM_DATA = 'data';
    
    private final String ACTION_VALUE_DISMISS = 'dismiss';
    private final String ACTION_VALUE_DISMISS_ONBOARDING = 'dismissOnboarding';
    private final String ACTION_VALUE_RESET_ONBOARDING = 'resetOnboarding';
    
    public FlagDataServer() {
    }
    
    public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
    public override void handleRequest() {
        try {
        	logger.logDebug('FlagDataServer----entered handleRequest----');

			String action = readParam(REQUEST_PARAM_ACTION);
        	String requestData = readParam(REQUEST_PARAM_DATA);
        	
            if(String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
            }
            
            if(ACTION_VALUE_DISMISS.equalsIgnoreCase(action)) {
        		response = dismissTask(requestData);
            } else if(ACTION_VALUE_DISMISS_ONBOARDING.equalsIgnoreCase(action)) {
        		response = dismissOnboarding(requestData);
            } else if(ACTION_VALUE_RESET_ONBOARDING.equalsIgnoreCase(action)) {
        		response = resetOnboarding();
            } else {
                throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            }
            
        } catch (Exception ex) {
        	logger.logError('Either no page access or action parameter returning wrong data',ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        
    } 
    
    private ResponseWrapper dismissTask(String taskId) {
    	logger.logDebug('FlagDataServer.dismissTask()--------'+taskId);
    	ResponseWrapper responseToReturn;
    	try{
    		HelpDao daoObj = new HelpDao();
    		if(String.isNotBlank(taskId) && 'connect-account-prompt'.equalsIgnoreCase(taskId)) {
    			daoObj.dismissConnectAccountsPrompt(taskId);
    		}else {
    			daoObj.dismissTask(taskId);
    		}
    		
    		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
    	
    	} catch(Exception e) {
    		logger.logError('FlagDataServer.dismissTask()----Could not dismiss task',e);
    		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
    	}
    	return responseToReturn;
    }
    
    private ResponseWrapper dismissOnboarding(String settingName) {
    	logger.logDebug('FlagDataServer.dismissTask()--------'+settingName);
    	ResponseWrapper responseToReturn;
    	try{
    		PeopleDao daoObj = new PeopleDao();
    		daoObj.dismissOnboarding(settingName);
    		
    		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
    	
    	} catch(Exception e) {
        	logger.logError('FlagDataServer.dismissOnboarding()----Could not dismissOnboarding',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
    	return responseToReturn;
    }
    
    private ResponseWrapper resetOnboarding() {
    	logger.logDebug('FlagDataServer.resetOnboarding()--------');
    	ResponseWrapper responseToReturn;
    	
    	try{
    		PeopleDao daoObj = new PeopleDao();
    		daoObj.resetOnboarding();
    		
    		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
    	
    	} catch(Exception e) {
        	logger.logError('FlagDataServer.resetOnboarding()----Could not reset Onboarding',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
    	return responseToReturn;
    }
}