({
	loadCarousel : function(component, helper) {
		var action = component.get("c.getCarouselData");
            
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            if (state === "SUCCESS") {
                console.log('Data from backend');
                var jsonData = JSON.parse(response.getReturnValue());
                
                jsonData = jsonData.result.listOfItems;
                console.log(jsonData);
                var finalData = [];
                for (var counter=0; counter < jsonData.length; counter++) {
                    jsonData[counter].srNo = counter+1;
                    
                    if (jsonData[counter].item.imgLandscape == null) {
                    	
                    	if (jsonData[counter].item.type == 'Page') {
                    		jsonData[counter].item.imgLandscape = 'https://static.simpplr.com/lightning-asset/img/carousel_page.png';
                    	
                    	} else if (jsonData[counter].item.type == 'BlogPost') {
                    		jsonData[counter].item.imgLandscape = 'https://static.simpplr.com/lightning-asset/img/carousel_blog.png';
                    	
                    	} else if (jsonData[counter].item.type == 'Event') { 
                    		jsonData[counter].item.imgLandscape =  'https://static.simpplr.com/lightning-asset/img/carousel_event.png';
                    	}
                    	
                    }
                    
                    if (jsonData[counter].item.type != 'Album') {
                		finalData.push(jsonData[counter]);
                	
                	} 
                    
                }
                
                component.set('v.carouselData', finalData);
                
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