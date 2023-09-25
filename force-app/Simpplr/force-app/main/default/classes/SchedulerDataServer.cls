public with sharing class SchedulerDataServer extends DataServer{ 
	
    private final String ACTION_VALUE_SEARCH = 'search'; 
    
    private final String REQUEST_PARAM_DATA = 'data';
    
    private final String ACTION_VALUE_RUN_SCHEDULER_NOW='runSchedulerNow';
    
    private final String ACTION_VALUE_SCHEDULE_SCHEDULER_NOW='schduleSchdulerNow';
    
    private final String ACTION_VALUE_CLEAR_SCHEDULER='clear';

    private final String REQUEST_PARAM_BATCH_SIZE = 'bsize';

    private final String REQUEST_PARAM_BATCH_CRON = 'bcron';

    private final String REQUEST_PARAM_BATCH_KILL = 'killold';
    
    /**
     *
     */
    public SchedulerDataServer() {
        
    }
    	
    public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public override void handleRequest() {
        try {
			logger.logDebug('SchedulerDataServer----entered handleRequest----');        	
			
			String action = readParam(REQUEST_PARAM_ACTION);
        	
            if (String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
            }
            
            if (ACTION_VALUE_SEARCH.equalsIgnoreCase(action)) {
                String requestData = readParam(REQUEST_PARAM_DATA);
	        	response = getSchdulerListing(requestData);
            } else if(ACTION_VALUE_RUN_SCHEDULER_NOW.equalsIgnoreCase(action)){
            	String requestData = readParam(REQUEST_PARAM_DATA);
	        	response = runSchedulerNow(requestData);
            } else if(ACTION_VALUE_SCHEDULE_SCHEDULER_NOW.equalsIgnoreCase(action)){
            	String requestData = readParam(REQUEST_PARAM_DATA);
	        	response = scheduleSchedulerNow(requestData);
            } else if(ACTION_VALUE_CLEAR_SCHEDULER.equalsIgnoreCase(action)){
            	String requestData = readParam(REQUEST_PARAM_DATA);
	        	response = clear(requestData);
            } else {
                throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            }
            
        } catch (Exception ex) {
        	logger.logError('Either no page access or action parameter returning wrong data',ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR,MessageHelper.translateSFMessageToErrorCode(ex), null);
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
    private ResponseWrapper getSchdulerListing(String requestData){
    	logger.logDebug('SchedulerDataServer.getSchdulerListing()----requestData----'+requestData);
        	ResponseWrapper responseWrapperObj = null;
        try{
        	SchedulerWrapper.PaginationWrapper itemsList = new SchedulerWrapper.PaginationWrapper();
        	SchedulerDao schedulerDaoObj = new SchedulerDao();
        	itemsList.listOfItems= schedulerDaoObj.getApexClassWrapperList();
        	
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, itemsList);
       		logger.logDebug('SchedulerDataServer.getSchdulerListing()----responseWrapperObj----'+responseWrapperObj);
        }catch(Exception e){
        	logger.logError('SchedulerDataServer----Could not fetch scheduler listing',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
        return responseWrapperObj;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private ResponseWrapper runSchedulerNow(String requestData){
    	logger.logDebug('SchedulerDataServer.runSchedulerNow()----requestData----'+requestData);
        	ResponseWrapper responseWrapperObj = null;
        try{
        	SchedulerDao schedulerDaoObj= new SchedulerDao();
        	List<String> listOfSchedulerTobeRun= (List<String>)Json.deserialize(requestData,List<String>.class);
        	
        	schedulerDaoObj.runSchedulerNow(listOfSchedulerTobeRun);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
        	logger.logDebug('SchedulerDataServer.runSchedulerNow()----responseWrapperObj----'+responseWrapperObj);
        }catch(Exception e){
        	logger.logError('SchedulerDataServer----Could not run scheduler',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
        return responseWrapperObj;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private ResponseWrapper scheduleSchedulerNow(String requestData){
    	logger.logDebug('SchedulerDataServer.scheduleSchedulerNow()----requestData----'+requestData);
        	ResponseWrapper responseWrapperObj = null;
        try{

        	Integer bsize = String.isBlank(readParam(REQUEST_PARAM_BATCH_SIZE))? null : Integer.valueOf(readParam(REQUEST_PARAM_BATCH_SIZE));
            String  bcron = String.isBlank(readParam(REQUEST_PARAM_BATCH_CRON))? null : readParam(REQUEST_PARAM_BATCH_CRON);
            Boolean killold = String.isBlank(readParam(REQUEST_PARAM_BATCH_KILL))? false : Boolean.valueOf(readParam(REQUEST_PARAM_BATCH_KILL));
            
        	List<String> listOfSchedulerTobeScheduled= (List<String>)Json.deserialize(requestData,List<String>.class);
        	SchedulerDao schedulerDaoObj= new SchedulerDao();
        	SchedulerWrapper.PaginationWrapper itemsList = new SchedulerWrapper.PaginationWrapper();
        	itemsList.listOfItems = schedulerDaoObj.scheduleSchedulerNow(listOfSchedulerTobeScheduled, bsize, bcron, killold);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, itemsList);
       		logger.logDebug('SchedulerDataServer.scheduleSchedulerNow()----responseWrapperObj----'+responseWrapperObj);
        }catch(Exception e){
        	logger.logError('SchedulerDataServer----Could not schedule scheduler',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
        return responseWrapperObj;
    }

    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private ResponseWrapper clear(String requestData){
    	logger.logDebug('SchedulerDataServer.clear()----requestData----'+requestData);
        ResponseWrapper responseWrapperObj = null;
        try{
        	List<String> listOfSchedulerToBeCleared= (List<String>)Json.deserialize(requestData,List<String>.class);
        	SchedulerDao schedulerDaoObj= new SchedulerDao();
        	schedulerDaoObj.clear(listOfSchedulerToBeCleared);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
        }catch(Exception e){
        	logger.logError('SchedulerDataServer----Could not clear scheduler',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        logger.logDebug('SchedulerDataServer.clear()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
}