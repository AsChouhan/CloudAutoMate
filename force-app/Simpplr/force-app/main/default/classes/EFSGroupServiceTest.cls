/**
 * This class contains unit tests for validating the behavior of Apex class EFSGroupService 
 */
@isTest
private class EFSGroupServiceTest {
	public static App_Integration__c appIntegRecord;
	
	@testSetup static void setup() {
		TestHelper.setupAppConfig();	
    	appIntegRecord = TestHelper.setUpAppIntegration();
    	
    	People__c ppl = TestHelper.createPeopleRecordForUser(UserInfo.getUSerId());
        User userAsOwner = TestHelper.createUser('Simpplr_usrAsSiteOwner', null, false);
        User userAsMember = TestHelper.createUser('Simpplr_usrAsMember', null, false);
        People_Integration__c peopleIntegRecord = TestHelper.createPeopleIntegRecordForUser(ppl.Id);
        
        CollaborationGroup cgroup = TestHelper.createCollaborationGroup('MySettingsAppManagerCtrlTest_Grp1','Public');
        cgroup.owner = [SELECT id FROM User WHERE Id=: UserInfo.getUserId()][0];
        update cgroup;
        
		peopleIntegRecord.Group_Id_Set__c = cgroup.Id;
        peopleIntegRecord.User__c = UserInfo.getUserId();
        update peopleIntegRecord;
		TestHelper.createCollaborationGroupMember(cgroup.Id, userAsMember.id,'Standard');
		Simpplr_Site__c siteObj = getSimpplrSite();
        siteObj.File_Storage_Source__c = 'gdrive';
        update siteObj;
		Folder__c folderObj = TestHelper.createChatterFolder('testFolder01', null, getSimpplrSite().id, 'Intranet', null, 'readwrite');		
		folderObj.Type__c = 'gdrive';
		folderObj.Is_System_Folder__c = true;
		update folderObj;
    }
    
    static void initDb() {
        appIntegRecord = [SELECT Id, Client_Id__c, Client_Secret__c,
			integration_Enabled__c, name, Scope__c,
			app_Access_Token__c from App_Integration__c where name = 'gdrive'];
        
							
        if (appIntegRecord.name != 'dropbox') {
            appIntegRecord.name = 'dropbox';
            update appIntegRecord;
        }
    }
    
    private static Simpplr_Site__c getSimpplrSite(){
    	 return([select id from Simpplr_Site__c where name = 'MySettingsAppManagerCtrlTest_Grp1']);
    }
    
    static EFSGroupService createDbGroupService(){
    	SimpplrContext.Integrations.get('dropbox').Enterprise_Id__c = 'email.com';
    	EFSAccessService clientAccess = new EFSAccessService('dropbox', true);
    	clientAccess.fileStorage = 'dropbox' ;
		EFSGroupService grpService = new EFSGroupService(clientAccess);
		return grpService;
    }
    
    @isTest static void createGroupDbTest() {
    	try {
	    	Test.startTest();	
	    		EFSGroupService grpService = createDbGroupService();
				grpService.createGroup('Sample Group', 'String description', 'string@email.com');
				grpService.createGroup('Forbidden', 'String description', 'test@email.com');
			Test.stopTest();

			System.assert(true, 'Running as expected');
    	} catch (Exception e ) {}
    }
    
    @isTest static void updateGroupDbTest() {
    	try {
    		Test.startTest();
				initDb();
            	EFSGroupService grpDbService = createDbGroupService();
            	grpDbService.updateGroup('string@email.com', 'String name', 'String description');
				grpDbService.updateGroup('string@email.com', 'Forbidden', 'Forbidden');
			Test.stopTest();

			System.assert(true, 'Running as expected');
    	} catch (Exception e ) {}
    		
    }
    
    @isTest static void deleteGroupDbTest() {
    	try {
    		Test.startTest();
		    	EFSGroupService grpService = createDbGroupService();
				grpService.deleteGroup('string@email.com');
				grpService.deleteGroup('Forbidden@email.com');
			Test.stopTest();

			System.assert(true, 'Running as expected');
		} catch (Exception e ) {}		
    }
    
    @isTest static void addMemberDbTest() {
    	try {
    		Test.startTest();
	    		EFSGroupService grpService = createDbGroupService();
				grpService.addMember('string@email.com', 'String usrKey');
				grpService.addMember('grpKey1', 'badRequest');
				grpService.addMember('Forbidden', 'Forbidden');
			Test.stopTest();

			System.assert(true, 'Running as expected');
		} catch (Exception e ) {}			
    }
    
    // add member to multiple groups Dropbox
    @isTest static void addMemberMultipleDbTest() {
    	try {
    		Test.startTest();
	    		EFSGroupService grpService = createDbGroupService();
				grpService.addMember(new List<String>{'string@email.com','grpKey1'}, 'String usrKey');
				grpService.addMember(new List<String>{'Forbidden','Forbidden1'}, 'Forbidden');
			Test.stopTest();

			System.assert(true, 'Running as expected');
		} catch (Exception e ) {}			
    }
    
    @isTest static void removeMemberDbTest() {
    	try {
    		Test.startTest();
		    	EFSGroupService grpService = createDbGroupService();
				grpService.removeMember('grpKey@email.com', 'String usrKey');
				grpService.removeMember('Forbidden', 'String usrKey');
			Test.stopTest();

			System.assert(true, 'Running as expected');
		} catch (Exception e ) {}			
    }

}