Simpplr.Salesforce.Knowledge = {
	search :function (data) {
		if (typeof data !== 'undefined' && typeof data.category !== 'undefined' && 
				typeof data.categoryGroup !== 'undefined' && data.category.indexOf('.com') > 0) {
			window.location.replace(data.category);
			return;
		}
		return Simpplr.Salesforce.sendRequest({
		data: {'data' : JSON.stringify(data)},
		method:'POST',
		endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=KnowledgeDataServer&action=search'
		});
	}
}	  