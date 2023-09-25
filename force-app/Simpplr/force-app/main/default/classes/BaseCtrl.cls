/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
// TODO: AJAY - code refactoring needed.
public abstract with sharing class BaseCtrl{


	public Map<String, String> labelMap;
	
	public static String MESSAGE_TYPE_DANGER = 'danger';
	public static String MESSAGE_TYPE_SUCCESS = 'success';
	public static String MESSAGE_TYPE_INFO = 'info';
	public static String MESSAGE_TYPE_WARNING = 'warning';
	
	public String debugLogs {
		get{
			debugLogs = ''; 
			if(SimpplrContext.isDebugEnabled){
				debugLogs = JSON.serialize(logger.getLogs());
			}
			return debugLogs;
		}set;
	}
	
	public Boolean isMobileMode{get{
		isMobileMode = Utility.isMobileMode;
		return isMobileMode;
	}set;}
	
	public String refererPage { get{
			return ApexPages.currentPage().getHeaders().get('Referer');
	} set; }
	
	public String pageMessages{get{
		return MessageHelper.getMessageList(true);
	}set;}
	
	public String AppPageTitle{
		get {
			if(String.isNotBlank(SimpplrContext.applicationName)){
				return ' - ' + SimpplrContext.applicationName;
			}else{
				return '';
			}
		}
	}
	
	public String resourcePath {
		get {
			String packageName = String.isNotBlank(SimpplrContext.packageName) ? (SimpplrContext.packageName + '__') : '';
			return SimpplrContext.salesforceBaseUrl + '/resource/'+ packageName;
		}
	}

    public abstract String getPageFeature();
    
    /**
    **
    */
	public static Organization org{get{
    	if(org == null){
    		org = [SELECT InstanceName,isSandbox FROM Organization limit 1];
    	}
    	return org;
    }private set;}

    /**
    **
    */
    public static Boolean isSandbox{get{
    	if(isSandbox == null){
    		isSandbox = org.isSandbox;
    	}
    	return isSandbox;
    }private set;}
    
	/**
    **
    */
	public String currentPageUrl{get{
		return SimpplrContext.salesforceBaseUrl + ApexPages.currentPage().getUrl(); 
	}set;}

    /**
    **
    */
   	public static String instance{get{
        if (instance == null) {
            instance = org.InstanceName;    
            instance = instance.toLowerCase();      					
        } 
        return instance;
    }private set;}
    
    /**
    **
    */
	public static String salesforceHost{get{
		return 'https://' + instance + '.salesforce.com';
	}private set;}
	
    /**
    **
    */
    public static String simpplrBaseURL { get {
		return BaseCtrl.salesForceBaseUrl;
	}private set;}

    /**
    **
    */    
    public static String salesForceBaseUrl {set;get{
    	return SimpplrContext.salesforceBaseUrl ;
    }}

	/**
    **
    */
    public static String salesforceOrgDomainUrl {set;get{
    	return SimpplrContext.salesforceOrgDomainUrl ;
    }}

	/**
    **
    */    
    public static String salesForceContentUrl {set;get{
    	return SimpplrContext.salesforceBaseUrl.contains('.vf.force.com') ? SimpplrContext.salesforceBaseUrl.replace('.vf.force.com','.file.force.com'): SimpplrContext.salesforceBaseUrl;
    }}
    
    /**
    **
    */
    public BaseCtrl(){
		labelMap = LocaleContext.getLabelMap(PageContext.currentPageName, UserContext.languageLocaleKey);
    }
    
    /**
    **
    */
	public String readParam(String requestParamName){
		Map<String,String> params = ApexPages.currentPage().getParameters();
		return SIMPESAPI.encoder().SFDC_JSENCODE(params!=null?(params.containsKey(requestParamName) ? params.get(requestParamName) : null):null);
	}

	/**
    ** 
    */
	public PageReference handleAndTranslateException(PageReference returnPage, Exception e){
		PageReference returnPageRef = returnPage;
		logger.logDebug('handleAndTranslateException ' + e);
		String msgCode = MessageHelper.translateSFMessageToErrorCode(e);
		logger.logDebug('handleAndTranslateException msgCode = ' + msgCode);
		
	    // redirect to error page // else case is for showing error message on same page.
	    if(ExceptionCode.MISSING_SYSTEM_CONFIGURATION.name().equals(msgCode)){ 
		} else if(ServiceConstants.ERROR_404.equals(msgCode)){
			returnPageRef = new PageReference(PageContext.getPageURL(Pages.app + '?u=/error/404'));
			returnPageRef.setRedirect(true);
		} else if(ServiceConstants.ERROR_403.equals(msgCode)){
			returnPageRef = new PageReference(PageContext.getPageURL(Pages.app + '?u=/error/403'));
			returnPageRef.setRedirect(true);
		} else if(ExceptionCode.NO_ACCESS.name().equals(msgCode)){
		} else if(ExceptionCode.INCORRECT_USER_SETUP.name().equals(msgCode)){
		} else if(ExceptionCode.OPTION_DISABLED.name().equals(msgCode)){
		} else if(ExceptionCode.NO_SITE_ACCESS.name().equals(msgCode)){
		} else if(ExceptionCode.INVALID_TOPIC_ID.name().equals(msgCode)){
		} else if(ExceptionCode.INVALID_SITE_ID.name().equals(msgCode)){
		} else if(ExceptionCode.INVALID_USER_ID.name().equals(msgCode)){
		} else if(ExceptionCode.BOX_FILE_NOT_FOUND.name().equals(msgCode)){
		} else if(ExceptionCode.PERMISSION_SET_EXCEPTION.name().equals(msgCode)){
		} else if(ServiceConstants.ERROR_412.equals(msgCode)){
		} else if(ServiceConstants.ERROR_500.equals(msgCode)){
			returnPageRef = new PageReference(PageContext.getPageURL(Pages.app + '?u=/error/500'));
			returnPageRef.setRedirect(true);
		} else if(ServiceConstants.MIGRATION_ERROR.equals(msgCode)){
		} else {
			returnPageRef = null;
			logger.logError(e); // logging errors for unknown messages.
			// message will display on same page.
			MessageHelper.addErrorMessage(msgCode);
		}
		return returnPageRef;
	}
	
	/**
    **
    */
	public String prepareMessage(String messageType, String message){
		JSONGenerator messageJson = JSON.createGenerator(false);
		messageJson.writeStartObject();
		messageJson.writeStringField('type', messageType);
        messageJson.writeStringField('message', message);
		messageJson.writeEndObject();
		return messageJson.getAsString();
	}
}