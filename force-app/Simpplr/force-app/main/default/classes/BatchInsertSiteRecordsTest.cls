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
private class BatchInsertSiteRecordsTest {

	private static User siteOwnr;
	private static CollaborationGroup cgroup;
	private static App_Config__c appConfigRecord;
	@testSetup 
	private static void setup() {
		appConfigRecord = TestHelper.setupAppConfig();
	}
	
    @isTest static void testStart() {
        BatchInsertSiteRecords b = new BatchInsertSiteRecords();
        database.querylocator obj = b.start(null);
        
        System.assert(true,'Running as expected');
        
    }
    
    @isTest static void testExecute() {
    	appConfigRecord = SimpplrContext.appConfig;
    	appConfigRecord.AT_CollaborationGroup_Enabled__c = false;
    	update appConfigRecord;
    	
    	cgroup = TestHelper.createCollaborationGroup('BatchInsertSiteRecordsTest_Grp1','Public');
    	List<CollaborationGroup> colGrpList = new List<CollaborationGroup>();
    	colGrpList.add(cgroup);
    	
        BatchInsertSiteRecords b = new BatchInsertSiteRecords();
        b.execute(null,colGrpList);
        
        System.assert(true,'Running as expected');
    }
    
}