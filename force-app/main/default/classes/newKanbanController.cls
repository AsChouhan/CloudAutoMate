public class newKanbanController {
    /**************************Wrapper Class For Object Picklist*******************************/
  public class ObjPickListValues {
      @AuraEnabled
      public String label;
      
      @AuraEnabled
      public String value;
  }
  /**************************Wrapper Class For Fields Picklist***********************************/
  @AuraEnabled
  public static List<ObjPickListValues> objectsList() {
      List<ObjPickListValues> objectList  = new List<objPickListValues>();
      List<String> useForObjPLSort = new List<String>();
      Map<String, Schema.SObjectType> typeOfObject = Schema.getGlobalDescribe();        
      for(Schema.SObjectType objectType : typeOfObject.values()) {
          Schema.DescribeSObjectResult objectNames = objectType.getDescribe();
          if(objectNames.isQueryable() && objectNames.isSearchable() && objectNames.isCreateable() && objectNames.isUpdateable()&& objectNames.isDeletable()){
              ObjPickListValues toStore = new ObjPickListValues();
              toStore.label = objectNames.getLabel();
              toStore.value = objectNames.getName();
              objectList.add( toStore ); 
              useForObjPLSort.add(objectNames.getLabel()); 
          }
      }
      useForObjPLSort.sort();
      return sorting(useForObjPLSort, objectList);
  }
  /**************************Field Picklist*******************************/
  @AuraEnabled
  public static Map<Integer,List<ObjPickListValues>> fieldsList(String selectedObj) {
      List<ObjPickListValues> pickListFields  = new List<objPickListValues>();
        //
      List<ObjPickListValues> simpleFields  = new List<objPickListValues>();

      List<String> useForPickListFieldSort = new List<String>();
        //
      List<String> useForSimpleFieldSort = new List<String>();

        //
      Map<Integer,List<ObjPickListValues>> allFields = new Map<Integer,List<ObjPickListValues>>();

      Schema.SObjectType selectedObjectType = Schema.getGlobalDescribe().get(selectedObj);            
      Schema.DescribeSObjectResult sObjectResult = selectedObjectType.getDescribe();
      
      for(Schema.SObjectField fieldNames : sObjectResult.fields.getMap().values()) {                
          Schema.DescribeFieldResult fieldName = fieldNames.getDescribe();
          if( fieldName.getName()!='Name' &&  fieldName.isAccessible() && fieldName.isSortable() && fieldName.isUpdateable() && fieldName.getType() == Schema.DisplayType.PICKLIST) {                   
              ObjPickListValues toStore = new objPickListValues();       
              toStore.label = fieldName.getLabel();
              toStore.value = fieldName.getName();
              pickListFields.add( toStore ); 
              useForPickListFieldSort.add(fieldName.getLabel());                                  
          }else if(fieldName.getName()!='Name' &&  fieldName.isAccessible() && fieldName.isSortable() && fieldName.isUpdateable()){
                ObjPickListValues toStore = new objPickListValues();       
                toStore.label = fieldName.getLabel();
                toStore.value = fieldName.getName();
                simpleFields.add( toStore ); 
                useForSimpleFieldSort.add(fieldName.getLabel()); 
          }               
      }        
      useForPickListFieldSort.sort();   
      useForSimpleFieldSort.sort();   

      pickListFields = sorting(useForPickListFieldSort, pickListFields);
      simpleFields = sorting(useForSimpleFieldSort, simpleFields);

      allFields.put(1,pickListFields);
      allFields.put(2,simpleFields);
      System.debug(allFields.get(2).size());
      
      return allFields;
  }
  /**************************Picklist Values*******************************/
  @AuraEnabled
  public static List<String> getPLValues(String selPicklist, String selectedObj) {
      Schema.SObjectType selectedObjectType = Schema.getGlobalDescribe().get(selectedObj);            
      Schema.DescribeSObjectResult sObjectResult = selectedObjectType.getDescribe();
      List<Schema.Picklistentry> fld =sObjectResult.fields.getMap().get(selPicklist).getDescribe().getpicklistValues();
      List<String> picklistVal = new List<String>();
      for(Integer start = 0; start < fld.size(); start++) {        
            picklistVal.add(fld[start].getValue());          
      }
      return picklistVal;
  }
  /**************************List Of Records*******************************/
  @AuraEnabled
  public static Map<String, List<sObject>> getRelRec(String objectname, String picklistNamestr, List<String> fields) {
      Map<String, List<sObject>> createdCardsMap = new Map<String, List<sObject>>();

    String queryrelrec;

      
    if(objectname=='case'){
        queryrelrec = 'SELECT id,CaseNumber,' + picklistNamestr+',';

      }else if(objectname=='solution'){
        queryrelrec = 'SELECT id,SolutionNumber,' + picklistNamestr+',';
      }
      else{
        queryrelrec = 'SELECT id,Name,' + picklistNamestr+',';
      }


        for(Integer i=0;i<fields.size();i++){
            if(i <= fields.size()-2){
            queryrelrec+=(fields[i]+',');
        }else{
            queryrelrec+=(fields[i]+' from '+objectname);
        }
    }

        System.debug(queryrelrec);


  
     list<sObject> records = Database.query(queryrelrec);
      for(sObject singleRec : records){
          String val = String.valueOf(singleRec.get(picklistNamestr));
          
          if(!createdCardsMap.containsKey(val)){
              createdCardsMap.put(val, new List<sObject>());
          }
          createdCardsMap.get(val).add(singleRec);
      }
      
      return createdCardsMap;     
  }  
   /**************************Update Record*******************************/
  @AuraEnabled
  public static void updateElement(String elementId, String elementPLVal, String picklistName, String objName) {
      String queryForRec = 'SELECT Id, ' + picklistName + ' FROM ' + objName + ' WHERE Id = \'' + elementId + '\'';
      List<sObject> rec = Database.query(queryForRec);
      for(sObject singleRec : rec) {
          singleRec.put(picklistName, elementPLVal);
          update singleRec;
      }
  }
  /**************************Label wise Sorting in Field Picklist*******************************/
  private static List<objPickListValues> sorting (List<String> labels, List<objPickListValues> tempList) {
      List<objPickListValues> finalList = new List<objPickListValues>();
      for(String checkFld : labels) {
          objPickListValues toStore = new objPickListValues();
          toStore.label = checkFld;
          for(objPickListValues checkFldValue : tempList) {
              if(checkFldValue.label == checkFld) {
                  toStore.value = checkFldValue.value;
              }
          }
          finalList.add(toStore);
      }
      return finalList;
  }  
}