({    
    getFiles1 : function(component, event){
        component.set("v.spinner", true);
        console.log('helper file 1');
        var action = component.get('c.getfile1');
        var folId = component.get('v.folderId');
        console.log('foderId => '+folId);
        action.setParams({
            folderId: folId
        })
        action.setCallback(this, function(response){
            console.log('b');
            if(response.getState() == 'SUCCESS'){
                for(var x of response.getReturnValue()){
                    console.log(x);
                }
                component.set("v.files",response.getReturnValue());
            }
            component.set("v.spinner", false);
        })
        $A.enqueueAction(action);
    },   
    
    openFolder : function(component, event, folId){
        var action = component.get('c.openFolder');
        action.setParams({
            folderId: folId
        })
        action.setCallback(this, function(response){
            console.log('inside callback'+ response.getState());
            if(response.getState() == 'SUCCESS'){
                for(var x of response.getReturnValue()){
                    console.log(x.name);
                }
                component.set("v.files",response.getReturnValue());
            }
            component.set("v.spinner", false);
        })
        $A.enqueueAction(action);

    }
})