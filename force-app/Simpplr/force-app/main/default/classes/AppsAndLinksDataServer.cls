/**
 * @description AppsAndLinksDataServer
 */
public with sharing class AppsAndLinksDataServer extends DataServer{
    @Testvisible private final String REQUEST_PARAM_DATA = 'data';

    @Testvisible private final String ACTION_VALUE_GET = 'get';
    @Testvisible private final String ACTION_VALUE_SAVE = 'save';
    
    /**
     * @description getPageFeature - returns page feature
     * @return FEATURE_SIMPPLR
     */
    public String getPageFeature() {
        return AccessManager.FEATURE_SIMPPLR;
    }
    
    /**
     * @description handleRequest - to handle requests via API
     */
    public override void handleRequest() {
        try{
            logger.logDebug('AppsAndLinksDataServer----entered handleRequest----');
            String action = readParam(REQUEST_PARAM_ACTION);
            if(String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
            }
            
            if(ACTION_VALUE_GET.equalsIgnoreCase(action)) {
                response = getAppsAndLinksData(readParam('segmentId'));
            } else if(ACTION_VALUE_SAVE.equalsIgnoreCase(action)) {
                response = saveAppsAndLinksData(readParam('data'), readParam('segmentId'));
            } else {
                throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            }
        }catch(Exception ex) {
            logger.logError('Either no page access or action parameter returning wrong data',ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR,MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
    }

    /**
     * @description getAppsAndLinksData
     * @param segmentId
     * @return ResponseWrapper
     */
    private ResponseWrapper getAppsAndLinksData(String segmentId) {
        logger.logDebug('AppsAndLinksDataServer.getAppsAndLinksData()----segmentId----'+segmentId);
        ResponseWrapper responseWrapperObj = null;
        try {
            Boolean useSegmentAppsNLinks = SimpplrContext.isSegmentsEnabled && SimpplrContext.isSegmentAppsNLinksEnabled;
			Sobject launchpadSobject;
            String namespacePrefix = SimpplrContext.namespacePrefix;
			if(useSegmentAppsNLinks) {
				launchpadSobject = getSegment(segmentId);
			} else {
                String appConfigQuery = 'SELECT Id, SSO_Custom_JSON__c, SSO_Provider__c, Custom_Links_JSON__c'
                    + ' FROM App_Config__c LIMIT 1';
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                launchpadSobject = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];
            }

            LaunchpadWrapper resultWrapper = new LaunchpadWrapper();
            resultWrapper.appsIntegrationProvider = (String)launchpadSobject.get(namespacePrefix + 'SSO_Provider__c');
            resultWrapper.customJson = (String)launchpadSobject.get(namespacePrefix + 'SSO_Custom_JSON__c');
            resultWrapper.externalLinks = new List<LaunchpadWrapper.LinkWrapper>();
            if (String.isNotBlank((String)launchpadSobject.get(namespacePrefix + 'Custom_Links_JSON__c'))) {
                resultWrapper.externalLinks = (List<LaunchpadWrapper.LinkWrapper>)JSON.deserialize((String)launchpadSobject.get(namespacePrefix + 'Custom_Links_JSON__c'), List<LaunchpadWrapper.LinkWrapper>.Class);
                resultWrapper.externalLinks.sort();
            }
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, resultWrapper);

        } catch(Exception e) {
            logger.logError('AppsAndLinksDataServer----could not get launchpad configurations', e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        logger.logDebug('AppsAndLinksDataServer.getAppsAndLinksData()----responseWrapperObj----' + responseWrapperObj);
        return responseWrapperObj;
    }

    /**
     * @description getSegment
     * @param segmentId
     * @return Segment
     */
    private Segment__c getSegment(String segmentId) {
		segmentId = String.isNotBlank(segmentId) ? segmentId : UserContext.getCurrentUserInfo.Segment__c;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', segmentId);
		String query = 'Select Id, SSO_Provider__c, Custom_Links_JSON__c, SSO_Custom_JSON__c from Segment__c Where Id = :soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Segment__c> segmentList = (List<Segment__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		return segmentList[0];
    }

    /**
     * @description saveAppsAndLinksData
     * @param requestData
     * @param segmentId
     * @return ResponseWrapper
     */
    private ResponseWrapper saveAppsAndLinksData(String requestData, String segmentId) {
        logger.logDebug('AppsAndLinksDataServer.saveLaunchpadData()----requestData----'+requestData);
        ResponseWrapper responseWrapperObj = null;
        try {
            LaunchpadWrapper launchpadObj = (LaunchpadWrapper)JSON.deserialize(requestData, LaunchpadWrapper.class);
            Boolean useSegmentAppsNLinks = SimpplrContext.isSegmentsEnabled && SimpplrContext.isSegmentAppsNLinksEnabled;
			if(useSegmentAppsNLinks) {
				Segment__c segmentObj = getSegment(segmentId);
                segmentId = segmentObj.Id;
                segmentObj.SSO_Provider__c = launchpadObj.appsIntegrationProvider;
                segmentObj.SSO_Custom_JSON__c = launchpadObj.customJson;
                segmentObj.Custom_Links_JSON__c = launchpadObj.externalLinks != null ? JSON.serialize(launchpadObj.externalLinks) : null;
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                SIMPESAPI.accessController().updateAsUser(segmentObj, new List<Schema.SObjectField>{
                    Segment__c.SSO_Provider__c,
                    Segment__c.SSO_Custom_JSON__c,
                    Segment__c.Custom_Links_JSON__c
                });
			} else {
                App_Config__c appConfigObj = new App_Config__c(Id = SimpplrContext.appConfig.Id);
                appConfigObj.SSO_Provider__c = launchpadObj.appsIntegrationProvider;
                appConfigObj.SSO_Custom_JSON__c = launchpadObj.customJson;
                appConfigObj.Custom_Links_JSON__c = launchpadObj.externalLinks != null ? JSON.serialize(launchpadObj.externalLinks) : null;
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                SIMPESAPI.accessController().updateAsUser(appConfigObj, new List<Schema.SObjectField>{
                    App_Config__c.SSO_Provider__c,
                    App_Config__c.SSO_Custom_JSON__c,
                    App_Config__c.Custom_Links_JSON__c
                });
            }
            External_Search_Data_Trail__c obj = new External_Search_Data_Trail__c();
            obj.Type__c = 'Links';
            obj.Segment__c = useSegmentAppsNLinks ? segmentId : null;
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().insertAsUser(obj, new List<Schema.SObjectField>{
                External_Search_Data_Trail__c.Type__c,
                External_Search_Data_Trail__c.Segment__c
            });

            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, launchpadObj);

        } catch(Exception e) {
            logger.logError('AppsAndLinksDataServer----could not get launchpad configurations', e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        logger.logDebug('AppsAndLinksDataServer.getAppsAndLinksData()----responseWrapperObj----' + responseWrapperObj);
        return responseWrapperObj;
    }
}