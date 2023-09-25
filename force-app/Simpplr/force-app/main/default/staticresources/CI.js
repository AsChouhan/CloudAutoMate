Simpplr.Salesforce.CampaignAndInitiative =  (function(Simpplr, $){
	var module = {};
	
	module.addInitiative = function (data) { 
  		return Simpplr.Salesforce.sendRequest({
          	data : { data },
          	method : 'POST',
          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CIDataServer&action=addInitiative'
      	});
  	}

	module.initiatives = function (data) { 
		console.log(data);
		return Simpplr.Salesforce.sendRequest({
			data : {'data' : JSON.stringify(data)},
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CIDataServer&action=getInitiatives'
		});
	}

	module.campaigns = function (data) { 
		return Simpplr.Salesforce.sendRequest({
			data : {'data' : JSON.stringify(data)},
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CIDataServer&action=getCampaigns'
		});
	}

	module.getInitiativeById = function (data) { 
		return Simpplr.Salesforce.sendRequest({
			data : { data },
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CIDataServer&action=getInitiativeById'
		});
	}

	module.getCampaignById = function (data) { 
		return Simpplr.Salesforce.sendRequest({
			data : { data },
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CIDataServer&action=getCampaignById'
		});
	}
	
	module.getCampaignsByInitiativeId = function (data) { 
		return Simpplr.Salesforce.sendRequest({
			data : { data },
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CIDataServer&action=getCampaignsByInitiativeId'
		});
	}
	
	module.getSupportingActivitiesByInitiativeId = function (data) { 
		return Simpplr.Salesforce.sendRequest({
			data : { data },
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CIDataServer&action=getSupportingActivitiesByInitiativeId'
		});
	}

	module.addCampaign = function (data) { 
		return Simpplr.Salesforce.sendRequest({
			data : { data },
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CIDataServer&action=addCampaign'
		});
	}
	
	module.removecampaign = function (data) { 
		return Simpplr.Salesforce.sendRequest({
			data : { data },
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CIDataServer&action=removecampaign'
		});
	}
	
	module.addCampaignItem = function (data) { 
		return Simpplr.Salesforce.sendRequest({
			data : { data },
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CIDataServer&action=addCampaignItem'
		});
	}
	

	module.editcampaign = function (data) { 
		return Simpplr.Salesforce.sendRequest({
			data : { data },
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CIDataServer&action=editcampaign'
		});
	}

	module.removecampaignitem = function (data) { 
		return Simpplr.Salesforce.sendRequest({
			data : { data },
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CIDataServer&action=removecampaignitem'
		});
	}

	module.getCampaignItemsByCampaignId = function (data) { 
		return Simpplr.Salesforce.sendRequest({
			data : { data },
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CIDataServer&action=getCampaignItemsByCampaignId'
		});
	}

	module.getContent = function (data) { 
		return Simpplr.Salesforce.sendRequest({
			data : { data },
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CIDataServer&action=getContent'
		});
	}

	module.editInitiative = function (data) { 
		return Simpplr.Salesforce.sendRequest({
			data : { data },
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CIDataServer&action=editInitiative'
		});
	}

	module.getSites = function (data) { 
		return Simpplr.Salesforce.sendRequest({
			data : { data },
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CIDataServer&action=getSites'
		});
	}

	module.addSupportingCommunication = function (data) { 
		return Simpplr.Salesforce.sendRequest({
			data : { data },
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CIDataServer&action=addSupportingCommunication'
		});
	}

	module.removeSupportingCommunication = function (data) { 
		return Simpplr.Salesforce.sendRequest({
			data : { data },
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CIDataServer&action=removeSupportingCommunication'
		});
	}

	module.getSurveys = function (data) { 
		return Simpplr.Salesforce.sendRequest({
			data : { data },
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CIDataServer&action=getSurveys'
		});
	}

	module.getVideos = function (data) { 
		return Simpplr.Salesforce.sendRequest({
			data : { data },
			method : 'POST',
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=CIDataServer&action=getVideos'
		});
	}
	
	return module;
	
})(Simpplr, jQuery);