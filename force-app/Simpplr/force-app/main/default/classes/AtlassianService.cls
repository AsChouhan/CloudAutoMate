public with sharing class AtlassianService {



    public AtlassianWrapper getSupportIntegrationsConfig(){
		AtlassianWrapper atlassianIntegrationWrapperObj = new AtlassianWrapper();
		atlassianIntegrationWrapperObj.atlassianEnabled = SimpplrContext.atlassianIntegrationEnabled;
		atlassianIntegrationWrapperObj.atlassianConnectedAs = SimpplrContext.atlassianUserEmail;
		atlassianIntegrationWrapperObj.atlassianInstanceUrl = SimpplrContext.atlassianInstanceUrl;
        atlassianIntegrationWrapperObj.atlassianKeysSaved = SimpplrContext.atlassianIntegrationEnabled;
		atlassianIntegrationWrapperObj.confluenceEnabled = SimpplrContext.confluenceEnabled;
		atlassianIntegrationWrapperObj.isConfluenceKnowledgeDefaultSelected = String.isBlank(SimpplrContext.confluenceCustomKBName);
		atlassianIntegrationWrapperObj.customConfluenceKnowledgebaseName = SimpplrContext.confluenceCustomKBName;
        atlassianIntegrationWrapperObj.isConfluenceKnowledgeSpacesSelected = SimpplrContext.confluenceKnowledgeSpacesSelected;
		atlassianIntegrationWrapperObj.showAtlassianVPNMessage = SimpplrContext.showAtlassianVPNMessage;
		string storedKBJson = String.isBlank(SimpplrContext.confluenceKnowledgeBasesJSON) ? '[]' : SimpplrContext.confluenceKnowledgeBasesJSON;
		atlassianIntegrationWrapperObj.confluenceKBWrapperList = (List<AtlassianWrapper.KnowledgeBaseWrapper>)JSON.deserialize(storedKBJson, List<AtlassianWrapper.KnowledgeBaseWrapper>.class);
		return atlassianIntegrationWrapperObj;
    }


	public AtlassianWrapper.ConfluenceSpacesWrapper getConfluenceSpaces(Integer recordLimit, String nextPageToken, Map<String,Object> requestMap) {
		AtlassianWrapper.ConfluenceSpacesWrapper confluenceSpacesWrapperObj = new AtlassianWrapper.ConfluenceSpacesWrapper();
		List<AtlassianWrapper.KnowledgeBaseWrapper> listOfConfluenceSpaces = new List<AtlassianWrapper.KnowledgeBaseWrapper>();
		
		String domain = SimpplrContext.atlassianInstanceUrl;
		String term = requestMap.containsKey('term') ? (String)requestMap.get('term') : null;
		Boolean isFilterCall = requestMap.containsKey('isConnected') ? (Boolean) requestMap.get('isConnected') : false;
        Map<String, Object> requestBody = new Map<String, Object>();
        Map<String, Object> responseBody = new Map<String, Object>();
        String externalEndPoint = SimpplrContext.simpplrAPIEndpoint + '/atlassian/confluence/search';
		requestBody.put('action', 'getConfluenceSpaces');
        requestBody.put('domain', domain); 
        requestBody.put('orgId', SimpplrContext.simpplrOrgId);
        requestBody.put('peopleId', UserContext.peopleId);
		requestBody.put('limit', recordLimit);

		if(isFilterCall){
			String spacesJSONStr = String.isBlank(SimpplrContext.confluenceKnowledgeBasesJSON) ? '[]' : SimpplrContext.confluenceKnowledgeBasesJSON;
			Boolean confluenceKnowledgeSpacesSelected = SimpplrContext.confluenceKnowledgeSpacesSelected;
			List<AtlassianWrapper.KnowledgeBaseWrapper> confluenceKBWrapperList = (List<AtlassianWrapper.KnowledgeBaseWrapper>) JSON.deserialize(spacesJSONStr, List<AtlassianWrapper.KnowledgeBaseWrapper>.class);		
			
			Set<String> confluenceSpaceSet = new Set<String>();

			for(AtlassianWrapper.KnowledgeBaseWrapper kbWrapper : confluenceKBWrapperList){
				confluenceSpaceSet.add(kbWrapper.id);
			}

			if(!confluenceSpaceSet.isEmpty() && confluenceKnowledgeSpacesSelected == false){
				requestBody.put('space', confluenceSpaceSet);
			}
		}
		
		if(String.isNotBlank(term)) {
			requestBody.put('term', term);
		}
		if(String.isNotBlank(nextPageToken)) {
			requestBody.put('nextPageToken', nextPageToken);
		}
        
		logger.logDebug('AtlassianService.getConfluenceSpaces()----calling API----');

		HTTPResponse res=Utility.getResponseFromAWS(externalEndPoint, requestBody);
        String spacesJson='';
		
		logger.logDebug('AtlassianService.getConfluenceSpaces()----status code----' + res.getStatusCode());

		if (res.getStatusCode() == 200) {
			spacesJson =res.getBody();
        
        } else {
			logger.logError('AtlassianService.getConfluenceSpaces()----status code----' + res.getStatusCode());
			throw new SimpplrException(String.valueOf(res.getStatusCode()));
        }

		Map<String, Object> resultBodyMap = ((Map<String, Object>) JSON.deserializeUntyped(spacesJson));

		List<Object> resultList = (List<Object>)resultBodyMap.get('results');
		Object links = resultBodyMap.get('_links');
		
		for(Object result : resultList){
            Map<String,Object> mapOfParams = (Map<String,Object>)result;
			Map<String,Object> spaceMap = (Map<String,Object>)mapOfParams.get('space'); 
			AtlassianWrapper.KnowledgeBaseWrapper spaceWrapper = new AtlassianWrapper.KnowledgeBaseWrapper();
            spaceWrapper.name = (String)spaceMap.get('name');
            spaceWrapper.id = (String)spaceMap.get('key');
            listOfConfluenceSpaces.add(spaceWrapper);
		}
		
		Map<String,Object> linkParams = (Map<String,Object>)links;
		if(linkParams.get('next')!=null){
			confluenceSpacesWrapperObj.nextPageToken = (String)linkParams.get('next');
		}
		confluenceSpacesWrapperObj.results = listOfConfluenceSpaces;
	
		return confluenceSpacesWrapperObj;
	}

	public AtlassianWrapper.SearchWrapper searchConfluence(Integer recordLimit, String nextPageToken, Map<String, Object> requestMap){

		AtlassianWrapper.SearchWrapper searchWrapper = new AtlassianWrapper.SearchWrapper();
		List<AtlassianWrapper.KBItemSearchWrapper> searchItemWrapperList = new List<AtlassianWrapper.KBItemSearchWrapper>();

		String domain = SimpplrContext.atlassianInstanceUrl;
		String term = requestMap.containsKey('term') ? (String) requestMap.get('term') : null;
		String type = requestMap.containsKey('type') ? (String) requestMap.get('type') : null;
		String label = requestMap.containsKey('label') ? (String) requestMap.get('label') : null;
		String lastModified = requestMap.containsKey('lastModified') ? (String) requestMap.get('lastModified') : null;
		
		Map<String, Object> spaceMap = null;
		Map<String, Object> contributorMap = null;
		String space = null;
		String contributor = null;
		if(requestMap.containsKey('space')){
			Object spaceObj = requestMap.get('space');
			if(spaceObj instanceof String){
				space = (String) spaceObj;
			}
			else{
				spaceMap = (Map<String, Object>) spaceObj;
			}
		}
		if(requestMap.containsKey('contributor')){
			Object contributorObj = requestMap.get('contributor');
			if(contributorObj instanceof String){
				contributor = (String) contributorObj;
			}
			else{
				contributorMap = (Map<String, Object>) contributorObj;
			}
		}

        Map<String, Object> requestBody = new Map<String, Object>();
        String externalEndPoint = SimpplrContext.simpplrAPIEndpoint + '/atlassian/confluence/search';
		requestBody.put('action', 'getConfluenceData');
        requestBody.put('domain', domain); 
        requestBody.put('orgId', SimpplrContext.simpplrOrgId);
        requestBody.put('peopleId', UserContext.peopleId);
		requestBody.put('limit', recordLimit);
		String spacesJSONStr = String.isBlank(SimpplrContext.confluenceKnowledgeBasesJSON) ? '[]' : SimpplrContext.confluenceKnowledgeBasesJSON;
		Boolean confluenceKnowledgeSpacesSelected = SimpplrContext.confluenceKnowledgeSpacesSelected;
		List<AtlassianWrapper.KnowledgeBaseWrapper> confluenceKBWrapperList = (List<AtlassianWrapper.KnowledgeBaseWrapper>) JSON.deserialize(spacesJSONStr, List<AtlassianWrapper.KnowledgeBaseWrapper>.class);		
		
		Set<String> confluenceSpaceSet = new Set<String>();

		for(AtlassianWrapper.KnowledgeBaseWrapper kbWrapper : confluenceKBWrapperList){
			confluenceSpaceSet.add(kbWrapper.id);
		}
		if(String.isNotBlank(term)) {
			requestBody.put('term', term);
		}
		if(String.isNotBlank(nextPageToken)) {
			requestBody.put('nextPageToken', nextPageToken);
		}
		if(spaceMap != null) {
			Set<String> confluenceSpace = new Set<String>();
			confluenceSpace.add((String) spaceMap.get('id'));
			requestBody.put('space', confluenceSpace);
		}
		else if(String.isNotBlank(space)) {
			Set<String> confluenceSpace = new Set<String>();
			confluenceSpace.add(space);
			requestBody.put('space', confluenceSpace);
		}
		else if(!confluenceSpaceSet.isEmpty() && confluenceKnowledgeSpacesSelected == false){
			requestBody.put('space', confluenceSpaceSet);
		}
		if(contributorMap != null) {
			requestBody.put('contributor', (String) contributorMap.get('id'));
		}
		else if(String.isNotBlank(contributor)) {
			requestBody.put('contributor', contributor);
		}
		if(String.isNotBlank(type)) {
			requestBody.put('type', type);
		}
		if(String.isNotBlank(label)) {
			requestBody.put('label', label);
		}

		DateTime tempDateFilter = null;
		if (String.isNotBlank(lastModified) && 
				!'anytime'.equalsIgnoreCase(lastModified)) {

			if (lastModified.equalsIgnoreCase('past_24_hours')) {
				tempDateFilter = System.now().addHours(-24);

			} else if (lastModified.equalsIgnoreCase('past_week')) {
				tempDateFilter = System.now().addDays(-7);

			} else if (lastModified.equalsIgnoreCase('past_month')) {
				tempDateFilter = System.now().addMonths(-1);

			} else if (lastModified.equalsIgnoreCase('past_year')) {
				tempDateFilter = System.now().addYears(-1);
			}
		}

		if(tempDateFilter != null){
			requestBody.put('lastModifiedDate', tempDateFilter.formatGMT('yyyy-MM-dd'));
		}
		
		logger.logDebug('AtlassianService.searchConfluence()----calling API----');
		HTTPResponse res = Utility.getResponseFromAWS(externalEndPoint, requestBody);
		logger.logDebug('AtlassianService.searchConfluence()----status code----' + res.getStatusCode());
		
		String respJSONString = null;
		if (res.getStatusCode() == 200) {
			respJSONString = res.getBody();
			if(respJSONString.containsIgnoreCase(ServiceConstants.CONFLUENCE_REFRESH_TOKEN_EXPIRED)){
                throw new SimpplrException(ServiceConstants.CONFLUENCE_REFRESH_TOKEN_EXPIRED);
            }
		} else {
			logger.logError('AtlassianService.getConfluenceSpaces()----status code----' + res.getStatusCode());
			throw new SimpplrException(String.valueOf(res.getStatusCode()));
		}

		Map<String, Object> resultBodyMap = (Map<String, Object>) JSON.deserializeUntyped(respJSONString);
		List<Object> resultList = (List<Object>) resultBodyMap.get('results');
		Object links = resultBodyMap.get('_links');
		
		//SV2-40797 response does not always contain content
		for(Object result : resultList){
			Map<String, Object> mapOfParams = (Map<String, Object>) result;
			Map<String, Object> spaceObjMap = mapOfParams.containsKey('resultGlobalContainer') ? (Map<String, Object>) mapOfParams.get('resultGlobalContainer') : null;
			Map<String, Object> contentMap = mapOfParams.containsKey('content') ? (Map<String, Object>) mapOfParams.get('content') : null;
			AtlassianWrapper.KBItemSearchWrapper kbItemSearchWrapper = new AtlassianWrapper.KBItemSearchWrapper();
			AtlassianWrapper.SearchItemWrapper searchItemWrapper = new AtlassianWrapper.SearchItemWrapper();
			if(spaceObjMap <> null){
				searchItemWrapper.space = spaceObjMap.containsKey('title') ? (String) spaceObjMap.get('title') : '';
			}
			if(domain.right(1) == '/'){
				searchItemWrapper.url = domain + 'wiki'+ (mapOfParams.containsKey('url' ) ? (String) mapOfParams.get('url') : '');
			}else{
				searchItemWrapper.url = domain + '/wiki'+ (mapOfParams.containsKey('url' ) ? (String) mapOfParams.get('url') : '');
			}
			if(contentMap <> null){
				searchItemWrapper.id = contentMap.containsKey('id') ? (String) contentMap.get('id') : '';
				searchItemWrapper.title = contentMap.containsKey('title') ? (String) contentMap.get('title') : '';
			}
			searchItemWrapper.modifiedAt = mapOfParams.containsKey('lastModified') ? (String) mapOfParams.get('lastModified') : '';
			searchItemWrapper.description =	mapOfParams.containsKey('excerpt') ? ((String) mapOfParams.get('excerpt')).unescapeHtml4() : '';
			kbItemSearchWrapper.item = searchItemWrapper;
			kbItemSearchWrapper.itemType = 'confluencePage';
			searchItemWrapperList.add(kbItemSearchWrapper);
		}
		
		if(links != null){
			Map<String, Object> linkParams = (Map<String, Object>) links;
			if(linkParams.get('next') != null){
				searchWrapper.nextPageToken = (String) linkParams.get('next');
			}	
		}
		searchWrapper.results = searchItemWrapperList;

		Integer totalSize = resultBodyMap.get('totalSize') != null ? (Integer) resultBodyMap.get('totalSize') : 0;
		searchWrapper.totalRecords = totalSize;
		return searchWrapper;
	}

	public AtlassianWrapper.ContributorWrapper getConfluenceUsers(Integer recordLimit, String nextPageToken, Map<String,Object> requestMap) {
		AtlassianWrapper.ContributorWrapper contributorWrapper = new AtlassianWrapper.ContributorWrapper();
		List<AtlassianWrapper.ContributorItemWrapper> contributorItemWrapperList = new List<AtlassianWrapper.ContributorItemWrapper>();
		
		String domain = SimpplrContext.atlassianInstanceUrl;
		String term = requestMap.containsKey('term') ? (String) requestMap.get('term') : null;

		String externalEndPoint = SimpplrContext.simpplrAPIEndpoint + '/atlassian/confluence/search';
        Map<String, Object> requestBody = new Map<String, Object>();
		requestBody.put('action', 'getConfluenceUsers');
        requestBody.put('domain', domain); 
        requestBody.put('orgId', SimpplrContext.simpplrOrgId);
        requestBody.put('peopleId', UserContext.peopleId);
		requestBody.put('limit', recordLimit);
		
		if(String.isNotBlank(term)) {
			requestBody.put('term', term);
		}
		if(String.isNotBlank(nextPageToken)) {
			requestBody.put('nextPageToken', nextPageToken);
		}
        
		logger.logDebug('AtlassianService.getConfluenceUsers()----calling API----');

		HTTPResponse res=Utility.getResponseFromAWS(externalEndPoint, requestBody);
        String userJsonStr = null;
		
		logger.logDebug('AtlassianService.getConfluenceUsers()----status code----' + res.getStatusCode());

		if (res.getStatusCode() == 200) {
			userJsonStr = res.getBody();
        
        } else {

			logger.logError('AtlassianService.getConfluenceUsers()----status code----' + res.getStatusCode());
			throw new SimpplrException(String.valueOf(res.getStatusCode()));
        }

		Map<String, Object> resultBodyMap = (Map<String, Object>) JSON.deserializeUntyped(userJsonStr);
		List<Object> resultList = (List<Object>) resultBodyMap.get('results');

		Set<String> confluenceUserIdSet = new Set<String>();
		for(Object result : resultList){
            Map<String, Object> mapOfParams = (Map<String, Object>) result;
			Map<String, Object> userMap = (Map<String, Object>) mapOfParams.get('user'); 

			confluenceUserIdSet.add((String) userMap.get('accountId'));
		}

		List<People_Integration__c> peopleIntegrationList = [SELECT Id, People__c, External_Id__c,
															 People__r.Id, People__r.User__c, People__r.user__r.Id,
															 People__r.Community_Nickname__c, People__r.First_Name__c,
															 People__r.Last_Name__c, People__r.user__r.FullPhotoURL,
															 People__r.Department__c, People__r.Title__c, People__r.City__c,
															 People__r.State__c, People__r.Country__c, People__r.User__r.isactive,
															 People__r.Email__c, People__r.Phone__c, People__r.mobile_phone__c,
															 People__r.extension__c, People__r.About__c, People__r.Birth_Date__c,
															 people__r.Joining_Date__c 
															 FROM People_Integration__c
															 WHERE External_Id__c IN :confluenceUserIdSet AND
															 Name = 'Atlassian' WITH SECURITY_ENFORCED];
		
		Map<String, People_Integration__c> confluenceUserIdVsPeopleIntMap = new Map<String, People_Integration__c>();													 
		for(People_Integration__c pplIntgObj : peopleIntegrationList){

			confluenceUserIdVsPeopleIntMap.put(pplIntgObj.External_Id__c, pplIntgObj);
		}

		for(Object result : resultList){
            Map<String, Object> mapOfParams = (Map<String, Object>) result;
			Map<String, Object> userMap = (Map<String, Object>) mapOfParams.get('user'); 

			AtlassianWrapper.ContributorItemWrapper contributorItemWrapper = new AtlassianWrapper.ContributorItemWrapper();
            contributorItemWrapper.id = (String) userMap.get('accountId');
            contributorItemWrapper.confluenceUserId = (String) userMap.get('accountId');
			contributorItemWrapper.name = (String) userMap.get('displayName');
			
			PeopleListWrapper peopleListWrapperObj = null;
			if(confluenceUserIdVsPeopleIntMap.containsKey(contributorItemWrapper.id)){
				contributorItemWrapper.isSimpplrUser = true;
				
				People_Integration__c pplIntgObj = confluenceUserIdVsPeopleIntMap.get(contributorItemWrapper.id);
				peopleListWrapperObj = toPeopleListWrapper(pplIntgObj.People__r);
				
			} else {
				contributorItemWrapper.isSimpplrUser = false;

				peopleListWrapperObj = new PeopleListWrapper();
				peopleListWrapperObj.nickname = (String) userMap.get('publicName');
				peopleListWrapperObj.url = domain + (String) mapOfParams.get('url');
				peopleListWrapperObj.name = (String) userMap.get('displayName');
				peopleListWrapperObj.img = null;

				if(userMap.get('profilePicture') != null){
					peopleListWrapperObj.img = domain + (String) ((Map<String, Object>) userMap.get('profilePicture')).get('path');
				}
				peopleListWrapperObj.title = (String) mapOfParams.get('title');
				peopleListWrapperObj.email = (String) userMap.get('email');

			}
			contributorItemWrapper.people = peopleListWrapperObj;

            contributorItemWrapperList.add(contributorItemWrapper);
		}
		
		Object links = resultBodyMap.get('_links');
		Map<String, Object> linkParams = (Map<String, Object>) links;
		if(linkParams.get('next') != null){
			contributorWrapper.nextPageToken = (String) linkParams.get('next');
		}
		contributorWrapper.results = contributorItemWrapperList;
	
		return contributorWrapper;
	}

	private PeopleListWrapper toPeopleListWrapper(People__c peopleObj){
		PeopleListWrapper peopleListWrapperObj = new PeopleListWrapper();

		peopleListWrapperObj.id = peopleObj.Id;
		peopleListWrapperObj.peopleId = peopleObj.Id;
		peopleListWrapperObj.sfUserId = peopleObj.user__r.Id;
		peopleListWrapperObj.nickname = peopleObj.Community_Nickname__c;
		peopleListWrapperObj.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleObj.Id;
		String name = Utility.buildName(peopleObj.First_Name__c, peopleObj.Last_Name__c);
		if(String.isNotBlank(name)){
			peopleListWrapperObj.name = name;
		}
		peopleListWrapperObj.img = peopleObj.user__r.FullPhotoURL.endsWith('005/F') ? null : peopleObj.user__r.FullPhotoURL;
		peopleListWrapperObj.department = peopleObj.Department__c;
		peopleListWrapperObj.title = peopleObj.Title__c;
		peopleListWrapperObj.location = Utility.buildLocation(peopleObj.City__c, peopleObj.State__c, peopleObj.Country__c);
		peopleListWrapperObj.email = peopleObj.Email__c;
		peopleListWrapperObj.phone = peopleObj.Phone__c;
		peopleListWrapperObj.mobile = peopleObj.mobile_phone__c;
		peopleListWrapperObj.phoneExtension = peopleObj.extension__c;
		peopleListWrapperObj.about = peopleObj.About__c;
		peopleListWrapperObj.birthday = SimpplrContext.isPPBirthDateDisplay ? Utility.dateToDisplayString(peopleObj.Birth_Date__c, 'MM-dd') : null;
		if(SimpplrContext.isPPJoiningDateDisplay && peopleObj.Joining_Date__c != null && peopleObj.Joining_Date__c < Date.today().addDays(-3)) {
			peopleListWrapperObj.hireDate = Utility.dateToDisplayString(peopleObj.Joining_Date__c, 'yyyy-MM-dd');
		}
		if (UserContext.usersIFollowIdSet.contains(peopleObj.User__c)) {
			peopleListWrapperObj.isFollowing = true;
				
		} else {
			peopleListWrapperObj.isFollowing = false;

		}
		
		peopleListWrapperObj.isActive = peopleObj.User__r.isactive;

		return peopleListWrapperObj;
	}

	/**
	 * @description Makes callout to AWS for updating Refresh token for Atlassian Integration
	 */
	public static void refreshUserTokens() {

        Map<String, Object> requestBody = new Map<String, Object>();
        String externalEndPoint = SimpplrContext.simpplrAPIEndpoint + '/atlassian/confluence/search';
		requestBody.put('action', 'refreshtokensbulk');
        requestBody.put('orgId', SimpplrContext.simpplrOrgId);
		
		Utility.getResponseFromAWS(externalEndPoint, requestBody);
 		
	}
	
}