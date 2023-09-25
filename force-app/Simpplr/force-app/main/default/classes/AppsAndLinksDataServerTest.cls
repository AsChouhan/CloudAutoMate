/**
 * @description
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
 private class AppsAndLinksDataServerTest {
    private static App_Config__c appConfig;
    private static PageReference pgRef;
    private static People__c peopleObj;

    @testSetUp
    private static void setup() {
        appConfig = TestHelper.setupAppConfig();
        TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
     }

    
     private static void init() {
    	pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','AppsAndLinksDataServer');
        Test.setCurrentPage(pgRef);
    }
    
    @isTest
    private static void testHandleRequestWhenActionNull(){
        init();
        pgRef.getParameters().put('action', null);
        pgRef.getParameters().put('segmentId', null);
        Test.setCurrentPage(pgRef);
        AppsAndLinksDataServer serverObj = new AppsAndLinksDataServer();
        Test.startTest();
        serverObj.handleRequest();
        System.assertEquals('error', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
    }

    @isTest
    private static void testHandleRequestWhenActionInvalid(){
        init();
        pgRef.getParameters().put('action', 'invalid');
        pgRef.getParameters().put('segmentId', null);
        Test.setCurrentPage(pgRef);
        AppsAndLinksDataServer serverObj = new AppsAndLinksDataServer();
        Test.startTest();
        serverObj.handleRequest();
        System.assertEquals('error', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
    }



    

    @isTest
    private static void testGetAppsAndLinksDataWhenSegmentNull(){
       init();

        //Get Apps and Links when segment Disabled
        pgRef.getParameters().put('action', 'get');
        pgRef.getParameters().put('segmentId', null);
        Test.setCurrentPage(pgRef);

        AppsAndLinksDataServer serverObj = new AppsAndLinksDataServer();

        Test.startTest();
            serverObj.handleRequest();

        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();

    }

    @isTest
    private static void testGetAppsAndLinksDataWhenSegmentNotNullWithSegmentIdNull(){
       init();

        //Get Apps and Links when segment enabled
        pgRef.getParameters().put('action', 'get');
        peopleObj = TestHelper.getPeopleRecordForUser(UserInfo.getUserId());
        Segment__c segmentObj = TestHelper.createSegment(peopleObj.id);
        pgRef.getParameters().put('segmentId', '');
        Test.setCurrentPage(pgRef);
        SimpplrContext.isSegmentsEnabled = true;
        SimpplrContext.isSegmentAppsNLinksEnabled = true;
        AppsAndLinksDataServer serverObj = new AppsAndLinksDataServer();

        Test.startTest();
        serverObj.handleRequest();
        System.assertEquals('error', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
    }

    @isTest
    private static void testGetAppsAndLinksDataWhenSegmentNotNull(){
       init();

        //Get Apps and Links when segment enabled
        pgRef.getParameters().put('action', 'get');
        peopleObj = TestHelper.getPeopleRecordForUser(UserInfo.getUserId());
        Segment__c segmentObj = TestHelper.createSegment(peopleObj.id);
        pgRef.getParameters().put('segmentId', segmentObj.id);
        Test.setCurrentPage(pgRef);
        SimpplrContext.isSegmentsEnabled = true;
        SimpplrContext.isSegmentAppsNLinksEnabled = true;
        AppsAndLinksDataServer serverObj = new AppsAndLinksDataServer();

        Test.startTest();
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
    }
    
    @isTest
    private static void testSaveAppsAndLinksDataWhenSegmentNull(){
       init();
        
        //Save Apps and Links when segment Disabled
        pgRef.getParameters().put('action', 'save');
        pgRef.getParameters().put('segmentId', null);
        pgRef.getParameters().put('data', '{"appsIntegrationProvider":"custom","customJson":"[{\\"name\\": \\"Google Drive\\",\\"url\\": \\"http://google.com/drive\\",\\"img\\": \\"https://imgurl\\"}]","externalLinks":[]}');
        Test.setCurrentPage(pgRef);

        AppsAndLinksDataServer serverObj = new AppsAndLinksDataServer();

        Test.startTest();
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
    }

   

    @isTest
    private static void testSaveAppsAndLinksDataWhenSegmentNotNull(){
       init();
        
        //Save Apps and Links when segment enabled
        pgRef.getParameters().put('action', 'save');
        peopleObj = TestHelper.getPeopleRecordForUser(UserInfo.getUserId());
        Segment__c segmentObj = TestHelper.createSegment(peopleObj.id);
        pgRef.getParameters().put('segmentId', segmentObj.id);
        pgRef.getParameters().put('data', '{"appsIntegrationProvider":"custom","customJson":"[{\\"name\\": \\"Google Drive\\",\\"url\\": \\"http://google.com/drive\\",\\"img\\": \\"https://imgurl\\"}]","externalLinks":[]}');
        Test.setCurrentPage(pgRef);
        SimpplrContext.isSegmentsEnabled = true;
        SimpplrContext.isSegmentAppsNLinksEnabled = true;
        AppsAndLinksDataServer serverObj = new AppsAndLinksDataServer();

        Test.startTest();
        serverObj.handleRequest();

        System.assertEquals('success', serverObj.response.status , serverObj.response.message);

        Test.stopTest();

    }

    @isTest
    private static void testGetPageFeature(){
        Test.startTest();
    	init();
        AppsAndLinksDataServer serverObj = new AppsAndLinksDataServer();
        String pageFeature = serverObj.getPageFeature();
        System.assertEquals(AccessManager.FEATURE_SIMPPLR , pageFeature , 'AppsAndLinksDataServer.testGetPageFeature Failed');
        Test.stopTest();

    }


 }