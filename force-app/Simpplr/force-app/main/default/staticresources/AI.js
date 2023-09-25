Simpplr.Salesforce.AI = (function (Simpplr, $) {
	var module = {};
    
    module.checkCommentToxicity = function (data) {
		Simpplr.Salesforce.log('ai.checkCommentToxicity---data---' + JSON.stringify(data));
		return Simpplr.Salesforce.sendRequest({
			data: { 'data': JSON.stringify(data) },
			method: 'POST',
			endpoint: Simpplr.Salesforce.Endpoints.ReadWrite + '?target=AIDataServer&action=checkCommentToxicity'
		});
	}

	module.getModerationQueue = function (data) {
		Simpplr.Salesforce.log('ai.getModerationQueue---data---' + JSON.stringify(data));
		return Simpplr.Salesforce.sendRequest({
			data: { 'data': JSON.stringify(data) },
			method: 'POST',
			endpoint: Simpplr.Salesforce.Endpoints.ReadWrite + '?target=AIDataServer&action=getModerationQueue'
		});
	}

	module.markModerationItemDismissed = function (data) {
		Simpplr.Salesforce.log('AI.markModerationItemDismissed----data----'+ data);
		return Simpplr.Salesforce.sendRequest({
			data : {'data' : JSON.stringify(data)},
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite + '?target=AIDataServer&action=markModerationItemDismissed'
		});
	}

	module.markModerationItemRemoved = function (data) {
		Simpplr.Salesforce.log('AI.markModerationItemRemoved----data----'+ data);
		return Simpplr.Salesforce.sendRequest({
			data : {'data' : JSON.stringify(data)},
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite + '?target=AIDataServer&action=markModerationItemRemoved'
		});
	}
	
	module.reportContent = function (data) {
		Simpplr.Salesforce.log('ai.reportContent----data----' +JSON.stringify(data));
		return Simpplr.Salesforce.sendRequest({
			data : {'data' : JSON.stringify(data)},
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite + '?target=AIDataServer&action=reportContent'
		})
	}

	module.getFiltersData = function () {
		Simpplr.Salesforce.log('ai.getFiltersData-------');
		return Simpplr.Salesforce.sendRequest({
			data : {'data' : ''},
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite + '?target=AIDataServer&action=getFiltersData'
		})
	}

	module.getModerationHistory = function (data) {
		Simpplr.Salesforce.log('ai.getModerationHistory---data---' + JSON.stringify(data));
		return Simpplr.Salesforce.sendRequest({
			data: { 'data': JSON.stringify(data) },
			method: 'POST',
			endpoint: Simpplr.Salesforce.Endpoints.ReadWrite + '?target=AIDataServer&action=getModerationHistory'
		});
	}

	module.getHistoryFiltersData = function (data) {
		Simpplr.Salesforce.log('ai.getHistoryFiltersData---data---');
		return Simpplr.Salesforce.sendRequest({
			data: { 'data': ''},
			method: 'POST',
			endpoint: Simpplr.Salesforce.Endpoints.ReadWrite + '?target=AIDataServer&action=getHistoryFiltersData'
		});
	}

    return module;
})(Simpplr, jQuery);