@isTest
private class RequestApprovalDataServerTest {
	@testSetup 
    private static void setup() {
		App_config__c appConfigObj = TestHelper.setupAppConfig();
		User siteOwnr = TestHelper.createUser('RequestApprovalDataServerTest_siteOwner', null, false);
		CollaborationGroup cgroup = TestHelper.createCollaborationGroup('RequestApprovalDataServerTest_Grp1','Private');
        Simpplr_Site__c testSite = [Select id From Simpplr_Site__c where name =: 'RequestApprovalDataServerTest_Grp1'];  
        TestHelper.shareSitesToAllPeople(new List<String>{testSite.Id});
		TestHelper.createCollaborationGroupMember(cgroup.Id, siteOwnr.id,'Standard');
		TestHelper.changeCollaborationGroupOwner(cgroup.id, siteOwnr.Id);
		TestHelper.removeCollaborationGroupMember(cgroup.id, UserContext.id);
		CollaborationGroupMemberRequest cGrpMem= TestHelper.createCollaborationGroupMemberRequest(cgroup.id, UserContext.id);
		People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
		TestHelper.createPeoplePreference(peopleObj.id);
        Simpplr_Content__c conObj = TestHelper.createContent('simpplr test Page', 'Page', 'Approved', siteOwnr, testSite);
        conObj.Is_Deleted__c = false;
        update conObj;
        Must_Read_Audit__c mustReadObj = TestHelper.createMustReadAudit( conObj.Id, 'site_members' , peopleObj.id);
        mustReadObj.Removed_DateTime__c = null;
        update mustReadObj;
		App_Notification__c notificationObj =TestHelper.createSimpplrNotification('Dummy',UserContext.peopleId,null,'Pending',cGrpMem.id,null);
        notificationObj.Status__c = 'Pending';
        notificationObj.Object_Type__c = 'CollaborationGroupMemberRequest';
        update notificationObj;
		System.assert(true,'Running as expected');
    }
    
  private static void init() {
    	PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','RequestApprovalDataServer');
        Test.setCurrentPage(pgRef);
	}
    
    @isTest static void testGet(){
        Test.startTest();
        PageReference pageRef = Page.DataServerRW;
        CollaborationGroup cgroup =[Select id From CollaborationGroup where Name =: 'RequestApprovalDataServerTest_Grp1'];
        CollaborationGroupMemberRequest cGrpMem = [Select id From CollaborationGroupMemberRequest];
        cGrpMem.status = 'Accepted';
        update cGrpMem;
		pageRef.getParameters().put('target','RequestApprovalDataServer');
        pageRef.getParameters().put('action','get');
        pageRef.getParameters().put('requestId',cGrpMem.Id);
		pageRef.getParameters().put('type','privateSiteAccess');
        Test.setCurrentPage(pageRef);
    	RequestApprovalDataServer serverObj = new RequestApprovalDataServer();
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','Approve');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','Reject');
        serverObj.handleRequest();
        
        Test.stopTest();
    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testWhenApprove(){
        Test.startTest();
        PageReference pageRef = Page.DataServerRW;
        CollaborationGroup cgroup =[Select id From CollaborationGroup where Name =: 'RequestApprovalDataServerTest_Grp1'];
        CollaborationGroupMemberRequest cGrpMem = [Select id From CollaborationGroupMemberRequest];
		pageRef.getParameters().put('target','RequestApprovalDataServer');
        pageRef.getParameters().put('action','Approve');
        pageRef.getParameters().put('requestId',cGrpMem.Id);
		pageRef.getParameters().put('type','privateSiteAccess');
        Test.setCurrentPage(pageRef);
    	RequestApprovalDataServer serverObj = new RequestApprovalDataServer();
        serverObj.handleRequest();
        Test.stopTest();
    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testWhenReject(){
        Test.startTest();
        PageReference pageRef = Page.DataServerRW;
        CollaborationGroup cgroup =[Select id From CollaborationGroup where Name =: 'RequestApprovalDataServerTest_Grp1'];
        CollaborationGroupMemberRequest cGrpMem = [Select id From CollaborationGroupMemberRequest];
		pageRef.getParameters().put('target','RequestApprovalDataServer');
        pageRef.getParameters().put('action','Reject');
        pageRef.getParameters().put('requestId',cGrpMem.Id);
		pageRef.getParameters().put('type','privateSiteAccess');
        Test.setCurrentPage(pageRef);
    	RequestApprovalDataServer serverObj = new RequestApprovalDataServer();
        serverObj.handleRequest();
        Test.stopTest();
    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testException() {
        Test.startTest();
        RequestApprovalDataServer serverObj = new RequestApprovalDataServer();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','RequestApprovalDataServer');
        pgRef.getParameters().put('action','###');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        
        pgRef.getParameters().put('action','');
        serverObj.handleRequest();
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    

}