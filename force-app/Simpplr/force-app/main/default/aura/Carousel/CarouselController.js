({
	doInit : function(component, event, helper) {
        try {
			helper.loadCarousel(component, helper);
        
        } catch (e) {
                console.log(e);
        }
	}
})