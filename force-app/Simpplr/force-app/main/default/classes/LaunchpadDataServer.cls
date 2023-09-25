/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class LaunchpadDataServer extends DataServer{
	
	@TestVisible private static final String UNAUTHORIZED_ENDPOINT_OKTA = 'Unauthorized endpoint, please check Setup->Security->Remote site settings and ensure that Okta is added there.';
	@TestVisible private static final String UNAUTHORIZED_ENDPOINT_ONELOGIN = 'Unauthorized endpoint, please check Setup->Security->Remote site settings and ensure that OneLogin is added there.';
	@Testvisible private static final Integer AAPS_PER_PAGE = 500; 
	@Testvisible private final String ACTION_VALUE_SEARCH = 'search'; 
    
    @Testvisible private final String REQUEST_PARAM_DATA = 'data';
    
	List<LaunchpadWrapper> listOfLaunchpadApplications;
	List<LaunchpadWrapper> allAppsFromSSOProvider {get;set;}
	Boolean isSSOConfigured {get;set;}
	public static String  oktaUserName {get;set;}
	
    
    public LaunchpadDataServer() {
		
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
        	logger.logDebug('LaunchpadDataServer----entered handleRequest----');
	    	
            String action = readParam(REQUEST_PARAM_ACTION);
        	
            if(String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
            }
            
            if(ACTION_VALUE_SEARCH.equalsIgnoreCase(action)) {
                response = search(action);
            }else{
                throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            }
            
        }catch(Exception ex) {
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
    
    @Testvisible 
    private ResponseWrapper search(String requestData){
		ResponseWrapper responseWrapperObj = null;
		try {
			logger.logDebug('LaunchpadDataServer.search()----requestData----'+requestData);
			
			Map<String, Object> resultMap = new Map<String, Object>();
			Boolean useSegmentAppsNLinks = SimpplrContext.isSegmentsEnabled && SimpplrContext.isSegmentAppsNLinksEnabled;
			Segment__c segmentObj;
			if(useSegmentAppsNLinks) {
				segmentObj = getUserSegment();
			}
			resultMap.put('listOfApps', getResultList(useSegmentAppsNLinks, segmentObj));
			resultMap.put('listOfLinks', getCustomLinksList(useSegmentAppsNLinks, segmentObj));
			
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, resultMap);
			logger.logDebug('LaunchpadDataServer.search()----responseWrapperObj----'+responseWrapperObj);
        
		} catch(exception e){
  				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}

		return responseWrapperObj;
    }

	/**
	 * @description getUserSegment - segmentId in which user exists
	 * @return segment
	 */
	private Segment__c getUserSegment() {
		String segmentId = UserContext.getCurrentUserInfo.Segment__c;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', segmentId);
		String query = 'Select id, SSO_Provider__c, Custom_Links_JSON__c, SSO_Custom_JSON__c from Segment__c Where Id = :soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Segment__c> segmentList = (List<Segment__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		return segmentList[0];
	}
    
    /**
     * @description getCustomLinksList
     * @param useSegmentAppsNLinks
     * @param segmentObj
     * @return customlinksList
     */
    @Testvisible 
    private List<ManageApplicationWrapper.CheckboxLink> getCustomLinksList(Boolean useSegmentAppsNLinks, Segment__c segmentObj){
		List<ManageApplicationWrapper.CheckboxLink> customlinksList = new List<ManageApplicationWrapper.CheckboxLink>();
		String jsonCustomLinksString = useSegmentAppsNLinks ? segmentObj.Custom_Links_JSON__c : SimpplrContext.appConfig.Custom_Links_JSON__c; 
		
		if(String.isNotBlank(jsonCustomLinksString)){
			List<ManageApplicationWrapper.CheckboxLink> dbCustomlinksList = (List<ManageApplicationWrapper.CheckboxLink>)Json.deserialize(jsonCustomLinksString, List<ManageApplicationWrapper.CheckboxLink>.class);
			for (ManageApplicationWrapper.CheckboxLink customlinkObj : dbCustomlinksList){
				if(customlinkObj.onOff){
					customlinksList.add(customlinkObj);
				}
			}
		}
		customlinksList.sort();
		logger.logDebug('LaunchpadDataServer.getCustomLinksList() ' + customlinksList);
		return customlinksList;
    }
    
    /**
     * @description getResultList
     * @param useSegmentAppsNLinks
     * @param segmentObj
     * @return appsData
     */
    @Testvisible 
    private List<LaunchpadWrapper> getResultList(Boolean useSegmentAppsNLinks, Segment__c segmentObj){    	
		listOfLaunchpadApplications=new List<LaunchpadWrapper>();
		String ssoProvider = useSegmentAppsNLinks ? segmentObj.SSO_Provider__c : SimpplrContext.SSOProvider;
		String customAppsJsonStr = useSegmentAppsNLinks ? segmentObj.SSO_Custom_JSON__c : SimpplrContext.CustomSSOJSON;
		ssoProvider = ssoProvider == null ? '' : ssoProvider;
		isSSOConfigured = false;

		validateAppsProvider(ssoProvider, customAppsJsonStr);
		
		if('okta'.equalsIgnoreCase(ssoProvider) 
			&& SimpplrContext.isOktaEnabled 
			&& String.isNotBlank(SimpplrContext.OktaAPIToken) 
			&& String.isNotBlank(SimpplrContext.OktaLink)) {
				
				isSSOConfigured = true;
				List<LaunchpadWrapper> userApps=getAllOktaApps(SimpplrContext.OktaLink, SimpplrContext.OktaAPIToken);
				listOfLaunchpadApplications.addAll(userApps);
		} else if ('onelogin'.equalsIgnoreCase(ssoProvider)
			&& SimpplrContext.isOneLoginEnabled 
		 	&& String.isNotBlank(SimpplrContext.OneLoginAPIToken) 
		 	&& String.isNotBlank(SimpplrContext.OneLoginEmbeddingToken)
		 	&& String.isNotBlank(SimpplrContext.OneLoginLink)){
		 		isSSOConfigured = true;
				List<LaunchpadWrapper> userApps=getAllOneLoginApps(SimpplrContext.OneLoginAPIToken, SimpplrContext.OneLoginEmbeddingToken, SimpplrContext.OneLoginLink);
				listOfLaunchpadApplications.addAll(userApps);
		} else if ('custom'.equalsIgnoreCase(ssoProvider)){
			// Pull custom data from here
			isSSOConfigured = true;
			List<LaunchpadWrapper> userApps = getAllCustomApps(useSegmentAppsNLinks, segmentObj);
			listOfLaunchpadApplications.addAll(userApps);
		} else if('microsoft'.equalsIgnoreCase(ssoProvider) 
			&& SimpplrContext.adIntegrationEnabled && checkADSIEnabled()) {

            isSSOConfigured = true;
            List<LaunchpadWrapper> userApps = getAllActiveDirectoryApps();
            listOfLaunchpadApplications.addAll(userApps);
		}
		logger.logDebug('LaunchpadDataServer.getResultList()----listOfLaunchpadApplications----'+listOfLaunchpadApplications);
		return listOfLaunchpadApplications;
    }

    /**
     * @description validateAppsProvider - throw error if token or json not available againt provider
     * @param ssoProvider
     * @param customAppsJsonStr
     */
    private void validateAppsProvider(String ssoProvider, String customAppsJsonStr) {
        if((String.isBlank(SimpplrContext.OktaAPIToken) && 'okta'.equalsIgnoreCase(ssoProvider)) ||
            (String.isBlank(SimpplrContext.OneLoginAPIToken) && 'onelogin'.equalsIgnoreCase(ssoProvider)) ||
            (String.isBlank(customAppsJsonStr) && 'custom'.equalsIgnoreCase(ssoProvider))) {
            
            throw new SimpplrException(ServiceConstants.ERROR_404);
        }
    }
    
    @Testvisible 
	private List<LaunchpadWrapper> getAllOneLoginApps (String apiToken, String embedToken, String oneLoginBaseUrl){
		logger.logDebug('LaunchpadDataServer.getAllOneLoginApps()----apiToken----'+apiToken+'----embedToken----'+embedToken+'----oneLoginBaseUrl----'+oneLoginBaseUrl);
		if(allAppsFromSSOProvider==null) {
			allAppsFromSSOProvider=new List<LaunchpadWrapper>();
			try{

				Blob vector = Blob.valueOf(ServiceConstants.CRYPTO_INITIALIZATION_VECTOR);
				Blob cryptoKey = EncodingUtil.base64Decode(SimpplrContext.DataKey);
				Blob cipherText = EncodingUtil.base64Decode(apiToken);
				String decodedApiToken = Crypto.decrypt('AES128', cryptoKey, vector, cipherText).toString();

				String endPoint=oneLoginBaseUrl+'/client/apps/embed2?token='+embedToken+'&email='+UserContext.getCurrentUserInfo.Email__c;
				HttpResponse res=getJsonResponseWithBasicAuth(endPoint,decodedApiToken,'x');
				allAppsFromSSOProvider= convertXmlToListObject(res.getBody());
			} catch(Exception ex) {
				logger.logError('System Error occurred while getting applications from OneLogin:', ex);
				if(ex.getMessage().containsIgnorecase('Unauthorized endpoint')) {
					throw new SimpplrException(LaunchpadDataServer.UNAUTHORIZED_ENDPOINT_ONELOGIN);
				} else {
					throw ex;
				}
			}
		}
		logger.logDebug('LaunchpadDataServer.getAllOneLoginApps()----allAppsFromSSOProvider----'+allAppsFromSSOProvider);
		return allAppsFromSSOProvider;
	}
	
	/**
	 * @description getAllCustomApps
	 * @param useSegmentAppsNLinks
	 * @param segmentObj
	 * @return customAppsData
	 */
	@Testvisible 
	private List<LaunchpadWrapper> getAllCustomApps(Boolean useSegmentAppsNLinks, Segment__c segmentObj){
		
		if(allAppsFromSSOProvider==null) {
			allAppsFromSSOProvider=new List<LaunchpadWrapper>();
			String jsonCustomApplicationsString = useSegmentAppsNLinks ? segmentObj.SSO_Custom_JSON__c : SimpplrContext.appConfig.SSO_Custom_JSON__c; 
			
			allAppsFromSSOProvider=(List<LaunchpadWrapper>)Json.deserialize(jsonCustomApplicationsString,List<LaunchpadWrapper>.class);
		}
		logger.logDebug('LaunchpadDataServer.getAllCustomApps()----allAppsFromSSOProvider----'+allAppsFromSSOProvider);
		return allAppsFromSSOProvider;
	}

    /**
     * @description checkADSIEnabled
     * @return boolean - integrationEnabledOrNot
     */
    private Boolean checkADSIEnabled (){
        String appIntQuery = 'SELECT Id, Client_Id__c, Client_Secret__c, App_Access_Token__c,'
            + ' App_Refresh_Token__c, User_Email__c, User_Name__c'
            + ' FROM App_Integration__c WHERE Is_Deleted__c = false AND Name = :soqlParam1';
        Map<String, Object> sqlParamMap = new Map<String, Object>();
        sqlParamMap.put('soqlParam1', IntegrationConstants.INTEGRATION_TYPE_ADSI);

        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<App_integration__c> appIntegrationList = (List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, sqlParamMap);
        
        return (!appIntegrationList.isEmpty() && String.isNotBlank(appIntegrationList[0].Client_Id__c)
            && String.isNotBlank(appIntegrationList[0].App_Access_Token__c));
    }
	
	@TestVisible 
	private List<LaunchpadWrapper> convertXmlToListObject(String xmlBody){
		logger.logDebug('LaunchpadDataServer.convertXmlToListObject()----xmlBody----'+xmlBody);
		List<LaunchpadWrapper> listOfLaunchPadWrapper = new List<LaunchpadWrapper> ();
		
		if(String.isNotBlank(xmlBody)){
			DOM.Document xmlDoc= new Dom.Document();
			xmlDoc.load(xmlBody);
			Dom.XMLNode appsNode = xmlDoc.getRootElement();
			List<Dom.XmlNode> xmlChildNodes=appsNode.getChildren();
			
			for(Dom.XmlNode singleAppNode: xmlChildNodes) {
				if('app'.equalsIgnoreCase(singleAppNode.getName())) {
				    String appId=singleAppNode.getChildElement('id', null).getText();
				    String name= singleAppNode.getChildElement('name', null).getText();
				    String icon= singleAppNode.getChildElement('icon', null).getText();
				    LaunchpadWrapper temp = new LaunchpadWrapper();
				    temp.url='https://app.onelogin.com/launch/'+appId;
				    temp.img=icon;
				    temp.name=name;
				    listOfLaunchPadWrapper.add(temp);
				}
			}
			listOfLaunchPadWrapper.sort();
			
		}
		logger.logDebug('LaunchpadDataServer.convertXmlToListObject()----listOfLaunchPadWrapper----'+listOfLaunchPadWrapper);
		return listOfLaunchPadWrapper;
	}
	
	@Testvisible 
	private List<LaunchpadWrapper> toLaunchpadWrapper(Map<String, Object> appDetailsMap){
		List<LaunchpadWrapper> launchpadWrapperList = new List<LaunchpadWrapper>();  
		LaunchpadWrapper launchpadWrapperObj = null;
		
		if(appDetailsMap.get('value') != null){
			List<Object> appObjList = (List<Object>) appDetailsMap.get('value');
			for (Object appObj : appObjList){
				Map<String, Object> appObjMap = (Map<String, Object>) appObj;
				launchpadWrapperObj = new LaunchpadWrapper();
				
				launchpadWrapperObj.name = (String)appObjMap.get('displayName');
				
				if(appObjMap.get('info') != null){
					Map<String, Object> infoMap = (Map<String, Object>) appObjMap.get('info');
					
					launchpadWrapperObj.img = (String) infoMap.get('logoUrl');
				}
				
		        launchpadWrapperObj.url = 'https://account.activedirectory.windowsazure.com/applications/redirecttoapplication.aspx?Operation=SignIn&applicationId=' + ((String) appObjMap.get('appId'));
		        launchpadWrapperList.add(launchpadWrapperObj);
			}
		}
		
		return launchpadWrapperList;
	}
	
	@Testvisible 
	private List<LaunchpadWrapper> getAllActiveDirectoryApps() {
		logger.logDebug('LaunchpadDataServer.getAllActiveDirectoryApps()');
		if(allAppsFromSSOProvider == null) {
			allAppsFromSSOProvider = new List<LaunchpadWrapper>();
			try {
				Map<String, Object> appDetailMap = this.getMicrosoftApps();
				
				if(appDetailMap != null){
		        	 allAppsFromSSOProvider = toLaunchpadWrapper(appDetailMap);
		        	 if(allAppsFromSSOProvider != null) {
		        	 	allAppsFromSSOProvider.sort();
		        	 }
		        }
			} catch (Exception ex) {
				logger.logError('System Error occurred while getting applications from Microsoft:', ex);
				throw ex;
			}
		}
		logger.logDebug('LaunchpadDataServer.getAllActiveDirectoryApps()----allAppsFromSSOProvider----'+allAppsFromSSOProvider);
		return allAppsFromSSOProvider;
	}
	
	@Testvisible
	private Map<String, Object> getMicrosoftApps(){
		// Request the enpoint
		Map<String, Object> result = null;
		String endpoint = 'https://graph.microsoft.com/beta/applications?$select=id,appId,logo,info,displayName';
		
		String accessToken = this.getMicrosoftAccessToken();
		
		logger.logDebug('TOKEN: ' + accessToken);
		
		try{
			if(String.isNotBlank(endpoint)){
				Http h = new Http();
				
				HttpRequest req = new HttpRequest();
				req.setEndpoint(endpoint);
				req.setMethod('GET');
				req.setHeader('Authorization', 'Bearer ' + accessToken);
				req.setHeader('Accept', 'application/json');
				req.setTimeout(60000);
				
				HTTPResponse response = h.send(req);
				
				if(response.getStatusCode() == 200){
					String bodyStr = response.getBody();
					
					if(String.isNotBlank(bodyStr)){
						 result = ((Map<String, Object>) JSON.deserializeUntyped(bodyStr));
					}
				} else {
					throw new SimpplrException('Failed to list Apps with status 200');
				}
			}
		}catch(Exception ex){
			logger.logDebug('LaunchpadDataServer (failed to list Apps from Microsoft): ' + ex);
			throw ex;
		}
		
		return result;
	}
	
	@Testvisible
	private String getMicrosoftAccessToken(){
		String accessToken = null;
		try{
			if(SimpplrContext.adIntegrationEnabled){
				IntegrationService adIS = new IntegrationService('adsi', null);
				
				if(adIS.appAccessTokenExpired()) {
					adIS.exchangeCode(adIS.appIntegrator.App_Refresh_Token__c, false);
					logger.logDebug('Exchange Code successfull.');
				}
				
				accessToken = adIS.appIntegrator.App_Access_Token__c;
				logger.logDebug('Access token: ' + accessToken);
			} else {
				throw new SimpplrException('Active Directory is not enabled.');
			}
		}catch(Exception ex){
			logger.logDebug('LaunchpadDataServer - Failed while getting token of Microsoft App Listing:' + ex);
			throw ex;
		}
		
		return accessToken;
	}
	
	@Testvisible 
	private List<LaunchpadWrapper> getAllOktaApps(String oktaUrl,String token) {
		logger.logDebug('LaunchpadDataServer.getAllOktaApps()----oktaUrl----'+oktaUrl+'----token----'+token);
		if(allAppsFromSSOProvider==null) {
			allAppsFromSSOProvider=new List<LaunchpadWrapper>();
			try {
				HTTPResponse res;
				Map<String, Object> userDetails;

				Blob vector = Blob.valueOf(ServiceConstants.CRYPTO_INITIALIZATION_VECTOR);
				Blob cryptoKey = EncodingUtil.base64Decode(SimpplrContext.DataKey);
				Blob cipherText = EncodingUtil.base64Decode(token);
				String oktaApiToken = Crypto.decrypt('AES128', cryptoKey, vector, cipherText).toString();

				if('11'.equalsIgnoreCase(SimpplrContext.OktaPeopleNameFormat)) {
					res = getJsonResponse(oktaUrl + '/api/v1/users?q=' + getOktaLogin() + '&limit=1',oktaApiToken);
					List<Object> usersList = (List<Object>)JSON.deserializeUntyped(res.getBody());
					if(usersList.size() > 0) {
						userDetails = (Map<String, Object>)usersList[0];
					}
				} else {
					res = getJsonResponse(oktaUrl + '/api/v1/users/' + getOktaLogin(),oktaApiToken);
					userDetails=(Map<String, Object>)JSON.deserializeUntyped(res.getBody());
				}
		        if(userDetails != null && userDetails.get('errorSummary')==null){
		        	 res=getJsonResponse(oktaUrl + '/api/v1/users/' + userDetails.get('id') + '/appLinks',oktaApiToken);
		        	 allAppsFromSSOProvider= createListOfLaunchpadApplications((List<Object>)JSON.deserializeUntyped(res.getBody()));
		        	 if(allAppsFromSSOProvider != null) {
		        	 	allAppsFromSSOProvider.sort();
		        	 }
		        }
			} catch (Exception ex) {
				logger.logError('System Error occurred while getting applications from Okta:',ex);
				if(ex.getMessage().containsIgnorecase('Unauthorized endpoint')) {
					throw new SimpplrException(LaunchpadDataServer.UNAUTHORIZED_ENDPOINT_OKTA);
				} else {
					throw ex;
				}
			}
		}
		logger.logDebug('LaunchpadDataServer.getAllOktaApps()----allAppsFromSSOProvider----'+allAppsFromSSOProvider);
		return allAppsFromSSOProvider;
	}
	
	@Testvisible 
	private List<LaunchpadWrapper> createListOfLaunchpadApplications(List<Object> appDetails) {
		logger.logDebug('LaunchpadDataServer.createListOfLaunchpadApplications()----appDetails----'+appDetails);
		List<LaunchpadWrapper> appList=new List<LaunchpadWrapper>();
        LaunchpadWrapper LaunchpadWrapperObj;
        for(Object appDetail:appDetails) {
        	Map<String,Object> application = (Map<String,Object>)appDetail;
	        LaunchpadWrapperObj=new LaunchpadWrapper();
	        LaunchpadWrapperObj.name=(String)application.get('label');
	        LaunchpadWrapperObj.img=(String)application.get('logoUrl');
	        LaunchpadWrapperObj.url=(String)application.get('linkUrl');
	        if(LaunchpadWrapperObj.name!=null && LaunchpadWrapperObj.img!=null && LaunchpadWrapperObj.url!=null) {
	        	appList.add(LaunchpadWrapperObj);
	        }
        }
        logger.logDebug('LaunchpadDataServer.createListOfLaunchpadApplications()----appList----'+appList);
        return appList;
	}
	
	@TestVisible 
	private String getOktaLogin() {
		if(oktaUserName == null) {
			oktaUserName = '';
			String oktaUserNameFormat = SimpplrContext.OktaPeopleNameFormat;
			if(String.isBlank(oktaUserNameFormat)) {
				oktaUserNameFormat = '10';
			}
			if(oktaUserNameFormat == '0') {
				oktaUserName = UserInfo.getFirstName().trim();
			} else if(oktaUserNameFormat == '1') {
				oktaUserName = UserInfo.getFirstName().trim() + UserInfo.getLastName().trim(); 
			} else if(oktaUserNameFormat == '2') {
				oktaUserName = UserInfo.getFirstName().substring(0,1) + UserInfo.getLastName().trim(); 
			} else if(oktaUserNameFormat == '3') {
				oktaUserName = UserInfo.getFirstName().trim() + UserInfo.getLastName().substring(0,1); 
			} else if(oktaUserNameFormat == '4') {
				oktaUserName = UserInfo.getFirstName().trim() + '.' + UserInfo.getLastName().trim(); 
			} else if(oktaUserNameFormat == '5') {
				oktaUserName = UserInfo.getFirstName().substring(0,1) + '.' +  UserInfo.getLastName().trim(); 
			} else if(oktaUserNameFormat == '6') {
				oktaUserName = UserInfo.getFirstName().trim() + '.' + UserInfo.getLastName().substring(0,1); 
			} else if(oktaUserNameFormat == '7') {
				oktaUserName = UserInfo.getFirstName().trim() + '_' + UserInfo.getLastName().trim(); 
			} else if(oktaUserNameFormat == '8') {
				oktaUserName = UserInfo.getFirstName().substring(0,1) + '_' +  UserInfo.getLastName().trim(); 
			} else if(oktaUserNameFormat == '9') {
				oktaUserName = UserInfo.getFirstName().trim() + '_' + UserInfo.getLastName().substring(0,1); 
			} else if(oktaUserNameFormat == '10') {
				oktaUserName = UserInfo.getUserName();
			} else if(oktaUserNameFormat == '11') {
				oktaUserName = UserInfo.getUserEmail();
			} else if(oktaUserNameFormat == '12') {
				oktaUserName = UserInfo.getUserName().split('@')[0];
			} else if(oktaUserNameFormat == '13') {
				oktaUserName = UserInfo.getUserEmail().split('@')[0];
			}
		}
		logger.logDebug('LaunchpadDataServer.getOktaLogin()----oktaUserName----'+oktaUserName);
		return oktaUserName;
	}
	
	@Testvisible 
	private HTTPResponse getJsonResponse(String url,String pToken) {
		logger.logDebug('LaunchpadDataServer.getJsonResponse()----url----' + url);
		HttpRequest req = new HttpRequest();
     	req.setEndpoint(url);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'SSWS ' + pToken);
        req.setMethod('GET');
        Http http = new Http();
		HTTPResponse response = http.send(req);
        logger.logDebug('LaunchpadDataServer.getJsonResponse()----response----' + response);
		logger.logDebug('LaunchpadDataServer.getJsonResponse()----response body----' + response.getBody());
		return response;
	}
	
	@Testvisible 
	private HTTPResponse getJsonResponseWithBasicAuth(String endPoint, String authUsername, String authPassword){
		logger.logDebug('LaunchpadDataServer.getJsonResponseWithBasicAuth()----endPoint----'+endPoint+'----authUsername----'+authUsername+'----authPassword----'+authPassword);
		HTTP h = new HTTP();
		HTTPRequest r = new HTTPRequest();
		r.setEndpoint(endPoint);
		Blob headerValue = Blob.valueOf(authUsername + ':' + authPassword);
		String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
		r.setHeader('Authorization', authorizationHeader);
		r.setHeader('Accept', 'application/json');
		r.setMethod('GET');
		HTTPResponse response = h.send(r);
		logger.logDebug('LaunchpadDataServer.getJsonResponseWithBasicAuth()----response----'+response);
		return response;
	}
	
	public  class LaunchpadWrapper implements Comparable{
	    public String url {get;set;}
	    public String img {get; set;}
	    public String name {get; set;}
	    
	    public Integer compareTo(Object compareTo) {
	    	LaunchpadWrapper launchpadWrapperObj = (LaunchpadWrapper) compareTo;
	    	if(name==null || launchpadWrapperObj.name==null){
	    		return 0;
	    	}
	    	if (name > launchpadWrapperObj.name) return 1;
            if (name < launchpadWrapperObj.name) return -1;
            return 0;
	    }
	}  
}