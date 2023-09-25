Simpplr.Salesforce.Scheduler = Simpplr.Salesforce.Scheduler || {};

Simpplr.Salesforce.Scheduler =  (function (Simpplr, $){
	var module = {};
	
	module.search=function (data) {
		Simpplr.Salesforce.log('Scheduler.search---data---'+ JSON.stringify(data));
		return Simpplr.Salesforce.sendRequest({
		      data: {'data' : JSON.stringify(data)},
		      method:'POST',
		      endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SchedulerDataServer&action=search'
		});
	},
	module.run=function (data) {
		Simpplr.Salesforce.log('Scheduler.run---data---'+ JSON.stringify(data));
		return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(data)},
			method:'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SchedulerDataServer&action=runSchedulerNow'
		});
	},
	module.schedule = function(data) {
		Simpplr.Salesforce.log('Scheduler.run---data---'+ JSON.stringify(data));
		return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(data)},
			method:'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SchedulerDataServer&action=schduleSchdulerNow'
		});
	},
	
	module.clear=function (data) {
		Simpplr.Salesforce.log('Scheduler.clear---data---'+ JSON.stringify(data));
		return Simpplr.Salesforce.sendRequest({
	      data: {'data' : JSON.stringify(data)},
	      method:'POST',
	      endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SchedulerDataServer&action=clear'
	  });
	}
	return module;
})(Simpplr, jQuery);