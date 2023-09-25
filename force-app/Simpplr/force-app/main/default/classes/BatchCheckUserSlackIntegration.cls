/**
* Class BatchCheckUserSlackIntegration
* Purpose:  Batch to authenticate user's slack integration token if the token is invalid 
* disconnect slack and send email to users
*
*/
public with sharing class BatchCheckUserSlackIntegration implements Database.Batchable<SObject>,Database.AllowsCallouts, Database.Stateful {
    public String query;
    public String integrationType;
    public String slackContentIntegration;
    public Exception exceptionDetailsObj;
    public Boolean runNext;

    public BatchCheckUserSlackIntegration(Boolean runNext) {
        String integrationType = IntegrationConstants.INTEGRATION_TYPE_SLACK;
        this.integrationType = integrationType;
        String slackContentIntegration = IntegrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE;
        this.slackContentIntegration = slackContentIntegration;
        this.runNext = runNext;
        String query;
        if(SimpplrContext.slackIntegrationEnabled){
            query =  ' SELECT Id,Name,Access_Token__c,Refresh_Token__c,People__c';
            query += ' FROM People_Integration__c';
            query += ' WHERE Connected__c = TRUE AND App_Integration__r.Name =:integrationType';
            query += ' AND Is_Deleted__c = FALSE AND Name=:slackContentIntegration';
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
            List<People_Integration__c> disconnectList = new List<People_Integration__c>();
            Set<Id> peopleIds = new Set<Id>();
            for(People_Integration__c peopleInt : peopleIntList){
                Boolean success = validateSlackToken(peopleInt);
                if(!success){
                    disconnectList.add(peopleInt);
                    peopleIds.add(peopleInt.People__c);
                }  
            }
            if(peopleIds.size()>0){
                disableSites(peopleIds);
            }          
            if(disconnectList.size()>0){
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                SIMPESAPI.accessController().deleteAsUser(disconnectList);
            }
            if(peopleIds.size()>0){
                NotificationDispatcher.userIntegrationTokenExpireSendEmailSaveLogs(peopleIds,'Slack');
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
            Utility.sendExceptionEmail('BatchCheckUserSlackIntegration', exceptionDetailsObj);
        }
        if(runNext){
            BatchCheckUserServiceNowIntegration serviceNowBatch = new BatchCheckUserServiceNowIntegration(runNext);
            Database.executeBatch(serviceNowBatch, 100);
        }
    }

    /**
     * @description make api callout to validate slack token
     * @param peopleInt
	 * @return Boolean Success/Fail
     */
    public Boolean validateSlackToken(People_Integration__c peopleInt){
        Boolean isSuccess = false;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        String endPoint = 'https://slack.com/api/auth.test';
        req.setEndpoint(endPoint);
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setBody('token='+peopleInt.Access_Token__c);
        req.setMethod('POST');
        req.setTimeout(120000);
        HttpResponse resObj = h.send(req);
        if (resObj.getStatusCode()== 200) { 
            String resBodyJSON = resObj.getBody();
            Map<String,Object> resBody = (Map<String,Object>)JSON.deserializeUntyped(resBodyJSON);
            if(String.valueOf(resBody.get('ok')) == 'false') {
                isSuccess = false;
            }
            else if(String.valueOf(resBody.get('ok')) == 'true'){
                isSuccess = true;
            } 
        }
        return isSuccess;
    }

    /**
     * @description disable slack on sites where site manager's slack is disabled
     * @param peopleIds
     */
    public void disableSites(Set<Id> peopleIds){
        Map<String, Object> soqlParamMap = new Map<String, Object>();
		List<Simpplr_Site__c> siteObjList = new List<Simpplr_Site__c>();
		soqlParamMap.put('soqlParam1', peopleIds);
		String query = 'SELECT Id, Slack_Access_Token__c, Slack_Channel_Name__c, ' +
			' Slack_Channel_Id__c, Slack_Url__c, Slack_Post_Enabled__c, ' +
            ' Slack_Integration_Enabled__c, Slack_Comment_Enabled__c, Slack_Site_Manager__c ' +
			' FROM Simpplr_Site__c '+
			' WHERE Slack_Site_Manager__c in: soqlParam1 ';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        siteObjList = (List<Simpplr_Site__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
        for(Simpplr_Site__c  config : siteObjList) {
            config.Slack_Access_Token__c = null;
            config.Slack_Channel_Name__c = null;
            config.Slack_Channel_Id__c = null;
            config.Slack_Url__c = null;
            config.Slack_Post_Enabled__c = false;
            config.Slack_Integration_Enabled__c = false;
            config.Slack_Comment_Enabled__c = false;
            config.Slack_Site_Manager__c = null;
        }
        if(siteObjList.size() >0){
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(new Map<id, Simpplr_Site__c>(siteObjList), 
                                                        new List<Schema.SObjectField>{
                                                            Simpplr_Site__c.Slack_Access_Token__c,
                                                            Simpplr_Site__c.Slack_Channel_Name__c,
                                                            Simpplr_Site__c.Slack_Channel_Id__c,
                                                            Simpplr_Site__c.Slack_Url__c,
                                                            Simpplr_Site__c.Slack_Post_Enabled__c,
                                                            Simpplr_Site__c.Slack_Integration_Enabled__c,
                                                            Simpplr_Site__c.Slack_Comment_Enabled__c,
                                                            Simpplr_Site__c.Slack_Site_Manager__c});
        }
    }
}