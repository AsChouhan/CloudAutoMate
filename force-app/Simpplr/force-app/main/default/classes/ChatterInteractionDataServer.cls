/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class ChatterInteractionDataServer extends DataServer {

	public ChatterInteractionDataServer () {
		 
	}
	public override void handleRequest (){
		try {
			String recordId = readSafeParam('recordId');
			String actionType = readSafeParam('action');
			String likeType = readSafeParam('likeType');
			String subjectId = readSafeParam('subjectId');
			String url = readSafeParam('url');
			String urlName = readParam('urlName');
			String contentId = readSafeParam('contentId');
			String albumMediaId = readSafeParam('albumMediaId');
			String campaignId = readSafeParam('campaignId');
			String textToPost = readParam('textToPost');
			String bodyJson = readParam('bodyJson');

			logger.logDebug('entered Media recordId = '+recordId +'likeType = ' + likeType+' actionType = '+actionType);
			if ('content'.equalsIgnoreCase(likeType) && String.isNotBlank(actionType) && recordId != null) {
				if(actionType.equalsIgnoreCase('like')){
					response = likeContent(recordId);
				}else{
					response = unlikeContent(recordId);
				}
			} else if ('file'.equalsIgnoreCase(likeType) && String.isNotBlank(actionType) && recordId != null) {
				if(actionType.equalsIgnoreCase('like')){
					response = likeFile(recordId);
				} else {
					response = unlikeFile(recordId);
				}
			} else if ('share'.equalsIgnoreCase(actionType)) {
				if(String.isNotBlank(URL)){
					URL = URL.replaceAll('\\\\', '');
				}
				String successStr = '';
				Boolean isSuccess ;
				// share album media file if albumMediaId is not blank
				logger.logDebug('#########albumMediaId===='+ albumMediaId);
				if (String.isNotBlank(albumMediaId)) {
					response = shareAlbumMediaToFeed (subjectId, url, urlName, textToPost, bodyJson, contentId, albumMediaId);
				} else if (String.isNotBlank(campaignId)) {
					response = shareCampaignToFeed (subjectId, url, urlName, textToPost, bodyJson, campaignId);
				} else {
					response = shareContentToFeed (subjectId, url, urlName, textToPost, bodyJson, contentId);
				}
				
			} else if('media'.equalsIgnoreCase(likeType) && String.isNotBlank(actionType) && recordId != null){
				logger.logDebug('entered Media');
				if(actionType.equalsIgnoreCase('like')){
					logger.logDebug('entered Media Like');
					response = likeMedia(recordId);
				}else{
					response = unlikeMedia(recordId);
				}
					
			}
		} catch(Exception e) {
			logger.logError('ChatterInteractionDataServer.handleRequest()-----could not retrieve data----',e);
       		response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
		}
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	@testVisible 
	private ResponseWrapper likeContent (String contentIdArg) {
		Savepoint sp = Database.setSavepoint(); 
		ResponseWrapper responseToReturn = null;
		try {
			String currentUserPeopleId = UserContext.peopleId;
			List<Like__c> listOfContentLikes = [SELECT Id FROM Like__c
					WHERE Content__r.Id =: contentIdArg AND people__c =: currentUserPeopleId WITH SECURITY_ENFORCED];
			List<Simpplr_Content__c> simpplrContentList;
			
			if (listOfContentLikes.isEmpty()) {
				Like__c likeObj = new Like__c();
				likeObj.Content__c = contentIdArg;
				likeObj.People__c = UserContext.getCurrentUserInfo.Id;
				
					
				simpplrContentList = [SELECT id,Likes__c, type__c ,
						Primary_Author__c, Primary_Author__r.User__c, Primary_Author__r.First_Name__c, 
						Title__c, Site__c, Site__r.name, Site__r.Chatter_Group_Id__c, Display_Excerpt__c,
						Primary_Author__r.External_Photo_URL__c, 
						Primary_Author__r.External_Photo_URL_Expiry_Date__c, Primary_Author__r.Full_Name__c   
						FROM Simpplr_Content__c 
						WHERE ID =: contentIdArg WITH SECURITY_ENFORCED];
				if(simpplrContentList.isEmpty()){
					throw new SimpplrException(ServiceConstants.ERROR_404);
				}
				likeObj.Like_Receiver__c = 	simpplrContentList[0].Primary_Author__c	;
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
	   			SIMPESAPI.accessController().insertAsUser(likeObj, 
	   					new List<Schema.SObjectField>{ 
	   						Like__c.Content__c, Like__c.Like_Receiver__c, Like__c.People__c
	   					}
	   			);	
	   			
				simpplrContentList[0].Likes__c = simpplrContentList[0].Likes__c + 1;
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
	    		SIMPESAPI.accessController().updateAsUser(simpplrContentList[0], new List<Schema.SObjectField>{
	    				Simpplr_Content__c.Likes__c});
	    		NotificationDispatcher.sendEmailForContentLike(simpplrContentList[0]);
	    		NotificationDispatcher.sendNotificationForContentLike(simpplrContentList[0]);
			}
			
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, true);
			
		} catch (exception e) {
			logger.logError('ChatterInteractionDataServer.likeContent()-----could not retrieve data----',e);
			Database.rollback(sp);
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, false);
		}
		return responseToReturn;
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	@testVisible
	private ResponseWrapper unlikeMedia(String fileIdArg) {
		ResponseWrapper responseToReturn = null;
		try{
			String currentUserPeopleId = UserContext.peopleId;
			list<Like__c>likeList = [select ID, File__c,people__c from Like__c where File__c =:fileIdArg and people__c =: currentUserPeopleId WITH SECURITY_ENFORCED];
			
			if(!likeList.isEmpty()){
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
   				SIMPESAPI.accessController().deleteAsUser(likeList);
				
				File__c fileObj = new File__c();
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', fileIdArg);
				String fileQuery  = 'select ID,Likes__c from File__c where ID =: soqlParam1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				fileObj = ((List<File__c>)SIMPESAPI.accessController().queryAsUser(fileQuery, soqlParamMap)).get(0);

	   			fileObj.Likes__c = fileObj.Likes__c - 1;
	   			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	    		SIMPESAPI.accessController().updateAsUser(fileObj, new List<Schema.SObjectField>{
	    				File__c.Likes__c});
			}
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, true);
			
		} catch (Exception e) {
			logger.logError('ChatterInteractionDataServer.unlikeMedia()-----could not retrieve data----',e);
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, false);
		}
		return responseToReturn;
	}
	
	@testVisible
	private ResponseWrapper likeMedia(String fileIdArg) {
		ResponseWrapper responseToReturn = null;
		try{
			String currentUserPeopleId = UserContext.peopleId;
			list<Like__c>likeList = [select ID, File__c,people__c from Like__c where File__c =:fileIdArg and people__c =: currentUserPeopleId WITH SECURITY_ENFORCED];
			
			if(likeList.isEmpty()){
				Like__c likeObj = new Like__c();
				likeObj.File__c = FileIdArg;
				likeObj.People__c = currentUserPeopleId;
				
				File__c fileObj = new File__c();
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', fileIdArg);
				String fileQuery = 'select ID,Likes__c,Author__c,Author__r.User__c,Simpplr_Content__r.Primary_Author__c,Mime_Type__c,Simpplr_Content__r.Album_Allow_All_to_Upload__c from File__c where ID =: soqlParam1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				fileObj = ((List<File__c>)SIMPESAPI.accessController().queryAsUser(fileQuery, soqlParamMap)).get(0);

				likeObj.Like_Receiver__c = fileObj.Author__c;
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().insertAsUser(likeObj, 
	   					new List<Schema.SObjectField>{ 
	   						Like__c.File__c, Like__c.People__c, Like__c.Like_Receiver__c
	   					}
	   				);
				
	   			fileObj.Likes__c = fileObj.Likes__c == null ? 1 :  fileObj.Likes__c + 1;
	   			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	    		SIMPESAPI.accessController().updateAsUser(fileObj, new List<Schema.SObjectField>{
	    				File__c.Likes__c});
				Simpplr_Content__c simpplrContentObj = [SELECT id,Likes__c, Type__c ,Primary_Author__c, Primary_Author__r.User__c, Primary_Author__r.First_Name__c, 
															Title__c, Site__c, Site__r.name, Site__r.Chatter_Group_Id__c, Display_Excerpt__c,
															Primary_Author__r.External_Photo_URL__c,
															Primary_Author__r.External_Photo_URL_Expiry_Date__c, Primary_Author__r.Full_Name__c,
															(select id from File_Simpplr_Content__r) 
															FROM Simpplr_Content__c 
															WHERE ID =: fileObj.Simpplr_Content__c WITH SECURITY_ENFORCED];
		
				NotificationDispatcher.sendEmailForMediaLike(fileObj,simpplrContentObj);
				NotificationDispatcher.sendNotificationForMediaLike(fileObj,simpplrContentObj);
			} 
			
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, true);
		} catch (Exception e) {
			logger.logError('ChatterInteractionDataServer.likeMedia()-----could not retrieve data----',e);
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, false);
		}
		return responseToReturn;
	}
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	@testVisible
	private ResponseWrapper unlikeContent(String contentIdArg) {
		Savepoint sp = Database.setSavepoint();
		ResponseWrapper responseToReturn = null;
		try {
			String currentUserPeopleId = UserContext.peopleId;
			List<Like__c> listOfContentLikes = new List<Like__c>();
			listOfContentLikes =[SELECT Id FROM Like__c
					WHERE Content__r.Id =: contentIdArg AND people__c =: currentUserPeopleId WITH SECURITY_ENFORCED];
				
			if (!listOfContentLikes.isEmpty()) {
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
   				SIMPESAPI.accessController().deleteAsUser(listOfContentLikes);
				List<Simpplr_Content__c> simpplrContentList = [SELECT Id, Likes__c  FROM Simpplr_Content__c 
						WHERE ID =: contentIdArg WITH SECURITY_ENFORCED];
						
				if(simpplrContentList.isEmpty()){
					throw new SimpplrException(ServiceConstants.ERROR_404);
				}
				simpplrContentList[0].Likes__c = simpplrContentList[0].Likes__c > 0 ? simpplrContentList[0].Likes__c - 1 : 0;
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
    			SIMPESAPI.accessController().updateAsUser(simpplrContentList[0],new List<Schema.SObjectField>{
    					Simpplr_Content__c.Likes__c});
				
				responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, true);
				
			} else {
				responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, false);
			}
			
		} catch (exception e) {
			logger.logError('ChatterInteractionDataServer.unlikeContent()-----could not retrieve data----',e);		
			Database.rollback(sp);
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, false);
		}
		return responseToReturn;
	}
	
	@testVisible
	private ResponseWrapper likeFile (String fileIdArg) {
		Savepoint sp = Database.setSavepoint(); 
		ResponseWrapper responseToReturn = null;
		try {
			String currentUserPeopleId = UserContext.peopleId;
			List<Like__c> listOfFileLikes = [SELECT Id FROM Like__c
					WHERE External_File_Id__c =: fileIdArg AND people__c =: currentUserPeopleId WITH SECURITY_ENFORCED];
					
			if (listOfFileLikes.isEmpty()) {
				Like__c likeObj = new Like__c();
				likeObj.External_File_Id__c = fileIdArg;
				likeObj.People__c = UserContext.getCurrentUserInfo.Id;
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
	   			SIMPESAPI.accessController().insertAsUser(likeObj, new List<Schema.SObjectField>{
	   					Like__c.External_File_Id__c, Like__c.People__c});
			}
			 
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, true);
			
		} catch (exception e) {
			logger.logError('ChatterInteractionDataServer.likeFile()-----could not retrieve data----',e);					
			Database.rollback(sp);
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, false);
		}
		return responseToReturn;
	}
	
	@testVisible
	private ResponseWrapper unlikeFile(String fileIdArg) {
		Savepoint sp = Database.setSavepoint();
		ResponseWrapper responseToReturn = null;
		try {
			String currentUserPeopleId = UserContext.peopleId;
			List<Like__c> listOfFileLikes = [SELECT Id FROM Like__c
											 WHERE External_File_Id__c =: fileIdArg 
											 AND people__c =: currentUserPeopleId WITH SECURITY_ENFORCED];
			
			if (!listOfFileLikes.isEmpty()) {
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
   				SIMPESAPI.accessController().deleteAsUser(listOfFileLikes);
				
				responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, true);
				
			} else {
				responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, false);
			}
			
		} catch (exception e) {
			logger.logError('ChatterInteractionDataServer.unlikeFile()-----could not retrieve data----',e);							
			Database.rollback(sp);
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, false);
		}
		return responseToReturn;
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	@testVisible
	private ResponseWrapper shareContentToFeed (String subjectIdArg, String urlArg,
			String urlNameArg, String textToPostArg, String bodyJson, String contentId) {
		ResponseWrapper responseToReturn = null;		
		try {
			String resultData = '';
			String feedElementType = 'News';
			ConnectApi.FeedElement feedElementObj;  
			urlArg+='&utm_term=content_share&utm_source=activity_notifications_email&utm_medium=email' ;
			if (textToPostArg.indexOf(ServiceConstants.FEED_EXT_FILE_SEPRATOR) >= 0) {
				feedElementObj = FeedConnectAPIService.postFeedElementWithOutCapability(
						null, subjectIdArg, feedElementType, textToPostArg, bodyJson,null);
						
			} else {
				 feedElementObj = FeedConnectAPIService.postFeedElementWithLinkCapability(
						null, subjectIdArg, feedElementType, urlArg, urlNameArg, textToPostArg,bodyJson);
			}
			
            
            if (feedElementObj != null && String.isNotBlank(contentId)) {
				Share__c shareObj = new Share__c();
				shareObj.people__c = UserContext.peopleId;
				shareObj.Feed_Item_Id__c = feedElementObj.id;
				shareObj.Content__c = contentId;
				Simpplr_Content__c contentObj = [select id,type__c , Primary_Author__c, Primary_Author__r.User__c,
							Primary_Author__r.First_Name__c, Title__c, Site__c, Shares__c, 
							Display_Excerpt__c, Site__r.name, Site__r.Chatter_Group_Id__c, 
							Primary_Author__r.External_Photo_URL__c, Primary_Author__r.External_Photo_URL_Expiry_Date__c, 
							Primary_Author__r.Full_Name__c FROM Simpplr_Content__c WHERE id=:contentId WITH SECURITY_ENFORCED limit 1];
					shareObj.Share_Receiver__c = contentObj.Primary_Author__c;

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().insertAsUser(shareObj, new List<Schema.SObjectField>{
					Share__c.people__c,
					Share__c.Feed_Item_Id__c,
					Share__c.Content__c,
					Share__c.Share_Receiver__c
				});
                    
				if (contentObj != null) {
					contentObj.Shares__c = contentObj.Shares__c +1;
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().updateAsUser(contentObj, new List<Schema.SObjectField>{Simpplr_Content__c.Shares__c});
					
					NotificationDispatcher.sendEmailForContentShare(contentObj, urlArg, feedElementObj);
					NotificationDispatcher.sendNotificationForContentShare(contentObj, feedElementObj);
				}
			}
			
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, true);
		} catch (Exception e) {
			logger.logError('ChatterInteractionDataServer.shareContentToFeed()-----could not retrieve data----',e);					
  			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, false);
		}
		return responseToReturn;
	}
	
	@testVisible
	private ResponseWrapper shareCampaignToFeed (String subjectIdArg, String urlArg,
			String urlNameArg, String textToPostArg, String bodyJson, String campaignId) {
		ResponseWrapper responseToReturn = null;		
		try {
			String resultData = '';
			String feedElementType = 'News';
			ConnectApi.FeedElement feedElementObj; 
			
			String urlOfCampaignArg =  PageContext.getPageURL(Pages.app) + '?campaignId=' + campaignid;
			
			 feedElementObj = FeedConnectAPIService.postFeedElementWithLinkCapability(
					null, subjectIdArg, feedElementType, urlOfCampaignArg, urlNameArg, textToPostArg, bodyJson);
			
            
            if (feedElementObj != null && String.isNotBlank(campaignId)) {
				Share__c shareObj = new Share__c();
				shareObj.people__c = UserContext.peopleId;
				shareObj.Feed_Item_Id__c = feedElementObj.id;
				shareObj.Social_Campaign__c = campaignId;
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', campaignId);
				String queryStr = 'select id, People__c, People__r.User__c, URL_Preview_Json__c FROM Social_Campaign__c WHERE id=:soqlParam1 limit 1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				Social_Campaign__c campaignObj = (Social_Campaign__c)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap)[0];
				if(campaignObj != null){
					shareObj.Share_Receiver__c = campaignObj.People__c;
				}	
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().insertAsUser(shareObj, new List<Schema.SObjectField>{
								Share__c.people__c,
								Share__c.Feed_Item_Id__c,
								Share__c.Social_Campaign__c,
								Share__c.Share_Receiver__c
							});
				if(campaignObj!=null){
					String chatterGroupid = (String.isNotBlank(subjectIdArg) && subjectIdArg.startsWith('0F9')) ? subjectIdArg : '';
					NotificationDispatcher.sendNotificationForCampaignFeedShare(campaignObj, feedElementObj, chatterGroupid);
				}
				
			} 
			
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, true);
		} catch (Exception e) {
			logger.logError('ChatterInteractionDataServer.shareCampaignToFeed()-----could not retrieve data----',e);					
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, false);
		}
		return responseToReturn;
	}
		
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	@testVisible
	private ResponseWrapper shareAlbumMediaToFeed (String subjectIdArg, String urlArg,
			String urlNameArg, String textToPostArg, String bodyJson, String contentId, String albumMediaId) {
		ResponseWrapper responseToReturn = null;
		logger.logDebug('entered shareAlbumMediaToFeed :: recordId = ');		
		try {
			String resultData = '';
			String feedElementType = 'News';
			ConnectApi.FeedElement feedElementObj = FeedConnectAPIService.postFeedElementWithLinkCapability(
					null, subjectIdArg, feedElementType, urlArg, urlNameArg, textToPostArg, bodyJson);
            
            
            File__c fileObj = new File__c();
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', albumMediaId);
			String fileQuery = 'SELECT ID,Likes__c,Author__c,Author__r.User__c,Simpplr_Content__r.Primary_Author__c,'+
								' Mime_Type__c,Simpplr_Content__r.Album_Allow_All_to_Upload__c'+ 
								' FROM File__c WHERE ID =: soqlParam1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			fileObj = ((List<File__c>)SIMPESAPI.accessController().queryAsUser(fileQuery, soqlParamMap)).get(0);
            
            if (feedElementObj != null && String.isNotBlank(contentId)) {
				
				Simpplr_Content__c contentObj = [select id,type__c , Primary_Author__c, Primary_Author__r.User__c,
							Primary_Author__r.First_Name__c, Title__c, Site__c, Shares__c, 
							Display_Excerpt__c, Site__r.name, Site__r.Chatter_Group_Id__c, 
							Primary_Author__r.External_Photo_URL__c, Primary_Author__r.External_Photo_URL_Expiry_Date__c, 
							Primary_Author__r.Full_Name__c FROM Simpplr_Content__c WHERE id=:contentId WITH SECURITY_ENFORCED limit 1];
                    
				if (contentObj != null) {
					NotificationDispatcher.sendEmailForMediaShare(fileObj,contentObj,feedElementObj.Id);
					NotificationDispatcher.sendNotificationForMediaShare(fileObj,contentObj,feedElementObj.Id);
				}
			}
			
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, true);
		} catch (Exception e) {
			logger.logError('ChatterInteractionDataServer.shareAlbumMediaToFeed()-----could not retrieve data----',e);					
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, false);
		}
		return responseToReturn;
	}
	
}