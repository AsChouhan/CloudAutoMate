@IsTest
private class TriggerTestClass {
    
    @IsTest
    static void testInsert(){
        List<Account> testAccts = TriggerTestClassFactory.createAccounts(7);
        List<Contact> testContacts1 = TriggerTestClassFactory.createContactsMulti(200,testAccts[0],'ASC');
        List<Contact> testContacts2 = TriggerTestClassFactory.createContactsMulti(200,testAccts[1],'DESC');
        List<Contact> testContacts3 = TriggerTestClassFactory.createContactsOne(200,testAccts[2],null);
        List<Contact> testContacts4 = TriggerTestClassFactory.createContactsOne(200,testAccts[3],1);
        List<Contact> testContacts5 = TriggerTestClassFactory.createContactsOne(200,testAccts[4],0);
        List<Contact> testContacts6 = TriggerTestClassFactory.createContactsOne(200,testAccts[5],1000);
        
        Database.insert(testContacts2, true);
        Database.insert(testContacts3, true);

        Test.startTest();
            Database.insert(testContacts1, true);
            Database.insert(testContacts4, true);
            Database.insert(testContacts5, true);
            Database.insert(testContacts6, true);
        Test.stopTest();
        List<Contact> getList1 = [SELECT Id FROM Contact WHERE AccountId=:testAccts[0].Id];
        List<Contact> getList2 = [SELECT Id FROM Contact WHERE AccountId=:testAccts[1].Id];
        List<Contact> getList3 = [SELECT Id FROM Contact WHERE AccountId=:testAccts[2].Id];
        List<Contact> getList4 = [SELECT Id FROM Contact WHERE AccountId=:testAccts[3].Id];
        List<Contact> getList5 = [SELECT Id FROM Contact WHERE AccountId=:testAccts[4].Id];
        List<Contact> getList6 = [SELECT Id FROM Contact WHERE AccountId=:testAccts[5].Id];
        
        List<Contact> ctc = TriggerTestClassFactory.createContactsOne(50,testAccts[3],1);
        Database.insert(ctc, true);
        
        System.assertEquals(getList1.size() == 200, true);
        System.assertEquals(getList2.size() == 200, true);
        System.assertEquals(getList3.size() == 200, true);
        System.assertEquals(getList4.size() == 200, true);
        System.assertEquals(getList5.size() == 200, true);
        System.assertEquals(getList6.size() == 200, true);
    }

    @isTest
    static void testDelete(){
        List<Account> testAccts = TriggerTestClassFactory.createAccounts(3);
        List<Contact> testContacts = TriggerTestClassFactory.createContactsOne(10,testAccts[0],null);
        testContacts = TriggerTestClassFactory.createContactsOne(10,testAccts[1],null);
        testContacts = TriggerTestClassFactory.createContactsOne(10,testAccts[2],null);
        Database.insert(testContacts, true);
        List<Contact> con = [SELECT Id FROM Contact WHERE Name LIKE 'Test Contact 1'];
        List<Contact> conSeq = [SELECT Id,Sequence_Number__c FROM Contact WHERE Sequence_Number__c=10];
        con.addAll(conSeq);
        Test.startTest();
            Database.DeleteResult[] delRes = Database.Delete(con, true);
        Test.stopTest();

    }

    // Undelete test cases
    @isTest
    static void testUnDelete(){
        List<Account> testAccts = TriggerTestClassFactory.createAccounts(5);
        List<Contact> testContacts = TriggerTestClassFactory.createContactsOne(10,testAccts[0],null);
        testContacts = TriggerTestClassFactory.createContactsOne(10,testAccts[1],null);
        testContacts = TriggerTestClassFactory.createContactsOne(10,testAccts[2],null);
        testContacts = TriggerTestClassFactory.createContactsOne(10,testAccts[3],null);
        testContacts = TriggerTestClassFactory.createContactsOne(10,testAccts[4],null);
        Database.insert(testContacts, true);
        List<Contact> con = [SELECT Id FROM Contact WHERE Name LIKE 'Test Contact 1'];
        List<Contact> conSeq = [SELECT Id,Sequence_Number__c FROM Contact WHERE Sequence_Number__c=4];
        con.addAll(conSeq);
        Delete con;
        Test.startTest();
            Database.UndeleteResult[] unDelRes = Database.Undelete(con, true);
        Test.stopTest();
    }

    @isTest
    static void testUpdate(){
        List<Account> testAccts = TriggerTestClassFactory.createAccounts(2);
        List<Contact> testContacts1 = TriggerTestClassFactory.createContactsMulti(200,testAccts[0],'ASC');
        
      	insert testContacts1;
        List<Contact> getList1 = [SELECT Id,Sequence_Number__c,AccountId FROM Contact WHERE AccountId=:testAccts[0].Id];
        
        for(Contact con : getList1){
            if(con.Sequence_Number__c <= 100){
                con.AccountId = testAccts[1].Id;
            }
        }
        
        Test.startTest();
        update getList1;
        Test.stopTest();
        
        getList1 = [SELECT Id,Sequence_Number__c,AccountId FROM Contact WHERE AccountId=:testAccts[0].Id];
        for(contact ct : getList1){
            if(ct.Sequence_Number__c <= 50){
            	ct.Sequence_Number__c = 1;
            }else{
                ct.Sequence_Number__c = null;
            }
        }
        
        
        update getList1;
        

       List<Contact> newList1 = [SELECT Id,Sequence_Number__c,AccountId FROM Contact WHERE AccountId=:testAccts[0].Id];
       List<Contact> newList2 = [SELECT Id,Sequence_Number__c,AccountId FROM Contact WHERE AccountId=:testAccts[1].Id];
        
        System.assertEquals(newList1.size() == 100, true);
        System.assertEquals(newList2.size() == 100, true);
    }
}