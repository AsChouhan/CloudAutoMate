/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class SlackDataServer extends DataServer{ 
	
    @TestVisible private final String ACTION_VALUE_GET_SLACK_UNFURL_INFO = 'getSlackUnfurlInfo';
    @TestVisible private final String ACTION_SAVE_SLACK_INFO = 'saveSlackInfoToPeopleInteg';
	@TestVisible private final String ACTION_APP_UNINSTALLED = 'uninstall';
	@TestVisible private final String ACTION_FOLLOW_USER = 'followUser';
	@TestVisible private final String ACTION_FOLLOW_SITE = 'followSite';
	@TestVisible private final String ACTION_REQUEST_SITE =  'requestSiteAccess';
	@TestVisible private final String REQUEST_PARAM_DATA = 'data';
	@TestVisible private final String ACTION_PUSH_TO_SLACK = 'shareContent';
	@TestVisible private final String ACTION_GET_AVAILABLE_SLACK_CHANNELS = 'getAvailableChannels';
	@TestVisible private final String ACTION_ENABLE_SLACK_UNFURL = 'enableSlackUnfurl';

	public List<String> allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).replace('Blog', 'BlogPost').split(',');
		    
    public SlackDataServer() {

    } 
    
    public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }    
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public override void handleRequest() {
    	try{
    		logger.logDebug('SlackDataServer----entered handleRequest----');
            String action = readParam(REQUEST_PARAM_ACTION);
			String likeType = readParam('likeType');
			String recordId = readParam('recordId');
            String dataJSON = readParam(REQUEST_PARAM_DATA);
            
			if(ACTION_VALUE_GET_SLACK_UNFURL_INFO.equalsIgnoreCase(action)){
            	response = getSlackUnfurlInfo(readParam('unfurlUrl'), readParam('setPeopleIntegSlackFlag'));		
            } else if(ACTION_SAVE_SLACK_INFO.equalsIgnoreCase(action)){
            	response = saveSlackInfoToPeopleInteg(readParam('slackUserName'), readParam('teamId'), readParam('slackUserId'));		
            } else if(ACTION_APP_UNINSTALLED.equalsIgnoreCase(action)){
				response = unInstallSlackApp();
			} else if(ACTION_GET_AVAILABLE_SLACK_CHANNELS.equalsIgnoreCase(action)){
				response = getAvailableChannels();
			} else if (action.equalsIgnoreCase('like')) {
				if('content'.equalsIgnoreCase(likeType) && recordId != null){
					response = likeContent(recordId);
				} else if('media'.equalsIgnoreCase(likeType) && recordId != null){
					response = likeMedia(recordId);
				}

			} else if(ACTION_FOLLOW_USER.equalsIgnoreCase(action)){
            	response = followUser(readParam('peopleId'));		
            } else if(ACTION_FOLLOW_SITE.equalsIgnoreCase(action)){
            	response = followSite(readParam('siteId'));		
            } else if(ACTION_REQUEST_SITE.equalsIgnoreCase(action)){
            	response = requestSiteAccess(readParam('data'));		
            } else if(ACTION_PUSH_TO_SLACK.equalsIgnoreCase(action)){
            	response = pushToSlack(readParam('data'));		
            }  else if(ACTION_ENABLE_SLACK_UNFURL.equalsIgnoreCase(action)){
            	response = enableSlackUnfurl(readParam('appName'));	
            } else { 
                throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            }
            
        }catch(Exception ex) {
            logger.logError('Either no page access or action parameter returning wrong data', ex);
       		response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
         }
    }  
    
    @TestVisible private ResponseWrapper getSlackUnfurlInfo(String unfurlUrl, String setPeopleIntegSlackFlag) {
    	logger.logDebug('SlackDataServer.getSlackUnfurlInfo()---unfurlUrl---' + unfurlUrl);
    	ResponseWrapper resultWrapper = new ResponseWrapper();
    	
		try{
			if('true'.equalsIgnoreCase(setPeopleIntegSlackFlag)){
				setSlackConnectedFlag();	
			}
			
            if(!SimpplrContext.slackIntegrationEnabled){
            	throw new SimpplrException('Slack must be enabled within your Org to show a preview of this link');	
            } 			

    		if(String.isBlank(unfurlUrl)){
    			throw new SimpplrException('unfurlUrl parameter not found');
    		}
			
			ResponseStructure slackUnfurlResponse = new ResponseStructure();
			String peopleId ;
			String contentId ;
			String albumFileId;
			String siteId;
			String contentPrefix = Utility.getSimpplrContentPrefix();
			String peoplePrefix = Utility.getPeoplePrefix();
			String sitePrefix = Utility.getSimpplrSitePrefix();
			String filePrefix = Utility.getSimpplrFilePrefix();
			
			if (unfurlUrl.containsIgnoreCase('app')){
				String uParam =  Utility.getParamValueFromUrl(unfurlUrl, 'u');
				List<String> uParamSplitList = String.isNotBlank(uParam) ? uParam.split('/') : new List<String>();
				
				if(unfurlUrl.containsIgnoreCase('/gallery/')){
					for(String u : uParamSplitList){
						if(u.startsWith(filePrefix)){
							albumFileId = u;
						}
					}							
				
				} else if(unfurlUrl.containsIgnoreCase('/blog/') || unfurlUrl.containsIgnoreCase('/event/') || unfurlUrl.containsIgnoreCase('/album/') || unfurlUrl.containsIgnoreCase('/page/')){
					for(String u : uParamSplitList){
						if(u.startsWith(contentPrefix)){
							contentId = u;
						}
					}
						
				} else if(unfurlUrl.containsIgnoreCase('/people/')){
					for(String u : uParamSplitList){
						if(u.startsWith(peoplePrefix)){
							peopleId = u;
						}
					}					
				} else if(unfurlUrl.containsIgnoreCase('/site/')){
					for(String u : uParamSplitList){
						if(u.startsWith(sitePrefix)){
							siteId = u;
						}
					}					
				}
			}
			
			if(String.isNotBlank(contentId)){
				ManageContentDao manageContentDaoObj = new ManageContentDao(); 
				slackUnfurlResponse = manageContentDaoObj.getSlackUnfurlInfoForContent(contentId);	
					
			} else if(String.isNotBlank(albumFileId)){
				ManageContentDao manageContentDaoObj = new ManageContentDao(); 
				slackUnfurlResponse = manageContentDaoObj.getSlackUnfurlInfoForAlbumMedia(albumFileId);
			
			} else if(String.isNotBlank(peopleId)){
				PeopleContentProvider peopleContentProviderObj = new PeopleContentProvider(); 
				slackUnfurlResponse = peopleContentProviderObj.getSlackUnfurlInfoForProfile(peopleId);	
			} else if(String.isNotBlank(siteId)){
				SiteContentProvider siteContentProviderObj = new SiteContentProvider(); 
				slackUnfurlResponse = siteContentProviderObj.getSlackUnfurlInfoForSite(siteId);	
			} else {
				throw new SimpplrException('Invalid id');	
			}	
			slackUnfurlResponse.isOrgChartEnabled = SimpplrContext.isOrgChartEnabled;	
			slackUnfurlResponse.link = unfurlUrl;
    		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Unfurl info for slack ', slackUnfurlResponse);    		
	        logger.logDebug('SlackDataServer.getSlackUnfurlInfo()-----resultWrapper-- '+ resultWrapper);
    	}catch(Exception e){
			logger.logError(e.getMessage());
    		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR,e.getMessage(), null);
    	}
    	return resultWrapper; 
    } 
    
    private void setSlackConnectedFlag(){
		List<People_Integration__c> peopleIntegToUpdate = new List<People_Integration__c>();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', UserContext.peopleId);
		String queryStr = 'Select Id, Connected__c from People_Integration__c where people__c = :soqlParam1';   					
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		peopleIntegToUpdate = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
		if(!peopleIntegToUpdate.isEmpty() && !peopleIntegToUpdate[0].Connected__c ){
			peopleIntegToUpdate[0].Connected__c = true;	
		}
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id, People_Integration__c>(peopleIntegToUpdate), new List<Schema.SObjectField>{									
											People_Integration__c.Connected__c
											});				    	
    }

	@testVisible
    private ResponseWrapper enableSlackUnfurl(String appName) {
		ResponseWrapper resultWrapper = new ResponseWrapper();
		try {
			if(IntegrationConstants.INTEGRATION_TYPE_SLACK_UNFURL.equalsIgnoreCase(appName) && SimpplrContext.slackIntegrationEnabled && SimpplrContext.isSlackPhase2FeatureEnabled) {
				resultWrapper = saveSlackInfoToPeopleInteg('', '', '');
				String redirectUrl = SimpplrContext.salesforceBaseUrl + '/apex/app' + '?u=/my-settings/external-apps';
				if(resultWrapper.status.equalsIgnoreCase('success')) {
					resultWrapper.redirectUrl = redirectUrl;
					return resultWrapper;
				} else {
					return resultWrapper;
				}
			}
			return resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		} catch(Exception e){
			logger.logError(e.getMessage());
			return resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
	}
    
    @testVisible
    private ResponseWrapper saveSlackInfoToPeopleInteg(String slackUserName, String slackTeamId, String slackUserId){
    	ResponseWrapper resultWrapper = new ResponseWrapper();
    	try{
	    	List<People_Integration__c> peopleIntegToUpdate = new List<People_Integration__c>();
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			String queryStr;
			soqlParamMap.put('soqlParam1', UserContext.peopleId);
			soqlParamMap.put('soqlParam2', IntegrationConstants.INTEGRATION_TYPE_SLACK_UNFURL);
			if (String.isBlank(slackUserName)) {
				queryStr = 'Select Id, Name, User_Name__c,User_Email__c, Connected__c, External_Id__c from People_Integration__c where people__c = :soqlParam1 AND Name=:soqlParam2 AND Is_Deleted__c= false ';
			
			} else {
				queryStr = 'Select Id, Name, User_Name__c,User_Email__c, Connected__c, External_Id__c from People_Integration__c where people__c = :soqlParam1 AND Name=:soqlParam2 AND Is_Deleted__c= false AND Connected__c=true ';   					
			}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			peopleIntegToUpdate = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
			if(!peopleIntegToUpdate.isEmpty()){
				peopleIntegToUpdate[0].User_Name__c = slackUserName;
				peopleIntegToUpdate[0].User_Email__c = slackUserId;
				peopleIntegToUpdate[0].Connected__c = true;
				peopleIntegToUpdate[0].External_Id__c = slackTeamId;
				peopleIntegToUpdate[0].Name = IntegrationConstants.INTEGRATION_TYPE_SLACK_UNFURL;
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<Id, People_Integration__c>(peopleIntegToUpdate), new List<Schema.SObjectField>{									
											People_Integration__c.User_Name__c,
											People_Integration__c.User_Email__c,
											People_Integration__c.Connected__c,
											People_Integration__c.External_Id__c,
											People_Integration__c.Name
											});
			} else {
				People_Integration__c peopleIntegObj = new People_Integration__c();
				peopleIntegObj.User_Name__c = slackUserName;
				peopleIntegObj.User_Email__c = slackUserId;
				peopleIntegObj.Connected__c = true;
				peopleIntegObj.External_Id__c = slackTeamId;
				peopleIntegObj.people__c = UserContext.peopleId;
				peopleIntegObj.Name = IntegrationConstants.INTEGRATION_TYPE_SLACK_UNFURL;
				peopleIntegObj.App_Integration__c = SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SLACK).id;
				if(UserContext.getCurrentUserInfo != null){
					peopleIntegObj.OwnerId = UserContext.getCurrentUserInfo.User__c;
				}	
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().insertAsUser(peopleIntegObj, new List<Schema.SObjectField>{									
												People_Integration__c.User_Name__c,
												People_Integration__c.User_Email__c,
												People_Integration__c.Connected__c,
												People_Integration__c.External_Id__c,
												People_Integration__c.people__c,
												People_Integration__c.Name,
												People_Integration__c.App_Integration__c,
												People_Integration__c.OwnerId
											});				
			}
			
			return resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
    	}catch(Exception e){
			logger.logError(e.getMessage());
			return resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		
    }

	
    
	@testVisible
    private ResponseWrapper unInstallSlackApp(){
    	ResponseWrapper resultWrapper = new ResponseWrapper();
    	try{
	    	String appIntQuery = 'SELECT Id, App_Installed__c from App_Integration__c WHERE Name = :soqlParam1 limit 1';
			Map<String, Object> sqlParamMap = new Map<String, Object>();
			sqlParamMap.put('soqlParam1', IntegrationConstants.INTEGRATION_TYPE_SLACK);
	
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<App_integration__c> appIntegList = (List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, sqlParamMap);

	    	if(appIntegList.isEmpty()==false){
				appIntegList[0].App_Installed__c = false;
				
				List<Schema.SObjectField> fieldList = new List<Schema.SObjectField> {
					App_integration__c.App_Installed__c
				};

				SIMPESAPI.accessController().updateAsUser(new Map<Id, App_integration__c>(appIntegList), fieldList);

				BatchSlackDisconnectUsers job = new BatchSlackDisconnectUsers();
				Database.executeBatch(job,2000);
			}	
			return resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Successfully uninstalled Slack App', null);
    	}catch(Exception e){
			logger.logError(e.getMessage());
			return resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR,MessageHelper.translateSFMessageToErrorCode(e), null);
		}
		
    }


	@testVisible
    private ResponseWrapper getAvailableChannels(){
    	ResponseWrapper resultWrapper = new ResponseWrapper();
		List<ChannelWrapper> channelsList = new List<ChannelWrapper>();
		try{
			if(SimpplrContext.slackIntegrationEnabled && UserContext.isSlackContentShareConnected){
				String accessToken = UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE).Access_Token__c;
				String payLoadChannels = 'token='+accessToken+'&exclude_archived=true&limit=1000&types=public_channel,private_channel';
				
				HttpRequest req = new HttpRequest();
				Http http = new Http();
				HTTPResponse res = null;
						
				req.setEndpoint('https://slack.com/api/conversations.list');
				req.setMethod('GET');
				req.setBody(payLoadChannels);
				res = http.send(req);
				String resBody = res.getBody();
				SlackChannelsWrapper channelList = (SlackChannelsWrapper)JSON.deserialize(resBody,SlackChannelsWrapper.class);			
				if(channelList.ok){
					List<SlackChannelsWrapper.SlackChannels> channels = (List<SlackChannelsWrapper.SlackChannels>)(channelList.channels);
					if(channelList.response_metadata != null && String.isNotBlank(channelList.response_metadata.next_cursor)){
						//there are more channels, lets retrun empty list
					} else {
						for(SlackChannelsWrapper.SlackChannels channel : channels){
							if(channel.is_mpim == false && channel.is_im == false){		
								ChannelWrapper wrapperObj = new ChannelWrapper();					
								wrapperObj.channelId = channel.id;
								wrapperObj.name = channel.name;
								wrapperObj.isPrivate = channel.is_group == true ? true : false;
								channelsList.add(wrapperObj);
							}
						}	
					}		
				}
			}
			Map<String,Object> resultMap = new Map<String,Object>();
			channelsList.sort();
			resultmap.put('listOfChannels',channelsList);
	    	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, resultMap);
    	} catch(Exception e){
			logger.logError('SlackDataServer.getAvailableChannels()----Exception occurec----' + e);
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR,MessageHelper.translateSFMessageToErrorCode(e), null);
		}
		return resultWrapper;
    }

	private class ChannelWrapper implements Comparable{
		public String channelId;
		public String name;
		public Boolean isPrivate;
		public Integer compareTo (Object compareTo) {
		ChannelWrapper compareToChannelWrapper = (ChannelWrapper)compareTo;
		if (name == compareToChannelWrapper.name) return 0;
		if (name > compareToChannelWrapper.name) return 1;
		return -1; 
	}
	}

	 

    private ResponseWrapper likeContent (String contentIdArg) {
		if(!SimpplrContext.slackIntegrationEnabled){
        	throw new SimpplrException('slackDisabled');	
        }
		Savepoint sp = Database.setSavepoint(); 
		
		try {
			String currentUserPeopleId = UserContext.peopleId;
			List<Like__c> listOfContentLikes = [SELECT Id FROM Like__c WHERE Content__r.Id =: contentIdArg AND people__c =: currentUserPeopleId WITH SECURITY_ENFORCED];
			if (listOfContentLikes.isEmpty()) {
				Like__c likeObj = new Like__c();
				likeObj.Content__c = contentIdArg;
				likeObj.People__c = UserContext.getCurrentUserInfo.Id;
				
				List<Simpplr_Content__c> simpplrContentList = [SELECT id,Likes__c, type__c ,
						Primary_Author__c, Primary_Author__r.User__c, Primary_Author__r.First_Name__c, 
						Title__c, Site__c, Site__r.name, Site__r.Chatter_Group_Id__c, Display_Excerpt__c,
						Primary_Author__r.External_Photo_URL__c, 
						Primary_Author__r.External_Photo_URL_Expiry_Date__c, Primary_Author__r.Full_Name__c   
						FROM Simpplr_Content__c 
						WHERE ID =: contentIdArg AND Is_Published__c = true AND Is_Deleted__c = false AND ( Site__c = null OR (Site__r.Is_Active__c = true AND Site__r.Is_Deleted__c = false)) WITH SECURITY_ENFORCED];
				if(simpplrContentList.isEmpty()){
					throw new SimpplrException(ServiceConstants.ERROR_404);
					
				} else {
					if(simpplrContentList[0].Site__c != null){
						List<CollaborationGroup> collGrpList = [SELECT Id from CollaborationGroup where Id =:simpplrContentList[0].Site__r.Chatter_Group_Id__c WITH SECURITY_ENFORCED];
					
						if(collGrpList.isEmpty()){
							throw new SimpplrException(ServiceConstants.ERROR_403);
						}
					}
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
			response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Successfully liked the content.', true);
			return response;
			
		} catch (exception e) {
			logger.logError(e.getMessage());			
			Database.rollback(sp);
			response = buildResponseWrapper(RESPONSE_STATUS_ERROR,e.getMessage(), true);
		}
		
		return response;
	}
	
	private ResponseWrapper likeMedia (String fileIdArg) {
		if(!SimpplrContext.slackIntegrationEnabled){
        	throw new SimpplrException('slackDisabled');	
        }
        try{
			String currentUserPeopleId = UserContext.peopleId;
			list<Like__c>likeList = [select ID, File__c,people__c from Like__c where File__c =:fileIdArg and people__c =: currentUserPeopleId WITH SECURITY_ENFORCED];
			
			if(likeList.isEmpty()){
				Like__c likeObj = new Like__c();
				likeObj.File__c = FileIdArg;
				likeObj.People__c = currentUserPeopleId;
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', fileIdArg);
				String filesQuery = 'select ID, Simpplr_Content__r.Site__r.Chatter_Group_Id__c, Likes__c,Author__c,Author__r.User__c,Simpplr_Content__r.Primary_Author__c,Mime_Type__c,Simpplr_Content__r.Album_Allow_All_to_Upload__c from File__c where ID =: soqlParam1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<File__c> fileObjList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
				if(fileObjList.isEmpty()){
					throw new SimpplrException(ServiceConstants.ERROR_404);
				}
				
				Simpplr_Content__c simpplrContentObj = [SELECT id,Likes__c, Type__c ,Primary_Author__c, Primary_Author__r.User__c, Primary_Author__r.First_Name__c, 
															Title__c, Site__c, Site__r.name, Site__r.Chatter_Group_Id__c, Display_Excerpt__c,
															Primary_Author__r.External_Photo_URL__c,
															Primary_Author__r.External_Photo_URL_Expiry_Date__c, Primary_Author__r.Full_Name__c,
															(select id from File_Simpplr_Content__r) 
															FROM Simpplr_Content__c 
															WHERE ID =: fileObjList[0].Simpplr_Content__c WITH SECURITY_ENFORCED];
				List<CollaborationGroup> collGrpList = [SELECT Id from CollaborationGroup where Id =:fileObjList[0].Simpplr_Content__r.Site__r.Chatter_Group_Id__c WITH SECURITY_ENFORCED];
				
				if(collGrpList.isEmpty()){
					throw new SimpplrException(ServiceConstants.ERROR_403);
				}
				likeObj.Like_Receiver__c = fileObjList[0].Author__c;
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().insertAsUser(likeObj, 
	   					new List<Schema.SObjectField>{ 
	   						Like__c.File__c, Like__c.People__c, Like__c.Like_Receiver__c
	   					}
	   				);
				
	   			fileObjList[0].Likes__c = fileObjList[0].Likes__c == null ? 1 :  fileObjList[0].Likes__c + 1;
	   			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	    		SIMPESAPI.accessController().updateAsUser(fileObjList[0], new List<Schema.SObjectField>{
	    				File__c.Likes__c});
				
				NotificationDispatcher.sendEmailForMediaLike(fileObjList[0],simpplrContentObj);
				NotificationDispatcher.sendNotificationForMediaLike(fileObjList[0],simpplrContentObj);
			}
			response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Successfully liked the media.', true);
			
		} catch (Exception e) {
			logger.logError(e.getMessage());
			response = buildResponseWrapper(RESPONSE_STATUS_ERROR,e.getMessage(), true);
		}
		return response;
	}
	
    private ResponseWrapper followUser(String peopleId){
    	ResponseWrapper resultWrapper = new ResponseWrapper();
    	try{
			if(!SimpplrContext.slackIntegrationEnabled){
				throw new SimpplrException('slackDisabled');	
			}
	    	List<People__c> peopleList = [select user__c from People__c where id =:peopleId WITH SECURITY_ENFORCED limit 1];
			if(peopleList.isEmpty() == false){
				ToggleFollowDataServer followDSObj = new ToggleFollowDataServer();
				followDSObj.followUser(peopleList[0].user__c);
			} else {
				throw new SimpplrException('404');	
			}
			return resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Successfully followed user', null);
    	} catch(Exception e){
			logger.logError(e.getMessage());
			return resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR,e.getMessage(), null);
		}
	}

	private ResponseWrapper followSite(String siteId){
    	ResponseWrapper resultWrapper = new ResponseWrapper();
    	try{
			if(!SimpplrContext.slackIntegrationEnabled){
				throw new SimpplrException('slackDisabled');	
			}
			ToggleFollowDataServer followDSObj = new ToggleFollowDataServer();
			followDSObj.followSite(siteId);
			return resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
    	} catch(Exception e){
			logger.logError(e.getMessage());
			return resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR,e.getMessage(), null);
		}
	}

	private ResponseWrapper requestSiteAccess(String siteId){
    	ResponseWrapper resultWrapper = new ResponseWrapper();
    	try{
			if(!SimpplrContext.slackIntegrationEnabled){
				throw new SimpplrException('slackDisabled');	
			}
			SiteDataServer sdsObj = new SiteDataServer();
			resultWrapper = sdsObj.requestSiteMembership(siteId);
			return resultWrapper;
    	} catch(Exception e){
			logger.logError(e.getMessage());
			return resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR,e.getMessage(), null);
		}
	}

	@testVisible
    private ResponseWrapper pushToSlack(String requestData){
    	ResponseWrapper resultWrapper = new ResponseWrapper();
    	try{
			Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
			String contentId = (String)requestDataMap.get('contentId');
			String message = (String)requestDataMap.get('message');
			String channelId = (String)requestDataMap.get('channelId');
			String contentUrl = (String)requestDataMap.get('contentUrl');
			String channelUrl = (String)requestDataMap.get('channelUrl');
			if(String.isNotBlank(channelUrl)) {
				channelId = channelUrl.substringAfterLast('/');
			}
			if(SimpplrContext.isSlackPhase2FeatureEnabled && SimpplrContext.isSlackUpgraded) {
				List<String> channelList = new List<String>();
				for(Object channel : (List<Object>)requestDataMap.get('channelList')) {
					channelList.add((String)channel);
				}
				SlackHelper slackHelper = new SlackHelper();
				slackHelper.getContentInfo(contentId, channelList, message);
			} else {
				contentUrl += '&utm_medium=slack&utm_source=slack';
				ManageContentDao mcdObj = new ManageContentDao();
				SlackDataServer.ResponseStructure contentObj = mcdObj.getSlackUnfurlInfoForContent(contentId);
				String contentObjJSON = JSON.serialize(contentObj);
				pushContentToSlack(contentId, message, channelId, contentUrl, contentObjJSON);
			}
			return resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
    	}catch(Exception e){
			logger.logError(e.getMessage());
			return resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
		}
		
    }

	@future (callout =true)
	public static void pushContentToSlack(String contentId, String message, String channelId, String contentUrl, String contentObjJSON){
		SlackDataServer.ResponseStructure contentObj = (SlackDataServer.ResponseStructure)JSON.deserialize(contentObjJSON, SlackDataServer.ResponseStructure.class);
		if(SimpplrContext.slackIntegrationEnabled && UserContext.isSlackContentShareConnected){ 
	   		if(String.isNotBlank(channelId)){
				Http h = new Http();
				HttpRequest req = new HttpRequest();
				String endPoint = 'https://slack.com/api/chat.postMessage?token='+UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE).Access_Token__c+'&channel='+EncodingUtil.urlEncode(channelId,'UTF-8')+'&text='+EncodingUtil.urlEncode(contentUrl,'UTF-8');
				req.setEndpoint(endPoint);
				req.setHeader('Content-Type','application/x-www-form-urlencoded');
				String attachmentsJson = getAttcahmentJSON(contentObj,contentUrl, message);
				req.setBody('attachments='+EncodingUtil.urlEncode(attachmentsJson,'UTF-8'));
				req.setMethod('POST');
				req.setTimeout(60000);
				if (Test.isRunningTest() == false){
						HttpResponse res = h.send(req);
				} 
			}
		}
	}

	

	private static String getAttcahmentJSON(SlackDataServer.ResponseStructure contentObj, String contentUrl, String message){
		ContentAttachmentStructure attachmentObj  = new ContentAttachmentStructure();
		attachmentObj.title = contentObj.contentDetail.title;
		attachmentObj.title_link = contentUrl;
		attachmentObj.image_url = contentObj.contentDetail.img;
		attachmentObj.callback_id= 'likeOrcommentId';
		attachmentObj.footer= 'Added by Simpplr';
		AttachmentActions action = new AttachmentActions();
		action.name = 'like button';
		action.value = 'likeId';
		action.style = 'primary';
		action.type = 'button';
		action.text = 'Like';
		attachmentObj.actions = new List<AttachmentActions>{action};
		attachmentObj.fields = new List<Map<String,Object>>();
		String summary = '';
		if(String.isNotBlank(message)){
			summary = contentObj.contentDetail.summary + '\n *Message* '+message;
		} else {
			summary = contentObj.contentDetail.summary;
		}
		if('Event'.equalsIgnoreCase(contentObj.type)){
			attachmentObj.text = summary+'\n *Site * <'+contentObj.contentDetail.site.url+'|'+contentObj.contentDetail.site.name+'>	*Author * <'+contentObj.contentDetail.authoredBy.url+'|'+contentObj.contentDetail.authoredBy.name+'> ';
			if(contentObj.contentDetail.isAllDay){
				if(contentObj.contentDetail.isMultiDay){
					Map<String,Object> field1 = new Map<String,Object>();
					field1.put('title','Event Start');
					field1.put('value',contentObj.contentDetail.startsAt+'. All day');//to be formatted
					field1.put('short',true);
					attachmentObj.fields.add(field1);

					Map<String,Object> field2 = new Map<String,Object>();
					field2.put('title','Event End');
					field2.put('value',contentObj.contentDetail.endsAt+'. All day');//to be formatted
					field2.put('short',true);
					attachmentObj.fields.add(field2);

				} else {
					Map<String,Object> field1 = new Map<String,Object>();
					field1.put('title','Event Start');
					field1.put('value',contentObj.contentDetail.startsAt+'. All day');//to be formatted
					field1.put('short',true);
					attachmentObj.fields.add(field1);
				}
			} else {
				if(contentObj.contentDetail.isMultiDay){

					Map<String,Object> field1 = new Map<String,Object>();
					field1.put('title','Event Start');
					field1.put('value',contentObj.contentDetail.startsAt);//to be formatted
					field1.put('short',true);
					attachmentObj.fields.add(field1);

					Map<String,Object> field2 = new Map<String,Object>();
					field2.put('title','Event End');
					field2.put('value',contentObj.contentDetail.endsAt);//to be formatted
					field2.put('short',true);
					attachmentObj.fields.add(field2);
				} else {

					Map<String,Object> field1 = new Map<String,Object>();
					field1.put('title','Event Start');
					field1.put('value',contentObj.contentDetail.startsAt+' - '+contentObj.contentDetail.endsAt);//to be formatted
					field1.put('short',true);
					attachmentObj.fields.add(field1);
				}
			}
			
			if(contentObj.contentDetail.location != null &&  contentObj.contentDetail.location != ''){
				
				Map<String,Object> field1 = new Map<String,Object>();
				field1.put('title','Event Location');
				if(String.isNotBlank(contentObj.contentDetail.googleCalendarWebUrl)){
					field1.put('value',contentObj.contentDetail.location+'\n <'+contentObj.contentDetail.googleCalendarWebUrl+ '| Open online map>');
				} else {
					field1.put('value', contentObj.contentDetail.location);
				}
				field1.put('short',true);
				attachmentObj.fields.add(field1);
				
			}
		} else if('Page'.equalsIgnoreCase(contentObj.type)){
			attachmentObj.text = summary+'\n *Site * <'+contentObj.contentDetail.site.url+'|'+contentObj.contentDetail.site.name+'>	*Author * <'+contentObj.contentDetail.authoredBy.url+'|'+contentObj.contentDetail.authoredBy.name+'> ';
		} else if('Album'.equalsIgnoreCase(contentObj.type)){
			attachmentObj.text = summary+'\n *Site * <'+contentObj.contentDetail.site.url+'|'+contentObj.contentDetail.site.name+'>	*Author * <'+contentObj.contentDetail.authoredBy.url+'|'+contentObj.contentDetail.authoredBy.name+'> ';
		} else if('BlogPost'.equalsIgnoreCase(contentObj.type)){
			attachmentObj.text = summary+'\n *Author * <'+contentObj.contentDetail.authoredBy.url+'|'+contentObj.contentDetail.authoredBy.name+'>';
		} 
		List<ContentAttachmentStructure> contStructureList = new List<ContentAttachmentStructure>{attachmentObj};
		String jsonResponse = JSON.serialize(contStructureList);
		return jsonResponse;
	}

	
	
    public class ResponseStructure{
    	public ContentWrapper contentDetail;
    	public String link;
    	public String type;
    	public FileListingWrapper fileDetail;
    	public PeopleLiteWrapper profileDetail;
		public SiteDetailWrapper siteDetail; 
		public Boolean isOrgChartEnabled;
    	
    }

	private class ContentAttachmentStructure{
		public string title;
		public string title_link;
		public String image_url;
		public String text;
		public String callback_id;
		public String footer;
		public List<AttachmentActions> actions;
		public List<Map<String,Object>> fields;

	}

	private class AttachmentActions{
		public String name;
		public String text;
		public String value;
		public String style;
		public String type;
	}
}