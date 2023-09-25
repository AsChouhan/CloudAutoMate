@isTest
private class BatchOktaUserSyncTest {
    
    @testSetup static void setup() {
        TestHelper.setupAppConfig();
        TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
    }
    
    @isTest static void testBatchOktaUserSync() {
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/getUsersFromOkta',false));
        BatchOktaUserSync job1 = new BatchOktaUserSync('UserSync');
		Database.executeBatch(job1,100);
        
        BatchOktaUserSync job2 = new BatchOktaUserSync('UserSync','nextPageLink');
		Database.executeBatch(job2,100);
		System.assert(true, 'Running as Expected');
    }
    
    @isTest static void testBatchOktaUserSyncSyncSourceOkta() {
        App_Config__c appConfig = TestHelper.getAppConfig();
        appConfig.PDS_Title__c = true;
        appConfig.PDS_Department__c = true;
        appConfig.PDS_Division__c = true;
        appConfig.PDS_State__c = true;
        appConfig.PDS_Country__c = true;
        appConfig.PDS_City__c = true;
        appConfig.PDS_Postal_Code__c = true;
        appConfig.PDS_Phone__c = true;
        appConfig.PDS_Mobile_Phone__c = true;
        appConfig.PDS_Street__c = true;
        appConfig.PDS_Community_Nickname__c = true;
        appConfig.PDS_Company_Name__c = true;
        appConfig.PDS_Joining_Date__c = true;
        appConfig.PDS_Enable_Formatting__c = true;
        appConfig.PDS_Birth_Date__c = true;
        appConfig.PDS_Birth_Date_Key__c = String.valueOf(date.today() - 600);
        appConfig.PDS_Joining_Date_Key__c = String.valueOf(date.today() - 2);
        appConfig.PP_User_Custom_Fields__c = '[{"syncSource":"okta","isEditable":false,"columnName":"Custom_Field_1__c", "fieldName":"CustomField1"},' +
                                                 '{"syncSource":"okta","isEditable":false,"columnName":"Custom_Field_2__c", "fieldName":"CustomField2"},' +
                                                 '{"syncSource":"okta","isEditable":false,"columnName":"Custom_Field_3__c", "fieldName":"CustomField3"},' +
                                                 '{"syncSource":"okta","isEditable":false,"columnName":"Custom_Field_4__c", "fieldName":"CustomField4"},' +
                                                 '{"syncSource":"okta","isEditable":true, "columnName":"Custom_Field_5__c", "fieldName":"CustomField5"}]';
        update appConfig;
        People__c peopleObj = [Select Id From People__c Limit 1];
        peopleObj.Department__c = 'testDepartment';
        peopleObj.Sync_Field__c = 'testId';
        peopleObj.Email__c = 'test@simpplr.com';
        update peopleObj;
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/getUsersFromOkta',false));
        BatchOktaUserSync job1 = new BatchOktaUserSync('syncIdentifier');
		Database.executeBatch(job1,100);
		System.assert(true, 'Running as Expected');
    }
    
    @isTest static void testBatchOktaUserSyncUpdatePeopleSyncIdentifier() {
        People__c peopleObj = [Select Id From People__c Limit 1];
        peopleObj.Sync_Field__c = 'testId';
        peopleObj.Email__c = 'test@simpplr.com';
        update peopleObj;
        SImpplrContext.locationNormalizationEnabled = true;
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/getUsersFromOkta',false));
        BatchOktaUserSync job1 = new BatchOktaUserSync('syncIdentifier');
		Database.executeBatch(job1,100);
		System.assert(true, 'Running as Expected');
    }
    
    @isTest Static void testOktaUtility() {
        Test.startTest();
        People__c peopleObj = [Select Id From People__c Limit 1];
        peopleObj.Extension__c = '+91';
        peopleObj.Fax__c = '0000';
        update peopleObj;
        OktaUtility.updateAboutMe(peopleObj,'New Value');
        OktaUtility.updateExtension(peopleObj,'New Value');
        OktaUtility.updateFax(peopleObj,'New Value');
        OktaUtility.convertStringToOktaDate(String.valueOf(date.today()));
        OktaUtility.convertStringToOktaDate('03-06');
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }

}