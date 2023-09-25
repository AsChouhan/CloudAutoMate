public with sharing class BatchPushDataForExternalSearch implements Database.Batchable<SObject>, Database.stateful,Database.AllowsCallouts {
    private final String RECORD_TYPE_SITE = 'Site';
	private final String RECORD_TYPE_PEOPLE = 'People';
	private final String RECORD_TYPE_SIMPPLR_CONTENT = 'Content';
    private final String RECORD_TYPE_CONTENT_TEMPLATE = 'Content_Template'; // NOPMD - correct naming convension, suppressed codacy error
	private final String RECORD_TYPE_TILES_CONFIG = 'Tiles';
	
	private final String RECORD_TYPE_PAGES_CATEGORY = 'Pages_Category';
	private final String RECORD_TYPE_SITE_CATEGORY = 'Site_Category';
	private final String RECORD_TYPE_PEOPLE_CATEGORY = 'People_Category';
    private final String RECORD_TYPE_SITE_ROLE = 'Site_Role';
    private final String RECORD_TYPE_LINKS = 'Links';	
	private final String RECORD_TYPE_CONTENT_DOCUMENT = 'ContentDocument';
    private final String RECORD_TYPE_CONTENT_DOCUMENT_LINK = 'ContentDocumentLink';
    private final String RECORD_TYPE_FAILED_TRANSACTIONS = 'FailedTransactions';
    private final String RECORD_TYPE_EVENT_RSVP_RESPONSE = 'Event_RSVP_Response';
    private final String RECORD_TYPE_SITE_MEMBERSHIP_REQUEST = 'Site_Membership_Request';
    private final String RECORD_TYPE_EXPERTISE = 'Expertise';
    private final String RECORD_TYPE_ALERT = 'Alert';
    private final String RECORD_TYPE_TOPIC = 'Topic';
    private final String RECORD_TYPE_NEWSLETTER = 'Newsletter';
    private final String RECORD_TYPE_NATIVE_VIDEO = 'native_video';
    private final String RECORD_TYPE_MERGE_EXPERTISE = 'Merge_Expertise';
    private final String RECORD_TYPE_MERGE_TOPIC = 'Merge_Topic';
    
    private final String RECORD_TYPE_COLLABORATION_GROUP_MEMBERSHIP_REQUEST = 'CollaborationGroupMemberRequest';

	private String ENDPOINT_FOR_INITIAL_INDEX;
	
	private String recordType;
	private Boolean runNextBatchInSequence;
	private Exception exceptionDetailsObj;

	public BatchPushDataForExternalSearch(String recordType, Boolean runNextBatchInSequence){
        this.recordType = recordType;
		this.runNextBatchInSequence = runNextBatchInSequence;
	}
	
	public database.querylocator start(Database.BatchableContext bc) {
        String query;
        ENDPOINT_FOR_INITIAL_INDEX = SearchConstants.APIS_UPSERT;
		DateTime threeHoursAgoDateTime = DateTime.Now().addHours(-3);
        PushDataHelperForExternalSearch pushDataHelper = new PushDataHelperForExternalSearch();
        
        if (RECORD_TYPE_FAILED_TRANSACTIONS.equalsIgnoreCase(recordType)) {
			query = 'Select Id, Type__c, Site__c, Site_Role__c, People__c, Content__c, Content_Document__c, People_Category__c, Site_Category__c, Pages_Category__c, Tiles_Config__c, Segment__c, '
						+ ' Event_RSVP_Response__c, Site_Membership_Request__c, Alert__c, Mailer__c, Expertise__c, Topic__c, Merge_To__c, Merge_From__c, File__c, Content_Template__c FROM External_Search_Data_Trail__c';
			

		} else if (RECORD_TYPE_COLLABORATION_GROUP_MEMBERSHIP_REQUEST.equalsIgnoreCase(recordType)) {
            DateTime oneHourAgoDateTime = DateTime.Now().addHours(-1);
            query = 'SELECT id, CollaborationGroupId, RequesterId, Status,' +  
                    'LastModifiedDate FROM collaborationGroupMemberRequest ' + 
                    ' WHERE LastModifiedDate >=: oneHourAgoDateTime ';
        }

		return Database.getQueryLocator(query);
	}
	
	public void execute(Database.BatchableContext bc, sObject[] listOfsObject) {
        try {
            String jsonBody;

            if (RECORD_TYPE_FAILED_TRANSACTIONS.equalsIgnoreCase(recordType)) {
				List<External_Search_Data_Trail__c> listOfDataTrialObj = (List<External_Search_Data_Trail__c>) listOfsObject;
				sendFailedTransactionData(listOfDataTrialObj);

            } else if (RECORD_TYPE_COLLABORATION_GROUP_MEMBERSHIP_REQUEST.equalsIgnoreCase(recordType)) {
                List<collaborationGroupMemberRequest> listOfCollaborationGrpMemberReq = (List<collaborationGroupMemberRequest>) listOfsObject;
                
                if (!listOfCollaborationGrpMemberReq.isEmpty()) {
                    syncCollabGrpMemReqWithSiteMembershipReq(listOfCollaborationGrpMemberReq);
                }

            }
            
        } catch(Exception e) {
			exceptionDetailsObj =  e;
			throw e;
		}

    }
	
	public void finish(Database.BatchableContext bc){
        AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
        
        if (currentJob.Status != 'Completed' || currentJob.NumberOfErrors > 0) {
			runNextBatchInSequence = false;
			Utility.sendExceptionEmail('BatchPushDataForExternalSearch-' + recordType, exceptionDetailsObj);
        }
        
        if (RECORD_TYPE_COLLABORATION_GROUP_MEMBERSHIP_REQUEST.equalsIgnoreCase(recordType)) {
            Database.executebatch(new BatchPushDataForExternalSearch(RECORD_TYPE_FAILED_TRANSACTIONS,runNextBatchInSequence),50);
        }
        
    }

    private void syncCollabGrpMemReqWithSiteMembershipReq(List<collaborationGroupMemberRequest> listOfCollabGrpMemberReq) {
        Set<String> setOfCollabGrpMemberReqId = new Set<String>();
        Set<String> setOfUserId = new Set<String>();
        Set<String> setOfCollabGrpId = new Set<String>();

        for (collaborationGroupMemberRequest cGMRObj : listOfCollabGrpMemberReq) {
            setOfCollabGrpMemberReqId.add(cGMRObj.id); 
            setOfUserId.add(cGMRObj.RequesterId);
            setOfCollabGrpId.add(cGMRObj.CollaborationGroupId);

            if (cGMRObj.status == 'Accepted' ) {
                cGMRObj.status = 'Approved';

            } else if (cGMRObj.status == 'Declined') {
                cGMRObj.status = 'Rejected';
            }

        }
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1', setOfCollabGrpMemberReqId);
        String query = 'SELECT Id, Action_By__c, ' +
                ' Site__c, Site__r.Chatter_Group_Id__c, User__c, ' +
                ' CollaborationGroupMemberRequest_Id__c, Action_DateTime__c, Status__c ' +
                ' FROM Site_Membership_Request__c ' +
                ' WHERE Is_Deleted__c = false AND ' +
                ' CollaborationGroupMemberRequest_Id__c IN :soqlParam1';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<Site_Membership_Request__c> listOfSiteMemberShipRequest = (List<Site_Membership_Request__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);

        Map<String, Site_Membership_Request__c> mapOfReqIdWithSiteMemReqObj = new Map<String, Site_Membership_Request__c >();
        
        for (Site_Membership_Request__c siteMemberReqObj: listOfSiteMemberShipRequest) {
            mapOfReqIdWithSiteMemReqObj.put(siteMemberReqObj.CollaborationGroupMemberRequest_Id__c, siteMemberReqObj);
        }

        List<People__c> listOfPeople = [SELECT Id, User__c 
                FROM People__c
                WHERE user__c IN:setOfUserId];
        Map<String, String> mapOfUserIdToPeopleId = new Map<String, String>();

        for (People__c peopleObj: listOfPeople) {
            mapOfUserIdToPeopleId.put(peopleObj.user__c, peopleObj.id);
        }

        List<Simpplr_Site__c> listOfSite = [SELECT Id, Chatter_Group_Id__c 
                FROM Simpplr_Site__c
                WHERE Chatter_Group_Id__c IN:setOfCollabGrpId];
        Map<String, String> mapOfCollabGrpIdToSiteId = new Map<String, String>();

        for (Simpplr_Site__c siteObj: listOfSite) {
            mapOfCollabGrpIdToSiteId.put(siteObj.Chatter_Group_Id__c, siteObj.id);
        }

        List<Site_Membership_Request__c> listOfSiteMembershipReqToInsert = new List<Site_Membership_Request__c>();
        List<Site_Membership_Request__c> listOfSiteMembershipReqForUpdate = new List<Site_Membership_Request__c>();
        
        for (collaborationGroupMemberRequest cGMRObj: listOfCollabGrpMemberReq) {

            if (mapOfReqIdWithSiteMemReqObj.keyset().contains(cGMRObj.id)){
                Site_Membership_Request__c siteMemReqObjForUpdate = mapOfReqIdWithSiteMemReqObj.get(cGMRObj.id);
                
                if (cGMRObj.status != siteMemReqObjForUpdate.Status__c ) {
                    siteMemReqObjForUpdate.Status__c = cGMRObj.status;
                    listOfSiteMembershipReqForUpdate.add(siteMemReqObjForUpdate);
                    
                } 

            } else {
                Site_Membership_Request__c siteMemReqObjToInsert = new Site_Membership_Request__c();
                siteMemReqObjToInsert.Status__c = cGMRObj.status;
                siteMemReqObjToInsert.Request_By__c = mapOfUserIdToPeopleId.get(cGMRObj.RequesterId);
                siteMemReqObjToInsert.User__c = cGMRObj.RequesterId;
                siteMemReqObjToInsert.Site__c = mapOfCollabGrpIdToSiteId.get(cGMRObj.CollaborationGroupId);
                siteMemReqObjToInsert.Request_DateTime__c = DateTime.Now();
                siteMemReqObjToInsert.CollaborationGroupMemberRequest_Id__c = cGMRObj.id; 
                listOfSiteMembershipReqToInsert.add(siteMemReqObjToInsert);
            }
 
        }

        if (!listOfSiteMembershipReqForUpdate.isEmpty()) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, Site_Membership_Request__c>(
                    listOfSiteMembershipReqForUpdate), 
                    new List<Schema.SObjectField>{
                    Site_Membership_Request__c.Status__c
                    });
        }
        
        if (!listOfSiteMembershipReqToInsert.isEmpty()) {
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().insertAsUser(listOfSiteMembershipReqToInsert, 
                    new List<Schema.SObjectField>{
                    Site_Membership_Request__c.Status__c,
                    Site_Membership_Request__c.Request_By__c,
                    Site_Membership_Request__c.User__c,
                    Site_Membership_Request__c.Site__c,
                    Site_Membership_Request__c.Request_DateTime__c,
                    Site_Membership_Request__c.CollaborationGroupMemberRequest_Id__c
                    }); 
        }

    }

    private void sendFailedTransactionData(List<External_Search_Data_Trail__c> listOfDataTrialObj) {
		PushDataHelperForExternalSearch pushDataHelperObj = new PushDataHelperForExternalSearch();
    		List<External_Search_Data_Trail__c> listOfObjectToDelete = new List<External_Search_Data_Trail__c>();
    		String requestBody;
    		for (External_Search_Data_Trail__c trailObj : ListOfDataTrialObj) {
                Boolean isUpsertMany = false;
	    		if(RECORD_TYPE_SITE.equalsIgnoreCase(trailObj.Type__c)) {
	    			requestBody = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForSite(trailObj.Site__c));
			
				} else if(RECORD_TYPE_PEOPLE.equalsIgnoreCase(trailObj.Type__c)) {
					requestBody = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForPeople(trailObj.People__c));
			    	
		    	} else if(RECORD_TYPE_SIMPPLR_CONTENT.equalsIgnoreCase(trailObj.Type__c)){
		    		requestBody = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForSimpplrContent(trailObj.Content__c));
                
                } else if(RECORD_TYPE_CONTENT_TEMPLATE.equalsIgnoreCase(trailObj.Type__c)){
		    		requestBody = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForContentTemplate(trailObj.Content_Template__c));
		    	
		    	} else if(RECORD_TYPE_CONTENT_DOCUMENT.equalsIgnoreCase(trailObj.Type__c)){
		    		requestBody = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForContentDocument(trailObj.Content_Document__c));
		    	
		    	} else if(RECORD_TYPE_PEOPLE_CATEGORY.equalsIgnoreCase(trailObj.Type__c)){
	   				requestBody = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForPeopleCategory(trailObj.People_Category__c));
	   			
	   			} else if(RECORD_TYPE_SITE_CATEGORY.equalsIgnoreCase(trailObj.Type__c)){
		   			requestBody = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForSiteCategory(trailObj.Site_Category__c));
	   			
	   			} else if(RECORD_TYPE_PAGES_CATEGORY.equalsIgnoreCase(trailObj.Type__c)){
		   			requestBody = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForPagesCategory(trailObj.Pages_Category__c));
	   			
   				} else if(RECORD_TYPE_CONTENT_DOCUMENT_LINK.equalsIgnoreCase(trailObj.Type__c)){
		    		requestBody = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForContentDocument(trailObj.Content_Document__c));
		    	
   				} else if(RECORD_TYPE_LINKS.equalsIgnoreCase(trailObj.Type__c)){
		    		requestBody = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForLinks(trailObj.Segment__c));
                    isUpsertMany = true;
                } else if(RECORD_TYPE_SITE_ROLE.equalsIgnoreCase(trailObj.Type__c)){
                    ExternalSearchWrapper.SiteRole resp = pushDataHelperObj.getSearchDataWrapperForSiteRole(trailObj.Site_Role__c);
                    if(resp != null) {
                       requestBody = JSON.serialize(resp);
                    } else {
                        requestBody = null;
                    }

		    	} else if(RECORD_TYPE_TILES_CONFIG.equalsIgnoreCase(trailObj.Type__c)){
                    ExternalSearchWrapper.TilesConfig resp = pushDataHelperObj.getSearchDataWrapperForTilesConfig(trailObj.Tiles_Config__c);
                    if(resp != null) {
                       requestBody = JSON.serialize(resp);
                    } else {
                        requestBody = null;
                    }

                } else if(RECORD_TYPE_EVENT_RSVP_RESPONSE.equalsIgnoreCase(trailObj.Type__c)){
                    requestBody = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForEventRSVPResponse(trailObj.Event_RSVP_Response__c));
 
                } else if(RECORD_TYPE_SITE_MEMBERSHIP_REQUEST.equalsIgnoreCase(trailObj.Type__c)){
                    requestBody = JSON.serialize(pushDataHelperObj.getSearchDataWrapForSiteMembershipReq(trailObj.Site_Membership_Request__c));

                } else if(RECORD_TYPE_EXPERTISE.equalsIgnoreCase(trailObj.Type__c)){
                    requestBody = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForExpertise(trailObj.Expertise__c));

                } else if(RECORD_TYPE_ALERT.equalsIgnoreCase(trailObj.Type__c)){
                    requestBody = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForAlert(trailObj.Alert__c));

                } else if(RECORD_TYPE_TOPIC.equalsIgnoreCase(trailObj.Type__c)){
                    requestBody = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForTopic(trailObj.Topic__c));

                } else if(RECORD_TYPE_NEWSLETTER.equalsIgnoreCase(trailObj.Type__c)){
                    requestBody = JSON.serialize(pushDataHelperObj.getSearchDataWrapForNewsletter(trailObj.Mailer__c));

                } else if(RECORD_TYPE_NATIVE_VIDEO.equalsIgnoreCase(trailObj.Type__c)){
                    requestBody = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForNativeVideo(trailObj.File__c));

                } else if(RECORD_TYPE_MERGE_EXPERTISE.equalsIgnoreCase(trailObj.Type__c)){
                    requestBody = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForMergeExpertise(trailObj.Merge_To__c, trailObj.Merge_From__c));

                }else if(RECORD_TYPE_MERGE_TOPIC.equalsIgnoreCase(trailObj.Type__c)){
                    requestBody = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForMergeTopic(trailObj.Merge_To__c, trailObj.Merge_From__c));
                }
                if(String.isNotBLank(requestBody)) {
                    if(isUpsertMany && pushDataForInitialIndex(requestBody)) {
                        listOfObjectToDelete.add(trailObj);
                    } else if(pushFailedDataForIndex(requestBody, trailObj.Type__c)) {
                        listOfObjectToDelete.add(trailObj);
                    }
                } else {
                    listOfObjectToDelete.add(trailObj);
                }
    		}
            if(listOfObjectToDelete.size() > 0) {
                SIMPESAPI.accessController().setArrayOperationMode(SIMPSFDCAccessController.OperationMode.BEST_EFFORT);
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                SIMPESAPI.accessController().deleteAsUser(listOfObjectToDelete);
            }
    }  
    
    private Boolean pushDataForInitialIndex(String jsonBody) {
        String simpDri = Utility.externalRequestAuthToken() + 
                ' ' + SimpplrContext.simpplrOrgId.substring(0, 15) +
                ' ' + UserContext.userId.substring(0, 15);

        String reqBodyStr = '{"data":' + jsonBody + ', "base_url":"' + 
                SimpplrContext.getExternalSearchBaseUrl + '",'+ 
                ' "org_id":"' + SimpplrContext.simpplrOrgId + '", '+ 
                ' "request_path":"upsert_many", "instance_url":"' + 
                SimpplrContext.salesforceHost + '"}';

        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('simpplr-dri', simpDri);
        req.setMethod('POST');
        req.setBody(reqBodyStr);
		req.setEndpoint(SearchConstants.APIS_UPSERT);
		req.setTimeout(60000);
		Http http = new Http();
		HTTPResponse res = http.send(req);
		if(res.getStatusCode() !=200) {
			throw new SimpplrException(res.getStatusCode() + ' received, Response Body is ' + res.getBody());
		}
        return true;
	} 
	
	private Boolean pushFailedDataForIndex(String jsonBody, String trailObjectType) {
        Boolean success = false;
        String simpDri = Utility.externalRequestAuthToken() + 
                ' ' + SimpplrContext.simpplrOrgId.substring(0, 15) +
                ' ' + UserContext.userId.substring(0, 15);
        String skipFileDownloadStr = '';  
        
        if (RECORD_TYPE_CONTENT_DOCUMENT_LINK.equalsIgnoreCase(trailObjectType)) {
            skipFileDownloadStr = ',"skip_file_download":1';
        
        } else if (RECORD_TYPE_CONTENT_DOCUMENT.equalsIgnoreCase(trailObjectType)) {
            skipFileDownloadStr = ',"skip_file_download":0';
        }

        String reqBodyStr = '{"data":' + jsonBody + ', "base_url":"' + 
                SimpplrContext.getExternalSearchBaseUrl + '",'+ 
                ' "org_id":"' + SimpplrContext.simpplrOrgId + '", '+ 
                ' "request_path":"upsert", "instance_url":"' + 
                SimpplrContext.salesforceHost + '" ' + skipFileDownloadStr + '}';

        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('simpplr-dri', simpDri);
        req.setMethod('POST');
        req.setBody(reqBodyStr);
		req.setEndpoint(SearchConstants.APIS_UPSERT);
		req.setTimeout(60000);
		Http http = new Http();
		HTTPResponse res = http.send(req);
		return (res.getStatusCode() == 200);
	}
	
}