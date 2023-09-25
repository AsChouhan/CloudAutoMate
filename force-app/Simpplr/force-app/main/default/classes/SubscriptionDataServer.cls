public with sharing class SubscriptionDataServer extends DataServer{
    
    private final String ACTION_VALUE_SEARCH = 'search';
    private final String ACTION_VALUE_GET = 'get';
    private final String ACTION_VALUE_SAVE = 'save';
    private final String ACTION_VALUE_DELETE = 'delete';
    private final String ACTION_VALUE_START_BATCH_JOB = 'startBatchJob';
	private final String ACTION_VALUE_RERUN = 'rerun';
    
    private final String REQUEST_PARAM_DATA = 'data';
    
    public override void handleRequest() {
		logger.logDebug('SubscriptionDataServer.handleRequest()----entered handleRequest----');
		try {
			String action = readParam(REQUEST_PARAM_ACTION);
			String requestData = readParam(REQUEST_PARAM_DATA);
			
			if(ACTION_VALUE_SEARCH.equalsIgnoreCase(action)) {
	            response = search(requestData);
		        
			} else if(ACTION_VALUE_GET.equalsIgnoreCase(action)) {
	            response = getSubscription(readParam('subscriptionId'));
		        
			} else if(ACTION_VALUE_SAVE.equalsIgnoreCase(action)) {
	            response = saveSubscription(requestData);
		        
			} else if(ACTION_VALUE_DELETE.equalsIgnoreCase(action)) {
				Boolean deleteUnfollow = null;
				if(readParam('deleteUnfollow') != null){
					deleteUnfollow = Boolean.valueOf(readParam('deleteUnfollow'));
				}
				
	            response = deleteSubscription(readParam('subscriptionId'), deleteUnfollow);
		        
			} else if(ACTION_VALUE_START_BATCH_JOB.equalsIgnoreCase(action)) {
				startBatchJob();
				
			}  else if(ACTION_VALUE_RERUN.equalsIgnoreCase(action)) {
				response = rerun(readParam('subscriptionId'));
				
			} else {
				throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
			} 
		} catch(Exception ex) {
            logger.logError('SubscriptionDataServer.handleRequest()---Exception occured----', ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
	}
	
	/**
	 * @api {get} /apex/DataServerRO?target=SubscriptionDataServer&action=search search
	 * @apiVersion 1.0.0
	 * @apiGroup SubscriptionDataServer
	 * @apiName search
	 *
	 * @apiParam {String} segmentId - Optional. If provided, only return Subscriptions from within this segment.
	 * @apiParam {String} siteId - Optional. If provided, only return Subscriptions which are set to autofollow this site
	 * @apiParam {String} size - Number of records to return.
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.Subscription.search
	 * 2. Used in Susbscription listing 
	 * 
	 * @apiSuccess {List[SubscriptionWrapper]} Response.listOfItems List of all the subscriptions satisfying the criteria
	 * @apiUse SubscriptionWrapper
	 *
	 * @apiError SimpplrException Simpplr Exception
	*/
	private ResponseWrapper search(String requestData) {
		logger.logDebug('SubscriptionDataServer.search()----- RequestData: ' + requestData);
		
		ResponseWrapper responseWrapperObj = null;
		try {
			Criteria.Subscription subscriptionCriteriaObj = (Criteria.Subscription) JSON.deserialize(requestData, Criteria.Subscription.class);
			
			Boolean isCurrentUserSiteManager = UserContext.sitesIManageIdSet.contains(subscriptionCriteriaObj.siteId);

			SiteContext.siteId = subscriptionCriteriaObj.siteId;

			if(((SiteContext.isUnlistedSite == false) && !(UserContext.isUserAppModerator || UserContext.hasModifyAllDataPermission || UserContext.isSegmentManager || isCurrentUserSiteManager))
					|| (SiteContext.isUnlistedSite &&!(UserContext.hasManageUnlistedSitePermission || isCurrentUserSiteManager ))) {
				
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}
			if(subscriptionCriteriaObj.size == null) {
	    		subscriptionCriteriaObj.size = SimpplrContext.simpplrDefaultPageSize;
	    	}
	    	if (subscriptionCriteriaObj.nextPageToken == null) {
    			subscriptionCriteriaObj.offset = 0;
    			
    		} else {
    			subscriptionCriteriaObj.offset = Integer.valueOf(subscriptionCriteriaObj.nextPageToken);
    		}
			
			SubscriptionService service = new SubscriptionService();
			List<SubscriptionWrapper> listOfSubscriptionWrap = service.search(subscriptionCriteriaObj);
			
			SubscriptionWrapper.PaginationWrapper subscriptionPaginatorObj = new SubscriptionWrapper.PaginationWrapper ();
			subscriptionPaginatorObj.listOfItems = listOfSubscriptionWrap;
    		if (subscriptionPaginatorObj.listOfItems.size() == (subscriptionCriteriaObj.size + 1) &&
		        		subscriptionCriteriaObj.offset < 2000) {
		        subscriptionPaginatorObj.listOfItems.remove((subscriptionPaginatorObj.listOfItems.size()-1));
		        subscriptionPaginatorObj.nextPageToken = String.valueOf(subscriptionCriteriaObj.offset + subscriptionCriteriaObj.size);
		    } else {
		        subscriptionPaginatorObj.nextPageToken = null;
		    }
			
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, subscriptionPaginatorObj);
		} catch (Exception ex) {
			logger.logError('SubscriptionDataServer.search()---Exception occured----', ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		
		return responseWrapperObj;
	}
	
	/**
	 * @api {post} /apex/DataServerRW?target=SubscriptionDataServer&action=save save
	 * @apiVersion 1.0.0
	 * @apiGroup SubscriptionDataServer
	 * @apiName save
	 *
	 * @apiParam {String} subscriptionId - ID of the Subscription to save. null for new Subscriptions
	 * @apiParam {String} data - A full subscription model
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.Subscription.save
	 * 2. Used in Susbscription save 
	 * 
	 * @apiSuccess {SubscriptionWrapper} Response.result A full subscription model
	 * @apiUse SubscriptionWrapper
	 *
	 * @apiError SimpplrException Simpplr Exception
	*/
	private ResponseWrapper saveSubscription(String requestData) {
		logger.logDebug('SubscriptionDataServer.saveSubscription()----' + '----requestData----' + requestData);
		ResponseWrapper responseWrapperObj = null;
		
		if(!UserContext.isUserAppModerator && !UserContext.isSegmentManager) {
			throw new SimpplrException(ServiceConstants.ERROR_403);
		}
		
		try {
			if(String.isBlank(requestData)){ 
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}
			
			SubscriptionWrapper subscriptionObj = (SubscriptionWrapper) JSON.deserialize(requestData, SubscriptionWrapper.class);
			SubscriptionService serviceObj = new SubscriptionService();
			
			// Restrict this operation on Subscription, if it is locked.
			if(String.isNotBlank(subscriptionObj.subscriptionId) && serviceObj.isSubscriptionLocked(subscriptionObj.subscriptionId)){
				throw new SimpplrException(ServiceConstants.SUBSCRIPTION_LOCKED_ERROR);
			}
			
			SubscriptionWrapper newSubscriptionObj = null;
			if(String.isBlank(subscriptionObj.subscriptionId)){
				newSubscriptionObj = serviceObj.createSubscription(subscriptionObj);
			} else {
				newSubscriptionObj = serviceObj.updateSubscription(subscriptionObj);
			}
			
			newSubscriptionObj.isLocked = false;
			AudienceService audienceServiceObj = new AudienceService();
			newSubscriptionObj.audience.audienceCount = audienceServiceObj.getAudienceMemberCount(newSubscriptionObj.audience.audienceId);

			BatchProcessSubscription job = null;
			
			Map<String, String> batchParamMap = new Map<String, String>();
			batchParamMap.put('audienceId', newSubscriptionObj.audience.audienceId);
			batchParamMap.put('subscriptionId', newSubscriptionObj.subscriptionId);
			
			job = new BatchProcessSubscription('newSubscriptionEntities', batchParamMap);
			
			Database.executeBatch(job, 200);
			
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Save Subscription is successful.', newSubscriptionObj);
		} catch(Exception ex) {
			logger.logError('SubscriptionDataServer.saveSubscription()---Exception occured----', ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		
		return responseWrapperObj;
	}
	
	/**
	 * @api {post} /apex/DataServerRW?target=SubscriptionDataServer&action=delete delete
	 * @apiVersion 1.0.0
	 * @apiGroup SubscriptionDataServer
	 * @apiName delete
	 *
	 * @apiParam {String} subscriptionId - ID of the Subscription to delete.
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.Subscription.delete
	 * 2. Used in Susbscription delete/remove 
	 * 
	 * @apiSuccess {Null} Response.result Null 
	 *
	 * @apiError SimpplrException Simpplr Exception
	 * @apiError (error 403) Forbidden 
	 * @apiError Susbcription is locked
	*/
	private ResponseWrapper deleteSubscription(String subscriptionId, Boolean deleteUnfollow) {
		logger.logDebug('SubscriptionDataServer.deleteSubscription()----requestData----'+ subscriptionId + ' ' + deleteUnfollow);
		ResponseWrapper responseWrapperObj = null;
		
		if(!UserContext.isUserAppModerator && !UserContext.isSegmentManager) {
			throw new SimpplrException(ServiceConstants.ERROR_403);
		}
		
		try {
			if(!(UserContext.isUserAppModerator || UserContext.isSegmentManager)){ 
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}
			
			SubscriptionService serviceObj = new SubscriptionService();
			// Restrict this operation on Subscription, if it is locked.
			if(serviceObj.isSubscriptionLocked(subscriptionId)){
				throw new SimpplrException(ServiceConstants.SUBSCRIPTION_LOCKED_ERROR);
			}
			
			if(String.isNotBlank(subscriptionId)){
				if(deleteUnfollow != null && deleteUnfollow){
					serviceObj.deleteSubscriptionAndUnfollow(subscriptionId);
				} else {
					serviceObj.deleteSubscription(subscriptionId);
				}
			} else {
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}
			
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
		} catch(Exception ex) {
			logger.logError('SubscriptionDataServer.deleteSubscription()---Exception occured----', ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		
		return responseWrapperObj;
	}
	
	/**
	 * @api {get} /apex/DataServerRO?target=SubscriptionDataServer&action=get get
	 * @apiVersion 1.0.0
	 * @apiGroup SubscriptionDataServer
	 * @apiName get
	 *
	 * @apiParam {String} subscriptionId - ID of the Subscription to retrieve.
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.Subscription.get
	 * 2. Used in Susbscription get by Id 
	 * 
	 * @apiSuccess {List[SubscriptionWrapper]} Response.result A full subscription model
	 * @apiUse SubscriptionWrapper
	 *
	 * @apiError SimpplrException Simpplr Exception
	 * @apiError (error 404) Not Found
	*/
	public ResponseWrapper getSubscription(String subscriptionId) {
		ResponseWrapper responseWrapperObj = new ResponseWrapper();
		
		if(!UserContext.isUserAppModerator && !UserContext.isSegmentManager) {
			throw new SimpplrException(ServiceConstants.ERROR_403);
		}
			
		try {
			SubscriptionService serviceObj = new SubscriptionService();
			SubscriptionWrapper subscriptionWrapperobj = serviceObj.getSubscriptionById(subscriptionId);
			
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, subscriptionWrapperobj);
		} catch (exception ex) {
    		logger.logError('SubscriptionDataServer.getSubscription()---Exception occured----', ex);
        	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }

		return responseWrapperObj;
	}
	
	private ResponseWrapper startBatchJob() {
		ResponseWrapper responseWrapperObj;
		List<Audience_Member__c> audienceMemberList = [SELECT Audience__c FROM Audience_Member__c 
													   WHERE Is_All_Subscription_Required__c = true WITH SECURITY_ENFORCED limit 1];
		
		if(audienceMemberList.isEmpty()) {
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, 'All subscriptions have already been processed.', null, null);
			
		} else {
			Boolean isUserEmailToBeSwitchedOff = 'true'.equalsIgnoreCase(readParam('isUserEmailToBeSwitchedOff'));
			BatchProcessSubscription job = new BatchProcessSubscription(isUserEmailToBeSwitchedOff, 'newAudienceMembers', audienceMemberList[0].Audience__c);
			Database.executeBatch(job, 200);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Batch job started sucessfully.', null, null);
			
		}
					
		
		return responseWrapperObj;
	}

	private ResponseWrapper rerun(String subscriptionId) {

		logger.logDebug('SubscriptionDataServer.rerun()----subscriptionId----' + subscriptionId);
		ResponseWrapper responseWrapperObj = null;

		if(!UserContext.isUserAppModerator && !UserContext.isSegmentManager) {
			throw new SimpplrException(ServiceConstants.ERROR_403);
		}
		
		try {
			if(String.isBlank(subscriptionId)){ 
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}

			SubscriptionService serviceObj = new SubscriptionService();

			String audienceId = null;
			
			// Restrict this operation on Subscription, if it is locked.
			if(String.isNotBlank(subscriptionId) && serviceObj.isSubscriptionLocked(subscriptionId)){
				throw new SimpplrException(ServiceConstants.SUBSCRIPTION_LOCKED_ERROR);
			}

			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', subscriptionId);
			
			String queryString = 'SELECT id, Processing_Required__c, Subscription__r.Audience__c FROM Subscription_Entity__c WHERE Subscription__c = :soqlParam1';
			List<Subscription_Entity__c> subsEntityList = (List<Subscription_Entity__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);
		
			for(Subscription_Entity__c entityObj : subsEntityList) {
				entityObj.Processing_Required__c = true;
				if(audienceId == null) {
					audienceId = entityObj.Subscription__r.Audience__c;
				}
			}

			Database.update(subsEntityList);

			Map<String, String> batchParamMap = new Map<String, String>();
			batchParamMap.put('audienceId', audienceId);
			batchParamMap.put('subscriptionId', subscriptionId);
			BatchProcessSubscription job = new BatchProcessSubscription('newSubscriptionEntities', batchParamMap);
				
			Database.executeBatch(job, 200);
			
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'ReRun Subscription is successful.', subscriptionId);
		} catch(Exception ex) {
			logger.logError('SubscriptionDataServer.rerun()---Exception occured----', ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}

		return responseWrapperObj;
	}
	
}