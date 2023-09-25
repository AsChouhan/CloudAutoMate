public with sharing class ActiveDirectoryService {


    public List<ActiveDirectoryModel.ADGroup> searchSelectedGroups(String searchToken){
        List<ActiveDirectoryModel.ADGroup> listOfAdGrpWrap = new List<ActiveDirectoryModel.ADGroup>();

        /*String term = '%' + searchToken + '%';
        List<Active_Directory_Group__C> listOfADGrp = [SELECT id, name, 
                Email__C, AD_Object_Id__c 
                FROM Active_Directory_Group__C 
                WHERE Name like :term];*/

        //Need to get these records from AWS when implemented
        String query = 'SELECT id, name, Email__C, AD_Object_Id__c FROM Active_Directory_Group__C LIMIT 1';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
        List<Active_Directory_Group__C> listOfADGrp = (List<Active_Directory_Group__C>)SIMPESAPI.accessController().queryAsUSer(query, null);
        
        if (!listOfADGrp.isEmpty()) {
            
            for (Active_Directory_Group__C aDGrpObj: listOfADGrp) {
                ActiveDirectoryModel.ADGroup aDGrpWrapObj = new ActiveDirectoryModel.ADGroup();
                aDGrpWrapObj.id = aDGrpObj.id; 
                aDGrpWrapObj.label = aDGrpObj.name; 
                aDGrpWrapObj.email = aDGrpObj.Email__c; 
                listOfAdGrpWrap.add(aDGrpWrapObj);
            }

        } 

        return listOfAdGrpWrap;
    } 

    /**
     * @description - intiate AD people sync job on AWS
     */
    public static void intiateADPeopleSyncJob() {

        Map<String, Object> requestBody = new Map<String, Object>();
        String endpoint = SimpplrContext.simpplrAPIEndpoint + '/ad-groups/people-manager';
		requestBody.put('action', 'syncpeople');
        requestBody.put('orgId', SimpplrContext.simpplrOrgId);
        requestBody.put('email', UserContext.email);

        Utility.getResponseFromAWS(endpoint, requestBody);
    }

    /**
     * @description intiate AD group sync job on AWS
     */
    public static void intiateADGroupSyncJob() {

        if(SimpplrContext.isActiveDirectoryGroupsEnabled) {

            Map<String, Object> requestBody = new Map<String, Object>();
            String endpoint = SimpplrContext.simpplrAPIEndpoint + '/ad-groups/group-manager';
            requestBody.put('action', 'syncadgroupsinsalesforce');
            requestBody.put('orgId', SimpplrContext.simpplrOrgId);

            try {
                HttpResponse respone = Utility.getResponseFromAWS(endpoint, requestBody);
                // update flag in DB for AD Group Sync
                updateBatchProcessingFlag(true);              
            } catch (Exception ex) {
                // job is not initiated on AWS
                ActiveDirectoryService.updateBatchProcessingFlag(false);
                logADGroupSyncStatus('failed', 'Group Sync activedirectory');               
            }   
        }
    }  
    
    public static void updateBatchProcessingFlag(Boolean status) {

        Map<String, Object> soqlParamMap = new  Map<String, Object>();
        soqlParamMap.put('soqlParam1', IntegrationConstants.INTEGRATION_TYPE_ACTIVE_DIRECTORY);                  
        String query = 'SELECT Id FROM App_Integration__c WHERE name =: soqlParam1 LIMIT 1';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<App_Integration__c> appIntegrationList = (List<App_Integration__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap); 
        if(!appIntegrationList.isEmpty()) {
            App_Integration__c appIntegrationObj = appIntegrationList[0];
            appIntegrationObj.Batch_Processing__c = status;
            SIMPESAPI.accessController().updateAsUser(appIntegrationObj, new List<Schema.SObjectField>{
                App_Integration__c.Batch_Processing__c});                    
        }  
    }

	public static void logADGroupSyncStatus(String status, String sourceInfo){

		Logs__c logsObj = new Logs__c(
			Log_Data__c = status,
			Log_Type__c = 'INFO',
			Source_Info__c = sourceInfo,
			Data_Counter__c = 0,
			Is_Deleted__c = false,
			Unique_Token__c = null
		);

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().insertAsUser(logsObj, new List<Schema.SObjectField>{
																		Logs__c.Log_Data__c,
																		Logs__c.Log_Type__c,
																		Logs__c.Source_Info__c,
																		Logs__c.Data_Counter__c,
																		Logs__c.Is_Deleted__c,
																		Logs__c.Unique_Token__c});

	}    

    /**
     * @description intiate Audience Member sync from AD groups
     */    
    public static void initiateAudienceMemSync() {
        
        String query = 'SELECT Id FROM Audience__c WHERE Is_Created_From_AD_Groups__c = true AND Is_deleted__c = false';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<Audience__c> audienceList = (List<Audience__c>)SIMPESAPI.accessController().queryAsUSer(query, null);
        List<String> audienceIdsList = new List<String>();
        for(Audience__c audience : audienceList) {
            audienceIdsList.add(audience.Id);
        }

        if(!audienceIdsList.isEmpty()) {
            BatchSyncAudienceMembersFromAD syncAudienceMemberFromADObj = new BatchSyncAudienceMembersFromAD('syncAudienceMemWithAD', audienceIdsList, true);
            Database.executeBatch(syncAudienceMemberFromADObj, 2000);
        } else {
            ActiveDirectoryService.updateBatchProcessingFlag(false);
            ActiveDirectoryService.logADGroupSyncStatus('successful', 'Group Sync activedirectory');             
        }           
        
    }
    
    /**
     * @description this method handle all the ad group listing, filteing and searching
     * @return ResultWrapper - response wrapper
     * @param requestData - String type request map
     */
    public ResultWrapper getActiveDirectoryGroups(String requestData, Boolean isADGroupsV2Enabled){
        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(requestData);
        logger.logDebug('ActiveDirectoryService.getActiveDirectoryGroups()----requestMap----' + requestMap);

        String tab = requestMap.containsKey('tab') ? (String) requestMap.get('tab') : 'All';
        if('Selected'.equalsIgnoreCase(tab)){
            return fetchSelectedGroups(requestMap, isADGroupsV2Enabled);
        } else {
            return fetchAllGroups(requestMap, isADGroupsV2Enabled);
        }
    }

    /**
     * @description this method handle all the ad group listing, filteing and searching for selected tab
     * @return ResultWrapper - response wrapper
     * @param requestMap - Map<String, Object> type request map
     */
    public ResultWrapper fetchSelectedGroups(Map<String, Object> requestMap, Boolean isADGroupsV2Enabled){
        ResultWrapper resultWrapperObj = new ResultWrapper();

        String tab = requestMap.containsKey('tab') ? (String) requestMap.get('tab') : 'All';
		String term = requestMap.containsKey('term') ? (String) requestMap.get('term') : null;
        String nextPageToken = '0'; 

        if (requestMap.containsKey('nextPageToken') && (String)requestMap.get('nextPageToken') != null) {
            nextPageToken = (String) requestMap.get('nextPageToken');
        }
        
        String groupType = requestMap.containsKey('groupType') ? (String) requestMap.get('groupType') : null;
        Integer size = requestMap.containsKey('size') ? (Integer) requestMap.get('size') : SimpplrContext.simpplrDefaultPageSize;
		String externalEndPoint = SimpplrContext.simpplrAPIEndpoint + '/ad-groups/group-manager';
        Map<String, Object> requestBody = new Map<String, Object>();
		requestBody.put('action', 'getADGroups');
        requestBody.put('orgId', SimpplrContext.simpplrOrgId);
        requestBody.put('peopleId', UserContext.peopleId);
        requestBody.put('size', size);
        requestBody.put('tab', tab);
        if(String.isNotBlank(term)) {
			requestBody.put('term', term);
        }
        if(String.isNotBlank(groupType)) {
			requestBody.put('groupType', groupType);
        }
        if(isADGroupsV2Enabled) {
            requestBody.put('releaseVersion', ServiceConstants.RELEASE_VERSION);
        }

        string selectedGroups = null;

        List<string> selectedGroupList = fetchSelectedGroupsSF(integer.valueof(nextPageToken), size, isADGroupsV2Enabled);

        resultWrapperObj.totalRecords = fetchSelectedGroupsCount(isADGroupsV2Enabled); //Get Total count

        Integer tempVal = integer.valueof(nextPageToken) + size;
        if(selectedGroupList.size() == size+1 && nextPageToken != null && tempVal < resultWrapperObj.totalRecords ){
            resultWrapperObj.nextPageToken = String.valueOf(tempVal);
            selectedGroupList.remove(selectedGroupList.size() - 1);
        }

        if(selectedGroupList.size() > 0){
            selectedGroups = string.join(selectedGroupList,',');
            logger.logDebug('selectedGroups -- > '+selectedGroups);
        } else {
            resultWrapperObj.totalRecords = 0;
            resultWrapperObj.nextPageToken = null;
            return resultWrapperObj;
        }

        requestBody.put('selectedGroups', selectedGroups);

		HTTPResponse res = Utility.getResponseFromAWS(externalEndPoint, requestBody);
		
		logger.logDebug('ActiveDirectoryService.fetchSelectedGroups()----status code----' + res.getStatusCode());

        String responseVal;
		if (res.getStatusCode() == 200) {
			responseVal = res.getBody();
        
        } else {

			logger.logError('ActiveDirectoryService.fetchSelectedGroups()----status code----' + res.getStatusCode());
			throw new SimpplrException(String.valueOf(res.getStatusCode()));
        }

		Map<String, Object> resultBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseVal);
        
        List<Object> resultList = (List<Object>) resultBodyMap.get('value');
        logger.logError('ActiveDirectoryService.fetchSelectedGroups()----resultList----' + resultList);
        
        List<ActiveDirectoryModel.ADGroup> adGroupWrapObjectList =  new List<ActiveDirectoryModel.ADGroup>();
        for(Object rowValue:resultList){
            adGroupWrapObjectList.add(convertToAdWrappper(rowValue, null, isADGroupsV2Enabled));
        }

        resultWrapperObj.listOfItems = adGroupWrapObjectList;
        return resultWrapperObj;
    }

    /**
     * @description this method handle all the ad group listing, filteing and searching for all tab
     * @return ResultWrapper - response wrapper
     * @param requestMap - Map<String, Object> type request map
     */
    public ResultWrapper fetchAllGroups(Map<String, Object> requestMap, Boolean isADGroupsV2Enabled){
        ResultWrapper resultWrapperObj = new ResultWrapper();

        String tab = requestMap.containsKey('tab') ? (String) requestMap.get('tab') : 'All';
		String term = requestMap.containsKey('term') ? (String) requestMap.get('term') : null;
        String nextPageToken = requestMap.containsKey('nextPageToken') ? (String) requestMap.get('nextPageToken') : null;
        String groupType = requestMap.containsKey('groupType') ? (String) requestMap.get('groupType') : null;
        Integer size = requestMap.containsKey('size') ? (Integer) requestMap.get('size') : SimpplrContext.simpplrDefaultPageSize;
		String externalEndPoint = SimpplrContext.simpplrAPIEndpoint + '/ad-groups/group-manager';
        Map<String, Object> requestBody = new Map<String, Object>();
		requestBody.put('action', 'getADGroups');
        requestBody.put('orgId', SimpplrContext.simpplrOrgId);
        requestBody.put('peopleId', UserContext.peopleId);
        if(isADGroupsV2Enabled) {
            requestBody.put('releaseVersion', ServiceConstants.RELEASE_VERSION);
        }
        requestBody.put('size', size);
        requestBody.put('tab', tab);

		if(String.isNotBlank(term)) {
			requestBody.put('term', term);
        }
        if(String.isNotBlank(groupType)) {
			requestBody.put('groupType', groupType);
        }
		if(String.isNotBlank(nextPageToken)) {
			requestBody.put('nextPageToken', nextPageToken);
		}

		HTTPResponse res = Utility.getResponseFromAWS(externalEndPoint, requestBody);
		
		logger.logDebug('ActiveDirectoryService.fetchAllGroups()----status code----' + res.getStatusCode());

        String responseVal;
		if (res.getStatusCode() == 200) {
			responseVal = res.getBody();
        
        } else {

			logger.logError('ActiveDirectoryService.fetchAllGroups()----status code----' + res.getStatusCode());
			throw new SimpplrException(String.valueOf(res.getStatusCode()));
        }

		Map<String, Object> resultBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseVal);
        
        List<Object> resultList = (List<Object>) resultBodyMap.get('value');
        logger.logError('ActiveDirectoryService.fetchAllGroups()----resultList----' + resultList);
        
        List<ActiveDirectoryModel.ADGroup> adGroupWrapObjectList =  new List<ActiveDirectoryModel.ADGroup>();

        Set<String> selectedGroupsIds = null;
        Set<String> groupsIdsToFetch = new Set<String>();
        //get All returned group Ids
        for(Object rowValue:resultList){
            Map<String, Object> mapOfValues  = (Map<String, Object>) rowValue;
            groupsIdsToFetch.add((String) mapOfValues.get('id'));
        }

        if(groupsIdsToFetch.size() > 0){
            selectedGroupsIds = fetchGroupsFromIds(groupsIdsToFetch);
        }

        for(Object rowValue:resultList){
            adGroupWrapObjectList.add(convertToAdWrappper(rowValue, selectedGroupsIds, isADGroupsV2Enabled));
        }

        resultWrapperObj.listOfItems = adGroupWrapObjectList;
        resultWrapperObj.totalRecords = resultBodyMap.containsKey('@odata.count') ? (Integer) resultBodyMap.get('@odata.count') : null;
        resultWrapperObj.nextPageToken = resultBodyMap.containsKey('@odata.nextLink') ? sanitizeNextPageUrl((String) resultBodyMap.get('@odata.nextLink'))  : null;

        return resultWrapperObj;
    }


    /**
     * @description this method extracts nextPage token from nextPage url
     * @return String - nextPageToken string
     * @param urlString - String nextPage url value
     */
    private String sanitizeNextPageUrl(String urlString) {
        ApexPages.PageReference ref = new ApexPages.PageReference(urlString);
        Map<String, String> params = ref.getParameters();
        if(params.containsKey('$skiptoken')){
            return params.get('$skiptoken');
        }
        return null;
    }

    /**
     * @description this method returns all selected groups in org
     * @return Integer - number of groups selected
     */
    private Integer fetchSelectedGroupsCount(Boolean isADGroupsV2Enabled) {
        List<String> newAdGroupTypeList = new List<String>{'mail-security', 'distribution'};
        return isADGroupsV2Enabled
            ? [SELECT count() FROM Active_Directory_Group__c WHERE Is_Deleted__c = false WITH SECURITY_ENFORCED]
            : [SELECT count() FROM Active_Directory_Group__c WHERE AD_Group_Type__c NOT IN :newAdGroupTypeList AND Is_Deleted__c = false WITH SECURITY_ENFORCED];
    }

    /**
     * @description this method fetch saved and selected group ids from sf db
     * @return Set<String> - list of all group ids selected
     * @param groupIds - Set<String>
     */
    private Set<String> fetchGroupsFromIds(Set<String> groupIds) {
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1',groupIds);
        String groupQuery = 'SELECT Id,AD_Object_Id__c FROM Active_Directory_Group__c Where AD_Object_Id__c IN :soqlParam1 AND Is_Deleted__c = false';
       
        Set<String> selectedGroups = new Set<string>();
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<Active_Directory_Group__c> groupsList = (List<Active_Directory_Group__c>)SIMPESAPI.accessController().queryAsUser(groupQuery, soqlParamMap);

        for(Active_Directory_Group__c groupObj: groupsList){
            selectedGroups.add('\''+groupObj.AD_Object_Id__c+'\'');
        }
        return selectedGroups;
    }

    /**
     * @description this method fetch saved and selected group ids from sf db
     * @return List<String> - list of all group ids selected
     * @param nextPageToken - integer nextPageToken value
     * @param size - integer size value
     */
    private List<String> fetchSelectedGroupsSF(Integer nextPageToken, Integer size, Boolean isADGroupsV2Enabled) {
        if(nextPageToken != null && nextPageToken > 2000){
            throw new SimpplrException('Offset limit 2000');
        }

        Map<String, Object> soqlParamMap = new Map<String, Object>();

        String groupQuery = 'SELECT Id, AD_Object_Id__c, AD_Group_Type__c FROM Active_Directory_Group__c WHERE Is_Deleted__c = false';
        
        if(size != null && size > 0){
            soqlParamMap.put('soqlParam1', size+1);
            groupQuery += ' LIMIT :soqlParam1';
        }

        if(nextPageToken != null && nextPageToken > 0){
            soqlParamMap.put('soqlParam2', nextPageToken);
            groupQuery += ' OFFSET :soqlParam2';
        }

        List<String> selectedGroups = new List<string>();
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<Active_Directory_Group__c> groupsList = (List<Active_Directory_Group__c>)SIMPESAPI.accessController().queryAsUser(groupQuery, soqlParamMap);

        for(Active_Directory_Group__c groupObj: groupsList){
            if(!isADGroupsV2Enabled && (groupObj.AD_Group_Type__c == 'mail-security' || groupObj.AD_Group_Type__c == 'distribution')) {
                continue;
            }
            selectedGroups.add('\''+groupObj.AD_Object_Id__c+'\'');
        }
        return selectedGroups;
    }

    /**
     * @description this method handle conversion of ad aws response to UI response
     * @return ActiveDirectoryModel.ADGroup - response wrapper
     * @param rowValue - Object type instance of group from AWS
     */
    private ActiveDirectoryModel.ADGroup convertToAdWrappper(Object rowValue, Set<String> selectedGroupsIds, Boolean isADGroupsV2Enabled){
        Map<String, Object> mapOfValues  = (Map<String, Object>) rowValue;
        ActiveDirectoryModel.ADGroup adGroupWrapObject =  new ActiveDirectoryModel.ADGroup();
        adGroupWrapObject.id = (String) mapOfValues.get('id');
        adGroupWrapObject.name = (String) mapOfValues.get('displayName');
        adGroupWrapObject.email = (String) mapOfValues.get('mail');
        if(isADGroupsV2Enabled) {
            List<String> groupTypes = (List<String>) JSON.deserializeStrict(JSON.serialize(mapOfValues.get('groupTypes')), List<String>.class);
            if(!groupTypes.isEmpty() && groupTypes[0] == 'Unified') {
                adGroupWrapObject.groupType = 'microsoft365';
            } else if (mapOfValues.get('mailEnabled') == true) {
                adGroupWrapObject.groupType = mapOfValues.get('securityEnabled') == true ? 'mail-security' : 'distribution';
            } else if (mapOfValues.get('securityEnabled') == true) {
                adGroupWrapObject.groupType = 'security';
            }  
        } else {
            adGroupWrapObject.groupTypes = (List<String>) JSON.deserializeStrict(JSON.serialize(mapOfValues.get('groupTypes')), List<String>.class) ;
        }
        if(selectedGroupsIds != null){ //Check for All groups tab if group is in selected groups or not
            if(selectedGroupsIds.contains('\''+adGroupWrapObject.id+'\'')){
                adGroupWrapObject.isSelected = true;
            }else{
                adGroupWrapObject.isSelected = false;
            }
            
        } else {
            adGroupWrapObject.isSelected = true;
        }

        return adGroupWrapObject;
    }

    /**
     * @description this method handle all the ad group member listing, filteing and searching
     * @return ResultWrapper - response wrapper
     * @param requestData - String type request map
     */
    public ResultWrapper getActiveDirectoryGroupMembers(String requestData){
        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(requestData);
        logger.logDebug('ActiveDirectoryService.getActiveDirectoryGroupMembers()----requestMap----' + requestMap);

        if(!requestMap.containsKey('groupId')){
            throw new SimpplrException('Group Id is missing in reqest');
        }

        String groupId = (String) requestMap.get('groupId');
        String nextPageToken = requestMap.containsKey('nextPageToken') ? (String) requestMap.get('nextPageToken') : null;
        Integer size = requestMap.containsKey('size') ? (Integer) requestMap.get('size') : SimpplrContext.simpplrDefaultPageSize;
        String term = requestMap.containsKey('term') ? (String) requestMap.get('term') : null;

		String externalEndPoint = SimpplrContext.simpplrAPIEndpoint + '/ad-groups/group-manager';
        Map<String, Object> requestBody = new Map<String, Object>();
		requestBody.put('action', 'getADGroupMembers');
        requestBody.put('orgId', SimpplrContext.simpplrOrgId);
        requestBody.put('peopleId', UserContext.peopleId);
        requestBody.put('size', size);
        requestBody.put('groupId', groupId);

        if(String.isNotBlank(term)) {
			requestBody.put('term', term);
        }
        
        if(String.isNotBlank(nextPageToken)) {
			requestBody.put('nextPageToken', nextPageToken);
		}

		HTTPResponse res = Utility.getResponseFromAWS(externalEndPoint, requestBody);
		
		logger.logDebug('ActiveDirectoryService.fetchSelectedGroups()----status code----' + res.getStatusCode());

        String responseVal;
		if (res.getStatusCode() == 200) {
			responseVal = res.getBody();
        
        } else {

			logger.logError('ActiveDirectoryService.fetchSelectedGroups()----status code----' + res.getStatusCode());
			throw new SimpplrException(String.valueOf(res.getStatusCode()));
        }

		Map<String, Object> resultBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseVal);
        
        List<Object> resultList = (List<Object>) resultBodyMap.get('value');
        logger.logError('ActiveDirectoryService.fetchSelectedGroups()----resultList----' + resultList);
        
        List<ActiveDirectoryModel.ADGroupMember> adGroupMemberWrapObjectList =  new List<ActiveDirectoryModel.ADGroupMember>();
        for(Object rowValue:resultList){
            adGroupMemberWrapObjectList.add(convertToAdMemberWrappper(rowValue));
        }

        ResultWrapper resultWrapperObj = new ResultWrapper();
        resultWrapperObj.listOfItems = adGroupMemberWrapObjectList;
        resultWrapperObj.totalRecords = resultBodyMap.containsKey('@odata.count') ? (Integer) resultBodyMap.get('@odata.count') : null;
        resultWrapperObj.nextPageToken = resultBodyMap.containsKey('@odata.nextLink') ? sanitizeNextPageUrl((String) resultBodyMap.get('@odata.nextLink'))  : null;

        return resultWrapperObj;
    }

    /**
     * @description this method handle conversion of ad aws response to UI response
     * @return ActiveDirectoryModel.ADGroup - response wrapper
     * @param rowValue - Object type instance of group from AWS
     */
    private ActiveDirectoryModel.ADGroupMember convertToAdMemberWrappper(Object rowValue){
        Map<String, Object> mapOfValues  = (Map<String, Object>) rowValue;
        ActiveDirectoryModel.ADGroupMember adGroupMemberWrapObject =  new ActiveDirectoryModel.ADGroupMember();
        adGroupMemberWrapObject.id = (String) mapOfValues.get('id');
        adGroupMemberWrapObject.name = (String) mapOfValues.get('displayName');
        adGroupMemberWrapObject.email = (String) mapOfValues.get('mail');

        return adGroupMemberWrapObject;
    }

    /**
     * @description ResultWrapper class for response
     */
    public class ResultWrapper{
		public String nextPageToken;
		public Integer totalRecords;
    	public List<Object> listOfItems = new List<Object>();
	}
}