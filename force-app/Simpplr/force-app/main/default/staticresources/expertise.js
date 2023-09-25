Simpplr.Salesforce.Expertise = {

  search :function (data) {
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data' : JSON.stringify(data)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ExpertiseDataServer&action=search'
	});
  },
  
  save :function (id,data) {
  	var obj = {'id':id, 'name':data.name};
  	
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data' : JSON.stringify(obj)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ExpertiseDataServer&action=save'
	});
  },
  
  merge :function (fromExpertiseIdArg, toExpertiseIdArg) {
	var obj = {'fromExpertiseId':fromExpertiseIdArg, 'toExpertiseId':toExpertiseIdArg};
  	
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data' : JSON.stringify(obj)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ExpertiseDataServer&action=mergeExpertises'
	});
  },
  
  delete :function (expertiseIdArg) {  	
  	var obj = {'expertiseId':expertiseIdArg};
  	
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data' : JSON.stringify(obj)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ExpertiseDataServer&action=deleteExpertise'
	});
  }
  
}