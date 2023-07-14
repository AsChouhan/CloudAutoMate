({
	helperMethod : function(component, event, helper, userName, password){
		console.log('helper called');
		var action = component.get("c.loginCheck");
		action.setParams({
			username: userName,
			password: password,
			startUrl: component.get("v.startUrl")
		})
		console.log('params set');
		action.setCallback(this, function(response){
			console.log(response.getState());
			if(response.getReturnValue() == 'success'){
				alert('success');
			}else{
				alert(response.getReturnValue());
			}
		})
		$A.enqueueAction(action);
	}
})