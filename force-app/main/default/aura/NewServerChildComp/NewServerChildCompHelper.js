({   
  
    processRecords : function(component,size,pageNumber) {
     console.log("process callled");
        var sttt = [];
        var map = new Map();
        component.set("v.mapForMaintain",map);
        map = component.get("v.mapForMaintain");
     console.log("a");
     var selected = [];
     console.log(map.has(pageNumber));
        if(map.has(pageNumber)){
            selected = map.get(pageNumber);
        }else{
            selected = [];
        }
     console.log("b");

        console.log(selected+' comes');
        
        //component.set("v.selectedRow",selected);
        var action = component.get("c.getFirstRecords");
        action.setParams({
            objectName : component.get("v.objectName"),
            fields : component.get("v.selectedFields"),
            pageSize : size,
            pageNumber : pageNumber
        })
        console.log('pareaem set');
        action.setCallback(this,function(response){
            var state = response.getState();
            var records = [];
            console.log(state);
            if(state == "SUCCESS"){  
                var wrapper = response.getReturnValue();     
                console.log(wrapper.records.length);
                        
                component.set("v.data",wrapper.records);   
                component.set("v.totalPages",wrapper.totalRecords);
                component.set("v.hasNext",wrapper.disabledList[0]);
                component.set("v.hasPrevious",wrapper.disabledList[1]);
                console.log(component.get("v.mapForMaintain").get(pageNumber).length);
                component.set("v.selectedRow",component.get("v.mapForMaintain").get(pageNumber));
            }             
            
        })
        $A.enqueueAction(action);
	},

    sortData : function(component,field,sortDirection) {
        console.log(field+"  "+sortDirection);
    	var data = component.get("v.data");
         var ids = [];
        console.log(data.length);
         for(var x of data){
             ids.push(x.Id);
         }
         console.log('a');
         var action = component.get("c.sortRecords");
         console.log('b');

         action.setParams({
             conId : ids,
             fields : component.get("v.selectedFields"),
             objectName : component.get("v.objectName"),
             fieldName : field,
             sortDir : sortDirection
         })
         console.log('param set');
         action.setCallback(this,function(response){
             var state = response.getState();
             if(state == "SUCCESS"){
                 console.log("success");
                 console.log(response.getReturnValue().length);
                 component.set("v.data",response.getReturnValue());
             }
         })
         $A.enqueueAction(action);
    },
    
})