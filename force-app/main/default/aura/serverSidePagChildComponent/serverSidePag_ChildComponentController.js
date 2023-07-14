({
    showRecords1 : function(component, event, helper) {
        console.log('comesaaa');
 	   var size = 5;
       var col = [];
        var map = new Map();
        component.get("v.mapForMaintain",map);
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
   
    
    
    
    
    
    getNewRecords : function(component,event,helper){
        var size = component.get("v.pageSize");
        console.log(size);
        console.log("con");
        //helper.process1(component,size);
    },
    
    
    sort : function(component, event, helper){
        var field = event.getParam("fieldName");
        console.log(field);
        var sortDirection = event.getParam("sortDirection");
        helper.sortData(component,field,sortDirection);
    },
    
    selectThat : function(component, event, helper) {   
        console.log("selected the");
        var map = new Map();
        component.set("v.selectedRecMap",map);
        var existMap = component.get("v.selectedRecMap");
        var pageNumber = component.get("v.pageNumber");
        console.log(pageNumber);
        if(existMap.has(pageNumber)){
            existMap.delete(pageNumber);
        }
     
	},    
})