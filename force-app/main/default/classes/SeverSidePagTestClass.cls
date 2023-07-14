@IsTest
private class SeverSidePagTestClass {
	@IsTest
    static void testgetObjectList(){
        System.assert(ServerSidePaginationClass.getObjectList().size()!=0,true);
    }

    @IsTest
    static void testgetObjectFields(){
        String objectName = 'Contact';
        System.assert(ServerSidePaginationClass.getObjectFields(objectName).size()!=0,true);
    }

    @IsTest
    static void testgetRecords(){

        List<Account> listOfAcc = sspFactory.createAccounts(100);

        Integer pageSize = 10;
        List<String> field = new List<String>{'Amount__c','Rating','Industry','Active__c'};
        String objectName = 'Account';
        Integer pageNumber = 1;

        System.assert(ServerSidePaginationClass.getRecords(pageSize,field,objectName,pageNumber).records.size()!=0,true);
    }

    @IsTest
    static void testsortRecords(){
        List<Account> listOfAcc = sspFactory.createAccounts(100);
        Integer pageSize = 10;
        List<String> field = new List<String>{'Amount__c','Rating','Industry','Active__c'};
        String objectName = 'Account';
        Integer pageNumber = 1;
        String sortDir = 'asc';
        String fieldName = 'Amount__c';
        List<Id> ids = new List<Id>();
        List<sObject> sObj = ServerSidePaginationClass.getRecords(pageSize,field,objectName,pageNumber).records;
        for(sObject sob : sObj){
            ids.add(sob.Id);
        }
        List<SObject> tempObj = ServerSidePaginationClass.sortRecords(ids,field,objectName,fieldName,sortDir);
        System.assert(tempObj.size() == sObj.size(),true);
    }
}