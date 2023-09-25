({
	doInit : function(component, event, helper) {
        try {
            helper.loadPopularContent(component, helper);
            helper.loadLatestContent(component, helper);
         } catch (e) {
                console.log(e);
         }

	}
})