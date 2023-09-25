Simpplr.Salesforce.Feedback = Simpplr.Salesforce.Feedback || {};
Simpplr.Salesforce.Feedback = (function (Simpplr, $){
	
	var module = {};
	
    module.create =  function (reqData, pageTitle) {
		var data = {};
		data.feedbackMsg = JSON.stringify(reqData.feedback);
		data.pageUrl = encodeURIComponent(window.location);
        data.pageTitle = encodeURIComponent(pageTitle);
        data.helpTopics = reqData.helpTopics;
        data.emailProductResearch = reqData.emailProductResearch;
		
		return Simpplr.Salesforce.sendRequest({
		  data: {'data' : JSON.stringify(data)},
		  method:'POST',
		  endpoint: Simpplr.Salesforce.Endpoints.ReadWrite + '?target=UtilityDataServer&action=sendFeedBackEmail' 
        });
        
    };

	return module;
})(Simpplr, jQuery);