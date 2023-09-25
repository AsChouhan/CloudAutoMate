/**
 * This class contains unit tests for validating the behavior of Apex class BatchEFSFolderSyncTest 
 */
@isTest
private class BatchEFSFolderSyncTest {
	
	@testSetup static void setup() {
    	App_Config__c appConfigRecord = TestHelper.setupAppConfig();
    	People__c ppl = TestHelper.createPeopleRecordForUser(UserInfo.getUSerId());
        User userAsOwner = TestHelper.createUser('Simpplr_usrAsSiteOwner', null, false);
        User userAsMember = TestHelper.createUser('Simpplr_usrAsMember', null, false);
        People_Preference__c peoplePreferenceRecord = TestHelper.createPeoplePreference(ppl.Id);
        
        List<App_Integration__c> appIntList  = TestHelper.createAppIntegrationRecords(false, new Set<String>{'dropbox', 'sharepoint', 'onedrive'}); 
		List<People_Integration__c> peopleIntList = TestHelper.createPeopleIntegrationRecords(appIntList, ppl.id, 'sadadqeq');
		
        CollaborationGroup cgroup = TestHelper.createCollaborationGroup('MySettingsAppManagerCtrlTest_Grp1','Public');
        cgroup.owner = [SELECT id FROM User WHERE Id=: UserInfo.getUserId()][0];
        update cgroup;

		TestHelper.createCollaborationGroupMember(cgroup.Id, userAsMember.id,'Standard');
    }
    
 	private static void setIntegrationsConnected(String storage, Boolean connectFlag) {
 		App_Integration__c eAppInteg = SimpplrContext.Integrations.get(storage);
 		eAppInteg.Integration_Enabled__c = true;
 		eAppInteg.Connected__c = connectFlag;
 		update eAppInteg;
 		
 		List<People_Integration__c> pplList = new List<People_Integration__c>();
 		for(People_Integration__c pplObj : [Select Id, Name, Connected__c FROM People_Integration__c WHERE name=:storage]) {
 			pplObj.Connected__c = connectFlag;
 			pplList.add(pplObj);
 		}
 		
 		update pplList;
 	}   
    
    private static Simpplr_Site__c getSimpplrSite(){
    	 return([select id,File_Storage_Source__c from Simpplr_Site__c where name = 'MySettingsAppManagerCtrlTest_Grp1']);
    }
        
    private static void initDB() {
		Simpplr_Site__c site = getSimpplrSite();
		site.File_Storage_Source__c = 'dropbox';
		update site;
		
		Folder__c folderObj = TestHelper.createChatterFolder('testFolder01', null, getSimpplrSite().id, 'Intranet', null, 'readwrite');		
		folderObj.Type__c = 'dropbox';
		folderObj.Is_System_Folder__c = true;
		update folderObj;
    }
    
   @isTest static void batchFolderSyncAppDropbox() {
    	initDB();
		Test.startTest();
		setIntegrationsConnected('dropbox', true);
		Database.executeBatch(new BatchEFSFolderSync('APP', UserInfo.getUserId(), 'dropbox'), 200);
		Database.executeBatch(new BatchEFSFolderSync('ADMINDEL', JSON.serialize(new Set<String>{getSimpplrSite().Id}), 'dropbox'), 200);
		Database.executeBatch(new BatchEFSFolderSync('APPDEL', UserInfo.getUserId(), 'dropbox'), 200);
		setIntegrationsConnected('dropbox', false);
		Test.stopTest();
		People_Integration__c pplIntegration = [SELECT Id, Connected__c FROM People_Integration__c LIMIT 1];
		System.assertEquals(false,pplIntegration.Connected__c,'Running as expected');
	}
    
   @isTest static void batchFolderSyncUserDropbox() {
    	initDB();
		Test.startTest();
		setIntegrationsConnected('dropbox', true);
		Database.executeBatch(new BatchEFSFolderSync('USER', UserInfo.getUserId(), 'dropbox'), 200);
		Database.executeBatch(new BatchEFSFolderSync('USERDISCONNECT', UserInfo.getUserId(), 'dropbox'), 200);
		setIntegrationsConnected('dropbox', false);
		Test.stopTest();
		People_Integration__c pplIntegration = [SELECT Id, Connected__c FROM People_Integration__c LIMIT 1];
		System.assertEquals(false,pplIntegration.Connected__c,'Running as expected');
	}

   @isTest static void batchFolderSyncSiteDropbox() {
    	initDB();
		Test.startTest();
		setIntegrationsConnected('dropbox', true);
		Database.executeBatch(new BatchEFSFolderSync('SITEADD', JSON.serialize(new Set<String>{getSimpplrSite().Id}), 'dropbox'), 200);
		Database.executeBatch(new BatchEFSFolderSync('SITENAME', JSON.serialize(new Set<String>{getSimpplrSite().Id}), 'dropbox'), 200);
		Database.executeBatch(new BatchEFSFolderSync('SITEMADEPUBLIC', JSON.serialize(new Set<String>{getSimpplrSite().Id}), 'dropbox'), 200);
		Database.executeBatch(new BatchEFSFolderSync('SITEMADEPRIVATE', JSON.serialize(new Set<String>{getSimpplrSite().Id}), 'dropbox'), 200);
		Database.executeBatch(new BatchEFSFolderSync('SITEDEL', JSON.serialize(new Set<String>{getSimpplrSite().Id}), 'dropbox'), 200);
		setIntegrationsConnected('dropbox', false);
		Test.stopTest();
		People_Integration__c pplIntegration = [SELECT Id, Connected__c FROM People_Integration__c LIMIT 1];
		System.assertEquals(false,pplIntegration.Connected__c,'Running as expected');
	}
}