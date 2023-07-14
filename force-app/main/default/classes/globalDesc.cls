public class globalDesc{
    // Component class Instance
  
    
    // Selected Object Name
    public string objectName{get;set;} 
    
    //variable for KeyPrefix
    public String prefixKeyOfObject{get;set;}


    // Map of objects
    Public Map<String,schema.SObjectType> gd = schema.getGlobalDescribe(); 
    public List<String> stObj = System.label.StObjects.split(',');
    
    //Selected Fields List
    public List<String> selectedFieldsList{get;set;}  
    public List<SelectOption> dropDownSelectedFieldList{get;set;}
    
    // Selected fields for remove
    public List<String> deSelectedFieldsList{get;set;}
    
    // Object Drop Down List For Chose Object
    public List<SelectOption> ObjectList{get;set;} 
    
    //Map of fields and SelectList for fields
    public map<String,schema.SObjectField> Fields = new map<String,schema.SObjectField>();
    public List<SelectOption> dropDownFieldList{get;set;}
    
    // Boolean variables
    public Boolean addBool{get;set;}                    // Disable/Enable Add Button
    public Boolean removeBool{get;set;}					// Disable/Enable Remove Button
    Public Boolean bool{get;set;}                       // Disable/Enable PanelGrid Section
    public boolean disableNone{get;set;}   				// Disable/Enable None option
    public boolean processBool{get;set;}				// Disable/Enable ProcessRecord Button
    public Boolean prBool{get;set;}
    // Temp var.....
    public string queryString{get;set;}
    public List<String> FieldsName{get;set;}
    
        
    public List<selectOption> sortSo(List<selectOption> op){
        op.sort();
        List <selectOption> tempOp = new List<selectOption>();
        for(selectOption opp : op){
            tempOp.add(new selectOption(opp.getLabel(),opp.getValue()));            
        }        
        return tempOp;
    }

    public void sortFieldAtAddremove(List<SelectOption> op){
        List<selectOption> tempopp = new List<SelectOption>();
        for(selectOption opp : op){
            tempopp.add(new SelectOption(opp.getLabel(),opp.getValue()));
        }
        tempopp.sort();
        op.clear();
        for(SelectOption newop : tempopp){
            op.add(new SelectOption(newop.getLabel(),newop.getValue()));
        }
    }


    // Constructor
    public globalDesc(){         
        prBool = true;
        addBool = false;
        removeBool = true;
        deSelectedFieldsList = new List<String>();
        dropDownSelectedFieldList = new List<SelectOption>();        
        selectedFieldsList = new List<string>();
        dropDownFieldList = new List<SelectOption>();      
        ObjectList = new List<SelectOption>();    
        FieldsName = new List<String>();
        for(String str:stObj){
            ObjectList.add(new selectOption(gd.get(str).getDescribe().getLabel(),str));
        }
        
        for(String s : gd.keySet()){			
            if(gd.get(s).getDescribe().isCustom()){
                ObjectList.add(new selectoption(gd.get(s).getDescribe().getlabel(),s));
            }
        }      
        ObjectList = sortSo(ObjectList);        
    }   
    
    // Process Record method
    public void Processrecord(){         
        processBool = true;
        prefixKeyOfObject = gd.get(objectName).getDescribe().getKeyPrefix();
        System.debug(prefixKeyOfObject);
    }
    
    
    //Method For Sort(label)
public void SortList(List<selectOption> sList){
    List<String> tempList = new List<String>();
    for(Integer i=0;i<sList.size();i++){
        tempList.add(sList.get(i).getLabel());
    }
    tempList.sort();
    System.debug(tempList);
    for(Integer i=0;i<tempList.size();i++){
        for(Integer j=i+1;j<sList.size();j++){
            if(tempList[i]==sList.get(j).getlabel()){
            selectOption temp = sList.get(j);
            sList.remove(j);
            sList.add(i,temp);
            }
        }
    }
}
    
    // Method For Add and Remove Values From List
    public void addInSelectedList(){ 
        
        if(selectedFieldsList.size() == 0){
            apexPages.addMessage(new apexPages.Message(apexpages.Severity.WARNING,'Select field for add'));
        }else if((dropDownSelectedFieldList.size()+ selectedFieldsList.size())<=10){      
            for(String s : selectedFieldsList ){    
                //Remove Eliment 
                System.debug(s+' '+dropDownFieldList.indexOf(new selectoption(s,fields.get(s).getDescribe().getLabel())));
                System.debug(s+'\n'+dropDownFieldList.size()+'  '+dropDownFieldList.indexOf(new selectOption(s,fields.get(s).getDescribe().getLabel())));
                dropDownFieldList.remove(dropDownFieldList.indexOf(new selectOption(s,fields.get(s).getDescribe().getLabel())));    
                // Adding Eliment
                dropDownSelectedFieldList.add(new selectoption(s,fields.get(s).getDescribe().getLabel()));							
            }                    
            dropDownSelectedFieldList.sort();
            
            addBool = (dropDownSelectedFieldList.size()<10)?false:true;
            removeBool = (dropDownSelectedFieldList.size()!=0)?false:true; 
        }
        else{
            apexPages.addMessage(new apexPages.Message(apexpages.Severity.WARNING,'Can\'t add more then 10 fields'));
        }     
        prBool = (dropDownSelectedFieldList.size()>0)?false:true;    
        
        sortFieldAtAddremove(dropDownSelectedFieldList);
        
    }        
    
    
    //Remove Method 
    public void removeFromSelectedFields(){ 
        if(deSelectedFieldsList.size() == 0){
            apexPages.addMessage(new apexPages.Message(apexpages.Severity.WARNING,'Select field for remove'));
        }else{
            for(String s : deSelectedFieldsList){
                //Remove Eliment 
                dropDownSelectedFieldList.remove(dropDownSelectedFieldList.indexOf(new selectOption(s,fields.get(s).getDescribe().getLabel()))); 
                // Adding Eliment
                dropDownFieldList.add(new selectOption(s,fields.get(s).getDescribe().getLabel()));												
            }
            
            //sortList(dropDownFieldList);           
            dropDownFieldList.sort(); 
            
            addBool = (dropDownSelectedFieldList.size()<=10)?false:true;
            removeBool = (dropDownSelectedFieldList.size()!=0)?false:true;
        }        
        prBool = (dropDownSelectedFieldList.size()>0)?false:true;     
        sortFieldAtAddremove(dropDownFieldList) ;
    }
    
    public void ShowFields(){      
        System.debug('called');
        processBool = false;
        addBool = false;
        removeBool = true;
        disableNone = true;     
        dropDownSelectedFieldList.clear();
        dropDownFieldList.clear();
        if(objectname != '--None--'){  
            bool = true;
            schema.DescribeSObjectResult result = gd.get(objectName).getDescribe();
            fields = result.fields.getmap();
            
            for(String str : fields.keySet()){
                if(Fields.get(str).getDescribe().isAccessible() && Fields.get(str).getDescribe().isUpdateable() && Fields.get(str).getDescribe().isSortable()){
                    dropDownFieldList.add(new selectoption(fields.get(str).getDescribe().getLabel(),str));
                }
            }       
            dropDownFieldList = sortSo(dropDownFieldList);
        }else{
            bool = false;
        }        
    } 
    
    
    
    
    public void Reset(){
        bool = false;
        disableNone = false;        
        objectName = '--None--';
        processBool = false;
        dropDownFieldList.clear();
        dropDownSelectedFieldList.clear();      
    }    
}