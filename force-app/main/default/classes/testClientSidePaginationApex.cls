@isTest
private class testClientSidePaginationApex {
   @isTest
   static void testgetObjectList(){
        List<ClientSidePaginationApex.ObjectWrapperClass> rsltnt = new List<ClientSidePaginationApex.ObjectWrapperClass>();
        rsltnt = ClientSidePaginationApex.getObjectList();
        System.assertEquals('Account', rsltnt[0].label);
   }

   @isTest
   static void testgetObjectFields(){
        String objectName = 'Account';
        List<ClientSidePaginationApex.ObjectWrapperClass> rsltnt = new List<ClientSidePaginationApex.ObjectWrapperClass>();
        rsltnt = ClientSidePaginationApex.getObjectFields(objectName);
        System.assertEquals('Account Description', rsltnt[0].label);
   }

   @isTest
   static void testgetRecords(){
        List<Account> listOfAcc = sspFactory.createAccounts(100);
        String objectName = 'Account';
        List<String> fields = new List<String>();
        fields.add('Amount__c');
        fields.add('Rating');
        fields.add('Active__c');
        List<sObject> rsltnt = ClientSidePaginationApex.getRecords(fields, objectName);
        System.assertEquals(rsltnt.size()!=0, true);
   }


}