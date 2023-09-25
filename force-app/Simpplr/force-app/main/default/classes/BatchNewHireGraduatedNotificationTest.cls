@istest
public with sharing class BatchNewHireGraduatedNotificationTest {

    private static final String BATCH_NEW_HIRE_NOTIFICATION = 'newHireNotification';
    private static final String BATCH_MOVE_TO_FAVORITES = 'moveOnboardingToFavorites';
    private static User systemAdmin;
    private static User siteOwnr;
    private static CollaborationGroup cgroup;
    
    @testSetup
	public static void setUp() {
		TestHelper.setupAppConfig();  
        TestHelper.createUser('BatchNewHireGraduatedNotificationTest', null, false);
        People__c peopleObj = [SELECT Id FROM People__c WHERE User__r.LastName = 'BatchNewHireGraduatedNotificationTest'];
        peopleObj.Joining_Date__c = Date.today().addDays(-30);
        update peopleObj;
       	systemAdmin = TestHelper.createUser('ContentOnboardingTest_admin', null, true);
        siteOwnr = TestHelper.createUser('ContentOnboardingTest_siteOwnr', null, false);
        //Private site 
        cgroup = TestHelper.createCollaborationGroup('ContentOnboardingTest_Grp2','Private');
        Simpplr_Site__c  testSite2 = TestHelper.getSiteRecord(cgroup.Id);
        TestHelper.createCollaborationGroupMember(cgroup.Id, siteOwnr.id,'Admin');
        TestHelper.changeCollaborationGroupOwner(cgroup.id, siteOwnr.Id);
        testSite2.Is_Onboarding_Enabled__c=true;
        update testSite2;
        TestHelper.createSiteRole(peopleObj.id, testSite2.id);
        //Event CONTENT_STATUS_SITE_ONBOARDING testSite2
        Simpplr_Content__c simpplrContentPage = TestHelper.createContent('ContentOnboardingTest Page', 'Page', 'Approved', systemAdmin, testSite2);
        TestHelper.createContentTitleImage(simpplrContentPage.Id);
        simpplrContentPage.Content_Onboarding_Status__c = ServiceConstants.CONTENT_STATUS_SITE_ONBOARDING;
        update simpplrContentPage;
    }
    

    @isTest
    public static void testBatchNewHireGraduatedNotification(){
        Test.startTest();
            Database.executeBatch(new BatchNewHireGraduatedNotification(BATCH_NEW_HIRE_NOTIFICATION), 100);
		Test.stopTest();
        list<App_Notification__c> log = [SELECT Id, Category__c FROM App_Notification__c LIMIT 1];
        System.assertEquals('New_Hire_Graduated', log[0].Category__c, 'New Hire Graduated Notification not sent');
	}
}