/**
 * This class contains unit tests for validating the behavior of Apex class BatchEFSPeoplePreferenceUpdate
 */
@isTest
public with sharing class BatchEFSPeoplePreferenceUpdateTest {
    @testSetup static void setup() {
    	App_Config__c appConfigRecord = TestHelper.setupAppConfig();
    	appConfigRecord.Allow_Comments__c=false;
    	appConfigRecord.Allow_Public_Contribution__c=false;
    	update appConfigRecord;
    	
    	People__c ppl = TestHelper.createPeopleRecordForUser(UserInfo.getUSerId());
        User userAsOwner = TestHelper.createUser('Simpplr_usrAsSiteOwner', null, false);
        User userAsMember = TestHelper.createUser('Simpplr_usrAsMember', null, false);
        CollaborationGroup cgroup = TestHelper.createCollaborationGroup('MySettingsAppManagerCtrlTest_Grp1','Public');
        
        TestHelper.createCollaborationGroupMember(cgroup.Id, userAsOwner.id,'Admin');
		TestHelper.changeCollaborationGroupOwner(cgroup.id, userAsOwner.Id);       
		TestHelper.createCollaborationGroupMember(cgroup.Id, userAsMember.id,'Standard');
    }
    
   @isTest static void AdminDelTest() {
		Test.StartTest();
		
		Database.executeBatch(new BatchEFSPeoplePreferenceUpdate('ADMINDEL'));
		
		Test.StopTest();

		System.assert(true, 'Running as expected');
	}
	
   @isTest static void SetMountFlagTest() {
		Test.StartTest();
		
		Database.executeBatch(new BatchEFSPeoplePreferenceUpdate('SETMOUNTFLAG'));
		
		Test.StopTest();

		System.assert(true, 'Running as expected');
	}
	@isTest static void AppDelTest() {
		Test.StartTest();
		
		Database.executeBatch(new BatchEFSPeoplePreferenceUpdate('APPDEL'));
		
		Test.StopTest();

		System.assert(true, 'Running as expected');
	}
}