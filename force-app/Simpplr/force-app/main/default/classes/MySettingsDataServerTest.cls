@isTest
private class MySettingsDataServerTest {

    @testSetup static void setup() {
		TestHelper.setupAppConfig(); 
		App_Config__c appConfigRecord = TestHelper.setupAppConfig();
        User testUser = TestHelper.createUser('Simpplr_usr1', null, false);
        User testAdminUser = TestHelper.createUser('Simpplr_admin', null, true); 
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
        People_Preference__c peoplePreferenceRec = Testhelper.createPeoplePreference(peopleObj.Id);
        peoplePreferenceRec.Email_Product_Research__c = true;
        update peoplePreferenceRec;
        List<App_Integration__c> appIntList  = TestHelper.createAppIntegrationRecords(false, new Set<String>{'servicenow', 'slack','twitter', 'facebook', 'linkedin', 'googledrive', 'box', 'googlecalendar','onedrive'});
        List<People_Integration__c> peopleIntList = TestHelper.createPeopleIntegrationRecords(appIntList, peopleObj.id, 'sadadqeq');
    }
    
    private static PageReference init() {
    	PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','MySettingDataServer');
        Test.setCurrentPage(pgRef);
        return pgRef;
    }
   
    
    private static User getAdminUser(){
        User userObj = [select id,name,alias,profile.PermissionsCustomizeApplication,profile.PermissionsModifyAllData,profile.permissionsModerateChatter 
        					from User where profile.name ='System Administrator' and lastname='Simpplr_admin' LIMIT 1];
        return userObj;
    }
    
     private static People__c getPeople(String lastName){
        People__c  peopleObj = [Select Id, Title__c, Street__c, State__c, Phone__c, Full_Name__c, User__c, Mobile_Phone__c, Manager__c, 
        							Last_Name__c, First_Name__c, Fax__c, Extension__c, Email__c, Department__c, Country__c, City__c 
									From People__c where Last_Name__c =: lastName LIMIT 1];
        return peopleObj;
    }
   
     @isTest static void testHandleRequestWhenActionAvailable() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/success',false));
        people__c peopleObj = getPeople('Simpplr_usr1');
        PageReference pageRef = Page.DataServerRW;
   
        pageRef.getParameters().put('target','MySettingDataServer');

        MySettingDataServer SettingDSObject= new MySettingDataServer();
        SettingDSObject.handleRequest(); 
        System.assertEquals('error', SettingDSObject.response.status, SettingDSObject.response.message);

        pageRef.getParameters().put('action','saveSummariesAndDigestSettings');
        pageRef.getParameters().put('data','{"peopleId":"'+peopleObj.Id+'", "digestFrequency":"Daily","topStoriesFrequency":"Never", "siteAnalyticsFrequency":"Monthly", "emailProductResearch":false}');
		Test.setCurrentPage(pageRef);
        SettingDSObject.handleRequest(); 
        System.assertEquals('success', SettingDSObject.response.status, SettingDSObject.response.message);
        
        pageRef.getParameters().put('action','getEmailNotificationsSettings');
        pageRef.getParameters().put('peopleId',peopleObj.Id); 
        Test.setCurrentPage(pageRef);
        SettingDSObject.handleRequest();
        System.assertEquals('success', SettingDSObject.response.status, SettingDSObject.response.message);

        pageRef.getParameters().put('action','getSummariesAndDigestSettings');
        pageRef.getParameters().put('peopleId',peopleObj.Id); 
        Test.setCurrentPage(pageRef);
        SettingDSObject.handleRequest();
        System.assertEquals('success', SettingDSObject.response.status, SettingDSObject.response.message);
         
        pageRef.getParameters().put('action','getAppManagerNotificationsSettings');
        pageRef.getParameters().put('peopleId',peopleObj.Id); 
        Test.setCurrentPage(pageRef);
        SettingDSObject.handleRequest();
        System.assertEquals('success', SettingDSObject.response.status, SettingDSObject.response.message);
        
        pageRef.getParameters().put('action','getMobileAppNotificationsSettings');
        pageRef.getParameters().put('peopleId',peopleObj.Id); 
        Test.setCurrentPage(pageRef);
        SettingDSObject.handleRequest();
        System.assertEquals('success', SettingDSObject.response.status, SettingDSObject.response.message);
        
        pageRef.getParameters().put('action','getNativeMobileAppNotificationsSettings');
        pageRef.getParameters().put('peopleId',peopleObj.Id); 
        Test.setCurrentPage(pageRef);
        SettingDSObject.handleRequest();
        System.assertEquals('success', SettingDSObject.response.status, SettingDSObject.response.message);

        pageRef.getParameters().put('action','getBrowserNotificationsSettings');
        pageRef.getParameters().put('peopleId',peopleObj.Id); 
        Test.setCurrentPage(pageRef);
        SettingDSObject.handleRequest();
        System.assertEquals('success', SettingDSObject.response.status, SettingDSObject.response.message);
         
        pageRef.getParameters().put('action','getSMSNotificationsSettings');
        pageRef.getParameters().put('peopleId',peopleObj.Id); 
        Test.setCurrentPage(pageRef);
        SettingDSObject.handleRequest();
        System.assertEquals('success', SettingDSObject.response.status, SettingDSObject.response.message);
 
         App_Integration__c appInteg = new App_Integration__c();
         appInteg.Name = 'linkedin';
         appInteg.Integration_Enabled__c = true;
         appInteg.Connected__c = true;
         appInteg.Client_Id__c = 'Devops';
         appInteg.Client_Secret__c ='Salesforce';
         appInteg.Is_Deleted__c = false;
         appInteg.Org_Id__c = UserInfo.getOrganizationId();
         insert appInteg;
         
         People_Integration__c ppl = new People_Integration__c();
         ppl.Is_Deleted__c = false;
         ppl.App_Integration__c = appInteg.id;
         ppl.People__c = peopleObj.id;
         insert ppl;

        pageRef.getParameters().put('action','saveBrowserNotificationsSettings');
        pageRef.getParameters().put('data','{"peopleId":"'+ peopleObj.id +'","browserUpdatesContentSitesFollow":true,"browserSubscriptionRequest":true,"browserSharesMyPost":true,"browserReplyOnMyPost":true,"browserReplyOnLikedPost":true,"browserReplyAfterMe":true,"browserPrivateSiteMembershipResponse":true,"browserPrivateSiteMembershipRequest":true,"browserPostsToMe":true,"browserMustRead":true,"browserLikesMyPostOrReply":true,"browserFollowsMe":true,"browserEventUpdatesAuthoredOrganized":true,"browserEventUpdatesAttending":true,"browserEventInvite":true,"browserEndorseExpertise":true,"browserContentValidationRequired":true,"browserContentValidationExpired":true,"browserContentSubmittedForModeration":true,"browserContentLikesSharesOnPublished":true,"browserContentFeedback":true,"browserContentCommentsOnPublished":true,"browserContentApprovalRejection":true,"browserAlerts":true,"browserQnAQuestionMention":true,"browserQnAAnswerMention":true,"browserQnAVote":true,"browserQnAAnswerApproval":true,"browserQnANewAnswer":true,"browserQnANewApprovedAnswer":true,"browserQnADuplicateQuestion":true,"browserQnANewQuestion":true,"browserContentAnswer":true,"browserContentQuestion":true,"browserCnIEndCampaign":true,"browserCnINewCampaign":true,"browserCnIInitiativeEnd":true,"browserCnIInitiativeStart":true}');
        Test.setCurrentPage(pageRef);
        SettingDSObject.handleRequest();
        System.assertEquals('success', SettingDSObject.response.status, 'Sattus should be success');

        Test.stopTest();
     }
    
        @isTest static void testSaveProfileSettings() {
        Test.startTest();
        init();
        PageReference pgRef = Page.DataServerRW;
        people__c poepleObj = getPeople('Simpplr_usr1');
        update poepleObj;
        MySettingDataServer serverObj = new MySettingDataServer();
        
       
    	pgRef.getParameters().put('target','MySettingDataServer');
        Test.setCurrentPage(pgRef);
        SimpplrContext.isPPTimezoneDisplay = true;
        SimpplrContext.isPPTimezoneEditable = true;
        SimpplrContext.isPPManagerEditable = true;
        SimpplrContext.PDSSourceApplication = 's';
        UserContext.isUserAppModerator = false;
        People__c currentPeople = [select id from people__c where user__c=:UserInfo.getUserId()];
        pgRef.getParameters().put('action', 'saveProfileSettings');
        pgRef.getParameters().put('data', '{"peopleId":"' + currentPeople.Id + '", "timeZone":"Asia/Kolkata"}');

        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, 'Running as expected');
       
        SimpplrContext.PDSSourceApplication = 'None';
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, 'Running as expected');

        UserContext.isUserAppModerator = true;
        pgRef.getParameters().put('action', 'saveProfileSettings');
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, 'Running as expected');
         
     	SimpplrContext.PDSSourceApplication = 'Nne';
		MySettingsWrapper.CustomUserFields cFObj = new  MySettingsWrapper.CustomUserFields();            
		cFObj.fieldName = 'firstname__c';
		cFObj.columnName = 'first_name__c';
		cFObj.fieldType = 'multipicklist';
        cFObj.isEditable = 'true'; 
        List<MySettingsWrapper.CustomUserFields> cFList = new List<MySettingsWrapper.CustomUserFields>();
       	cFList.add(cFObj);
        cFList.add(cFObj);
        String cFJSON = JSON.serialize(cFList);
      	String requestJSON = '{"peopleId":"' + currentPeople.Id + '","customUserFieldList":' + cFJSON + ',"firstName":"Deepak","SimpplrLanguageLocaleKey":"en_UK","salesforceLanguageLocaleKey":"en_US","lastName":"Sirohi","manager":"ss","title":"Mr","department":"eng","companyName":"simmplr","division":"intern","birthdayMonth":"12","birthdayDay":"5","joiningDate__label":"Aug 26 2019","joiningDate":"2019-08-26","aboutme":"ss","phone":"123","extension":null,"mobile":"2345","zoomId":"13253","street":"ff","city":"Gurugram","state":"Haryana","country":"IN","timeZone":"America/Los_Angeles","fieldType":"multipicklist","isEditable":true}';
        MySettingsWrapper.ProfileWrapper profileWrapper = (MySettingsWrapper.ProfileWrapper)Json.deserialize(requestJSON, MySettingsWrapper.ProfileWrapper.class);
        pgRef.getParameters().put('data', requestJSON);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, 'Running as expected');

		cFObj.fieldType = 'date';
        cFList.add(cFObj);
        cFJSON = JSON.serialize(cFList);
        requestJSON = '{"peopleId":"' + currentPeople.Id + '","timeZone":"Asia/Kolkata","customUserFieldList":' + cFJSON + '}';    
        profileWrapper = (MySettingsWrapper.ProfileWrapper)Json.deserialize(requestJSON, MySettingsWrapper.ProfileWrapper.class);
        pgRef.getParameters().put('data', requestJSON);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, 'Running as expected');
       
        cFObj.fieldType = 'string';
        cFList.add(cFObj);
        cFJSON = JSON.serialize(cFList);
        requestJSON = '{"peopleId":"' + currentPeople.Id + '","timeZone":"Asia/Kolkata","customUserFieldList":' + cFJSON + '}';    
        profileWrapper = (MySettingsWrapper.ProfileWrapper)Json.deserialize(requestJSON, MySettingsWrapper.ProfileWrapper.class);
        pgRef.getParameters().put('data', requestJSON);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, 'Running as expected');
        
        cFObj.fieldType = 'sing';
        cFList.add(cFObj);
        cFJSON = JSON.serialize(cFList);
        requestJSON = '{"peopleId":"' + currentPeople.Id + '","timeZone":"Asia/Kolkata","customUserFieldList":' + cFJSON + '}';    
        profileWrapper = (MySettingsWrapper.ProfileWrapper)Json.deserialize(requestJSON, MySettingsWrapper.ProfileWrapper.class);
        pgRef.getParameters().put('data', requestJSON);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, 'Running as expected');
        
        SimpplrContext.PDSSourceApplication = 'none';
        serverObj.handleRequest(); 
        System.assertEquals('success', serverObj.response.status, 'Running as expected');
     
        SimpplrContext.isSegmentsEnabled = true; 
        UserContext.isUserAppModerator = true;
        requestJSON = '{"peopleId":"' + poepleObj.Id + '","timeZone":"Asia/Kolkata","customUserFieldList":' + cFJSON + '}';
        pgRef.getParameters().put('data', requestJSON);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, 'Running as expected');
        Test.stopTest();
    }

        @isTest static void testSaveProfileSettingsWithLocation() {
        Test.startTest();
        init();
        PageReference pgRef = Page.DataServerRW;
        MySettingDataServer serverObj = new MySettingDataServer();
    	pgRef.getParameters().put('target','MySettingDataServer');
        Test.setCurrentPage(pgRef);
        SimpplrContext.isPPTimezoneDisplay = true;
        SimpplrContext.isPPTimezoneEditable = true;
        SimpplrContext.isPPManagerEditable = true;
        SimpplrContext.PDSSourceApplication = 's';
        Simpplrcontext.isPPCityEditable = true;
        SimpplrContext.isPPCityDisplay = true;
        SimpplrContext.isPDSCity = false;
        SimpplrContext.locationNormalizationEnabled = true;
        UserContext.isUserAppModerator = false;
        People__c currentPeople = [select id from people__c where user__c=:UserInfo.getUserId()];
        pgRef.getParameters().put('action', 'saveProfileSettings');
        pgRef.getParameters().put('data', '{"peopleId":"' + currentPeople.Id + '", "city":"Mumbai", "timeZone":"Asia/Kolkata"}');
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/normalization/locations/validate-address',false));
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, 'Running as expected');       
        Test.stopTest();
    }

    @isTest static void testSaveEmailNotificationsSettings() {
        Test.startTest();
        PageReference pgRef = init();
        people__c peopleObj = getPeople('Simpplr_usr1');
        MySettingDataServer serverObj = new MySettingDataServer();
		People_Preference__c ppObj = TestHelper.createPeoplePreference(peopleObj.Id);
        App_Default__c appDefaultObj = TestHelper.setupAppDefault();
        pgRef.getParameters().put('action','saveEmailNotificationsSettings');
		pgRef.getParameters().put('data','{"peopleId":"'+peopleObj.id+'","emailSiteActionableForAppMgr":true,"topStoriesFrequency":"Never","siteAnalyticsFrequency":"monthly","emailUpdatesContentSitesFollow":true,"emailSubscriptionModeration":true,"emailSharesPostMade":true,"emailProductResearch":true,"emailPrivateSiteMembershipResponse":true,"emailPrivateSiteMembershipRequest":true,"emailPostsToMe":true,"emailNotificationFrequency":"Immediate","emailLikesSharesContentPublished":true,"emailLikesPostOrCommentMade":true,"emailKnowledgeReview":true,"emailKnowledgeExpired":true,"emailForContentUseful":true,"emailFollowsMe":true,"emailEventInviteMore":true,"emailEndorseExpertise":true,"emailContentSubmittedRejected":false,"emailContentSubmittedForModeration":true,"emailContentSubmittedApproved":false,"emailContentSubmissionResponse":true,"emailContentMarkedAsMustRead":true,"emailCommentsPostMade":true,"emailCommentsPostLike":true,"emailCommentsContentPublished":true,"emailCommentsAfterMe":true,"digestFrequency":"Daily","allowSimpplrEmails":"enable"}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, serverObj.response.message);
        
        UserContext.emailProductResearch = true;
        pgRef.getParameters().put('data','{"peopleId":"'+peopleObj.id+'","topStoriesFrequency":"Never","siteAnalyticsFrequency":"monthly","emailUpdatesContentSitesFollow":true,"emailSubscriptionModeration":true,"emailSharesPostMade":true,"emailProductResearch":false,"emailPrivateSiteMembershipResponse":true,"emailPrivateSiteMembershipRequest":true,"emailPostsToMe":true,"emailNotificationFrequency":"Immediate","emailLikesSharesContentPublished":true,"emailLikesPostOrCommentMade":true,"emailKnowledgeReview":true,"emailKnowledgeExpired":true,"emailForContentUseful":true,"emailFollowsMe":true,"emailEventInviteMore":true,"emailEndorseExpertise":true,"emailContentSubmittedRejected":false,"emailContentSubmittedForModeration":true,"emailContentSubmittedApproved":false,"emailContentSubmissionResponse":true,"emailContentMarkedAsMustRead":true,"emailCommentsPostMade":true,"emailCommentsPostLike":true,"emailCommentsContentPublished":true,"emailCommentsAfterMe":true,"digestFrequency":"Daily","allowSimpplrEmails":"enable"}');
		Test.setCurrentPage(pgRef);
        //serverObj.handleRequest();
        //System.assertEquals('success', serverObj.response.status, serverObj.response.message);
        
        Test.stopTest();
    }

    @isTest static void testSaveNativeMobileAppNotificationsSettings() {
  
        PageReference pgRef = init();
        people__c peopleObj = getPeople('Simpplr_usr1');
        update peopleObj;
        MySettingDataServer serverObj = new MySettingDataServer();
        pgRef.getParameters().put('action', 'saveNativeMobileAppNotificationsSettings');
        pgRef.getParameters().put('data', '{"peopleId":"' + peopleObj.Id + '","mobileAppFollowsMe":true,"mobileAppLikesPostOrCommentMade":true,"mobileAppCommentsPostMade":true,"mobileAppCommentsContentPublished":true,"mobileAppPostsToMe":true,"mobileAppLikesOrSharesContentPublished":true,"mobileAppUpdatesContentSitesFollow":true,"mobileAppEventInviteMore":true,"mobileAppContentSubmittedForModeration":true,"mobileAppPrivateSiteMembershipRequest":true}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, serverObj.response.message);
    }

    @isTest static void testSaveMobileNoOnProfileSettings() {
  
        PageReference pgRef = init();
        people__c peopleObj = getPeople('Simpplr_usr1');
        update peopleObj;
        MySettingDataServer serverObj = new MySettingDataServer();
        pgRef.getParameters().put('action', 'saveMobileNoOnProfileSettings');
        pgRef.getParameters().put('data', '{"peopleId":"' + peopleObj.Id + '","mobile":"9999999999"}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, serverObj.response.message);
    }

    @isTest static void testSaveUserWebPushConfig() {
  
        PageReference pgRef = init();
        people__c peopleObj = getPeople('Simpplr_usr1');
        update peopleObj;
        MySettingDataServer serverObj = new MySettingDataServer();
        pgRef.getParameters().put('action', 'saveUserWebPushConfig');
        pgRef.getParameters().put('data','{"peopleId":"' + peopleObj.Id + '","notificationOpted":"false","webPushToken":"token","userAgent":"userAgent"}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, serverObj.response.message);
    }

    @isTest static void testSaveSMSNotificationsSettings() {
        PageReference pgRef = init();
        people__c peopleObj = getPeople('Simpplr_usr1');
        MySettingsWrapper.SMSNotificationsWrapper notificationWrapper = new MySettingsWrapper.SMSNotificationsWrapper();
        notificationWrapper.peopleId = peopleObj.id;
        notificationWrapper.smsAlerts = true;
        notificationWrapper.smsContentMarkedAsMustRead = true;
        notificationWrapper.smsContentPromotionMessage = true;
        string str = JSON.serialize(notificationWrapper);
        MySettingDataServer serverObj = new MySettingDataServer();
        pgRef.getParameters().put('action', 'saveSMSNotificationsSettings');
        pgRef.getParameters().put('data', str);
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, serverObj.response.message);
    }

    @isTest static void testSaveAppManagerNotificationsSettings() {
        
    	PageReference pgRef = init();
        people__c peopleObj = getPeople('Simpplr_usr1');
        update peopleObj;
        MySettingDataServer serverObj = new MySettingDataServer();
        pgRef.getParameters().put('action', 'saveAppManagerNotificationsSettings');
        pgRef.getParameters().put('data','{"peopleId":"' + peopleObj.Id + '","appManagerUsefulContentNotifications":true,"appManagerUpdateContentNotifications":false,"appManagerNotifications":true}');
    	Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, serverObj.response.message);
    }
    
    @isTest static void testSaveMobileAppNotificationsSettings() {
        
    	PageReference pgRef = init();
        people__c peopleObj = getPeople('Simpplr_usr1');
        update peopleObj;
        MySettingDataServer serverObj = new MySettingDataServer();
        pgRef.getParameters().put('action','saveMobileAppNotificationsSettings');
        pgRef.getParameters().put('data','{"peopleId":"' + peopleObj.Id + '","mobileAppUpdatesContentSitesFollow":true,"mobileAppSharesPostMade":true,"mobileAppPrivateSiteMembershipResponse":true,"mobileAppPrivateSiteMembershipRequest":true,"mobileAppPostsToMe":true,"mobileAppNotifications":true,"mobileAppLikesPostOrCommentMade":true,"mobileAppLikesOrSharesContentPublished":true,"mobileAppFollowsMe":true,"mobileAppEventInviteMore":true,"mobileAppEndorseExpertise":false,"mobileAppContentUseful":true,"mobileAppContentSubmittedRejected":true,"mobileAppContentSubmittedForModeration":true,"mobileAppContentSubmittedApproved":true,"mobileAppContentSubmissionResponse":true,"mobileAppContentMarkedAsMustRead":true,"mobileAppCommentsPostMade":true,"mobileAppCommentsPostLike":true,"mobileAppCommentsContentPublished":true,"mobileAppCommentsAfterMe":true}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, serverObj.response.message);
    }
    
    static void externalApp(string name){
        people__c peopleObj = getPeople('Simpplr_usr1');
        App_Integration__c appInteg = new App_Integration__c();
        appInteg.Name = name;
        appInteg.Integration_Enabled__c = true;
        appInteg.Connected__c = true;
        appInteg.Client_Id__c = 'Devops';
        appInteg.Client_Secret__c ='Salesforce';
        appInteg.Is_Deleted__c = false;
        appInteg.Org_Id__c = UserInfo.getOrganizationId();
        insert appInteg;
         
        People_Integration__c ppl = new People_Integration__c();
        ppl.Is_Deleted__c = false;
        ppl.App_Integration__c = appInteg.id;
        ppl.People__c = peopleObj.id;
        insert ppl;

    }
    
     @isTest static void testGetExternalAppsSettingsforlinkedin() {
        PageReference pageRef = Page.DataServerRW;
        MySettingDataServer SettingDSObject = new MySettingDataServer();
        pageRef.getParameters().put('target','MySettingDataServer');
        people__c peopleObj = getPeople('Simpplr_usr1');
        update peopleObj;
        pageRef.getParameters().put('action','getExternalAppsSettings');
        pageRef.getParameters().put('peopleId',peopleObj.Id); 
        Test.setCurrentPage(pageRef);
           
        externalApp('linkedin');
        Test.setCurrentPage(pageRef);
        Test.startTest();
      	Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/manage-slack-info',false));
        SettingDSObject.handleRequest();
        System.assertEquals('success', SettingDSObject.response.status, SettingDSObject.response.message);
        Test.stopTest();
     }
    
    @isTest static void testGetExternalAppsSettingsforservicenow() {
        PageReference pageRef = Page.DataServerRW;
        MySettingDataServer SettingDSObject = new MySettingDataServer();
        pageRef.getParameters().put('target','MySettingDataServer');
        people__c peopleObj = getPeople('Simpplr_usr1');
        update peopleObj;
        pageRef.getParameters().put('action','getExternalAppsSettings');
        pageRef.getParameters().put('peopleId',peopleObj.Id); 
        Test.setCurrentPage(pageRef);
           
        externalApp('servicenow');
        Test.setCurrentPage(pageRef);
        Test.startTest();
      	Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/manage-slack-info',false));
        SettingDSObject.handleRequest();
        System.assertEquals('success', SettingDSObject.response.status, SettingDSObject.response.message);
        Test.stopTest();
     }
    
    @isTest static void testGetExternalAppsSettingsforfacebook() {
        
        PageReference pageRef = Page.DataServerRW;
        MySettingDataServer SettingDSObject = new MySettingDataServer();
        pageRef.getParameters().put('target','MySettingDataServer');
        people__c peopleObj = getPeople('Simpplr_usr1');
        update peopleObj;
        pageRef.getParameters().put('action','getExternalAppsSettings');
        pageRef.getParameters().put('peopleId',peopleObj.Id);
        Test.setCurrentPage(pageRef);
           
        externalApp('facebook');
        Test.setCurrentPage(pageRef);
        Test.startTest();
      	Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/manage-slack-info',false));
        SettingDSObject.handleRequest();
        System.assertEquals('success', SettingDSObject.response.status, SettingDSObject.response.message);
        Test.stopTest();  
     }
    
    @isTest static void testGetExternalAppsSettingsadsi() {
        PageReference pageRef = Page.DataServerRW;
        MySettingDataServer SettingDSObject = new MySettingDataServer();
        pageRef.getParameters().put('target','MySettingDataServer');
        people__c peopleObj = getPeople('Simpplr_usr1');
        update peopleObj;
        pageRef.getParameters().put('action','getExternalAppsSettings');
        pageRef.getParameters().put('peopleId',peopleObj.Id); 
        Test.setCurrentPage(pageRef);
           
        externalApp('adsi');
        Test.startTest();
      	Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/manage-slack-info',false));
        SettingDSObject.handleRequest();
        System.assertEquals('success', SettingDSObject.response.status, SettingDSObject.response.message);
        Test.stopTest();  
     }
    
    @isTest static void testGetExternalAppsSettingsforsalesforce() {
        PageReference pageRef = Page.DataServerRW;
        MySettingDataServer SettingDSObject = new MySettingDataServer();
        pageRef.getParameters().put('target','MySettingDataServer');
        people__c peopleObj = getPeople('Simpplr_usr1');
        update peopleObj;
        pageRef.getParameters().put('action','getExternalAppsSettings');
        pageRef.getParameters().put('peopleId',peopleObj.Id); 
        Test.setCurrentPage(pageRef);
           
        externalApp('salesforce');
        Test.startTest();
      	Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/manage-slack-info',false));
        SettingDSObject.handleRequest();
        System.assertEquals('success', SettingDSObject.response.status, SettingDSObject.response.message);
        Test.stopTest();  
     }
    
    @isTest static void testGetExternalAppsSettingsforslack() {
        PageReference pageRef = Page.DataServerRW;
        MySettingDataServer SettingDSObject = new MySettingDataServer();
        pageRef.getParameters().put('target','MySettingDataServer');
        people__c peopleObj = getPeople('Simpplr_usr1');
        update peopleObj;
        pageRef.getParameters().put('action','getExternalAppsSettings');
        pageRef.getParameters().put('peopleId',peopleObj.Id); 
        Test.setCurrentPage(pageRef);
           
        externalApp('slack');
        List<People_Integration__c> pplList = [SELECT Id, Name FROM People_Integration__c WHERE People__c =: peopleObj.id LIMIT 1];
        pplList[0].Name = 'slackContentShare';
        update pplList;
        Test.setCurrentPage(pageRef);
        Test.startTest();
      	Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/manage-slack-info',false));
        SimpplrContext.isSlackPhase2FeatureEnabled = false;
        SettingDSObject.handleRequest();
        
        SimpplrContext.isSlackPhase2FeatureEnabled = true;
        SimpplrContext.isSlackUpgraded = true;
        pplList[0].Name = 'slack';
        update pplList;
        SettingDSObject.handleRequest();
        System.assertEquals('success', SettingDSObject.response.status, SettingDSObject.response.message);
        Test.stopTest(); 
     }
    
    @isTest static void testGetExternalAppsSettingsforsharepoint() {
		PageReference pageRef = Page.DataServerRW;
        MySettingDataServer SettingDSObject = new MySettingDataServer();
        pageRef.getParameters().put('target','MySettingDataServer');
        people__c peopleObj = getPeople('Simpplr_usr1');
        update peopleObj;
        pageRef.getParameters().put('action','getExternalAppsSettings');
        pageRef.getParameters().put('peopleId',peopleObj.Id); 
        Test.setCurrentPage(pageRef);
           
        externalApp('sharepoint');
        Test.startTest();
      	Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/manage-slack-info',false));
        SettingDSObject.handleRequest();
        System.assertEquals('success', SettingDSObject.response.status, SettingDSObject.response.message);
        Test.stopTest();  
     }
    
    @isTest static void testGetExternalAppsSettingsforonedrive() {
        
        PageReference pageRef = Page.DataServerRW;
        MySettingDataServer SettingDSObject = new MySettingDataServer();
        pageRef.getParameters().put('target','MySettingDataServer');
        people__c peopleObj = getPeople('Simpplr_usr1');
        pageRef.getParameters().put('action','getExternalAppsSettings');
        pageRef.getParameters().put('peopleId',peopleObj.Id); 
        Test.setCurrentPage(pageRef);
           
        externalApp('onedrive');  
        SimpplrContext.IsBoxIntegrationEnabled = true;
        SimpplrContext.BoxUsername = 'saleforce';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'/manage-slack-info',true));
        SettingDSObject.handleRequest();    
        System.assertEquals('success', SettingDSObject.response.status, SettingDSObject.response.message);
		Test.stopTest();  
     }
    
    @isTest static void testGetExternalAppsSettingsforMicrosoftTeamsConnected() {
        PageReference pageRef = Page.DataServerRW;
        MySettingDataServer SettingDSObject = new MySettingDataServer();
        pageRef.getParameters().put('target','MySettingDataServer');
        people__c peopleObj = getPeople('Simpplr_usr1');
        update peopleObj;
        pageRef.getParameters().put('action','getExternalAppsSettings');
        pageRef.getParameters().put('peopleId',peopleObj.Id); 
        Test.setCurrentPage(pageRef);
           
        externalApp('microsoftteams');
        List<People_Integration__c> pplList = [SELECT Id, Name FROM People_Integration__c WHERE People__c =: peopleObj.id LIMIT 1];
        pplList[0].Name = 'microsoftteams';
        update pplList;
        
        Test.setCurrentPage(pageRef);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/manage-slack-info',false));
        SettingDSObject.handleRequest();
        System.assertEquals('success', SettingDSObject.response.status, SettingDSObject.response.message);
        Test.stopTest(); 
     }
    
     @isTest static void testGetExternalAppsSettingsforMicrosoftTeamsDisconnected() {
        PageReference pageRef = Page.DataServerRW;
        MySettingDataServer SettingDSObject = new MySettingDataServer();
        pageRef.getParameters().put('target','MySettingDataServer');
        people__c peopleObj = getPeople('Simpplr_usr1');
        update peopleObj;
        pageRef.getParameters().put('action','getExternalAppsSettings');
        pageRef.getParameters().put('peopleId',peopleObj.Id); 
        Test.setCurrentPage(pageRef);
           
        externalApp('microsoftteams');
        Test.setCurrentPage(pageRef);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/manage-slack-info',false));
        SettingDSObject.handleRequest();
        System.assertEquals('success', SettingDSObject.response.status, SettingDSObject.response.message);
        Test.stopTest(); 
     }
    

}