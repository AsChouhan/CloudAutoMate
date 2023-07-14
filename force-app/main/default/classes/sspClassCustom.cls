public class sspClassCustom {
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
    
    
    
    public static Map<String,schema.SObjectType> objectMap = schema.getGlobalDescribe();
    
    @AuraEnabled      
    public static List<ObjectWrapperClass> getObjectList(){
        
        
        List<String> customLAbelObject = System.label.StObjects.split(',');
        
        List<Map<String,String>> objectSelectOptionList = new List<Map<String,String>>();
        System.debug('getObjectTest');
        List<ObjectWrapperClass> objectWrapper = new List<ObjectWrapperClass>();
        for(String ObjectApi : objectMap.keySet()){
            if(objectMap.get(ObjectApi).getDescribe().isCustom()){
                objectWrapper.add(new ObjectWrapperClass(ObjectApi,objectMap.get(ObjectApi).getDescribe().getLabel()));
                //objectSelectOptionList.add(new Map<String,String>{'value' => ObjectApi,'label' => ObjectApi});        
            }
        }
        for(String apiNameOfCustomLabel : customLAbelObject){
            objectWrapper.add(new ObjectWrapperClass(apiNameOfCustomLabel,objectMap.get(apiNameOfCustomLabel).getDescribe().getLabel()));
            //objectSelectOptionList.add(new Map<String,String>{'value' => apiNameOfCustomLabel,'label' => apiNameOfCustomLabel});
        }
        return objectWrapper;
    }
    
    
    @AuraEnabled
    public static List<ObjectWrapperClass> getObjectFields(String objectName){
        Map<String,schema.SObjectField> objectFieldsMap = new Map<String,schema.SObjectField>();
        List<ObjectWrapperClass> objectWrapper = new List<ObjectWrapperClass>();
        System.debug('getfieldtest');
        if(objectName != '--None--'){
            objectFieldsMap = objectMap.get(objectName).getDescribe().fields.getMap();
            System.debug(objectFieldsMap.size()+'    '+objectMap.containskey(objectName));
            for(String field : objectFieldsMap.keySet()){
                if(objectFieldsMap.get(field).getDescribe().isAccessible() && objectFieldsMap.get(field).getDescribe().isUpdateable()){
                    objectWrapper.add(new ObjectWrapperClass(objectFieldsMap.get(field).getDescribe().getName(),objectFieldsMap.get(field).getDescribe().getLabel()));
                }
            }
        }
        return objectWrapper;
    }
    
    public static apexPages.StandardSetController sCon;
    
    
    
    
    
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
}