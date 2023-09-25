public with sharing class SegmentDataServer extends DataServer {
    private final String ACTION_VALUE_GET = 'get';
    private final String ACTION_VALUE_SEARCH = 'search';
    private final String ACTION_VALUE_SET_MANAGERS = 'setManagers';
    private final String ACTION_VALUE_SET_ENABLED = 'setEnabled';
    private final String ACTION_VALUE_SETUP = 'setup';
    private final String ACTION_VALUE_ALLOW_APPS_N_LINKS = 'allowAppsAndLinks';
    private final String ACTION_VALUE_ALLOW_BRANDING = 'allowBranding';
    private final String REQUEST_PARAM_DATA = 'data';
    private final String ACTION_VALUE_GET_POSSIBLE_SUBSEGMENT = 'getPossibleSubsegments';
    @TestVisible private final String ACTION_VALUE_GET_BY_IDS = 'getByIds';

    public override void handleRequest () {
		logger.logDebug('SegmentDataServer.handleRequest()----entered handleRequest----');
		
		try {
			String action = readParam(REQUEST_PARAM_ACTION);
			String requestData = readParam(REQUEST_PARAM_DATA);
			
			if (ACTION_VALUE_GET.equalsIgnoreCase(action)) {
				response = getSegment(readParam('segmentId'));
				
			} else {
				if (ACTION_VALUE_SEARCH.equalsIgnoreCase(action) ) {
					if(!UserContext.hasManageCampaignAccess && !UserContext.canAccessAnalytics) {
						throw new SimpplrException(ServiceConstants.ERROR_403);
					}
				
				} else if(!UserContext.isUserAppModerator ){ 
					throw new SimpplrException(ServiceConstants.ERROR_403);
				
				}		
				
				if (ACTION_VALUE_SEARCH.equalsIgnoreCase(action)) {
					Criteria.Segment criteriaSegmentObj = (Criteria.Segment)JSON.deserialize(requestData, 
							Criteria.Segment.class);
					response = search(criteriaSegmentObj);
				
				} else if(ACTION_VALUE_SET_ENABLED.equalsIgnoreCase(action)){
					List<SegmentWrapper> criteriaSegmentSetupObj = new List<SegmentWrapper>();
					if(String.isNotBlank(requestData)) {
						criteriaSegmentSetupObj = (List<SegmentWrapper>)JSON.deserialize(requestData, List<SegmentWrapper>.class);
					}
					SegmentWrapper.Options segmentOptions = new SegmentWrapper.Options();
					segmentOptions.isAppsAndLinksSegmented = 'true'.equalsIgnoreCase(readParam('isAppsAndLinksSegmented')) ? true : false;
					segmentOptions.isBrandingSegmented = 'true'.equalsIgnoreCase(readParam('isBrandingSegmented')) ? true : false;
					segmentOptions.shouldInherit = 'true'.equalsIgnoreCase(readParam('shouldInherit')) ? true : false;
					
		            response = setEnabled(readParam('profileField'), criteriaSegmentSetupObj, segmentOptions);
	
				} else if (ACTION_VALUE_SETUP.equalsIgnoreCase(action)) {
					List<SegmentWrapper> criteriaSegmentSetupObj = (List<SegmentWrapper>)JSON.deserialize(requestData, 
							List<SegmentWrapper>.class);
					response = setup(criteriaSegmentSetupObj);
					
				} else if (ACTION_VALUE_SET_MANAGERS.equalsIgnoreCase(action)) {
					List<PeopleLiteWrapper> peopleWrapperList = (List<PeopleLiteWrapper>)JSON.deserialize(readParam('listOfManagers'), List<PeopleLiteWrapper>.class);
					response = setManagers(readParam('segmentId'), peopleWrapperList);
									
				} else if (ACTION_VALUE_ALLOW_APPS_N_LINKS.equalsIgnoreCase(action)) {
					response = allowAppsAndLinks(readparam('isEnabled'));
									
				} else if (ACTION_VALUE_ALLOW_BRANDING.equalsIgnoreCase(action)) {
					response = allowBranding(readparam('isEnabled'));
									
				} else if (ACTION_VALUE_GET_POSSIBLE_SUBSEGMENT.equalsIgnoreCase(action)) {
					response = getPossibleSubsegments(readparam('profileField'));
					
				} else if (ACTION_VALUE_GET_BY_IDS.equalsIgnoreCase(action)){

                String[] listOfSegmentId = (String[])JSON.deserialize(requestData, 
                        String[].class);

                logger.logDebug(listOfSegmentId);
                List<Segment__c> listOfSegments = new SegmentDao().getSegmentsByIds(listOfSegmentId);
                List<AudienceWrapper.SegmentLiteWrapper> listOfSiteWrap = new NewsletterV2DataAdapter().convertToListOfSegmentLiteWrapper(listOfSegments);
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, listOfSiteWrap);
            
            } else {
					throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
				} 
			}
			
		} catch (Exception ex) {
            logger.logError('SegmentDataServer.handleRequest()---Exception occured----', ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        
	}
	
	/**
	 * @api {get} /apex/DataServerRO?target=SegmentDataServer&action=search search
	 * @apiVersion 1.0.0
	 * @apiGroup SegmentDataServer
	 * @apiName searchFiles
	 *
	 * @apiParam (Query Parameter){String} action=search 
	 * @apiParam (Post Parameter) {Object} data
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.Segment.search
	 * 2. Used in SegmentList
	 * 3. This is used for search and for Segment listing with various filter conditions
	 * 
	 * @apiSuccess {List[SegmentWrapper]} Response.listOfItems List of Segments that matches the search filter criteria
	 * @apiUse SegmentWrapper
	 *
	 * @apiError SimpplrException Simpplr Exception
	 * @apiError (Error 404) SimpplrException Segment not found
	 */
	private ResponseWrapper search(Criteria.Segment requestObj) {
		ResponseWrapper responseWrapperObj = null;
		
		try {
			String queryStr;
			Boolean sortSegmentList = false;
			if (requestObj.isFullModel) {
				queryStr = 'SELECT '+String.join(getFullModelSegmentFieldList(),',');
				
			} else {
				queryStr = 'SELECT '+String.join(getSegmentFieldList(),',');
				
			}
			if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
				queryStr += ' FROM Segment__c ';
				sortSegmentList = true;
			} else {
				queryStr += ' FROM Segment__c order by Name__c ASC ';
			}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			List<Segment__c> listOfSegment = (List<Segment__c>)SIMPESAPI.accessController().queryAsUSer(queryStr, null);	
			SegmentWrapper.PaginationWrapper paginationObj = new SegmentWrapper.PaginationWrapper();
			
			if (!listOfSegment.isEmpty()) {
				
				if (requestObj.isFullModel) {
					paginationObj = SegmentationWrapperAdapter.convertToFullSegmentWrapList(listOfSegment, requestObj.includeUnassigned);
				
				} else {
					paginationObj = SegmentationWrapperAdapter.convertToLightSegmentWrapList(listOfSegment, requestObj.includeUnassigned);
				}
				
			}
			if(sortSegmentList) {
				paginationObj.listOfItems.sort();
			}
			
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, paginationObj);
		
		} catch (Exception ex) {
			logger.logError('SegmentDataServer.search()---Exception occured----', ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, 
			null, null);
		}
		
		return responseWrapperObj;
	}
	
	/**
	 * @description setEnabled - @api {post} /apex/DataServerRW?target=SegmentDataServer&action=setEnabled
	 * @param profileField
	 * @param listOfSegmentSetup
	 * @param segmentOptions
	 * @return ResponseWrapper
	*/
	private ResponseWrapper setEnabled(String profileField, List<SegmentWrapper> listOfSegmentSetup, SegmentWrapper.Options segmentOptions) {
		logger.logDebug('SegmentDataServer.setEnabled()----profileField----'+ profileField + '----segmentOptions----' +segmentOptions);
		ResponseWrapper responseWrapperObj = null;
		try {
			if (!UserContext.isUserAppModerator) { 
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}
			
			SegmentService serviceObj = new SegmentService(); 
			
			if ('false'.equalsIgnoreCase(profileField)) {
				serviceObj.disableSegmentation();
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Batch process to disable segmentation started successfully', null);
				
			} else if (Utility.getPeopleFieldVsLabelMap().keySet().contains(profileField)) {

				serviceObj.enableSegmentation(profileField, listOfSegmentSetup, segmentOptions);
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Batch process to enable segmentation started successfully', null);
				
			} else {
				throw new SimpplrException(ExceptionCode.INVALID_PARAMETER.name());
			}
			
		} catch (Exception ex) {
			logger.logError('SegmentDataServer.setEnabled()---Exception occured----', ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, ex.getMessage(), null);
		}
		
		return responseWrapperObj;
	}
	
	/**
	 * @api {get} /apex/DataServerRO?target=SegmentDataServer&action=getSegment getSegment
	 * @apiVersion 1.0.0
	 * @apiGroup SegmentDataServer
	 * @apiName getSegment
	 *
	 * @apiParam (Query Parameter) {String} action=getSegment 
	 * @apiParam (Post Parameter) {Object} data {segmentId}
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.Segment.getSegment
	 * 2. Used in Segments
	 * 3. This is used for getting Segment details
	 * 
	 * @apiSuccess {SegmentWrapper} Response.result The Segments object
	 * @apiUse SegmentWrapper
	 *
	 * @apiError SimpplrException Simpplr Exception
	 * @apiError (Error 404) SimpplrException Segment not found
	 */
	private ResponseWrapper getSegment(String segmentId) {
		ResponseWrapper responseWrapperObj = new ResponseWrapper();
		
		try {
			logger.logDebug('SegmentDataServer.getSegment()----segmentId----'+ segmentId);
			Map<String, Object> soqlParamMap = new  Map<String, Object>();
			soqlParamMap.put('soqlParam1', segmentId);
			String queryStr = 'SELECT ' + String.join(getFullModelSegmentFieldList(),',') + 
					' FROM Segment__c where id=:soqlParam1 ';	
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			List<Segment__c> listOfSegment = (List<Segment__c>)SIMPESAPI.accessController().queryAsUSer(queryStr, soqlParamMap);				
			SegmentWrapper segmentWrapperObj = new SegmentWrapper();
			
			if (!listOfSegment.isEmpty()) {
				Map<String, SegmentWrapper.SubsegmentListWrapper> mapOfSubsegmentListWrapper = SegmentationWrapperAdapter.getSubsegments(listOfSegment);				
				segmentWrapperObj = SegmentationWrapperAdapter.convertToFullSegmentWrap(listOfSegment[0]);
				
				SegmentWrapper.SubsegmentListWrapper subSegmentDetails = mapOfSubsegmentListWrapper.get(listOfSegment[0].Id);
				if(subSegmentDetails == null) {
					segmentWrapperObj.listOfSubsegments = new List<SegmentWrapper.SubsegmentWrapper>();
					segmentWrapperObj.audienceCount = 0;
				} else {
					segmentWrapperObj.listOfSubsegments = mapOfSubsegmentListWrapper.get(listOfSegment[0].Id).listOfSubsegments;
					segmentWrapperObj.audienceCount = mapOfSubsegmentListWrapper.get(listOfSegment[0].Id).audienceCount;
				}				
			}
			
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 
					null, segmentWrapperobj);					
		
		} catch (exception ex) {
    		logger.logError('SegmentDataServer.getSegment()---Exception occured----', ex);
        	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, 
        			MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        
		return responseWrapperObj;
	}

	/**
	 * @description allowAppsAndLinks - This is used for enabling or disabling apps & links within Segments
	 * @param isEnabled
	 * @return ResponseWrapper
	 */
	private ResponseWrapper allowAppsAndLinks(String isEnabled) {
		ResponseWrapper responseWrapperObj = new ResponseWrapper();
		try {
			logger.logDebug('SegmentDataServer.allowAppsAndLinks()----isEnabled----'+ isEnabled);
			String appConfigQuery = 'Select Id, Segment_Apps_Links_Enabled__c FROM App_Config__c limit 1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<App_Config__c> listOfAppConfig = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);

			listOfAppConfig[0].Segment_Apps_Links_Enabled__c = Boolean.valueOf(isEnabled);

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Config__c>(listOfAppConfig), new List<Schema.SObjectField>{
				App_Config__c.Segment_Apps_Links_Enabled__c
			});

			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, true);
		} catch (exception ex) {
			logger.logError('SegmentDataServer.allowAppsAndLinks()---Exception occured----', ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
		}

		return responseWrapperObj;
	}

	/**
	 * @api {post} /apex/DataServerRW?target=SegmentDataServer&action=allowbranding allowbranding
	 * @apiVersion 1.0.0
	 * @apiGroup SegmentDataServer
	 * @apiName allowbranding
	 *
	 * @apiParam (Query Parameter){Boolean} action=allowbranding 
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.Segment.allowbranding
	 * 2. Used in Segments
	 * 3. This is used for enabling or disabling branding within Segments
	 * 
	 * @apiSuccess {Boolean} Response.result true/false
	 *
	 * @apiError SimpplrException Simpplr Exception
	 */
	private ResponseWrapper allowbranding(String isEnabled) {
		ResponseWrapper responseWrapperObj = new ResponseWrapper();
		
		try {
			logger.logDebug('SegmentDataServer.allowbranding()----isEnabled----'+ isEnabled);
			String appConfigQuery = 'Select Id, Segment_Branding_Enabled__c, Branding_CSS__c,'
													+ ' Branding_CSS_Class__c, Branding_Custom_Font_CSS__c, Favicons_Folder__c,'
													+ ' Branding_JSON__c, Branding_Logo__c FROM App_Config__c limit 1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<App_Config__c> listOfAppConfig = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
													
	    	if(listOfAppConfig[0]==null){
				throw new SimpplrException(ExceptionCode.CONFIGURATION_ERROR.name());
			}	
			
			if(SimpplrContext.isSegmentsEnabled){
				// Default values for branding
				String brandingJSON = Utility.getDefaultBrandingValues();
				
				String faviconsFolderPathString = ServiceConstants.DEFAULT_BRANDING.get('logo_faviconPath');
				
				if(Boolean.valueOf(isEnabled)){
					// Update default branding's value to all Segments 

					String query = 'SELECT id, Branding_CSS__c, Branding_CSS_Class__c, Branding_Custom_Font_CSS__c, '
									+ '	Favicons_Folder__c, Branding_JSON__c, Branding_Logo__c, Branding_Package_Version__c '
									+ '	FROM Segment__c limit 8000';

					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
					List<Segment__c> segmentList = (List<Segment__c>)SIMPESAPI.accessController().queryAsUSer(query, null);
					
					if(!segmentList.isEmpty()){
						for (Segment__c segmentObj : segmentList){
							segmentObj.Branding_CSS__c = '';
							segmentObj.Branding_CSS_Class__c = '';
							segmentObj.Branding_Custom_Font_CSS__c = '';
							segmentObj.Favicons_Folder__c = faviconsFolderPathString;
							segmentObj.Branding_JSON__c = brandingJSON;
							segmentObj.Branding_Logo__c = '';
							segmentObj.Branding_Package_Version__c = ServiceConstants.PACKAGE_VERSION;
						}

						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
						SIMPESAPI.accessController().updateAsUser(new Map<Id, Segment__c>(segmentList), new List<Schema.SObjectField>{
							Segment__c.Branding_CSS__c,
							Segment__c.Branding_CSS_Class__c, 
							Segment__c.Branding_Custom_Font_CSS__c,
							Segment__c.Favicons_Folder__c,
							Segment__c.Branding_JSON__c,
							Segment__c.Branding_Logo__c,
							Segment__c.Branding_Package_Version__c
						});
					}
				}  else {
					// Update default branding to App level
					listOfAppConfig[0].Branding_CSS__c = '';
					listOfAppConfig[0].Branding_CSS_Class__c = '';
					listOfAppConfig[0].Branding_Custom_Font_CSS__c = '';
					listOfAppConfig[0].Favicons_Folder__c = faviconsFolderPathString;
					listOfAppConfig[0].Branding_JSON__c = brandingJSON;
					listOfAppConfig[0].Branding_Logo__c = '';
				}
			}
			
			listOfAppConfig[0].Segment_Branding_Enabled__c = Boolean.valueOf(isEnabled);
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Config__c>(listOfAppConfig), new List<Schema.SObjectField>{
				App_Config__c.Branding_CSS__c, 
				App_Config__c.Branding_CSS_Class__c, 
				App_Config__c.Branding_Custom_Font_CSS__c, 
				App_Config__c.Favicons_Folder__c, 
				App_Config__c.Branding_JSON__c, 
				App_Config__c.Branding_Logo__c
			});
			
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 
					null, true);					
		
		} catch (exception ex) {
    		logger.logError('SegmentDataServer.getSegment()---Exception occured----', ex);
        	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, 
        			MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        
		return responseWrapperObj;
	}		
	
	/**
	 * @api {post} /apex/DataServerRW?target=SegmentDataServer&action=setManagers setManagers
	 * @apiVersion 1.0.0
	 * @apiGroup SegmentDataServer
	 * @apiName setManagers
	 *
	 * @apiParam (Query Parameter){String} action=setManagers 
	 * @apiParam (Post Parameter){List[PeopleLiteWrapper]} action=setManagers 
	 * 
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.Segment.setManagers
	 * 2. Used in Segments
	 * 3. This is used for assigning managers to a Segment
	 * 
	 * @apiSuccess {Boolean} Response.result true/false
	 *
	 * @apiError SimpplrException Simpplr Exception
	 */
	private ResponseWrapper setManagers(String segmentId, List<PeopleLiteWrapper> peopleWrapperList) {
		logger.logDebug('SegmentDataServer.setManagers()----segmentId----'+ segmentId + '----peopleWrapperList----' + peopleWrapperList);
		ResponseWrapper responseWrapperObj = new ResponseWrapper();
		
		try {
			if(String.isBlank(segmentId) || peopleWrapperList == null){
				throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
			}
			
			Set<Id> managerIdSet = new Set<Id>();
			for(PeopleLiteWrapper peopleWrapperRec: peopleWrapperList){
				managerIdSet.add(peopleWrapperRec.peopleId);
			}
			
			List<People__c> peopleList = SegmentDao.getSegmentMembersForSaveManager(segmentId, managerIdSet);
			List<People__c> peopleListToUpdate = new List<People__c>();
			
			Set<String> toBeNotifiedPeopleIdSet = new Set<String>();
			for (People__c peopleRec: peopleList) {
				if(!peopleRec.Is_Segment_Manager__c){
					toBeNotifiedPeopleIdSet.add(peopleRec.Id);
				}
				peopleRec.Is_Segment_Manager__c = !peopleRec.Is_Segment_Manager__c;	
				peopleListToUpdate.add(peopleRec);
			} 
			
			SegmentDao.updatePeopleList(peopleListToUpdate);
			// Notify People getting added as Segment Manager(s)
			if(!toBeNotifiedPeopleIdSet.isEmpty()){
				NotificationDispatcher.sendNotificationToNewSegmentManagers(segmentId, toBeNotifiedPeopleIdSet);
				NotificationDispatcher.sendEmailNotificationToNewSegmentManagers(segmentId, toBeNotifiedPeopleIdSet);
			}
			
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, true);					
		
		} catch (exception ex) {
    		logger.logError('SegmentDataServer.getSegment()---Exception occured----', ex);
        	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, 
        			MessageHelper.translateSFMessageToErrorCode(ex), false);
        }
        
		return responseWrapperObj;
	}
	
	/**
	 * @api {post} /apex/DataServerRW?target=SegmentDataServer&action=setup setup
	 * @apiVersion 1.0.0
	 * @apiGroup SegmentDataServer
	 * @apiName setup
	 *
	 * @apiParam (Query Parameter){List[SegmentWrapper]} action=setup 
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.Segment.setup
	 * 2. Used in Segments
	 * 3. This is used in setting up Segments
	 * 
	 * @apiSuccess {Boolean} Response.result true/false
	 *
	 * @apiError SimpplrException Simpplr Exception
	 */
	private ResponseWrapper setup(List<SegmentWrapper> listOfSegmentSetup) {
		ResponseWrapper responseWrapObj = null;
		
		// Enable Maintenance 
		String appConfigQuery = 'select id, Maintenance_In_Progress__c, Maintenance_Reason__c from App_Config__c limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		App_Config__c appConfig = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];
		
		appConfig.Maintenance_In_Progress__c = true;
		appConfig.Maintenance_Reason__c = 'enableSegmentation';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().updateAsUser(appConfig, new List<Schema.SObjectField>{
				App_Config__c.Maintenance_In_Progress__c,
				App_Config__c.Maintenance_Reason__c
		});

		segmentService segmentServiceObj = new segmentService();
		SegmentWrapper.Options segmentOptions = new SegmentWrapper.Options();
		segmentOptions.isAppsAndLinksSegmented = SimpplrContext.isSegmentAppsNLinksEnabled;
		segmentOptions.isBrandingSegmented = SimpplrContext.isSegmentBrandingEnabled;
		segmentOptions.shouldInherit = false;
		segmentServiceObj.setupSegment(listOfSegmentSetup, segmentOptions);
		responseWrapObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, true);	
		
		return responseWrapObj;
	}
	
	/**
	 * @api {post} /apex/DataServerRW?target=SegmentDataServer&action=getPossibleSubsegments getPossibleSubsegments
	 * @apiVersion 1.0.0
	 * @apiGroup SegmentDataServer
	 * @apiName getPossibleSubsegments
	 *
	 * @apiParam (Post Parameter){String} action=getPossibleSubsegments 
	 * @apiParam (Post Parameter) {Object} data {profileField}
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.Segment.getPossibleSubsegments
	 * 2. Used in Segments
	 * 3. This is used for getting Subsegment list
	 * 
	 * @apiSuccess {SegmentWrapper.UnassignedWrapper} Response.listOfSubsegments  List of possible Subsegments
	 * @apiUse SegmentWrapperUnassignedWrapper
	 *
	 * @apiError SimpplrException Simpplr Exception
	 * @apiError (Error 404) SimpplrException Segment not found
	 */
	private ResponseWrapper getPossibleSubsegments(String profileField) {
		ResponseWrapper responseWrapObj = null;
		SegmentWrapper.UnassignedWrapper resultObj = new SegmentWrapper.UnassignedWrapper();
		
		segmentService segmentServiceObj = new segmentService();
		resultObj = segmentServiceObj.getPossibleSubsegments(profileField);
		responseWrapObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, resultObj);	
		return responseWrapObj;
	}
	
	
	public static List<String> getFullModelSegmentFieldList() {
		List<String> fullModelSegmentFieldList = getSegmentFieldList();
		fullModelSegmentFieldList.addAll(new List<String>{
			'(SELECT Id, user__r.Id, First_Name__c, Community_Nickname__c, Last_Name__c, Full_Name__c, user__r.SmallPhotoURL, Department__c, About__c, Title__c, City__c, State__c, Country__c, Email__c, Phone__c, mobile_phone__c, Extension__c, Birth_Date__c, Joining_Date__c, Skype_Id__c, Zoom_Id__c, User__c, User__r.isactive FROM People_Segment__r WHERE Is_Segment_Manager__c = TRUE)'
		});	
		return fullModelSegmentFieldList;
	}
	
	public static List<String> getSegmentFieldList() {
    		return New List<String>{
			'Id',
			'CreatedDate',
			'LastModifiedDate',
			'Name__c',
            'Branding_CSS__c',
            'Branding_CSS_Class__c',
            'Branding_Custom_Font_CSS__c',
            'Branding_JSON__c',
            'Branding_Logo__c',
            'Created_By_People__c', 
            'Modified_By_People__c',
			'Segment_Attribute_Value_JSON__c',
			'Created_By_People__r.user__r.Id',
			'Created_By_People__r.First_Name__c', 
			'Created_By_People__r.Community_Nickname__c',
            'Created_By_People__r.Last_Name__c',
            'Created_By_People__r.Full_Name__c',
            'Created_By_People__r.user__r.SmallPhotoURL',
			'Created_By_People__r.Department__c',
			'Created_By_People__r.About__c',
			'Created_By_People__r.Title__c',
			'Created_By_People__r.City__c',
			'Created_By_People__r.State__c',
			'Created_By_People__r.Country__c',
			'Created_By_People__r.Email__c',
			'Created_By_People__r.Phone__c',
			'Created_By_People__r.mobile_phone__c',
			'Created_By_People__r.extension__c',
			'Created_By_People__r.Birth_Date__c',
			'Created_By_People__r.Joining_Date__c',
			'Created_By_People__r.Skype_Id__c', 
			'Created_By_People__r.Zoom_Id__c',
			'Created_By_People__r.User__c',
			'Created_By_People__r.User__r.isactive',	
			'Modified_By_People__r.user__r.Id',
			'Modified_By_People__r.First_Name__c', 
			'Modified_By_People__r.Community_Nickname__c',
            'Modified_By_People__r.Last_Name__c',
            'Modified_By_People__r.Full_Name__c',
            'Modified_By_People__r.user__r.SmallPhotoURL',
			'Modified_By_People__r.Department__c',
			'Modified_By_People__r.About__c',
			'Modified_By_People__r.Title__c',
			'Modified_By_People__r.City__c',
			'Modified_By_People__r.State__c',
			'Modified_By_People__r.Country__c',
			'Modified_By_People__r.Email__c',
			'Modified_By_People__r.Phone__c',
			'Modified_By_People__r.mobile_phone__c',
			'Modified_By_People__r.extension__c',
			'Modified_By_People__r.Birth_Date__c',
			'Modified_By_People__r.Joining_Date__c',
			'Modified_By_People__r.Skype_Id__c', 
			'Modified_By_People__r.Zoom_Id__c',
			'Modified_By_People__r.User__c',
			'Modified_By_People__r.User__r.isactive'					
        };
    }
    
}