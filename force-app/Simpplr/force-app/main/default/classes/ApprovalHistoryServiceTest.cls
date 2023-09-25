/**
 * @description This class contains unit tests for validating the behavior of Apex classes
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
private class ApprovalHistoryServiceTest {
    
    @isTest static void testGetModerationHistoryWithNoData() {
        User managerUserObj = TestHelper.createUser('Simpplr_mngr', null, false);
        String contentId = TestHelper.createContent('test content', 'test type', 'test status', managerUserObj, null).Id;
        Test.startTest();
        List<ApprovalHistoryService.ModerationHistoryWrapper> listOfModerationHistory = ApprovalHistoryService.getModerationHistory(contentId, 16, 16);
        Test.stopTest();

        System.assertEquals(0, listOfModerationHistory.size(), 'list size should be zero');
    }

    @isTest static void testGetModerationHistoryWithDataAuthorChanged() {
        User managerUserObj = TestHelper.createUser('Simpplr_mngr', null, false);
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
        String contentId = TestHelper.createContent('test content', 'test type', 'test status', managerUserObj, null).Id;

        Content_Audit_Trail__c auditTrailObj = new Content_Audit_Trail__c();
        auditTrailObj.Action_By__c = peopleObj.Id;
        auditTrailObj.Content__c = contentId;
        auditTrailObj.Action_By__r = peopleObj;
        auditTrailObj.Action_DateTime__c = DateTime.now();
        auditTrailObj.Action__c = 'Author Changed';
        auditTrailObj.New_Author__c = peopleObj.id;
        auditTrailObj.New_Author__r = peopleObj;
        insert auditTrailObj;

        Test.startTest();
        List<ApprovalHistoryService.ModerationHistoryWrapper> listOfModerationHistory = ApprovalHistoryService.getModerationHistory(contentId, 16, 0);
        Test.stopTest();

        System.assertNotEquals(0, listOfModerationHistory.size(), 'list size should not be zero');
        System.assertEquals('Author Changed', listOfModerationHistory[0].action, 'action should be same');
    }

    @isTest static void testGetModerationHistoryWithDataRejected() {
        User managerUserObj = TestHelper.createUser('Simpplr_mngr', null, false);
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
        String contentId = TestHelper.createContent('test content', 'test type', 'test status', managerUserObj, null).Id;

        Content_Audit_Trail__c auditTrailObj = new Content_Audit_Trail__c();
        auditTrailObj.Action_By__c = peopleObj.Id;
        auditTrailObj.Content__c = contentId;
        auditTrailObj.Action_By__r = peopleObj;
        auditTrailObj.Action_DateTime__c = DateTime.now();
        auditTrailObj.Action__c = 'Rejected';
        auditTrailObj.Comment__c = 'test comment';
        insert auditTrailObj;

        Test.startTest();
        List<ApprovalHistoryService.ModerationHistoryWrapper> listOfModerationHistory = ApprovalHistoryService.getModerationHistory(contentId, 16, 0);
        Test.stopTest();

        System.assertNotEquals(0, listOfModerationHistory.size(), 'list size should not be zero');
        System.assertEquals('test comment', listOfModerationHistory[0].reason, 'action should be same');
    }

    @isTest static void testGetModerationHistoryWithDataSiteChanged() {
        User managerUserObj = TestHelper.createUser('Simpplr_mngr', null, false);
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
        CollaborationGroup collGrp = TestHelper.createCollaborationGroup('FileDataServerTest_googleDriveSite', 'Public'); 
		Simpplr_Site__c site = [select id,File_Storage_Source__c,chatter_group_Id__c from Simpplr_Site__c where chatter_group_Id__c =: collGrp.id limit 1];
        String contentId = TestHelper.createContent('test content', 'test type', 'test status', managerUserObj, null).Id;

        Content_Audit_Trail__c auditTrailObj = new Content_Audit_Trail__c();
        auditTrailObj.Action_By__c = peopleObj.Id;
        auditTrailObj.Content__c = contentId;
        auditTrailObj.Action_By__r = peopleObj;
        auditTrailObj.Action_DateTime__c = DateTime.now();
        auditTrailObj.Action__c = 'Site Changed';
        auditTrailObj.Old_site__c = site.id;
        auditTrailObj.Old_site__r = site;
        auditTrailObj.New_site__c = site.id;
        auditTrailObj.New_site__r = site;
        insert auditTrailObj;

        Test.startTest();
        List<ApprovalHistoryService.ModerationHistoryWrapper> listOfModerationHistory = ApprovalHistoryService.getModerationHistory(contentId, 16, 0);
        Test.stopTest();

        System.assertNotEquals(0, listOfModerationHistory.size(), 'list size should not be zero');
        System.assertEquals(site.id, listOfModerationHistory[0].fromSite.id, 'old site od should be same');
    }

    @isTest static void testGetOnboardingHistoryWithNoData() {
        User managerUserObj = TestHelper.createUser('Simpplr_mngr', null, false);
        String contentId = TestHelper.createContent('test content', 'test type', 'test status', managerUserObj, null).Id;
        Test.startTest();
        List<ApprovalHistoryService.OnboardingHistoryWrapper> listOfOnboardingHistory = ApprovalHistoryService.getOnboardingHistory(contentId, 16, 16);
        Test.stopTest();

        System.assertEquals(0, listOfOnboardingHistory.size(), 'list size should be zero');
    }

    @isTest static void testGetOnboardingHistoryWithDataOnboardingSiteEnabled() {
        User managerUserObj = TestHelper.createUser('Simpplr_mngr', null, false);
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
        String contentId = TestHelper.createContent('test content', 'test type', 'test status', managerUserObj, null).Id;

        Content_Audit_Trail__c auditTrailObj = new Content_Audit_Trail__c();
        auditTrailObj.Action__c = 'Site Onboarding Enabled';
        auditTrailObj.Action_By__c = peopleObj.Id;
        auditTrailObj.Content__c = contentId;
        auditTrailObj.Action_By__r = peopleObj;
        auditTrailObj.Action_DateTime__c = DateTime.now();
        auditTrailObj.New_Author__c = peopleObj.id;
        auditTrailObj.New_Author__r = peopleObj;
        insert auditTrailObj;

        Test.startTest();
        List<ApprovalHistoryService.OnboardingHistoryWrapper> listOfOnboardingHistory = ApprovalHistoryService.getOnboardingHistory(contentId, 16, 0);
        Test.stopTest();

        System.assertNotEquals(0, listOfOnboardingHistory.size(), 'list size should not be zero');
        System.assertEquals('site', listOfOnboardingHistory[0].type, 'action should be same');
        System.assertEquals('added', listOfOnboardingHistory[0].action, 'action should be same');
    }

    @isTest static void testGetOnboardingHistoryWithDataOrgOnboardingEnabled() {
        User managerUserObj = TestHelper.createUser('Simpplr_mngr', null, false);
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
        String contentId = TestHelper.createContent('test content', 'test type', 'test status', managerUserObj, null).Id;

        Content_Audit_Trail__c auditTrailObj = new Content_Audit_Trail__c();
        auditTrailObj.Action__c = 'Org Onboarding Enabled';
        auditTrailObj.Action_By__c = peopleObj.Id;
        auditTrailObj.Content__c = contentId;
        auditTrailObj.Action_By__r = peopleObj;
        auditTrailObj.Action_DateTime__c = DateTime.now();
        auditTrailObj.Comment__c = 'test comment';
        insert auditTrailObj;

        Test.startTest();
        List<ApprovalHistoryService.OnboardingHistoryWrapper> listOfOnboardingHistory = ApprovalHistoryService.getOnboardingHistory(contentId, 16, 0);
        Test.stopTest();

        System.assertNotEquals(0, listOfOnboardingHistory.size(), 'list size should not be zero');
        System.assertEquals('org', listOfOnboardingHistory[0].type, 'action should be same');
        System.assertEquals('added', listOfOnboardingHistory[0].action, 'action should be same');
    }

    @isTest static void testGetOnboardingHistoryWithDataOrgOnboardingUpdate() {
        User managerUserObj = TestHelper.createUser('Simpplr_mngr', null, false);
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
        String contentId = TestHelper.createContent('test content', 'test type', 'test status', managerUserObj, null).Id;

        Content_Audit_Trail__c auditTrailObj = new Content_Audit_Trail__c();
        auditTrailObj.Action__c = 'Updated To Org Onboarding';
        auditTrailObj.Action_By__c = peopleObj.Id;
        auditTrailObj.Content__c = contentId;
        auditTrailObj.Action_By__r = peopleObj;
        auditTrailObj.Action_DateTime__c = DateTime.now();
        auditTrailObj.Comment__c = 'test comment';
        insert auditTrailObj;

        Test.startTest();
        List<ApprovalHistoryService.OnboardingHistoryWrapper> listOfOnboardingHistory = ApprovalHistoryService.getOnboardingHistory(contentId, 16, 0);
        Test.stopTest();

        System.assertNotEquals(0, listOfOnboardingHistory.size(), 'list size should not be zero');
        System.assertEquals('org', listOfOnboardingHistory[0].type, 'action should be same');
        System.assertEquals('updated', listOfOnboardingHistory[0].action, 'action should be same');
    }

    @isTest static void testGetOnboardingHistoryWithDataSiteOnboardingUpdate() {
        User managerUserObj = TestHelper.createUser('Simpplr_mngr', null, false);
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
        String contentId = TestHelper.createContent('test content', 'test type', 'test status', managerUserObj, null).Id;

        Content_Audit_Trail__c auditTrailObj = new Content_Audit_Trail__c();
        auditTrailObj.Action__c = 'Updated To Site Onboarding';
        auditTrailObj.Action_By__c = peopleObj.Id;
        auditTrailObj.Content__c = contentId;
        auditTrailObj.Action_By__r = peopleObj;
        auditTrailObj.Action_DateTime__c = DateTime.now();
        auditTrailObj.Comment__c = 'test comment';
        insert auditTrailObj;

        Test.startTest();
        List<ApprovalHistoryService.OnboardingHistoryWrapper> listOfOnboardingHistory = ApprovalHistoryService.getOnboardingHistory(contentId, 16, 0);
        Test.stopTest();

        System.assertNotEquals(0, listOfOnboardingHistory.size(), 'list size should not be zero');
        System.assertEquals('site', listOfOnboardingHistory[0].type, 'action should be same');
        System.assertEquals('updated', listOfOnboardingHistory[0].action, 'action should be same');
    }

    @isTest static void testGetOnboardingHistoryWithDataSiteOnboardingDisabled() {
        User managerUserObj = TestHelper.createUser('Simpplr_mngr', null, false);
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
        String contentId = TestHelper.createContent('test content', 'test type', 'test status', managerUserObj, null).Id;

        Content_Audit_Trail__c auditTrailObj = new Content_Audit_Trail__c();
        auditTrailObj.Action__c = 'Site Onboarding Disabled';
        auditTrailObj.Action_By__c = peopleObj.Id;
        auditTrailObj.Content__c = contentId;
        auditTrailObj.Action_By__r = peopleObj;
        auditTrailObj.Action_DateTime__c = DateTime.now();
        auditTrailObj.Comment__c = 'test comment';
        insert auditTrailObj;

        Test.startTest();
        List<ApprovalHistoryService.OnboardingHistoryWrapper> listOfOnboardingHistory = ApprovalHistoryService.getOnboardingHistory(contentId, 16, 0);
        Test.stopTest();

        System.assertNotEquals(0, listOfOnboardingHistory.size(), 'list size should not be zero');
        System.assertEquals('site', listOfOnboardingHistory[0].type, 'action should be same');
        System.assertEquals('removed', listOfOnboardingHistory[0].action, 'action should be same');
    }
}