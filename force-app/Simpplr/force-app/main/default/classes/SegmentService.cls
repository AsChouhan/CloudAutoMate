/**
* @Class [SegmentService] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class SegmentService {

    
    public void enableSegmentation(String profileField, List<SegmentWrapper> listOfSegmentSetup, SegmentWrapper.Options segmentOptions) {
		String appConfigQuery = 'SELECT Id, Segment_Enabled__c, Segment_Column_Name__c,'
				+ ' Branding_Logo__c, Branding_JSON__c, Branding_Custom_Font_CSS__c, Branding_CSS__c,'
				+ ' Branding_CSS_Class__c, Segment_Apps_Links_Enabled__c, Segment_Branding_Enabled__c, PP_Division_Editable__c,'
				+ ' PP_Company_Name_Editable__c, PP_Country_Editable__c, PP_Department_Editable__c,'
				+ ' PP_City_Editable__c, PP_State_Editable__c'
    			+ ' FROM App_Config__c LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> appConfigList = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
					
		if (appConfigList.isEmpty() || appConfigList[0].Segment_Enabled__c){
			throw new SimpplrException(ExceptionCode.INVALID_PARAMETER.name());
		}
		
		App_config__c appConfig = appConfigList[0];
		appConfig.Segment_Enabled__c = true;
		appConfig.Maintenance_In_Progress__c = true;
		appConfig.Maintenance_Reason__c = 'enableSegmentation';
		appConfig.Segment_Apps_Links_Enabled__c = segmentOptions.isAppsAndLinksSegmented;
		appConfig.Segment_Branding_Enabled__c = segmentOptions.isBrandingSegmented;
		appConfig.Segment_Column_Name__c = profileField;
		appConfig.PP_Division_Editable__c = 'Division__c'.equalsIgnoreCase(profileField) ? false : appConfig.PP_Division_Editable__c;
		appConfig.PP_Company_Name_Editable__c = 'Company_Name__c'.equalsIgnoreCase(profileField) ? false : appConfig.PP_Company_Name_Editable__c;
		appConfig.PP_Country_Editable__c = 'Country__c'.equalsIgnoreCase(profileField) ? false : appConfig.PP_Country_Editable__c;
		appConfig.PP_Department_Editable__c = 'Department__c'.equalsIgnoreCase(profileField) ? false : appConfig.PP_Department_Editable__c;
		appConfig.PP_City_Editable__c = 'City__c'.equalsIgnoreCase(profileField) ? false : appConfig.PP_City_Editable__c;
		appConfig.PP_State_Editable__c = 'State__c'.equalsIgnoreCase(profileField) ? false : appConfig.PP_State_Editable__c;
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().updateAsUser(appConfig, new List<Schema.SObjectField>{
				App_config__c.Segment_Enabled__c, App_config__c.Maintenance_In_Progress__c,
				App_config__c.Maintenance_Reason__c, 
				App_config__c.Segment_Apps_Links_Enabled__c, App_config__c.Segment_Branding_Enabled__c,
				App_config__c.Segment_Column_Name__c, App_config__c.PP_Division_Editable__c,
				App_config__c.PP_Company_Name_Editable__c, App_config__c.PP_Country_Editable__c,
				App_config__c.PP_Department_Editable__c,App_config__c.PP_City_Editable__c,
				App_config__c.PP_State_Editable__c});
		setupSegment(listOfSegmentSetup, segmentOptions);
		
    }
    
    public void disableSegmentation(){ 
    	// Update App Config
    	String appConfigQuery = 'SELECT Id, Segment_Enabled__c, Segment_Column_Name__c, Segment_Apps_Links_Enabled__c, Segment_Branding_Enabled__c, Maintenance_In_Progress__c'
    										+ ' FROM App_Config__c LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> appConfigList = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
		
		App_config__c appConfig = appConfigList[0];
    	
    	if(appConfigList.isEmpty() || !appConfig.Segment_Enabled__c){
			throw new SimpplrException(ExceptionCode.INVALID_PARAMETER.name());
		}
    	
		appConfig.Segment_Enabled__c = false;
		appConfig.Maintenance_In_Progress__c = true;
		appConfig.Maintenance_Reason__c = 'disableSegmentation';
		appConfig.Segment_Apps_Links_Enabled__c = false;
		appConfig.Segment_Branding_Enabled__c = false;
		appConfig.Segment_Column_Name__c = null;
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().updateAsUser(appConfig, new List<Schema.SObjectField>{App_config__c.Segment_Enabled__c,
																							 App_config__c.Segment_Column_Name__c,
																							 App_Config__c.Maintenance_Reason__c,
																							 App_Config__c.Maintenance_In_Progress__c,
																							 App_config__c.Segment_Apps_Links_Enabled__c,
																							 App_config__c.Segment_Branding_Enabled__c});
		
		String queryStr = 'SELECT Id FROM Segment__C Limit 10000';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		Map<Id, Segment__c> idVsSegmentMap = new Map<Id, Segment__c>((List<Segment__c>)SIMPESAPI.accessController().queryAsUSer(queryStr, null));
		
		// Fire a batch to remove segmentation completely.			 
    	BatchProcessSegment job = new BatchProcessSegment('disableSegmentation', true, idVsSegmentMap.keySet());
    	Database.executeBatch(job, 2000);
    } 
    
    /**
     * @description setupSegment - use to create segments
     * @param listOfSegmentSetup
     * @param segmentOptions - contains isAppsAndLinksSegmented, isBrandingSegmented, shouldInherit values
     */
    public void setupSegment (List<SegmentWrapper> listOfSegmentSetup, SegmentWrapper.Options segmentOptions) {
    	List<Segment__c> listOfSegmentForInsert = new List<Segment__c>(); 
		List<Segment__c> listOfSegmentForUpdate = new List<Segment__c>();
		String queryStr = 'SELECT Id FROM Segment__C Limit 10000';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		Map<Id, Segment__c> mapOfIdWithSegmentInSFForDelete = new Map<id, Segment__c>((List<Segment__c>)SIMPESAPI.accessController().queryAsUSer(queryStr, null));
		List<Segment_Rule__c> listOfSegmentRuleToInsert = new List<Segment_Rule__c>();
		Map<String, List<Segment__c>> insertAndUpdateSegmentListMap = getInsertAndUpdateSegmentListMap(listOfSegmentSetup, mapOfIdWithSegmentInSFForDelete, segmentOptions);
		listOfSegmentForInsert = insertAndUpdateSegmentListMap.get('insert');
		listOfSegmentForUpdate = insertAndUpdateSegmentListMap.get('update');

		/**New segment case handling **/
		if (!listOfSegmentForInsert.isEmpty()) {
			String appConfigQuery = 'SELECT Branding_CSS__c, Branding_CSS_Class__c,'
					+ ' Branding_Custom_Font_CSS__c, Favicons_Folder__c,'
					+ ' Branding_JSON__c, Branding_Logo__c,'
					+ ' SSO_Provider__c, Custom_Links_JSON__c, SSO_Custom_JSON__c'
					+ ' FROM App_Config__c limit 1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<App_Config__c> listOfAppConfig = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);		

			if (segmentOptions.isBrandingSegmented) {
				setSegmentBranding(listOfSegmentForInsert, listOfAppConfig[0], segmentOptions);
			}
			if(segmentOptions.isAppsAndLinksSegmented) {
				setSegmentAppsNLinks(listOfSegmentForInsert, listOfAppConfig[0], segmentOptions);
			}

			//Inserting new segments 
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPSFDCAccessControlResults.InsertResults result  = SIMPESAPI.accessController().insertAsUser(
					listOfSegmentForInsert, 
					new List<Schema.SObjectField>{
					Segment__c.Name__c,
					Segment__c.Modified_By_People__c,
					Segment__c.Segment_Attribute_Value_JSON__c,
					Segment__c.Created_By_people__c,
					Segment__c.Carousel_Layout__c,
					Segment__c.Branding_CSS__c,
					Segment__c.Branding_CSS_Class__c,
					Segment__c.Branding_Custom_Font_CSS__c,
					Segment__c.Favicons_Folder__c,
					Segment__c.Branding_JSON__c,
					Segment__c.Branding_Logo__c,
					Segment__c.Branding_Package_Version__c,
					Segment__c.SSO_Provider__c,
					Segment__c.SSO_Custom_JSON__c,
					Segment__c.Custom_Links_JSON__c
					});
			
			listOfSegmentForInsert = (List<Segment__c>)result.getInsertedObjects();
			indexSegmentRelatedLinks(listOfSegmentForInsert, listOfAppConfig[0], segmentOptions);
			createSegmentRuleAndAudienceForNewSegment(listOfSegmentForInsert);
		}
		
		//Delete unwanted segment rules
		
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', listOfSegmentForUpdate);
		soqlParamMap.put('soqlParam2', mapOfIdWithSegmentInSFForDelete.keySet());
		
		String query  = 'SELECT Id, Segment__c '
									+ ' FROM Segment_Rule__c '
									+ ' WHERE Segment__c =:soqlParam1 or Segment__c=: soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Segment_Rule__c> listOfSegmentRuleToDelete = (List<Segment_Rule__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
		
		if (!listOfSegmentRuleToDelete.isEmpty()) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().deleteAsUser(listOfSegmentRuleToDelete);
		}
		
		//Existing segment subsegment update
		if (!listOfSegmentForUpdate.isEmpty()) {
			updateSegmentAndRules(listOfSegmentForUpdate);
		}
		 
		//DELETE removed Segment(s) 
		if (mapOfIdWithSegmentInSFForDelete.keyset().size() > 0) {
			BatchProcessSegment job = new BatchProcessSegment('removeSubscription', true, mapOfIdWithSegmentInSFForDelete.keySet());
    		Database.executeBatch(job, 2000);
		}
		
		// Fire a batch to update people for segmentation
		Boolean runNextBatchInSequence = segmentOptions.shouldInherit; 
		BatchProcessSegment job = new BatchProcessSegment('setupsegment', runNextBatchInSequence, mapOfIdWithSegmentInSFForDelete.keySet());
		Database.executeBatch(job, 2000);
    }

	/**
	 * @description getInsertAndUpdateSegmentListMap
	 * @param listOfSegmentSetup
	 * @param mapOfIdWithSegmentInSFForDelete
	 * @param segmentOptions
	 * @return insertAndUpdateListMap
	 */
	private Map<String, List<Segment__c>> getInsertAndUpdateSegmentListMap(List<SegmentWrapper> listOfSegmentSetup, Map<Id, Segment__c> mapOfIdWithSegmentInSFForDelete, SegmentWrapper.Options segmentOptions) {
		Map<String, List<Segment__c>> insertAndUpdateListMap = new Map<String, List<Segment__c>>();
		List<Segment__c> listOfSegmentForInsert = new List<Segment__c>();
		List<Segment__c> listOfSegmentForUpdate = new List<Segment__c>();
		for (SegmentWrapper segmentSetupObj: listOfSegmentSetup) {
			Segment__c segmentObj = new Segment__c();
			segmentObj.Id = segmentSetupObj.segmentId;
			segmentObj.Name__c = segmentSetupObj.name;
			segmentObj.Modified_By_People__c = UserContext.peopleId;
			
			if (segmentSetupObj.listOfSubsegments != null && !segmentSetupObj.listOfSubsegments.isEmpty()) {
				segmentObj.Segment_Attribute_Value_JSON__c = JSON.serialize(segmentSetupObj.listOfSubsegments); //If subsegment is present
			}
			
			if (String.isNotblank(segmentSetupObj.segmentId)) { 
				mapOfIdWithSegmentInSFForDelete.remove(segmentSetupObj.segmentId);
				listOfSegmentForUpdate.add(segmentObj); //Existing segment 
				
			} else {
				segmentObj.Created_By_people__c = UserContext.peopleId;
				if(segmentOptions.shouldInherit) {
					segmentObj.Carousel_Layout__c = SimpplrContext.carouselLayout;
				}
				listOfSegmentForInsert.add(segmentObj); //New segment 
			}
		}
		insertAndUpdateListMap.put('insert', listOfSegmentForInsert);
		insertAndUpdateListMap.put('update', listOfSegmentForUpdate);
		return insertAndUpdateListMap;
	}

	/**
	 * @description setSegmentAppsNLinks - set apps and links related fields in Segment object
	 * @param listOfSegments
	 * @param appConfigObj
	 * @param segmentOptions
	 */
	private void setSegmentAppsNLinks(List<Segment__c> listOfSegments, App_Config__c appConfigObj, SegmentWrapper.Options segmentOptions) {
		if (!segmentOptions.shouldInherit) {
			appConfigObj = new App_Config__c();
		}
		for (Segment__c segmentObj: listOfSegments) {
			segmentObj.SSO_Provider__c = appConfigObj.SSO_Provider__c;
			segmentObj.SSO_Custom_JSON__c = appConfigObj.SSO_Custom_JSON__c;
			segmentObj.Custom_Links_JSON__c = appConfigObj.Custom_Links_JSON__c;
		}
	}
	
	/**
	 * @description setSegmentBranding - set branding related fields in Segment object
	 * @param listOfSegments
	 * @param appConfigObj
	 * @param segmentOptions
	 */
	private void setSegmentBranding(List<Segment__c> listOfSegments, App_Config__c appConfigObj, SegmentWrapper.Options segmentOptions) {
		// Default values
		String defaultBrandingJSON = Utility.getDefaultBrandingValues();

		for (Segment__c segmentObj: listOfSegments) {
			if (segmentOptions.shouldInherit) {
				segmentObj.Branding_CSS__c = appConfigObj.Branding_CSS__c;
				segmentObj.Branding_CSS_Class__c = appConfigObj.Branding_CSS_Class__c;
				segmentObj.Branding_Custom_Font_CSS__c = appConfigObj.Branding_Custom_Font_CSS__c;
				segmentObj.Favicons_Folder__c = appConfigObj.Favicons_Folder__c;
				segmentObj.Branding_JSON__c = String.isBlank(appConfigObj.Branding_JSON__c) ? defaultBrandingJSON : appConfigObj.Branding_JSON__c;
				segmentObj.Branding_Logo__c = appConfigObj.Branding_Logo__c;
				segmentObj.Branding_Package_Version__c = ServiceConstants.PACKAGE_VERSION;

			} else {
				segmentObj.Branding_CSS__c = '';
				segmentObj.Branding_CSS_Class__c = '';
				segmentObj.Branding_Custom_Font_CSS__c = '';
				segmentObj.Favicons_Folder__c = ServiceConstants.DEFAULT_BRANDING.get('logo_faviconPath');
				segmentObj.Branding_JSON__c = defaultBrandingJSON;
				segmentObj.Branding_Logo__c = '';
				segmentObj.Branding_Package_Version__c = ServiceConstants.PACKAGE_VERSION;
			}
		}
	}

	/**
	 * @description indexSegmentRelatedLinks
	 * @param listOfSegments
	 * @param appConfigObj
	 * @param segmentOptions
	 */
	private void indexSegmentRelatedLinks(List<Segment__c> listOfSegments, App_Config__c appConfigObj, SegmentWrapper.Options segmentOptions) {
		if(segmentOptions.shouldInherit && segmentOptions.isAppsAndLinksSegmented
			&& String.isNotBlank(appConfigObj.Custom_Links_JSON__c)) {

			List<External_Search_Data_Trail__c> externalSearchDataTrailObjList = new List<External_Search_Data_Trail__c>();
			for(Segment__c segmentObj : listOfSegments) {
				externalSearchDataTrailObjList.add(new External_Search_Data_Trail__c(Type__c='Links', Segment__c=segmentObj.Id));
			}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().insertAsUser(externalSearchDataTrailObjList, new List<Schema.SObjectField>{
				External_Search_Data_Trail__c.Type__c,
				External_Search_Data_Trail__c.Segment__c
			});
		}
	}

	/**
	 * @description createSegmentRuleAndAudienceForNewSegment
	 * @param listOfSegments
	 */
	private void createSegmentRuleAndAudienceForNewSegment(List<Segment__c> listOfSegments) {
		List<Audience__c> audienceList = new List<Audience__c>();
		List<Segment_Rule__c> listOfSegmentRuleToInsert = new List<Segment_Rule__c>();
		for (Segment__c segmentObj: listOfSegments) {
			
			if (String.isNotBlank(segmentObj.Segment_Attribute_Value_JSON__c)) {
				List<SegmentWrapper.SubsegmentWrapper> listOfSubsegment = (List<SegmentWrapper.SubsegmentWrapper>)JSON.deserialize(
					segmentObj.Segment_Attribute_Value_JSON__c, List<SegmentWrapper.SubsegmentWrapper>.class);
					
				for (SegmentWrapper.SubsegmentWrapper subsegmentObj: listOfSubsegment) {
					Segment_Rule__c segmentRuleObj = new Segment_Rule__c();
					segmentRuleObj.Segment__c = segmentObj.id;
					segmentRuleObj.Attribute_Value__c = String.isNotBlank(subsegmentObj.name) ? subsegmentObj.name.toLowerCase() : null; 
					listOfSegmentRuleToInsert.add(segmentRuleObj);
				}
			} 

			Audience__c audienceObj = new Audience__c();
			audienceObj.Name__c = 'Everyone in segment - ' + segmentObj.Name__c.left(200);
			audienceObj.Segment__c = segmentObj.Id;
			audienceObj.Created_By_People__c = UserContext.peopleId;
			audienceObj.Modified_By_People__c = UserContext.peopleId;
			audienceObj.Audience_Rule_Json__c = '[]';
			audienceObj.Is_Hidden__c = true;			
			audienceList.add(audienceObj);						
		}
		
		if (!listOfSegmentRuleToInsert.isEmpty()) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().insertAsUser(
				listOfSegmentRuleToInsert, new List<Schema.SObjectField>{Segment_Rule__c.Segment__c, Segment_Rule__c.Attribute_Value__c});
		}

		if(!audienceList.isEmpty()){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(
				audienceList, new List<Schema.SObjectField>{
								Audience__c.Name__c,
								Audience__c.Segment__c,
								Audience__c.Created_By_People__c,
								Audience__c.Modified_By_People__c,
								Audience__c.Audience_Rule_Json__c,
								Audience__c.Is_Hidden__c
							}
			);
		}
	}

	/**
	 * @description updateSegmentAndRules
	 * @param listOfSegmentForUpdate
	 */
	private void updateSegmentAndRules(List<Segment__c> listOfSegmentForUpdate) {
		//Update existing segments
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id, Segment__c>(listOfSegmentForUpdate), new List<Schema.SObjectField>{
			Segment__c.Name__c,
			Segment__c.Modified_By_People__c, 
			Segment__c.Segment_Attribute_Value_JSON__c
		});

		List<Segment_Rule__c> listOfSegmentRuleToInsert = new List<Segment_Rule__c>();
		for (Segment__c segmentObj: listOfSegmentForUpdate) { //Creating segment rule obj for existing segment  
			
			if (String.isNotBlank(segmentObj.Segment_Attribute_Value_JSON__c)) {
				List<SegmentWrapper.SubsegmentWrapper> listOfSubsegment = (List<SegmentWrapper.SubsegmentWrapper>)JSON.deserialize(
					segmentObj.Segment_Attribute_Value_JSON__c, List<SegmentWrapper.SubsegmentWrapper>.class);
					
				for (SegmentWrapper.SubsegmentWrapper subsegmentObj: listOfSubsegment) {
					Segment_Rule__c segmentRuleObj = new Segment_Rule__c();
					segmentRuleObj.Segment__c = segmentObj.id;
					segmentRuleObj.Attribute_Value__c = String.isNotBlank(subsegmentObj.name) ? subsegmentObj.name.toLowerCase() : null; 
					listOfSegmentRuleToInsert.add(segmentRuleObj);
				}	
			}
		}
		
		if (!listOfSegmentRuleToInsert.isEmpty()) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().insertAsUser(listOfSegmentRuleToInsert, new List<Schema.SObjectField>{
				Segment_Rule__c.Segment__c,
				Segment_Rule__c.Attribute_Value__c
			});
		}
	}
    
    public SegmentWrapper.UnassignedWrapper getPossibleSubsegments(String profileField) {
    	String packageName = SimpplrContext.packageName;
    	SegmentWrapper.UnassignedWrapper resultObj = new SegmentWrapper.UnassignedWrapper();
		resultObj.unclassifiedAudienceCount = 0;
		
		if (!Utility.getPeopleFieldVsLabelMap().keySet().contains(profileField)) {
			throw new SimpplrException('Segment not enabled or not configured properly.');
		}
		
		resultObj.listOfSubsegments = new List<SegmentWrapper.SubsegmentWrapper>();
		if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			Map<String, Integer> profileFieldCountMap = getProfileFieldCountMap(profileField);
			for(String key : profileFieldCountMap.keySet()) {
				SegmentWrapper.SubsegmentWrapper subsegmentObj = new SegmentWrapper.SubsegmentWrapper();
				if (String.isNotBlank(key)) {
					subsegmentObj.name = key;
					subsegmentObj.audienceCount = profileFieldCountMap.get(key);
					resultObj.listOfSubsegments.add(subsegmentObj);
				} else {
					resultObj.unclassifiedAudienceCount = profileFieldCountMap.get(key);
				}
			}
		} else {
			Map<String, Object> soqlParamMap = new  Map<String, Object>();
			String query = 'SELECT ' + String.escapeSingleQuotes(profileField) + ' segmentColumnName, COUNT(Id) countOfSubsegment'+ 
					' FROM People__c where User__r.IsActive = true AND User__r.UserType = \'Standard\' ' ;
			
			if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
				soqlParamMap.put('soqlParam1', packageName);
				query += ' And user__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix = :soqlParam1)';
			} 
			
			query += ' group by ' + String.escapeSingleQuotes(profileField);

			logger.logDebug('query----'+query);
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			List<AggregateResult> aggResultList = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
			
			if (!aggResultList.isEmpty()) {
				
				for (AggregateResult aggResultObj: aggResultList){
					SegmentWrapper.SubsegmentWrapper subsegmentObj = new SegmentWrapper.SubsegmentWrapper();
					String subsegmentName = (String)aggResultObj.get('segmentColumnName');
					
					if (String.isNotBlank(subsegmentName)) {
						subsegmentObj.name = subsegmentName;
						subsegmentObj.audienceCount = (Integer)aggResultObj.get('countOfSubsegment');
						resultObj.listOfSubsegments.add(subsegmentObj);
					
					} else {
						resultObj.unclassifiedAudienceCount = (Integer)aggResultObj.get('countOfSubsegment');
					}
					
				}
				
			}
		}
  		
  		resultObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action=getUnassignedUsers&field=' + (EncodingUtil.urlEncode(profileField, 'UTF-8'));
		return resultObj;
    }

	private Map<String, Integer> getProfileFieldCountMap(String profileField) {
		Map<String, Integer> profileFieldCountMap = new Map<String,Integer>();
		String packageName = SimpplrContext.packageName;
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		String query = 'SELECT ' + String.escapeSingleQuotes(profileField) + ' , Id '+
			' FROM People__c where User__r.IsActive = true AND User__r.UserType = \'Standard\' ' ;
		if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
			soqlParamMap.put('soqlParam1', packageName);
			query += ' And user__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: soqlParam1)';
		}
		logger.logDebug('query----'+query);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<People__c> peopleList = (List<People__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);

		if (!peopleList.isEmpty()) {
			String fieldName = (String.isNotBlank(packageName) ? packageName + '__' : '') + profileField;
			for (People__c peopleObj: peopleList){
				String subsegmentName = (String)peopleObj.get(fieldName);
				subsegmentName = String.isBlank(subsegmentName) ? '' : subsegmentName.toLowerCase();
				if(!profileFieldCountMap.containsKey(subsegmentName)) {
					profileFieldCountMap.put(subsegmentName, 0);
				}
				profileFieldCountMap.put(subsegmentName, profileFieldCountMap.get(subsegmentName) + 1);
			}
		}
		return profileFieldCountMap;
	}
}