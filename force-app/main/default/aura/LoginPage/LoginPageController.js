({
	checkUser : function(component, event, helper) {
		var userName = component.find('username').get('v.value');
		var password = component.find('password').get('v.value');
		console.log('value recived');
		if(userName !='' && password !=''){
			helper.helperMethod(component, event, helper, userName, password);
		}else{
			alert('Please enter right username and password!');
		}
	}
})