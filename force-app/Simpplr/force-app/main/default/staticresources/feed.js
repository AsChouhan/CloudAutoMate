Simpplr.Salesforce.Feed = Simpplr.Salesforce.Feed || {};
Simpplr.Salesforce.localRepo = Simpplr.Salesforce.localRepo || {};
Simpplr.Salesforce.localRepo.feedIdsInViewPort = Simpplr.Salesforce.localRepo.feedIdsInViewPort || [];

Simpplr.Salesforce.Feed = (function(Simpplr, $){
	var module = {};
    module.User = {};
    var SFDC = {}; 
    SFDC.Utility = {};
    
    if (!String.prototype.startsWith) {
    
	  	String.prototype.startsWith = function(searchString, position) {
	    	position = position || 0;
	    	return this.indexOf(searchString, position) === position;
	  	};
	  	
	}
    
    SFDC.Utility.uint8ToString = function(buf) {
	        var i, length, out = '';
        
	        for (i = 0, length = buf.length; i < length; i += 1) {
	            out += String.fromCharCode(buf[i]);
	        }
        
	        return out;
	}
     
    SFDC.Utility.isFunction = function(fn) {
    	return typeof fn == 'function';
	};
    
	module.delete = function (type, id) {
	
        if (typeof id !== 'undefined' &&  typeof type !== 'undefined') {
        	var requestObj = {};
        	var methodName = '';
        	
        	if (type === 'post') {
        		requestObj.feedElementId = id;
        		requestObj.communityId  =  null;
        		requestObj.action = 'deletefeed';
        	} else {
        		requestObj.commentId = id;
        		requestObj.communityId  =  null;
        		requestObj.action = 'deletecomment';
        	}
        	
        	return Simpplr.Salesforce.sendRequest({
          		data : {'data' : JSON.stringify(requestObj)},
          		method : 'POST',
          		endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ConnectAPIInteractionDataServer'
      		});
      		
        } else {
        	Simpplr.Salesforce.rejectAjaxcall();
        }
       
	};
    
    module.setFavorited = function (id, setFavoritedBool){
        
        if (typeof id !== 'undefined' &&  typeof setFavoritedBool !== 'undefined') {
        
        	var requestObj = {
        		feedElementId : id,
        		communityId : null,
        		action : 'toggleFavorite',
        		setBookmark :  setFavoritedBool
        	};
        	
        	return Simpplr.Salesforce.sendRequest({
          		data : {'data' : JSON.stringify(requestObj)},
          		method : 'POST',
          		endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ConnectAPIInteractionDataServer'
      		});
      		
        } else {
        	Simpplr.Salesforce.rejectAjaxcall();
        }
    }
    
    module.create = function (type, data){


		data.bodyJson = JSON.stringify(data.bodyJson);
		

		data.textBodyOfFeed = data.body.replace(/^(#+)|(\s##+)/g, ' #').trim();
 
		if ((type === 'text' || type === 'recognition' ) && typeof data !== 'undefined') {
        	// Handling file and type posting 
        	if (typeof data.listOfFiles !== 'undefined' && data.listOfFiles !== null && 
        			data.listOfFiles.length > 0) {
	        	var listOfAttachedFile = [];
				var listOfExternalFile = []; 
				
				for (var i = 0; i < data.listOfFiles.length; i++) {
					
					if (data.listOfFiles[i].context.toLowerCase() === 'gdrive' || 
							data.listOfFiles[i].context.toLowerCase() === 'box' || 
							data.listOfFiles[i].context.toLowerCase() === 'dropbox' ||
							data.listOfFiles[i].context.toLowerCase() === 'onedrive' ||
							data.listOfFiles[i].context.toLowerCase() === 'sharepoint' ||
							data.listOfFiles[i].context.toLowerCase() === 'googledrive' ||
							data.listOfFiles[i].context.toLowerCase() === 'native_video'
							) {
							
						// Google and Box files handling 
						listOfExternalFile.push(data.listOfFiles[i]);
					} else {
						// SF files or local files 
						listOfAttachedFile.push(data.listOfFiles[i].id);	
					}
				}
				
				if (listOfExternalFile.length > 0) {
					var externalFileInfoStr = '';
					var fileStarter = '';
					var fileEnd = '';
					var seprator = ' | '; 
					var newLine = '\n';
					var bodyToFileSeprator = '\u2063\uFEFF\u200b\uFEFF\u2063';
					
					for (var i = 0; i < listOfExternalFile.length; i++) {
						var singleFileInfoStr = '';
						if (listOfExternalFile[i].context.toLowerCase() === 'native_video') {
							singleFileInfoStr = newLine + fileStarter + listOfExternalFile[i].title + 
									seprator + listOfExternalFile[i].externalFileId + seprator + 
									listOfExternalFile[i].size + seprator + listOfExternalFile[i].type +
									seprator + listOfExternalFile[i].context + seprator + 
									listOfExternalFile[i].url + fileEnd;
							externalFileInfoStr = externalFileInfoStr + singleFileInfoStr;

						} else if(listOfExternalFile[i].context.toLowerCase() === 'box' || 
								listOfExternalFile[i].context.toLowerCase() === 'gdrive' || 
								listOfExternalFile[i].context.toLowerCase() === 'dropbox' ||
								listOfExternalFile[i].context.toLowerCase() === 'onedrive' ||
								listOfExternalFile[i].context.toLowerCase() === 'sharepoint' ||
								listOfExternalFile[i].context.toLowerCase() === 'googledrive'								
								) {
							
							singleFileInfoStr = newLine + fileStarter + listOfExternalFile[i].title + 
									seprator + listOfExternalFile[i].fileId + seprator + 
									listOfExternalFile[i].size + seprator + listOfExternalFile[i].type +
									seprator + listOfExternalFile[i].context + seprator + 
									listOfExternalFile[i].url + fileEnd;
									
							externalFileInfoStr = externalFileInfoStr + singleFileInfoStr;
						}
					}
					externalFileInfoStr = externalFileInfoStr.substr(1); 	
					data.textBodyOfFeed = data.textBodyOfFeed + bodyToFileSeprator + externalFileInfoStr;
				} 
				
				// If there are sf files attached  
				if (listOfAttachedFile.length > 0) {
					var requestObj = { 
	        			communityId : null,
		        		subjectId : data.subjectId,
		        		feedElementType : data.type,
		        		textBody : data.textBodyOfFeed,
						bodyJson : data.bodyJson,
						externalFiles : listOfExternalFile,
		        		listOfTopic : data.listOfTopics, 
		        		action : 'postFile',
		        		locationURL : location.href,
		        		listOfAttachedFileId : listOfAttachedFile,
						moderationResult : null,
						recognitionBody : null
	        		};
	        	
	        	// If only box/ google files are attached 
        		} else {
        			var requestObj = {
		        		communityId : null,
		        		subjectId : data.subjectId,
		        		feedElementType : data.type, 
		        		textBody : data.textBodyOfFeed,
		        		listOfTopic : data.listOfTopics,
						bodyJson : data.bodyJson,
						externalFiles : listOfExternalFile,
		        		action : 'posttextpost',
		        		locationURL : location.href,
						moderationResult : null,
						recognitionBody : null
		        	};
		        	
        		}
				if (typeof data.moderationResult !== 'undefined' && data.moderationResult !== null) {
					requestObj.moderationResult = data.moderationResult;
				}
				if (typeof data.recognition !== 'undefined' && data.recognition !== null) {
					requestObj.recognitionBody = data.recognition;
				}
	        	//console.log('---172 requestObj---'+requestObj);
	        	return Simpplr.Salesforce.sendRequest({
	          		data : {'data' : JSON.stringify(requestObj)},
	          		method : 'POST',
	          		endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ConnectAPIInteractionDataServer'
	      		});
        	
        	// If no file attached simple text posting 
        	} else {
	        	var requestObj = {
	        		communityId : null,
	        		subjectId : data.subjectId,
	        		feedElementType : data.type, 
	        		textBody : data.textBodyOfFeed,
	        		listOfTopic : data.listOfTopics,
					bodyJson : data.bodyJson,					
	        		action : 'posttextpost',
	        		locationURL : location.href,
					moderationResult : null,
					recognitionBody : null
	        	};
				if (typeof data.moderationResult !== 'undefined' && data.moderationResult !== null) {
					requestObj.moderationResult = data.moderationResult;
				}
				if (typeof data.recognition !== 'undefined' && data.recognition !== null) {
					requestObj.recognitionBody = data.recognition;
				}
	        	return Simpplr.Salesforce.sendRequest({
	          		data : {'data' : JSON.stringify(requestObj)},
	          		method : 'POST',
	          		endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ConnectAPIInteractionDataServer'
	      		});
      		}
      		
        } else if (type === 'link' && typeof data !== 'undefined') {
	        var requestObj = {
        		communityId : null,
        		subjectId : data.subjectId,
        		feedElementType : data.type, 
        		textBody : data.textBodyOfFeed,
				bodyJson : data.bodyJson,
        		urlArg : data.url,
        		urlName : data.name,
        		listOfTopic : data.listOfTopics,
        		action : 'postlink',
        		locationURL : location.href,
				moderationResult : null
        	};
			if (typeof data.moderationResult !== 'undefined' && data.moderationResult !== null) {
				requestObj.moderationResult = data.moderationResult;
			}
        	
        	return Simpplr.Salesforce.sendRequest({
          		data : {'data' : JSON.stringify(requestObj)},
          		method : 'POST',
          		endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ConnectAPIInteractionDataServer'
      		});
      		
	    } else if (type === 'boxFile' && typeof data !== 'undefined') {
	        var requestObj = {
        		communityId : null,
        		subjectId : data.subjectId,
        		feedElementType : data.type, 
        		textBody : data.textBodyOfFeed,
				bodyJson : data.bodyJson,
        		urlArg : data.file.url,
        		urlName : data.file.title,
        		listOfTopic : data.listOfTopics,
        		action : 'postlink',
        		locationURL : location.href,
				moderationResult : null
        	};
			if (typeof data.moderationResult !== 'undefined' && data.moderationResult !== null) {
				requestObj.moderationResult = data.moderationResult;
			}
        	
        	return Simpplr.Salesforce.sendRequest({
          		data : {'data' : JSON.stringify(requestObj)},
          		method : 'POST',
          		endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ConnectAPIInteractionDataServer'
      		});    
      		
        } else if (type === 'poll' && typeof data !== 'undefined') {
        	
        	if (typeof data.textBodyOfFeed !== 'undefined' && data.textBodyOfFeed.indexOf('\n@[005') > 0) {
			    data.textBodyOfFeed = data.textBodyOfFeed.replace('\n@[005', '\n @[005');
			}
			
	        var requestObj = {
        		communityId : null,
        		subjectId : data.subjectId,
        		feedElementType : data.type, 
        		textBody : data.textBodyOfFeed,
				bodyJson : data.bodyJson,
        		listOfPollChoice : data.choices,
        		listOfTopic : data.listOfTopics,
        		action : 'postpoll',
        		locationURL : location.href
        	};
        	
        	return Simpplr.Salesforce.sendRequest({
          		data : {'data' : JSON.stringify(requestObj)},
          		method : 'POST',
          		endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ConnectAPIInteractionDataServer'
      		});
            
        } else if (type === 'boxFileComment' && typeof data !== 'undefined') {
	    	var requestObj = {
    			communityId : null,
    			feedElementId : data.postId,
    			contentDocumentId : null,
    			textBody : data.body +'\n' +data.file.url,
				bodyJson : data.bodyJson,
    			action : 'postcomment',
				moderationResult : null
    		};
			if (typeof data.moderationResult !== 'undefined' && data.moderationResult !== null) {
				requestObj.moderationResult = data.moderationResult;
			}
    	
    		return Simpplr.Salesforce.sendRequest({
      			data : {'data' : JSON.stringify(requestObj)},
      			method : 'POST', 
      			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ConnectAPIInteractionDataServer'
  			});
      		   
        } else if (type === 'comment'  && typeof data !== 'undefined') { 
        	
        	if (typeof data !== 'undefined' && typeof data.postId !== 'undefined' && 
        			typeof data.body !== 'undefined') {
	        	var contentDocIdForComment = null;
	        	
	        	// If files are attached to Comment. 
	        	if (typeof data.listOfFiles !== 'undefined' && data.listOfFiles !== null && 
        			data.listOfFiles.length > 0) {
	        		
	        		var listOfAttachedFileCmnt = [];
					var listOfExternalFileCmnt = []; 
				
					for (var i = 0; i < data.listOfFiles.length; i++) {
						
						if (data.listOfFiles[i].context.toLowerCase() === 'gdrive' ||
								data.listOfFiles[i].context.toLowerCase() === 'dropbox'|| 
								data.listOfFiles[i].context.toLowerCase() === 'box' ||
								data.listOfFiles[i].context.toLowerCase() === 'onedrive' || 
								data.listOfFiles[i].context.toLowerCase() === 'sharepoint' ||
								data.listOfFiles[i].context.toLowerCase() === 'googledrive' ||
								data.listOfFiles[i].context.toLowerCase() === 'native_video') {
							
							//GD, Box files 
							listOfExternalFileCmnt.push(data.listOfFiles[i]);
							
						} else {
							// SF files 
							listOfAttachedFileCmnt.push(data.listOfFiles[i]);	
						}
					}
				
					if (listOfExternalFileCmnt.length > 0) {
						var externalFileInfoStrCmnt = '';
						var fileStarter = '';
						var fileEnd = '';
						var seprator = ' | '; 
						var newLine = '\n';
						var bodyToFileSeprator = '\u2063\uFEFF\u200b\uFEFF\u2063';
						
						for (var i = 0; i < listOfExternalFileCmnt.length; i++) {
							var singleFileInfoStrCmnt = '';
							
							if(listOfExternalFileCmnt[i].context.toLowerCase() === 'native_video') {
								singleFileInfoStrCmnt = newLine + fileStarter + listOfExternalFileCmnt[i].title + 
										seprator + listOfExternalFileCmnt[i].externalFileId + seprator + 
										listOfExternalFileCmnt[i].size + seprator + listOfExternalFileCmnt[i].type +
										seprator + listOfExternalFileCmnt[i].context + seprator +
										listOfExternalFileCmnt[i].url + fileEnd;
								externalFileInfoStrCmnt = externalFileInfoStrCmnt + singleFileInfoStrCmnt;
										
							} else if (listOfExternalFileCmnt[i].context.toLowerCase() === 'box' || 
									listOfExternalFileCmnt[i].context.toLowerCase() === 'gdrive' ||
									listOfExternalFileCmnt[i].context.toLowerCase() === 'dropbox' || 
									listOfExternalFileCmnt[i].context.toLowerCase() === 'onedrive' || 
									listOfExternalFileCmnt[i].context.toLowerCase() === 'sharepoint' ||
									listOfExternalFileCmnt[i].context.toLowerCase() === 'googledrive') {
									
								singleFileInfoStrCmnt = newLine + fileStarter + listOfExternalFileCmnt[i].title + 
										seprator + listOfExternalFileCmnt[i].fileId + seprator + 
										listOfExternalFileCmnt[i].size + seprator + listOfExternalFileCmnt[i].type +
										seprator + listOfExternalFileCmnt[i].context + seprator +
										listOfExternalFileCmnt[i].url + fileEnd;
										
								externalFileInfoStrCmnt = externalFileInfoStrCmnt + singleFileInfoStrCmnt;
							}
						}
						externalFileInfoStrCmnt = externalFileInfoStrCmnt.substr(1);
						data.body = data.body + bodyToFileSeprator + externalFileInfoStrCmnt;
						
					}
					
					if (listOfAttachedFileCmnt.length > 0) {
		        		contentDocIdForComment = listOfAttachedFileCmnt[0].id;
		        	}
		        	
				}
	        	
	        	var requestObj = {
        			communityId : null,
        			feedElementId : data.postId,
        			contentDocumentId : contentDocIdForComment,
        			textBody : data.body,
					bodyJson : data.bodyJson,
					externalFiles : listOfExternalFileCmnt,
        			action : 'postcomment',
					moderationResult : null
        		};
				if (typeof data.moderationResult !== 'undefined' && data.moderationResult !== null) {
					requestObj.moderationResult = data.moderationResult;
				}
        	
        		return Simpplr.Salesforce.sendRequest({
          			data : {'data' : JSON.stringify(requestObj)},
          			method : 'POST', 
          			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ConnectAPIInteractionDataServer'
      			});
	       
		            
        	} else {
        		Simpplr.Salesforce.rejectAjaxcall();
        	}
        	
        } else if (type === 'Topic' && typeof data !== 'undefined') {
	        
           var requestObj = {
        		communityId : null,
        		feedElementId : data.postId,
        		listOfTopic : data.listOfTopic,
        		action : 'upserttopic'
        	};
        	
        	return Simpplr.Salesforce.sendRequest({
          		data : {'data' : JSON.stringify(requestObj)},
          		method : 'POST',
          		endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ConnectAPIInteractionDataServer'
      		});
      		
        }
        
    }
    
    module.vote = function (postId, choiceId) {
        
        if (typeof postId !== 'undefined'  && typeof choiceId !== 'undefined') {
	        var requestObj = {
	    		communityId : null,
	    		feedElementId : postId,
	    		myChoiceId : choiceId, 
	    		action : 'voteonpoll'
	    	};
	    	
	    	
	    	return Simpplr.Salesforce.sendRequest({
	      		data : {'data' : JSON.stringify(requestObj)},
	      		method : 'POST',
	      		endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ConnectAPIInteractionDataServer'
	  		});
	  		
  		} else {
  			Simpplr.Salesforce.rejectAjaxcall();
  		}
    }
    
    module.share = function (postId, data) {
    	
        if (typeof postId !== 'undefined'  && typeof data !== 'undefined') {
			data.bodyJson = JSON.stringify(data.bodyJson);
	    	var requestObj = {
	    		communityId : null,
	    		subjectId : data.subjectId,
	    		feedElementType : data.type, 
	    		originalFeedElementId : postId,
	    		commentText : data.body, 
				bodyJson : data.bodyJson,
	    		action : 'sharefeed'
	    	};
	    	
	    	return Simpplr.Salesforce.sendRequest({
	      		data : {'data' : JSON.stringify(requestObj)},
	      		method : 'POST',
	      		endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FeedShareDataServer'
	  		});
	  		
  		} else {
  			Simpplr.Salesforce.rejectAjaxcall();
  		}
    }
    
	module.setLiked = function(data, setLikedBool) {
        
		var likeId = data.likeId;
		var postId = data.postId;
		var replyId = data.replyId;
		
		
        if (typeof likeId !== 'undefined' &&  typeof postId !== 'undefined' && typeof replyId !== 'undefined' && typeof setLikedBool !== 'undefined') {
        	if(replyId === null){
				var requestObj = {};
				
				if (setLikedBool) {
					requestObj.feedElementId = postId;
					requestObj.communityId  =  null;
					requestObj.action = 'likefeed';
					
				} else {
					requestObj.feedElementId = postId;
					requestObj.likeId = likeId;
					requestObj.communityId  =  null;
					requestObj.action = 'unlikefeed';
				}
				
				return Simpplr.Salesforce.sendRequest({
					data : {'data' : JSON.stringify(requestObj)},
					method : 'POST',
					endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ConnectAPIInteractionDataServer'
				});
			} else if(replyId !== null){
				var requestObj = {};
				
				if (setLikedBool) {
					requestObj.feedElementId = postId;
					requestObj.commentId = replyId;
					requestObj.communityId  =  null;
					requestObj.action = 'likecomment';
					
				} else {
					requestObj.feedElementId = postId;
					requestObj.likeId = likeId;
					requestObj.commentId = replyId;
					requestObj.communityId  =  null;
					requestObj.action = 'unlikecomment';
				}
				
				return Simpplr.Salesforce.sendRequest({
					data : {'data' : JSON.stringify(requestObj)}, 
					method : 'POST',
					endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ConnectAPIInteractionDataServer'
				});			
			
			}	
        } else {
        	Simpplr.Salesforce.rejectAjaxcall();
        }
        
    };
    
    module.edit =  function (type, postId, data) {
		data.bodyJson = JSON.stringify(data.bodyJson);
    	if (typeof type !== 'undefined' && type == "topic" && typeof data !== 'undefined' && typeof postId != 'undefined') {
            
            var requestObj = {
        		communityId : null,
        		feedElementId : postId,
        		listOfTopic : data.listOfTopics,
        		action : 'upserttopic'
        	};
        	
        	return Simpplr.Salesforce.sendRequest({
          		data : {'data' : JSON.stringify(requestObj)},
          		method : 'POST', 
          		endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ConnectAPIInteractionDataServer'
      		});
	
        } else if (typeof type !== 'undefined' && (type === 'post' || type === 'recognition' ) && typeof data !== 'undefined'
        		&& typeof postId != 'undefined') {
        	
        	// File type post only gdrive and box.  SF files can't be edited. 
        	if (typeof data.listOfFiles !== 'undefined' && data.listOfFiles !== null && 
        			data.listOfFiles.length > 0) {
				var listOfExternalFile = []; 
				
				for (var i = 0; i < data.listOfFiles.length; i++) {
					
					if (typeof data.listOfFiles[i].id !== 'undefined' && 
							data.listOfFiles[i].context !== null && 
							(data.listOfFiles[i].context.toLowerCase() === 'gdrive' || 
								data.listOfFiles[i].context.toLowerCase() === 'dropbox' || 
								data.listOfFiles[i].context.toLowerCase() === 'box' ||
								data.listOfFiles[i].context.toLowerCase() === 'onedrive' || 
								data.listOfFiles[i].context.toLowerCase() === 'sharepoint' ||
								data.listOfFiles[i].context.toLowerCase() === 'googledrive' ||
								data.listOfFiles[i].context.toLowerCase() === 'native_video')) {
						
						// Gdrive and box files 
						listOfExternalFile.push(data.listOfFiles[i]);
					} 
				}
				
				if (listOfExternalFile.length > 0) {
					var externalFileInfoStr = '';
					var fileStarter = '';
					var fileEnd = '';
					var seprator = ' | '; 
					var newLine = '\n';
					var bodyToFileSeprator = '\u2063\uFEFF\u200b\uFEFF\u2063';
					
					for (var i = 0; i < listOfExternalFile.length; i++) {
						var singleFileInfoStr = '';
						
						if(listOfExternalFile[i].context.toLowerCase() === 'native_video') {
							singleFileInfoStr = newLine + fileStarter + listOfExternalFile[i].title + 
									seprator + listOfExternalFile[i].externalFileId + seprator + 
									listOfExternalFile[i].size + seprator + listOfExternalFile[i].type +
									seprator + listOfExternalFile[i].context + seprator + 
									listOfExternalFile[i].url + fileEnd;
							externalFileInfoStr = externalFileInfoStr + singleFileInfoStr;

						} else if (listOfExternalFile[i].context.toLowerCase() === 'box' || 
								listOfExternalFile[i].context.toLowerCase() === 'gdrive' ||
								listOfExternalFile[i].context.toLowerCase() === 'dropbox' ||
								listOfExternalFile[i].context.toLowerCase() === 'onedrive' || 
								listOfExternalFile[i].context.toLowerCase() === 'sharepoint' ||
								listOfExternalFile[i].context.toLowerCase() === 'googledrive') {
							
							singleFileInfoStr = newLine + fileStarter + listOfExternalFile[i].title + 
									seprator + listOfExternalFile[i].fileId + seprator + 
									listOfExternalFile[i].size + seprator + listOfExternalFile[i].type +
									seprator + listOfExternalFile[i].context + seprator + 
									listOfExternalFile[i].url + fileEnd;
							externalFileInfoStr = externalFileInfoStr + singleFileInfoStr;
						} 
					}
					externalFileInfoStr = externalFileInfoStr.substr(1);
					data.body = data.body + bodyToFileSeprator + externalFileInfoStr;
					
				}
				
        	}
        	
        	var requestObj = {
        		communityId : null,
        		feedElementId : postId,
        		textBody : data.body,
				bodyJson : data.bodyJson,
				externalFiles : listOfExternalFile,
        		action : 'updatefeed',
				locationURL : location.href,
				moderationResult : null,
				recognitionBody : null
        	};
			if (typeof data.moderationResult !== 'undefined' && data.moderationResult !== null) {
				requestObj.moderationResult = data.moderationResult;
			}
			if (typeof data.recognition !== 'undefined' && data.recognition !== null) {
				requestObj.recognitionBody = data.recognition;
			}
        	
        	return Simpplr.Salesforce.sendRequest({
          		data : {'data' : JSON.stringify(requestObj)},
          		method : 'POST', 
          		endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ConnectAPIInteractionDataServer'
      		});
            
        } else if (typeof type !== 'undefined' && type == "comment" && typeof data !== 'undefined' &&
        		typeof postId != 'undefined') {
        		
        	if (typeof data.listOfFiles !== 'undefined' && data.listOfFiles !== null && 
        			data.listOfFiles.length > 0) {
        		var listOfExternalCommentFile = [];
				
				for (var i = 0; i < data.listOfFiles.length; i++) {
					
					if ( typeof data.listOfFiles[i].id !== 'undefined' &&  
							data.listOfFiles[i].context !== null && 
							(data.listOfFiles[i].context.toLowerCase() === 'gdrive' || 
								data.listOfFiles[i].context.toLowerCase() === 'dropbox' ||
								data.listOfFiles[i].context.toLowerCase() === 'box' ||
								data.listOfFiles[i].context.toLowerCase() === 'onedrive' || 
								data.listOfFiles[i].context.toLowerCase() === 'sharepoint' ||
								data.listOfFiles[i].context.toLowerCase() === 'googledrive' ||
								data.listOfFiles[i].context.toLowerCase() === 'native_video')) {
						listOfExternalCommentFile.push(data.listOfFiles[i]);
					} 
				}
				
				if (listOfExternalCommentFile.length > 0) {
					var externalFileInfoStrCmnt = '';
					var fileStarter = '';
					var fileEnd = '';
					var seprator = ' | '; 
					var newLine = '\n';
					var bodyToFileSeprator = '\u2063\uFEFF\u200b\uFEFF\u2063';
					
					for (var i = 0; i < listOfExternalCommentFile.length; i++) {
						var singleFileInfoStrCmnt = '';
						
						if(listOfExternalCommentFile[i].context.toLowerCase() === 'native_video') {
							singleFileInfoStrCmnt = newLine + fileStarter + listOfExternalCommentFile[i].title + 
									seprator + listOfExternalCommentFile[i].externalFileId + seprator + 
									listOfExternalCommentFile[i].size + seprator + listOfExternalCommentFile[i].type +
									seprator + listOfExternalCommentFile[i].context + seprator + 
									listOfExternalCommentFile[i].url + fileEnd;
									
							externalFileInfoStrCmnt = externalFileInfoStrCmnt + singleFileInfoStrCmnt;

						} else if (listOfExternalCommentFile[i].context.toLowerCase() === 'box' || 
								listOfExternalCommentFile[i].context.toLowerCase() === 'gdrive' || 
								listOfExternalCommentFile[i].context.toLowerCase() === 'dropbox' ||
								listOfExternalCommentFile[i].context.toLowerCase() === 'onedrive' || 
								listOfExternalCommentFile[i].context.toLowerCase() === 'sharepoint' ||
								listOfExternalFile[i].context.toLowerCase() === 'googledrive') {
							
							singleFileInfoStrCmnt = newLine + fileStarter + listOfExternalCommentFile[i].title + 
									seprator + listOfExternalCommentFile[i].fileId + seprator + 
									listOfExternalCommentFile[i].size + seprator + listOfExternalCommentFile[i].type +
									seprator + listOfExternalCommentFile[i].context + seprator + 
									listOfExternalCommentFile[i].url + fileEnd;
									
							externalFileInfoStrCmnt = externalFileInfoStrCmnt + singleFileInfoStrCmnt;
						} 
					}
					externalFileInfoStrCmnt = externalFileInfoStrCmnt.substr(1);
					data.body = data.body + bodyToFileSeprator + externalFileInfoStrCmnt;
				}
				
        	}

            var requestObj = {
        		communityId : null,
        		commentId : postId,
        		commentText : data['body'],
				bodyJson : data.bodyJson,
				externalFiles : listOfExternalCommentFile,
        		action : 'updatecomment',
				moderationResult : null
        	};
			if (typeof data.moderationResult !== 'undefined' && data.moderationResult !== null) {
				requestObj.moderationResult = data.moderationResult;
			}
        	
        	return Simpplr.Salesforce.sendRequest({
          		data : {'data' : JSON.stringify(requestObj)}, 
          		method : 'POST', 
          		endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ConnectAPIInteractionDataServer'
      		});
            
        } else {
        	Simpplr.Salesforce.rejectAjaxcall();
        }
        
    }
    
    
    module.checkForUpdates = function (data) {
    	var feedRefreshEndPointURL = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FeedUpdatesServer';
    	
		var requestObj = {
			pageName : data.pageName,
			subjectId : data.subjectId,
			timeStamp : data.timeStamp,
			updatesToken : data.updatesToken,
			type : data.type,
			idsInViewPort : JSON.stringify(Simpplr.Salesforce.localRepo.feedIdsInViewPort),
			sortBy : data.sortBy
		};
		Simpplr.Salesforce.log(requestObj);	
		return Simpplr.Salesforce.sendRequest({
	       	data : requestObj,
	        method :'GET',
	    	endpoint : feedRefreshEndPointURL
      	});
      	
    }
    
	module.search = function (data) {
		var feedEndPointURL = Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FeedDataServer&action=search';
		var requestObj = { 
			nextPageToken: data.nextPageToken,
			size: data.size,
			subjectId: data.subjectId,
			type: data.type,
			term: data.term,
			sort: data.sort,
			postId: data.postId,
			postIds: data.postIds
		};
	 				
		return Simpplr.Salesforce.sendRequest({
	       	data : requestObj,
	        method :'GET',
	    	endpoint : feedEndPointURL
      	}).done(function(data){
      		
      		if (typeof data !== 'undefined' && typeof data.result !== 'undefined' && typeof data.result.listOfItems !== 'undefined') {
      			
      			for (var i = 0; i < data.result.listOfItems.length; i++) {
      				Simpplr.Salesforce.localRepo.feedIdsInViewPort.push(data.result.listOfItems[i].id);
      			}
      			
      		}
      		
      	});
	}
	
	module.getReplies = function (data) {
		
		if (typeof data !== 'undefined') {
			
			if (typeof data.nextPageToken === 'undefined') {
				data.nextPageToken = null;
			}
			
			return Simpplr.Salesforce.sendRequest({
	        	data : {'data' : JSON.stringify(data)},
	          	method :'GET',
	          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FeedCommentDataServer'
      		});
      		
      	} else {
        	Simpplr.Salesforce.rejectAjaxcall();
        }
      
	}
	
	module.getPollResults = function (pollId) {
	
		if (typeof pollId !== 'undefined') {
			var requestObj = { 
        		communityId : null,
        		feedElementId : pollId,
        		action : 'getpollresults'
        	};
        	
			return Simpplr.Salesforce.sendRequest({
	        	data : {'data' : JSON.stringify(requestObj)},
	          	method :'GET',
	          	endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ConnectAPIInteractionDataServer'
      		});
      		
      	} else {
        	Simpplr.Salesforce.rejectAjaxcall();
        }
	}
	
	module.saveSortBy = function (filterValueArg) {
		var requestObj = {
    		filterValue : filterValueArg,
    		action : 'savesortby'
    	}; 
    	
    	return Simpplr.Salesforce.sendRequest({
      		data : {'data' : JSON.stringify(requestObj)}, 
      		method : 'POST', 
      		endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ConnectAPIInteractionDataServer'
  		});
	}
	
	module.saveFilterBy = function (filterValueArg) {
		var requestObj = {
    		filterValue : filterValueArg,
    		action : 'savefilterby'
    	}; 
    	
    	return Simpplr.Salesforce.sendRequest({
      		data : {'data' : JSON.stringify(requestObj)}, 
      		method : 'POST', 
      		endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=ConnectAPIInteractionDataServer'
  		});
	} 
	
	module.getLikers = function (params) {
		Simpplr.Salesforce.log('Salesforce.Feed---data---'+ JSON.stringify(params));
    	return Simpplr.Salesforce.sendRequest({
      		data : {'postId' : params.postId, 'commentId':params.commentId,'nextPageToken':params.nextPageToken,'size':params.size}, 
      		method : 'POST', 
      		endpoint : Simpplr.Salesforce.Endpoints.ReadWrite +'?target=FeedLikeDataServer'
  		});
    }
    
    module.getPopularContent = function (params) {
    	return Simpplr.Salesforce.sendRequest({
      		data : {'siteId': params.siteId}, 
      		method : 'POST', 
      		endpoint : Simpplr.Salesforce.Endpoints.ReadWrite + '?target=FeedDataServer&action=getPopularContent'
  		});
	}
	
	module.getUpcomingEvents = function (params) {
		return Simpplr.Salesforce.sendRequest({
			data : {'siteId': params.siteId}, 
			method : 'POST', 
			endpoint : Simpplr.Salesforce.Endpoints.ReadWrite + '?target=FeedDataServer&action=getUpcomingEvents'
		});
    }
	
	module.getMustReadContent = function (params) {
    	return Simpplr.Salesforce.sendRequest({
      		data : {'siteId': params.siteId}, 
      		method : 'POST', 
      		endpoint : Simpplr.Salesforce.Endpoints.ReadWrite + '?target=FeedDataServer&action=getMustReadContent'
  		});
	}

	module.getPeoplePosts = function (params) {
    	return Simpplr.Salesforce.sendRequest({
      		data : {'variant': params.variant}, 
      		method : 'GET', 
      		endpoint : Simpplr.Salesforce.Endpoints.ReadWrite + '?target=FeedDataServer&action=getPeoplePosts'
  		}); 
	}

	module.getFeedOnboardingContent = function (params) {
    	return Simpplr.Salesforce.sendRequest({
      		data : {'siteId': params.siteId}, 
      		method : 'POST', 
      		endpoint : Simpplr.Salesforce.Endpoints.ReadWrite + '?target=FeedDataServer&action=getFeedOnboardingContent'
  		});
	}

	module.saveFeedOnboardingFlag = function (params) {
    	return Simpplr.Salesforce.sendRequest({
      		data : {'isOnboardingDisabledOnFeed': params.isOnboardingDisabledOnFeed}, 
      		method : 'POST', 
      		endpoint : Simpplr.Salesforce.Endpoints.ReadWrite + '?target=FeedDataServer&action=saveFeedOnboardingFlag'
  		});
	}

	return module;
})(Simpplr, jQuery);
