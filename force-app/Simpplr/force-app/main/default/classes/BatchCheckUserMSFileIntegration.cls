/**
* Class BatchCheckUserMSFileIntegration
* Purpose:  Batch to refresh user'd access token, if token cannot be refreshed 
* disconnect integration and send mail
*
*/
public with sharing class BatchCheckUserMSFileIntegration implements Database.Batchable<SObject>,Database.AllowsCallouts, Database.Stateful {
    public String query;
    public Set<String> integrationType;
    public Exception exceptionDetailsObj;
    public Boolean runNext;
    public static final String SHAREPOINT = 'Sharepoint';
    public static final String ONEDRIVE = 'OneDrive';

    public BatchCheckUserMSFileIntegration(Boolean runNext) {
        Set<String> integrationType = new Set<String>();
        if(SimpplrContext.connectedStorages.contains(IntegrationConstants.INTEGRATION_TYPE_SHAREPOINT)){
            integrationType.add(IntegrationConstants.INTEGRATION_TYPE_SHAREPOINT);
        }
        if(SimpplrContext.connectedStorages.contains(IntegrationConstants.INTEGRATION_TYPE_ONEDRIVE)){
            integrationType.add(IntegrationConstants.INTEGRATION_TYPE_ONEDRIVE);
        }
        this.integrationType = integrationType;
        this.runNext = runNext;
        String query;
        if(integrationType.size()>0){
            query =  ' SELECT Id,Access_Token__c,Refresh_Token__c,People__c,People__r.User__c,';
            query += ' App_Integration__r.Client_Id__c,App_Integration__r.Client_Secret__c,';
            query += ' App_Integration__r.Name';
            query += ' FROM People_Integration__c WHERE Connected__c = TRUE AND';
            query += ' Is_Deleted__c = FALSE AND App_Integration__r.Name IN:integrationType';
        }
        else{
            query = 'SELECT Id FROM People_Integration__c WHERE Id = null';
        }
        this.query=query;
    }

    public database.querylocator start(Database.BatchableContext bc){
    	return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<People_Integration__c> peopleIntList){
    	try{
            Set<Id> peopleIdsSharepoint = new Set<Id>();
            Set<Id> peopleIdsOneDrive = new Set<Id>();
            List<People_Integration__c> disconnectList = refreshSharepointToken(peopleIntList);
            for(People_Integration__c peopleInt : disconnectList){   
                if(peopleInt.App_Integration__r.Name.equalsIgnoreCase(IntegrationConstants.INTEGRATION_TYPE_SHAREPOINT)){
                    peopleIdsSharepoint.add(peopleInt.People__c);
                }
                else if(peopleInt.App_Integration__r.Name.equalsIgnoreCase(IntegrationConstants.INTEGRATION_TYPE_ONEDRIVE)){
                    peopleIdsOneDrive.add(peopleInt.People__c);
                }	
            }
            if(disconnectList.size()>0){
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                SIMPESAPI.accessController().deleteAsUser(disconnectList);
            } 
            if(peopleIdsSharepoint.size()>0){
                NotificationDispatcher.userIntegrationTokenExpireSendEmailSaveLogs(peopleIdsSharepoint,SHAREPOINT);
            }
            if(peopleIdsOneDrive.size()>0){
                NotificationDispatcher.userIntegrationTokenExpireSendEmailSaveLogs(peopleIdsOneDrive,ONEDRIVE);
            }
    	}catch(Exception ex){
    		exceptionDetailsObj =  ex;
    		throw ex;
    	}
    }

    public void finish(Database.BatchableContext bc){
        AsyncApexJob currentJob = [SELECT Id, Status, NumberOfErrors, 
        JobItemsProcessed, TotalJobItems, CreatedBy.Email, ExtendedStatus 
        FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        Boolean canStartNextBatch = false;
        if(currentJob.Status.equalsIgnoreCase(IntegrationConstants.COMPLETED)  && currentJob.NumberOfErrors == 0) {
            canStartNextBatch = true;
        } else {
            Utility.sendExceptionEmail(BatchCheckUserMSFileIntegration.class.getName(), exceptionDetailsObj);
        }
        if(runNext){
            BatchCheckUserTwitterIntegration twitterBatch = new BatchCheckUserTwitterIntegration(runNext);
            Database.executeBatch(twitterBatch, 100);
        }
    }

     /**
     * @description update/delete sharepoint/onedrive token on basis of api call
     * @param  peopleIntList list of People_Integration__c records
	 * @return List<People_Integration__c> to disconnect/delete
     */
    public List<People_Integration__c> refreshSharepointToken(List<People_Integration__c> peopleIntList){
		List<People_Integration__c> disconnectList = new List<People_Integration__c>();
        Map<Id,People_Integration__c> updateMap = new Map<Id,People_Integration__c>();
        try{
            for(People_Integration__c peopleInt : peopleIntList){
                HttpResponse resObj = makeCallout(peopleInt);
                if (resObj.getStatusCode()== 200) { 
                    String resBodyJSON = resObj.getBody();
                    Map<String,Object> resBody = (Map<String,Object>)JSON.deserializeUntyped(resBodyJSON);
                    if(String.isNotBlank(String.valueOf(resBody.get(IntegrationConstants.ERROR)))) {
                        disconnectList.add(peopleInt);
                    }
                    else {
                        People_Integration__c peopleIntegObj = new People_Integration__c(Id = peopleInt.Id);
                        peopleIntegObj.Access_Token__c = String.valueOf(resBody.get(IntegrationConstants.ACCESS_TOKEN));
                        peopleIntegObj.Access_Token_Expiry__c =  Decimal.valueOf((String)resBody.get(IntegrationConstants.EXPIRES_IN));
                        peopleIntegObj.Access_Token_Expiration_Datetime__c = DateTime.now().addSeconds(peopleIntegObj.Access_Token_Expiry__c.intValue());
                        peopleIntegObj.Access_Token_Requested_Datetime__c = DateTime.now();
                        peopleIntegObj.Refresh_Token__c = String.valueOf(resBody.get(IntegrationConstants.REFRESH_TOKEN));
                        peopleIntegObj.Connected__c = true;
                        updateMap.put(peopleIntegObj.Id,peopleIntegObj);
                    } 
                }
                else{
                    disconnectList.add(peopleInt);
                }  
            }
            if(updateMap.size()>0){
                updateTokens(updateMap);
            }
        }
        catch(Exception ex){
            exceptionDetailsObj =  ex;
    		throw ex;
        }
        return disconnectList;
	}

    /**
     * @description make api callout to refresh sharepoint token
     * @param  peopleInt  People_Integration__c record
	 * @return HttpResponse of request
     */
    public HttpResponse makeCallout(People_Integration__c peopleInt){
        HttpResponse resObj;
        try{
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            String endPoint = IntegrationConstants.TOKEN_ENDPOINT_MAP.get(peopleInt.App_Integration__r.Name);
            req.setEndpoint(endPoint);
            req.setHeader(IntegrationConstants.CONTENT_TYPE,IntegrationConstants.URL_ENCODED_FORM);
            req.setBody(IntegrationConstants.GRANT_TYPE+ '='+IntegrationConstants.REFRESH_TOKEN
            +'&'+IntegrationConstants.REFRESH_TOKEN+'='
            +EncodingUtil.urlEncode(peopleInt.Refresh_Token__c,IntegrationConstants.CHARSET_UTF8)
            +'&'+IntegrationConstants.CLIENT_ID+'='
            +EncodingUtil.urlEncode(peopleInt.App_Integration__r.Client_Id__c,IntegrationConstants.CHARSET_UTF8)
            +'&'+IntegrationConstants.CLIENT_SECRET+'='
            +EncodingUtil.urlEncode(peopleInt.App_Integration__r.Client_Secret__c,IntegrationConstants.CHARSET_UTF8));
            req.setMethod(IntegrationConstants.POST_REQUEST_TYPE);
            req.setTimeout(120000);
            System.debug(req);
            resObj = http.send(req);
        }
        catch(Exception ex){
            exceptionDetailsObj =  ex;
    		throw ex;
        }
        return resObj;
    }

    /**
     * @description update the integration token
     * @param  updateMap  map of Id and People_Integration__c record
     */
    public void updateTokens(Map<Id,People_Integration__c> updateMap){
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        SIMPESAPI.accessController().updateAsUser(updateMap, new List<Schema.SObjectField>{
                People_Integration__c.Access_Token__c,
                People_Integration__c.Access_Token_Expiry__c,
                People_Integration__c.Access_Token_Expiration_Datetime__c,
                People_Integration__c.Access_Token_Requested_Datetime__c,
                People_Integration__c.Refresh_Token__c,
                People_Integration__c.Connected__c
        });
    }
}