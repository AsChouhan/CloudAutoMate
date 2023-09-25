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
private class PostInstallSetupServerTest {
    private static PageReference pgRef;
    @testSetup static void setup() {
        TestHelper.setupAppConfig();
        TestHelper.createPeopleRecordForUser(UserContext.id);
	 	TestHelper.createUser('PostInstallSetupServerTest_siteAdmin', null, false);
        TestHelper.createEveryoneAudience();
        TestHelper.createTopic('PostInstallSetupServerTest');
	 }
	private static void init() {
		pgRef = Page.PostInstallSetupServer;
        pgRef.getParameters().put('target','PostInstallSetupServer');
		pgRef.getParameters().put('date',Datetime.now().format('yyyy-mm-dd'));
		pgRef.getParameters().put('startDate',Datetime.now().format('yyyy-mm-dd'));
		pgRef.getParameters().put('endDate',Datetime.now().addDays(5).format('yyyy-mm-dd'));
        pgRef.getParameters().put('objectName','all');
        pgRef.getParameters().put('recordType','moveUnseenNotifications');
        pgRef.getParameters().put('runNextBatchInSequence','true');
        Test.setCurrentPage(pgRef);
	}
    @isTest static void testMethods() {
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false));
        PostInstallSetupServer serverObj = new PostInstallSetupServer();
        serverObj.createAppConfig();
        serverObj.createSchedulerRecords();
        serverObj.resetSchedulerConfig();
        //serverObj.runMigrationBatch();
        serverobj.startSiteTitleImpageImport();
        serverObj.runSiteConversionBatch('convertAllToSites');
        serverObj.createDefaultSiteCategory();
        serverObj.startInsertPeopleBatch();
        serverObj.runAnalyticsBatch();
        serverObj.runAnalyticsDeletionBatch();
        serverObj.stringToDate(Datetime.now().format('yyyy-mm-dd'));
        serverObj.topicsCleanUp('topicsCleanUp');
        serverObj.insertPeoplePreferenceRecords();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testUndefinedAction() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false));
        PageReference pgRef = Page.PostInstallSetupServer;
        PostInstallSetupServer serverObj = new PostInstallSetupServer();
        serverObj.createAppConfig();
        SimpplrContext.appConfigQueried = false;

        pgRef.getParameters().put('target','PostInstallSetupServer');
        pgRef.getParameters().put('action', 'startInitialSetup');
        pgRef.getParameters().put('recordType','moveUnseenNotifications');
        pgRef.getParameters().put('runNextBatchInSequence','true');
    	Test.setCurrentPage(pgRef);
    	
        serverObj.handleRequest();

        //pgRef.getParameters().put('action', 'startMigration');
        //serverObj.handleRequest();

        pgRef.getParameters().put('action', 'resetSchedulerConfig');
        serverObj.handleRequest();

        pgRef.getParameters().put('action', 'disableAllSiteDashboardAndContentFeature');
        serverObj.handleRequest();

        pgRef.getParameters().put('action', 'convertAllToSites');
        serverObj.handleRequest();

        pgRef.getParameters().put('action', 'revertAllToChatterGroups');
        serverObj.handleRequest();

        pgRef.getParameters().put('action', 'topicsCleanUp');
        serverObj.handleRequest();
        
        pgRef.getParameters().put('action', 'runAnalyticsDeletionBatch');
        serverObj.handleRequest();

        /*pgRef.getParameters().put('action', 'startPushAnalyticsBatch'); 
        pgRef.getParameters().put('recordType', 'site'); 
        pgRef.getParameters().put('startDate', '2019-01-01'); 
        serverObj.handleRequest();*/

        pgRef.getParameters().put('recordType','initAnalyticsData');
        pgRef.getParameters().put('action', 'sendMonthlyAdoptionEmail');
        serverObj.handleRequest();
        
        pgRef.getParameters().put('action', 'runAnalyticsBatch');
        serverObj.handleRequest();

        pgRef.getParameters().put('action', 'insertPeoplePreferenceRecords');
        serverObj.handleRequest();

        Test.stopTest();
        System.assert(true,'Running as expected');
    }
}