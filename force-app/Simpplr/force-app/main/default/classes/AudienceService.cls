/**
* @Class [AudienceService] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class AudienceService {


	private Map<String, String> peopleCatIdVsNameMap;
	private static final String ERROR_AUDIENCE_SAVE_AD = 'audience.save.ad_error_flash';

	private static Map<String, String> peopleCatIdAndNameMap {
		get {
			if(peopleCatIdAndNameMap == null) {
				peopleCatIdAndNameMap = new Map<String, String>();
				if(SimpplrContext.isPeopleCategoryEnable) {
					String pCatQuery = 'SELECT Id, Name__c FROM People_Category__c WHERE'
														+ ' Is_Deleted__c = false LIMIT 5000';
																	
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					List<People_Category__c> pCatList = (List<People_Category__c>)SIMPESAPI.accessController().queryAsUser(pCatQuery, null);

					for (People_Category__c peopleCatObj : pCatList){
						peopleCatIdAndNameMap.put(peopleCatObj.Id, peopleCatObj.Name__c);
					}
				}
			}
			return peopleCatIdAndNameMap;
		} private set;
	}

    public List<AudienceWrapper> search(String segmentId, Integer recordLimit, Integer offset, String textSearch) {
        List<AudienceWrapper> listOfAudienceWrap = new List<AudienceWrapper>();

		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		
        String query = 'SELECT ' + String.join(getAudienceFieldList(), ',') +
		' FROM Audience__c ' +
		' WHERE is_Deleted__c = false ' +
		' AND Is_Hidden__c = false';
        
        if('org'.equalsIgnoreCase(segmentId) && UserContext.isUserAppModerator) {
			segmentId = '';
		} else if( !SimpplrContext.isSegmentsEnabled ) {
			segmentId = '';
		} else if(SimpplrContext.isSegmentsEnabled && !UserContext.isUserAppModerator) {
			segmentId = UserContext.segmentId;
		}

		if(!String.isBlank(segmentId)){
			soqlParamMap.put('soqlParam1', segmentId);
			query += ' AND segment__c = :soqlParam1 ';
		}
		
		if(String.isNotBlank(textSearch)) {
			query += getSearchTermCondition(Utility.getSearchTokens(String.escapeSingleQuotes(textSearch)));
		}

		soqlParamMap.put('soqlParam2', recordLimit);
		soqlParamMap.put('soqlParam3', offset);
        query += ' Order By LastModifiedDate DESC ' +
		                 ' LIMIT :soqlParam2 OFFSET :soqlParam3';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Audience__c> audienceList = (List<Audience__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);

        Map<String, AudienceWrapper.SegmentLiteWrapper> audIdAndSegmentMap = getSegmentDetailsForAudience(audienceList);
		Map<String, List<PeopleLiteWrapper>> audienceIdToPeopleListMap = getAudienceIdToPeopleListMap(audienceList,false);

        listOfAudienceWrap = toAudienceListWrapper(audienceList, audIdAndSegmentMap, audienceIdToPeopleListMap);

        return listOfAudienceWrap;
    }

    private List<AudienceWrapper> toAudienceListWrapper(List<Audience__c> audienceList, Map<String, AudienceWrapper.SegmentLiteWrapper> audIdAndSegmentMap, Map<String, List<PeopleLiteWrapper>> audienceIdToPeopleListMap) {
        List<String> audienceIds = new List<String>();
        List<AudienceWrapper> listOfAudienceWrap = new List<AudienceWrapper>();
		Map<String, Set<String>> mapOfAudienceIdWithADGroupSet = new Map<String, Set<String>> ();
		Set<String> setOfAllADGroupsId = new Set<String>();

        for (Audience__c audienceObj : audienceList) {
            audienceIds.add(audienceObj.Id);

			if (SimpplrContext.isActiveDirectoryEnabled && 
					SimpplrContext.isActiveDirectoryGroupsEnabled) {
				List<Map<String, Set<String>>> audienceRuleMapList = new List<Map<String, Set<String>>>();
				Set<String> setOfActiveDirectoryGrpId = new Set<String>();
				String audienceRuleStr = audienceObj.Audience_Rule_Json__c;

				if (String.isNotBlank(audienceRuleStr)) {
					audienceRuleMapList = (List<Map<String, Set<String>>>) Json.deserialize(audienceRuleStr, 
							Type.forName('List<Map<String, Set<String>>>'));
				}

				if (audienceRuleMapList != null && audienceRuleMapList.size() > 0 && 
						audienceRuleMapList[0].containsKey('aDGroupSet')) {
					setOfActiveDirectoryGrpId.addAll(audienceRuleMapList[0].get('aDGroupSet'));

					if (!setOfActiveDirectoryGrpId.isEmpty()) {
						mapOfAudienceIdWithADGroupSet.put(audienceObj.id, setOfActiveDirectoryGrpId);
						setOfAllADGroupsId.addAll(setOfActiveDirectoryGrpId);
					}	

				}
			}

        }

		Map<String, Active_Directory_Group__c> mapOfADGrpIdWithObj = new Map<String, Active_Directory_Group__c>();

		if (SimpplrContext.isActiveDirectoryEnabled && 
				SimpplrContext.isActiveDirectoryGroupsEnabled) {
			Map<String, Object> soqlParamMap = new  Map<String, Object>();
			String query = 'SELECT id, name, name__c, Email__c, AD_Object_Id__c, Mail_Enabled__c,' + // change name with name__c 
					' Security_Enabled__c FROM Active_Directory_Group__c ' +
					' WHERE AD_Object_Id__c IN :soqlParam1 AND Is_Deleted__c = false';
			soqlParamMap.put('soqlParam1', setOfAllADGroupsId);
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			List<Active_Directory_Group__c> listOfADGroup = (List<Active_Directory_Group__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
			
			for ( Active_Directory_Group__c aDGrpObj: listOfADGroup) {
				mapOfADGrpIdWithObj.put(aDGrpObj.AD_Object_Id__c, aDGrpObj);
			}
		}

        AudienceWrapper.SegmentLiteWrapper segmentObj = null;
        Map<String, Integer> audienceMemberCountMap = getAudienceMemberCount(audienceIds);

		Map<String, AudienceWrapper.UsageLiteWrapper> audienceIdAndUsageMap = getAudienceUsageCount(audienceIds);

        for (Audience__c audienceObj : audienceList) {
            segmentObj = audIdAndSegmentMap.get(audienceObj.Id);
			AudienceWrapper audienceWrapObj = toAudienceWrapper(audienceObj, audienceMemberCountMap, audienceIdAndUsageMap, segmentObj, audienceIdToPeopleListMap, true);
			
			if (audienceWrapObj.type == 'activeDirectoryGroups') {
				
				for (AudienceWrapper.ADGroup aDGroupWrapObj:audienceWrapObj.listOfActiveDirectoryGroups) {

					if (mapOfADGrpIdWithObj.containsKey(aDGroupWrapObj.id)) {
						Active_Directory_Group__c aDGroupObj = new Active_Directory_Group__c();
						aDGroupObj = mapOfADGrpIdWithObj.get(aDGroupWrapObj.id);
						aDGroupWrapObj.name = aDGroupObj.name__c;
						aDGroupWrapObj.email = aDGroupObj.Email__c;

						if (aDGroupObj.Mail_Enabled__c) {
							aDGroupWrapObj.groupTypes = new List<String> {'Unified'};

						} else {
							aDGroupWrapObj.groupTypes = new List<String>();
						}

						
					}
					
				}
				
			}
			
			listOfAudienceWrap.add(audienceWrapObj);
        }

        return listOfAudienceWrap;
    }

    private AudienceWrapper toAudienceWrapper(Audience__c audienceObj,  Map<String, Integer> audienceMemberCountMap, Map<String,AudienceWrapper.UsageLiteWrapper> audienceIdAndUsageMap, AudienceWrapper.SegmentLiteWrapper segmentObj, Map<String, List<PeopleLiteWrapper>> audienceIdToPeopleListMap, Boolean allFields) {
		
		AudienceWrapper audienceWrapperObj = new AudienceWrapper();
		
        audienceWrapperObj.audienceId = audienceObj.Id;
		audienceWrapperObj.isDeleted = audienceObj.is_deleted__c;
        audienceWrapperObj.name = audienceObj.Name__c;
        
		if(audienceObj.Is_Created_By_Csv__c != null &&
			 audienceObj.Is_Created_By_Csv__c &&
				 'InProgress'.equalsIgnoreCase(audienceObj.Csv_Status__c)){
					 
			// Send count as zero if the csv is in process state.
			audienceWrapperObj.audienceCount = 0;		
		} else {

			audienceWrapperObj.audienceCount = (audienceMemberCountMap == null) ? 0 : audienceMemberCountMap.get(audienceObj.Id);
		}

        audienceWrapperObj.segment = segmentObj;
		audienceWrapperObj.segmentId = audienceWrapperObj.segment != null ? segmentObj.id : null;
		audienceWrapperObj.isCreatedFromADGroups = audienceObj.Is_Created_From_AD_Groups__c;
		audienceWrapperObj.isAutoGenerated = audienceObj.Is_Audience_Created_Automatically__c;
		audienceWrapperObj.isCreatedByAudienceCsv = audienceObj.Is_Created_By_Csv__c;
		audienceWrapperObj.status = audienceObj.Csv_Status__c;

		audienceWrapperObj.usage = (audienceIdAndUsageMap == null) ? null : audienceIdAndUsageMap.get(audienceObj.Id);
		String audienceRuleStr = audienceObj.Audience_Rule_Json__c;
		List<Map<String, Set<String>>> audienceRuleMapList = null;

		if (String.isNotBlank(audienceRuleStr)){
			audienceRuleMapList = (List<Map<String, Set<String>>>) Json.deserialize(audienceRuleStr, Type.forName('List<Map<String, Set<String>>>'));
		}

		if  (SimpplrContext.isActiveDirectoryEnabled && 
				SimpplrContext.isActiveDirectoryGroupsEnabled && !audienceRuleMapList.isEmpty() && 
				audienceRuleMapList[0].containsKey('aDGroupSet')) {
			audienceWrapperObj.type = 'activeDirectoryGroups';
			audienceWrapperObj.listOfActiveDirectoryGroups = new List<AudienceWrapper.ADGroup>();
			Set<String> setOfActiveDirectoryGrpId = new Set<String>();
			setOfActiveDirectoryGrpId.addAll(audienceRuleMapList[0].get('aDGroupSet'));

			for (String aDGrpIdStr :setOfActiveDirectoryGrpId) {
				AudienceWrapper.ADGroup aDGroupObj = new AudienceWrapper.ADGroup();
				aDGroupObj.id = aDGrpIdStr;
				audienceWrapperObj.listOfActiveDirectoryGroups.add(aDGroupObj);
			}
			
		} else if(audienceRuleMapList != null && audienceRuleMapList.size() > 0 && audienceRuleMapList[0].containsKey('peopleId')) {
			List<PeopleLiteWrapper> peopleLiteList = (List<PeopleLiteWrapper>)audienceIdToPeopleListMap.get(audienceObj.Id);
			audienceWrapperObj.listOfPeople = peopleLiteList;

			audienceWrapperObj.type = 'people';
		} else if(audienceWrapperObj.isCreatedByAudienceCsv == true) {
			audienceWrapperObj.type = 'csv';
		} else {
			List<AudienceWrapper.AudienceCondition> audienceConditionList = new List<AudienceWrapper.AudienceCondition>();
			for(Map<String, Set<String>> audienceRuleMap : audienceRuleMapList) {
				String conditionType = (new list<String>(audienceRuleMap.keySet()))[0];
				AudienceWrapper.AudienceCondition audienceConditionObj = new AudienceWrapper.AudienceCondition();
				
				audienceConditionObj.name = conditionType;

				audienceConditionObj.label = conditionType;
				
				List<AudienceWrapper.AudienceConditionValue> audienceConditionValuesList = new List<AudienceWrapper.AudienceConditionValue>();
				Set<String> audienceConditionSet = new Set<String>();	
				
				for(String valueStr : audienceRuleMap.get(conditionType)) {
					AudienceWrapper.AudienceConditionValue valueObj = new AudienceWrapper.AudienceConditionValue();
					
					valueObj.name = valueStr;
					valueObj.id = null;
					
					if('category'.equalsIgnoreCase(conditionType)){
						valueObj.name = peopleCatIdAndNameMap.get(valueStr);
						valueObj.id = valueStr;
					
					} else if('hireDateBefore'.equalsIgnoreCase(conditionType) || 'hireDateAfter'.equalsIgnoreCase(conditionType)) {
						audienceConditionObj.name = 'hireDate';
						audienceConditionObj.label = 'Hire date';
						valueObj.id = conditionType;
						valueObj.name = valueStr;

					}
					
					audienceConditionValuesList.add(valueObj);
					audienceConditionSet.add(valueStr);
				}
				
				audienceConditionObj.values = audienceConditionValuesList;
				audienceConditionObj.conditionSet = audienceConditionSet;
				
				audienceConditionList.add(audienceConditionObj);
			}
			audienceWrapperObj.listOfConditions = audienceConditionList;
			audienceWrapperObj.type = 'conditions';
		}

        audienceWrapperObj.createdAt = audienceObj.CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        audienceWrapperObj.modifiedAt = audienceObj.LastModifiedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'); 

        if(allFields) {
			if(audienceObj.Created_By_People__r != null) {
				audienceWrapperObj.createdBy = toPeopleLiteWrapper(audienceObj.Created_By_People__r);
			} 
			if(audienceObj.Created_By_People__r != null) {
        		audienceWrapperObj.modifiedBy = toPeopleLiteWrapper(audienceObj.Modified_By_People__r);
			}
		}

		for(File__c fileObj : audienceObj.File_Audience__r) {
			if(fileObj.External_id__c != null) {
				audienceWrapperObj.listOfFiles = toFileLiteWrapper(fileObj);
			}
		}
		
		return audienceWrapperObj;
	} 

	public List<FileContentWrapper> toFileLiteWrapper(File__c fileObj) {
		List<FileContentWrapper> fileWrapperList = new List<FileContentWrapper>();
    	FileContentWrapper fileWrapperObj = new FileContentWrapper();
  		fileWrapperObj.fileId = fileObj.id;
  		fileWrapperObj.fileExtension = fileObj.MIME_Type__c;		
		fileWrapperObj.id = fileObj.id;
		fileWrapperObj.externalFileId = fileObj.External_Id__c;
		fileWrapperObj.title = fileObj.title__c;
		fileWrapperObj.size = fileObj.size__c!=null ? Integer.valueOf(fileObj.size__c):0; 
		fileWrapperList.add(fileWrapperObj);
  		return fileWrapperList;
    }

    private PeopleLiteWrapper toPeopleLiteWrapper(People__c peopleObj) {
        PeopleLiteWrapper peopleLiteWrapperObj = new PeopleLiteWrapper();
        Set<Id> usersIFollowIdSet = UserContext.usersIFollowIdSet;
		Set<Id>	setOfMyFavouritePeopleId = UserContext.setOfMyFavouritePeopleId;


        peopleLiteWrapperObj.id =  peopleObj.Id;
        peopleLiteWrapperObj.peopleId =  peopleObj.Id;
        peopleLiteWrapperObj.userId =  peopleObj.user__r.Id;
        peopleLiteWrapperObj.sfUserId =  peopleObj.user__r.Id;
        if(String.isNotBlank(Utility.buildName(peopleObj.First_Name__c,peopleObj.Last_Name__c))){
            peopleLiteWrapperObj.name = Utility.buildName(peopleObj.First_Name__c,peopleObj.Last_Name__c);
        }	
        peopleLiteWrapperObj.nickname = peopleObj.Community_Nickname__c;
        peopleLiteWrapperObj.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleObj.Id;
        peopleLiteWrapperObj.img = peopleObj.user__r.SmallPhotoURL.endsWith('005/T') ? null : peopleObj.user__r.SmallPhotoURL;
        peopleLiteWrapperObj.department = peopleObj.Department__c;
        peopleLiteWrapperObj.title = peopleObj.Title__c;
        peopleLiteWrapperObj.location = Utility.buildLocation(peopleObj.City__c, peopleObj.State__c, peopleObj.Country__c);
        peopleLiteWrapperObj.email = peopleObj.Email__c;
        peopleLiteWrapperObj.phone = peopleObj.Phone__c;
        peopleLiteWrapperObj.mobile = peopleObj.mobile_phone__c;
        peopleLiteWrapperObj.phoneExtension = peopleObj.extension__c;
        peopleLiteWrapperObj.about = peopleObj.About__c;
        peopleLiteWrapperObj.birthday = SimpplrContext.isPPBirthDateDisplay ? Utility.dateToDisplayString(peopleObj.Birth_Date__c,'MM-dd') : null;
        if(SimpplrContext.isPPJoiningDateDisplay && peopleObj.Joining_Date__c != null && peopleObj.Joining_Date__c < Date.today().addDays(-3)) {
            peopleLiteWrapperObj.hireDate = Utility.dateToDisplayString(peopleObj.Joining_Date__c,'yyyy-MM-dd');
            peopleLiteWrapperObj.workAnniversary = Utility.dateToDisplayString(peopleObj.Joining_Date__c,'MM-dd');
        }	
        peopleLiteWrapperObj.isFollowing = usersIFollowIdSet.contains(peopleObj.User__c);	
        peopleLiteWrapperObj.isFavorited = setOfMyFavouritePeopleId.contains(peopleObj.Id);	
        peopleLiteWrapperObj.isActive = peopleObj.User__r.isactive;
        peopleLiteWrapperObj.canFollow = (UserContext.getCurrentUserInfo.Id == peopleObj.Id) ? false : peopleObj.User__r.isactive;
    
        if(ServiceConstants.VIDEO_PROVIDER_ZOOM.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
            peopleLiteWrapperObj.videoCallUsername = peopleObj.Zoom_Id__c;
        } else if(ServiceConstants.VIDEO_PROVIDER_SKYPE.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
            peopleLiteWrapperObj.videoCallUsername = peopleObj.Skype_Id__c;
        }
        peopleLiteWrapperObj.videoCallProvider = SimpplrContext.PPVideoProvider;

        return peopleLiteWrapperObj;
    }

    private Map<String, AudienceWrapper.SegmentLiteWrapper> getSegmentDetailsForAudience(List<Audience__c> audienceList) {
        Map<String, AudienceWrapper.SegmentLiteWrapper> audIdAndSegmentMap = new Map<String, AudienceWrapper.SegmentLiteWrapper>();

        List<String> segmentIds = new List<String>();

        for(Audience__c audienceObj : audienceList) {
            if(String.isNotBlank(audienceObj.Segment__c)) {
                segmentIds.add(audienceObj.Segment__c);
            }
        }

        Map<String, AudienceWrapper.SegmentLiteWrapper> segmentMap = new Map<String, AudienceWrapper.SegmentLiteWrapper>();
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', segmentIds);
		String query = 'SELECT Id, Name__c, Created_By_People__c, CreatedDate, Modified_By_People__c, LastModifiedDate ' 
						+ ' FROM Segment__c '
						+ ' WHERE Id = :soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Segment__c> segmentList = (List<Segment__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);

        for(Segment__c segmentObj : segmentList) {
            segmentMap.put(segmentObj.Id, toSegmentLiteWrapper(segmentObj));
        }

        for(Audience__c audienceObj : audienceList) {
            if(segmentMap.containsKey(audienceObj.Segment__c)) {
                audIdAndSegmentMap.put(audienceObj.Id, segmentMap.get(audienceObj.Segment__c));
            }
        }

        return audIdAndSegmentMap;
    }

	private Map<String, List<PeopleLiteWrapper>> getAudienceIdToPeopleListMap(List<Audience__c> audienceList,Boolean fromEditModal) {
		Map<String, List<PeopleLiteWrapper>> audienceIdToPeopleListMap = new Map<String, List<PeopleLiteWrapper>>();
		Set<String> audienceSet = new Set<String>();

		List<Map<String, Set<String>>> audienceRuleMapList;
		for(Audience__c audienceObj : audienceList) {
			String audienceRuleStr = audienceObj.Audience_Rule_Json__c;
			if(String.isNotBlank(audienceRuleStr)){
				audienceRuleMapList = (List<Map<String, Set<String>>>) Json.deserialize(audienceRuleStr, Type.forName('List<Map<String, Set<String>>>'));
			}
			if(audienceRuleMapList != null && audienceRuleMapList.size() > 0 && audienceRuleMapList[0].containsKey('peopleId')) {
				audienceSet.add(audienceObj.Id);
			}
			audienceRuleMapList = null;
		}

		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', audienceSet);
		if(fromEditModal){
			if(audienceSet!=null && !audienceSet.isEmpty()){	
			String audienceId = new List<String> (audienceSet).get(0);	
			soqlParamMap.put('soqlParam2', audienceId);
			String queryAudienceMembStr = 'select People__r.Id, People__r.Full_Name__c, People__r.User__c from audience_member__c where User__r.isActive = true And Audience__c = :soqlParam2';
			List<Audience_Member__c> audienceMembList = (List<Audience_Member__c>)SIMPESAPI.accessController().queryAsUser(queryAudienceMembStr, soqlParamMap);
			List<People__c> peopleList = new List<People__c>();
				for(Audience_Member__c memberObj : audienceMembList) {
					peopleList.add(memberObj.people__r);
				}
				audienceIdToPeopleListMap.put(audienceId, toPeopleLiteWrapperList(peopleList));
			}
		}else{
			String queryStr = 'SELECT id, (select People__r.Id, People__r.Full_Name__c, People__r.User__c from audience_members__r limit 5)'
			+ ' FROM Audience__c WHERE Id IN :soqlParam1';

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			for(Audience__c audienceObj : (List<Audience__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap)) {
				List<People__c> peopleList = new List<People__c>();
				for(Audience_Member__c memberObj : audienceObj.audience_members__r) {
					peopleList.add(memberObj.people__r);
				}
				audienceIdToPeopleListMap.put(audienceObj.Id, toPeopleLiteWrapperList(peopleList));
			}

		}
		
		return audienceIdToPeopleListMap;
	}

	private List<PeopleLiteWrapper> toPeopleLiteWrapperList(List<People__c> peopleList) {
		List<PeopleLiteWrapper> peopleLiteWrapperList = new List<PeopleLiteWrapper>();

		for(People__c peopleObject : peopleList) {
			PeopleLiteWrapper peopleLiteWrapperObj = new PeopleLiteWrapper();
			peopleLiteWrapperObj.id = peopleObject.Id;
			peopleLiteWrapperObj.peopleId = peopleObject.Id;
			peopleLiteWrapperObj.sfUserId = peopleObject.User__c;
			peopleLiteWrapperObj.name = peopleObject.Full_Name__c;
			peopleLiteWrapperObj.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleObject.Id;

			peopleLiteWrapperList.add(peopleLiteWrapperObj);
		}
		return peopleLiteWrapperList;
	}

    private AudienceWrapper.SegmentLiteWrapper toSegmentLiteWrapper(Segment__c segmentObj) {
        AudienceWrapper.SegmentLiteWrapper sLiteWrapperObj = new AudienceWrapper.SegmentLiteWrapper();

        sLiteWrapperObj.id = segmentObj.Id;
		sLiteWrapperObj.segmentId = segmentObj.Id;
        sLiteWrapperObj.name = segmentObj.Name__c;

        return sLiteWrapperObj;
    } 

	public AudienceWrapper saveAudience(AudienceWrapper audiencewrapper) {		

		Map<String, Set<String>> audienceRuleMap = null;
		List<Map<String, Set<String>>> audienceRuleMapList = new List<Map<String, Set<String>>>();
		List<Audience__c> audienceList = new List<Audience__c>(); 
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		String queryStr;
		Audience__c audienceObj = new Audience__c();

		if(audiencewrapper.type.equalsIgnoreCase('activeDirectoryGroups') && (!SimpplrContext.isActiveDirectoryGroupsEnabled ||
			!SimpplrContext.isActiveDirectoryEnabled || !SimpplrContext.adIntegrationEnabled)) {

			LocaleContext.getAllLabelMap('AudienceDataServer', new List<String>{UserContext.languageLocaleKey});
			throw new SimpplrException(LocaleContext.getLabel(UserContext.languageLocaleKey, ERROR_AUDIENCE_SAVE_AD));
		}

		if(String.isNotBlank(audienceWrapper.audienceId)){
			audienceObj.id = audienceWrapper.audienceId;	
			soqlParamMap.put('soqlParam1', audienceObj.id);
			queryStr = 'SELECT Id, Is_Deleted__c, Is_Created_By_Csv__c, (Select id, External_id__c from File_Audience__r LIMIT 1) FROM Audience__c Where id =: soqlParam1 And Is_Created_By_Csv__c = true';
			logger.logDebug('AudienceService.saveAudience()----queryStr----' + queryStr);
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			audienceList = (List<Audience__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
			if(!audienceList.isEmpty()) {
				deleteAudienceCsv(audienceList[0], 'save');	
			}
		}

		// Reset all the flags
		audienceObj.Has_City_Condition__c = false;
		audienceObj.Has_Company_Name_Condition__c = false;
		audienceObj.Has_Country_Condition__c = false;
		audienceObj.Has_Department_Condition__c = false;
		audienceObj.Has_Division_Condition__c = false;
        audienceObj.Has_Joining_Date_Condition__c = false;
		audienceObj.Has_People_Category_Condition__c = false;
		audienceObj.Has_State_Condition__c = false;
		audienceObj.Has_Title_Condition__c = false;
        audienceObj.Has_Custom_Field_1_Condition__c = false;
		audienceObj.Has_Custom_Field_2_Condition__c = false;
		audienceObj.Has_Custom_Field_3_Condition__c = false;
		audienceObj.Has_Custom_Field_4_Condition__c = false;
		audienceObj.Has_Custom_Field_5_Condition__c = false;
        audienceObj.Has_Custom_Field_6_Condition__c = false;
		audienceObj.Has_Custom_Field_7_Condition__c = false;
		audienceObj.Has_Custom_Field_8_Condition__c = false;
		audienceObj.Has_Custom_Field_9_Condition__c = false;
		audienceObj.Has_Custom_Field_10_Condition__c = false;
		audienceObj.Has_Custom_Field_11_Condition__c = false;
		audienceObj.Has_Custom_Field_12_Condition__c = false;
		audienceObj.Has_Custom_Field_13_Condition__c = false;
		audienceObj.Has_Custom_Field_14_Condition__c = false;
		audienceObj.Has_Custom_Field_15_Condition__c = false;
        audienceObj.Has_Custom_Field_16_Condition__c = false;
		audienceObj.Has_Custom_Field_17_Condition__c = false;
		audienceObj.Has_Custom_Field_18_Condition__c = false;
		audienceObj.Has_Custom_Field_19_Condition__c = false;
		audienceObj.Has_Custom_Field_20_Condition__c = false;
        audienceObj.Has_Custom_Field_21_Condition__c = false;
		audienceObj.Has_Custom_Field_22_Condition__c = false;
		audienceObj.Has_Custom_Field_23_Condition__c = false;
		audienceObj.Has_Custom_Field_24_Condition__c = false;
		audienceObj.Has_Custom_Field_25_Condition__c = false;							
		audienceObj.Is_Created_From_AD_Groups__c = false;
		audienceObj.Is_Created_By_Csv__c = false;

        if(audiencewrapper.listOfPeople != null && !audiencewrapper.listOfPeople.isEmpty()) {
			audienceRuleMap = new Map<String, Set<String>>();
			audienceRuleMap.put('peopleId', new Set<String>());
			audienceRuleMapList.add(audienceRuleMap);
		} else if(audiencewrapper.listOfConditions != null && !audiencewrapper.listOfConditions.isEmpty()) {
			for(AudienceWrapper.AudienceCondition audienceCondObject : audiencewrapper.listOfConditions){
				audienceRuleMap = new Map<String, Set<String>>();
				if('hireDate'.equalsIgnoreCase(audienceCondObject.name) == false) {
					audienceRuleMap.put(audienceCondObject.name, new Set<String>());
				}
				// turn on relative flag 
				fillAudienceFlagField(audienceObj, audienceCondObject.name);

				if((audienceCondObject.values).isEmpty()) {
					throw new SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
				}
			
				for(AudienceWrapper.AudienceConditionValue valueObj : audienceCondObject.values){					
					if('hireDateBefore'.equalsIgnoreCase(valueObj.id) || 'hireDateAfter'.equalsIgnoreCase(valueObj.id)) {
						Date dateValidator;
						try {
							dateValidator = Date.valueOf(valueObj.name);
						} catch(Exception ex) {
							throw new SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
						}
						audienceRuleMap.put(valueObj.id, new Set<String>{String.ValueOf(dateValidator)});	
					} else {
						String conditionValue = String.isNotBlank(valueObj.id) ? valueObj.id : valueObj.name;
						audienceRuleMap.get(audienceCondObject.name).add(conditionValue);
					}
				}
			
				audienceRuleMapList.add(audienceRuleMap);
            } 
            
		} else if(audiencewrapper.listOfActiveDirectoryGroups != null && !audiencewrapper.listOfActiveDirectoryGroups.isEmpty()) {
			Set<String> aDGroupIdSet = new Set<String>();
            audienceRuleMap = new Map<String, Set<String>>();
            
			for (AudienceWrapper.ADGroup aDGrpObj : audiencewrapper.listOfActiveDirectoryGroups) {
				aDGroupIdSet.add(aDGrpObj.id);
            }
            
			audienceRuleMap.put('aDGroupSet', aDGroupIdSet);
			audienceRuleMapList.add(audienceRuleMap);
			audienceObj.Is_Created_From_AD_Groups__c = true;
		}

		audienceObj.Name__c = audiencewrapper.name;
		audienceObj.Segment__c = audiencewrapper.segmentId;
		audienceObj.Audience_Rule_Json__c = JSON.serialize(audienceRuleMapList);
		audienceObj.Modified_By_People__c = UserContext.peopleId;
		audienceObj.Created_By_People__c = UserContext.peopleId;

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		if(String.isBlank(audienceWrapper.audienceId)){
            audienceObj = (Audience__c) SIMPESAPI.accessController().insertAsUser(audienceObj, 
                    new List<Schema.SObjectField>{
                        Audience__c.Name__c,
                        Audience__c.Segment__c,
                        Audience__c.Audience_Rule_Json__c,
                        Audience__c.Has_City_Condition__c,
                        Audience__c.Has_Company_Name_Condition__c,
                        Audience__c.Has_Country_Condition__c,
                        Audience__c.Has_Department_Condition__c,
                        Audience__c.Has_Division_Condition__c,
                        Audience__c.Has_Joining_Date_Condition__c,
                        Audience__c.Has_People_Category_Condition__c,
                        Audience__c.Has_State_Condition__c,
                        Audience__c.Has_Title_Condition__c,
                        Audience__c.Has_Custom_Field_1_Condition__c,
                        Audience__c.Has_Custom_Field_2_Condition__c,
                        Audience__c.Has_Custom_Field_3_Condition__c,
                        Audience__c.Has_Custom_Field_4_Condition__c,
                        Audience__c.Has_Custom_Field_5_Condition__c,
                        Audience__c.Has_Custom_Field_6_Condition__c,
                        Audience__c.Has_Custom_Field_7_Condition__c,
                        Audience__c.Has_Custom_Field_8_Condition__c,
                        Audience__c.Has_Custom_Field_9_Condition__c,
                        Audience__c.Has_Custom_Field_10_Condition__c,
                        Audience__c.Has_Custom_Field_11_Condition__c,
                        Audience__c.Has_Custom_Field_12_Condition__c,
                        Audience__c.Has_Custom_Field_13_Condition__c,
                        Audience__c.Has_Custom_Field_14_Condition__c,
                        Audience__c.Has_Custom_Field_15_Condition__c,
                        Audience__c.Has_Custom_Field_16_Condition__c,
                        Audience__c.Has_Custom_Field_17_Condition__c,
                        Audience__c.Has_Custom_Field_18_Condition__c,
                        Audience__c.Has_Custom_Field_19_Condition__c,
                        Audience__c.Has_Custom_Field_20_Condition__c,
                        Audience__c.Has_Custom_Field_21_Condition__c,
                        Audience__c.Has_Custom_Field_22_Condition__c,
                        Audience__c.Has_Custom_Field_23_Condition__c,
                        Audience__c.Has_Custom_Field_24_Condition__c,
                        Audience__c.Has_Custom_Field_25_Condition__c,																								
                        Audience__c.Created_By_People__c,
                        Audience__c.Modified_By_People__c,
						Audience__c.Is_Created_From_AD_Groups__c,
						Audience__c.Is_Created_By_Csv__c
                    });
		} else {
            SIMPESAPI.accessController().updateAsUser(audienceObj, 
                    new List<Schema.SObjectField>{
                        Audience__c.Name__c,
                        Audience__c.Segment__c,
                        Audience__c.Audience_Rule_Json__c,
                        Audience__c.Has_City_Condition__c,
                        Audience__c.Has_Company_Name_Condition__c,
                        Audience__c.Has_Country_Condition__c,
                        Audience__c.Has_Department_Condition__c,
                        Audience__c.Has_Division_Condition__c,
                        Audience__c.Has_Joining_Date_Condition__c,
                        Audience__c.Has_People_Category_Condition__c,
                        Audience__c.Has_State_Condition__c,
                        Audience__c.Has_Title_Condition__c,
                        Audience__c.Has_Custom_Field_1_Condition__c,
                        Audience__c.Has_Custom_Field_2_Condition__c,
                        Audience__c.Has_Custom_Field_3_Condition__c,
                        Audience__c.Has_Custom_Field_4_Condition__c,
                        Audience__c.Has_Custom_Field_5_Condition__c,
                        Audience__c.Has_Custom_Field_6_Condition__c,
                        Audience__c.Has_Custom_Field_7_Condition__c,
                        Audience__c.Has_Custom_Field_8_Condition__c,
                        Audience__c.Has_Custom_Field_9_Condition__c,
                        Audience__c.Has_Custom_Field_10_Condition__c,
                        Audience__c.Has_Custom_Field_11_Condition__c,
                        Audience__c.Has_Custom_Field_12_Condition__c,
                        Audience__c.Has_Custom_Field_13_Condition__c,
                        Audience__c.Has_Custom_Field_14_Condition__c,
                        Audience__c.Has_Custom_Field_15_Condition__c,
                        Audience__c.Has_Custom_Field_16_Condition__c,
                        Audience__c.Has_Custom_Field_17_Condition__c,
                        Audience__c.Has_Custom_Field_18_Condition__c,
                        Audience__c.Has_Custom_Field_19_Condition__c,
                        Audience__c.Has_Custom_Field_20_Condition__c,
                        Audience__c.Has_Custom_Field_21_Condition__c,
                        Audience__c.Has_Custom_Field_22_Condition__c,
                        Audience__c.Has_Custom_Field_23_Condition__c,
                        Audience__c.Has_Custom_Field_24_Condition__c,
                        Audience__c.Has_Custom_Field_25_Condition__c,						
                        Audience__c.Modified_By_People__c,
						Audience__c.Is_Created_From_AD_Groups__c,
						Audience__c.Is_Created_By_Csv__c
			});
		}
        
        return getAudienceById(audienceObj.id);																			
	}

    public AudienceWrapper getAudienceById(String audienceId, Boolean fromEditModal) {
		List<AudienceWrapper> listOfAudienceWrap = new List<AudienceWrapper>();
		List<String> fieldList = new List<String>();
		fieldList.addAll(getAudienceFieldList());

        String fieldsStr = String.join(fieldList, ',');
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', audienceId);
		String queryStr = 'SELECT ' + fieldsStr + ' FROM Audience__c WHERE id = :soqlParam1';
		logger.logDebug('AudienceService.getAudienceById()----queryStr----' + queryStr);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Audience__c> audienceList = (List<Audience__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
		
		if(audienceList.isEmpty()) {
			throw new SimpplrException(ServiceConstants.ERROR_404);
		}

		Map<String, AudienceWrapper.SegmentLiteWrapper> audIdAndSegmentMap = getSegmentDetailsForAudience(audienceList);
		Map<String, List<PeopleLiteWrapper>> audienceIdToPeopleListMap = getAudienceIdToPeopleListMap(audienceList,fromEditModal);

        listOfAudienceWrap = toAudienceListWrapper(audienceList, audIdAndSegmentMap, audienceIdToPeopleListMap);
		
		return listOfAudienceWrap[0];
	}

	public AudienceWrapper getAudienceById(String audienceId) {
		return getAudienceById(audienceId,false);
	}

	public Map<Id, AudienceWrapper> getAudienceIdByWrapperMap(List<Id> audienceIdsList) {
		Map<Id, AudienceWrapper> audienceIdByWrapperMap = new Map<Id, AudienceWrapper>();
		
		List<AudienceWrapper> listOfAudienceWrap = new List<AudienceWrapper>();
		List<String> fieldList = new List<String>();
		fieldList.addAll(getAudienceFieldList());

        String fieldsStr = String.join(fieldList, ',');
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', audienceIdsList);
		String queryStr = 'SELECT ' + fieldsStr + ' FROM Audience__c WHERE id = :soqlParam1';
		logger.logDebug('AudienceService.getAudienceIdByWrapperMap()----queryStr----' + queryStr);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Audience__c> audienceList = (List<Audience__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);

		if(!audienceList.isEmpty()) {
			Map<String, AudienceWrapper.SegmentLiteWrapper> audIdAndSegmentMap = getSegmentDetailsForAudience(audienceList);
			Map<String, List<PeopleLiteWrapper>> audienceIdToPeopleListMap = getAudienceIdToPeopleListMap(audienceList,false);

			listOfAudienceWrap = toAudienceListWrapper(audienceList, audIdAndSegmentMap, audienceIdToPeopleListMap);
			
			for(AudienceWrapper audWrapperObj : listOfAudienceWrap) {
				audienceIdByWrapperMap.put(audWrapperObj.audienceId, audWrapperObj);
			}
		}

		return audienceIdByWrapperMap;
	}

	public AudienceWrapper getAudienceByIdAndRuleJSON(Audience__c audienceObj, Map<String, Active_Directory_Group__c> adIdToADObjectMap) {
		AudienceWrapper audienceWrapperObj = new AudienceWrapper();
		audienceWrapperObj.audienceId = audienceObj.id;
		audienceWrapperObj.name = audienceObj.Name__c;
		audienceWrapperObj.isDeleted = audienceObj.Is_Deleted__c;

		String audienceRuleStr = audienceObj.Audience_Rule_Json__c;
		
		List<Map<String, Set<String>>> audienceRuleMapList = null;
		if(String.isNotBlank(audienceRuleStr)){
			audienceRuleMapList = (List<Map<String, Set<String>>>) Json.deserialize(audienceRuleStr, Type.forName('List<Map<String, Set<String>>>'));
		}
		// for AD audience
		if(audienceRuleMapList != null && !audienceRuleMapList.isEmpty() &&
			audienceRuleMapList[0].containsKey('aDGroupSet')) {
			audienceWrapperObj.type = 'activeDirectoryGroups';
			audienceWrapperObj.listOfActiveDirectoryGroups = new List<AudienceWrapper.ADGroup>();
			Set<String> setOfActiveDirectoryGrpId = new Set<String>();
			setOfActiveDirectoryGrpId.addAll(audienceRuleMapList[0].get('aDGroupSet'));
			for (String aDGrpIdStr : setOfActiveDirectoryGrpId) {
				AudienceWrapper.ADGroup aDGroupWrapObj = new AudienceWrapper.ADGroup();
				Active_Directory_Group__c aDGroupObj = adIdToADObjectMap.get(aDGrpIdStr);
				aDGroupWrapObj.id = aDGrpIdStr;
				if(aDGroupObj != null) {
					aDGroupWrapObj.name = aDGroupObj.name__c;
					aDGroupWrapObj.email = aDGroupObj.Email__c;
	
					if (aDGroupObj.Mail_Enabled__c) {
						aDGroupWrapObj.groupTypes = new List<String> {'Unified'};
	
					} else {
						aDGroupWrapObj.groupTypes = new List<String>();
					}
				}
				audienceWrapperObj.listOfActiveDirectoryGroups.add(aDGroupWrapObj);
			}			
		} else {
			List<AudienceWrapper.AudienceCondition> audienceConditionList = new List<AudienceWrapper.AudienceCondition>();
			for(Map<String, Set<String>> audienceRuleMap : audienceRuleMapList) {
				String conditionType = (new list<String>(audienceRuleMap.keySet()))[0];
				AudienceWrapper.AudienceCondition audienceConditionObj = new AudienceWrapper.AudienceCondition();
				
				audienceConditionObj.name = conditionType;
				audienceConditionObj.label = conditionType;
				
				List<AudienceWrapper.AudienceConditionValue> audienceConditionValuesList = new List<AudienceWrapper.AudienceConditionValue>();
				
				for(String valueStr : audienceRuleMap.get(conditionType)) {
					AudienceWrapper.AudienceConditionValue valueObj = new AudienceWrapper.AudienceConditionValue();
					
					valueObj.name = valueStr;
					valueObj.id = null;
					
					if('category'.equalsIgnoreCase(conditionType)) {
						valueObj.name = getPeopleCategoryName(valueStr);
						valueObj.id = valueStr;
	
					} else if('hireDateBefore'.equalsIgnoreCase(conditionType) || 'hireDateAfter'.equalsIgnoreCase(conditionType)) {
						audienceConditionObj.name = 'hireDate';
						audienceConditionObj.label = 'Hire date';
						valueObj.id = conditionType;
						valueObj.name = valueStr;
					
					} 				
					audienceConditionValuesList.add(valueObj);
				}
				
				audienceConditionObj.values = audienceConditionValuesList;
				
				audienceConditionList.add(audienceConditionObj);
			}
			audienceWrapperObj.listOfConditions = audienceConditionList;
		}
		return audienceWrapperObj;
	}

	private String getPeopleCategoryName(String categoryId) {
		if(peopleCatIdVsNameMap == null) {
			peopleCatIdVsNameMap = new Map<String, String>();
			if(SimpplrContext.isPeopleCategoryEnable) {
				String pCatQuery = 'SELECT Id, Name__c FROM People_Category__c WHERE'
													+ ' Is_Deleted__c = false LIMIT 5000';
																
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<People_Category__c> pCatList = (List<People_Category__c>)SIMPESAPI.accessController().queryAsUser(pCatQuery, null);

				for (People_Category__c peopleCatObj : pCatList){
					peopleCatIdVsNameMap.put(peopleCatObj.Id, peopleCatObj.Name__c);
				}
			}
		}
		return peopleCatIdVsNameMap.get(categoryId);
	}

	private void fillAudienceFlagField(Audience__c audienceObj, String conditionName){

        if(String.isNotBlank(conditionName) && conditionName.containsIgnoreCase('Hire Date')) {
            conditionName = 'Hire Date';
        }

		if('city'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_City_Condition__c = true;
		} else if('country'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_Country_Condition__c = true;
		} else if('company'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_Company_Name_Condition__c = true;
		} else if('department'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_Department_Condition__c = true;
    	} else if('division'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_Division_Condition__c = true;
		} else if('Hire Date'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_Joining_Date_Condition__c = true;
		} else if('category'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_People_Category_Condition__c = true;
		} else if('state'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_State_Condition__c = true;
		} else if('title'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_Title_Condition__c = true;
		} else if('Custom_Field_1__c'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_Custom_Field_1_Condition__c = true;
		} else if('Custom_Field_2__c'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_Custom_Field_2_Condition__c = true;
		} else if('Custom_Field_3__c'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_Custom_Field_3_Condition__c = true;
		} else if('Custom_Field_4__c'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_Custom_Field_4_Condition__c = true;
		} else if('Custom_Field_5__c'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_Custom_Field_5_Condition__c = true;
		} else if('Custom_Field_6__c'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_Custom_Field_6_Condition__c = true;
		} else if('Custom_Field_7__c'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_Custom_Field_7_Condition__c = true;
		} else if('Custom_Field_8__c'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_Custom_Field_8_Condition__c = true;
		} else if('Custom_Field_9__c'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_Custom_Field_9_Condition__c = true;
		} else if('Custom_Field_10__c'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_Custom_Field_10_Condition__c = true;
		} else if('Custom_Field_11__c'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_Custom_Field_11_Condition__c = true;
		} else if('Custom_Field_12__c'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_Custom_Field_12_Condition__c = true;
		} else if('Custom_Field_13__c'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_Custom_Field_13_Condition__c = true;
		} else if('Custom_Field_14__c'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_Custom_Field_14_Condition__c = true;
		} else if('Custom_Field_15__c'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_Custom_Field_15_Condition__c = true;
		} else if('Custom_Field_16__c'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_Custom_Field_16_Condition__c = true;
		} else if('Custom_Field_17__c'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_Custom_Field_17_Condition__c = true;
		} else if('Custom_Field_18__c'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_Custom_Field_18_Condition__c = true;
		} else if('Custom_Field_19__c'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_Custom_Field_19_Condition__c = true;
		} else if('Custom_Field_20__c'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_Custom_Field_20_Condition__c = true;
		} else if('Custom_Field_21__c'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_Custom_Field_21_Condition__c = true;
		} else if('Custom_Field_22__c'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_Custom_Field_22_Condition__c = true;
		} else if('Custom_Field_23__c'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_Custom_Field_23_Condition__c = true;
		} else if('Custom_Field_24__c'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_Custom_Field_24_Condition__c = true;
		} else if('Custom_Field_25__c'.equalsIgnorecase(conditionName)) {
			audienceObj.Has_Custom_Field_25_Condition__c = true;
		}
    }

	public Integer getAudienceMemberCount(String audienceId) {
		String packageName = SimpplrContext.packageName;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', audienceId);
		String query = 'SELECT count() FROM Audience_Member__c WHERE Audience__c = :soqlParam1 AND People__r.User__r.isActive = true ';
		if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
			soqlParamMap.put('soqlParam2', packageName);
			query += ' AND user__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: soqlParam2)';
		}
		if(Utility.isApiOnlyUserQueryable()){
			query += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			query += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\')) ';
		} 
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		Integer recordCount = SIMPESAPI.accessController().countQueryAsUser(query, soqlParamMap);
		return recordCount;
	}

    public Map<String, Integer> getAudienceMemberCount(List<String> audienceIds) {
        String packageName = SimpplrContext.packageName;
		Map<String, Integer> audienceMemberCountMap = new Map<String, Integer>();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', audienceIds);
        String query = ' SELECT Audience__c audienceId, count(People__c) audienceCount from Audience_Member__c ' +
                       ' WHERE Audience__c IN :soqlParam1 ' +
                       ' AND People__r.User__r.isActive = true ';                       

        if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
			soqlParamMap.put('soqlParam2', packageName);
			query += ' AND user__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: soqlParam2)';
		}
		if(Utility.isApiOnlyUserQueryable()){
			query += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			query += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\')) ';
		}
		query += ' GROUP BY Audience__c';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<AggregateResult> arList = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);

        for(AggregateResult ar : arList) {
    		String audienceId = (Id)ar.get('audienceId');
            Integer audienceCount = ((Decimal)ar.get('audienceCount')).intValue();

            audienceMemberCountMap.put(audienceId, audienceCount);
        }

        return audienceMemberCountMap;
	}

	public Map<String, AudienceWrapper.UsageLiteWrapper> getAudienceUsageCount(List<String> audienceIds) {
		Map<String, AudienceWrapper.UsageLiteWrapper> audienceUsageCountMap = new Map<String, AudienceWrapper.UsageLiteWrapper>();
		
		Map<String, Integer> audienceUsageCountSubscriptionMap = getAudienceUsageSubscriptionCount(audienceIds);
		Map<String, Integer> audienceUsageCountNewsletterMap = getAudienceUsageNewsletterCount(audienceIds);
		Map<String, Integer> audienceUsageCountAlertsMap = getAudienceUsageAlertCount(audienceIds);
		Map<String, Integer> audienceUsageCountSocialCampaignMap = getAudienceUsageSocialCampaignCount(audienceIds);

        for(String audienceIdObj : audienceIds) {
			AudienceWrapper.UsageLiteWrapper usageLiteWrapperObj = new AudienceWrapper.UsageLiteWrapper();
			usageLiteWrapperObj.subscriptionCount = audienceUsageCountSubscriptionMap.get(audienceIdObj);
			usageLiteWrapperObj.newsletterCount = audienceUsageCountNewsletterMap.get(audienceIdObj);
			usageLiteWrapperObj.alertCount = audienceUsageCountAlertsMap.get(audienceIdObj);
			usageLiteWrapperObj.socialCampaignCount = audienceUsageCountSocialCampaignMap.get(audienceIdObj);

			String audienceId = audienceIdObj;
			audienceUsageCountMap.put(audienceId, usageLiteWrapperObj);
		}
		return audienceUsageCountMap;
	}

	public Map<String, Integer> getAudienceUsageSubscriptionCount(List<String> audienceIds) {
		Map<String, Integer> audienceUsageSubscriptionCountMap = new Map<String, Integer>();

		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', audienceIds);
		
		String queryString = 'SELECT Audience__c audienceId, count(Id) subscriptionCount FROM Subscription__c WHERE Audience__c IN :soqlParam1 GROUP BY Audience__c';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<AggregateResult> arList = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);
		
		for(AggregateResult ar : arList) {
			String audienceId = (String)ar.get('audienceId');
            Integer subscriptionCount = ((Integer)ar.get('subscriptionCount'));

			audienceUsageSubscriptionCountMap.put(audienceId, subscriptionCount);
		}
		return audienceUsageSubscriptionCountMap;
	}

	public Map<String, Integer> getAudienceUsageNewsletterCount(List<String> audienceIds) {
		Map<String, Integer> audienceUsageNewsletterCountMap = new Map<String, Integer>();

		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', audienceIds);
		String query = ' SELECT Audience__c audienceId, count(Id) newsletterCount FROM Mailer__c ' +
		               ' WHERE Audience__c IN :soqlParam1 AND Is_Deleted__c = false' +
					   ' GROUP BY Audience__c ';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<AggregateResult> arList= (List<AggregateResult>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
		for(AggregateResult ar : arList) {
			String audienceId = (String)ar.get('audienceId');
			Integer newsletterCount = ((Integer)ar.get('newsletterCount'));

			audienceUsageNewsletterCountMap.put(audienceId, newsletterCount);
		}
		return audienceUsageNewsletterCountMap;
	}

	public Map<String, Integer> getAudienceUsageAlertCount(List<String> audienceIds) {
		Map<String, Integer> audienceUsageAlertCountMap = new Map<String, Integer>();
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', audienceIds);
		String query = ' SELECT Audience__c audienceId, count(Id) alertCount FROM Alert__c ' +
		               ' WHERE Audience__c IN :soqlParam1 AND Is_Expired__c=false AND Is_Deleted__c = false' +
					   ' GROUP BY Audience__c ';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<AggregateResult> arList = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);

		for(AggregateResult ar : arList) {
			String audienceId = (String)ar.get('audienceId');
			Integer alertCount = ((Integer)ar.get('alertCount'));

			audienceUsageAlertCountMap.put(audienceId, alertCount);
		}
		return audienceUsageAlertCountMap;
	}

	public Map<String, Integer> getAudienceUsageSocialCampaignCount(List<String> audienceIds) {
		Map<String, Integer> audienceUsageSocialCampaignMap = new Map<String, Integer>();

		String query = ' SELECT Audience__c audienceId, count(Id) socialCampaignCount FROM Social_Campaign__c ' +
		               ' WHERE Audience__c IN :audienceIds AND Is_Active__c=true AND Is_Deleted__c = false' +
					   ' GROUP BY Audience__c ';

		List<AggregateResult> arList = Database.query(query);

		for(AggregateResult ar : arList) {
			String audienceId = (String)ar.get('audienceId');
			Integer socialCampaignCount = ((Integer)ar.get('socialCampaignCount'));

			audienceUsageSocialCampaignMap.put(audienceId, socialCampaignCount);
		}
		return  audienceUsageSocialCampaignMap;
	}

	public void deleteAudience(String audienceId) {
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', audienceId);
		String queryStr = 'SELECT Id, Is_Deleted__c, Is_Created_By_Csv__c, (Select id, External_id__c from File_Audience__r LIMIT 1) FROM Audience__c WHERE Id =: soqlParam1';
		logger.logDebug('AudienceService.saveAudience()----queryStr----' + queryStr);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Audience__c> audienceList = (List<Audience__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
		if(!audienceList.isEmpty()) {
			if(audienceList[0].Is_Created_By_Csv__c == true) {
				deleteAudienceCsv(audienceList[0], 'delete');
			}
			audienceList[0].Is_Deleted__c = true;
			SIMPESAPI.accessController().updateAsUser(audienceList[0], new List<Schema.SObjectField>{
																	Audience__c.Is_Deleted__c
																	});
		} else {
			throw new SimpplrException(ServiceConstants.ERROR_404);
		}
	}

    public void deleteAudienceCsv(Audience__c audienceObj, String actionType) {
        Map<String, Object> requestMap = new Map<String, Object>();
        String fileId;
        String externalFileId;
        for(File__c fileObj : audienceObj.File_Audience__r) {
            fileId = fileObj.id;
            externalFileId = fileObj.External_Id__c;
        }
        requestMap.put('orgId', UserInfo.getOrganizationId());
        requestMap.put('audienceId', audienceObj.Id);
        requestMap.put('peopleId', UserContext.peopleId);	
        requestMap.put('fileId', fileId);
        requestMap.put('externalFileId', externalFileId);
        requestMap.put('action', 'deleteAudience');
        requestMap.put('type', actionType);
        logger.logDebug('AudienceService.deleteAudienceCsv()----request body----'+ requestMap);
        String endpoint = SimpplrContext.simpplrAPIEndpoint + '/audience/manage-audience';	
        Utility.getResponseFromAWS(endpoint, requestMap); 
    }

	public void markAlertsAsExpired(List<String> audienceIdList) {
		DateTime currentTime = DateTime.now();
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', audienceIdList);
		soqlParamMap.put('soqlParam2', currentTime);
		String query = 'SELECT Id, Display_To_DateTime__c FROM Alert__c WHERE Audience__c = :soqlParam1 AND Display_To_DateTime__c > :soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Alert__c> alertList = (List<Alert__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
		for(Alert__c alertObj : alertList) {
			alertObj.Display_To_DateTime__c = currentTime.addMinutes(-1);
		}

		if(!alertList.isEmpty()) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, Alert__c>(alertList), new List<Schema.SObjectField>{
																			Alert__c.Display_To_DateTime__c});
		}
	}

	public void markAlertsAsExpired(String audienceId) {
		markAlertsAsExpired(new List<String>{audienceId});
	}

	public void markCampaignAsInactive(List<String> audienceIdList) {

		String query = 'SELECT Id, Is_Active__c FROM Social_Campaign__c WHERE Audience__c = :soqlParam1 AND Is_Active__c = true';
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', audienceIdList);	
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Social_Campaign__c> campaignList  = (List<Social_Campaign__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);			
		for(Social_Campaign__c campaignObj : campaignList) {
			campaignObj.Is_Active__c = false;
		}

		if(!campaignList.isEmpty()) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, Social_Campaign__c>(campaignList), new List<Schema.SObjectField>{
																			Social_Campaign__c.Is_Active__c});
		}		
	}

	public void markCampaignAsInactive(String audienceId) {
		markCampaignAsInactive(new List<String>{audienceId});
	}

	public void deleteDraftOrScheduledNewsletter(List<String> audienceIdList) {
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', audienceIdList);
		String query = 'select id from Mailer__c where Audience__c= :soqlParam1 And (Status__c = \'Draft\' OR Status__c=\'Scheduled\')';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Mailer__c> mailerList  = (List<Mailer__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
		if(!mailerList.isEmpty()) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().deleteAsUser(mailerList);
		}
	}

	public void deleteDraftOrScheduledNewsletter(String audienceId) {	
		deleteDraftOrScheduledNewsletter(new List<String>{audienceId});
	}

	public void deletePendingSubscriptions(List<String> audienceIdList) {
		List<Subscription__c> subscriptionListToDelete = new List<Subscription__c>();
		List<Subscription_Entity__c> subscriptionEntityListToDelete = new List<Subscription_Entity__c>();
		
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', audienceIdList);
		String query = 'SELECT Id, Status__c, (Select Id, Status__c FROM Subscription_Entities__r) FROM Subscription__c WHERE Audience__c = :soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Subscription__c> subsObjList  = (List<Subscription__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
		for(Subscription__c subsObj : subsObjList) {
			Boolean deleteSubscription = true;
			for(Subscription_Entity__c entityObj : subsObj.Subscription_Entities__r) {
				if('pending'.equalsIgnoreCase(entityObj.Status__c)) {
					subscriptionEntityListToDelete.add(new Subscription_Entity__c(Id = entityObj.Id));
				} else {
					deleteSubscription = false;
				}
			}

			if(deleteSubscription) {
				subscriptionListToDelete.add(new Subscription__c(Id = subsObj.Id));
			}
		}

		// HARD delete pending subscription entities
		if(!subscriptionEntityListToDelete.isEmpty()) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().deleteAsUser(subscriptionEntityListToDelete);
		}

		// HARD delete subscription if it has no approved entities
		if(!subscriptionListToDelete.isEmpty()) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().deleteAsUser(subscriptionListToDelete);
		}
	}

	public void deletePendingSubscriptions(String audienceId) {
		deletePendingSubscriptions(new List<String>{audienceId});
	}

	public Boolean updateAudienceMembers(AudienceWrapper audienceWrapperObj, List<String> peopleIdslist){
		logger.logDebug('AudienceService.updateAudienceMembers()----audienceWrapperObj----' + audienceWrapperObj);
		String packageName = SimpplrContext.packageName;
		List<String> condValueList = null;
		
		// Prepare new audience member condition for query 
		Map<String, String> audienceAvailableFieldsMap = Utility.getLabelVsPeopleFieldMap();

		Date joiningStartDate = null;
		Date joiningEndDate = null;
		String segmentId = audienceWrapperObj.segmentId;
		String newSubMemberCondition = ' User__r.isActive = true ';
		List<String> listOfPeople = new List<String>();

        if(audienceWrapperObj.listOfPeople != null && !audienceWrapperObj.listOfPeople.isEmpty()) {
			Set<String> peopleIdsSet = new Set<String>();
			for(PeopleLiteWrapper peopleLiteObj : audienceWrapperObj.listOfPeople) {
				peopleIdsSet.add(peopleLiteObj.peopleId);
			}
			listOfPeople.addAll(peopleIdsSet);
			newSubMemberCondition += ' AND Id IN :peopleIdsSet ';
		} else if(audienceWrapperObj.listOfConditions != null) {
			for(AudienceWrapper.AudienceCondition audienceCondObject : audienceWrapperObj.listOfConditions) {										
				if(audienceCondObject.values.isEmpty() == false) {
					condValueList = new List<String>();
					for(AudienceWrapper.AudienceConditionValue valueObj : audienceCondObject.values){
						if (SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(valueObj.id) && valueObj.id.containsIgnoreCase('hireDate')) {
								newSubMemberCondition += ' AND Id IN :peopleIdslist ';

						} else if('hireDateBefore'.equalsIgnoreCase(valueObj.id)) {
							joiningStartDate = Date.valueOf(valueObj.name);
							newSubMemberCondition += ' And Joining_Date__c <= :joiningStartDate' ;

						} else if('hireDateAfter'.equalsIgnoreCase(valueObj.id)) {
							joiningEndDate = Date.valueOf(valueObj.name);
							newSubMemberCondition += ' And Joining_Date__c >= :joiningEndDate ';

						} else {
							condValueList.add('\'' + String.escapeSingleQuotes(String.isNotBlank(valueObj.id) ? valueObj.id : valueObj.name) + '\'');
						}
					}
					logger.logDebug('AudienceService.updateAudienceMember()---audienceCondObject.name' + audienceCondObject.name);
					if('hireDate'.equalsIgnoreCase(audienceCondObject.name) == false) {	
						newSubMemberCondition += ' AND ' + audienceAvailableFieldsMap.get(audienceCondObject.name) + 
													' IN ( '  +
												 		String.join(condValueList, ',') +
													' ) ';
					}
				}
			} 
		}
		
		if(String.isNotBlank(segmentId)){
			newSubMemberCondition += ' AND segment__c =:segmentId ';
		}
		
		// Insert new Audience Members
		String oldAudienceMemberQuery = 'SELECT people__c FROM Audience_Member__c WHERE Audience__c = \'' + audienceWrapperObj.audienceId + '\'';
		String newAudienceMemberCountQuery = 'SELECT COUNT(Id) peopleCount FROM People__c WHERE (Id NOT IN (' + oldAudienceMemberQuery + ')) AND ' + newSubMemberCondition;
		if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
			newAudienceMemberCountQuery += ' AND user__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: packageName)';
		}
		if(Utility.isApiOnlyUserQueryable()){
			newAudienceMemberCountQuery += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			newAudienceMemberCountQuery += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\')) ';
		}
		logger.logDebug('AudienceService.updateAudienceMember()----newAudienceMemberCountQuery----' + newAudienceMemberCountQuery);
		
		List<AggregateResult> aggResForInsert = Database.query(newAudienceMemberCountQuery);
		Integer numberOfRowsToBeInserted = (Integer) aggResForInsert[0].get('peopleCount');
		
		// Removed Audience Members Count
		String newSubscriptionMemberQuery = 'SELECT Id FROM People__c WHERE ' + newSubMemberCondition;
		String removeAudienceMemberCountQuery = 'SELECT COUNT(Id) c FROM Audience_Member__c WHERE (People__c NOT IN (' + newSubscriptionMemberQuery + ')) AND Audience__c = \'' + audienceWrapperObj.audienceId + '\' ';
		if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
			removeAudienceMemberCountQuery += ' AND user__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: packageName)';
		}

		logger.logDebug('AudienceService.updateAudienceMember()----removeAudienceMemberCountQuery----' + removeAudienceMemberCountQuery);
		List<AggregateResult> aggResForRemove = Database.query(removeAudienceMemberCountQuery);
		Integer numberOfRowsToBeDeleted = (Integer) aggResForRemove[0].get('c');
		
		// Update members in real time if the records are lesser than 9000, otherwise call a batch.
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		if((numberOfRowsToBeInserted + numberOfRowsToBeDeleted) > 3000) {
			BatchProcessAudienceMembership job = new BatchProcessAudienceMembership(audienceWrapperObj.audienceId, listOfPeople);
			Database.executeBatch(job, 2000);	
		
			return true;
		} else {
			// Add new members acc to the new rule, If any
			String peopleListToAddAsMemberQuery = 'SELECT Id, User__c FROM People__c WHERE (Id NOT IN (' + oldAudienceMemberQuery + ')) AND ' + newSubMemberCondition;
			if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
				peopleListToAddAsMemberQuery += ' AND user__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: packageName)';
			}
			if(Utility.isApiOnlyUserQueryable()){
				peopleListToAddAsMemberQuery += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
			} else {
				peopleListToAddAsMemberQuery += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\')) ';
			}
			List<People__c> newPeopleList = (List<People__c>) Database.query(peopleListToAddAsMemberQuery);

			List<Audience_Member__c> newAudienceMemberList = new List<Audience_Member__c>();
			for(People__c peopleObj : newPeopleList){
				Audience_Member__c audienceMember = new Audience_Member__c(
														Audience__c = audienceWrapperObj.audienceId,
														Is_All_Subscription_Required__c = true,
														People__c = peopleObj.Id,
														User__c = peopleObj.User__c);
				
				newAudienceMemberList.add(audienceMember);
			}
			
			if(!newAudienceMemberList.isEmpty()){
				SIMPESAPI.accessController().insertAsUser(newAudienceMemberList, new List<Schema.SObjectField>{
																				Audience_Member__c.Audience__c,
																				Audience_Member__c.Is_All_Subscription_Required__c,
																				Audience_Member__c.People__c,
																				Audience_Member__c.User__c});
			}
			
			// Delete members acc to the new rule, if any
			String removeAudienceMemberQuery = 'SELECT Id, People__c FROM Audience_Member__c WHERE (People__c NOT IN (' + newSubscriptionMemberQuery + ')) AND Audience__c = \'' + audienceWrapperObj.audienceId + '\'';
			if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
				removeAudienceMemberQuery += ' AND user__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: packageName)';
			}
			List<Audience_Member__c> removedAudienceMemberList = (List<Audience_Member__c>) Database.query(removeAudienceMemberQuery);
			
			if(!removedAudienceMemberList.isEmpty()){
				SIMPESAPI.accessController().deleteAsUser(removedAudienceMemberList);
			}
			
			// Fire batch to make audience follow site/people											
			Map<String, String> batchParamMap = new Map<String, String>();
			batchParamMap.put('audienceId', audienceWrapperObj.audienceId);

			BatchProcessSubscription job = new BatchProcessSubscription('newSubscriptionEntities', batchParamMap);
			Database.executeBatch(job, 200);
				
			return false; // TODO - not sure if return is required.. ie. whether this needs to be handled
		}
	}

	public Audience__c getSegmentDefaultAudience(String segmentId) {
		Audience__c audienceObj;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', segmentId);
		String queryStr = 'SELECT Id, Name__c, Audience_Member_Count__c FROM Audience__c '+
											' WHERE Segment__c = :soqlParam1 AND Is_Hidden__c = true AND Is_Deleted__c = false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Audience__c> audienceList = (List<Audience__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
		if(!audienceList.isEmpty()) {
			audienceObj = audienceList[0];
		}

		return audienceObj;
	}

	private String getSearchTermCondition(Set<String> setOfSearchTerms) {
		String queryStr = '';
		if (setOfSearchTerms != null) {
			for(String searchToken:setOfSearchTerms) {
    				queryStr += ' And Name__c like \'%'+searchToken+'%\' ';
			}
        }
        return queryStr;
	}

	public List<String> getAudienceFieldList() {
		List<String> fieldList = new List<String>{
			'Id',
			'Name__c',
			'CreatedDate',
			'LastModifiedDate',
			'Segment__c',
			'Is_Deleted__c',
            'Audience_Rule_Json__c',
            'Audience_Member_Count__c',
			'Csv_Status__c',
			'Is_Created_By_Csv__c',
			'Created_By_People__r.user__r.Id',
			'Created_By_People__r.First_Name__c',
			'Created_By_People__r.Community_Nickname__c',
            'Created_By_People__r.Last_Name__c',
            'Created_By_People__r.Full_Name__c',
            'Created_By_People__r.user__r.SmallPhotoURL',
			'Created_By_People__r.Department__c',
			'Created_By_People__r.About__c',
			'Created_By_People__r.Title__c',
			'Created_By_People__r.City__c',
			'Created_By_People__r.State__c',
			'Created_By_People__r.Country__c',
			'Created_By_People__r.Email__c',
			'Created_By_People__r.Phone__c',
			'Created_By_People__r.mobile_phone__c',
			'Created_By_People__r.extension__c',
			'Created_By_People__r.Birth_Date__c',
			'Created_By_People__r.Joining_Date__c',
			'Created_By_People__r.Skype_Id__c',
			'Created_By_People__r.Zoom_Id__c',
			'Created_By_People__r.User__c',
			'Created_By_People__r.User__r.isactive',	
			'Modified_By_People__r.user__r.Id',
			'Modified_By_People__r.First_Name__c', 
			'Modified_By_People__r.Community_Nickname__c',
            'Modified_By_People__r.Last_Name__c',
            'Modified_By_People__r.Full_Name__c',
            'Modified_By_People__r.user__r.SmallPhotoURL',
			'Modified_By_People__r.Department__c',
			'Modified_By_People__r.About__c',
			'Modified_By_People__r.Title__c',
			'Modified_By_People__r.City__c',
			'Modified_By_People__r.State__c',
			'Modified_By_People__r.Country__c',
			'Modified_By_People__r.Email__c',
			'Modified_By_People__r.Phone__c',
			'Modified_By_People__r.mobile_phone__c',
			'Modified_By_People__r.extension__c',
			'Modified_By_People__r.Birth_Date__c',
			'Modified_By_People__r.Joining_Date__c',
			'Modified_By_People__r.Skype_Id__c',
			'Modified_By_People__r.Zoom_Id__c',
			'Modified_By_People__r.User__c',
			'Modified_By_People__r.User__r.isactive',
			'Is_Created_From_AD_Groups__c',
			'Is_Audience_Created_Automatically__c',
			'(Select id, External_id__c, title__c, MIME_Type__c, size__c from File_Audience__r where is_deleted__c = false LIMIT 1)'
    	};

        return fieldList;
    }

    public List<AudienceWrapper> getAudienceByIds(List<String> listOfAudienceId) {
        List<AudienceWrapper> listOfAudienceWrap = new List<AudienceWrapper>();

        String audienceQuery = 'SELECT ' + String.join(getAudienceFieldList(), ',') +
                ' FROM Audience__c ' +
                ' WHERE is_Deleted__c = false ' +
                ' AND Is_Hidden__c = false AND ID IN: listOfAudienceId';
        

        List<Audience__c> audienceList = Database.query(audienceQuery);

        Map<String, AudienceWrapper.SegmentLiteWrapper> audIdAndSegmentMap = getSegmentDetailsForAudience(audienceList);
		Map<String, List<PeopleLiteWrapper>> audienceIdToPeopleListMap = getAudienceIdToPeopleListMap(audienceList,false);

        listOfAudienceWrap = toAudienceListWrapper(audienceList, audIdAndSegmentMap, audienceIdToPeopleListMap);

        return listOfAudienceWrap;
    }

	/**
	 * @description method checks whether userId is member of set of audiences
	 * @param userId
	 * @param audienceIds
	 * @return Boolean
	 */	
	public Boolean isUserMemberOfAudiences(String userId, Set<Id> audienceIds) {
		logger.logDebug('AudienceService.isUserMemberOfAudiences()----userId----' + userId + '----audience Ids----' + audienceIds);
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', userId);
		soqlParamMap.put('soqlParam2', audienceIds);
		String query = 'SELECT Id from Audience_Member__c '+
						'WHERE User__c =: soqlParam1 ' +
						'AND Audience__c IN: soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Audience_Member__c> userAudienceMemeberList = (List<Audience_Member__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);	
		if(userAudienceMemeberList.size() > 0) {
			return true;
		}
		return false;
	}

}