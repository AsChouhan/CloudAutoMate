public with sharing class PushDataHelperForExternalSearch {

	private static final Set<String> setOfFileExtensionToIgnore = new Set<String>{'jpg','gif','png','jpeg','JPG','GIF','PNG','JPEG'};
	

	
	public ExternalSearchWrapper.SearchDataWrapper getSearchDataWrapperForPeople(String peopleId){
		ExternalSearchWrapper.SearchDataWrapper searchDataWrapperForPeople = new ExternalSearchWrapper.SearchDataWrapper();
		String query = 'SELECT '+String.join(getPeopleFieldsForExternalData(),',')+' From People__c Where  id=:peopleId And (User__r.UserType=\'Standard\' OR User__r.Show_Simpplr__c=\'Yes\') '; 
		List<People__c> listOfPeopleObj = (List<People__c>)Database.query(query);
		if(!listOfPeopleObj.isEmpty()) {
			searchDataWrapperForPeople = convertPeopleToSearchDataWrapper(listOfPeopleObj[0]);
		} else {
			searchDataWrapperForPeople = null;
		}
		return searchDataWrapperForPeople;
	}
	
	public ExternalSearchWrapper.SearchDataWrapper getSearchDataWrapperForSite(String siteId){
		ExternalSearchWrapper.SearchDataWrapper searchDataWrapperForSite = new ExternalSearchWrapper.SearchDataWrapper();
		String query = 'SELECT '+String.join(getSiteFieldsForExternalData(),',')+' From Simpplr_Site__c Where  id=:siteId';
		List<Simpplr_Site__c> listOfSiteObj = (List<Simpplr_Site__c>)Database.query(query);
		Map<String,CollaborationGroup> groupmap = getGroupMap(listOfSiteObj);
		if(!listOfSiteObj.isEmpty()) {
			searchDataWrapperForSite = convertSiteToSearchDataWrapper(listOfSiteObj[0], groupmap.get(listOfSiteObj[0].Chatter_Group_Id__c));
		} else {
			searchDataWrapperForSite = null;
		}
		return searchDataWrapperForSite;
	}
	
	public ExternalSearchWrapper.SearchDataWrapper getSearchDataWrapperForSimpplrContent(String contentId){
		ExternalSearchWrapper.SearchDataWrapper searchDataWrapperForSimpplrContent = new ExternalSearchWrapper.SearchDataWrapper();
		List<ExternalSearchWrapper.SearchDataWrapper> listOfRecordsToReturn = new List<ExternalSearchWrapper.SearchDataWrapper>();
		String query = 'SELECT '+String.join(getContentFieldsForExternalData(),',')+' From Simpplr_Content__c Where Id=:contentId';
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', contentId);
		String queryFiles = 'SELECT '+String.join(getContentFieldsForExternalDataFiles(),',')+' From File__c WHERE (((location__c != \'inline\' AND location__c != \'media\') OR Is_Title_Image__c = true) AND Is_Deleted__c = false) AND Simpplr_Content__c =:soqlParam1';
		List<Simpplr_Content__c> listOfContentObj = (List<Simpplr_Content__c>)Database.query(query);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> fileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(queryFiles, soqlParamMap);
		List<ExternalSearchWrapper.TopicWrapper> listOfExtTopicWrap = new List<ExternalSearchWrapper.TopicWrapper>();
		List<topicAssignment> listOfTopicAssignement = [SELECT Id, EntityId, topicId, topic.name 
				FROM topicAssignment WHERE entityId=:contentId WITH SECURITY_ENFORCED];

		if (!listOfTopicAssignement.isEmpty()) {
			for (TopicAssignment topicAssObj: listOfTopicAssignement) {
				ExternalSearchWrapper.TopicWrapper topicWrapObj = new ExternalSearchWrapper.TopicWrapper();
				topicWrapObj.id = topicAssObj.topicId;
				topicWrapObj.name = topicAssObj.topic.name; 
				listOfExtTopicWrap.add(topicWrapObj);
			}
		}
		if (!listOfContentObj.isEmpty()) {
			searchDataWrapperForSimpplrContent = convertSimpplrContentToSearchDataWrapper(listOfContentObj[0], listOfExtTopicWrap,fileList);
		} else {
			searchDataWrapperForSimpplrContent = null;
		}
		return searchDataWrapperForSimpplrContent;
	}

	/**
	* @description get content template data to push to elastic 
	* @param contentTemplateId content template Id
	* @return ExternalSearchWrapper.SearchDataWrapper wrapper json to be pushed to elastic
	**/
	public ExternalSearchWrapper.SearchDataWrapper getSearchDataWrapperForContentTemplate(String contentTemplateId){
		ExternalSearchWrapper.SearchDataWrapper searchDataWrapperForContentTemplate = new ExternalSearchWrapper.SearchDataWrapper();
		List<ExternalSearchWrapper.SearchDataWrapper> listOfRecordsToReturn = new List<ExternalSearchWrapper.SearchDataWrapper>();
		String query = 'SELECT '+ String.join(getContentTemplateFieldsForExternalData(),',') + ' FROM Content_Template__c WHERE Id=:contentTemplateId';
		List<Content_Template__c> listContentTemplates = (List<Content_Template__c>)Database.query(query);
		if (!listContentTemplates.isEmpty()) {
			searchDataWrapperForContentTemplate = convertContentTemplateToSearchDataWrapper(listContentTemplates[0]);
		} else {
			searchDataWrapperForContentTemplate = null;
		}
		return searchDataWrapperForContentTemplate;
	}

	public ExternalSearchWrapper.EventRSVPResponseWrapper getSearchDataWrapperForEventRSVPResponse(String rsvpResponseId){
		ExternalSearchWrapper.EventRSVPResponseWrapper eventRSVPResponse = new ExternalSearchWrapper.EventRSVPResponseWrapper();
		String query = 'SELECT '+String.join(getEventRSVPResponseFieldsForExternalData(),',')+' From Event_RSVP_Response__c Where  id=:rsvpResponseId';
		List<Event_RSVP_Response__c> listOfEventRSVPResponseObj = (List<Event_RSVP_Response__c>)Database.query(query);
		if(!listOfEventRSVPResponseObj.isEmpty()) {
			eventRSVPResponse = convertEventRSVPResponseToSearchDataWrapper(listOfEventRSVPResponseObj[0]);
		} else {
			eventRSVPResponse = null;
		}
		return eventRSVPResponse; 
	}
	
	public ExternalSearchWrapper.SearchDataWrapper getSearchDataWrapperForContentDocument(String contentDocId){
		ExternalSearchWrapper.SearchDataWrapper searchDataWrapperForContentDocument = new ExternalSearchWrapper.SearchDataWrapper();
		List<ExternalSearchWrapper.SearchDataWrapper> listOfRecordsToReturn = new List<ExternalSearchWrapper.SearchDataWrapper>();
		String query = 'SELECT '+String.join(getContentDocumentFields(),',')+' From ContentDocument Where Id=:contentDocId AND LatestPublishedVersion.FileType NOT IN :setOfFileExtensionToIgnore';
		List<ContentDocument> listOfContentDocObj = (List<ContentDocument>)Database.query(query);
		Set<String> userIds = new Set<String>();
		for (ContentDocument contentDocObj : listOfContentDocObj) {
			userIds.add(contentDocObj.LatestPublishedVersion.OwnerId);
		}
		PeopleDao.setPeopleNameMapByUserId(userIds);
		if(!listOfContentDocObj.isEmpty() && listOfContentDocObj[0].LatestPublishedVersion.Origin == 'H'){
			Map<String, List<ExternalSearchWrapper.ChatterGroupId>> mapOfCollIdAndContDoc = getmapOfCollIdAndContDoc(listOfContentDocObj);
			searchDataWrapperForContentDocument = convertContentDocumentToSearchDataWrapper(listOfContentDocObj[0], mapOfCollIdAndContDoc.get(listOfContentDocObj[0].id));	
		} else if(!listOfContentDocObj.isEmpty() && listOfContentDocObj[0].LatestPublishedVersion.Origin == 'C' && 
				 (UserInfo.getOrganizationId().equalsIgnoreCase('00D3h000002DwNtEAK'))) {
			Map<String, List<ExternalSearchWrapper.ChatterGroupId>> mapOfCollIdAndContDoc = getmapOfCollIdAndContDoc(listOfContentDocObj);
			searchDataWrapperForContentDocument = convertContentDocumentToSearchDataWrapper(listOfContentDocObj[0], mapOfCollIdAndContDoc.get(listOfContentDocObj[0].id));
		} else {
			searchDataWrapperForContentDocument = getDeletedContentDocumentToSearchDataWrapper(contentDocId);
		}
		return searchDataWrapperForContentDocument;
	}
	
	public Map<String,CollaborationGroup> getGroupMap(List<Simpplr_Site__c> siteList){
		List<String> groupIds = new List<String>();
		for(Simpplr_site__c siteObj : siteList){
			groupIds.add(siteObj.chatter_group_id__c);
		}
		return(new Map<String,CollaborationGroup>([Select Id,description,name, MemberCount from CollaborationGroup where Id IN:groupIds]));
	}
	
	public ExternalSearchWrapper.CategoryWrapper getSearchDataWrapperForPeopleCategory(String peopleCategoryId){
		ExternalSearchWrapper.CategoryWrapper peoplCatObjToReturn = new ExternalSearchWrapper.CategoryWrapper();

		String pCatQuery = 'SELECT '+String.join(getPeopleCategoryFieldsForExternalData(),',')+' FROM People_Category__c WHERE Id = :soqlParam1';

		Map<String, Object> sqlParamMap = new Map<String, Object>();
		sqlParamMap.put('soqlParam1', peopleCategoryId);

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<People_Category__c> listOfPeopleCatObj = (List<People_Category__c>)SIMPESAPI.accessController().queryAsUser(pCatQuery, sqlParamMap);
		if(!listOfPeopleCatObj.isEmpty()) {
			peoplCatObjToReturn = convertPeopleCategoryToSearchDataWrapper(listOfPeopleCatObj[0]);
		} else {
			peoplCatObjToReturn = null;
		}
		return peoplCatObjToReturn;
	}
	
	public ExternalSearchWrapper.CategoryWrapper convertPeopleCategoryToSearchDataWrapper(People_Category__c peopleCatObj){
		ExternalSearchWrapper.CategoryWrapper objectToIndex = new ExternalSearchWrapper.CategoryWrapper();
		if(peopleCatObj != null){
			objectToIndex.id = peopleCatObj.id;
			objectToIndex.object_type = 'People_Category';
			objectToIndex.name = peopleCatObj.Name__c;
            objectToIndex.is_deleted = peopleCatObj.is_deleted__c;
            objectToIndex.createddate = peopleCatObj.createddate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            objectToIndex.lastmodifieddate = peopleCatObj.LastModifiedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		}
		
		return objectToIndex;
	}
	
	public ExternalSearchWrapper.CategoryWrapper getSearchDataWrapperForSiteCategory(String siteCategoryId){
		ExternalSearchWrapper.CategoryWrapper catObjToReturn = new ExternalSearchWrapper.CategoryWrapper();
		List<String> fieldList = getSiteCategoryFieldsForExternalData();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteCategoryId);
		String query = 'SELECT '+String.join(fieldList,',')+' From Site_Category__c Where  id=:soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Site_Category__c> listOfSiteCatObj = (List<Site_Category__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		if(!listOfSiteCatObj.isEmpty()) {
			catObjToReturn = convertSiteCategoryToSearchDataWrapper(listOfSiteCatObj[0]);
		} else {
			catObjToReturn = null;
		}
		return catObjToReturn;
	}
	
	public ExternalSearchWrapper.CategoryWrapper convertSiteCategoryToSearchDataWrapper(Site_Category__c siteCatObj){
		ExternalSearchWrapper.CategoryWrapper objectToIndex = new ExternalSearchWrapper.CategoryWrapper();
		if(siteCatObj != null){
			objectToIndex.id = siteCatObj.id;
			objectToIndex.object_type = 'Site_Category';
			objectToIndex.name = siteCatObj.Name__c;
			objectToIndex.is_deleted = siteCatObj.is_deleted__c;
            objectToIndex.add_site_access= siteCatObj.access__c;
            objectToIndex.createddate = siteCatObj.createddate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            objectToIndex.lastmodifieddate = siteCatObj.LastModifiedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');

		}
		return objectToIndex;
	}
	
	public ExternalSearchWrapper.CategoryWrapper getSearchDataWrapperForPagesCategory(String pageCategoryId){
		ExternalSearchWrapper.CategoryWrapper catObjToReturn = new ExternalSearchWrapper.CategoryWrapper();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', pageCategoryId);
		String query = 'SELECT '+String.join(getPagesCategoryFieldsForExternalData(),',')+' From Pages_Category__c Where  id=:soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Pages_Category__c> listOfPagesCatObj = (List<Pages_Category__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		if(!listOfPagesCatObj.isEmpty()) {
			catObjToReturn = convertPagesCategoryToSearchDataWrapper(listOfPagesCatObj[0]);
		} else {
			catObjToReturn = null;
		}
		return catObjToReturn;
    }

    public ExternalSearchWrapper.CategoryWrapper convertPagesCategoryToSearchDataWrapper(Pages_Category__c pageCatObj){
		ExternalSearchWrapper.CategoryWrapper objectToIndex = new ExternalSearchWrapper.CategoryWrapper();
		if(pageCatObj != null){
			objectToIndex.id = pageCatObj.id;
			objectToIndex.site = pageCatObj.Site__c;
			objectToIndex.object_type = 'Pages_Category';
			objectToIndex.name = pageCatObj.Name__c;
            objectToIndex.is_deleted = pageCatObj.is_deleted__c;
            objectToIndex.createddate = pageCatObj.createddate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            objectToIndex.lastmodifieddate = pageCatObj.LastModifiedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		}
		return objectToIndex;
	}
	
	public ExternalSearchWrapper.SearchDataWrapper getSearchDataWrapperForExpertise(String expertiseId){
		ExternalSearchWrapper.SearchDataWrapper expertiseObjToReturn = new ExternalSearchWrapper.SearchDataWrapper();
		String query = 'SELECT '+String.join(getExpertiseFieldsForExternalData(),',')+' From Expertise__c Where  id=:expertiseId';
		List<Expertise__c> listOfExpertiseObj = (List<Expertise__c>)Database.query(query);
		if(!listOfExpertiseObj.isEmpty()) {
			expertiseObjToReturn = convertExpertiseToSearchDataWrapper(listOfExpertiseObj[0]);
		}
		else {
			expertiseObjToReturn = getDeletedExpertiseToSearchDataWrapper(expertiseId);
		} 
		return expertiseObjToReturn;
    }

	public ExternalSearchWrapper.SearchDataWrapper getSearchDataWrapperForAlert(String alertId){
		ExternalSearchWrapper.SearchDataWrapper alertObjToReturn = new ExternalSearchWrapper.SearchDataWrapper();
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', alertId);
		String query = 'SELECT '+String.join(getAlertFieldsForExternalData(),',')+' From Alert__c Where id=:soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Alert__c> listOfAlertObj = (List<Alert__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);

		if(!listOfAlertObj.isEmpty()) {
			alertObjToReturn = convertAlertToSearchDataWrapper(listOfAlertObj[0]);
		}
		else {
			alertObjToReturn = getDeletedAlertToSearchDataWrapper(alertId);
		}
		return alertObjToReturn;
    }

    public ExternalSearchWrapper.SearchDataWrapper convertExpertiseToSearchDataWrapper(Expertise__c expetiseObj){
		ExternalSearchWrapper.SearchDataWrapper objectToIndex = new ExternalSearchWrapper.SearchDataWrapper();
		if(expetiseObj != null){
			objectToIndex.id = expetiseObj.id;
			objectToIndex.object_type = 'Expertise';
			objectToIndex.expertise_name = expetiseObj.Display_Name__c;
			objectToIndex.is_deleted = expetiseObj.IsDeleted;
			objectToIndex.expertise_user_count = Integer.ValueOf(expetiseObj.User_Count__c);
		}
		return objectToIndex;
	}

	private ExternalSearchWrapper.SearchDataWrapper getDeletedExpertiseToSearchDataWrapper(String expetiseObj) {
		ExternalSearchWrapper.SearchDataWrapper objectToIndex = new ExternalSearchWrapper.SearchDataWrapper();
		objectToIndex.id = expetiseObj;
		objectToIndex.object_type ='Expertise';
		objectToIndex.is_deleted = true;
		return objectToIndex;
	}

	
	public ExternalSearchWrapper.SearchDataWrapper convertAlertToSearchDataWrapper(Alert__c alertObj){
		ExternalSearchWrapper.SearchDataWrapper objectToIndex = new ExternalSearchWrapper.SearchDataWrapper();
		if(alertObj != null){
			objectToIndex.object_type = 'Alert';
			objectToIndex.id = alertObj.id;
			objectToIndex.name = alertObj.name;
			objectToIndex.alert_message = alertObj.Alert_Message__c;
			objectToIndex.alert_url = alertObj.Alert_Url__c;
			objectToIndex.author = alertObj.Author__c;
			objectToIndex.notification_author_r_name = alertObj.Author__r.Full_Name__c;
			objectToIndex.display_from_datetime = alertObj.Display_From_DateTime__c;
			objectToIndex.display_to_datetime = alertObj.Display_To_DateTime__c;
			objectToIndex.notification_sent = alertObj.Notification_Sent__c;
			objectToIndex.external_id = alertObj.External_Id__c;
			objectToIndex.is_active = alertObj.Is_Active__c;
			objectToIndex.is_dismissible = alertObj.Is_Dismissible__c;
			objectToIndex.is_expired = alertObj.Is_Expired__c;
			objectToIndex.is_link_alert = alertObj.Is_Link_Alert__c;
			objectToIndex.is_manually_expired = alertObj.Is_Manually_Expired__c;
			objectToIndex.is_scheduled = alertObj.Is_Scheduled__c;
			objectToIndex.members_type = alertObj.Members_Type__c;
			objectToIndex.recipient = alertObj.Recipient__c;
			objectToIndex.recipient_count = alertObj.Recipient_Count__c;
			objectToIndex.recipient_site = alertObj.Recipient_Site__c;
			objectToIndex.seen_count = alertObj.Seen_Count__c;
			objectToIndex.audience = alertObj.Audience__c;
			objectToIndex.segment = alertObj.Audience__r.Segment__c;
            objectToIndex.is_deleted = alertObj.Is_Deleted__c;
            objectToIndex.createddate = alertObj.createddate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            objectToIndex.lastmodifieddate = alertObj.LastModifiedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		}
		return objectToIndex;
	}
	public ExternalSearchWrapper.SearchDataWrapper getSearchDataWrapperForMergeExpertise(String MergeTo, String MergeFrom){
		ExternalSearchWrapper.SearchDataWrapper expertiseObjToReturn = new ExternalSearchWrapper.SearchDataWrapper();
		String query = 'SELECT '+String.join(getExpertiseFieldsForExternalData(),',')+' From Expertise__c Where  id=:MergeTo';
		List<Expertise__c> listOfMergeToExpertiseObj = (List<Expertise__c>)Database.query(query);

		String queryStr = 'SELECT '+String.join(getExpertiseFieldsForExternalData(),',')+' From Expertise__c Where  id=:MergeFrom ';
		List<Expertise__c> listOfMergeFromExpertiseObj = (List<Expertise__c>)Database.query(queryStr);
		if(!listOfMergeToExpertiseObj.isEmpty() && !listOfMergeFromExpertiseObj.isEmpty()) {
			expertiseObjToReturn = convertPeopleExpertiseToSearchDataWrapper(listOfMergeFromExpertiseObj[0], listOfMergeToExpertiseObj[0]);
		}
		return expertiseObjToReturn;
    }

	public ExternalSearchWrapper.SearchDataWrapper convertPeopleExpertiseToSearchDataWrapper(Expertise__c mergeToExpertiseObj, Expertise__c mergeFromExpertiseObj){
		ExternalSearchWrapper.SearchDataWrapper objectToIndex = new ExternalSearchWrapper.SearchDataWrapper();
		if(mergeToExpertiseObj != null && mergeFromExpertiseObj != null){
			objectToIndex.object_type = 'Expertise';
			objectToIndex.merge_from_expertise = convertPeopleExpertise(mergeFromExpertiseObj);
			objectToIndex.merge_to_expertise = convertPeopleExpertise(mergeToExpertiseObj);
		}
		
		return objectToIndex;
	}

	private ExternalSearchWrapper.mergeWrapper convertPeopleExpertise(Expertise__c expetiseObj) {
		ExternalSearchWrapper.mergeWrapper objectToIndex = new ExternalSearchWrapper.mergeWrapper();
		objectToIndex.id = expetiseObj.id;
		objectToIndex.name = expetiseObj.Display_Name__c;
		return objectToIndex;
	}

	private ExternalSearchWrapper.SearchDataWrapper getDeletedAlertToSearchDataWrapper(String alertId) {
		ExternalSearchWrapper.SearchDataWrapper objectToIndex = new ExternalSearchWrapper.SearchDataWrapper();
		objectToIndex.id = alertId;
		objectToIndex.object_type ='Alert';
		objectToIndex.is_deleted = true;
		return objectToIndex;
	}

	public ExternalSearchWrapper.SearchDataWrapper getSearchDataWrapperForNativeVideo(String fileId){
		ExternalSearchWrapper.SearchDataWrapper fileObjToReturn = new ExternalSearchWrapper.SearchDataWrapper();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		String chatterGroupId;
		Set<String> setOfChatterGrp  = new Set<String>();
		Boolean accessibleToEveryone = false;
		soqlParamMap.put('soqlParam1', fileId);
		String query = 'SELECT '+String.join(getNativeVideoFieldsForExternalData(),',')+' From File__c Where id =:soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> listOfFileObj = (List<File__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		if(!listOfFileObj.isEmpty()) {
			String extId = listOfFileObj[0].External_Id__c;
			soqlParamMap.put('soqlParam2', extId);
			String queryStr = 'SELECT '+String.join(getNativeVideoFieldsForExternalData(),',')+' From File__c Where External_id__c =: soqlParam2 and is_deleted__c = false';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<File__c> listOfExtId = (List<File__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
			for(File__c fileObj : listOfExtId) {
				if((String.isNotBlank(fileObj.Simpplr_Content__c) && 'BlogPost'.equalsIgnoreCase(fileObj.Simpplr_Content__r.type__c)) || 
						(String.isBlank(fileObj.Simpplr_Content__c) && String.isBlank(fileObj.Site__c))) {
							accessibleToEveryone = true;
							break;
				}

				if(String.isNotBlank(fileObj.Site__c) || (String.isNotBlank(fileObj.Simpplr_Content__c) && !'BlogPost'.equalsIgnoreCase(fileObj.Simpplr_Content__r.type__c))) {
					chatterGroupId = fileObj.Simpplr_Content__c != null && String.isNotBlank(fileObj.Simpplr_Content__c) ? fileObj.Simpplr_Content__r.site__r.chatter_group_id__c : fileObj.site__r.chatter_group_id__c;
					setOfChatterGrp.add(chatterGroupId);
				}
			}
			
			if(!listOfExtId.isEmpty()) {
				Map<String, List<ExternalSearchWrapper.ChatterGroupId>> mapOfChatterGroup = getmapOfCollIdForNativeVideo(extId, setOfChatterGrp);
				fileObjToReturn = convertNativeVideoToSearchDataWrapper(listOfFileObj[0], mapOfChatterGroup.get(extId), accessibleToEveryone);	
			} else {
				fileObjToReturn = getDeletedNativeVideoToSearchDataWrapper(extId);
			}
		}
		return fileObjToReturn;
    }

    public ExternalSearchWrapper.SearchDataWrapper convertNativeVideoToSearchDataWrapper(File__c fileObj, List<ExternalSearchWrapper.ChatterGroupId> listOfChatterGroupId, Boolean accessibleToEveryone){
		ExternalSearchWrapper.SearchDataWrapper objectToIndex = new ExternalSearchWrapper.SearchDataWrapper();
		if(fileObj != null){
			objectToIndex.id = fileObj.External_Id__c;
			objectToIndex.title = fileObj.title__c;
			objectToIndex.file_name = fileObj.title__c;
			objectToIndex.object_type = 'NativeVideo';
			objectToIndex.listOfChatterGroupId = listOfChatterGroupId;
            objectToIndex.is_deleted = false;
			objectToIndex.accessible_to_everyone = accessibleToEveryone;
			objectToIndex.img = fileObj.Thumbnail_URL__c;
            objectToIndex.createddate = fileObj.createddate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            objectToIndex.lastmodifieddate = fileObj.LastModifiedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		}
		return objectToIndex;
	}

	private ExternalSearchWrapper.SearchDataWrapper getDeletedNativeVideoToSearchDataWrapper(String externalId) {
		ExternalSearchWrapper.SearchDataWrapper objectToIndex = new ExternalSearchWrapper.SearchDataWrapper();
		objectToIndex.id = externalId;
		objectToIndex.object_type ='NativeVideo';
		objectToIndex.is_deleted = true;
		return objectToIndex;
	}

	public Map<String, List<ExternalSearchWrapper.ChatterGroupId>> getmapOfCollIdForNativeVideo(String externalId, Set<String> setOfChatterGrp){
			
		Map<String, CollaborationGroup> mapOfCollaborationGroup = getmapOfCollaborationGroup(setOfChatterGrp);
		List<ExternalSearchWrapper.ChatterGroupId> listOfChatterGrp = new List<ExternalSearchWrapper.ChatterGroupId>();
		Map<String, List<ExternalSearchWrapper.ChatterGroupId>> mapOfChatterGroup = new Map<String, List<ExternalSearchWrapper.ChatterGroupId>>();
		for(String chatterGroupObj : setOfChatterGrp){
			ExternalSearchWrapper.ChatterGroupId chatterGrpIdAndType = new ExternalSearchWrapper.ChatterGroupId();
			CollaborationGroup cg = mapOfCollaborationGroup.get(chatterGroupObj);
			chatterGrpIdAndType.id = cg.id;
			chatterGrpIdAndType.site_type = cg.CollaborationType;
			chatterGrpIdAndType.is_active = !cg.IsArchived;
			chatterGrpIdAndType.is_deleted = false;
			if(mapOfChatterGroup.containsKey(externalId)){
				mapOfChatterGroup.get(externalId).add(chatterGrpIdAndType);
			
			}else {
				listOfChatterGrp = new List<ExternalSearchWrapper.ChatterGroupId>{chatterGrpIdAndType};
				mapOfChatterGroup.put(externalId,listOfChatterGrp);
			}
		}
		return mapOfChatterGroup;
	}

	public ExternalSearchWrapper.SearchDataWrapper getSearchDataWrapperForTopic(String topicId){
		ExternalSearchWrapper.SearchDataWrapper expertiseObjToReturn = new ExternalSearchWrapper.SearchDataWrapper();
		String query = 'SELECT '+String.join(getTopicFieldsForExternalData(),',')+' From Topic Where  id=:topicId';
		List<Topic> listOftopicObj = (List<Topic>)Database.query(query);
		if(!listOftopicObj.isEmpty()) {
			expertiseObjToReturn = convertTopicToSearchDataWrapper(listOftopicObj[0]);
		}
		else {
			expertiseObjToReturn = getDeletedTopicToSearchDataWrapper(topicId);
		}
		return expertiseObjToReturn;
    }

    public ExternalSearchWrapper.SearchDataWrapper convertTopicToSearchDataWrapper(Topic topicObj){
		ExternalSearchWrapper.SearchDataWrapper objectToIndex = new ExternalSearchWrapper.SearchDataWrapper();
		if(topicObj != null){
			objectToIndex.id = topicObj.id;
			objectToIndex.object_type = 'Topic';
			objectToIndex.topic_name = topicObj.Name;
            objectToIndex.is_deleted = false;
            objectToIndex.createddate = topicObj.createddate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		}
		return objectToIndex;
	}

	private ExternalSearchWrapper.SearchDataWrapper getDeletedTopicToSearchDataWrapper(String topicObj) {
		ExternalSearchWrapper.SearchDataWrapper objectToIndex = new ExternalSearchWrapper.SearchDataWrapper();
		objectToIndex.id = topicObj;
		objectToIndex.object_type ='Topic';
		objectToIndex.is_deleted = true;
		return objectToIndex;
	}

	public ExternalSearchWrapper.SearchDataWrapper getSearchDataWrapperForMergeTopic(String MergeTo, String MergeFrom){
		ExternalSearchWrapper.SearchDataWrapper objectToIndex = new ExternalSearchWrapper.SearchDataWrapper();
		if(MergeTo != null && MergeFrom != null){
			objectToIndex.id = MergeFrom;
			objectToIndex.object_type = 'Topic';
			objectToIndex.merge_from_topic = MergeFrom;
			objectToIndex.merge_to_topic = MergeTo;
		}
		return objectToIndex;
	}
    
    
    public ExternalSearchWrapper.SiteRole getSearchDataWrapperForSiteRole(String siteRoleId){
		ExternalSearchWrapper.SiteRole siteRoleObjToReturn;
        String query = 'SELECT ' + String.join(getSiteRoleFieldsForExternalData(), ',') + 
				' FROM Site_Role__c WHERE id=:siteRoleId AND Site__r.Is_Active__c = true AND Site__r.Is_Deleted__c = false ';
        List<Site_Role__c> listOfSiteRole = (List<Site_Role__c>)Database.query(query);					
		if(!listOfSiteRole.isEmpty()) {
			siteRoleObjToReturn = new ExternalSearchWrapper.SiteRole();
			List<collaborationGroup> listOfCollbGrp = [SELECT id, ownerId, name 
                FROM collaborationGroup 
                WHERE id =:listOfSiteRole[0].site__r.Chatter_Group_Id__C WITH SECURITY_ENFORCED];
			siteRoleObjToReturn = convertSiteRoleToSearchDataWrapper(listOfSiteRole[0], 
                	listOfCollbGrp[0].ownerId);
		}
		return siteRoleObjToReturn;
	}
	
    public ExternalSearchWrapper.SiteRole convertSiteRoleToSearchDataWrapper(Site_Role__c siteRoleObj, 
            String ownerId){
		ExternalSearchWrapper.SiteRole objectToIndex = new ExternalSearchWrapper.SiteRole();
        
        if (siteRoleObj != null) {
			objectToIndex.id = siteRoleObj.id;
			objectToIndex.object_type = 'Site_Role';
			objectToIndex.is_manager = siteRoleObj.is_manager__c;
            objectToIndex.is_deleted = siteRoleObj.is_deleted__c;
            objectToIndex.is_member = siteRoleObj.is_member__C;
            objectToIndex.people_id = siteRoleObj.people__c;
            objectToIndex.is_content_manager = siteRoleObj.is_content_manager__c;
            objectToIndex.site_id = siteRoleObj.site__c;
            objectToIndex.user_id = siteRoleObj.user__c;
            objectToIndex.is_owner = false; 

            if (ownerId == siteRoleObj.people__r.user__c) {
                objectToIndex.is_owner = true;
            }

            objectToIndex.createddate = siteRoleObj.createddate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            objectToIndex.lastmodifieddate = siteRoleObj.LastModifiedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        }
		return objectToIndex;
    }
    
    public ExternalSearchWrapper.SiteMembershipRequest getSearchDataWrapForSiteMembershipReq(String siteMembershipReqId){
        ExternalSearchWrapper.SiteMembershipRequest siteMemReqObjToReturn = new ExternalSearchWrapper.SiteMembershipRequest();
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1', siteMembershipReqId);
        String query = 'SELECT ' + String.join(getSiteMembershipReqFieldsForExternalData(),',') + 
                ' From Site_Membership_Request__c Where  id=:soqlParam1';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<Site_Membership_Request__c> listOfSiteMemReq = (List<Site_Membership_Request__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
        if(!listOfSiteMemReq.isEmpty()) {
            siteMemReqObjToReturn = convertSiteMemReqToSearchDataWrapper(listOfSiteMemReq[0]);
        }
        return siteMemReqObjToReturn;
    }
	
	public ExternalSearchWrapper.SiteMembershipRequest convertSiteMemReqToSearchDataWrapper(Site_Membership_Request__c siteMemReqObj){
		ExternalSearchWrapper.SiteMembershipRequest objectToIndex = new ExternalSearchWrapper.SiteMembershipRequest();
        
        if (siteMemReqObj != null) {
			objectToIndex.id = siteMemReqObj.id;
			objectToIndex.object_type = 'Site_Membership_Request';
            objectToIndex.is_deleted = siteMemReqObj.is_deleted__c; 
            objectToIndex.action_by = siteMemReqObj.action_by__c;
            
            if (siteMemReqObj.action_datetime__c != null) {
                objectToIndex.action_datetime =  siteMemReqObj.action_datetime__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            }

            if (siteMemReqObj.request_datetime__c != null) {
                objectToIndex.request_datetime =  siteMemReqObj.request_datetime__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            }

            objectToIndex.request_by = siteMemReqObj.request_by__c;
            objectToIndex.site_id = siteMemReqObj.site__c;
			objectToIndex.collaboration_group_member_request_id = siteMemReqObj.CollaborationGroupMemberRequest_Id__c;
            objectToIndex.status = siteMemReqObj.status__c;
            objectToIndex.people_id_site_id = objectToIndex.request_by + objectToIndex.site_id;
            objectToIndex.action_by_name = siteMemReqObj.action_by__r.Full_Name__c;
            objectToIndex.request_by_name = siteMemReqObj.request_by__r.Full_Name__c;
            objectToIndex.createddate = siteMemReqObj.createddate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            objectToIndex.lastmodifieddate = siteMemReqObj.LastModifiedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');

        }
        
		return objectToIndex;
	}

	private ExternalSearchWrapper.SearchDataWrapper getDeletedContentDocumentToSearchDataWrapper(String contentDocumentId) {
		ExternalSearchWrapper.SearchDataWrapper objectToIndex = new ExternalSearchWrapper.SearchDataWrapper();
		objectToIndex.id = contentDocumentId;
		objectToIndex.object_type ='file';
		objectToIndex.is_deleted = true;
		return objectToIndex;
	}
	
	private ExternalSearchWrapper.SearchDataWrapper convertContentDocumentToSearchDataWrapper(ContentDocument cdObject, List<ExternalSearchWrapper.ChatterGroupId> listOfChatterGroupId) {
		ExternalSearchWrapper.SearchDataWrapper objectToIndex = new ExternalSearchWrapper.SearchDataWrapper();
		objectToIndex.id = cdObject.id;
		objectToIndex.title = cdObject.LatestPublishedVersion.title;
		objectToIndex.description = cdObject.LatestPublishedVersion.description;
		objectToIndex.file_size = String.valueOf(cdObject.LatestPublishedVersion.ContentSize);
		objectToIndex.file_name = cdObject.LatestPublishedVersion.title;
		objectToIndex.object_type ='file';
		objectToIndex.contentVersionId =cdObject.LatestPublishedVersionId;
		objectToIndex.listOfChatterGroupId = listOfChatterGroupId;
		objectToIndex.origin = cdObject.LatestPublishedVersion.Origin;
		objectToIndex.owner_id = cdObject.LatestPublishedVersion.OwnerId;
		objectToIndex.owner_name = PeopleDao.mapUserIdToPeopleName.containsKey(cdObject.LatestPublishedVersion.Ownerid) ? PeopleDao.mapUserIdToPeopleName.get(cdObject.LatestPublishedVersion.Ownerid) : cdObject.LatestPublishedVersion.Owner.name;
		objectToIndex.type = cdObject.LatestPublishedVersion.FileType; //file type
		objectToIndex.lastmodifieddate = cdObject.LatestPublishedVersion.ContentModifiedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		objectToIndex.is_deleted = cdObject.isArchived;
		objectToIndex.fileExtension = cdObject.LatestPublishedVersion.FileExtension;
		objectToIndex.createddate = cdObject.createdDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		return objectToIndex;
	}
	
	public List<ExternalSearchWrapper.SearchDataWrapper> convertContentDocumentListToSearchDataWrapperList(List<ContentDocument> contentDocumentList,Map<String, List<ExternalSearchWrapper.ChatterGroupId>> mapOfCollIdAndContDoc){
		List<ExternalSearchWrapper.SearchDataWrapper> listOfRecords = new List<ExternalSearchWrapper.SearchDataWrapper>();
        for(ContentDocument cdObject : contentDocumentList){
			if(!setOfFileExtensionToIgnore.contains(cdObject.LatestPublishedVersion.FileType)){
				listOfRecords.add(convertContentDocumentToSearchDataWrapper(cdObject, mapOfCollIdAndContDoc.get(cdObject.id)));
			}
		}
		return listOfRecords;
	}
	
	
	public List<ExternalSearchWrapper.SearchDataWrapper> convertSiteListToSearchDataWrapperList(List<Simpplr_Site__c> siteList, Map<String,CollaborationGroup> groupmap){
		List<ExternalSearchWrapper.SearchDataWrapper> listOfObjects = new List<ExternalSearchWrapper.SearchDataWrapper>();
		for(Simpplr_site__c siteRec : siteList){
			listOfObjects.add(convertSiteToSearchDataWrapper(siteRec, groupmap.get(siteRec.Chatter_Group_Id__c)));
		}
		return listOfObjects;
    }
	
    public List<ExternalSearchWrapper.SearchDataWrapper> convertPeopleListToSearchDataWrapperList(List<People__c> listOfPeopleObj){
		List<ExternalSearchWrapper.SearchDataWrapper> listOfRecords = new List<ExternalSearchWrapper.SearchDataWrapper>();

        for (People__c peopleObj : listOfPeopleObj) {            
            ExternalSearchWrapper.SearchDataWrapper objectToIndex = convertPeopleToSearchDataWrapper(peopleObj);
            listOfRecords.add(objectToIndex);
		}

		return listOfRecords;
	}
	
	private ExternalSearchWrapper.SearchDataWrapper convertPeopleToSearchDataWrapper(People__c peopleObj) {
		ExternalSearchWrapper.SearchDataWrapper objectToIndex = new ExternalSearchWrapper.SearchDataWrapper();
		objectToIndex.id = peopleObj.id;
		objectToIndex.user = peopleObj.User__c;
		objectToIndex.joining_date = String.valueOf(peopleObj.Joining_Date__c);
		objectToIndex.street = peopleObj.Street__c;
		objectToIndex.object_type = 'People';
		objectToIndex.department = peopleObj.Department__c;
		objectToIndex.birth_date = String.valueOf(peopleObj.Birth_Date__c);
		objectToIndex.country = peopleObj.Country__c;
		objectToIndex.company_name = peopleObj.Company_Name__c;
		objectToIndex.division = peopleObj.Division__c;
		objectToIndex.user_r_show_simpplr = peopleObj.User__r.Show_Simpplr__c;
		objectToIndex.last_name = peopleObj.Last_Name__c;
		objectToIndex.mobile_phone = peopleObj.Mobile_Phone__c;
		objectToIndex.about_me = peopleObj.About__c;
		objectToIndex.city = peopleObj.City__c;
		objectToIndex.people_category = peopleObj.People_Category__c;
		objectToIndex.people_category_r_name = peopleObj.People_Category__r.Name__c;
		objectToIndex.img = Utility.getProfilePhotoURL(peopleObj.User__r.SmallPhotoURL);
		objectToIndex.user_r_isactive = peopleObj.User__r.isactive;
		objectToIndex.phone = peopleObj.Phone__c;
		objectToIndex.email = peopleObj.Email__c;
		objectToIndex.title = peopleObj.Title__c;
		objectToIndex.state = peopleObj.State__c;
		objectToIndex.user_r_usertype = peopleObj.User__r.UserType;
		objectToIndex.first_name = peopleObj.First_Name__c;
		objectToIndex.name = peopleObj.Full_Name__c;
		objectToIndex.ppl_segment_id = peopleObj.Segment__c;
		objectToIndex.is_influencer = peopleObj.Is_Influencer__c;
		objectToIndex.has_simpplr_license = peopleObj.Has_Simpplr_License__c;
		objectToIndex.is_deleted = !(peopleObj.User__r.isactive);
		objectToIndex.custom_field_1 = peopleObj.Custom_Field_1__c;
		objectToIndex.custom_field_2 = peopleObj.Custom_Field_2__c;
		objectToIndex.custom_field_3 = peopleObj.Custom_Field_3__c;
		objectToIndex.custom_field_4 = peopleObj.Custom_Field_4__c;
		objectToIndex.custom_field_5 = peopleObj.Custom_Field_5__c;
		objectToIndex.custom_field_6 = peopleObj.Custom_Field_6__c;
		objectToIndex.custom_field_7 = peopleObj.Custom_Field_7__c;
		objectToIndex.custom_field_8 = peopleObj.Custom_Field_8__c;
		objectToIndex.custom_field_9 = peopleObj.Custom_Field_9__c;
		objectToIndex.custom_field_10 = peopleObj.Custom_Field_10__c;
		objectToIndex.custom_field_11 = peopleObj.Custom_Field_11__c;
		objectToIndex.custom_field_12 = peopleObj.Custom_Field_12__c;
		objectToIndex.custom_field_13 = peopleObj.Custom_Field_13__c;
		objectToIndex.custom_field_14 = peopleObj.Custom_Field_14__c;
		objectToIndex.custom_field_15 = peopleObj.Custom_Field_15__c;
		objectToIndex.custom_field_16 = peopleObj.Custom_Field_16__c;
		objectToIndex.custom_field_17 = peopleObj.Custom_Field_17__c;
		objectToIndex.custom_field_18 = peopleObj.Custom_Field_18__c;
		objectToIndex.custom_field_19 = peopleObj.Custom_Field_19__c;
		objectToIndex.custom_field_20 = peopleObj.Custom_Field_20__c;
		objectToIndex.custom_field_21 = peopleObj.Custom_Field_21__c;
		objectToIndex.custom_field_22 = peopleObj.Custom_Field_22__c;
		objectToIndex.custom_field_23 = peopleObj.Custom_Field_23__c;
		objectToIndex.custom_field_24 = peopleObj.Custom_Field_24__c;
		objectToIndex.custom_field_25 = peopleObj.Custom_Field_25__c;
		objectToIndex.custom_profile_field_1 = peopleObj.User_Custom_Field_1__c;
		objectToIndex.custom_profile_field_2 = peopleObj.User_Custom_Field_2__c;
		objectToIndex.custom_profile_field_3 = peopleObj.User_Custom_Field_3__c;
		objectToIndex.custom_profile_field_4 = peopleObj.User_Custom_Field_4__c;
		objectToIndex.custom_profile_field_5 = peopleObj.User_Custom_Field_5__c;
		objectToIndex.custom_profile_field_6 = peopleObj.User_Custom_Field_6__c;
		objectToIndex.custom_profile_field_7 = peopleObj.User_Custom_Field_7__c;
		objectToIndex.custom_profile_field_8 = peopleObj.User_Custom_Field_8__c;
		objectToIndex.custom_profile_field_9 = peopleObj.User_Custom_Field_9__c;
		objectToIndex.custom_profile_field_10 = peopleObj.User_Custom_Field_10__c;
		objectToIndex.custom_profile_field_11 = peopleObj.User_Custom_Field_11__c;
		objectToIndex.custom_profile_field_12 = peopleObj.User_Custom_Field_12__c;
		objectToIndex.custom_profile_field_13 = peopleObj.User_Custom_Field_13__c;
		objectToIndex.custom_profile_field_14 = peopleObj.User_Custom_Field_14__c;
		objectToIndex.custom_profile_field_15 = peopleObj.User_Custom_Field_15__c;
		objectToIndex.custom_profile_field_16 = peopleObj.User_Custom_Field_16__c;
		objectToIndex.custom_profile_field_17 = peopleObj.User_Custom_Field_17__c;
		objectToIndex.custom_profile_field_18 = peopleObj.User_Custom_Field_18__c;
		objectToIndex.custom_profile_field_19 = peopleObj.User_Custom_Field_19__c;
		objectToIndex.custom_profile_field_20 = peopleObj.User_Custom_Field_20__c;
		objectToIndex.custom_profile_field_21 = peopleObj.User_Custom_Field_21__c;
		objectToIndex.custom_profile_field_22 = peopleObj.User_Custom_Field_22__c;
		objectToIndex.custom_profile_field_23 = peopleObj.User_Custom_Field_23__c;
		objectToIndex.custom_profile_field_24 = peopleObj.User_Custom_Field_24__c;
        objectToIndex.custom_profile_field_25 = peopleObj.User_Custom_Field_25__c;
        objectToIndex.createddate = peopleObj.createddate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        objectToIndex.lastmodifieddate = peopleObj.LastModifiedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		objectToIndex.enable_org_level_onboarding = peopleObj.Enable_Org_Level_Onboarding__c;
		objectToIndex.slack_user_id = peopleObj.Slack_User_Id__c;
		objectToIndex.slack_user_name = peopleObj.Slack_User_Name__c;
		objectToIndex.slack_tenant_id = peopleObj.Slack_Tenant_Id__c;
		return objectToIndex;
	}
    
    private ExternalSearchWrapper.SearchDataWrapper convertSiteToSearchDataWrapper(Simpplr_Site__c siteRec, CollaborationGroup groupRec) {
    		ExternalSearchWrapper.SearchDataWrapper objectToIndex = new ExternalSearchWrapper.SearchDataWrapper();
		objectToIndex.id = siteRec.Id;
        objectToIndex.site_name = siteRec.name;
        
		if (groupRec !=null) {
			objectToIndex.chatter_group_id = groupRec.id;
			objectToIndex.collaborationgroup_name = groupRec.name;
			objectToIndex.collaborationgroup_description = groupRec.description;
			objectToIndex.siteMemberCount = groupRec.memberCount;
        }
        
		objectToIndex.is_active = siteRec.Is_Active__c;
		objectToIndex.show_in_simpplr = siteRec.Show_In_Simpplr__c;
		objectToIndex.site_type = siteRec.Site_Type__c;
		objectToIndex.is_deleted = !(siteRec.Is_Active__c);
		objectToIndex.site_category_r_name = siteRec.Site_category__r.name__c;
		objectToIndex.site_category = siteRec.Site_category__c;
		objectToIndex.is_site_featured = siteRec.Is_Featured__c;
		objectToIndex.object_type='Site';
		objectToIndex.has_albums = siteRec.Has_Albums__c;
		objectToIndex.has_events = siteRec.Has_Events__c;
		objectToIndex.has_pages = siteRec.Has_Pages__c;
		objectToIndex.landing_page = siteRec.Landing_Page__c;
		objectToIndex.title_content_document = siteRec.Title_Content_Document__c;
		objectToIndex.title_content_version = siteRec.Title_Content_Version__c;
		objectToIndex.is_newsletter_allowed = siteRec.Is_Newsletter_Allowed__c;
		objectToIndex.is_alert_enabled = siteRec.Is_Alert_Enabled__c;
		objectToIndex.createddate = siteRec.createddate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		objectToIndex.lastmodifieddate = siteRec.LastModifiedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		objectToIndex.is_onboarding_enabled = siteRec.Is_Onboarding_Enabled__c;
		objectToIndex.question_answer_enabled = siteRec.Question_Answer_Enabled__c;
		return objectToIndex;
    }

    /**
    * @description adopter method to convert content template object to json
    * @param contentTemplate content template object to be pushed to elastic
    * @return ExternalSearchWrapper.SearchDataWrapper wrapper json of content template to be pushed to elastic
    **/
    private ExternalSearchWrapper.SearchDataWrapper convertContentTemplateToSearchDataWrapper(Content_Template__c contentTemplate) {
		ExternalSearchWrapper.SearchDataWrapper objectToIndex = new ExternalSearchWrapper.SearchDataWrapper();
		objectToIndex.id = contentTemplate.Id;
		objectToIndex.name = contentTemplate.Name__c;
		objectToIndex.is_enabled = contentTemplate.Is_Enabled__c;
		objectToIndex.is_system_template = contentTemplate.Is_System_Template__c;
		objectToIndex.content_sub_type = contentTemplate.Sub_type__c;

		objectToIndex.primary_author = contentTemplate.Primary_Author__c;
		objectToIndex.site = contentTemplate.Site__c;
		objectToIndex.object_type = 'Content_Template';
		
		objectToIndex.pages_category_r_name = contentTemplate.Pages_Category__r.Name__c;
		objectToIndex.pages_category = contentTemplate.Pages_Category__c;
		objectToIndex.primary_author_r_name = contentTemplate.Primary_author__r.Full_Name__c;
		objectToIndex.primary_author_r_ppl_segment_id = contentTemplate.Primary_Author__r.Segment__c;
		objectToIndex.primary_author_r_department = contentTemplate.Primary_Author__r.Department__c;
		objectToIndex.primary_author_r_people_category = contentTemplate.Primary_Author__r.People_Category__c;
		objectToIndex.title = contentTemplate.Title__c;

		objectToIndex.site_r_site_type = contentTemplate.Site__r.Site_Type__c;
		objectToIndex.site_r_landing_page = contentTemplate.Site__r.Landing_Page__c;
		objectToIndex.site_r_is_active = contentTemplate.Site__r.Is_Active__c ;
		objectToIndex.site_r_is_deleted = !(contentTemplate.Site__r.Is_Active__c);
		objectToIndex.site_r_name = contentTemplate.Site__r.Name;
		objectToIndex.site_r_show_in_simpplr = contentTemplate.Site__r.Show_In_Simpplr__c;
		objectToIndex.site_r_chatter_group_id = contentTemplate.Site__r.Chatter_Group_Id__c;
		objectToIndex.site_r_has_pages = contentTemplate.Site__r.Has_Pages__c;
		objectToIndex.site_r_has_albums = contentTemplate.Site__r.Has_Albums__c;
		objectToIndex.site_r_has_events = contentTemplate.Site__r.Has_Events__c;

		objectToIndex.type = contentTemplate.type__c;
		objectToIndex.is_deleted = contentTemplate.Is_Deleted__c;
		objectToIndex.createddate = contentTemplate.createddate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        objectToIndex.lastmodifieddate = contentTemplate.LastModifiedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		
		objectToIndex.site_r_title_content_version = contentTemplate.Site__r.Title_Content_Version__c;
		objectToIndex.site_r_title_content_document = contentTemplate.Site__r.Title_Content_Document__c;
		
		return objectToIndex;		
    }
    
	private ExternalSearchWrapper.SearchDataWrapper convertSimpplrContentToSearchDataWrapper(Simpplr_Content__c contentObj, 
			List<ExternalSearchWrapper.TopicWrapper> listOfExtTopicWrap, List<File__C> fileList) {
		ExternalSearchWrapper.SearchDataWrapper objectToIndex = new ExternalSearchWrapper.SearchDataWrapper();
		objectToIndex.id = contentObj.Id;
		objectToIndex.primary_author = contentObj.primary_author__c;
		objectToIndex.site = contentObj.site__c;
		objectToIndex.object_type = 'Content';
		objectToIndex.topics = listOfExtTopicWrap;
		objectToIndex.content_sub_type = contentObj.content_sub_type__c;
		objectToIndex.last_validated_date_time = (contentObj.last_validated_datetime__c != null) ? contentObj.last_validated_datetime__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ') : null;

		if(contentObj.last_edited_datetime__c != null){
			objectToIndex.last_edited_datetime = contentObj.last_edited_datetime__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		} else {
			objectToIndex.last_edited_datetime = contentObj.lastmodifieddate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		}
		objectToIndex.summary = contentObj.Summary_1__c;
		objectToIndex.status = contentObj.Status__c;
		objectToIndex.question_answer_enabled = contentObj.Question_Answer_Enabled__c;
		
		if('Page'.equalsIgnoreCase(contentObj.type__c)) {
			objectToIndex.pages_category_r_name = contentObj.Pages_Category__r.name__c;
			objectToIndex.pages_category = contentObj.Pages_Category__c;
		
		} else if('Event'.equalsIgnoreCase(contentObj.type__c)) {
			objectToIndex.event_timezonesidkey = contentObj.Event_TimezoneSidKey__c;
			objectToIndex.event_end_datetime = contentObj.Event_End_DateTime__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
			objectToIndex.event_start_datetime = contentObj.Event_Start_DateTime__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
			objectToIndex.attending_count = Integer.valueOf(contentObj.Event_Attending_Count__c);
			objectToIndex.event_rsvp_limit = Integer.valueOf(contentObj.Event_RSVP_Limit__c);
		}
		
		objectToIndex.is_published = contentObj.Is_Published__c;
		objectToIndex.primary_author_r_name = contentObj.Primary_author__r.Full_Name__c;
		objectToIndex.is_must_read = contentObj.Is_Must_Read__c;
		objectToIndex.primary_author_r_ppl_segment_id = contentObj.Primary_Author__r.Segment__c;
		objectToIndex.primary_author_r_department = contentObj.Primary_Author__r.Department__c;
		objectToIndex.primary_author_r_people_category = contentObj.Primary_Author__r.People_Category__c;
		objectToIndex.publish_start_datetime = contentObj.publish_start_datetime__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		if(contentObj.publish_end_datetime__c != null) {
			objectToIndex.publish_end_datetime = contentObj.publish_end_datetime__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		}
		objectToIndex.title = contentObj.title__c;
		
		if(!('BlogPost'.equalsIgnoreCase(contentObj.type__c))){
			objectToIndex.site_r_site_type = contentObj.site__r.site_type__c;
			objectToIndex.site_r_landing_page = contentObj.site__r.Landing_Page__c;
			objectToIndex.site_r_is_active = contentObj.site__r.is_active__c ;
			objectToIndex.site_r_is_deleted = !(contentObj.site__r.is_active__c);
			objectToIndex.site_r_name = contentObj.site__r.name;
			objectToIndex.site_r_show_in_simpplr = contentObj.site__r.show_in_simpplr__c;
			objectToIndex.site_r_chatter_group_id = contentObj.site__r.chatter_group_id__c;
			objectToIndex.site_r_has_pages = contentObj.site__r.has_Pages__c;
			objectToIndex.site_r_has_albums = contentObj.site__r.Has_Albums__c;
			objectToIndex.site_r_has_events = contentObj.site__r.Has_Events__c;
		}
		objectToIndex.event_is_all_day = contentObj.Event_Is_All_Day__c;
		objectToIndex.display_summary = contentObj.Display_Excerpt__c;
		objectToIndex.type = contentObj.type__c;
		objectToIndex.likes_int = Integer.valueOf(contentObj.Likes__c);
		objectToIndex.total_view_count_int = Integer.valueOf(contentObj.Total_View_Count__c);
		objectToIndex.is_deleted = contentObj.Is_Deleted__c;
		objectToIndex.createddate = contentObj.createddate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        objectToIndex.lastmodifieddate = contentObj.LastModifiedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		objectToIndex.event_rsvp_allowed = contentObj.Event_RSVP_Allowed__c;
		objectToIndex.event_rsvp_show_maybe = contentObj.Event_RSVP_Show_Maybe__c;
		objectToIndex.body = (String.isNotBlank(contentObj.Text_Intro__c) ? contentObj.Text_Intro__c : '') +
							  (String.isNotBlank(contentObj.Text_Main__c) ? contentObj.Text_Main__c : '') +
							  (String.isNotBlank(contentObj.Text_Main_Continued__c) ? contentObj.Text_Main_Continued__c : '');
		
		objectToIndex.site_r_title_content_version = contentObj.site__r.Title_Content_Version__c;
		objectToIndex.site_r_title_content_document = contentObj.site__r.Title_Content_Document__c;
		
		if(fileList.size() > 0) {
			List<ExternalSearchWrapper.AttachedFile> listOfAttachment = new List<ExternalSearchWrapper.AttachedFile>();
		
			for(File__c fileObj : fileList) {
		
				if(fileObj.Is_Title_Image__c) {
		
					if(ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(contentObj.Type__c)) {
						objectToIndex.img = String.isNotBlank(fileObj.Content_Version__c) ? Utility.getFileDownloadURL(fileObj.Content_Version__c) : fileObj.Thumbnail_URL__c;
						objectToIndex.imgLandscape = objectToIndex.img;
						objectToIndex.imgContentDocumentId = fileObj.Content_Document__c;
						objectToIndex.imgContentVersionId = fileObj.Content_Version__c;
						objectToIndex.imgLandscapeContentDocumentId = objectToIndex.imgContentDocumentId;
						objectToIndex.imgLandscapeContentVersionId = objectToIndex.imgContentVersionId;
	        				
					} else if(ServiceConstants.TITLE_IMAGE_TYPE_THUMBNAIL.equalsIgnoreCase(fileObj.Title_Image_Type__c)){
						objectToIndex.img = fileObj.Content_Version__c;
						objectToIndex.imgContentDocumentId = fileObj.Content_Document__c;
						objectToIndex.imgContentVersionId = fileObj.Content_Version__c;
					
					} else if(ServiceConstants.TITLE_IMAGE_TYPE_WIDESCREEN.equalsIgnoreCase(fileObj.Title_Image_Type__c)) {
						objectToIndex.imgLandscape = fileObj.Content_Version__c;
						objectToIndex.imgLandscapeContentVersionId = fileObj.Content_Version__c;
						objectToIndex.imgLandscapeContentDocumentId = fileObj.Content_Document__c;
        					
					}
		
				} else if(('CRM Library').equalsIgnorecase(fileObj.Repository__c) || ('Intranet').equalsIgnorecase(fileObj.Repository__c)){
					ExternalSearchWrapper.AttachedFile attachedFile = new ExternalSearchWrapper.AttachedFile();
					attachedFile.contentDocumentId = fileObj.Content_Document__c;
					attachedFile.contentVersionId = fileObj.Content_Version__c;
					attachedFile.fileType = fileObj.MIME_Type__c;
					listOfAttachment.add(attachedFile);
				}

			}

			objectToIndex.listOfAttachment = listOfAttachment;
		} else {
			// 
		}

		objectToIndex.onboarding_status = contentObj.Content_Onboarding_Status__c;
		objectToIndex.onboarding_added_date = (contentObj.Onboarding_Added_Date__c != null) ? Utility.dateToDisplayString(contentObj.Onboarding_Added_Date__c,'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ') : null;
		return objectToIndex;		
    }

	private ExternalSearchWrapper.EventRSVPResponseWrapper convertEventRSVPResponseToSearchDataWrapper(Event_RSVP_Response__c rsvpResponseObj) {
		ExternalSearchWrapper.EventRSVPResponseWrapper objectToIndex = new ExternalSearchWrapper.EventRSVPResponseWrapper();
		objectToIndex.id = rsvpResponseObj.id;
		objectToIndex.content_id = rsvpResponseObj.Content__c;
		objectToIndex.people_id = rsvpResponseObj.People__c;
		objectToIndex.rsvp_response = rsvpResponseObj.RSVP_Response__c;
        objectToIndex.object_type = 'rsvp';
        objectToIndex.createddate = rsvpResponseObj.createddate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        objectToIndex.lastmodifieddate = rsvpResponseObj.LastModifiedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		return objectToIndex;
	}
    
	private List<String> getContentFieldsForExternalData(){
		return New List<String>{
			'Id',
			'Primary_author__r.Full_Name__c', 
			'primary_author__c', 
			'Primary_Author__r.Department__c',
			'Primary_Author__r.People_Category__c',
			'Primary_Author__r.Segment__c',
			'publish_start_datetime__c',
			'publish_end_datetime__c',  
			'last_edited_datetime__c',
			'content_sub_type__c',
			'last_validated_datetime__c',
			'Pages_Category__c', 
			'Pages_Category__r.name__c', 
			'Display_Excerpt__c',
			'title__c',
			'Status__c',
			'type__c', 
			'Likes__c',
			'Total_View_Count__c',
			'Event_Attending_Count__c',
			'site__c',
			'site__r.is_active__c',
			'site__r.show_in_simpplr__c',
			'site__r.site_type__c',
			'site__r.name',
			'site__r.chatter_group_id__c',
			'site__r.has_Pages__c',
			'site__r.Has_Events__c',
			'site__r.Has_Albums__c',
			'site__r.Landing_Page__c',
			'Site__r.Title_Content_Version__c',
			'Site__r.Title_Content_Document__c',
			'Is_Must_Read__c',
			'Is_Deleted__c',
			'Event_Is_All_Day__c',
			'Is_Published__c',
			'Event_End_DateTime__c',
			'Event_Start_DateTime__c',
			'Event_TimezoneSidKey__c',
			'Event_RSVP_Allowed__c',
			'Event_RSVP_Show_Maybe__c',
			'Event_RSVP_Limit__c',
			'Text_Intro__c',
			'Text_Main__c',
			'Text_Main_Continued__c',
			'Summary_1__c',
			'Question_Answer_Enabled__c',
            'lastmodifieddate',
            'CreatedDate',
			'Content_Onboarding_Status__c',
			'Onboarding_Added_Date__c'
		};
	}

	private List<String> getContentTemplateFieldsForExternalData(){
		return New List<String>{
			'Id',
			'Name__c',
			'Is_Enabled__c',
			'Is_System_Template__c',
			'Primary_author__r.Full_Name__c', 
			'primary_author__c', 
			'Primary_Author__r.Department__c',
			'Primary_Author__r.People_Category__c',
			'Primary_Author__r.Segment__c',
			'Sub_Type__c',
			'Pages_Category__c', 
			'Pages_Category__r.Name__c', 
			'Title__c',
			'Type__c', 
			'Site__c',
			'Site__r.Is_Active__c',
			'Site__r.Show_In_Simpplr__c',
			'Site__r.Site_Type__c',
			'Site__r.Name',
			'Site__r.Chatter_Group_Id__c',
			'Site__r.Has_Pages__c',
			'Site__r.Has_Events__c',
			'Site__r.Has_Albums__c',
			'Site__r.Landing_Page__c',
			'Site__r.Title_Content_Version__c',
			'Site__r.Title_Content_Document__c',
			'Is_Deleted__c',
			'LastModifiedDate',
			'CreatedDate'
		};
	}

	private List<String> getContentFieldsForExternalDataFiles(){
		return New List<String>{
			'Id',
			'Content_Document__c',
			'Content_Version__c',
			'Repository__c',
			'MIME_Type__c',
			'Is_Title_Image__c',
			'Title_Image_Type__c',
			'Thumbnail_URL__c'
			};
	}

	public List<String> getEventRSVPResponseFieldsForExternalData(){
		return New List<String>{
			'Id',
			'Name',
			'Content__c', 
			'Is_Deleted__c', 
			'People__c', 
            'RSVP_Response__c',
            'CreatedDate', 
            'LastModifiedDate'
		};
	}
	
	public List<String> getSiteFieldsForExternalData(){
		return New List<String>{
			'Id',
			'Name',
			'Is_Active__c', 
			'Show_In_Simpplr__c', 
			'Site_Type__c', 
			'Is_Featured__c', 
			'chatter_group_id__c',
			'Site_category__r.name__c',
			'Site_category__c', 
			'Has_Albums__c',
			'Has_Events__c',
			'Has_Pages__c',
			'Landing_Page__c',
			'Title_Content_Document__c',
			'Title_Content_Version__c',
			'Is_Newsletter_Allowed__c', 
			'Is_Alert_Enabled__c',
			'CreatedDate', 
			'LastModifiedDate',
			'Is_Onboarding_Enabled__c',
			'Question_Answer_Enabled__c'
		};
	}
	
	public List<String> getContentDocumentFields(){
		return New List<String>{
			'Id',
			'LatestPublishedVersion.Description',
			'LatestPublishedVersion.Title',
			'LatestPublishedVersion.ContentSize',
			'LatestPublishedVersionId',
			'LatestPublishedVersion.Origin',
			'LatestPublishedVersion.OwnerId',
			'LatestPublishedVersion.Owner.name',
			'LatestPublishedVersion.ContentModifiedDate',
			'LatestPublishedVersion.FileType',
			'LatestPublishedVersion.FileExtension',
			'createdDate',
            'isArchived',
            'LastModifiedDate'
		};
	}
	public List<String> getPeopleFieldsForExternalData() {
		return New List<String>{
			'Id',
			'User__c', 
			'Title__c', 
			'Street__c', 
			'State__c', 
			'About__c', 
			'User__r.isactive', 
			'People_Category__c',
			'Mobile_Phone__c', 
			'Department__c', 
			'Email__c', 
			'Phone__c',
			'Joining_Date__c', 
			'Extension__c',
			'Manager__c',
			'Birth_Date__c', 
			'People_Category__r.Name__c',
			'User__r.SmallPhotoURL', 
			'Full_Name__c',
			'City__c', 
			'Country__c',
			'Company_Name__c',
			'Division__c',
			'First_Name__c', 
			'Last_Name__c',
			'User__r.UserType',
			'User__r.Show_Simpplr__c',
			'Segment__c',
			'Custom_Field_1__c',
			'Custom_Field_2__c',
			'Custom_Field_3__c',
			'Custom_Field_4__c',
			'Custom_Field_5__c',
			'Custom_Field_6__c',
			'Custom_Field_7__c',
			'Custom_Field_8__c',
			'Custom_Field_9__c',
			'Custom_Field_10__c',			
			'Custom_Field_11__c',
			'Custom_Field_12__c',
			'Custom_Field_13__c',
			'Custom_Field_14__c',
			'Custom_Field_15__c',
			'Custom_Field_16__c',
			'Custom_Field_17__c',
			'Custom_Field_18__c',
			'Custom_Field_19__c',
			'Custom_Field_20__c',
			'Custom_Field_21__c',
			'Custom_Field_22__c',
			'Custom_Field_23__c',
			'Custom_Field_24__c',
			'Custom_Field_25__c',									
			'User_Custom_Field_1__c',
			'User_Custom_Field_2__c',
			'User_Custom_Field_3__c',
			'User_Custom_Field_4__c',
			'User_Custom_Field_5__c',
			'User_Custom_Field_6__c',
			'User_Custom_Field_7__c',
			'User_Custom_Field_8__c',
			'User_Custom_Field_9__c',
			'User_Custom_Field_10__c',
			'User_Custom_Field_11__c',
			'User_Custom_Field_12__c',
			'User_Custom_Field_13__c',
			'User_Custom_Field_14__c',
			'User_Custom_Field_15__c',
			'User_Custom_Field_16__c',
			'User_Custom_Field_17__c',
			'User_Custom_Field_18__c',
			'User_Custom_Field_19__c',
			'User_Custom_Field_20__c',
			'User_Custom_Field_21__c',
			'User_Custom_Field_22__c',
			'User_Custom_Field_23__c',
			'User_Custom_Field_24__c',
			'User_Custom_Field_25__c',
            'Is_Influencer__c',
			'Has_Simpplr_License__c',
            'CreatedDate', 
            'LastModifiedDate',
			'Enable_Org_Level_Onboarding__c',
			'Slack_User_Id__c',
			'Slack_User_Name__c',
			'Slack_Tenant_Id__c'
		};
	}
	
	public List<String> getPeopleCategoryFieldsForExternalData() {
		return New List<String>{
			'Id',
			'Is_Deleted__c',
            'Name__c',
            'CreatedDate', 
            'LastModifiedDate'
		};
    }

	public List<String> getSiteCategoryFieldsForExternalData() {
		return New List<String>{
			'Id',
			'Is_Deleted__c',
			'Name__c', 
            'access__c',
            'CreatedDate', 
            'LastModifiedDate'
		};
    }

	public List<String> getPagesCategoryFieldsForExternalData() {
		return New List<String>{
			'Id',
			'Is_Deleted__c',
			'Name__c', 
            'Site__c',
            'CreatedDate', 
            'LastModifiedDate'
		};
    }
    
    public List<String> getSiteRoleFieldsForExternalData() {
		return New List<String>{
			'Id',
            'Is_content_manager__c',
            'Is_Manager__c',
            'Is_Deleted__c',
            'Is_Member__c',
            'People__c',
            'Site__c',
            'User__c',
            'site__r.ownerId',
            'people__r.user__c',
            'site__r.chatter_group_id__c',
            'CreatedDate', 
            'LastModifiedDate'
		};
	}
	
	public List<String> getExpertiseFieldsForExternalData() {
		return New List<String>{
			'Id',
            'Display_Name__c',
			'User_Count__c',
            'IsDeleted',
            'CreatedDate', 
            'LastModifiedDate'

		};
	}
	
	public List<String> getPeopleExpertiseFieldsForExternalData() {
		return New List<String>{
			'Id',
            'Expertise__c'
		};
    }

	public List<String> getAlertFieldsForExternalData() {
		return New List<String>{
			'Id',
            'Name',
			'IsDeleted',
			'Alert_Message__c',
			'Alert_Url__c',
			'Author__c',
			'Author__r.Full_Name__c',
			'Display_From_DateTime__c',
			'Display_To_DateTime__c',
			'Notification_Sent__c',
			'External_Id__c',
			'External_URL__c',
			'Is_Active__c',
			'Is_Deleted__c',
			'Is_Dismissible__c',
			'Is_Expired__c',
			'Is_Link_Alert__c',
			'Is_Manually_Expired__c',
			'Is_Scheduled__c',
			'Members_Type__c',
			'Recipient__c',
			'Recipient_Count__c',
			'Recipient_Site__c',
			'Seen_Count__c',
			'Audience__c',
            'Audience__r.Segment__c',
            'CreatedDate', 
            'LastModifiedDate'
		};
    }
    
	
	public List<String> getTopicFieldsForExternalData() {
		return New List<String>{
			'Id',
            'Name',
            'CreatedDate'
		};
	}

	public List<String> getNativevideoFieldsForExternalData() {
		return New List<String>{
			'Id',
            'External_Id__c',
			'Is_deleted__c',
            'Title__c',
			'Site__c',
			'Simpplr_Content__c',
			'Simpplr_Content__r.type__c',
			'Simpplr_Content__r.site__r.chatter_group_id__c',
			'site__r.chatter_group_id__c',
			'Thumbnail_URL__c',
			'Feed_Item__c',
            'CreatedDate', 
            'LastModifiedDate'
		};
	}
	
    public List<String> getSiteMembershipReqFieldsForExternalData() {
		return New List<String>{
			'Id',
            'Action_By__c',
            'Action_By__r.Full_Name__c',
            'Action_DateTime__c',
            'Is_Deleted__c',
            'Comment__c',
            'Request_DateTime__c',
            'Request_By__c',
            'Request_By__r.Full_Name__c',
			'CollaborationGroupMemberRequest_Id__c',
            'Site__c',
            'Status__c',
            'CreatedDate', 
            'LastModifiedDate'
		};
	}

	/**
	* @description gets Tile_Config fields list
	* @return fields list
	*/
	public List<String> getTileConfigFieldsForExternalData(){
		return new List<String>{
			'Id',
			'Data__c',
			'Is_Active__c',
			'Is_Deleted__c',
			'Is_Manager_Driven__c',
			'Is_Newly_Pushed__c',
			'Layout_Column__c',
			'Location__c',
			'Mobile_Order__c',
			'Name__c',
			'Order__c',
			'People__c',
			'Segment__c',
			'Sync_Status__c',
			'Type__c',
			'Variant__c',
			'CreatedById',
			'CreatedDate',
			'LastModifiedById',
			'LastModifiedDate',
			'Site__c',
			'Site__r.Chatter_Group_Id__c',
			'Site__r.Name',
			'Site__r.Is_Active__c',
			'Site__r.Is_Deleted__c',
			'Site__r.Show_In_Simpplr__c',
			'Site__r.Site_Type__c',
			'Site__r.Title_Content_Version__c',
			'Site__r.Landing_Page__c'
		};
	}

    public List<String> getMustReadAuditFieldsForExternalData() {
        return New List<String>{
            'Id',
            'Audience_Type__c',
            'Content__c',
            'Removed_By_People__c',
            'Removed_Reason__c',
            'Removed_DateTime__c',
            'CreatedDate', 
            'LastModifiedDate'
        };
    }

    public List<String> getMustReadConfirmHistoryFieldsForExternalData() {
        return New List<String>{
            'Id',
            'Content__c',
            'People__c',
            'CreatedDate', 
            'LastModifiedDate'
        };
    }
	
	public Map<String, List<ExternalSearchWrapper.ChatterGroupId>> getmapOfCollIdAndContDoc(List<ContentDocument> contentDocumentList){
		List<String> listOfIds = new List<String>();
		Map<String, List<ExternalSearchWrapper.ChatterGroupId>> mapOfCollIdAndContDoc = new Map<String, List<ExternalSearchWrapper.ChatterGroupId>>();
		
		for(ContentDocument cd : contentDocumentList){
			listOfIds.add(cd.Id);
		}
		String query ='Select Id, LinkedEntityId,LinkedEntity.Type, ContentDocumentId, IsDeleted From ContentDocumentLink Where ContentDocumentId IN :listOfIds';
		
		List<ContentDocumentLink> listOfCDLs = Database.query(query);
		
		Set<String> setOfChatterGrp = new set<String>();
		for(ContentDocumentLink cdl : listOfCDLs){
			if('CollaborationGroup'.containsIgnoreCase(cdl.LinkedEntity.Type) && cdl.IsDeleted==false){
				setOfChatterGrp.add(cdl.LinkedEntityId);
			}
		}
		Map<String, CollaborationGroup> mapOfCollaborationGroup = getmapOfCollaborationGroup(setOfChatterGrp);
		List<ExternalSearchWrapper.ChatterGroupId> listOfChatterGrp = new List<ExternalSearchWrapper.ChatterGroupId>();
		
		for(ContentDocumentLink cdl : listOfCDLs){
			if('CollaborationGroup'.containsIgnoreCase(cdl.LinkedEntity.Type)){
				ExternalSearchWrapper.ChatterGroupId chatterGrpIdAndType = new ExternalSearchWrapper.ChatterGroupId();
				CollaborationGroup cg = mapOfCollaborationGroup.get(cdl.LinkedEntityId);
				chatterGrpIdAndType.id = cdl.LinkedEntityId;
				chatterGrpIdAndType.site_type = cg.CollaborationType;
				chatterGrpIdAndType.is_active = !cg.IsArchived;
				chatterGrpIdAndType.is_deleted = false;
				if(mapOfCollIdAndContDoc.containsKey(cdl.ContentDocumentId)){
					mapOfCollIdAndContDoc.get(cdl.ContentDocumentId).add(chatterGrpIdAndType);
				
				}else {
					listOfChatterGrp = new List<ExternalSearchWrapper.ChatterGroupId>{chatterGrpIdAndType};
					mapOfCollIdAndContDoc.put(cdl.ContentDocumentId,listOfChatterGrp);
				}
				
			}
		}
		return mapOfCollIdAndContDoc;
	}
	
	private Map<String, CollaborationGroup> getMapOfCollaborationGroup(Set<String> setOfCollId){
		Map<String, CollaborationGroup> mapOfCollaborationGroup = new Map<String, CollaborationGroup>();
		mapOfCollaborationGroup = new Map<String,CollaborationGroup>([Select Id,CollaborationType, IsArchived FROM CollaborationGroup WHERE Id IN: setOfCollId]);	
		return mapOfCollaborationGroup;
    }

	/**
	* 
	* @description  gets wrapper data for dashboard links
	* @param segmentId
	* @return  wrapperList
	*/
	public List<ExternalSearchWrapper.CustomLink> getSearchDataWrapperForLinks(String segmentId) {
		List<ExternalSearchWrapper.CustomLink> linksWrapperToReturn = new List<ExternalSearchWrapper.CustomLink>();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		String query;
		if(String.isNotBlank(segmentId)) {
			soqlParamMap.put('soqlParam1', segmentId);
			query = 'SELECT Id, Custom_Links_JSON__c FROM Segment__c WHERE Id = :soqlParam1';
		} else {
			query = 'SELECT Id, Custom_Links_JSON__c FROM App_Config__c Limit 1';
		}
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Sobject> linksSobject = SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
		List<LaunchpadWrapper.LinkWrapper> listOfLinksWrapper = new List<LaunchpadWrapper.LinkWrapper>();
		String namespacePrefix = SimpplrContext.namespacePrefix;
		if(!linksSobject.isEmpty() && String.isNotBlank((String)linksSobject[0].get(namespacePrefix + 'Custom_Links_JSON__c'))) {
			listOfLinksWrapper = (List<LaunchpadWrapper.LinkWrapper>)JSON.deserialize((String)linksSobject[0].get(namespacePrefix + 'Custom_Links_JSON__c'), List<LaunchpadWrapper.LinkWrapper>.class);
		}
		for(LaunchpadWrapper.LinkWrapper linkObj : listOfLinksWrapper) {
			ExternalSearchWrapper.CustomLink customLink = new ExternalSearchWrapper.CustomLink();
			customLink.object_type = 'Links';
			customLink.links_url = linkObj.url;
			customLink.links_on_off = linkObj.onOff;
			customLink.links_label = linkObj.name;
			customLink.links_item_order = String.isNotBlank(linkObj.itemOrder) ? Integer.valueOf(linkObj.itemOrder) : 0;
			customLink.ppl_segment_id = segmentId;
			linksWrapperToReturn.add(customLink);
		}
		if(linksWrapperToReturn.isEmpty()) {
			ExternalSearchWrapper.CustomLink customLink = new ExternalSearchWrapper.CustomLink();
			customLink.object_type = 'Links';
			customLink.links_on_off = false;
			customLink.links_item_order = 0;
			customLink.ppl_segment_id = segmentId;
			linksWrapperToReturn.add(customLink);
		}
		return linksWrapperToReturn;
	}
    
    public ExternalSearchWrapper.Newsletter getSearchDataWrapForNewsletter(String newsletterId){
        ExternalSearchWrapper.Newsletter newsletterToReturn = new ExternalSearchWrapper.Newsletter();
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', newsletterId);
        String query = 'SELECT '+String.join(getNewsletterFieldList(),',') + 
                ' FROM Mailer__c WHERE id=:soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Mailer__c> newsletterList = (List<Mailer__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
        newsletterToReturn = convertNewsletterToSearchDataWrapper(newsletterList[0]);
        return newsletterToReturn; 
	}
	
	public ExternalSearchWrapper.Newsletter convertNewsletterToSearchDataWrapper(Mailer__c newsletterObj){
		ExternalSearchWrapper.Newsletter objectToIndex = new ExternalSearchWrapper.Newsletter();
        objectToIndex.object_type = 'Newsletter';
        objectToIndex.is_deleted = newsletterObj.Is_Deleted__c; 
        objectToIndex.id  = newsletterObj.id; 
        objectToIndex.subject = newsletterObj.Subject__c;
        objectToIndex.name = newsletterObj.name__c;
        objectToIndex.site = newsletterObj.site__c;
        objectToIndex.status = newsletterObj.Status__c;
        objectToIndex.senddate = (newsletterObj.Sent_Time__c != null)? newsletterObj.Sent_Time__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'):null;
        objectToIndex.recipient_site = newsletterObj.Site__c;
        objectToIndex.recipient_audience = newsletterObj.Audience__c;
        objectToIndex.recipient = newsletterObj.Recipient__c;
        objectToIndex.createddate = newsletterObj.CreatedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        objectToIndex.lastmodifieddate = newsletterObj.LastModifiedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        objectToIndex.sent_by = newsletterObj.Sent_By__c;
        objectToIndex.primary_author = newsletterObj.Sent_By__c;
        objectToIndex.content_details = new List<ExternalSearchWrapper.NewsletterContentDetail>();
        objectToIndex.content_details = getNLContentDetails(newsletterObj.id);
		return objectToIndex;
    }

    private List<ExternalSearchWrapper.NewsletterContentDetail> getNLContentDetails (Id newsLetterId) {
        List<ExternalSearchWrapper.NewsletterContentDetail> listOfNLContentDetail = new List<ExternalSearchWrapper.NewsletterContentDetail>();	
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', newsLetterId);
        String query = 'SELECT Id, Is_Deleted__c, Mailer__c, ' 
				+ ' Content__c, content__r.Title__c, content__r.Display_Excerpt__c '
				+ ' FROM Mailer_Details__c '
                + ' WHERE Mailer__c =:soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Mailer_Details__c> mailerDetailsList = (List<Mailer_Details__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
        for (Mailer_Details__c mailerDetailObj: mailerDetailsList) {
            ExternalSearchWrapper.NewsletterContentDetail nLContentDetailObj = new ExternalSearchWrapper.NewsletterContentDetail();
            nLContentDetailObj.content_id = mailerDetailObj.Content__c;
            nLContentDetailObj.content_r_title = mailerDetailObj.Content__r.Title__c;
            nLContentDetailObj.content_r_display_summary = mailerDetailObj.Content__r.Display_Excerpt__c;
            listOfNLContentDetail.add(nLContentDetailObj);
        }

        return listOfNLContentDetail;
    }
    
    public static List<String> getNewsletterFieldList() {
    	return new List<String> {
    		'Id',
            'Name__c',
            'Is_Deleted__c',
			'Audience__c',
			'Audience__r.Name__c',
			'Recipient__c',
            'From_Address__c',
            'From_Address_Id__c',
            'Introduction_Inlined__c',
            'Introduction_Text__c',
            'Sent_By__c',
            'Sent_Time__c',
            'Status__c',
            'Site__c',
            'Subject__c',
            'CreatedDate',
            'lastModifiedDate',
            '(select id, name from Mailer_Details_Mailer__r )'
        };
    }

	/**
	* @description gets data wrapper for tiles_config
	* @param tileConfigId
	* @return data wrapper
	*/
	public ExternalSearchWrapper.TilesConfig getSearchDataWrapperForTilesConfig(String tileConfigId){
		ExternalSearchWrapper.TilesConfig tileConfigObjToReturn = null; 
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', tileConfigId);
		String query = 'SELECT ' + String.join(getTileConfigFieldsForExternalData(), ',') + ' From Tiles_Config__c Where id =:soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Tiles_Config__c> listOfTilesConfigObj = (List<Tiles_Config__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		if(!listOfTilesConfigObj.isEmpty()) {
			tileConfigObjToReturn = new ExternalSearchWrapper.TilesConfig();
			CollaborationGroup collaborationGroupRec;
			if(listOfTilesConfigObj[0].Site__c != null) {
				String groupId = listOfTilesConfigObj[0].Site__r.Chatter_group_Id__c;
				String chatterGroupQuery = 'SELECT Description, InformationTitle, InformationBody FROM CollaborationGroup WHERE id = :groupId ';
				chatterGroupQuery += SimpplrContext.isCommunitiesEnabled ? ' AND NetworkId = null' : '';
				List<CollaborationGroup> listOfCollaborationGroups = Database.query(chatterGroupQuery);
				collaborationGroupRec = listOfCollaborationGroups.size() > 0 ? listOfCollaborationGroups[0] : null;
			}
			tileConfigObjToReturn = convertTilesConfigToSearchDataWrapper(listOfTilesConfigObj[0], collaborationGroupRec);
		}
		return tileConfigObjToReturn;
	}

	/**
	* @description convert tiles_config object into data wrapper
	* @param tilesConfigObj
	* @param collaborationGroupRec
	* @return data wrapper
	*/
	public ExternalSearchWrapper.TilesConfig convertTilesConfigToSearchDataWrapper(Tiles_Config__c tilesConfigObj, CollaborationGroup collaborationGroupRec){
		ExternalSearchWrapper.TilesConfig tileConfigObjToReturn = new ExternalSearchWrapper.TilesConfig();
		tileConfigObjToReturn.id = tilesConfigObj.Id;
		tileConfigObjToReturn.object_type = 'Tiles';
		tileConfigObjToReturn.createdbyid = tilesConfigObj.CreatedById;
		tileConfigObjToReturn.lastmodifiedbyid = tilesConfigObj.LastModifiedById;
		tileConfigObjToReturn.createddate = tilesConfigObj.CreatedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		tileConfigObjToReturn.lastmodifieddate = tilesConfigObj.LastModifiedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		tileConfigObjToReturn.is_deleted = tilesConfigObj.Is_Deleted__c;
		tileConfigObjToReturn.is_manager_driven = tilesConfigObj.Is_Manager_Driven__c;
		tileConfigObjToReturn.is_active = tilesConfigObj.Is_Active__c;
		tileConfigObjToReturn.is_newly_pushed = tilesConfigObj.Is_Newly_Pushed__c;
		tileConfigObjToReturn.tile_location = tilesConfigObj.Location__c;
		tileConfigObjToReturn.tile_type = tilesConfigObj.Type__c;
		tileConfigObjToReturn.tile_variant = tilesConfigObj.Variant__c;
		tileConfigObjToReturn.segment = tilesConfigObj.Segment__c;
		tileConfigObjToReturn.people_id = tilesConfigObj.People__c;
		tileConfigObjToReturn.site = tilesConfigObj.Site__c;
		if(tilesConfigObj.Site__c != null) {
			tileConfigObjToReturn.site_r_name = tilesConfigObj.Site__r.Name;
			tileConfigObjToReturn.site_r_chatter_group_id = tilesConfigObj.Site__r.Chatter_Group_Id__c;
			tileConfigObjToReturn.site_r_is_active = tilesConfigObj.Site__r.Is_Active__c;
			tileConfigObjToReturn.site_r_is_deleted = tilesConfigObj.Site__r.Is_Deleted__c;
			tileConfigObjToReturn.site_r_show_in_simpplr = tilesConfigObj.Site__r.Show_In_Simpplr__c;
			tileConfigObjToReturn.site_r_site_type = tilesConfigObj.Site__r.Site_Type__c;
			tileConfigObjToReturn.site_r_title_content_version = tilesConfigObj.Site__r.Title_Content_Version__c;
			tileConfigObjToReturn.site_r_landing_page = tilesConfigObj.Site__r.Landing_Page__c;
		}
		tileConfigObjToReturn.tile_title = String.isNotBlank(tilesConfigObj.Name__c) ? tilesConfigObj.Name__c : getTileTitle(tilesConfigObj.Type__c, tilesConfigObj.Variant__c);
		TileDataWrapper.TileDataSettings tiledataSettings = (TileDataWrapper.TileDataSettings)JSON.deserialize(tilesConfigObj.Data__c, TileDataWrapper.TileDataSettings.class);
		if(tiledataSettings.listOfItems != null) {
			tileConfigObjToReturn.tile_link_items = getTilesConfigLinks(tiledataSettings.listOfItems);
		}
		tileConfigObjToReturn.tile_description = tiledataSettings.code;
		if('site_info'.equalsIgnoreCase(tilesConfigObj.Type__c) && collaborationGroupRec != null) {
			tileConfigObjToReturn.tile_description = collaborationGroupRec.InformationBody;
			tileConfigObjToReturn.tile_title = String.isNotBlank(collaborationGroupRec.InformationTitle) ? collaborationGroupRec.InformationTitle : 'Information';
		}
		return tileConfigObjToReturn;
    }

	private String getTileTitle(String type, String variant) {
		String title = '';
		if('links'.equalsIgnoreCase(type)) {
			title = 'Links';

		} else if('html'.equalsIgnoreCase(type)) {
			title = 'iframe'.equalsIgnoreCase(variant) ? 'HTML' : 'Text';
		}
		return title;
	}

	private List<ExternalSearchWrapper.TilesLinkItem> getTilesConfigLinks(List<TileDataWrapper.TileData> listOfItems) {
		List<ExternalSearchWrapper.TilesLinkItem> itemsList = new List<ExternalSearchWrapper.TilesLinkItem>();
		if(listOfItems == null) {
			return null;
		}
		for(TileDataWrapper.TileData item : listOfItems) {
			ExternalSearchWrapper.TilesLinkItem data = new ExternalSearchWrapper.TilesLinkItem();
			data.link_url = item.url;
			data.link_text = item.text;
			itemsList.add(data);
		}
		return itemsList;
	}
    public ExternalSearchWrapper.MustReadAudit getSearchDataWrapperForMustReadContentConfig(String mustReadId){
        ExternalSearchWrapper.MustReadAudit mustReadAuditWrapperObj = null;
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1', mustReadId);
        String query = 'SELECT ' + String.join(getMustReadAuditFieldsForExternalData(),',') + 
                ' From Must_Read_Audit__c Where  id=:soqlParam1';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<Must_Read_Audit__c> mustReadAuditList = (List<Must_Read_Audit__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
        
        if(!mustReadAuditList.isEmpty() && mustReadAuditList[0].Removed_DateTime__c == null) {
            mustReadAuditWrapperObj = convertMustReadAuditToSearchDataWrapper(mustReadAuditList[0]);
        }

        return mustReadAuditWrapperObj;
    }
	
    public ExternalSearchWrapper.MustReadAudit convertMustReadAuditToSearchDataWrapper(Must_Read_Audit__c mustReadObj){
        ExternalSearchWrapper.MustReadAudit objectToIndex = new ExternalSearchWrapper.MustReadAudit();

        if (mustReadObj != null) {
            objectToIndex.id = mustReadObj.Id;
            objectToIndex.object_type = 'Must_Read';
            objectToIndex.content_id = mustReadObj.Content__c;
            objectToIndex.is_deleted = false;      
            objectToIndex.createddate = mustReadObj.createddate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            objectToIndex.lastmodifieddate = mustReadObj.LastModifiedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        }
        
        return objectToIndex;
    }

    
    public ExternalSearchWrapper.MustReadConfirmHistory getSearchDataWrapperForMustReadConfirmHistoryConfig(String mustReadConfirmHistoryId){
        ExternalSearchWrapper.MustReadConfirmHistory mustReadConfirmHistoryWrapperObj = null;
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1', mustReadConfirmHistoryId);
        String query = 'SELECT ' + String.join(getMustReadConfirmHistoryFieldsForExternalData(),',') + 
                ' From Must_Read_Confirm_History__c Where  id=:soqlParam1';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<Must_Read_Confirm_History__c> mustReadConfirmHistoryList = (List<Must_Read_Confirm_History__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
        
        if(!mustReadConfirmHistoryList.isEmpty()) {
            mustReadConfirmHistoryWrapperObj = convertMustReadConfirmHistoryToSearchDataWrapper(mustReadConfirmHistoryList[0]);
        } 

        return mustReadConfirmHistoryWrapperObj;
    }
	
    public ExternalSearchWrapper.MustReadConfirmHistory convertMustReadConfirmHistoryToSearchDataWrapper(Must_Read_Confirm_History__c mustReadConfirmHistoryObj){
        ExternalSearchWrapper.MustReadConfirmHistory objectToIndex = new ExternalSearchWrapper.MustReadConfirmHistory();

        if (mustReadConfirmHistoryObj != null) {
            objectToIndex.id = mustReadConfirmHistoryObj.Id;
            objectToIndex.object_type = 'Must_Read_Confirm_History';
            objectToIndex.content_id = mustReadConfirmHistoryObj.Content__c;
            objectToIndex.people_id = mustReadConfirmHistoryObj.People__c;
            objectToIndex.is_deleted = false;      
            objectToIndex.createddate = mustReadConfirmHistoryObj.createddate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            objectToIndex.lastmodifieddate = mustReadConfirmHistoryObj.LastModifiedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        }
        
        return objectToIndex;
    }

	/**
    * @description This method used to delete search trail records post data push to external service
    * @param trailRecordIds earch trail record ids
    **/
    public static void deleteSearchTrails(List<Id> trailRecordIds){
        List<External_Search_Data_Trail__c> listOfDataTrialObj = [SELECT Id FROM External_Search_Data_Trail__c WHERE Id IN :trailRecordIds WITH SECURITY_ENFORCED];

        if(listOfDataTrialObj != null && !listOfDataTrialObj.isEmpty()){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().deleteAsUser(listOfDataTrialObj);
        }
    }
}