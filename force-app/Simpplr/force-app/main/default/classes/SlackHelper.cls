public with sharing class SlackHelper {
    public static final String JWT_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/jwt';
    public static final String ZEUS_USER_ROLE = '3c774e6c-02b6-4b61-9d7d-03d083540136';
    public static final String SLACK_DISCONNECT_EXCEPTION = 'Slack is not connected in Org';
    public static String baseUrl = SimpplrContext.salesforceBaseUrl;

    public void updateAndDeletePeopleAndSiteRecords(Boolean isClearSlackDetailInPeople) {
        Map<String, Object> soqlParamMap = new  Map<String, Object>();
        List<String> availableSlackInte = new List<String>{IntegrationConstants.INTEGRATION_TYPE_SLACK,IntegrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE,IntegrationConstants.INTEGRATION_TYPE_SLACK_UNFURL};
        soqlParamMap.put('soqlParam1', availableSlackInte);
        String query = 'SELECT Id FROM People_Integration__c WHERE Name IN :soqlParam1';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<People_Integration__c> peopleIntList = (List<People_Integration__c>) SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
        if (peopleIntList != null && peopleIntList.size() > 0) {
            SIMPESAPI.accessController().deleteAsUser(peopleIntList);
        }
        //removing slack connection detail from people records
        if(isClearSlackDetailInPeople) {
            query = 'SELECT Id, Slack_User_Id__c, Slack_User_Name__c, Slack_Tenant_Id__c,Last_Edited_DateTime__c FROM People__c WHERE Slack_User_Id__c != null';
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            List<People__c> peopleList = (List<People__c>) SIMPESAPI.accessController().queryAsUSer(query, null);
            if(!peopleList.isEmpty()) {
                for(People__c people:peopleList) {
                    people.Slack_User_Id__c = '';
                    people.Slack_User_Name__c = '';
                    people.Slack_Tenant_Id__c = '';
                    people.Last_Edited_DateTime__c = DateTime.now();
                }
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                SIMPESAPI.accessController().updateAsUser(new Map<Id,People__c>(peopleList), new List<Schema.SObjectField>{
                        People__c.Slack_User_Id__c,
                        People__c.Slack_User_Name__c,
                        People__c.Slack_Tenant_Id__c,
                        People__c.Last_Edited_DateTime__c
                });
            }
        }
        List<Simpplr_Site__c> siteList = [SELECT Id,External_Apps_Site_Config_Json__c FROM Simpplr_Site__c WHERE Slack_Site_Manager__c = :UserContext.peopleId WITH SECURITY_ENFORCED];
		if(!siteList.isEmpty()){
            for(Simpplr_Site__c siteObj : siteList) {
                siteObj.Slack_Integration_Enabled__c = false;
                siteObj.Slack_Site_Manager__c = null;
                if(siteObj.External_Apps_Site_Config_Json__c != null){
                    ManageSiteWrapper.ExternalAppsSiteConfig externalAppsSiteConfig = new ManageSiteWrapper.ExternalAppsSiteConfig();
                    externalAppsSiteConfig = (ManageSiteWrapper.ExternalAppsSiteConfig)JSON.deserialize(siteObj.External_Apps_Site_Config_Json__c, ManageSiteWrapper.ExternalAppsSiteConfig.class);
                    externalAppsSiteConfig.SlackSiteConfig = null;
                    siteObj.External_Apps_Site_Config_Json__c = JSON.serializePretty(externalAppsSiteConfig,true);
                }
            }
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(new Map<Id,Simpplr_Site__c>(siteList), new List<Schema.SObjectField>{
                Simpplr_Site__c.Slack_Integration_Enabled__c,
                Simpplr_Site__c.Slack_Site_Manager__c,
                Simpplr_Site__c.External_Apps_Site_Config_Json__c
            });
        }
                        
    }

    public HttpResponse saveSlackManageAppInfo(Map<String, Object> mapOfSlackConfig) {
        Map<String, Object> requestBody = new Map<String, Object>();
        Map<String, String> mapOfCustomHeader = new Map<String, String>();
        String endpoint = SimpplrContext.simpplrAPIEndpoint + '/v1/account/appConfig/app.integrations.messaging';
        mapOfCustomHeader.put('jwttoken', Utility.getJWTToken());
        mapOfCustomHeader.put(IntegrationConstants.ZEUS_HEADER_ACCOUNT_ID, SimpplrContext.uuid);
        mapOfCustomHeader.put(IntegrationConstants.ZEUS_HEADER_USER_ID, UserContext.uuid);
        mapOfCustomHeader.put(IntegrationConstants.ZEUS_HEADER_APP, IntegrationConstants.ZEUS_APP_TYPE_ODIN);
        requestBody.put('slackIntegrationEnabled', mapOfSlackConfig.get('slackEnabledFlag'));
        requestBody.put('slackUnfurlAppInstalled', mapOfSlackConfig.get('slackUnfurlFlag'));
        requestBody.put('slackCustomAppName', mapOfSlackConfig.get('customAppName'));
        requestBody.put('slackCustomAppIconUrl', mapOfSlackConfig.get('customAppIconUrl'));
        HttpResponse res = Utility.getResponseFromAWS(endpoint, requestBody, mapOfCustomHeader);
        return res;
    }

    public class SlackContentWrapper{
	public String authorName;
        public String title = '';
        public String imgURL;
        public String siteName;
        public String summary;
        public String authorURL;
        public String siteURL;
        public String siteType;
        public String contentURL;
        public String contentType;
        public Boolean allDayEvent = false;
        public String eventStartDate = '';
        public String eventEndDate = '';
        public String eventLocation = '';
        public String eventMapUrl = '';
        public String message = '';

    }

    public class SlackUserWrapper{
		public String message;
        public Result result;
    }

    public class Result {
        public List<Map<String,String>> listOfApps;
    }

    
    public Map<String, String> getUserDetails () { 
        Map<String, String> userProfileMap = new Map<String, String>();
        Map<String, String> mapOfCustomHeader = new Map<String, String>();
        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        String endpoint = SimpplrContext.simpplrAPIEndpoint + '/v1/account/integrations/users/appSettings/integrations';
        mapOfCustomHeader.put('jwttoken', Utility.getJWTToken());
        mapOfCustomHeader.put(IntegrationConstants.ZEUS_HEADER_ACCOUNT_ID,SimpplrContext.uuid);
        mapOfCustomHeader.put(IntegrationConstants.ZEUS_HEADER_USER_ID,UserContext.uuid);
        mapOfCustomHeader.put(IntegrationConstants.ZEUS_HEADER_APP, IntegrationConstants.ZEUS_APP_TYPE_ODIN);
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        for(String key: mapOfCustomHeader.keySet()){
            req.setHeader(key, mapOfCustomHeader.get(key));
        }
        req.setMethod('GET');
        req.setTimeout(60000);
        HTTPResponse res = http.send(req);
        if(res.getStatusCode()==200){
            SlackUserWrapper slackUserWrapper = (SlackUserWrapper) System.JSON.deserialize(res.getBody(), SlackUserWrapper.class);
            if(slackUserWrapper.result.listOfApps!=null){
                for(Map<String,String> obj : slackUserWrapper.result.listOfApps){
                    if(obj.get('name').equalsIgnoreCase('slackContentShare')){
                        userProfileMap.put('userName', (String) obj.get('connectedAs'));
                        userProfileMap.put('userId', (String) obj.get('userId'));
                        userProfileMap.put('teamId', (String) obj.get('teamId'));
                    }
                }
            }   
        }
        return userProfileMap;
    }

    public void createPeopleIntegrationRecord (String userName, String userId, String teamId) {

        People_Integration__c peopleIntegrationObj = new  People_Integration__c();
        peopleIntegrationObj.Name = IntegrationConstants.INTEGRATION_TYPE_SLACK;
        peopleIntegrationObj.People__c = UserContext.peopleId;
        peopleIntegrationObj.Connected__c = true;
        peopleIntegrationObj.User_Name__c = userName;
        peopleIntegrationObj.User_Email__c = userId;
        peopleIntegrationObj.External_Id__c = teamId;
        peopleIntegrationObj.App_Integration__c = SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SLACK).id;
        peopleIntegrationObj.User__c = UserInfo.getUserID();
        if(UserContext.getCurrentUserInfo != null){
            peopleIntegrationObj.OwnerId = UserContext.getCurrentUserInfo.User__c;
        }	
        List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>{
                        People_Integration__c.Name, 
                        People_Integration__c.People__c,
                        People_Integration__c.Connected__c,
                        People_Integration__c.App_Integration__c,
                        People_Integration__c.User__c,                           
                        People_Integration__c.OwnerId,
                        People_Integration__c.User_Name__c,
                        People_Integration__c.User_Email__c,
                        People_Integration__c.External_Id__c
                    };
        if(UserContext.Integrations.containsKey(IntegrationConstants.INTEGRATION_TYPE_SLACK)) {
            peopleIntegrationObj.id = UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SLACK).Id;
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(peopleIntegrationObj, fieldList);
        } else {
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().insertAsUser(peopleIntegrationObj, fieldList);      
        }	 
        updatePeopleRecord(userName, userId, teamId);       
    }

    public void updatePeopleRecord (String userName, String userId, String tenantId) {
        Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', UserContext.peopleId);
        String query = 'SELECT Id, Slack_User_Id__c, Slack_User_Name__c, Slack_Tenant_Id__c,Last_Edited_DateTime__c FROM People__c WHERE Id = :soqlParam1 AND Is_Deleted__c = false LIMIT 1';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<People__c> peopleList = (List<People__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
        if (!peopleList.isEmpty()) {
            peopleList[0].Slack_User_Id__c = userId;
            peopleList[0].Slack_User_Name__c = userName;
            peopleList[0].Slack_Tenant_Id__c = tenantId;
            peopleList[0].Last_Edited_DateTime__c = DateTime.now();
            List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>{
                People__c.Slack_User_Id__c,
                People__c.Slack_User_Name__c,
                People__c.Slack_Tenant_Id__c,
                People__c.Last_Edited_DateTime__c
            };
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(peopleList[0], fieldList);
        }
    }

    public void updateAppIntegrationRecord(){
        String appIntQuery = 'select id, App_Installed__c from App_Integration__c where name = :soqlParam1 AND Integration_Enabled__c = true AND Is_Deleted__c = false';
        Map<String, Object> sqlParamMap = new Map<String, Object>();
        sqlParamMap.put('soqlParam1', IntegrationConstants.INTEGRATION_TYPE_SLACK);

        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<App_integration__c> appIntegList = (List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, sqlParamMap);
        
        if(appIntegList.isEmpty()==false){
            if(appIntegList[0].App_installed__c == false) {
                appIntegList[0].App_installed__c = true;

                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
                SIMPESAPI.accessController().updateAsUser(new Map<Id, App_integration__c>(appIntegList), new List<Schema.SObjectField>{
                        App_integration__c.App_installed__c
                });
            }
        } else {
            App_Integration__c appIntegObj = new App_Integration__c(Integration_Enabled__c=true,
                                            Client_Id__c=IntegrationConstants.SLACK_CLIENT_ID,
                                            Client_Secret__c=IntegrationConstants.SLACK_CLIENT_SECRET,
                                            Org_Id__c = UserInfo.getOrganizationId(),
                                            name=IntegrationConstants.INTEGRATION_TYPE_SLACK);
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
            SIMPESAPI.accessController().insertAsUser(appIntegObj,
                    new List<Schema.SObjectField>{
                        App_Integration__c.Integration_Enabled__c, 
                        App_Integration__c.Name, 
                        App_Integration__c.Client_Id__c, 
                        App_Integration__c.Client_Secret__c, 
                        App_Integration__c.Org_Id__c});
        }
    }

    public Boolean getSlackAppInstalledInfo() {
        Boolean isSlackAppInstalled = false;
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1', IntegrationConstants.INTEGRATION_TYPE_SLACK);
        String query = 'SELECT id, Name, App_Installed__c FROM App_Integration__c where Name =:soqlParam1 AND Integration_Enabled__c = true AND Is_Deleted__c = false';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<App_integration__c> appIntegList = (List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
        if(appIntegList != null && appIntegList.size() > 0) {
            isSlackAppInstalled = appIntegList[0].App_Installed__c;
        }
        return isSlackAppInstalled;
    }

    public HttpResponse processSlackDisconnectionAtZeus(String appName, String flow, Boolean slackUnfurlAppInstalled, Boolean isAppLevelSlackDisconnect) {
        Map<String, Object> requestBody = new Map<String, Object>();
        Map<String, String> mapOfCustomHeader = new Map<String, String>();
        String endpoint = SimpplrContext.simpplrAPIEndpoint + '/v1/account/internal/core/integrations/'+ appName +'/disconnect?flow='+flow;
        mapOfCustomHeader.put('jwttoken', Utility.getJWTToken());
        mapOfCustomHeader.put(IntegrationConstants.ZEUS_HEADER_ACCOUNT_ID,SimpplrContext.uuid);
        mapOfCustomHeader.put(IntegrationConstants.ZEUS_HEADER_USER_ID,UserContext.uuid);
        requestBody.put('isSlackUnfurlConnected', slackUnfurlAppInstalled);
        requestBody.put('isSlackAppLevelDisconnect', isAppLevelSlackDisconnect);
        HttpResponse res = Utility.getResponseFromAWS(endpoint, requestBody, mapOfCustomHeader);
        return res;
    }

    public void publishSiteFeed(String feedPostId, String replyId, SlackContentWrapper contentData, Map<String, Object> requestBodyMap){
        Map<String, Object> requestBodySlack = new Map<String, Object>();
        Map<String, String> mapOfCustomHeader = new Map<String, String>();
        String endpoint = SimpplrContext.zeusMicroserviceUrl + '/v1/content/slack/postMessage';
        mapOfCustomHeader.put('authorization', Utility.getJWTToken());
        requestBodySlack.put('contentData', contentData);
        requestBodySlack.put('feedPostId', feedPostId);
        requestBodySlack.put('replyId', replyId);
        if(requestBodyMap != null && requestBodyMap.size() > 0) {
            requestBodySlack.put('isUnfurlEnabled', requestBodyMap.get('isUnfurlEnabled'));
            requestBodySlack.put('channelId', requestBodyMap.get('slackChannelId'));
            requestBodySlack.put('category', requestBodyMap.get('category'));
            requestBodySlack.put('channelList', requestBodyMap.get('channelList'));
            requestBodySlack.put('mode', requestBodyMap.get('mode'));
            requestBodySlack.put('appName', requestBodyMap.get('appName'));
            requestBodySlack.put('userId', requestBodyMap.get('userId'));
            requestBodySlack.put('feedMessageSegments', requestBodyMap.get('feedMessageSegments'));
        }
        
        HttpResponse res = Utility.getResponseFromAWS(endpoint, requestBodySlack, mapOfCustomHeader);
    }

    @future (callout = true)
    public static void createSiteFeedContent(Map<String, String> mapOfContentDetail, List<String> channelList){
        if(channelList != null && channelList.size() > 0) {
            mapOfContentDetail.put('slackChannelId', '');
            new SlackHelper().prepareContentSlackBody(mapOfContentDetail, channelList);
        } else {
            List<Simpplr_Site__c> siteList = [SELECT Id, name, External_Apps_Site_Config_Json__c FROM Simpplr_Site__c  WHERE Id =: mapOfContentDetail.get('siteId')  WITH SECURITY_ENFORCED]; 
            if(siteList.size()>0){
                Simpplr_Site__c siteObj = 	siteList[0];
                if(siteObj.External_Apps_Site_Config_Json__c != null){
                    ManageSiteWrapper.ExternalAppsSiteConfig externalAppsSiteConfig = new ManageSiteWrapper.ExternalAppsSiteConfig();
                    externalAppsSiteConfig = (ManageSiteWrapper.ExternalAppsSiteConfig)JSON.deserialize(siteObj.External_Apps_Site_Config_Json__c, ManageSiteWrapper.ExternalAppsSiteConfig.class);
                    if((externalAppsSiteConfig.SlackSiteConfig != null) && externalAppsSiteConfig.SlackSiteConfig.slackSiteFeedOptions.size()>0 && externalAppsSiteConfig.SlackSiteConfig.slackSiteFeedOptions.contains('slackTimeline')){
                        mapOfContentDetail.put('slackChannelId', externalAppsSiteConfig.SlackSiteConfig.slackChannelId);
                        List<People__c> people = [SELECT UUID__c FROM People__c where Slack_User_Id__c =:externalAppsSiteConfig.SlackSiteConfig.slackConnectedUserId];
                        if(people.size()>0 && people[0].UUID__c != null){
                            mapOfContentDetail.put('userId', people[0].UUID__c);
                        }
                        channelList = channelList != null ? channelList : new List<String>();
                        new SlackHelper().prepareContentSlackBody(mapOfContentDetail, channelList);
                    }
                }
            }
        }
    }

    public void getContentInfo(String contentId, List<String> channelList, String message){
        Map<String, Object> soqlParamMap = new  Map<String, Object>();
        soqlParamMap.put('soqlParam1', contentId);
        String contentQuery = 'SELECT Id, Site__c, Site__r.Is_Content_Unfurl_Enabled__c, Site__r.Site_Type__c, Type__c, (SELECT Id,Content_Version__c,Content_Document__c, '+ 
        ' Title_Image_Type__c,Is_Title_Image__c,Thumbnail_URL__c, MIME_Type__c FROM File_Simpplr_Content__r WHERE Is_Title_Image__c = true And Is_Deleted__c = false) '+
		' FROM Simpplr_Content__c WHERE Id = :soqlParam1 AND Is_Published__c = true AND Is_Deleted__c = false ';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
        List<Simpplr_Content__c> contentInfo = (List<Simpplr_Content__c>) SIMPESAPI.accessController().queryAsUSer(contentQuery, soqlParamMap);
        List<File__c> titleFilesList = contentInfo[0].File_Simpplr_Content__r;
        String imgUrl = '';
        ManageContentDao obj = new ManageContentDao();
        if(!titleFilesList.isEmpty()){
            if(String.isBlank(titleFilesList[0].Content_Version__c) && String.isNotBlank(titleFilesList[0].Thumbnail_URL__c)){ //video
                imgUrl = titleFilesList[0].Thumbnail_URL__c; 
                
            } else if(String.isNotBlank(titleFilesList[0].Content_Version__c)){ //image
                Map<Id, String> cvIdNPublicUrlMap = obj.generateEmbedPublicUrl(new List<Id>{titleFilesList[0].Content_Version__c});
                List<ContentDistribution> listOfNewContentDistribution = [SELECT Id, ContentDownloadUrl FROM ContentDistribution 
                                                                        WHERE ContentVersionId =:titleFilesList[0].Content_Version__c WITH SECURITY_ENFORCED];					
                imgUrl = listOfNewContentDistribution[0].ContentDownloadUrl;
            }
        }
        Map<String, String> mapOfContentDetail = new Map<String, String>();
        mapOfContentDetail.put('contentId', contentId);
        mapOfContentDetail.put('contentType', contentInfo[0].Type__c);
        mapOfContentDetail.put('imgUrl', imgUrl);
        mapOfContentDetail.put('message', message);
        mapOfContentDetail.put('siteId', contentInfo[0].Site__c);
        mapOfContentDetail.put('isUnfurlEnabled',String.valueOf(contentInfo[0].Site__r.Is_Content_Unfurl_Enabled__c));
        mapOfContentDetail.put('siteType', contentInfo[0].Site__r.Site_Type__c);
        if(channelList != null && channelList.size() > 0) {
            mapOfContentDetail.put('mode', 'mannual');
            createSiteFeedContent(mapOfContentDetail, channelList);
        } else {
            mapOfContentDetail.put('mode', 'auto');
		    createSiteFeedContent(mapOfContentDetail, channelList);
        }
    }

    public void createSiteFeed(Map<String, String> siteFeedDetail){
        SlackContentWrapper contentWrapper = new SlackContentWrapper();
        String siteId = String.isNotBlank(siteFeedDetail.get('siteId')) ? siteFeedDetail.get('siteId') : '';
        String postId = String.isNotBlank(siteFeedDetail.get('postId')) ? siteFeedDetail.get('postId') : '';
        String slackUserId = String.isNotBlank(siteFeedDetail.get('slackUserId')) ? siteFeedDetail.get('slackUserId') : '';
        String category = String.isNotBlank(siteFeedDetail.get('category')) ? siteFeedDetail.get('category') : '';
        String channelId = String.isNotBlank(siteFeedDetail.get('channelId')) ? siteFeedDetail.get('channelId') : '';
        String replyId = String.isNotBlank(siteFeedDetail.get('replyId')) ? siteFeedDetail.get('replyId') : '';
        contentWrapper.imgURL = String.isNotBlank(siteFeedDetail.get('imgURL')) ? siteFeedDetail.get('imgURL') : '';
        contentWrapper.authorName = UserContext.peopleName;
        contentWrapper.siteName = String.isNotBlank(siteFeedDetail.get('siteName')) ? siteFeedDetail.get('siteName') : '';
        contentWrapper.summary = String.isNotBlank(siteFeedDetail.get('body')) ? siteFeedDetail.get('body') : '';
        contentWrapper.siteType = String.isNotBlank(siteFeedDetail.get('siteType')) ? siteFeedDetail.get('siteType') : '';
        contentWrapper.contentType = 'Feed';
        contentWrapper.siteURL = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteId + '/dashboard' + '&origin=slack';
        contentWrapper.authorURL = baseUrl + Page.PageRedirector.getUrl() + '?userId=' + UserInfo.getUserId() +'&pageToRedirect='+Pages.ProfileAbout+'&origin=slack';
        contentWrapper.contentURL = baseUrl + Page.app.getUrl()+'?u=/feed/'+postId+'&origin=slack';
        contentWrapper.message = ''; //avoiding null in message key
        String appName = SimpplrContext.applicationName;
        List<People__c> people = [SELECT UUID__c FROM People__c where Slack_User_Id__c =:slackUserId];
        Map<String, Object> requestBodyMap = new Map<String, Object>();
        requestBodyMap.put('slackChannelId', channelId);
        requestBodyMap.put('category', category);
        requestBodyMap.put('appName', appName);
        requestBodyMap.put('channelList', new List<String>());
        requestBodyMap.put('mode', 'auto');
        requestBodyMap.put('isUnfurlEnabled', siteFeedDetail.get('isUnfurlEnabled'));

        List<Object> feedMessageSegments = (List<Object>) JSON.deserializeUntyped(siteFeedDetail.get('feedMessageSegments'));
        requestBodyMap.put('feedMessageSegments', feedMessageSegments);
        if(people.size()>0 && people[0].UUID__c != null){
            requestBodyMap.put('userId', people[0].UUID__c);
        }
        new SlackHelper().publishSiteFeed(postId, replyId, contentWrapper, requestBodyMap);
    }

    public void prepareContentSlackBody(Map<String, String> mapOfContentDetail, List<String> channelList) {
        Map<String, Object> soqlParamMap = new  Map<String, Object>();
        soqlParamMap.put('soqlParam1', mapOfContentDetail.get('contentId'));
        String contentQuery = 'SELECT Id ,Title__c, Display_Excerpt__c, Primary_Author__c, Primary_Author__r.Full_Name__c, Site__r.Name, ' +
        ' Event_Is_All_Day__c, Event_Location__c, Event_End_DateTime__c, Event_Map_URL__c,  Event_Start_DateTime__c ' +
        ' FROM Simpplr_Content__c WHERE Id =: soqlParam1 AND Is_Published__c = true AND Is_Deleted__c = false ';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
        List<Simpplr_Content__c> contentInfo = (List<Simpplr_Content__c>) SIMPESAPI.accessController().queryAsUSer(contentQuery, soqlParamMap);
        
        String contentURL = PageContext.getPageURL(Pages.app)+'?u=/site/' + mapOfContentDetail.get('siteId') +'/'+mapOfContentDetail.get('contentType').uncapitalize()+'/'+contentInfo[0].Id;
        String siteURL = PageContext.getPageURL(Pages.app) +'?u=/site/' + mapOfContentDetail.get('siteId') + '/dashboard' + '&origin=slack';
        String authorURL = baseUrl + Page.PageRedirector.getUrl() + '?userId=' + UserInfo.getUserId() +'&pageToRedirect='+Pages.ProfileAbout+'&origin=slack';
        SlackContentWrapper contentWrapper = new SlackContentWrapper();
        contentWrapper.imgURL = String.isNotBlank(mapOfContentDetail.get('imgUrl')) ? mapOfContentDetail.get('imgUrl') : '';
        contentWrapper.contentURL = String.isNotBlank(contentURL) ? contentURL : '';
        contentWrapper.siteURL = String.isNotBlank(siteURL) ? siteURL : '';
        contentWrapper.authorURL = String.isNotBlank(authorURL) ? authorURL : '';
        contentWrapper.title = String.isNotBlank(contentInfo[0].Title__c) ? contentInfo[0].Title__c : '';
        contentWrapper.siteName = String.isNotBlank(contentInfo[0].Site__r.Name) ? contentInfo[0].Site__r.Name : '';
        contentWrapper.summary = String.isNotBlank(contentInfo[0].Display_Excerpt__c) ? contentInfo[0].Display_Excerpt__c : '';
        contentWrapper.authorName = String.isNotBlank(contentInfo[0].Primary_Author__r.Full_Name__c) ? contentInfo[0].Primary_Author__r.Full_Name__c : '';
        contentWrapper.contentType = String.isNotBlank(mapOfContentDetail.get('contentType')) ? mapOfContentDetail.get('contentType'): '';
        contentWrapper.allDayEvent = contentInfo[0].Event_Is_All_Day__c;
        contentWrapper.eventStartDate = String.isNotBlank(String.valueOf(contentInfo[0].Event_Start_DateTime__c)) ? String.valueOf(contentInfo[0].Event_Start_DateTime__c) : '';
        contentWrapper.eventEndDate = String.isNotBlank(String.valueOf(contentInfo[0].Event_End_DateTime__c)) ? String.valueOf(contentInfo[0].Event_End_DateTime__c) : '';
        contentWrapper.eventLocation = String.isNotBlank(contentInfo[0].Event_Location__c) ? String.valueOf(contentInfo[0].Event_Location__c) : '';
        contentWrapper.eventMapUrl = String.isNotBlank(contentInfo[0].Event_Map_URL__c) ? String.valueOf(contentInfo[0].Event_Map_URL__c) : '';
        contentWrapper.message = String.isNotBlank(mapOfContentDetail.get('message')) ? mapOfContentDetail.get('message') : '';
        contentWrapper.siteType = String.isNotBlank(mapOfContentDetail.get('siteType')) ? mapOfContentDetail.get('siteType') : '';
        Map<String, Object> requestBodyMap = new Map<String, Object>();
        requestBodyMap.put('slackChannelId', mapOfContentDetail.get('slackChannelId'));
        requestBodyMap.put('category', 'Promote_Content');
        requestBodyMap.put('appName', SimpplrContext.applicationName);
        requestBodyMap.put('channelList', channelList);
        requestBodyMap.put('mode', mapOfContentDetail.get('mode'));
        requestBodyMap.put('isUnfurlEnabled', mapOfContentDetail.get('isUnfurlEnabled'));
        requestBodyMap.put('userId', mapOfContentDetail.get('userId'));
        requestBodyMap.put('feedMessageSegments', new List<Object>());
        new SlackHelper().publishSiteFeed(contentInfo[0].Id, '', contentWrapper, requestBodyMap);
    }

    public void updateDetailsInAppIntegration() {
        List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
        String appIntQuery = 'select id, App_Installed__c, Is_Slack_Upgraded__c from App_Integration__c where name = :soqlParam1 AND Is_Deleted__c = false';
        Map<String, Object> sqlParamMap = new Map<String, Object>();
        sqlParamMap.put('soqlParam1', IntegrationConstants.INTEGRATION_TYPE_SLACK);

        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
        List<App_integration__c> appIntegList = (List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, sqlParamMap);
        
        if(!appIntegList.isEmpty()) {
                appIntegList[0].App_installed__c = false;
                appIntegList[0].Is_Slack_Upgraded__c = true;
                fieldList.add(App_Integration__c.App_installed__c);
                fieldList.add(App_Integration__c.Is_Slack_Upgraded__c);
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
                SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Integration__c>(appIntegList), fieldList);
        }
    }
    /**
     * This method will disconnect slack at org level
     */
    public void handleSlackAppDisconnect(ManageApplicationWrapper.MessagingIntegrationWrapper integrationObj) {
        Map<String, App_Integration__c> mapOfIntegration = SimpplrContext.Integrations;
        if(mapOfIntegration.containsKey(IntegrationConstants.INTEGRATION_TYPE_SLACK)) {
            App_Integration__c slackInteObj = new App_Integration__c(Id= mapOfIntegration.get(IntegrationConstants.INTEGRATION_TYPE_SLACK).Id , Integration_Enabled__c=integrationObj.slackIntegrationEnabled, App_installed__c = false, Custom_Name_Enabled__c = false, Custom_App_Name__c = '', Custom_App_Icon_Url__c = '');

           boolean slackUnfurlAppInstalled = integrationObj.isSlackUnfurlAppInstalled == null ? false : integrationObj.isSlackUnfurlAppInstalled;
            if(integrationObj.slackIntegrationEnabled == false) {//deleting user connection when app connection disabled
                HttpResponse response = processSlackDisconnectionAtZeus(IntegrationConstants.INTEGRATION_SLACK_UNFURL, IntegrationConstants.INTEGRATION_FLOW_APP, slackUnfurlAppInstalled, true);
            }
            Map<String, Object> mapOfSlackConfig = new Map<String, Object>();
            mapOfSlackConfig.put('slackEnabledFlag', false);
            mapOfSlackConfig.put('slackUnfurlFlag', false);
            mapOfSlackConfig.put('customAppName', '');
            mapOfSlackConfig.put('customAppIconUrl', '');
            HttpResponse slackInteRespone = saveSlackManageAppInfo(mapOfSlackConfig);
            if (slackInteRespone.getStatusCode() == 200) {
                updateAndDeletePeopleAndSiteRecords(true);
                List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
                fieldList.add(App_Integration__c.Integration_Enabled__c);
                fieldList.add(App_Integration__c.App_installed__c);
                fieldList.add(App_Integration__c.Custom_Name_Enabled__c);
                fieldList.add(App_Integration__c.Custom_App_Name__c);
                fieldList.add(App_Integration__c.Custom_App_Icon_Url__c);
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
                SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Integration__c>(new List<App_Integration__c>{slackInteObj}), fieldList);
            }
        } else {
            throw new SimpplrException(SLACK_DISCONNECT_EXCEPTION);
        }
    }
}