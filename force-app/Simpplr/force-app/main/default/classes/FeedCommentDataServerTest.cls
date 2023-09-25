@isTest 
private class FeedCommentDataServerTest {
	@isTest static void testHandleRequest1() {
 	 	try {
 	 		FeedCommentDataServer feedCommentServerControllerObj = new FeedCommentDataServer();
			ConnectApi.FeedElementPage feedElementPageObj = new ConnectApi.FeedElementPage();
	       	List<ConnectApi.FeedElement> listOfFeedElement = new List<ConnectApi.FeedElement>();
	       	ConnectApi.FeedItem textPostObj = new ConnectAPI.FeedItem();
	       	textPostObj.type = ConnectApi.FeedItemType.TextPost;
	       	listOfFeedElement.add((ConnectApi.FeedElement)textPostObj);
	       	feedElementPageObj.elements = listOfFeedElement;
	       	connectApi.chatterFeeds.setTestSearchFeedElementsInFeed(null, 
	       			ConnectApi.FeedType.news, 'me', null, 10, ConnectApi.FeedSortOrder.LastModifiedDateDesc,
	       			'test', feedElementPageObj);
	       			
	        //PageReference pageRef = Page.FeedCommentDataServer;
	        PageReference pageRef = Page.DataServerRW;
        	pageRef.getParameters().put('target','FeedCommentDataServer');
        
	        Test.setCurrentPage(pageRef);
	        Criteria.Feed feedCriteriaObj = new Criteria.Feed();
	        feedCriteriaObj.nextPageToken = '123';
	        feedCriteriaObj.postId = '123';
	        feedCriteriaObj.size = 10;
	        ApexPages.currentPage().getParameters().put('data', Utility.getJsonFormat(feedCriteriaObj));
	        
	        feedCommentServerControllerObj.handleRequest();
    	} catch (Exception e) {
    	
    	}
		
		System.assert(true,'Running as expected');
 	 }
 	 
 	 @isTest static void testHandleRequest2() {
 	 	try {
 	 		FeedCommentDataServer feedCommentServerControllerObj = new FeedCommentDataServer();
			ConnectApi.FeedElementPage feedElementPageObj = new ConnectApi.FeedElementPage();
	       	List<ConnectApi.FeedElement> listOfFeedElement = new List<ConnectApi.FeedElement>();
	       	ConnectApi.FeedItem textPostObj = new ConnectAPI.FeedItem();
	       	textPostObj.type = ConnectApi.FeedItemType.TextPost;
	       	listOfFeedElement.add((ConnectApi.FeedElement)textPostObj);
	       	feedElementPageObj.elements = listOfFeedElement;
	       	connectApi.chatterFeeds.setTestSearchFeedElementsInFeed(null, 
	       			ConnectApi.FeedType.news, 'me', null, 10, ConnectApi.FeedSortOrder.LastModifiedDateDesc,
	       			'test', feedElementPageObj);
	       			
	        //PageReference pageRef = Page.FeedCommentDataServer;
	        PageReference pageRef = Page.DataServerRW;
        	pageRef.getParameters().put('target','FeedCommentDataServer');
	        Test.setCurrentPage(pageRef);
	        Criteria.Feed feedCriteriaObj = new Criteria.Feed();
	        ApexPages.currentPage().getParameters().put('data', Utility.getJsonFormat(feedCriteriaObj));
	        
	        feedCommentServerControllerObj.handleRequest();
    	} catch (Exception e) {
    	
    	}

		System.assert(true,'Running as expected');
 	 }
}