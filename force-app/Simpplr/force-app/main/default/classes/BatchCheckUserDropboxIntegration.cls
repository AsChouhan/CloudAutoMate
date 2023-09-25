/**
* Class BatchCheckUserDropboxIntegration
* Purpose:  Batch to refresh user'd access token, if token cannot be refreshed 
* disconnect integration and send mail
*
*/
public with sharing class BatchCheckUserDropboxIntegration implements Database.Batchable<SObject>,Database.AllowsCallouts, Database.Stateful {
    public String query;
    public String integrationType;
    public Exception exceptionDetailsObj;
    public Boolean runNext;

    public BatchCheckUserDropboxIntegration(Boolean runNext) {
        String integrationType = IntegrationConstants.INTEGRATION_TYPE_DROPBOX;
        this.integrationType = integrationType;
        this.runNext = runNext;
        String query;
        if(SimpplrContext.isDropboxConnected){
            query =  ' SELECT Id,Access_Token__c,Refresh_Token__c,People__c,People__r.User__c,';
            query += ' App_Integration__r.DB_User_Client_Id__c,';
            query += ' App_Integration__r.DB_User_Client_Secret__c';
            query += ' FROM People_Integration__c WHERE Connected__c = TRUE AND';
            query += ' Is_Deleted__c = FALSE AND App_Integration__r.Name =:integrationType';
        }
        else{
            query = 'SELECT Id from People_Integration__c where Id = null';
        }
        this.query=query;
    }

    public database.querylocator start(Database.BatchableContext bc){
    	return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<People_Integration__c> peopleIntList){
    	try{
            
			Set<Id> peopleIds = new Set<Id>();
            List<People_Integration__c> disconnectList = refreshDropboxToken(peopleIntList);
            for(People_Integration__c peopleInt : disconnectList){
                peopleIds.add(peopleInt.People__c);
            }
            if(disconnectList.size()>0){
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                SIMPESAPI.accessController().deleteAsUser(disconnectList);
            } 
            if(peopleIds.size()>0){
                NotificationDispatcher.userIntegrationTokenExpireSendEmailSaveLogs(peopleIds,'Dropbox');
            }
    	}catch(Exception ex){
    		exceptionDetailsObj =  ex;
    		throw ex;
    	}
    }
    
    public void finish(Database.BatchableContext bc){
        AsyncApexJob currentJob = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, 
        TotalJobItems, CreatedBy.Email, ExtendedStatus 
        FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        Boolean canStartNextBatch = false;
        if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
            canStartNextBatch = true;
        } else {
            Utility.sendExceptionEmail('BatchCheckUserDropboxIntegration', exceptionDetailsObj);
        }
        if(runNext){
            BatchCheckUserMSFileIntegration msFileBatch = new BatchCheckUserMSFileIntegration(runNext);
            Database.executeBatch(msFileBatch, 100);
        }
    }

    /**
     * @description make api callout to refresh dropbox token
     * @param peopleIntList
	 * @return List<People_Integration__c> to disconnect/delete
     */
    public List<People_Integration__c> refreshDropboxToken(List<People_Integration__c> peopleIntList){
        List<People_Integration__c> disconnectList = new List<People_Integration__c>();
        Map<Id,People_Integration__c> updateMap = new Map<Id,People_Integration__c>();
        try{
            for(People_Integration__c peopleInt : peopleIntList){
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                String endPoint = 'https://api.dropboxapi.com/oauth2/token';
                req.setEndpoint(endPoint);
                req.setHeader('Content-Type','application/x-www-form-urlencoded');
                req.setBody('grant_type=refresh_token'+'&refresh_token='
                +EncodingUtil.urlEncode(peopleInt.Refresh_Token__c,'UTF-8')
                +'&client_id='
                +EncodingUtil.urlEncode(peopleInt.App_Integration__r.DB_User_Client_Id__c,'UTF-8')
                +'&client_secret='
                +EncodingUtil.urlEncode(peopleInt.App_Integration__r.DB_User_Client_Secret__c,'UTF-8'));
                req.setMethod('POST');
                req.setTimeout(120000);
                System.debug(req);
                HttpResponse resObj = h.send(req);
                if (resObj.getStatusCode()== 200) { 
                    String resBodyJSON = resObj.getBody();
                    Map<String,Object> resBody = (Map<String,Object>)JSON.deserializeUntyped(resBodyJSON);
                    if(String.isNotBlank(String.valueOf(resBody.get('error')))) {
                        disconnectList.add(peopleInt);
                    }
                    else {
                        People_Integration__c peopleIntegObj = new People_Integration__c(Id = peopleInt.Id);
                        peopleIntegObj.Access_Token__c = String.valueOf(resBody.get('access_token'));
                        peopleIntegObj.Access_Token_Expiry__c =  (Decimal)resBody.get('expires_in');
                        peopleIntegObj.Access_Token_Expiration_Datetime__c = DateTime.now().addSeconds(peopleIntegObj.Access_Token_Expiry__c.intValue());
                        peopleIntegObj.Access_Token_Requested_Datetime__c = DateTime.now();
                        peopleIntegObj.Connected__c = true;
                        updateMap.put(peopleIntegObj.Id,peopleIntegObj);
                    } 
                }
                else{
                    disconnectList.add(peopleInt);
                }  
            }
            if(updateMap.size()>0){
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                SIMPESAPI.accessController().updateAsUser(updateMap, new List<Schema.SObjectField>{
                        People_Integration__c.Access_Token__c,
                        People_Integration__c.Access_Token_Expiry__c,
                        People_Integration__c.Access_Token_Expiration_Datetime__c,
                        People_Integration__c.Access_Token_Requested_Datetime__c,
                        People_Integration__c.Connected__c
                });
            }
        }
        catch(Exception ex){
            throw ex;
        }
        return disconnectList;
    }
}