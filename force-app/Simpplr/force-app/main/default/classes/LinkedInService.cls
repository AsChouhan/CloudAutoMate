public with sharing class LinkedInService {
   
    private final String ERROR_NOT_PERFORMING_CAMPAIGN_LINKEDIN = 'Unable to perform action';
    public void linkedInShareProcess(Social_Campaign__c campaignRec, String message){
		IntegrationService integrationServiceObj = new IntegrationService(IntegrationConstants.INTEGRATION_TYPE_LINKEDIN, UserContext.peopleId);
		if(integrationServiceObj.accessTokenExpired()){
			throw new SimpplrException(ERROR_NOT_PERFORMING_CAMPAIGN_LINKEDIN);
			
		}else {
			String access_token = integrationServiceObj.getAccessToken();
			Map<String, Object>jsonBodyMap;
			if(String.isNotBlank(campaignRec.Url__c)){
				jsonBodyMap = getJsonBodyMapWithUrl(campaignRec, message, integrationServiceObj.integrator.External_Id__c);
			} else {
				jsonBodyMap = getJsonBodyMapWithoutUrl(message, integrationServiceObj.integrator.External_Id__c);
			}			
			HttpResponse res = Utility.getJsonResponseFromExternalSystem('POST', IntegrationConstants.LINKEDIN_POST_ENDPOINT, 'Bearer ' + access_token, JSON.serialize(jsonBodyMap));
			System.debug('res.getBody()----18--'+res.getBody());
			system.debug('LS>>>>>linkedInShareProcess>>>>>JSON.serialize(jsonBodyMap)>>>>20 ' + JSON.serialize(jsonBodyMap));

			logger.logDebug('Linkedin campaign share response:'+res.getBody());
			if(res.getStatusCode() == 201){	
				System.debug('inside if with statuscode==201');
				Map<String, String> postResponseData = (Map<String, String>)JSON.deserialize(res.getBody(), Map<String, String>.class);
				
				Social_Campaign_Share__c shareObj = new Social_Campaign_Share__c();
				shareObj.Social_Campaign__c = campaignRec.Id;
				shareObj.People__c = UserContext.peopleId;
				shareObj.External_Post_Id__c = (String)postResponseData.get('updateKey');
				shareObj.Network_Shared__c = 'LinkedIn';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    			SIMPESAPI.accessController().insertAsUser(shareObj, new List<Schema.SObjectField>{
											Social_Campaign_Share__c.Network_Shared__c,
											Social_Campaign_Share__c.People__c,
											Social_Campaign_Share__c.Social_Campaign__c,
											Social_Campaign_Share__c.External_Post_Id__c
											});
			} else {
				logger.logError('LinkedinService Exception:'+res.getBody());
				if(res.getStatusCode() == 401){
					throw new SimpplrException(ERROR_NOT_PERFORMING_CAMPAIGN_LINKEDIN);		
				} else{
					Map<String, String> errorResponseData = (Map<String, String>)JSON.deserialize(res.getBody(), Map<String, String>.class);
					if(errorResponseData !=null && String.isNotBlank(errorResponseData.get('message'))) {
						throw new SimpplrException(errorResponseData.get('message'));
					} else {
						throw new SimpplrException(ERROR_NOT_PERFORMING_CAMPAIGN_LINKEDIN + ' - '  + res.getStatusCode() + ' received from LinkedIn');
					}
				}
			}	
		}
	
	}

	private Map<String, Object> getJsonBodyMapWithUrl(Social_Campaign__c campaignRec, String message, String authorExternalId){
		Map<String, String> shareCommentary = new Map<String,String>();
		shareCommentary.put('text', message);

		Map<String, Object> shareMedia = new Map<String,Object>();
		shareMedia.put('status', 'READY');
		shareMedia.put('originalUrl', campaignRec.Url__c);

		Map<String, Object>contentDataMap = new Map<String,Object>();
		contentDataMap.put('shareCommentary', shareCommentary);
		contentDataMap.put('shareMediaCategory', 'ARTICLE');
		contentDataMap.put('media', new List<Object> {shareMedia});
		
		Map<String, Object>specificContent = new Map<String, Object>();
		specificContent.put('com.linkedin.ugc.ShareContent', contentDataMap);

		Map<String, String>visibility = new Map<String,String>();
		visibility.put('com.linkedin.ugc.MemberNetworkVisibility', 'PUBLIC');

		Map<String, Object>jsonBodyMap = new Map<String, Object>();			
		jsonBodyMap.put('author', 'urn:li:person:' + authorExternalId);
		jsonBodyMap.put('lifecycleState', 'PUBLISHED');
		jsonBodyMap.put('specificContent', specificContent);
		jsonBodyMap.put('visibility', visibility);
		return jsonBodyMap;
	}

	private Map<String, Object> getJsonBodyMapWithoutUrl(String message, String authorExternalId){
		Map<String, String> shareCommentary = new Map<String,String>();
		shareCommentary.put('text', message);

		Map<String, Object>contentDataMap = new Map<String,Object>();
		contentDataMap.put('shareCommentary', shareCommentary);
		contentDataMap.put('shareMediaCategory', 'NONE');
		Map<String, Object>specificContent = new Map<String, Object>();
		specificContent.put('com.linkedin.ugc.ShareContent', contentDataMap);

		Map<String, String>visibility = new Map<String,String>();
		visibility.put('com.linkedin.ugc.MemberNetworkVisibility', 'PUBLIC');

		Map<String, Object>jsonBodyMap = new Map<String, Object>();			
		jsonBodyMap.put('author', 'urn:li:person:' + authorExternalId);
		jsonBodyMap.put('lifecycleState', 'PUBLISHED');
		jsonBodyMap.put('specificContent', specificContent);
		jsonBodyMap.put('visibility', visibility);
		return jsonBodyMap;
	}
}