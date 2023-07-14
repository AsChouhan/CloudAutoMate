public class ServerSidePaginationClass {


    // Wrapper class for object...........    

    public class ObjectWrapperClass{        
        @AuraEnabled
        public String apiName;
        @AuraEnabled
        public String labelName;
        
        public ObjectWrapperClass(String apiName,String labelName){
            this.apiName = apiName;
            this.labelName = labelName;
        }
    } 


    public class OtherWrapperForResult{
        @AuraEnabled
        public List<Boolean> disabledList = new List<Boolean>();
        @AuraEnabled
        public List<sObject> records = new List<sObject>();
        @AuraEnabled
        public Integer totalRecords;

        public OtherWrapperForResult(List<Boolean> disabledList,List<sObject> records,Integer totalRecords){
            this.disabledList = disabledList;
            this.records = records;
            this.totalRecords = totalRecords;



            for(sObject sb : records){
                System.debug(sb);
            }

            for(Boolean bb : disabledList){
                System.debug(bb);
            }

            System.debug(totalRecords);
        }
    }

    public static Map<String,schema.SObjectType> objectMap = schema.getGlobalDescribe();

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

    public static apexPages.StandardSetController sCon;

    

    @AuraEnabled
    public static OtherWrapperForResult getRecords(Integer pagesize,List<String> fields,String objectName,Integer pageNumber){
        List<SObject> records = new List<sObject>();
        List<Boolean> boolList = new List<Boolean>();
        Integer totalRecords;    
        
        String query1 = 'SELECT ';
        for(Integer i=0;i<fields.size();i++){
            if(i<fields.size()-1){
                query1+=fields[i]+',';
            }else{                
                query1+=(fields[i]+' from '+objectName);
            }
        }  
        System.debug(query1);
        sCon = new Apexpages.StandardSetController(Database.getqueryLocator(query1));
        sCon.setPageSize(pagesize);
        scon.setPageNumber(pageNumber);
        for(sObject sob : sCon.getRecords()){
            records.add(sob);
        }
        System.debug(sCon.getResultSize());

        if(sCon.gethasNext()){
            boolList.add(false);
        }else{
            boolList.add(true);
        }
        if(sCon.gethasPrevious()){
            boolList.add(false);
        }else{
            boolList.add(true);
        }

        Decimal dc = sCon.getResultSize();
        totalRecords = Integer.valueOf(Math.ceil(dc/pagesize));
        

        OtherWrapperForResult forSend = new OtherWrapperForResult(boolList,records,totalRecords);
        return forSend;  
    }


    
   @AuraEnabled
   public static List<sObject> sortRecords(List<Id> conId ,List<String> fields,String objectName,String fieldName,String sortDir){
        List<sObject> ct = new List<sObject>();
        System.debug(fieldName);
        String query1 = 'SELECT ';
        for(Integer i=0;i<fields.size();i++){
            if(i<fields.size()-1){
                query1+=fields[i]+',';
            }else{                
                query1+=(fields[i]+' from '+objectName);
            }
        }  
        query1+=(' WHERE Id In : conId ORDER BY '+fieldName +' '+sortDir);
        System.debug(query1);
        ct = database.query(query1);
        return ct;
   }


   private static List<ObjectWrapperClass> sorting (List<String> labels, List<ObjectWrapperClass> tempList) {
    List<ObjectWrapperClass> finalList = new List<ObjectWrapperClass>();
    for(String checkFld : labels) {
        for(ObjectWrapperClass checkFldValue : tempList) {
            if(checkFldValue.labelName == checkFld) {
                finalList.add(new ObjectWrapperClass(checkFldValue.apiName, checkFld));
            }
        }
    }
    return finalList;
}  
}