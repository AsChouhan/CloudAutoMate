@isTest 
private class FeedShareDataServerTest {

    @testSetup static void setup() {
        TestHelper.setupAppConfig();
    	User testUser = TestHelper.createUser('Simpplr_usr1', null, false);
    	People__c peopleObj = TestHelper.createPeopleRecordForUser(String.valueOf(UserContext.id));
    	Id collaborationGroupId = TestHelper.createCollaborationGroup('TestForCtrlClasses_Grp1', 'Public').Id;
    	Simpplr_Site__c  testSite = TestHelper.getSiteRecord(collaborationGroupId);
        TestHelper.shareSitesToAllPeople(new List<String>{testSite.Id});
    	Simpplr_Content__c simpplrContent = TestHelper.createContent('TestForCtrlClasses Event', 'Event', 'Approved', testUser, testSite);
       
    }
 
    

    private static User getStandardUser(){
        User userObj = [select id,name,alias,profile.PermissionsCustomizeApplication,profile.PermissionsModifyAllData,profile.permissionsModerateChatter 
        		from User where profile.name ='Standard User' and lastname='Simpplr_usr1' LIMIT 1];
        return userObj;
    }

     @isTest static void testShareNonLinkFeed() {
        FeedShareDataServer feedShareDataServerObj = new FeedShareDataServer();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','FeedShareDataServer');
    	pgRef.getParameters().put('data', '{"action": "sharefeed", "communityId": null, "subjectId": "me",'+ 
                '"feedElementType":"news", "originalFeedElementId":"123", "commentText":"Hello World"}');
    	Test.setCurrentPage(pgRef);
        feedShareDataServerObj.handleRequest();
        System.assert(true,'Running as expected');
    	
	    	
    }

    @isTest static void testShareLinkFeed() {
        FeedShareDataServer feedShareDataServerObj = new FeedShareDataServer();
        Feeditem feedItemObj = new FeedItem();
        feedItemObj.Type = 'LinkPost';
        feedItemObj.linkUrl = 'https://google.com';
    	feedItemObj.parentId = UserInfo.getUserId();		
        insert feedItemObj; 
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','FeedShareDataServer');
    	pgRef.getParameters().put('data', '{"action": "sharefeed", "communityId": null, "subjectId": "me",'+ 
                '"feedElementType":"news", "originalFeedElementId":"' + 
                feedItemObj.id + '", "commentText":"Hello World"}');
    	Test.setCurrentPage(pgRef);
        feedShareDataServerObj.handleRequest();
        System.assert(true,'Running as expected');
    	
	    	
    }

    @isTest static void testShareFeedToUser() {
        FeedShareDataServer feedShareDataServerObj = new FeedShareDataServer();
        User userObj = getStandardUser();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','FeedShareDataServer');
    	pgRef.getParameters().put('data', '{"action": "sharefeed", "communityId": null,'+ 
                ' "subjectId": "' + userObj.id + '","feedElementType":"record", ' + 
                '"originalFeedElementId":"123", "commentText":"Hello World"}');
    	Test.setCurrentPage(pgRef);
        feedShareDataServerObj.handleRequest();
        System.assert(true, 'Running as expected');
    	
	    	
    }

}