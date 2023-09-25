@isTest private class BatchContentOnboardingEmailDigestTest {
    
    private static User systemAdmin;
    private static User siteOwnr;
    private static CollaborationGroup cgroup;

    @TestSetup static void setup() {
        TestHelper.setupAppConfig();
        People__c people = TestHelper.createPeopleRecordForUser(UserContext.id);
        People_Preference__c preference = TestHelper.createPeoplePreference(people.Id);
        Test.startTest();
        people.Joining_Date__c = Date.today().addDays(-5);
        people.Is_Deleted__c = false;
        update people;
        preference.Email_Onboarding_Frequency__c = 'Weekly';
        preference.Is_Deleted__c = false;
        update preference;

        systemAdmin = TestHelper.createUser('ContentOnboardingTest_admin', null, true);
        siteOwnr = TestHelper.createUser('ContentOnboardingTest_siteOwnr', null, false);
        //Private site 
        cgroup = TestHelper.createCollaborationGroup('ContentOnboardingTest_Grp2','Private');
        Simpplr_Site__c  testSite2 = TestHelper.getSiteRecord(cgroup.Id);
        TestHelper.createCollaborationGroupMember(cgroup.Id, siteOwnr.id,'Admin');
        TestHelper.changeCollaborationGroupOwner(cgroup.id, siteOwnr.Id);
        TestHelper.createSiteRole(people.id, testSite2.id);
        //Event CONTENT_STATUS_SITE_ONBOARDING testSite2
        Simpplr_Content__c simpplrContentPage = TestHelper.createContent('ContentOnboardingTest Page', 'Page', 'Approved', systemAdmin, testSite2);
        TestHelper.createContentTitleImage(simpplrContentPage.Id);
        simpplrContentPage.Content_Onboarding_Status__c = ServiceConstants.CONTENT_STATUS_SITE_ONBOARDING;
        update simpplrContentPage;
        //Event CONTENT_STATUS_SITE_ONBOARDING testSite2
        Simpplr_Content__c simpplrContentEvent = TestHelper.createContent('ContentOnboardingTest Event', 'Event', 'Approved', systemAdmin, testSite2);
        TestHelper.createContentTitleImage(simpplrContentEvent.Id);
        simpplrContentEvent.Content_Onboarding_Status__c = ServiceConstants.CONTENT_STATUS_ORG_ONBOARDING;
        update simpplrContentEvent;
        Test.stopTest();
    }
    
    @isTest static void testBatchContentOnboardingEmailDigest() {
        Test.startTest();
            String batchprocessid = DataBase.executeBatch(new BatchContentOnboardingEmailDigest());
        Test.stopTest();
        AsyncApexJob currentJob = [SELECT Id, Status, NumberOfErrors FROM AsyncApexJob WHERE Id = :batchprocessid];
        System.assertEquals(true, (currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0), 'Running as expected');
    }
}