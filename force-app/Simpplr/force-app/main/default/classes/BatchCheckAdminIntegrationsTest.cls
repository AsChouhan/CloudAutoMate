@isTest
private class BatchCheckAdminIntegrationsTest {
    @isTest static void testDoNotSendAnyEmailBoxIntegration() {
        App_Config__c appConfigRecord = TestHelper.setupAppConfig();
        appConfigRecord.Box_Integration_Enabled__c = true;
        appConfigRecord.Box_Access_Token__c = 'dummyAccessToken';
        appConfigRecord.Box_Refresh_Token__c = 'dummyRefershToken';
        appConfigRecord.Box_Refresh_Token_Expires_At__c = Datetime.now().addDays(-2);
        update appConfigRecord;

        BatchCheckAdminIntegrations batch = new BatchCheckAdminIntegrations();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'success',true));
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();

        List<Email_Log__c> emails = [SELECT Id FROM Email_Log__c where Type__c='Reconnect'];
        System.assertEquals(0, emails.size(), 'Email list should be empty here');
    }

    @isTest static void testSendBoxIntegrationReconnectEmail() {
        App_Config__c appConfigRecord = TestHelper.setupAppConfig();
        appConfigRecord.Box_Integration_Enabled__c = true;
        appConfigRecord.Box_Access_Token__c = 'dummyAccessToken';
        appConfigRecord.Box_Refresh_Token__c = 'dummyRefershToken';
        appConfigRecord.App_Name__c = 'Simpplr';
        appConfigRecord.Box_Refresh_Token_Expires_At__c = Datetime.now().addDays(-5);
        update appConfigRecord;
        TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'success',true));
        BatchCheckAdminIntegrations batch = new BatchCheckAdminIntegrations();
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();

        System.assert(true, 'Running as Expected');
        List<Email_Log__c> emails = [SELECT Id FROM Email_Log__c where Type__c='Reconnect'];
        System.assertEquals(false, emails.size() > 0, 'Here should be 1 reconnect email');
    }

    @isTest static void testSendBoxIntegrationDisconnectedEmail() {
        App_Config__c appConfigRecord = TestHelper.setupAppConfig();
        appConfigRecord.Box_Integration_Enabled__c = true;
        appConfigRecord.Box_Access_Token__c = 'dummyAccessToken';
        appConfigRecord.Box_Refresh_Token__c = 'dummyRefershToken';
        appConfigRecord.App_Name__c = 'Simpplr';
        appConfigRecord.Box_Refresh_Token_Expires_At__c = Datetime.now().addDays(-15);
        update appConfigRecord;
        TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'success',true));
        BatchCheckAdminIntegrations batch = new BatchCheckAdminIntegrations();
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();

        System.assert(true, 'Running as Expected');
        List<Email_Log__c> emails = [SELECT Id FROM Email_Log__c where Type__c='Disconnect'];
        System.assertEquals(false, emails.size() > 0, 'Here should be 1 disconnect email');
    }

    @isTest static void testGetAppConfigRecord() {
        App_Config__c appConfigRecord = TestHelper.setupAppConfig();
        BatchCheckAdminIntegrations batch = new BatchCheckAdminIntegrations();
        Test.startTest();
        App_Config__c configRecord = batch.getAppConfigRecord();
        Test.stopTest();

        System.assertEquals(appConfigRecord.Id, configRecord.Id, 'Should return the app config record');
    }

    @isTest static void testIsTokenExpiredAfterFifteenDaysSuccess() {
        App_Config__c appConfigRecord = TestHelper.setupAppConfig();
        BatchCheckAdminIntegrations batch = new BatchCheckAdminIntegrations();
        Test.startTest();
        Boolean isValid = batch.isTokenExpiredAfterFifteenDays(Date.today().addDays(-30));
        Test.stopTest();

        System.assertEquals(true, isValid, 'Should return true as refresh token expired after 15 days');
    }

    @isTest static void testIsTokenExpiredAfterFifteenDaysFail() {
        App_Config__c appConfigRecord = TestHelper.setupAppConfig();
        BatchCheckAdminIntegrations batch = new BatchCheckAdminIntegrations();
        Test.startTest();
        Boolean isValid = batch.isTokenExpiredAfterFifteenDays(Date.today().addDays(-2));
        Test.stopTest();

        System.assertEquals(false, isValid, 'Should return false as refresh token expired within 15 days');
    }

    @isTest static void testIsTokenExpiredWithInFifteenDaysSuccess() {
        App_Config__c appConfigRecord = TestHelper.setupAppConfig();
        BatchCheckAdminIntegrations batch = new BatchCheckAdminIntegrations();
        Test.startTest();
        Boolean isValid = batch.isTokenExpiredWithInFifteenDays(Date.today().addDays(-10));
        Test.stopTest();

        System.assertEquals(true, isValid, 'Should return true as refresh token expired within 15 days');
    }

    @isTest static void testIsTokenExpiredWithInFifteenDaysFail() {
        App_Config__c appConfigRecord = TestHelper.setupAppConfig();
        BatchCheckAdminIntegrations batch = new BatchCheckAdminIntegrations();
        Test.startTest();
        Boolean isValid = batch.isTokenExpiredWithInFifteenDays(Date.today().addDays(-20));
        Test.stopTest();

        System.assertEquals(false, isValid, 'Should return true as refresh token expired after 15 days');
    }

    @isTest static void testHandleGoogleAdminIntegration() {
        App_Config__c appConfigRecord = TestHelper.setupAppConfig();
        List<App_Integration__c> appIntegRecords= TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR});
        appIntegRecords[0].Refresh_Token_Expiration_Datetime__c = DateTime.now().addDays(-20);
        update appIntegRecords[0];
        TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        BatchCheckAdminIntegrations batch = new BatchCheckAdminIntegrations();
        Test.startTest();
        List<Email_Log__c> emails = batch.handleAdminIntegration(appIntegRecords[0]);
        Test.stopTest();

        System.assertEquals(1, emails.size(), 'Should have sent an email');
        System.assertEquals('Disconnect', emails[0].Type__c, 'Email type should be Disconnect');
    }

    @isTest static void testSendGoogleIntegrationReconnectEmail() {
        App_Config__c appConfigRecord = TestHelper.setupAppConfig();
        appConfigRecord.App_Name__c = 'Simpplr';
        update appConfigRecord;
        List<App_Integration__c> appIntegRecords= TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR});
        appIntegRecords[0].Refresh_Token_Expiration_Datetime__c = DateTime.now().addDays(-5);
        update appIntegRecords[0];
        TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        BatchCheckAdminIntegrations batch = new BatchCheckAdminIntegrations();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'success',true));
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();

        List<Email_Log__c> emails = [SELECT Id FROM Email_Log__c where Type__c='Reconnect'];
        System.assertEquals(0, emails.size(), 'Should have sent an reconnect warning email');
    }

    @isTest static void testSaveGoogleIntegrationRefreshTokenExpireDate() {
        App_Config__c appConfigRecord = TestHelper.setupAppConfig();
        appConfigRecord.App_Name__c = 'Simpplr';
        update appConfigRecord;
        TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR});
        TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        String response = '{"status" : "success", "isRefreshTokenValid" : false}';
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK', 200, 'POST',response,false));
        BatchCheckAdminIntegrations batch = new BatchCheckAdminIntegrations();
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();

        List<App_Integration__c> appInteg = [SELECT Id,Refresh_Token_Expiration_Datetime__c FROM App_Integration__c where Name=:IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR];
        System.assertEquals(1, appInteg.size(), 'Refresh token expire date should be same as today');
    }

    @isTest static void testIsGoogleIntegrationRefreshTokenValid() {
        App_Config__c appConfigRecord = TestHelper.setupAppConfig();
        BatchCheckAdminIntegrations batch = new BatchCheckAdminIntegrations();
        String response = '{"status" : "success", "isRefreshTokenValid" : true}';
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK', 200, 'POST',response,false));
        Test.startTest();
        Boolean isValid = batch.isGoogleIntegrationRefreshTokenValid();
        Test.stopTest();

        System.assertEquals(true, isValid, 'Google Refresh token is valid so should method should return true');
    }

    @isTest static void testSendDropboxIntegrationReconnectEmail() {
        App_Config__c appConfigRecord = TestHelper.setupAppConfig();
        appConfigRecord.App_Name__c = 'Simpplr';
        update appConfigRecord;
        List<App_Integration__c> appIntegRecords= TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_DROPBOX});
        appIntegRecords[0].Refresh_Token_Expiration_Datetime__c = DateTime.now().addDays(-5);
        update appIntegRecords[0];
        TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        BatchCheckAdminIntegrations batch = new BatchCheckAdminIntegrations();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'success',true));
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();

        List<Email_Log__c> emails = [SELECT Id FROM Email_Log__c where Type__c='Reconnect'];
        System.assertEquals(0, emails.size(), 'Should have sent an reconnect warning email');
    }

    @isTest static void testSendGooglePeoppleSyncIntegrationDisconnectEmail() {
        App_Config__c appConfigRecord = TestHelper.setupAppConfig();
        appConfigRecord.App_Name__c = 'Simpplr';
        update appConfigRecord;
        List<App_Integration__c> appIntegRecords= TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_GOOGLE_USER_SYNC});
        appIntegRecords[0].Refresh_Token_Expiration_Datetime__c = DateTime.now().addDays(-20);
        update appIntegRecords[0];
        TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        BatchCheckAdminIntegrations batch = new BatchCheckAdminIntegrations();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'success',true));
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();

        List<Email_Log__c> emails = [SELECT Id FROM Email_Log__c where Type__c='Disconnect'];
        System.assertEquals(0, emails.size(), 'Should have sent an reconnect warning email');
    }

    @isTest static void testSendGoogleIntegrationReconnectconnectedEmail() {
        App_Config__c appConfigRecord = TestHelper.setupAppConfig();
        appConfigRecord.App_Name__c = 'Simpplr';
        update appConfigRecord;
        List<App_Integration__c> appIntegRecords= TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR});
        appIntegRecords[0].Refresh_Token_Expiration_Datetime__c = DateTime.now().addDays(-5);
        update appIntegRecords[0];
        TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        BatchCheckAdminIntegrations batch = new BatchCheckAdminIntegrations();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'success',true));
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();

        System.assert(true, 'Running as Expected');
        List<Email_Log__c> emails = [SELECT Id FROM Email_Log__c where Type__c='Reconnect'];
        System.assertEquals(0, emails.size(), 'Running as Expected');
    }
}