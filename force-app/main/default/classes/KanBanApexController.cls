public class KanBanApexController {

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
        
        List<ObjectWrapperClass> objectWrapper = new List<ObjectWrapperClass>();
        for(String ObjectApi : objectMap.keySet()){
            if(objectMap.get(ObjectApi).getDescribe().isCustom()){
                objectWrapper.add(new ObjectWrapperClass(ObjectApi,objectMap.get(ObjectApi).getDescribe().getLabel()));
            }
        }
        for(String apiNameOfCustomLabel : customLAbelObject){
            objectWrapper.add(new ObjectWrapperClass(apiNameOfCustomLabel,objectMap.get(apiNameOfCustomLabel).getDescribe().getLabel()));
        }
        return objectWrapper;
    }    


    public static Map<Integer,List<ObjectWrapperClass>> getFields(String objectName){
        Map<Integer,List<ObjectWrapperClass>>  fieldsMap= new Map<Integer,List<ObjectWrapperClass>>();
        List<ObjectWrapperClass> pickListTypeFields = new List<ObjectWrapperClass>();
        List<ObjectWrapperClass> notPickListTypeFields = new List<ObjectWrapperClass>();


        Map<String,Schema.SobjectField> mapOfFields = objectMap.get(objectName).getDescribe().fields.getMap();
        for(String st : mapOfFields.keySet()){
            Schema.DisplayType result = mapOfFields.get(st).getDescribe().getType();
            if(result == Schema.DisplayType.Picklist){
                pickListTypeFields.add(new ObjectWrapperClass(mapOfFields.get(st).getDescribe().getName(),mapOfFields.get(st).getDescribe().getLabel()));
            }else{
                notPickListTypeFields.add(New ObjectWrapperClass(mapOfFields.get(st).getDescribe().getName(),mapOfFields.get(st).getDescribe().getLabel()));
            }
        }

        fieldsMap.put(1,pickListTypeFields);
        fieldsMap.put(2,notPickListTypeFields);
        System.debug(notPickListTypeFields.size());
        System.debug(pickListTypeFields.size());

        return fieldsMap;
    }
}