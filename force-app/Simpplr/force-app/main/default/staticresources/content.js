Simpplr.Salesforce.Content = {

  search :function (data) {
  	Simpplr.Salesforce.log('Content.search---data---'+ JSON.stringify(data));
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data' : JSON.stringify(data)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AllContentDataServer&action=search'
	});
  },
  
  getRelated :function (contentId) {
  	
  	data = {
  		"contentId": contentId
  	}
  	
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data' : JSON.stringify(data)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AllContentDataServer&action=getRelated'
	});
  },
  
  save :function (type,id,data,action) {
  Simpplr.Salesforce.log('Content.save---type---'+ type);
  	var actionName = "";
  	var endPointURL = "";
  	if(id == null){
  		actionName = "publish";
  	} else if(action == 'approve') {
  		data.id = id;
  		actionName = "approve";
  	} else {
  		data.id = id;
  		actionName = "update";
  	}
  	if("page" === type){
  		endPointURL = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteAddPageDataServer&action='+actionName + '&siteId=' + data.siteId; 
  	}else if("event" === type){
  		endPointURL = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteAddEventDataServer&action='+actionName + '&siteId=' + data.siteId;  
  	}else if("album" === type){
  		endPointURL = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteAddAlbumDataServer&action='+actionName + '&siteId=' + data.siteId;
  	}else if("blog_post" === type){
  		endPointURL = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ProfileAddBlogPostDataServer&action='+actionName;
	  }
	  
	if(id !== null){
		endPointURL += '&contentId=' + id;
	}

  	return Simpplr.Salesforce.sendRequest({
	  data: {'data' : JSON.stringify(data)},
	  method:'POST',
	  endpoint: endPointURL
	});
  },
  
  saveDraft  :function (type,id,data) {
  	var actionName = "";
  	var endPointURL = "";
  	if(id == null){
  		actionName = "saveDraft";
  	} else {
  		data.id = id;
  		actionName = "updateDraft";
  	}
  	if("page" === type){
  		endPointURL = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteAddPageDataServer&action='+actionName + '&siteId=' + data.siteId; 
  	}else if("event" === type){
  		endPointURL = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteAddEventDataServer&action='+actionName + '&siteId=' + data.siteId;  
  	}else if("album" === type){
  		endPointURL = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteAddAlbumDataServer&action='+actionName + '&siteId=' + data.siteId;
  	}else if("blog_post" === type){
  		endPointURL = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ProfileAddBlogPostDataServer&action='+actionName;
  	}
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data' : JSON.stringify(data)},
	  method:'POST',
	  endpoint: endPointURL
	});
  },
  
  setLiked  : function (contentId, setLikedBool) {
	    	var actionName = "";
	    	if(setLikedBool){
	    		actionName = "like";
	    	}else{
	    		actionName = "unlike";
	    	}
    		return Simpplr.Salesforce.sendRequest({
		  data: {recordId: contentId, action:actionName, likeType: 'content'},
		  method:'POST',
		  endpoint: Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ChatterInteractionDataServer'
		});
    },
    
    setFavorited  : function (id, setFavoritedBool) {
	    	var actionName = "";
	    	if(setFavoritedBool){
	    		actionName = "bookmark";
	    	}else{
	    		actionName = "unbookmark";
	    	}
    		return Simpplr.Salesforce.sendRequest({
		  data: {recordId: id, action:actionName},
		  method:'POST',
		  endpoint: Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ToggleBookmarkDataServer'
		});
    },
    
    share : function (data) {
     	var deferred = $.Deferred();
     	if (typeof data.urlName !== 'undefined' && data.urlName.length >= 255) {
	   		data.urlName = data.urlName.substring(0, 200);
     	}
     	
     	data['url'] = data['url'].replace(/\//g, '\\\\/');
     	
     	if (typeof data !== undefined) {
	     	var requestObj = {
	     		albumMediaId: data['albumMediaId'],
				action:'share',
				contentId: data['contentId'],
				subjectId:data['subjectId'],
				Type:data['type'], 
				url:data['url'],
				urlName:data['urlName'],
				textToPost : data['body'],
				bodyJson: JSON.stringify(data['bodyJson'])
			};
        	
        	return Simpplr.Salesforce.sendRequest({
          		data : requestObj,
          		method : 'POST',
          		endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ChatterInteractionDataServer'
      		});
			
		} else {
			deferred.reject(false);
		}
     	return deferred;
    },
  
  getLikers : function (data) {
  	Simpplr.Salesforce.log('Salesforce.Content.getLikers---data---'+ JSON.stringify(data));
  	return Simpplr.Salesforce.sendRequest({
	  data:  {'data' : JSON.stringify(data)},
	  method:'GET',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ContentLikeDataServer'
	});
  },
  
  delete :function (siteId, contentId) {
  	var data={siteId:siteId, contentId:contentId};
  	Simpplr.Salesforce.log('Content.delete---data---'+ JSON.stringify(data));
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data' : JSON.stringify(data)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AllContentDataServer&action=delete&siteId='+siteId
	});
  },
  
  approve :function (siteIdArg, contentIdArg) {
  	var data={siteId:siteIdArg, contentId:contentIdArg};
  	Simpplr.Salesforce.log('Content.approve---data---'+ JSON.stringify(data));
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data': JSON.stringify(data)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AllContentDataServer&action=approve&siteId='+siteIdArg
	});
  },
  
  setPublished :function (siteId, contentId, setPublishedBool) {
  	Simpplr.Salesforce.log('Content.setPublished---siteId---'+ siteId);
  	Simpplr.Salesforce.log('Content.setPublished---contentId---'+ contentId);
  	Simpplr.Salesforce.log('Content.setPublished---setPublishedBool---'+ setPublishedBool);
  	var data={siteId:siteId, contentId:contentId, setPublishedBool:setPublishedBool};
  	var actionName = "";
  	if(setPublishedBool){
  		actionName = "publish";
  	} else {
  		actionName = "unpublish";
  	}
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data': JSON.stringify(data)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AllContentDataServer&action='+actionName+'&siteId='+siteId
	});
  },
  
  create :function (siteId, contentId) {
  	Simpplr.Salesforce.log('Content.create---data---'+ JSON.stringify(data));
  	var data={siteId:siteId, contentId:contentId};
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data': JSON.stringify(data)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AllContentDataServer&action=create&siteId='+siteId
	});
  },
  
  reject :function (siteIdArg, contentIdArg, rejectionCommentArg) {
  	var data={siteId:siteIdArg, contentId:contentIdArg, rejectionComment:rejectionCommentArg};
  	Simpplr.Salesforce.log('Content.reject---data---'+ JSON.stringify(data));
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data': JSON.stringify(data)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AllContentDataServer&action=reject&siteId='+siteIdArg
	});
  },
  
  rate :function (contentIdArg, isUsefulArg, commentArg) {
    Simpplr.Salesforce.log(arguments);
  	var data={isUsefulBool:isUsefulArg, contentId:contentIdArg, comment:commentArg};
  	Simpplr.Salesforce.log('Content.rate---data---'+ JSON.stringify(data));
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data': JSON.stringify(data)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AllContentDataServer&action=rate'
	});
  },
  
  getRatings :function (data) {
  	var data={contentId:data.id, nextPageToken:data.nextPageTokenArg, limit:data.limitArg};
  	Simpplr.Salesforce.log('Content.getRatings---data---'+ JSON.stringify(data));
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data': JSON.stringify(data)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AllContentDataServer&action=getRatings'
	});
  },
  
  getModerationHistory :function (data) {
  	Simpplr.Salesforce.log('Content.getRatings---data---'+ JSON.stringify(data));
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data': JSON.stringify(data)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AllContentDataServer&action=getModerationHistory'
	});
  },

  getOnboardingHistory :function (data) {
    Simpplr.Salesforce.log('Content.getOnboardingHistory---data---'+ JSON.stringify(data));
    return Simpplr.Salesforce.sendRequest({
      data: {'data': JSON.stringify(data)},
      method:'POST',
      endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AllContentDataServer&action=getOnboardingHistory'
    });
  },
  
  prepareBulkDataCsv :function (data) {
	return Simpplr.Salesforce.sendRequest({
	data: {'data': JSON.stringify(data)},
	method:'POST',
	endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AllContentDataServer&action=prepareBulkDataCsv'
  });
},
  
  deleteRatings :function (feedbackIdArg) {
  	var data={feedbackId:feedbackIdArg};
  	Simpplr.Salesforce.log('Content.deleteRatings---data---'+ JSON.stringify(data));
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data': JSON.stringify(data)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AllContentDataServer&action=deleteRatings'
	});
  },
  
  get :function (contentIdArg, data) {
  	var endPointURL = "";
  	
  	if("page" === data.contentType){
  		endPointURL = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteAddPageDataServer&action=get';
  	}else if("event" === data.contentType){
  		endPointURL = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteAddEventDataServer&action=get';
  	}else if("album" === data.contentType){
  		endPointURL = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteAddAlbumDataServer&action=get';
  	}else if("blog_post" === data.contentType){
  		endPointURL = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ProfileAddBlogPostDataServer&action=get';
  	}
  	return Simpplr.Salesforce.sendRequest({
  		data: {'contentId': contentIdArg, 'versionHistoryId': data.versionId, data: JSON.stringify(data)},
  		method:'GET',
  		endpoint:endPointURL
  	});
  },
  
  sendNotification :function (contentIdArg, siteId, message, membersType) {
  	return Simpplr.Salesforce.sendRequest({
  		data: {'contentId': contentIdArg, 'siteId': siteId, 'message': message, 'membersType':membersType},
  		method:'POST',
  		endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=NotificationDataServer&action=sendNotification'
  	});
  },

	getNotificationMessage :function (contentIdArg, contentMessageId) {
		return Simpplr.Salesforce.sendRequest({
  		data: {'contentId': contentIdArg, 'contentMessageId': contentMessageId},
  		method:'POST',
  		endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=NotificationDataServer&action=getNotificationMessage'
  	});
  },
  submit :function (siteIdArg, contentIdArg) {
  	var data={siteId:siteIdArg, contentId:contentIdArg};
  	Simpplr.Salesforce.log('Content.submit---data---'+ JSON.stringify(data));
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data': JSON.stringify(data)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AllContentDataServer&action=submit&siteId='+data.siteId
	});
  },
  
  makeMustRead :function (id, data) { 
		data.contentId=id;
  	Simpplr.Salesforce.log('Content.makeMustRead---contentId---'+ id);
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data': JSON.stringify(data)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AllContentDataServer&action=makeMustRead'
	});
  },
  
   removeMustRead :function (id) {
   var data={contentId:id};
  	Simpplr.Salesforce.log('Content.removeMustRead---contentId---'+ id);
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data': JSON.stringify(data)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AllContentDataServer&action=removeMustRead'
	});
  },
  
  resetMustRead :function (id) {
   var data={contentId:id};
  	Simpplr.Salesforce.log('Content.removeMustRead---contentId---'+ id);
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data': JSON.stringify(data)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AllContentDataServer&action=resetMustRead'
	});
	},
	
   markAsRead :function (id) {
   var data={contentId:id};
  	Simpplr.Salesforce.log('Content.markAsRead---contentId---'+ id);
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data': JSON.stringify(data)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AllContentDataServer&action=markAsRead'
	});
	},
   
  sendMustReadReminderMail :function (id) {
		var data={contentId:id};
		 Simpplr.Salesforce.log('Content.sendMustReadReminderMail---contentId---'+ id);
		 return Simpplr.Salesforce.sendRequest({
		 data: {'data': JSON.stringify(data)},
		 method:'POST',
		 endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AllContentDataServer&action=sendMustReadReminderMail'
	 });
	 },

	
	move : function(contentIdListArg, siteIdArg, categoryIdArg) {
		var data={contentIdList:contentIdListArg,
			siteId: siteIdArg,
			categoryId:categoryIdArg
		};

		Simpplr.Salesforce.log('Content.move---contentIdListArg---'+ contentIdListArg); 
		
		return Simpplr.Salesforce.sendRequest({
			data: {'data': JSON.stringify(data)},
			method:'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AllContentDataServer&action=move'
		});
	},

	 setValid :function (contentId, isValid) {
		var data={contentId: contentId, isValid: isValid};
		 return Simpplr.Salesforce.sendRequest({
			data: {'data': JSON.stringify(data)},
			method:'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AllContentDataServer&action=setValid'
		});
	 },
	 
	 getExpiringContentCounts :function (siteId) {
		 Simpplr.Salesforce.log('Content.getExpiringContentCounts---' + 'siteId----' + siteId);
		 return Simpplr.Salesforce.sendRequest({
			data: {'data': JSON.stringify({siteId: siteId})},
			method:'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AllContentDataServer&action=getExpiringContentCounts'
		});
	 },
	 
	 dismissValidation: function (contentId, type) {
		 Simpplr.Salesforce.log('Content.dismissValidation---');
		 return Simpplr.Salesforce.sendRequest({
		 data: {'data': JSON.stringify({contentId: contentId, type: type})},
		 method:'POST',
		 endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AllContentDataServer&action=dismissValidation'
	 });
	 },
	 
	 getVersionHistory: function (data) {
		 Simpplr.Salesforce.log('Content.getVersionHistory---');
		 return Simpplr.Salesforce.sendRequest({
			data: {'data': JSON.stringify(data)},
			method:'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AllContentDataServer&action=getVersionHistory'
		});
	 },
	 
	 restoreVersion: function (contentId, versionId) {
		Simpplr.Salesforce.log('Content.restoreVersion---');
		return Simpplr.Salesforce.sendRequest({
		data: {'data': JSON.stringify({contentId: contentId, versionId: versionId})},
		method:'POST',
		endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AllContentDataServer&action=restoreVersion'
	});
	},
	 
	startContentEdit: function (contentId, versionNumber, contentType) {
	   	Simpplr.Salesforce.log('Content.startContentEdit---');
	
		var endPointURL = "";
  		if("page" === contentType){
			endPointURL = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteAddPageDataServer&action=startContentEdit';

		} else if("event" === contentType){
			endPointURL = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteAddEventDataServer&action=startContentEdit';

		} else if("album" === contentType){
			endPointURL = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=SiteAddAlbumDataServer&action=startContentEdit';

		}

	   return Simpplr.Salesforce.sendRequest({
	   		data: {'data': JSON.stringify({contentId: contentId, versionNumber: versionNumber})},
	   		method: 'POST',
	   		endpoint: endPointURL
	   });
   },
	 
   renewLock: function (contentId) {
	   Simpplr.Salesforce.log('Content.renewLock---');
	   return Simpplr.Salesforce.sendRequest({
	   data: {'data': JSON.stringify({contentId: contentId})},
	   method:'POST',
	   endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AllContentDataServer&action=renewLock'
   });
   },

	optForNotification : function (contentId, isOpenToNotification) {
		Simpplr.Salesforce.log('Content.optForNotification ---');
		return Simpplr.Salesforce.sendRequest({
			data: {'data': JSON.stringify({contentId: contentId, isOpenToNotification: isOpenToNotification})},
			method:'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AllContentDataServer&action=optForNotification '
		});
	},

	getByIds : function (listOfContentId) {
        return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(listOfContentId)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AllContentDataServer&action=getByIds'
		}); 
    },

	getLatestContents : function (data) {
        return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(data)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AllContentDataServer&action=getLatestContents'
      	});
    },

    getPopularContents : function (data) {
        return Simpplr.Salesforce.sendRequest({
			data: {'data' : JSON.stringify(data)},
          	method:'POST',
          	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AllContentDataServer&action=getPopularContents'
      	});
    },

	getMetadata : function (contentId) {
		return Simpplr.Salesforce.sendRequest({
			data: {'data': JSON.stringify({contentId: contentId})},
			method:'POST',
			endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +"?target=AllContentDataServer&action=getMetadata"
		});
	},
	saveContentOnboardingStatus :function (contentIdArg, onboardingStatusArg) {
		var data={contentId:contentIdArg, onboardingStatus:onboardingStatusArg};
  	Simpplr.Salesforce.log('Content.saveContentOnboardingStatus---data---'+ JSON.stringify(data));
  	return Simpplr.Salesforce.sendRequest({
	  data: {'data': JSON.stringify(data)},
	  method:'POST',
	  endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AllContentDataServer&action=saveContentOnboardingStatus'
	});
  },
    updateContentPosition : function(siteId, contentIdsArray){
		var data = {'siteId':siteId,'contentIdsArray':contentIdsArray};
		Simpplr.Salesforce.log('Content.updateContentPosition---data---'+ JSON.stringify(data));
		return Simpplr.Salesforce.sendRequest({
		data: {'data' : JSON.stringify(data)},
		method:'POST',
		endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AllContentDataServer&action=updateContentPosition&siteId='+siteId
    });
  },
  	moveContentToTop : function(siteId, contentId){
		var data = {'siteId':siteId, 'contentId':contentId};
		Simpplr.Salesforce.log('Content.moveContentToTop---data---'+ JSON.stringify(data));
		return Simpplr.Salesforce.sendRequest({
		data: {'data' : JSON.stringify(data)},
		method:'POST',
		endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AllContentDataServer&action=moveContentToTop&siteId='+siteId
	});
  },
  	moveContentToBottom : function(siteId, contentId){
		var data = {'siteId':siteId, 'contentId':contentId};
		Simpplr.Salesforce.log('Content.moveContentToBottom---data---'+ JSON.stringify(data));
		return Simpplr.Salesforce.sendRequest({
		data: {'data' : JSON.stringify(data)},
		method:'POST',
		endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=AllContentDataServer&action=moveContentToBottom&siteId='+siteId
  	});
  },
    getMyOnboardingContents :function (data) {
    	Simpplr.Salesforce.log('Content.getMyOnboardingContents---data---'+ JSON.stringify(data));
    	return Simpplr.Salesforce.sendRequest({
      	data: {'data': JSON.stringify(data)},
      	method:'POST',
      	endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=AllContentDataServer&action=getMyOnboardingContents'
    });
  }
}

