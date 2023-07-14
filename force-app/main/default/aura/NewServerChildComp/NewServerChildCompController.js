({
    tempFunction : function(component, event, helper){
        console.log(component.get("v.objectName"));
        for(var x of component.get("v.selectedFields")){
            console.log(x);
        }
        console.log(component.get("v.pageSize"));
        var action = component.get('c.getFirstRecords');
        action.setParams({
            objectName : component.get("v.objectName"),
            fields : component.get("v.selectedFields"),
            pageSize : component.get("v.pageSize"),
            pageNumber : component.get("v.pageNumber")
        })
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state);

        })
        $A.enqueueAction(action);

    },

   

    showRecords1 : function(component, event, helper) {
        console.log('comesaaa');
 	   var size = 5; 
       var col = [];
       // var map = new Map();
       // component.set("v.mapForMaintain",map);
       for(var x of component.get("v.selectedFields")){
           for(var y of component.get("v.Fields")){
               if(x == y.value){
                   var item = {
                       "label": y.label,
                       "fieldName": y.value,
                       "sortable": true,
                       "sortedBy":y.value
                   };                    
                   col.push(item);					               
               }
           }           
       }
        
        for(var x of col){
            console.log(x.label+'   '+x.fieldName);
        }
       component.set("v.column",col);
       
       if(component.get("v.selectedFields").length > 0){
           var pageNumber = component.get("v.pageNumber");    	   
           component.set("v.showRecordsBool",true);           
           helper.processRecords(component,size,pageNumber);           
           
       }else{
           component.set("v.showRecordsBool",false);
       }
    },
   
    
    
    
    
    
    setSize : function(component,event,helper){
        var map = new Map();
        component.set("v.mapForMaintain",map);
        component.set("v.selectedRow",null);
        var size = component.get("v.pageSize");
        var pageNumber = 1;
        component.set("v.pageNumber",1);
       
        helper.processRecords(component,size,pageNumber);
    },
    
    
    sort : function(component, event, helper){
        var field = event.getParam("fieldName");
        console.log(field);
        var sortDirection="";
        var sortBool = component.get("v.sortBool");
        if(sortBool == true){
            sortDirection= "asc";
            helper.sortData(component,field,sortDirection);
            component.set("v.sortBool",false);
        }else{            
            sortDirection= "desc";
            helper.sortData(component,field,sortDirection);
            component.set("v.sortBool",true);
        }            
    },

    selectThat : function(component, event, helper) {          
        var selected = event.getParam('selectedRows');
        //component.set("v.selectedRow",hou);
        var lis = [];
        var pageNumber = component.get("v.pageNumber");
        var map = new Map();
        map = component.get("v.mapForMaintain");
        for(var x of selected){
            lis.push(x.Id);      
          }   
        map.set(pageNumber,lis);
        
      	component.set("v.mapForMaintain",map);
      
        //console.log(hou.length+" "+hui.length);        
    }, 
    next : function(component,event,helper){     
        var pageNumber = component.get("v.pageNumber")+1;
        var size = component.get("v.pageSize");        
        component.set("v.pageNumber",pageNumber);
        helper.processRecords(component,size,pageNumber);        
    },
    
    previous : function(component,event,helper){         
        var pageNumber = component.get("v.pageNumber")-1;       
        var size = component.get("v.pageSize");           
        component.set("v.pageNumber",pageNumber);         
        helper.processRecords(component,size,pageNumber);
	},
                  
    last : function(component,event,helper){
        var pageNumber = component.get("v.totalPages");
        var size = component.get("v.pageSize");
        component.set("v.pageNumber",pageNumber);
      
        helper.processRecords(component,size,pageNumber);
    },
    
    first : function(component,event,helper){       
        var pageNumber = 1;       
        component.set("v.pageNumber",pageNumber);
        var size = component.get("v.pageSize");
        helper.processRecords(component,size,pageNumber);
    },
       
})