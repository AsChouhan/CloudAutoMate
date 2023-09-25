Simpplr.Salesforce.Topic = {

  search :function (data) {
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data' : JSON.stringify(data)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=TopicDataServer&action=search'
	});
	},
	
  get :function (topicId) {
  	return Simpplr.Salesforce.sendRequest({
	  data: {'topicId' : topicId},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite + '?target=TopicDataServer&action=get'
	});
  },
  
  save :function (id,data) {
  	var obj = {'id':id, 'name':data.name};
  	
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data' : JSON.stringify(obj)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=TopicDataServer&action=save'
	});
  },
  
  favorite :function (data) {
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data' : JSON.stringify(data)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=TopicDataServer&action=favorite'
	});
  },
  
  setFollowing :function (id, isFollowingBoolean) {
	var obj = {'topicId':id};
	var actionName = "";
	if(isFollowingBoolean){
		actionName = "followTopic";
	}else{
		actionName = "unfollowTopic";
	}
  	
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data' : JSON.stringify(obj)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ToggleFollowDataServer&action='+actionName
	});
  },
  
  merge :function (fromTopicIdArg, toTopicIdArg) {
	var obj = {'fromTopicId':fromTopicIdArg, 'toTopicId':toTopicIdArg};
  	
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data' : JSON.stringify(obj)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=TopicDataServer&action=mergeTopics'
	});
  },
  
  delete :function (topicIdArg) {  	
  	var obj = {'topicId':topicIdArg};
  	
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data' : JSON.stringify(obj)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=TopicDataServer&action=deleteTopic'
	});
  },
  
  unfavorite :function (data) {
  	Simpplr.Salesforce.log('Topic.unfavorite---data---'+ JSON.stringify(data));
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data' : JSON.stringify(data)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=TopicDataServer&action=unfavorite'
	});
  },
  
}