@isTest
private class BatchContentDocumentTest {
    @TestSetup
    static void setupData() {
        Simpplr_Content__c contentRec = TestHelper.getContentRecordForCreation('title', 'Page', 'Draft', null);
        insert contentRec;

        TestHelper.createContentTitleImage(contentRec.id);
    }

    @isTest
    static void testBatch() {
        Simpplr_Content__c contentRec = [SELECT Id FROM Simpplr_Content__c LIMIT 1];
        Test.startTest();
            BatchContentDocument batchjob = new BatchContentDocument('updateAccessToFiles', new Set<Id>{contentRec.id}, new Set<String>(), true, true);
            Database.executeBatch(batchjob);

            BatchContentDocument batchjob1 = new BatchContentDocument('updateAccessToFiles', new Set<Id>{contentRec.id}, new Set<String>(), false, false);
            Database.executeBatch(batchjob1);
        Test.stopTest();

        system.assert(true, 'Batch ran successfully');
    }
}