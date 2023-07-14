public with sharing class Tree_Grid_Handler {
    @AuraEnabled
    public static List<sObject> getAccounts(){
        List<sObject> sobList = [select name from account];
        return sobList;
    }

    @AuraEnabled
    public static List<sObject> sendChildRecord(List<String> parentId){
        List<sObject> childRecords = [select id, (select id, name from contacts), (select id, name from Opportunities) from Account where id in: parentId];

        // Map<id, List<Map<String, List<sobject>>>> childObjectRecord  = new Map<id, List<Map<String, List<sObject>>>>();
        // Map<String, List<sobject>> tempMap
        // for(Account ac : childRecords){
        //     if(!childObjectRecord.containsKey(ac.id)){
        //         childObjectRecord.put(ac.id, new List<Map<String, List<sobject>>>());
        //     }
        //     if(!childObjectRecord.get(ac.id).)
        // }
        return childRecords;
    }
}