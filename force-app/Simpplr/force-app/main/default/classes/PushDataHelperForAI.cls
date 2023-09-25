public with sharing class PushDataHelperForAI {
	

	private static final String RELATED_CONTENT_API_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/content/related-content';
	
	public List<AIWrapper.ContentWrapper> convertSimpplrContentListToAIDataWrapperList(List<Simpplr_Content__c> contentList) {
		List<AIWrapper.ContentWrapper> listOfObjects = new List<AIWrapper.ContentWrapper>();
		Set<Id> contentIdSet = new Set<Id>();
		Map<String,List<TopicAssignment>> contentIdWithTopicListMap = new Map<String,List<TopicAssignment>>();

		for(Simpplr_Content__c contentObj : contentList) { 
			contentIdSet.add(contentObj.Id);
		}
		contentIdWithTopicListMap = initiateMapOfContentIdWithTopicList(contentIdSet);

		for(Simpplr_Content__c contentObj : contentList) { 
			listOfObjects.add(convertSimpplrContentToAIDataWrapper(contentObj, contentIdWithTopicListMap));
		}

		return listOfObjects;
	}
    
    private AIWrapper.ContentWrapper convertSimpplrContentToAIDataWrapper(Simpplr_Content__c contentObj, Map<String,List<TopicAssignment>> contentIdWithTopicListMap) {
        
        AIWrapper.ContentWrapper contentObjForAI = new AIWrapper.ContentWrapper();
		contentObjForAI.id = contentObj.Id;
		contentObjForAI.title = contentObj.title__c;
		contentObjForAI.text_intro = String.isNotBlank(contentObj.Text_Intro__c) ? contentObj.Text_Intro__c : '';
		contentObjForAI.site_id = contentObj.Site__c;
		contentObjForAI.site_type = contentObj.Type__c == 'BlogPost' ? 'Public' : contentObj.Site__r.Site_Type__c;
		contentObjForAI.type = contentObj.Type__c;
		contentObjForAI.publishStartDate = contentObj.Publish_Start_DateTime__c != null ? contentObj.Publish_Start_DateTime__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') : '';
		contentObjForAI.expires_at = contentObj.Publish_End_DateTime__c != null ? contentObj.Publish_End_DateTime__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') : '';
		if(ServiceConstants.TYPE_PAGE.equalsIgnoreCase(contentObj.Type__c)) {
			contentObjForAI.page_category = contentObj.Pages_Category__r.Name__c;
		}

		if(contentIdWithTopicListMap.get(contentObj.Id) != null && contentIdWithTopicListMap.get(contentObj.Id).size()>0) {
			contentObjForAI.topic_list = convertContentTopicsToTopicWrapper(contentObj.Type__c,contentIdWithTopicListMap.get(contentObj.Id));
		}
		
		return contentObjForAI;		
    }

	private Map<String,List<TopicAssignment>> initiateMapOfContentIdWithTopicList(Set<Id> contentIdSet) {
		Map<String,List<TopicAssignment>> contentIdWithtopicListMap = new Map<String,List<TopicAssignment>>();
		if(contentIdSet.size()>0) {
			String queryToFetchTopic = 'SELECT Id,Topic.Id,Topic.name,EntityId FROM TopicAssignment WHERE EntityId IN:contentIdSet';
			if(SimpplrContext.isCommunitiesEnabled) {
				queryToFetchTopic = queryToFetchTopic+' AND NetworkId = null';
			}
			List<TopicAssignment> topicList = Database.query(queryToFetchTopic);
			
			if(!topicList.isEmpty()) {
				for(TopicAssignment topicAssObj : topicList) {
					if(contentIdWithtopicListMap.get(topicAssObj.EntityId) == null) {
						contentIdWithtopicListMap.put(topicAssObj.EntityId,new List<TopicAssignment>());
					}
					contentIdWithtopicListMap.get(topicAssObj.EntityId).add(topicAssObj);
				}
			}
		}
		
		return contentIdWithtopicListMap;
	}

	private List<String> convertContentTopicsToTopicWrapper(String contentType, List<topicAssignment> topicAssignmentList) {
		List<String> topicWrapperList = new List<String>();
		for(topicAssignment topicAssignmentObj : topicAssignmentList) {
			topicWrapperList.add(topicAssignmentObj.topic.name);
		}
		return topicWrapperList;
	}


	public HttpResponse pushDataForIndexing(String jsonBody) {                
		Map<String, Object> requestBody = new Map<String, Object>();
		requestBody.put('org_id', SimpplrContext.simpplrOrgId);
		requestBody.put('data', jsonBody);
		requestBody.put('action', 'indexData');
		requestBody.put('version', ServiceConstants.RELATED_CONTENT_API_VERSION);
		HttpResponse res = Utility.getResponseFromAWS(RELATED_CONTENT_API_ENDPOINT, requestBody);
		return res;
	} 

	public void recommendationsSetUp() {  
	Map<String, Object> requestBody = new Map<String, Object>();
	requestBody.put('org_id', SimpplrContext.simpplrOrgId);
	requestBody.put('action', 'recommendationsSetUp');
	requestBody.put('version', ServiceConstants.RELATED_CONTENT_API_VERSION);

	HttpResponse res = Utility.getResponseFromAWS(RELATED_CONTENT_API_ENDPOINT, requestBody);

	if(res.getStatusCode() != 200) {
		throw new SimpplrException(res.getStatusCode() + ' received, Response Body is ' + res.getBody());
	}else{
			String jobIdResponse= res.getBody();
			Map<String, Object> jobIdResponseMap = (Map<String, Object>)JSON.deserializeUntyped(jobIdResponse);

			if (jobIdResponseMap != null && jobIdResponseMap.containsKey('job_id')) {
				String logQuery = 'SELECT Id, Data_Counter__c, Is_Deleted__c, Log_Data__c, Log_Type__c, Source_Info__c, Unique_Token__c FROM Logs__c Where Source_Info__c = \'AIContentIndexing\'';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					List<Logs__c> logsList = (List<Logs__c>)SIMPESAPI.accessController().queryAsUser(logQuery, null);
				if(logsList.size() > 0) {
					logsList[0].Log_Data__c = (String)jobIdResponseMap.get('job_id');

					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().updateAsUser(logsList[0], 
							new List<Schema.SObjectField>{
								Logs__c.Log_Data__c
					});
				} else {
						ManageApplicationDao.logUserSyncProvStatus((String)jobIdResponseMap.get('job_id'), 'AIContentIndexing');
				}
			}
		}
	} 
	
}