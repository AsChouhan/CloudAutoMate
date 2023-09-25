public with sharing class BatchSyncAudienceMembership implements Database.Batchable<SObject>, Database.Stateful {
	private String batchType;
	private String query;
	private Set<Id> peopleIdSet;
	String packageName;
	private List<Audience_Member__c> newAudienceMembersList = new List<Audience_Member__c>();
	private List<Audience_Member__c> removeAudienceMembersList = new List<Audience_Member__c>();
	
	public BatchSyncAudienceMembership (String batchTypeArg, Set<Id> peopleIdSet) {
		packageName = SimpplrContext.packageName;
		this.batchType = batchTypeArg;
		this.peopleIdSet = peopleIdSet;
	}
			
	public database.querylocator start (Database.BatchableContext bc) {
		query = 'SELECT id, Country__c, City__c, Company_Name__c, Department__c, Joining_Date__c, '
  				+ ' Division__c, People_Category__c, State__c, Segment__c, User__c, Title__c, Location_Normalization_Status__c, ' 
				+ ' Custom_Field_1__c, Custom_Field_2__c, Custom_Field_3__c, Custom_Field_4__c, Custom_Field_5__c, '
				+ ' Custom_Field_6__c, Custom_Field_7__c, Custom_Field_8__c, Custom_Field_9__c, Custom_Field_10__c, '
				+ ' Custom_Field_11__c, Custom_Field_12__c, Custom_Field_13__c, Custom_Field_14__c, Custom_Field_15__c, '
				+ ' Custom_Field_16__c, Custom_Field_17__c, Custom_Field_18__c, Custom_Field_19__c, Custom_Field_20__c, '
				+ ' Custom_Field_21__c, Custom_Field_22__c, Custom_Field_23__c, Custom_Field_24__c, Custom_Field_25__c '
  				+ ' FROM People__c WHERE User__r.IsActive = true ';
		
  		if(this.peopleIdSet != null && !this.peopleIdSet.isEmpty()){
  			query += ' AND Id IN :peopleIdSet';
  		}
		
		if('deleteDuplicateRecords'.equalsIgnoreCase(batchType)) {
			//Do nothing
		}  else {
			query += ' AND Audience_Processing_Required__c = true ';
			if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
				query += ' And user__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =:packageName) ';
			}
			if(Utility.isApiOnlyUserQueryable()){
				query += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
			} else {
				query += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\')) ';
			}
		}
  		 
		if(Test.isRunningTest()) {
			query += ' Limit 1';
		}
  		return Database.getQueryLocator(query);
	}
	
	public void execute (Database.BatchableContext bc, sObject[] listOfsObject) {
		List<People__c> peopleList = (List<People__c>) listOfsObject;
  		
  		if ('addUserAudienceMembership'.equalsIgnoreCase(batchType)) {
  			for(People__c peopleObj : peopleList){
  				addUserAudienceMembership(peopleObj);
				peopleObj.Audience_Processing_Required__c = false;
  			}
			update peopleList;
  		}else if ('editUserAudienceMembership'.equalsIgnoreCase(batchType)) {
  			for(People__c peopleObj : peopleList){
  				editUserAudienceMembership(peopleObj);
				peopleObj.Audience_Processing_Required__c = false;
				if(peopleObj.Location_Normalization_Status__c != null && peopleObj.Location_Normalization_Status__c < 10 && peopleObj.Location_Normalization_Status__c >=5) {
					peopleObj.Location_Normalization_Status__c -= 5;
				}
		    }
			update peopleList;
  		} else if('deleteDuplicateRecords'.equalsIgnoreCase(batchType)) {
			deleteDuplicateRecords(peopleList);
		}
  		
  		processAudienceMemberShip();
	}

	private void deleteDuplicateRecords(List<People__c> peopleList) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', peopleList);
		String queryStr = 'select Audience__c, People__c from Audience_Member__c '+
										' where People__c=: soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Audience_Member__c> audienceMemberList = (List<Audience_Member__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
		List<Audience_Member__c> toBeDeletedAudienceMemberList = new List<Audience_Member__c>();
		Set<String> audienceIdPeopleIdSet = new Set<String>();
		for(Audience_Member__c memberObj:audienceMemberList) {
			String key = String.valueOf(memberObj.Audience__c) + String.valueOf(memberObj.People__c);
			if(audienceIdPeopleIdSet.contains(key)) {
				toBeDeletedAudienceMemberList.add(memberObj);
			} else {
				audienceIdPeopleIdSet.add(key);
			}
		}
		if(toBeDeletedAudienceMemberList.size() > 0) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().deleteAsUser(toBeDeletedAudienceMemberList);
		}
	}
	
	public void finish (Database.BatchableContext bc) {
		String queryStr = 'select audience__c, People__c, count(id) '+
								' from Audience_Member__c'+
								' WHERE User__r.IsActive = true'+
								' And People__c != null'+
								' And Audience__r.Is_Deleted__c = false'+
								' group by Audience__c, People__c'+
								' having count(id)  > 1 Limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<AggregateResult> aggrList = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(queryStr, null);
		if(aggrList.size() > 0) {
			BatchSyncAudienceMembership manageSusbcriptionJob = new BatchSyncAudienceMembership('deleteDuplicateRecords', null);
			Database.executeBatch(manageSusbcriptionJob, 200);
		}
	}
	
	private void processAudienceMemberShip(){
		// Remove the users
		if(!removeAudienceMembersList.isEmpty()){	
			SIMPESAPI.accessController().setArrayOperationMode(SIMPSFDCAccessController.OperationMode.BEST_EFFORT);											 
	    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().deleteAsUser(removeAudienceMembersList);
		}
		
		// Insert users as the new audience members
		if(!newAudienceMembersList.isEmpty()){											 
	    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPSFDCAccessControlResults.InsertResults result = SIMPESAPI.accessController().insertAsUser(newAudienceMembersList,
														new List<Schema.SObjectField>{
															Audience_Member__c.Audience__c,
															Audience_Member__c.Is_All_Subscription_Required__c,
															Audience_Member__c.People__c,
															Audience_Member__c.User__c});
			 
			Map<Id, Audience_Member__c> audienceMemberMap = new Map<Id, Audience_Member__c>(((List<Audience_Member__c>)result.getInsertedObjects()));												
			Set<Id> audienceMemberIdSet = audienceMemberMap.keySet();
			// Fetch again to get all the fields those are used in batch
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', audienceMemberIdSet);
			String queryStr = 'SELECT id, Audience__c, People__r.User__r.UserPreferencesDisableAllFeedsEmail,'+
										  					 ' People__r.User__c, Is_All_Subscription_Required__c FROM Audience_Member__c'+
										  					 ' WHERE Id IN :soqlParam1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Audience_Member__c> audienceMembersToProcessList = (List<Audience_Member__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
			// Honor subscription entities for the new members
			if(!audienceMembersToProcessList.isEmpty()){										 
		    	BatchProcessSubscription batchObj = new BatchProcessSubscription(
															'newAudienceMembers', 
															new Map<String, String>());														
				batchObj.processAudienceMembers(audienceMembersToProcessList);
			}
		}
		
		// Clear the lists for the next batch
		removeAudienceMembersList.clear();
		newAudienceMembersList.clear();
	}
	
	// Batch methods exposed as class methods
	public void managePeopleAudienceMembership(String batchType, People__c peopleObj){
		if('addUserAudienceMembership'.equalsIgnoreCase(batchType)){
			addUserAudienceMembership(peopleObj);
		} else if('editUserAudienceMembership'.equalsIgnoreCase(batchType)){
			editUserAudienceMembership(peopleObj);
		}
		
		processAudienceMemberShip();
	}
	
	// Add existing user whose profile has been updated to corresponding subscription(s)
	private void editUserAudienceMembership(People__c peopleObj) {
		List<Audience_Member__c> newAudienceMemberList = new List<Audience_Member__c>();
		Set<String> newAudienceIdSet = getExistingPeopleAudienceIdSet(peopleObj);
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', peopleObj.Id);
		String queryStr = 'SELECT id, People__c, Audience__c '+
														' FROM Audience_Member__c '+
														' WHERE people__c = :soqlParam1'+
														' And Audience__r.Is_deleted__c=false AND Audience__r.Is_Created_From_AD_Groups__c = FALSE AND Audience__r.Is_Created_By_Csv__c = FALSE';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Audience_Member__c> oldAudienceMembers = (List<Audience_Member__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
		List<String> audienceMemberIdToRemoveList = new List<String>();
		Set<String> commonAudienceMemberIdSet = new Set<String>();
		for(Audience_Member__c audienceMemberObj : oldAudienceMembers){
			if(newAudienceIdSet.contains(audienceMemberObj.Audience__c)){
				commonAudienceMemberIdSet.add(audienceMemberObj.Audience__c);
			} else if(peopleObj.Location_Normalization_Status__c == null || !(peopleObj.Location_Normalization_Status__c >= 5 && peopleObj.Location_Normalization_Status__c < 10)){
				audienceMemberIdToRemoveList.add(audienceMemberObj.Audience__c);
			}
		}
		
		List<Audience_Member__c> audienceMembersToAdd = new List<Audience_Member__c>();
		for(String audienceId : newAudienceIdSet){
			if(!commonAudienceMemberIdSet.contains(audienceId)){
				Audience_Member__c audienceMember = new Audience_Member__c(
														Audience__c = audienceId,
														Is_All_Subscription_Required__c = true,
														People__c = peopleObj.Id,
														User__c = peopleObj.User__c);
				
				audienceMembersToAdd.add(audienceMember);
			}
		}
		
    	// Delete members records which were created for previous subscriptions rules
    	if(!audienceMemberIdToRemoveList.isEmpty()){
			soqlParamMap.put('soqlParam1', audienceMemberIdToRemoveList);
			soqlParamMap.put('soqlParam2', peopleObj.Id);
    		queryStr = 'SELECT id FROM Audience_Member__c'+
														 ' WHERE Audience__c IN :soqlParam1'+
														 ' AND People__c = :soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Audience_Member__c> amToRemoveList = (List<Audience_Member__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
			removeAudienceMembersList.addAll(amToRemoveList);
    	}
		
		// Insert audience member records for this user and
		// follow site/users(i.e. honor corresponding subscription entities)
		if(!audienceMembersToAdd.isEmpty()){
    		newAudienceMembersList.addAll(audienceMembersToAdd);												
		}
	}
	
	// Add new user to corresponding Audience(s)
	private void addUserAudienceMembership(People__c peopleObj) {
		List<Audience_Member__c> audienceMemberList = getNewPeopleAudienceMemberList(peopleObj);
		
		// Insert audience member records for this user and
		// follow site/users(i.e. honor corresponding subscription entities)
		if(!audienceMemberList.isEmpty()){
    		newAudienceMembersList.addAll(audienceMemberList);												
		}
    }
    
	private List<Audience_Member__c> getNewPeopleAudienceMemberList(People__c peopleObj) {
		List<Audience_Member__c> audienceMemberList = new List<Audience_Member__c>();
		List<Audience__c> audienceList = getAudienceListForPeople(peopleObj);
		Map<String, Set<String>> audienceIdToPeopleIdsMap = getAudienceIdToPeopleIdsMap(audienceList, peopleObj.Id);
		Map<String, String> peopleFieldVsValueMap = getPeopleFieldVsValueMap(peopleObj);
		for(Audience__c audienceObj : audienceList){
			Boolean isPeopleBelongsToAudience = true;
			if(audienceObj.is_Hidden__c) {
				isPeopleBelongsToAudience = true;
			} else {
				isPeopleBelongsToAudience =  checkIfPeopleBelongsToAudience(peopleFieldVsValueMap, audienceObj.Audience_Rule_Json__c, audienceIdToPeopleIdsMap.get(audienceObj.Id));
			}
			if(isPeopleBelongsToAudience){
				Audience_Member__c audienceMember = new Audience_Member__c(
													Audience__c = audienceObj.id,
													Is_All_Subscription_Required__c = true,
													People__c = peopleObj.id,
													User__c = peopleObj.User__c);														
				audienceMemberList.add(audienceMember);				
			}
		}
		return audienceMemberList;
	}

	private Set<String> getExistingPeopleAudienceIdSet(People__c peopleObj) {
		Set<String> audienceIdSet = new Set<String>();
		List<Audience__c> audienceList = getAudienceListForPeople(peopleObj);
		Map<String, Set<String>> audienceIdToPeopleIdsMap = getAudienceIdToPeopleIdsMap(audienceList, peopleObj.Id);
		Map<String, String> peopleFieldVsValueMap = getPeopleFieldVsValueMap(peopleObj);
		for(Audience__c audienceObj : audienceList){
			Boolean isPeopleBelongsToAudience = true;
			if(audienceObj.is_Hidden__c) {
				isPeopleBelongsToAudience = true;
			} else {
				isPeopleBelongsToAudience =  checkIfPeopleBelongsToAudience(peopleFieldVsValueMap, audienceObj.Audience_Rule_Json__c, audienceIdToPeopleIdsMap.get(audienceObj.Id));
			}
			if(isPeopleBelongsToAudience){
				audienceIdSet.add(audienceObj.id);
			}
		}
		return audienceIdSet;
	}	

	private Map<String, Set<String>> getAudienceIdToPeopleIdsMap(List<Audience__c> audienceList, String peopleId) {
		Map<String, Set<String>> audienceIdToPeopleIdsMap = new Map<String, Set<String>>();

		List<Map<String, List<String>>> audienceRuleMapList;
		for(Audience__c audienceObj : audienceList) {
			String audienceRuleStr = audienceObj.Audience_Rule_Json__c;
			if(String.isNotBlank(audienceRuleStr)){
				audienceRuleMapList = (List<Map<String, List<String>>>) Json.deserialize(audienceRuleStr, List<Map<String, List<String>>>.class);
			}
			if(audienceRuleMapList != null && audienceRuleMapList.size() > 0 && audienceRuleMapList[0].containsKey('peopleId')) {
				audienceIdToPeopleIdsMap.put(audienceObj.Id, new Set<String>());
			}
			audienceRuleMapList = null;
		}

		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', audienceIdToPeopleIdsMap.keySet());
		soqlParamMap.put('soqlParam2', peopleId);
		String queryStr = 'SELECT Id, People__c, Audience__c FROM Audience_Member__c WHERE Audience__c in :soqlParam1 AND People__c = :soqlParam2 ';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		for(Audience_Member__c audienceMemberObj : (List<Audience_Member__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap)) {
			audienceIdToPeopleIdsMap.get(audienceMemberObj.Audience__c).add(audienceMemberObj.People__c);
		}
		return audienceIdToPeopleIdsMap;
	}

	private Boolean checkIfPeopleBelongsToAudience(Map<String, String> peopleFieldVsValueMap, String audienceRuleJson, Set<String> peopleIds) {
		List<Map<String, Set<String>>> audienceRuleMapList = 
							(List<Map<String, Set<String>>>)JSON.deserialize(audienceRuleJson, Type.forName('List<Map<String, Set<String>>>'));	
		Boolean isPeopleBelongsToAudience = true;		 															
		for(Map<String, Set<String>> audienceRuleMap : audienceRuleMapList){
			String ruleKey = (new list<String>(audienceRuleMap.keySet()))[0];					
			if(String.isNotBlank(peopleFieldVsValueMap.get(ruleKey))){
				Set<String> ruleValueSet = audienceRuleMap.get(ruleKey);
				if('hireDateBefore'.equalsIgnoreCase(ruleKey)) {
					isPeopleBelongsToAudience = Date.valueOf(peopleFieldVsValueMap.get(ruleKey)) <= Date.valueOf(new List<string>(ruleValueSet)[0]);

				} else if('hireDateAfter'.equalsIgnoreCase(ruleKey)) {
					isPeopleBelongsToAudience = Date.valueOf(peopleFieldVsValueMap.get(ruleKey)) >= Date.valueOf(new List<string>(ruleValueSet)[0]);

				} else if('peopleId'.equalsIgnoreCase(ruleKey)) {
					isPeopleBelongsToAudience = peopleIds.contains(peopleFieldVsValueMap.get(ruleKey));

				} else {					
					if(ruleValueSet.contains(peopleFieldVsValueMap.get(ruleKey)) == false){						
						isPeopleBelongsToAudience = false;
						break;
					}
				}
			} else {
				isPeopleBelongsToAudience = false;
				break;
			}
		}
		return isPeopleBelongsToAudience;
	}

	private Map<String, String> getPeopleFieldVsValueMap(People__c peopleObj) {
		Map<String, String> peopleFieldVsValueMap = new Map<String, String>();
		peopleFieldVsValueMap.put('country', peopleObj.Country__c);
		peopleFieldVsValueMap.put('city', peopleObj.City__c);
		peopleFieldVsValueMap.put('company', peopleObj.Company_Name__c);
		peopleFieldVsValueMap.put('department', peopleObj.Department__c);
		peopleFieldVsValueMap.put('division', peopleObj.Division__c);
		peopleFieldVsValueMap.put('category', peopleObj.People_Category__c);
		peopleFieldVsValueMap.put('state', peopleObj.State__c);
		peopleFieldVsValueMap.put('title', peopleObj.Title__c);
		peopleFieldVsValueMap.put('hireDateBefore', String.valueOf(peopleObj.Joining_Date__c));
		peopleFieldVsValueMap.put('hireDateAfter', String.valueOf(peopleObj.Joining_Date__c));
		peopleFieldVsValueMap.put('Custom_Field_1__c', peopleObj.Custom_Field_1__c);
		peopleFieldVsValueMap.put('Custom_Field_2__c', peopleObj.Custom_Field_2__c);
		peopleFieldVsValueMap.put('Custom_Field_3__c', peopleObj.Custom_Field_3__c);
		peopleFieldVsValueMap.put('Custom_Field_4__c', peopleObj.Custom_Field_4__c);
		peopleFieldVsValueMap.put('Custom_Field_5__c', peopleObj.Custom_Field_5__c);
		peopleFieldVsValueMap.put('Custom_Field_6__c', peopleObj.Custom_Field_6__c);
		peopleFieldVsValueMap.put('Custom_Field_7__c', peopleObj.Custom_Field_7__c);
		peopleFieldVsValueMap.put('Custom_Field_8__c', peopleObj.Custom_Field_8__c);
		peopleFieldVsValueMap.put('Custom_Field_9__c', peopleObj.Custom_Field_9__c);
		peopleFieldVsValueMap.put('Custom_Field_10__c', peopleObj.Custom_Field_11__c);
		peopleFieldVsValueMap.put('Custom_Field_12__c', peopleObj.Custom_Field_12__c);
		peopleFieldVsValueMap.put('Custom_Field_13__c', peopleObj.Custom_Field_13__c);
		peopleFieldVsValueMap.put('Custom_Field_14__c', peopleObj.Custom_Field_14__c);
		peopleFieldVsValueMap.put('Custom_Field_15__c', peopleObj.Custom_Field_15__c);
		peopleFieldVsValueMap.put('Custom_Field_16__c', peopleObj.Custom_Field_16__c);
		peopleFieldVsValueMap.put('Custom_Field_17__c', peopleObj.Custom_Field_17__c);
		peopleFieldVsValueMap.put('Custom_Field_18__c', peopleObj.Custom_Field_18__c);
		peopleFieldVsValueMap.put('Custom_Field_19__c', peopleObj.Custom_Field_19__c);
		peopleFieldVsValueMap.put('Custom_Field_20__c', peopleObj.Custom_Field_20__c);
		peopleFieldVsValueMap.put('Custom_Field_21__c', peopleObj.Custom_Field_21__c);
		peopleFieldVsValueMap.put('Custom_Field_22__c', peopleObj.Custom_Field_22__c);
		peopleFieldVsValueMap.put('Custom_Field_23__c', peopleObj.Custom_Field_23__c);
		peopleFieldVsValueMap.put('Custom_Field_24__c', peopleObj.Custom_Field_24__c);
		peopleFieldVsValueMap.put('Custom_Field_25__c', peopleObj.Custom_Field_25__c);

		peopleFieldVsValueMap.put('peopleId', peopleObj.Id);
		return peopleFieldVsValueMap;
	}

	private List<Audience__c> getAudienceListForPeople(People__c peopleObj){
    	String segmentId = peopleObj.Segment__c;											 		
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', segmentId);
		String subQuery = 'SELECT id, Audience_Rule_Json__c, is_Hidden__c FROM Audience__c'
						+ ' WHERE (Segment__c = :soqlParam1 OR Segment__c = null) And Is_Deleted__c = false  AND Is_Created_From_AD_Groups__c = FALSE AND Is_Created_By_Csv__c = FALSE';
				
		if(String.isBlank(peopleObj.Country__c)){
			subQuery += ' AND Has_Country_Condition__c = false';
		}
				
		if(String.isBlank(peopleObj.City__c)){
			subQuery += ' AND Has_City_Condition__c = false';
		}
			 	
		if(String.isBlank(peopleObj.Company_Name__c)){
			subQuery += ' AND Has_Company_Name_Condition__c = false';
		}
				
		if(String.isBlank(peopleObj.Department__c)){
			subQuery += ' AND Has_Department_Condition__c = false';
		}
				
		if(String.isBlank(peopleObj.Division__c)){
			subQuery += ' AND Has_Division_Condition__c = false';
		}
				
		if(String.isBlank(peopleObj.People_Category__c)){
			subQuery += ' AND Has_People_Category_Condition__c = false';
		}
				
		if(String.isBlank(peopleObj.State__c)){
			subQuery += ' AND Has_State_Condition__c = false';
		}
		
		if(peopleObj.Joining_Date__c == null){
			subQuery += ' AND Has_Joining_Date_Condition__c = false';
		}

		if(String.isBlank(peopleObj.Title__c)){
			subQuery += ' AND Has_Title_Condition__c = false';
		}
		
		if(String.isBlank(peopleObj.Custom_Field_1__c)){
			subQuery += ' AND Has_Custom_Field_1_Condition__c = false';
		}

		if(String.isBlank(peopleObj.Custom_Field_2__c)){
			subQuery += ' AND Has_Custom_Field_2_Condition__c = false';
		}

		if(String.isBlank(peopleObj.Custom_Field_3__c)){
			subQuery += ' AND Has_Custom_Field_3_Condition__c = false';
		}

		if(String.isBlank(peopleObj.Custom_Field_4__c)){
			subQuery += ' AND Has_Custom_Field_4_Condition__c = false';
		}

		if(String.isBlank(peopleObj.Custom_Field_5__c)){
			subQuery += ' AND Has_Custom_Field_5_Condition__c = false';
		}	
		
		if(String.isBlank(peopleObj.Custom_Field_6__c)){
			subQuery += ' AND Has_Custom_Field_6_Condition__c = false';
		}	
		
		if(String.isBlank(peopleObj.Custom_Field_7__c)){
			subQuery += ' AND Has_Custom_Field_7_Condition__c = false';
		}	

		if(String.isBlank(peopleObj.Custom_Field_8__c)){
			subQuery += ' AND Has_Custom_Field_8_Condition__c = false';
		}	

		if(String.isBlank(peopleObj.Custom_Field_9__c)){
			subQuery += ' AND Has_Custom_Field_9_Condition__c = false';
		}	

		if(String.isBlank(peopleObj.Custom_Field_10__c)){
			subQuery += ' AND Has_Custom_Field_10_Condition__c = false';
		}	

		if(String.isBlank(peopleObj.Custom_Field_11__c)){
			subQuery += ' AND Has_Custom_Field_11_Condition__c = false';
		}	

		if(String.isBlank(peopleObj.Custom_Field_12__c)){
			subQuery += ' AND Has_Custom_Field_12_Condition__c = false';
		}	

		if(String.isBlank(peopleObj.Custom_Field_13__c)){
			subQuery += ' AND Has_Custom_Field_13_Condition__c = false';
		}	

		if(String.isBlank(peopleObj.Custom_Field_14__c)){
			subQuery += ' AND Has_Custom_Field_14_Condition__c = false';
		}	

		if(String.isBlank(peopleObj.Custom_Field_15__c)){
			subQuery += ' AND Has_Custom_Field_15_Condition__c = false';
		}	

		if(String.isBlank(peopleObj.Custom_Field_16__c)){
			subQuery += ' AND Has_Custom_Field_16_Condition__c = false';
		}	

		if(String.isBlank(peopleObj.Custom_Field_17__c)){
			subQuery += ' AND Has_Custom_Field_17_Condition__c = false';
		}	

		if(String.isBlank(peopleObj.Custom_Field_18__c)){
			subQuery += ' AND Has_Custom_Field_18_Condition__c = false';
		}	

		if(String.isBlank(peopleObj.Custom_Field_19__c)){
			subQuery += ' AND Has_Custom_Field_19_Condition__c = false';
		}	

		if(String.isBlank(peopleObj.Custom_Field_20__c)){
			subQuery += ' AND Has_Custom_Field_20_Condition__c = false';
		}	

		if(String.isBlank(peopleObj.Custom_Field_21__c)){
			subQuery += ' AND Has_Custom_Field_21_Condition__c = false';
		}	

		if(String.isBlank(peopleObj.Custom_Field_22__c)){
			subQuery += ' AND Has_Custom_Field_22_Condition__c = false';
		}	

		if(String.isBlank(peopleObj.Custom_Field_23__c)){
			subQuery += ' AND Has_Custom_Field_23_Condition__c = false';
		}	

		if(String.isBlank(peopleObj.Custom_Field_24__c)){
			subQuery += ' AND Has_Custom_Field_24_Condition__c = false';
		}
		
		if(String.isBlank(peopleObj.Custom_Field_25__c)){
			subQuery += ' AND Has_Custom_Field_25_Condition__c = false';
		}		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Audience__c> audienceList = (List<Audience__c>)SIMPESAPI.accessController().queryAsUser(subQuery, soqlParamMap);
		return audienceList;
	}	
}