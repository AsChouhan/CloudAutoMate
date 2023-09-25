/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class QuestionsDataServer extends DataServer{ 
    
    private final String REQUEST_PARAM_DATA = 'data';
    
    private final String ACTION_GET = 'get';
    private final String ACTION_SEARCH = 'search';
	private final String ACTION_SUGGESTION = 'suggestion';
    private final String ACTION_CREATE = 'create';
    private final String ACTION_UPDATE = 'update';
    private final String ACTION_DELETE = 'delete';
    private final String ACTION_MARK_AS_DUPLICATE = 'markAsDuplicate';
	private final String ACTION_MARK_AS_NOT_DUPLICATE = 'markAsNotDuplicate';
	private final String ACTION_UNPUBLISH = 'unpublish';
	private final String ACTION_PUBLISH = 'publish';
	
	private final String ERROR_QUESTION_DELETED = 'Could not perform action - Question has been deleted';
    
    
    public QuestionsDataServer() {
        
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
        	logger.logDebug('QuestionsDataServer----entered handleRequest----');

			String action = readParam(REQUEST_PARAM_ACTION);
        	String requestData = readParam(REQUEST_PARAM_DATA);
        	
            if(String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
            }

			if(!SimpplrContext.isQuestionAnswerEnabled) {
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}

			if(ACTION_GET.equalsIgnoreCase(action)) {
        		response = getQuestion();
            }else if(ACTION_SEARCH.equalsIgnoreCase(action)){
            	response = searchQuestion(requestData);
            }else if(ACTION_SUGGESTION.equalsIgnoreCase(action)){
            	response = searchSuggestion(requestData);
            }else if(ACTION_CREATE.equalsIgnoreCase(action)){
            	response = createQuestion(requestData);
            }else if(ACTION_UNPUBLISH.equalsIgnoreCase(action)){
            	response = unpublishQuestion(requestData);
            }else if(ACTION_PUBLISH.equalsIgnoreCase(action)){
            	response = publishQuestion(requestData);
            }else if(ACTION_UPDATE.equalsIgnoreCase(action)){
            	response = updateQuestion(requestData);
            }else if(ACTION_DELETE.equalsIgnoreCase(action)){
            	response = deleteQuestion(requestData);
			}else if(ACTION_MARK_AS_DUPLICATE.equalsIgnoreCase(action)){
            	response = markAsDuplicate(requestData);
			}else if(ACTION_MARK_AS_NOT_DUPLICATE.equalsIgnoreCase(action)){
            	response = markAsNotDuplicate(requestData);
            }else {
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
    @TestVisible  
    private ResponseWrapper getQuestion() {
		try{
			logger.logDebug('QuestionDataServer.getQuestion()--------');
			
			String questionId = readParam('questionId');
			Boolean canManageSite = String.isBlank(SiteContext.siteId) ? false : SiteContext.canManage();
			if(String.isNotBlank(SiteContext.siteId) && !(canAccessSite() || canManageSite)){
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}
			String endpoint = '/v1/question/'+questionId+'/view';
			Map<String, Object> responseMap = QuestionAnswerService.getQnARepsonseFromAWS(endpoint, 'GET', null, canManageSite);

			return buildResponseWrapper((String)responseMap.get('status'), (String)responseMap.get('message'), responseMap.get('result'));
		} catch(Exception e) {
			logger.logError(e.getStackTraceString());
			return buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
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
    @TestVisible  
    private ResponseWrapper markAsDuplicate(String requestData) {
		try{
			logger.logDebug('QuestionDataServer.markAsDuplicate()--------');
			String questionId = readParam('questionId');
			String originalQuestionId = readParam('originalQuestionId');
			Boolean canManageSite = String.isBlank(SiteContext.siteId) ? false : SiteContext.canManage();
			if(String.isNotBlank(SiteContext.siteId) && !(canAccessSite() || canManageSite)){
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}

			String endpoint = '/v1/question/'+questionId+'/mark/duplicate/'+ originalQuestionId;
			Map<String, Object> responseMap = QuestionAnswerService.getQnARepsonseFromAWS(endpoint, 'POST', null, canManageSite);

			return buildResponseWrapper((String)responseMap.get('status'), (String)responseMap.get('message'), responseMap.get('result'));
		} catch(Exception e) {
			logger.logError(e.getStackTraceString());
			return buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
    }

	private ResponseWrapper markAsNotDuplicate(String requestData) {
		try{
			logger.logDebug('QuestionDataServer.markAsDuplicate()--------');
			String questionId = readParam('questionId');
			Boolean canManageSite = String.isBlank(SiteContext.siteId) ? false : SiteContext.canManage();
			if(String.isNotBlank(SiteContext.siteId) && !(canAccessSite() || canManageSite)){
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}

			String endpoint = '/v1/question/'+questionId+'/mark/not-duplicate';
			Map<String, Object> responseMap = QuestionAnswerService.getQnARepsonseFromAWS(endpoint, 'POST', null, canManageSite);

			return buildResponseWrapper((String)responseMap.get('status'), (String)responseMap.get('message'), responseMap.get('result'));
		} catch(Exception e) {
			logger.logError(e.getStackTraceString());
			return buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
    }
    
    @TestVisible  
    public ResponseWrapper searchQuestion(String requestData) {
		try{
			Criteria.Question criteriaObj = (Criteria.Question)JSON.deserialize(requestData, Criteria.Question.class);
			ResponseWrapper responseToReturn;
			SiteContext.siteId = criteriaObj.siteId;
			Boolean canManageSite = String.isBlank(SiteContext.siteId) ? false : SiteContext.canManage();
			if(String.isNotBlank(SiteContext.siteId) && !(canAccessSite() || canManageSite)){
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}

			Map<String, Object> requestBody = new Map<String, Object>();
			requestBody.put('siteId', criteriaObj.siteId);
			requestBody.put('size', criteriaObj.size);
			requestBody.put('filter', criteriaObj.filter);
			requestBody.put('sortBy', criteriaObj.sortBy);
			requestBody.put('section', criteriaObj.section);
			requestBody.put('term', criteriaObj.term);
			requestBody.put('nextPageToken', criteriaObj.nextPageToken);

			String endpoint = '/v1/question/search/listing';
			Map<String, Object> responseMap = QuestionAnswerService.getQnARepsonseFromAWS(endpoint, 'POST', requestBody, canManageSite);

			return buildResponseWrapper((String)responseMap.get('status'), (String)responseMap.get('message'), responseMap.get('result'));
		} catch(Exception e) {
			logger.logError(e.getStackTraceString());
			return buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
    }
    
	@TestVisible  
    public ResponseWrapper searchSuggestion(String requestData) {
		try{
			Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(requestData);
			SiteContext.siteId = (String)requestMap.get('siteId');
			Boolean canManageSite = String.isBlank(SiteContext.siteId) ? false : SiteContext.canManage();
			if(String.isNotBlank(SiteContext.siteId) && !(canAccessSite() || canManageSite)){
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}

			String endpoint = '/v1/question/search/suggestion?criteria=' + (String)requestMap.get('criteria');
			if(requestMap.get('term') != null) {
				endpoint += '&term=' + EncodingUtil.urlEncode((String)requestMap.get('term'), 'UTF-8');
			}
			if(requestMap.get('siteId') != null) {
				endpoint += '&site=' + requestMap.get('siteId');
			}
			if(requestMap.get('exemptQuestionId') != null) {
				endpoint += '&exempt_question=' + requestMap.get('exemptQuestionId');
			}
			Map<String, Object> responseMap = QuestionAnswerService.getQnARepsonseFromAWS(endpoint, 'GET', null, canManageSite);

			return buildResponseWrapper((String)responseMap.get('status'), (String)responseMap.get('message'), responseMap.get('result'));
		} catch(Exception e) {
			logger.logError(e.getStackTraceString());
			return buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
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
    
    @TestVisible  
    private  ResponseWrapper createQuestion(String requestData) {
		try{
			logger.logDebug('QuestionDataServer.createQuestion()--------'+requestData);
			Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(requestData);
			SiteContext.siteId = (String)requestMap.get('siteId');
			Boolean canManageSite = String.isBlank(SiteContext.siteId) ? false : SiteContext.canManage();
			if(String.isNotBlank(SiteContext.siteId) && !(canAccessSite() || canManageSite)){
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}
			
			Map<String, Object> requestBody = new Map<String, Object>();
			requestBody.put('siteId', requestMap.get('siteId'));
			requestBody.put('title', requestMap.get('title'));
			requestBody.put('body', requestMap.get('body'));

			String endpoint = '/v1/question/new';
			Map<String, Object> responseMap = QuestionAnswerService.getQnARepsonseFromAWS(endpoint, 'POST', requestBody, canManageSite);

			return buildResponseWrapper((String)responseMap.get('status'), (String)responseMap.get('message'), responseMap.get('result'));
		} catch(Exception e) {
			logger.logError(e.getStackTraceString());
			return buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
    }
	
	private ResponseWrapper unpublishQuestion(String requestData) {
		try{
			logger.logDebug('QuestionDataServer.unpublishQuestion()--------');
			String questionId = readParam('questionId');
			Boolean canManageSite = String.isBlank(SiteContext.siteId) ? false : SiteContext.canManage();
			if(String.isNotBlank(SiteContext.siteId) && !(canAccessSite() || canManageSite)){
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}

			String endpoint = '/v1/question/'+questionId + '/mark/unpublish';
			Map<String, Object> responseMap = QuestionAnswerService.getQnARepsonseFromAWS(endpoint, 'POST', null, canManageSite);

			return buildResponseWrapper((String)responseMap.get('status'), (String)responseMap.get('message'), responseMap.get('result'));
		} catch(Exception e) {
			logger.logError(e.getStackTraceString());
			return buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
	}

	private ResponseWrapper publishQuestion(String requestData) {
		try{
			logger.logDebug('QuestionDataServer.publishQuestion()--------');
			String questionId = readParam('questionId');
			Boolean canManageSite = String.isBlank(SiteContext.siteId) ? false : SiteContext.canManage();
			if(String.isNotBlank(SiteContext.siteId) && !(canAccessSite() || canManageSite)){
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}

			String endpoint = '/v1/question/'+questionId+'/mark/publish';
			Map<String, Object> responseMap = QuestionAnswerService.getQnARepsonseFromAWS(endpoint, 'POST', null, canManageSite);

			return buildResponseWrapper((String)responseMap.get('status'), (String)responseMap.get('message'), responseMap.get('result'));
		} catch(Exception e) {
			logger.logError(e.getStackTraceString());
			return buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
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
    
    @TestVisible  
    private  ResponseWrapper updateQuestion(String requestData) {
		try{
			logger.logDebug('QuestionDataServer.updateQuestion()--------'+requestData);
			Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(requestData);
			SiteContext.siteId = (String)requestMap.get('siteId');
			Boolean canManageSite = String.isBlank(SiteContext.siteId) ? false : SiteContext.canManage();
			if(String.isNotBlank(SiteContext.siteId) && !(canAccessSite() || canManageSite)){
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}

			Map<String, Object> requestBody = new Map<String, Object>();
			requestBody.put('title', requestMap.get('title'));
			requestBody.put('body', requestMap.get('body'));

			String questionId = readParam('questionId');

			String endpoint = '/v1/question/'+questionId+'/edit';
			Map<String, Object> responseMap = QuestionAnswerService.getQnARepsonseFromAWS(endpoint, 'PUT', requestBody, canManageSite);

			return buildResponseWrapper((String)responseMap.get('status'), (String)responseMap.get('message'), responseMap.get('result'));
		} catch(Exception e) {
			logger.logError(e.getStackTraceString());
			return buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
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
    
	@TestVisible  
    private  ResponseWrapper deleteQuestion(String requestData) {
		try{
			logger.logDebug('QuestionDataServer.deleteQuestion()--------');
			String questionId = readParam('questionId');
			Boolean canManageSite = String.isBlank(SiteContext.siteId) ? false : SiteContext.canManage();
			if(String.isNotBlank(SiteContext.siteId) && !(canAccessSite() || canManageSite)){
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}

			String endpoint = '/v1/question/'+questionId+'/delete';
			Map<String, Object> responseMap = QuestionAnswerService.getQnARepsonseFromAWS(endpoint, 'DELETE', null, canManageSite);

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