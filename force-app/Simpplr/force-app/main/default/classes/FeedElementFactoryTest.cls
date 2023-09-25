public with sharing class FeedElementFactoryTest {
    public static void createFeedElementPageRecord (String feedTypeArg, Integer pageSizeArg) {
       	ConnectApi.FeedElementPage feedElementPageObj = new ConnectApi.FeedElementPage();
       	List<ConnectApi.FeedElement> listOfFeedElement = new List<ConnectApi.FeedElement>();
       	
       	/**TextPost Type Feed**/
       	ConnectApi.FeedItem textPostObj = new ConnectAPI.FeedItem();
       	textPostObj.type = ConnectApi.FeedItemType.TextPost;
       	listOfFeedElement.add((ConnectApi.FeedElement)textPostObj);
       	feedElementPageObj.elements = listOfFeedElement;
       	connectApi.chatterFeeds.setTestGetFeedElementsFromFeed(null, ConnectApi.FeedType.news, 'me', null, 
        		pageSizeArg, ConnectApi.FeedSortOrder.LastModifiedDateDesc, feedElementPageObj);
        		
    }

	public static void createFeedElementPageRecordForFeedItemType (String feedTypeArg, String feedItemType, Integer pageSizeArg) {
       	ConnectApi.FeedElementPage feedElementPageObj = new ConnectApi.FeedElementPage();
       	List<ConnectApi.FeedElement> listOfFeedElement = new List<ConnectApi.FeedElement>();
       	
       	ConnectApi.FeedItem feedItemObj = new ConnectAPI.FeedItem();
		if('LinkPost'.equalsIgnoreCase(feedItemType)) {
       		feedItemObj.type = ConnectApi.FeedItemType.TextPost;
		} else if('TextPost'.equalsIgnoreCase(feedItemType)) {
			feedItemObj.type = ConnectApi.FeedItemType.LinkPost;
		} else if('PollPost'.equalsIgnoreCase(feedItemType)) {
			feedItemObj.type = ConnectApi.FeedItemType.PollPost;
		}

       	listOfFeedElement.add((ConnectApi.FeedElement)feedItemObj);
       	feedElementPageObj.elements = listOfFeedElement;
       	connectApi.chatterFeeds.setTestGetFeedElementsFromFeed(null, ConnectApi.FeedType.news, 'me', null, 
        		pageSizeArg, ConnectApi.FeedSortOrder.LastModifiedDateDesc, feedElementPageObj);
        		
    }

	public static void createFeedElementPageRecordWithFeedDensity () {
       	ConnectApi.FeedElementPage feedElementPageObj = new ConnectApi.FeedElementPage();
       	List<ConnectApi.FeedElement> listOfFeedElement = new List<ConnectApi.FeedElement>();
       	
       	/**TextPost Type Feed**/
       	ConnectApi.FeedItem feedItemObj = new ConnectAPI.FeedItem();
       	feedItemObj.type = ConnectApi.FeedItemType.TextPost;
       	listOfFeedElement.add((ConnectApi.FeedElement)feedItemObj);
       	feedElementPageObj.elements = listOfFeedElement;
       	connectApi.chatterFeeds.setTestGetFeedElementsFromFeed(null, ConnectApi.FeedType.news, 
                'me', 3, ConnectApi.FeedDensity.AllUpdates, null, 10, 
                ConnectApi.FeedSortOrder.LastModifiedDateDesc, feedElementPageObj);	
        connectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(null, ConnectApi.FeedType.COMPANY, 
                3, ConnectApi.FeedDensity.AllUpdates, null, 10, 
                ConnectApi.FeedSortOrder.LastModifiedDateDesc, feedElementPageObj);
        connectApi.ChatterFeeds.setTestSearchFeedElementsInFeed(null, ConnectApi.FeedType.news, 'me', 3, 
                ConnectApi.FeedDensity.AllUpdates, null, 10, 
                ConnectApi.FeedSortOrder.LastModifiedDateDesc, '*test*', feedElementPageObj);
        
    }
    
     public static void createFeedElementPageRecordForSpecifiedFeed (String feedTypeArg,
     		ConnectApi.FeedElement feedElemObjArg) {
     			
       	ConnectApi.FeedElementPage feedElementPageObj = new ConnectApi.FeedElementPage();
       	List<ConnectApi.FeedElement> listOfFeedElement = new List<ConnectApi.FeedElement>();
       	listOfFeedElement.add(feedElemObjArg);
       	feedElementPageObj.elements = listOfFeedElement;
       	
       	connectApi.chatterFeeds.setTestGetFeedElementsFromFeed(null, ConnectApi.FeedType.news, 'me', null, 
        		10, ConnectApi.FeedSortOrder.LastModifiedDateDesc, feedElementPageObj); 
        		
    }
    
    public static ConnectApi.FeedElementPage getFeedElementPageObject (String feedTypeArg) {
    	return ConnectApi.ChatterFeeds.getFeedElementsFromFeed(null, ConnectApi.FeedType.News,
    			'me', null, 10, ConnectApi.FeedSortOrder.LastModifiedDateDesc);
    }
}