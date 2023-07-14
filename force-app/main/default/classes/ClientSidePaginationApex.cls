public with sharing class ClientSidePaginationApex {
    public static Map<String,schema.SObjectType> objectMap = schema.getGlobalDescribe();

    // Wrapper class for object...........    
    public class ObjectWrapperClass{        
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String label;
        
        public ObjectWrapperClass(String value,String label){
            this.value = value;
            this.label = label;
        }
    } 

    @AuraEnabled      
    public static List<ObjectWrapperClass> getObjectList(){
        List<String> customLAbelObject = System.label.StObjects.split(',');
        List<ObjectWrapperClass> objectWrapper = new List<ObjectWrapperClass>();
        List<String> useForObjPLSort = new List<String>();

        for(String ObjectApi : objectMap.keySet()){
            if(objectMap.get(ObjectApi).getDescribe().isCustom()){
                objectWrapper.add(new ObjectWrapperClass(ObjectApi,objectMap.get(ObjectApi).getDescribe().getLabel()));
                useForObjPLSort.add(objectMap.get(ObjectApi).getDescribe().getLabel());
            }
        }
        for(String apiNameOfCustomLabel : customLAbelObject){
            objectWrapper.add(new ObjectWrapperClass(apiNameOfCustomLabel,objectMap.get(apiNameOfCustomLabel).getDescribe().getLabel()));
            useForObjPLSort.add(objectMap.get(apiNameOfCustomLabel).getDescribe().getLabel());
        }
        useForObjPLSort.sort();
        return sorting(useForObjPLSort, objectWrapper);
    }


    @AuraEnabled
    public static List<ObjectWrapperClass> getObjectFields(String objectName){
        Map<String,schema.SObjectField> objectFieldsMap = new Map<String,schema.SObjectField>();
        List<ObjectWrapperClass> objectWrapper = new List<ObjectWrapperClass>();
        List<String> useForObjPLSort = new List<String>();

		 System.debug('getfieldtest');
        if(objectName != '--None--'){
            objectFieldsMap = objectMap.get(objectName).getDescribe().fields.getMap();
            System.debug(objectFieldsMap.size()+'    '+objectMap.containskey(objectName));
            for(String field : objectFieldsMap.keySet()){
                if(objectFieldsMap.get(field).getDescribe().isAccessible() && objectFieldsMap.get(field).getDescribe().isUpdateable()){
                    objectWrapper.add(new ObjectWrapperClass(objectFieldsMap.get(field).getDescribe().getName(),objectFieldsMap.get(field).getDescribe().getLabel()));
                    useForObjPLSort.add(objectFieldsMap.get(field).getDescribe().getLabel());
                }
            }
        }
        useForObjPLSort.sort();
        return sorting(useForObjPLSort, objectWrapper);
    }

    

    @AuraEnabled
    public static List<sObject> getRecords(List<String> fields,String objectName){
        List<SObject> records = new List<sObject>();
        String query1 = 'SELECT ';
        for(Integer i=0;i<fields.size();i++){
            if(i<fields.size()-1){
                query1+=fields[i]+',';
            }else{                
                query1+=(fields[i]+' from '+objectName);
            }
        }  
        System.debug(query1);

        records = Database.query(query1);
        System.debug(records.size());
        return records;
    }





    private static List<ObjectWrapperClass> sorting (List<String> labels, List<ObjectWrapperClass> tempList) {
        List<ObjectWrapperClass> finalList = new List<ObjectWrapperClass>();
        for(String checkFld : labels) {
            for(ObjectWrapperClass checkFldValue : tempList) {
                if(checkFldValue.label == checkFld) {
                    finalList.add(new ObjectWrapperClass(checkFldValue.value, checkFld));
                }
            }
        }
        return finalList;
    }  

}