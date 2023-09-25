Simpplr.Salesforce.Event = {

  search :function (data) {
  	var endPoint = Simpplr.Salesforce.Endpoints.ReadOnly +'?target=EventDataServer&action=search';
  	if(data.siteId !== undefined) {
  		endPoint += '&siteId='+data.siteId;
  	}
    return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:endPoint
    });
  },

  getRsvp : function(data) {
  	Simpplr.Salesforce.log('Event.getRsvp---data---'+ JSON.stringify(data));
    return Simpplr.Salesforce.sendRequest({
      data: {'data' : data},
      method:'POST',
      endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=RsvpDataServer&action=getRecord'
    });
  },
  rsvp : function(data){
  	Simpplr.Salesforce.log('Event.rsvp---data---'+ JSON.stringify(data));
    return Simpplr.Salesforce.sendRequest({
      data: {'data' : JSON.stringify(data)},
      method:'POST',
      endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=RsvpDataServer&action=save'
    });
  },
  getInvited : function(data){
  	Simpplr.Salesforce.log('Event.getInvited---data---'+ JSON.stringify(data));
    return Simpplr.Salesforce.sendRequest({
      data: {'data' : JSON.stringify(data)},
      method:'POST',
      endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteAddEventDataServer&action=invitedUsers'
    });
  },
  getAttending : function(data){
  	Simpplr.Salesforce.log('Event.getAttending---data---'+ JSON.stringify(data));
    return Simpplr.Salesforce.sendRequest({
      data: {'data' : JSON.stringify(data)},
      method:'POST',
      endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteAddEventDataServer&action=getAttending'
    });
  },
  invite : function(id, userIds, sendInvitationMail){
  	var data = {"id": id, "peopleList": userIds, "sendInvitationMail": sendInvitationMail};
  	Simpplr.Salesforce.log('Event.invite---data---'+ JSON.stringify(data));
    return Simpplr.Salesforce.sendRequest({
      data: {'data' : JSON.stringify(data)},
      method:'POST',
      endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteAddEventDataServer&action=invite'
    });
  },
  autoCompleteInvitee : function (data){
	Simpplr.Salesforce.log('event.autoCompleteInvitee---data---'+ JSON.stringify(data));
	return Simpplr.Salesforce.sendRequest({
	  data: {'data' : JSON.stringify(data)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=SearchUserDataServer&action=autoCompleteInvitee'
	}); 
  },

  deleteAttending: function (contentId, peopleIds, note) {
		Simpplr.Salesforce.log('event.deleteAttending ---');
		return Simpplr.Salesforce.sendRequest({
			data: {'data': JSON.stringify({contentId: contentId, peopleIds: peopleIds, note: note})},
			method:'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=RsvpDataServer&action=deleteAttending '
		});
  }, 
  
  sendEventUpdateMail: function (contentId) {
		Simpplr.Salesforce.log('event.sendEventUpdateMail ---');
		return Simpplr.Salesforce.sendRequest({
			data: {'data': JSON.stringify({contentId: contentId})},
			method:'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteAddEventDataServer&action=sendEventUpdateMail '
		});
  }

}