public class AutoNumberPrectice {
    public static void fieldsList(String selectedObj) {
        
        List<String> useForFldPLSort = new List<String>();
        
        Map<String,Schema.SObjectType> selectedObjectType = Schema.getGlobalDescribe();            
        
        
        Map<String,Schema.SObjectField> fieldMap = selectedObjectType.get(selectedObj).getDescribe().fields.getMap();
               
        boolean bb = fieldMap.get('Name').getDescribe().isAutonumber();
        System.debug(bb);
        String name = fieldMap.get('Name').getDescribe().getName();
        System.debug(name);
    }
}