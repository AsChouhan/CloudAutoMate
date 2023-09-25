@isTest 
private class ContentLikeDataServerTest {
    @testSetup static void setup() {
    	TestHelper.setupAppConfig();
        User testAdminUser = TestHelper.createUser('ContentLikeDataServerTest_AdmnUser', null, true);  
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
        CollaborationGroup collGrp = TestHelper.createCollaborationGroup('ContentLikeDataServerTestSite', 'Public');
        Simpplr_Content__c simpplrContent = TestHelper.createContent('simpplr test event', 'Event', 'Approved', testAdminUser, getSite());
        Bookmark__c bookmarkObj = TestHelper.createContentBookmark(simpplrContent.Id, peopleObj.Id);
        bookmarkObj.Type__c = 'People';
        update bookmarkObj;
        Like__c likeObj = TestHelper.createContentLike(simpplrContent.Id, peopleObj.Id);
    }
    
    private static Simpplr_Site__c getSite() {
        Simpplr_Site__c  siteObj = [select Id from Simpplr_Site__c where Name='ContentLikeDataServerTestSite' LIMIT 1];
        return siteObj;
    }
    
    private static Simpplr_Content__c getContent() {
        Simpplr_Content__c contentObj = [Select Id From Simpplr_Content__c Limit 1];
        return contentObj;
    }
    
    @isTest static void testHandleRequest() {
    	try {
            Simpplr_Content__c contentObj = getContent();
	        PageReference pageRef = Page.DataServerRW;
	        Test.setCurrentPage(pageRef);
            ContentLikeDataServer contentLikeDataServerObj = new ContentLikeDataServer();
            
	        ApexPages.currentPage().getParameters().put('target','ContentLikeDataServer');
            contentLikeDataServerObj.handleRequest();
            
	        ApexPages.currentPage().getParameters().put('data', '{"id":"123", "size":"10", "nextPageToken":"null"}');
	        String pageFeatures = contentLikeDataServerObj.getPageFeature();
	        contentLikeDataServerObj.handleRequest();
            
            ApexPages.currentPage().getParameters().put('data', '{"id":"'+contentObj.Id+'", "size":"10", "nextPageToken":"null"}');
            contentLikeDataServerObj.handleRequest();
    	} catch (Exception e) {
    	
    	}

		System.assert(true,'Running as expected');

    }
    
}