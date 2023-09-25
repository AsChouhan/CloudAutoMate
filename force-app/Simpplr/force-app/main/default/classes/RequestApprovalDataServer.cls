public with sharing class RequestApprovalDataServer extends DataServer {
    
	private static final String STATUS_WITHDRAWN = 'Cancelled';
    public static final String STATUS_APPROVED='Approved';
	public static final String STATUS_REJECTED='Rejected';
	public static final String STATUS_ACCEPTED='Accepted';
	public static final String STATUS_DECLINED='Declined';
	public static final String TYPE_INFORMATION='Information';
    
	private final String ACTION_VALUE_GET = 'Get'; 
    private final String ACTION_VALUE_APPROVE = 'Approve'; 
    private final String ACTION_VALUE_REJECT = 'Reject'; 
    
    private static final String REQUEST_PARAM_DATA = 'data';
    private static final String REQUEST_PARAM_TYPE = 'type';
    private static final String REQUEST_PARAM_REQUEST_ID = 'requestId';
    
    public RequestApprovalDataServer () {
    
    }
    
    public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
    public override void handleRequest () {
    	try {
	    	logger.logDebug('RequestApprovalDataServer----entered handleRequest----');
	    	
	    	String action = readParam(REQUEST_PARAM_ACTION);
        	
            if (String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
            }
            String requestId = readParam(REQUEST_PARAM_REQUEST_ID);
            String requestType = readParam(REQUEST_PARAM_TYPE);
            
            if (String.isBlank(requestId) || String.isBlank(requestType)) {
                throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
            }
            if (!'privateSiteAccess'.equalsIgnoreCase(requestType)) {
                throw new SimpplrException(ExceptionCode.INVALID_REQUEST_PARAM_VALUE.name());
            }
            
	    	ResponseWrapper responseWrapObj = new ResponseWrapper();
			
	    	App_Notification__c notificationObj = [Select Id, GUID__c, Sent_By__c, Object_Id__c, Simpplr_site__c, Simpplr_site__r.Name 
	    										FROM App_Notification__c WHERE Is_Deleted__c = false AND Object_Id__c =: requestId and Sent_To__c =: UserContext.peopleId WITH SECURITY_ENFORCED];
	    	//String notificationId = notificationObj.Id;
	    	String guId = notificationObj.GUID__c;
	    	String siteId = notificationObj.Simpplr_site__c;
	    	String siteName = notificationObj.Simpplr_site__r.Name;
	    	String requestorId = notificationObj.Sent_By__c;
	    	
	    	if (String.isBlank(requestId)) {
                throw new SimpplrException(ServiceConstants.ERROR_404);
            }
	    	if(ACTION_VALUE_GET.equalsIgnoreCase(action)) {
				response = getPrivateSiteMembershipRequest(requestId, siteId, requestorId);

	    	} else if (ACTION_VALUE_APPROVE.equalsIgnoreCase(action)) {
	    		response = approvePrivateSiteMembershipRequest(requestId, siteId, siteName);

	    	} else if (ACTION_VALUE_REJECT.equalsIgnoreCase(action))  {
	    		response =  rejectPrivateSiteMembershipRequest(requestId, siteId, siteName);
	    	}
	    } catch (Exception ex) {
        	logger.logError('Either no page access or action parameter returning wrong data',ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR,MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
	    
	    
    }
    private ResponseWrapper  getPrivateSiteMembershipRequest (String requestId, String siteId, String requestorId) {
		logger.logDebug('RequestApprovalDataServer.getPrivateSiteMembershipRequest()----siteId----'+requestorId);
		ResponseWrapper responseToReturn = null;
		try {
	    	List<CollaborationGroupMemberRequest> listOfCollGrpMemReq = [SELECT  Id,status, CollaborationGroupId, LastModifiedById 
																		FROM CollaborationGroupMemberRequest 
																		WHERE Id=:requestId WITH SECURITY_ENFORCED];
    		
			String status = '';
			if (listOfCollGrpMemReq.isEmpty()) {
				status = 'cancelled';		
				updateOrphanNotifications(requestId, STATUS_WITHDRAWN, null);

			} else if ('Pending'.equalsIgnoreCase(listOfCollGrpMemReq[0].status)){
				status = 'pending';				
			
			} else if(STATUS_ACCEPTED.equalsIgnoreCase(listOfCollGrpMemReq[0].status)){
				updateOrphanNotifications(requestId, STATUS_APPROVED, listOfCollGrpMemReq[0].LastModifiedById);
				status = 'approved';	

			} else {
				updateOrphanNotifications(requestId, STATUS_REJECTED, listOfCollGrpMemReq[0].LastModifiedById);
				status = 'rejected';	
			}
			Map<String, Object> response = new Map<String, Object>();
			SiteContentProvider provider = new SiteContentProvider();
			SiteDetailWrapper siteDetails = provider.getsiteDetailData(siteId, null);
			response.put('site', siteDetails);

			PeopleWrapper pwObj = new PeopleContentProvider().getUser(requestorId, false,false);
			response.put('user', pwObj);
			
			response.put('status', status);

			responseToReturn =  buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null , response);
		} catch(Exception e) {
			if(e.getMessage().containsIgnoreCase('You can only update pending requests')) {
        		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR,ServiceConstants.SITE_MEMBER_REQUEST_APPROVED_MESSAGE, null);
        	} else {
				responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR,MessageHelper.translateSFMessageToErrorCode(e), null);
			}
		}
        
        logger.logDebug('RequestApprovalDataServer.getPrivateSiteMembershipRequest()----responseToReturn----'+responseToReturn);
    	return responseToReturn;
	}

    public ResponseWrapper  approvePrivateSiteMembershipRequest (String requestId, String siteId, String siteName) {
    	logger.logDebug('RequestApprovalDataServer.approvePrivateSiteMembershipRequest()----requestId----'+requestId);
    	ResponseWrapper responseToReturn = null;
    	
    	try {
            List<CollaborationGroupMemberRequest> listOfCollGrpMemReq = [SELECT  Id, status, RequesterId FROM CollaborationGroupMemberRequest WHERE Id=:requestId WITH SECURITY_ENFORCED];
    		
			if (listOfCollGrpMemReq.isEmpty()) {
                throw new SimpplrException(ServiceConstants.ERROR_404);
                
			} else if ('Pending'.equalsIgnoreCase(listOfCollGrpMemReq[0].status)){
                List<Simpplr_Site__c> listOfSimpplrSite =  [SELECT Id, Chatter_Group_Id__c ,Site_Type__c,  
                        File_Storage_Source__c
                        FROM Simpplr_Site__c 
                        WHERE Id=:siteId WITH SECURITY_ENFORCED];

                if (!listOfSimpplrSite.isEmpty()) {	
                    String requestUserId = listOfCollGrpMemReq[0].RequesterId; 
                    String groupId = listOfSimpplrSite[0].Chatter_Group_Id__c;
        
                    if (listOfSimpplrSite[0].File_Storage_Source__c == 'googledrive' && SimpplrContext.googleManagedPermission != true) {
							Map<String, Object> soqlParamMap = new Map<String, Object>();
							soqlParamMap.put('soqlParam1', requestUserId);
							soqlParamMap.put('soqlParam2', ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING);
                        String queryStr = 'SELECT id, user_email__c,  '+
                                ' user__c'+
                                ' FROM People_Integration__c '+
                                ' WHERE user__c =:soqlParam1 AND '+
                                ' name=:soqlParam2';
						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
						List<People_Integration__c> listOfPeopleInteg = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
                        if (!listOfPeopleInteg.isEmpty()) {
                            String domainStr = SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING).Enterprise_Id__c;
                            String groupKey = groupId + GoogleDriveService.READ_SIMPPLR_MANAGED_GROUP_SUFFIX + domainStr;
                            String memberKey = listOfPeopleInteg[0].user_email__c;
                            String response = new GoogleDriveService().addMemberToGroup(groupKey, memberKey);
        
                        }
        
                    }

                }

				listOfCollGrpMemReq[0].status = STATUS_ACCEPTED;
				
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				logger.logDebug('RequestApprovalDataServer----approving private site membership request');
				SIMPESAPI.accessController().updateAsUser(
								listOfCollGrpMemReq[0],new List<Schema.SObjectField>{CollaborationGroupMemberRequest.status});
				
				List<Ungrouped_Notification__c> ungroupedNotiList = [SELECT GUID__c from Ungrouped_Notification__c WHERE Object_Id__c = :listOfCollGrpMemReq[0].id AND Is_Deleted__c = false WITH SECURITY_ENFORCED];
				if(ungroupedNotiList.isEmpty() == false){
					SiteService.updateSiteRequestNotifications(ungroupedNotiList[0].GUID__c, siteId, siteName, 'private', STATUS_APPROVED, 'Request approved by ' + UserContext.id);
					NotificationDispatcher.sendPrivateSiteRequestApprovalEmail(siteName, siteId, listOfCollGrpMemReq[0].RequesterId);
				} else {
					List<App_Notification__c> appNotiList = [SELECT GUID__c from App_Notification__c WHERE Object_Id__c = :listOfCollGrpMemReq[0].id WITH SECURITY_ENFORCED];
					if(appNotiList.isEmpty() == false && String.isNotBlank(appNotiList[0].GUID__c)){
						Map<String,App_Notification__c> userToNotificationMap = generatePrivateSiteRequestApprovedNotifications(appNotiList[0].GUID__c, siteId, siteName, 'Request approved by ' + UserContext.id);
						NotificationDispatcher.sendPrivateSiteRequestApprovalEmail(siteName, siteId, listOfCollGrpMemReq[0].RequesterId);
					}
				}
				responseToReturn =  buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Successfully approved the request!' , true);
			}else {
				throw new SimpplrException('Request is already ' + listOfCollGrpMemReq[0].status);
			}
		}
		catch(Exception e) {
			logger.logError('RequestApprovalDataServer.approvePrivateSiteMembershipRequest()----Exception occured---', e);
			if(e.getMessage().containsIgnoreCase('You can only update pending requests')) {
        		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR,ServiceConstants.SITE_MEMBER_REQUEST_APPROVED_MESSAGE, null);
        	} else {
				responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR,null, null);
			}
		}
        
        logger.logDebug('RequestApprovalDataServer.approvePrivateSiteMembershipRequest()----responseToReturn----'+responseToReturn);
    	return responseToReturn;
    }
    
    public ResponseWrapper  rejectPrivateSiteMembershipRequest (String requestId, String siteId, String siteName) { 
    	logger.logDebug('RequestApprovalDataServer.rejectPrivateSiteMembershipRequest()----requestId----'+requestId);
    	ResponseWrapper responseToReturn = null;
    	try {
	    	List<CollaborationGroupMemberRequest> listOfCollGrpMemReq = [SELECT  Id,status FROM CollaborationGroupMemberRequest WHERE Id=:requestId WITH SECURITY_ENFORCED];
	    			
			if (listOfCollGrpMemReq.isEmpty()) {
				throw new SimpplrException(ServiceConstants.ERROR_404);
			}
			else if ('Pending'.equalsIgnoreCase(listOfCollGrpMemReq[0].status)){
				listOfCollGrpMemReq[0].status = STATUS_DECLINED;
				
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				logger.logDebug('RequestApprovalDataServer----rejecting private site membership request');
				SIMPESAPI.accessController().updateAsUser(
								listOfCollGrpMemReq[0],new List<Schema.SObjectField>{CollaborationGroupMemberRequest.status});
				
				
				List<Ungrouped_Notification__c> ungroupedNotiList = [SELECT GUID__c from Ungrouped_Notification__c WHERE Object_Id__c = :listOfCollGrpMemReq[0].id AND Is_Deleted__c = false WITH SECURITY_ENFORCED];
				if(ungroupedNotiList.isEmpty() == false){
					SiteService.updateSiteRequestNotifications(ungroupedNotiList[0].GUID__c, siteId, siteName, 'private', STATUS_REJECTED, 'Request rejected by ' + UserContext.id);
				} else {
					List<App_Notification__c> appNotiList = [SELECT GUID__c from App_Notification__c WHERE Object_Id__c = :listOfCollGrpMemReq[0].id WITH SECURITY_ENFORCED];
					if(appNotiList.isEmpty() == false && String.isNotBlank(appNotiList[0].GUID__c)){
						generatePrivateSiteRequestRejectNotifications(appNotiList[0].GUID__C, siteId, siteName, 'Request rejected by ' + UserContext.id);
					}
				}
				responseToReturn =  buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Successfully rejected the request!' , true);
				
			} else {
				throw new SimpplrException('Request is already ' + listOfCollGrpMemReq[0].status);
			}
		}
		catch(Exception e) {
			
			if(e.getMessage().containsIgnoreCase('You can only update pending requests')) {
        		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR,ServiceConstants.SITE_MEMBER_REQUEST_APPROVED_MESSAGE, null);
        	} else {
				responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
			}
		} 
		
		logger.logDebug('RequestApprovalDataServer.rejectPrivateSiteMembershipRequest()----responseToReturn----'+responseToReturn);
    	return responseToReturn;
    }
    
    private Map<String,App_Notification__c> generatePrivateSiteRequestApprovedNotifications(String guId, String siteId, String siteName, String actionComment) {
		try {
			List<App_Notification__c> listOfSN = NotificationDao.prepareActionNotifications(guId, actionComment, STATUS_APPROVED);
			String parentId = ''; 
			String submitterId = '';
			String objType = '';
			String objId = '';
			for(App_Notification__c sn : listOfSN){
				parentId = sn.id;
				submitterId = sn.Sent_By__c;
				objType = sn.Object_Type__c;
				objId = sn.Object_Id__c;
			}
			
			App_Notification__c notificationObj = new App_Notification__c(Category__c='PrivateSiteMembership_Response',Is_Read__c=false,type__c=TYPE_INFORMATION, Sub_Type__c = 'Update',
				Status__c=STATUS_APPROVED,Object_Type__c=objType,Object_Id__c=objId,Sent_By__c=UserContext.peopleId, Simpplr_site__c = siteId,
				Sent_to__c=submitterId,Action_Comment__c=actionComment,	Action_By__c=UserContext.peopleId, Parent__c=parentId, Created_DateTime__c = DateTime.now(),
				Snippet__c = siteName);
			
			Map<String,App_Notification__c> userToNotificationMap = NotificationDao.createNotifications(new List<App_Notification__c>{notificationObj});
			
			List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{
				App_Notification__c.Is_Read__c,
				App_Notification__c.Is_New__c,
				App_Notification__c.Action_By__c,
				App_Notification__c.Action_On__c,
				App_Notification__c.Action_Comment__c,
				App_Notification__c.Status__c
			};

			NotificationDao.updateNotification(listOfSN, listOfColumnsToBeUpdated);
			return userToNotificationMap;
		}
		catch(Exception ex) {
			throw ex;
		}
	}
    
    private void generatePrivateSiteRequestRejectNotifications(String guId, String siteId, String siteName, String actionComment) {
		try {
			List<App_Notification__c> listOfSN = NotificationDao.prepareActionNotifications(guId, actionComment, STATUS_REJECTED);

			List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{
				App_Notification__c.Is_Read__c,
				App_Notification__c.Is_New__c,
				App_Notification__c.Action_By__c,
				App_Notification__c.Action_On__c,
				App_Notification__c.Action_Comment__c,
				App_Notification__c.Status__c
			};

			NotificationDao.updateNotification(listOfSN, listOfColumnsToBeUpdated);
		}
		catch(Exception ex) {
			throw ex;
		}
	}
	
	@TestVisible
	private void updateOrphanNotifications(String requestId, String status, String actionedByUserId) {
		List<App_Notification__c> notificationsList = [Select Id, Object_Id__c, Status__c, Sent_By__c
														FROM App_Notification__c WHERE Is_Deleted__c = false AND Object_Id__c =: requestId AND Status__c = 'Pending'
														AND Object_Type__c = 'CollaborationGroupMemberRequest' WITH SECURITY_ENFORCED];
		if(!notificationsList.isEmpty()) {
			UserDao userDaoObj = new UserDao();
			People__c peopleObj;
			
			if(String.isNotBlank(actionedByUserId))  {
				peopleObj = userDaoObj.getUserInfo(actionedByUserId);
			} 
			for(App_Notification__c notificationObj : notificationsList) {
				
				if('Pending'.equalsIgnoreCase(notificationObj.Status__c)) {
					if(STATUS_WITHDRAWN.equalsIgnoreCase(status)) {
						notificationObj.Action_By__c = notificationObj.Sent_By__c;
					
					} else if(STATUS_APPROVED.equalsIgnoreCase(status)) {
						notificationObj.Action_By__c = peopleObj.Id;
						
					} else if(STATUS_REJECTED.equalsIgnoreCase(status)) {
						notificationObj.Action_By__c = peopleObj.Id;
					}
					notificationObj.Status__c = status;
					notificationObj.Is_New__c = false;
				}
			}

			List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{
				App_Notification__c.Action_By__c,
				App_Notification__c.Is_New__c,
				App_Notification__c.Status__c
			};

			NotificationDao.updateNotification(notificationsList, listOfColumnsToBeUpdated);
		}
   		
   	}
    
}