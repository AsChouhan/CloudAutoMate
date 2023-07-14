public class tempGlobalDesc{
    // Selected Object Name
    public string objectName{get;set;} 
    
    // Map of objects
	Public Map<String,schema.SObjectType> gd = schema.getGlobalDescribe();  
    
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
    public Boolean processBool{get;set;}				// Disable/Enable ProcessRecord Button
    
    // Constructor
    public tempGlobalDesc(){         
        addBool = false;
        removeBool = true;
        dropDownSelectedFieldList = new List<SelectOption>();        
        selectedFieldsList = new List<string>();
        dropDownFieldList = new List<SelectOption>();        
        ObjectList = new List<SelectOption>();        
        for(String s : gd.keySet()){			
            if(gd.get(s).getDescribe().isAccessible() && gd.get(s).getDescribe().isDeletable() && gd.get(s).getDescribe().isUpdateable() && gd.get(s).getDescribe().isQueryable()){
                ObjectList.add(new selectoption(s,gd.get(s).getDescribe().getlabel()));
            }
        }      
      ObjectList.sort();        
    }   
      
 // Process Record method
    public void Processrecord(){
        //sendFieldToProcess
        processBool = true;
        //System.debug(objectName+' '+dropDownSelectedFieldList);       
    }
    
    
/*Method For Sort(label)
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
    }*/
    
// Method For Add and Remove Values From List
    public void addInSelectedList(){ 
        if(selectedFieldsList.size() == 0){
            apexPages.addMessage(new apexPages.Message(apexpages.Severity.WARNING,'Select field for add'));
        }else if((dropDownSelectedFieldList.size()+ selectedFieldsList.size())<=10){      
            for(String s : selectedFieldsList ){    
                //Remove Eliment 
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
    }        
    
    
    //Remove Method 
    public void removeFromSelectedFields(){ 
        System.debug(deSelectedFieldsList.size());
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
    }
    
   public void ShowFields(){      
       
       disableNone = true;     
       dropDownSelectedFieldList.clear();
       dropDownFieldList.clear();
       if(objectname != '--None--'){  
           bool = true;
            schema.DescribeSObjectResult result = gd.get(objectName).getDescribe();
            fields = result.fields.getmap();
            
            for(String str : fields.keySet()){
                dropDownFieldList.add(new selectoption(str,fields.get(str).getDescribe().getLabel()));          
            }       
        dropDownFieldList.sort();
       }else{
           bool = false;
       }
   } 
    
    
    
    
    public void Reset(){
        bool = false;
        disableNone = false;        
       	objectName = '--None--';
       /* System.debug(selectedFieldsList);
        pagereference page = new PageReference(System.currentPageReference().geturl());
        page.setRedirect(false);
        return page;*/
    }    
}