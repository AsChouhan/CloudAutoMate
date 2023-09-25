/**
* Class BatchCheckUserServiceNowIntegration
* Purpose:  Batch to refresh user's ServiceNow integration token if the token is valid 
* else disconnect ServiceNow and send email to users
*
*/
public with sharing class BatchCheckUserServiceNowIntegration implements Database.Batchable<SObject>,Database.AllowsCallouts, Database.Stateful {
    public String query;
    public String integrationType;
    public Exception exceptionDetailsObj;
    public Boolean runNext;
    
    public BatchCheckUserServiceNowIntegration(Boolean runNext){
        String integrationType = IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW;
        this.integrationType = integrationType;
        this.runNext = runNext;
        String query;
        if(SimpplrContext.isServiceNowConnected){
            query =  ' SELECT Id,Access_Token__c,Refresh_Token__c,People__c,People__r.User__c';
            query += ' FROM People_Integration__c WHERE Connected__c = TRUE AND';
            query += ' Is_Deleted__c = FALSE AND App_Integration__r.Name =:integrationType';
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
            Set<Id> peopleIds = new Set<Id>();
            List<People_Integration__c> disconnectList = refreshServiceNowToken(peopleIntList);
            for(People_Integration__c peopleInt : disconnectList){   
                peopleIds.add(peopleInt.People__c);	
            }
            if(disconnectList.size()>0){
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                SIMPESAPI.accessController().deleteAsUser(disconnectList);
            } 
            if(peopleIds.size()>0){
                NotificationDispatcher.userIntegrationTokenExpireSendEmailSaveLogs(peopleIds,'ServiceNow');
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
            Utility.sendExceptionEmail('BatchCheckUserServiceNowIntegration', exceptionDetailsObj);
        }
        if(runNext){
            BatchCheckUserLinkedinIntegration linkedInBatch = new BatchCheckUserLinkedinIntegration(runNext);
            Database.executeBatch(linkedInBatch,100);
        }
    }

    /**
     * @description make api callout to refresh servicenow token
     * @param  peopleIntList list of People_Integration__c records
	 * @return List<People_Integration__c> to disconnect/delete
     */
    public List<People_Integration__c> refreshServiceNowToken(List<People_Integration__c> peopleIntList){
		List<People_Integration__c> disconnectList = new List<People_Integration__c>();
        Map<Id,People_Integration__c> updateMap = new Map<Id,People_Integration__c>();
		try{
            Blob headerValue = Blob.valueOf(Utility.decryptFn(SimpplrContext.ServiceNowClientId) + ':' + Utility.decryptFn(SimpplrContext.ServiceNowClientSecret));
			String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            String redUrl = EncodingUtil.urlEncode('https://services.simpplr.com/oauth/redirect/code_passthrough.php', 'UTF-8');
			String clientId = SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Client_Id__c;
			String clientSecret = SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Client_Secret__c;
            String reqURL = SimpplrContext.simpplrIntegrationServiceEndpoint;
            for(People_Integration__c peopleInt: peopleIntList){
                HttpRequest reqObj = new HttpRequest();
                reqObj.setEndpoint(reqURL+'?action=getaccesstoken');
                reqObj.setHeader('content-type','application/x-www-form-urlencoded');
                reqObj.setHeader('accept', 'application/json');
                reqObj.setMethod('POST');
                String refreshToken = peopleInt.Refresh_Token__c;
                reqObj.setBody('{"refreshToken":"'+refreshToken+'","grantType":"refresh_token","tokenUrl":"'+SimpplrContext.serviceNowInstanceUrl+'/oauth_token.do","integrationname":"servicenow","redirectUrl":"'+redUrl+'","scope":"useraccount","clientId":"'+Utility.decryptFn(clientId)+'","clientSecret":"'+Utility.decryptFn(clientSecret)+'","method":"POST", "authorizationHeader": "'+authorizationHeader+'"}');
                Http httpObj = new Http();
                HTTPResponse resObj = httpObj.send(reqObj);
                if (resObj.getStatusCode()== 200) { 
                    String resBodyJSON = resObj.getBody();
                    Map<String,Object> resBody = (Map<String,Object>)JSON.deserializeUntyped(resBodyJSON);
                    if(String.isNotBlank(String.valueOf(resBody.get('error')))) {
                        disconnectList.add(peopleInt);
                    } 
                    else {
                        People_Integration__c peopleIntegObj = new People_Integration__c(Id = peopleInt.Id);
                        peopleIntegObj.Access_Token__c = String.valueOf(resBody.get('access_token'));
                        peopleIntegObj.Refresh_Token__c = String.valueOf(resBody.get('refresh_token'));
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
                        People_Integration__c.Refresh_Token__c,
                        People_Integration__c.Access_Token_Expiry__c,
                        People_Integration__c.Access_Token_Expiration_Datetime__c,
                        People_Integration__c.Access_Token_Requested_Datetime__c,
                        People_Integration__c.Connected__c
                });
            }
		} catch(Exception ex) {
            throw ex;
		}
		return disconnectList;
	}
}