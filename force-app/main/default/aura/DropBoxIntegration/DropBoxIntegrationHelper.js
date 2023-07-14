({
	getFiles : function(component, event) {
		component.set("v.spinner", true);
		console.log('get files called');
		var pth = component.get('v.path');
		var action = component.get('c.getFiles');
		action.setParams({
			path: pth
		})
		action.setCallback(this, function(response){
			console.log(response.getState());
			if(response.getState() == 'SUCCESS'){
				console.log('inside success get filels');
				
				for(var x of response.getReturnValue()){
					console.log(x);
				}
				component.set('v.files', response.getReturnValue());
			}
            component.set("v.spinner", false);
		})
		$A.enqueueAction(action);
	},	
})