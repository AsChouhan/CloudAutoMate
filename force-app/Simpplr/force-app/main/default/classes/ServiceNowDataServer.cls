public with sharing class ServiceNowDataServer extends DataServer {
    @TestVisible private final String ACTION_GET_INCIDENT = 'getIncidents';
    @TestVisible private final String ACTION_CREATE_INCIDENT = 'createIncident';
    @TestVisible private final String ACTION_CREATE_NOTIFICATION = 'createNotification';
	@TestVisible private final String ACTION_GET_KNOWLEDGEBASES = 'getKnowledgeBases';
	@TestVisible private final String ACTION_GET_KNOWLEDGEBASE_ITEMS = 'getKnowledgeBaseItems';
    @TestVisible private final String ACTION_GET_CATEGORY = 'getCategory';
    @TestVisible private final String ACTION_GET_SUB_CATEGORY = 'getSubcategory';
    @TestVisible private final String ACTION_GET_ACCESS_TOKEN = 'getAccessToken';
    @TestVisible private final String ACTION_REVOKE_ACCESS_TOKEN = 'revokeAccessToken';
	
    /*
    public transient final String STR_KEY_1 = 'common.error_message';
    public transient final String STR_KEY_2 = 'servicenow.must.connected';
    */
    public ServiceNowDataServer() {

    }
    public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }    
    
    

    public override void handleRequest() {
    	try{
    		logger.logDebug('ServiceNowDataServer----entered handleRequest----');
            String action = readParam(REQUEST_PARAM_ACTION); 
			String dataJSON = readParam('data');
            
			if(ACTION_GET_INCIDENT.equalsIgnoreCase(action)){
            	response = getIncidents(dataJSON);		
            } else if(ACTION_CREATE_INCIDENT.equalsIgnoreCase(action)){
            	response = createIncident(dataJSON);		
            } else if(ACTION_GET_KNOWLEDGEBASES.equalsIgnoreCase(action)){
				response = getKnowledgeBases();
			} else if(ACTION_GET_KNOWLEDGEBASE_ITEMS.equalsIgnoreCase(action)){
				response = getKnowledgeBaseItems(dataJSON);
			} else if(ACTION_GET_CATEGORY.equalsIgnoreCase(action)){
				response = getCategory();
			} else if(ACTION_GET_SUB_CATEGORY.equalsIgnoreCase(action)){
				response = getSubcategory(readParam('categoryName'));
			} else if(ACTION_GET_ACCESS_TOKEN.equalsIgnoreCase(action)){
				response = getAccessToken();
			} else if(ACTION_REVOKE_ACCESS_TOKEN.equalsIgnoreCase(action)){
				response = revokeAccessToken();
			} else if(ACTION_CREATE_NOTIFICATION.equalsIgnoreCase(action)){
				
                response = createNotification(readParam('snUserId'),readParam('incidentId'), readParam('description'),readParam('status'),readParam('notitype'));
			} else { 
                throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            }
            
        }catch(Exception ex) {
            logger.logError('Either no page access or action parameter returning wrong data', ex);
       		response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
         }
    }

    @testVisible
    private ResponseWrapper getIncidents(String dataJSON){
    	ResponseWrapper resultWrapper = new ResponseWrapper();
		try{
            if(SimpplrContext.serviceNowIntegrationEnabled == false || SimpplrContext.isServiceNowConnected == false){
            	throw new SimpplrException('Servicenow must be enabled within your Org');	
            }
            if(UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) == null || UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Connected__c ==false ){

            	throw new SimpplrException('Servicenow must be connected ');	
            }
            Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(dataJSON);
            String searchTerm = dataMap.get('term') != null?String.valueOf(dataMap.get('term')):null;
            String filter = dataMap.get('filter') != null?String.valueOf(dataMap.get('filter')):null;
            String sortOrder = dataMap.get('sortBy') != null?String.valueOf(dataMap.get('sortBy')):null;
            if('lastUpdatedNewest'.equalsIgnoreCase(sortOrder)){
                filter = 'sys_updated_on';
                sortOrder = 'DESC';
            } else if('lastUpdatedOldest'.equalsIgnoreCase(sortOrder)){
                filter = 'sys_updated_on';
                sortOrder = '';
            } else if('statusDesc'.equalsIgnoreCase(sortOrder)){
                filter = 'state';
                sortOrder = 'DESC';
            } else if('statusAsc'.equalsIgnoreCase(sortOrder)){
                filter = 'state';
                sortOrder = '';
            } else if('descriptionDesc'.equalsIgnoreCase(sortOrder)){
                filter = 'short_description';
                sortOrder = 'DESC';
            } else if('descriptionAsc'.equalsIgnoreCase(sortOrder)){
                filter = 'short_description';
                sortOrder = '';
            } else {
                filter = 'sys_updated_on';
                sortOrder = 'desc';
            }
            
            Integer nextPageToken = dataMap.get('nextPageToken') != null?Integer.valueOf(dataMap.get('nextPageToken')):0;
            Integer size = dataMap.get('size') != null?Integer.valueOf(dataMap.get('size')):0;
            resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, new ServiceNowIntegrationService().getIncidents(searchTerm, nextPageToken,size, sortOrder, filter));
    	} catch(Exception e){
			logger.logError(e.getMessage());
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR,MessageHelper.translateSFMessageToErrorCode(e), null);
		}
        return resultWrapper;
		
    }

    @testVisible
    private ResponseWrapper getKnowledgeBases(){
    	ResponseWrapper resultWrapper = new ResponseWrapper();
		try{
            if(SimpplrContext.serviceNowIntegrationEnabled == false || SimpplrContext.isServiceNowConnected == false){
            	throw new SimpplrException('Servicenow must be enabled within your Org');	
            }
            
            List<ServiceNowWrapper.KnowledgeBaseWrapper> snKBWrapperObjList = new List<ServiceNowWrapper.KnowledgeBaseWrapper>();
			snKBWrapperObjList = new ServiceNowIntegrationService().getKnowledgeBases();
            Map<String,Object> resultmap = new Map<String,Object>();
            resultmap.put('listOfItems',snKBWrapperObjList);
	    	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, resultMap);
			
		} catch(Exception e){
			logger.logError(e.getMessage());
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR,MessageHelper.translateSFMessageToErrorCode(e), null);
		}
        return resultWrapper;
		
    }


    @testVisible
    private ResponseWrapper getCategory(){
    	ResponseWrapper resultWrapper = new ResponseWrapper();
		try{
            if(SimpplrContext.serviceNowIntegrationEnabled == false || SimpplrContext.isServiceNowConnected == false){
            	throw new SimpplrException('Servicenow must be enabled within your Org');	
            }

            if(UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) == null || UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Connected__c ==false ){

            	throw new SimpplrException('Servicenow must be connected ');	
            }
            List<ServiceNowWrapper.KBCategoryWrapper> categoryList = new ServiceNowIntegrationService().getCategory();
            Map<String,Object> resultmap = new Map<String,Object>();
			resultmap.put('listOfItems',categoryList);
	    	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, resultMap);
			
		} catch(Exception e){
			logger.logError(e.getMessage());
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR,MessageHelper.translateSFMessageToErrorCode(e), null);
		}
        return resultWrapper;
		
    }

    @testVisible
    private ResponseWrapper getSubcategory(String categoryName){
    	ResponseWrapper resultWrapper = new ResponseWrapper();
		try{
            if(SimpplrContext.serviceNowIntegrationEnabled == false || SimpplrContext.isServiceNowConnected == false){
            	throw new SimpplrException('Servicenow must be enabled within your Org');	
            }

            if(UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) == null || UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Connected__c ==false ){

            	throw new SimpplrException('Servicenow must be connected ');	
            }
            List<String> categoryList = new ServiceNowIntegrationService().getSubcategory(categoryName);
			Map<String,Object> resultmap = new Map<String,Object>();
            resultmap.put('listOfItems',categoryList);
	    	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, resultMap);
			
		} catch(Exception e){
			logger.logError(e.getMessage());
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR,MessageHelper.translateSFMessageToErrorCode(e), null);
		}
        return resultWrapper;
		
    }

    @testVisible
    private ResponseWrapper createIncident(String dataJSON){
    	ResponseWrapper resultWrapper = new ResponseWrapper();
		try{
            if(SimpplrContext.serviceNowIntegrationEnabled == false || SimpplrContext.isServiceNowConnected == false){
            	throw new SimpplrException('Servicenow must be enabled within your Org');	
            }

            if(UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) == null || UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Connected__c ==false ){

            	throw new SimpplrException('Servicenow must be connected ');	
            }
            ServiceNowWrapper.KnowledgeBaseWrapper kbWrapperObj = new ServiceNowWrapper.KnowledgeBaseWrapper();
            Map<String,Object> reqDataMap = (Map<String,Object>)JSON.deserializeUntyped(dataJSON);
            String category = reqDataMap.get('category')!= null ? String.valueOf(reqDataMap.get('category')):'';
            String subCategory = reqDataMap.get('subCategory')!= null ? String.valueOf(reqDataMap.get('subCategory')):'';
            String urgency = reqDataMap.get('urgency')!= null ? String.valueOf(reqDataMap.get('urgency')):'';
            String shortDescription = reqDataMap.get('title')!= null ? String.valueOf(reqDataMap.get('title')):'';
            String description = reqDataMap.get('description')!= null ? String.valueOf(reqDataMap.get('description')):'';
            String impact = reqDataMap.get('impact')!= null ? String.valueOf(reqDataMap.get('impact')):'';
            Integer filesCount = reqDataMap.get('filesCount')!= null ? Integer.valueOf(reqDataMap.get('filesCount')):0;
            kbWrapperObj = new ServiceNowIntegrationService().createIncident(category, subCategory, urgency, shortDescription, description, filesCount, impact);
            resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, kbWrapperObj);
    	} catch(Exception e){
			logger.logError(e.getMessage());
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR,MessageHelper.translateSFMessageToErrorCode(e), null);
		}
		return resultWrapper;
    }

    @testVisible
    private ResponseWrapper getKnowledgeBaseItems(String dataJSON){
    	ResponseWrapper resultWrapper = new ResponseWrapper();
		try{
            if(SimpplrContext.serviceNowIntegrationEnabled == false || SimpplrContext.isServiceNowConnected == false){
            	throw new SimpplrException('Servicenow must be enabled within your Org');	
            }

            if(UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) == null || UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Connected__c ==false ){
            	throw new SimpplrException('Servicenow must be connected ');	
            }
            Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(dataJSON);
            String searchTerm = readParam('term');
            if(String.isBlank(searchTerm)){
             searchTerm  = dataMap.get('term') != null?String.valueOf(dataMap.get('term')):null;
            }
            Integer nextPageToken = dataMap.get('nextPageToken') != null?Integer.valueOf(dataMap.get('nextPageToken')):0;
            Integer size = dataMap.get('size') != null?Integer.valueOf(dataMap.get('size')):0;
            resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, new ServiceNowIntegrationService().getKnowledgeBaseItems(searchTerm, nextPageToken,size));
        } catch(Exception e){
			logger.logError('ServiceNowDataServer.getKnowledgeBaseItems()----Exception Occurec----', e);
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR,MessageHelper.translateSFMessageToErrorCode(e), null);
		}
		return resultWrapper;
    }

    @testVisible
    private ResponseWrapper createNotification(String snUserId, String incidentId, String incidentDescription, String status, String notiType){
    	ResponseWrapper resultWrapper = new ResponseWrapper();
		try{
            if(SimpplrContext.serviceNowIntegrationEnabled == false || SimpplrContext.isServiceNowConnected == false){
            	throw new SimpplrException('Servicenow must be enabled within your Org');	
            }

            if(SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SALESFORCE) == null) {
            	throw new SimpplrException('Servicenow notification must be enabled within your Org');	
            }
            Map<String, Object> soqlParamMap = new Map<String, Object>();
            soqlParamMap.put('soqlParam1', IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW);
            soqlParamMap.put('soqlParam2', snUserId);
            String queryStr = 'SELECT people__c from People_Integration__c WHERE Name =: soqlParam1 AND External_Id__c=:soqlParam2 AND IS_Deleted__c = false';
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            List<People_Integration__c> peopleIntegList = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
            List<App_Notification__c> listOfNotification = new List<App_Notification__c>();
            List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();

            for(People_Integration__c peopleIntegObj : peopleIntegList) {
                String peopleId = peopleIntegObj.people__c;
                App_Notification__c notificationObject = new App_Notification__c();
                notificationObject.Sent_By__c = peopleId;
                notificationObject.GUID__c = peopleId + '-' + System.currentTimeMillis();
                notificationObject.External_Id__c = incidentId;
                notificationObject.Object_Type__c = IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW;
                notificationObject.Status__c = status;
                notificationObject.Type__c = 'Information';
                notificationObject.Sub_Type__c = notiType;
                notificationObject.Is_Read__c = false;
                notificationObject.Is_New__c = true;
                notificationObject.Category__c = 'ServiceNow';
                notificationObject.Snippet__c =  Utility.chompString(incidentDescription, 255);
                notificationObject.Sent_to__c = peopleId;
                notificationObject.Created_DateTime__c = DateTime.now();
                listOfNotification.add(notificationObject);
                
            }
            
            if( !listOfNotification.isEmpty()) {
                fieldList.add(App_Notification__c.Sent_By__c);
                fieldList.add(App_Notification__c.GUID__c);
                fieldList.add(App_Notification__c.External_Id__c);
                fieldList.add(App_Notification__c.Object_Type__c);
                fieldList.add(App_Notification__c.Status__c);
                fieldList.add(App_Notification__c.Type__c);
                fieldList.add(App_Notification__c.Sub_Type__c);
                fieldList.add(App_Notification__c.Is_Read__c);
                fieldList.add(App_Notification__c.Is_New__c);
                fieldList.add(App_Notification__c.Category__c);
                fieldList.add(App_Notification__c.Snippet__c);
                fieldList.add(App_Notification__c.Sent_to__c);
                fieldList.add(App_Notification__c.Created_DateTime__c);
                                
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                SIMPESAPI.accessController().insertAsUser(listOfNotification, fieldList);
            }
            
            resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, 'Servicenow incident notification created successfully');
        } catch(Exception e){
			logger.logError('ServiceNowDataServer.createNotification()----Exception Occured----', e);
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR,MessageHelper.translateSFMessageToErrorCode(e), null);
		}
		return resultWrapper;
    }

    @testVisible
    private ResponseWrapper getAccessToken(){
        ResponseWrapper responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null,UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) != null ? UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Access_Token__c:'');
     	return responseWrapperObj;
    }

    @testVisible
    private ResponseWrapper revokeAccessToken(){
        ResponseWrapper responseWrapperObj = new ResponseWrapper();
        try{

            ServiceNowIntegrationService snisObj = new ServiceNowIntegrationService();
            snisObj.revokeAccessToken();
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null,null);
            
        } catch(Exception ex){
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null,null);
        }
     	return responseWrapperObj;
    }
}