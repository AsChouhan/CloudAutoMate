public with sharing class comboBoxApexController {
    @AuraEnabled
    public static List<sObject> getRecords(String query){
        try {
            List<sObject> records = Database.query(query);
            System.debug(records.size());
            return records;
        } catch (Exception e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<sObject> getSortedRecords(String str){
        List<sObject> records = new List<sObject>();
        String query = 'select  Id,Name,Rating from account where name like \''+str+'%\''; 
        records = Database.query(query);
        System.debug(records.size());
        return records;
    }
}