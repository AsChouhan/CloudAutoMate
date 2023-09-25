public with sharing class MicrosoftTeamsHelper {
    public static final String JWT_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/jwt';
    public static final String MICROSOFT_TEAMS_SAVE_MESSAGING_CONFIG_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/msteams/teams/updateAppIntegration';
    public static final String MICROSOFT_TEAMS_USER_CONNECTION = SimpplrContext.simpplrAPIEndpoint + '/msteams/teams/verifyUserConnection';
    public static final String MICROSOFT_TEAMS_ADMIN_CONNECTION = SimpplrContext.simpplrAPIEndpoint + '/msteams/teams/verifyAdminConnection';
    public static final String MICROSOFT_TEAMS_DISCONNECT_USER_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/msteams/teams/disconnectUser';
    public static final String MICROSOFT_TEAMS_POST_TO_CHANNEL = SimpplrContext.simpplrAPIEndpoint + '/msteams/teams/postToChannel';
    public static final String MICROSOFT_TEAMS_INSTALL_APP_FOR_TEAMS = SimpplrContext.simpplrAPIEndpoint + '/msteams/teams/enableUnfurlingInTeams';
    public static final String MICROSOFT_TEAMS_UNINSTALL_APP_FOR_TEAMS = SimpplrContext.simpplrAPIEndpoint + '/msteams/teams/disableUnfurlingInTeams';
    public static final String MICROSOFT_TEAMS_TENANT_APP_SETTINGS = SimpplrContext.simpplrAPIEndpoint + '/v1/account/internal/appConfig?namespace=app.integrations.messaging';

    public void updateAndDeletePeopleAndSiteRecords () {   
        Map<String, Object> soqlParamMap = new  Map<String, Object>();
        soqlParamMap.put('soqlParam1', IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS);
        String query = 'SELECT Id FROM People_Integration__c WHERE Name = :soqlParam1';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<People_Integration__c> peopleIntList = (List<People_Integration__c>) SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
        SIMPESAPI.accessController().deleteAsUser(peopleIntList);
        
        query = 'SELECT Id FROM People__c WHERE Microsoft_Teams_User_Id__c != null';
        List<People__c> peopleList = (List<People__c>) SIMPESAPI.accessController().queryAsUSer(query, null);
        for(People__c people:peopleList) {
            people.Microsoft_Teams_User_Id__c = '';
            people.Microsoft_Teams_User_Name__c = '';
            people.Microsoft_Tenant_Id__c = '';
        }
        
        SIMPESAPI.accessController().updateAsUser(new Map<Id,People__c>(peopleList), new List<Schema.SObjectField>{
            People__c.Microsoft_Teams_User_Id__c,
            People__c.Microsoft_Teams_User_Name__c,
            People__c.Microsoft_Tenant_Id__c
        });

        List<Simpplr_Site__c> siteList = [SELECT Id,External_Apps_Site_Config_Json__c FROM Simpplr_Site__c WHERE Microsoft_Teams_Site_Manager__c = :UserContext.peopleId WITH SECURITY_ENFORCED];
        if(!siteList.isEmpty()){
            for(Simpplr_Site__c siteObj : siteList) {
                siteObj.Microsoft_Teams_Integration_Enabled__c = false;
                siteObj.Microsoft_Teams_Site_Manager__c = null;
                if(siteObj.External_Apps_Site_Config_Json__c != null){
                    ManageSiteWrapper.ExternalAppsSiteConfig externalAppsSiteConfig = new ManageSiteWrapper.ExternalAppsSiteConfig();
                    externalAppsSiteConfig = (ManageSiteWrapper.ExternalAppsSiteConfig)JSON.deserialize(siteObj.External_Apps_Site_Config_Json__c, ManageSiteWrapper.ExternalAppsSiteConfig.class);
                    externalAppsSiteConfig.MsTeamsSiteConfig = null;
                    siteObj.External_Apps_Site_Config_Json__c = JSON.serializePretty(externalAppsSiteConfig,true);
                }
            }
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(new Map<Id,Simpplr_Site__c>(siteList), new List<Schema.SObjectField>{
                Simpplr_Site__c.Microsoft_Teams_Integration_Enabled__c,
                Simpplr_Site__c.Microsoft_Teams_Site_Manager__c,
                Simpplr_Site__c.External_Apps_Site_Config_Json__c
            });
        }
                            
    }

    public void createPeopleIntegrationRecord (String externalId, String userName, String userEmail, String tenantId) {
        //install msteams app for content link unfurling
        MicrosoftTeamsHelper.installOrUninstallMSTeamsAppForUser(externalId, tenantId, true);
        People_Integration__c peopleIntegrationObj = new  People_Integration__c();
        peopleIntegrationObj.Name = IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS;
        peopleIntegrationObj.People__c = UserContext.peopleId;
        peopleIntegrationObj.Connected__c = true;
        peopleIntegrationObj.External_Id__c = externalId;
        peopleIntegrationObj.User_Email__c = userEmail;
        peopleIntegrationObj.User_Name__c = userName;
		peopleIntegrationObj.App_Integration__c = SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS).id;
        peopleIntegrationObj.User__c = UserInfo.getUserID();
        if(UserContext.getCurrentUserInfo != null){
			peopleIntegrationObj.OwnerId = UserContext.getCurrentUserInfo.User__c;
		}	
        List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>{
                        People_Integration__c.Name, 
                        People_Integration__c.People__c,
                        People_Integration__c.Connected__c,
                        People_Integration__c.External_Id__c,
                        People_Integration__c.User_Email__c,
                        People_Integration__c.User_Name__c,
                        People_Integration__c.App_Integration__c,
                        People_Integration__c.User__c,
                        People_Integration__c.OwnerId
                    };
        if(UserContext.Integrations.containsKey(IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS)) {
            peopleIntegrationObj.id = UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS).Id;
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(peopleIntegrationObj, fieldList);
        } else {
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().insertAsUser(peopleIntegrationObj, fieldList);
        }
        updatePeopleRecord(externalId, userName, tenantId);
    }

    public void updatePeopleRecord (String externalId, String userName, String tenantId) {
        List<People__c> peopleList = new List<People__c>();
        Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', UserContext.peopleId);
        String query = 'SELECT Id, Microsoft_Teams_User_Id__c, Microsoft_Teams_User_Name__c, Microsoft_Tenant_Id__c FROM People__c WHERE Id = :soqlParam1 LIMIT 1';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        peopleList = SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
        peopleList[0].Microsoft_Teams_User_Id__c = externalId;
        peopleList[0].Microsoft_Teams_User_Name__c = userName;
        peopleList[0].Microsoft_Tenant_Id__c = tenantId;
        List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>{
            People__c.Microsoft_Teams_User_Id__c,
            People__c.Microsoft_Teams_User_Name__c,
            People__c.Microsoft_Tenant_Id__c
        };
        SIMPESAPI.accessController().updateAsUser(peopleList[0], fieldList);
    }

    public Map<String,Object> getJoinedTeams() {
        Map<String,Object> resultMap = new Map<String,Object>();
        PageReference returnPage;
        MicrosoftTeamsWrapper.MicrosoftMyJoinedTeams teamsList = new MicrosoftTeamsWrapper.MicrosoftMyJoinedTeams();
        if(SimpplrContext.microsoftTeamsIntegrationEnabled && SimpplrContext.isFeatureMicrosoftTeamsEnabled) {
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            returnPage = new Pagereference(PageContext.getPageURL(Pages.app) + '?u=/my-settings/external-apps');

            returnPage.setRedirect(true);
            String endpointURL = SimpplrContext.simpplrAPIEndpoint + '/oauth/ms-teams-oauth-manager?action=getJoinedTeams&orgId='+SimpplrContext.simpplrOrgId+'&peopleId='+UserContext.peopleId;
            req.setEndpoint(endpointURL);
		    req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            req.setMethod('GET');
            req.setTimeout(60000);
            HTTPResponse res = http.send(req);
            String resBody = res.getBody();
            String resStatus = res.getStatus();
            teamsList = (MicrosoftTeamsWrapper.MicrosoftMyJoinedTeams)JSON.deserialize(resBody,MicrosoftTeamsWrapper.MicrosoftMyJoinedTeams.class);			
            
            resultmap.put('listOfTeams',teamsList.value);
        }
        return resultmap;
    }

    public Map<String,Object> getJoinedChannels(String teamId) {
        Map<String,Object> resultMap = new Map<String,Object>();
        PageReference returnPage;
        MicrosoftTeamsWrapper.MicrosoftMyJoinedTeams channelsList = new MicrosoftTeamsWrapper.MicrosoftMyJoinedTeams();
        if(SimpplrContext.microsoftTeamsIntegrationEnabled && SimpplrContext.isFeatureMicrosoftTeamsEnabled) {
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            returnPage = new Pagereference(PageContext.getPageURL(Pages.app) + '?u=/my-settings/external-apps');

            returnPage.setRedirect(true);
            String endpointURL = SimpplrContext.simpplrAPIEndpoint + '/oauth/ms-teams-oauth-manager?action=getJoinedChannels&orgId='+SimpplrContext.simpplrOrgId+'&peopleId='+UserContext.peopleId+'&teamId='+teamId;
            req.setEndpoint(endpointURL);
		    req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            req.setMethod('GET');
            req.setTimeout(60000);
            HTTPResponse res = http.send(req);
            String resBody = res.getBody();
            String resStatus = res.getStatus();
            channelsList = (MicrosoftTeamsWrapper.MicrosoftMyJoinedTeams)JSON.deserialize(resBody,MicrosoftTeamsWrapper.MicrosoftMyJoinedTeams.class);			
            
            resultmap.put('listOfChannels',channelsList.value);
        }
        return resultmap;
    }

    public void promoteContentToChannel(String teamId, String channelId, String URL, String message, String calledFor, String msTenantId, String msUserId, ContentWrapper.ContentSiteFeedWrapper contentWrapper) {
        String endpointURL = SimpplrContext.simpplrAPIEndpoint + '/oauth/ms-teams-oauth-manager?action=promoteContentToChannel';
        Map<String, Object> mapOfRequestBody = new Map<String, Object>();
        Map<String, String> mapOfCustomHeader = new Map<String, String>();
        mapOfRequestBody.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestBody.put('peopleId', UserContext.peopleId);
        mapOfRequestBody.put('teamId', teamId);
        mapOfRequestBody.put('channelId', channelId);
        mapOfRequestBody.put('message', message);
        mapOfRequestBody.put('url', URL);
        if (IntegrationConstants.POST_ALERT_TO_EXTERNAL_APP.equalsIgnoreCase(calledFor)) {
            endpointURL = SimpplrContext.simpplrAPIEndpoint + '/msteams/bot/api/postInChannel';
            mapOfRequestBody.put('userId', msUserId);
            mapOfRequestBody.put('tenantId', msTenantId);
            mapOfRequestBody.put('stageName', SimpplrContext.environmentStageName);
            //adding jwt token in api header
            mapOfCustomHeader.put('jwttoken', Utility.getJWTToken());
        } else if (IntegrationConstants.POST_SITE_FEED_CONTENT.equalsIgnoreCase(calledFor)) {
            endpointURL = MICROSOFT_TEAMS_POST_TO_CHANNEL;
            mapOfRequestBody.put('postUrl', false);
            mapOfRequestBody.put('externalId', msUserId);
            mapOfRequestBody.put('contentData', contentWrapper);
            //adding jwt token in api header
            if (!test.isRunningTest()){
                mapOfCustomHeader.put('jwttoken', Utility.getJWTToken());
            }
        }
        
        HTTPResponse res = Utility.getResponseFromAWS(endpointURL, mapOfRequestBody, mapOfCustomHeader);
        
    }

    @future (callout=true)
    public static void postAlertToChannelAsync(String teamId, String channelId, String URL, String message, String msTenantId, String msUserId) {
        MicrosoftTeamsHelper msTeamHelper = new MicrosoftTeamsHelper();
        ContentWrapper.ContentSiteFeedWrapper contentWrapper = new ContentWrapper.ContentSiteFeedWrapper();
        msTeamHelper.promoteContentToChannel(teamId, channelId, URL, message, IntegrationConstants.POST_ALERT_TO_EXTERNAL_APP, msTenantId, msUserId,contentWrapper);
    }

    @future (callout = true)
    public static void postAlertAsDMAsync(String URL, String message, String recipient, String memberType, String siteId, String audienceId, String msTenantId) {
        MicrosoftTeamsHelper msTeamHelper = new MicrosoftTeamsHelper();
        msTeamHelper.postAlertAsDM(URL, message, recipient, memberType, siteId, audienceId, msTenantId);
    }

    public void postAlertAsDM(String url, String message, String recipient, String memberType, String siteId, String audienceId, String msTenantId) {
        String endpointURL = SimpplrContext.simpplrAPIEndpoint + '/msteams/bot/api/postDM';
        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        Map<String, String> mapOfCustomHeader = new Map<String, String>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);
        mapOfRequestParam.put('message', message);
        mapOfRequestParam.put('url', URL);
        mapOfRequestParam.put('tenantId', msTenantId);
        
        Map<String, Object> alertDetailMap = new Map<String, Object>();
        Map<String, Object> alertRecipientMap = new Map<String, Object>();
        
        alertDetailMap.put('type', memberType);
        if (String.isNotBlank(siteId)) {
            alertDetailMap.put('id', siteId);

        } else if (String.isNotBlank(audienceId)) {
            alertDetailMap.put('id', audienceId);

        } else {
            alertDetailMap.put('id', 'all');

        }
        alertRecipientMap.put('recipientType', recipient);
        alertRecipientMap.put('value', alertDetailMap);
        mapOfRequestParam.put('sendTo', alertRecipientMap);
        //adding jwt token in api header
        mapOfCustomHeader.put('jwttoken',Utility.getJWTToken());
        HTTPResponse res = Utility.getResponseFromAWS(endpointURL, mapOfRequestParam, mapOfCustomHeader);
    }
    
    @future (callout = true)
    public static void publishSiteFeedContent(String contentId, String siteId, String contentType, String title, String summary, String authorName, String imgUrl){
        List<Simpplr_Site__c> siteList = [SELECT Id, name, External_Apps_Site_Config_Json__c FROM Simpplr_Site__c  WHERE Id =: siteId  WITH SECURITY_ENFORCED]; 
        if(siteList.size()>0){
            Simpplr_Site__c siteObj = 	siteList[0];
            if(siteObj.External_Apps_Site_Config_Json__c != null){
                ManageSiteWrapper.ExternalAppsSiteConfig externalAppsSiteConfig = new ManageSiteWrapper.ExternalAppsSiteConfig();
		        externalAppsSiteConfig = (ManageSiteWrapper.ExternalAppsSiteConfig)JSON.deserialize(siteObj.External_Apps_Site_Config_Json__c, ManageSiteWrapper.ExternalAppsSiteConfig.class);
                if((externalAppsSiteConfig.MsTeamsSiteConfig != null) && externalAppsSiteConfig.MsTeamsSiteConfig.msTeamsSiteFeedOptions.size()>0 && externalAppsSiteConfig.MsTeamsSiteConfig.msTeamsSiteFeedOptions.contains('msTeamsTimeline')){
                    String baseUrl = SimpplrContext.salesforceBaseUrl;
                    String viewLink = '';
			        String actor = '';
                    String siteOrContentURL = '';
                    String siteFeedURL = ''; 
                    String contentURL = PageContext.getPageURL(Pages.app)+'?u=/site/' + siteId +'/'+contentType+'/'+contentId+'&origin=microsoftteams';
                    siteOrContentURL = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteId + '/dashboard' + '&origin=microsoftteams';
                    String teamsTitle = SimpplrContext.applicationName+' - '+ siteObj.Name;
                    actor = getMicrosoftTeamsLink(UserContext.peopleName, baseUrl + Page.PageRedirector.getUrl() + '?userId=' + UserInfo.getUserId() +'&pageToRedirect='+Pages.ProfileAbout+'&origin=microsoftteams');
			        actor += ' in ' + getMicrosoftTeamsLink(teamsTitle, siteOrContentURL);
                    viewLink = getMicrosoftTeamsLink('View Post', contentURL);
                    actor = actor +' - '+viewLink;
                    siteFeedURL = actor + '<br>' + title;
                    String externalId = externalAppsSiteConfig.MsTeamsSiteConfig.msTeamsConnectedUserId;
                    ContentWrapper.ContentSiteFeedWrapper contentWrapper = new ContentWrapper.ContentSiteFeedWrapper();
                    contentWrapper.contentId = contentId;
                    contentWrapper.siteId = siteId;
                    contentWrapper.orgId = SimpplrContext.simpplrOrgId;
                    contentWrapper.title = title;
                    contentWrapper.summary = summary;
                    contentWrapper.authorName = authorName;
                    contentWrapper.imgUrl = imgUrl;
                    new MicrosoftTeamsHelper().promoteContentToChannel(externalAppsSiteConfig.MsTeamsSiteConfig.msTeamsTeamId, externalAppsSiteConfig.MsTeamsSiteConfig.msTeamsChannelId, contentURL, siteFeedURL, IntegrationConstants.POST_SITE_FEED_CONTENT, '', externalId, contentWrapper);
                }
            }
        }
    }

    public void getContentInfo(String contentId, String type){
        List<String> allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).replace('Blog', 'BlogPost').split(',');
        List<Simpplr_Content__c> contentInfo = [SELECT Id, Site__c ,Title__c, Display_Excerpt__c, Primary_Author__c, Primary_Author__r.Full_Name__c, 
												(SELECT Id,Content_Version__c,Content_Document__c,Title_Image_Type__c,Is_Title_Image__c,Thumbnail_URL__c, MIME_Type__c FROM File_Simpplr_Content__r WHERE Is_Title_Image__c = true And Is_Deleted__c = false) 
												FROM Simpplr_Content__c WHERE Id = :contentId AND TYPE__c IN :allowedFeaturesInAppList AND Activated_By_Feature__c = true AND Is_Published__c = true AND Is_Deleted__c = false WITH SECURITY_ENFORCED];
        List<File__c> titleFilesList = contentInfo[0].File_Simpplr_Content__r;
        String imgUrl = '';
        ManageContentDao obj = new ManageContentDao();
			if(!titleFilesList.isEmpty()){
				if(String.isBlank(titleFilesList[0].Content_Version__c) && String.isNotBlank(titleFilesList[0].Thumbnail_URL__c)){ //video
					imgUrl = titleFilesList[0].Thumbnail_URL__c; 
					
				} else if(String.isNotBlank(titleFilesList[0].Content_Version__c)){ //image
					Map<Id, String> cvIdNPublicUrlMap = obj.generateEmbedPublicUrl(new List<Id>{titleFilesList[0].Content_Version__c});
					imgUrl = cvIdNPublicUrlMap.get(titleFilesList[0].Content_Version__c);						
				}
			}
            publishSiteFeedContent(contentId, contentInfo[0].Site__c, type, contentInfo[0].Title__c, contentInfo[0].Display_Excerpt__c, contentInfo[0].Primary_Author__r.Full_Name__c, imgUrl);
    }

    public static String getMicrosoftTeamsLink(String name, String url){
	String linkToReturn = '';
    url = (String.isNotBlank(SimpplrContext.DeeplinkingRedirectURL)?SimpplrContext.DeeplinkingRedirectURL: ServiceConstants.SIMPPLR_DEEPLINKING_REDIRECTOR_URL) + EncodingUtil.urlEncode(url, 'UTF-8');
	linkToReturn = '<a href = "' + url + '">' + name + '</a>';
	return linkToReturn;
    }
    
    public HttpResponse saveMicrosoftTeamsManageAppInfo(Boolean microsoftTeamsIntegrationEnabled) {
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('microsoftTeamsIntegrationEnabled', microsoftTeamsIntegrationEnabled);
        HttpResponse res = getResponseFromMicrosoftTeamsMS(MICROSOFT_TEAMS_SAVE_MESSAGING_CONFIG_ENDPOINT, requestBody, IntegrationConstants.POST_REQUEST_TYPE, null);
        return res;
    }

    public HttpResponse getResponseFromMicrosoftTeamsMS(String endpoint, Object body, String method, Map<String, String> customHeaders) {
        HttpRequest req = new HttpRequest();
		req.setEndpoint(endpoint);     
        req.setHeader('jwttoken', Utility.getJwtToken());
        if(customHeaders != null && !customHeaders.isEmpty()) {
            for(String key: customHeaders.keySet()){
                req.setHeader(key, customHeaders.get(key));
            }
        }
        req.setMethod(method);
        req.setTimeout(60000);
        if(body != null) {
            req.setHeader('Content-Type', 'application/json');   
            req.setBody(Json.serialize(body));
        }
        Http http = new Http();
        HttpResponse response = http.send(req);
		logger.logDebug('MicrosoftTeamsHelper.getResponseFromMicrosoftTeamsMS()----endpoint----' + endpoint);
		logger.logDebug('MicrosoftTeamsHelper.getResponseFromMicrosoftTeamsMS()----request body----' + body);
        logger.logDebug('MicrosoftTeamsHelper.getResponseFromMicrosoftTeamsMS()----response body----' + response.getBody());
        if (response.getStatusCode() != 200) {
            throw new SimpplrException(ExceptionCode.UNEXPECTED_ERROR.name());
        }
        return response;                
    }  

    public Map<String, String> verifyAndGetUserDetails (Boolean isAdmin) { 

        Map<String, String> userProfileMap = null;
        String url;
        if(isAdmin) {
            url = MICROSOFT_TEAMS_ADMIN_CONNECTION;
        } else {
            url = MICROSOFT_TEAMS_USER_CONNECTION;
        }
        HttpResponse res = getResponseFromMicrosoftTeamsMS(url, null, IntegrationConstants.GET_REQUEST_TYPE, null);
        System.debug(res.getBody());
        Map<String, Object> resBodyMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        if(resBodyMap.get('result') != null) {
            userProfileMap = new Map<String, String>();
            Map<String, Object> resultMap = (Map<String, Object>) resBodyMap.get('result');
            userProfileMap.put('email', (String) resultMap.get('mail'));
            userProfileMap.put('userName', (String) resultMap.get('displayName'));
            userProfileMap.put('externalId', (String) resultMap.get('id'));
            userProfileMap.put('tenantId', (String) resultMap.get('tenantId'));
        }
        return userProfileMap;
    }

   public void createAppIntegrationRecord(String tenantId) {
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1',IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS);
        String query = 'SELECT id, Name, Integration_Enabled__c, User_Name__c, User_Email__c, External_Id__c, Enterprise_Id__c  FROM App_Integration__c where Name =:soqlParam1 LIMIT 1';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<App_Integration__c> appInteList = (List<App_Integration__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
        if(!appInteList.isEmpty()) {
            appInteList[0].User_Email__c = UserContext.email;
            appInteList[0].Enterprise_Id__c = tenantId;
            appInteList[0].Integration_Enabled__c = true;
            appInteList[0].Connected__c = true;
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Integration__c>(appInteList), new List<Schema.SObjectField>{									
                            App_Integration__c.User_Email__c,
                            App_Integration__c.Enterprise_Id__c,
                            App_Integration__c.Connected__c,
                            App_Integration__c.Integration_Enabled__c
                                        });
        } else {
            App_Integration__c appInteRecord = new App_Integration__c();
            appInteRecord.Name = IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS;
            appInteRecord.User_Email__c = UserContext.email;
            appInteRecord.Connected__c = true;
            appInteRecord.Integration_Enabled__c = true;
            appInteRecord.Enterprise_Id__c = tenantId;
            appInteRecord.Org_Id__c = UserInfo.getOrganizationId();
            appInteRecord.Client_Id__c = IntegrationConstants.MICROSOFT_TEAMS_CLIENT_ID;
            appInteRecord.Client_Secret__c = IntegrationConstants.MICROSOFT_TEAMS_CLIENT_SECRET;
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().insertAsUser(appInteRecord, new List<Schema.SObjectField>{									
                                App_Integration__c.User_Email__c,
                                App_Integration__c.Enterprise_Id__c,
                                App_Integration__c.Name,
                                App_Integration__c.Org_Id__c,
                                App_Integration__c.Client_Id__c,
                                App_Integration__c.Client_Secret__c,
                                App_Integration__c.Integration_Enabled__c,
                                App_Integration__c.Connected__c
                                        });
        }
   }

   public void processMSTeamsAdminDisconnect(Boolean isEnabledFlagSaveAtZeus) {
        if(isEnabledFlagSaveAtZeus) {
            HTTPResponse httpResponse = saveMicrosoftTeamsManageAppInfo(false);
        }
        processMSTeamsAdminAccountDisconnect();
        updateAndDeletePeopleAndSiteRecords();
    }

   public void processMSTeamsAdminAccountDisconnect() {
        //Process msteams app level disconnect at Zeus first then make corresponding updates in Odin
        HttpResponse response = processMSTeamsDisconnectAtZeus(IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS, IntegrationConstants.INTEGRATION_FLOW_APP);
        Map<String, Object> soqlParamMap = new  Map<String, Object>();
        soqlParamMap.put('soqlParam1', IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS);
        String query = 'SELECT id, Name, Connected__c, Integration_Enabled__c, User_Name__c, User_Email__c, External_Id__c, Enterprise_Id__c, Alerts_For_App_Enabled__c FROM App_Integration__c where Name =:soqlParam1 AND Integration_Enabled__c = true AND Is_Deleted__c = false';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<App_Integration__c> appInteList = (List<App_Integration__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
        if(!appInteList.isEmpty()) {
            appInteList[0].Connected__c = false;
            appInteList[0].Integration_Enabled__c = false;
            appInteList[0].User_Name__c = '';
            appInteList[0].User_Email__c = '';
            appInteList[0].External_Id__c = '';
            appInteList[0].Enterprise_Id__c = '';
            appInteList[0].Alerts_For_App_Enabled__c = false;
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Integration__c>(appInteList), new List<Schema.SObjectField>{									
                    App_Integration__c.User_Name__c,
                    App_Integration__c.User_Email__c,
                    App_Integration__c.Enterprise_Id__c,
                    App_Integration__c.External_Id__c,
                    App_Integration__c.Connected__c,
                    App_Integration__c.Alerts_For_App_Enabled__c,
                    App_Integration__c.Integration_Enabled__c
                                });
        }
    }

    public Map<String, String> getMSTeamsTenantInfo() {
        Map<String, String> mapOfTenantDetail = new Map<String, String>();
        Map<String, String> mapOfCustomHeaders = new Map<String, String>();
        String endpoint = MICROSOFT_TEAMS_TENANT_APP_SETTINGS;
        mapOfCustomHeaders.put(IntegrationConstants.ZEUS_HEADER_ACCOUNT_ID, SimpplrContext.uuid);
        HttpResponse res = getResponseFromMicrosoftTeamsMS(endpoint, null, IntegrationConstants.GET_REQUEST_TYPE, mapOfCustomHeaders);

        Map<String, Object> resBodyMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        if(resBodyMap.get('result') != null) {
            Map<String, Object> resultMap = (Map<String, Object>) resBodyMap.get('result');
            mapOfTenantDetail.put('tenantId', (String) resultMap.get('microsoftTeamsTenantId'));
        }
        return mapOfTenantDetail;
    }

    public HttpResponse processMSTeamsDisconnectAtZeus(String appName, String flow) {
        Map<String, Object> requestBody = new Map<String, Object>();
        Map<String, String> mapOfCustomHeader = new Map<String, String>();
        String endpoint = SimpplrContext.simpplrAPIEndpoint + '/v1/account/internal/core/integrations/'+ appName +'/disconnect?flow='+flow;
        mapOfCustomHeader.put('jwttoken', Utility.getJWTToken());
        mapOfCustomHeader.put(IntegrationConstants.ZEUS_HEADER_ACCOUNT_ID,SimpplrContext.uuid);
        mapOfCustomHeader.put(IntegrationConstants.ZEUS_HEADER_USER_ID,UserContext.uuid);
        HttpResponse res = Utility.getResponseFromAWS(endpoint, requestBody, mapOfCustomHeader);
        return res;
    }

    @future (callout=true)
    public static void installOrUninstallMSTeamsAppForUser(String msteamsUserId, String tenantId, Boolean isInstall) {
        Map<String, Object> requestBody = new Map<String, Object>();
        String endpoint;
        if(msteamsUserId != null && tenantId != null) {
            requestBody.put('msteamsUserId', msteamsUserId);
            requestBody.put('tenantId', tenantId);
            Map<String, String> mapOfCustomHeader = new Map<String, String>();
            mapOfCustomHeader.put('jwttoken', Utility.getJwtToken());
            if(isInstall) {
                endpoint = SimpplrContext.simpplrAPIEndpoint + '/msteams/teams/enableUnfurlInDM';
            } else {
                endpoint = SimpplrContext.simpplrAPIEndpoint + '/msteams/teams/disableUnfurlInDM';
            }
            HttpResponse res = Utility.getResponseFromAWS(endpoint, requestBody, mapOfCustomHeader);
        }
    }
}