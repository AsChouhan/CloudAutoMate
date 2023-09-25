public without sharing class BatchAlertNotifications implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    

    private static final String KEY_SMS_ALERT_EVERYONE = 'push.notification.alert.everyone';
    private static final String KEY_SMS_ALERT_AUDIENCE = 'push.notification.alert.saved_audience';
    private static final String KEY_SMS_ALERT_SITE = 'push.notification.alert.site_members';
    private static final String KEY_SMS_ALERT_SITE_MEMBERS_FOLLOWERS = 'push.notification.alert.site_members_followers';
    private static final String KEY_SMS_ALERT_SEGMENT = 'push.notification.alert.segment';

	private static final String KEY_EMAIL_ALERT_SUBJECT = 'email.notification.alert.subject';
    private static final String KEY_EMAIL_ALERT_INTRO = 'email.notification.alert.intro';
    private static final String KEY_EMAIL_ALERT_ALL_ORGANIZATION = 'email.notification.alert.all_organization';
    private static final String KEY_EMAIL_ALERT_SHARED_WITH_SITE = 'email.notification.alert.shared_with_site';
    private static final String KEY_EMAIL_ALERT_SHARED_WITH_AUDIENCE = 'email.notification.alert.shared_with_audience';
    private static final String KEY_EMAIL_GO_TO_SIMPPLR_BTN = 'email.common.go_to_simpplr';
    private static final String KEY_EMAIL_HI = 'email.common.salutation';
    public static final String KEY_FOOTER_SETTINGS = 'email.common.footer.settings';
	public static final String KEY_COPYRIGHT_TEXT = 'email.common.footer.copyright';
	public static final String KEY_POWERED_BY = 'email.common.footer.powered_by';

    public static Map<String,String> alertPartMap = new Map<String,String>{
		'emailTemplateWithHeaderFooterWithNoSettings' => '<!doctype html> <html> <head> <meta charset="utf-8"> <meta content="width=device-width, initial-scale=1.0" name="viewport"> <meta content="text/html" http-equiv="Content-Type"> <meta content="telephone=no" name="format-detection"> {7} <title>Email Notification</title> </head> <body class="" style="-ms-text-size-adjust: 100%; -webkit-font-smoothing: antialiased; -webkit-text-size-adjust: 100%; background-color: #f6f6f6; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; height: 100% !important; line-height: 1.4; margin: 0; padding: 0; width: 100% !important;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" class="body" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #f6f6f6; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> </td> <td class="container" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; display: block; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; margin: 0 auto !important; max-width: 580px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 10px; text-align: left; vertical-align: top; width: 580px;"> <div class="content" style="-moz-box-sizing: border-box; box-sizing: border-box; display: block; margin: 0 auto; max-width: 580px; padding: 10px;"> <!-- START CENTERED WHITE CONTAINER --> <table role="presentation" class="main" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background: #ffffff; border-collapse: collapse !important; border-radius: 4px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <!-- START HEADER --> <tr> <td class="header" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;background: #{10}; border-bottom: 1px solid #eeeeee; border-collapse: collapse; border-radius: 4px 4px 0 0; box-sizing: border-box; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px; text-align: left; vertical-align: top;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <img height="31" class="logo" src="{0}" style="-ms-interpolation-mode: bicubic; border: 0; display: block; height: auto; max-height: 31px; max-width: 100%; outline: 0; text-decoration: none; width: auto;"> </td> <td class="align-right align-middle" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: right; vertical-align: middle;"> <span class="date" style="color: #c5c5c5; font-size: 12px; font-weight: normal;">{1}</span> </td> </tr> </table> </td> </tr> <!-- END HEADER --> <!-- START MAIN CONTENT AREA --> {2} <!-- END MAIN CONTENT AREA --> </table> <!-- START FOOTER --> {9}<div class="footer" style="clear: both; margin-top: 10px; text-align: center; width: 100%;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td class="content-block" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 12px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: center; vertical-align: top;"> <a href="{8}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999999; font-size: 12px; text-align: center; text-decoration: underline;"> {3} </a> <br>{4} </td> </tr> <tr> <td class="content-block powered-by" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 12px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: center; vertical-align: top;"> {5} <a href="{6}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999999; font-size: 12px; text-align: center; text-decoration: none;">Simpplr</a>. </td> </tr><tr><td><img src={11}{12} width="1" height="1" alt="Simpplr" style="display:none";/></td></tr> </table> </div> <!-- END FOOTER --> <!-- END CENTERED WHITE CONTAINER --> </div> </td> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> </td> </tr> </table> </body> </html>'
	  };
    
    public NotificationHelper.BrandingInfo brandingInfo;
    public Boolean isSimpplrEmailEnabled;
    public Boolean isCalledFromScheduler;
    public String logoUrl;
    public Datetime alertScheduledDate;
    private Alert__c alertObj;
    private String alertId;
    private String packageName;
    private Integer batchNumber = 1;
    private String audienceId;
    private String audienceName;
    private String segmentId;
    private String segmentName;
    private String siteId;
    public String siteName;
    private String chatterGroupId;
    private String membersType;
    App_Config__c appConfig ;
    
    private Exception exceptionDetailsObj;
    
    public BatchAlertNotifications(String alertId,Datetime currentHourTime,Boolean isCalledFromScheduler) {
        this.alertId = alertId;      
        Map<String, Object> soqlParamMap = new  Map<String, Object>();
        soqlParamMap.put('soqlParam1', alertId);
        String query = 'SELECT Id, Audience__c, Members_Type__c , Notification_Sent__c, External_Apps_Config_Json__c, Audience__r.Name__c, Recipient__c, Recipient_Site__c, Recipient_Site__r.Chatter_Group_Id__c,Recipient_Site__r.name, Audience__r.Segment__c, Audience__r.Segment__r.Name__c, Alert_Message__c,Alert_Url__c,Is_Link_Alert__c '
                            + ' FROM Alert__c WHERE Id = :soqlParam1';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
        this.alertObj = ((List<Alert__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap))[0];
        this.audienceId = this.alertObj.Audience__c;
        this.audienceName = this.alertObj.Audience__r.Name__c;
        this.chatterGroupId = this.alertObj.Recipient_Site__r.Chatter_Group_Id__c;
        this.siteName = this.alertObj.Recipient_Site__r.name;
        this.segmentId = this.alertObj.Audience__r.Segment__c;
        this.segmentName = this.alertObj.Audience__r.Segment__r.Name__c;
        this.isCalledFromScheduler = isCalledFromScheduler;
        this.alertScheduledDate = currentHourTime;
        this.membersType = this.alertObj.Members_Type__c;
        this.siteId = this.alertObj.Recipient_Site__c;

        String appConfigQuery = 'Select Simpplr_Emails_Allowed__c, Simpplr_Mobile_Notification_Allowed__c,Package_Name__c,Branding_JSON__c,Branding_Logo__c from App_Config__c Limit 1 ';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		appConfig = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];

        brandingInfo = new NotificationHelper.BrandingInfo();
        isSimpplrEmailEnabled = appConfig.Simpplr_Emails_Allowed__c;
    }

    public database.querylocator start(Database.BatchableContext bc) {
        packageName = SimpplrContext.packageName;
        String query =  ' Select Id, Mobile_Token_Android__c, Mobile_Token_iOS__c, New_Notification_Count__c, User__r.languagelocalekey,User_Hash__c, ' +
                        ' Mobile_FCM_ID_Android__c, Mobile_Bundle_ID_Android__c, Mobile_FCM_ID_iOS__c, Mobile_Bundle_ID_iOS__c, ' +
                        ' Mobile_App_Type_Android__c, Mobile_App_Type_iOS__c,user__r.userName,Last_Name__c,First_Name__c, Mobile_Phone__c, Segment__c, Segment__r.Branding_JSON__c, ' + 
                        ' Segment__r.Branding_Logo__c FROM People__c WHERE User__r.isActive=true AND User__r.UserType=\'Standard\' ' ;
                        
		
		if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
    		query += ' AND User__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: packageName) ';
    	}

        if(alertObj.Recipient__c == 'everyone') {
            //Do nothing
        
        } else if(alertObj.Recipient__c == 'audience') {
            query += ' AND User__c in (Select User__c from Audience_Member__c WHERE Audience__c=:audienceId) ';
        } else if(alertObj.Recipient__c == 'site') {
            query += ' AND User__c in (Select MemberId from CollaborationGroupMember where CollaborationGroupId=:chatterGroupId) ';
        } else if(alertObj.Recipient__c == 'segment') {
            query += ' AND Segment__c = :segmentId ';
        }

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, sObject[] listOfsObject) {
        try {
            List<People__c> peopleList = (List<People__c>)listOfsObject;
            if (siteId!=null && membersType=='site_members'){
                Map<String, People__c> peopleIdMap = new Map<String, People__c>();
                for (People__c people:peopleList ){
                    peopleIdMap.put(people.id, people);
                }
                List<people__c> peopleNewList = new List<people__c>();
                for (Site_Role__c siteRole: [Select id, people__c, site__c, is_Member__c from Site_Role__c where site__c = :siteId and people__c in:peopleIdMap.keySet() and is_Member__c=true AND Is_Deleted__c = false]){
                    if (peopleIdMap.containsKey(siteRole.people__c)){
                        peopleNewList.add(peopleIdMap.get(siteRole.people__c));
                    }
                }
                peopleList.clear();
                peopleList.addAll(peopleNewList);
            }
            initLangKeyValueMap(peopleList);
            sendPushNotification(peopleList);
            if(SimpplrContext.isSMSEnabled) {
                sendAlertSms(peopleList);
            }
            String msTenantQuery = 'select id, Microsoft_Teams_User_Id__c, Microsoft_Tenant_Id__c  from People__c where Microsoft_Tenant_Id__c != null LIMIT 1';
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
            List<People__c> mspeopleList  = ((List<People__c>)SIMPESAPI.accessController().queryAsUSer(msTenantQuery, null));
            
            if (String.isNotBlank(alertObj.External_Apps_Config_Json__c) && isCalledFromScheduler && !mspeopleList.isEmpty()) {
                AlertWrapper.ExternalAppsForAlert exAppDetail = (AlertWrapper.ExternalAppsForAlert)JSON.deserialize(alertObj.External_Apps_Config_Json__c, AlertWrapper.ExternalAppsForAlert.class);
                String simpUrl = SimpplrContext.salesforceBaseUrl + '/apex/' + SimpplrContext.namespacePrefix+ 'app';
                MicrosoftTeamsHelper msTeamsHelper = new MicrosoftTeamsHelper();
                if (exAppDetail.isMSTeamsPostAlertAsChannel && String.isNotBlank(exAppDetail.msTeamsTeamId) && String.isNotBlank(exAppDetail.msTeamsChannelId)) {
                    ContentWrapper.ContentSiteFeedWrapper contentWrapper = new ContentWrapper.ContentSiteFeedWrapper();
                    msTeamsHelper.promoteContentToChannel(exAppDetail.msTeamsTeamId, exAppDetail.msTeamsChannelId,  simpUrl, alertObj.Alert_Message__c, IntegrationConstants.POST_ALERT_TO_EXTERNAL_APP, mspeopleList[0].Microsoft_Tenant_Id__c, mspeopleList[0].Microsoft_Teams_User_Id__c,contentWrapper);
                    }
                if (exAppDetail.isMSTeamsPostAlertAsDM) {
                    msTeamsHelper.postAlertAsDM(simpUrl, alertObj.Alert_Message__c, alertObj.Recipient__c, alertObj.Members_Type__c, alertObj.Recipient_Site__c, alertObj.Audience__c, mspeopleList[0].Microsoft_Tenant_Id__c);    
                }
            }
    		if(isSimpplrEmailEnabled) {
            sendAlertEmailNotification(peopleList);
            }
            batchNumber = batchNumber + 1;

        } catch (Exception ex) {
            exceptionDetailsObj =  ex;
    		throw ex;
        }
    }    

    private void sendPushNotification(List<People__c> listOfPeople) {
        Set<String> localeSet = new Set<String>();
        set<Id> peopleIdSet = new set<Id>();
        List<People_Preference__c> peoplePreferenceList; 
        Map<Id,People_Preference__c> peoplePreferenceMap  = new Map<Id,People_Preference__c>();
        for(People__c peopleObj : listOfPeople) {
            peopleIdSet.add(peopleObj.id);
            localeSet.add(Utility.getSimpplrLanguageLocaleKey(peopleObj.User__r.languagelocalekey));
        }
        Map<String, Object> soqlParamMap = new  Map<String, Object>();
        soqlParamMap.put('soqlParam1', peopleIdSet);
        string query = '';
        if(String.isNotBlank(SimpplrContext.packageName) && SimpplrContext.isSandbox == false && !Test.isRunningTest()){
            soqlParamMap.put('soqlParam2', SimpplrContext.packageName);
            query = 'select Id, People__c, Allow_Browser_Notifications__c, Native_Mobile_Alerts__c, Browser_Alerts__c from People_Preference__c' +
                                    ' where People__c in:soqlParam1 AND people__r.User__r.IsActive=true  and people__r.User__r.UserType=\'Standard\''+
                                    'and (Native_Mobile_Alerts__c = true OR Browser_Alerts__c = true) and User__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: soqlParam2)';
        
        } else {
            query = 'select Id, People__c, Allow_Browser_Notifications__c, Native_Mobile_Alerts__c, Browser_Alerts__c from People_Preference__c' +
                                    ' where People__c in:soqlParam1 AND people__r.User__r.IsActive=true  and people__r.User__r.UserType=\'Standard\''+
                                    'and (Native_Mobile_Alerts__c = true OR Browser_Alerts__c = true)';
        }
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
        peoplePreferenceList = (List<People_Preference__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
        
        For(People_Preference__c preferenceObj:peoplePreferenceList){
            peoplePreferenceMap.put(preferenceObj.people__c,preferenceObj);
        }
        LocaleContext.getAllLabelMap('PushNotifications', new List<String>(localeSet));

        List<PushNotifcationWrapper> pushNotiListMobile = new List<PushNotifcationWrapper>();
        List<PushNotifcationWrapper> pushNotiListBrowser = new List<PushNotifcationWrapper>();
        
        for(People__c peopleObj : listOfPeople) {
            if(peoplePreferenceMap.containsKey(peopleObj.Id)) {
                String localeKey = Utility.getSimpplrLanguageLocaleKey(peopleObj.User__r.languagelocalekey);
                People_Preference__c peoplePrefObj = peoplePreferenceMap.get(peopleObj.Id);

                // prepare notification list for mobile push
                if(true == peoplePrefObj.Native_Mobile_Alerts__c) {
                    if('native'.equalsIgnoreCase(peopleObj.Mobile_App_Type_Android__c) && String.isNotBlank(peopleObj.Mobile_Token_Android__c) ){
                        PushNotifcationWrapper pushNotiAndroidObj = new PushNotifcationWrapper();
                        
                        if(alertObj.Recipient__c == 'everyone') {
                            pushNotiAndroidObj.notificationtext = LocaleContext.getLabel(localeKey, KEY_SMS_ALERT_EVERYONE)
                                                            .replace('{{message}} {{url}}', Utility.chompString(alertObj.Alert_Message__c, 100)); 
                        } else if(alertObj.Recipient__c == 'audience') {
                            pushNotiAndroidObj.notificationtext = LocaleContext.getLabel(localeKey, KEY_SMS_ALERT_AUDIENCE)
                                                            .replace('{{message}} {{url}}', Utility.chompString(alertObj.Alert_Message__c, 100));
                        } else if(alertObj.Recipient__c == 'site') {
                            if(alertObj.Members_Type__c == 'site_members') {
                                pushNotiAndroidObj.notificationtext = LocaleContext.getLabel(localeKey, KEY_SMS_ALERT_SITE)
                                                            .replace('{{message}} {{url}}', Utility.chompString(alertObj.Alert_Message__c, 100)).replace('{{siteName}}', siteName);
                            } else {
                                pushNotiAndroidObj.notificationtext = LocaleContext.getLabel(localeKey, KEY_SMS_ALERT_SITE_MEMBERS_FOLLOWERS)
                                                            .replace('{{message}} {{url}}', Utility.chompString(alertObj.Alert_Message__c, 100)).replace('{{siteName}}', siteName);
                            }
                        } else if(alertObj.Recipient__c == 'segment') {
                            pushNotiAndroidObj.notificationtext = LocaleContext.getLabel(localeKey, KEY_SMS_ALERT_SEGMENT)
                                                            .replace('{{message}} {{url}}', Utility.chompString(alertObj.Alert_Message__c, 100)).replace('{{segmentName}}', segmentName);
                        }

                        pushNotiAndroidObj.deviceToken = String.valueOf(peopleObj.Mobile_Token_Android__c);
                        pushNotiAndroidObj.deviceType = 'android';
                        pushNotiAndroidObj.appType = 'native';
                        pushNotiAndroidObj.notificationType = 'alert';
                        pushNotiAndroidObj.sentById = UserContext.peopleId;
                        pushNotiAndroidObj.isClickable = true;
                        pushNotiAndroidObj.isActionable = false;
                        pushNotiAndroidObj.badge = Integer.valueOf(peopleObj.New_Notification_Count__c);
                        pushNotiAndroidObj.sound = 'default';
                        pushNotiAndroidObj.fcmId = peopleObj.Mobile_FCM_ID_Android__c;
                        pushNotiAndroidObj.bundleId = peopleObj.Mobile_Bundle_ID_Android__c;
                        pushNotiListMobile.add(pushNotiAndroidObj);
                    }

                    if('native'.equalsIgnoreCase(peopleObj.Mobile_App_Type_IOS__c) && String.isNotBlank(peopleObj.Mobile_Token_IOS__c)) {
                        PushNotifcationWrapper pushNotiIOSObj = new PushNotifcationWrapper();

                        if(alertObj.Recipient__c == 'everyone') {
                            pushNotiIOSObj.notificationtext = LocaleContext.getLabel(localeKey, KEY_SMS_ALERT_EVERYONE)
                                                            .replace('{{message}} {{url}}', Utility.chompString(alertObj.Alert_Message__c, 100)); 
                        } else if(alertObj.Recipient__c == 'audience') {
                            pushNotiIOSObj.notificationtext = LocaleContext.getLabel(localeKey, KEY_SMS_ALERT_AUDIENCE)
                                                            .replace('{{message}} {{url}}', Utility.chompString(alertObj.Alert_Message__c, 100));
                        } else if(alertObj.Recipient__c == 'site') {
                            if(alertObj.Members_Type__c == 'site_members') {
                                pushNotiIOSObj.notificationtext = LocaleContext.getLabel(localeKey, KEY_SMS_ALERT_SITE)
                                                            .replace('{{message}} {{url}}', Utility.chompString(alertObj.Alert_Message__c, 100)).replace('{{siteName}}', siteName);
                            } else {
                                pushNotiIOSObj.notificationtext = LocaleContext.getLabel(localeKey, KEY_SMS_ALERT_SITE_MEMBERS_FOLLOWERS)
                                                            .replace('{{message}} {{url}}', Utility.chompString(alertObj.Alert_Message__c, 100)).replace('{{siteName}}', siteName);
                            }
                        } else if(alertObj.Recipient__c == 'segment') {
                            pushNotiIOSObj.notificationtext = LocaleContext.getLabel(localeKey, KEY_SMS_ALERT_SEGMENT)
                                                            .replace('{{message}} {{url}}', Utility.chompString(alertObj.Alert_Message__c, 100)).replace('{{segmentName}}', segmentName);
                        }
                        
                        pushNotiIOSObj.deviceToken = String.valueOf(peopleObj.Mobile_Token_IOS__c);
                        pushNotiIOSObj.deviceType = 'ios';
                        pushNotiIOSObj.appType = 'native';
                        pushNotiIOSObj.notificationType = 'alert';
                        pushNotiIOSObj.sentById = UserContext.peopleId;
                        pushNotiIOSObj.isClickable = true;
                        pushNotiIOSObj.isActionable = false;
                        pushNotiIOSObj.badge = Integer.valueOf(peopleObj.New_Notification_Count__c);
                        pushNotiIOSObj.sound = 'default';
                        pushNotiIOSObj.fcmId = peopleObj.Mobile_FCM_ID_iOS__c;
                        pushNotiIOSObj.bundleId = peopleObj.Mobile_Bundle_ID_iOS__c;
                        pushNotiListMobile.add(pushNotiIOSObj);
                    }
                }
                
                // prepare notification list for browser push
                if('Yes'.equalsIgnoreCase(peoplePrefObj.Allow_Browser_Notifications__c) && (true == peoplePrefObj.Browser_Alerts__c)) {
                    PushNotifcationWrapper pushNotiBrowserObj = new PushNotifcationWrapper();
                    
                    if(alertObj.Recipient__c == 'everyone') {
                        pushNotiBrowserObj.notificationtext = LocaleContext.getLabel(localeKey, KEY_SMS_ALERT_EVERYONE)
                                                        .replace('{{message}} {{url}}', Utility.chompString(alertObj.Alert_Message__c, 100)); 
                    } else if(alertObj.Recipient__c == 'audience') {
                        pushNotiBrowserObj.notificationtext = LocaleContext.getLabel(localeKey, KEY_SMS_ALERT_AUDIENCE)
                                                        .replace('{{message}} {{url}}', Utility.chompString(alertObj.Alert_Message__c, 100));
                    } else if(alertObj.Recipient__c == 'site') {
                        if(alertObj.Members_Type__c == 'site_members') {
                            pushNotiBrowserObj.notificationtext = LocaleContext.getLabel(localeKey, KEY_SMS_ALERT_SITE)
                                                        .replace('{{message}} {{url}}', Utility.chompString(alertObj.Alert_Message__c, 100)).replace('{{siteName}}', siteName);
                        } else {
                            pushNotiBrowserObj.notificationtext = LocaleContext.getLabel(localeKey, KEY_SMS_ALERT_SITE_MEMBERS_FOLLOWERS)
                                                        .replace('{{message}} {{url}}', Utility.chompString(alertObj.Alert_Message__c, 100)).replace('{{siteName}}', siteName);
                        }
                    } else if(alertObj.Recipient__c == 'segment') {
                        pushNotiBrowserObj.notificationtext = LocaleContext.getLabel(localeKey, KEY_SMS_ALERT_SEGMENT)
                                                        .replace('{{message}} {{url}}', Utility.chompString(alertObj.Alert_Message__c, 100)).replace('{{segmentName}}', segmentName);
                    }
                    pushNotiBrowserObj.url = String.isEmpty(alertObj.alert_url__c) ? PageContext.getPageURL(Pages.app)+'?u=/' : alertObj.alert_url__c;
                    pushNotiBrowserObj.title = SimpplrContext.applicationName;
                    pushNotiBrowserObj.notificationType = 'alert';
                    pushNotiBrowserObj.sentById = UserContext.peopleId;
                    pushNotiBrowserObj.sentToId = ((String)peopleObj.Id).substring(0, 15);
                    pushNotiBrowserObj.isClickable = true;
                    pushNotiBrowserObj.isActionable = false;
                    pushNotiBrowserObj.badge = Integer.valueOf(peopleObj.New_Notification_Count__c);
                    pushNotiBrowserObj.sound = 'default';
                    
                    pushNotiListBrowser.add(pushNotiBrowserObj);
                }
            }
        }

        if((pushNotiListMobile.size() > 0 || pushNotiListBrowser.size() > 0) && !test.isRunningTest()){    		
            String notiListJsonMobile = null;
            String notiListJsonBrowser = null;
            
            if( !pushNotiListMobile.isEmpty() ) {
                notiListJsonMobile = JSON.serialize(pushNotiListMobile);
            }
            if( !pushNotiListBrowser.isEmpty() ) {
                notiListJsonBrowser = JSON.serialize(pushNotiListBrowser);
            }

            Utility.sendPushNotifications(notiListJsonMobile, notiListJsonBrowser);
        }
       
    }
    @testVisible
    private void sendAlertSms(List<People__c> listOfPeople) {
        set<Id> peopleIdSet = new set<Id>();
        List<Map<String, String>> mobileLanguageMapList = new List<Map<String, String>>();
        Map<Id,People_Preference__c> peoplePreferenceMap  = new Map<Id,People_Preference__c>();
        for(People__c peopleObj : listOfPeople) {
            peopleIdSet.add(peopleObj.id);
        }
        Map<String, Object> soqlParamMap = new  Map<String, Object>();
        soqlParamMap.put('soqlParam1', peopleIdSet);
        String query = 'Select Id, People__c, SMS_Alerts__c From People_Preference__c Where People__c in:soqlParam1 AND SMS_Alerts__c=true';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
        List<People_Preference__c> peoplePreferenceList = (List<People_Preference__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
        for(People_Preference__c preferenceObj : peoplePreferenceList){
            peoplePreferenceMap.put(preferenceObj.people__c,preferenceObj );
        }
        
        for(People__c peopleObj : listOfPeople) {
            if(peopleObj.Mobile_Phone__c != NULL && peoplePreferenceMap.containsKey(peopleObj.id)) {
                Map<String, String> MobileVsLangMap = new Map<String, String>();
                MobileVsLangMap.put('people_id', peopleObj.id);
                MobileVsLangMap.put('mobile_number', peopleObj.Mobile_Phone__c);
                MobileVsLangMap.put('languageLocaleKey', Utility.getSimpplrLanguageLocaleKey(peopleObj.User__r.languagelocalekey).replace('_', '-'));
                mobileLanguageMapList.add(MobileVsLangMap);
            }
        }

        if(mobileLanguageMapList.size() > 0 ) {
			sendSms(mobileLanguageMapList);
		}
    }

    private ResponseWrapper sendSms (List<Map<String, String>> mobileLanguageMapList) {
        logger.logDebug('NotificationDataServer----sendSms----');
		String ALERT_SMS_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/notifications/sms-processor?utm_medium=sms&utm_source=sms_alert'; 
		ResponseWrapper response;
		Http httpObj = new Http();
		String simpplrDri = Utility.externalRequestAuthToken() + 
                ' ' + SimpplrContext.simpplrOrgId.substring(0, 15) +
                ' ' + UserContext.userId.substring(0, 15);
        HttpRequest req = new HttpRequest();
		req.setEndpoint(ALERT_SMS_ENDPOINT);
		
		Map<String, Object> requestBody = new Map<String, Object>();
		requestBody.put('mobileLanguageMapList', mobileLanguageMapList);
        requestBody.put('appName', SimpplrContext.applicationName);
        requestBody.put('alertMessage', alertObj.Alert_Message__c);
        requestBody.put('recipient', alertObj.Recipient__c);
        if(alertObj.Recipient__c == 'site') {
            requestBody.put('siteName', siteName);
            requestBody.put('memberType', alertObj.Members_Type__c);
        }
        if(alertObj.Recipient__c == 'segment') {
            requestBody.put('segmentName', segmentName);
        }
        requestBody.put('isLink', alertObj.Is_Link_Alert__c);
		requestBody.put('alert_id', alertObj.Id);
		requestBody.put('url', alertObj.Alert_Url__c);
		requestBody.put('sms_type', 'Alert');
		requestBody.put('batch_number', batchNumber);
		requestBody.put('sender_id', UserContext.peopleId);
		requestBody.put('org_id', SimpplrContext.simpplrOrgId.substring(0, 15));
        requestBody.put('releaseVersion', ServiceConstants.RELEASE_VERSION);
		req.setBody(Json.serialize(requestBody));
		req.setHeader('simpplr-dri', simpplrDri);
		
        req.setMethod('POST');

        HttpResponse res;
        String smsResponse;
        if (!test.isRunningTest()){
            res = httpObj.send(req);
            smsResponse = res.getBody();
        } else {
            smsResponse = '{"status":"200" }';
        }
		Map<String, Object> requestDataMap = (Map<String, Object>)JSON.deserializeUntyped(smsResponse);

		if (requestDataMap != null && requestDataMap.containsKey('status')) {

			if ('error'.equalsIgnoreCase((String)requestDataMap.get('status'))) {
				logger.logError('BatchAlertNotifications.sendSms()-------' + 'error'); 
			
			} else {
				logger.logError('BatchAlertNotifications.sendSms()-------' + 'success');
			}

		} else {
			logger.logError('BatchAlertNotifications.sendSms()-------' + 'error');
		}
		
		return response;
	}

    private void sendAlertEmailNotification(List<People__c> listOfPeople){
        String emailHeading = '';
        String subject = '';
        set<Id> peopleIdSet = new set<Id>();
        List<People_Preference__c> peoplePreferenceList; 
        Map<Id,People_Preference__c> peoplePreferenceMap  = new Map<Id,People_Preference__c>();
        List<Messaging.SingleEmailMessage> alertEmailList = new List<Messaging.SingleEmailMessage>();
        for(People__c peopleObj : listOfPeople) {
            peopleIdSet.add(peopleObj.id);
        }
        Map<String, Object> soqlParamMap = new  Map<String, Object>();
        soqlParamMap.put('soqlParam1', peopleIdSet);
        string query = '';
        if(String.isNotBlank(SimpplrContext.packageName) && SimpplrContext.isSandbox == false && !Test.isRunningTest()){
            soqlParamMap.put('soqlParam2', SimpplrContext.packageName);
            query = 'select id,People__c,Allow_Simpplr_Emails__c from People_Preference__c where People__c in:soqlParam1 AND Allow_Simpplr_Emails__c=true AND Email_Notification_Digest_Frequency__c=\'Immediate\' and people__r.User__r.IsActive=true  and people__r.User__r.UserType=\'Standard\' and Email_Alerts__c = true and User__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: soqlParam2)';
        } else {
            query = 'select id,People__c,Allow_Simpplr_Emails__c from People_Preference__c where People__c in:soqlParam1 AND Allow_Simpplr_Emails__c=true AND Email_Notification_Digest_Frequency__c=\'Immediate\' and people__r.User__r.IsActive=true  and people__r.User__r.UserType=\'Standard\' and Email_Alerts__c = true';
        }
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
        peoplePreferenceList = (List<People_Preference__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
        For(People_Preference__c preferenceObj:peoplePreferenceList){
            peoplePreferenceMap.put(preferenceObj.people__c,preferenceObj);
        }
        for(People__c peopleObj : listOfPeople) {
            if(peoplePreferenceMap.containsKey(peopleObj.id)){
                brandingInfo = EmailUtility.getBrandingInfo4People(peopleObj);
                String localeKey = Utility.getSimpplrLanguageLocaleKey(peopleObj.User__r.languagelocalekey);
                subject =      LocaleContext.getLabel(localeKey, KEY_EMAIL_ALERT_SUBJECT)
                            .replace('{{message}}', Utility.chompString(alertObj.Alert_Message__c, 100));


                emailHeading = LocaleContext.getLabel(localeKey, KEY_EMAIL_ALERT_INTRO)
                            .replace('{{appName}}', SimpplrContext.applicationName);
                String alertBody = getAlertHTMLEmailBody(emailHeading, alertObj, localeKey, peopleObj);

                Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
                singleMail.setTargetObjectId(peopleObj.User__c);
                singleMail.setSubject(subject);
                // singleMail.setReplyTo(ServiceConstants.EMAIL_NOTI_NOREPLY_ADDRESS);
                if(String.isNotBlank(SimpplrContext.SEDFromEmail)) {
                    singleMail.setOrgWideEmailAddressId(SimpplrContext.SEDFromEmail);
                }
                if(SimpplrContext.DeeplinkingEnabled) {
                    alertBody = EmailUtility.deeplinkedMailBody(alertBody);
                }
                
                singleMail.setHtmlBody(alertBody);
                singleMail.setCharset('UTF-8');
                singleMail.setUseSignature(false);
                singleMail.setSaveAsActivity(false);
                alertEmailList.add(singleMail);
            }
        }
        
        List<Messaging.SendEmailResult> results = new list<Messaging.SendEmailResult>();
        if(alertEmailList.size() > 0) {
        	 results = Messaging.sendEmail(alertEmailList);
        }

        
    }
    

    private String getAlertHTMLEmailBody(String heading, Alert__c alertObj,
						String localeKey, People__c peopleObj) {
                            
        String targetPeopleId = peopleObj.Id;
        String targetUserName = peopleObj.user__r.userName;
                    
        List<String> formatterList = new List<String>();

        String userName = peopleObj.Last_Name__c;
		if(String.isNotBlank(peopleObj.First_Name__c)){
			userName = peopleObj.First_Name__c;
        }
        
		formatterList.add(LocaleContext.getLabel(localeKey, KEY_EMAIL_HI)
                        .replace('{{firstName}}', userName));

        String alertLink = (String.isNotBlank(alertObj.Alert_Url__c)) ? alertObj.Alert_Url__c : '';
        String emailBodyAlert = EmailTemplateService.templatePartMap.get('alert');
        
        String uName = '';
        uName = UserContext.getCurrentUserInfo.Full_Name__c;

        formatterList.add(heading);//0
        // Start of 2
        if(alertObj.Recipient__c == 'everyone'){
            formatterList.add(LocaleContext.getLabel(localeKey, KEY_EMAIL_ALERT_ALL_ORGANIZATION)); 
        }else if(alertObj.Recipient__c == 'audience'){
            formatterList.add(LocaleContext.getLabel(localeKey, KEY_EMAIL_ALERT_SHARED_WITH_AUDIENCE));
            
        }else if(alertObj.Recipient__c == 'site'){
            formatterList.add(LocaleContext.getLabel(localeKey, KEY_EMAIL_ALERT_SHARED_WITH_SITE)
            .replace('{{siteName}}', siteName));            
        }else if(alertObj.Recipient__c == 'segment') {
            formatterList.add(LocaleContext.getLabel(localeKey, KEY_EMAIL_ALERT_ALL_ORGANIZATION));        
         
        }
        
        
        //End of 2
        
        if (String.isNotBlank(alertLink)){
            formatterList.add(''); //3
            alertLink = '<a href="'+ alertLink+'" style="cursor:pointer" >'+alertObj.Alert_Message__c+'</a>';
            formatterList.add(alertLink);//4
        } else {
            formatterList.add(alertObj.Alert_Message__c); //3
            formatterList.add('');//4  
        }
        formatterList.add(LocaleContext.getLabel(localeKey, KEY_EMAIL_GO_TO_SIMPPLR_BTN)
        .replace('{{appName}}', SimpplrContext.applicationName));//5
        formatterList.add(PageContext.getPageURL(Pages.app) +'?u=/'); //6
        emailBodyAlert = EmailUtility.format(emailBodyAlert, formatterList);

        formatterList.clear();

        return getEmailTemplateWithHeaderFooterWithNoSettings(targetUserName, targetPeopleId, emailBodyAlert, localeKey,alertObj,peopleObj);
        

    }

    private String getEmailTemplateWithHeaderFooterWithNoSettings(String targetUserName, String targetPeopleId, String emailBody, String localeKey,Alert__c alertObj,People__c peopleObj){
		String finalEmailWithTemplate = '';
		logoUrl = brandingInfo.logo_url;
		List<String> formatterList = new List<String>();
		String templateWithHeaderFooter = alertPartMap.get('emailTemplateWithHeaderFooterWithNoSettings');
		
		formatterList.add(logoUrl); //{0}
    	formatterList.add(LocaleContext.getLocalisedDateAsMMMMDDYYYY(DateTime.now(), localekey));//{1}
    	formatterList.add(emailBody);//{2}
    	formatterList.add(LocaleContext.getLabel(localekey, KEY_FOOTER_SETTINGS).replace('{{appName}}', SimpplrContext.applicationName));//{3}
		formatterList.add((LocaleContext.getLabel(localekey, KEY_COPYRIGHT_TEXT)).replace('{{year}}', String.valueOf(Date.today().year())));//{4} 
    	formatterList.add(LocaleContext.getLabel(localekey, KEY_POWERED_BY));//{5}
		formatterList.add('http://www.simpplr.com');//{6}
		formatterList.add('<style> @media all {.ExternalClass {width: 100%;}.ExternalClass,.ExternalClass p,.ExternalClass span,.ExternalClass font, .ExternalClass td,.ExternalClass div {line-height: 100%; }.apple-link a {color: inherit !important;font-family: inherit !important;font-size: inherit !important;font-weight: inherit !important; line-height: inherit !important; text-decoration: none !important;}}@media only screen and (max-width: 620px) {table[class=body] .wrapper,table[class=body] .header, table[class=body] .article { padding: 10px !important; } table[class=body] .content { padding: 0 !important; } table[class=body] .container {padding: 0 !important; width: 100% !important; }table[class=body] .main {border-left-width: 0 !important;border-radius: 0 !important;border-right-width: 0 !important;} table[class=body] .btn table {width: 100% !important;}table[class=body] .btn a {width: 100% !important; }table[class=body] .img-responsive {height: auto !important;max-width: 100% !important;width: auto !important; }td[class="mobile-hide"] {display: none; }.mobile-hide {display: none;} .wrapper,.header, .article { padding: 10px !important;} .content { padding: 0 !important;}.container {padding: 0 !important;width: 100% !important;}.main { border-left-width: 0 !important;border-radius: 0 !important; border-right-width: 0 !important;}.btn table { width: 100% !important;} .btn a { width: 100% !important; }.img-responsive { height: auto !important;max-width: 100% !important;width: auto !important;}} a[x-apple-data-detectors] {color: inherit !important;text-decoration: none !important;font-size: inherit !important;font-family: inherit !important; font-weight: inherit !important;line-height: inherit !important; }</style><!--[if (gte mso 9)|(IE)]> <style type="text/css"> table {border-collapse: collapse;} </style> <![endif]-->');//{7}
    	formatterList.add(BaseCtrl.salesForceBaseUrl + Page.PageRedirector.getUrl()+'?userId='+targetPeopleId+'&pageToRedirect='+Pages.MySettingsEmail+'&origin=ne');//{8}
		
		formatterList.add(EmailUtility.getMobilePromotionFooterDiv(localekey, targetPeopleId)); // mobile promotion footer
		
		// header background // 10
		if('dark'.equalsIgnoreCase(brandingInfo.header_preset)){
			formatterList.add('000000');
		} else if('primary'.equalsIgnoreCase(brandingInfo.header_preset)) {
			formatterList.add(brandingInfo.general_primaryColor);
		} else if('default'.equalsIgnoreCase(brandingInfo.header_preset)){
			formatterList.add('ffffff');
		} else {
			formatterList.add(brandingInfo.header_backgroundColor);
        }
        formatterList.add(SimpplrContext.simpplrAPIEndpoint+'/sneot?td='); //9
		formatterList.add(Utility.getNewsletterTrackerCode(alertObj.Id, peopleObj.User_Hash__c)+'&action=alert'); //10

		finalEmailWithTemplate = EmailUtility.format(templateWithHeaderFooter, formatterList);

		return finalEmailWithTemplate;
    }

    public static String getMobilePromotionFooterDiv(String localekey, String peopleId) {
		String footerMobilePromotionDiv = '';

		if (SimpplrContext.mobilePromotionEnabled) {
			String footerMobilePromotionPart = EmailTemplateService.commonPartMap.get('footerMobilePromotion');

			String pid = UserInfo.getOrganizationId().subString(0,15) + String.valueOf(peopleId).subString(0,15);  

			String KEY_FOOTER_PROMOTION_HEADING = 'email.common.footer.promotion_heading';
			String KEY_FOOTER_PROMOTION_TEXT = 'email.common.footer.promotion_text';
			
			List<String> formatterList = new List<String>();

			//{0} Promotion heading
			formatterList.add(LocaleContext.getLabel(localeKey, 
					KEY_FOOTER_PROMOTION_HEADING).replace('{{appName}}',
					SimpplrContext.applicationName));
			//{1} Promotion text 
			formatterList.add(LocaleContext.getLabel(localeKey, 
					KEY_FOOTER_PROMOTION_TEXT).replace('{{appName}}',
					SimpplrContext.applicationName));
			//{2} iOS APP LInk 
			formatterList.add(EmailConstants.MOBILE_PROMOTION_LINK + 'iOS&utm_source=email_footer&utm_term=' + pid);
			//{3} IOS badge 
			formatterList.add(EmailConstants.footerPromotionBadgeIOS.replace('{{locale}}',localeKey));
			//{4} Android app link 
			formatterList.add(EmailConstants.MOBILE_PROMOTION_LINK + 'android&utm_source=email_footer&utm_term=' + pid);
			//{5} Android badge 
			formatterList.add(EmailConstants.footerPromotionBadgeAndroid.replace('{{locale}}',localeKey));
			footerMobilePromotionDiv = EmailUtility.format(footerMobilePromotionPart, formatterList);
		}
		
		return footerMobilePromotionDiv;
    }
    public static void initLangKeyValueMap(List<People__c> PeopleList) {
        Set<String> localeSet = new Set<String>();
		for(People__c peopleObj : PeopleList){
			localeSet.add(Utility.getSimpplrLanguageLocaleKey(peopleObj.User__r.languagelocalekey));
		}
		LocaleContext.getAllLabelMap('EmailNotifications', new List<String>(localeSet));
    }

    public void finish(Database.BatchableContext BC) {
        List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
        
        alertObj.Notification_Sent__c=true;
        fieldList.add(Alert__c.Notification_Sent__c);

        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
  		SIMPESAPI.accessController().updateAsUser(alertObj, fieldList);

        if(isCalledFromScheduler){
            Map<String, Object> soqlParamMap = new  Map<String, Object>();
            soqlParamMap.put('soqlParam1', alertScheduledDate);
            String queryAlert  = ' SELECT id ,Is_Deleted__c,Notification_Sent__c,Display_From_DateTime__c, '+
							 'Display_To_DateTime__c FROM alert__c WHERE Display_From_DateTime__c=:soqlParam1 AND Notification_Sent__c = false AND Is_Deleted__c= false  LIMIT 1 '; 	
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
            List<Alert__c> alertList = (List<Alert__c>)SIMPESAPI.accessController().queryAsUSer(queryAlert, soqlParamMap);	
        
            if(!alertList.isEmpty()){
                BatchAlertNotifications job = new BatchAlertNotifications(alertList[0].id,alertScheduledDate,true);
                Database.executeBatch(job,500);
            }
        }
        
    }
}