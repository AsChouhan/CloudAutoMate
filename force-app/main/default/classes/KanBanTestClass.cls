@isTest
private class KanBanTestClass {
	@isTest
    static void testForObjectList() {
        List<newKanbanController.ObjPickListValues> check = new List<newKanbanController.objPickListValues>();
        Test.startTest();
            check = newKanbanController.objectsList();
        Test.stopTest();
        System.assertEquals('Account', check[0].label);
    }
    
    @isTest 
    static void testForFieldPicklist() {
        List<newKanbanController.ObjPickListValues> check = new List<newKanbanController.objPickListValues>();
        Map<Integer, List<newKanbanController.ObjPickListValues>> Map1 = new Map<Integer, List<newKanbanController.ObjPickListValues>>();
        
        Test.startTest();
            Map1 = newKanbanController.fieldsList('Account');
        	check = Map1.get(1);
        Test.stopTest();
        System.assertEquals('Account Rating', check[0].label);
    }
    
    @isTest
    static void testForGetPLValues() {
        List<String> check = new List<String>();
        Test.startTest();
        	check = newKanbanController.getPLValues('Rating', 'Account');
        Test.stopTest();
        System.assertEquals('Hot', check[0]);
    }
    
    @isTest
    static void testForGetRelRec() {
        List<String> fields = new List<String>{'Amount__c','AccountNumber'};
       
        List<Account> acc = new List<Account>{new Account(Name = 'tempAcc', Rating = 'Cold')};
        Map<String, List<sObject>> map2 = new Map<String, List<sObject>>();
        insert acc;
        Map<String, List<sObject>> check = new Map<String, List<sObject>>();
        Test.startTest();
        	check = newKanbanController.getRelRec('Account', 'Rating',fields);
        Test.stopTest();
        System.assertEquals(acc, check.get('Cold'));
    }
    
    @isTest
    static void testForUpdateElement() {
        Account acc = new Account(Name = 'tempAcc', Rating = 'Hot');
        insert acc;
        Test.startTest();
        	newKanbanController.updateElement(String.valueOf(acc.id), 'Cold', 'Rating', 'Account');
        Test.stopTest();
        Account check = [SELECT Id, Name, Rating FROM Account WHERE id = :acc.id];
        System.assertEquals('Cold',check.Rating);
    }
}