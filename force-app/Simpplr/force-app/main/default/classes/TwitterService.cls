public with sharing class TwitterService {
	private final String ERROR_DUPLICATE_POST = 'It\'s not possible to share duplicate Social Campaigns to Twitter';
	private final String ERROR_NOT_PERFORMING_CAMPAIGN_TWITTER = 'Unable to perform action';
	public static final String REDIRECT_URL_STRING = 'https://services.simpplr.com/oauth/redirect/code_passthrough.php';
	public class TwitterRequestTokenResponse{
		public String oauth_token;
		public String oauth_token_secret;
		public String oauth_callback_confirmed;
	}
	
	public class TwitterAccessTokenResponse{
		public String oauth_token;
		public String oauth_token_secret;
		public String screen_name;
		public String user_id;
		public String x_auth_expires;
	}
	
	public class TwitterPostResponse{
		public String id_str;
	}				
	 
	public String getTwitterRequestToken(String requestPageURL){
		TwitterService.TwitterRequestTokenResponse twitterReqResponse = new TwitterService.TwitterRequestTokenResponse();
		Map<String, String> twitterAuthorisationMap = new Map<String, String>();
		if(String.isNotBlank(requestPageURL)) {
			twitterAuthorisationMap.put('requestPageURL', requestPageURL);
		}
		String authorisationString = generateTwitterAuthorisationString(twitterAuthorisationMap);
		HttpResponse res = Utility.getJsonResponseFromExternalSystem(IntegrationConstants.POST_REQUEST_TYPE,IntegrationConstants.TWITTER_REQUEST_ENDPOINT, authorisationString, '');
		
		if(res.getStatusCode() == 200){
			PageReference twitterParamPage = new PageReference(SimpplrContext.salesforceBaseUrl + '?' + res.getBody());			
			if('true'.equalsIgnoreCase(twitterParamPage.getParameters().get('oauth_callback_confirmed'))){
				twitterReqResponse.oauth_token = twitterParamPage.getParameters().get('oauth_token');
				twitterReqResponse.oauth_token_secret = twitterParamPage.getParameters().get('oauth_token_secret');
				twitterReqResponse.oauth_callback_confirmed = twitterParamPage.getParameters().get('oauth_callback_confirmed');
			}
		}
		
		if(String.isNotBlank(twitterReqResponse.oauth_token)){
    		String pageString = IntegrationConstants.TWITTER_AUTH_ENDPOINT + twitterReqResponse.oauth_token;
    		return pageString;    			
		}
		else{
			return '';
		}
			
	}
			
	public String generateTwitterAuthorisationString(Map<String, String> twitterAuthorisationMap){
		String headerString = '';
			String token = twitterAuthorisationMap.get('token');
			String secret = twitterAuthorisationMap.get('secret');
			String stringToTweet = twitterAuthorisationMap.get('stringToTweet');
			String twitterPostId = twitterAuthorisationMap.get('twitterPostId');
			String requestPageURL = twitterAuthorisationMap.get('requestPageURL');
					
			IntegrationService intService = new IntegrationService(IntegrationConstants.INTEGRATION_TYPE_TWITTER, UserContext.peopleId);
			String consumerKey = '';
			String consumerSecret = '';
			String signature = '';
			Map<String, String> twitterSignatureMap = new Map<String, String>();			

			if(String.isNotBlank(intService.integrator.id)){
				consumerKey = intService.integrator.App_Integration__r.Client_Id__c;
				consumerSecret = intService.integrator.App_Integration__r.Client_Secret__c;
			} else if(intService.appintegrator != null){
				consumerKey = intService.appIntegrator.Client_Id__c;
				consumerSecret = intService.appIntegrator.Client_Secret__c;			
			} 		
					
			String timestamp = String.valueOf(DateTime.now().getTime()/1000); 
			String nonce = String.valueOf(UserInfo.getUserId() + String.valueOf(DateTime.now().getTime()));
			Map<String, String> oauth_params = new Map<String, String>(); //store oauth params for signature generation   
			oauth_params.put(EncodingUtil.urlEncode('oauth_version', IntegrationConstants.CHARSET_UTF8), EncodingUtil.urlEncode('1.0', IntegrationConstants.CHARSET_UTF8));
			oauth_params.put(EncodingUtil.urlEncode('oauth_nonce', IntegrationConstants.CHARSET_UTF8), EncodingUtil.urlEncode(nonce, IntegrationConstants.CHARSET_UTF8));
			oauth_params.put(EncodingUtil.urlEncode('oauth_timestamp', IntegrationConstants.CHARSET_UTF8), EncodingUtil.urlEncode(timestamp, IntegrationConstants.CHARSET_UTF8));
			oauth_params.put(EncodingUtil.urlEncode('oauth_consumer_key', IntegrationConstants.CHARSET_UTF8), EncodingUtil.urlEncode(consumerKey, IntegrationConstants.CHARSET_UTF8));
			oauth_params.put(EncodingUtil.urlEncode('oauth_signature_method', IntegrationConstants.CHARSET_UTF8), EncodingUtil.urlEncode('HMAC-SHA1', IntegrationConstants.CHARSET_UTF8));
			
			if(String.isNotBlank(token)){
				oauth_params.put(EncodingUtil.urlEncode('oauth_token', IntegrationConstants.CHARSET_UTF8), EncodingUtil.urlEncode(token, IntegrationConstants.CHARSET_UTF8));
				
			} else {
				
				String stateParam = intService.getRedirectUri() + '?state=' + IntegrationConstants.INTEGRATION_TYPE_TWITTER;
				if(String.isNotBlank(requestPageURL)) {
					stateParam += '&retURL=' + EncodingUtil.urlEncode(requestPageURL, 'UTF-8');
					
				} 
				String oauthCallbackParam = REDIRECT_URL_STRING + '?state=' + EncodingUtil.urlEncode(stateParam, IntegrationConstants.CHARSET_UTF8);
				oauth_params.put(EncodingUtil.urlEncode('oauth_callback', IntegrationConstants.CHARSET_UTF8), EncodingUtil.urlEncode(oauthCallbackParam, IntegrationConstants.CHARSET_UTF8));
					
			}

			
			
			if(String.isNotBlank(stringToTweet)){
				oauth_params.put(EncodingUtil.urlEncode('status', IntegrationConstants.CHARSET_UTF8), EncodingUtil.urlEncode(stringToTweet, IntegrationConstants.CHARSET_UTF8).replaceAll('\\+','%20'));
				twitterSignatureMap.put('stringToTweet', stringToTweet);
			}
			twitterSignatureMap.put('httpMethod', IntegrationConstants.POST_REQUEST_TYPE);
			
			if(String.isNotBlank(twitterPostId)){
				oauth_params.put(EncodingUtil.urlEncode('id', IntegrationConstants.CHARSET_UTF8), EncodingUtil.urlEncode(twitterPostId, IntegrationConstants.CHARSET_UTF8).replaceAll('\\+','%20'));
				twitterSignatureMap.put('httpMethod', IntegrationConstants.GET_REQUEST_TYPE);
				twitterSignatureMap.put('twitterPostId', twitterPostId);
			}			
			
			if(String.isNotBlank(secret)){
				twitterSignatureMap.put('secret', secret);
			}
			
			if(String.isNotBlank(consumerSecret)){
				twitterSignatureMap.put('consumerSecret', consumerSecret);
			}	
			
			signature = generateTwitterSignatureString(twitterSignatureMap, oauth_params);
			if(String.isNotBlank(signature)){
				oauth_params.put(EncodingUtil.urlEncode('oauth_signature', IntegrationConstants.CHARSET_UTF8), EncodingUtil.urlEncode(signature, IntegrationConstants.CHARSET_UTF8));
			}
			headerString = 'OAuth ';
	
			for(String paramKey : oauth_params.keySet()) {
				headerString += paramKey + '="' + oauth_params.get(paramkey) + '", ';
			}
		return headerString;	
	} 

	
	public String generateTwitterSignatureString(Map<String, String> twitterSignatureMap, Map<String, String> oauth_params) { 
	    Blob signature;	
			String httpMethod = twitterSignatureMap.containsKey('httpMethod')?twitterSignatureMap.get('httpMethod'):'';
			String secret = twitterSignatureMap.containsKey('secret')?twitterSignatureMap.get('secret'):'';
			String stringToTweet = twitterSignatureMap.containsKey('stringToTweet')?twitterSignatureMap.get('stringToTweet'):'';
			String consumerSecret = twitterSignatureMap.containsKey('consumerSecret')?twitterSignatureMap.get('consumerSecret'):'';
			String twitterPostId = twitterSignatureMap.containsKey('twitterPostId')?twitterSignatureMap.get('twitterPostId'):'';
			    	 
		    String signatureBase = '';
			if(String.isNotBlank(stringToTweet)){
		   		signatureBase = IntegrationConstants.TWITTER_POST_ENDPOINT.removeEnd('?status=');	 		
		    } else if(String.isNotBlank(twitterPostId)){
		   		signatureBase = IntegrationConstants.TWITTER_GET_TWEET_DETAILS.removeEnd('?id=');	 		
		    } else {
		   		signatureBase = IntegrationConstants.TWITTER_REQUEST_ENDPOINT; 		
		    }
		
		    signatureBase = httpMethod.toUpperCase() + '&' + EncodingUtil.urlEncode(signatureBase, IntegrationConstants.CHARSET_UTF8) + '&';
		
		    //sort parameters  before appending to signature 
		    List<string> sortParams = new List<string>(oauth_params.keySet());
		    sortParams.sort();
			
			String paramString = '';
		    //append all the params for signature
		    for(String param_key : sortParams) {
		        paramString += param_key + '=' + oauth_params.get(param_key) + '&';
		    }
			paramString = paramString.removeEndIgnoreCase('&');
			signatureBase += EncodingUtil.urlEncode(paramString, IntegrationConstants.CHARSET_UTF8);
		    String signatureKey = EncodingUtil.urlEncode(consumerSecret, IntegrationConstants.CHARSET_UTF8) + '&' + (String.isNotBlank(secret)? EncodingUtil.urlEncode(secret, IntegrationConstants.CHARSET_UTF8):'');
		
		    signature = Crypto.generateMac('HmacSHA1', Blob.valueOf(signatureBase), Blob.valueOf(signatureKey));
	    return EncodingUtil.base64Encode(signature);
	
	}
	
	public Boolean saveAccessToken(String token, String code) { 
		TwitterAccessTokenResponse twitterAccessResponse = new TwitterAccessTokenResponse();
		Map<String, String> twitterAuthorisationMap = new Map<String, String>();
		twitterAuthorisationMap.put('token', token);
		String authorisationString = generateTwitterAuthorisationString(twitterAuthorisationMap);
		HttpResponse res = Utility.getJsonResponseFromExternalSystem(IntegrationConstants.POST_REQUEST_TYPE,IntegrationConstants.TWITTER_TOKEN_ENDPOINT + code, authorisationString, '');    					
		
		if(res.getStatusCode() == 200){
			PageReference twitterParamPage = new PageReference(SimpplrContext.salesforceBaseUrl + '?' + res.getBody());
			twitterAccessResponse.oauth_token = twitterParamPage.getParameters().get('oauth_token');
			twitterAccessResponse.oauth_token_secret = twitterParamPage.getParameters().get('oauth_token_secret');
			twitterAccessResponse.screen_name = twitterParamPage.getParameters().get('screen_name'); 
			twitterAccessResponse.user_id = twitterParamPage.getParameters().get('user_id');
			twitterAccessResponse.x_auth_expires = twitterParamPage.getParameters().get('x_auth_expires');
			saveAccessTokenToDB(twitterAccessResponse);
			return true;
		}
		return false;
	}	

	public void saveAccessTokenToDB(TwitterAccessTokenResponse twitterAccessResponse) { 
		IntegrationService intServiceObj = new IntegrationService(IntegrationConstants.INTEGRATION_TYPE_TWITTER, UserContext.peopleId);
		DateTime currentTime = DateTime.now();
		if(String.isBlank(intServiceObj.integrator.id)){
			intServiceObj.integrator.name = IntegrationConstants.INTEGRATION_TYPE_TWITTER;
			intServiceObj.integrator.Access_Token__c = twitterAccessResponse.oauth_token;
			intServiceObj.integrator.Access_Token_Requested_Datetime__c = currentTime;
			intServiceObj.integrator.Access_Token_Expiration_Datetime__c =  currentTime.addYears(20);
			intServiceObj.integrator.Access_Token_Expiry__c = currentTime.addYears(20).getTime() - currentTime.getTime();
			intServiceObj.integrator.Access_Token_Secret__c = twitterAccessResponse.oauth_token_secret;
			intServiceObj.integrator.App_Integration__c = intServiceObj.appIntegrator.id;
			intServiceObj.integrator.User_Name__c = twitterAccessResponse.screen_name;
			intServiceObj.integrator.External_Id__c = twitterAccessResponse.user_id;
			intServiceObj.integrator.People__c = UserContext.peopleId;
			intServiceObj.integrator.User__c = UserContext.userId;
			if(UserContext.getCurrentUserInfo != null){
				intServiceObj.integrator.OwnerId = UserContext.getCurrentUserInfo.User__c;
			}	

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().insertAsUser(intServiceObj.integrator, new List<Schema.SObjectField>{
					People_Integration__c.name,
					People_Integration__c.Access_Token__c,
					People_Integration__c.Access_Token_Requested_Datetime__c,
					People_Integration__c.Access_Token_Expiration_Datetime__c,
					People_Integration__c.Access_Token_Expiry__c,
					People_Integration__c.Access_Token_Secret__c,
					People_Integration__c.App_Integration__c,
					People_Integration__c.User_Name__c,
					People_Integration__c.External_Id__c,
					People_Integration__c.People__c,
					People_Integration__c.User__c,
					People_Integration__c.OwnerId
					});

		} else {
			intServiceObj.integrator.Access_Token__c = twitterAccessResponse.oauth_token;
			intServiceObj.integrator.Access_Token_Requested_Datetime__c = System.now();
			intServiceObj.integrator.Access_Token_Secret__c = twitterAccessResponse.oauth_token_secret;
			intServiceObj.integrator.User_Name__c = twitterAccessResponse.screen_name;
			intServiceObj.integrator.External_Id__c = twitterAccessResponse.user_id;
			intServiceObj.integrator.Access_Token_Expiration_Datetime__c =  currentTime.addYears(20);
			intServiceObj.integrator.Access_Token_Expiry__c = currentTime.addYears(20).getTime() - currentTime.getTime();
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(intServiceObj.integrator, new List<Schema.SObjectField>{
					People_Integration__c.Access_Token__c,
					People_Integration__c.Access_Token_Requested_Datetime__c,
					People_Integration__c.Access_Token_Secret__c,
					People_Integration__c.User_Name__c,
					People_Integration__c.External_Id__c,
					People_Integration__c.Access_Token_Expiration_Datetime__c,
					People_Integration__c.Access_Token_Expiry__c
					});
		}
	}
	
	public void postOnTwitter(Social_Campaign__c socialCampaign, String stringToTweet) {
		stringToTweet = (stringToTweet.length() < 257 ? stringToTweet : stringToTweet.subString(0,256)) ; 
		if(String.isNotBlank(socialCampaign.Url__c)){
			stringToTweet = stringToTweet +  ' ' + socialCampaign.Url__c;
		}
		String intType = IntegrationConstants.INTEGRATION_TYPE_TWITTER;
		String peopleId = UserContext.peopleId;
		
		List<People_Integration__c> peopleIntegrationList = new List<People_Integration__c>();	
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', peopleId);
		soqlParamMap.put('soqlParam2', intType);
		String queryStr = 'SELECT c.Name, c.Id, c.Access_Token__c, c.Access_Token_Secret__c, c.Access_Token_Requested_Datetime__c, c.Access_Token_Expiry__c, c.External_Id__c,'+
					   			' c.People__c, c.User__c,  c.User_Email__c, c.User_Name__c, c.App_Integration__c'+
								' FROM People_Integration__c c '+
								' WHERE c.People__c =: soqlParam1  '+
								' AND   c.Is_Deleted__c = false  '+
								' AND	  c.Name = :soqlParam2 '+
								' LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		peopleIntegrationList = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
		if(!peopleIntegrationList.isEmpty()){
			Map<String, String> twitterAuthorisationMap = new Map<String, String>();
			twitterAuthorisationMap.put('token', peopleIntegrationList[0].Access_Token__c);
			twitterAuthorisationMap.put('secret', peopleIntegrationList[0].Access_Token_Secret__c);
			twitterAuthorisationMap.put('stringToTweet', stringToTweet);						
			
			String authorisationString = generateTwitterAuthorisationString(twitterAuthorisationMap);
			HttpResponse res = Utility.getJsonResponseFromExternalSystem(IntegrationConstants.POST_REQUEST_TYPE,IntegrationConstants.TWITTER_POST_ENDPOINT + EncodingUtil.urlEncode(stringToTweet, IntegrationConstants.CHARSET_UTF8).replaceAll('\\+','%20') , authorisationString, '');
			if(res.getStatusCode() == 200){
				TwitterPostResponse twtPostResponse = (TwitterPostResponse)JSON.deserialize(res.getBody(), TwitterPostResponse.class);
				if(twtPostResponse != null){
					Social_Campaign_Share__c socialCampaignShare = new Social_Campaign_Share__c();
					socialCampaignShare.External_Post_Id__c = twtPostResponse.id_str;
					socialCampaignShare.Network_Shared__c = IntegrationConstants.INTEGRATION_TYPE_TWITTER;
					socialCampaignShare.people__c = UserContext.peopleId;
					socialCampaignShare.Social_Campaign__c = socialCampaign.Id;

					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().insertAsUser(socialCampaignShare, new List<Schema.SObjectField>{
							Social_Campaign_Share__c.External_Post_Id__c,
							Social_Campaign_Share__c.Network_Shared__c,
							Social_Campaign_Share__c.people__c,
							Social_Campaign_Share__c.Social_Campaign__c
							});
				}
				
				 	
			} else {
				String message = res.getBody().subStringAfter('message":"').subStringBefore('"');
				if(String.isNotBlank(message) && message.containsIgnoreCase('Duplicate')) {
					throw new SimpplrException(ERROR_DUPLICATE_POST);
				} else if(res.getStatusCode() == 401){
					throw new SimpplrException(ERROR_NOT_PERFORMING_CAMPAIGN_TWITTER);		
				} else {
					throw new SimpplrException(message);
				}
			}
			
		} else{
			throw new SimpplrException(ERROR_NOT_PERFORMING_CAMPAIGN_TWITTER);
		}
	}	

		     
}