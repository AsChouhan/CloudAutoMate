public with sharing class MessageHelper {
	
	private static List<Message> messageList = new List<Message>();
	
	public class Message{
		String type{get;set;}
		String message{get;set;}
		Boolean sticky{get;set;}
		
		public Message(String typ, String msg, Boolean isSticky){
			type = typ;
			message = msg;
			sticky = isSticky;
		}
	}
	
	public static void refreshMessage(){
		messageList = new List<Message>();
		ApexPages.getMessages().clear();
	}
	
	public static String getMessageList(Boolean deleteExisting){
		String returnValue = JSON.serializePretty(messageList);
		if(deleteExisting!=null && deleteExisting){
			messageList = new List<Message>();
		}
		return returnValue;
	}

	public static void showError(String msg){

	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public static String getMessageCodeList(){
		String returnList = ServiceConstants.SF_EXCEPTION;
		for(ApexPages.Message msg :ApexPages.getMessages()){
			returnList += msg.getSummary();
		}
		return returnList;
	}

	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public static void loadMessages(List<String> msgList){
		for(String msg :msgList){
			addConfirmMessage(msg, false);
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
	public static void loadErrorMessages(List<String> msgList){
		for(String msg :msgList){
			addErrorMessage(msg, false);
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
	public static void addConfirmMessage(String confirmMsg, Boolean isSticky){
		Message newMsg = new Message('success',resolveMessage(confirmMsg), isSticky);
		messageList.add(newMsg);
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public static void addInfoMessage(String infoMsg, Boolean isSticky){
		Message newMsg = new Message('info',resolveMessage(infoMsg), isSticky);
		messageList.add(newMsg);
	}

	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public static void addWarningMesssage(String warnMsg, Boolean isSticky){
		Message newMsg = new Message('warning',resolveMessage(warnMsg), isSticky);
		messageList.add(newMsg);
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public static void addErrorMessage(String errMsg, Boolean isSticky){
		Message newMsg = new Message('danger',resolveMessage(errMsg), isSticky);
		messageList.add(newMsg);
	}
	
	public static void addErrorMessage(String errMsg){
		addErrorMessage(errMsg, false);
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public static void logError(String errMsg){
		logger.logError(errMsg);
	}

	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public static void logError(String errMsg, Exception ex){
		logger.logError(errMsg, ex);
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public static void logAndShowError(String errMsg, Exception ex){
		if(SimpplrContext.isDebugEnabled) {
			Long errorCode = System.currentTimeMillis();
			if(SimpplrContext.isUIStackTraceEnabled) {
				addErrorMessage('System exception occurred - ' + errorCode + ' - ' + errMsg + 
						  '<br/>Error cause - ' + ex.getCause() + 
						  '<br/>Error Message - ' + ex.getMessage() + 
						  '<br/>Error stack trace - ' + ex.getStackTraceString(), false);
			} else {
				addErrorMessage('System exception occurred - ' + errorCode + ' - ' + errMsg, false);
			}
		} else {
			addErrorMessage(errMsg, false);
		}
	}
	
	/**
	* Map hold text values for ExceptionCode enum.
	*
	*/
	private static Map<String, String> messageMap = new Map<String, String>{
		'LINKED_FOLDER_LIMIT_EXCEEDED_FOR_ORG' => 'org folder limit exceeded',
		'LINKED_FOLDER_LIMIT_EXCEEDED_FOR_SITE' => 'site folder limit exceeded',

		'FOLDER_ALREADY_LINKED_FOR_SITE' => 'Folder is already linked',
		
	    'MISSING_REQUIRED_PARAM' => 'Missing required parameters',
	    'MISSING_ACTION_PARAM' => 'Missing action parameter',
	    'UNKNOWN_ACTION_PARAM' => 'Action paramater not supported',
	    'CAN_NOT_ADD_YOURSELF_AS_MANAGER' => 'You cannot add yourself as manager',
	    
	    'INVALID_FILTER_DATA' => 'Requested filter data is invalid',
	    'INVALID_PARAMETER' => 'INVALID_PARAMETER',
	    'INVALID_REQUEST_PARAM_VALUE' => 'Request parameter value is invalid',
	    'INVALID_SEARCH_TERM' => 'Please enter valid search string',
	    'INVALID_SITE_ID' => 'Invalid site id',
	    'INVALID_USER_ID' => 'Invalid user id',
	    'INVALID_REQUEST_DATA' => 'Request data is invalid',
	    'INVALID_STRING_FOR_REMOVING_HASHTAG' => ' Please pass valid String for removing hash. Passed String is: ',
	    'INVALID_MAX_LENGTH' => 'Please pass valid max length',
	    'INVALID_STRING' => 'Please pass a valid string',
	    'INVALID_VIDEO_ID' => 'Invalid Video URL',
	    'INSUFFICIENT_ACCESS_OR_READONLY' => 'You do not have the required privileges to make these changes',
	    'SITE_CONTEXT_NOT_AVAILABLE' => 'SiteContext object not available for operation',
	    'NO_SITE_ACCESS' => 'Access to this site is restricted. Please contact Site owner',
	    'NO_ACCESS' => 'You do not have access to the requested page. Please contact your App Manager',
	    'OPERATION_ON_INACTIVE_USER_CONTENT' => 'Could not make changes - please transfer Site ownership first',
	    
	    'EMPTY_PUBLISH_START_DATE' => 'Publish start date can not be empty',
	    
	    'USER_NOT_CONNECTED_TO_BOX' => 'Box account is not connected for current user',
	    'USER_NOT_CONNECTED_TO_GOOGLE_DRIVE' => 'You must connect your account to view Google Drive files within "' + SimpplrContext.applicationName + '"',
	    'BOX_EXCEPTION_GET_FOLDER' => 'Exception occurred while trying to get Box folders',
	    'BOX_CONNECTION_FAILED_WITH_STATUS' => 'Failed to connect to Box, status code returned is ',
	    'BOX_CANNOT_GET_USER_DETAILS' => 'Failed to get user details from Box ',
	    'BOX_FILE_NOT_FOUND' => 'File you are trying to access is no longer available or you don\'t have access to this file',
	    
	    'CANNOT_ADD_ENDORSEMENT_INACTIVE_USER' => 'Endorsement cannot be added for inactive user',
	    'CANNOT_REMOVE_ENDORSEMENT_INACTIVE_USER' => 'Endorsement cannot be removed for inactive user',
	
	    'NULL_TYPE_OBJECT_ID' => ' Object Id should not be null',
	    'NULL_TYPE_OBJECT_TYPE' => ' Object Type should not be null',
	    'NULL_SOBJECT' => 'Object can\'t be null',
	    
	    'ERROR_SITE_CREATION' => 'Could not create the site',
	    'SETUP_PROCESS_STARTED' => 'Setup process has already been initiated',
	    
	    'NO_CREATE_TOPIC_PERMISSION' => 'You don\'t have permission to create new topic',
	    'TOPIC_SPACING_N_CAPITALIZATION_ALLOWED' => 'Could not edit Topic - Only character spacing and capitalization allowed',
		
		'NO_CREATE_EXPERTISE_PERMISSION' => 'You don\'t have permission to create new Expertise',
	    'EXPERTISE_SPACING_N_CAPITALIZATION_ALLOWED' => 'Could not edit Expertise - Only character spacing and capitalization allowed',
	    
	    'EVENT_USER_ALREADY_INVITED' => 'This Person has already been invited',
	    'EVENT_CANNOT_INVITE_SELF' => 'One can not invite himself to an event',
	    'PERMISSION_SET_EXCEPTION' => 'You do not have required permission to access Simpplr, please contact your administrator',
	    'VIDEO_INTEGRATION_NOT_CONFIGURED' => 'Video Integration not configured',
	    'DATA_VALUE_TOO_LARGE' => 'Character length exceeded',
    	'EVENT_STATUS_UNPUBLISHED' => 'Event is unpublished',
    	'EVENT_IS_DELETED' => 'Could not invite more People - Event no longer exists'
	};

    /**
	* method search messagekey in map if not found then return same
	*/
	public static String resolveMessage(String messageKey){
    	return messageMap.containsKey(messageKey) ? messageMap.get(messageKey) : messageKey;
	}
	
	public static String translateSFMessageToErrorCode(Exception e){
		String messageKey = e.getMessage();
		
		String simpplrErrorCode = null;
		
		if (messageKey.containsIgnoreCase('STRING_TOO_LONG')) {
			simpplrErrorCode = 'DATA_VALUE_TOO_LARGE';
			
		} else if (messageKey.containsIgnoreCase('Given final block not properly padded')) {
			simpplrErrorCode = ServiceConstants.ERROR_412;
			
		} else if (messageKey.containsIgnoreCase('Insufficient Privileges')) {
		 	simpplrErrorCode = ServiceConstants.ERROR_403;
		 	
		} else if (messageKey.containsIgnoreCase('This link is invalid')) {
			simpplrErrorCode = 'Could not create Post - Link URL invalid';
			
		}
		
		if(simpplrErrorCode == null && (e instanceof SimpplrException) == false){
			Map<String, String> sfExceptionMessageMap = new Map<String, String>();
			sfExceptionMessageMap.put('AsyncException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('CalloutException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('DmlException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('EmailException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('ExternalObjectException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('InvalidParameterValueException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('LimitException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('JSONException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('ListException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('MathException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('NoAccessException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('NoDataFoundException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('NoSuchElementException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('NullPointerException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('QueryException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('RequiredFeatureMissing',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('SearchException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('SecurityException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('SerializationException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('SObjectException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('StringException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('TypeException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('VisualforceException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('XmlException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('Canvas.CanvasRenderException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('ConnectApi.ConnectApiException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('ConnectApi.NotFoundException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('ConnectApi.RateLimitException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('DataSource.​DataSource​Exception',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('DataSource.OAuthTokenExpiredException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('Reports.FeatureNotSupportedException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('Reports.InstanceAccessException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('Reports.InvalidFilterException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('Reports.InvalidReportMetadataException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('Reports.InvalidSnapshotDateException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('Reports.MetadataException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('Reports.ReportRunException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('Reports.UnsupportedOperationException',ServiceConstants.SF_EXCEPTION);
			sfExceptionMessageMap.put('Site.ExternalUserCreateException',ServiceConstants.SF_EXCEPTION);
			
			simpplrErrorCode = sfExceptionMessageMap.get(e.getTypeName());
			if(simpplrErrorCode == null) {
				simpplrErrorCode = sfExceptionMessageMap.get(e.getTypeName().removeStart('System.'));
			}
		}
		
		if(simpplrErrorCode == null){
			simpplrErrorCode = messageKey;
		}
    	return simpplrErrorCode;
	}
		
	public static void showConfirm(String confirmMsg){
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, confirmMsg));
	}
	
	public static void showWarning(String warnMsg){
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, warnMsg));
	}
	
	public static void refreshMesage(){
		ApexPages.getMessages().clear();
	}
    
    public static void showInfo(String infoMsg){
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, infoMsg));
	}
	
}