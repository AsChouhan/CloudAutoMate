/**
 * @description Test BatchUpdatePeopleLicence batch 
 */
@isTest private class BatchUpdatePeopleLicenceTest {

    @TestSetup static void setup() {
        TestHelper.setupAppConfig();
        TestHelper.createUser('systemAdmin', null, true);
        TestHelper.createPeopleRecordForUser(UserContext.id);
    }
    
    @isTest static void testBatchUpdatePeopleLicence() {
        Test.startTest();
            String batchprocessid = DataBase.executeBatch(new BatchUpdatePeopleLicence('syncLicenseFlagToTrue'),5);
        Test.stopTest();
        AsyncApexJob currentJob = [SELECT Id, Status, NumberOfErrors FROM AsyncApexJob WHERE Id = :batchprocessid];
        System.assertEquals(true, (currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0), 'Running as expected');
    }
}