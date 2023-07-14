({
    getObjects : function(component, event, helper) {
       console.log("first");
		//tempstrt 
		var map = new Map();
        component.set("v.mapForMaintain",map);
		//tempend
       var action = component.get("c.getObjectList");
       action.setCallback(this,function(response){
           var state = response.getState();
           if(state == "SUCCESS"){
               var items = [];                
               for(var x of response.getReturnValue()){  
                   var item = { 
                       "label":x.labelName,
                       "value":x.apiName
                   };                   
                   items.push(item);
               }                
               component.set("v.options",items);  
               component.set("v.addBool",false);
           }
       });
       $A.enqueueAction(action);
       
    },
   
   getFields : function(component, event, helper) {
       component.set("v.data",null);
		component.set("v.showRecordsBool",false);
		component.set("v.selectedFields",null);
       component.set("v.size",5);
       
       component.set("v.objectname",component.find("item").get("v.value"));
       var action = component.get("c.getObjectFields");
       action.setParams({objectName : component.find("item").get("v.value")});  
       action.setCallback(this,function(response){
           var state = response.getState();
           
           if(state == "SUCCESS" && response.getReturnValue().length != 0){
              var fieldsName = [];
              for(var x of response.getReturnValue()){
                   var item = {
                       "label": x.labelName,
                       "value": x.apiName
                   };
                   fieldsName.push(item);
               }
               component.set("v.Fields",fieldsName);
               component.set("v.addBool",true);          
           }else{
                component.set("v.addBool",false);
           }       
       })
       $A.enqueueAction(action);
   },
    
    
    getNewRecords : function(component,event,helper){
        var map = new Map();
        component.set("v.mapForMaintain",map);
        component.set("v.selectedRow",null);
        var size = component.get("v.pageSize");
        var pageNumber = 1;
        component.set("v.pageNumber",1);
       
        helper.processRecords(component,size,pageNumber);
    },
    
    
    
    resetAll : function(component, event, helper) {
       component.find("item").set("v.value",null);
       component.set("v.addBool",false);
       component.set("v.showRecordsBool",false);
       component.set("v.selectedFields",null);
       component.set("v.data",null);
   },
    
    showFields : function(component, event, helper){
        console.log('show method called');
        console.log(component.get("v.selectedFields").length);
        for(var x of component.get("v.selectedFields")){
            console.log(x);
        }
    },
    
   showRecords : function(component, event, helper) {
       console.log('pCalled');
       console.log(component.get("v.Fields").length);
 	   var size = 5;
       var col = [];
        console.log(component.get("v.selectedFields").length);
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
       component.set("v.column",col);
       console.log('a');
      
       
       if(component.get("v.selectedFields").length > 0){
           var pageNumber = component.get("v.pageNumber");    	   
           component.set("v.showRecordsBool",true);           
           helper.processRecords(component,size,pageNumber);           
           
       }else{
           component.set("v.showRecordsBool",false);
       }
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
        console.log(pageNumber+' 1234');
        var size = component.get("v.pageSize");
         console.log(pageNumber+' 1234   '+size);
        component.set("v.pageNumber",pageNumber);
      
        helper.processRecords(component,size,pageNumber);
    },
    
    first : function(component,event,helper){       
        var pageNumber = 1;       
        component.set("v.pageNumber",pageNumber);
        var size = component.get("v.pageSize");
        helper.processRecords(component,size,pageNumber);
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

})