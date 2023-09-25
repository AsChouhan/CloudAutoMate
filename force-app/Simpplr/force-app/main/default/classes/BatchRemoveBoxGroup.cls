public without sharing class BatchRemoveBoxGroup implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.stateful {
    BoxService boxServiceObj = new BoxService();
    private Exception exceptionDetailsObj;
    private final String BATCH_BOX_ADMIN_DISCONNECT = 'boxAdminDisconnect';
    List<String> groupType = new List<String> {'BOX_ADMIN_GROUP_ID', 'BOX_MEMBER_GROUP_ID'};
    private String batchContext;
    private String requestType;

    /**
     * @description Parameterized consutructor which takes the type of batch as we have used same batch class to run multiple batch types
     * @param batchContext 
     */
    public BatchRemoveBoxGroup(String batchContext) {
        this.batchContext = batchContext;
    }
    /**
     * @description Parameterized consutructor which takes the type of batch as we have used same batch class to run multiple batch types
     */
    public BatchRemoveBoxGroup() {

    }

	BoxWrapper.UserTokens adminUserTokens;

    public database.querylocator start(Database.BatchableContext bc){	
        String query = '';
        adminUserTokens = boxServiceObj.getBoxAdminUserTokens(true);
        if('boxAdminDisconnect'.equalsIgnoreCase(batchContext)) {
            query = 'SELECT Id, Is_Deleted__c, value__c ' 
                    + ' FROM Simpplr_Metadata__c where ' 
                    + ' Simpplr_Site__c != null '
                    + ' And Type__c =: groupType '
                    + ' And Is_Deleted__c = false ';

        } else {
            String folderType = 'Box';
            query = 'Select Name, Id, Chatter_Group_Id__c FROM Simpplr_Site__c WHERE Id not In '+
                    '(Select Site__c From Folder__c WHERE Type__c=:folderType and Is_Deleted__c=false) ';
        }
        return Database.getQueryLocator(query); 
    }
    
    
   	public void execute (Database.BatchableContext bc, List<sObject> listOfsObject) {
   		try{
        if('boxAdminDisconnect'.equalsIgnoreCase(batchContext)) {
            List<Simpplr_Metadata__c> listOfSimpplrMetadata = (List<Simpplr_Metadata__c>)listOfsObject;
            disconnectBoxAdmin(listOfSimpplrMetadata);
        } else {

            List<Simpplr_Site__c> listOfSites = (List<Simpplr_Site__c>)listOfsObject;
            List<Id> listOfSiteIdWithoutLinkedFolder = new List<Id>();
            
            for (Simpplr_Site__c siteObj : listOfSites) {
                
                if (siteObj.Simpplr_Folders__r.isEmpty()) {
                    listOfSiteIdWithoutLinkedFolder.add(siteObj.Id);
                }
                
            }

            if (!listOfSiteIdWithoutLinkedFolder.isEmpty()) {
                
                Map<String, Object> soqlParamMap = new  Map<String, Object>();
                soqlParamMap.put('soqlParam1', listOfSiteIdWithoutLinkedFolder);
                soqlParamMap.put('soqlParam2', groupType);
                String query = 'SELECT Is_Deleted__c, value__c ' 
                        + ' FROM Simpplr_Metadata__c ' 
                        + ' WHERE Simpplr_Site__c IN:soqlParam1 '
                        + ' And Type__c = : soqlParam2 '
                        + ' AND Is_Deleted__c = false ';
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
                List<Simpplr_Metadata__c> listOfMetadataObj = (List<Simpplr_Metadata__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
                List<Schema.SObjectField> listOfModifiedFileds = new List<Schema.SObjectField>();
                if (!listOfMetadataObj.isEmpty()) {
                    List<String> listOfBoxId = new List<String>();
                    
                    for (Simpplr_Metadata__c metadataObj : listOfMetadataObj) {
                        listOfBoxId.add(metadataObj.value__c);
                    }
                    
                    Map<String,String> resultStatusMap = deleteBoxGroup(listOfBoxId, adminUserTokens);
                    
                    for (Simpplr_Metadata__c metadataObj : listOfMetadataObj) {
                        if (resultStatusMap.get(metadataObj.value__c) == 'SUCCESS'){
                            metadataObj.Is_Deleted__c = true;
                            listOfModifiedFileds.add(Simpplr_Metadata__c.Is_Deleted__c);
                        }
                    }
                    
                    SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                    SIMPESAPI.accessController().updateAsUser(new Map<Id, Simpplr_Metadata__c>(listOfMetadataObj), listOfModifiedFileds);
                }
            }
        }
   		}catch(Exception ex) {
    		exceptionDetailsObj =  ex;
    		throw ex;
   		}
   	}
   	
   	public void finish (Database.BatchableContext bc) {
   		AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
		Boolean canStartNextBatch = false;
		if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
			canStartNextBatch = true;
		} else {
			Utility.sendExceptionEmail('BatchRemoveBoxGroup', exceptionDetailsObj);
		}
   		
   	}

	private Map<String, String> deleteBoxGroup (List<String> listOfBoxIdArg, BoxWrapper.UserTokens adminUserTokens) {
    	Map<String, String> resultStatusMap = new Map<String, String>();
    	
    	if (!listOfBoxIdArg.isEmpty()) {
	    	try {
    			if (adminUserTokens != null && String.isNotBlank(adminUserTokens.accessToken)) {
    				for (String boxGroupId : listOfBoxIdArg) {
		    			string jsonBody = '';
			    		HttpResponse res = Utility.getJsonResponseFromExternalSystem('DELETE',
			    				'https://api.box.com/2.0/groups/'+boxGroupId+'',
			    				'Bearer ' + adminUserTokens.accessToken, jsonBody);
			    				
		    			resultStatusMap.put(boxGroupId, 'SUCCESS' );
    				}
    			}
				
			} catch (Exception ex) {
				throw ex;
			}
    	}
    	
    	return resultStatusMap;
    }

    /**
     * @description This is used to delete box group when admin record is disconnected
     * @param listOfSimpplrMetadata
     */
    public void disconnectBoxAdmin(List<Simpplr_Metadata__c> listOfSimpplrMetadata){
        Map<String, String> simpplrMetadataIdVsValueMap = new Map<String, String>();
        String appConfigQuery = 'Select id, Box_client_id__c, Box_Client_Secret__c, Box_Access_Token__c, Box_Refresh_token__c From App_Config__c LIMIT 1';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
        List<App_Config__c> appConfigList = (List<App_Config__c>)SIMPESAPI.accessController().queryAsUSer(appConfigQuery, null);	
        App_Config__c appConfigRecord = appConfigList[0];
        for(Simpplr_Metadata__c simpplrMetadata : listOfSimpplrMetadata) {
            simpplrMetadataIdVsValueMap.put(simpplrMetadata.Id, simpplrMetadata.Value__c);
        }
        disconnectBoxAdmin(appConfigRecord, simpplrMetadataIdVsValueMap);
    }

    /**
     * @description This is used to send a request to delete box group when admin record is disconnected
     * @param appconfigRecord - app_Config__c Obj record 
     * @param simpplrMetadataIdVsValueMap - map of Simpplr_Metadata__c
     */
    public void disconnectBoxAdmin(App_Config__c appconfigRecord, Map<String, string> simpplrMetadataIdVsValueMap) {
        String endpointURL = SimpplrContext.simpplrAPIEndpoint + '/box/box-group-manager?action=deleteBoxGroup';
        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);
        mapOfRequestParam.put('userId', UserContext.userId);
        mapOfRequestParam.put('clientId', appconfigRecord.Box_client_id__c);
        mapOfRequestParam.put('clientSecret', appconfigRecord.Box_Client_Secret__c);
        mapOfRequestParam.put('accessToken', appconfigRecord.Box_Access_Token__c);	
        mapOfRequestParam.put('refreshToken', appconfigRecord.Box_Refresh_token__c);
        mapOfRequestParam.put('appConfigId', appconfigRecord.Id);
        mapOfRequestParam.put('simpplrMetadataIdVsValueMap',simpplrMetadataIdVsValueMap);
        mapOfRequestParam.put('action', 'deleteBoxGroup');
        Utility.getResponseFromAWS(endpointURL, mapOfRequestParam);  
    }
}