({
    init : function(component) {	//Get Object List
        var action = component.get('c.objectsList');
        action.setCallback(this, function(response) {          
            if(response.getState() == "SUCCESS") {
                component.set("v.objNames", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);        
    },
    selectedObj : function(component) {  	//Get Fields List Of picklist Datatype
        component.set("v.spinner", true);
        component.set("v.selectedField", "");
        component.set("v.addBool",false);
        var pickListFields = [];
        var simpleFields = [];
        var action = component.get('c.fieldsList');
        action.setParams({ "selectedObj" : component.get('v.selectedObject') });
        action.setCallback(this, function(response) {      
            if(response.getState() == "SUCCESS") {
                var result = response.getReturnValue();
                var bool = true;
                for(var x in result){              
                    if(x == 1){   
                    console.log(x+'  '+result[x].length);  
                    component.set("v.fieldName",result[x]); 
                    }else{
                        component.set("v.simpleFields",result[x]);
                    }                
                }      
                      
                component.set("v.dis", false);
                component.set("v.spinner", false);
            }
        });
        $A.enqueueAction(action);
    },

    //Get Picklist values
    selectedFld : function(component, event, helper) {	
       
        component.set("v.spinner", false);
        var action = component.get('c.getPLValues');
        console.log(component.get("v.selectedField"));
        action.setParams({ "selPicklist" : component.get("v.selectedField"), "selectedObj" : component.get('v.selectedObject') });
        action.setCallback(this, function(response) {      
            if(response.getState() == "SUCCESS") {
                var vals = response.getReturnValue();
                vals.push('null');
                component.set("v.picklistVal", vals);
                component.set("v.visible", false);
            }
        });
        $A.enqueueAction(action);
        helper.getRecs(component, event);
    },

    showDualList : function(component, event, helper){
        console.log('comesss');
        component.set("v.addBool",true);
        console.log("v.objectName");
    },

    handleClick : function(component) {	//Get back to first page
        component.set("v.spinner", true);
        component.set("v.visible", true);
        component.set("v.selectedObject", "");
        component.set("v.selectedField", "");
        component.set("v.dis", true);
        component.set("v.relRecs", "");
        component.set("v.spinner", false);
        component.set("v.addBool",false);
        component.set("v.selectedFields","");
    },
    allowDrop: function(cmp, event, helper){	//Prevent default on Drop
        event.preventDefault();
    },
    drag: function(cmp, ev, helper){		//Drag functionality
        cmp.set("v.startId",ev.target.id);
        cmp.set("v.parentId",document.getElementById(ev.target.id).parentElement.id);
        console.log(cmp.get("v.startId")+'   '+document.getElementById(ev.target.id).parentElement.id);
    },
    drop: function(cmp, ev, helper){	//Drop Functionality
        var drag = cmp.get("v.startId");
        var div = ev.target.id;
        
        var parId = cmp.get("v.parentId");
        console.log(div+'   '+parId);
        var fragment = document.createDocumentFragment();
        fragment.appendChild(document.getElementById(drag));
        if(div.length == 0) {
            document.getElementById(parId).appendChild(fragment);
        } else {
            if(div.charCodeAt(0) >=48 && div.charCodeAt(0) <= 57) {
                div = document.getElementById(div).parentElement.id;
                console.log(div);
            }
            document.getElementById(div).appendChild(fragment);
            document.getElementById(drag).style.borderColor = "red";
            
            var action = cmp.get('c.updateElement');
            action.setParams({ "elementId" : cmp.get("v.startId"), "elementPLVal" : div, "picklistName" : cmp.get("v.selectedField"), "objName" : cmp.get("v.selectedObject")});
            action.setCallback(this, function(response) {
                if(response.getState() == "SUCCESS") {
                    helper.getRecs(cmp, ev);
                    if(cmp.get("v.done")) {

                        document.getElementById(drag).style.borderColor = "green";   
                        cmp.set("v.done", false);
                    }                
                }
            });
            $A.enqueueAction(action);
        }
    }
})