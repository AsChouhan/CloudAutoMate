/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers. 
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
@isTest
private class NotificationDataServerTest {

    private static PageReference pgRef;
    private static NotificationDataServer serverObj;
    private static App_Config__c appConfigRecord;
    private static User testAdminUser;
    private static User testStandardUser;
    private static CollaborationGroup cgroup;
    private static CollaborationGroupMember memberRecord;
    private static Simpplr_Site__c testSite;


    private static void init(){
        pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','NotificationDataServer');
        Test.setCurrentPage(pgRef);

        appConfigRecord = TestHelper.setupAppConfig();
        serverObj = new NotificationDataServer();
    }

    private static User getUserRecord(String userId) {
        List<User> userList = [SELECT Id FROM User WHERE Id =: userId];
        return userList[0];
    }

    private static People__c getPeopleRecordForStandardUser() {
        if (testStandardUser == null) {
            testStandardUser = TestHelper.createUser('Simpplr_usr_stand', null, false);
        }
        People__c  peopleObj = [Select Id, Title__c, Street__c, State__c, Phone__c, Full_Name__c, User__c, Mobile_Phone__c, Manager__c, 
                                Last_Name__c, First_Name__c, Fax__c, Extension__c, Email__c, Department__c, Country__c, City__c 
                                From People__c where User__c = :testStandardUser.Id LIMIT 1];
        return peopleObj;
    }

    private static People__c getPeopleRecordForAdminUser() {
        User testAdminUser = getAdminUser();
        People__c  peopleObj = [Select Id, Title__c, Street__c, State__c, Phone__c, Full_Name__c, User__c, Mobile_Phone__c, Manager__c, 
                                Last_Name__c, First_Name__c, Fax__c, Extension__c, Email__c, Department__c, Country__c, City__c 
                                From People__c where User__c = :testAdminUser.Id LIMIT 1];
        return peopleObj;
    }

    private static Simpplr_Site__c getSiteRecord() {
        if (cgroup == null) {
            cgroup = TestHelper.createCollaborationGroup('Simpplr_Grp', 'Public');
        }
        
        if (testSite == null) {
            testSite = TestHelper.getSiteRecord(cgroup.Id);
        }

        return testSite;
    }

    private static User getAdminUser(){
        if (testAdminUser == null) {
            testAdminUser = TestHelper.createUser('Simpplr_usr_admin', null, true);
        }
        return testAdminUser;
    }

    private static Simpplr_Content__c createContent() {
        Simpplr_Content__c contentRec = new Simpplr_Content__c(
            Title__c='title',
            Text_Intro__c='Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam hendrerit lacus arcu', 
            Text_Main__c='Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam hendrerit lacus arcu',
            Text_Main_Continued__c='Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam hendrerit lacus arcu',
            Type__c='Page', 
            Summary_1__c='Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam hendrerit lacus arcu',
            Summary_2__c='Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam hendrerit lacus arcu',
            Status__c='Approved',
            Is_Deleted__c = false,
            Is_Must_Read__c = true,
            Primary_Author__c=getPeopleRecordForAdminUser().Id,
            Publish_Start_DateTime__c = DateTime.now(),
            Last_Edited_DateTime__c = DateTime.now(),
            Site__c=getSiteRecord().Id);
        
        TestHelper.createContent(contentRec, getAdminUser());
        return contentRec;
    }

    private static App_Notification__c getNotificationRecord() {
        People__c ppl = getPeopleRecordForAdminUser();
        App_Notification__c notificationObj = TestHelper.createSimpplrNotification('Dummy', ppl.Id, null, 'Like', null, null);
        notificationObj.Simpplr_Site__c = getSiteRecord().Id;
        update notificationObj;

        return notificationObj;
    }

    private static boolean testAction(String category, Integer count, Boolean isSnippet){
        App_Notification__c notificationObj = new App_Notification__c(); 
        notificationObj.submitter_comment__c = '10';
        notificationObj.Status__c = 'updated';
        notificationObj.category__c = category; 
        if(isSnippet){
            notificationObj.snippet__c = '1'; 
        }else{
            notificationObj.snippet__c = null; 
        }
        
        notificationObj.Action_Count__c = count;
        Boolean pageText = testActionLoop(notificationObj, 'page');
        Boolean blogpostText = testActionLoop(notificationObj, 'blogpost');
        Boolean albumText = testActionLoop(notificationObj, 'album');
        Boolean eventText = testActionLoop(notificationObj, 'event');
        
        if(pageText && blogpostText && albumText && eventText){
            return true;
        }
        
        return false;
    }
    
    private static boolean testActionLoop(App_Notification__c notificationObj, String type){
        
        while(notificationObj.Action_Count__c > 0) {
            String notificationText = notificationTextInApp(notificationObj, type);
            if(String.isBlank(notificationText)){
                return false;
            }
            notificationObj.Action_Count__c--;
        }
        
        return true;
    }

    private static String testGetNotificationTextSnippet(String category) {
        App_Notification__c notiObj = new App_Notification__c(Category__c= category, Snippet__c = 'Dummy Snippet', Status__c = 'approved');
        return testGetNotificationTextSnippet(notiObj);
    }
    
    private static String testGetNotificationTextSnippet(App_Notification__c notiObj) {
        return NotificationDao.getNotificationtext(notiObj, 'en_US', 'page', 'Dummy Content Title', 'file', 'Dummy Site Name', new Map<String, String>{UserContext.peopleId => UserContext.peopleName});
    }
    
    private static String testGetNotificationTextWOSnippet(String category) {
        App_Notification__c notiObj = new App_Notification__c(Category__c= category, Snippet__c = '', Status__c = 'approved');
        return  NotificationDao.getNotificationtext(notiObj, 'en_US', 'page', 'Dummy Content Title', 'file', 'Dummy Site Name', new Map<String, String>{UserContext.peopleId => UserContext.peopleName});
    }
    
    private static String notificationTextInApp(App_Notification__c notificationObj, String type) {
        return ObjectToWrapperAdapter.getInAppNotificationtext('en_US', notificationObj, 'Dummy Site Name', type, 'Dummy content title', 'file', 'approved');
    }

    private static String testGetNotificationTextCT(String contentType) {
        App_Notification__c notiObj = new App_Notification__c(Category__c= 'Content_Share', Snippet__c = 'Dummy Snippet', Status__c = 'approved');
        return NotificationDao.getNotificationtext(notiObj, 'en_US', contentType, 'Dummy Content Title', 'file', 'Dummy Site Name', new Map<String, String>{UserContext.peopleId => UserContext.peopleName});
    }
    
    private static String testGetNotificationTextMyCT(String contentType) {
        App_Notification__c notiObj = new App_Notification__c(Category__c= 'My_Content_Share', Snippet__c = 'Dummy Snippet', Status__c = 'approved');
        return NotificationDao.getNotificationtext(notiObj, 'en_US', contentType, 'Dummy Content Title', 'file', 'Dummy Site Name', null);
    }
    
    @isTest static void testNotification() {
        init();
        Simpplr_Site__c siteObj = getSiteRecord();
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        App_Notification__c notificationObj = TestHelper.createSimpplrNotification('Dummy', peopleObj.Id, null, 'Like', null, null);
        notificationObj.Simpplr_Site__c = siteObj.Id;
        update notificationObj;
        String param = '{"includeActioned":true,"nextPageToken":0,"size":4,"sortBy":"","filter":"All","since":"","offset":0, "peopleId":"'+String.valueOf(peopleObj.Id)+'", "siteId" : "' + String.valueOf(siteObj.Id) + '"}';
        Criteria.Notification notificationCriteriaObj = (Criteria.Notification)JSON.deserialize(param, Criteria.Notification.class);
        Test.startTest();
        ResponseWrapper response1 = serverObj.getAllNotifications(notificationCriteriaObj);
        System.assertEquals('success', response1.status,serverObj.response.message);
        
        notificationCriteriaObj.origin = 'mobile';
        ResponseWrapper response2 = serverObj.getAllNotifications(notificationCriteriaObj);
        System.assertEquals('success', response2.status,serverObj.response.message);
        
        pgRef.getParameters().put('action', 'search');
        pgRef.getParameters().put('data', '{"size":10,"markAsSeen":true,"filter":"activity","includeActioned":false,"nextPageToken":3,"includeFeedNotification":true}');
        serverObj.HandleRequest();
        Test.stopTest();

        System.assertEquals('success', serverObj.response.status,serverObj.response.message);
    }

    @isTest static void testMarkAllTypeAsSeen() {
        init();

        System.runAs(getAdminUser()) {
            Test.startTest();
            pgRef.getParameters().put('action', 'markAllTypeAsSeen');
            pgRef.getParameters().put('type', 'exception');
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status, serverObj.response.message);
            
            pgRef.getParameters().put('type', 'activity');
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status, serverObj.response.message);
            
            pgRef.getParameters().put('action', 'getNotificationMessage');
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status, serverObj.response.message);
            Test.stopTest();
        }
    }

    @isTest static void testSearchUngrouped() {
        init();
        System.runAs(getAdminUser()) {
            Test.startTest();
            TestHelper.createSimpplrUnGroupedNotifications(getPeopleRecordForAdminUser().Id);
            pgRef.getParameters().put('action', 'search');
            pgRef.getParameters().put('data', '{"size":10,"includeActioned":false}');
            
            serverObj.handleRequest();
            System.assertEquals('error', serverObj.response.status, 'search result failed');
            Test.stoptest();
        }
    }

    @isTest static void testMobilePromotionSms() {
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false));

        App_config__c appConfigObj = [SELECT Id, Branded_App_Distribution_Enabled__c FROM App_config__c LIMIT 1];
        appConfigObj.Branded_App_Distribution_Enabled__c = false;
        appConfigObj.Native_App_Enabled__c = true;
        update appConfigObj;

        Test.startTest();
        pgRef.getParameters().put('action', 'sendMobilePromotionLink');
        pgRef.getParameters().put('type', 'MOBILE_PROMOTION_PHONE');        
        pgRef.getParameters().put('mobileNumber', '9654435619');
        
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status,' MobilePromotion Sms failed ');
        
        pgRef.getParameters().put('type', 'MOBILE_PROMOTION_EMAIL');
        pgRef.getParameters().put('emailAddress', 'xyz@test.com');
        
        serverObj.handleRequest();
        System.assertEquals('error', serverObj.response.status, serverObj.response.message);
        Test.stopTest();
    }
    
    @isTest static void testUndefinedAction() {
        init(); 

        pgRef.getParameters().put('action', 'undefinedAction');
        pgRef.getParameters().put('data', '{}');
        Test.setCurrentPage(pgRef);
        
        Test.startTest();
        serverObj.handleRequest();
        Test.stopTest();
        
        System.assertEquals('error', serverObj.response.status,serverObj.response.message);
    }

    @isTest static void testCreateNotification() {
        init();
        Test.startTest();
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        User userObj = getUserRecord(UserInfo.getUserId());
        userObj.Email = 'test@email.com';
        update userObj;

        pgRef.getParameters().put('action', 'create');        
        pgRef.getParameters().put('data', '{"actionBy":"test@email.com", "propertyName":"Email","sentTo":"' + 'test@email.com' + '","sentBy":"' + 'test@email.com' + '","url":"https://simpplr.pbcpayroll.in/Pages/ESS1903.aspx?hash=IN0mRDbZON8fRsv481qnG9En4arlPDKzIJP8TMLrPKbC79GoH9Gc8Mrm9cyz89CmG1I","notificationType":"Actionable","comment":"{{fullName}} has submmitted leave request for approval"}');        
        
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, serverObj.response.message);
        
        App_Notification__c notification = TestHelper.createSimpplrNotification('Dummy', peopleObj.Id, null, 'Like', null, null);
        notification.Object_Type__c = 'External';
        update notification;
        pgRef.getParameters().put('action', 'markAsActioned'); 
        pgRef.getParameters().put('notificationId', notification.Id); 
        pgRef.getParameters().put('data', '{"actionBy":"test@email.com", "propertyName":"Email","actionAt":"2021-10-07T10:05:26.615Z"}');        
        serverObj.handleRequest();
        Test.stopTest();

        System.assertEquals('success', serverObj.response.status, serverObj.response.message);
    }
    
    @isTest static void testSearch() {
        init();

        Test.startTest();
        pgRef.getParameters().put('origin','mobile');
        pgRef.getParameters().put('action', 'search');
        pgRef.getParameters().put('data', '{"size":10,"includeActioned":false,"nextPageToken":3}');
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status,serverObj.response.message);
        
        pgRef.getParameters().put('action', 'search');
        pgRef.getParameters().put('data', '{"size":10,"includeActioned":false,"filter":"latest","nextPageToken":0}');
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status,serverObj.response.message);
        
        pgRef.getParameters().put('action', 'search');
        pgRef.getParameters().put('data', '{"size":10,"includeActioned":true,"nextPageToken":1}');
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status,serverObj.response.message);
        
        pgRef.getParameters().put('action', 'search');
        pgRef.getParameters().put('data', '{"size":10,"markAsSeen":true,"filter":"activity","includeActioned":false,"nextPageToken":3,"includeFeedNotification":true}');
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status,serverObj.response.message);
        Test.stoptest();
    }
    
    @isTest static void testMarkAllActivityNotificationAsRead() {
        init();
        Simpplr_Site__c priCollabGrp = getSiteRecord();
        TestHelper.shareSitesToAllPeople(new List<String>{priCollabGrp.Id});
        Simpplr_Content__c contentObj = createContent();
        TestHelper.createSimpplrNotification('Dummy', getPeopleRecordForAdminUser().Id, null, 'Like', contentObj.id, null);

        Test.startTest();
        pgRef.getParameters().put('action', 'markAllNonActionableAsRead');
        serverObj.handleRequest();
        Test.stopTest();

        System.assertEquals('success', serverObj.response.status, serverObj.response.message);
    }
    
    @isTest static void testMarkNotificationAsSeen() {
        init();
        Simpplr_Site__c priCollabGrp = getSiteRecord();
        TestHelper.shareSitesToAllPeople(new List<String>{priCollabGrp.Id});
        Simpplr_Content__c contentObj = createContent();
        TestHelper.createSimpplrNotification('Dummy', getPeopleRecordForAdminUser().Id, null, 'Like', contentObj.id, null);
        pgRef.getParameters().put('action', 'markAllTypeAsSeen');
        
        Test.startTest();
        serverObj.handleRequest();
        Test.stopTest();

        System.assertEquals('success', serverObj.response.status, serverObj.response.message);
    }
    
    @isTest 
    static void testNotificationTextCategory1() {
        init();
        LocaleContext.getLabelMap('PushNotifications', 'en_US');
        String notificationText;
        Boolean result = false;
        System.runAs(getAdminUser()) {
            Test.startTest();
            //Comments Notification texts
            notificationText = testGetNotificationTextSnippet('Comments_After_Me');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Comments_After_Me');
            System.assert(notificationText != null , 'notification text not returned');
            
            // #################################### Comments_After_Me END ##################################### 
            notificationText = testGetNotificationTextSnippet('Comments_On_My_Post');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Comments_On_My_Post');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Comments_On_My_Post', 5, false);
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Comments_On_My_Post', 5, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Comments_On_My_Post ###################################### 
            notificationText = testGetNotificationTextSnippet('Comments_On_My_Content_Post');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Comments_On_My_Content_Post');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Comments_On_My_Content_Post', 5, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Comments_On_My_Content_Post ###################################### 
            notificationText = testGetNotificationTextSnippet('Comments_On_Post_I_Like');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Comments_On_Post_I_Like');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Comments_On_Post_I_Like', 1, false);
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Comments_On_Post_I_Like', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            Test.stopTest();
        }
    }
    
    @isTest 
    static void testNotificationTextCategory2() {
        init();
        LocaleContext.getLabelMap('PushNotifications', 'en_US');
        String notificationText;
        Boolean result = false;
        
        System.runAs(getAdminUser()) {
            Test.startTest();
            notificationText = testGetNotificationTextSnippet('Album_Submitted_For_Moderation');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Album_Submitted_For_Moderation');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Album_Submitted_For_Moderation', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Album_Submitted_For_Moderation ###################################### 
            notificationText = testGetNotificationTextSnippet('Page_Submitted_For_Moderation');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Page_Submitted_For_Moderation');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Page_Submitted_For_Moderation', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Page_Submitted_For_Moderation ###################################### 
            notificationText = testGetNotificationTextSnippet('Event_Submitted_For_Moderation');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Event_Submitted_For_Moderation');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Event_Submitted_For_Moderation', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Event_Submitted_For_Moderation ###################################### 
            notificationText = testGetNotificationTextSnippet('Endorses_Me');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Endorses_Me');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Endorses_Me', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            Test.stopTest();
        }
    }
    
    @isTest 
    static void testNotificationTextCategory3() {
        init();
        LocaleContext.getLabelMap('PushNotifications', 'en_US');
        String notificationText;
        Boolean result = false;

        System.runAs(getAdminUser()) {
            Test.startTest();
            notificationText = testGetNotificationTextSnippet('Follows_Me');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Follows_Me');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Follows_Me', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Follows_Me ###################################### 
            notificationText = testGetNotificationTextSnippet('Like_My_Post');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Like_My_Post');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Like_My_Post', 5, false);
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Like_My_Post', 5, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Like_My_Post ###################################### 
            notificationText = testGetNotificationTextSnippet('Like_My_Reply');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Like_My_Reply');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Like_My_Reply', 5, false);
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Like_My_Reply', 5, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Like_My_Reply ###################################### 
            notificationText = testGetNotificationTextSnippet('Like_My_Comment_On_Content');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Like_My_Comment_On_Content');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Like_My_Comment_On_Content', 5, true);
            System.assertEquals(true, result, 'notification text not returned');
            Test.stopTest();
        }
    }
    
    @isTest 
    static void testNotificationTextCategory4() {
        init();
        LocaleContext.getLabelMap('PushNotifications', 'en_US');
        String notificationText;
        Boolean result = false;

        System.runAs(getAdminUser()) {
            Test.startTest();
            notificationText = testGetNotificationTextSnippet('Like_My_Poll');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Like_My_Poll');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Like_My_Poll', 5, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Like_My_Poll ###################################### 
            notificationText = testGetNotificationTextSnippet('Like_My_Reply_On_Content');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Like_My_Reply_On_Content');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Like_My_Reply_On_Content', 5, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Like_My_Reply_On_Content', 5, false);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Like_My_Reply_On_Content ###################################### 
            notificationText = testGetNotificationTextSnippet('Mentions_Me_In_Post');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Mentions_Me_In_Post');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Mentions_Me_In_Post', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Mentions_Me_In_Post ###################################### 
            notificationText = testGetNotificationTextSnippet('Mentions_Me_In_Reply');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Mentions_Me_In_Reply');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Mentions_Me_In_Reply', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            Test.stopTest();
        }
    }
    
    @isTest 
    static void testNotificationTextCategory5() {
        init();
        LocaleContext.getLabelMap('PushNotifications', 'en_US');
        String notificationText;
        Boolean result = false;

        System.runAs(getAdminUser()) {
            Test.startTest();
            notificationText = testGetNotificationTextSnippet('My_Content_Approved');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('My_Content_Approved');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('My_Content_Approved', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### My_Content_Approved ###################################### 
            notificationText = testGetNotificationTextSnippet('Content_Approved');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Content_Approved');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Content_Approved', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Content_Approved ###################################### 
            notificationText = testGetNotificationTextSnippet('Content_Post');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Content_Post');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Content_Post', 5, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Content_Post ###################################### 
            notificationText = testGetNotificationTextSnippet('My_Content_Like');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('My_Content_Like');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('My_Content_Like', 5, true);
            System.assertEquals(true, result, 'notification text not returned');
            Test.stopTest();
        }
    }
    
    @isTest 
    static void testNotificationTextCategory6() {
        init();
        LocaleContext.getLabelMap('PushNotifications', 'en_US');
        String notificationText;
        Boolean result = false;

        System.runAs(getAdminUser()) {
            Test.startTest();
            notificationText = testGetNotificationTextSnippet('Album_Photo_Like');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Album_Photo_Like');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Album_Photo_Like', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Album_Photo_Like ###################################### 
            notificationText = testGetNotificationTextSnippet('Album_Video_Like');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Album_Video_Like');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Album_Video_Like', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Album_Video_Like ###################################### 
            notificationText = testGetNotificationTextSnippet('Album_Your_Photo_Like');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Album_Your_Photo_Like');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Album_Your_Photo_Like', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Album_Your_Photo_Like ###################################### 
            notificationText = testGetNotificationTextSnippet('Content_Rejected');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Content_Rejected');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Content_Rejected', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            Test.stopTest();
        }
    }
    
    @isTest 
    static void testNotificationTextCategory7() {
        init();
        LocaleContext.getLabelMap('PushNotifications', 'en_US');
        String notificationText;
        Boolean result = false;

        System.runAs(getAdminUser()) {
            Test.startTest();
            notificationText = testGetNotificationTextSnippet('Content_Like');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Content_Like');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Content_Like', 5, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Content_Like ###################################### 
            notificationText = testGetNotificationTextSnippet('Album_Your_Video_Like');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Album_Your_Video_Like');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Album_Your_Video_Like', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Album_Your_Video_Like ###################################### 
            notificationText = testGetNotificationTextSnippet('Album_Photo_Share');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Album_Photo_Share');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Album_Photo_Share', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Album_Photo_Share ###################################### 
            notificationText = testGetNotificationTextSnippet('Album_Video_Share');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Album_Video_Share');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Album_Video_Share', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            Test.stopTest();
        }
    }
    
    @isTest 
    static void testNotificationTextCategory8() {
        init();
        LocaleContext.getLabelMap('PushNotifications', 'en_US');
        String notificationText;
        Boolean result = false;

        System.runAs(getAdminUser()) {
            Test.startTest();
            notificationText = testGetNotificationTextSnippet('Album_Your_Photo_Share');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Album_Your_Photo_Share');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Album_Your_Photo_Share', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Album_Your_Photo_Share ###################################### 
            notificationText = testGetNotificationTextSnippet('Album_Your_Video_Share');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Album_Your_Video_Share');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Album_Your_Video_Share', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Album_Your_Video_Share ###################################### 
            notificationText = testGetNotificationTextSnippet('My_Content_Post');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('My_Content_Post');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('My_Content_Post', 5, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### My_Content_Post ###################################### 
            notificationText = testGetNotificationTextSnippet('My_Content_File_Post');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('My_Content_File_Post');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('My_Content_File_Post', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            Test.stopTest();
        }
    }
    
    @isTest 
    static void testNotificationTextCategory9() {
        init();
        LocaleContext.getLabelMap('PushNotifications', 'en_US');
        String notificationText;
        Boolean result = false;

        System.runAs(getAdminUser()) {
            Test.startTest();
            notificationText = testGetNotificationTextSnippet('My_Content_Rejected');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('My_Content_Rejected');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('My_Content_Rejected', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### My_Content_Rejected ###################################### 
            notificationText = testGetNotificationTextSnippet('Posts_On_My_Profile');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Posts_On_My_Profile');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Posts_On_My_Profile', 1, false);
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Posts_On_My_Profile', 1, true);
            System.assertEquals(true, result, 'notification text not returned');

            // ####################################### Posts_On_My_Profile ###################################### 
            notificationText = testGetNotificationTextSnippet('PrivateSiteMembership_Response');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('PrivateSiteMembership_Response');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('PrivateSiteMembership_Response', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### PrivateSiteMembership_Response ###################################### 
            notificationText = testGetNotificationTextSnippet('Private_Site_Membership_Requests');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Private_Site_Membership_Requests');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Private_Site_Membership_Requests', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            Test.stopTest();
        }
    }
    
    @isTest 
    static void testNotificationTextCategory10() {
        init();
        LocaleContext.getLabelMap('PushNotifications', 'en_US');
        String notificationText;
        Boolean result = false;

        System.runAs(getAdminUser()) {
            Test.startTest();
            notificationText = testGetNotificationTextSnippet('Shares_My_Post');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Shares_My_Post');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Shares_My_Post', 5, false);
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Shares_My_Post', 5, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Shares_My_Post ###################################### 
            notificationText = testGetNotificationTextSnippet('Invited_To_Event');
            System.assert(notificationText != null , 'notification text not returned');
            
            
            notificationText = testGetNotificationTextWOSnippet('Invited_To_Event');
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Invited_To_Event', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Invited_To_Event ###################################### 
            notificationText = testGetNotificationTextSnippet('Comments_On_My_Poll');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Comments_On_My_Poll');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Comments_On_My_Poll', 5, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Comments_On_My_Poll ###################################### 
            notificationText = testGetNotificationTextSnippet('Comments_On_My_Post_With_File');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Comments_On_My_Post_With_File');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Comments_On_My_Post_With_File', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            Test.stopTest();
        }
    }
    
    @isTest 
    static void testNotificationTextCategory11() {
        init();
        LocaleContext.getLabelMap('PushNotifications', 'en_US');
        String notificationText;
        Boolean result = false;

        System.runAs(getAdminUser()) {
            Test.startTest();
            notificationText = testGetNotificationTextSnippet('Also_Replied_On_My_Comment');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Also_Replied_On_My_Comment');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Also_Replied_On_My_Comment', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Also_Replied_On_My_Comment ###################################### 
            notificationText = testGetNotificationTextSnippet('Also_Replied_On_Post');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Also_Replied_On_Post');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Also_Replied_On_Post', 5, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Also_Replied_On_Post ###################################### 
            notificationText = testGetNotificationTextSnippet('Also_Replied_On_My_Post');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Also_Replied_On_My_Post');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Also_Replied_On_My_Post', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Also_Replied_On_My_Post ###################################### 
            notificationText = testGetNotificationTextSnippet('Also_Replied_On_Comment');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Also_Replied_On_Comment');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Also_Replied_On_Comment', 5, true);
            System.assertEquals(true, result, 'notification text not returned');
            Test.stopTest();
        }
    }
    
    @isTest 
    static void testNotificationTextCategory12() {
        init();
        LocaleContext.getLabelMap('PushNotifications', 'en_US');
        String notificationText;
        Boolean result = false;

        System.runAs(getAdminUser()) {
            Test.startTest();
            notificationText = testGetNotificationTextSnippet('Comments_On_Post_On_My_Profile');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Comments_On_Post_On_My_Profile');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Comments_On_Post_On_My_Profile', 5, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Comments_On_Post_On_My_Profile ###################################### 
            notificationText = testGetNotificationTextSnippet('Posts_A_Poll_On_My_Profile');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Posts_A_Poll_On_My_Profile');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Posts_A_Poll_On_My_Profile', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Posts_A_Poll_On_My_Profile ###################################### 
            notificationText = testGetNotificationTextSnippet('Posts_On_My_Profile_With_File');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Posts_On_My_Profile_With_File');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Posts_On_My_Profile_With_File', 1, false);
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Posts_On_My_Profile_With_File', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Posts_On_My_Profile_With_File ###################################### 
            notificationText = testGetNotificationTextSnippet('Album_Media_Add');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Album_Media_Add');
            System.assert(notificationText != null , 'notification text not returned');
            Test.stopTest();
        }
    }
    
    @isTest 
    static void testNotificationTextCategory13() {
        init();
        LocaleContext.getLabelMap('PushNotifications', 'en_US');
        String notificationText;
        Boolean result = false;

        System.runAs(getAdminUser()) {
            Test.startTest();
            notificationText = testGetNotificationTextSnippet('Content_For_Review');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Content_For_Review');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Content_For_Review', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Content_For_Review ###################################### 
            notificationText = testGetNotificationTextSnippet('Content_Expired');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Content_Expired');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Content_Expired', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Content_Expired ###################################### 
            notificationText = testGetNotificationTextSnippet('ServiceNow');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('ServiceNow');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('ServiceNow', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### ServiceNow ###################################### 
            notificationText = testGetNotificationTextSnippet('External');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('External');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('External', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            Test.stopTest();
        }
    }
    
    @isTest 
    static void testNotificationTextCategory14() {
        init();
        LocaleContext.getLabelMap('PushNotifications', 'en_US');
        String notificationText;
        Boolean result = false;

        System.runAs(getAdminUser()) {
            Test.startTest();
            notificationText = testGetNotificationTextSnippet('Member_Added');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Member_Added');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Member_Added', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Member_Added ###################################### 
            notificationText = testGetNotificationTextSnippet('Subscription_Request');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Subscription_Request');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Subscription_Request', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Subscription_Request ###################################### 
            notificationText = testGetNotificationTextSnippet('Content_Rated_Unuseful');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Content_Rated_Unuseful');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Content_Rated_Unuseful', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            
            // ####################################### Content_Rated_Unuseful ###################################### 
            notificationText = testGetNotificationTextSnippet('Newsletter');
            System.assert(notificationText != null , 'notification text not returned');
            
            notificationText = testGetNotificationTextWOSnippet('Newsletter');
            System.assert(notificationText != null , 'notification text not returned');
            
            result = testAction('Newsletter', 1, true);
            System.assertEquals(true, result, 'notification text not returned');
            Test.stopTest();
        }
    }
    
    @isTest 
    static void testNotificationTextCategory15() {
        init();
        LocaleContext.getLabelMap('PushNotifications', 'en_US');
        Boolean result = false;

        System.runAs(getAdminUser()) {
            Test.startTest();
            //Covering all the remaing in-app cases
            result = testAction('Campaign_Share', 1, true); //Campaign_Share
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Grant_Campaign_Access', 1, true); //Grant_Campaign_Access
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Grant_Newsletter_Access', 1, true); //Grant_Newsletter_Access
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Grant_Site_Newsletter_Access', 1, true); //Grant_Site_Newsletter_Access
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Email_Notifcation_Overwrite', 1, true); //Email_Notifcation_Overwrite
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Native_Mobile_Notification_Overwrite', 1, true); //Native_Mobile_Notification_Overwrite
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Browser_Notification_Overwrite', 1, true); //Browser_Notification_Overwrite
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('SMS_Notification_Overwrite', 1, true); //SMS_Notification_Overwrite
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Feed_Default_Overwrite', 1, true); //Feed_Default_Overwrite
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Home_Default_Overwrite', 1, true); //Home_Default_Overwrite
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Home_Default_Reminder', 1, true); //Home_Default_Reminder
            System.assertEquals(true, result, 'notification text not returned');
            Test.stopTest();
        }
    }
    
    @isTest 
    static void testNotificationTextCategory16() {
        init();
        LocaleContext.getLabelMap('PushNotifications', 'en_US');
        Boolean result = false;

        System.runAs(getAdminUser()) {
            Test.startTest();
            //Covering all the remaing in-app cases
            result = testAction('Mobile_Promotion', 1, true); //Mobile_Promotion
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Content_Notification', 1, true); //Content_Notification
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('My_Content_Share', 5, true); //My_Content_Share
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Content_Share', 5, true); //Content_Share
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Public_Site_Membership_Response', 1, true); //Public_Site_Membership_Response
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Public_Site_Membership_Requests', 1, true); //Public_Site_Membership_Requests
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Public_Site_Membership_Request_Auto_Approve', 1, true); //Public_Site_Membership_Request_Auto_Approve
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Public_Site_Membership_Request_Auto_Approve', 1, false); //Public_Site_Membership_Request_Auto_Approve
            System.assertEquals(true, result, 'notification text not returned');
            Test.stopTest();
        }
    }
    
    @isTest 
    static void testNotificationTextCategory17() {
        init();
        LocaleContext.getLabelMap('PushNotifications', 'en_US');
        Boolean result = false;

        System.runAs(getAdminUser()) {
            Test.startTest();
            //Covering all the remaing in-app cases
            result = testAction('Must_Read', 1, true); //Must_Read
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Last_Month_App_Analytics', 1, true); //Last_Month_App_Analytics
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Last_Month_Site_Analytics', 1, true); //Last_Month_Site_Analytics
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Last_Month_Content_Analytics', 1, true); //Last_Month_Content_Analytics
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Made_Site_Manager', 1, true); //Made_Site_Manager
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Made_Site_Content_Manager', 1, true); //Made_Site_Content_Manager
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Made_Site_Owner', 1, true); //Made_Site_Owner
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Made_Content_Author', 1, true); //Made_Content_Author
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Published_On_Behalf', 1, true); //Published_On_Behalf
            System.assertEquals(true, result, 'notification text not returned');
            Test.stopTest();
        }
    }
    
    @isTest 
    static void testNotificationTextCategory18() {
        init();
        LocaleContext.getLabelMap('PushNotifications', 'en_US');
        Boolean result = false;

        System.runAs(getAdminUser()) {
            Test.startTest();
            //Covering all the remaing in-app cases
            result = testAction('My_Content_Edited', 1, true); //My_Content_Edited
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Changed_Content_Author', 1, true); //Changed_Content_Author
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Social_Campaign_Ready', 1, true); //Social_Campaign_Ready
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Made_Segment_Manager', 1, true); //Made_Segment_Manager
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Subscription_Approved', 1, true); //Subscription_Approved
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Subscription_Rejected', 1, true); //Subscription_Rejected
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('RSVP_Removed', 1, true); //RSVP_Removed
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Event_Deleted', 1, true); //Event_Deleted
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Event_Unpublished', 1, true); //Event_Unpublished
            System.assertEquals(true, result, 'notification text not returned');
            
            result = testAction('Event_Updated', 1, true); //Event_Updated
            System.assertEquals(true, result, 'notification text not returned');
            Test.stopTest();
        }
    }
    
    @isTest 
    static void testNotificationTextCategoryQnA() {
        init();
        LocaleContext.getLabelMap('PushNotifications', 'en_US');
        String notificationText;
        Boolean result = false;

        System.runAs(getAdminUser()) {
            Test.startTest();
            App_Notification__c appNotifObj = new App_Notification__c();
            appNotifObj.Category__c = 'Mentions_In_Question';
            appNotifObj.snippet__c = 'test snippet';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.Category__c = 'Mentions_In_Answer';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.Category__c = 'Voted_On_Answer';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.Category__c = 'Answer_Approved';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.Category__c = 'New_Answer_To_Question';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.Category__c = 'Approved_Answer_To_Question';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.Category__c = 'Question_Marked_Duplicate';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.Category__c = 'New_Question';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.Category__c = 'New_Question_In_Content';
            appNotifObj.Action_Count__c = 1;
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.Action_Count__c = 2;
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.Action_Count__c = 3;
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.Action_Count__c = 4;
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.Action_Count__c = 5;
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.Category__c = 'New_Answer_In_Content';
            appNotifObj.Action_Count__c = 1;
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.Action_Count__c = 2;
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.Action_Count__c = 3;
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.Action_Count__c = 4;
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.Action_Count__c = 5;
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');

            Test.stopTest();
        }
    }
    
        @isTest
    static void testGetPopUpNotificationsRecognition() {
        init();
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        App_Notification__c notificationObj = TestHelper.createSimpplrNotification('Dummy', peopleObj.Id, null, 'recognition', null, null);
        notificationObj.Type__c = 'Information';
        notificationObj.Is_Read__c = false;
        notificationObj.Is_New__c = true;
        notificationObj.category__c = 'recognition_hub';
        notificationObj.Object_Type__c = 'recognition';
        notificationObj.Object_Id__c = 'objectId';
        update notificationObj;

        TestHelper.createSimpplrUnGroupedNotifications(peopleObj.Id);

        pgRef.getParameters().put('action', 'search');
        pgRef.getParameters().put('data', '{"size":10,"includeActioned":false,"nextPageToken":0, "peopleId":"'+String.valueOf(peopleObj.Id)+'"}');
        
        Test.startTest();
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, serverObj.response.message);

        pgRef.getParameters().put('origin', 'mobile');
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, serverObj.response.message);
        
        Test.stopTest();

    }

    @isTest 
    static void testNotificationTextCategoryRecognitionInApp() {
        init();
        LocaleContext.getLabelMap('InAppNotifications', 'en_US');
        String notificationText;
        Boolean result = false;

        System.runAs(getAdminUser()) {
            Test.startTest();
            App_Notification__c appNotifObj = new App_Notification__c();
            appNotifObj.Category__c = 'recognition';
            appNotifObj.snippet__c = 'test snippet';

            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.Category__c = 'recognition_hub';
            appNotifObj.sub_Type__c = 'new_award_10_days_before';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.sub_Type__c = 'existing_award_7_days_before';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.sub_Type__c = 'new_award_3_days_before';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'delegate_open';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'low_participation';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'delegate_close';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'overdue_next_open';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'overdue_next_close';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'overdue_warning';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'award_skipped';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'award_missed';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'user_open';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'user_open_n_awards';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'award_granted';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'award_winner';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'direct_new_award';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'direct_existing_award';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'award_due';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.sub_Type__c = 'award_skipped';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.sub_Type__c = 'recognition_recipient';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.sub_Type__c = 'recognition_mention';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.sub_Type__c = 'award_cheer';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.sub_Type__c = 'recognition_cheer';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.sub_Type__c = 'award_comment';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.sub_Type__c = 'recognition_comment';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.sub_Type__c = 'recognition_comment_like';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'notify_manager_award';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'notify_manager_recognition';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'overdue_warning';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'overdue_awarded';
            notificationText = notificationTextInApp(appNotifObj, '');
            System.assert(notificationText != null , 'notification text not returned');

            Test.stopTest();
        }
    }

    @isTest 
    static void testNotificationTextCategoryRecognitionPush() {
        init();
        LocaleContext.getLabelMap('PushNotifications', 'en_US');
        String notificationText;
        Boolean result = false;

        System.runAs(getAdminUser()) {
            Test.startTest();
            App_Notification__c appNotifObj = new App_Notification__c();
            appNotifObj.Category__c = 'recognition';
            appNotifObj.snippet__c = 'test snippet';

            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.Category__c = 'recognition_hub';
            appNotifObj.sub_Type__c = 'new_award_10_days_before';
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.sub_Type__c = 'existing_award_7_days_before';
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.sub_Type__c = 'new_award_3_days_before';
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'delegate_open';
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'low_participation';
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'delegate_close';
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'overdue_next_open';
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'overdue_next_close';
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'overdue_warning';
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'award_skipped';
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'award_missed';
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'user_open';
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'user_open_n_awards';
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'award_granted';
            appNotifObj.Action_Count__c = 1;
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.Action_Count__c = 2;
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.Action_Count__c = 3;
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.Action_Count__c = 4;
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.Action_Count__c = 5;
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'award_winner';
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'direct_new_award';
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'direct_existing_award';
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'award_due';
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.sub_Type__c = 'award_skipped';
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.sub_Type__c = 'recognition_recipient';
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.sub_Type__c = 'recognition_mention';
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.sub_Type__c = 'award_cheer';
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.sub_Type__c = 'recognition_cheer';
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.sub_Type__c = 'award_comment';
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.sub_Type__c = 'recognition_comment';
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');
            
            appNotifObj.sub_Type__c = 'recognition_comment_like';
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'notify_manager_award';
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'notify_manager_recognition';
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'overdue_warning';
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');

            appNotifObj.sub_Type__c = 'overdue_awarded';
            notificationText = testGetNotificationTextSnippet(appNotifObj);
            System.assert(notificationText != null , 'notification text not returned');

            Test.stopTest();
        }
    }
    
    @isTest static void testSendInAppPushNotificationsRecognition() {
        init();
        TestHelper.createPeopleRecordForUser(UserContext.id);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false));
        people__c people1 = getPeopleRecordForStandardUser();
        people1.Mobile_App_Type_Android__c = 'native';
        people1.Mobile_App_Type_iOS__c = 'native';
        people1.Mobile_App_Version_Android__c = '4.60.00';
        people1.Mobile_App_Version_iOS__c = '4.6.0';
        people1.Mobile_Bundle_ID_Android__c = 'com.simpplr.SimpplrX';
        people1.Mobile_Bundle_ID_iOS__c = 'com.workwin.aurora';
        people1.Mobile_FCM_ID_Android__c = 'dJUpc8d9QVyc9VU1fmYQ_F:APA91bHKqktXA66nAhjIFY0Oa0247kXU31-G_gD27zn7ohi--6omZFbSFgcqilG6wHYaMyU98aCu23RbIoAmBHwDgF6bx1PD1li5ybt_nvsDP2Pt1GiEWK0b-7ggv2TQmhMnsqPc_Ffy';
        people1.Mobile_FCM_ID_iOS__c = 'dJUpc8d9QVyc9VU1fmYQ_F:APA91bHKqktXA66nAhjIFY0Oa0247kXU31-G_gD27zn7ohi--6omZFbSFgcqilG6wHYaMyU98aCu23RbIoAmBHwDgF6bx1PD1li5ybt_nvsDP2Pt1GiEWK0b-7ggv2TQmhMnsqPc_Ffy';
        people1.Mobile_Token_Android__c = 'dJUpc8d9QVyc9VU1fmYQ_F:APA91bHKqktXA66nAhjIFY0Oa0247kXU31-G_gD27zn7ohi--6omZFbSFgcqilG6wHYaMyU98aCu23RbIoAmBHwDgF6bx1PD1li5ybt_nvsDP2Pt1GiEWK0b-7ggv2TQmhMnsqPc_Ffd';
        people1.Mobile_Token_iOS__c = 'dJUpc8d9QVyc9VU1fmYQ_F:APA91bHKqktXA66nAhjIFY0Oa0247kXU31-G_gD27zn7ohi--6omZFbSFgcqilG6wHYaMyU98aCu23RbIoAmBHwDgF6bx1PD1li5ybt_nvsDP2Pt1GiEWK0b-7ggv2TQmhMnsqPc_Ff5';
        update people1;

        people__c people2 = getPeopleRecordForAdminUser();
        
        SimpplrContext.SimpplrMobileNotificationAllowed = true;

        Test.startTest();
        pgRef.getParameters().put('action', 'sendInAppPushNotifications');
        
        pgRef.getParameters().put('data', '{\"notificationsListJson\":\"[{\\\"isNew\\\":true,\\\"objectID\\\":\\\"ca7105a7-0378-41c8-9a35-d8sr8b2a28821\\\",\\\"objectType\\\":\\\"Recognition\\\",\\\"fromUser\\\":\\\"'+people2.Id+'\\\",\\\"toUser\\\":\\\"'+people1.Id+'\\\",\\\"status\\\":\\\"Pending\\\",\\\"snippet\\\":\\\"award name\\\",\\\"type\\\":\\\"Information\\\",\\\"fromUserSmallPhotoUrl\\\":\\\"\\\",\\\"fromUserPhotoColor\\\":\\\"\\\",\\\"title\\\":\\\"recognition\\\",\\\"categoryStr\\\":\\\"recognition_hub\\\",\\\"subType\\\":\\\"award_winner\\\"}]\"}');
        
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, serverObj.response.message);
        Test.stoptest();
    }

    @isTest static void testSendInAppPushNotifications() {
        init();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false));
        pgRef.getParameters().put('action', 'sendInAppPushNotifications');
        
        pgRef.getParameters().put('data', '{\"notificationsListJson\":\"[{\\\"isNew\\\":true,\\\"objectID\\\":\\\"ca7105a7-0378-41c8-9a35-d8sr8b2a28821\\\",\\\"objectType\\\":\\\"Newsletter\\\",\\\"fromUser\\\":\\\"'+UserContext.UserId+'\\\",\\\"toUser\\\":\\\"'+UserContext.UserId+'\\\",\\\"status\\\":\\\"Pending\\\",\\\"snippet\\\":\\\"VJ Notification test\\\",\\\"type\\\":\\\"Information\\\",\\\"fromUserSmallPhotoUrl\\\":\\\"\\\",\\\"fromUserPhotoColor\\\":\\\"\\\",\\\"title\\\":\\\"Newsletter\\\",\\\"categoryStr\\\":\\\"Newsletter\\\",\\\"subType\\\":\\\"award_winner\\\"}]\"}');
        
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, serverObj.response.message);
        Test.stoptest();
    }
    
    @isTest static void testBrandedAppDistributionPhonePromotion() {
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false));
        
        App_config__c appConfigObj = [SELECT Id, Branded_App_Distribution_Enabled__c FROM App_config__c LIMIT 1];
        appConfigObj.Branded_App_Distribution_Enabled__c = true;
        update appConfigObj;
        
        people__c ppl = getPeopleRecordForAdminUser();
        ppl.Mobile_Phone__c = '9898989898';
        ppl.Country__c = 'India';
        update ppl;

        List<Branded_App_Distribution__c> badObjList = New List<Branded_App_Distribution__c>();
		badObjList.add(new Branded_App_Distribution__c(Code__c = 'ssss', Country__c = 'India'));
		insert badObjList;
        
        pgRef.getParameters().put('action', 'sendBrandedAppDistributionLink');
        pgRef.getParameters().put('type', 'MOBILE_PROMOTION_PHONE');
        pgRef.getParameters().put('mobileNumber', '9898989898');
        
        Test.startTest();
        serverObj.handleRequest();
        Test.stoptest();
        System.assertEquals('success', serverObj.response.status, serverObj.response.message);
    }
    
    
    @isTest static void testBrandedAppDistributionPhonePromotionNoCodeInCountry() {
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'pushNotifications',false));
        
        App_config__c appConfigObj = [SELECT Id, Branded_App_Distribution_Enabled__c FROM App_config__c LIMIT 1];
        appConfigObj.Branded_App_Distribution_Enabled__c = true;
        update appConfigObj;

        people__c ppl = getPeopleRecordForAdminUser();
        ppl.Mobile_Phone__c = '9898989898';
        ppl.Country__c = 'India';
        update ppl;

        List<Branded_App_Distribution__c> badObjList = New List<Branded_App_Distribution__c>();
		badObjList.add(new Branded_App_Distribution__c(Code__c = 'ssss'));
		insert badObjList;

        pgRef.getParameters().put('action', 'sendBrandedAppDistributionLink');
        pgRef.getParameters().put('type', 'MOBILE_PROMOTION_PHONE');
        pgRef.getParameters().put('mobileNumber', '9898989898');
        
        Test.startTest();
        serverObj.handleRequest();
        Test.stoptest();
        System.assertEquals('error', serverObj.response.status, serverObj.response.message);
    }
    
    @isTest static void testBrandedAppDistributionPhonePromotionEmail() {
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'pushNotifications',false));
        
        App_config__c appConfigObj = [SELECT Id, Branded_App_Distribution_Enabled__c FROM App_config__c LIMIT 1];
        appConfigObj.Branded_App_Distribution_Enabled__c = true;
        update appConfigObj;

        people__c ppl = getPeopleRecordForAdminUser();
        ppl.Email__c = 'test@mail.com';
        ppl.Country__c = 'India';
        update ppl;

        List<Branded_App_Distribution__c> badObjList = New List<Branded_App_Distribution__c>();
		badObjList.add(new Branded_App_Distribution__c(Code__c = 'ssss',Country__c = 'India'));
		insert badObjList;
        
        pgRef.getParameters().put('action', 'sendBrandedAppDistributionLink');
        pgRef.getParameters().put('type', 'MOBILE_PROMOTION_EMAIL');
        pgRef.getParameters().put('emailAddress', 'test@mail.com');
        
        Test.startTest();
        serverObj.handleRequest();
        Test.stoptest();
        System.assertEquals('error', serverObj.response.status, serverObj.response.message);
    }
    
    @isTest static void testBrandedAppDistributionPhonePromotionAlreadySent() {
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'pushNotifications',false));
        
        App_config__c appConfigObj = [SELECT Id, Branded_App_Distribution_Enabled__c FROM App_config__c LIMIT 1];
        appConfigObj.Branded_App_Distribution_Enabled__c = true;
        update appConfigObj;
        
        people__c ppl = getPeopleRecordForAdminUser();
        ppl.Email__c = 'test@mail.com';
        ppl.Country__c = 'India';
        update ppl;

        List<Branded_App_Distribution__c> badObjList = New List<Branded_App_Distribution__c>();
		badObjList.add(new Branded_App_Distribution__c(Code__c = 'ssss',Country__c = 'India',People__c = ppl.Id ));
		insert badObjList;

        pgRef.getParameters().put('action', 'sendBrandedAppDistributionLink');
        pgRef.getParameters().put('type', 'MOBILE_PROMOTION_EMAIL');
        pgRef.getParameters().put('emailAddress', 'test@mail.com');
        
        Test.startTest();
        serverObj.handleRequest();
        Test.stoptest();
        System.assertEquals('error', serverObj.response.status, serverObj.response.message);
    }
    
    @isTest static void testBrandedAppDistributionPhonePromotionBulkSMSLowCodes() {
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'pushNotifications',false));
        
        App_config__c appConfigObj = [SELECT Id, Branded_App_Distribution_Enabled__c FROM App_config__c LIMIT 1];
        appConfigObj.Branded_App_Distribution_Enabled__c = true;
        update appConfigObj;
        
        people__c ppl = getPeopleRecordForAdminUser();
        ppl.Phone__c = '9191919191';
        ppl.Country__c = 'India';
        update ppl;
        
        List<Branded_App_Distribution__c> badObjList = New List<Branded_App_Distribution__c>();
		badObjList.add(new Branded_App_Distribution__c(Code__c = 'ssss',Country__c = 'India',People__c = ppl.Id ));
		insert badObjList;

        pgRef.getParameters().put('action', 'buldSendBrandedAppDistributionLink');
        pgRef.getParameters().put('type', 'MOBILE_PROMOTION_PHONE');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/NotificationDataServer/peopleByCountry',false));
        serverObj.handleRequest();
        Test.stoptest();
        System.assertEquals('success', serverObj.response.status, serverObj.response.message);
    }
    
    @isTest static void testBrandedAppDistributionPhonePromotionBulkEmailLowCodes() {
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'pushNotifications',false));
        
        App_config__c appConfigObj = [SELECT Id, Branded_App_Distribution_Enabled__c FROM App_config__c LIMIT 1];
        appConfigObj.Branded_App_Distribution_Enabled__c = true;
        update appConfigObj;

        people__c ppl = getPeopleRecordForAdminUser();
        ppl.Email__c = 'test@mail.com';
        ppl.Country__c = 'India';
        update ppl;

        List<Branded_App_Distribution__c> badObjList = New List<Branded_App_Distribution__c>();
		badObjList.add(new Branded_App_Distribution__c(Code__c = 'ssss',Country__c = 'India',People__c = ppl.Id ));
		insert badObjList;
        
        pgRef.getParameters().put('action', 'buldSendBrandedAppDistributionLink');
        pgRef.getParameters().put('type', 'MOBILE_PROMOTION_EMAIL');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/NotificationDataServer/peopleByCountry',false));
        serverObj.handleRequest();
        Test.stoptest();

        System.assertEquals('success', serverObj.response.status, serverObj.response.message);
    }
    
    @isTest static void testBrandedAppDistributionPhonePromotionNoCodesAtAll() {
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'pushNotifications',false));
        
        App_config__c appConfigObj = [SELECT Id, Branded_App_Distribution_Enabled__c FROM App_config__c LIMIT 1];
        appConfigObj.Branded_App_Distribution_Enabled__c = true;
        update appConfigObj;
        
        people__c ppl = getPeopleRecordForAdminUser();
        ppl.Email__c = 'test@mail.com';
        ppl.Country__c = 'India';
        update ppl;
        
        pgRef.getParameters().put('action', 'sendBrandedAppDistributionLink');
        pgRef.getParameters().put('type', 'MOBILE_PROMOTION_EMAIL');
        pgRef.getParameters().put('emailAddress', 'test@mail.com');
        
        Test.startTest();
        serverObj.handleRequest();
        Test.stoptest();
        System.assertEquals('error', serverObj.response.status, serverObj.response.message);
    }
    
    @isTest static void testBrandedAppDistributionError() {
        init();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false));
        
        App_config__c appConfigObj = [SELECT Id, Branded_App_Distribution_Enabled__c FROM App_config__c LIMIT 1];
        appConfigObj.Branded_App_Distribution_Enabled__c = true;
        update appConfigObj;
        
        pgRef.getParameters().put('action', 'sendBrandedAppDistributionLink');
        pgRef.getParameters().put('type', 'MOBILE_PROMOTION_PHONE');
        pgRef.getParameters().put('mobileNumber', '9898989898');
        
        serverObj.handleRequest();
        System.assertEquals('error', serverObj.response.status, serverObj.response.message); //There are no codes available for download
        
        Branded_App_Distribution__c badObj = new Branded_App_Distribution__c(Code__c = 'ssss', Country__c = 'someCountry');   
        insert badObj;
        
        pgRef.getParameters().put('type', 'MOBILE_PROMOTION_EMAIL');
        pgRef.getParameters().put('emailAddress', 'test@mail.com');
        serverObj.handleRequest();
        System.assertEquals('error', serverObj.response.status, serverObj.response.message); //No codes are available for your location
        
        Test.stoptest();
    }
    
    @isTest static void testBrandedAppDistributionPhonePromotionBulkPhone() {
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'pushNotifications',false));
        
        App_config__c appConfigObj = [SELECT Id, Branded_App_Distribution_Enabled__c FROM App_config__c LIMIT 1];
        appConfigObj.Branded_App_Distribution_Enabled__c = true;
        update appConfigObj;

        people__c ppl = getPeopleRecordForAdminUser();
        ppl.Phone__c = '9191919191';
        ppl.Country__c = 'India';
        update ppl;

        List<Branded_App_Distribution__c> badObjList = New List<Branded_App_Distribution__c>();
		badObjList.add(new Branded_App_Distribution__c(Code__c = 'code', Country__c = 'India'));
		insert badObjList;
        
        pgRef.getParameters().put('action', 'buldSendBrandedAppDistributionLink');
        pgRef.getParameters().put('type', 'MOBILE_PROMOTION_PHONE');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/NotificationDataServer/peopleByCountry',false));
        serverObj.handleRequest();
        Test.stoptest();
        
        System.assertEquals('success', serverObj.response.status, serverObj.response.message);
    }
    @isTest static void testBrandedAppDistributionPhonePromotionBulkSMS() {
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'pushNotifications',false));
        
        App_config__c appConfigObj = [SELECT Id, Branded_App_Distribution_Enabled__c FROM App_config__c LIMIT 1];
        appConfigObj.Branded_App_Distribution_Enabled__c = true;
        update appConfigObj;
        
        people__c ppl = getPeopleRecordForAdminUser();
        ppl.Email__c = 'test.'+ppl.Title__c+'@mail.com';
        ppl.Country__c = 'India';
        update ppl;

        List<Branded_App_Distribution__c> badObjList = New List<Branded_App_Distribution__c>();
		badObjList.add(new Branded_App_Distribution__c(Code__c = 'code', Country__c = 'India'));
		insert badObjList;

        pgRef.getParameters().put('action', 'buldSendBrandedAppDistributionLink');
        pgRef.getParameters().put('type', 'MOBILE_PROMOTION_EMAIL');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/NotificationDataServer/peopleByCountry',false));
        serverObj.handleRequest();
        Test.stoptest();
        System.assertEquals('success', serverObj.response.status, serverObj.response.message);
    }

    @isTest static void testBrandedAppDistributionPhonePromotionBulkLowCode() {
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'pushNotifications',true));
        
        App_config__c appConfigObj = [SELECT Id, Branded_App_Distribution_Enabled__c FROM App_config__c LIMIT 1];
        appConfigObj.Branded_App_Distribution_Enabled__c = true;
        update appConfigObj;
        
        people__c ppl = getPeopleRecordForAdminUser();
        ppl.Email__c = 'test.'+ppl.Title__c+'@mail.com';
        ppl.Country__c = 'India';
        update ppl;

        List<Branded_App_Distribution__c> badObjList = New List<Branded_App_Distribution__c>();
		badObjList.add(new Branded_App_Distribution__c(Code__c = 'codeUS',Country__c = 'US'));
		insert badObjList;
       
        pgRef.getParameters().put('action', 'buldSendBrandedAppDistributionLink');
        pgRef.getParameters().put('type', 'MOBILE_PROMOTION_EMAIL');
        
        Test.startTest();
        serverObj.handleRequest();
        Test.stoptest();


        System.assertEquals('error', serverObj.response.status, serverObj.response.message);
    }

    @isTest
    static void testSendNotification() {
        init();
        Simpplr_Content__c contentObj = createContent();
        TestHelper.createPeopleRecordForUser(UserInfo.getUserId());        
        pgRef.getParameters().put('action', 'sendNotification');
        pgRef.getParameters().put('message', 'send notification');
        pgRef.getParameters().put('membersType', 'site_members');
        pgRef.getParameters().put('contentId', contentObj.Id);

        Test.startTest();
        serverObj.handleRequest();
        Test.stopTest();

        System.assertEquals('success', serverObj.response.status, serverObj.response.message);
    }

    @isTest
    static void testGetPopUpNotifications() {
        init();
        Simpplr_Site__c siteObj = getSiteRecord();
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        App_Notification__c notificationObj = TestHelper.createSimpplrNotification('Dummy', peopleObj.Id, null, 'Like', null, null);
        notificationObj.Simpplr_Site__c = siteObj.Id;
        Simpplr_Content__c contentObj = createContent();
        notificationObj.Type__c = 'Information';
        notificationObj.Is_Read__c = false;
        notificationObj.Is_New__c = true;
        notificationObj.Object_Id__c = contentObj.Id;
        update notificationObj;

        TestHelper.createSimpplrUnGroupedNotifications(peopleObj.Id);

        pgRef.getParameters().put('action', 'search');
        pgRef.getParameters().put('data', '{"size":10,"includeActioned":false,"nextPageToken":0, "peopleId":"'+String.valueOf(peopleObj.Id)+'", "siteId" : "' + String.valueOf(siteObj.Id) + '"}');
        
        Test.startTest();
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, serverObj.response.message);

        pgRef.getParameters().put('origin', 'mobile');
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, serverObj.response.message);
        Test.stopTest();

    }
    
    @isTest
    static void testGetPopUpNotifications2() {
        init();
        Simpplr_Site__c siteObj = getSiteRecord();
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        App_Notification__c notificationObj = TestHelper.createSimpplrNotification('Dummy', peopleObj.Id, null, 'Like', null, null);
        notificationObj.Category__c = 'Like_My_Reply';
        notificationObj.Simpplr_Site__c = siteObj.Id;
        notificationObj.Type__c = 'Information';
        notificationObj.Is_Read__c = false;
        notificationObj.Is_New__c = true;
        notificationObj.Object_Id__c = '23456788';
        notificationObj.Object_Type__c = 'FeedComment';
        update notificationObj;

        TestHelper.createSimpplrUnGroupedNotifications(peopleObj.Id);

        pgRef.getParameters().put('action', 'search');
        pgRef.getParameters().put('data', '{"size":10,"includeActioned":false,"nextPageToken":0, "peopleId":"'+String.valueOf(peopleObj.Id)+'", "siteId" : "' + String.valueOf(siteObj.Id) + '"}');
        
        Test.startTest();
            serverObj.handleRequest();
        Test.stopTest();
            
        System.assertEquals('success', serverObj.response.status, serverObj.response.message);
    }
    
    @isTest
    static void testActionSendEmail() {
        init();

        pgRef.getParameters().put('action', 'sendEmail');
        pgRef.getParameters().put('data', '{"htmlSnippets": { "Mentions_In_Question": { "snippet": "{0}", "values": [{ "snippet": "{0}", "values": [{ "snippetRef": "peopleFirstName" }] }] } }, "emailRequests": [ { "targetUserId": "'+UserInfo.getUserId()+'", "subject": "test", "htmlBody": "", "generateHtmlBody": true, "htmlSnippetName": "Mentions_In_Question", "snippetRefValueMap": { "peopleFirstName": "Test" }}]}');
        
        Test.startTest();
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, serverObj.response.message);
        Test.stopTest();

    }
}