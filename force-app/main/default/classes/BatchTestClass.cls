@isTest
private class BatchTestClass {
    @isTest
    private static void testBatchApex(){
        List<Contact> cList = new List<Contact>();
        Datetime yesterday = Datetime.now().addDays(-1);
        for(Integer i=0;i<200;i++){
            contact ct = new Contact(Lastname = 'aasheesh');
            cList.add(ct);
        }
        insert cList;
        for(contact ctt : cList){
            Test.setCreatedDate(ctt.Id, yesterday);  
        }
        Test.startTest();
        BatchAssignment ba = new BatchAssignment();
        Database.executeBatch(ba);
        Test.stopTest();


        List<Contact> tempClist = new List<Contact>();

        tempClist = [SELECT name,status__c from contact where status__c = 'Ready For Approval'];
        System.assertEquals(tempClist.size() == cList.size(),true);
    }
}