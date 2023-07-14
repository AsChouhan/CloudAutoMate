({      
    
    checkUser : function(component, event, helper){
        const startingUrl = new URL(window.location.href);
        const authcode = startingUrl.searchParams.get('code');
        var items = [];
        var item = ({
            label: 'Home',
            value: 'root'
        })
        items.push(item);
        component.set('v.breadCrumbList',items);
        var action = component.get('c.checkUserInDatabase');
        component.set("v.spinner", true);
        action.setCallback(this, function(response){
            if(response.getState() == 'SUCCESS'){
                console.log(response.getReturnValue());
                var result = response.getReturnValue();
                if(result == 'Found'){
                    console.log('checking expiry...');
                    // check access token expire or not...
                    var action = component.get('c.checkForAccessToken');
                    console.log('after action..');
                    action.setCallback(this, function(response){
                        console.log('inside callback..');
                        if(response.getReturnValue() == 'NOT EXPIRED'){
                            helper.getFiles1(component, event);
                            component.set("v.spinner", false);
                        }else{
                            var action = component.get('c.getNewAccessToken');
                            action.setCallback(this, function(response){
                                if(response.getReturnValue() == 'UPDATED'){
                                    console.log('updated');
                                    helper.getFiles1(component, event);
                                }
                                component.set("v.spinner", false);
                            })
                            $A.enqueueAction(action);
                        }
                    })
                    $A.enqueueAction(action);
                    
                }else{
                    console.log('auth code -> '+authcode);
                    if(authcode == null){
                        console.log('creating authUrl');
                        var action = component.get('c.createAuthURL');
                        
                        action.setCallback(this, function(response){
                            if(response.getState() == 'SUCCESS'){
                                console.log('authUrl -> '+response.getReturnValue());
                                window.location.href = response.getReturnValue();
                                alert('auth call successfully');
                            }
                            component.set("v.spinner", false);
                        })
                        $A.enqueueAction(action);
                    }else{
                        alert('auth code recived -> '+ authcode);
                        var action = component.get("c.getAccessToken");
                        action.setParams({
                            code: authcode
                        })
                        action.setCallback(this,function(response){
                            console.log(response.getState());
                            if(response.getState() == "SUCCESS"){
                                console.log(response.getReturnValue());
                                var accessToken = response.getReturnValue();
                                console.log(authcode);
                                helper.getFiles1(component, event);
                                component.set("v.accessToken", response.getReturnValue());                    
                            }
                            component.set("v.spinner", false);
                        })
                        $A.enqueueAction(action);
                        console.log('comes in this part');
                    }
                }
            }
        })
        $A.enqueueAction(action);
    },
    
    
    
    deleteFile : function(component, event, helper){
        component.set("v.spinner", true);
        alert('delete call');
        
        var fId = event.target.id;
        console.log(fId);
        var action = component.get("c.deleteData");
        action.setParams({
            fileId : fId
        })
        
        action.setCallback(this, function(response){
            console.log('inside callBack');
            if(response.getState() == "SUCCESS"){
                helper.getFiles1(component, event);
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
        console.log(component.get('v.folderName'));
        var action = component.get('c.createFolderinDrive');
        var folId = component.get('v.folderId');
        console.log('folder id>>'+folId);
        action.setParams({
            folderName: component.get('v.folderName'),
            folderId: folId
        });
        action.setCallback( this, function(response) {
            var result = response.getReturnValue();
            
            if(result == 'Success'){
                alert('Folder is created');
                helper.getFiles1(component, event);
            }
            else{
                alert('Cannot create folder');
            }
            component.set('v.isPopUpOpen', false);
            component.set("v.spinner", false);
        });
        $A.enqueueAction(action);
    },
    
    openFile : function(component, event, helper){
        component.set("v.spinner", true);
        var ids = event.target.id;
        var el = event.target.dataset;
        var fileName = el['filename'];
        console.log(el['filename']);
        console.log(ids);
        var items = component.get('v.breadCrumbList');
        for(var x of items){
            console.log(x.label+'  ->  '+x.value);
        }
        var item = ({
            label: fileName,
            value: ids
        });
        items.push(item);
        component.set('v.breadCrumbList', items);    
        component.set('v.folderId', ids);
        helper.openFolder(component, event, ids);
    },
    
    handleUpload : function(component, event, helper){
        component.set("v.spinner", true);
        var uploadedFile = event.getParam('files');
        var type = uploadedFile[0].mimeType;
        var name = uploadedFile[0].name;
        console.log('a');
        var file = btoa(JSON.stringify(uploadedFile[0]));
        console.log('b');
        console.log(file);
        var folId = component.get('v.folderId');
        
        var action = component.get('c.uploadFile');
        action.setParams({
            filename : name,
            filetype : type,
            file : file,
            folderId : folId
        })
        action.setCallback(this, function(response){
            console.log(response.getState());
            if(response.getState() == 'SUCCESS'){
                console.log(response.getReturnValue());
                
                if(response.getReturnValue() == 'success'){
                    alert('success');
                	helper.getFiles1(component, event);
                }else{
                    alert('error');
                }
            }
            component.set("v.spinner", false);
        })
        $A.enqueueAction(action);        
    },
    
    gotoPage : function(component, event, helper){
        component.set("v.spinner", true);
        //console.log('gotoPage called');
        var locId = event.target.id;
        console.log(locId);
        component.set('v.folderId',locId);
        var newItems = [];
        var items = component.get('v.breadCrumbList');
        for(var x of items){
            if(x.value == locId){
                newItems.push(x);
                break;
            }else{
                newItems.push(x);
            }            
        }
        component.set('v.breadCrumbList', newItems);
        
        helper.openFolder(component, event, locId);
    }
})