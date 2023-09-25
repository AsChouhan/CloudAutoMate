({
	loadPopularContent : function(component, helper) {
		var action = component.get("c.getPopularContent");
            
            action.setParams({ contentType : component.get("v.contentType"), 
                              siteId:component.get("v.siteId")});

            action.setCallback(this, function(response) {
                var state = response.getState(); 
                if (state === "SUCCESS") {
                    
                	var jsonData = JSON.parse(response.getReturnValue());
                                        
                    for (var counter=0; counter < jsonData.length; counter++) {
               			jsonData[counter].srNo = counter+1;
                	}
                	console.log('In popular content helper' + component.get("v.contentType"));
                    console.log(jsonData);
    				component.set('v.popularContents', jsonData);
                   
                } else if (state === "INCOMPLETE") {
                    // do something
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                     errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
    
            $A.enqueueAction(action);
	},
    
    loadLatestContent: function(component, helper) {
		var action = component.get("c.getLatestContent");
            
        action.setParams({ contentType : component.get("v.contentType"), 
                          siteId:component.get("v.siteId")});
        
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            if (state === "SUCCESS") {
                
                var jsonData = JSON.parse(response.getReturnValue());
                console.log('*****Latest view*******' + component.get("v.contentType"));
                console.log(jsonData);
                
                for (var counter=0; counter < jsonData.length; counter++) {
               		jsonData[counter].srNo = counter+1;
                }
                console.log(jsonData);
                component.set('v.latestContents', jsonData);
                
            } else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
	}
})