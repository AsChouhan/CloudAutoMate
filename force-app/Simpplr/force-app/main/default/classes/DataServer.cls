/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public abstract with sharing class DataServer{
	

	protected final String REQUEST_TARGET = 'target';
	protected Map<String, String> labelMap;

	protected List<String> featureFlagList;	

    protected Map<String,String> mapOfRequestParameters = new Map<String, String>();
    protected Map<String,String> mapOfRequestHeaders = new Map<String, String>();
	
	protected final String RESPONSE_STATUS_SUCCESS = 'success';
    protected final String RESPONSE_STATUS_FAIL = 'fail';
    protected final String RESPONSE_STATUS_ERROR = 'error';
    
	protected final String REQUEST_PARAM_ACTION = 'action'; 
    
    public ResponseWrapper response;

	public String resultString{get{
		if(SimpplrContext.isDebugEnabled){
			try {
				response.debugLogs = logger.getLogs();
			} catch (Exception e) {
				System.debug('Exception - ' + e.getMessage());
				response.debugLogs = new List<String>{'logger.getLogs method failed due to ' + e.getStackTraceString()};
			}
		}
		return JSON.serialize(response,true);
		
    }set;}

    /**
    * @description replacement for ApexPages.currentPage().getUrl()
    * @return String 
    **/
    public String requestURI{
    	get{
			if(requestURI == null){
				//When isRESTServiceContext = true - requestURI is set from RestWebServiceHandler
				//current page does not exists in API context
				if(ApexPages.currentPage() != null && SimpplrContext.isRESTServiceContext != true){
					requestURI = ApexPages.currentPage().getUrl();
				}
			}
			return requestURI;
	    }set;
	}
    
    public DataServer(){
		response = new ResponseWrapper();
		labelMap = new Map<String, String>();
		if(String.isNotBlank(readParam(REQUEST_TARGET))) {
			labelMap = LocaleContext.getLabelMap(readParam(REQUEST_TARGET), UserContext.languageLocaleKey);
		}
		if (ApexPages.currentPage() != null) {
			// if(SimpplrContext.isDebugEnabled){
			// 	logger.logdebug('Header: ' + ApexPages.currentPage().getHeaders());
			// 	logger.logdebug('Request Param: ' + mapOfRequestParameters);
			// }
			mapOfRequestParameters = ApexPages.currentPage().getParameters();
		}
    }

	// 
	public abstract void handleRequest();
	
	public ResponseWrapper buildResponseWrapper(String status, String message, String i18nMessage, Object result){
		return null;
	}

	public void flushLogs(){
		try {
			logger.flushLogsToDB();	
		} catch (Exception e) {
			System.debug('Exception - ' + e.getMessage());
			if(response.debugLogs == null) {
				response.debugLogs = new List<String>{'logger.flushLogsToDB method failed due to ' + e.getStackTraceString()};
			}else{
				response.debugLogs.add('logger.flushLogsToDB method failed due to ' + e.getStackTraceString());
			}
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
    public ResponseWrapper buildResponseWrapper(String status, String message, Object result){
		System.debug('?????? Dataserver. status 99   ' + status);
		System.debug('?????? Dataserver. status 100   ' + message);
		System.debug('?????? Dataserver. status 101  ' + result);


    
    	String resolvedMessage = MessageHelper.resolveMessage(message);
  		ResponseWrapper rw = new ResponseWrapper();
  		rw.status = status;
  		if(RESPONSE_STATUS_ERROR.equalsIgnoreCase(status) || RESPONSE_STATUS_FAIL.equalsIgnoreCase(status)){
  			rw.message = resolvedMessage;
  		}
  		if(result!=null){
	  		rw.result = result;
			  System.debug('?????? Dataserver.buildResponseWrapper  RW.result  109   ' + rw.result);

  		}
		  System.debug('?????? Dataserver.buildResponseWrapper  RW  109   ' + rw);

  		return rw;
  	}

  	
  	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
  	public String readParam(String requestParamName){
  		if(SimpplrContext.isRESTServiceContext != true){
  			if (ApexPages.currentPage() != null) {
				mapOfRequestParameters = ApexPages.currentPage().getParameters();
			} else if(mapOfRequestParameters == null) {
				mapOfRequestParameters = new Map<String, String>();
			}
  		}
		return (mapOfRequestParameters != null ? mapOfRequestParameters.get(requestParamName) : null);
	}

	/**
	* @description safely read parameters
	* @param requestParamName request param key
	* @return String param value
	**/
	public String readSafeParam(String requestParamName){
		return SIMPESAPI.encoder().SFDC_JSENCODE(readparam(requestParamName));
	}

	/**
	* @description replacement for ApexPages.currentPage().getHeaders()
	* @param requestHeaderName header key
	* @return String 
	**/
	public String readHeader(String requestHeaderName){
		if(SimpplrContext.isRESTServiceContext != true){
			if (ApexPages.currentPage() != null) {
				mapOfRequestHeaders = ApexPages.currentPage().getHeaders();
			} else if (mapOfRequestHeaders == null){
				mapOfRequestHeaders = new Map<String, String>();
			}
		}
		return (mapOfRequestHeaders != null ? mapOfRequestHeaders.get(requestHeaderName) : null);
	}

}