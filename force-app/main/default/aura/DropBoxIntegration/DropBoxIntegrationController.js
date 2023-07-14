({
	doAuth : function(component, event, helper) {
		component.set("v.spinner", true);
		var items = [];
		var item = ({
			label: 'Home',
			value: ''
		});
		items.push(item);
		component.set('v.breadCrumbList', items);

		var startingUrl = new URL(window.location.href);
        var authcode = startingUrl.searchParams.get('code');
		var action = component.get('c.checkUserInDB');
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				console.log(response.getReturnValue());
				if(response.getReturnValue() == 'FOUND'){
					// checking for access token expiration....
					var action = component.get('c.checkExpiration');
					action.setCallback(this, function(response){
						if(response.getState() == 'SUCCESS'){
							if(response.getReturnValue() == 'NOT EXPIRED'){
								helper.getFiles(component, event);
							}else{
								alert('inside new access');
								var action = component.get('c.getNewAccessToken');
								action.setCallback(this, function(response){
									if(response.getState() == 'SUCCESS'){
										if(response.getReturnValue() == 'UPDATED'){
											alert('access token updated');
											helper.getFiles(component, event);
										}
									}else{
										alert('Error at apex while genrating new access token');
									}
								})
								$A.enqueueAction(action);
							}
						}else{
							alert('Error at apex side..');
						}
					})
					$A.enqueueAction(action);
				}else{
					if(authcode == null){
						console.log('inside null');
						var action = component.get('c.creatAuthUrl');
						action.setCallback(this, function(response){
							console.log('inside call back authurl'+ response.getState());
							if(response.getState() == 'SUCCESS'){
								console.log(response.getReturnValue());
								alert('wait');
								window.location.href = response.getReturnValue();
							}
						})
						$A.enqueueAction(action);
					}else{
						console.log(authcode);
						var action = component.get('c.getAccessToken');
						action.setParams({
							code: authcode
						});
						console.log('param set');
						action.setCallback(this, function(response){
							console.log('inside callback'+response.getState());
							if(response.getState() ==  'SUCCESS'){
								console.log('comes at get files');					
								helper.getFiles(component, event);
							}
						});
						$A.enqueueAction(action);
					}
				}
			}
            component.set("v.spinner", false);
		})
		$A.enqueueAction(action);		
	},

	deleteFile : function(component, event, helper){
		component.set("v.spinner", true);

		var filId = event.target.id;
		console.log(filId);
		var action = component.get('c.deleteFiles');
		action.setParams({
			path : filId
		})
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				alert(response.getReturnValue());
				if(response.getReturnValue() == 'FILE DELETED'){
					helper.getFiles(component, event);
				}
			}else{
				alert('error at apex while deleting file');
				component.set("v.spinner", false);
			}
		})
		$A.enqueueAction(action);
	},

	downloadFile : function(component, event, helper){
		component.set("v.spinner", true);
		var filPath = event.target.id;
		var action = component.get('c.downloadFiles');
		console.log(filPath);
		action.setParams({
			path: filPath
		});
		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				var res = response.getReturnValue();
				window.open(res);
			}else{
				alert('ERROR WHILE DOWNLOADING FILE AT APEX');
			}
            component.set("v.spinner", false);

		})
		$A.enqueueAction(action);
	},


	openFolder : function(component, event, helper){
		component.set("v.spinner", true);
		var el = event.target.dataset;
		var fileName = el['filename'];
		var pth = event.target.id;
		console.log(fileName);

		var breadList = component.get('v.breadCrumbList');
		var item = ({
			label: fileName,
			value: pth
		})
		breadList.push(item);
		component.set('v.breadCrumbList', breadList);
		
		component.set('v.path',pth);
		console.log(pth);
		helper.getFiles(component, event);
	},

	gotoPage : function(component, event, helper){
		component.set("v.spinner", true);

		var pth = event.target.id;
		component.set('v.path', pth);
		console.log(pth);
		var newList = [];
		var breadList = component.get('v.breadCrumbList');
		for(var x of breadList){
			newList.push(x);
			if(x.value == pth){
				break;
			}		
		}
		component.set('v.breadCrumbList', newList);
		helper.getFiles(component, event);
	},

	handleUpload : function(component, event, helper){
		component.set("v.spinner", true);

		console.log('update called');
		var uploadedFile = event.getParam('files');
		var jsonString = JSON.stringify(uploadedFile[0]);

		console.log(jsonString);

		var file1 = btoa(jsonString);
		console.log(file1);
		//var file1 = btoa(JSON.stringify(uploadedFile[0]));
		var fileName1 = uploadedFile[0].name;
		var pth = component.get('v.path');
		var action = component.get('c.uploadFile');

		action.setParams({
			filename: fileName1,
			path: pth,
			file: file1
		})

		action.setCallback(this, function(response){
			if(response.getState() == 'SUCCESS'){
				alert(response.getReturnValue());

				if(response.getReturnValue() == 'success'){
					helper.getFiles(component, event);
				}
			}else{
				alert('error at apex while uploading');
			}
            component.set("v.spinner", false);

		})
		$A.enqueueAction(action);
	},

	closePopUp: function(component, event, helper) {
        component.set('v.isPopUpOpen', false);
    },
    
    openCreateFolderPopUp: function(component, event, helper) {
        component.set('v.folderName', '');
        component.set('v.isPopUpOpen', true);
    },

	createFolder: function(component, event, helper) {
		component.set("v.spinner", true);
		var fldName = component.get('v.folderName');
		console.log(fldName);
		var pth = component.get('v.path');
		console.log(pth);
		console.log(fldName == '');
		if(fldName != ''){
			console.log('not null');
			var action = component.get('c.tryCreate');
			action.setParams({
				folderName: fldName,
				path: pth
			})
			action.setCallback(this, function(response){
				console.log(response.getReturnValue());
				if(response.getState() == 'SUCCESS'){
					console.log('success');
					if(response.getReturnValue() == 'pass'){
						console.log('pass');
						helper.getFiles(component, event);
					}else if(response.getReturnValue() == 'fail'){
						console.log('fail');
					}else{
						console.log('Unknown');
					}
				}else{
					alert('error at apex while create folder');
				}
			})
			$A.enqueueAction(action);
		}else{
			alert('enter folder name');
		}
		component.set('v.isPopUpOpen', false);

	}
    
})