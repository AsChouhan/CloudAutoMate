public with sharing class PeopleTriggerHandler {
    
    public void OnBeforeInsert (List<People__c> listOfNewPeople) {
    	
		for(People__c ppl : listOfNewPeople) {
			populateFullName(ppl);
			
			if(SimpplrContext.isSegmentsEnabled && String.isNotBlank(SimpplrContext.segmentColumnName)) {
				ppl.Segment_Processing_Required__c = true;
			}
		} 
		
		if(SimpplrContext.isSegmentsEnabled && String.isNotBlank(SimpplrContext.segmentColumnName)) {
			updateSegmentatId(listOfNewPeople);
		}
		
		// populate fill_date for related fields 
		populateFillDateOnInsert(listOfNewPeople);
	}
	
    public void OnAfterInsert (Map<Id,People__c> mapOfNewPeople) {
    	onAfterInsertRecord(mapOfNewPeople.values());

		Set<Id> peopleIdSet = mapOfNewPeople.keySet();
    	
    	BatchSyncAudienceMembership batchObj = new BatchSyncAudienceMembership('addUserAudienceMembership', peopleIdSet);
    	if(peopleIdSet.size() == 1 && !Test.isRunningTest()){ 
    		batchObj.managePeopleAudienceMembership('addUserAudienceMembership', mapOfNewPeople.values()[0]);
    	} else if(peopleIdSet.size() > 1 && !System.isBatch()){
    		Database.executeBatch(batchObj, 1);
    	}
    }
    public void OnAfterUpdate (Map<Id,People__c> mapOfOldPeople, Map<Id,People__c> mapOfNewPeople){
    	onAfterUpdateRecord(mapOfOldPeople,mapOfNewPeople);
        Set<Id> peopleIdSet = mapOfNewPeople.keySet();
        if(SimpplrContext.locationNormalizationEnabled) {
            Set<Id> peopleIdSetForNormalization = new Set<Id>();
            for(People__c ppl : mapOfNewPeople.values()){
                if(ppl.Location_Normalization_Status__c == null){
                    peopleIdSetForNormalization.add(ppl.id);
                }
            }
            if(!peopleIdSetForNormalization.isEmpty() && !System.isBatch() && !Test.isRunningTest()) {
                BatchPeopleLocationNormalization batchOb = new BatchPeopleLocationNormalization();
                Database.executeBatch(batchOb, 2000);
            } 
        }
    	BatchSyncAudienceMembership batchObj = new BatchSyncAudienceMembership('editUserAudienceMembership', peopleIdSet);
    	if(peopleIdSet.size() == 1 && !Test.isRunningTest()){ 
    		batchObj.managePeopleAudienceMembership('editUserAudienceMembership', mapOfNewPeople.values()[0]);
    	} else if(peopleIdSet.size() > 1 && !System.isBatch() && !Test.isRunningTest()){
    		Database.executeBatch(batchObj, 1);
    	}
    }
    private void onAfterInsertRecord(List<People__c> listPeopleRecord){
    	List<External_Search_Data_Trail__c> listToInsert = new List<External_Search_Data_Trail__c>();
    	if(SimpplrContext.isExternalSearchAppConnected){
    		for(People__c ppl : listPeopleRecord) {
	    		External_Search_Data_Trail__c obj = new External_Search_Data_Trail__c();
	    		obj.People__c = ppl.Id;
	    		obj.Type__c = 'People';
	    		listToInsert.add(obj);
	    	}

			if(listToInsert.size() > 0) {
				List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
		
				fieldList.add(External_Search_Data_Trail__c.People__c);
				fieldList.add(External_Search_Data_Trail__c.Type__c);

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().insertAsUser(listToInsert, fieldList);
			}
    	}
    }
    
    private void onAfterUpdateRecord(Map<Id,People__c> mapOfOldPeople, Map<Id,People__c> mapOfNewPeople){
    	List<External_Search_Data_Trail__c> listToInsert = new List<External_Search_Data_Trail__c>();
    	if(SimpplrContext.isExternalSearchAppConnected){
    		for(People__c ppl : mapOfNewPeople.values()){
				if(mapOfOldPeople.get(ppl.id).Last_Edited_DateTime__c < mapOfNewPeople.get(ppl.id).Last_Edited_DateTime__c){
					External_Search_Data_Trail__c obj = new External_Search_Data_Trail__c();
					obj.People__c = ppl.Id;
					obj.Type__c = 'People';
					listToInsert.add(obj);
				}
    		}

    		if(listToInsert.size() > 0) {
				List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
		
				fieldList.add(External_Search_Data_Trail__c.People__c);
				fieldList.add(External_Search_Data_Trail__c.Type__c);

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().insertAsUser(listToInsert, fieldList);
			}
    	}
    }
	
	public void OnBeforeUpdate (Map<Id, People__c> mapOfOldPeople, Map<Id, People__c> mapOfNewPeople) {
		
		for(People__c ppl : mapOfNewPeople.values()) {
			populateFullName(ppl);
		}
		
		if(SimpplrContext.isSegmentsEnabled && String.isNotBlank(SimpplrContext.segmentColumnName)) {
			updateSegmentatId(mapOfNewPeople.values());
		}
		updateAudienceProcessingRequired(mapOfOldPeople, mapOfNewPeople);
        if(SimpplrContext.locationNormalizationEnabled) {
			updateLocationFields(mapOfOldPeople, mapOfNewPeople);
        }
		// populate fill_date for related fields 
		populateFillDateOnUpdate(mapOfOldPeople,mapOfNewPeople);
	}

	private void populateFullName(People__c ppl) {
		String nameValue = (String.isBlank(ppl.First_Name__c) ? '' : (ppl.First_Name__c + ' ')) +
			(String.isBlank(ppl.Middle_Name__c) ? '' : (ppl.Middle_Name__c + ' ')) +
			ppl.Last_Name__c;
		ppl.name =  nameValue.length() > 80 ? nameValue.substring(0,80) : nameValue;
		ppl.Full_Name__c =  nameValue.length() > 255 ? nameValue.substring(0,255) : nameValue;
	}
	
	private void updateSegmentatId(List<People__c> listOfNewPeople) {
		Set<String> segmentFieldSet = new Set<String>();
		DateTime currentTime = Datetime.now();

		for(People__c ppl : listOfNewPeople) {
			String newSegmentAttributeValue = (String) ppl.get(SimpplrContext.namespacePrefix + SimpplrContext.segmentColumnName);
			if(String.isBlank(newSegmentAttributeValue)) {
				ppl.segment__c = null;
				ppl.Segment_Attribute_Value__c = null;
				ppl.Is_Segment_Manager__c = false;
				ppl.Last_Edited_DateTime__c = currentTime;
				
			} else if(newSegmentAttributeValue.equalsIgnoreCase(ppl.Segment_Attribute_Value__c) == false) {
				ppl.Segment_Processing_Required__c = true;
				segmentFieldSet.add(newSegmentAttributeValue);
				
			}
		}
		
		if(!segmentFieldSet.isEmpty()) {
			Map<String, String> mapOfSegmentConditionAndSegmentId = new Map<String, String>();
			
			Map<String, Object> soqlParamMap = new  Map<String, Object>();
			soqlParamMap.put('soqlParam1', segmentFieldSet);
			String query = 'select Attribute_Value__c, Segment__c from Segment_Rule__c where Attribute_Value__c=:soqlParam1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			List<Segment_Rule__c>  segmentRuleList = (List<Segment_Rule__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
			for(Segment_Rule__c ruleObj : segmentRuleList) {
				mapOfSegmentConditionAndSegmentId.put(ruleObj.Attribute_Value__c.toLowerCase(), ruleObj.Segment__c);
			}
			for(People__c ppl : listOfNewPeople) {
				String newSegmentAttributeValue = (String) ppl.get(SimpplrContext.namespacePrefix + SimpplrContext.segmentColumnName);
				if(String.isNotBlank(newSegmentAttributeValue) && newSegmentAttributeValue.equalsIgnoreCase(ppl.Segment_Attribute_Value__c) == false) {
					ppl.Segment_Attribute_Value__c = String.isNotBlank(newSegmentAttributeValue)? newSegmentAttributeValue.toLowerCase() : null;
					// avoid updating segment if lopcation normalized
            		if(!SimpplrContext.locationNormalizationEnabled || !(ppl.Location_Normalization_Status__c != null && ppl.Location_Normalization_Status__c >=5 && mapOfSegmentConditionAndSegmentId.get(newSegmentAttributeValue.toLowerCase()) == null) ) {
                        ppl.segment__c = mapOfSegmentConditionAndSegmentId.get(newSegmentAttributeValue.toLowerCase());
                        ppl.Is_Segment_Manager__c = false;
                    }
                    ppl.Last_Edited_DateTime__c = currentTime;
				}
			}
		}
	}
	
	private void updateAudienceProcessingRequired(Map<Id, People__c> mapOfOldPeople, Map<Id, People__c> mapOfNewPeople) {
		Set<String> setOfAudienceAvailableFields = new Set<String>{'Custom_Field_1__c', 'Custom_Field_2__c', 'Custom_Field_3__c',
															'Custom_Field_4__c', 'Custom_Field_5__c', 'Custom_Field_6__c', 'Custom_Field_7__c',
															'Custom_Field_8__c', 'Custom_Field_9__c', 'Custom_Field_10__c', 'Custom_Field_11__c',
															'Custom_Field_12__c', 'Custom_Field_13__c', 'Custom_Field_14__c', 'Custom_Field_15__c',
															'Custom_Field_16__c', 'Custom_Field_17__c', 'Custom_Field_18__c', 'Custom_Field_19__c',
															'Custom_Field_20__c', 'Custom_Field_21__c', 'Custom_Field_22__c', 'Custom_Field_23__c',
															'Custom_Field_24__c', 'Custom_Field_25__c'};
		setOfAudienceAvailableFields.addAll(new FilterService().getAudienceAvailableFields().keySet());
		for(People__c newPopleObj : mapOfNewPeople.values()) {
			People__c oldPeopleObj = mapOfOldPeople.get(newPopleObj.id);  
			Boolean audienceAttributeValueChanged = false;  
			for(String columnName : setOfAudienceAvailableFields) {
				if(columnName.containsIgnoreCase('Date')) {
					Date newDateValue = (Date) newPopleObj.get(SimpplrContext.namespacePrefix + columnName);
					Date oldDateValue = (Date) oldPeopleObj.get(SimpplrContext.namespacePrefix + columnName);
					if(newDateValue != null) {
						if(newDateValue != oldDateValue) {
							audienceAttributeValueChanged = true;
							break;
						}
						
					} else if(oldDateValue != null) {
						audienceAttributeValueChanged = true;
						break;
					}
				} else {
					String newColumnValue = (String) newPopleObj.get(SimpplrContext.namespacePrefix + columnName);
					String oldColumnValue = (String) oldPeopleObj.get(SimpplrContext.namespacePrefix + columnName);
					if(String.isNotBlank(newColumnValue)) {
						if(newColumnValue.equalsIgnoreCase(oldColumnValue) == false) {
							audienceAttributeValueChanged = true;
							break;
						}
						
					} else if(String.isNotBlank(oldColumnValue)) {
						audienceAttributeValueChanged = true;
						break;
					}
				}
			}
			if(audienceAttributeValueChanged) {
				newPopleObj.Audience_Processing_Required__c = true;
			}
		}
	}
	
	// Runs before Insert
	private void populateFillDateOnInsert (List<People__c> listOfNewPeople) {
		DateTime currentTime = DateTime.now();
		for (People__c ppl : listOfNewPeople) {
			ppl.AboutMe_Fill_DateTime__c = (String.isNotBlank(ppl.About__c) ? currentTime : null);
			ppl.Cover_Photo_Fill_DateTime__c = (String.isNotBlank(ppl.Cover_Content_Document_Id__c) ? currentTime : null);
			ppl.Mobile_Fill_DateTime__c = (String.isNotBlank(ppl.Mobile_Phone__c) ? currentTime : null);
			ppl.Phone_Fill_DateTime__c = (String.isNotBlank(ppl.Phone__c) ? currentTime : null);
			ppl.Profile_Photo_Fill_DateTime__c = (String.isNotBlank(ppl.External_Photo_URL__c) ? currentTime : null);
			ppl.Birthdate_Fill_Datetime__c = (ppl.Birth_Date__c != null ? currentTime : null);			
			ppl.Day_Of_Year_B__c = (ppl.Birth_Date__c != null
										? date.newInstance(2000, ppl.Birth_Date__c.month(), ppl.Birth_Date__c.day()).dayOfYear() 
										: null);

			ppl.Day_Of_Year_J__c = (ppl.Joining_Date__c != null
										? date.newInstance(2000, ppl.Joining_Date__c.month(), ppl.Joining_Date__c.day()).dayOfYear() 
										: null);
		}
	}
	
	// Runs before Update
	private void populateFillDateOnUpdate (Map<Id, People__c> mapOfOldPeople, Map<Id, People__c> mapOfNewPeople) {
		People__c oldPpl;
		DateTime currentTime = DateTime.now();
		for (People__c ppl : mapOfNewPeople.values()) {
			oldPpl = mapOfOldPeople.get(ppl.Id);
			
			// filling AboutMe_Fill_DateTime__c
			if (String.isBlank(oldPpl.About__c) &&  String.isNotBlank(ppl.About__c)) {
				ppl.AboutMe_Fill_DateTime__c = currentTime;

			} else if (String.isNotBlank(oldPpl.About__c) &&  String.isBlank(ppl.About__c)) {
				ppl.AboutMe_Fill_DateTime__c = null;

			} else if(ppl.AboutMe_Fill_DateTime__c == null && String.isNotBlank(ppl.About__c)) {
				ppl.AboutMe_Fill_DateTime__c = currentTime;
			}
			
			// filling Cover_Photo_Fill_DateTime__c 
			if (String.isBlank(oldPpl.Cover_Content_Document_Id__c) &&  String.isNotBlank(ppl.Cover_Content_Document_Id__c)) {
				ppl.Cover_Photo_Fill_DateTime__c = currentTime;

			} else if (String.isNotBlank(oldPpl.Cover_Content_Document_Id__c) &&  String.isBlank(ppl.Cover_Content_Document_Id__c)) {
				ppl.Cover_Photo_Fill_DateTime__c = null;

			} else if(ppl.Cover_Photo_Fill_DateTime__c == null && String.isNotBlank(ppl.Cover_Content_Document_Id__c)) {
				ppl.Cover_Photo_Fill_DateTime__c = currentTime;
			}
			
			// filling Mobile_Fill_DateTime__c 
			if (String.isBlank(oldPpl.Mobile_Phone__c) &&  String.isNotBlank(ppl.Mobile_Phone__c)) {
				ppl.Mobile_Fill_DateTime__c = currentTime;

			} else if (String.isNotBlank(oldPpl.Mobile_Phone__c) &&  String.isBlank(ppl.Mobile_Phone__c)) {
				ppl.Mobile_Fill_DateTime__c = null;

			} else if (ppl.Mobile_Fill_DateTime__c == null && String.isNotBlank(ppl.Mobile_Phone__c)) {
				ppl.Mobile_Fill_DateTime__c = currentTime;
			}
			
			// filling Phone_Fill_DateTime__c 
			if (String.isBlank(oldPpl.Phone__c) &&  String.isNotBlank(ppl.Phone__c)) {
				ppl.Phone_Fill_DateTime__c = currentTime;

			} else if (String.isNotBlank(oldPpl.Phone__c) &&  String.isBlank(ppl.Phone__c)) {
				ppl.Phone_Fill_DateTime__c = null;

			} else if (ppl.Phone_Fill_DateTime__c == null && ppl.Phone__c != null) {
				ppl.Phone_Fill_DateTime__c = currentTime;
			}
			
			// filling Profile_Photo_Fill_DateTime__c 
			if (String.isBlank(oldPpl.External_Photo_URL__c) &&  String.isNotBlank(ppl.External_Photo_URL__c)) {
				ppl.Profile_Photo_Fill_DateTime__c = currentTime;

			} else if (String.isNotBlank(oldPpl.External_Photo_URL__c) &&  String.isBlank(ppl.External_Photo_URL__c)) {
				ppl.Profile_Photo_Fill_DateTime__c = null;

			} else if(String.isNotBlank(ppl.External_Photo_URL__c) && ppl.Profile_Photo_Fill_DateTime__c == null) {
				ppl.Profile_Photo_Fill_DateTime__c = currentTime;
				
			}

			// filling Birthdate_Fill_DateTime__c 
			if (oldPpl.Birth_Date__c == null &&  ppl.Birth_Date__c != null) {
				ppl.Birthdate_Fill_DateTime__c = currentTime;

			} else if (oldPpl.Birth_Date__c != null &&  ppl.Birth_Date__c == null) {
				ppl.Birthdate_Fill_DateTime__c = null;

			} else if (ppl.Birthdate_Fill_DateTime__c == null && ppl.Birth_Date__c != null) {
				ppl.Birthdate_Fill_DateTime__c = currentTime;

			}

			ppl.Day_Of_Year_B__c = (ppl.Birth_Date__c != null
										? date.newInstance(2000, ppl.Birth_Date__c.month(), ppl.Birth_Date__c.day()).dayOfYear() 
										: null);

			ppl.Day_Of_Year_J__c = (ppl.Joining_Date__c != null
										? date.newInstance(2000, ppl.Joining_Date__c.month(), ppl.Joining_Date__c.day()).dayOfYear() 
										: null);

		}
	}
    private void updateLocationFields (Map<Id, People__c> mapOfOldPeople, Map<Id, People__c> mapOfNewPeople) {
        People__c oldPpl;
        for (People__c ppl : mapOfNewPeople.values()) {
            oldPpl = mapOfOldPeople.get(ppl.Id);
            if((oldPpl.city__c != ppl.city__c || oldPpl.state__c != ppl.state__c || oldPpl.country__c != ppl.country__c) && (String.isNotBlank(ppl.city__c) || String.isNotBlank(ppl.state__c) || String.isNotBlank(ppl.country__c))){
                if(ppl.Location_Normalization_Status__c != null && ppl.Location_Normalization_Status__c <5) {
                	ppl.Location_Normalization_Status__c = null;
                }
            }
            //Add 5 to Location_Normalization_Status__c in MySettingDataServer.getNormalizedLocation() and subtract here to avoid overwrite
            if(ppl.Location_Normalization_Status__c != null && ppl.Location_Normalization_Status__c >=10) {
                ppl.Location_Normalization_Status__c -= 10;
            } else if (ppl.Audience_Processing_Required__c == false && ppl.Location_Normalization_Status__c != null && ppl.Location_Normalization_Status__c >=5) {
				ppl.Location_Normalization_Status__c -= 5;
			}

        }
    }
}