public with sharing class AnswerDataServer extends DataServer{ 
    private final String REQUEST_PARAM_DATA = 'data';
    
    private final String ACTION_GET = 'get';
    private final String ACTION_CREATE = 'create';
    private final String ACTION_UPDATE = 'update';
    private final String ACTION_SEARCH = 'search';
    private final String ACTION_APPROVE = 'approve';
    private final String ACTION_UNAPPROVE = 'unapprove';
    
    
    public AnswerDataServer() {}
    
    public String getPageFeature() {
        return AccessManager.FEATURE_SIMPPLR;
    }
    
    public override void handleRequest() {
        try {
            logger.logDebug('AnswerDataServer----entered handleRequest----');
            String action = readParam(REQUEST_PARAM_ACTION);
            String requestData = readParam(REQUEST_PARAM_DATA);
            
            if(String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
            }
            if(!SimpplrContext.isQuestionAnswerEnabled) {
                throw new SimpplrException(ServiceConstants.ERROR_403);
            }

            if(ACTION_GET.equalsIgnoreCase(action)) {
                response = getAnswer();
            }else if(ACTION_CREATE.equalsIgnoreCase(action)){
                response = createAnswer(requestData);
            }else if(ACTION_UPDATE.equalsIgnoreCase(action)){
                response = updateAnswer(requestData);
            }else if(ACTION_SEARCH.equalsIgnoreCase(action)){
                response = searchAnswer(requestData);
            }else if(ACTION_APPROVE.equalsIgnoreCase(action)){
                response = approveAnswer(requestData);
            }else if(ACTION_UNAPPROVE.equalsIgnoreCase(action)){
                response = unapproveAnswer(requestData);
            }else {
                throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            }
        } catch (Exception ex) {
            logger.logError('Either no page access or action parameter returning wrong data',ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR,MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
    } 
    
    @TestVisible  
    private ResponseWrapper getAnswer() {
        try{
            logger.logDebug('AnswerDataServer.getAnswer()--------');
            String answerId = readParam('answerId');
            
            Boolean canManageSite = SiteContext.canManage();
            if(!(canAccessSite() || canManageSite)){
                throw new SimpplrException(ServiceConstants.ERROR_403);
            }
            String endpoint = '/v1/answer/'+answerId+'/view';
            Map<String, Object> responseMap = QuestionAnswerService.getQnARepsonseFromAWS(endpoint, 'GET', null, canManageSite);

            return buildResponseWrapper((String)responseMap.get('status'), (String)responseMap.get('message'), responseMap.get('result'));
        } catch(Exception e) {
            logger.logError(e.getStackTraceString());
            return buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
    }
    
    @TestVisible  
    private ResponseWrapper createAnswer(String requestData) {
        try{
            logger.logDebug('AnswerDataServer.createAnswer()--------');

            Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(requestData);
            SiteContext.siteId = (String)requestMap.get('siteId');
            Boolean canManageSite = SiteContext.canManage();
            if(!(canAccessSite() || canManageSite)){
                throw new SimpplrException(ServiceConstants.ERROR_403);
            }

            Map<String, Object> requestBody = new Map<String, Object>();
            requestBody.put('siteId', requestMap.get('siteId'));
            requestBody.put('questionId', requestMap.get('questionId'));
            requestBody.put('body', requestMap.get('body'));

            String endpoint = '/v1/answer/new';
            Map<String, Object> responseMap = QuestionAnswerService.getQnARepsonseFromAWS(endpoint, 'POST', requestBody, canManageSite);

            return buildResponseWrapper((String)responseMap.get('status'), (String)responseMap.get('message'), responseMap.get('result'));
        } catch(Exception e) {
            logger.logError(e.getStackTraceString());
            return buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
    }
    
    @TestVisible  
    private ResponseWrapper updateAnswer(String requestData) {
        try{
            logger.logDebug('AnswerDataServer.updateAnswer()--------');
            String answerId = readParam('answerId');

            Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(requestData);
            SiteContext.siteId = (String)requestMap.get('siteId');
            Boolean canManageSite = SiteContext.canManage();
            if(!(canAccessSite() || canManageSite)){
                throw new SimpplrException(ServiceConstants.ERROR_403);
            }

            Map<String, Object> requestBody = new Map<String, Object>();
            requestBody.put('siteId', requestMap.get('siteId'));
            requestBody.put('body', requestMap.get('body'));

            String endpoint = '/v1/answer/'+answerId+'/edit';
            Map<String, Object> responseMap = QuestionAnswerService.getQnARepsonseFromAWS(endpoint, 'POST', requestBody, canManageSite);

            return buildResponseWrapper((String)responseMap.get('status'), (String)responseMap.get('message'), responseMap.get('result'));
        } catch(Exception e) {
            logger.logError(e.getStackTraceString());
            return buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
    }

    @TestVisible
    private ResponseWrapper searchAnswer(String requestData){
        try{
            logger.logDebug('AnswerDataServer.searchAnswer()---------');
            Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(requestData);
            SiteContext.siteId = (String)requestMap.get('siteId');
            Boolean canManageSite = SiteContext.canManage();
            if(!(canAccessSite() || canManageSite)){
                throw new SimpplrException(ServiceConstants.ERROR_403);
            }
            Map<String, Object> requestBody = new Map<String, Object>();
            requestBody.put('questionId', requestMap.get('questionId'));
            requestBody.put('size', requestMap.get('size'));
            requestBody.put('sortBy', requestMap.get('sortBy'));
            requestBody.put('nextPageToken', requestMap.get('nextPageToken'));

            String endpoint = '/v1/answer/search/listing';
            Map<String, Object> responseMap = QuestionAnswerService.getQnARepsonseFromAWS(endpoint, 'POST', requestBody, canManageSite);
            return buildResponseWrapper((String)responseMap.get('status'), (String)responseMap.get('message'), responseMap.get('result'));
        } catch(Exception e){
            logger.logError(e.getStackTraceString());
            return buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }

    }

    @TestVisible  
    private ResponseWrapper approveAnswer(String requestData) {
        try{
            logger.logDebug('AnswerDataServer.approveAnswer()--------');
            Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(requestData);
            SiteContext.siteId = (String)requestMap.get('siteId');
            Boolean canManageSite = SiteContext.canManage();
            if(!canManageSite){
                throw new SimpplrException(ServiceConstants.ERROR_403);
            }
            String answerId = (String)requestMap.get('answerId');
            String endpoint = '/v1/answer/'+answerId+'/mark/approve';
            Map<String, Object> responseMap = QuestionAnswerService.getQnARepsonseFromAWS(endpoint, 'POST', null, canManageSite);

            return buildResponseWrapper((String)responseMap.get('status'), (String)responseMap.get('message'), responseMap.get('result'));
        } catch(Exception e) {
            logger.logError(e.getStackTraceString());
            return buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
    }

    @TestVisible  
    private ResponseWrapper unapproveAnswer(String requestData) {
        try{
            logger.logDebug('AnswerDataServer.unapproveAnswer()--------');
            Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(requestData);
            SiteContext.siteId = (String)requestMap.get('siteId');
            Boolean canManageSite = SiteContext.canManage();
            if(!canManageSite){
                throw new SimpplrException(ServiceConstants.ERROR_403);
            }
            String answerId = (String)requestMap.get('answerId');
            String endpoint = '/v1/answer/'+answerId+'/mark/unapprove';
            Map<String, Object> responseMap = QuestionAnswerService.getQnARepsonseFromAWS(endpoint, 'POST', null, canManageSite);

            return buildResponseWrapper((String)responseMap.get('status'), (String)responseMap.get('message'), responseMap.get('result'));
        } catch(Exception e) {
            logger.logError(e.getStackTraceString());
            return buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
    }

    private static Boolean canAccessSite() {
        Boolean canAccessSite = false;
        Site_Role__c siteRoleObj = SiteContext.currentSiteRoleRecordWRTLoggedUser;

        if(SiteContext.isPublicSite){
            canAccessSite = true;
        } else if(SiteContext.isPrivateSite && siteRoleObj != null){
            canAccessSite = true;
        } else if( SiteContext.isUnlistedSite && siteRoleObj != null){
            canAccessSite = true;
        }
        return canAccessSite;
    }
}