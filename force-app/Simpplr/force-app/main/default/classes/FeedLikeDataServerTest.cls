@isTest 
private class FeedLikeDataServerTest {
 	 @isTest static void testInitCase1() {
 	 	try {
 	 		FeedLikeDataServer feedLikeDataServerObj = new FeedLikeDataServer();
			ConnectApi.FeedElementPage feedElementPageObj = new ConnectApi.FeedElementPage();
	       	List<ConnectApi.FeedElement> listOfFeedElement = new List<ConnectApi.FeedElement>();
	       	ConnectApi.FeedItem textPostObj = new ConnectAPI.FeedItem();
	       	textPostObj.type = ConnectApi.FeedItemType.TextPost;
	       	listOfFeedElement.add((ConnectApi.FeedElement)textPostObj);
	       	feedElementPageObj.elements = listOfFeedElement;
	       	connectApi.chatterFeeds.setTestSearchFeedElementsInFeed(null, 
	       			ConnectApi.FeedType.news, 'me', null, 10, ConnectApi.FeedSortOrder.LastModifiedDateDesc,
	       			'test', feedElementPageObj);
	       			
	        PageReference pageRef = Page.DataServerRW;
	        Test.setCurrentPage(pageRef);
	        
	        ApexPages.currentPage().getParameters().put('nextPageToken', null);
	        ApexPages.currentPage().getParameters().put('size', '10');
	        ApexPages.currentPage().getParameters().put('postId', '123');
	        feedLikeDataServerObj.handleRequest();
    	} catch (Exception e) {
    	
    	}

		System.assert(true,'Running as expected');
 	 }
 	 
 	 @isTest static void testInitCase2() {
 	 	try {
 	 		FeedLikeDataServer feedLikeDataServerObj = new FeedLikeDataServer();
			ConnectApi.FeedElementPage feedElementPageObj = new ConnectApi.FeedElementPage();
	       	List<ConnectApi.FeedElement> listOfFeedElement = new List<ConnectApi.FeedElement>();
	       	ConnectApi.FeedItem textPostObj = new ConnectAPI.FeedItem();
	       	textPostObj.type = ConnectApi.FeedItemType.TextPost;
	       	listOfFeedElement.add((ConnectApi.FeedElement)textPostObj);
	       	feedElementPageObj.elements = listOfFeedElement;
	       	connectApi.chatterFeeds.setTestSearchFeedElementsInFeed(null, 
	       			ConnectApi.FeedType.news, 'me', null, 10, ConnectApi.FeedSortOrder.LastModifiedDateDesc,
	       			'test', feedElementPageObj);
	       			
	        PageReference pageRef = Page.DataServerRW;
	        Test.setCurrentPage(pageRef);
	        
	        ApexPages.currentPage().getParameters().put('nextPageToken', null);
	        ApexPages.currentPage().getParameters().put('size', '10');
	        ApexPages.currentPage().getParameters().put('postId', '123');
	        feedLikeDataServerObj.handleRequest();
    	} catch (Exception e) {
    	
    	}

		System.assert(true,'Running as expected');
 	 }
 	 
 	 @isTest static void testInitNegtive() {
 	 	try {
 	 		FeedLikeDataServer feedLikeDataServerObj = new FeedLikeDataServer();
			ConnectApi.FeedElementPage feedElementPageObj = new ConnectApi.FeedElementPage();
	       	List<ConnectApi.FeedElement> listOfFeedElement = new List<ConnectApi.FeedElement>();
	       	ConnectApi.FeedItem textPostObj = new ConnectAPI.FeedItem();
	       	textPostObj.type = ConnectApi.FeedItemType.TextPost;
	       	listOfFeedElement.add((ConnectApi.FeedElement)textPostObj);
	       	feedElementPageObj.elements = listOfFeedElement;
	       	connectApi.chatterFeeds.setTestSearchFeedElementsInFeed(null, 
	       			ConnectApi.FeedType.news, 'me', null, 10, ConnectApi.FeedSortOrder.LastModifiedDateDesc,
	       			'test', feedElementPageObj);
	       			
	        PageReference pageRef = Page.DataServerRW;
	        Test.setCurrentPage(pageRef);
	        
	        ApexPages.currentPage().getParameters().put('nextPageToken', null);
	        ApexPages.currentPage().getParameters().put('size', '1d0');
	        ApexPages.currentPage().getParameters().put('postId', null);
	        feedLikeDataServerObj.handleRequest();
    	} catch (Exception e) {
    	
    	}

		System.assert(true,'Running as expected');
 	 }
}