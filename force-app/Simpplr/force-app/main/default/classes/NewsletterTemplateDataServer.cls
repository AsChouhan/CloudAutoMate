public with sharing class NewsletterTemplateDataServer extends DataServer {
    @TestVisible private final String ACTION_VALUE_DELETE = 'delete';
	@TestVisible private final String ACTION_VALUE_GET = 'get';
    @TestVisible private final String ACTION_VALUE_SAVE = 'save';
    @TestVisible private final String ACTION_VALUE_SEARCH = 'search';
	
	public List<String> allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).replace('Blog', 'BlogPost').split(',');
    private final String REQUEST_PARAM_DATA = 'data';
    String currentUserId = UserContext.Id; 
    
    private Set<String>  allowedFeaturesInAppSet = new  Set<String>();
    
    public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }

    public override void handleRequest() {

        try {

	    	for (String feature : allowedFeaturesInAppList) {
		    	allowedFeaturesInAppSet.add(feature.toLowerCase());
		    }
	    	
        	String action = readParam(REQUEST_PARAM_ACTION);
	    	String requestData = readParam(REQUEST_PARAM_DATA);
            String result = '';

	        if (String.isBlank(action)) {
	        	throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
	        }

			if (ACTION_VALUE_SAVE.equalsIgnoreCase(action)){
                String templateId = readParam('templateId');

                if (!String.isBlank(templateId)) {
                    result  = new NewsletterService().updateTemplate(templateId, requestData); 
                    response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);

                } else {
                    result = new NewsletterService().createTemplate(requestData); 
                    response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                }
                
                
			} else if (ACTION_VALUE_DELETE.equalsIgnoreCase(action)){
                String templateId = readParam('templateId');
				result = new NewsletterService().deleteTemplate (templateId); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                
			}  else if (ACTION_VALUE_SEARCH.equalsIgnoreCase(action)){
				result = new NewsletterService().searchTemplate(requestData); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                
            }  else if (ACTION_VALUE_GET.equalsIgnoreCase(action)){
                String templateId = readParam('templateId');
				result = new NewsletterService().getTemplate(templateId); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                
            } else {
	            throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
	        }
            
        } catch (Exception ex) {
        	logger.logError('Either no page access or action parameter returning wrong data',ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        
    }
    
   	
    
}