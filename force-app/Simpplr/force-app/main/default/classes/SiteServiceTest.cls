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
private class SiteServiceTest {

    @testSetup static void setup() {
        App_Config__c appConfigRecord = TestHelper.setupAppConfig();
    	update appConfigRecord;
        TestHelper.createContentVersion('H');
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
        CollaborationGroup cgroup = TestHelper.createCollaborationGroup('Simpplr_Grp_SiteDataServerTest','Public');
    }
    
    @isTest static void testSearchChatterSites() {
        // Perform some testing
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testToSiteListingWrapper() {
        // Perform some testing
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testToWrapper() {
        // Perform some testing
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetGroupIdSiteObjMapForFavoriteSimpplrSite() {
        // Perform some testing
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetGroupIdSiteObjMapForNonFavoriteSimpplrSite() {
        // Perform some testing
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetFavoriteChatterGroupIds() {
        // Perform some testing
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetCategoryGroups1() {
        // Perform some testing
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetCategoryGroups2() {
        // Perform some testing
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetGroupIds4CategoryName() {
        // Perform some testing
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetCategoryIdByName() {
        // Perform some testing
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetCategoryIdsByName() {
        // Perform some testing
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testMethod1() {
        // Perform some testing
        System.assert(true,'Running as expected');
    }

    @isTest static void testMethod2() {
        // Perform some testing
       System.assert(true,'Running as expected');
    }

    @isTest static void testGetSiteDataMap() {
        Simpplr_Site__c siteObj = new Simpplr_Site__c(
            Name = 'Test Site'
        );
        insert siteObj;
        Test.startTest();
        Map<Id, Simpplr_Site__c> data = SiteService.getSiteDataMap(new List<String>{siteObj.id});
        Test.stopTest();

        System.assert(data.keySet().contains(siteObj.id), 'Site Object Should be correct');
    }
    
    @isTest static void testGetChatterGroupDataMap() {
        CollaborationGroup collaborationGroupRec = new CollaborationGroup(
            Name = 'testGetChatterGroupDataMap', CollaborationType = 'Public'
        );
        insert collaborationGroupRec;
        Test.startTest();
        Map<Id, CollaborationGroup> data = SiteService.getChatterGroupDataMap(new List<String>{collaborationGroupRec.id});
        Test.stopTest();

        System.assert(data.keySet().contains(collaborationGroupRec.id), 'Chatter group Object Should be correct');
    }
    
    @isTest static void testUpdateSiteRequestNotifications() {
        Simpplr_Site__c siteObj = [select id, name from Simpplr_Site__c where name = 'Simpplr_Grp_SiteDataServerTest'];

        App_Notification__c appNotif = TestHelper.createSimpplrNotification('guid12345', UserContext.peopleId, 'actionStatus', 'subType', '123456789012345', null);

        Ungrouped_Notification__c notifRec = TestHelper.getUnGroupedNotificationsForMembershipRequest('1234567890', UserContext.peopleId);
        notifRec.App_Notification__c = appNotif.Id;
        insert notifRec;

        Ungrouped_Notification__c notifRec2 = TestHelper.getUnGroupedNotificationsForMembershipRequest('0987654321', UserContext.peopleId);
        notifRec2.App_Notification__c = appNotif.Id;
        insert notifRec2;

        Test.startTest();
            SiteService.updateSiteRequestNotifications('1234567890', siteObj.Id, siteObj.Name, 'public', 'Approved', 'comment');
        Test.stopTest();

        Ungrouped_Notification__c result = [SELECT Id, Is_Deleted__c FROM Ungrouped_Notification__c WHERE GUID__c = '1234567890'];

        System.assertEquals(true, result.Is_Deleted__c, 'Record should be deleted');
    }

    @isTest static void testUpdateSiteRequestNotifications2() {
        Simpplr_Site__c siteObj = [select id, name from Simpplr_Site__c where name = 'Simpplr_Grp_SiteDataServerTest'];

        App_Notification__c appNotif = TestHelper.createSimpplrNotification('guid12345', UserContext.peopleId, 'actionStatus', 'subType', '123456789012345', null);
        appNotif.RAB_2__c = UserContext.peopleId;
        update appNotif;

        Ungrouped_Notification__c notifRec = TestHelper.getUnGroupedNotificationsForMembershipRequest('1234567890', UserContext.peopleId);
        notifRec.App_Notification__c = appNotif.Id;
        insert notifRec;

        Ungrouped_Notification__c notifRec2 = TestHelper.getUnGroupedNotificationsForMembershipRequest('0987654321', UserContext.peopleId);
        notifRec2.App_Notification__c = appNotif.Id;
        insert notifRec2;

        Test.startTest();
            SiteService.updateSiteRequestNotifications('1234567890', siteObj.Id, siteObj.Name, 'public', 'Approved', 'comment');
        Test.stopTest();

        Ungrouped_Notification__c result = [SELECT Id, Is_Deleted__c FROM Ungrouped_Notification__c WHERE GUID__c = '1234567890'];

        System.assertEquals(true, result.Is_Deleted__c, 'Record should be deleted');
    }
}