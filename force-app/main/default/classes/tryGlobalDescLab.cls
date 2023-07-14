public class tryGlobalDescLab {

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
    
    
    // Constructor
    public tryGlobalDescLab(){         
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
        
        ObjectList = method(ObjectList);        
    }   
    
    // Process Record method
    public void Processrecord(){         
        processBool = true;
        prefixKeyOfObject = gd.get(objectName).getDescribe().getKeyPrefix();
        System.debug(prefixKeyOfObject);
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
            dropDownFieldList = method(dropDownFieldList);
        }else{
            bool = false;
        }        
    } 
    
    public List<selectOption> method(List<selectOption> op){
        op.sort();
        List <selectOption> tempOp = new List<selectOption>();
        for(selectOption opp : op){
            tempOp.add(new selectOption(opp.getLabel(),opp.getValue()));            
        }        
        return tempOp;
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