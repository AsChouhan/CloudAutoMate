@isTest
public class BatchNotificationArchivalTest {
    
    @testSetup static void setup() {
        App_Config__c appConfig = TestHelper.setupAppConfig();
        appConfig.Notification_Archival_Duration_In_Months__c = 0;
        update appConfig;
        TestHelper.createPeopleRecordForUser(String.valueOf(UserContext.id));
		TestHelper.createSimpplrNotification('Dummy', UserContext.peopleId,null,'Like',null,null);
    }

    @isTest
    public static void testDeleteUngroupedNotification() {
        Ungrouped_Notification__c notiObj = new Ungrouped_Notification__c(GUID__c = '908765555', 
                Is_Read__c=false, Sent_To__c=UserContext.peopleId,Sent_By__c=UserContext.peopleId, Type__c='Information', 
                Object_Type__c='FeedComment',Is_New__c = true, Object_Id__c = '23456788',  
                is_Deleted__c=false, snippet__c = 'test blah blah');
        insert notiObj;

        notiObj.Created_DateTime__c = DateTime.now().addDays(-30);
        update notiObj;

        Test.startTest();
            BatchNotificationArchival job = new BatchNotificationArchival('deleteUngroupedNotifications', false);
            Database.executeBatch(job, 1000);
        job.execute(null,new List<Ungrouped_Notification__c>{notiObj});
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM Ungrouped_Notification__c].size(), 'Ungrouped notifications not archieved!');
    }
    
    @isTest
    public static void testDeleteNotificationAll() {
        List<App_Notification__c> notifications = [SELECT Id FROM App_Notification__c];
        for(App_Notification__c notification:notifications) {
            notification.Created_DateTime__c = DateTime.now().addDays(-30);
        }
        update notifications;

        Test.startTest();
            BatchNotificationArchival job = new BatchNotificationArchival('deleteNotifications', false);
            Database.executeBatch(job, 1000);
            job.execute(null,notifications);
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM App_Notification__c].size(), 'App notifications not archieved!');
    }
    
    @isTest
    public static void testpNotificationsArchivalToAws() {
		List<App_Notification__c> notifications = [SELECT Id FROM App_Notification__c];
        for(App_Notification__c notification:notifications) {
            notification.Created_DateTime__c = DateTime.now().addDays(-1);
        }
        update notifications;
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockAppNotificationArchival());
            BatchNotificationArchival job = new BatchNotificationArchival('pushAppNotifications', false);
            Database.executeBatch(job, 1000);
        Test.stopTest();

        System.assertEquals(1, [SELECT Id FROM App_Notification__c].size(), 'App notifications not pushed to aws!');
    }

    public class MockAppNotificationArchival implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"success": "success"}');
            response.setStatusCode(200);
            return response; 
        }
    }

}