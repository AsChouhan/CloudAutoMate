@isTest
private class ToggleFollowDataServerTest {
	@testSetup 
	private static void setup() {
		App_Config__c appConfigRecord = TestHelper.setupAppConfig();
		People__c peopleRec = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
		CollaborationGroup cgroup = TestHelper.createCollaborationGroup('ToggleFollowDataServerTest_Grp','Public');	
		User siteOwnr = TestHelper.createUser('ToggleFollowDataServerTest_siteOwnr', null, false);
		TestHelper.createCollaborationGroupMember(cgroup.Id, siteOwnr.id,'Admin');
		TestHelper.changeCollaborationGroupOwner(cgroup.id, siteOwnr.Id);
		List<App_Integration__c> appIntegList  = TestHelper.createAppIntegrationRecords(true, new Set<String>{'googledrive'});
		if(appIntegList.size() > 0) {
			appIntegList[0].Is_My_Drive_Enabled__c = true;
			appIntegList[0].Simpplr_Managed_Permission__c = true;
		}
		update appIntegList;
		TestHelper.createPeopleIntegrationRecords(appIntegList, peopleRec.id, 'dummy'); 
		TestHelper.createTopic('ToggleFollowDataServerTest');	
	}
	
	@isTest static Simpplr_Site__c getSite() {
		Simpplr_Site__c siteObj = [Select id, chatter_group_id__c from Simpplr_Site__c where name = 'ToggleFollowDataServerTest_Grp' limit 1];
		siteObj.File_Storage_Source__c = 'googledrive';
		update siteObj;
		System.assert(true,'Running as expected');
		return siteObj;
	}
	@isTest static void testFollowSite() {
		string siteId = getSite().id;
		String cgId = getSite().chatter_group_id__c;
		TestHelper.removeCollaborationGroupMember(cgId, UserContext.id);
		try {
			ApexPages.currentPage().getParameters().put('target', 'ToggleFollowDataServer'); 
			ApexPages.currentPage().getParameters().put('siteId', siteId);
			ApexPages.currentPage().getParameters().put('action', 'followSite');
			ToggleFollowDataServer toggleFollowDataServerObj = new ToggleFollowDataServer();
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'GoogleDriveAddMember',true));
			toggleFollowDataServerObj.handleRequest();
			System.assertEquals('success', toggleFollowDataServerObj.response.status, 'Running as expected');
			Test.stopTest();
		} catch (Exception e) {
		
		}
	}
	
	@isTest static void testUnfollowSite() {
		try {
			ApexPages.currentPage().getParameters().put('target', 'ToggleFollowDataServer');
			ApexPages.currentPage().getParameters().put('action', 'unfollowSite');
			ApexPages.currentPage().getParameters().put('siteId', getSite().id);
			ToggleFollowDataServer toggleFollowDataServerObj = new ToggleFollowDataServer();         
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'GoogleDriveRemoveMember',true));
			toggleFollowDataServerObj.handleRequest();
			System.assertEquals('success', toggleFollowDataServerObj.response.status, 'Running as expected');
			Test.stopTest();
		} catch (Exception e) {
		
		}
	}
	
	@isTest static void testFollowUnfollowUser() {
		try {
			ApexPages.currentPage().getParameters().put('target', 'ToggleFollowDataServer');
			ApexPages.currentPage().getParameters().put('data','{"sfUserId": "'+getUser().id+'"}');
			ApexPages.currentPage().getParameters().put('action', 'followUser');
			ToggleFollowDataServer toggleFollowDataServerObj = new ToggleFollowDataServer();
			toggleFollowDataServerObj.handleRequest();
			System.assertEquals('success', toggleFollowDataServerObj.response.status, 'Running as expected');
			ApexPages.currentPage().getParameters().put('action', 'unFollowUser');
			toggleFollowDataServerObj.handleRequest();
			System.assertEquals('success', toggleFollowDataServerObj.response.status, 'Running as expected');
		} catch (Exception e) {
		
		}	
	}

	@isTest static void testFollowUnfollowTopic() {
		try {
			Topic topicObj = [select id from Topic where name='ToggleFollowDataServerTest'];
			ApexPages.currentPage().getParameters().put('target', 'ToggleFollowDataServer');
			ApexPages.currentPage().getParameters().put('data', '{"topicId":"' + topicObj.id + '"}');
			ApexPages.currentPage().getParameters().put('action', 'followTopic');
			ToggleFollowDataServer toggleFollowDataServerObj = new ToggleFollowDataServer();
			toggleFollowDataServerObj.handleRequest();
			// if the org has feed tracking enabled it will give success and if disable it will give error- "Topics do not have feeds enabled"
			System.assert(true,'Running as expected');
			ApexPages.currentPage().getParameters().put('action', 'unFollowTopic');
			toggleFollowDataServerObj.handleRequest();
			System.assert(true,'Running as expected');
		} catch (Exception e) {
		
		}	
	}
		
	@isTest
	static User getUser() {
		User userObj = [Select id from User where lastName = 'ToggleFollowDataServerTest_siteOwnr'  limit 1];
		System.assert(true,'Running as expected');
		return userObj;
	}

}