public with sharing class ContentTriggerHandler {
	public static Boolean isCalledFromEditContentScreen = false;

	@future(callout=true)
    public static void pushContentForAIRecommendation(Set<Id> contentIds)
    {   
		List<Simpplr_Content__c> contentList = [SELECT Id, Text_Intro__c, Title__c, Site__c, Site__r.Site_Type__c, Type__c, Pages_Category__r.Name__c, Publish_Start_DateTime__c, Publish_End_DateTime__c  FROM Simpplr_Content__c WHERE Is_Deleted__c = false AND Is_Unpublished__c = false AND Id IN:contentIds WITH SECURITY_ENFORCED];
		if(!test.isRunningTest() && contentList.size() > 0) {
			PushDataHelperForAI pushDataHelperForAIObj = new PushDataHelperForAI();
			List<AIWrapper.ContentWrapper> dataToBePushed = pushDataHelperForAIObj.convertSimpplrContentListToAIDataWrapperList( contentList );
			String jsonBody = Json.serialize(dataToBePushed);
			HttpResponse res = pushDataHelperForAIObj.pushDataForIndexing(jsonBody);
			if(res.getStatusCode() != 200){
					throw new SimpplrException(res.getStatusCode() + ' received, Response Body is ' + res.getBody());
			}else{
                    pushDataHelperForAIObj.recommendationsSetUp();
			}
		}
    }	
	
	@future(callout=true)
    public static void removeContentFromAIServer(Set<Id> contentIds)
    {   
		String RELATED_CONTENT_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/content/related-content';
		for(Id contentId:contentIds){
			Map<String, Object> requestBody = new Map<String, Object>();
			requestBody.put('orgId', SimpplrContext.simpplrOrgId);
			requestBody.put('contentId', contentId);
			requestBody.put('action', 'removeContentData');
			requestBody.put('version', ServiceConstants.RELATED_CONTENT_API_VERSION);
			HttpResponse httpresponseObj = Utility.getResponseFromAWS(RELATED_CONTENT_ENDPOINT, requestBody);
		}
    }
}