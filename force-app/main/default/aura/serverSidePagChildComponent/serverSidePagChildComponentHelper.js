({    	
    processRecords : function(component,size,pageNumber) {
     console.log("process callled");
        var sttt = [];
        var map = component.get("v.mapForMaintain");
        var selected = map.get(pageNumber);
        console.log(selected+' comes');
        
        //component.set("v.selectedRow",selected);
        var action = component.get("c.getRecords");
        action.setParams({
            pagesize: size,
            fields: component.get("v.selectedFields"),
            objectName: component.find("item").get("v.value"),
            pageNumber: pageNumber
        })
        action.setCallback(this,function(response){
      
            
            var state = response.getState();
            var records = [];
            if(state == "SUCCESS"){                    
                
                
                var wrapper = response.getReturnValue();
                
                
                console.log(wrapper.totalPages)
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
    
})