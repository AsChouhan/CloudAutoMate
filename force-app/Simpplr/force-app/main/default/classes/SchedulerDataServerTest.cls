@isTest 
private class SchedulerDataServerTest {
    
    @testSetup static void setup() {
    	App_Config__c appConfig = TestHelper.setupAppConfig();
        appConfig.Simpplr_Top_Stories_Emails_Allowed__c = true;
        update appConfig;
        
        Simpplr_Metadata__c simpplrMetadataObj = new Simpplr_Metadata__c();
        simpplrMetadataObj.Type__c = ServiceConstants.SIMPPLR_SCHEDULE_JOB;
        simpplrMetadataObj.Value__c = '[{"setOfApexClass":["BatchInsertPeopleRecords"],"size":200,"cron_exp":"0 10 0 * * ?","description":"Scheduler job to get new people records.","name":"SchedulerBatchInsertPeopleRecords"}]';
        insert simpplrMetadataObj;
    }
    
    private static Simpplr_Metadata__c getSimpprlMetadata() {
        Simpplr_Metadata__c simmplrMetadata = [Select Id From Simpplr_Metadata__c Limit 1];
        return simmplrMetadata;
    }
    
    @isTest static void testActionSearch() {
        Test.startTest();
        PageReference pageRef = Page.DataServerRO;
		SchedulerDataServer schedulerDSObj = new SchedulerDataServer();
    	pageRef.getParameters().put('target','SchedulerDataServer');
        pageRef.getParameters().put('action','search');
        Test.setCurrentPage(pageRef);
        schedulerDSObj.handleRequest();
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testActionRunSchedulerNow() {
        Test.startTest();
        
        PageReference pageRef = Page.DataServerRO;
		SchedulerDataServer schedulerDSObj = new SchedulerDataServer();
    	pageRef.getParameters().put('target','SchedulerDataServer');
        pageRef.getParameters().put('action','runSchedulerNow');
        Test.setCurrentPage(pageRef);
        schedulerDSObj.handleRequest();
        
        pageRef.getParameters().put('data','["SchedulerBatchInsertPeopleRecords"]');
        schedulerDSObj.handleRequest();
        SimpplrContext.aiFeaturesEnabled='110000000';
        
        Simpplr_Metadata__c simpplrMetadataObj = getSimpprlMetadata();
        simpplrMetadataObj.Value__c = '[{"setOfApexClass":["BatchTopStories"],"size":50,"cron_exp":"0 30 0 * * ?","description":"Scheduler job for daily top story digest","name":"SchedulerBatchTopStories"}]';
        update simpplrMetadataObj;
        pageRef.getParameters().put('data','["SchedulerBatchTopStories"]');
        schedulerDSObj.handleRequest();
        
        simpplrMetadataObj.Value__c = '[{"setOfApexClass":["BatchNotificationDigest"],"size":100,"cron_exp":"0 50 0 * * ?","description":"Scheduler job for daily Notification digest","name":"SchedulerBatchNotificationDigest"}]';
        update simpplrMetadataObj;
        pageRef.getParameters().put('data','["SchedulerBatchNotificationDigest"]');
        schedulerDSObj.handleRequest();
        
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testActionSchduleSchdulerNow() {
        Test.startTest();
        Simpplr_Metadata__c simpplrMetadataObj = getSimpprlMetadata();
        simpplrMetadataObj.Value__c = '[{"setOfApexClass":["BatchPendingApprovalDigest"],"size":100,"cron_exp":"0 1 0,4,8,12,16,20 * * ?","description":"Scheduler job for sending pending approval digest","name":"SchedulerBatchPendingApprovalDigest"}]';
        update simpplrMetadataObj;
        PageReference pageRef = Page.DataServerRO;
		SchedulerDataServer schedulerDSObj = new SchedulerDataServer();
    	pageRef.getParameters().put('target','SchedulerDataServer');
        pageRef.getParameters().put('action','schduleSchdulerNow');
        Test.setCurrentPage(pageRef);
        schedulerDSObj.handleRequest();
        
        pageRef.getParameters().put('data','["SchedulerBatchPendingApprovalDigest"]');
        schedulerDSObj.handleRequest();
        
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testActionClear() {
        Test.startTest();
        PageReference pageRef = Page.DataServerRO;
		SchedulerDataServer schedulerDSObj = new SchedulerDataServer();
    	pageRef.getParameters().put('target','SchedulerDataServer');
        pageRef.getParameters().put('action','clear');
        Test.setCurrentPage(pageRef);
        schedulerDSObj.handleRequest();
        
        pageRef.getParameters().put('data','["SchedulerBatchInsertPeopleRecords"]');
        schedulerDSObj.handleRequest();
        
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testNoAction() {
        Test.startTest();
        PageReference pageRef = Page.DataServerRO;
		SchedulerDataServer schedulerDSObj = new SchedulerDataServer();
        schedulerDSObj.getPageFeature();
        
    	pageRef.getParameters().put('target','SchedulerDataServer');
        Test.setCurrentPage(pageRef);
        schedulerDSObj.handleRequest();
        
        pageRef.getParameters().put('action','###');
        schedulerDSObj.handleRequest();
        
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
}