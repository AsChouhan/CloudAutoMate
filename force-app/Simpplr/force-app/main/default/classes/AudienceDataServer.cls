public with sharing class AudienceDataServer extends DataServer {
	
    private final String ACTION_VALUE_GET_FIELD_VALUES = 'getFieldValues';
    private final String ACTION_VALUE_GET = 'get';
	private final String ACTION_VALUE_SEARCH = 'search';
	private final String ACTION_VALUE_SAVE = 'save';
	private final String ACTION_VALUE_DELETE_AUDIENCE = 'delete';
    
    private final String REQUEST_PARAM_DATA = 'data';
    @TestVisible private final String ACTION_VALUE_GET_AUDIENCE_BY_IDS = 'getByIds';
    public override void handleRequest () {
		logger.logDebug('AudienceDataServer.handleRequest()----entered handleRequest----');
		
		try {
			String action = readParam(REQUEST_PARAM_ACTION);
			String requestData = readParam(REQUEST_PARAM_DATA);
			
			if(ACTION_VALUE_GET_FIELD_VALUES.equalsIgnoreCase(action)){
	            	response = getFieldValues(requestData);		    
		        
			} else if(ACTION_VALUE_GET.equalsIgnoreCase(action)){
	            	response = getAudience(requestData);
		        
			} else if(ACTION_VALUE_SEARCH.equalsIgnoreCase(action)){
	            	response = search(requestData);
		        
			} else if(ACTION_VALUE_SAVE.equalsIgnoreCase(action)){
				    response = saveAudience(requestData);

			} else if(ACTION_VALUE_DELETE_AUDIENCE.equalsIgnoreCase(action)){
				    response = deleteAudience(requestData);

			}  else if (ACTION_VALUE_GET_AUDIENCE_BY_IDS.equalsIgnoreCase(action)){
                String[] listOfAudienceId = (String[])JSON.deserialize(requestData, 
                        String[].class);

                logger.logDebug(listOfAudienceId);
                List<AudienceWrapper> listOfAudienceWrap = new AudienceService().getAudienceByIds(listOfAudienceId);
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, listOfAudienceWrap);
            
            } else {
				response = null;

			}
			
		} catch (Exception ex) {
            logger.logError('AudienceDataServer.handleRequest()---Exception occured----', ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        
	}

	private ResponseWrapper getFieldValues(String requestData) {
		ResponseWrapper responseWrapperObj = null;
		try {
			Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestData, Map<String, String>.class);
			String segmentId = (requestMap.containsKey('segmentId')) ? requestMap.get('segmentId') : '';
			String field = (requestMap.containsKey('field')) ? requestMap.get('field') : '';
			logger.logDebug('AudienceDataServer.getFieldValues()----requestData----' + requestData);
			logger.logDebug('AudienceDataServer.getFieldValues()----segmentId----' + segmentId + '----field----' + field);
			
			AudienceWrapper.AudienceCondition audienceWrapperObj = new AudienceWrapper.AudienceCondition();
			if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
				audienceWrapperObj = getAudienceFieldValuesFromAWS(segmentId, field);
			} else {
				audienceWrapperObj = getAudienceFieldValuesFromSF(segmentId, field);
			}
			
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, audienceWrapperObj);					
					
		} catch(Exception ex) {
			logger.logError('AudienceDataServer.getFieldValues()---Exception occured----', ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		
		return responseWrapperObj;
	}

	private  AudienceWrapper.AudienceCondition getAudienceFieldValuesFromAWS(String segmentId, String fieldName) {
		String searchForType = 'Audience_Field_Values';

		AudienceWrapper.AudienceCondition audienceConditionWrapper = new AudienceWrapper.AudienceCondition();
		audienceConditionWrapper.name = fieldName;
		audienceConditionWrapper.label = fieldName;
		
		Map<String, String> customFieldNameToAPINameMap = new Map<String, String> {
			'custom_field_1__c' => 'Custom_Field_1', 'custom_field_2__c' => 'Custom_Field_2',
			'custom_field_3__c' => 'Custom_Field_3', 'custom_field_4__c' => 'Custom_Field_4',
			'custom_field_5__c' => 'Custom_Field_5', 'custom_field_6__c' => 'Custom_Field_6',
			'custom_field_7__c' => 'Custom_Field_7', 'custom_field_8__c' => 'Custom_Field_8',
			'custom_field_9__c' => 'Custom_Field_9', 'custom_field_10__c' => 'Custom_Field_10',
			'custom_field_11__c' => 'Custom_Field_11', 'custom_field_12__c' => 'Custom_Field_12',
			'custom_field_13__c' => 'Custom_Field_13', 'custom_field_14__c' => 'Custom_Field_14',
			'custom_field_15__c' => 'Custom_Field_15', 'custom_field_16__c' => 'Custom_Field_16',
			'custom_field_17__c' => 'Custom_Field_17', 'custom_field_18__c' => 'Custom_Field_18',
			'custom_field_19__c' => 'Custom_Field_19', 'custom_field_20__c' => 'Custom_Field_20',
			'custom_field_21__c' => 'Custom_Field_21', 'custom_field_22__c' => 'Custom_Field_22',
			'custom_field_23__c' => 'Custom_Field_23', 'custom_field_24__c' => 'Custom_Field_24',
			'custom_field_25__c' => 'Custom_Field_25', 'category' => 'people_category'
		};

		if(customFieldNameToAPINameMap.containsKey(fieldName.toLowerCase())) {
			fieldName = customFieldNameToAPINameMap.get(fieldName.toLowerCase());
		}

		Criteria.ExternalSearchReq audienceFiledValuesCriteria = new Criteria.ExternalSearchReq();
		audienceFiledValuesCriteria.fieldName = fieldName;
		audienceFiledValuesCriteria.ppl_segment_id = segmentId;

		ExternalSearchService externalServiceObj = new ExternalSearchService();
		ExternalSearchWrapper.ObjectTypeWrapper returnWrapper = externalServiceObj.getAudienceFieldValues(audienceFiledValuesCriteria, searchForType);

		logger.logDebug('AudienceDataServer.getFieldValues()---- returnWrapper :: ' + returnWrapper);

		audienceConditionWrapper.values = new List<AudienceWrapper.AudienceConditionValue>();

		for(ExternalSearchWrapper.BucketWrapper rec : returnWrapper.buckets) {
			AudienceWrapper.AudienceConditionValue valueObj = new AudienceWrapper.AudienceConditionValue();
			if(rec != null && String.isNotBlank(rec.value)){
				if(customFieldNameToAPINameMap.get('category').equalsIgnoreCase(fieldName)) {
					valueObj.id = rec.people_category_id;
				}
				valueObj.name = rec.value;

				(audienceConditionWrapper.values).add(valueObj);
			}
		}

		return audienceConditionWrapper;
	}
	
	@TestVisible
	private AudienceWrapper.AudienceCondition getAudienceFieldValuesFromSF(String segmentId, String fieldName) {
		String packageName = SimpplrContext.packageName; 
		
		String fieldAPIName = Utility.getLabelVsPeopleFieldMap().get(fieldName);

		if('People_Category__r'.equalsIgnoreCase(fieldAPIName)) {
			fieldAPIName = 'People_Category__r.Name__c';
		}
		
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', segmentId);

		String queryStr = 'SELECT '+ fieldAPIName + ' ' + fieldAPIName +  ' FROM People__c WHERE User__r.IsActive = true AND User__r.UserType = \'Standard\' ';
		
		if(String.isNotBlank(segmentId)) {
			queryStr += ' And Segment__c = :soqlParam1 ';
		}
		if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
			soqlParamMap.put('soqlParam2', packageName);
			queryStr += ' AND User__c IN (SELECT UserId FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: soqlParam2)';
		}
		queryStr += ' AND ' + fieldAPIName + ' != NULL GROUP BY ' + fieldAPIName;

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<AggregateResult> arList = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);

		AudienceWrapper.AudienceCondition audienceConditionWrapper = new AudienceWrapper.AudienceCondition();
		audienceConditionWrapper.name = fieldName;
		audienceConditionWrapper.label = fieldName;
		audienceConditionWrapper.values = new List<AudienceWrapper.AudienceConditionValue>();

		List<String> categoryIds = new List<String>();
        for(AggregateResult ar : arList) {
			categoryIds.add((String)ar.get(fieldAPIName));
		}

		Map<String, Object> soqlParamMap1 = new Map<String, Object>();
		soqlParamMap1.put('soqlParam1', categoryIds);
		String queryStr1 = 'SELECT Id, Name__c FROM People_Category__c WHERE Id = :soqlParam1';

		List<People_Category__c> categoryList = (List<People_Category__c>)SIMPESAPI.accessController().queryAsUSer(queryStr1, soqlParamMap1);	

		Map<String, String> categoryIdAndNameMap = new Map<String, String>();
		for(People_Category__c catObj : categoryList) {
			categoryIdAndNameMap.put(catObj.Id, catObj.Name__c);
		}


		for(AggregateResult ar : arList) {
			AudienceWrapper.AudienceConditionValue valueObj = new AudienceWrapper.AudienceConditionValue();

			if('category'.equalsIgnoreCase(fieldName)) {
				String categoryId = (String)ar.get(fieldAPIName);
				valueObj.id = categoryId;
				valueObj.name = categoryIdAndNameMap.get(categoryId);
			} else {
				valueObj.name = (String)ar.get(fieldAPIName);
			}

			(audienceConditionWrapper.values).add(valueObj);
        }
		
		return audienceConditionWrapper;
	}

	private ResponseWrapper search(String requestData) {
		logger.logDebug('AudienceDataServer.search()----- requestData: ' + requestData);
		AudienceWrapper.PaginationWrapper audienceListingContainerObj = new AudienceWrapper.PaginationWrapper();
		Criteria.Audience criteriaAudienceObj = new Criteria.Audience();
		
		if(String.isNotBlank(requestData)) {
			criteriaAudienceObj = (Criteria.Audience)JSON.deserialize(requestData, Criteria.Audience.class);
		}

		if(criteriaAudienceObj.size == null) {
			criteriaAudienceObj.size = 16; //TODO
		}

		Integer recordLimit = criteriaAudienceObj.size + 1;

		ResponseWrapper responseWrapperObj = null;
		try {
			if (criteriaAudienceObj.nextPageToken == null) {
				criteriaAudienceObj.offset = 0;
				
			} else {
				criteriaAudienceObj.offset = Integer.valueOf(criteriaAudienceObj.nextPageToken);
			}

			AudienceService service = new AudienceService();
			
			String segmentId = criteriaAudienceObj.segmentId;

			List<AudienceWrapper> listOfAudienceWrap = service.search(segmentId, recordLimit, criteriaAudienceObj.offset, criteriaAudienceObj.term);
			
			if(listOfAudienceWrap !=null){
	   			audienceListingContainerObj.listOfItems.addAll(listOfAudienceWrap);
	   		}
	        if (audienceListingContainerObj.listOfItems.size() == (SimpplrContext.simpplrDefaultPageSize + 1) &&
	     		criteriaAudienceObj.offset < 2000) {
	        	audienceListingContainerObj.listOfItems.remove((audienceListingContainerObj.listOfItems.size()-1));
	        	audienceListingContainerObj.nextPageToken = String.valueOf(criteriaAudienceObj.offset + SimpplrContext.simpplrDefaultPageSize);
	       
	        } else {
	        	audienceListingContainerObj.nextPageToken = null;
	        }

			//Map<String, Object> audienceItemsMap = new Map<String, Object>();
			//audienceItemsMap.put('listOfItems', audienceListingContainerObj.listOfItems);
    		
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, audienceListingContainerObj);
		} catch (Exception ex) {
			logger.logError('AudienceDataServer.search()---Exception occured----', ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		
		return responseWrapperObj;
	}

	private ResponseWrapper saveAudience(String requestData) { 
		logger.logDebug('AudienceDataServer.saveAudience() ----- requestData: ' + requestData);

		ResponseWrapper responseWrapperObj = null;
		try {
			if(String.isBlank(requestData)){ 
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}
			AudienceWrapper audienceWrapperObj = (AudienceWrapper) JSON.deserialize(requestData, AudienceWrapper.class);
			if(audienceWrapperObj.isCreatedByAudienceCsv == true) {
				Map<String, String> batchParamMap = new Map<String, String>();
				batchParamMap.put('audienceId', audienceWrapperObj.audienceId);

				BatchProcessSubscription job = new BatchProcessSubscription('newSubscriptionEntities', batchParamMap);
				Database.executeBatch(job, 200);
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, audienceWrapperObj);
			} else  {
				if (hasAccess(UserContext.segmentId)) {	
					List<PeopleLiteWrapper> peopleLiteList = audienceWrapperObj.listOfPeople;
					List<String> peopleIdslist = null;

					if (SimpplrContext.isFeatureEnabled('Full_External_Search') && audienceWrapperObj.listOfConditions != null) {
						for(AudienceWrapper.AudienceCondition audienceCondObject : audienceWrapperObj.listOfConditions) {
							if(!audienceCondObject.values.isEmpty()) {
								for(AudienceWrapper.AudienceConditionValue valueObj : audienceCondObject.values) {
									if (String.isNotBlank(valueObj.id) && valueObj.id.containsIgnoreCase('hireDate')){
										ExternalSearchService externalSearchServiceObj = new ExternalSearchService();
										String filter_value = valueObj.id.containsIgnoreCase('Before') ? 'before' : 'after';
										peopleIdslist = externalSearchServiceObj.getNewHiresOnJoinigDate(valueObj.name, filter_value, 'joining_date');
									}
								}
							}
						}
					}

					AudienceService service = new AudienceService();			
					audienceWrapperObj = service.saveAudience(audienceWrapperObj);
					audienceWrapperObj.listOfPeople = peopleLiteList;
					if(!audienceWrapperObj.isCreatedFromADGroups) {
						service.updateAudienceMembers(audienceWrapperObj, peopleIdslist);
					} else {
						List<String> audienceList = new List<String>();
						audienceList.add(audienceWrapperObj.audienceId);
						Database.executeBatch(new BatchSyncAudienceMembersFromAD('syncAudienceMemWithAD', audienceList, false), 2000);
					}
					audienceWrapperObj.audienceCount = service.getAudienceMemberCount(audienceWrapperObj.audienceId);
	
					if (audienceWrapperObj.listOfPeople!=null && audienceWrapperObj.listOfPeople.size()>ServiceConstants.AUDIENCE_MEMBER_LIMIT) {
						List<PeopleLiteWrapper> tobeShownpeopleLiteList = new List<PeopleLiteWrapper>();
						for(Integer i=0;i<ServiceConstants.AUDIENCE_MEMBER_LIMIT;i++){
							tobeShownpeopleLiteList.add(audienceWrapperObj.listOfPeople[i]);
						}
						audienceWrapperObj.listOfPeople = tobeShownpeopleLiteList;
					}
					responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, audienceWrapperObj);
				} else {
					responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, 'Insufficient privileges!', null);
				}
			}
		} catch(Exception e) {
			String errMsg = (e instanceof SimpplrException) ? e.getMessage() : null;
        	logger.logError('AudienceDataServer.saveAudience()----Exception Occured----',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, errMsg, null);			
		}

		return responseWrapperObj;
	}

	private Boolean hasAccess(String segmentId) {
		Boolean hasAccess = false;

		if(UserContext.isUserAppModerator || (SimpplrContext.isSegmentsEnabled && UserContext.isSegmentManager)) {
			hasAccess = true;
		}

		return hasAccess;
	}

	private ResponseWrapper deleteAudience(String requestData) {
		logger.logDebug('AudienceDataServer.deleteAudience()----- requestData: ' + requestData);
		Criteria.AudienceDeleteParams criteriaAudienceObj = (Criteria.AudienceDeleteParams)JSON.deserialize(requestData, Criteria.AudienceDeleteParams.class);
		ResponseWrapper responseWrapperObj = null;

		try {
			AudienceService service = new AudienceService();
			if(String.isNotBlank(criteriaAudienceObj.audienceId)) {
				service.deleteAudience(criteriaAudienceObj.audienceId);
				service.markCampaignAsInactive(criteriaAudienceObj.audienceId);
				service.markAlertsAsExpired(criteriaAudienceObj.audienceId);
				service.deletePendingSubscriptions(criteriaAudienceObj.audienceId);
				service.deleteDraftOrScheduledNewsletter(criteriaAudienceObj.audienceId);
			}
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
		} catch(Exception e) {
			logger.logError('AudienceDataServer.deleteAudience()---Exception occured---', e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}

		return responseWrapperObj;
	}

	private ResponseWrapper getAudience(String requestData) {
		logger.logDebug('AudienceDataServer.getAudience()----- requestData: ' + requestData);
		ResponseWrapper responseWrapperObj = null;
		
		if(String.isBlank(requestData)){ 
			throw new SimpplrException(ServiceConstants.ERROR_403);
		}

		Criteria.AudienceDeleteParams criteriaAudienceObj = (Criteria.AudienceDeleteParams)JSON.deserialize(requestData, Criteria.AudienceDeleteParams.class);
		AudienceWrapper audienceWrapperObj; 

		try {
			AudienceService service = new AudienceService();
			if(String.isNotBlank(criteriaAudienceObj.audienceId)) {
				if(criteriaAudienceObj.fromEditModal==true){
					audienceWrapperObj = service.getAudienceById(criteriaAudienceObj.audienceId,criteriaAudienceObj.fromEditModal);
				}else{
					audienceWrapperObj = service.getAudienceById(criteriaAudienceObj.audienceId);
				}
			} else {
				throw new SimpplrException(ServiceConstants.ERROR_INVALID_REQUEST_PARAMETERS);
			}
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, audienceWrapperObj);
		} catch(Exception e) {
			logger.logError('AudienceDataServer.getAudience()---Exception occured---', e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}

		return responseWrapperObj;
	}

	public class AudienceFieldsWrapper {
		public String id;
		public String label;
		public String type;
	}

}