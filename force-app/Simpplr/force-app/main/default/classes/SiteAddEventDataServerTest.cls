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
public class SiteAddEventDataServerTest {
    
    public static String data;
    public static String editData;
    public static String siteId;
    public static ContentVersion cvObj;
    public static File__c fileObj;
    
    @testSetup static void setup() {
    	TestHelper.setupAppConfig();
        User testUser = TestHelper.createUser('SiteAddEventDataServerTest_StdUser', null, false); 
        User testAdminUser = TestHelper.createUser('SiteAddEventDataServerTest_AdminUser', null, true); 
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id); 
        TestHelper.createPeoplePreference(peopleObj.id);
        CollaborationGroup collGrp = TestHelper.createCollaborationGroup('SiteAddEventDataServerTestSite', 'Public');
        Simpplr_Content__c simpplrContent = TestHelper.createContent('simpplr test event', 'Event', 'Approved', testAdminUser, getSite());
        Simpplr_Content__c simpplrContent1 = TestHelper.createContent('simpplr test event1', 'Event', 'Published', testAdminUser, getSite());
        cvObj = TestHelper.createContentVersion('bsnbmasbdmna', 'File_SiteAddEvent');
        File__c fileObj = TestHelper.createContentTitleImage(simpplrContent.id);
        fileObj.Location__c = 'media';
        update fileObj;     
    }
    
     private static User getStandardUser(){
        User userObj = TestHelper.getUser('Standard User', 'SiteAddEventDataServerTest_StdUser');
        return userObj;
    }
    
    private static User getAdminUser(){
    	User userObj = TestHelper.getUser('System Administrator', 'SiteAddEventDataServerTest_AdminUser');
        return userObj;
    }
    
    private static Simpplr_Site__c getSite(){
        Simpplr_Site__c  siteObj = [select Id, Name, Chatter_Group_Id__c, Landing_Page__c 
        								from Simpplr_Site__c where Name='SiteAddEventDataServerTestSite' LIMIT 1];
        return siteObj;
    }
    
    private static People__c getPeople(String userId){
        People__c  peopleObj = [Select Id, Title__c, Street__c, State__c, Phone__c, Full_Name__c, User__c, Mobile_Phone__c, Manager__c, 
        							Last_Name__c, First_Name__c, Fax__c, Extension__c, Email__c, Department__c, Country__c, City__c 
									From People__c where User__c = :userId LIMIT 1];
        return peopleObj;
    }
    
	private static User getUser(String userId){
        User  userObj = TestHelper.getUserById(userId);
        return userObj;
    }
    
    private static Simpplr_Content__c getContent(){
        Simpplr_Content__c  contentObj = [Select Id,Text_Intro__c,Display_Excerpt__c,Summary_1__c,Type__c,Version__c,
        Is_Published__c,Is_Unpublished__c,Is_Deleted__c,Activated_By_Feature__c,Publish_End_DateTime__c,Is_Must_Read__c,
        Status__c,Primary_Author__c,site__c,Title__c,CreatedDate,Publish_Start_DateTime__c,Event_End_DateTime__c,Event_Is_All_Day__c,
        Event_Start_DateTime__c,LastModifiedDate,Primary_Author__r.User__r.Id,Primary_Author__r.Full_Name__c,Site__r.Landing_Page__c,Event_RSVP_Allowed__c,
        Primary_Author__r.User__r.SmallPhotoUrl,Site__r.name,Site__r.Is_Active__c,Site__r.Is_Deleted__c,Site__r.Site_Type__c,
        (SELECT Id,Content_Version__c,Is_Title_Image__c,Title_Image_Type__c FROM File_Simpplr_Content__r where Is_Deleted__c = false)                                  
        From Simpplr_Content__c where Title__c =  'simpplr test event' LIMIT 1];
        return contentObj;
    }

    private static Simpplr_Content__c getPublishedContent(){
        Simpplr_Content__c  contentObj = [Select Id,Text_Intro__c,Display_Excerpt__c,Summary_1__c,Type__c,Version__c,
        Is_Published__c,Is_Unpublished__c,Is_Deleted__c,Activated_By_Feature__c,Publish_End_DateTime__c,Is_Must_Read__c,
        Status__c,Primary_Author__c,site__c,Title__c,CreatedDate,Publish_Start_DateTime__c,Event_End_DateTime__c,Event_Is_All_Day__c,
        Event_Start_DateTime__c,LastModifiedDate,Primary_Author__r.User__r.Id,Primary_Author__r.Full_Name__c,Site__r.Landing_Page__c,Event_RSVP_Allowed__c,
        Primary_Author__r.User__r.SmallPhotoUrl,Site__r.name,Site__r.Is_Active__c,Site__r.Is_Deleted__c,Site__r.Site_Type__c,
        (SELECT Id,Content_Version__c,Is_Title_Image__c,Title_Image_Type__c FROM File_Simpplr_Content__r where Is_Deleted__c = false)                                  
        From Simpplr_Content__c where Title__c =  'simpplr test event1' LIMIT 1];
        return contentObj;
    }

    private static void init() {
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'SiteAddEventDataServer');
        Test.setCurrentpage(pageRef);
    }
    
    @isTest public static void testActionDraft() { 
        init();
        Test.startTest();
        
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'SiteAddEventDataServer');
        
        User standardUserObj = getStandardUser();
        User adminUserObj = getAdminUser();
        People__c peopleObj = getPeople(adminUserObj.Id);
        Simpplr_Site__c  siteObj = getSite();
        simpplr_content__c contentObj = getContent();
        siteId = siteObj.Id;
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));
        String dataString = '{"siteId":"' + siteId + '",' + 
                                    '"authoredBy":{"userId":"' + adminUserObj.Id + '","url":"https://c.na34.visual.force.com/apex/profileabout?id=' + peopleObj.Id + '",' + 
                                        '"title":"Mr","role":null,"img":"https://c.na34.content.force.com/profilephoto/72961000000F6qr/T",' + 
                                        '"peopleId":"' + peopleObj.Id + '","name":"Deepak Sirohi","location":null,' + 
                                        '"department":"Department_01","canFollow":null,' + 
                                        '"address":"Gurgaon,Haryana,India"},' + 
                                    '"title":"Test Event DS0001","startsAt":"2017-01-01T00:00:00","timezoneIso":"Asia/Colombo",' + 
                                    '"endsAt":"2020-12-31T00:00:00","isAllDayEvent":false,' + 
                                    '"location":"Delhi","isDirectionEnabled":true,"directionSteps":["jkl","mm","mmm"],' + 
                                    '"showTitleImageOnDetailPage":true,"body":"<p>Test Event 01 DS0001 - content</p>","summary":null,' + 
                                    '"bodyJson":{"type":"doc","content":[{"type":"paragraph","attrs":{"indentation":0,"textAlign":"left","className":""},"content":[{"type":"text","text":"abcd"}]},{"type":"paragraph","attrs":{"indentation":0,"textAlign":"left","className":""}}]},' +
                                    '"listOfOrganizers":[{"userId":"' + adminUserObj.Id + '","url":null,"title":null,"state":null,"role":null,' + 
                                        '"img":"https://c.na34.content.force.com/profilephoto/72961000000DSit/T","peopleId":"' + peopleObj.Id + 
                                        '","name":"Arav Sirohi","location":null,"id":"' + adminUserObj.Id + '",' + 
                                        '"department":null,"country":null,"city":null,' + 
                                        '"canFollow":null,"address":null,"$order":2}],"mapUrl":"Https://www.google.com","directions":["Go to India","Go to Simpplr"],' + 
                                    '"publishAt":"2017-01-01T00:00:00","rsvp":{"hasMaybeOption":true,"capacityCount":"10","noteLabel":"Size","dueAtDate":"2017-07-26T01:15:00-06:00"},' + 
                                    '"promoteAt":"2017-01-01T00:00:00","hasDirections":true,"hasRsvp":true,"isRsvpMaybeAllowed":false,' + 
                                    '"titleImage":null,"titleImageCaption":null,"deletedTitleImage":[],"topics":{"records":[]},"deletedTopics":[],"deletedOrganizers":[],"files":[],"deletedFiles":[]}';
                
        
        String publistDataString = '{"siteId":"' + siteId + '","id":"' + contentObj.Id + '",' + 
        							'"authoredBy":{"userId":"' + adminUserObj.Id + '","url":"https://c.na34.visual.force.com/apex/profileabout?id=' + peopleObj.Id + '",' + 
        								'"title":"Mr","role":null,"img":"https://c.na34.content.force.com/profilephoto/72961000000F6qr/T",' + 
        								'"peopleId":"' + peopleObj.Id + '","name":"Deepak Sirohi","location":null,' + 
        								'"department":"Department_01","canFollow":null,' + 
        								'"address":"Gurgaon,Haryana,India"},' + 
        							'"title":"Test Event DS0001","startsAt":"2017-01-01T00:00:00","timezoneIso":"Asia/Colombo",' + 
        							'"endsAt":"2020-12-31T00:00:00","isAllDayEvent":false,' + 
        							'"location":"Delhi","isDirectionEnabled":true,"directionSteps":["jkl","mm","mmm"],' + 
        							'"showTitleImageOnDetailPage":true,"body":"<p>Test Event 01 DS0001 - content</p>","summary":null,' + 
                                    '"bodyJson":{"type":"doc","content":[{"type":"paragraph","attrs":{"indentation":0,"textAlign":"left","className":""},"content":[{"type":"text","text":"abcd"}]},{"type":"paragraph","attrs":{"indentation":0,"textAlign":"left","className":""}}]},' +
        							'"listOfOrganizers":[{"userId":"' + adminUserObj.Id + '","url":null,"title":null,"state":null,"role":null,' + 
        								'"img":"https://c.na34.content.force.com/profilephoto/72961000000DSit/T","peopleId":"' + peopleObj.Id + 
        								'","name":"Arav Sirohi","location":null,"id":"' + adminUserObj.Id + '",' + 
        								'"department":null,"country":null,"city":null,' + 
        								'"canFollow":null,"address":null,"$order":2}],"mapUrl":"Https://www.google.com","directions":["Go to India","Go to Simpplr"],' + 
        							'"publishAt":"2017-01-01T00:00:00","rsvp":{"hasMaybeOption":true,"capacityCount":"10","noteLabel":"Size","dueAtDate":"2017-07-26T01:15:00-06:00"},' + 
        							'"promoteAt":"2017-01-01T00:00:00","hasDirections":true,"hasRsvp":true,"isRsvpMaybeAllowed":false,' + 
        							'"titleImage":null,"titleImageCaption":null,"deletedTitleImage":[],"topics":{"records":[]},"deletedTopics":[],"deletedOrganizers":[],"files":[],"deletedFiles":[]}';
        
        SiteAddEventDataServer serverObj = new SiteAddEventDataServer();
        pgRef.getParameters().put('data', dataString);
        pgRef.getParameters().put('siteId', siteId);
        
        pgRef.getParameters().put('action', 'saveDraft');
        pgRef.getParameters().put('data', dataString);
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.status, 'Running as expected');

        pgRef.getParameters().put('action', 'get');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();

    	Test.stopTest();	
    }

    @isTest public static void testActionPublish() { 
        init();
        Test.startTest();
        
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'SiteAddEventDataServer');
        
        User standardUserObj = getStandardUser();
        User adminUserObj = getAdminUser();
        People__c peopleObj = getPeople(adminUserObj.Id);
        Simpplr_Site__c  siteObj = getSite();
        simpplr_content__c contentObj = getContent();
        siteId = siteObj.Id;
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));
        String dataString = '{"siteId":"' + siteId + '",' + 
                                    '"authoredBy":{"userId":"' + adminUserObj.Id + '","url":"https://c.na34.visual.force.com/apex/profileabout?id=' + peopleObj.Id + '",' + 
                                        '"title":"Mr","role":null,"img":"https://c.na34.content.force.com/profilephoto/72961000000F6qr/T",' + 
                                        '"peopleId":"' + peopleObj.Id + '","name":"Deepak Sirohi","location":null,' + 
                                        '"department":"Department_01","canFollow":null,' + 
                                        '"address":"Gurgaon,Haryana,India"},' + 
                                    '"title":"Test Event DS0001","startsAt":"2017-01-01T00:00:00","timezoneIso":"Asia/Colombo",' + 
                                    '"endsAt":"2020-12-31T00:00:00","isAllDayEvent":false,' + 
                                    '"location":"Delhi","isDirectionEnabled":true,"directionSteps":["jkl","mm","mmm"],' + 
                                    '"showTitleImageOnDetailPage":true,"body":"<p>Test Event 01 DS0001 - content</p>","summary":null,' + 
                                    '"bodyJson":{"type":"doc","content":[{"type":"paragraph","attrs":{"indentation":0,"textAlign":"left","className":""},"content":[{"type":"text","text":"abcd"}]},{"type":"paragraph","attrs":{"indentation":0,"textAlign":"left","className":""}}]},' +
                                    '"listOfOrganizers":[{"userId":"' + adminUserObj.Id + '","url":null,"title":null,"state":null,"role":null,' + 
                                        '"img":"https://c.na34.content.force.com/profilephoto/72961000000DSit/T","peopleId":"' + peopleObj.Id + 
                                        '","name":"Arav Sirohi","location":null,"id":"' + adminUserObj.Id + '",' + 
                                        '"department":null,"country":null,"city":null,' + 
                                        '"canFollow":null,"address":null,"$order":2}],"mapUrl":"Https://www.google.com","directions":["Go to India","Go to Simpplr"],' + 
                                    '"publishAt":"2017-01-01T00:00:00","rsvp":{"hasMaybeOption":true,"capacityCount":"10","noteLabel":"Size","dueAtDate":"2017-07-26T01:15:00-06:00"},' + 
                                    '"promoteAt":"2017-01-01T00:00:00","hasDirections":true,"hasRsvp":true,"isRsvpMaybeAllowed":false,' + 
                                    '"titleImage":null,"titleImageCaption":null,"deletedTitleImage":[],"topics":{"records":[]},"deletedTopics":[],"deletedOrganizers":[],"files":[],"deletedFiles":[]}';
                
        
        String publistDataString = '{"siteId":"' + siteId + '","id":"' + contentObj.Id + '",' + 
        							'"authoredBy":{"userId":"' + adminUserObj.Id + '","url":"https://c.na34.visual.force.com/apex/profileabout?id=' + peopleObj.Id + '",' + 
        								'"title":"Mr","role":null,"img":"https://c.na34.content.force.com/profilephoto/72961000000F6qr/T",' + 
        								'"peopleId":"' + peopleObj.Id + '","name":"Deepak Sirohi","location":null,' + 
        								'"department":"Department_01","canFollow":null,' + 
        								'"address":"Gurgaon,Haryana,India"},' + 
        							'"title":"Test Event DS0001","startsAt":"2017-01-01T00:00:00","timezoneIso":"Asia/Colombo",' + 
        							'"endsAt":"2020-12-31T00:00:00","isAllDayEvent":false,' + 
        							'"location":"Delhi","isDirectionEnabled":true,"directionSteps":["jkl","mm","mmm"],' + 
        							'"showTitleImageOnDetailPage":true,"body":"<p>Test Event 01 DS0001 - content</p>","summary":null,' + 
                                    '"bodyJson":{"type":"doc","content":[{"type":"paragraph","attrs":{"indentation":0,"textAlign":"left","className":""},"content":[{"type":"text","text":"abcd"}]},{"type":"paragraph","attrs":{"indentation":0,"textAlign":"left","className":""}}]},' +
        							'"listOfOrganizers":[{"userId":"' + adminUserObj.Id + '","url":null,"title":null,"state":null,"role":null,' + 
        								'"img":"https://c.na34.content.force.com/profilephoto/72961000000DSit/T","peopleId":"' + peopleObj.Id + 
        								'","name":"Arav Sirohi","location":null,"id":"' + adminUserObj.Id + '",' + 
        								'"department":null,"country":null,"city":null,' + 
        								'"canFollow":null,"address":null,"$order":2}],"mapUrl":"Https://www.google.com","directions":["Go to India","Go to Simpplr"],' + 
        							'"publishAt":"2017-01-01T00:00:00","rsvp":{"hasMaybeOption":true,"capacityCount":"10","noteLabel":"Size","dueAtDate":"2017-07-26T01:15:00-06:00"},' + 
        							'"promoteAt":"2017-01-01T00:00:00","hasDirections":true,"hasRsvp":true,"isRsvpMaybeAllowed":false,' + 
        							'"titleImage":null,"titleImageCaption":null,"deletedTitleImage":[],"topics":{"records":[]},"deletedTopics":[],"deletedOrganizers":[],"files":[],"deletedFiles":[]}';
        
        SiteAddEventDataServer serverObj = new SiteAddEventDataServer();
        pgRef.getParameters().put('data', dataString);
        pgRef.getParameters().put('siteId', siteId);
        
        pgRef.getParameters().put('action', 'publish');
        pgRef.getParameters().put('data', publistDataString);
    	Test.setCurrentPage(pgRef);
        serverObj.handleRequest();    
        System.assertEquals('success', serverObj.Response.status, 'Running as expected'); 
    	Test.stopTest();	
    }

    @isTest public static void testActionApprove() { 
        init();
        Test.startTest();
        
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'SiteAddEventDataServer');
        
        User standardUserObj = getStandardUser();
        User adminUserObj = getAdminUser();
        People__c peopleObj = getPeople(adminUserObj.Id);
        Simpplr_Site__c  siteObj = getSite();
        simpplr_content__c contentObj = getContent();
        siteId = siteObj.Id;
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));
        String dataString = '{"siteId":"' + siteId + '",' + 
                                    '"authoredBy":{"userId":"' + adminUserObj.Id + '","url":"https://c.na34.visual.force.com/apex/profileabout?id=' + peopleObj.Id + '",' + 
                                        '"title":"Mr","role":null,"img":"https://c.na34.content.force.com/profilephoto/72961000000F6qr/T",' + 
                                        '"peopleId":"' + peopleObj.Id + '","name":"Deepak Sirohi","location":null,' + 
                                        '"department":"Department_01","canFollow":null,' + 
                                        '"address":"Gurgaon,Haryana,India"},' + 
                                    '"title":"Test Event DS0001","startsAt":"2017-01-01T00:00:00","timezoneIso":"Asia/Colombo",' + 
                                    '"endsAt":"2020-12-31T00:00:00","isAllDayEvent":false,' + 
                                    '"location":"Delhi","isDirectionEnabled":true,"directionSteps":["jkl","mm","mmm"],' + 
                                    '"showTitleImageOnDetailPage":true,"body":"<p>Test Event 01 DS0001 - content</p>","summary":null,' + 
                                    '"listOfOrganizers":[{"userId":"' + adminUserObj.Id + '","url":null,"title":null,"state":null,"role":null,' + 
                                        '"img":"https://c.na34.content.force.com/profilephoto/72961000000DSit/T","peopleId":"' + peopleObj.Id + 
                                        '","name":"Arav Sirohi","location":null,"id":"' + adminUserObj.Id + '",' + 
                                        '"department":null,"country":null,"city":null,' + 
                                        '"canFollow":null,"address":null,"$order":2}],"mapUrl":"Https://www.google.com","directions":["Go to India","Go to Simpplr"],' + 
                                    '"publishAt":"2017-01-01T00:00:00","rsvp":{"hasMaybeOption":true,"capacityCount":"10","noteLabel":"Size","dueAtDate":"2017-07-26T01:15:00-06:00"},' + 
                                    '"promoteAt":"2017-01-01T00:00:00","hasDirections":true,"hasRsvp":true,"isRsvpMaybeAllowed":false,' + 
                                    '"titleImage":null,"titleImageCaption":null,"deletedTitleImage":[],"topics":{"records":[]},"deletedTopics":[],"deletedOrganizers":[],"files":[],"deletedFiles":[]}';
                
        
        String publistDataString = '{"siteId":"' + siteId + '","id":"' + contentObj.Id + '",' + 
        							'"authoredBy":{"userId":"' + adminUserObj.Id + '","url":"https://c.na34.visual.force.com/apex/profileabout?id=' + peopleObj.Id + '",' + 
        								'"title":"Mr","role":null,"img":"https://c.na34.content.force.com/profilephoto/72961000000F6qr/T",' + 
        								'"peopleId":"' + peopleObj.Id + '","name":"Deepak Sirohi","location":null,' + 
        								'"department":"Department_01","canFollow":null,' + 
        								'"address":"Gurgaon,Haryana,India"},' + 
        							'"title":"Test Event DS0001","startsAt":"2017-01-01T00:00:00","timezoneIso":"Asia/Colombo",' + 
        							'"endsAt":"2020-12-31T00:00:00","isAllDayEvent":false,' + 
        							'"location":"Delhi","isDirectionEnabled":true,"directionSteps":["jkl","mm","mmm"],' + 
        							'"showTitleImageOnDetailPage":true,"body":"<p>Test Event 01 DS0001 - content</p>","summary":null,' + 
        							'"listOfOrganizers":[{"userId":"' + adminUserObj.Id + '","url":null,"title":null,"state":null,"role":null,' + 
        								'"img":"https://c.na34.content.force.com/profilephoto/72961000000DSit/T","peopleId":"' + peopleObj.Id + 
        								'","name":"Arav Sirohi","location":null,"id":"' + adminUserObj.Id + '",' + 
        								'"department":null,"country":null,"city":null,' + 
        								'"canFollow":null,"address":null,"$order":2}],"mapUrl":"Https://www.google.com","directions":["Go to India","Go to Simpplr"],' + 
        							'"publishAt":"2017-01-01T00:00:00","rsvp":{"hasMaybeOption":true,"capacityCount":"10","noteLabel":"Size","dueAtDate":"2017-07-26T01:15:00-06:00"},' + 
        							'"promoteAt":"2017-01-01T00:00:00","hasDirections":true,"hasRsvp":true,"isRsvpMaybeAllowed":false,' + 
        							'"titleImage":null,"titleImageCaption":null,"deletedTitleImage":[],"topics":{"records":[]},"deletedTopics":[],"deletedOrganizers":[],"files":[],"deletedFiles":[]}';
        
        SiteAddEventDataServer serverObj = new SiteAddEventDataServer();
        pgRef.getParameters().put('data', dataString);
        pgRef.getParameters().put('siteId', siteId);
        
        pgRef.getParameters().put('action', 'approve');
        pgRef.getParameters().put('data', publistDataString);
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.status, 'Running as expected');
        
    	Test.stopTest();	
    }

    @isTest public static void testActionUpdateDraft() { 
        init();
        Test.startTest();
        
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'SiteAddEventDataServer');
        
        User standardUserObj = getStandardUser();
        User adminUserObj = getAdminUser();
        People__c peopleObj = getPeople(adminUserObj.Id);
        Simpplr_Site__c  siteObj = getSite();
        simpplr_content__c contentObj = getContent();
        siteId = siteObj.Id;
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));
        String dataString = '{"siteId":"' + siteId + '",' + 
                                    '"authoredBy":{"userId":"' + adminUserObj.Id + '","url":"https://c.na34.visual.force.com/apex/profileabout?id=' + peopleObj.Id + '",' + 
                                        '"title":"Mr","role":null,"img":"https://c.na34.content.force.com/profilephoto/72961000000F6qr/T",' + 
                                        '"peopleId":"' + peopleObj.Id + '","name":"Deepak Sirohi","location":null,' + 
                                        '"department":"Department_01","canFollow":null,' + 
                                        '"address":"Gurgaon,Haryana,India"},' + 
                                    '"title":"Test Event DS0001","startsAt":"2017-01-01T00:00:00","timezoneIso":"Asia/Colombo",' + 
                                    '"endsAt":"2020-12-31T00:00:00","isAllDayEvent":false,' + 
                                    '"location":"Delhi","isDirectionEnabled":true,"directionSteps":["jkl","mm","mmm"],' + 
                                    '"showTitleImageOnDetailPage":true,"body":"<p>Test Event 01 DS0001 - content</p>","summary":null,' + 
                                    '"listOfOrganizers":[{"userId":"' + adminUserObj.Id + '","url":null,"title":null,"state":null,"role":null,' + 
                                        '"img":"https://c.na34.content.force.com/profilephoto/72961000000DSit/T","peopleId":"' + peopleObj.Id + 
                                        '","name":"Arav Sirohi","location":null,"id":"' + adminUserObj.Id + '",' + 
                                        '"department":null,"country":null,"city":null,' + 
                                        '"canFollow":null,"address":null,"$order":2}],"mapUrl":"Https://www.google.com","directions":["Go to India","Go to Simpplr"],' + 
                                    '"publishAt":"2017-01-01T00:00:00","rsvp":{"hasMaybeOption":true,"capacityCount":"10","noteLabel":"Size","dueAtDate":"2017-07-26T01:15:00-06:00"},' + 
                                    '"promoteAt":"2017-01-01T00:00:00","hasDirections":true,"hasRsvp":true,"isRsvpMaybeAllowed":false,' + 
                                    '"titleImage":null,"titleImageCaption":null,"deletedTitleImage":[],"topics":{"records":[]},"deletedTopics":[],"deletedOrganizers":[],"files":[],"deletedFiles":[]}';
                
        
        String publistDataString = '{"siteId":"' + siteId + '","id":"' + contentObj.Id + '",' + 
        							'"authoredBy":{"userId":"' + adminUserObj.Id + '","url":"https://c.na34.visual.force.com/apex/profileabout?id=' + peopleObj.Id + '",' + 
        								'"title":"Mr","role":null,"img":"https://c.na34.content.force.com/profilephoto/72961000000F6qr/T",' + 
        								'"peopleId":"' + peopleObj.Id + '","name":"Deepak Sirohi","location":null,' + 
        								'"department":"Department_01","canFollow":null,' + 
        								'"address":"Gurgaon,Haryana,India"},' + 
        							'"title":"Test Event DS0001","startsAt":"2017-01-01T00:00:00","timezoneIso":"Asia/Colombo",' + 
        							'"endsAt":"2020-12-31T00:00:00","isAllDayEvent":false,' + 
        							'"location":"Delhi","isDirectionEnabled":true,"directionSteps":["jkl","mm","mmm"],' + 
        							'"showTitleImageOnDetailPage":true,"body":"<p>Test Event 01 DS0001 - content</p>","summary":null,' + 
        							'"listOfOrganizers":[{"userId":"' + adminUserObj.Id + '","url":null,"title":null,"state":null,"role":null,' + 
        								'"img":"https://c.na34.content.force.com/profilephoto/72961000000DSit/T","peopleId":"' + peopleObj.Id + 
        								'","name":"Arav Sirohi","location":null,"id":"' + adminUserObj.Id + '",' + 
        								'"department":null,"country":null,"city":null,' + 
        								'"canFollow":null,"address":null,"$order":2}],"mapUrl":"Https://www.google.com","directions":["Go to India","Go to Simpplr"],' + 
        							'"publishAt":"2017-01-01T00:00:00","rsvp":{"hasMaybeOption":true,"capacityCount":"10","noteLabel":"Size","dueAtDate":"2017-07-26T01:15:00-06:00"},' + 
        							'"promoteAt":"2017-01-01T00:00:00","hasDirections":true,"hasRsvp":true,"isRsvpMaybeAllowed":false,' + 
        							'"titleImage":null,"titleImageCaption":null,"deletedTitleImage":[],"topics":{"records":[]},"deletedTopics":[],"deletedOrganizers":[],"files":[],"deletedFiles":[]}';
        
        SiteAddEventDataServer serverObj = new SiteAddEventDataServer();
        pgRef.getParameters().put('data', dataString);
        pgRef.getParameters().put('siteId', siteId);
        
        pgRef.getParameters().put('action', 'updateDraft');
        pgRef.getParameters().put('data', publistDataString);
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.status, 'Running as expected');

    	Test.stopTest();	
    }

    @isTest 
    static void testActions2() {
        Test.startTest();
        init();
        
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'SiteAddEventDataServer');
        
        User standardUserObj = getStandardUser();
        User adminUserObj = getAdminUser();
        People__c peopleObj = getPeople(adminUserObj.Id);
        Simpplr_Site__c  siteObj = getSite();
        simpplr_content__c contentObj = getContent();
        siteId = siteObj.Id;
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));
        SiteAddEventDataServer serverObj = new SiteAddEventDataServer();
        SimpplrContext.PPVideoProvider = 'skype';
        pgRef.getParameters().put('action', 'invite');
        pgRef.getParameters().put('data', '{"id":"' + contentObj.Id + '","siteId":"' + siteObj.Id + '","isPrivate":false, "peopleList":["' + peopleObj.Id +'"], "sendInvitationMail": true}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.status, 'Running as expected');
        
        TestHelper.createRSVPResponse(contentObj.Id, peopleObj.Id, 'yes');
        pgRef.getParameters().put('action', 'getAttending');
        pgRef.getParameters().put('data', '{"contentId":"' + contentObj.Id + '","size":"2"}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.status, 'Running as expected');
        
        pgRef.getParameters().put('action', 'invitedUsers');
        pgRef.getParameters().put('data', '{"contentId":"' + contentObj.Id + '","nextPageToken":"3","size":"3"}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.status, 'Running as expected');

        pgRef.getParameters().put('action','startContentEdit');
        pgRef.getParameters().put('data','{"contentId":"'+contentObj.id+'","versionNumber":1}');
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.status, 'Running as expected');

        pgRef.getParameters().put('action','sendEventUpdateMail');
        pgRef.getParameters().put('data','{"contentId":"'+contentObj.id+'"}');
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.status, 'Running as expected');

        Test.stopTest();
    }
    
    
    @isTest static void testUndefinedAction() {
        init();
        SiteAddEventDataServer serverObj = new SiteAddEventDataServer();
        
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'SiteAddEventDataServer');
        pgRef.getParameters().put('action', 'undefinedAction');
        pgRef.getParameters().put('data', '{}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        //data is missing
        System.assertEquals('error', serverObj.Response.status, 'Running as expected');
    }
    
    @isTest static void testConvertToWrapperMethod () {
        init();
        PageReference pgRef = Page.DataServerRW;
        List<App_Config__c> appConfigList = [SELECT id,Calendar_Google_Enabled__c, Calendar_Outlook_Web_Enabled__c,
                Calendar_App_Enabled__c,Calendar_Office365_Enabled__c FROM App_Config__c LIMIT 1];
        App_Config__c appConfig = (appConfigList.size() > 0 ? appConfigList[0] : new App_Config__c());
        appConfig.Calendar_Google_Enabled__c = false;
        appConfig.Calendar_Outlook_Web_Enabled__c = false;
        appConfig.Calendar_App_Enabled__c = false;
        appConfig.Calendar_Office365_Enabled__c = false;
        update appConfig;
        Simpplr_Site__c  siteObj = getSite();
        User adminUserObj = getAdminUser();
        People__c peopleObj = getPeople(adminUserObj.Id);
        Simpplr_Content__c simpplrContent = TestHelper.createContent('simpplr event', 'Event', 'Approved', adminUserObj , siteObj);
        TestHelper.createContentCollaborator(simpplrContent.id, peopleObj.id,'Organizer');
        File__c fileObj = TestHelper.createContentTitleImage(simpplrContent.id);
        fileObj.Title_Image_Type__c = 'thumbnail';
        update fileObj;
        SiteAddEventDataServer serverObj = new SiteAddEventDataServer();
        serverObj.convertToContentWrapper (simpplrContent);
        System.assertEquals('success', serverObj.Response.status, 'Running as expected');
        fileObj.Title_Image_Type__c = 'widescreen';
        update fileObj;
        serverObj.convertToContentWrapper (simpplrContent);
        fileObj.Title_Image_Type__c = 'original';
        update fileObj;
        serverObj.convertToContentWrapper (simpplrContent);
        fileObj.Title_Image_Type__c = null;
        fileObj.Location__c = 'attachment';
        update fileObj;
        serverObj.convertToContentWrapper (simpplrContent);
        fileObj.Location__c = 'inline';
        update fileObj;
        serverObj.convertToContentWrapper (simpplrContent);

        TestHelper.createCarousel(siteObj.id,simpplrContent.id);
        pgRef.getParameters().put('action', 'get');
        pgRef.getParameters().put('origin', 'mobile');
        pgRef.getParameters().put('User-Agent', 'mobile');
        pgRef.getParameters().put('contentId', simpplrContent.Id );
        pgRef.getParameters().put('data', '{"contentType":"event"}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, 'Running as expected');
    }
    
    @isTest public static void testActionsupdate() { 
        Test.startTest();  
        init();       
        PageReference pgRef = Page.DataServerRW;
        SiteAddEventDataServer serverObj = new SiteAddEventDataServer();
        pgRef.getParameters().put('target', 'SiteAddEventDataServer');
        
        User adminUserObj = getAdminUser();
        People__c peopleObj = getPeople(adminUserObj.Id);
        Simpplr_Site__c  siteObj = getSite();
        simpplr_content__c contentObj = getContent();
        contentObj.Status__c = 'Published';
        update contentObj;
        siteId = siteObj.Id;
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false)); 
        pgRef.getParameters().put('action','update');
        pgRef.getParameters().put('siteId', siteId);
        pgRef.getParameters().put('contentId', contentObj.Id);
        pgRef.getParameters().put('data', '{"authoredBy":{"peopleId":"'+peopleObj.Id+'"},"publishAt":"2020-04-15T00:00:00","siteId":"'+siteId+'","startsAt":"2020-04-15T00:00:00+05:30","isAllDay":true,"endsAt":"2020-04-15T23:59:59+05:30","timezoneIso":"Asia/Colombo","hasRsvp":false,"location":"Delhi","title":"TestEvent1","isFeedEnabled":true}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.status, 'Running as expected');
        
        Test.stopTest();
    }
    
    @isTest public static void testActionsupdate2() { 
        Test.startTest();  
        init();       
        PageReference pgRef = Page.DataServerRW;
        SiteAddEventDataServer serverObj = new SiteAddEventDataServer();
        pgRef.getParameters().put('target', 'SiteAddEventDataServer');
        
        User adminUserObj = getAdminUser();
        People__c peopleObj = getPeople(adminUserObj.Id);
        Simpplr_Site__c  siteObj = getSite();
        simpplr_content__c contentObj = getPublishedContent();
        siteId = siteObj.Id;
        fileObj = [Select id, MIME_Type__c From File__c where title__c='TitleImage' And Location__c='media' LIMIT 1];
        cvObj = [select Id, Title, ContentDocumentId, PathOnClient, IsDeleted, Origin, CreatedDate FROM ContentVersion where Title ='Title_File_SiteAddEvent'][0];
        String updateDataString = '{"siteId":"' + siteId + '","id":"' + contentObj.Id + '",' + 
                            '"authoredBy":{"userId":"' + adminUserObj.Id + '","url":"https://c.na34.visual.force.com/apex/profileabout?id=' + peopleObj.Id + '",' + 
                                '"title":"Mr","role":null,"img":"https://c.na34.content.force.com/profilephoto/72961000000F6qr/T",' + 
                                '"peopleId":"' + peopleObj.Id + '","name":"Deepak Sirohi","location":null,' + 
                                '"department":"Department_01","canFollow":null,' + 
                                '"address":"Gurgaon,Haryana,India"},' + 
                            '"title":"Test Event DS0001","startsAt":"2017-01-01T00:00:00","timezoneIso":"Asia/Colombo",' + 
                            '"endsAt":"2020-12-31T00:00:00","isAllDayEvent":false,' + 
                            '"location":"Delhi","isDirectionEnabled":true,"directionSteps":["jkl","mm","mmm"],' + 
                            '"showTitleImageOnDetailPage":true,"body":"<p>Test Event 01 DS0001 - content</p>","summary":null,' + 
                            '"listOfOrganizers":[{"userId":"' + adminUserObj.Id + '","url":null,"title":null,"state":null,"role":null,' + 
                                '"img":"https://c.na34.content.force.com/profilephoto/72961000000DSit/T","peopleId":"' + peopleObj.Id + 
                                '","name":"Arav Sirohi","location":null,"id":"' + adminUserObj.Id + '",' + 
                                '"department":null,"country":null,"city":null,' + 
                                '"canFollow":null,"address":null,"$order":2}],"mapUrl":"Https://www.google.com","directions":["Go to India","Go to Simpplr"],' + 
                            '"publishAt":"2017-01-01T00:00:00","rsvp":{"hasMaybeOption":true,"capacityCount":"10","noteLabel":"Size","dueAtDate":"2017-07-26T01:15:00-06:00"},' + 
                            '"promoteAt":"2017-01-01T00:00:00","hasDirections":true,"hasRsvp":true,"isRsvpMaybeAllowed":false,' + 
                            '"titleImage":null,"titleImageCaption":null,"deletedTitleImage":[],"topics":{"records":[]},"deletedTopics":[],"deletedOrganizers":[],"files":[],"deletedFiles":[],'+
                            '"listOfFiles":[{"id":null,"fileId":null,"contentVersionId":"' + cvObj.id + '","contentDocumentId":"' + cvObj.contentDocumentId+ '","url":"testurl","fileUrl":"testurl","downloadUrl":"testurl","title":"testimage","size":"3332","fileType":"' + fileObj.MIME_Type__c + '","type":"' + fileObj.MIME_Type__c + '","externalFileId":"testexternalId","isImage":true}]}';
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false)); 
        pgRef.getParameters().put('action','update');
        pgRef.getParameters().put('siteId', siteId);
        pgRef.getParameters().put('contentId', contentObj.Id);
        pgRef.getParameters().put('data', updateDataString);
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.status, 'Running as expected');
        Test.stopTest();
    }

    @isTest static void testGet() {
        Test.startTest();
        Simpplr_Site__c siteObj = getSite();
        User adminUserObj = getAdminUser();
        People__c peopleObj = getPeople(adminUserObj.Id);
        
        Simpplr_Content__c contentObj = getContent();
        contentObj.Version__c = 1;
        contentObj.Text_Intro__c = 'abcd';
        contentObj.Text_Main__c = 'def';
        contentObj.Text_Main_Continued__c='ghi';
        contentObj.Text_Json__c = '{}';
        contentObj.Event_Location__c = 'test';
        contentObj.Event_Directions_Enabled__c = true;
        contentObj.Event_Map_URL__c='www.test.simpplr.org.1';
        contentObj.Event_Is_All_Day__c = false;
        contentObj.Event_TimezoneSidKey__c = 'America/Los_Angeles';
        contentObj.Event_Start_DateTime__c = System.today().addDays(2);
        update contentObj;
        
        Content_History__c historyObj = new Content_History__c();
        historyObj.Content__c = contentObj.id;
        historyObj.Version__c = contentObj.Version__c;
        historyObj.File_Json__c = JSON.serialize(contentObj.File_Simpplr_Content__r);
        historyObj.Content_Json_Part1__c = JSON.serialize(contentObj);
        Content_Collaborator__c collaboratorObj= TestHelper.createContentCollaborator(contentObj.id, peopleObj.id,'Organizer');
        historyObj.Collaborator_Json__c = JSON.serialize(new List<Content_Collaborator__c>{collaboratorObj});
        insert historyObj;
        
        SiteAddEventDataServer serverObj = new SiteAddEventDataServer();
        PageReference pgRef = Page.DataServerRW;
        
        pgRef.getParameters().put('action', 'get');
        pgRef.getParameters().put('data','{"contentId":"'+contentObj.id+'"}');
        pgRef.getParameters().put('contentId', contentObj.id);
        pgRef.getParameters().put('siteId', contentObj.site__c);
        pgRef.getParameters().put('versionHistoryId', '1');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        //System.assertEquals('success', serverObj.Response.status, serverObj.response.message);
        Test.stopTest();
    }
    
    @isTest static void testUpdateEvent() {
        Test.startTest();
        init();

        User testAdminUsr = TestHelper.createUser('SiteAddEventDataServer_AdminUser', null, true); 
        system.runAs(testAdminUsr){
            Simpplr_Site__c siteObj = getSite();
            User adminUserObj = getAdminUser();
            People__c peopleObj = getPeople(adminUserObj.Id);
            
            Simpplr_Content__c contentObj = getContent();
            contentObj.Primary_Author__c = peopleObj.id;
            update contentObj;
            Content_Collaborator__c contentCollabratorObj = TestHelper.createContentCollaborator(contentObj.id, peopleObj.id, 'event');
            Event_RSVP_Response__c eventRsvpResObj = TestHelper.createRSVPResponse(contentObj.id, peopleObj.id, 'Yes');
            SiteAddEventDataServer serverObj = new SiteAddEventDataServer();
            PageReference pgRef = Page.DataServerRW;
            pgRef.getParameters().put('target', 'SiteAddEventDataServer');
            pgRef.getParameters().put('action','sendEventUpdateMail');
            Test.setCurrentPage(pgRef);
            pgRef.getParameters().put('data', '{"authoredBy":{"peopleId":"'+peopleObj.Id+'"},"publishAt":"2020-04-15T00:00:00","siteId":"'+siteId+'","startsAt":"2020-04-15T00:00:00+05:30","isAllDay":true,"endsAt":"2020-04-15T23:59:59+05:30","timezoneIso":"Asia/Colombo","hasRsvp":false,"location":"Delhi","title":"TestEvent1","isFeedEnabled":true,"contentId":"'+contentObj.Id+'"}');
            serverObj.handleRequest();
            System.assertEquals('error', serverObj.Response.status, 'No permission/access on content');
            Test.stopTest();
        }
    }
        
    @isTest static void testUpdateEvent2() {
        Test.startTest();
        init();
        User testAdminUsr = TestHelper.createUser('SiteAddEventDataServer_AdminUser', null, true); 

        Simpplr_Site__c siteObj = getSite();
        User adminUserObj = getAdminUser();
        People__c peopleObj = getPeople(adminUserObj.Id);
        
        Simpplr_Content__c contentObj = getContent();
        contentObj.Primary_Author__c = peopleObj.id;
        update contentObj;
        Content_Collaborator__c contentCollabratorObj = TestHelper.createContentCollaborator(contentObj.id, peopleObj.id, 'event');
        Event_RSVP_Response__c eventRsvpResObj = TestHelper.createRSVPResponse(contentObj.id, peopleObj.id, 'Yes');
        SiteAddEventDataServer serverObj = new SiteAddEventDataServer();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'SiteAddEventDataServer');
        pgRef.getParameters().put('action','sendEventUpdateMail');
        Test.setCurrentPage(pgRef);
        pgRef.getParameters().put('data', '{"authoredBy":{"peopleId":"'+peopleObj.Id+'"},"publishAt":"2020-04-15T00:00:00","siteId":"'+siteId+'","startsAt":"2020-04-15T00:00:00+05:30","isAllDay":true,"endsAt":"2020-04-15T23:59:59+05:30","timezoneIso":"Asia/Colombo","hasRsvp":false,"location":"Delhi","title":"TestEvent1","isFeedEnabled":true,"contentId":"'+contentObj.Id+'"}');
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.status, 'Running as expected');
        Test.stopTest();
    }
}