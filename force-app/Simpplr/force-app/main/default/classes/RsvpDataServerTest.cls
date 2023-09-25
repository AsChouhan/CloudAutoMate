@isTest
private class RsvpDataServerTest {
	private static App_Config__c appConfigRecord;
	private static User systemAdmin;
	private static User siteOwnr;
	private static User siteMember;
	private static User managerOfsiteMember;
	private static CollaborationGroup cgroup;
	private static Simpplr_Content__c simpplrContent;
	private static Simpplr_Content__c simpplrContentForScore;
	private static Simpplr_Site__c site;
	
	@isTest static void testHandleRequest() {
        
        appConfigRecord = TestHelper.setupAppConfig();
		People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
        TestHelper.createPeoplePreference(peopleObj.id);
		systemAdmin = TestHelper.createUser('RedirectionServer_admin1', null, true);
		siteOwnr = TestHelper.createUser('RedirectionServer_siteOwnr1', null, false);
		managerOfsiteMember = TestHelper.createUser('RedirectionServer_userMngr1', null, false);
		siteMember = TestHelper.createUser('RedirectionServer_siteMmbr1', managerOfsiteMember, false);
		cgroup = TestHelper.createCollaborationGroup('RedirectionServer_Grp12','Public');
		TestHelper.createCollaborationGroupMember(cgroup.Id, siteOwnr.id,'Admin');
		TestHelper.changeCollaborationGroupOwner(cgroup.id, siteOwnr.Id);
		site = TestHelper.getSiteRecord(cgroup.Id);
        simpplrContent = TestHelper.createContent('RSVPDataServerTest Event1', 'Event', 'Approved', systemAdmin, site);

        List<People__c> peopleList = [SELECT Id FROM People__c WHERE User__c = :siteMember.id];
        TestHelper.createRSVPResponse(simpplrContent.Id, peopleList[0].Id, 'Yes');
        
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','RsvpDataServer');
        Test.setCurrentPage(pageRef);
        RsvpDataServer RsvpDataServerObj= new RsvpDataServer();
        RsvpDataServerObj.getPageFeature();
      	
        pageRef.getParameters().put('siteId',site.id);
        String data = '{"id":"'+simpplrContent.id+'","choice":"Yes","note":""}';
        pageRef.getParameters().put('data',data);
        pageRef.getParameters().put('action','save');
        Test.setCurrentPage(pageRef);
        RsvpDataServerObj.handleRequest();
        data = '{"id":"'+simpplrContent.id+'","choice":"Yes","note":"Hello"}';
        pageRef.getParameters().put('data',data);
        RsvpDataServerObj.handleRequest();
        System.assertEquals('success', RsvpDataServerObj.response.status, 'Running as expected');   
        
        pageRef.getParameters().put('siteId',site.id);
        data = simpplrContent.id+'';
        pageRef.getParameters().put('data',data);
        pageRef.getParameters().put('action','getRecord');
        Test.setCurrentPage(pageRef);
        RsvpDataServerObj.handleRequest();
        System.assertEquals('success', RsvpDataServerObj.response.status, 'Running as expected');   

        data = '{"contentId":"'+simpplrContent.id+'","peopleIds":["'+peopleList[0].Id+'"],"note":"Hello you are removed"}';
        pageRef.getParameters().put('siteId', site.id);
        pageRef.getParameters().put('data', data);
        pageRef.getParameters().put('action','deleteAttending');
        Test.setCurrentPage(pageRef);
        RsvpDataServerObj.handleRequest();
        System.assertEquals('success', RsvpDataServerObj.response.status, 'Running as expected');   
        
        TestHelper.createRSVPResponse(simpplrContent.Id, peopleList[0].Id, 'Yes');
        data = '{"contentId":"'+simpplrContent.id+'","peopleIds":["'+peopleList[0].Id+'"],"note":""}';
        pageRef.getParameters().put('data', data);
        RsvpDataServerObj.handleRequest();
        System.assertEquals('success', RsvpDataServerObj.response.status, 'Running as expected');   
        
        pageRef.getParameters().put('action','');
        Test.setCurrentPage(pageRef);
        RsvpDataServerObj.handleRequest();
        System.assertEquals('error', RsvpDataServerObj.response.status, 'action is missing');
        RsvpDataServerObj.dateToDisplayString(DateTime.now(), 'MMM dd, yyyy\' at \'hh:mm aa');
        System.assert(true,'Running as expected');
    }
    
}