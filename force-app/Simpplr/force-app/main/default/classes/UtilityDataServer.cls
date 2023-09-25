/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class UtilityDataServer extends DataServer{ 
	
	private final String REQUEST_PARAM_DATA = 'data';
	
	private final String ACTION_GET_SALESFORCE_BASE_URL = 'getSalesforceBaseUrl';
	private final String ACTION_SUGGEST_TOPICS = 'suggestTopics';
	private final string ACTION_GET_BRANDING_CSS = 'getBrandingCSS';
	private final string ACTION_GET_CUSTOM_FONT_CSS = 'getCustomFontCSS';
	private final string ACTION_SEND_FEEDBACK_EMAIL = 'sendFeedBackEmail';
	private final string ACTION_GET_SCHEDULING_SLOTS = 'getSchedulingSlots';
    
	private final string ACTION_GET_CUSTOMIZATIONS_VALUES = 'getValues';
	private final string ACTION_SAVE_CUSTOMIZATIONS_VALUES = 'saveCustomizations';
	private final string ACTION_REFRESH_CUSTOMIZATIONS_VALUES = 'refreshCustomizations';
	private final String ACTION_GET_REQUEST_TOKEN = 'getDRI';
	private final string ACTION_GET_APP_CONFIG = 'getAppConfig';
	private final string ACTION_GET_CURRENT_USER_SETTINGS = 'getCurrentUserSettings';
	private final string ACTION_GET_DEFERRED_APP_CONFIG = 'getDeferredAppConfig';
	private final string ACTION_GET_PROFILE_FIELDS = 'getProfileFields';
	private final String ACTION_VALUE_GET_FROM_ADDRESSES = 'getFromAddresses';
	private final string ACTION_GET_SECURITY_TOKEN = 'getSecurityToken';
	private final string ACTION_DELETE_DISMISSIBLE_FLASHES = 'deleteDismissibleFlashes';
	private static final String FEEDBACK_TOEMAIL_SHARE_WITH_SIMPPLR_ADDRESS = 'product.feedback@simpplr.com';
	private static final String FEEDBACK_DEFAULT_SUBJECT = 'User feedback for ';
	private static final String EMBEDLY_OEMBED = 'oembed';
	private final string ACTION_GET_LISTENER_SUITE_JWT = 'getListenerSuiteJwt';
	private final String ACTION_GET_JWT_TOKEN = 'getJWTToken';
	private final String ACTION_GET_AVAILABLE_TIMEZONES = 'getAvailableTimezones';
	private final String ACTION_GET_SSJWT_TOKEN = 'getSSJWTToken';
	private final String ACTION_RESET_CDC_RETRY_COUNT = 'resetCDCRetryCount';
	private final String ACTION_RESET_CACHE = 'resetCache';
	
	private String packageName;
	private String resourcePath;
	private String defaultFontCSS;
	public String brandingCssString{get;set;}
	/**
	 * 
	 * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	 * Parameters:
	 * parameter_name -- [Explanation of the purpose of this parameter to the method.
	 *	  
	 * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public UtilityDataServer() {
		featureFlagList = new List<String> {
			'ga4_integration','zu_odin_manageapp_campaign'
		};
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
		try{
			logger.logDebug('UtilityDataServer----entered handleRequest----');

			packageName = String.isNotBlank(SimpplrContext.packageName) ? (SimpplrContext.packageName + '__') : '';
			resourcePath = SimpplrContext.salesforceBaseUrl + '/resource/'+ packageName;
			
			defaultFontCSS = '';
			
			if (String.isNotBlank(SimpplrContext.PackageName)) {
				defaultFontCSS = resourcePath + 'font_min_css';
			
			} else {
				defaultFontCSS = resourcePath + 'font_min_css_dev';
			}

			String action = readParam(REQUEST_PARAM_ACTION);
				
			if (String.isBlank(action)) {
				throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
			
			} else {
				
				if (ACTION_GET_BRANDING_CSS.equalsIgnoreCase(action)) {
					getBrandingCss();
					
				} else if(ACTION_GET_CUSTOM_FONT_CSS.equalsIgnoreCase(action)) {
			   		getCustomFontCSS();

				} else if(ACTION_GET_APP_CONFIG.equalsIgnoreCase(action)) {
			   		response = getAppConfig();

				}else if(ACTION_GET_CURRENT_USER_SETTINGS.equalsIgnoreCase(action)){
					response = getCurrentUserSettings();
					
				} else if(ACTION_GET_DEFERRED_APP_CONFIG.equalsIgnoreCase(action)) {
					response = getDeferredAppConfig();

				} else if(ACTION_GET_PROFILE_FIELDS.equalsIgnoreCase(action)) {
			   		response = getProfileFields();

				} else if(ACTION_SEND_FEEDBACK_EMAIL.equalsIgnoreCase(action)) {
					   response = sendFeedBackEmail(readParam(REQUEST_PARAM_DATA));
					   
				} else if(ACTION_GET_SCHEDULING_SLOTS.equalsIgnoreCase(action)) {
					response = getSchedulingSlots();
				
				}  else if(ACTION_GET_CUSTOMIZATIONS_VALUES.equalsIgnoreCase(action)) {
			   		response = getCustomizationValues(readParam('segmentId'));
				
				} else if(ACTION_SAVE_CUSTOMIZATIONS_VALUES.equalsIgnoreCase(action)) {
			   		saveCustomizationValues();
				
				} else if(ACTION_REFRESH_CUSTOMIZATIONS_VALUES.equalsIgnoreCase(action)) {
					saveCustomizationValues();
				

				} else if(ACTION_GET_SALESFORCE_BASE_URL.equalsIgnoreCase(action)){
					response = getSalesforceBaseUrl();
				
				} else if(ACTION_SUGGEST_TOPICS.equalsIgnoreCase(action)){
					response = suggestTopics(readParam(REQUEST_PARAM_DATA));

				} else if(EMBEDLY_OEMBED.equalsIgnoreCase(action)){
					response = getEmbedlyResponse(readParam(REQUEST_PARAM_DATA));
					
				} else if (ACTION_GET_REQUEST_TOKEN.equalsIgnoreCase(action)) {
					response = getRequestToken();
					
				} else if (ACTION_GET_SECURITY_TOKEN.equalsIgnoreCase(action)) {
					response = getSecurityToken();
					
				} else if(ACTION_VALUE_GET_FROM_ADDRESSES.equalsIgnoreCase(action)){
                    response = getFromAddresses();
                    
				} else if(ACTION_DELETE_DISMISSIBLE_FLASHES.equalsIgnoreCase(action)){
                    response = deleteDismissibleFlashes(readParam(REQUEST_PARAM_DATA));
                    
				} else if(ACTION_GET_LISTENER_SUITE_JWT.equalsIgnoreCase(action)){
					response = getListenerSuiteJwt();               
				
				} else if(ACTION_GET_JWT_TOKEN.equalsIgnoreCase(action)){
					response = getJWTToken();               
				
				} else if(ACTION_GET_AVAILABLE_TIMEZONES.equalsIgnoreCase(action)){
					response = getAvailableTimezones();               

				} else if(ACTION_GET_SSJWT_TOKEN.equalsIgnoreCase(action)){
					response = getSSJWTToken();               
				
				} else if(ACTION_RESET_CDC_RETRY_COUNT.equalsIgnoreCase(action)){
					response = resetCDCRetryCount();               

				} else if(ACTION_RESET_CACHE.equalsIgnoreCase(action)){
					clearPartitionCache();
				} else {
					throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
				}
			}
			
		}catch(Exception ex) {
			logger.logError('Either no page access or action parameter returning wrong data',ex);
			response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
		}
		
	}
	
	@testVisible 
	private ResponseWrapper getSalesforceBaseUrl(){
		logger.logDebug('----getSalesforceBaseUrl---');
		ResponseWrapper responseWrapperObj = new ResponseWrapper();
		try{
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, Url.getSalesforceBaseUrl().toExternalForm());
		}catch(Exception e){
			logger.logError('Could not retrieve salesforce base url',e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		logger.logDebug('UtilityDataServer.getSalesforceBaseUrl()----responseWrapperObj----'+responseWrapperObj);
		return responseWrapperObj;
	}
	
	public ResponseWrapper getEmbedlyResponse (String urlArg) {
		logger.logDebug('UtilityDataServer.getEmbedlyResponse()----urlArg----'+urlArg);
		ResponseWrapper responseWrapperObj = new ResponseWrapper();
		try {
			if(SimpplrContext.EmbedlyEnabled && String.isNotBlank(SimpplrContext.EmbedlyAPIKey)) {
				String jsonResult;
				HttpRequest req = new HttpRequest();
				Map<String,Object> requestMap= (Map<String,Object>)JSON.deserializeUntyped(urlArg);
				Boolean autoplay = (requestMap!=null && requestMap.containsKey('autoplay')) ? (Boolean)requestMap.get('autoplay'):false;
				String url = (String)requestMap.get('url');
				if(autoplay){
					if(url.contains('?')){
						url = url + '&autoplay=true';
					}else{
						url = url + '?autoplay=true';
					}
				}
				Map<String,String> requestBody = new Map<String,String>();
				requestBody.put('url', url);
				requestBody.put('Authorization', Utility.externalRequestAuthToken());
				req.setEndpoint('https://api.simpplr.com/oembedparser'); 
				req.setBody(json.serialize(requestBody));
				req.setMethod('POST');		  
								
			 	Http http = new Http();
			 	HTTPResponse res = http.send(req);
			 	if (res.getStatusCode() == 200) {
                    Map<String,Object> responseRequestMap= (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
                    String htmlStr ;
                    if(responseRequestMap.get('html') != null){
                        htmlStr = String.valueOf(responseRequestMap.get('html'));
                        String sanitizedHtml;
                        
                        if (htmlStr.containsIgnoreCase('<iframe')) {
                            String iframeStr = '';
                            Pattern myPattern = Pattern.compile('(?:<iframe[^>]*)(?:(?:\\/>)|(?:>.*?<\\/iframe>))');
                            Matcher myMatcher = myPattern.matcher(htmlStr);
                            
                            while (myMatcher.find()) {
                                iframeStr += myMatcher.group(0);
                            }
                            
                            sanitizedHtml = Utility.getSanitizedHTMLfromLambda(iframeStr);
                        }                       
                        responseRequestMap.put('html',sanitizedHtml);
                    }
                    responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, responseRequestMap);
                
                } else {
			 		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
			 	}
			 		
			} else {
				logger.logError('UtilityDataServer.getEmbedlyResponse()----Embedly response not setup----');
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
			}
		} catch (Exception e) {
			logger.logError('UtilityDataServer.getEmbedlyResponse()----could not fetch Embedly Response----',e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}

		return responseWrapperObj;
	}
	

	private ResponseWrapper getSchedulingSlots() {
		logger.logDebug('UtilityDataServer.getSchedulingSlots()');
		ResponseWrapper responseWrapperObj = new ResponseWrapper();
		List<LabelValueData> dataList = new List<LabelValueData>();

		//CONT-10438
		
		// String soql = 'select ';
		// if (Schema.sObjectType.CronTrigger.fields.nextfiretime.isAccessible()){
		// 	soql += 'nextfiretime';
		// }
		// soql += ' from CronTrigger where CronJobDetail.JobType = \'7\' and cronjobdetail.name = \'SchedulerHourlySimpplrServices\'';
		// System.debug('-----soql--'+soql);

		// List<CronTrigger> cronTriggerList = (List<CronTrigger>)SIMPESAPI.accessController().queryAsUser(soql, null);
		// System.debug('-----cronTriggerList query--'+cronTriggerList);

		//CONT-10438
		
		List<CronTrigger> cronTriggerStr = [select nextfiretime FROM CronTrigger WHERE CronJobDetail.JobType = '7' and cronjobdetail.name = 'SchedulerHourlySimpplrServices'];
		SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, cronTriggerStr);
	   	List<CronTrigger> cronTriggerList = decision.getRecords();
		//List<CronTrigger> cronTriggerList = [select nextfiretime FROM CronTrigger WHERE CronJobDetail.JobType = '7' and cronjobdetail.name = 'SchedulerHourlySimpplrServices' WITH SECURITY_ENFORCED];
		if(!cronTriggerList.isEmpty()) {
			Integer minutes = cronTriggerList[0].nextfiretime.minute();
			DateTime dateTimeObj;
			for(Integer i=0; i<24; i++) {
				dateTimeObj = DateTime.newInstance(1,1,1900, i, minutes, 0);
				LabelValueData dataObj = new LabelValueData();
				dataObj.label = dateTimeObj.format('h:mm a');
				dataObj.value = dateTimeObj.format('HH:mm');
				dataList.add(dataObj);
			}
		}
		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, dataList);
		return responseWrapperObj;
	}
	@testVisible 
	private ResponseWrapper sendFeedBackEmail(String requestData) {
		logger.logDebug('UtilityDataServer.sendFeedBackEmail()----requestData----' + requestData);
		Criteria.FeedbackParams feedbackCriteriaObj = (Criteria.FeedbackParams)JSON.deserialize(requestData, Criteria.FeedbackParams.class);
		feedbackCriteriaObj.feedbackMsg = feedbackCriteriaObj.feedbackMsg.replaceAll('<','&lt;');
		feedbackCriteriaObj.feedbackMsg = feedbackCriteriaObj.feedbackMsg.replaceAll('>','&gt;');
		
		if (String.isBlank(feedbackCriteriaObj.feedbackMsg)) {
			throw new SimpplrException(ExceptionCode.MISSING_EMAIL_BODY.name());
        }
        
		ResponseWrapper responseWrapperObj = new ResponseWrapper();
        
        try { 
 
            //Check if the value is changed on UI
            if (UserContext.emailProductResearch != feedbackCriteriaObj.emailProductResearch) {
                NotificationDispatcher notifObj = new NotificationDispatcher();
                List<People_Preference__c> listOfPeoplePref = [SELECT id, 
                        Email_Product_Research__c, People__c
                        FROM People_Preference__c 
                        WHERE People__c=:UserContext.peopleId WITH SECURITY_ENFORCED];

                // If user choose for product research 
                if (feedbackCriteriaObj.emailProductResearch == true) {
                    notifObj.addContactToSendInBlue();
                    listOfPeoplePref[0].Email_Product_Research__c = true; 
                    update listOfPeoplePref[0];

                // If user don't want to participate in product research
                } else {
                    notifObj.removeContactFromSendInBlue();
                    listOfPeoplePref[0].Email_Product_Research__c = false; 
                    update listOfPeoplePref[0];
                }
                
            }

			String emailSubject = FEEDBACK_DEFAULT_SUBJECT + SimpplrContext.applicationName;
			
			String toEmails = SimpplrContext.feedbackToEmails;
			toEmails = (toEmails.endsWith(','))? toEmails.subString(0, toEmails.length() -1) : toEmails;
			
			if(SimpplrContext.feedbackShareWithSimpplr) {
				if(String.isNotBlank(toEmails) && String.isNotBlank(FEEDBACK_TOEMAIL_SHARE_WITH_SIMPPLR_ADDRESS)) {
					toEmails += ',';
				}
				toEmails += FEEDBACK_TOEMAIL_SHARE_WITH_SIMPPLR_ADDRESS;
			}
			
			if(String.isNotBlank(toEmails)) {
				List<String> toEmailList = toEmails.split(',');
				List <Messaging.SingleEmailMessage> emailObjList = new List <Messaging.SingleEmailMessage>();
				
				for(String toEmail : toEmailList) {
					String emailText = getFeedbackEmailBody(toEmail, feedbackCriteriaObj.feedbackMsg.replace('\\n', '<BR/>'), feedbackCriteriaObj.pageUrl, feedbackCriteriaObj.pageTitle, feedbackCriteriaObj.helpTopics);
					Messaging.SingleEmailMessage emailObject = EmailUtility.getSingleEmailMessageObject(emailText, emailSubject,  toEmail, UserInfo.getUserEmail());
					emailObjList.add(emailObject);
				}
				
				Messaging.sendEmail(emailObjList);

				List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
				Feedback__c feedbackObj = new Feedback__c();

				feedbackObj.Message__c = feedbackCriteriaObj.feedbackMsg;
				feedbackObj.Page_Title__c = feedbackCriteriaObj.pageTitle;
				feedbackObj.Page_URL__c = feedbackCriteriaObj.pageUrl;
				feedbackObj.People__c = UserContext.peopleId;
				feedbackObj.Type__c = feedbackCriteriaObj.helpTopics;

				fieldList.add(Feedback__c.Message__c);
				fieldList.add(Feedback__c.Page_Title__c);
				fieldList.add(Feedback__c.Page_URL__c);
				fieldList.add(Feedback__c.People__c);
				fieldList.add(Feedback__c.Type__c);
				
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().insertAsUser(feedbackObj, fieldList);

				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, feedbackCriteriaObj);
			}
			else {
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, feedbackCriteriaObj);
            }

            
		}catch(Exception e){
			logger.logError('UtilityDataServer.sendFeedBackEmail()-----Exception occured',e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return responseWrapperObj;
	}
	
	@testVisible 
	private String getFeedbackEmailBody(String toEmails, String emailText, String pageUrl, String pageTitle, String helpTopic) {
		String targetUserFirstName = '';
		String targetUserLastName = '';
		
		if(emailText.startsWith('"')) {
			emailText = emailText.subString(1, emailText.length());
		}
		if(emailText.endsWith('"')) {
			emailText = emailText.subString(0, emailText.length() - 1);
		}
		
		List<String> formatterList = new List<String>();
		
		String profileDisplayIcon = '';
		String heading = UserContext.firstName;

		if('other'.equalsIgnoreCase(helpTopic)){
			heading += ' has provided feedback';
		
		} else if('report_problem'.equalsIgnoreCase(helpTopic)){
			heading += ' has reported a problem';
		
		} else if('give_suggestion'.equalsIgnoreCase(helpTopic)){
			heading += ' has given a suggestion';
		
		} else if('ask_question'.equalsIgnoreCase(helpTopic)){
			heading += ' has asked a question';
		
		} else if('rating_feedback'.equalsIgnoreCase(helpTopic)){
			heading += ' has provided a feedback through mobile';

		}

		String externalPhotoUrl = UserContext.externalPhotoUrl;
		DateTime externalPhotoUrlExpiryDate = UserContext.externalPhotoUrlExpiryDate;
		
		NotificationHelper.BrandingInfo brandingInfo = new NotificationHelper.BrandingInfo();
		
		People__c peopleObj = UserContext.getCurrentUserInfo;
		brandingInfo = EmailUtility.getBrandingInfo4People(peopleObj);
		
		String segmentInfo = '';
		
		if(SimpplrContext.isSegmentsEnabled) {
			segmentInfo = '(' + peopleObj.Segment__r.Name__c + ')';
		}
		
		if(String.isBlank(externalPhotoUrl) || (externalPhotoUrlExpiryDate==null || externalPhotoUrlExpiryDate <= DateTime.now())) {
			formatterList.add(EmailConstants.peopleDefaultIcon);
		} else {
			formatterList.add(externalPhotoUrl);
		}
		profileDisplayIcon = EmailUtility.format(EmailTemplateService.templatePartMap.get('profileImage'),formatterList);
		formatterList.clear();
		
		String contentLink = '';//SimpplrContext.salesForceBaseUrl + Page.PageRedirector.getUrl() + '?siteId=' + simpplrContentObj.site__c +'&contentId='+simpplrContentObj.id+'&pageToRedirect=ContentDetailPage'+'&origin=ne';
		
		String emailBodyfeedbackEmail = EmailTemplateService.feedbackEmailTemplateMap.get('feedbackEmail');
		//0=Target User First Name 1=Subject  2=profileImage 3=Logged in user Full Name 4=content LinkBody 5=Link to Content 6=Link to content		
		formatterList.add('Hi');
		String uName = String.isNotBlank(UserContext.peopleName) ? UserContext.peopleName : UserContext.name;
		formatterList.add(heading); // 1
		formatterList.add(profileDisplayIcon); // 2
		formatterList.add(uName + segmentInfo + ' on ' + EncodingUtil.urlDecode(pageTitle, 'UTF-8')); // 3
		
		formatterList.add('"' + emailText + '"'); // 4
		formatterList.add(EncodingUtil.urlDecode(pageUrl, 'UTF-8')); // 5
		formatterList.add(brandingInfo.general_primaryColor); // 6
		
		emailBodyfeedbackEmail = EmailUtility.format(emailBodyfeedbackEmail, formatterList);
		formatterList.clear();
		return emailTemplateWithHeaderFooterForFeedbackEmail(toEmails, emailBodyfeedbackEmail, brandingInfo.logo_Url, brandingInfo);
	}
	
	private String emailTemplateWithHeaderFooterForFeedbackEmail(String targetEmailIds, String emailBody, String logoUrl, NotificationHelper.BrandingInfo brandingInfo){
		String finalEmailWithTemplate = '';
		List<String> formatterList = new List<String>();
		String templateWithHeaderFooter = EmailTemplateService.feedbackEmailTemplateMap.get('emailTemplateWithHeaderFooterForFeedbackEmail');
		formatterList.add('<img src="'+logoUrl+'" alt="" height="36" style="border:none; outline:none; text-decoration:none; width:auto;">');
		formatterList.add('');// current date 
		formatterList.add(emailBody);
		formatterList.add('mailto:' + targetEmailIds); // {4} - mailTo : toEmails
		formatterList.add(targetEmailIds);			 // {5} - toEmails
		formatterList.add('Copyright ' + Date.today().year() + '. All rights reserved.'); // 7
		formatterList.add(brandingInfo.general_primaryColor);
		
		if('dark'.equalsIgnoreCase(brandingInfo.header_preset)){
			formatterList.add('000000');
		} else if('primary'.equalsIgnoreCase(brandingInfo.header_preset)) {
			formatterList.add(brandingInfo.general_primaryColor);
		} else if('default'.equalsIgnoreCase(brandingInfo.header_preset)){
			formatterList.add('ffffff');
		} else {
			formatterList.add(brandingInfo.header_backgroundColor);
		}
		
		formatterList.add('f8f8f8');
		formatterList.add('333333');
		formatterList.add(SimpplrContext.salesforceBaseUrl + '/' + UserInfo.getOrganizationId());  // {11} - orgUrl
		formatterList.add(UserInfo.getOrganizationName());								   // {12} - orgName
		finalEmailWithTemplate = EmailUtility.format(templateWithHeaderFooter, formatterList);
		
		return finalEmailWithTemplate;
	}
	
	@testVisible 
	private ResponseWrapper getCustomizationValues(String segmentId){

		ResponseWrapper responseWrapperObj = new ResponseWrapper();
		try{
			String brandingJSON;
			
			if(SimpplrContext.isSegmentBrandingEnabled){
				Map<String, Object> soqlParamMap = new  Map<String, Object>();
				soqlParamMap.put('soqlParam1', segmentId);
				String query = 'SELECT Id,Branding_JSON__c FROM Segment__c WHERE Id = :soqlParam1 LIMIT 1';		
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
				List<Segment__c> segmentList  = (List<Segment__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
				System.debug('??????segmentList 486   ' + segmentList);

				
				if(segmentList.isEmpty()){
					throw new SimpplrException(ExceptionCode.INVALID_REQUEST_PARAM_VALUE.name());
				}
				
				if(String.isNotBlank(segmentList[0].Branding_JSON__c)){
					brandingJSON = segmentList[0].Branding_JSON__c;
				}				
			} else {
				String appConfigQuery = 'SELECT Id,Branding_JSON__c FROM App_Config__c limit 1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<App_Config__c> appConfigList = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
				System.debug('??????appConfigList 506   ' + appConfigList);

				
				if(!appConfigList.isEmpty() && String.isNotBlank(appConfigList[0].Branding_JSON__c)){
					brandingJSON = appConfigList[0].Branding_JSON__c;
					System.debug('??????brandingJSON 501   ' + brandingJSON);

				}
			} 
			
			if(String.isBlank(brandingJSON)) {
				brandingJSON = Utility.getDefaultBrandingValues();
				System.debug('??????responseWrapperObj 506   ' + brandingJSON);

			}			
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			String queryString = 'select Created_By__c, Created_By__r.Full_Name__c, createddate from Audit_Trail__c where Object_Name__c = '; 
			
			if(String.isNotBlank(segmentid)){
				soqlParamMap.put('soqlParam1', segmentId);
				queryString += '\'Segment__c\' AND segment__c = :soqlParam1';
			
			} else {
				queryString += '\'App_Config__c\'';
			
			}	
			queryString += ' And Column_Name__c = \'Branding__c\'  order by createddate desc limit 1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Audit_Trail__c> auditTrailList = new List<Audit_Trail__c>();
			if(soqlParamMap.isEmpty()){
				auditTrailList = (List<Audit_Trail__c>)SIMPESAPI.accessController().queryAsUser(queryString, null);
			} else{
				auditTrailList = (List<Audit_Trail__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);
			}
			
			Map<String, Object> resultMap = new Map<String, Object>();
			resultMap.put('values', (Map<String,Object>)JSON.deserializeUntyped(brandingJSON));
			if(auditTrailList.isEmpty() == false) {
				PeopleLiteWrapper peopleWrapperObj = new PeopleLiteWrapper();
				peopleWrapperObj.name = auditTrailList[0].Created_By__r.Full_Name__c;
				peopleWrapperObj.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + auditTrailList[0].Created_By__c;
				resultMap.put('modifiedAt',auditTrailList[0].createddate.format(ServiceConstants.DATETIME_FORMAT));
				resultMap.put('modifiedBy', peopleWrapperObj);
			}
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, resultMap);
			System.debug('??????responseWrapperObj 537   ' + responseWrapperObj);

		}catch(Exception e){
			logger.logError('UtilityDataServer.getCustomizationValues()----could not retrieve Customizations Values',e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		logger.logDebug('UtilityDataServer.getCustomizationValues()----responseWrapperObj----'+responseWrapperObj);
		System.debug('??????responseWrapperObj 544   ' + responseWrapperObj);

		return responseWrapperObj; 
	}
	
	@testVisible 
	private void saveCustomizationValues(){
		String segmentId = readParam('segmentId');
		String customizationString = readParam('values');
		String cssString = readParam('css');
		String classNames = readParam('classNames');
		String packageVersion = readParam('packageVersion');

		if(String.isBlank(segmentId)){
			saveCustomizationValuesForApp(customizationString, cssString, classNames);
		
		} else if(SimpplrContext.isSegmentBrandingEnabled){
			saveCustomizationValuesForSegment(segmentId, customizationString, cssString, classNames);	
			
		} else {
			throw new SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
		}
	}
	
	private void saveCustomizationValuesForApp (String customizationString, String cssString, String classNames) {
		logger.logDebug('UtilityDataServer.saveCustomizationValuesForApp()----updating values for app');
		if (!AccessManager.hasBrandingUpdatePermissions()) {
			throw new SimpplrException(ServiceConstants.ERROR_403);
		}
		
		String appConfigQuery = 'SELECT Id, Package_Version__c, Branding_JSON__c,'
										+ ' Branding_CSS_Class__c, Branding_CSS__c,Branding_Logo__c, Favicons_Folder__c'
										+ ' FROM App_Config__c limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> appConfigList = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
		
		if (!appConfigList.isEmpty() && String.isNotBlank(customizationString)) {
			String oldBrandingValue = appConfigList[0].Branding_Logo__c;
			Map<String, Object> logoUrlMap = (Map<String, Object>)JSON.deserializeUntyped(customizationString);
			
			if (logoUrlMap != null && !logoUrlMap.isEmpty()) {
				Map<String, Object> logoObjMap = (Map<String, Object>)logoUrlMap.get('logo_logo');
				
				if (logoObjMap != null && !logoObjMap.isEmpty()) {
					if (logoObjMap.get('thumbnailImg') != null) {
						appConfigList[0].Branding_Logo__c = String.valueOf(logoObjMap.get('thumbnailImg'));	
					} 
				} else {
					// set to default
					appConfigList[0].Branding_Logo__c = null;
				} 
				
			}
			
			if (logoUrlMap.get('logo_faviconPath') != null) {
				appConfigList[0].Favicons_Folder__c = String.valueOf(logoUrlMap.get('logo_faviconPath'));
			
			} else {
				appConfigList[0].Favicons_Folder__c = '';
			}
			
			if (String.isNotBlank(cssString)) {
				appConfigList[0].Branding_CSS__c = cssString.replace('url(/servlet', 
						'url(' + Utility.getFileDownloadBaseURL() + '/servlet');
			
			} else {
				appConfigList[0].Branding_CSS__c = '';
			}
			
			if (String.isNotBlank(classNames)) {
				appConfigList[0].Branding_CSS_Class__c = classNames;
			
			} else {
				appConfigList[0].Branding_CSS_Class__c = '';
			}
			
			appConfigList[0].Branding_JSON__c = customizationString;
			System.debug(' >>>>>>appConfigList[0].Branding_JSON__c ' + appConfigList[0].Branding_JSON__c);
			appConfigList[0].Package_Version__c = ServiceConstants.PACKAGE_VERSION;
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,App_Config__c>(appConfigList),
					new List<Schema.SObjectField>{App_Config__c.Package_Version__c, 
					App_Config__c.Branding_CSS__c, App_Config__c.Branding_CSS_Class__c, 
					App_Config__c.Branding_JSON__c, App_Config__c.Branding_Logo__c,
					App_Config__c.Favicons_Folder__c});
					
			if(ACTION_SAVE_CUSTOMIZATIONS_VALUES.equalsIgnoreCase(readParam(REQUEST_PARAM_ACTION)) && SimpplrContext.isAuditTrailEnabled){
				List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
				Audit_Trail__c auditTrailObj = new Audit_Trail__c();
				
				auditTrailObj.Created_By__c = UserContext.peopleId;
				auditTrailObj.New_Value__c = appConfigList[0].Branding_Logo__c;
				auditTrailObj.Column_Name__c = 'Branding__c';
				auditTrailObj.Old_Value__c = oldBrandingValue;
				auditTrailObj.Object_Name__c = 'App_Config__c';

				fieldList.add(Audit_Trail__c.Created_By__c);
				fieldList.add(Audit_Trail__c.New_Value__c);
				fieldList.add(Audit_Trail__c.Column_Name__c);
				fieldList.add(Audit_Trail__c.Old_Value__c);
				fieldList.add(Audit_Trail__c.Object_Name__c);
				
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().insertAsUser(auditTrailObj, fieldList);
			}
			
			logger.logDebug('UtilityDataServer.saveCustomizationValuesForApp()----values updated for app');
		}	
			
	}  
	
	private void saveCustomizationValuesForSegment(String segmentId, String customizationString, String cssString, String classNames){
		logger.logDebug('UtilityDataServer.saveCustomizationValuesForSegment()----updating values for segment ' + segmentId);
		if(AccessManager.hasBrandingUpdatePermissions() || (segmentId.equalsIgnoreCase(UserContext.segmentId) && UserContext.isSegmentManager)) {
			//User has branding change permissions
		} else {
			throw new SimpplrException(ServiceConstants.ERROR_403); 	
		}

		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', segmentId);
		String query = 'SELECT Id, Branding_JSON__c, Branding_CSS_Class__c, Branding_CSS__c,Branding_Logo__c,Favicons_Folder__c FROM Segment__c WHERE Id = :soqlParam1 LIMIT 1';		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Segment__c> segmentList  = (List<Segment__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);

		if (!segmentList.isEmpty() && String.isNotBlank(customizationString)) {
			String oldBrandingValue = segmentList[0].Branding_Logo__c;
			Map<String,Object> logoUrlMap = (Map<String,Object>)JSON.deserializeUntyped(customizationString);
			
			if (logoUrlMap != null && !logoUrlMap.isEmpty()) {
				Map<String,Object> logoObjMap = (Map<String,Object>)logoUrlMap.get('logo_logo');
				
				if (logoObjMap != null && !logoObjMap.isEmpty()) {
					
					if (logoObjMap.get('thumbnailImg') != null) {
						segmentList[0].Branding_Logo__c = String.valueOf(logoObjMap.get('thumbnailImg'));	
					} 
					
				} else {
					// set to default
					segmentList[0].Branding_Logo__c = null;
				}
				
			}
			
			if (logoUrlMap.get('logo_faviconPath') != null) {
				segmentList[0].Favicons_Folder__c = String.valueOf(logoUrlMap.get('logo_faviconPath'));
			
			} else {
				segmentList[0].Favicons_Folder__c = '';
			}
			
			if (String.isNotBlank(cssString)) {
				segmentList[0].Branding_CSS__c = cssString.replace('url(/servlet', 'url(' + Utility.getFileDownloadBaseURL() + '/servlet');
			
			} else {
				segmentList[0].Branding_CSS__c = '';
			}
			
			if (String.isNotBlank(classNames)) {
				segmentList[0].Branding_CSS_Class__c = classNames;
			
			} else {
				segmentList[0].Branding_CSS_Class__c = '';
			}
			
			segmentList[0].Branding_JSON__c = customizationString;
			segmentList[0].Branding_Package_Version__c = ServiceConstants.PACKAGE_VERSION;
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,Segment__c>(segmentList),
					new List<Schema.SObjectField>{Segment__c.Branding_CSS__c, Segment__c.Branding_Package_Version__c,
					Segment__c.Branding_CSS_Class__c, Segment__c.Branding_JSON__c, 
					Segment__c.Branding_Logo__c, Segment__c.Favicons_Folder__c});
			
			String appConfigQuery = 'SELECT Id, Package_Version__c from App_Config__c LIMIT 1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<App_Config__c> appConfigList = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
				
			if(!appConfigList.isEmpty()) {
				appConfigList[0].Package_Version__c = ServiceConstants.PACKAGE_VERSION;			
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<Id,App_Config__c>(appConfigList),
														new List<Schema.SObjectField>
															{App_Config__c.Package_Version__c});
			}

			if(ACTION_SAVE_CUSTOMIZATIONS_VALUES.equalsIgnoreCase(readParam(REQUEST_PARAM_ACTION)) && SimpplrContext.isAuditTrailEnabled){
				Audit_Trail__c auditTrailObj = new Audit_Trail__c();
				auditTrailObj.Created_By__c = UserContext.peopleId;
				auditTrailObj.New_Value__c = segmentList[0].Branding_Logo__c;
				auditTrailObj.Column_Name__c = 'Branding__c';
				auditTrailObj.Old_Value__c = oldBrandingValue;
				auditTrailObj.Object_Name__c = 'Segment__c';
				auditTrailObj.Segment__c = segmentId;

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().insertAsUser(auditTrailObj, new List<Schema.SObjectField>{
						Audit_Trail__c.Created_By__c,
						Audit_Trail__c.New_Value__c,
						Audit_Trail__c.Column_Name__c,
						Audit_Trail__c.Old_Value__c,
						Audit_Trail__c.Object_Name__c,
						Audit_Trail__c.Segment__c
						});
			}
			
		}	
			
	}	  
	
	@testVisible 
	private void getBrandingCss(){
		if(SimpplrContext.isSegmentsEnabled && SimpplrContext.isSegmentBrandingEnabled && String.isNotBlank(UserContext.segmentId)) {
			brandingCssString = UserContext.getCurrentUserInfo.Segment__r.Branding_CSS__c;
			
		} else {
			brandingCssString = SimpplrContext.appConfig.Branding_CSS__c;
		}
		logger.logDebug('UtilityDataServer.getBrandingCss()----brandingCssString'+brandingCssString);
	}
	
	@testVisible 
	private void getCustomFontCSS(){
		String brandingJSON;
		
		if(SimpplrContext.isSegmentsEnabled && SimpplrContext.isSegmentBrandingEnabled && String.isNotBlank(UserContext.segmentId)) {
			brandingJSON = UserContext.getCurrentUserInfo.Segment__r.Branding_JSON__c;
			if(String.isBlank(brandingJSON)) {
				brandingJSON = Utility.getDefaultBrandingValues();
			}
			Map<String,Object> brandingMap = (Map<String,Object>)JSON.deserializeUntyped(brandingJSON);
			String fontUsed = String.valueOf(brandingMap.get('font_font'));
			if('custom'.equalsIgnoreCase(fontUsed)) {
				brandingCssString = String.valueOf(brandingMap.get('font_font_css'));
			}			
			
		} else {
			String appConfigQuery = 'SELECT Id, Branding_JSON__c FROM App_Config__c limit 1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<App_Config__c> appConfigList = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
			
			if(!appConfigList.isEmpty()){
				brandingJSON = appConfigList[0].Branding_JSON__c;
				if(String.isBlank(brandingJSON)) {
					brandingJSON = Utility.getDefaultBrandingValues();
				}
				Map<String,Object> brandingMap = (Map<String,Object>)JSON.deserializeUntyped(brandingJSON);
				String fontUsed = String.valueOf(brandingMap.get('font_font'));
				if('custom'.equalsIgnoreCase(fontUsed)) {
					brandingCssString = String.valueOf(brandingMap.get('font_font_css'));
				}			
			}			
		}		
		
		logger.logDebug('UtilityDataServer.getCustomFontCSS()----customCssString'+brandingCssString);
	}
	
	private ResponseWrapper getRequestToken () { 
		ResponseWrapper responseWrapperObj = new ResponseWrapper(); 
		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'DRI fetched', utility.externalRequestAuthToken());
		return responseWrapperObj;
	}
	
	private ResponseWrapper getSecurityToken(){
		logger.logDebug('getSecurityToken----entered getSecurityToken----');
		ResponseWrapper localResult = null;
		try{
			String securityCode = Utility.externalRequestAuthToken();
	        Map<String, Object> responseObj = new Map<String, Object>();
	        responseObj.put('securityToken', securityCode);
			localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS,null, responseObj);
		}catch(Exception e) {
        	logger.logError('UtilityDataServer.getSecurityToken() Exception Details', e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult;
	}
	
	@TestVisible private ResponseWrapper getFromAddresses(){
	ResponseWrapper resultWrapper = New ResponseWrapper();
		try {
		FilterService filterServiceObj = new FilterService();
		List<Map<String, String>> fromAdressesList = filterServiceObj.getFromAddresses();	
		Map<String, Object> resultMap = new Map<String, Object>();
		resultMap.put('listOfItems', fromAdressesList);	
		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, resultMap);
		} catch (exception e){
			logger.logError('UtilityDataServer.getFromAddresses() Exception Details', e);
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return resultWrapper;
	}



	private void validatePlatformCaching() {

		String platformCacheAppConfigStr = 'Local.Cache.appConfig';
		String platformCacheAppIntegStr = 'Local.Cache.appIntegrations';

		if (!String.isblank(SimpplrContext.namespacePrefix)) {
			platformCacheAppConfigStr = 'Simpplr.Cache.appConfig';
			platformCacheAppIntegStr = 'Simpplr.Cache.appIntegrations';
		}

		if (SimpplrContext.isPlatformCachingFeatureEnabled  && 
				Cache.Org.contains(platformCacheAppConfigStr)) {  
			logger.logDebug('Retrieving AppConfig through cache ------');
		} else {
			logger.logDebug('Retrieving AppConfig through SOQL ------');
		}

		if (SimpplrContext.isPlatformCachingFeatureEnabled && Cache.Org.contains(platformCacheAppIntegStr)) { 
			logger.logDebug('Retrieving AppIntegrations through cache ------');
		} else {
			logger.logDebug('Retrieving AppIntegrations through SOQL ------');
		}
	}
	private ResponseWrapper getCurrentUserSettings(){
		ResponseWrapper responseWrapperObj = new ResponseWrapper();
		try{

			AppInitWrapper wrapperObj = new AppInitWrapper();
			wrapperObj.currentUser = getUserConfig();

			wrapperObj.currentUser.hasConnectedLinkedInAccount = false;
			wrapperObj.currentUser.hasConnectedTwitterAccount = false;  	
			if (SimpplrContext.isEmployeeAdvocacyEnabled) {
				Boolean isLinkedinEnabled = SimpplrContext.appIntegrationEnabledSet.contains(IntegrationConstants.INTEGRATION_TYPE_LINKEDIN);
				Boolean isTwitterEnabled = SimpplrContext.appIntegrationEnabledSet.contains(IntegrationConstants.INTEGRATION_TYPE_TWITTER);
				IntegrationService integrationServiceObj = new IntegrationService(UserContext.peopleId);
					
				if (isLinkedinEnabled) {
					integrationServiceObj.setIntegrationVariables(IntegrationConstants.INTEGRATION_TYPE_LINKEDIN);
					if (integrationServiceObj.integrator != null && !integrationServiceObj.accessTokenExpired()) {
						wrapperObj.currentUser.hasConnectedLinkedInAccount = true;
					}
				}
				
				if (isTwitterEnabled) {
					integrationServiceObj.setIntegrationVariables(IntegrationConstants.INTEGRATION_TYPE_TWITTER);
					if (integrationServiceObj.integrator != null && !integrationServiceObj.accessTokenExpired()) {
						wrapperObj.currentUser.hasConnectedTwitterAccount = true;
					}
				}
			}
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, wrapperObj);
		} catch (Exception e) {
			logger.logError('UtilityDataServer.getCurrentUserSettings()----could not fetch getCurrentUserSettings----',e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}

		return responseWrapperObj;
	}

	private ResponseWrapper getAppConfig(){
		ResponseWrapper responseWrapperObj = new ResponseWrapper();
		try{

			AppInitWrapper wrapperObj = new AppInitWrapper();
			wrapperObj.settings = getAppSettings();

			if (SimpplrContext.isEmployeeAdvocacyEnabled) {
				Boolean isFacebookEnabled = SimpplrContext.appIntegrationEnabledSet.contains(IntegrationConstants.INTEGRATION_TYPE_FACEBOOK);
				IntegrationService integrationServiceObj = new IntegrationService(UserContext.peopleId);
				if (isFacebookEnabled) {
					integrationServiceObj.setIntegrationVariables(IntegrationConstants.INTEGRATION_TYPE_FACEBOOK);
					wrapperObj.settings.socialCampaignsFacebookAppId = integrationServiceObj.getClientId();
				}				
			}
			
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, wrapperObj);
		} catch (Exception e) {
			logger.logError('UtilityDataServer.getAppConfig()----could not fetch getAppConfig----',e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}

		return responseWrapperObj;
	}

	private AppInitWrapper.UserConfig getUserConfig() {
		AppInitWrapper.UserConfig userDetails = new AppInitWrapper.UserConfig();
		userDetails.sfUserId = UserContext.userId;
		userDetails.peopleId = UserContext.peopleId;
		if (SimpplrContext.appConfig != NULL) { 
			userDetails.isNewUser = (UserContext.firstLoginDateTime > SimpplrContext.appConfig.Last_Major_Upgrade_DateTime__c);
		} else {
			userDetails.isNewUser = true; 
		}	
		userDetails.nickname = UserContext.communityNickname;
		userDetails.firstName = UserContext.firstName;
		userDetails.name = UserContext.peopleName;
		userDetails.email = UserInfo.getUserEmail();
		userDetails.img = Utility.getProfilePhotoURL(UserContext.fullPhotoURL);
		userDetails.language = UserContext.languageLocaleKey.replace('_', '-');
		userDetails.lastLoginAt = (UserContext.getCurrentUserInfo !=null ? Utility.dateTimeToMomentJSDateTime(UserContext.getCurrentUserInfo.User__r.LastLoginDate) : null);
		if(UserContext.getCurrentUserInfo != null) {
			String seprator = '';
			userDetails.location = '';
			if(String.isNotBlank(UserContext.getCurrentUserInfo.City__c)) {
				userDetails.location = UserContext.getCurrentUserInfo.City__c;
				seprator = ', ';
			} 
			if(String.isNotBlank(UserContext.getCurrentUserInfo.State__c)) {
				userDetails.location += seprator + UserContext.getCurrentUserInfo.State__c;
				seprator = ', ';
			}
			if(String.isNotBlank(UserContext.getCurrentUserInfo.Country__c)) {
				userDetails.location += seprator + UserContext.getCurrentUserInfo.Country__c;
			}
			
			userDetails.isNewHire = UserContext.isNewHire;
			userDetails.isOnboardingDisabledOnFeed = UserContext.isOnboardingDisabledOnFeed;
			userDetails.locationId = UserContext.getCurrentUserInfo.city__c + ' @@ ' + UserContext.getCurrentUserInfo.state__c + ' @@ ' + UserContext.getCurrentUserInfo.country__c ;
			userDetails.department = UserContext.getCurrentUserInfo.Department__c;
			userDetails.departmentId = String.isNotBlank(UserContext.getCurrentUserInfo.Department__c) ? UserContext.getCurrentUserInfo.Department__c.toLowerCase() : null;
			userDetails.country = UserContext.getCurrentUserInfo.Country__c;
			userDetails.company = UserContext.getCurrentUserInfo.Company_Name__c;
			userDetails.division = UserContext.getCurrentUserInfo.Division__c;
			userDetails.city = UserContext.getCurrentUserInfo.City__c;
			userDetails.state = UserContext.getCurrentUserInfo.State__c;	
			userDetails.birthday = Utility.dateToDisplayString(UserContext.getCurrentUserInfo.Birth_Date__c,'MM-dd');
			userDetails.hireDate = Utility.dateToDisplayString(UserContext.getCurrentUserInfo.Joining_Date__c,'yyyy-MM-dd');		

			userDetails.hasLoggedInToMobileApp = String.isNotBlank(UserContext.getCurrentUserInfo.Mobile_Token_Android__c) || 
												 String.isNotBlank(UserContext.getCurrentUserInfo.Mobile_Token_iOS__c);
		}

		userDetails.browserNotificationAllowed = 'Yes'.equalsIgnoreCase(UserContext.browserNotificationAllowed) ? true : false;
		userDetails.phone = UserContext.phone;
		userDetails.mobile = UserContext.mobile;		
		userDetails.coverImageUrl = String.isBlank(UserContext.coverImageId) ? '' : Utility.getFileDownloadURL(UserContext.coverImageId);
		userDetails.about = UserContext.aboutMe;
		userDetails.timezone = UserContext.timeZoneLabel;
		userDetails.timezoneIso = UserInfo.getTimeZone().getId();
		TimeZone tz = UserInfo.getTimeZone();
		userDetails.timezoneOffset = tz.getOffset(system.today()); 
		userDetails.timezoneName = UserContext.timeZoneLabel;
		userDetails.feedSort = UserContext.feedSortOrder;
        userDetails.feedFilter = UserContext.feedFilter; 
		userDetails.segmentId = UserContext.segmentId;
		userDetails.segmentName = UserContext.segmentName;
		userDetails.subSegment = UserContext.segmentAttributeValue;
		userDetails.sessionId = UserInfo.getSessionId();
		userDetails.hasConnectedBoxAccount	= SimpplrContext.IsBoxIntegrationEnabled && UserContext.isBoxConnected;	
		userDetails.hasConnectedGoogleDriveAccount = isAppIntegrationEnabled('googledrive') && hasUserConnectedAccount('googledrive');
		userDetails.hasConnectedDropboxAccount = isAppIntegrationEnabled('dropbox') && hasUserConnectedAccount('dropbox');
		userDetails.hasConnectedOneDriveAccount = isAppIntegrationEnabled('onedrive') && hasUserConnectedAccount('onedrive');
		userDetails.hasConnectedSharePointAccount = isAppIntegrationEnabled('sharepoint') && hasUserConnectedAccount('sharepoint');

		userDetails.hasConnectedGoogleCalendarAccount = SimpplrContext.AllowedFeatures.containsIgnoreCase(AccessManager.FEATURE_EVENT) && 
														isAppIntegrationEnabled('googlecalendar') && 
														hasUserConnectedAccount('googlecalendar');

		userDetails.hasConnectedOutlookCalendarAccount = SimpplrContext.AllowedFeatures.containsIgnoreCase(AccessManager.FEATURE_EVENT) && 
														isAppIntegrationEnabled('outlookcalendar') && 
														hasUserConnectedAccount('outlookcalendar');

		userDetails.hasConnectedServiceNowAccount = SimpplrContext.isServiceNowConnected && 
													hasUserConnectedAccount(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW)
													&& String.isNotBlank(UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Refresh_Token__c);
		if(SimpplrContext.isSlackPhase2FeatureEnabled && SimpplrContext.isSlackUpgraded){
			userDetails.hasConnectedSlackAccount = hasUserConnectedAccount(IntegrationConstants.INTEGRATION_TYPE_SLACK);
		} else {
			userDetails.hasConnectedSlackAccount = hasUserConnectedAccount(IntegrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE);
		}
		userDetails.hasConnectedMicrosoftTeamsAccount = hasUserConnectedAccount(IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS);
		userDetails.hasConnectedAtlassianAccount = SimpplrContext.isAtlassianConnected && hasUserConnectedAccount(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN);
		
		userDetails.emailProductResearch = UserContext.emailProductResearch;
		userDetails.hasDismissedWebPushPromptFromNotiPanel = UserContext.hasDismissedWebPushPromptFromNotiPanel;
		userDetails.spInstanceId = UserContext.spInstanceId;
		userDetails.permissions = getUserPermissions();
		userDetails.microsoftTeamsUserId = UserContext.microsoftTeamsUserId;
		userDetails.microsoftTeamsUserName = UserContext.microsoftTeamsUserName;
		userDetails.microsoftTeamsConnectedAs = UserContext.microsoftTeamsConnectedAs;
		userDetails.microsoftTenantId = UserContext.microsoftTenantId;
		userDetails.slackUserId = UserContext.slackUserId;
		userDetails.slackConnectedAs = UserContext.slackConnectedAs;

		return userDetails;

	}

	private AppInitWrapper.UserPermissions getUserPermissions() {
		AppInitWrapper.UserPermissions permissions = new AppInitWrapper.UserPermissions();
		permissions.canCreateSite = UserContext.canCreateOrOwnGroups;
		
		if(SimpplrContext.isOnlyInfluencersAllowedToCreateBlog && UserContext.getCurrentUserInfo != null && UserContext.getCurrentUserInfo.Is_Influencer__c == false){
			permissions.canCreateBlogPost =  false;
			
		} else if(SimpplrContext.AllowedFeatures.containsIgnoreCase(AccessManager.FEATURE_BLOG)) {
			permissions.canCreateBlogPost =  true;
		}		
		
		permissions.canCreateTopics = UserContext.canCreateTopics;
		permissions.canAccessAllPrivateSites = UserContext.hasModifyAllDataPermission;
		permissions.canManageHomeDashboard = SimpplrContext.isSegmentsEnabled ? (UserContext.isSegmentManager || UserContext.isUserAppModerator) : (UserContext.canControlHomeDashboard || UserContext.isUserAppModerator);
		permissions.isSiteManager = UserContext.isUserSiteManager || UserContext.isUserAppModerator || UserContext.hasModifyAllDataPermission || UserContext.hasManageUnlistedSitePermission;
		permissions.isSiteOwner = UserContext.isUserSiteOwner;
		permissions.isContentManager = !UserContext.sitesIManageContentsIdSet.isEmpty();
		permissions.isProtectedAuthorAllowlisted = UserContext.isProtectedAuthorAllowlisted;
		permissions.isPeopleManager = UserContext.isUserPeopleManager;

		if(SimpplrContext.isFeatureEnabled('Alerts')) {
			permissions.canSendAlerts = UserContext.canSendSiteAlert;
			permissions.canSendAlertsToAll = UserContext.canSendAlerts || UserContext.isUserAppModerator;
		} else {
			permissions.canSendAlerts = false;
			permissions.canSendAlertsToAll = false;
		}
		
		permissions.canAccessAnalytics = UserContext.isUserAppModerator || UserContext.canAccessAnalytics;
		permissions.canManageSentimentCheck = getCanManageSentimentFlag();
		permissions.canManageSurveys = UserContext.canManageSurveys; 

		if(SimpplrContext.isFeatureEnabled('Newsletter') || SimpplrContext.newsletterPlusEnabled) {
			permissions.canSendNewsletter = UserContext.canSendSiteNewsletter;
			permissions.canSendNewsletterToAll = UserContext.canSendNewsletter || UserContext.isUserAppModerator;
		} else {
			permissions.canSendNewsletter = false;
			permissions.canSendNewsletterToAll = false;
		}
		permissions.isAppManager = UserContext.isUserAppModerator;
		permissions.isCampaignManager = UserContext.isUserCampaignModerator;
		permissions.isSystemAdmin = UserContext.hasModifyAllDataPermission;
		permissions.isUnlistedAdmin = UserContext.hasManageUnlistedSitePermission;
		permissions.isSegmentManager = UserContext.isSegmentManager;
		permissions.canManageCampaigns = SimpplrContext.isFeatureEnabled('Employee_Advocacy') ? UserContext.hasManageCampaignAccess : false;
		permissions.canManageInternalUsers = UserContext.canManageInternalUsers;
		permissions.isInitiativesAndCampaignsManager = UserContext.isInitiativesAndCampaignsManager;

        if(SimpplrContext.isFeatureContentOnboardingEnabled) {
            if(SimpplrContext.allSiteOnboardingEnabled){
                permissions.canManageSiteOnboarding= (permissions.isSiteManager || permissions.isSiteOwner || permissions.isContentManager) ? true : false;
            } else{
                permissions.canManageSiteOnboarding= UserContext.isUserSiteOnboardingManager && (permissions.isSiteManager || permissions.isSiteOwner || permissions.isContentManager) ? true : false;
            }
            permissions.canManageOrgOnboarding = UserContext.isUserAppModerator || (UserContext.getCurrentUserInfo != null && UserContext.getCurrentUserInfo.Enable_Org_Level_Onboarding__c);
        } else {
            permissions.canManageOrgOnboarding = false;
            permissions.canManageSiteOnboarding = false;
        }
		
		if(SimpplrContext.leadercastEnabledFor.equalsIgnoreCase(ServiceConstants.ALLOW_LEADERCAST_ALL_USER)) {
			permissions.canAccessLeadercast = true;
		} else if(SimpplrContext.leadercastEnabledFor.equalsIgnoreCase(ServiceConstants.ALLOW_LEADERCAST_APP_MANAGERS) && UserContext.isUserAppModerator) {
			permissions.canAccessLeadercast = true;
		} else if(SimpplrContext.leadercastEnabledFor.equalsIgnoreCase(ServiceConstants.ALLOW_LEADERCAST_SELECTED_SITES_USERS) && 
					UserContext.canAccessLeadercast) {
			permissions.canAccessLeadercast = true;
		} else {
			permissions.canAccessLeadercast = false;
		}
		if(SimpplrContext.aiContentModerationFeatureEnabled){
			permissions.isContentModerator = UserContext.isContentModerator || UserContext.isUserAppModerator;
		}
		if(SimpplrContext.recognitionEnabled){
			permissions.canManageRecognition = UserContext.canManageRecognition;
		}
		return permissions;
	}

	private Map<String, Datetime> getDismissedFlagList() {
		Map<String, Datetime> dismissedTaskMap = new Map<String, Datetime>(); 
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', UserContext.peopleId);		
		String query = 'select Help_Text__r.Task_Id__c, LastModifiedDate from Help_Text_View__c '+
													' where Help_Text__r.Type__c = \'Task\''+
													' And Is_Deleted__c = false'+
													' And People__c=: soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Help_Text_View__c> helpTextViewList = (List<Help_Text_View__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		for(Help_Text_View__c helpTextViewObj : helpTextViewList) {
			dismissedTaskMap.put(helpTextViewObj.Help_Text__r.Task_Id__c, helpTextViewObj.LastModifiedDate);
		}
		return dismissedTaskMap;
	}

	private List<AppInitWrapper.DismissibleFlashWrapper> getDismissibleFlashList() {
    	List<AppInitWrapper.DismissibleFlashWrapper> dismissibleFlashWrapperList = new List<AppInitWrapper.DismissibleFlashWrapper>(); 
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', UserContext.peopleId);	
		soqlParamMap.put('soqlParam2', ServiceConstants.DISMISSIBLE_FLASHES_TASK_TYPE_MAP.values());	
    	String query = 'select Help_Text__r.Task_Id__c, Help_Text__r.Type__c '+
													' from Help_Text_View__c '+
    												' where Help_Text__r.Type__c IN: soqlParam2'+
    												' And Is_Deleted__c = false'+
    												' And People__c=: soqlParam1';												
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Help_Text_View__c> helpTextViewList = (List<Help_Text_View__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
    	for(Help_Text_View__c helpTextViewObj : helpTextViewList) {
			AppInitWrapper.DismissibleFlashWrapper dismissibleFlashWrapperObj = new AppInitWrapper.DismissibleFlashWrapper();
			dismissibleFlashWrapperObj.name = helpTextViewObj.Help_Text__r.Task_Id__c;
			dismissibleFlashWrapperObj.type = helpTextViewObj.Help_Text__r.Type__c;
    		dismissibleFlashWrapperList.add(dismissibleFlashWrapperObj);
    	}
    	return dismissibleFlashWrapperList;
    }

	private ResponseWrapper deleteDismissibleFlashes(String requestData) {

		logger.logDebug('UtilityDataServer.deleteDismissibleFlashes()----requestData----'+requestData);
		ResponseWrapper responseWrapperObj = new ResponseWrapper();
		try {
			Map<String, List<AppInitWrapper.DismissibleFlashWrapper>> mapOfParams = (Map<String, List<AppInitWrapper.DismissibleFlashWrapper>>) JSON.deserialize(requestData, Map<String, List<AppInitWrapper.DismissibleFlashWrapper>>.class);
			List<AppInitWrapper.DismissibleFlashWrapper> dismissibleFlashList = (List<AppInitWrapper.DismissibleFlashWrapper>)mapOfParams.get('dismissibleFlashes');
			Set<String> taskIdSet = new Set<String>();
			for(AppInitWrapper.DismissibleFlashWrapper wrp:dismissibleFlashList){
				TaskIdSet.add(wrp.name);
			}
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', UserContext.peopleId);		
			soqlParamMap.put('soqlParam2', taskIdSet);	
			soqlParamMap.put('soqlParam3', ServiceConstants.DISMISSIBLE_FLASHES_TASK_TYPE_MAP.values());	
			String query = 'select Help_Text__r.Task_Id__c from Help_Text_View__c '+
														' where Help_Text__r.Type__c IN: soqlParam3'+
														' And Is_Deleted__c = false'+
														' And People__c=: soqlParam1'+
														' AND Help_Text__r.Task_Id__c IN: soqlParam2';	
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Help_Text_View__c> helpTextViewList = (List<Help_Text_View__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);		
			for(Help_Text_View__c helpTextView : helpTextViewList) {
				helpTextView.is_deleted__c = true;
			}									
			if(!helpTextViewList.isEmpty()){
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<Id,Help_Text_View__c>(helpTextViewList), new List<Schema.SObjectField>{
					Help_Text_View__c.Is_Deleted__c
				});
			}				
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);							
		} catch (Exception ex) {
			logger.logError('UtilityDataServer.deleteDismissibleFlashes()---Exception occured----', ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);			
		}
		return responseWrapperObj;		
	}
 
	private Boolean hasUserConnectedAccount(String integrationType) {
		return UserContext.Integrations != null && UserContext.Integrations.containsKey(integrationType) 
				&& UserContext.Integrations.get(integrationType).Connected__c;
	}

	private Boolean isAppIntegrationEnabled(String integrationType) {
		if(IntegrationConstants.INTEGRATION_TYPE_OUTLOOK_CALENDAR.equalsIgnoreCase(integrationType) || (IntegrationConstants.INTEGRATION_TYPE_SHAREPOINT.equalsIgnoreCase(integrationType) && SimpplrContext.isSharepointUpgraded == true)) {
			return SimpplrContext.Integrations != null && SimpplrContext.Integrations.containsKey(integrationType) && 
				SimpplrContext.Integrations.get(integrationType).Integration_Enabled__c   
				&& SimpplrContext.Integrations.get(integrationType).Whitelist_Domain__c != null;

		} else {
			return SimpplrContext.Integrations != null && SimpplrContext.Integrations.containsKey(integrationType) && 
					SimpplrContext.Integrations.get(integrationType).Integration_Enabled__c 
					&& SimpplrContext.Integrations.get(integrationType).Connected__c;
		}
	}

	private AppInitWrapper.AppSettings getAppSettings() {	
		system.debug('>>>>>>> UtilitydataServer.getAppSettings() ');
		AppInitWrapper.AppSettings settingObj = new AppInitWrapper.AppSettings();

		settingObj.addOns = AccessManager.getAddOns(); 
		
		settingObj.isCampaignManagerFeatureEnabled = FeatureFlagManager.isFeatureEnabled('zu_odin_manageapp_campaign');
		settingObj.isAudienceCSVEnabled = SimpplrContext.isAudienceCSVEnabled;
		settingObj.isOutlookCalendarFeatureEnabled = SimpplrContext.isOutlookCalendarFeatureEnabled;
		settingObj.isAdditional20FieldsFeatureEnabled = SimpplrContext.isAdditional20FieldsFeatureEnabled;
		settingObj.isImageLazyLoadEnabled = SimpplrContext.isImageLazyLoadEnabled;
		settingObj.isPhoneNoAndMobileTokenRemovableFeatureEnabled = SimpplrContext.isPhoneNoAndMobileTokenRemovableFeatureEnabled;
		settingObj.isMobileAppPopupFeatureEnabled = SimpplrContext.isMobileAppPopupFeatureEnabled;
		settingObj.launchpadProvider = (SimpplrContext.isSegmentsEnabled && SimpplrContext.isSegmentAppsNLinksEnabled) ? UserContext.getCurrentUserInfo.Segment__r.SSO_Provider__c : SimpplrContext.SSOProvider;
		settingObj.organizationId = UserInfo.getOrganizationId();
		settingObj.organizationName = UserInfo.getOrganizationName();
		settingObj.packageInfo = (String.isBlank(SimpplrContext.packageName) ? 'unmanaged' : ServiceConstants.PACKAGE_VERSION);
		Map<String,Object> brandingMap = new Map<String,Object>();
		settingObj.isSegmentsEnabled = SimpplrContext.isSegmentsEnabled;
		if(settingObj.isSegmentsEnabled && SimpplrContext.isSegmentBrandingEnabled) {
			if(String.isNotBlank(UserContext.getCurrentUserInfo.Segment__r.Branding_JSON__c)) {
				brandingMap = (Map<String,Object>)JSON.deserializeUntyped(UserContext.getCurrentUserInfo.Segment__r.Branding_JSON__c);
			}			
		} else {
			brandingMap = (Map<String,Object>)JSON.deserializeUntyped(SimpplrContext.SABrandingJSON);
		}
		settingObj.brandingPrimaryColor = String.valueOf(brandingMap.get('general_primaryColor'));
		settingObj.brandingPrimaryDarkModeColor = String.valueOf(brandingMap.get('general_primaryDarkModeColor'));
		settingObj.brandingLightModeLinkColor = String.valueOf(brandingMap.get('general_lightModelinkColor'));				//CONT-10737
		settingObj.brandingDarkModeLinkColor = String.valueOf(brandingMap.get('general_darkmodelinkColor'));				//CONT-10737
		settingObj.brandingAnchorPrimaryColor = String.valueOf(brandingMap.get('general_brandingAnchorPrimaryColor'));				//CONT-10737

		System.debug('>>>>>>> settingObj.brandingPrimaryColor 1240   ' + settingObj.brandingPrimaryColor);
		System.debug('>>>>>>> settingObj.brandingPrimaryDarkModeColor 1241   ' + settingObj.brandingPrimaryColor);


		if(String.isBlank(settingObj.brandingPrimaryColor)) {
			settingObj.brandingPrimaryColor = '1abc9c';
		}
		settingObj.analyticsColorScheme = (brandingMap != null && brandingMap.containsKey('analytics_analytics')) ? String.valueOf(brandingMap.get('analytics_analytics')) : ServiceConstants.DEFAULT_BRANDING.get('analytics_analytics');
		settingObj.isAppsAndLinksSegmented = SimpplrContext.isSegmentAppsNLinksEnabled;
		settingObj.isBrandingSegmented = SimpplrContext.isSegmentBrandingEnabled;	
		settingObj.logoUrl = SimpplrContext.isSegmentBrandingEnabled ? UserContext.getCurrentUserInfo.Segment__r.Branding_Logo__c : SimpplrContext.SALogo;	
		settingObj.allowFileUpload = SimpplrContext.allowFileUpload;
		settingObj.haveToMentionGroup = !SimpplrContext.isMuteContentPostInSiteFeedEnabled;
		settingObj.isOrgChartEnabled = SimpplrContext.isOrgChartEnabled;
		settingObj.goToSalesforceEnabled = SimpplrContext.isGoToSalesforceEnabled; 
		settingObj.isJsDebugEnabled = SimpplrContext.isJSDebugEnabled;	
		settingObj.brandingNeedsRefresh = isBrandingNeedsRefresh();
		settingObj.launchpadEnabled = Utility.isLaunchpadConfigured();
		settingObj.mobileAppsEnabled = SimpplrContext.mobileAppsEnabled;
		settingObj.isIframeSecurityEnabled = SimpplrContext.isIframeSecurityEnabled;
		settingObj.isSimpplrEmailEnabled = SimpplrContext.enableEmail;
		settingObj.isTopStoriesEmailEnabled = SimpplrContext.enableTopStoriesEmails;
		settingObj.isVideosManagementFeatureEnabled = SimpplrContext.isVideosManagementFeatureEnabled;
		settingObj.isActionPollerNotificationEnabled = SimpplrContext.isActionPollerNotificationEnabled;

		settingObj.languages =  new List<String>();
		settingObj.appUrl = PageContext.getPageURL(Pages.app);
		for(String lang:SimpplrContext.appLanguageEnabledSet) {
			settingObj.languages.add(lang.replace('_', '-'));
		}
		if(SimpplrContext.isContentGovernanceEnabled) {
			settingObj.validationPeriod = SimpplrContext.contentValidationPeriod;
		}

		settingObj.framebusterOption = SimpplrContext.appLightningSetting;
		settingObj.segmentField = String.isBlank(SimpplrContext.segmentColumnName) ? null : Utility.getLabelForSegmentFieldApi(SimpplrContext.segmentColumnName).toLowerCase();
		settingObj.segmentColumnName = SimpplrContext.segmentColumnName;
		if(SimpplrContext.appConfig!= null) {
			//Default Value Elastic to GlobalSearchProvider
			settingObj.globalSearchProvider = String.isBlank(SimpplrContext.appConfig.Global_Search_Provider__c) ? 'Elastic' : SimpplrContext.appConfig.Global_Search_Provider__c;
			settingObj.isHtmlTileEnabled = SimpplrContext.appConfig.HTML_tile_enabled__c;
			settingObj.isSocialTilesEnabled = SimpplrContext.appConfig.Social_Tiles_Enabled__c;
			settingObj.socialCampaignsPolicyUrl = SimpplrContext.appConfig.Social_Campaign_Policy_URL__c;
			settingObj.isHomeCarouselEnabled = SimpplrContext.appConfig.Home_Carousel_Enabled__c;
			settingObj.isSiteCarouselEnabled = SimpplrContext.appConfig.Site_Carousel_Enabled__c;
			settingObj.isSmsNotificationsEnabled = SimpplrContext.appConfig.SMS_Enabled__c;
			settingObj.showLogoOnMobile = SimpplrContext.appConfig.Show_Logo_On_Mobile__c;
			settingObj.isActiveDirectoryGroupsEnabled=false;
			if(SimpplrContext.Integrations.get('adsi')!=null && SimpplrContext.Integrations.get('adsi').Active_Directory_Groups_Enabled__c!=null){
				settingObj.isActiveDirectoryGroupsEnabled=SimpplrContext.Integrations.get('adsi').Active_Directory_Groups_Enabled__c;
			}
			settingObj.isAutomatedTranslationEnabled = SimpplrContext.appConfig.Automated_Translation_Enabled__c;
			settingObj.isMobileNotificationsEnabled = SimpplrContext.appConfig.Simpplr_Mobile_Notification_Allowed__c;
			settingObj.isQuestionAnswerEnabled = SimpplrContext.isQuestionAnswerEnabled;
			settingObj.isQuestionEnabledForContent = SimpplrContext.isQuestionAnswerEnabled && SimpplrContext.questionChangesForKITA;
			settingObj.microserviceUrl = SimpplrContext.simpplrAPIEndpoint;
			settingObj.zeusMicroserviceUrl = SimpplrContext.zeusMicroserviceUrl;
			
			if(SimpplrContext.appConfig.Branded_App_Distribution_Enabled__c == null){
				settingObj.isBrandedAppDistributionEnabled = false;
			}else{
				settingObj.isBrandedAppDistributionEnabled = SimpplrContext.nativeAppEnabled && !SimpplrContext.loginFromGenericAppAllowed && SimpplrContext.appConfig.Branded_App_Distribution_Enabled__c;
			}

			if(SimpplrContext.appConfig.Vbrick_Enabled__c && String.isNotBlank(SimpplrContext.appConfig.Vbrick_Base_Url__c)) {
				settingObj.vBrickBaseURL = SimpplrContext.appConfig.Vbrick_Base_Url__c.substringAfter('://').removeStartIgnoreCase('www.').substringBefore('.vbrick.com') + '.vbrick.com';
			}
		
		} else {
			settingObj.isSocialTilesEnabled = false;
			settingObj.isHomeCarouselEnabled = true;
			settingObj.isSiteCarouselEnabled = true;
			settingObj.showLogoOnMobile = false;
			settingObj.isAutomatedTranslationEnabled =  false;
			settingObj.isSmsNotificationsEnabled = true;
			settingObj.isBrandedAppDistributionEnabled = false;
			settingObj.isQuestionAnswerEnabled = false;
		}

		settingObj.feedPlaceholder = SimpplrContext.feedPlaceholder;
		
		/*settingObj.usageTrackingEnabled = String.isNotBlank(SimpplrContext.packageName) ? SimpplrContext.isAnalyticsDataCollectionEnabled : false;
		https://simpplr.atlassian.net/browse/SV2-45241
		Removing this flag as we decided to stop making simpplr google analytics call 
		*/
		settingObj.isFeedbackEnabled = String.isNotBlank(SimpplrContext.feedbackToEmails);
		settingObj.isMaintenanceModeEnabled = SimpplrContext.isMaintenanceInProgress;
		settingObj.maintenanceModeReason = SimpplrContext.maintenanceReason;

		if(settingObj.isMaintenanceModeEnabled == false && isServiceAccountSetupPending()) {
			settingObj.isMaintenanceModeEnabled = true;
			settingObj.maintenanceModeReason = 'serviceAccountSetupPending';

		}
		if(SimpplrContext.isDemoAnalyticsEnabled==false) {
			// Staging MixPanel
			if(String.isBlank(SimpplrContext.packageName) || SimpplrContext.isTestOrg || SimpplrContext.isSandbox) {
				settingObj.simpplrMixpanelProjectToken = '4307794dfe05ddb0769e824b8884d805';
			} else {
				// Production MixPanel
				settingObj.simpplrMixpanelProjectToken = 'ff806c0fa0a2f6f04cfe7b602257cb27';
			}
	    }
		settingObj.isExternalSearchIndexing = !(SimpplrContext.isFlowExternalSearchEnabled && SimpplrContext.isExternalSearchActiveEnabled);
		settingObj.isPublicFilesLinkEnabled = SimpplrContext.allowFileShareWithPublicLink;
		settingObj.simpplrVersion = ServiceConstants.RELEASE_VERSION;
		
		settingObj.jsPath = (String.isBlank(SimpplrContext.cdnPath) ? 
							'https://static.simpplr.com/simpplr/'+ServiceConstants.RELEASE_VERSION :
							SimpplrContext.cdnPath) + '/js/';
		settingObj.imgPath = 'https://static.simpplr.com/simpplr/img/';		
		settingObj.defaultFontCss = 'https://static.simpplr.com/simpplr/'+ServiceConstants.RELEASE_VERSION + '/css/font.min.css';		

		/*settingObj.simpplrGaCode = 'UA-49858407-6';
		https://simpplr.atlassian.net/browse/SV2-45241
		Removing this simpplrGaCode as we decided to stop making simpplr google analytics call 
		*/
		settingObj.isHomeAppManagerControlled = ServiceConstants.DASHBOARD_OWNER_APP_MANAGER.equalsIgnoreCase(SimpplrContext.AppDashboardMode);
		settingObj.isExpertiseAppManagerControlled = SimpplrContext.isExpertiseAppManagerControlled;
		settingObj.isExpertiseCreateAppManagerControlled = SimpplrContext.isExpertiseCreateAppManagerControlled;
		settingObj.isMobilePromotionEnabled = SimpplrContext.nativeAppEnabled && SimpplrContext.loginFromGenericAppAllowed && SimpplrContext.mobilePromotionEnabled;
		settingObj.isNativeAppEnabled = SimpplrContext.nativeAppEnabled;
		settingObj.isAndroidAppLinkAvailable = String.isNotBlank(SimpplrContext.androidAppLink);
		settingObj.contentSubmissionsEnabled = SimpplrContext.isPublicContributionAllowed;
		settingObj.peopleCustomFieldEnabled = SimpplrContext.isPeopleCategoryEnable;
		settingObj.peopleCustomFieldSingular = SimpplrContext.peopleCategorySingular;
		settingObj.peopleCustomFieldPlural = SimpplrContext.peopleCategoryPlural;
		settingObj.isSiteAppManagerControlled = ServiceConstants.SITE_DASHBOARD_OWNER_APP_MANAGER.equalsIgnoreCase(SimpplrContext.SiteDashboardMode);		
		settingObj.feedMode = SimpplrContext.feedMode;	
		settingObj.feedRichTextEnabled	= SimpplrContext.isFeedRichTextEnabled;
		settingObj.carouselSpeed = SimpplrContext.carouselSpeed;
		settingObj.notificationRefreshInterval = 30000;
		if(SimpplrContext.simpplrNotificationRefreshInterval != null && SimpplrContext.simpplrNotificationRefreshInterval > 30) {
			settingObj.notificationRefreshInterval = SimpplrContext.simpplrNotificationRefreshInterval * 1000;
		}
		settingObj.alertRefreshInterval = ServiceConstants.ALERT_REFRESH_INTERVAL * 1000;
		if(SimpplrContext.simpplrAlertRefreshInterval != null && SimpplrContext.simpplrAlertRefreshInterval > ServiceConstants.ALERT_REFRESH_INTERVAL) {
			settingObj.alertRefreshInterval = SimpplrContext.simpplrAlertRefreshInterval * 1000;
		}
		
		settingObj.feedOnContentEnabled = SimpplrContext.isCommentsAllowed;
		settingObj.loginTimeout = SimpplrContext.loginTimeout;
		settingObj.appName = SimpplrContext.applicationName;		

		settingObj.feedRefreshInterval = 60000;
		if(SimpplrContext.simpplrFeedRefreshInterval != null && SimpplrContext.simpplrFeedRefreshInterval > 60) {
			settingObj.feedRefreshInterval = SimpplrContext.simpplrFeedRefreshInterval * 1000;
		}
		settingObj.listingLoadSize = SimpplrContext.simpplrDefaultPageSize;
		settingObj.commentStagger = 10;								

		settingObj.homeDashboardLayout = SimpplrContext.tileLayout;
    	if(ServiceConstants.DASHBOARD_OWNER_USER.equalsIgnoreCase(SimpplrContext.AppDashboardMode)) {
			settingObj.homeDashboardLayout = UserContext.isTilesInitialized ? UserContext.tileLayout : getAppHomeDefaultLayout();
			  		
    	} else if(SimpplrContext.isSegmentsEnabled) {
    		settingObj.homeDashboardLayout = UserContext.segmentTileLayout;    		
		}
		
		settingObj.baseUrl = SimpplrContext.salesforceBaseUrl;
		settingObj.isEnhancedDomainEnabled = SimpplrContext.isEnhancedDomainEnabled;
		settingObj.contentUrl = Utility.getFileDownloadBaseURL();

		settingObj.addToCalendar = getAddToCalendar();
		settingObj.availableContentTypes = getAvailableContentTypes();
		settingObj.isUnlistedSitesEnabled = isUnlistedSitesEnabled();			
		settingObj.links = getLinks();
		settingObj.fileProviders = getFileProviders();		
		settingObj.integrations = getIntegrationSettings();
		settingObj.availableAudienceFieldTypes = getAvailableAudienceFieldTypes();

		settingObj.isAITopicSuggestionEnabled = SimpplrContext.aiTopicSuggestionEnabled;
		settingObj.isAIRelatedContentEnabled = SimpplrContext.aiRelatedContentEnabled;
		settingObj.isAIContentRecommendationEnabled = SimpplrContext.aiContentRecommendationEnabled;
		settingObj.isAIContentModerationFeatureEnabled = SimpplrContext.aiContentModerationFeatureEnabled;
		settingObj.isAIPersonalizedCarouselFeatureEnabled = SimpplrContext.aiPersonalizedCarouselFeatureEnabled;
		settingObj.isJwtAuthEnabled = SimpplrContext.isJwtAuthEnabled;
		if(SimpplrContext.aiContentModerationFeatureEnabled){
			settingObj.isAIContentModerationEnabled = SimpplrContext.aiContentModerationEnabled;
		}
		settingObj.isSiteAndLaunchpadAnalyticsEnabled = SimpplrContext.isSiteAndLaunchpadAnalyticsEnabled;
		
		if(SimpplrContext.isSandbox || SimpplrContext.isTestOrg || String.isBlank(SimpplrContext.packageName)) { 
			settingObj.externalAnalyticsJwtEndpoint = 'https://staging.api.simpplr.com/analytics-jwt/';
		} else {
			String externalAnalyticsUrl = SimpplrContext.appConfig != null ? SimpplrContext.appConfig.External_Analytics_URL__c : '';
			settingObj.externalAnalyticsJwtEndpoint = externalAnalyticsUrl.replace('analytics/', 'analytics-jwt/');
		}

		settingObj.isInitiativesAndCampaignsEnabled = SimpplrContext.isInitiativesAndCampaignsEnabled;

		if(settingObj.isAITopicSuggestionEnabled){
			settingObj.aiTopicSuggestionVersion = SimpplrContext.aiTopicSuggestionVersion;
		}
		if(settingObj.isAIRelatedContentEnabled){
			settingObj.aiRelatedContentVersion = SimpplrContext.aiRelatedContentVersion;
		}
		if(settingObj.isAIContentRecommendationEnabled){
			settingObj.aiContentRecommendationVersion = SimpplrContext.aiContentRecommendationVersion;
		}
		if(settingObj.isAIContentModerationFeatureEnabled){
			settingObj.aiContentModerationVersion = SimpplrContext.aiContentModerationVersion;
		}
		if(settingObj.isAIPersonalizedCarouselFeatureEnabled){
			settingObj.aiPersonalizedCarouselVersion = SimpplrContext.aiPersonalizedCarouselVersion;
		}
		settingObj.isTestOrg = SimpplrContext.isTestOrg;
		settingObj.isSandbox = SimpplrContext.isSandbox;
		settingObj.recognitionModuleUrl = SimpplrContext.simpplrAPIEndpoint+'/recognition/web/remoteEntry.js';
		settingObj.globalSearchUrl = SimpplrContext.simpplrAPIEndpointMFE+'/search/remoteEntry.js';
		settingObj.globalSearchBaseUrl = SimpplrContext.simpplrAPIEndpointMFE+'/search';
		settingObj.isOnboardingEnabled = SimpplrContext.isOnboardingEnabled;
		settingObj.isOnboardingContentExist = SimpplrContext.isOnboardingContentExist;
		if (SimpplrContext.isFeatureMicrosoftTeamsEnabledPhase2) {
			settingObj.isAlertsForTeamsEnabled = isAlertsEnabledForConectedApp(IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS);
		}
		settingObj.sisenseAnalyticsUrl = SimpplrContext.sisenseAnalyticsUrl;
		settingObj.isNewEditorEnabled = SimpplrContext.isNewEditorEnabled;
		settingObj.hasInitiatives = SimpplrContext.hasInitiatives;
		settingObj.isMyTeamsAnalyticsEnabled = SimpplrContext.isMyTeamsAnalyticsEnabled;
		settingObj.isMyTeamsAnalyticsSettingEnabled = SimpplrContext.isMyTeamsAnalyticsSettingEnabled;
		settingObj.isListenerSuiteForMyTeamsEnabled = SimpplrContext.isListenerSuiteForMyTeamsEnabled;
		settingObj.isPerceptionAnalyticsEnabled = SimpplrContext.isPerceptionAnalyticsEnabled;
		settingObj.isSlackUpgraded = checkSlackUpgradeStatus();
		return settingObj;
	}

	@testVisible
	private List<AppInitWrapper.AudienceField> getAvailableAudienceFieldTypes() {
		List<AppInitWrapper.AudienceField> availableAudienceFieldTypes = new List<AppInitWrapper.AudienceField>();

		Map<String, String> audienceAvailableFieldsMap = Utility.getLabelVsPeopleFieldMap();

		for(String audienceAvailableFieldName : audienceAvailableFieldsMap.keySet()){
			AppInitWrapper.AudienceField audienceFieldObj = new AppInitWrapper.AudienceField();

			audienceFieldObj.name = audienceAvailableFieldName;
			audienceFieldObj.label = audienceAvailableFieldName;
			// Override name & label for custom fields
			if(Utility.PEOPLE_CUSTOM_FIELDS_NAME_LIST.contains(audienceAvailableFieldsMap.get(audienceAvailableFieldName))){
				audienceFieldObj.name = audienceAvailableFieldsMap.get(audienceAvailableFieldName);
				audienceFieldObj.label = Utility.getPeopleCustomFieldsMap('apiNameVsUiLabel').get(audienceFieldObj.name);
			}

			availableAudienceFieldTypes.add(audienceFieldObj);
		}

		return availableAudienceFieldTypes;
	}

	@testVisible
	private String getAppHomeDefaultLayout() {
		String segmentId;
		if(SimpplrContext.isSegmentsEnabled && String.isNotBlank(UserContext.segmentId)){
			segmentId = UserContext.segmentId;
		}
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', segmentId);
		String query = 'Select id, Layout__c From App_Default__c where Type__c=\'home-default\' and Segment__c = :soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Default__c> appDefaultList = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		String layout = 'd';
   		if(!appDefaultList.isEmpty() && String.isNotBlank(appDefaultList[0].Layout__c)) {
			layout = appDefaultList[0].Layout__c;
   		}
		return layout;
	}

	private Boolean isServiceAccountSetupPending() {
		Boolean isServiceAccountSetupPending = true;
		if(SimpplrContext.Integrations.containsKey(IntegrationConstants.INTEGRATION_TYPE_SERVICE_ACCOUNT)) {
			isServiceAccountSetupPending = (SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_ACCOUNT).Owner.IsActive == false);
		} 
		return isServiceAccountSetupPending;
	}

	@testVisible 
	private ResponseWrapper getProfileFields(){
		ResponseWrapper responseWrapperObj = new ResponseWrapper();
		try{
			List<AudienceWrapper.ProfileFields> profileFieldList = new FilterService().getStandardProfileFieldList();
			List<CustomProfileField> customFieldList = new List<CustomProfileField>();
			if(String.isNotBlank(SimpplrContext.PPUserCustomFields)) {
				Map<String,Schema.SObjectField> userFields = User.SObjectType.getDescribe().fields.getMap();
				customFieldList = (List<CustomProfileField>)Json.deserialize(SimpplrContext.PPUserCustomFields, List<CustomProfileField>.class);
				for(CustomProfileField customFieldObj : customFieldList) {	
					if(String.isBlank(customFieldObj.syncSource)) {
						DescribeFieldResult resultObj = userFields.get(customFieldObj.fieldName).getDescribe();
						if (Schema.DisplayType.Picklist == resultObj.getType()) {
							customFieldObj.listOfOptions = getPickListOptions(resultObj.getPicklistValues());
							customFieldObj.fieldType = 'picklist';
						
						} else if (Schema.DisplayType.MultiPicklist == resultObj.getType()) {
							customFieldObj.listOfOptions = getPickListOptions(resultObj.getPicklistValues());
							customFieldObj.fieldType = 'multipicklist';

						} else {
							customFieldObj.fieldType = resultObj.getType().name();
						}
					}
				}
			}
			Map<String, Object> result = new Map<String, Object>();
			result.put('standard', profileFieldList);
			result.put('custom', customFieldList); 
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);

		}catch(Exception e){
			logger.logError('UtilityDataServer.getProfileFields()----Exception Occured----',e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return responseWrapperObj;
	}

	private List<String> getDismissedOnboardingFlags() {
		List<String> dismissedFlagList = new List<String>();		
		if (UserContext.getCurrentUserSettings != NULL ) {
			
			if (String.isNotBlank(UserContext.getCurrentUserSettings.Dismissed_Onboarding_Flags__c)) {
				dismissedFlagList.addAll(UserContext.getCurrentUserSettings.Dismissed_Onboarding_Flags__c.split(','));
			}
		}
		return dismissedFlagList;
	}
	private Boolean isBrandingNeedsRefresh() {
		Boolean brandingNeedsRefresh = true;
		if(SimpplrContext.isSegmentsEnabled && SimpplrContext.isSegmentBrandingEnabled) {
			if(String.isBlank(UserContext.segmentId)) {
				brandingNeedsRefresh = false;
			} else if(ServiceConstants.PACKAGE_VERSION.equalsIgnoreCase(UserContext.getCurrentUserInfo.Segment__r.Branding_Package_Version__c)) {
				brandingNeedsRefresh = false;
			}
		} else {
			if(ServiceConstants.PACKAGE_VERSION.equalsIgnoreCase(SimpplrContext.packageVersion)) {
				brandingNeedsRefresh = false;
			}
			
		}
		return brandingNeedsRefresh;
	}

	private List<CustomProfileField.Option> getPickListOptions(List<Schema.PicklistEntry> pickListEntries) {
		List<CustomProfileField.Option> optionList = new List<CustomProfileField.Option>();
		for(Schema.PicklistEntry pickList : pickListEntries) {
			CustomProfileField.Option optionWrapper = new CustomProfileField.Option();
			optionWrapper.label = pickList.getLabel();
			optionWrapper.value = pickList.getValue();
			optionList.add(optionWrapper);
		}
		return optionList;
	}

	private List<String> getAddToCalendar() {
		List<String> addToCalendarList = new List<String>();
		App_Config__c appConfigObj = SimpplrContext.appConfig;
		if(appConfigObj != null) {	
			if(appConfigObj.Calendar_App_Enabled__c){
				addToCalendarList.add('app');
			}
			if(appConfigObj.Calendar_Office365_Enabled__c){
				addToCalendarList.add('office365');
			}
			if(appConfigObj.Calendar_Google_Enabled__c){
				addToCalendarList.add('google');
			}
			if(appConfigObj.Calendar_Outlook_Web_Enabled__c){
				addToCalendarList.add('outlook');
			}
		}
		return addToCalendarList;
	}

	private Boolean isUnlistedSitesEnabled() {
		Boolean isUnlistedSitesEnabled = false;
		Schema.DescribeFieldResult collGrpTypeInfo = CollaborationGroup.CollaborationType.getDescribe();
		List <Schema.PicklistEntry> collGrpTypeVals = collGrpTypeInfo.getPicklistValues();
		for(Schema.PicklistEntry collGrpType : collGrpTypeVals){
			if('Unlisted'.equalsIgnoreCase(collGrpType.value)){
				isUnlistedSitesEnabled = true;
				break;
			}
		}
		return isUnlistedSitesEnabled;
	}

	private List<FilterAttributeWrapper> getFileProviders() {
		List<FilterAttributeWrapper> listOfFileProviders = new List<FilterAttributeWrapper>();  
		listOfFileProviders.add(new FilterAttributeWrapper('intranet','Intranet Files'));
		if(SimpplrContext.IsBoxIntegrationEnabled && UserContext.isBoxConnected) {
			listOfFileProviders.add(new FilterAttributeWrapper('box','Box Files'));
		}
		if (isAppIntegrationEnabled('dropbox') && hasUserConnectedAccount('dropbox')) {
			listOfFileProviders.add(new FilterAttributeWrapper('dropbox','Dropbox Files'));
        }
         
		if (isAppIntegrationEnabled('googledrive') && hasUserConnectedAccount('googledrive')) {
			listOfFileProviders.add(new FilterAttributeWrapper('googledrive', 'Google Drive Files'));
        }
        
		if (isAppIntegrationEnabled('sharepoint') && hasUserConnectedAccount('sharepoint')) {
			listOfFileProviders.add(new FilterAttributeWrapper('sharepoint','SharePoint Files'));
		} 
		if (isAppIntegrationEnabled('onedrive') && hasUserConnectedAccount('onedrive')) {
			listOfFileProviders.add(new FilterAttributeWrapper('onedrive','OneDrive Files'));
		}		
		if(isCRMEnabled) {
			listOfFileProviders.add(new FilterAttributeWrapper('crm','CRM Files'));
		}

		return listOfFileProviders;
	}

	private Boolean isCRMEnabled { get{
		if(isCRMEnabled == null) {
			FolderDao folderDaoObj = new FolderDao();
			isCRMEnabled = folderDaoObj.isCRMAvailable();
		}
		return isCRMEnabled;
	}set; }
	private List<String> getAvailableContentTypes() {
		List<String> availableContentTypes = new List<String>();
		if(SimpplrContext.AllowedFeatures.containsIgnoreCase(AccessManager.FEATURE_PAGE)){
			availableContentTypes.add('page');
		}
		if(SimpplrContext.AllowedFeatures.containsIgnoreCase(AccessManager.FEATURE_EVENT)){
			availableContentTypes.add('event');
		}
		if(SimpplrContext.AllowedFeatures.containsIgnoreCase(AccessManager.FEATURE_ALBUM)){
			availableContentTypes.add('album');
		}
		if(SimpplrContext.AllowedFeatures.containsIgnoreCase(AccessManager.FEATURE_BLOG)){
			availableContentTypes.add('blog');
		}
		return availableContentTypes;
	}

	private Simpplr_Site__c getPopularSite() {
		Simpplr_Site__c popularSite;
		String userId=UserContext.id;
		List<String> allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).split(',');
		String query = 'select CollaborationGroupid from collaborationGroupMember where CollaborationGroup.IsArchived=false And memberid=:userId ';
		
		if(SimpplrContext.isCommunitiesEnabled){
			query += ' AND NetworkId = null ';
		}
		query += 'order by CollaborationGroup.memberCount desc limit 1';
		List<collaborationGroupMember> cgmList = Database.query(query);
		if(!cgmList.isEmpty()) {
			List<Simpplr_Site__c> siteList = [select id, Layout__c,
											(SELECT id FROM Simpplr_Carousel_Contents__r WHERE Is_Deleted__c = false 
														And (Item_Type__c = 'external' 
																	OR (Item_Type__c = 'Campaign' And Social_Campaign__r.Audience__c = null 
																			AND Social_Campaign__r.Is_Active__c = true)
																OR (Item_Type__c = 'Content' And Simpplr_Content__r.is_published__c=true 
																			AND Simpplr_Content__r.is_deleted__c=false 
																			AND Simpplr_Content__r.Activated_By_Feature__c=true 
																			AND Simpplr_Content__r.Type__c IN : allowedFeaturesInAppList)
															)
														limit 1),
											(SELECT id FROM Tiles_Config_Simpplr_Site__r WHERE Is_Deleted__c = false AND 
												(People__c = null OR People__c = :UserContext.peopleId) LIMIT 1)
											from Simpplr_Site__c where chatter_group_id__c =:cgmList[0].CollaborationGroupId
											And Landing_page__c='dashboard'
											And show_in_Simpplr__c=true WITH SECURITY_ENFORCED];
			
			if(!siteList.isEmpty()) {
				popularSite = siteList[0];    			
			}
		}
		return popularSite;
	}

	private AppInitWrapper.IntegrationSettings getIntegrationSettings() {
		AppInitWrapper.IntegrationSettings integrations = new AppInitWrapper.IntegrationSettings();
		integrations.box = SimpplrContext.IsBoxIntegrationEnabled;
		integrations.googledrive = isAppIntegrationEnabled('googledrive');
		integrations.dropbox = isAppIntegrationEnabled('dropbox');
		integrations.onedrive = isAppIntegrationEnabled('onedrive');
        integrations.sharepoint = isAppIntegrationEnabled('sharepoint');
		integrations.atlassian = isAppIntegrationEnabled('atlassian');
		integrations.googleCalendar = SimpplrContext.AllowedFeatures.containsIgnoreCase(AccessManager.FEATURE_EVENT) && 
									  isAppIntegrationEnabled('googlecalendar');

		integrations.outlookCalendar = SimpplrContext.AllowedFeatures.containsIgnoreCase(AccessManager.FEATURE_EVENT) && 
									  isAppIntegrationEnabled('outlookcalendar');

        if (integrations.googledrive) { 
            integrations.isMyDriveEnabled = SimpplrContext.myDriveEnabled;
            integrations.isSharedDriveEnabled = SimpplrContext.sharedDriveEnabled;
            integrations.showOpenInGoogleDrive = SimpplrContext.showOpenInGoogleDrive;
            integrations.googleManagedPermission = SimpplrContext.googleManagedPermission;
        }
		if (integrations.sharepoint) {
			integrations.showOpenInSharePoint = SimpplrContext.showOpenInSharePoint;
		}
		if (integrations.box) { 
			integrations.showOpenInBox = SimpplrContext.showOpenInBox;
			integrations.boxManagedPermission = SimpplrContext.boxManagedPermission;
		}
 
		integrations.isSharePointFullSearchEnabled = integrations.sharepoint && 
													EFSConstants.SHAREPOINT_FULL_SEARCH_CLIENT_ID
														.equalsIgnoreCase(SimpplrContext.Integrations.get('sharepoint').Client_id__c);
		integrations.servicenow = SimpplrContext.isServiceNowConnected;
		integrations.confluence = SimpplrContext.confluenceEnabled;
		integrations.embedly = SimpplrContext.EmbedlyEnabled;
		integrations.crm = isCRMEnabled;
		integrations.okta = SimpplrContext.isOktaEnabled;
		integrations.onelogin = SimpplrContext.isOneLoginEnabled;
		integrations.slack = SimpplrContext.slackIntegrationEnabled;
		integrations.microsoftTeams = SimpplrContext.microsoftTeamsIntegrationEnabled;
		integrations.workday = SimpplrContext.workdayIntegrationEnabled;
		integrations.activeDirectory = isAppIntegrationEnabled('adsi') || isAppIntegrationEnabled('activedirectory');
		integrations.google = isAppIntegrationEnabled('googleusersync');
		integrations.ukgPro = SimpplrContext.ukgProIntegrationEnabled;

		// changed made to stop loading google analytics js if GA is not enabled in customer org.
		//https://simpplr.atlassian.net/browse/SV2-45241
		
		if((SimpplrContext.enableGoogleAnalytics3 && SimpplrContext.isGAEnabled) || (FeatureFlagManager.isFeatureEnabled('ga4_integration') == false && SimpplrContext.enableGoogleAnalytics3)){
			integrations.googleAnalytics = new AppInitWrapper.GoogleAnalyticsSettings();
			integrations.googleAnalytics.trackingCode = SimpplrContext.GATrackingCode;
			integrations.googleAnalytics.isDemographyInterests = SimpplrContext.isGADemographyInterests;
			integrations.googleAnalytics.isEnhancedLinkAttribution = SimpplrContext.isGAEnhancedLinkAttribution;
		}
		
		if(FeatureFlagManager.isFeatureEnabled('ga4_integration') && SimpplrContext.enableGoogleAnalytics4  && SimpplrContext.isGAEnabled){
			integrations.googleAnalytics4 = new AppInitWrapper.GoogleAnalyticsSettings4();
			integrations.googleAnalytics4.isEnableGoogleAnalytics4 = SimpplrContext.enableGoogleAnalytics4;
			integrations.googleAnalytics4.trackingCode4 = SimpplrContext.GATrackingCode4;
			
		}

		integrations.isGa4IntegrationFlagEnabled=FeatureFlagManager.isFeatureEnabled('ga4_integration');

		integrations.servicenowKnowledgebaseName = String.isBlank(SimpplrContext.ServiceNowCustomKBName) ? '' : SimpplrContext.ServiceNowCustomKBName;
		integrations.servicenowTicketingSystem = String.isBlank(SimpplrContext.ServiceNowCustomTicketingName) ? '' : SimpplrContext.ServiceNowCustomTicketingName;

		integrations.confluenceKnowledgebaseName = String.isBlank(SimpplrContext.confluenceCustomKBName) ? '' : SimpplrContext.confluenceCustomKBName;
		integrations.isServiceNowTicketEnabled = SimpplrContext.isServiceNowTicketEnabled;
		integrations.isServiceNowKnowledgebaseEnabled = SimpplrContext.isServiceNowKnowledgebaseEnabled;
		integrations.isServiceNowTicketCreationEnabled = SimpplrContext.isServiceNowTicketCreationEnabled;
		
		integrations.campaignSocialNetworks = SimpplrContext.appIntegrationEnabledSet;

		integrations.enterpriseSearch = new Map<String, AppInitWrapper.EnterpriseSearchSettings>();
		if(SimpplrContext.Integrations != null){
			for(String enterpriseSearch : IntegrationConstants.ENTERPRISE_SEARCH_INTEGRATION_NAME_LIST){
				if(SimpplrContext.Integrations.containsKey(enterpriseSearch) && SimpplrContext.Integrations.get(enterpriseSearch).Integration_Enabled__c){
					AppInitWrapper.EnterpriseSearchSettings enterpriseSearchWrapper = new AppInitWrapper.EnterpriseSearchSettings();
					enterpriseSearchWrapper.isEnabled = true;
					enterpriseSearchWrapper.provider = SimpplrContext.Integrations.get(enterpriseSearch).Data__c;
					enterpriseSearchWrapper.url = SimpplrContext.Integrations.get(enterpriseSearch).Endpoint_Url__c;

					integrations.enterpriseSearch.put(enterpriseSearch, enterpriseSearchWrapper);
				}
			}
		}

		integrations.isAtlassianVPNWarningVisible = SimpplrContext.showAtlassianVPNMessage <> null ? SimpplrContext.showAtlassianVPNMessage : false; 
		integrations.isActiveDirectoryGroupsEnabled = SimpplrContext.isActiveDirectoryEnabled &&
			SimpplrContext.adIntegrationEnabled && SimpplrContext.isActiveDirectoryGroupsEnabled;
		integrations.googleMultiDomainUpgradeStatus = SimpplrContext.googleMultiDomainUpgradeStatus != 
		ServiceConstants.UPGRADE_STATUS_IN_PROGRESS ? SimpplrContext.googleMultiDomainUpgradeStatus : GoogleDriveService.validateGoogleMultiDomainStatus();
		return integrations;
	}

	private AppInitWrapper.LinkSettings getLinks() {
		AppInitWrapper.LinkSettings links = new AppInitWrapper.LinkSettings();
		links.appsDownload = SimpplrContext.AppDownloadInfoURL;
		links.generateExternalLink = 'https://links.simpplr.com/?u=';
		links.knowledge = PageContext.getPageURL(Pages.KnowledgeCategories);

		if(SimpplrContext.IsBoxIntegrationEnabled) {
			if(IntegrationConstants.BOX_CLIENT_ID.equalsIgnoreCase(SimpplrContext.BoxClientId)) {
				links.connectBoxAccount = ServiceConstants.BOX_CONNECT_URL + 
										'&client_id=' + SimpplrContext.BoxClientId +
										'&redirect_uri=' +  EncodingUtil.urlEncode(SimpplrContext.simpplrAPIEndpoint + '/oauth/box-oauth-manager', 'UTF-8') + 
										'&state=' + EncodingUtil.urlEncode(PageContext.getPageURL(Pages.StorageSettings) + '?state=Box', 'UTF-8');
			} else {
				links.connectBoxAccount = ServiceConstants.BOX_CONNECT_URL + 
											'&state=Box'  +
											'&client_id=' + SimpplrContext.BoxClientId +
											'&redirect_uri=' +  SimpplrContext.salesforceBaseUrl  + 
											Page.StorageSettings.getUrl() + '?type=box'; 
			}
		} 
		if(isAppIntegrationEnabled('googledrive')) {
			links.connectGdriveAccount = new GoogleDriveHelper().getPeopleAuthUrl();
		}
		if(isAppIntegrationEnabled('dropbox')) {
			links.connectDropboxAccount = EFSAccessService.getAuthURL('dropbox');
		}
		if(isAppIntegrationEnabled('onedrive')) {
			links.connectOnedriveAccount = EFSAccessService.getAuthURL('onedrive');
		}
		if(isAppIntegrationEnabled('sharepoint')) {
			links.connectSharepointAccount = EFSAccessService.getAuthURL('sharepoint');
		}

		links.serviceNowInstanceUrl = SimpplrContext.serviceNowInstanceUrl;
		if (SimpplrContext.isServiceNowConnected) {
				IntegrationService integrationServiceObj = new IntegrationService(UserContext.peopleId);
				integrationServiceObj.setIntegrationVariables(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW); 
				links.connectServicenowAccount = integrationServiceObj.getAuthPage();
		}

		links.atlassianInstanceUrl = SimpplrContext.atlassianInstanceUrl;
		if (SimpplrContext.isAtlassianConnected) {
				AtlassianHelper atlassianHelperObj = new AtlassianHelper();
				links.connectAtlassianAccount = atlassianHelperObj.getPeopleAuthUrl();
		}

		links.logout = SimpplrContext.salesforceBaseUrl + '/secur/logout.jsp';		
		links.salesforce = '/home/home.jsp';
		links.pageRedirectUrl = SimpplrContext.simpplrPageRedirectUrl + '/lp?';
		return links;
	}

	@testVisible 
	private ResponseWrapper suggestTopics(String requestData){
		logger.logDebug('UtilityDataServer.suggestTopics()------requestData--'+requestData);

		ResponseWrapper responseWrapperObj = new ResponseWrapper();
		try{
			Map<String, String> mapOfParams = (Map<String, String>) JSON.deserialize(requestData, Map<String, String>.class);
	        String inputText = (String)mapOfParams.get('text');
			String title = (String)mapOfParams.get('title');
			if(String.isNotBlank(inputText)){
				inputText = inputText.replaceAll('<[^>]+>', '');
			}
			Map<String, Object> responseBody = new Map<String, Object>();
			if(SimpplrContext.aiTopicSuggestionEnabled) {
				responseWrapperObj = getSuggestedTopics(inputText,title);
				logger.logDebug(responseWrapperObj.status);
				if(responseWrapperObj.status == 'error'){
					FeedServiceProvider serviceProvider = new FeedServiceProvider();
					responseBody = serviceProvider.suggestTopics(inputText);
					String message = 'AI is enabled but AI failed';
					responseBody.put('message',message);
					responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, responseBody);
				}
			} else {
				FeedServiceProvider serviceProvider = new FeedServiceProvider();
				responseBody = serviceProvider.suggestTopics(inputText);
				String message = 'AI is not enabled';
				responseBody.put('message',message);
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, responseBody);
			}

			return responseWrapperObj;

		}catch(Exception e){
			logger.logError('Could not retrieve Topic suggestions',e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		logger.logDebug('UtilityDataServer.suggestTopics()----responseWrapperObj----'+responseWrapperObj);
		return responseWrapperObj;
	}

	private ResponseWrapper getSuggestedTopics(String inputText,String title) {
		List<TopicWrapper> topicList = new List<TopicWrapper>();
        Map<String, Object> requestBody = new Map<String, Object>();
        Map<String, Object> responseBody = new Map<String, Object>();
		ResponseWrapper responseWrapperObj = new ResponseWrapper();
		try {
			String externalEndPoint = SimpplrContext.simpplrAPIEndpoint + '/content/topic-suggest';
			requestBody.put('action', 'suggest-topic');
			requestBody.put('orgId', SimpplrContext.simpplrOrgId);
			requestBody.put('peopleId', UserContext.peopleId);
			requestBody.put('version', ServiceConstants.TOPIC_SUGGESTION_API_VERSION);
			if (String.isNotBlank(inputText)) {
				requestBody.put('input_text', inputText);
			}
			if (String.isNotBlank(title)) {
				requestBody.put('content_title', title);
			}
			Map<String, String> mapOfCustomHeader = new Map<String, String>();
			mapOfCustomHeader.put('jwttoken', Utility.getJWTToken());

			HttpResponse res = Utility.getResponseFromAWS(externalEndPoint, requestBody, mapOfCustomHeader);

			String suggestedTopicsJson='';

			if (res.getStatusCode() == 200) {
				suggestedTopicsJson =res.getBody();
				AIWrapper.TopicWrapper topicsWrapper = (AIWrapper.TopicWrapper)JSON.deserialize(suggestedTopicsJson, AIWrapper.TopicWrapper.class);
			
				for(AIWrapper.TopicsTagWrapper tagObj : topicsWrapper.listOfTopics){
					TopicWrapper topicObj = new TopicWrapper();
					topicObj.topicName = tagObj.tagName;
					if(tagObj.tagId!=null){
						topicObj.topicId = tagObj.tagId;
					}
					
					topicList.add(topicObj);
				}
				responseBody.put('topicList', topicList);
				responseBody.put('message','AI is enabled');
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, responseBody);
			} else {
				logger.logDebug('UtilityDataServer.getSuggestedTopics()-----Error-- '+ res.getStatusCode());
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
			}
		} catch (Exception e) {
			logger.logDebug('UtilityDataServer.getSuggestedTopics()-----Exception-- '+ e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}

		return responseWrapperObj;
	}

	/**
	* @description this method allows to get Accesstoken using JWT for listener Suite
	* @return ResponseWrapper - with access token from AWS
	*/
	private ResponseWrapper getListenerSuiteJwt() {
		ResponseWrapper responseObj = new ResponseWrapper();
		try{
			String endpoint = SimpplrContext.listenerSuiteURL + '/v1/authenticate';
			Map<String, String> claims = new Map<String, String>();
			claims.put('firstName', UserContext.firstName);
			claims.put('lastName', UserContext.lastName);
			claims.put('language', UserContext.languageLocaleKey);
			claims.put('timezone', UserContext.timeZoneSIDKey);
			claims.put('location', UserContext.getCurrentUserInfo.Country__c);
			claims.put('locationId', UserContext.getCurrentUserInfo.city__c + ' @@ ' + UserContext.getCurrentUserInfo.state__c + ' @@ ' + UserContext.getCurrentUserInfo.country__c );
			claims.put('department', UserContext.getUsersDepartmentDetail);
			claims.put('departmentId',String.isNotBlank(UserContext.getUsersDepartmentDetail) ? UserContext.getUsersDepartmentDetail.toLowerCase() : null);
			claims.put('peopleId',UserContext.peopleId);

			Map<String, Boolean> permissions = new Map<String, Boolean>();
			permissions.put('isAppManager', UserContext.isUserAppModerator);
			permissions.put('canManageSentimentCheck', getCanManageSentimentFlag());
			permissions.put('canManageSurveys', UserContext.canManageSurveys);

			Map<String, Object> requestBody = new Map<String, Object>();
			requestBody.put('orgId', SimpplrContext.simpplrOrgId);
			requestBody.put('sub', UserContext.userId); //the user id (sub = subject/who the token relates to)
			requestBody.put('sessionId', UserInfo.getSessionId());
			requestBody.put('claims', claims);
			requestBody.put('permissions', permissions);

			Map<String, String> customHeaders = new Map<String, String>();
			customHeaders.put('X-Api-Key',SimpplrContext.listenerSuiteAPIKey);
			HttpResponse response =	Utility.getResponseFromAWS(endpoint, requestBody, customHeaders);
			responseObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, JSON.deserializeUntyped(response.getBody()));
		} catch (Exception e){
			logger.logDebug('UtilityDataServer.getListenerSuiteJwt()-----Exception-- '+ e);
			responseObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return responseObj;
	}

	/**
	 * @description this method allows to get Accesstoken using JWT
	 * @return ResponseWrapper - with access token from AWS
	 */
	private ResponseWrapper getJWTToken() {
		logger.logDebug('API : '+Utility.getSimpDri());
		ResponseWrapper responseObj = new ResponseWrapper();
		try{
			String endpoint = SimpplrContext.simpplrAPIEndpoint + '/jwt';
			// Moved creation of JWT token body to Utility.cls to be used by other methods as well
			Map<String, Object> requestBody = Utility.getJwtTokenRequestBody();
			HttpResponse response =	Utility.getResponseFromAWS(endpoint, requestBody);
			responseObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, JSON.deserializeUntyped(response.getBody()));
		} catch (Exception e){
			logger.logDebug('UtilityDataServer.getJWTToken()-----Exception-- '+ e);
			responseObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return responseObj;
	}

	/**
	* @description this method allows to get Accesstoken using JWT
	* @return ResponseWrapper - with access token from AWS
	*/
	private ResponseWrapper getSSJWTToken() {
		ResponseWrapper responseObj = new ResponseWrapper();
		try{
			String endpoint = SimpplrContext.simpplrAPIEndpoint + '/ssjwt';

			Map<String, Object> requestBody = new Map<String, Object>();
			requestBody.put('iss', 'odin-sisense');
			requestBody.put('jti', Request.getCurrent().getRequestId());
			requestBody.put('sub', UserContext.peopleId);
			requestBody.put('firstName', UserContext.firstName);
			requestBody.put('lastName', UserContext.lastName);
			requestBody.put('email', UserInfo.getUserEmail());
			HttpResponse response =	Utility.getResponseFromAWS(endpoint, requestBody);
			responseObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, JSON.deserializeUntyped(response.getBody()));
		} catch (Exception e){
			logger.logDebug('UtilityDataServer.getSSJWTToken()-----Exception-- '+ e);
			responseObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return responseObj;
	}

	/**
	 * @description this method returns available timezones
	 * @return ResponseWrapper - available timezoones
	 */
	private ResponseWrapper getAvailableTimezones() {
		ResponseWrapper responseObj = new ResponseWrapper();
		try{
			List<String> timeZones = new List<String>(); 
			Schema.DescribeFieldResult fieldResult = User.TimeZoneSidKey.getdescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
			for(Schema.PicklistEntry p : ple) {	
				timeZones.add(p.getValue());
			}
			Map<String, Object> resultMap = new Map<String, Object>();
			resultMap.put('listOfTimezones', timeZones);	
			responseObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, resultMap);
		} catch (Exception e){
			logger.logDebug('UtilityDataServer.getAvailableTimezones()-----Exception-- '+ e);
			responseObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return responseObj;
	}
	private Boolean getCanManageSentimentFlag() {
        Boolean canManageSentiment = UserContext.canManageSentimentCheck;
        if(!canManageSentiment) {
            Map<String, Object> soqlParamMap = new Map<String, Object>();
            soqlParamMap.put('soqlParam1', UserContext.peopleId);
            String queryStr =   ' Select id from Site_Role__c WHERE Is_Deleted__c=false ' +
                                ' And Site__r.Is_Active__c=true  And Site__r.Show_In_Simpplr__c = true ' + 
                                ' And Site__r.Is_Deleted__c=false And (Is_Manager__c = true or Is_Content_Manager__c = true) ' + 
                                ' And People__c=: soqlParam1 ' ; 

            if(String.isNotBlank(UserContext.segmentId)) {
                soqlParamMap.put('soqlParam2', UserContext.segmentId);
                queryStr += ' And Site__c in (select site__c from Segment_Site__c ' +
                        ' Where Segment__c = :soqlParam2 And Is_Featured__c = true) ';
            } else {
                queryStr += ' And Site__r.Is_Featured__c=true ';
            }
            queryStr += ' Limit 1';
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
            List<Site_Role__c> siteRoleList = (List<Site_Role__c>)SIMPESAPI.accessController().queryAsUSer(queryStr, soqlParamMap); 
            if(!siteRoleList.isEmpty()) {
                canManageSentiment = true;
            }
        }
        return canManageSentiment;
    }

	public class LabelValueData {
		public String label;
		public String value;
	}

	/**
	 * @description this method allows to get if posting of alert to specified integrated app is enabled
	 * @return ResponseWrapper - a boolean value which specifies enabled(true) or disabled(false)
	 */
	public boolean isAlertsEnabledForConectedApp(String integrationType) {
        App_Integration__c appInt = SimpplrContext.Integrations.get(integrationType);
		return  SimpplrContext.Integrations != null && SimpplrContext.Integrations.containsKey(integrationType) && 
                appInt.Integration_Enabled__c && appInt.Alerts_For_App_Enabled__c;
	}

	private ResponseWrapper getDeferredAppConfig(){
		ResponseWrapper responseWrapperObj = new ResponseWrapper();
		try{
			validatePlatformCaching();
			AppInitWrapper.DeferredAppConfig wrapperObj = new AppInitWrapper.DeferredAppConfig();
			wrapperObj.currentUser = getDeferredUserConfig();
			wrapperObj.settings = getDeferredAppSettings();

			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, wrapperObj);

		} catch (Exception e) {
			logger.logError('UtilityDataServer.getDeferredAppConfig()----could not fetch DeferredAppConfig----',e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}

		return responseWrapperObj;
	}

	private AppInitWrapper.DeferredUserConfig getDeferredUserConfig() {
		AppInitWrapper.DeferredUserConfig userDetails = new AppInitWrapper.DeferredUserConfig();
		Map<String, DateTime> mapDismissedFlag = getdismissedFlagList();
		if(mapDismissedFlag.get('connect-account-prompt') == null) {
			HelpDao daoObj = new HelpDao();
			Help_Text__c helpTextObj = daoObj.getDismissibleFlashesHelpTextId('connect-account-prompt', 'Task');
			if(helpTextObj != null && helpTextObj.CreatedDate != null) {
				userDetails.newIntegrations = daoObj.getNewIntegrationsEnabled(helpTextObj.CreatedDate);
				userDetails.showConnectAccountsPrompt=true;
			}
		} else {
			HelpDao daoObj = new HelpDao();
			userDetails.newIntegrations = daoObj.getNewIntegrationsEnabled(mapDismissedFlag.get('connect-account-prompt'));
			userDetails.showConnectAccountsPrompt=false;
		}
		List<String> dismissedFlags = new List<String>();	
		for(String df: mapDismissedFlag.keySet()) {
			dismissedFlags.add(df);
		}
		userDetails.dismissedFlags = dismissedFlags;
		userDetails.dismissibleFlashes = getDismissibleFlashList();
		userDetails.dismissedOnboardingFlags = getDismissedOnboardingFlags();
		return userDetails;
	}

	private AppInitWrapper.DeferredAppSettings getDeferredAppSettings() {
		AppInitWrapper.DeferredAppSettings settingObj = new AppInitWrapper.DeferredAppSettings();
		settingObj.popularContentUrl = new ManageContentDao().getMostPopularPublicContentURL();
		Simpplr_Site__c popularSite = getPopularSite();
		if(popularSite != null) {
			settingObj.popularSiteId = popularSite.id;
			if(String.isBlank(popularSite.Layout__c)) {
				settingObj.popularSiteDashboardLayout = 'd';
			} else {
				settingObj.popularSiteDashboardLayout = popularSite.Layout__c.toLowerCase();
			}
			settingObj.popularSiteHasCarousel = popularSite.Simpplr_Carousel_Contents__r.isEmpty() == false;
			settingObj.popularSiteHasTiles = popularSite.Tiles_Config_Simpplr_Site__r.isEmpty() == false;
		}	
		return settingObj;
	}

	public Boolean checkSlackUpgradeStatus() {
		Boolean isSlackUpgraded = false;
		if(SimpplrContext.isSlackPhase2FeatureEnabled) {
			App_Integration__c appInt = SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SLACK);
			isSlackUpgraded = appInt != null ? appInt.Is_Slack_Upgraded__c : true ;
		} else {
			isSlackUpgraded = false;
		}
		return isSlackUpgraded;
	}

	private ResponseWrapper resetCDCRetryCount() {
		ResponseWrapper responseObj = new ResponseWrapper();
		try{
			BatchMigrateRecords job = new BatchMigrateRecords('resetCDCRetryCount', false);
    		Database.executeBatch(job,2000);
			responseObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
		} catch (Exception e){
			logger.logDebug('UtilityDataServer.resetCDCRetryCount()-----Exception-- '+ e);
			responseObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return responseObj;
	}

	@testVisible
	private void clearPartitionCache(){
		if (SimpplrContext.isPlatformCachingFeatureEnabled){
			String partitionName = 'Local.Cache';
			if(!String.isBlank(SimpplrContext.namespacePrefix)){
				partitionName = 'Simpplr.Cache';
			}
			Cache.OrgPartition orgPart = Cache.Org.getPartition(partitionName);
			if(orgPart != null){
				Set<String> allKeys = orgPart.getKeys();
				if(allKeys!=null && allKeys.size()>0){
					for(String key : allKeys){
						orgPart.remove(key);
					}
				}
			}
		}
	}
}