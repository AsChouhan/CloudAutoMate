/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class MicrosoftTeamsDataServer extends DataServer{ 
	
	@TestVisible private final String REQUEST_PARAM_DATA = 'data';
	@TestVisible private final String ACTION_PROMOTE_TO_MICROSOFT_TEAMS = 'shareContent';
	@TestVisible private final String ACTION_GET_JOINED_MICROSOFT_TEAMS_CHANNELS = 'getJoinedChannels';
    @TestVisible private final String ACTION_GET_JOINED_MICROSOFT_TEAMS_TEAMS = 'getJoinedTeams';

    public MicrosoftTeamsDataServer() {

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
    		logger.logDebug('MicrosoftTeamsDataServer----entered handleRequest----');
            String action = readParam(REQUEST_PARAM_ACTION);
            String dataJSON = readParam(REQUEST_PARAM_DATA);
            
			if(ACTION_GET_JOINED_MICROSOFT_TEAMS_TEAMS.equalsIgnoreCase(action)) {
            	response = getJoinedTeams();		
            } else if(ACTION_GET_JOINED_MICROSOFT_TEAMS_CHANNELS.equalsIgnoreCase(action)) {
            	response = getJoinedChannels(readParam('data'));		
            } else if(ACTION_PROMOTE_TO_MICROSOFT_TEAMS.equalsIgnoreCase(action)) {
				response = shareContent(readParam('data'));
			} else { 
                throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            }
            
        } catch(Exception ex) {
            logger.logError('Either no page access or action parameter returning wrong data', ex);
       		response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
         }
    }  

	@TestVisible
    private ResponseWrapper getJoinedTeams(){
    	ResponseWrapper resultWrapper = new ResponseWrapper();
		try{
            if(SimpplrContext.microsoftTeamsIntegrationEnabled && SimpplrContext.isFeatureMicrosoftTeamsEnabled) {
               MicrosoftTeamsHelper MicrosoftTeamsHelperObj = new MicrosoftTeamsHelper();
               Map<String,Object> resultMap = MicrosoftTeamsHelperObj.getJoinedTeams();
               resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Joined Teams received successfully', resultMap);
            }
    	} catch(Exception e){
			logger.logError('MicrosoftTeamsDataServer.getJoinedTeams()----Exception occurred----' + e);
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR,MessageHelper.translateSFMessageToErrorCode(e), null);
		}
		return resultWrapper;
    }

    @TestVisible
    private ResponseWrapper getJoinedChannels(String requestData){
    	ResponseWrapper resultWrapper = new ResponseWrapper();
		try{
            Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
            String teamId = (String)requestDataMap.get('teamId');

            if(SimpplrContext.microsoftTeamsIntegrationEnabled && SimpplrContext.isFeatureMicrosoftTeamsEnabled) {
               MicrosoftTeamsHelper MicrosoftTeamsHelperObj = new MicrosoftTeamsHelper();
               Map<String,Object> resultMap = MicrosoftTeamsHelperObj.getJoinedChannels(teamId);
               resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Joined Channels received successfully', resultMap);
            }
    	} catch(Exception e){
			logger.logError('MicrosoftTeamsDataServer.getJoinedTeams()----Exception occurred----' + e);
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR,MessageHelper.translateSFMessageToErrorCode(e), null);
		}
		return resultWrapper;
    }

	@TestVisible
    private ResponseWrapper shareContent(String requestData){
    	ResponseWrapper resultWrapper = new ResponseWrapper();
    	try {
			Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
            String channelId = (String)requestDataMap.get('channelId');
			String contentUrl = (String)requestDataMap.get('contentUrl');
            String message = (String)requestDataMap.get('message');
            String teamId = (String)requestDataMap.get('teamId');

			contentUrl += '&utm_medium=microsoftteams&utm_source=microsoftteams';
            if(SimpplrContext.microsoftTeamsIntegrationEnabled && SimpplrContext.isFeatureMicrosoftTeamsEnabled) {
                MicrosoftTeamsHelper MicrosoftTeamsHelperObj = new MicrosoftTeamsHelper();
                ContentWrapper.ContentSiteFeedWrapper contentWrapper = new ContentWrapper.ContentSiteFeedWrapper();
                MicrosoftTeamsHelperObj.promoteContentToChannel(teamId, channelId, contentUrl, message, '','','',contentWrapper);
            }
            return resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Content published to Microsoft Teams successfully', null);
        
        } catch(Exception e) {
			logger.logError(e.getMessage());
			return resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
		}	
    }

}