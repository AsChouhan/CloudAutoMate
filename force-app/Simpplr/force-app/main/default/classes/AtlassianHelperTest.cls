@isTest 
private class AtlassianHelperTest {
    static App_Config__c appConfig;
    static People__c currentUserPeopleObj; 
    
    @testSetup static void setup() {
        appConfig = TestHelper.setupAppConfig();
        currentUserPeopleObj = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        List<App_Integration__c>  appIntegList = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN});
        TestHelper.createPeopleIntegRecordForUser(UserCOntext.peopleId,IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN,appIntegList[0].id);
    }
    
    @isTest 
    static void testGetAdminAuthUrl() {
        Test.startTest();
        AtlassianHelper atHelper = new AtlassianHelper();
        String redirectURL = atHelper.getAdminAuthUrl();
        String assertStr = 'https://auth.atlassian.com/authorize?audience=api.atlassian.com&client_id=test_client_id&scope=read%3Aconfluence-content.summary+read%3Aconfluence-user+search%3Aconfluence+read%3Aconfluence-props+read%3Aconfluence-content.all+read%3Aconfluence-space.summary+read%3Ame+offline_access&redirect_uri=https%3A%2F%2Fapi.simpplr.com%2Foauth%2Fcallback-passthrough&response_type=code&prompt=consent&state=https%3A%2F%2Ftest.simpplr.com%2Foauth%2Fatlassian%3Fstate%3DstateString';
        System.assertEquals(assertStr, redirectURL, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest 
    static void testGetPeopleAuthUrl() {
        Test.startTest();
        AtlassianHelper atHelper = new AtlassianHelper();
        String redirectURL = atHelper.getPeopleAuthUrl();
        String assertStr = 'https://auth.atlassian.com/authorize?audience=api.atlassian.com&client_id=test_client_id&scope=read%3Aconfluence-content.summary+read%3Aconfluence-user+search%3Aconfluence+read%3Aconfluence-props+read%3Aconfluence-content.all+read%3Aconfluence-space.summary+read%3Ame+offline_access&redirect_uri=https%3A%2F%2Fapi.simpplr.com%2Foauth%2Fcallback-passthrough&response_type=code&prompt=consent&state=https%3A%2F%2Ftest.simpplr.com%2Foauth%2Fatlassian%3Fstate%3DstateString';
        System.assertEquals(assertStr, redirectURL, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest 
    static void testUpsertAppIntegrationRecord() {
        Test.startTest();
        List<app_Integration__c> appIntRecordList;
        appIntRecordList = [SELECT Id, External_Id__c, User_Name__c, User_Email__c FROM App_Integration__c WHERE External_Id__c = 'atlassianID' LIMIT 1];
        System.assertEquals(0, appIntRecordList.size(), 'Running as expected');
        
        AtlassianHelper atHelper = new AtlassianHelper();
        Boolean result1 = atHelper.upsertAppIntegrationRecord('atlassianID','testUserName','test@atlassianadmin.com');
        System.assertEquals(true, result1, 'Running as expected');

        appIntRecordList = [SELECT Id, External_Id__c, User_Name__c, User_Email__c FROM App_Integration__c WHERE External_Id__c = 'atlassianID' LIMIT 1];
        System.assertEquals(1, appIntRecordList.size(), 'Running as expected');
        
        Boolean result2 = atHelper.upsertAppIntegrationRecord('atlassianID','testUserName','updatedemail@atlassian.test');
        System.assertEquals(true, result2, 'Running as expected');

        appIntRecordList = [SELECT Id, External_Id__c, User_Name__c, User_Email__c FROM App_Integration__c WHERE External_Id__c = 'atlassianID' LIMIT 1];
        System.assertEquals('updatedemail@atlassian.test', appIntRecordList[0].User_Email__c, 'Running as expected');

        Test.stopTest();       
    }
    
    @isTest 
    static void testCreatePeopleIntegrationRecord() {
        Test.startTest();
        AtlassianHelper atHelper = new AtlassianHelper();
        List<People_Integration__c> peopleIntRecordList;
        peopleIntRecordList = [SELECT Id, External_Id__c, User_Name__c, User_Email__c FROM People_Integration__c WHERE External_Id__c = 'atlassianID' LIMIT 1];
        System.assertEquals(0, peopleIntRecordList.size(), 'Running as expected');
        
        atHelper.createPeopleIntegrationRecord('atlassianID','testUserName','test@atlassianuser.com');
        peopleIntRecordList = [SELECT Id, External_Id__c, User_Name__c, User_Email__c FROM People_Integration__c WHERE External_Id__c = 'atlassianID' LIMIT 1];
        System.assertEquals(1, peopleIntRecordList.size(), 'Running as expected');
        Test.stopTest();
    }
}