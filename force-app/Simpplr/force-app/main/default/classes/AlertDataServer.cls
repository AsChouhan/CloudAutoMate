/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class AlertDataServer extends DataServer{ 
    
    private final String REQUEST_PARAM_DATA = 'data';
    
    private final String ACTION_VALUE_GET_ALERT = 'getAlert';
    private final String ACTION_VALUE_SEARCH_ALERT = 'searchAlert';
    private final String ACTION_VALUE_DISPLAY_NOW = 'displayNow';
    private final String ACTION_VALUE_CREATE = 'create';
    private final String ACTION_VALUE_UPDATE = 'update';
    private final String ACTION_VALUE_EXPIRE_NOW = 'expireNow';
    private final String ACTION_DELETE_ALERT = 'delete';
    private final String ACTION_VALUE_GET_ACTIVE_ALERT = 'getActive';
    private final String ACTION_VALUE_MARK_DISMISS = 'markAsDismissed';
    
    /**
     *
     */
    public AlertDataServer() {
        
    }
    
    public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public override void handleRequest() {
        try {
        	logger.logDebug('AlertDataServer----entered handleRequest----');

			String action = readParam(REQUEST_PARAM_ACTION);
        	String requestData = readParam(REQUEST_PARAM_DATA);
        	
            if(String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
            }
            if(ACTION_VALUE_UPDATE.equalsIgnoreCase(action)){
				if(String.isNotBlank(requestData)){
					AlertWrapper alertWrapperObj = (AlertWrapper)JSON.deserialize(requestData, AlertWrapper.class);
					if(AccessManager.hasAlertModerationAccess(alertWrapperObj.alertId) ==  false){
						throw new SimpplrException(ServiceConstants.ERROR_403);
					}
				} else {
					throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
				}
			} else if(ACTION_VALUE_EXPIRE_NOW.equalsIgnoreCase(action)) {
				if(String.isNotBlank(requestData)) {
					if(AccessManager.hasAlertModerationAccess(requestData) ==  false){
						throw new SimpplrException(ServiceConstants.ERROR_403);
					}
				} else {
					throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
				}

			} else if(ACTION_DELETE_ALERT.equalsIgnoreCase(action)) {
				if(String.isNotBlank(requestData)) {
					if(AccessManager.hasAlertModerationAccess(requestData) ==  false){
						throw new SimpplrException(ServiceConstants.ERROR_403);
					}
				} else {
					throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
				}
			}
			if(ACTION_VALUE_CREATE.equalsIgnoreCase(action)){
				if(String.isNotBlank(requestData)){
					AlertWrapper alertWrapperObj = (AlertWrapper)JSON.deserialize(requestData, AlertWrapper.class);
					if(AccessManager.hasAlertCreateAccess(alertWrapperObj.siteId) ==  false){
						throw new SimpplrException(ServiceConstants.ERROR_403);
					}
				} else {
					throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
				}
			}

			if(ACTION_VALUE_GET_ALERT.equalsIgnoreCase(action)) {
        		response = getAlert(requestData);
            }else if(ACTION_VALUE_SEARCH_ALERT.equalsIgnoreCase(action)){
            	response = searchAlert(requestData);
            }else if(ACTION_VALUE_DISPLAY_NOW.equalsIgnoreCase(action)){
            	response = displayNow(requestData);
            }else if(ACTION_VALUE_CREATE.equalsIgnoreCase(action)){
            	response = createAlert(requestData);
            }else if(ACTION_VALUE_UPDATE.equalsIgnoreCase(action)){
            	response = updateAlert(requestData);
            }else if(ACTION_VALUE_EXPIRE_NOW.equalsIgnoreCase(action)){
            	response = expireNow(requestData);
            }else if(ACTION_DELETE_ALERT.equalsIgnoreCase(action)){
            	response = deleteAlert(requestData);
            }else if(ACTION_VALUE_GET_ACTIVE_ALERT.equalsIgnoreCase(action)){
            	response = getActiveAlert();
            }else if(ACTION_VALUE_MARK_DISMISS.equalsIgnoreCase(action)){
            	response = markAsDismiss(requestData);
            }else {
                throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            }
            
        } catch (Exception ex) {
        	logger.logError('Either no page access or action parameter returning wrong data',ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR,MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        
    } 
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    @TestVisible  
    private  ResponseWrapper getAlert(String alertId) {
    	logger.logDebug('AlertDataServer.getAlert()--------'+alertId);
		ResponseWrapper responseToReturn;
    	try{
    		AlertWrapper alertWrapperObj = new AlertWrapper();
    		if(String.isNotBlank(alertId)){
				Map<String, Object> soqlParamMap = new  Map<String, Object>();
				soqlParamMap.put('soqlParam1', alertId);

	    		String query = 'SELECT id, Members_Type__c, Alert_Message__c, Alert_Url__c, Display_From_DateTime__c, Display_To_DateTime__c, Is_Active__c, Is_Dismissible__c, External_Apps_Config_Json__c, '
	    							+ ' Is_Expired__c, Is_Link_Alert__c, Is_Manually_Expired__c, Is_Scheduled__c, Recipient_Count__c, Seen_Count__c, CreatedDate, LastModifiedDate, ' 
	    							+ ' Author__c, Author__r.User__r.Id, Author__r.Skype_Id__c, Author__r.Zoom_Id__c, Author__r.Full_Name__c, Author__r.User__r.SmallPhotoUrl, ' 
	    							+ ' Recipient__c, Audience__c, Audience__r.Name__c, Audience__r.Is_Deleted__c, Audience__r.Audience_Member_Count__c, Audience__r.Segment__c, Audience__r.Segment__r.Name__c, Recipient_Site__c, Recipient_Site__r.name, '
	    							+ ' Recipient_Site__r.Chatter_Group_Id__c, Recipient_Site__r.Title_Content_Version__c, Recipient_Site__r.Landing_Page__c, Recipient_Site__r.Site_Type__c '
	    							+ ' FROM Alert__c WHERE id=:soqlParam1 AND Is_Deleted__c = false Limit 1';

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
				List<Alert__c> ListOfAlert = (List<Alert__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
		    	alertWrapperObj = objectToWrapper(ListOfAlert[0]);
    		}  
		    responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null , alertWrapperObj);
		    logger.logDebug('AlertDataServer.getAlert()----responseToReturn----'+responseToReturn);
	     } catch(Exception e) {
        	logger.logError('AlertDataServer.getAlert()----Could not fetch alert',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
    	return responseToReturn;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    @TestVisible  
    private Map<Id,Simpplr_Site__c> getListedSitesForAppManagerMap(){
    	String userId = UserContext.Id;
    	List<CollaborationGroupMember> memberList = [SELECT Id,CollaborationRole,CollaborationGroupId FROM CollaborationGroupMember 
    													WHERE memberId=:userId AND CollaborationRole = 'Admin' AND (CollaborationGroup.CollaborationType ='Private' OR CollaborationGroup.CollaborationType ='Unlisted') WITH SECURITY_ENFORCED];
		Set<Id> cgGrpIdSet = new Set<Id>();
    	for(CollaborationGroupMember cgMember :memberList){
    		cgGrpIdSet.add(cgMember.CollaborationGroupId);
		}
		String unlistedCondition ;
		if(UserContext.hasManageUnlistedSitePermission) {
    		unlistedCondition = 'Unlisted';
    	}
		Map<Id,Simpplr_Site__c> sitesForAppManagerWithAlertAccessMap = new Map<Id,Simpplr_Site__c>([SELECT id, Name,Site_Type__c, Chatter_Group_Id__c from Simpplr_Site__c 
											WHERE  Is_Deleted__c = false 
											AND (Site_Type__c = 'Public' OR Chatter_Group_Id__c IN: cgGrpIdSet OR Site_Type__c =: unlistedCondition) order by Name]);
		return sitesForAppManagerWithAlertAccessMap;
    }
    
    @TestVisible  
    private ResponseWrapper searchAlert(String requestData) {
    	logger.logDebug('AlertDataServer.searchAlert()--------'+requestData);
		ResponseWrapper responseToReturn;
    	try{
	    	Map<String,Object> result = New Map<String,Object>();
    		if(String.isNotBlank(requestData)){
    			List<AlertWrapper> alertWrapperList = new List<AlertWrapper>();
	    		Map<String,Object> paramData = (Map<String,Object>)JSON.deserializeUntyped(requestData);
	    		
	    		Map<Id,Simpplr_Site__c> siteMap = new Map<Id, Simpplr_Site__c>();
				if (UserContext.hasModifyAllDataPermission) {
					siteMap.putAll(Utility.getAllSimpplrSiteMap());
				} else if(UserContext.isUserAppModerator || UserContext.canSendAlerts){
					siteMap.putAll(getListedSitesForAppManagerMap());
				} else{
					siteMap.putAll(Utility.sitesIManageWithAlertAccessMap());
				}
				Set<Id> siteSet = new Set<Id>();
				if(siteMap.keySet() != null){
					for(String siteId : siteMap.keySet()){
						siteSet.add(siteId);
					}
				}
				List<Alert__c> alertList = new List<Alert__c>();
				String searchTerm = paramData.get('term')==null ? '':String.valueOf(paramData.get('term'));
				if(SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(searchTerm)) {
					Criteria.ExternalSearchReq alertCriteria = (Criteria.ExternalSearchReq)JSON.deserialize(requestData, Criteria.ExternalSearchReq.class);
					alertCriteria.siteSet = siteSet;
					ExternalSearchService externalSearchServiceObj = new ExternalSearchService();
					List<String> alertIdList = externalSearchServiceObj.searchAlert(alertCriteria);
					logger.logDebug('alertIdList====>'+alertIdList);
					alertList = getAlertListFromIdList(alertIdList);
					logger.logDebug('alertList====>'+alertList);
				} else{
					alertList = getAlertListFromQuery(paramData, siteMap.keySet());
				}

				for(Alert__c alertObj : alertList){
					alertWrapperList.add(objectToWrapper(alertObj));
				}
	    		List<siteWrapper> siteWrapperList = new List<siteWrapper>();
	    		
		        result.put('listOfItems',alertWrapperList);
	    		Integer nextPageToken = paramData.get('nextPageToken')!=null?(Integer)paramData.get('nextPageToken'):0;
	    		Integer size = paramData.get('size')!=null?(Integer)paramData.get('size'):0;
		        nextPageToken = alertWrapperList.size() < size ? null : nextPageToken + size;
		        result.put('nextPageToken',nextPageToken);
		        if(siteMap.size()>0){
					for(Simpplr_Site__c siteObj : siteMap.values()){
						siteWrapper siteWrapperObj = new siteWrapper();
						siteWrapperObj.id = siteObj.Id;
						siteWrapperObj.title = siteObj.Name;
						siteWrapperList.add(siteWrapperObj);
					}
				}
				Map<String,Object> siteFilterOptions = new Map<String,Object>(); 
				siteFilterOptions.put('sites',siteWrapperList);

			    result.put('filterOptions',siteFilterOptions);  
    		}
		    responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
		    logger.logDebug('AlertDataServer.searchAlert()----responseToReturn----'+responseToReturn);
	     } catch(Exception e) {
        	logger.logError('AlertDataServer.searchAlert()----Could not search alert',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
    	return responseToReturn;
    }
    
    @TestVisible  
    private List<Alert__c> getAlertListFromQuery(Map<String,Object> paramData, Set<Id> siteIdSet){
    	String queryString = '';
		String searchTerm = paramData.get('term')==null ? '':String.valueOf(paramData.get('term'));
		String filter = paramData.get('filter')==null ? '':String.valueOf(paramData.get('filter'));
		String recipient = paramData.get('recipient')==null ? '':String.valueOf(paramData.get('recipient'));
		String sortBy = paramData.get('sortBy')==null ? '':String.valueOf(paramData.get('sortBy'));
		Integer size = paramData.get('size') != NULL ? Integer.valueOf(paramData.get('size')) : 0; 
		Integer nextPageToken = paramData.get('nextPageToken') == null ? 0 : Integer.valueOf(paramData.get('nextPageToken'));
		
		String orderBy = '';		
		String order = '';
		
		if (!String.isblank(sortBy) ){
			if(sortBy.equalsIgnoreCase('createdNewest') || sortBy.equalsIgnoreCase('createdOldest')){
				orderBy = 'CreatedDate';
				order = sortBy.equalsIgnoreCase('createdNewest')? 'DESC' : 'ASC';
			}else if(sortBy.equalsIgnoreCase('displayToNewest') || sortBy.equalsIgnoreCase('displayToOldest')){
				orderBy = 'Display_To_DateTime__c';
				order = sortBy.equalsIgnoreCase('displayToNewest')? 'DESC' : 'ASC';
			} else if(sortBy.equalsIgnoreCase('displayFromNewest') || sortBy.equalsIgnoreCase('displayFromOldest')){
				orderBy = 'Display_From_DateTime__c';
				order = sortBy.equalsIgnoreCase('displayFromNewest')? 'DESC' : 'ASC';
			}
		} else {
			orderBy = 'CreatedDate';
			order = 'DESC';
		}
		
		List<Alert__c> alertList = getAlertList(filter,recipient,searchTerm,orderBy,order,size,nextPageToken, siteIdSet);
    	
    	return alertList;
    }
    
	@TestVisible  
    private List<Alert__c> getAlertListFromIdList(List<String> alertIdList){

		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', alertIdList);

		String query = 'SELECT id, Members_Type__c, Alert_Message__c, Alert_Url__c, Display_From_DateTime__c, Display_To_DateTime__c, Is_Active__c, Is_Dismissible__c, External_Apps_Config_Json__c, '
	    								+ ' Is_Expired__c, Is_Link_Alert__c, Is_Manually_Expired__c, Is_Scheduled__c, Recipient_Count__c, Seen_Count__c, CreatedDate, LastModifiedDate, '
	    								+ ' Author__c, Author__r.User__r.Id, Author__r.Full_Name__c, Author__r.Skype_Id__c, Author__r.Zoom_Id__c, Author__r.User__r.SmallPhotoUrl, '
	    								+ ' Recipient__c, Audience__c, Audience__r.Name__c, Audience__r.Is_Deleted__c, Audience__r.Audience_Member_Count__c, Audience__r.Segment__c, Audience__r.Segment__r.Name__c, Recipient_Site__c, Recipient_Site__r.name, '
	    								+ ' Recipient_Site__r.Chatter_Group_Id__c, Recipient_Site__r.Title_Content_Version__c, Recipient_Site__r.Landing_Page__c, Recipient_Site__r.Site_Type__c '
	    								+ ' FROM Alert__c WHERE Id IN: soqlParam1';
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Alert__c> alertList = (List<Alert__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
		logger.logDebug('AlertDataServer.getAlertListFromIdList()----alertList----'+alertList);
		return alertList;
	}

    @TestVisible  
    private List<Alert__c> getAlertList(String filter,String recipient,String searchText,String orderBy,String order,Integer recordLimit,Integer offsetVal, Set<Id> sitesIdSet){
		Id currentPeopleRecordId = UserContext.getCurrentUserInfo.Id;
		String subConditionString = '';
		String conditionStringForChildRecords = '';
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		
		String conditionString = ' Is_Deleted__c = false';
		if('everyone'.equalsIgnoreCase(filter)){
			
		}else if('active'.equalsIgnoreCase(filter)){
			conditionString += ' AND Is_Active__c = true ';
		}else if('scheduled'.equalsIgnoreCase(filter)){
			conditionString += ' AND Is_Scheduled__c = true ';
		}else if('expired'.equalsIgnoreCase(filter)){
			conditionString += ' AND Is_Expired__c = true';
		}
		if(UserContext.hasModifyAllDataPermission){
			if(String.isBlank(recipient) || 'any'.equalsIgnoreCase(recipient)){
				
			} else if('everyone'.equalsIgnoreCase(recipient)){
				conditionString += ' AND Recipient_Site__c = null AND Recipient__c = \'everyone\' ';	
			} else if(sitesIdSet.contains(recipient)){
				soqlParamMap.put('soqlParam1', recipient);
				conditionString += ' AND Recipient_Site__c =:soqlParam1';
			}
		} else if(UserContext.canSendAlerts || UserContext.isUserAppModerator){
			if(String.isBlank(recipient) || 'any'.equalsIgnoreCase(recipient)){
				soqlParamMap.put('soqlParam1', sitesIdSet);
				conditionString += ' AND (Recipient_Site__c = null OR Recipient_Site__c IN:soqlParam1)'; 
			} else if('everyone'.equalsIgnoreCase(recipient)){
				conditionString += ' AND Recipient_Site__c = null AND Recipient__c = \'everyone\' ';	
			} else if(sitesIdSet.contains(recipient)){
				soqlParamMap.put('soqlParam1', recipient);
				conditionString += ' AND Recipient_Site__c =:soqlParam1';
			}
		} else {
			if(String.isBlank(recipient) || 'any'.equalsIgnoreCase(recipient)){
				soqlParamMap.put('soqlParam1', sitesIdSet);
				conditionString += ' AND Recipient_Site__c IN:soqlParam1';
			} else if('everyone'.equalsIgnoreCase(recipient)){
				throw new SimpplrException('Invalid Filter');
			} else if(sitesIdSet.contains(recipient)){
				soqlParamMap.put('soqlParam1', recipient);
				conditionString += ' AND Recipient_Site__c =:soqlParam1';
			} 
		}
		
		if(String.isNotBlank(searchText)){
			searchText = '%' + searchText + '%';
			soqlParamMap.put('soqlParam2', searchText);
			conditionString += ' AND (Alert_Message__c Like:soqlParam2 OR Author__r.Name Like:soqlParam2) ';
		}
		
		conditionString = !conditionString.equals('')?' WHERE'+conditionString : '';
		if(String.isNotBlank(orderBy)){
			subConditionString+=' ORDER BY '+orderBy+' '+order;
		}
		
		if(recordLimit != null && recordLimit > 0){
			soqlParamMap.put('soqlParam3', recordLimit);
			subConditionString+=' LIMIT :soqlParam3';
		}
		if(offsetVal != null && offsetVal > 0){
			soqlParamMap.put('soqlParam4', offsetVal);
			subConditionString+=' OFFSET :soqlParam4';
		}
	
		
		String baseQuery = ' SELECT id, Members_Type__c, Alert_Message__c, Alert_Url__c, Display_From_DateTime__c, Display_To_DateTime__c, Is_Active__c, Is_Dismissible__c, External_Apps_Config_Json__c, '+
	    								 ' Is_Expired__c, Is_Link_Alert__c, Is_Manually_Expired__c, Is_Scheduled__c, Recipient_Count__c, Seen_Count__c, CreatedDate, LastModifiedDate, '+ 
	    								 ' Author__c, Author__r.User__r.Id, Author__r.Full_Name__c, Author__r.Skype_Id__c, Author__r.Zoom_Id__c, Author__r.User__r.SmallPhotoUrl, ' +
	    								 ' Recipient__c, Audience__c, Audience__r.Name__c, Audience__r.Is_Deleted__c, Audience__r.Audience_Member_Count__c, Audience__r.Segment__c, Audience__r.Segment__r.Name__c, Recipient_Site__c, Recipient_Site__r.name, '+
	    								 ' Recipient_Site__r.Chatter_Group_Id__c, Recipient_Site__r.Title_Content_Version__c, Recipient_Site__r.Landing_Page__c, Recipient_Site__r.Site_Type__c '+ 
	    								 ' FROM Alert__c';
		String alertQuery = baseQuery+conditionString+subConditionString;
		logger.logDebug('AlertDataServer.getAlertListFromCriteria()----query----'+alertQuery);	
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Alert__c> alertList = (List<Alert__c>)SIMPESAPI.accessController().queryAsUSer(alertQuery, soqlParamMap);	
        return alertList;
	}
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    @TestVisible  
    private  ResponseWrapper displayNow(String alertId) {
    	logger.logDebug('AlertDataServer.displayNow()--------'+alertId);
		ResponseWrapper responseToReturn;
    	try{
    		Alert__c alertObj;
    		AlertWrapper alertWrapObj = new AlertWrapper();
    		if(String.isNotBlank(alertId)){
				Map<String, Object> soqlParamMap = new  Map<String, Object>();
				List<Schema.SObjectField> listOfModifiedFields = new List<Schema.SObjectField>();
				soqlParamMap.put('soqlParam1', alertId);
				String query = 'SELECT id, Members_Type__c, Alert_Message__c, Alert_Url__c, Display_From_DateTime__c, Display_To_DateTime__c, Is_Active__c, Is_Dismissible__c, External_Apps_Config_Json__c, '
									+ ' Is_Expired__c, Is_Link_Alert__c, Is_Manually_Expired__c, Is_Scheduled__c, Recipient_Count__c, Seen_Count__c, CreatedDate, LastModifiedDate, '
									+ ' Author__c, Author__r.User__r.Id, Author__r.Full_Name__c, Author__r.Skype_Id__c, Author__r.Zoom_Id__c, Author__r.User__r.SmallPhotoUrl, ' 
									+ ' Recipient__c, Audience__c, Audience__r.Name__c, Audience__r.Is_Deleted__c, Audience__r.Audience_Member_Count__c, Audience__r.Segment__c, Audience__r.Segment__r.Name__c, Recipient_Site__c, Recipient_Site__r.name, '
									+ ' Recipient_Site__r.Chatter_Group_Id__c, Recipient_Site__r.Title_Content_Version__c, Recipient_Site__r.Landing_Page__c, Recipient_Site__r.Site_Type__c '
									+ ' from Alert__c Where id=:soqlParam1 AND Is_Scheduled__c = true AND Is_Expired__c=false AND Is_Deleted__c = false Limit 1 ';
					
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
				alertObj = ((List<Alert__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap))[0];
	    		alertObj.Display_From_DateTime__c = DateTime.now();
				listOfModifiedFields.add(Alert__c.Display_From_DateTime__c);
	    		DateTime displayToTime = (DateTime.now()).addHours(168);
	    		Integer minute = displayToTime.minute() - Math.Mod(displayToTime.minute(), 15);
	    		displayToTime = DateTime.newInstance(displayToTime.Year(), displayToTime.Month(), displayToTime.Day(), 
	    															   displayToTime.Hour(), minute, 0);
    			if(displayToTime < alertObj.Display_To_DateTime__c) {
					listOfModifiedFields.add(Alert__c.Display_To_DateTime__c);
					alertObj.Display_To_DateTime__c = displayToTime;
					
				}
				String msTenantQuery = 'select id, Microsoft_Teams_User_Id__c, Microsoft_Tenant_Id__c  from People__c where Microsoft_Tenant_Id__c != null LIMIT 1';
            	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
            	List<People__c> peopleList  = ((List<People__c>)SIMPESAPI.accessController().queryAsUSer(msTenantQuery, null));
				
				if (String.isNotBlank(alertObj.External_Apps_Config_Json__c) && !peopleList.isEmpty()) {
					AlertWrapper.ExternalAppsForAlert exAppDetail = (AlertWrapper.ExternalAppsForAlert)JSON.deserialize(alertObj.External_Apps_Config_Json__c, AlertWrapper.ExternalAppsForAlert.class);
					String simpUrl = SimpplrContext.salesforceBaseUrl + '/apex/' + SimpplrContext.namespacePrefix+ 'app';
					if (exAppDetail.isMSTeamsPostAlertAsChannel && String.isNotBlank(exAppDetail.msTeamsTeamId) && String.isNotBlank(exAppDetail.msTeamsChannelId)) {
						MicrosoftTeamsHelper.postAlertToChannelAsync(exAppDetail.msTeamsTeamId, exAppDetail.msTeamsChannelId,  simpUrl, alertObj.Alert_Message__c, peopleList[0].Microsoft_Tenant_Id__c, peopleList[0].Microsoft_Teams_User_Id__c);
					}
					if (exAppDetail.isMSTeamsPostAlertAsDM) {
						MicrosoftTeamsHelper.postAlertAsDMAsync(simpUrl, alertObj.Alert_Message__c, alertObj.Recipient__c, alertObj.Members_Type__c, alertObj.Recipient_Site__c, alertObj.Audience__c, peopleList[0].Microsoft_Tenant_Id__c);	
					}
				}
				BatchAlertNotifications job = new BatchAlertNotifications(alertId,alertObj.Display_From_DateTime__c,false);
				Database.executeBatch(job,500);
				SIMPESAPI.accessController().updateAsUser(alertObj, listOfModifiedFields);
	    		alertWrapObj = ObjectToWrapper(alertObj);
				alertWrapObj.status = 'active';
    		}  
		    responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, alertWrapObj);
		    logger.logDebug('AlertDataServer.displayNow()----responseToReturn----'+responseToReturn);
	     } catch(Exception e) {
        	logger.logError('AlertDataServer.displayNow()----Could not display alert',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
    	return responseToReturn;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    
    @TestVisible  
    private  ResponseWrapper createAlert(String requestData) {
		logger.logDebug('AlertDataServer.createAlert()--------'+requestData);
		ResponseWrapper responseToReturn;
    	try{
    		Alert__c alertObj;
			if(String.isNotBlank(requestData)){
				AlertWrapper alertWrapperObj = (AlertWrapper)JSON.deserialize(requestData, AlertWrapper.class);
				alertObj = wrapperToObject(null, alertWrapperObj);

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        		alertObj = (Alert__c)SIMPESAPI.accessController().insertAsUser(alertObj, new List<Schema.SObjectField> {
																		Alert__c.Alert_Message__c,
																		Alert__c.Alert_Url__c,
																		Alert__c.Author__c,
																		Alert__c.Display_From_DateTime__c,
																		Alert__c.Display_To_DateTime__c,
																		Alert__c.Is_Dismissible__c,
																		Alert__c.Is_Link_Alert__c,
																		Alert__c.Members_Type__c,
																		Alert__c.Recipient__c,
																		Alert__c.Recipient_Count__c,									             
																		Alert__c.Recipient_Site__c,
																		Alert__c.Audience__c,
																		Alert__c.External_Apps_Config_Json__c
																	});

				if(alertObj.Display_From_DateTime__c < DateTime.now() || 'immediately'.equalsIgnoreCase(alertWrapperObj.durationStart)) {
					//posting alert to MS teams
					String msTenantQuery = 'select id, Microsoft_Teams_User_Id__c, Microsoft_Tenant_Id__c  from People__c where Microsoft_Tenant_Id__c != null LIMIT 1';
            		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
            		List<People__c> peopleList  = ((List<People__c>)SIMPESAPI.accessController().queryAsUSer(msTenantQuery, null));
					
					if (String.isNotBlank(alertObj.External_Apps_Config_Json__c) && !peopleList.isEmpty()) {
						AlertWrapper.ExternalAppsForAlert exAppDetail = (AlertWrapper.ExternalAppsForAlert)JSON.deserialize(alertObj.External_Apps_Config_Json__c, AlertWrapper.ExternalAppsForAlert.class);
						String simpUrl = SimpplrContext.salesforceBaseUrl + '/apex/' + SimpplrContext.namespacePrefix+ 'app';
						if (exAppDetail.isMSTeamsPostAlertAsChannel && String.isNotBlank(exAppDetail.msTeamsTeamId) && String.isNotBlank(exAppDetail.msTeamsChannelId)) {
							MicrosoftTeamsHelper.postAlertToChannelAsync(exAppDetail.msTeamsTeamId, exAppDetail.msTeamsChannelId,  simpUrl, alertObj.Alert_Message__c, peopleList[0].Microsoft_Tenant_Id__c, peopleList[0].Microsoft_Teams_User_Id__c);
						}
						if (exAppDetail.isMSTeamsPostAlertAsDM) {
							MicrosoftTeamsHelper.postAlertAsDMAsync(simpUrl, alertObj.Alert_Message__c, alertObj.Recipient__c, alertObj.Members_Type__c, alertObj.Recipient_Site__c, alertObj.Audience__c, peopleList[0].Microsoft_Tenant_Id__c);	
						}
					}
					BatchAlertNotifications job = new BatchAlertNotifications(alertObj.Id, alertObj.Display_From_DateTime__c, false);
					Database.executeBatch(job,500);
				}
    		}
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, alertObj);
			logger.logDebug('AlertDataServer.createAlert()----responseToReturn----'+responseToReturn);
	     } catch(Exception e) {
        	logger.logError('AlertDataServer.createAlert()----Could not create alert',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
    	return responseToReturn;
    }

	
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    
    @TestVisible  
    private  ResponseWrapper updateAlert(String requestData) {
    	logger.logDebug('AlertDataServer.updateAlert()--------'+requestData);
		ResponseWrapper responseToReturn;
    	try{
    		Alert__c alertObj;
    		if(String.isNotBlank(requestData)){
    			AlertWrapper alertWrapperObj = (AlertWrapper)JSON.deserialize(requestData, AlertWrapper.class);
	    		alertObj = wrapperToObject(alertWrapperObj.alertId,alertWrapperObj.itemData);
				Map<String, Object> soqlParamMap = new  Map<String, Object>();
				soqlParamMap.put('soqlParam1', alertObj.id);
    			String query  = 'SELECT id, Is_Active__c, External_Apps_Config_Json__c FROM Alert__c WHERE id=:soqlParam1 AND Is_Expired__c = false AND Is_Deleted__c = false Limit 1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
				List<Alert__c> savedAlertObj = (List<Alert__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
				//sending active alert to MS Teams
				String msTenantQuery = 'select id, Microsoft_Teams_User_Id__c, Microsoft_Tenant_Id__c  from People__c where Microsoft_Tenant_Id__c != null LIMIT 1';
            	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
            	List<People__c> peopleList  = ((List<People__c>)SIMPESAPI.accessController().queryAsUSer(msTenantQuery, null));
				if (savedAlertObj[0].Is_Active__c && String.isNotBlank(savedAlertObj[0].External_Apps_Config_Json__c) && !peopleList.isEmpty()) {
					AlertWrapper.ExternalAppsForAlert exAppDetail = (AlertWrapper.ExternalAppsForAlert)JSON.deserialize(savedAlertObj[0].External_Apps_Config_Json__c, AlertWrapper.ExternalAppsForAlert.class);
					String simpUrl = SimpplrContext.salesforceBaseUrl + '/apex/' + SimpplrContext.namespacePrefix+ 'app';
					if (exAppDetail.isMSTeamsPostAlertAsChannel && String.isNotBlank(exAppDetail.msTeamsTeamId) && String.isNotBlank(exAppDetail.msTeamsChannelId)) {
						MicrosoftTeamsHelper.postAlertToChannelAsync(exAppDetail.msTeamsTeamId, exAppDetail.msTeamsChannelId,  simpUrl, alertObj.Alert_Message__c, peopleList[0].Microsoft_Tenant_Id__c, peopleList[0].Microsoft_Teams_User_Id__c);
					}
					if (exAppDetail.isMSTeamsPostAlertAsDM) {
						MicrosoftTeamsHelper.postAlertAsDMAsync(simpUrl, alertObj.Alert_Message__c, alertObj.Recipient__c, alertObj.Members_Type__c, alertObj.Recipient_Site__c, alertObj.Audience__c, peopleList[0].Microsoft_Tenant_Id__c);	
					}
				}
	    		BatchUpdateAlertAnalytics batchAlertUpdate = new BatchUpdateAlertAnalytics('ResetMarkAsDismiss', alertObj.id, null);
	    		Database.executeBatch(batchAlertUpdate,2000);
    		}  
		    responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, alertObj);
		    logger.logDebug('AlertDataServer.updateAlert()----responseToReturn----'+responseToReturn);
	     } catch(Exception e) {
        	logger.logError('AlertDataServer.updateAlert()----Could not update alert',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
    	return responseToReturn;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    
    @TestVisible  
    private  ResponseWrapper expireNow(String alertId) {
    	logger.logDebug('AlertDataServer.expireNow()--------'+alertId);
		ResponseWrapper responseToReturn;
    	try{ 
    		Alert__c alertObj;
    		if(String.isNotBlank(alertId)){	
				Map<String, Object> soqlParamMap = new  Map<String, Object>();
				soqlParamMap.put('soqlParam1', alertId);
    			String query = 'select id, Members_type__c, Alert_Message__c, Alert_Url__c, Display_From_DateTime__c, Display_To_DateTime__c, Is_Active__c, Is_Dismissible__c, External_Apps_Config_Json__c, '
								+ ' Is_Expired__c, Is_Link_Alert__c, Is_Manually_Expired__c, Is_Scheduled__c, Recipient_Count__c, Seen_Count__c, CreatedDate, LastModifiedDate, ' 
								+ ' Author__c, Author__r.User__r.Id, Author__r.Full_Name__c, Author__r.Skype_Id__c, Author__r.Zoom_Id__c, Author__r.User__r.SmallPhotoUrl, '
								+ ' Recipient__c, Audience__c, Audience__r.Name__c, Audience__r.Is_Deleted__c, Audience__r.Audience_Member_Count__c, Audience__r.Segment__c, Audience__r.Segment__r.Name__c, Recipient_Site__c, Recipient_Site__r.name, '
								+ ' Recipient_Site__r.Chatter_Group_Id__c, Recipient_Site__r.Title_Content_Version__c, Recipient_Site__r.Landing_Page__c, Recipient_Site__r.Site_Type__c ' 
								+ ' from Alert__c Where id=:soqlParam1 AND Is_Deleted__c = false Limit 1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
				alertObj = ((List<Alert__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap))[0];
				alertObj.Is_Manually_Expired__c = true;
        		SIMPESAPI.accessController().updateAsUser(alertObj, new List<Schema.SObjectField>{
        			Alert__c.Is_Manually_Expired__c});
    		} 
		    responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, objectToWrapper(alertObj));
		    logger.logDebug('AlertDataServer.expireNow()----responseToReturn----'+responseToReturn);
	     } catch(Exception e) {
        	logger.logError('AlertDataServer.expireNow()----Could not expire alert',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
    	return responseToReturn;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    
    @TestVisible  
    private  ResponseWrapper deleteAlert(String alertId) {
    	logger.logDebug('AlertDataServer.deleteAlert()--------'+alertId);
		ResponseWrapper responseToReturn;
    	try{ 
    		Alert__c alertObj;
    		if(String.isNotBlank(alertId)){	
				Map<String, Object> soqlParamMap = new  Map<String, Object>();
				soqlParamMap.put('soqlParam1', alertId);
    			String query = 'select id from Alert__c Where id=:soqlParam1 AND Is_Deleted__c = false AND Is_Scheduled__c=true Limit 1';			
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
				alertObj = ((List<Alert__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap))[0];
				alertObj.Is_Deleted__c = true;
        		SIMPESAPI.accessController().updateAsUser(alertObj, new List<Schema.SObjectField>{
        			Alert__c.Is_Deleted__c});
    		} 
		    responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, alertObj);
		    logger.logDebug('AlertDataServer.expireNow()----responseToReturn----'+responseToReturn);
	     } catch(Exception e) {
        	logger.logError('AlertDataServer.deleteAlert()----Could not delete alert',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
    	return responseToReturn;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    
    public  ResponseWrapper getActiveAlert() {
    	logger.logDebug('AlertDataServer.getActiveAlert()--------');
		ResponseWrapper responseToReturn;
    	List<AlertWrapper> alertWrapperList = new List<AlertWrapper>();
    	try{
    		Map<String,Object> result = New Map<String,Object>();
			Set<Id> alertIdSet = new Set<Id>();
			if(SimpplrContext.isFeatureEnabled('Alerts')) {
				Map<Id,Simpplr_Site__c> sitesIfollowMap = UserContext.sitesIFollowMap;
				Map<Id,Audience__c> audiencesIAmMemberOfMap = UserContext.audiencesIAmMemberOfMap;		
				Map<String, Object> soqlParamMap = new  Map<String, Object>();
				soqlParamMap.put('soqlParam1', UserContext.PeopleId);
				soqlParamMap.put('soqlParam2', audiencesIAmMemberOfMap.keySet());
				soqlParamMap.put('soqlParam3', sitesIfollowMap.keySet());
				String query = 'SELECT id, Members_type__c, Alert_Message__c, Alert_Url__c, Display_From_DateTime__c, Display_To_DateTime__c, Is_Active__c, Is_Dismissible__c, External_Apps_Config_Json__c, '
									+ ' Is_Expired__c, Is_Link_Alert__c, Is_Manually_Expired__c, Is_Scheduled__c, Recipient_Count__c, Seen_Count__c, CreatedDate, LastModifiedDate, ' 
									+ ' Author__c, Author__r.User__r.Id, Author__r.Full_Name__c, Author__r.Skype_Id__c, Author__r.Zoom_Id__c, Author__r.User__r.SmallPhotoUrl, '  
									+ ' Recipient__c, Audience__c, Audience__r.Name__c, Audience__r.Is_Deleted__c, Audience__r.Audience_Member_Count__c, Audience__r.Segment__c, Audience__r.Segment__r.Name__c, Recipient_Site__c, Recipient_Site__r.name, '
									+ ' Recipient_Site__r.Chatter_Group_Id__c, Recipient_Site__r.Title_Content_Version__c, Recipient_Site__r.Landing_Page__c, Recipient_Site__r.Site_Type__c, '
									+ ' (SELECT Alert__r.id FROM Analytics_Alerts__r WHERE People__c=:soqlParam1 AND (Is_Marked_Dismissed__c = true OR Is_Deleted__c =true)) '
									+ ' FROM Alert__c ' 
									+ ' WHERE Is_Deleted__c = false AND Is_Active__c=true AND ((Recipient_Site__c = null AND Audience__c IN :soqlParam2) OR (Audience__c = null AND Recipient_Site__c IN :soqlParam3)) order by Display_From_DateTime__c Desc';
									
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
				List<Alert__c> alertObjList = (List<Alert__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);	
				Map<String, Boolean> siteIdSiteRoleMap = new Map<String, Boolean>();
				for (Site_Role__c siteRole: [Select id, site__c, is_Member__c, people__c, Is_Deleted__c from Site_Role__c where Is_Deleted__c=false and people__c =: UserContext.PeopleId and site__c in: sitesIfollowMap.keyset() WITH SECURITY_ENFORCED ]) {
					siteIdSiteRoleMap.put(siteRole.site__c, siteRole.is_Member__c);
				}
				for(Alert__c alertObj : alertObjList){
					if(alertObj.Analytics_Alerts__r.isEmpty()){
						if (alertObj.Recipient_Site__c!=null){
							if (alertObj.Members_type__c == 'site_members'){
								if (siteIdSiteRoleMap.containskey(alertObj.Recipient_Site__c) && siteIdSiteRoleMap.get(alertObj.Recipient_Site__c)){
									alertWrapperList.add(objectToWrapper(alertObj));
									alertIdSet.add(alertObj.id);
								}
							} else {
								alertWrapperList.add(objectToWrapper(alertObj));
								alertIdSet.add(alertObj.id);
							}
						} else {
							alertWrapperList.add(objectToWrapper(alertObj));
							alertIdSet.add(alertObj.id);
						}
					}
				}
			}
			logger.logDebug('AlertDataServer.getActiveAlert()----alertWrapperList----'+alertWrapperList.size());
			result.put('listOfItems',alertWrapperList);
		    responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
		    logger.logDebug('AlertDataServer.getActiveAlert()----responseToReturn----'+responseToReturn);
		    if(alertIdSet.isEmpty() == false){
		    	markAsSeen(alertIdSet, UserContext.peopleId);
		    }
	     } catch(Exception e) {
        	logger.logError('AlertDataServer.getActiveAlert()----Could not fetch active alert',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
    	return responseToReturn;
    }
    
    @TestVisible  
    private static void markAsSeen(Set<Id> alertIdSet, String peopleId){
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', alertIdSet);
		soqlParamMap.put('soqlParam2', peopleId);
		String anlytcsMailerQuery = 'SELECT id, Alert__c from Analytics_Alert__c WHERE Alert__c IN:soqlParam1 AND People__c=:soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Analytics_Alert__c> alertAnalyticsValidationList = (List<Analytics_Alert__c>)SIMPESAPI.accessController().queryAsUser(anlytcsMailerQuery, soqlParamMap);
    	for(Analytics_Alert__c alertAnlObj : alertAnalyticsValidationList){
    		if(alertIdSet.contains(alertAnlObj.Alert__c)){
    			alertIdSet.remove(alertAnlObj.Alert__c);
    		}
    	}
    	List<Analytics_Alert__c> alertAnalyticsList = new List<Analytics_Alert__c>();
    	for(Id alertId: alertIdSet){
    		Analytics_Alert__c alerAnalObj = new Analytics_Alert__c();
    		alerAnalObj.Alert__c = alertId;
    		alerAnalObj.People__c = peopleId;
    		alertAnalyticsList.add(alerAnalObj);
    	}
    	if(!alertAnalyticsList.isEmpty()){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
        	SIMPESAPI.accessController().insertAsUser(alertAnalyticsList,new List<Schema.SObjectField>{Analytics_Alert__c.Alert__c,
				Analytics_Alert__c.People__c});
    	}
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    @TestVisible  
    private  ResponseWrapper markAsDismiss(String alertId) {
    	logger.logDebug('AlertDataServer.markAsDismiss()--------'+alertId);
		ResponseWrapper responseToReturn;
    	try{
    		String loggedInPeopleId = UserContext.peopleId;
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', alertId);
			soqlParamMap.put('soqlParam2', loggedInPeopleId);
			String anlytcsMailerQuery = 'SELECT id, Is_Marked_Dismissed__c FROM Analytics_Alert__c WHERE  Alert__c =:soqlParam1 AND People__c=:soqlParam2  AND Is_Marked_Dismissed__c = false AND Alert__r.Is_Dismissible__c = true AND Is_Deleted__c=false';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Analytics_Alert__c> alertAnalyticsList = (List<Analytics_Alert__c>)SIMPESAPI.accessController().queryAsUser(anlytcsMailerQuery, soqlParamMap);
	    	if(!alertAnalyticsList.isEmpty()){
		    	for(Analytics_Alert__c alertAnalObj: alertAnalyticsList){
		    		alertAnalObj.Is_Marked_Dismissed__c = true;
		    	}
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<Id,Analytics_Alert__c>(alertAnalyticsList), new List<Schema.SObjectField>{
					Analytics_Alert__c.Is_Marked_Dismissed__c
				});
	    	}  
		    responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, alertAnalyticsList);
		    logger.logDebug('AlertDataServer.markAsDismiss()----responseToReturn----'+responseToReturn);
	     } catch(Exception e) {
        	logger.logError('AlertDataServer.markAsDismiss()----Could not mark alert as dismiss',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
    	return responseToReturn;
    }
    
    @TestVisible  
    private Alert__c wrapperToObject(String alertId, AlertWrapper alertWrapperObj){
    	Alert__c alertObj = new Alert__c();
		List<Schema.SObjectField> listOfModifiedFields = new List<Schema.SObjectField>();
    	if(String.isNotBlank(alertWrapperObj.alertId)){
    		alertObj.id = alertWrapperObj.alertId;
    	} else if(String.isNotBlank(alertId)){
    		alertObj.id = alertId;
		}
		alertObj.Members_Type__c = alertWrapperObj.membersType;
    	alertObj.Alert_Message__c = alertWrapperObj.message;
    	alertObj.Alert_Url__c = alertWrapperObj.url;
    	alertObj.Author__c = UserContext.peopleId;
		listOfModifiedFields.add(Alert__c.Alert_Message__c);
		listOfModifiedFields.add(Alert__c.Alert_Url__c);
    	if(String.isNotBlank(alertWrapperObj.displayFrom)) {
    		alertObj.Display_From_DateTime__c = Utility.momentJSDateTimeStringToDateTime(alertWrapperObj.displayFrom);
    	} else {
    		alertObj.Display_From_DateTime__c = DateTime.now();
    	}
		listOfModifiedFields.add(Alert__c.Display_From_DateTime__c);
		if(String.isNotBlank(alertWrapperObj.displayTo)) {
    		alertObj.Display_To_DateTime__c = Utility.momentJSDateTimeStringToDateTime(alertWrapperObj.displayTo);
			listOfModifiedFields.add(Alert__c.Display_To_DateTime__c);
		} else {
			alertObj.Display_To_DateTime__c = null;
		}

    	alertObj.Is_Dismissible__c = alertWrapperObj.isDismissible;
    	alertObj.Is_Link_Alert__c = alertWrapperObj.hasUrl;
		alertObj.Recipient__c = alertWrapperObj.recipient;
		listOfModifiedFields.add(Alert__c.Is_Dismissible__c);
		listOfModifiedFields.add(Alert__c.Is_Link_Alert__c);

		if (alertWrapperObj.externalDistribution != null) {
			alertObj.External_Apps_Config_Json__c = JSON.serialize(alertWrapperObj.externalDistribution);
			if(String.isNotBlank(alertId)) {
				listOfModifiedFields.add(Alert__c.External_Apps_Config_Json__c);
			}
		}
		alertObj.Recipient_Site__c = null;
		alertObj.Audience__c = null;

    	if(String.IsNotBlank(alertWrapperObj.siteId)){
			Set<String> receiptantCount = new Set<String>();
			if (alertObj.Members_Type__c =='site_members'){
				
				for (Site_Role__c siteRole: [Select id, site__c, people__c, is_Member__c from Site_Role__c where Is_Deleted__c= false and site__c=:alertWrapperObj.siteId and is_Member__c = true AND (People__r.User__r.Show_Simpplr__c ='Yes' OR (People__r.user__r.Show_Simpplr__c != 'No' AND People__r.user__r.isActive=true AND People__r.user__r.UserType='Standard')) WITH SECURITY_ENFORCED ]) {
					if (!receiptantCount.contains(siteRole.people__c)){
						receiptantCount.add(siteRole.people__c);
					}
				}
				alertObj.Recipient_Count__c = receiptantCount.size();
			} else {
				Simpplr_Site__c siteObj =[select Chatter_Group_Id__c from Simpplr_Site__c Where id=:alertWrapperObj.siteId WITH SECURITY_ENFORCED LIMIT 1];
	    		alertObj.Recipient_Count__c = [select memberCount from CollaborationGroup Where id=:siteObj.Chatter_Group_Id__c].memberCount;
			}
	    	
			alertObj.Recipient_Site__c = alertWrapperObj.siteId;
    	} else {
			if('audience'.equalsIgnoreCase(alertWrapperObj.recipient)) {
				alertObj.Audience__c = alertWrapperObj.audience.audienceId;
				alertObj.Recipient_Count__c = alertWrapperObj.audience.audienceCount;
			} else if('segment'.equalsIgnoreCase(alertWrapperObj.recipient)) {
				AudienceService audServiceObj = new AudienceService();
				Audience__c audienceObj = audServiceObj.getSegmentDefaultAudience(alertWrapperObj.segmentId);
				alertObj.Audience__c = audienceObj.Id;
				alertObj.Recipient_Count__c = audienceObj.Audience_Member_Count__c;
			} else {
				String query = 'select id from Audience__c where name__c=\'Everyone\' AND Is_Deleted__c = false AND Is_Hidden__c = true';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<Audience__c> audienceList = (List<Audience__c>)SIMPESAPI.accessController().queryAsUser(query, null);
				if(!audienceList.isEmpty()) {
					alertObj.Audience__c = audienceList[0].Id;
				}
    			alertObj.Recipient_Count__c = Utility.getTotalPeopleInSimpplr();
			}
    	}
		if(String.isNotBlank(alertId)) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			SIMPESAPI.accessController().updateAsUser(alertObj,listOfModifiedFields);
		}
    	return alertObj;
    }
    
    @TestVisible  
    private AlertWrapper objectToWrapper(Alert__c alertObj){
    	AlertWrapper alertWrapperObj = new AlertWrapper();
    	alertWrapperObj.alertId = alertObj.id;
    	alertWrapperObj.authoredBy = new PeopleLiteWrapper();
        alertWrapperObj.authoredBy.userId = alertObj.Author__r.User__r.Id;
        alertWrapperObj.authoredBy.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + alertObj.Author__c;
        alertWrapperObj.authoredBy.peopleId = alertObj.Author__c;
        alertWrapperObj.authoredBy.name = alertObj.Author__r.Full_Name__c;
        
        if(ServiceConstants.VIDEO_PROVIDER_ZOOM.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
			alertWrapperObj.authoredBy.videoCallUsername = alertObj.Author__r.Zoom_Id__c;
		} else if(ServiceConstants.VIDEO_PROVIDER_SKYPE.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
			alertWrapperObj.authoredBy.videoCallUsername = alertObj.Author__r.Skype_Id__c;
		}
		alertWrapperObj.authoredBy.videoCallProvider = SimpplrContext.PPVideoProvider;
        
        alertWrapperObj.authoredBy.img = alertObj.Author__r.User__r.SmallPhotoUrl.endsWith('005/T') ? null : alertObj.Author__r.User__r.SmallPhotoUrl;
        
        if(ServiceConstants.VIDEO_PROVIDER_ZOOM.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
			alertWrapperObj.authoredBy.videoCallUsername = alertObj.Author__r.Zoom_Id__c;
		} else if(ServiceConstants.VIDEO_PROVIDER_SKYPE.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
			alertWrapperObj.authoredBy.videoCallUsername = alertObj.Author__r.Skype_Id__c;
		}
		alertWrapperObj.authoredBy.videoCallProvider = SimpplrContext.PPVideoProvider;
        
    	alertWrapperObj.recipient = String.isNotBlank(alertObj.Recipient_Site__c) ? 'site' : alertObj.Recipient__c;
    	alertWrapperObj.recipientCount = (Integer)alertObj.Recipient_Count__c;
    	alertWrapperObj.seenCount = (Integer)alertObj.Seen_Count__c;
    	alertWrapperObj.canDelete = !alertObj.Is_Expired__c;
    	if(String.isNotBlank(alertObj.Recipient_Site__c)){
    		alertWrapperObj.siteId = alertObj.Recipient_Site__c;
    		alertWrapperObj.site = new SearchRecordWrapper();
	        alertWrapperObj.site.id = alertObj.Recipient_Site__c;
	        alertWrapperObj.site.siteId = alertObj.Recipient_Site__c;
	        alertWrapperObj.site.name = alertObj.Recipient_Site__r.name;
	        alertWrapperObj.site.title = alertObj.Recipient_Site__r.name;
	        alertWrapperObj.site.chatterGroupId = alertObj.Recipient_Site__r.Chatter_Group_Id__c;
	        alertWrapperObj.site.img = String.isBlank(alertObj.Recipient_Site__r.Title_Content_Version__c) ? null:Utility.getFileDownloadURLFor720By480(alertObj.Recipient_Site__r.Title_Content_Version__c);
	        alertWrapperObj.site.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + alertObj.Recipient_Site__c + '/' + alertObj.Recipient_Site__r.Landing_Page__c;
	        alertWrapperObj.site.isPrivate = ServiceConstants.PRIVATE_SITE.equalsIgnoreCase(alertObj.Recipient_Site__r.Site_Type__c);
	        alertWrapperObj.site.isListed = !ServiceConstants.UNLISTED_SITE.equalsIgnoreCase(alertObj.Recipient_Site__r.Site_Type__c);

		} else if(String.isNotBlank(alertObj.Audience__c)){
			if('segment'.equalsIgnoreCase(alertObj.Recipient__c)) {
				alertWrapperObj.segmentId = alertObj.Audience__r.Segment__c;
				alertWrapperObj.segment = new AudienceWrapper.SegmentLiteWrapper();
				alertWrapperObj.segment.id = alertObj.Audience__r.Segment__c;
				alertWrapperObj.segment.segmentId = alertObj.Audience__r.Segment__c;
				alertWrapperObj.segment.name = alertObj.Audience__r.Segment__r.Name__c;

			} else if('audience'.equalsIgnoreCase(alertObj.Recipient__c)) {
				alertWrapperObj.audienceId = alertObj.Audience__c;
				alertWrapperObj.audience = new AudienceWrapper();
				alertWrapperObj.audience.audienceId = alertObj.Audience__c;
				alertWrapperObj.audience.name = alertObj.Audience__r.Name__c;
				alertWrapperObj.audience.isDeleted = alertObj.Audience__r.Is_Deleted__c;

				alertWrapperObj.recipientCount = new AudienceService().getAudienceMemberCount(alertObj.Audience__c);
			}
		}
		

    	if(alertObj.Is_Active__c){
	    	alertWrapperObj.status = 'active';
    	} else if(alertObj.Is_Scheduled__c){
    		alertWrapperObj.status = 'scheduled';
    	} else if(alertObj.Is_Expired__c){
    		alertWrapperObj.status = 'expired';
    	}
		alertWrapperObj.message = alertObj.Alert_Message__c;
		alertWrapperObj.membersType = alertObj.Members_Type__c;
    	alertWrapperObj.isDismissible = alertObj.Is_Dismissible__c;
    	alertWrapperObj.url = alertObj.Alert_Url__c;
    	if(alertObj.Display_From_DateTime__c != null){  
	    	alertWrapperObj.displayFrom = Utility.dateTimeToMomentJSDateTime(alertObj.Display_From_DateTime__c);
    	}
    	alertWrapperObj.displayTo = Utility.dateTimeToMomentJSDateTime(alertObj.Display_To_DateTime__c);
    	alertWrapperObj.createdAt = Utility.dateTimeToMomentJSDateTime(alertObj.CreatedDate);
    	alertWrapperObj.modifiedAt = Utility.dateTimeToMomentJSDateTime(alertObj.LastModifiedDate);
		if (String.isNotBlank(alertObj.External_Apps_Config_Json__c)) {
			alertWrapperObj.externalDistribution = (AlertWrapper.ExternalAppsForAlert)JSON.deserialize(alertObj.External_Apps_Config_Json__c, AlertWrapper.ExternalAppsForAlert.class);
		}
		
    	return alertWrapperObj;
    }
    
    public class siteWrapper{
    	public String id;
    	public String title;
    }
    
}