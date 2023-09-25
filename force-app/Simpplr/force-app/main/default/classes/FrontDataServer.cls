public with sharing class FrontDataServer extends DataServer{ 
	
	private final String REQUEST_TARGET = 'target';
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public FrontDataServer() {
        
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
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
			
        	logger.logDebug('FrontDataServer----entered handleRequest----');
        	
        	if(!AccessManager.hasPageAccess(getPageFeature())) {
		        throw new SimpplrException(ServiceConstants.ERROR_404);
	    	}
	    	
			String target = readParam(REQUEST_TARGET);
        	
            if (String.isBlank(target)) {
                throw new SimpplrException(ServiceConstants.MISSING_TARGET_PARAM);
            }

            // protect from CSRF attack
            AccessManager.protectFromRequestForgery(target);
            
            String namespace = String.isBlank(SimpplrContext.packageName)? '': SimpplrContext.packageName;
            logger.logDebug('namespace -- ' + namespace);
            
            Type t = Type.forName(namespace, target);
            logger.logDebug('target-- ' + target);
        	DataServer ds = (DataServer)t.newInstance();
        	
            if(ds.featureFlagList !=null) {
                FeatureFlagManager.initializeFeatureFlagValueMap(ds.featureFlagList);
            }
        	ds.handleRequest();
            this.response = ds.response;
            
        } catch (Exception ex) {
        	logger.logError('Either no page access or wrong parameter.',ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }

        try {
            logger.flushLogsToDB();    
        } catch (Exception e) {
            System.debug('Exception - ' + e.getMessage());
            // Do not want to log this exception 
        }
	}

    
	
	
}