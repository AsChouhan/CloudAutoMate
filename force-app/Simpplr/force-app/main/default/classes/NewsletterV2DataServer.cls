public with sharing class NewsletterV2DataServer extends DataServer {
    @TestVisible private final String ACTION_VALUE_GET = 'get';
	@TestVisible private final String ACTION_VALUE_SAVE = 'save';
	@TestVisible private final String ACTION_VALUE_SAVE_GET_AUDITLOG = 'getAuditLog';
	@TestVisible private final String ACTION_VALUE_GET_SNAPSHOT = 'getSnapshot';
	@TestVisible private final String ACTION_VALUE_DELETE = 'delete';
	//@TestVisible private final String ACTION_VALUE_SEND = 'send'; not being used for now
	@TestVisible private final String ACTION_VALUE_SEND_PREVIEW = 'sendPreview'; 
	@TestVisible private final String ACTION_VALUE_VALIDATE = 'validate';
    @TestVisible private final String ACTION_VALUE_SEARCH = 'search';
    @TestVisible private final String ACTION_VALUE_GET_ANALYTICS = 'getAnalytics';
    @TestVisible private final String ACTION_VALUE_GET_ANALYTICS_OVERVIEW = 'getAnalyticsOverview';
    @TestVisible private final String ACTION_VALUE_GET_ANALYTICS_CLICKS = 'getAnalyticsClicksListing';
    @TestVisible private final String ACTION_VALUE_GET_ANALYTICS_HEATMAP = 'getAnalyticsHeatmap';
    @TestVisible private final String ACTION_VALUE_GET_EMAIL_IDENTITIES = 'getEmailIdentities';
    @TestVisible private final String ACTION_VALUE_GET_EMAIL_IDENTITY_DETAILS = 'getEmailIdentityDetails';
    @TestVisible private final String ACTION_VALUE_CREATE_EMAIL_IDENTITY = 'createEmailIdentity';
    @TestVisible private final String ACTION_VALUE_UPDATE_EMAIL_IDENTITY = 'updateEmailIdentity';
    @TestVisible private final String ACTION_VALUE_DELETE_EMAIL_IDENTITY = 'deleteEmailIdentity';
    @TestVisible private final String ACTION_VALUE_SYNC_EMAIL_IDENTITY = 'syncEmailIdentity';
    @TestVisible private final String ACTION_VALUE_GET_FILTER_OPTIONS = 'getFilterOptions';
    @TestVisible private final String ACTION_VALUE_GET_PHOTOS = 'getPhotos';
    @TestVisible private final String ACTION_VALUE_GET_CONTENT_ANALYTICS = 'getContentAnalytics';
    @TestVisible private final String ACTION_VALUE_TRACK_DOWNLOAD = 'trackDownload';
    @TestVisible private final String ACTION_VALUE_TRACK_SESSION = 'sessionHeartbeat';
    @TestVisible private final String ACTION_VALUE_GET_CATEGORIES = 'getCategories';
    @TestVisible private final String ACTION_VALUE_SAVE_CATEGORY = 'saveCategory';
    @TestVisible private final String ACTION_VALUE_GET_DETAILED_CATEGORIES = 'getDetailedCategories';
    @TestVisible private final String ACTION_VALUE_GET_CATEGORY_OVERVIEW = 'getCategoryOverview';
    @TestVisible private final String ACTION_VALUE_GET_CATEGORY_NEWSLETTERS = 'getCategoryNewsletters';
    @TestVisible private final String ACTION_VALUE_GET_CATEGORY_UNSENT_NEWSLETTERS = 'getCategoryUnsentNewsletters';
    @TestVisible private final String ACTION_VALUE_GET_ARCHIVED_NEWSLETTERS = 'getArchivedNewsletters';
    @TestVisible private final String ACTION_VALUE_GET_ALL_SENDERS_ADDRESSES = 'getAllSenderAddresses';
    @TestVisible private final String ACTION_VALUE_GET_ALL_DOMAINS = 'getAllDomains';
    @TestVisible private final String ACTION_VALUE_CREATEL_DOMAIN = 'createDomain';
    @TestVisible private final String ACTION_VALUE_CREATEL_SENDERS_ADDRESS = 'createSenderAddress';
    @TestVisible private final String ACTION_VALUE_UPDATE_SENDERS_ADDRESS = 'updateSenderAddress';
    @TestVisible private final String ACTION_VALUE_DELETE_SENDERS_ADDRESS = 'deleteSenderAddress';
    @TestVisible private final String ACTION_VALUE_DELETE_DOMAIN = 'deleteDomain';

    

    
    
	@TestVisible private final String ERROR_REVIEW_NEWSLETTER_CONTENTS = 'It\'s not possible to proceed, please review content added';
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
            logger.logDebug('requestData====' + requestData);
	        if (String.isBlank(action)) {
	        	throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
	        }
            String result = '';

			if (ACTION_VALUE_SAVE.equalsIgnoreCase(action)){
                String newsletterId = readParam('newsletterId'); 

                if (!String.isBlank(newsletterId)) {
                    result = new NewsletterService().updateNewsletter(newsletterId, requestData); 

                } else {
                    result = new NewsletterService().createNewsletter(requestData); 
                }
                
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
			} else if (ACTION_VALUE_DELETE.equalsIgnoreCase(action)){
                String newsletterId = readParam('newsletterId');
				result = new NewsletterService().deleteNewsletter(newsletterId); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                
			}  else if (ACTION_VALUE_SEARCH.equalsIgnoreCase(action)){
				result = new NewsletterService().searchNewsletter(requestData); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);

            } else if (ACTION_VALUE_SAVE_GET_AUDITLOG.equalsIgnoreCase(action)){
                String newsletterId = readParam('newsletterId');
				result = new NewsletterService().getAuditLog(newsletterId); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);

            } else if (ACTION_VALUE_GET.equalsIgnoreCase(action)){ 
                String newsletterId = readParam('newsletterId');
				result = new NewsletterService().getNewsletter(newsletterId); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);

            } else if (ACTION_VALUE_GET_SNAPSHOT.equalsIgnoreCase(action)){
                String newsletterId = readParam('newsletterId');
                result = new NewsletterService().getSnapshot(newsletterId, UserContext.peopleId); 
                if('mobile'.equalsIgnoreCase(readParam('origin'))){
                    Map<String, Object> deserializedResult = (Map<String, Object>) JSON.deserializeUntyped(result);
                    response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, deserializedResult);
                }else{
                    response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                }

			} else if (ACTION_VALUE_SEND_PREVIEW.equalsIgnoreCase(action)){
                String newsletterId = readParam('newsletterId'); 
                result = new NewsletterService().sendPreview(newsletterId, requestData); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);

			} else if (ACTION_VALUE_GET_ANALYTICS.equalsIgnoreCase(action)){
                String newsletterId = readParam('newsletterId'); 
                result = new NewsletterService().getAnalytics(newsletterId); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                
			} else if (ACTION_VALUE_GET_ANALYTICS_OVERVIEW.equalsIgnoreCase(action)){
                String newsletterId = readParam('newsletterId'); 
                result = new NewsletterService().getAnalyticsOverview(newsletterId); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                
			} else if (ACTION_VALUE_GET_ANALYTICS_CLICKS.equalsIgnoreCase(action)){
                String newsletterId = readParam('newsletterId');
                String order = readParam('order');
                result = new NewsletterService().getAnalyticsClicksListing(newsletterId, order); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                
			} else if (ACTION_VALUE_GET_ANALYTICS_HEATMAP.equalsIgnoreCase(action)){
                String newsletterId = readParam('newsletterId'); 
                result = new NewsletterService().getAnalyticsHeatmap(newsletterId); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                
			} else if (ACTION_VALUE_VALIDATE.equalsIgnoreCase(action)){
                result = JSON.serialize(new NewsletterService().validateContentIds(requestData)); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
    
            } else if (ACTION_VALUE_GET_EMAIL_IDENTITIES.equalsIgnoreCase(action)){ 
                result = new NewsletterService().getEmailIdentities(); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                
			} else if (ACTION_VALUE_GET_EMAIL_IDENTITY_DETAILS.equalsIgnoreCase(action)){
                String id = readParam('id');
                result = new NewsletterService().getEmailIdentityDetails(id); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                
			} else if (ACTION_VALUE_CREATE_EMAIL_IDENTITY.equalsIgnoreCase(action)){ 
                result = new NewsletterService().createEmailIdentity(requestData); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                
			} else if (ACTION_VALUE_UPDATE_EMAIL_IDENTITY.equalsIgnoreCase(action)){ 
                String id = readParam('id');
                result = new NewsletterService().updateEmailIdentity(id, requestData); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                
			} else if (ACTION_VALUE_DELETE_EMAIL_IDENTITY.equalsIgnoreCase(action)){ 
                String id = readParam('id');
                result = new NewsletterService().deleteEmailIdentity(id); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                
			} else if (ACTION_VALUE_SYNC_EMAIL_IDENTITY.equalsIgnoreCase(action)){ 
                String id = readParam('id');
                result = new NewsletterService().syncEmailIdentity(id); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                
			} else if (ACTION_VALUE_GET_FILTER_OPTIONS.equalsIgnoreCase(action)){ 
                result = new NewsletterService().getFilterOptions(); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                
			} else if (ACTION_VALUE_GET_PHOTOS.equalsIgnoreCase(action)){ 
                String query = readParam('query');
                String page = readParam('page');
                String perPage = readParam('perPage');
                result = new NewsletterService().getPhotos(query, page, perPage); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                
			} else if (ACTION_VALUE_GET_CONTENT_ANALYTICS.equalsIgnoreCase(action)){ 
                String days = readParam('days');
                result = new NewsletterService().getContentAnalytics(days); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                
			} else if (ACTION_VALUE_TRACK_DOWNLOAD.equalsIgnoreCase(action)){ 
                result = new NewsletterService().trackDownload(requestData); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                
			} else if (ACTION_VALUE_TRACK_SESSION.equalsIgnoreCase(action)){
                result = new NewsletterService().sessionHeartbeat(requestData); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);

            } else if (ACTION_VALUE_GET_CATEGORIES.equalsIgnoreCase(action)){
                result = new NewsletterService().getCategories(); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);

            } else if (ACTION_VALUE_SAVE_CATEGORY.equalsIgnoreCase(action)){
                result = new NewsletterService().saveCategory(requestData); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                
            } else if (ACTION_VALUE_GET_DETAILED_CATEGORIES.equalsIgnoreCase(action)){
                result = new NewsletterService().getDetailedCategories(); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                
            } else if (ACTION_VALUE_GET_CATEGORY_OVERVIEW.equalsIgnoreCase(action)){
                String categoryId = readParam('categoryId');
                result = new NewsletterService().getCategoryOverview(categoryId); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                
            } else if (ACTION_VALUE_GET_CATEGORY_NEWSLETTERS.equalsIgnoreCase(action)){
                result = new NewsletterService().getCategoryNewsletters(requestData); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                
            } else if (ACTION_VALUE_GET_CATEGORY_UNSENT_NEWSLETTERS.equalsIgnoreCase(action)){
                result = new NewsletterService().getCategoryUnsentNewsletters(requestData); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                
            } else if (ACTION_VALUE_GET_ARCHIVED_NEWSLETTERS.equalsIgnoreCase(action)){
                Boolean forIds = Boolean.valueOf(readParam('forIds'));
                result = new NewsletterService().getArchivedNewsletters(requestData, forIds); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                
            } else if (ACTION_VALUE_GET_ALL_SENDERS_ADDRESSES.equalsIgnoreCase(action)){
                result = new NewsletterService().getAllSenderAddresses(requestData); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                
            } else if (ACTION_VALUE_GET_ALL_DOMAINS.equalsIgnoreCase(action)){
                result = new NewsletterService().getAllDomains(requestData); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                
            } else if (ACTION_VALUE_CREATEL_DOMAIN.equalsIgnoreCase(action)){
                result = new NewsletterService().createDomain(requestData); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                
            } else if (ACTION_VALUE_CREATEL_SENDERS_ADDRESS.equalsIgnoreCase(action)){
                result = new NewsletterService().createSenderAddress(requestData); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                
            } else if (ACTION_VALUE_UPDATE_SENDERS_ADDRESS.equalsIgnoreCase(action)){
                result = new NewsletterService().updateSenderAddress(readParam('id'), requestData); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                
            } else if (ACTION_VALUE_DELETE_SENDERS_ADDRESS.equalsIgnoreCase(action)){
                result = new NewsletterService().deleteSenderAddress(readParam('id')); 
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
                
            } else if (ACTION_VALUE_DELETE_DOMAIN.equalsIgnoreCase(action)){
                result = new NewsletterService().deleteDomain(readParam('id')); 
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