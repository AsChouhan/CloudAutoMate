public with sharing class SlackSettingsCtrl extends BaseCtrl{
    public transient final String STR_APPS_CONNECTION_SUCCESS_LABEL { get { return labelMap.get('apps.connection.success');}}
    public static String pageName {get{
    	if(String.isEmpty(pageName)){
    		pageName = PageContext.namespacePrefix + 'SlackSettings';
    	}
    	return pageName;
    }set;}
    public override String getPageFeature() {
    	return AccessManager.FEATURE_MY_SETTINGS;
    }
    public PageReference handleRequest() { 
    	PageReference returnPage;
    	String state;
		String error;
		String returl;
		String codeFromSlack;
		Boolean isSiteContext = false;
		String openPostInSlackModal;
		try{
			codeFromSlack = apexpages.currentpage().getparameters().get('code');
			state = apexpages.currentpage().getparameters().get('state');
			error = apexpages.currentpage().getparameters().get('error');
			returl = apexpages.currentpage().getparameters().get('retUrl');
			openPostInSlackModal = apexpages.currentpage().getparameters().get('openPostInSlackModal');
			String sitePrefix = utility.getSimpplrSitePrefix();
			if (String.isBlank(returl) || 'null'.equalsIgnoreCase(returl)) {
				
				if (String.isNotBlank(state)) {
					
					if (state.startsWithIgnoreCase(sitePrefix)) {						
						returnPage = new PageReference(PageContext.getPageURL(Pages.app) + '?u=/manage/sites/'+state+'/external-apps');
						isSiteContext  = true;
					
					} else {
						returnPage = new PageReference(PageContext.getPageURL(Pages.app) + '?u=/my-settings/external-apps');
						returnPage.getParameters().put('alert',prepareMessage('success',  STR_APPS_CONNECTION_SUCCESS_LABEL.replace('{{appName}}', 'slack')));
					}

				}

			} else if (String.isNotBlank(openPostInSlackModal) && openPostInSlackModal.equalsIgnoreCase('true')){
				
				returnPage = new PageReference(returl+'&openPostInSlackModal=true');
			} else {
				returnPage = new PageReference(returl+'&openPromoteModal=true');
			}

			//This error parameter is added to  url only when cancel is pressed on SLACK OAUTH page.
			
			if (String.isBlank(error)) {	
				String REDIRECT_URL_STRING = 'https://services.simpplr.com/oauth/redirect/code_passthrough.php';
				String redirectUrl = '';

				if (String.isBlank(retUrl)) {
					redirectUrl = REDIRECT_URL_STRING + '?state=' + EncodingUtil.urlEncode(PageContext.getPageURL(Pages.SlackSettings)+'&state='+state, 'UTF-8');
				
				} else {
					redirectUrl = REDIRECT_URL_STRING + '?state=' + EncodingUtil.urlEncode(PageContext.getPageURL(Pages.SlackSettings)+'&state='+state, 'UTF-8')+'&retUrl='+retUrl;
				}
				
				

				HttpRequest req = new HttpRequest();
				
				String payLoad = 'client_id='+SimpplrContext.SlackClientId+
								'&client_secret='+SimpplrContext.SlackClientSecret+
								'&code='+codeFromSlack+
								'&redirect_uri='+redirectUrl;
				
				
				req.setEndpoint('https://slack.com/api/oauth.access');
				req.setMethod('GET');
				req.setBody(payLoad);
				Http http = new Http();
				HTTPResponse res = http.send(req);
				SlackChannelsWrapper.SlackAuth slackAuthWrapper = (SlackChannelsWrapper.SlackAuth)JSON.deserialize(res.getBody(),SlackChannelsWrapper.SlackAuth.class);
				
				if (slackAuthWrapper.ok == false) {
					throw new SimpplrException(slackAuthWrapper.error);
				}

				PeopleDao peopleDaoObj = new PeopleDao();
				List<People_Integration__c> peopleIntegList = peopleDaoObj.getPeopleIntegrationRecordByProfileIdAndType(state,IntegrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE);
				
				if (SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SLACK) != null) {
					String userName = getSlackUserNameBySlackUserId(slackAuthWrapper.user_id,slackAuthWrapper.access_token);
					
					if (peopleIntegList.isEmpty() == false) {
						peopleIntegList[0].Access_Token__c = slackAuthWrapper.access_token;
						peopleIntegList[0].User_Email__c = slackAuthWrapper.user_id;
						peopleIntegList[0].External_Id__c = slackAuthWrapper.team_id;
						peopleIntegList[0].User_Name__c = userName;
						peopleIntegList[0].Connected__c = true;
						peopleIntegList[0].App_Integration__c = SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SLACK).id;
						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
						SIMPESAPI.accessController().updateAsUser(peopleIntegList[0], new List<Schema.SObjectField>{									
												People_Integration__c.Access_Token__c,
												People_Integration__c.User_Email__c,
												People_Integration__c.External_Id__c,
												People_Integration__c.User_Name__c,
												People_Integration__c.Connected__c,
												People_Integration__c.App_Integration__c
											});							

					} else {

						if (String.isNotBlank(userName)) {
							People_Integration__c peopleIntegObj = new People_Integration__c();
							peopleIntegObj.Access_Token__c = slackAuthWrapper.access_token;
							peopleIntegObj.External_Id__c = slackAuthWrapper.team_id;
							peopleIntegObj.User_Name__c = userName;
							peopleIntegObj.User_Email__c = slackAuthWrapper.user_id;
							peopleIntegObj.Name = IntegrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE;
							peopleIntegObj.Connected__c = true;
							peopleIntegObj.People__c = UserContext.peopleId;
							peopleIntegObj.App_Integration__c = SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SLACK).id;
							if(UserContext.getCurrentUserInfo != null){
								peopleIntegObj.OwnerId = UserContext.getCurrentUserInfo.User__c;
							}	
							SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
							SIMPESAPI.accessController().insertAsUser(peopleIntegObj, new List<Schema.SObjectField>{
									People_Integration__c.Access_Token__c,
									People_Integration__c.External_Id__c,
									People_Integration__c.User_Name__c,
									People_Integration__c.User_Email__c,
									People_Integration__c.Name,
									People_Integration__c.Connected__c,
									People_Integration__c.People__c,
									People_Integration__c.App_Integration__c,
									People_Integration__c.OwnerId
									});

						}

					}

				}
				
			}

		} catch(Exception e) {

			if (isSiteContext) {
				returnPage = new PageReference(PageContext.getPageURL(Pages.app) + '?u=/manage/sites/'+state+'/external-apps');
				returnPage.getParameters().put('alert', prepareMessage('danger', e.getMessage()));
			} else {
				returnPage = new PageReference(PageContext.getPageURL(Pages.app) + '?u=/my-settings/external-apps');
				returnPage.getParameters().put('alert', prepareMessage('danger', e.getMessage()));
			}
			
		}
	return returnPage;
  }

	public String getSlackUserNameBySlackUserId(String slackUserId, String slackAccessToken){
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		String endPoint = 'https://slack.com/api/users.info?token='+slackAccessToken+'&user='+slackUserId ;
		req.setEndpoint(endPoint);
		req.setHeader('Content-Type','application/x-www-form-urlencoded');
		req.setMethod('GET');
		req.setTimeout(60000);
		HttpResponse res = h.send(req);
		UserInfo slackuserObj = (UserInfo)JSON.deserialize(res.getBody(),UserInfo.class);
		if(slackuserObj.ok){
			return slackuserObj.user.profile.real_name;
		} else {
			throw new SimpplrException(slackuserObj.error);
		}

	}

	public class UserInfo{
		public Boolean ok;
		public SlackUser user;
		public String error;
	}

	public class SlackUser{
		public SlackUserProfile profile;
	}
	public class SlackUserProfile{
		public String real_name;
	}
}