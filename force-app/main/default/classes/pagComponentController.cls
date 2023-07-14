public class pagComponentController {



    // Pagination variable.......
    public Integer size{get;set;} 
    public Boolean pageBool{get;set;}
    public Boolean delSelBool{get;set;}
    public List<string> character{get;set;}
    // component variable .......
    Boolean sortBool = true;
    public Id idForEditDelete{get;set;}
    public List<selectOption> tempFieldsSelectoptionLisst{get;set;}
    public String alphabate{get;set;}
    public String fieldForSort{get;set;}
    // New Record Vaiable.........
    Public String keyPrefixOfObject{get;set;}
    public List<String> FieldsName{get;set;}
    public String queryStr{get;set;}
    public String queryStrForCsv{get;set;}
    public List<sObject> Records{get;set;}    
    public apexPages.StandardSetController sCon{get;set;}    
    public Integer NewPageNumber{get;set;}    
    public String csvListStr{get;set;}
    public String ObjectNameForQuery{get;set;}
    public List<selectOption> objectFields{get;set;}
    //  Wrapper Class.............
    public List<wrapper> wrapperList{get;set;}
    public Set<Id> selectedWrapper{get;set;}

    public class wrapper{
        public Boolean Wrapperbool{get;set;}
        public SObject sObj{get;set;}     

        public wrapper(SObject sObj,Boolean Wrapperbool){
            this.sObj = sObj;
            this.Wrapperbool = Wrapperbool;
        }        
    }

// Add selected records in set............

    public void selectrecord(){        
        for(wrapper wrp : wrapperList){
            if(wrp.Wrapperbool == true){
                selectedWrapper.add(wrp.sObj.Id);
            }else if( selectedWrapper.contains(wrp.sObj.Id) && wrp.Wrapperbool == false ){
                selectedWrapper.remove(wrp.sObj.Id);
            }
        }
    }
    
    // Clear and add Records in wrapperList........

    public void addRecords(){
        wrapperList.clear();
        for(SObject sobj : sCon.getRecords()){
            if(selectedWrapper.contains(sobj.Id)){
                wrapperList.add(new wrapper(sobj,true));                    
            }else{
                wrapperList.add(new wrapper(sobj,false));  
            }
       }
    }


    // Check And add records in wrappeList......

    // Controller Constructor....
    public pagComponentController(){ 
        queryStrForCsv =' ';
        tempFieldsSelectoptionLisst = new List<SelectOption>();
        character = new List<String>{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','Other','All'};
        selectedWrapper = new Set<Id>();

		System.debug('Component Constructor');
        objectFields = new List<selectOption>();
        size = 5;
        delSelBool = true;
        Records = new List<sObject>();
        FieldsName = new List<String>();
    }    

// Edit | Delete In Action...........

    public Pagereference editRec(){
        System.debug(idForEditDelete);
        Pagereference pg = new Pagereference('/'+idForEditDelete+'/e');
        return pg;
    }

    public void deleteRec(){
        String delQuery = 'select name from '+ObjectNameForQuery+' where id = :idForEditDelete';
        sobject delObj = Database.query(delQuery);
        system.debug(delObj);
        try{
            Database.delete(delObj);
        }catch(DmlException d){
            apexPages.addMessage(new apexPages.Message(apexpages.Severity.WARNING,d.getMessage()));
        }
        sCon = new apexPages.StandardSetController(database.getqueryLocator(queryStr));
        sCon.setPageSize(Size);
        addRecords();
    }

//  Delete Selected Records method

    public void del(){
       selectrecord();
       if(selectedWrapper.size()>0){
         string qury = 'select name from '+ObjectNameForQuery+' where id IN :selectedWrapper';
         List<SObject> temp = Database.query(qury);
         try {
            delete temp;
         } catch (DmlException d) {
            apexPages.addMessage(new apexPages.Message(apexpages.Severity.WARNING,d.getMessage()));
            
         }         
         temp.clear();         
       }
       sCon = new apexPages.StandardSetController(database.getqueryLocator(queryStr));
       sCon.setPageSize(Size);
       addRecords();
    }
    
// New Record......

    public Pagereference newRecord(){
        Pagereference ref = new Pagereference('/'+keyPrefixOfObject+'/e');
        System.debug(keyPrefixOfObject);
        return ref;
    }

//  Record Filter by Charecter Method...........

    public void charFilter(){
        queryStr = 'SELECT ';
        String tem = 'A';
        if(ObjectNameForQuery != 'case' && ObjectNameForQuery != 'lead' && ObjectNameForQuery != 'Solution'){
            for(Integer i=0;i<objectFields.size();i++){
                if(i<=objectFields.size()-2){
                    queryStr+=objectFields[i].getvalue()+',';                
                }else{  
                    if(alphabate == 'all'){
                        queryStr+=(objectFields[i].getvalue()+' FROM '+ObjectNameForQuery);
                    }else if(alphabate == 'other'){
                        queryStr+=(objectFields[i].getvalue()+' FROM '+ObjectNameForQuery+' '+'WHERE Name <: tem');
                    }else{         
                        queryStr+=(objectFields[i].getvalue()+' FROM '+ObjectNameForQuery+' '+'WHERE Name Like \''+alphabate+'%\'');      
                    }         
                }
            }        
            selectedWrapper.clear();
            sCon = new apexPages.StandardSetController(database.getqueryLocator(queryStr));
            sCon.setPageSize(Size);
            addRecords();
        }else{
            apexPages.addMessage(new apexPages.Message(apexpages.Severity.WARNING,'this object is not able to filter '));
        }
    }    
    
// Next Page/Button Method.................

    public void Next(){
        selectrecord();
        sCon.next();
        addRecords();
        
    } 

// Last page/Button Method..............
    
    public void last(){
        selectrecord();
        sCon.last();       
        addRecords();
    }


 

// Previous Button Method................
    
    public void Previous(){
        selectrecord();
        sCon.previous();
        addRecords();
       
    }
    
// First Page Method...............

    public void First(){
        selectrecord();
        sCon.first();
        addRecords();

    }
    
//Set PageSzie Method.............

    public void setPageSiz(){
        selectrecord();
        sCon.setPageSize(size);
        addRecords();

    }	
    
    // Page Jump Method..........

    public void goToPage(){
        selectrecord();
        sCon.setPageNumber(NewPageNumber);
        System.debug(NewPageNumber+' '+sCon.getPageNumber());
        addRecords();

    }   
    

    //Main Method called by actionFunction(Show Records...)............
	public void showe(){  
        
        FieldsName.clear();
        tempFieldsSelectoptionLisst.clear();
        queryStr = 'SELECT ';        

        for(Integer i=0;i<objectFields.size();i++){
            if(i<=objectFields.size()-2){
                queryStr+=(objectFields.get(i).getValue()+',');
                tempFieldsSelectoptionLisst.add(new SelectOption(objectFields.get(i).getValue(),objectFields.get(i).getLabel()));
            }else{                
                queryStr+=(objectFields.get(i).getValue()+' from '+ObjectNameForQuery);
                tempFieldsSelectoptionLisst.add(new SelectOption(objectFields.get(i).getValue(),objectFields.get(i).getLabel()));
            }
        }   

        wrapperList = new List<wrapper>();
        List<SObject> sObj = new List<SObject>();
        sCon = new Apexpages.StandardSetController(Database.query(queryStr));
        
        sCon.setPageSize(Size);
        for(SObject obj:sCon.getRecords()){
            wrapperList.add(new wrapper(obj,false));
        }      
       pageBool = true;       
    }
    
// Download Csv Method.........

    public void createDownloadCsvstring(){
        selectrecord();
        csvListStr = 'SELECT ';
        queryStrForCsv = '';
        for(Integer i=0;i<objectFields.size();i++){
            if(i<objectFields.size()-1){
                csvListStr+=(objectFields.get(i).getValue()+',');
                queryStrForCsv+=objectFields.get(i).getLabel()+',';
            }else{                
                csvListStr+=(objectFields.get(i).getValue()+' from '+ObjectNameForQuery);
                queryStrForCsv+=objectFields.get(i).getLabel()+'\\n';
            }
        }        
        csvListStr+=' where id IN :selectedWrapper';
        List<sObject> tempList = Database.query(csvListStr);
        for(SObject sob : tempList){
            Integer i = 0;
            for(SelectOption s:objectFields){ 
                if(i<=objectFields.size()-2){
                    if(sob.get(s.getValue()) instanceof String){
                        System.debug(sob.get(s.getValue()));
                        String str1 = (String)sob.get(s.getValue());
                        if(str1.contains(',')){
                            queryStrForCsv+=('"'+sob.get(s.getValue())+'"'+',');
                        }else{
                            queryStrForCsv+=(sob.get(s.getValue())+',');
                        }
                    }else {
                        queryStrForCsv+=(sob.get(s.getValue())+',');
                    }
                }else{
                    if(sob.get(s.getValue()) instanceof String){
                        System.debug(sob.get(s.getValue()));
                        String str2 = (String)sob.get(s.getValue());
                        if(str2.contains(',')){
                            queryStrForCsv+=('"'+sob.get(s.getValue())+'"'+'\\n');
                        }else{
                            queryStrForCsv+=(sob.get(s.getValue())+'\\n');
                        }
                    }else {
                        queryStrForCsv+=(sob.get(s.getValue())+'\\n');
                    }
                }              
               i+=1;  
            }
        }
        System.debug(queryStrForCsv);
    }        
       
  // Tag Sorting...............
  public Set<Id> wrapperId = new Set<Id>();
  Public void addIntoIdSet(){
    for(Wrapper wrp : wrapperList){
        wrapperId.add(wrp.sObj.Id);
    }
  }

  Public void sortByTag(){
        System.debug(fieldForSort);
        addIntoIdSet();
        String tempqueryStr;
        if(ObjectNameForQuery != 'case' && ObjectNameForQuery != 'lead' && ObjectNameForQuery != 'Solution'){
            if(sortBool){
                tempQueryStr = queryStr+' WHERE id In :wrapperId '+ ' ORDER BY '+fieldForSort+' ASC';
                sortBool = false;
                System.debug(tempQueryStr);
            }else{
                tempQueryStr = queryStr+' WHERE id In :wrapperId'+' ORDER BY '+fieldForSort+' DESC';
                sortBool = true;
                System.debug(tempQueryStr);
            }

            selectedWrapper.clear();
            sCon = new apexPages.StandardSetController(database.getqueryLocator(tempQueryStr));
            sCon.setPageSize(Size);
           addRecords();
        }else{
            apexPages.addMessage(new apexPages.Message(apexpages.Severity.WARNING,'this object is not able to filter '));
        }
  }
}