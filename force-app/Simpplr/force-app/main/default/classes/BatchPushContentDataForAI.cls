public with sharing class BatchPushContentDataForAI implements Database.Batchable<SObject>, Database.stateful,Database.AllowsCallouts {
	private Exception exceptionDetailsObj;

	public database.querylocator start(Database.BatchableContext bc) {
                String query = ' SELECT Id, Text_Intro__c, Title__c, ' +
                                        ' Site__c, Site__r.Site_Type__c, Type__c, Pages_Category__r.Name__c, Publish_Start_DateTime__c, Publish_End_DateTime__c ' +
                                        ' FROM Simpplr_Content__c WHERE Is_Deleted__c = false AND Is_Unpublished__c = false ';
                                        
                return Database.getQueryLocator(query);
	}
	
	public void execute(Database.BatchableContext bc, sObject[] listOfsObject) {
                try {
                        List<Simpplr_Content__c> listOfContent = (List<Simpplr_Content__c>) listOfsObject;
                        PushDataHelperForAI pushDataHelperForAIObj = new PushDataHelperForAI();
                        List<AIWrapper.ContentWrapper> dataToBePushed = pushDataHelperForAIObj.convertSimpplrContentListToAIDataWrapperList(listOfContent);
                        String jsonBody = Json.serialize(dataToBePushed);
                        HttpResponse res = pushDataHelperForAIObj.pushDataForIndexing(jsonBody);
                        if(res.getStatusCode() != 200){
                                throw new SimpplrException(res.getStatusCode() + ' received, Response Body is ' + res.getBody());
                        }
                } catch(Exception e) {
                        exceptionDetailsObj =  e;
		        throw e;
                }
        }
	
	public void finish(Database.BatchableContext bc) {
            AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
            
            if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
                PushDataHelperForAI pushDataHelperForAIObj = new PushDataHelperForAI();
                if(!Test.isRunningTest()) { pushDataHelperForAIObj.recommendationsSetUp(); }
            } else {
                Utility.sendExceptionEmail('BatchPushContentDataForAI', exceptionDetailsObj);
            }

        }
}