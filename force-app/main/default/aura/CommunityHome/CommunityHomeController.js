({
	init : function(component, event, helper) {

		var action = component.get("c.getUserInfo");
        console.log('claasd');
        action.setCallback(this, function(response){  
            console.log(response.getReturnValue().Name);            
            component.set("v.name",response.getReturnValue().Name);
            component.set("v.email",response.getReturnValue().Email);            
        })
        $A.enqueueAction(action);
	}
})