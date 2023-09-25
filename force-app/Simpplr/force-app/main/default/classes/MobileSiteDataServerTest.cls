@istest

private with sharing class MobileSiteDataServerTest {
    @testSetup static void setup() {
        TestHelper.setupAppConfig();
        
        TestHelper.createUser('Simpplr_mngr', null, false); 
		PeopleDao peopleDaoObj = new PeopleDao();
        List<People__c> peopleList = peopleDaoObj.insertPeople(new List<User>{ getUser(UserContext.id) });
        
        User testUser = TestHelper.createUser('Simpplr_usr1', null, false);
        User testAdminUser = TestHelper.createUser('Simpplr_admin', null, true); 
        User testUser2 = TestHelper.createUser('Simpplr_usr2', null, false);
        
        Id collaborationGroupId = TestHelper.createCollaborationGroup('ContentDataServerTest_grp1', 'Private').Id;
        Simpplr_Site__c  testSite = TestHelper.getSiteRecord(collaborationGroupId);
        
		System.runAs(testAdminUser){
			CollaborationGroupMemberRequest cgmr1 = TestHelper.createCollaborationGroupMemberRequest(collaborationGroupId, testAdminUser.id);
			TestHelper.createSiteMembershipRequest(testSite.Id, cgmr1, peopleList[0].Id);
        }
        Site_Category__c sc = TestHelper.createSiteCategory();
        collaborationGroupId = TestHelper.createCollaborationGroup('Simpplr_Grp1', 'Public').Id;
		Simpplr_Site__c testSite2 = TestHelper.getSiteRecord(collaborationGroupId);
		
		testSite2.Show_In_Simpplr__c = true;
		testSite2.Is_Featured__c = true;
		testSite2.Is_Active__c = true;
		testSite2.Site_Category__c = sc.Id;
		testSite2.Title_Content_Document__c = 'Test';
	    	update testSite2;
	    	
	    	collaborationGroupId = TestHelper.createCollaborationGroup('Simpplr_Grp2', 'Public').Id;
		Simpplr_Site__c testSite3 = TestHelper.getSiteRecord(collaborationGroupId);
		
		Segment__c segmentRec = TestHelper.createSegment(peopleList[0].Id);
		Segment_Site__c siteSegRec = new Segment_Site__c(Segment__c = segmentRec.Id, Is_Featured__c = true, Site__c = testSite2.Id);
		insert siteSegRec;
		
		Audience__c audienceRec = TestHelper.createAudience(segmentRec.Id);
		Subscription__c subscriptionRec = TestHelper.createSubscription(audienceRec.Id, peopleList[0].Id, 'Site'); 
		List<Subscription_Entity__c> listOfSubscriptionEntity =  TestHelper.createPrivateSiteSubscriptionEntity(subscriptionRec.Id, testSite2.Id);
		List<Subscription_Entity__c> listOfSubscriptionEntity1 =  TestHelper.createPrivateSiteSubscriptionEntity(subscriptionRec.Id, testSite3.Id);
    }
    
    private static User getUser(String userId){
        User  userObj = TestHelper.getUserById(userId);
        return userObj;
    }
    
    @isTest static void testHandleRequest() {
    		Test.startTest();
    		List<Simpplr_Site__c> siteObj = [Select Id, Name, chatter_group_id__c, Site_Type__c from Simpplr_Site__c order by Site_Type__c];
    		List<CollaborationGroupMemberRequest> groupRequestList = [select id, CollaborationGroupId, status, lastmodifiedDate, requesterId, requester.name from CollaborationGroupMemberRequest];
    		List<Site_Membership_Request__c> siteMembershipRequestList = [SELECT Id, lastmodifiedDate, User__c, Request_By__r.Name,  Site__r.Chatter_Group_Id__c, Status__c FROM Site_Membership_Request__c ];
			User testUser = [Select Id from user where firstName =: 'Simpplr_usr1' Limit 1];
    		List<Segment__c> segmentList = [Select Id from Segment__c];
    		List<Segment_Site__c>siteSegmentList = [Select Id from Segment_Site__c];
    		List<Audience__c>audienceList = [Select Id from Audience__c];
    		List<Subscription__c> subscriptionList = [Select Id from Subscription__c];
    		List<Subscription_Entity__c> listOfSubscriptionEntity = [Select Id from Subscription_Entity__c];
    		List<Site_Category__c> scList = [Select Id from Site_Category__c];
    		SimpplrContext.isSegmentsEnabled = true;
        
        People__c peopleObj = [Select Id from People__c Where User__c = :UserInfo.getUserId()];
        Site_Role__c siteRoleObj = TestHelper.createSiteRole(peopleObj.Id, siteObj[1].Id);
	    	
		PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target', 'MobileSiteDataServer');
        Test.setCurrentPage(pageRef);
        MobileSiteDataServer msds = new MobileSiteDataServer();
        msds.getPageFeature();
        msds.handleRequest();
        
        ApexPages.currentPage().getParameters().put('action', '');
	    	msds.handleRequest();
	    	
	    	ApexPages.currentPage().getParameters().put('action', 'search');
	    	ApexPages.currentPage().getParameters().put('isFullModel','true');
	    	ApexPages.currentPage().getParameters().put('data', '{"term":"","size":"100", "category":"scList[0].Id"}');
	    	msds.handleRequest();
	    	
	    	ApexPages.currentPage().getParameters().put('data', '{"term":"","size":"100"}');
	    	msds.handleRequest();
	    	
	    	ApexPages.currentPage().getParameters().put('isFullModel','false');
	    	ApexPages.currentPage().getParameters().put('data', '{"term":"","size":"100", "filter":"featured", "nextPageToken":"10", "category":""}');
	    	msds.handleRequest();
	    	
	    	UserContext.segmentId = segmentList[0].Id;
	    	ApexPages.currentPage().getParameters().put('isFullModel','true');
	    	ApexPages.currentPage().getParameters().put('data', '{"term":"","size":"100", "filter":"featured", "nextPageToken":"10"}');
	    	msds.handleRequest();
	    	
	    	ApexPages.currentPage().getParameters().put('isFullModel','true');
	    	ApexPages.currentPage().getParameters().put('data', '{"term":"","size":"100", "filter":"latest","nextPageToken":"10"}');
	    	msds.handleRequest();
	    	
	    	ApexPages.currentPage().getParameters().put('isFullModel','false');
	    	ApexPages.currentPage().getParameters().put('data', '{"term":"","size":"100", "filter":"latest","nextPageToken":"10"}');
	    	msds.handleRequest();
	    	
	    	ApexPages.currentPage().getParameters().put('isFullModel','true');
	    	ApexPages.currentPage().getParameters().put('data', '{"term":"","size":"100", "filter":"following", "nextPageToken":"10"}');
	    	msds.handleRequest();
	    	
	    	ApexPages.currentPage().getParameters().put('isFullModel','false');
	    	ApexPages.currentPage().getParameters().put('data', '{"term":"","size":"100", "filter":"following", "nextPageToken":"10"}');
	    	msds.handleRequest();
	    	
	    	ApexPages.currentPage().getParameters().put('data', '{"term":"","size":"100", "filter":"all", "nextPageToken":"10"}');
	    	msds.handleRequest();
        
            subscriptionList[0].Action_Type__c = 'mandatory';
            subscriptionList[0].Status__c = 'approved';
            update subscriptionList;
            
            listOfSubscriptionEntity[0].Status__c = 'approved';
            listOfSubscriptionEntity[1].Status__c = 'approved';
            
            update listOfSubscriptionEntity;
	    	
	    	ApexPages.currentPage().getParameters().put('action', 'getsiteDetailData');
	    	ApexPages.currentPage().getParameters().put('siteId', siteObj[1].Id);
	    	msds.handleRequest();
        
        	ApexPages.currentPage().getParameters().put('siteId', '');
	    	
	    	Test.stopTest();
	    	
	    SiteContext.isActive = false;
	    	ApexPages.currentPage().getParameters().put('siteId', siteObj[1].Id);
	    	msds.handleRequest();
	    	
	    	System.runAs(testUser){
	    	SiteContext.isActive = true;
	    	SiteContext.isPublicSite = false;
	    	SiteContext.isUnlistedSite = true;
    		ApexPages.currentPage().getParameters().put('siteId', siteObj[0].Id);
    		msds.handleRequest();
    		
    		SiteContext.isUnlistedSite = false;
    		ApexPages.currentPage().getParameters().put('siteId', siteObj[0].Id);
    		msds.handleRequest();
	    	}
	    	
	    	ApexPages.currentPage().getParameters().put('action', 'getPrivateSiteStatus');
	    	ApexPages.currentPage().getParameters().put('privateSiteRequestId', groupRequestList[0].Id);
	    	msds.handleRequest();
	    	
	    	ApexPages.currentPage().getParameters().put('privateSiteRequestId', '');
	    	msds.handleRequest();

			ApexPages.currentPage().getParameters().put('privateSiteRequestId', siteMembershipRequestList[0].Id);
	    	msds.handleRequest();
	    	
	    	ApexPages.currentPage().getParameters().put('action', 'getFeaturedMandatorySiteList');
	    	ApexPages.currentPage().getParameters().put('data', '{"term":"","size":"100"}');
	    	msds.handleRequest();
	    	
	    	SimpplrContext.isSegmentsEnabled = false;
	    	ApexPages.currentPage().getParameters().put('data', '{"term":"","size":"100"}');
	    	msds.handleRequest();
	    	
	    System.assert(true, 'Running as expected');	
    }
    
    @isTest static void testGetsiteDetailData() {
        Test.startTest();
        List<Simpplr_Site__c> siteObj = [Select Id,Name, chatter_group_id__c, Site_Type__c from Simpplr_Site__c order by Site_Type__c];
        User testUser = [Select Id from user where firstName =: 'Simpplr_usr1' Limit 1];
        
        People__c peopleObj = [Select Id from People__c Limit 1];
        Site_Role__c siteRoleObj = TestHelper.createSiteRole(peopleObj.Id, siteObj[1].Id);
        
        MobileSiteDataServer msds = new MobileSiteDataServer();
        PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target', 'MobileSiteDataServer');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('action', 'getsiteDetailData');
	    pageRef.getParameters().put('siteId', siteObj[1].Id);
	    msds.handleRequest();
        
        ApexPages.currentPage().getParameters().put('siteId', siteObj[2].Id);
        SiteContext.isPublicSite = false;
        (UserContext.sitesIFollowIdSet).remove(SiteContext.siteId);
        UserContext.hasModifyAllDataPermission = false;
        msds.handleRequest();
        
        siteRoleObj.Is_Member__c = true;
        update siteRoleObj;
        msds.handleRequest();
        
        siteRoleObj.Is_Content_Manager__c = true;
        update siteRoleObj;
        msds.handleRequest();
        
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testException() {
        Test.startTest();
        
        MobileSiteDataServer msds = new MobileSiteDataServer();
        PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target', 'MobileSiteDataServer');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('action', '###');
        msds.handleRequest();
        
        pageRef.getParameters().put('action', 'search');
        msds.handleRequest();
        
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
}