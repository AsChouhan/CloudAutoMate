public with sharing class BatchProcessAudienceMembership implements Database.Batchable<SObject>, Database.Stateful  {
	private String batchType; 
	private String query;
	private String audienceId;
	private String subscriptionEntityId;
	private String subscriptionId;
	private Set<Id> siteIdSet;
	private List<String> listOfPeople;
	private Boolean isUserEmailToBeSwitchedOff;
	private Exception exceptionDetailsObj;
	
	/**
	 * @description construtor
	 * @param audienceId
	 * @param peopleIds
	 */
	public BatchProcessAudienceMembership(String audienceId, List<String> peopleIds) {
		this.audienceId = audienceId;
		this.listOfPeople = peopleIds;
	}
	
	public database.querylocator start (Database.BatchableContext bc) {
		String packageName = SimpplrContext.packageName;
		List<Audience__c> audienceList = [SELECT Id, Segment__c FROM Audience__c WHERE id = :audienceId];
		String segmentId = audienceList[0].Segment__c;
		
		query = 'SELECT Id, Segment__c, User__c FROM People__c WHERE User__r.IsActive = true';
		
		if(String.isNotBlank(segmentId)){
			query += ' AND Segment__c = :segmentId';
		}
		if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
			query += ' AND user__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: packageName)';
		}
		if(Utility.isApiOnlyUserQueryable()){
			query += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			query += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\')) ';
		}
		
		query += ' ORDER BY CreatedDate';
  		 
  		return Database.getQueryLocator(query);
	}
	
	public void execute (Database.BatchableContext bc, sObject[] listOfsObject) {
		try {
			List<People__c> peopleList = (List<People__c>) listOfsObject;	    		
			updateAudienceMembers(peopleList);
  		} catch(Exception ex) {
			exceptionDetailsObj =  ex;
			throw ex;
		}
	}
	
	private void updateAudienceMembers(List<People__c> peopleList){
    	List<String> currentScopePeopleIdList = new List<String>();
    	for (People__c peopleObj : peopleList){
    		currentScopePeopleIdList.add(peopleObj.Id);
    	}
    	
    	// New audience as per the current batch scope
		List<People__c> newAudienceMemberPeopleList = getAudienceMembers(currentScopePeopleIdList);
    	// Old audience as per the current batch scope
    	List<Audience_Member__c> oldAudienceMembers = [SELECT id, People__c FROM Audience_Member__c 
    													WHERE people__c IN :currentScopePeopleIdList
    													AND Audience__c = :audienceId];
    	
    	Set<String> oldAudienceMemberSet = new Set<String>();
    	for (Audience_Member__c audMemObj : oldAudienceMembers){
    		oldAudienceMemberSet.add(audMemObj.People__c);
    	}
    	
    	Set<String> removedAudiencePeopleIdSet = new Set<String>();
    	List<Audience_Member__c> newAudienceMemberList = new List<Audience_Member__c>();
    	Set<String> commonAudiencePeopleIdSet = new Set<String>();
    	for (People__c peopleObj : newAudienceMemberPeopleList){
    		if(!oldAudienceMemberSet.contains(peopleObj.Id)){
    			Audience_Member__c audienceMember = new Audience_Member__c(
														Audience__c = this.audienceId,
														Is_All_Subscription_Required__c = true,
														People__c = peopleObj.Id,
														User__c = peopleObj.User__c);
				
				newAudienceMemberList.add(audienceMember);
    		} else {
    			commonAudiencePeopleIdSet.add(peopleObj.Id);
    		}
    	}
    	for (String peopleId : oldAudienceMemberSet){
    		if(!commonAudiencePeopleIdSet.contains(peopleId)){
    			removedAudiencePeopleIdSet.add(peopleId);
    		}
    	}
    	
    	// Remove All the members those doesn't belong to this audience anymore.
    	List<Audience_Member__c> removeAudienceMembers = [SELECT id FROM Audience_Member__c WHERE people__c IN :removedAudiencePeopleIdSet AND Audience__c = :audienceId];
    	
    	// Delete members acc to the new rule, if any
    	if(!removeAudienceMembers.isEmpty()){
    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	    	SIMPESAPI.accessController().deleteAsUser(removeAudienceMembers);
    	}
    	
    	// Add new members acc to the new rule, If any
		if(!newAudienceMemberList.isEmpty()){
    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(newAudienceMemberList, new List<Schema.SObjectField>{
																			Audience_Member__c.Audience__c,
																			Audience_Member__c.Is_All_Subscription_Required__c,
																			Audience_Member__c.People__c,
																			Audience_Member__c.User__c});
    	}
    }

	private List<People__c> getAudienceMembers(List<String> peopleIdList){
    	List<Audience__c> audienceList = [SELECT id, Audience_Rule_Json__c, Segment__c FROM Audience__c WHERE Id = :audienceId];
    	List<Map<String, Set<String>>> audienceRuleMapList = (List<Map<String, Set<String>>>) JSON.deserialize(
    																			audienceList[0].Audience_Rule_Json__c, 
    																			Type.forName('List<Map<String, Set<String>>>'));
    	
    	List<String> condValueList = null;
    	String newSubMemberCondition = ' User__r.isActive = true ';
    	// Handle subscriptions without segments
    	if(String.isNotBlank(audienceList[0].Segment__c)){
    		newSubMemberCondition += ' AND segment__c = \'' + audienceList[0].Segment__c + '\' ';
    	}
    	if(audienceRuleMapList != null && audienceRuleMapList.size() > 0 && audienceRuleMapList[0].containsKey('peopleId')) {
			peopleIdList = getCommonItemsList(peopleIdList, listOfPeople);
		} else {
			Map<String, String> audienceAvailableFieldsMap = Utility.getLabelVsPeopleFieldMap();
			
			for(Map<String, Set<String>> audienceRuleMap : audienceRuleMapList){
				String condName = (new list<String>(audienceRuleMap.keySet()))[0];
				Set<String> condValueSet = audienceRuleMap.get(condName);
				
				newSubMemberCondition += ' AND ' + audienceAvailableFieldsMap.get(condName);
				
				condValueList = new List<String>();
				for(String value : condValueSet){
					condValueList.add('\'' + value + '\'');
				}
				
				newSubMemberCondition += ' IN ( ' + String.join(condValueList, ',') + ' ) ';
			}
		}
		String newSubscriptionMemberQuery = 'SELECT Id, User__c FROM People__c WHERE Id IN :peopleIdList AND ' + newSubMemberCondition;
		String packageName = SimpplrContext.packageName;
		if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
			newSubscriptionMemberQuery += ' AND user__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: packageName)';
		}
		List<People__c> newSubscriptionMembers = (List<People__c>) Database.query(newSubscriptionMemberQuery);
		
		return newSubscriptionMembers;
    }

	/**
	 * @description getCommonItemsList - get list of items that are common in provided lists
	 * @param listOne
	 * @param listTwo
	 * @return List
	 */
	private List<String> getCommonItemsList(List<String> listOne, List<String> listTwo) {
		List<String> commonItems = new List<String>();
		for(String item : listOne) {
			if(listTwo.contains(item)) {
				commonItems.add(item);
			}
		}
		return commonItems;
	}
	
	public void finish (Database.BatchableContext bc) {
		AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, 
				CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
		Boolean canStartNextBatch = false;
		if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
			canStartNextBatch = true;
		} else {
			Utility.sendExceptionEmail('BatchProcessAudienceMembership.' + batchType, exceptionDetailsObj);
		}

		// Update subscription status
		String audienceId = this.audienceId;
		List<Subscription__c> subscriptionList = [SELECT Id, Status__c FROM Subscription__c WHERE Audience__c = :audienceId];
				
		if(!subscriptionList.isEmpty()){
				
			// Fire batch to make audience follow site/people											
			Map<String, String> batchParamMap = new Map<String, String>();
			batchParamMap.put('audienceId', audienceId);
					
			BatchProcessSubscription job = new BatchProcessSubscription('newSubscriptionEntities', batchParamMap);
			Database.executeBatch(job, 200);
		}
		
	}
		 
}