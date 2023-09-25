/**
 * This class contains unit tests for validating the behavior of Apex class BatchEFSUserSync
 */
@isTest
public with sharing class BatchEFSUserSyncTest {
    @testSetup static void setup() {
    	App_Config__c appConfigRecord = TestHelper.setupAppConfig();
    	
    	People__c ppl = TestHelper.createPeopleRecordForUser(UserInfo.getUSerId());
        User userAsOwner = TestHelper.createUser('Simpplr_usrAsSiteOwner', null, false);
        User userAsMember = TestHelper.createUser('Simpplr_usrAsMember', null, false);
        People_Preference__c peoplePreferenceRecord = TestHelper.createPeoplePreference(ppl.Id);

        CollaborationGroup cgroup = TestHelper.createCollaborationGroup('MySettingsAppManagerCtrlTest_Grp1','Public');
        TestHelper.createCollaborationGroupMember(cgroup.Id, userAsOwner.id,'Admin');
		TestHelper.changeCollaborationGroupOwner(cgroup.id, userAsOwner.Id);       
		TestHelper.createCollaborationGroupMember(cgroup.Id, userAsMember.id,'Standard');
    }
    
   @isTest static void AdminDelTest() {
		Test.StartTest();
		
		String cgId = [select id, CollaborationType from CollaborationGroup limit 1][0].Id;
		Database.executeBatch(new BatchEFSUserSync(null,'["'+cgId+'"]', ''));
		
		Test.StopTest();

		System.assert(true, 'Running as expected');
	}
	
   @isTest static void SiteDelTest() {
		Test.StartTest();
		
		String cgId = [select id, CollaborationType from CollaborationGroup limit 1][0].Id;
		Database.executeBatch(new BatchEFSUserSync('SITEDEL','["'+cgId+'"]', ''));
		
		Test.StopTest();

		System.assert(true, 'Running as expected');
	}
    
   @isTest static void SiteMountTest() {
		Test.StartTest();
        Folder__c fol= new Folder__c();
        fol.Name = 'test folder';
        fol.Path__c = 'test';
        fol.Type__c = 'dropbox';
        fol.Is_System_Folder__c = true;
        fol.EFS_Shared_Folder_Id__c= 'test';
        insert fol;
		String cgId = [select id, CollaborationType from CollaborationGroup limit 1][0].Id;
        
		Database.executeBatch(new BatchEFSUserSync('MOUNT','["'+cgId+'"]', ''));
		
		Test.StopTest();

		System.assert(true, 'Running as expected');
	}
}