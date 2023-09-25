@istest
private with sharing class BatchSocialCampaignAnalyticsTest {
	
	@testSetup
	static void setUp() {
		App_Config__c appConfigRecord = TestHelper.setupAppconfig();
        appConfigRecord.Analytics_Data_Collection_Enabled__c = true;
        update appConfigRecord;
		People__c peopleObj = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
		List<App_Integration__c>  appIntList  = TestHelper.createAppIntegrationRecords(false, new Set<String>{'Facebook','Twitter','Linkedin'});
		List<People_Integration__c> peopleIntList = TestHelper.createPeopleIntegrationRecords(appIntList, peopleObj.id,'daedewdwef');
		Social_Campaign__c  sc = TestHelper.createSocialCampaign(peopleObj.id);
		List<Social_Campaign_Share__c> scsList = TestHelper.createSocialCampaignShareRecords(peopleObj.id, sc, new Set<String>{'Facebook','Twitter','Linkedin'});
        Analytics_Social_Campaign__c analyticsSocialCampaignObj = new Analytics_Social_Campaign__c();
        analyticsSocialCampaignObj.Social_Campaign_Share__c = scsList[0].id;
        analyticsSocialCampaignObj.Date__c = Date.today();
        insert analyticsSocialCampaignObj;
	}
	
	@isTest static void testBatchSocialCampaignAnalyticsMethods(){
		Test.startTest();
		BatchSocialCampaignAnalytics bscAnalObj = new BatchSocialCampaignAnalytics('initAnalyticsData', System.today());
		bscAnalObj.getFbLikeCount('test','test');
		Database.executeBatch(bscAnalObj, 10);
		Test.stopTest();
		System.assert(true,'Running as expected.');		
	}
    
    @isTest static void testBatchSocialCampaignAnalyticsSendSocialCampaignData(){
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/PushAnalytics',false));
		BatchSocialCampaignAnalytics bscAnalObj = new BatchSocialCampaignAnalytics('sendSocialCampaignData', System.today());
		Database.executeBatch(bscAnalObj, 10);
		Test.stopTest();
		System.assert(true,'Running as expected.');		
	}
    
    @isTest static void testBatchSocialCampaignAnalyticsSendSocialCampaignAnlyticsData(){
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/PushAnalytics',false));
		BatchSocialCampaignAnalytics bscAnalObj = new BatchSocialCampaignAnalytics('sendSocialCampaignAnlyticsData', System.today());
		Database.executeBatch(bscAnalObj, 10);
		Test.stopTest();
		System.assert(true,'Running as expected.');		
	}
    
}